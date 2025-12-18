module transmitter(input logic clk, rstn,  
                   input logic [7:0] data_in,
                   input logic tx_enb,
                   input logic wr_enb,
                   output logic tx,
                   output logic busy);

typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_tx;
state_tx current_state, next_state;

  logic [2:0] bit_counter;
  logic [7:0] shift_reg;

  always @(posedge clk) begin
    if (!rstn) 
      current_state <= IDLE;
    else if(tx_enb)
      current_state <= next_state;
  end

  always_ff@ (posedge clk or negedge rstn) begin
    if(!rstn) begin
      bit_counter = 3'd0;
      shift_reg = 8'd0;
    end 
    
    else if(current_state == IDLE && wr_enb)begin
    shift_reg <= data_in;
    bit_counter <= 3'd0;
    end
    
    else if(current_state == DATA && tx_enb) begin
      bit_counter <= bit_counter + 1'b1;
      shift_reg <= shift_reg >> 1;
    end 
  end
  
  always_comb begin
    case (current_state) 
      IDLE: if(wr_enb) 
        next_state <= START;
      
      START: if(tx_enb)
        next_state <= DATA;

      DATA: if(tx_enb && bit_counter == 3'd7)
          next_state <= STOP;

      STOP: if(tx_enb)
          next_state <= IDLE;
    endcase
  end

    always_comb begin
      tx = 1'b1;
      case (current_state)
        START: tx = 1'b0;
        DATA: tx = shift_reg[0];
        STOP: tx = 1'b1;
      endcase
    end
    
  assign busy = (current_state != IDLE);
    endmodule 
