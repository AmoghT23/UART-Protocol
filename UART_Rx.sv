module uart_rx (
  uart_if.uart2 intf,
  input logic clk_en,  
  input logic rdy_clr   
);

  typedef enum logic [1:0] {START, DATA, STOP} state_t;
  state_t state, next_state;

  logic [3:0] sample;
  logic [2:0] index;
  logic [7:0] shift_reg;

  always_ff @(posedge intf.clk or posedge intf.rst) begin
    if (intf.rst) begin
      state        <= START;
      sample       <= 4'd0;
      index        <= 3'd0;
      shift_reg    <= 8'd0;
      intf.doutrx  <= 8'd0;
      intf.donerx  <= 1'b0;
    end
    else if (clk_en) begin
      state <= next_state;

      if (rdy_clr)
        intf.donerx <= 1'b0;

      sample <= sample + 4'd1;

      case (state)
        START: begin
          if (sample == 4'd15)
            sample <= 4'd0;
        end

        DATA: begin
          if (sample == 4'd8) begin
            shift_reg[index] <= intf.rx;
            index <= index + 3'd1;
          end
          if (sample == 4'd15)
            sample <= 4'd0;
        end

        STOP: begin
          if (sample == 4'd15) begin
            intf.doutrx <= shift_reg;
            intf.donerx <= 1'b1;
            sample <= 4'd0;
            index  <= 3'd0;
          end
        end
      endcase
    end
  end

  always_comb begin
    next_state = state;

    case (state)
      START: begin
        if (intf.rx == 1'b0 && sample == 4'd15)
          next_state = DATA;
      end

      DATA: begin
        if (index == 3'd7 && sample == 4'd15)
          next_state = STOP;
      end

      STOP: begin
        if (sample == 4'd15)
          next_state = START;
      end

      default:
        next_state = START;
    endcase
  end

endmodule
