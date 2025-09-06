module clock_divider (
    input wire clk,
    input wire rst,
    output wire game_tick,   
    output wire vga_clk      
);


    reg [20:0] game_tick_counter;
    reg game_clk_in;
    reg vga_clk_in;
    reg vga_counter;             


    always @(posedge clk) 
    begin
        if (rst) 
        begin
            vga_counter <= 1'b0;
            vga_clk_in <= 1'b0;
        end 
        else 
        begin
            if (vga_counter == 1) 
            begin
                vga_counter <= 1'b0;
                vga_clk_in <= ~vga_clk_in;
            end 
            else 
            begin
                vga_counter <= vga_counter + 1'b1;
            end
        end
    end


    always @(posedge clk) 
    begin
        if (rst) 
        begin
            game_tick_counter <= 21'b0;
            game_clk_in <= 1'b0;
        end 
        else 
        begin
            if (game_tick_counter == 833_332) 
            begin
                game_tick_counter <= 21'b0;
                game_clk_in <= ~game_clk_in;
            end 
            else 
            begin
                game_tick_counter <= game_tick_counter + 21'b1;
            end
        end
    end

    assign game_tick = game_clk_in;
    assign vga_clk = vga_clk_in;

endmodule
