// Directed testbench for game_fsm: tests reset, jump sequence, landing, and collision leading to game over
`timescale 1ns/1ps
module tb_game_fsm;
    reg clk, rst, game_tick, jump_pressed, collision;
    wire [9:0] dino_y;
    wire       game_over;
    integer    i;

    game_fsm dut (
        .clk(clk),
        .rst(rst),
        .game_tick(game_tick),
        .jump_pressed(jump_pressed),
        .collision(collision),
        .dino_y(dino_y),
        .game_over(game_over)
    );

    initial 
    begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial 
    begin
        rst = 1; game_tick = 0; jump_pressed = 0; collision = 0;
        #20 rst = 0;

        // Idle tick: no jump, no collision
        game_tick = 1; #10;
        if (dino_y !== 0 || game_over !== 0) $error("Idle: unexpected dino_y=%0d or game_over=%b", dino_y, game_over);
        game_tick = 0; #10;

        // Issue jump
        jump_pressed = 1; game_tick = 1; #10;
        if (dino_y !== 0 || game_over !== 0) $error("Jump start: dino_y=%0d, game_over=%b", dino_y, game_over);
        jump_pressed = 0; game_tick = 0; #10;

        // Climb for two ticks: expect dino_y > 0
        for (i = 0; i < 2; i = i + 1) begin
            game_tick = 1; #10;
            game_tick = 0; #10;
        end
        if (dino_y <= 0) $error("Climb: dino_y did not increase, got %0d", dino_y);

        // Continue ticks until landing (dino_y returns to 0)
        for (i = 0; i < 30; i = i + 1) begin
            game_tick = 1; #10;
            game_tick = 0; #10;
        end
        if (dino_y !== 0 || game_over !== 0) $error("Landing: expected dino_y=0 and game_over=0, got %0d, %b", dino_y, game_over);

        // Collision in idle: game_over should assert
        collision = 1; game_tick = 1; #10;
        if (game_over !== 1) $error("Collision: game_over not asserted");
        
        $display("All game_fsm tests passed");
        $finish;
    end
endmodule
