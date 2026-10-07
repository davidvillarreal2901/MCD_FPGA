`ifndef RESTADOR_8BIT_V
`define RESTADOR_8BIT_V

`include "Restador_1bit.v"

// Restador de 8 bits en cadena (ripple-borrow): D = A - B
// bout = 1 cuando A < B (hubo préstamo en el bit más significativo)
module Restador_8bit (
    input  [7:0] a,      // minuendo
    input  [7:0] b,      // sustraendo
    output [7:0] d,      // diferencia
    output       bout    // borrow de salida (lt)
);
    wire [8:0] borrow;   // borrow[i] es el borrow de entrada del bit i

    assign borrow[0] = 1'b0;      // el bit 0 no recibe préstamo

    Restador_1bit rb0 (.a(a[0]), .b(b[0]), .bin(borrow[0]), .d(d[0]), .bout(borrow[1]));
    Restador_1bit rb1 (.a(a[1]), .b(b[1]), .bin(borrow[1]), .d(d[1]), .bout(borrow[2]));
    Restador_1bit rb2 (.a(a[2]), .b(b[2]), .bin(borrow[2]), .d(d[2]), .bout(borrow[3]));
    Restador_1bit rb3 (.a(a[3]), .b(b[3]), .bin(borrow[3]), .d(d[3]), .bout(borrow[4]));
    Restador_1bit rb4 (.a(a[4]), .b(b[4]), .bin(borrow[4]), .d(d[4]), .bout(borrow[5]));
    Restador_1bit rb5 (.a(a[5]), .b(b[5]), .bin(borrow[5]), .d(d[5]), .bout(borrow[6]));
    Restador_1bit rb6 (.a(a[6]), .b(b[6]), .bin(borrow[6]), .d(d[6]), .bout(borrow[7]));
    Restador_1bit rb7 (.a(a[7]), .b(b[7]), .bin(borrow[7]), .d(d[7]), .bout(borrow[8]));

    assign bout = borrow[8];
endmodule

`endif