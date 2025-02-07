`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/04 16:21:32
// Design Name: 
// Module Name: QAMModulator_32QAM_tb
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
module QAMModulator_32QAM_tb;

    // Parameters
    parameter CLK_PERIOD = 10;// Clock period

    // Inputs
    reg Clk;
    reg SRst;
    reg Start;
    reg DataValidIn;
    reg Data;

    // Outputs
    wire ModDataOutValid;
    wire FrameBeginnigIndicator;
    wire [7:0] FrameNum;
    wire [7:0] DataNum;
    wire signed [11:0] ModDataOutRe;
    wire signed [11:0] ModDataOutIm;

    // Instantiate the Unit Under Test (UUT)
    QAMModulator_32QAM uut (
        .Clk(Clk),
        .SRst(SRst),
        .Start(Start),
        .DataValidIn(DataValidIn),
        .Data(Data),
        .ModDataOutValid(ModDataOutValid),
        .FrameBeginnigIndicator(FrameBeginnigIndicator),
        .FrameNum(FrameNum),
        .DataNum(DataNum),
        .ModDataOutRe(ModDataOutRe),
        .ModDataOutIm(ModDataOutIm)
    );

    // Clock generation
    initial begin
        Clk = 0;
        forever #(CLK_PERIOD / 2) Clk = ~Clk;// Generate clock signal
    end

    // Stimulus process
    integer i ;
    initial begin
        // Initialize Inputs
        SRst = 1;                  // Set reset active
        Start = 0;                 // Set start inactive
        DataValidIn = 0;          // Set data valid inactive
        Data = 0;                  // Initialize data input

        // Wait for global reset
        #(CLK_PERIOD * 2);
        SRst = 0;                  // Release reset
        #(CLK_PERIOD);

        // Start the modulator
        Start = 1;
        #(CLK_PERIOD);
        Start = 0;

        // Input a sequence of bits
        for (i = 0;i < 64;i = i + 1) begin
            DataValidIn = 1;       // Set data valid
            Data = $urandom_range(0, 1);// Random bit (0 or 1)
            #(CLK_PERIOD);
            DataValidIn = 0;       // Clear data valid
            #(CLK_PERIOD);         // Wait for next clock edge
        end

        // Finish simulation
        #(CLK_PERIOD);
        $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time: %0d | ModDataOutValid: %b | FrameNum: %h | DataNum: %h | ModDataOutRe: %d | ModDataOutIm: %d", 
            $time, 
            ModDataOutValid, 
            FrameNum, 
            DataNum, 
            ModDataOutRe, 
            ModDataOutIm);
    end

endmodule

