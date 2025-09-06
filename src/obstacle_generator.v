module obstacle_generator (
    input wire clk,
    input wire rst,
    input wire game_tick,
    output wire [9:0] obstacle_x1,
    output wire [9:0] obstacle_x2
);

    localparam X1_RESET_POSITION     = 540;
    localparam X2_RESET_POSITION     = 750;
    localparam STAGGER_OFFSET        = 120;  
    localparam VELOCITY               = 10;


    reg [9:0] x1_reg;
    reg [9:0] x2_reg;

    always @(posedge clk) begin
        if (rst) 
        begin
            x1_reg <= X1_RESET_POSITION;
            x2_reg <= X2_RESET_POSITION;
        end 
        else if (game_tick) 
        begin
            if (x1_reg <= VELOCITY)
            begin
                x1_reg <= X1_RESET_POSITION;
            end
            else
            begin
                x1_reg <= x1_reg - VELOCITY;
            end

            if (x2_reg <= VELOCITY) 
            begin
                if (x1_reg > X1_RESET_POSITION - STAGGER_OFFSET)
                begin
                    x2_reg <= X1_RESET_POSITION + STAGGER_OFFSET;
                end
                else
                begin
                    x2_reg <= X2_RESET_POSITION;
                end
            end 
            else 
            begin
                x2_reg <= x2_reg - VELOCITY;
            end
        end
    end

    assign obstacle_x1 = x1_reg;
    assign obstacle_x2 = x2_reg;

endmodule
