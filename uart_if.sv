interface uart_if #(
  parameter int clk_rate = 1000000,
  parameter int baud_rate = 9600)
  
  (logic clk, rst,
   logic tx, rx,
   logic [7:0] dintx, doutrx,
   logic newd,
   logic donetx, donerx);
  
  modport uart1(
    input clk, rst,
    output dintx,
    output tx,
    output donetx);
  
  modport uart2(
    input clk, rst, 
    input doutrx, 
    input rx,
    output donerx);
  
endinterface 
