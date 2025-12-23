module uartRX(
    input  logic       clk,
    input  logic       rst,
    input  logic       rx,
    input  logic       rdy_clr,
    input  logic       clk_en,
    output logic       ready,
    output logic [7:0] data_out
);

    typedef enum logic [1:0] {START, DATA_OUT, STOP} state_t;
    state_t state, next_state;

    logic [3:0] sample;
    logic [2:0] index;
    logic [7:0] shift_reg;

    always_ff @(posedge clk) begin
        if (rst) begin
            state     <= START;
            sample    <= 4'd0;
            index     <= 3'd0;
            shift_reg <= 8'd0;
            data_out  <= 8'd0;
            ready     <= 1'b0;
        end
        else if (clk_en) begin
            state <= next_state;

            if (rdy_clr)
                ready <= 1'b0;

            sample <= sample + 4'd1;

            case(state)
                START: begin
                    if (sample == 4'd15)
                        sample <= 4'd0;
                end

                DATA_OUT: begin
                    if (sample == 4'd8) begin
                        shift_reg[index] <= rx;
                        index <= index + 3'd1;
                    end
                    if (sample == 4'd15)
                        sample <= 4'd0;
                end

                STOP: begin
                    if (sample == 4'd15) begin
                        data_out <= shift_reg;
                        ready    <= 1'b1;
                        sample   <= 4'd0;
                        index    <= 3'd0;
                    end
                end
            endcase
        end
    end
  
    always_comb begin
        next_state = state;

        case(state)
            START: begin
                if (rx == 1'b0 && sample == 4'd15)
                    next_state = DATA_OUT;
            end

            DATA_OUT: begin
                if (index == 3'd7 && sample == 4'd15)
                    next_state = STOP;
            end

            STOP: begin
                if (sample == 4'd15)
                    next_state = START;
            end
        endcase
    end

endmodule
