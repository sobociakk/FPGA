`timescale 1ns / 1ps

module fifo #(
    parameter DATA_SIZE = 8,          // number of bits in a data word
    parameter ADDR_SPACE_EXP = 4      // number of address bits (2^4 = 16 addresses)
)(
    input  wire clk,                  // FPGA clock
    input  wire reset,                // reset button
    input  wire write_to_fifo,        // signal start writing to FIFO
    input  wire read_from_fifo,       // signal start reading from FIFO
    input  wire [DATA_SIZE-1:0] write_data_in, // data word into FIFO
    
    output wire [DATA_SIZE-1:0] read_data_out, // data word out of FIFO
    output wire empty,                // FIFO is empty
    output wire full                  // FIFO is full
);

    // Parametr pomocniczy wyliczający głębokość FIFO (np. 1 << 4 = 16)
    localparam DEPTH = 1 << ADDR_SPACE_EXP;

    // Pamięć FIFO
    reg [DATA_SIZE-1:0] memory [0:DEPTH-1];
    
    // Wskaźniki zapisu i odczytu - uwaga: są o 1 bit szersze niż adres!
    // Dla ADDR_SPACE_EXP = 4, wskaźniki mają 5 bitów (od [4:0])
    reg [ADDR_SPACE_EXP:0] wr_ptr;
    reg [ADDR_SPACE_EXP:0] rd_ptr;

    // --- Logika Flag (Kombinacyjna) ---
    // Puste: wszystkie bity obu wskaźników są identyczne
    assign empty = (wr_ptr == rd_ptr);
    
    // Pełne: najstarszy bit (MSB) jest różny, ale reszta bitów (adresowych) jest taka sama
    assign full  = (wr_ptr[ADDR_SPACE_EXP] != rd_ptr[ADDR_SPACE_EXP]) && 
                   (wr_ptr[ADDR_SPACE_EXP-1:0] == rd_ptr[ADDR_SPACE_EXP-1:0]);

    // Odczyt asynchroniczny (FWFT - First-Word Fall-Through)
    // Zrzucamy najstarszy bit (MSB), żeby adresować fizyczną pamięć
    assign read_data_out = memory[rd_ptr[ADDR_SPACE_EXP-1:0]];

    // --- Logika Sekwencyjna (Zegarowana) ---
    always @(posedge clk) begin
        if (reset) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
        end else begin
            // Obsługa zapisu
            if (write_to_fifo && !full) begin
                memory[wr_ptr[ADDR_SPACE_EXP-1:0]] <= write_data_in;
                wr_ptr <= wr_ptr + 1'b1;
            end
            
            // Obsługa odczytu
            if (read_from_fifo && !empty) begin
                rd_ptr <= rd_ptr + 1'b1;
            end
        end
    end

endmodule