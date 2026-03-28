`timescale 1ns / 1ps

// ROM MODULE using your .mem file
module at_rom(
    input  wire [7:0] addr,  // <-- FIXED: Changed to 8 bits [7:0]
    output reg  [7:0] data
);

    // Declare a memory array: 256 rows, each 8 bits wide
    reg [7:0] rom_array [0:255];

    // Initialize the memory from your external file
    initial begin
        $readmemh("commands.mem", rom_array);
    end

    // Asynchronous read to feed the FSM
    always @* begin
        // If the address goes beyond initialized memory, output 0x00 to stop the FSM
        if (rom_array[addr] === 8'bx) 
            data = 8'h00;
        else
            data = rom_array[addr];
    end

endmodule