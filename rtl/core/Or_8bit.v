`ifndef OR_8BIT_V
`define OR_8BIT_V

module Or_8bit (
    input  [7:0] a,
    output       y
);
    wire n0, n1, n2, n3;   // nivel 1
    wire m0, m1;           // nivel 2

    assign n0 = a[0] | a[1];
    assign n1 = a[2] | a[3];
    assign n2 = a[4] | a[5];
    assign n3 = a[6] | a[7];

    assign m0 = n0 | n1;
    assign m1 = n2 | n3;

    assign y  = m0 | m1;
endmodule
`endif