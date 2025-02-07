`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/06 14:57:16
// Design Name: 
// Module Name: blk_mem_gen_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module blk_mem_gen_tb;

  // Clock and reset signals
  reg Clk;
  reg wea;
  reg [11:0] addra;
  reg [31:0] dina;
  reg [11:0] addrb;
  wire [31:0] doutb;

  // Instantiate the blk_mem_gen module
  blk_mem_gen_0_1 your_instance_name (
    .clka(Clk),
    .wea(wea),
    .addra(addra),
    .dina(dina),
    .clkb(Clk),
    .addrb(addrb),
    .doutb(doutb)
  );

  // Generate clock
  initial begin
    Clk = 0;
    forever #5 Clk = ~Clk; // 100 MHz clock
  end

  // Initialize and apply test vectors
  integer i;
  integer j;
  initial begin
    // Initialize signals
    wea = 0;
    addra = 12'b0;
    dina = 32'b0;
    addrb = 12'b0;

    // Reset and wait for a few cycles
    #10;

    // Write data to the memory
    wea = 1;
    for (i = 0; i < 10; i = i + 1) begin
      addra = i;
      dina = 32'hA5A5A5A5 + i; // Example pattern
      #10; // Wait for one clock cycle
    end
    wea = 0;

    // Read data from the memory
    #10;
    for (j = 0; j < 10; j = j + 1) begin
      addrb = j;
      #10; // Wait for one clock cycle
      $display("Time: %0t | Read Address: %0d | Data: %h", $time, addrb, doutb);
    end

    // Finish simulation
    $finish;
  end

endmodule

