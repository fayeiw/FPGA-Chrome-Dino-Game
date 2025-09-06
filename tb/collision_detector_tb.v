// Directed testbench for collision_detector: tests various dino positions and obstacle locations
`timescale 1ns/1ps
module tb_collision_detector;
    reg  [9:0] dino_y, obstacle_x1, obstacle_x2;
    wire       collision;

    collision_detector dut (
        .dino_y      (dino_y),
        .obstacle_x1 (obstacle_x1),
        .obstacle_x2 (obstacle_x2),
        .collision   (collision)
    );

    initial 
    begin
        // Case 1: Dino in air (y+100 < 490) → no collision regardless of X
        dino_y = 300; obstacle_x1 = 50; obstacle_x2 = 150; #1;
        if (collision !== 1'b0)
            $error("Case1 failed: expected no collision, got %b", collision);

        // Case 2: Dino on ground (y+100 >= 490) & obstacle1 overlaps → collision
        dino_y = 390; obstacle_x1 = 25; obstacle_x2 = 200; #1;
        if (collision !== 1'b1)
            $error("Case2 failed: expected collision with obstacle1, got %b", collision);

        // Case 3: Dino on ground & obstacle2 overlaps → collision
        dino_y = 395; obstacle_x1 = 200; obstacle_x2 = 30; #1;
        if (collision !== 1'b1)
            $error("Case3 failed: expected collision with obstacle2, got %b", collision);

        // Case 4: Dino on ground & both obstacles out of X-range → no collision
        dino_y = 380; obstacle_x1 = 200; obstacle_x2 = 300; #1;
        if (collision !== 1'b0)
            $error("Case4 failed: expected no collision, got %b", collision);

        // Case 5: Just below ground threshold (y+100 = 489) → no collision even if X overlaps
        dino_y = 389; obstacle_x1 = 25; obstacle_x2 = 25; #1;
        if (collision !== 1'b0)
            $error("Case5 failed: expected no collision at boundary, got %b", collision);

        // Case 6: Exactly at threshold (y+100 = 490) but X just misses → no collision
        dino_y = 390; obstacle_x1 = 0; obstacle_x2 = 100; #1;
        if (collision !== 1'b0)
            $error("Case6 failed: expected no collision on exact threshold, got %b", collision);

        $display("All collision_detector tests passed");
        $finish;
    end
endmodule
