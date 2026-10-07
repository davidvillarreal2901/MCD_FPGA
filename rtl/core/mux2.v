`ifndef MUX2_V
`define MUX2_V

module mux2 #(
    parameter WIDTH = 8
)(
    input  wire [WIDTH-1:0] d0,   // entrada seleccionada cuando sel = 0
    input  wire [WIDTH-1:0] d1,   // entrada seleccionada cuando sel = 1
    input  wire             sel,
    output wire [WIDTH-1:0] y
);

    assign y = sel ? d1 : d0;

endmodule

`endif