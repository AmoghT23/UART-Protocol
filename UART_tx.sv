module transmitter (
  uart_if.uart1 intf,
  input logic tx_enb
);

  typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_tx;
  state_tx current_state, next_state;

  logic [2:0] bit_counter;
  logic [7:0] shift_reg;

  always_ff @(posedge intf.clk or posedge intf.rst) begin
    if (intf.rst)
      current_state <= IDLE;
    else if (tx_enb)
      current_state <= next_state;
  end

  always_ff @(posedge intf.clk or posedge intf.rst) begin
    if (intf.rst) begin
      bit_counter <= 3'd0;
      shift_reg   <= 8'd0;
    end
    else if (current_state == IDLE && intf.newd) begin
      shift_reg   <= intf.dintx;
      bit_counter <= 3'd0;
    end
    else if (current_state == DATA && tx_enb) begin
      shift_reg   <= shift_reg >> 1;
      bit_counter <= bit_counter + 1'b1;
    end
  end

  always_comb begin
    next_state = current_state;

    case (current_state)
      IDLE:
        if (intf.newd)
          next_state = START;

      START:
        if (tx_enb)
          next_state = DATA;

      DATA:
        if (tx_enb && bit_counter == 3'd7)
          next_state = STOP;

      STOP:
        if (tx_enb)
          next_state = IDLE;

      default:
        next_state = IDLE;
    endcase
  end

  always_comb begin
    intf.tx     = 1'b1;
    intf.donetx = 1'b0;

    case (current_state)
      START: intf.tx = 1'b0;
      DATA:  intf.tx = shift_reg[0];
      STOP: begin
        intf.tx     = 1'b1;
        intf.donetx = 1'b1;
      end
    endcase
  end

endmodule
