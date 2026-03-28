`timescale 1ns / 1ps

module dust_sensor_reader
#(
    parameter CLK_FREQ    = 100_000_000,
    parameter SAMPLE_TIME = 1
)
(
    input  wire clk,
    input  wire reset,
    input  wire sensor_in,
    output reg  done_tick,
    output reg [31:0] dust_val
);

    localparam SAMPLE_COUNT = CLK_FREQ * SAMPLE_TIME;

    reg [31:0] sample_cnt_reg;
    reg [31:0] low_cnt_reg;

    reg sensor_ff1, sensor_ff2;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sensor_ff1 <= 1'b1;
            sensor_ff2 <= 1'b1;
        end
        else begin
            sensor_ff1 <= sensor_in;
            sensor_ff2 <= sensor_ff1;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sample_cnt_reg <= 0;
            low_cnt_reg    <= 0;
            dust_val       <= 0;
            done_tick      <= 1'b0;
        end
        else begin
            done_tick <= 1'b0;

            if (sample_cnt_reg == SAMPLE_COUNT - 1) begin
                sample_cnt_reg <= 0;
                dust_val       <= low_cnt_reg;
                low_cnt_reg    <= 0;
                done_tick      <= 1'b1;
            end
            else begin
                sample_cnt_reg <= sample_cnt_reg + 1;
                if (~sensor_ff2)
                    low_cnt_reg <= low_cnt_reg + 1;
            end
        end
    end

endmodule