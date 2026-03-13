module uart_tx #(
    parameter DBITS = 8,          // liczba bitów danych
    parameter SB_TICK = 16        // liczba ticków dla bitu stopu (16 = 1 bit stopu)
)(
    input  logic               clk,          // zegar systemowy (np. 100MHz)
    input  logic               rst,          // reset (asynchroniczny w tym przykładzie)
    input  logic               tx_start,     // sygnał rozpoczęcia nadawania
    input  logic               sample_tick,  // impulsy z generatora baud rate
    input  logic [DBITS-1:0]   data_in,      // dane do wysłania

    output logic               tx_done,      // flaga zakończenia transmisji
    output logic               tx            // linia danych wyjściowych UART
);

    // Definicja stanów za pomocą typu wyliczeniowego (SystemVerilog enum)
    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b10,
        STOP  = 2'b11
    } state_e;

    state_e state, next_state;

    // Rejestry wewnętrzne (używamy logic zamiast reg)
    logic [3:0]       tick_reg, tick_next;     // licznik ticków (oversampling)
    logic [2:0]       nbits_reg, nbits_next;   // licznik wysłanych bitów
    logic [DBITS-1:0] data_reg, data_next;     // rejestr przesuwny danych
    logic             tx_reg, tx_next;         // rejestr wyjściowy (zapobiega glitchom)

    // Logika sekwencyjna (Sequential Logic)
    // Zgodnie ze standardem używamy always_ff dla przerzutników 
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= IDLE;
            tick_reg  <= 4'b0;
            nbits_reg <= 3'b0;
            data_reg  <= '0;      // SystemVerilog '0 wypełnia zerami niezależnie od szerokości [cite: 23]
            tx_reg    <= 1'b1;    // Stan spoczynkowy UART to logiczna 1
        end else begin
            state     <= next_state;
            tick_reg  <= tick_next;
            nbits_reg <= nbits_next;
            data_reg  <= data_next;
            tx_reg    <= tx_next;
        end
    end

    // Logika kombinacyjna (Combinational Logic)
    // Zgodnie ze standardem używamy always_comb [cite: 33]
    always_comb begin
        // Wartości domyślne (zapobiegają latchom)
        next_state = state;
        tx_done    = 1'b0;
        tick_next  = tick_reg;
        nbits_next = nbits_reg;
        tx_next    = tx_reg;
        data_next  = data_reg;

        case (state)
            IDLE: begin
                tx_next = 1'b1;
                if (tx_start) begin
                    next_state = START;
                    tick_next  = 4'b0;
                    data_next  = data_in;
                end
            end

            START: begin
                tx_next = 1'b0; // Bit startu (zawsze 0)
                if (sample_tick) begin
                    if (tick_reg == 4'd15) begin
                        next_state = DATA;
                        tick_next  = 4'b0;
                        nbits_next = 3'b0;
                    end else begin
                        tick_next = tick_reg + 1'b1;
                    end
                end
            end

            DATA: begin
                tx_next = data_reg[0]; // Nadawanie LSB (Least Significant Bit)
                if (sample_tick) begin
                    if (tick_reg == 4'd15) begin
                        tick_next = 4'b0;
                        data_next = data_reg >> 1; // Przesunięcie w prawo
                        if (nbits_reg == (DBITS - 1))
                            next_state = STOP;
                        else
                            nbits_next = nbits_reg + 1'b1;
                    end else begin
                        tick_next = tick_reg + 1'b1;
                    end
                end
            end

            STOP: begin
                tx_next = 1'b1; // Bit stopu (zawsze 1)
                if (sample_tick) begin
                    if (tick_reg == (SB_TICK - 1)) begin
                        next_state = IDLE;
                        tx_done    = 1'b1;
                    end else begin
                        tick_next = tick_reg + 1'b1;
                    end
                end
            end
            
            // Dobre praktyki wymagają default w FSM
            default: next_state = IDLE;
        endcase
    end

    // Przypisanie wyjścia
    assign tx = tx_reg;

endmodule
