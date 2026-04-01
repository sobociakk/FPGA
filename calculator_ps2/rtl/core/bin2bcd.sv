`timescale 1ns / 1ps

module bin2bcd(
    input logic [13:0] bin_i,
    output logic [15:0] bcd_o
);
    // double dabble
    always_comb begin
        bcd_o = '0;
    
        for(int i = 13; i >= 0; i --) begin
            if(bcd_o[3:0] >= 5) begin
                bcd_o[3:0] = bcd_o[3:0] + 3;
            end

            if(bcd_o[7:4] >= 5) begin
                bcd_o[7:4] = bcd_o[7:4] + 3;
            end

            if(bcd_o[11:8] >= 5) begin
                bcd_o[11:8] = bcd_o[11:8] + 3;
            end

            if(bcd_o[15:12] >= 5) begin
                bcd_o[15:12] = bcd_o[15:12] + 3;
            end

            bcd_o = {bcd_o[14:0], bin_i[i]};
        end
    end

endmodule