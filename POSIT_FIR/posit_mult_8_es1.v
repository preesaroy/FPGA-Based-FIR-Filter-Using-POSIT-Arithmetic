
module posit_mult_8_es1 (
    input  logic [7:0] a,
    input  logic [7:0] b,
    output logic [7:0] y
);

    localparam logic [7:0] POSIT_ZERO = 8'h00;
    localparam logic [7:0] POSIT_NAR  = 8'h80;

    function automatic real posit_decode(input logic [7:0] p);
        integer i, j, run, k, exponent_value;
        logic [7:0] mag_bits;
        logic regime_bit;
        real fraction, scale, result_value;
        begin
            if ((^p) === 1'bx) begin
                posit_decode = 0.0;
            end
            else if ((p == POSIT_ZERO) || (p == POSIT_NAR)) begin
                posit_decode = 0.0;
            end
            else begin
                if (p[7])
                    mag_bits = (~p) + 8'd1;
                else
                    mag_bits = p;

                regime_bit = mag_bits[6];
                run = 0;
                i = 6;

                while ((i >= 0) &&
                       (mag_bits[i] == regime_bit)) begin
                    run = run + 1;
                    i = i - 1;
                end

                if (regime_bit)
                    k = run - 1;
                else
                    k = -run;

                if (i >= 0)
                    i = i - 1;

                exponent_value = 0;
                if (i >= 0) begin
                    exponent_value = mag_bits[i];
                    i = i - 1;
                end

                fraction = 0.0;
                scale = 0.5;

                for (j = i; j >= 0; j = j - 1) begin
                    if (mag_bits[j])
                        fraction = fraction + scale;
                    scale = scale / 2.0;
                end

                result_value = 1.0 + fraction;

                for (j = 0; j < k; j = j + 1)
                    result_value = result_value * 4.0;

                for (j = 0; j > k; j = j - 1)
                    result_value = result_value / 4.0;

                if (exponent_value != 0)
                    result_value = result_value * 2.0;

                if (p[7])
                    result_value = -result_value;

                posit_decode = result_value;
            end
        end
    endfunction

    function automatic logic [7:0] posit_encode(input real value);
        integer i, j, k, pos, exponent_value;
        real mag, norm, frac;
        logic [7:0] bits;
        logic negative;
        begin
            bits = 8'h00;
            negative = (value < 0.0);
            mag = negative ? -value : value;

            if (value != value) begin
                posit_encode = POSIT_NAR;
            end
            else if (mag == 0.0) begin
                posit_encode = POSIT_ZERO;
            end
            else begin
                k = 0;
                norm = mag;

                while (norm >= 4.0) begin
                    norm = norm / 4.0;
                    k = k + 1;
                end

                while (norm < 1.0) begin
                    norm = norm * 4.0;
                    k = k - 1;
                end

                pos = 6;

                if (k >= 0) begin
                    for (j = 0; j < k + 1; j = j + 1) begin
                        if (pos >= 0) begin
                            bits[pos] = 1'b1;
                            pos = pos - 1;
                        end
                    end
                    if (pos >= 0) begin
                        bits[pos] = 1'b0;
                        pos = pos - 1;
                    end
                end
                else begin
                    for (j = 0; j < -k; j = j + 1) begin
                        if (pos >= 0) begin
                            bits[pos] = 1'b0;
                            pos = pos - 1;
                        end
                    end
                    if (pos >= 0) begin
                        bits[pos] = 1'b1;
                        pos = pos - 1;
                    end
                end

                exponent_value = 0;
                if (norm >= 2.0) begin
                    exponent_value = 1;
                    norm = norm / 2.0;
                end

                if (pos >= 0) begin
                    bits[pos] = exponent_value[0];
                    pos = pos - 1;
                end

                frac = norm - 1.0;
                while (pos >= 0) begin
                    frac = frac * 2.0;
                    if (frac >= 1.0) begin
                        bits[pos] = 1'b1;
                        frac = frac - 1.0;
                    end
                    else begin
                        bits[pos] = 1'b0;
                    end
                    pos = pos - 1;
                end

                if (negative)
                    bits = (~bits) + 8'd1;

                posit_encode = bits;
            end
        end
    endfunction

    real av;
    real bv;
    real result_value;

    always_comb begin
        if ((a == POSIT_NAR) || (b == POSIT_NAR)) begin
            y = POSIT_NAR;
        end
        else begin
            av = posit_decode(a);
            bv = posit_decode(b);
            result_value = av * bv;
            y = posit_encode(result_value);
        end
    end

endmodule
