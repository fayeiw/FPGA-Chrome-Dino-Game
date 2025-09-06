module input_handler (
    input wire clk,
    input wire rst,
    input wire btn_jump,
    output reg jump_pressed
);

    reg [7:0] counter;

    always @ (posedge clk)
    begin
        if (rst)
        begin
            counter <= 8'b0;
        end
        else
        begin
            if (btn_jump)
            begin
                counter <= {counter[7:1], 1'b1};
            end
            else
            begin
                counter <= {counter[7:1], 1'b0};
            end
        end
    end
    
    always @ (*)
    begin
        if (counter == 8'b11111111)
        begin
            jump_pressed = 1;
        end
        else if (counter == 8'b00000000)
        begin
            jump_pressed = 0;
        end
    end
endmodule