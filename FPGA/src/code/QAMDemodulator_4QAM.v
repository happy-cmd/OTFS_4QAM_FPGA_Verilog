`timescale 1ns / 1ps

module QAMDemodulator_4QAM(
    input wire Clk,
    input wire OTFSRxDemodValid,
    input wire [23:0] OTFSRxDemodRe,
    input wire [23:0] OTFSRxDemodIm,
    output reg QAMDemodDataValid,
    output reg [4:0] QAMDemodData
);

always @(posedge Clk) begin
    QAMDemodDataValid <= 1'b0;
    QAMDemodData <= 5'b00000;

    if (OTFSRxDemodValid) begin
        QAMDemodDataValid <= 1'b1;

        if ($signed(OTFSRxDemodRe) < 0) begin
            if ($signed(OTFSRxDemodIm) < 0) begin
            QAMDemodData<=5'b01;// 1
            end else begin
                QAMDemodData <= 5'b00;// 0
            end
        end else begin
            if ($signed(OTFSRxDemodIm) < 0) begin
                QAMDemodData <= 5'b11;// 3 
            end else begin
                QAMDemodData <= 5'b10;// 2
            end
        end
    end
end

endmodule

