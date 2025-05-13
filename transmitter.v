`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.04.2025 20:40:13
// Design Name: 
// Module Name: transmitter
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


module transmitter (
    input clk,
    input reset,
    input transmit,
    input [7:0] data,
    output reg TxD
);

    reg [3:0] bitcounter;
    reg [13:0] counter;
    reg [1:0] state, nextstate;
    reg [9:0] rightshiftreg;
    reg shift, load, clear;
    // Baud rate = 9600, Clock = 100MHz => 100_000_000 / 9600 = 10416
    parameter BAUD_LIMIT = 10416;
    parameter IDLE = 2'b00;
    parameter TRANSMIT = 2'b01;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
        end else begin
            if (counter == BAUD_LIMIT - 1)
                counter <= 0;
            else
                counter <= counter + 1;
        end
    end
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
        end else if (counter == BAUD_LIMIT - 1) begin
            state <= nextstate;
        end
    end
    always @(*) begin
        shift = 0;
        load = 0;
        clear = 0;
        nextstate = state;
        case (state)
            IDLE: begin
                TxD = 1'b1; 
                if (transmit) begin
                    load = 1;
                    nextstate = TRANSMIT;
                end
            end
            TRANSMIT: begin
                TxD = rightshiftreg[0];
                if (bitcounter >= 10) begin
                    clear = 1;
                    nextstate = IDLE;
                end else begin
                    shift = 1;
                end
            end
        endcase
    end
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bitcounter <= 0;
            rightshiftreg <= 10'b1111111111;
        end else if (counter == BAUD_LIMIT - 1) begin
            if (load) begin
                rightshiftreg <= {1'b1, data, 1'b0}; 
                bitcounter <= 0;
            end else if (shift) begin
                rightshiftreg <= rightshiftreg >> 1;
                bitcounter <= bitcounter + 1;
            end else if (clear) begin
                bitcounter <= 0;
            end 
        end
    end
endmodule
