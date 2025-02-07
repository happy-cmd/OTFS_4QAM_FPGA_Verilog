`timescale 1ns / 1ps

module QAMDemodulator(
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

        if ($signed(OTFSRxDemodRe) < -1832) begin
            if ($signed(OTFSRxDemodIm) < -1832) begin
                QAMDemodData <= 5'b00110;// 6
            end else if ($signed(OTFSRxDemodIm) < -916) begin
                QAMDemodData <= 5'b00110;// 6
            end else if ($signed(OTFSRxDemodIm) < 0) begin
                QAMDemodData <= 5'b00111;// 7
            end else if ($signed(OTFSRxDemodIm) < 916) begin
                QAMDemodData <= 5'b00101;// 5
            end else if ($signed(OTFSRxDemodIm) < 1832) begin
                QAMDemodData <= 5'b00100;// 4
            end else begin
                QAMDemodData <= 5'b00100;// 4
            end
        end else if ($signed(OTFSRxDemodRe) < -916) begin
            if ($signed(OTFSRxDemodIm) < -1832) begin
                QAMDemodData <= 5'b00010;// 2
            end else if ($signed(OTFSRxDemodIm) < -916) begin
                QAMDemodData <= 5'b01110;// 14
            end else if ($signed(OTFSRxDemodIm) < 0) begin
                QAMDemodData <= 5'b01111;// 15
            end else if ($signed(OTFSRxDemodIm) < 916) begin
                QAMDemodData <= 5'b01101;// 13
            end else if ($signed(OTFSRxDemodIm) < 1832) begin
                QAMDemodData <= 5'b01100;// 12
            end else begin
                QAMDemodData <= 5'b00000;// 0
            end
        end else if ($signed(OTFSRxDemodRe) < 0) begin
            if ($signed(OTFSRxDemodIm) < -1832) begin
                QAMDemodData <= 5'b00011;// 3
            end else if ($signed(OTFSRxDemodIm) < -916) begin
                QAMDemodData <= 5'b01010;// 10
            end else if ($signed(OTFSRxDemodIm) < 0) begin
                QAMDemodData <= 5'b01011;// 11
            end else if ($signed(OTFSRxDemodIm) < 916) begin
                QAMDemodData <= 5'b01001;// 9
            end else if ($signed(OTFSRxDemodIm) < 1832) begin
                QAMDemodData <= 5'b01000;// 8
            end else begin
                QAMDemodData <= 5'b00001;// 1
            end
        end else if ($signed(OTFSRxDemodRe) < 916) begin
            if ($signed(OTFSRxDemodIm) < -1832) begin
                QAMDemodData <= 5'b10011;// 19
            end else if ($signed(OTFSRxDemodIm) < -916) begin
                QAMDemodData <= 5'b11010;// 26
            end else if ($signed(OTFSRxDemodIm) < 0) begin
                QAMDemodData <= 5'b11011;// 27
            end else if ($signed(OTFSRxDemodIm) < 916) begin
                QAMDemodData <= 5'b11001;// 25
            end else if ($signed(OTFSRxDemodIm) < 1832) begin
                QAMDemodData <= 5'b11000;// 24
            end else begin
                QAMDemodData <= 5'b10001;// 17
            end
        end else if ($signed(OTFSRxDemodRe) < 1832) begin
            if ($signed(OTFSRxDemodIm) < -1832) begin
                QAMDemodData <= 5'b10010;// 18
            end else if ($signed(OTFSRxDemodIm) < -916) begin
                QAMDemodData <= 5'b11110;// 30
            end else if ($signed(OTFSRxDemodIm) < 0) begin
                QAMDemodData <= 5'b11111;// 31
            end else if ($signed(OTFSRxDemodIm) < 916) begin
                QAMDemodData <= 5'b11101;// 29
            end else if ($signed(OTFSRxDemodIm) < 1832) begin
                QAMDemodData <= 5'b11100;// 28
            end else begin
                QAMDemodData <= 5'b10000;// 16
            end
        end else begin
            if ($signed(OTFSRxDemodIm) < -1832) begin
                QAMDemodData <= 5'b10110;// 22
            end else if ($signed(OTFSRxDemodIm) < -916) begin
                QAMDemodData <= 5'b10110;// 22
            end else if ($signed(OTFSRxDemodIm) < 0) begin
                QAMDemodData <= 5'b10111;// 23
            end else if ($signed(OTFSRxDemodIm) < 916) begin
                QAMDemodData <= 5'b10101;// 21
            end else if ($signed(OTFSRxDemodIm) < 1832) begin
                QAMDemodData <= 5'b10100;// 20
            end else begin
                QAMDemodData <= 5'b10100;// 20
            end
        end
    end
end

endmodule

