`ifndef RESTADOR_1BIT_V
`define RESTADOR_1BIT_V

module Restador_1bit (
    input  a,      // minuendo
    input  b,      // sustraendo
    input  bin,    // borrow de entrada
    output d,      // diferencia
    output bout    // borrow de salida
);
    assign d    = a ^ b ^ bin;
    assign bout = (~a & b) | ((~a | b) & bin);
endmodule
`endif