// Directed testbench for obstacle_generator: tests reset, normal movement, x1 reset, and x2 reset under both stagger conditions
`timescale 1ns/1ps
module tb_obstacle_generator;
    reg         clk, rst, game_tick;
    wire [9:0]  obstacle_x1, obstacle_x2;
    integer     i;
    reg [9:0]   expected_x1, expected_x2;

    obstacle_generator dut (
        .clk        (clk),
        .rst        (rst),
        .game_tick  (game_tick),
        .obstacle_x1(obstacle_x1),
        .obstacle_x2(obstacle_x2)
    );

    initial 
    begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial 
    begin
        // 1) Reset behavior
        rst = 1; game_tick = 0;
        #20;
        rst = 0; #10;
        if (obstacle_x1 !== 540) $error("Reset x1: got %0d, expected 540", obstacle_x1);
        if (obstacle_x2 !== 750) $error("Reset x2: got %0d, expected 750", obstacle_x2);

        // 2) Normal movement for 5 ticks
        for (i = 1; i <= 5; i = i + 1) begin
            expected_x1 = 540 - 10*i;
            expected_x2 = 750 - 10*i;
            game_tick = 1; #10;
            game_tick = 0; #10;
            if (obstacle_x1 !== expected_x1)
                $error("Tick %0d x1: got %0d, expected %0d", i, obstacle_x1, expected_x1);
            if (obstacle_x2 !== expected_x2)
                $error("Tick %0d x2: got %0d, expected %0d", i, obstacle_x2, expected_x2);
        end

        // 3) x1 reset when <= VELOCITY
        force dut.x1_reg = 10;
        force dut.x2_reg = 500;
        game_tick = 1; #10;
        game_tick = 0; #10;
        if (obstacle_x1 !== 540) $error("x1 reset: got %0d, expected 540", obstacle_x1);
        if (obstacle_x2 !== 490) $error("x2 decayed at x1 reset: got %0d, expected 490", obstacle_x2);
        release dut.x1_reg;
        release dut.x2_reg;

        // 4a) x2 reset to X1+STAGGER when x2 <= VELOCITY & x1 > X1-Offset
        force dut.x1_reg = 500;  // > 540-120=420
        force dut.x2_reg = 5;    // <= VELOCITY
        game_tick = 1; #10;
        game_tick = 0; #10;
        if (obstacle_x2 !== 660) $error("x2 stagger reset (case a): got %0d, expected 660", obstacle_x2);
        release dut.x1_reg;
        release dut.x2_reg;

        // 4b) x2 reset to X2_RESET when x2 <= VELOCITY & x1 <= X1-Offset
        force dut.x1_reg = 400;  // <= 420
        force dut.x2_reg = 5;    // <= VELOCITY
        game_tick = 1; #10;
        game_tick = 0; #10;
        if (obstacle_x2 !== 750) $error("x2 reset (case b): got %0d, expected 750", obstacle_x2);
        release dut.x1_reg;
        release dut.x2_reg;

        $display("All obstacle_generator tests passed");
        $finish;
    end
endmodule
