module game_fsm (
    input wire clk,
    input wire rst,
    input wire game_tick,
    input wire jump_pressed,
    input wire collision,
    output reg [9:0] dino_y,
    output reg game_over
);

    localparam IDLE      = 2'b00;
    localparam JUMPING   = 2'b01;
    localparam FALLING   = 2'b10;
    localparam GAME_OVER = 2'b11;

    reg [1:0] state, state_next;
    reg [1:0] velocity;
    reg [9:0] dino_y_next;

    localparam JUMP_STRENGTH = 40;
    localparam GRAVITY = 2;

    always @(posedge clk) 
    begin
        if (rst) 
        begin
            state <= IDLE;
            dino_y <= 0;
            velocity <= 0;
            game_over <= 0;
        end 
        else if (game_tick) 
        begin
            state <= state_next;
            dino_y <= dino_y_next;
            game_over <= (state_next == GAME_OVER);
        end
    end

    always @(*) 
    begin
        state_next = state;
        dino_y_next = dino_y;
        case (state)
            IDLE: 
            begin
                if (collision)
                begin
                    state_next = GAME_OVER;
                end
                else if (jump_pressed) 
                begin
                    state_next = JUMPING;
                    velocity = JUMP_STRENGTH;
                end
            end

            JUMPING: 
            begin
                velocity = velocity - GRAVITY;
                dino_y_next = dino_y + velocity;

                if (velocity <= 0)
                begin
                    state_next = FALLING;
                end
                if (collision)
                begin
                    state_next = GAME_OVER;
                end
            end

            FALLING: 
            begin
                velocity = velocity - GRAVITY;
                dino_y_next = (dino_y > velocity) ? dino_y - velocity : 0;

                if (dino_y_next == 0)
                begin
                    state_next = IDLE;
                end
                if (collision)
                begin
                    state_next = GAME_OVER;
                end
            end

            default: 
            begin
                state_next = GAME_OVER;
            end
        endcase
    end
endmodule
