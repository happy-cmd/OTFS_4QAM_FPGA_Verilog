`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/15 16:43:44
// Design Name: 
// Module Name: OTFSRx_32
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


//--------------------------------------------------------------------------------------------
//
// Generated by X-HDL VHDL Translator - Version 2.0.0 Feb. 1, 2011
// ?? 10? 31 2024 11:14:56
//
//      Input file      : 
//      Component name  : otfsrx
//      Author          : 
//      Company         : 
//
//      Description     : 
//
//
//--------------------------------------------------------------------------------------------


module OTFSRx_32(Clk, Srst, Start, RecSigDataValid, RecSigRe, RecSigIm, OTFSRxDemodValid, OTFSRxDemodRe, OTFSRxDemodIm, QAMDemodDataValid, QAMDemodData);
   input         Clk;
   input         Srst;
   input         Start;
   
   input         RecSigDataValid;
   input [15:0]  RecSigRe;
   input [15:0]  RecSigIm;
   
   output        OTFSRxDemodValid;
   output [23:0] OTFSRxDemodRe;
   output [23:0] OTFSRxDemodIm;
   
   output        QAMDemodDataValid;
   output [4:0]  QAMDemodData;
   
   
   wire          OTFSRxDemodValidReg;
   wire [23:0]   OTFSRxDemodReReg;
   wire [23:0]   OTFSRxDemodImReg;
   
   
   OTFSDemodulator U0(
   .Clk(Clk), 
   .Srst(Srst), 
   .Start(Start), 
   .RecSigDataValid(RecSigDataValid), 
   .RecSigRe(RecSigRe), 
   .RecSigIm(RecSigIm), 
   .OTFSRxDemodValid(OTFSRxDemodValidReg), 
   .OTFSRxDemodRe(OTFSRxDemodReReg), 
   .OTFSRxDemodIm(OTFSRxDemodImReg)
   );
   
   assign OTFSRxDemodValid = OTFSRxDemodValidReg;
   assign OTFSRxDemodRe = OTFSRxDemodReReg;
   assign OTFSRxDemodIm = OTFSRxDemodImReg;
   
   
   
   QAMDemodulator U1(
   .Clk(Clk), 
   .OTFSRxDemodValid(OTFSRxDemodValidReg), 
   .OTFSRxDemodRe(OTFSRxDemodReReg), 
   .OTFSRxDemodIm(OTFSRxDemodImReg), 
   .QAMDemodDataValid(QAMDemodDataValid), 
   .QAMDemodData(QAMDemodData)
   );
   
endmodule

