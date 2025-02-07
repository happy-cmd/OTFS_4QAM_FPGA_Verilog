`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/06 09:47:38
// Design Name: 
// Module Name: ROM_32QAM_ReIm_tb
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
module ROM_32QAM_ReIm_tb;

  // Inputs
  reg Clk;
  reg [4:0] CurrBits;
  
  // Outputs
  wire [11:0] ModDataOutRe_ROM;
  wire [11:0] ModDataOutIm_ROM;

  // Internal signals
  wire [5:0] addra;
  wire [5:0] addrb;
  reg [5:0] CurrBits_32;
  
  // Instantiate the Unit Under Test (UUT)
  ROM_32QAM_ReIm uut (
    .clka(Clk),
    .addra(addra),            // Input address for real part
    .douta(ModDataOutRe_ROM), // Output for real part
    .clkb(Clk),
    .addrb(addrb),            // Input address for imaginary part
    .doutb(ModDataOutIm_ROM)  // Output for imaginary part
  );

  // Assign address inputs for ROM
  assign addra = {1'b0, CurrBits};
  assign addrb = CurrBits_32;

  // Clock generation
  initial begin
    Clk = 0;
    forever #5 Clk = ~Clk; // 10ns period clock
  end

  // Test sequence
  initial begin
    // Initialize inputs
    CurrBits = 0;
    CurrBits_32 = CurrBits + 32;

    // Display header
    $display("Time(ns) | CurrBits | CurrBits_32 | ModDataOutRe_ROM | ModDataOutIm_ROM");

    // Stimulus for testing
    repeat(32) begin
      #10;
      $display("%0d       | %0d       | %0d         | %0d            | %0d", 
               $time, CurrBits, CurrBits_32, $signed(ModDataOutRe_ROM), $signed(ModDataOutIm_ROM));
      CurrBits = CurrBits + 1;
      CurrBits_32 = CurrBits + 32;
    end

    // Stop the simulation
    #10;
    $stop;
  end

endmodule

