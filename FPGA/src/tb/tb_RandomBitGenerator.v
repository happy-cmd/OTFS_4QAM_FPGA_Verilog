`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/11/04 14:42:59
// Design Name: 
// Module Name: tb_RandomBitGenerator
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

module RandomBitGenerator_tb; 

    // Parameters
    parameter CLK_PERIOD = 10; // ʱ������

    // Inputs
    reg Clk;
    reg SRst;
    reg Start;
    reg [2:0] ModulationOrder;

    // Outputs
    wire RandomBitValid;
    wire RandomBit;

    // Instantiate the Unit Under Test (UUT)
    RandomBitGenerator uut (
        .Clk(Clk),
        .SRst(SRst),
        .Start(Start),
        .ModulationOrder(ModulationOrder),
        .RandomBitValid(RandomBitValid),
        .RandomBit(RandomBit)
    );

    // Clock generation
    initial begin
        Clk = 0;
        forever #(CLK_PERIOD / 2) Clk = ~Clk; // ����ʱ���ź�
    end

    // Stimulus process
    initial begin
        // Initialize Inputs
        SRst = 1;
        Start = 0;
        ModulationOrder = 3'b000; // ���õ���˳���ʼΪ000

        // Wait for global reset
        #(CLK_PERIOD * 2);
        SRst = 0; // �����λ
        #(CLK_PERIOD);

        // Start the random bit generation with ModulationOrder = 000
        Start = 1; 
        #(CLK_PERIOD); // �ȴ�һ��ʱ������
        Start = 0; // ֹͣ�����ź�

        // Wait and observe the RandomBit outputs
        repeat (20) begin // �۲�20��ʱ������
            #(CLK_PERIOD);
            $display("RandomBitValid: %b, RandomBit: %b", RandomBitValid, RandomBit);
        end

        // Change ModulationOrder and restart
        ModulationOrder = 3'b001; // �޸ĵ���˳��
        Start = 1; 
        #(CLK_PERIOD); 
        Start = 0; 

        // Wait and observe the RandomBit outputs again
        repeat (20) begin 
            #(CLK_PERIOD);
            $display("RandomBitValid: %b, RandomBit: %b", RandomBitValid, RandomBit);
        end

        // Finish simulation
        $finish;
    end

endmodule

