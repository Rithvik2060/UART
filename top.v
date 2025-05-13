// top.v
module top (
    input clk,
    input reset,
    input btnC,
    input [7:0] sw,
    input RxD,
    output TxD,
    output [7:0] led
);

wire transmit;

debounce d1(
.pb_1(btnC),
.clk(clk),
.pb_out(transmit));

    wire [7:0] rx_data;
    wire rx_ready;

    transmitter tx_inst (
        .clk(clk),
        .reset(reset),
        .transmit(transmit),
        .data(sw),
        .TxD(TxD)
    );

    receiver rx_inst (
        .clk(clk),
        .reset(reset),
        .RxD(RxD),
        .data_out(rx_data),
        .data_ready(rx_ready)
    );

    assign led = rx_data;
endmodule