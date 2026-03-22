file mkdir syn/out

set rtl_dirs {
    rtl/core
    rtl/top
    rtl/packages
}

foreach dir $rtl_dirs {
    set files [glob -nocomplain "$dir/*.sv"]
    if {[llength $files] > 0} {
        puts "Reading files from $dir: $files"
        read_verilog -sv $files
    } else {
        puts "No .sv files found in $dir, skipping..."
    }
}

set xdc_files [glob -nocomplain "constraints/*.xdc"]
if {[llength $xdc_files] > 0} {
    puts "Reading constraints: $xdc_files"
    read_xdc $xdc_files
} else {
    puts "Warning: No constraints (.xdc) found. Timing analysis will be skipped."
}

synth_design -top rtc_top -part xc7a35tcpg236-1

report_utilization -file syn/out/utilization.txt
report_timing_summary -file syn/out/timing.txt