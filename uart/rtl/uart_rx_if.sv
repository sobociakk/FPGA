`timescale 1ns / 1ps

interface uart_rx_if();
    logic valid;
    logic ready;
    logic [7:0] data;

    modport host_mp(   
        input valid,
        input data,

        output ready
    );

    modport mac_mp(
        input ready,

        output valid,
        output data
    );

endinterface