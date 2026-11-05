`ifndef DATAPATH_V
`define DATAPATH_V

`include "mux2.v"
`include "Reg_8bit.v"
`include "Or_8bit.v"
`include "Restador_8bit.v"

module datapath (
    input  wire       clk,
    input  wire       rst,
    input  wire [7:0] A,
    input  wire [7:0] B,

    // Señales de control desde la UC
    input  wire       sel,     // 0: carga A/B, 1: carga R
    input  wire       ldX,
    input  wire       ldY,
    input  wire       op,      // 0: P-Q = X-Y, 1: P-Q = Y-X

    // Señales de estado hacia la UC
    output wire       neq,     // 1 si X != Y
    output wire       lt,      // 1 si P < Q (borrow del restador)
    output wire       zero,    // 1 si X == 0 o Y == 0

    // Resultado
    output wire [7:0] MCD
);

    wire [7:0] X, Y;           // salidas de los registros
    wire [7:0] x_in, y_in;     // entradas de los registros
    wire [7:0] P, Q, R;        // operandos y resultado del restador
    wire       or_x, or_y;     // OR de X y de Y (detección de cero)

    // ---------------- MUX de entrada a los registros ----------------
    mux2 #(.WIDTH(8)) mux_x (.d0(A), .d1(R), .sel(sel), .y(x_in));
    mux2 #(.WIDTH(8)) mux_y (.d0(B), .d1(R), .sel(sel), .y(y_in));

    // ---------------- Registros ----------------
    Reg_8bit #(.WIDTH(8)) regX (.clk(clk), .rst(rst), .ld(ldX), .d(x_in), .q(X));
    Reg_8bit #(.WIDTH(8)) regY (.clk(clk), .rst(rst), .ld(ldY), .d(y_in), .q(Y));

    // ---------------- MUX de operandos del restador ----------------
    mux2 #(.WIDTH(8)) mux_p (.d0(X), .d1(Y), .sel(op), .y(P));   // minuendo
    mux2 #(.WIDTH(8)) mux_q (.d0(Y), .d1(X), .sel(op), .y(Q));   // sustraendo

    // ---------------- Restador: R = P - Q ----------------
    Restador_8bit sub (.a(P), .b(Q), .d(R), .bout(lt));

    // ---------------- neq: OR de los 8 bits de R ----------------
    Or_8bit or_r (.a(R), .y(neq));

    // ---------------- Detección de cero: NAND(|X, |Y) ----------------
    Or_8bit or_xx (.a(X), .y(or_x));
    Or_8bit or_yy (.a(Y), .y(or_y));
    assign zero = ~(or_x & or_y);

    // ---------------- Salida: X | Y bit a bit ----------------
    assign MCD = X | Y;

endmodule

`endif