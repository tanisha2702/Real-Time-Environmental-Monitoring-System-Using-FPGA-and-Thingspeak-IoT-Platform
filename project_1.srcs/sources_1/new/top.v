`timescale 1ns / 1ps

module top(
    input  wire clk,
    input  wire reset,
    input  wire rx,
    input  wire sensor_in,
    output wire tx,
    output wire led0,
    output wire led1
);

    wire s_tick;
    wire tx_start;
    wire tx_done_tick;
    wire [7:0] tx_data;

    wire rx_done_tick;
    wire [7:0] rx_data;

    wire dust_done_tick;
    wire [31:0] dust_val;

    wire bin_ready;
    wire bin_done;
    wire [7:0] asc7, asc6, asc5, asc4, asc3, asc2, asc1, asc0;

    reg [7:0] asc7_reg, asc6_reg, asc5_reg, asc4_reg;
    reg [7:0] asc3_reg, asc2_reg, asc1_reg, asc0_reg;

    reg [25:0] blink_reg;

    assign led0   = ~sensor_in;
    assign led1   = (blink_reg != 0);

    always @(posedge clk or posedge reset) begin
        if (reset)
            blink_reg <= 0;
        else begin
            if (dust_done_tick)
                blink_reg <= 26'd50_000_000;
            else if (blink_reg != 0)
                blink_reg <= blink_reg - 1;
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            asc7_reg <= "0";
            asc6_reg <= "0";
            asc5_reg <= "0";
            asc4_reg <= "0";
            asc3_reg <= "0";
            asc2_reg <= "0";
            asc1_reg <= "0";
            asc0_reg <= "0";
        end
        else if (bin_done) begin
            asc7_reg <= asc7;
            asc6_reg <= asc6;
            asc5_reg <= asc5;
            asc4_reg <= asc4;
            asc3_reg <= asc3;
            asc2_reg <= asc2;
            asc1_reg <= asc1;
            asc0_reg <= asc0;
        end
    end

    dust_sensor_reader #(
        .CLK_FREQ(100_000_000),
        .SAMPLE_TIME(1)
    ) dust_unit (
        .clk(clk),
        .reset(reset),
        .sensor_in(sensor_in),
        .done_tick(dust_done_tick),
        .dust_val(dust_val)
    );

    bin2ascii translator_unit (
        .clk(clk),
        .reset(reset),
        .start(dust_done_tick),
        .bin(dust_val),
        .ready(bin_ready),
        .done_tick(bin_done),
        .asc7(asc7),
        .asc6(asc6),
        .asc5(asc5),
        .asc4(asc4),
        .asc3(asc3),
        .asc2(asc2),
        .asc1(asc1),
        .asc0(asc0)
    );

    baud_gen #(
        .CLK_FREQ(100_000_000),
        .BAUD(115200)
    ) baud_unit (
        .clk(clk),
        .reset(reset),
        .s_tick(s_tick)
    );

    uart_rx rx_unit (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .s_tick(s_tick),
        .rx_done_tick(rx_done_tick),
        .dout(rx_data)
    );

    uart_tx tx_unit (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .s_tick(s_tick),
        .din(tx_data),
        .tx_done_tick(tx_done_tick),
        .tx(tx)
    );

    at_fsm fsm_unit (
        .clk(clk),
        .reset(reset),
        .tx_done_tick(tx_done_tick),
        .asc7(asc7_reg),
        .asc6(asc6_reg),
        .asc5(asc5_reg),
        .asc4(asc4_reg),
        .asc3(asc3_reg),
        .asc2(asc2_reg),
        .asc1(asc1_reg),
        .asc0(asc0_reg),
        .tx_start(tx_start),
        .tx_data(tx_data)
    );
    
    


endmodule