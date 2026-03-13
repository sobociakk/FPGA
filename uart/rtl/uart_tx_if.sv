`timescale 1ns / 1ps

interface uart_tx_if();
    logic valid;
    logic ready;
    logic [7:0] data;

    modport host_mp (        // device sending data
        input ready,

        output valid, 
        output data
    ); 
    
    modport mac_mp(         // tx module 
        input valid, 
        input data, 
        
        output ready
    );     
    
endinterface
