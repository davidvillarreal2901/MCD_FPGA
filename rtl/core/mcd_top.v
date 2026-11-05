`ifndef MCD_TOP_V
`define MCD_TOP_V

`include "datapath.v"
`include "fsm.v"

module mcd_top (
    input  wire       clk,
    input  wire       rst,
    input  wire       start,
    input  wire [7:0] A,
    input  wire [7:0] B,
    output wire [7:0] MCD,
    output wire       done
);

    wire sel, ldX, ldY, op;    // control: FSM -> datapath
    wire zero, neq, lt;        // estado: datapath -> FSM

    fsm ctrl (
        .clk  (clk),
        .rst  (rst),
        .start(start),
        .zero (zero),
        .neq  (neq),
        .lt   (lt),
        .sel  (sel),
        .ldX  (ldX),
        .ldY  (ldY),
        .op   (op),
        .done (done)
    );

    datapath dp (
        .clk (clk),
        .rst (rst),
        .A   (A),
        .B   (B),
        .sel (sel),
        .ldX (ldX),
        .ldY (ldY),
        .op  (op),
        .neq (neq),
        .lt  (lt),
        .zero(zero),
        .MCD (MCD)
    );

endmodule

`endif