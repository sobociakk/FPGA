`timescale 1ns / 1ps

module fifo #(
    parameter int DATA_WIDTH = 8,
                  DEPTH = 16
)(
    input logic clk_i,
    input logic rst_ni,
    input logic wr_en_i,
    input logic [DATA_WIDTH-1:0] wr_data_i,
    input logic rd_en_i,

    output logic [DATA_WIDTH-1:0] rd_data_o,
    output logic full_o,
    output logic empty_o
);

logic [DATA_WIDTH-1:0] mem_q [0:DEPTH-1];

localparam int PTR_WIDTH = $clog2(DEPTH);

logic [PTR_WIDTH-1:0] wr_ptr_q, wr_ptr_d;
logic [PTR_WIDTH-1:0] rd_ptr_q, rd_ptr_d;
logic [PTR_WIDTH:0] count_q, count_d;

always_ff @(posedge clk_i, negedge rst_ni) begin
    if(!rst_ni) begin
        wr_ptr_q <= '0;
        rd_ptr_q <= '0;
        count_q <= '0;
    end else begin
        wr_ptr_q <= wr_ptr_d;
        rd_ptr_q <= rd_ptr_d;
        count_q <= count_d;
        if(wr_en_i == 1'b1 && !full_o) begin
            mem_q[wr_ptr_q] <= wr_data_i;
        end
    end
end

always_comb begin
    wr_ptr_d = wr_ptr_q;
    rd_ptr_d = rd_ptr_q;
    count_d = count_q;

    full_o = (count_q == DEPTH);
    empty_o = (count_q == '0);

    rd_data_o = mem_q[rd_ptr_q];

    if(wr_en_i == 1'b1 && !full_o) begin
        wr_ptr_d = wr_ptr_q + 1'b1;
    end
    if(rd_en_i == 1'b1 && !empty_o) begin
        rd_ptr_d = rd_ptr_q + 1'b1;
    end
    if(wr_en_i == 1'b1 && rd_en_i == 1'b1) begin
        count_d = count_q;
    end else if(wr_en_i == 1'b1 && !full_o) begin
        count_d = count_q + 1'b1;
    end else if (rd_en_i == 1'b1 && !empty_o) begin
        count_d = count_q - 1'b1;
    end
end

endmodule