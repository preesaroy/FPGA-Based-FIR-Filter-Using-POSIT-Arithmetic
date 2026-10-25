module fir_filter_posit (
    input         clk,
    input         rst,
    input  [7:0]  x_in,      // POSIT<8,1> input
    output reg [7:0] y_out   // POSIT<8,1> output
);

    // POSIT<8,1> encodings
    // 1.0 = 8'b01000000 = 8'h40
    // 2.0 = 8'b01010000 = 8'h50
    localparam [7:0] B0 = 8'h40;
    localparam [7:0] B1 = 8'h50;
    localparam [7:0] B2 = 8'h50;
    localparam [7:0] B3 = 8'h40;

    // Delay line stores POSIT-encoded samples
    reg [7:0] x1, x2, x3;

    // Multiplier outputs
    wire [7:0] p0, p1, p2, p3;

    // Adder outputs
    wire [7:0] sum01, sum012, sum0123;

    // POSIT multipliers
    posit_mult_8_es1 M0 (.a(x_in), .b(B0), .y(p0));
    posit_mult_8_es1 M1 (.a(x1),   .b(B1), .y(p1));
    posit_mult_8_es1 M2 (.a(x2),   .b(B2), .y(p2));
    posit_mult_8_es1 M3 (.a(x3),   .b(B3), .y(p3));

    // POSIT adders
    posit_add_8_es1 A0 (.a(p0),    .b(p1),    .y(sum01));
    posit_add_8_es1 A1 (.a(sum01), .b(p2),    .y(sum012));
    posit_add_8_es1 A2 (.a(sum012),.b(p3),    .y(sum0123));

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            x1    <= 8'h00;
            x2    <= 8'h00;
            x3    <= 8'h00;
            y_out <= 8'h00;
        end
        else begin
            x3    <= x2;
            x2    <= x1;
            x1    <= x_in;

            y_out <= sum0123;
        end
    end

endmodule