module uart_top;

  logic clk;
  logic rst;

  // Interface instance
  uart_if intf (
    .clk(clk),
    .rst(rst)
  );

  // TX and RX instances
  uart_tx tx_inst ( .intf(intf) );
  uart_rx rx_inst ( .intf(intf) );

  // Loopback connection
  assign intf.rx = intf.tx;

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  // Reset
  initial begin
    rst = 1;
    #20 rst = 0;
  end

endmodule
