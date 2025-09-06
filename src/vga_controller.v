module vga_controller (
    input wire vga_clk,             
    input wire rst,                 
    output reg [9:0] pixel_x,       
    output reg [9:0] pixel_y,       
    output reg hsync,               
    output reg vsync,               
    output wire display_area        
);

    localparam H_VISIBLE = 640;
    localparam H_FRONT   = 16;
    localparam H_SYNC    = 96;
    localparam H_BACK    = 48;
    localparam H_TOTAL   = 800;

    localparam V_VISIBLE = 480;
    localparam V_FRONT   = 10;
    localparam V_SYNC    = 2;
    localparam V_BACK    = 33;
    localparam V_TOTAL   = 525;

    localparam SCREEN_WIDTH  = H_TOTAL - 1;
    localparam SCREEN_HEIGHT = V_TOTAL - 1;

    reg [9:0] h_counter;
    reg [9:0] v_counter;

    always@(posedge vga_clk)
    begin
        if (rst)
        begin
            h_counter <= 10'b0;
            v_counter <= 10'b0;
        end
        else
        begin
            if (h_counter < SCREEN_WIDTH)
            begin
                h_counter <= h_counter + 1'b1;
            end
            else
            begin
                h_counter <= 10'b0;
                if (v_counter < SCREEN_HEIGHT)
                begin
                    v_counter <= v_counter + 1'b1;
                end
                else
                begin
                    v_counter <= 10'b0;
                end
            end
        end
    end

    always @(*) begin
        hsync = ~((h_counter >= H_VISIBLE + H_FRONT) && (h_counter < H_VISIBLE + H_FRONT + H_SYNC));
        vsync = ~((v_counter >= V_VISIBLE + V_FRONT) && (v_counter < V_VISIBLE + V_FRONT + V_SYNC));
    end

    always @(*) begin
        pixel_x = h_counter;
        pixel_y = v_counter;
    end

    assign display_area = (h_counter < H_VISIBLE) && (v_counter < V_VISIBLE);
endmodule
