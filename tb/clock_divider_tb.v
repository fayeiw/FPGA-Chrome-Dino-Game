// Directed testbench for clock_divider: tests reset behavior, VGA clock toggling, and game_tick toggling by forcing counter
`timescale 1ns/1ps
module tb_clock_divider;
    reg clk, rst;
    wire game_tick, vga_clk;

    clock_divider dut (
        .clk      (clk),
        .rst      (rst),
        .game_tick(game_tick),
        .vga_clk  (vga_clk)
    );

    initial 
    begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial 
    begin
        // 1) Reset behavior
        rst = 1; #20;
        rst = 0; #10;
        if (game_tick !== 0) $error("After reset: game_tick=%b, expected 0", game_tick);
        if (vga_clk   !== 0) $error("After reset: vga_clk=%b, expected 0", vga_clk);

        // 2) VGA clock toggles every 2 cycles
        @(posedge clk); #1; // 1st rising edge
        if (vga_clk !== 0) $error("VGA: toggled too early at cycle 1");
        @(posedge clk); #1; // 2nd rising edge
        if (vga_clk !== 1) $error("VGA: did not toggle to 1 at cycle 2");
        @(posedge clk); #1; // 3rd rising edge
        @(posedge clk); #1; // 4th rising edge
        if (vga_clk !== 0) $error("VGA: did not toggle back to 0 at cycle 4");

        // 3) Game tick toggling via force
        force dut.game_tick_counter = 21'd833331;
        force dut.game_clk_in      = 1'b0;

        // Next posedge: counter -> 833332, no toggle yet
        @(posedge clk); #1;
        if (game_tick !== 0) $error("GameTick: toggled too early at threshold-1");

        // Allow toggle on the following posedge
        release dut.game_clk_in;

        @(posedge clk); #1;
        if (game_tick !== 1) $error("GameTick: did not toggle at threshold");

        // Cleanup force
        release dut.game_tick_counter;

        $display("All tb_clock_divider tests passed");
        $finish;
    end
endmodule
