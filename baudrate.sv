`timescale 1ns/1ps

module baudRate #(parameter int tx_counter = 13,
                  parameter int rx_counter = 10,
                  parameter int tx_div = 5208,
                  parameter int rx_div = 325)
  
  (input clk, rstn,
   output rx_enb, tx_enb);

  logic [(tx_counter-1):0] tx_cnt;
  logic [(rx_counter-1):0] rx_cnt;

  always @(posedge clk or negedge rstn) begin
    if(!rstn)
      tx_cnt <= '0;
    else if(tx_cnt == tx_div-1)
      tx_cnt <= '0;
    else 
      tx_cnt <= tx_cnt + 1'b1;
  end

  always @(posedge clk or negedge rstn) begin
    if(!rstn)
      rx_cnt <= '0;
    else if(rx_cnt == rx_div-1)
      rx_cnt <= '0;
    else 
      rx_cnt <= rx_cnt + 1'b1;
  end

  assign tx_enb = (tx_cnt == 0);
  assign rx_enb = (rx_cnt == 0);
  
endmodule 
  
