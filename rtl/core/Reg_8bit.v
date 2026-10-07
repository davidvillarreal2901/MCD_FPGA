`ifndef REG_8BIT_V
`define REG_8BIT_V

// Registro con carga habilitada (load enable) y reset síncrono
module Reg_8bit #(
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             rst,   // reset síncrono, activo en alto
    input  wire             ld,    // habilita la carga
    input  wire [WIDTH-1:0] d,
    output reg  [WIDTH-1:0] q
);

    always @(posedge clk) begin
        if (rst)
            q <= {WIDTH{1'b0}};
        else if (ld)
            q <= d;
        // si ld = 0, q conserva su valor
    end

endmodule

`endif