
module receiver (
    input clk,
    input reset,
    input RxD,
    output reg [7:0] data_out,
    output reg data_ready
);
    parameter BAUD_RATE = 9600;
    parameter CLK_FREQ = 100_000_000;
    parameter SAMPLE_TICKS = CLK_FREQ / (BAUD_RATE * 16);

    reg [3:0] bit_index = 0;
    reg [7:0] rx_shift = 0;
    reg [3:0] sample_count = 0;
    reg [13:0] baud_counter = 0;
    reg [1:0] state = 0;

    parameter IDLE = 2'd0, START = 2'd1, DATA = 2'd2, STOP = 2'd3;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE; baud_counter <= 0; sample_count <= 0;
            bit_index <= 0; data_out <= 0; data_ready <= 0;
        end else begin
            case (state)
                IDLE: begin
                    data_ready <= 0;
                    if (~RxD) begin
                        state <= START; baud_counter <= 0; sample_count <= 0;
                    end
                end
                START: begin
                    if (baud_counter == SAMPLE_TICKS - 1) begin
                        baud_counter <= 0; sample_count <= sample_count + 1;
                        if (sample_count == 7) begin
                            if (~RxD) begin
                                state <= DATA; bit_index <= 0; sample_count <= 0;
                            end else state <= IDLE;
                        end
                    end else baud_counter <= baud_counter + 1;
                end
                DATA: begin
                    if (baud_counter == SAMPLE_TICKS - 1) begin
                        baud_counter <= 0; sample_count <= sample_count + 1;
                        if (sample_count == 15) begin
                            sample_count <= 0;
                            rx_shift <= {RxD, rx_shift[7:1]};
                            bit_index <= bit_index + 1;
                            if (bit_index == 7) state <= STOP;
                        end
                    end else baud_counter <= baud_counter + 1;
                end
                STOP: begin
                    if (baud_counter == SAMPLE_TICKS - 1) begin
                        baud_counter <= 0; sample_count <= sample_count + 1;
                        if (sample_count == 15) begin
                            data_out <= rx_shift;
                            data_ready <= 1;
                            state <= IDLE;
                        end
                    end else baud_counter <= baud_counter + 1;
                end
            endcase
        end
    end
endmodule
