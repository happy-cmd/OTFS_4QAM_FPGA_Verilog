`timescale 1ns / 1ps

module TopModuleTb;

    // DUT (Device Under Test) ports
    reg Clk = 1;
    reg SRst = 0;
    reg Start = 0;
    reg [2:0] ModulationOrder = 3'b000;
    
    wire QAMModDataOutValid;
    wire QAMFrameBeginnigIndicator;
    wire [7:0] QAMFrameNum;
    wire [7:0] QAMDataNum;
    wire [11:0] QAMModDataOutRe;
    wire [11:0] QAMModDataOutIm;
    
    wire OTFSTxDataValid;
    wire [15:0] OTFSTxDataRe;
    wire [15:0] OTFSTxDataIm;
    
    wire OTFSRxDemodValid;
    wire [23:0] OTFSRxDemodRe;
    wire [23:0] OTFSRxDemodIm;
    
    wire QAMDemodDataValid;
    wire [4:0] QAMDemodData;

    // Instantiate the DUT
    TopModule DUT (
        .Clk(Clk),
        .SRst(SRst),
        .Start(Start),
        .ModulationOrder(ModulationOrder),
        
        .QAMModDataOutValid(QAMModDataOutValid),
        .QAMFrameBeginnigIndicator(QAMFrameBeginnigIndicator),
        .QAMFrameNum(QAMFrameNum),
        .QAMDataNum(QAMDataNum),
        .QAMModDataOutRe(QAMModDataOutRe),
        .QAMModDataOutIm(QAMModDataOutIm),
        
        .OTFSTxDataValid(OTFSTxDataValid),
        .OTFSTxDataRe(OTFSTxDataRe),
        .OTFSTxDataIm(OTFSTxDataIm),
        
        .OTFSRxDemodValid(OTFSRxDemodValid),
        .OTFSRxDemodRe(OTFSRxDemodRe),
        .OTFSRxDemodIm(OTFSRxDemodIm),
        
        .QAMDemodDataValid(QAMDemodDataValid),
        .QAMDemodData(QAMDemodData)
    );

    // Clock generation
    always #5 Clk = ~Clk; // Toggle Clk every 5 ns

    integer logfile;
    // Stimuli process
    initial begin
        // Reset the DUT
        SRst = 1;
        #100;
        SRst = 0;
        #100;
        
        // Start the DUT
        Start = 1;
        ModulationOrder = 3'b000;// 32-QAM
        #10;
        Start = 0;
        
        // Finish simulation
//        #10000;// Wait some time before ending
//        $finish;// Properly end the simulation
//         // Close the log file at the end of the simulation
//        $fclose(logfile);
    end
    



   

endmodule

