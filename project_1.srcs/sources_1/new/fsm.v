`timescale 1ns / 1ps

module at_fsm(
    input  wire clk,
    input  wire reset,
    input  wire tx_done_tick,
    input  wire [7:0] asc7, asc6, asc5, asc4, asc3, asc2, asc1, asc0, 
    output reg  tx_start,
    output reg  [7:0] tx_data
);

    localparam [2:0]
        SEND        = 3'd0,
        WAIT_TX     = 3'd1,
        PAUSE       = 3'd2,
        SEND_DYN    = 3'd3,
        WAIT_DYN_TX = 3'd4,
        RESTART_WAIT= 3'd5;

    // Fixed Delays for 100MHz Clock
    localparam LINE_DELAY_TICKS    = 32'd200_000_000;   // 2 sec: Time for ESP to process standard AT commands
    localparam RESTART_DELAY_TICKS = 32'd2000_000_000;  // 20 sec: Safely clears ThingSpeak's 15-second rate limit

    reg [2:0] state_reg, state_next;
    reg [7:0] index_reg, index_next;
    reg [31:0] timer_reg, timer_next;
    reg [2:0] digit_reg, digit_next;

    wire [7:0] current_char;

    at_rom my_rom (
        .addr(index_reg),
        .data(current_char)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state_reg <= SEND;
            index_reg <= 8'd0;
            timer_reg <= 32'd0;
            digit_reg <= 3'd7;
        end
        else begin
            state_reg <= state_next;
            index_reg <= index_next;
            timer_reg <= timer_next;
            digit_reg <= digit_next;
        end
    end

    always @* begin
        state_next = state_reg;
        index_next = index_reg;
        timer_next = timer_reg;
        digit_next = digit_reg;
        tx_start   = 1'b0;
        tx_data    = current_char;

        case (state_reg)

            SEND: begin
                if (current_char == 8'h00) begin
                    timer_next = 0;
                    state_next = RESTART_WAIT;
                end
                else if (current_char == 8'hFE) begin // MAGIC MARKER 1: Live Data Inject
                    digit_next = 3'd7;
                    state_next = SEND_DYN;
                end
                else if (current_char == 8'hFF) begin // MAGIC MARKER 2: Explicit 2-Second Pause
                    timer_next = 0;
                    index_next = index_reg + 1;
                    state_next = PAUSE;
                end
                else begin
                    tx_start   = 1'b1;
                    tx_data    = current_char;
                    state_next = WAIT_TX;
                end
            end

            WAIT_TX: begin
                tx_data = current_char;
                if (tx_done_tick) begin
                    index_next = index_reg + 1;
                    state_next = SEND; // Clean loopback without checking for 0A
                end
            end

            SEND_DYN: begin
                tx_start = 1'b1;
                case (digit_reg)
                    3'd7: tx_data = asc7;
                    3'd6: tx_data = asc6;
                    3'd5: tx_data = asc5;
                    3'd4: tx_data = asc4;
                    3'd3: tx_data = asc3;
                    3'd2: tx_data = asc2;
                    3'd1: tx_data = asc1;
                    default: tx_data = asc0;
                endcase
                state_next = WAIT_DYN_TX;
            end

            WAIT_DYN_TX: begin
                case (digit_reg)
                    3'd7: tx_data = asc7;
                    3'd6: tx_data = asc6;
                    3'd5: tx_data = asc5;
                    3'd4: tx_data = asc4;
                    3'd3: tx_data = asc3;
                    3'd2: tx_data = asc2;
                    3'd1: tx_data = asc1;
                    default: tx_data = asc0;
                endcase

                if (tx_done_tick) begin
                    if (digit_reg == 0) begin
                        index_next = index_reg + 1; // Skip the FE marker
                        state_next = SEND;
                    end
                    else begin
                        digit_next = digit_reg - 1;
                        state_next = SEND_DYN;
                    end
                end
            end

            PAUSE: begin
                if (timer_reg < LINE_DELAY_TICKS)
                    timer_next = timer_reg + 1;
                else
                    state_next = SEND;
            end

            RESTART_WAIT: begin
                if (timer_reg < RESTART_DELAY_TICKS)
                    timer_next = timer_reg + 1;
                else begin
                    index_next = 8'd55; // Exactly points to 'A' in AT+CIPSTART
                    state_next = SEND;
                end
            end

            default: begin
                state_next = SEND;
                index_next = 8'd0;
            end
        endcase
    end
endmodule