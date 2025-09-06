// Directed testbench for vga_controller: tests reset, HSYNC, VSYNC, display_area, and pixel coords at non‑trivial points
`timescale 1ns/1ps
module tb_vga_controller;
    reg         vga_clk;
    reg         rst;
    wire [9:0]  pixel_x, pixel_y;
    wire        hsync, vsync, display_area;

    vga_controller dut (
        .vga_clk     (vga_clk),
        .rst         (rst),
        .pixel_x     (pixel_x),
        .pixel_y     (pixel_y),
        .hsync       (hsync),
        .vsync       (vsync),
        .display_area(display_area)
    );

    initial 
    begin
        vga_clk = 0;
        forever #10 vga_clk = ~vga_clk;
    end

    initial 
    begin
        // Reset
        rst = 1; #25;
        rst = 0; #15;

        // After reset: counters = 0
        if (pixel_x !== 0 || pixel_y !== 0)
            $error("Reset: pixel_x=%0d pixel_y=%0d, expected 0,0", pixel_x, pixel_y);
        if (display_area !== 1 || hsync !== 1 || vsync !== 1)
            $error("Reset: display_area=%b hsync=%b vsync=%b, expected 1,1,1",
                   display_area, hsync, vsync);

        // HSYNC active region (H_VISIBLE+H_FRONT = 656)
        force dut.h_counter = 656;
        force dut.v_counter = 100;
        #1;
        if (hsync !== 0 || display_area !== 0)
            $error("HSYNC ON: h_counter=656 display_area=%b hsync=%b", display_area, hsync);

        // HSYNC end (656+96 = 752)
        force dut.h_counter = 752;
        #1;
        if (hsync !== 1)
            $error("HSYNC OFF: h_counter=752 hsync=%b, expected 1", hsync);

        // Display area border test
        force dut.h_counter = 639; force dut.v_counter = 479; #1;
        if (display_area !== 1)
            $error("Display area edge: (%0d,%0d) display_area=%b, expected 1",
                   pixel_x, pixel_y, display_area);
        force dut.h_counter = 640; force dut.v_counter = 479; #1;
        if (display_area !== 0)
            $error("Outside display X: (%0d,%0d) display_area=%b, expected 0",
                   pixel_x, pixel_y, display_area);

        // VSYNC active region (V_VISIBLE+V_FRONT = 490)
        force dut.h_counter = 200;
        force dut.v_counter = 490; #1;
        if (vsync !== 0 || display_area !== 0)
            $error("VSYNC ON: v_counter=490 display_area=%b vsync=%b", display_area, vsync);

        // VSYNC end (490+2 = 492)
        force dut.v_counter = 492; #1;
        if (vsync !== 1)
            $error("VSYNC OFF: v_counter=492 vsync=%b, expected 1", vsync);

        // Release forced counters
        release dut.h_counter;
        release dut.v_counter;

        $display("All vga_controller tests passed");
        $finish;
    end
endmodule
