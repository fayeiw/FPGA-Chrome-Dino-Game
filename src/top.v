module top (
    input  wire        clk,        
    input  wire        rst,        
    input  wire        btn_jump,   
    output wire        hsync,      
    output wire        vsync,      
    output wire [3:0]  red,        
    output wire [3:0]  green,     
    output wire [3:0]  blue        
);

    wire        game_tick;
    wire        vga_clk;

    wire        jump_pressed;
    wire [9:0]  dino_y;
    wire        game_over;

    wire [9:0]  obstacle_x1;
    wire [9:0]  obstacle_x2;

    wire        collision;

    wire [9:0]  pixel_x;
    wire [9:0]  pixel_y;
    wire        display_area;


    clock_divider u_clk_div (
        .clk      (clk),
        .rst      (rst),
        .game_tick(game_tick),
        .vga_clk  (vga_clk)
    );


    obstacle_generator u_obstacles (
        .clk        (clk),
        .rst        (rst),
        .game_tick  (game_tick),
        .obstacle_x1(obstacle_x1),
        .obstacle_x2(obstacle_x2)
    );

    input_handler u_input (
        .clk         (clk),
        .rst         (rst),
        .btn_jump    (btn_jump),
        .jump_pressed(jump_pressed)
    );

    game_fsm u_fsm (
        .clk         (clk),
        .rst         (rst),
        .game_tick   (game_tick),
        .jump_pressed(jump_pressed),
        .collision   (collision),
        .dino_y      (dino_y),
        .game_over   (game_over)
    );


    collision_detector u_collision (
        .dino_y     (dino_y),
        .obstacle_x1(obstacle_x1),
        .obstacle_x2(obstacle_x2),
        .collision  (collision)
    );

    vga_controller u_vga (
        .vga_clk     (vga_clk),
        .rst         (rst),
        .pixel_x     (pixel_x),
        .pixel_y     (pixel_y),
        .hsync       (hsync),
        .vsync       (vsync),
        .display_area(display_area)
    );


    graphics_engine u_gfx (
        .vga_clk     (vga_clk),
        .pixel_x     (pixel_x),
        .pixel_y     (pixel_y),
        .display_area(display_area),
        .dino_y      (dino_y),
        .obstacle_x1 (obstacle_x1),
        .obstacle_x2 (obstacle_x2),
        .game_over   (game_over),
        .red         (red),
        .green       (green),
        .blue        (blue)
    );
endmodule
