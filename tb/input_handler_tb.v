// Directed testbench for input_handler: tests reset behavior, debouncing push to all‐1’s, mid‐state hold, and release to all‐0’s
`timescale 1ns/1ps
module tb_input_handler;
    reg         clk, rst, btn_jump;
    wire        jump_pressed;
    reg [7:0]   counter_shadow;
    integer     i;

    input_handler dut (
        .clk(clk),
        .rst(rst),
        .btn_jump(btn_jump),
        .jump_pressed(jump_pressed)
    );

    initial 
    begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial 
    begin
        // 1) Reset behavior: counter=0 → jump_pressed=0
        rst = 1; btn_jump = 0;
        #20;
        rst = 0; #10;
        if (jump_pressed !== 0)
            $error("After reset: jump_pressed=%b, expected 0", jump_pressed);

        // 2) Press button repeatedly: counter shifts in 1’s
        btn_jump = 1;
        counter_shadow = 0;
        for (i = 0; i < 8; i = i + 1) begin
            #10;  // wait one clock
            counter_shadow = {counter_shadow[7:1], 1'b1};
            if (dut.counter !== counter_shadow)
                $error("Cycle %0d: counter=%b, expected=%b", i, dut.counter, counter_shadow);
            if (jump_pressed !== 0)
                $error("Cycle %0d: jump_pressed asserted prematurely", i);
        end
        // After 8 ones, jump_pressed should assert
        #10;
        if (jump_pressed !== 1)
            $error("After full press: jump_pressed=%b, expected 1", jump_pressed);

        // 3) Release button: counter shifts in 0’s, jump_pressed holds until all zeros
        btn_jump = 0;
        for (i = 0; i < 7; i = i + 1) begin
            #10;
            if (jump_pressed !== 1)
                $error("Release mid: jump_pressed dropped early at cycle %0d", i);
        end
        // Final shift to all zeros
        #10;
        if (jump_pressed !== 0)
            $error("After release: jump_pressed=%b, expected 0", jump_pressed);

        $display("All input_handler tests passed");
        $finish;
    end
endmodule
