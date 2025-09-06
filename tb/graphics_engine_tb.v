// Directed testbench for graphics_engine: tests non-trivial scenarios for display_area, obstacles, and dino parts
`timescale 1ns/1ps
module tb_graphics_engine;
    reg         vga_clk;
    reg  [9:0]  pixel_x, pixel_y;
    reg         display_area;
    reg  [9:0]  dino_y, obstacle_x1, obstacle_x2;
    reg         game_over;
    wire [3:0]  red, green, blue;
    integer     errors = 0;

    graphics_engine dut (
        .vga_clk        (vga_clk),
        .pixel_x        (pixel_x),
        .pixel_y        (pixel_y),
        .display_area   (display_area),
        .dino_y         (dino_y),
        .obstacle_x1    (obstacle_x1),
        .obstacle_x2    (obstacle_x2),
        .game_over      (game_over),
        .red            (red),
        .green          (green),
        .blue           (blue)
    );

    initial 
    begin
        vga_clk = 0;
        forever #10 vga_clk = ~vga_clk;
    end

    initial 
    begin
        // Initialize common inputs
        dino_y      = 100;
        obstacle_x1 = 200;
        obstacle_x2 = 400;
        game_over   = 0;

        // 1) Outside display area → black
        display_area = 0;
        pixel_x = 320; pixel_y = 240;
        @(posedge vga_clk); #1;
        if ({red,green,blue} !== 12'b0000_0000_0000) begin
            $error("Outside display: got {%0h,%0h,%0h}", red,green,blue);
            errors = errors + 1;
        end

        // 2) Display area, empty sky → white
        display_area = 1;
        pixel_x = 100; pixel_y = 100;
        @(posedge vga_clk); #1;
        if ({red,green,blue} !== 12'b1111_1111_1111) begin
            $error("Sky pixel: got {%0h,%0h,%0h}", red,green,blue);
            errors = errors + 1;
        end

        // 3) Obstacle1 region → grey
        pixel_x = obstacle_x1 + 10;
        pixel_y = 350; // within 480-150=330 .. 479
        @(posedge vga_clk); #1;
        if ({red,green,blue} !== 12'b1000_1000_1000) begin
            $error("Obstacle1: got {%0h,%0h,%0h}", red,green,blue);
            errors = errors + 1;
        end

        // 4) Obstacle2 region → grey
        pixel_x = obstacle_x2 + 25;
        pixel_y = 400;
        @(posedge vga_clk); #1;
        if ({red,green,blue} !== 12'b1000_1000_1000) begin
            $error("Obstacle2: got {%0h,%0h,%0h}", red,green,blue);
            errors = errors + 1;
        end

        // 5) Dino body → grey
        pixel_x = 50 + 20; // DINO_X+10..+40
        pixel_y = 480 - dino_y - 30; // between 480-dino_y-60..479-dino_y
        @(posedge vga_clk); #1;
        if ({red,green,blue} !== 12'b1000_1000_1000) begin
            $error("Dino body: got {%0h,%0h,%0h}", red,green,blue);
            errors = errors + 1;
        end

        // 6) Dino head → grey
        pixel_x = 50 + 40; 
        pixel_y = 480 - dino_y - 70;
        @(posedge vga_clk); #1;
        if ({red,green,blue} !== 12'b1000_1000_1000) begin
            $error("Dino head: got {%0h,%0h,%0h}", red,green,blue);
            errors = errors + 1;
        end

        // 7) Dino left leg → grey
        pixel_x = 50 + 12;
        pixel_y = 480 - dino_y;
        @(posedge vga_clk); #1;
        if ({red,green,blue} !== 12'b1000_1000_1000) begin
            $error("Dino left leg: got {%0h,%0h,%0h}", red,green,blue);
            errors = errors + 1;
        end

        // 8) Dino right leg → grey
        pixel_x = 50 + 34;
        pixel_y = 480 - dino_y;
        @(posedge vga_clk); #1;
        if ({red,green,blue} !== 12'b1000_1000_1000) begin
            $error("Dino right leg: got {%0h,%0h,%0h}", red,green,blue);
            errors = errors + 1;
        end

        // 9) Dino tail → grey
        pixel_x = 50 + 5;
        pixel_y = 480 - dino_y - 10;
        @(posedge vga_clk); #1;
        if ({red,green,blue} !== 12'b1000_1000_1000) begin
            $error("Dino tail: got {%0h,%0h,%0h}", red,green,blue);
            errors = errors + 1;
        end

        // 10) Dino eye → grey
        pixel_x = 50 + 45;
        pixel_y = 480 - dino_y - 75;
        @(posedge vga_clk); #1;
        if ({red,green,blue} !== 12'b1000_1000_1000) begin
            $error("Dino eye: got {%0h,%0h,%0h}", red,green,blue);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("All graphics_engine tests passed");
        else
            $display("%0d graphics_engine tests failed", errors);

        $finish;
    end
endmodule
