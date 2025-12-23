module uart_tb;

  logic clk;
  logic rst;

  uart_top dut();

  initial clk = 0;
  always #5 clk = ~clk;

  assign dut.intf.clk = clk;
  assign dut.intf.rst = rst;

  uart_tx_item tx_item;

  logic [7:0] expected_data;

  task do_reset();
    rst = 1;
    dut.intf.newd = 0;
    #50;
    rst = 0;
  endtask

  task send_byte(input logic [7:0] data);
    wait (dut.intf.donetx == 0);

    dut.intf.dintx = data;
    dut.intf.newd  = 1'b1;
    expected_data  = data;

    @(posedge clk);
    dut.intf.newd = 1'b0;
  endtask

  task check_rx();
    wait (dut.intf.donerx == 1'b1);

    if (dut.intf.doutrx !== expected_data) begin
      $error("FAILED: Expected=%h Received=%h",
              expected_data, dut.intf.doutrx);
    end
    else begin
      $display("PASS: Received %h", dut.intf.doutrx);
    end

    @(posedge clk);
  endtask

  initial begin
    tx_item = new();

    do_reset();

    $display("---- Directed tests ----");

    send_byte(8'h00);  check_rx();
    send_byte(8'hFF);  check_rx();
    send_byte(8'hAA);  check_rx();
    send_byte(8'h55);  check_rx();

    $display("---- Random tests ----");

    repeat (10) begin
      assert(tx_item.randomize());
      send_byte(tx_item.data);
      check_rx();
    end

    $display("---- Back-to-back test ----");

    repeat (5) begin
      assert(tx_item.randomize());
      send_byte(tx_item.data);
      check_rx();
    end

    $display("---- Idle gap test ----");
    #1000;
    send_byte(8'h3C);
    check_rx();

    $finish;
  end

endmodule
