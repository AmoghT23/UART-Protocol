# UART-Protocol
**The theory and the implementation of UART Protocol using System Verilog**

*UART - Universal Asynchronous Receiver Transmitter
-> Establish Connection between 2 entities (components)
On Chip - AMBA (AXI, AHB, APB)
Peripheral - SPI, UART, I2C

*The asynchronous communication happens by converting parallel data from a computer into serial data (RS-232, RS485).
*Both master and slave will have their own clk rates.

Master      Slave   
  TX  -----> RX

Master      Slave   
  RX  <----- TX

*Important Definitions
Baud rate -> Symbol per second (bits/sec) 
Bit Time -> Amount or duration of allocated to a single bit. 
          Bit time  = 1/baud rate           //The bit rate is inversely proportionate to the baud rate.

Number of cycles = Time x Frequency

Eg. ref_clk = 5000MHZ, Baud rate = 9600, no. of cycles required to send data = ?

= (1/9600) x 5000MHz = 520833 cycles 

* The input will be parallel frame and it will be sent over the TX(master) and RX(slave).

* Oversampling (at the slave) -> used to save the data so that the data is not lost.
  
* The sampling is done in between so that we get only the data which we require.

 
