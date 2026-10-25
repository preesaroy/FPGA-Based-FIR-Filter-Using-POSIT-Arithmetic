`timescale 1ns / 1ps

module fir_tb_posit;

    reg clk = 0;
    reg rst;
    reg [7:0] x_in;
    wire [7:0] y_out;

    // Instantiate POSIT FIR filter
    fir_filter_posit uut (
        .clk(clk),
        .rst(rst),
        .x_in(x_in),
        .y_out(y_out)
    );

    // Clock generation: 10 ns period
    always #5 clk = ~clk;

    initial begin
        rst  = 1;
        x_in = 8'h00;  // POSIT zero

        #20 rst = 0;

        // Input sequence encoded in POSIT<8,1>
        #10 x_in = 8'h40;  // 1.0
        #10 x_in = 8'h50;  // 2.0
        #10 x_in = 8'h58;  // 3.0
        #10 x_in = 8'h60;  // 4.0
        #10 x_in = 8'h64;  // 5.0
        #10 x_in = 8'h00;  // 0.0

        #100 $finish;
    end

    // Display encoded input and output
    initial begin
        $monitor(
            "Time=%0t | rst=%b | x_in(POSIT)=%h | y_out(POSIT)=%h",
            $time, rst, x_in, y_out
        );
    end

endmodule