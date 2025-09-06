module collision_detector (
    input wire [9:0] dino_y,
    input wire [9:0] obstacle_x1,
    input wire [9:0] obstacle_x2,
    output reg collision
);
    
    localparam OBSTACLE_HEIGHT = 150;
    localparam OBSTACLE_WIDTH  = 50;
    localparam DINO_HEIGHT     = 100;
    localparam DINO_WIDTH      = 50;
    localparam DINO_X          = 50;

    always@(*)
    begin
        if (dino_y + DINO_HEIGHT < 490) 
        begin
            collision = 1'b0;
        end
        else if ((DINO_X < obstacle_x1 + OBSTACLE_WIDTH &&
                  DINO_X + DINO_WIDTH > obstacle_x1) ||
                 (DINO_X < obstacle_x2 + OBSTACLE_WIDTH &&
                  DINO_X + DINO_WIDTH > obstacle_x2)) begin
            collision = 1'b1;
        end
        else begin
            collision = 1'b0;
        end
    end   
endmodule
