// Este módulo es pa' sincronizar señales asíncronas del pulsador
// a eñ reloj de la FPGA, para que si se queda el dedo pulsando no se
// generen múltiples pulsos. Se usa un sincronizador de 2 flip-flops

module sync_2ff #(
    parameter WIDTH = 8
)(
    input  wire                 clk,
    input  wire                 rst,
    input  wire [WIDTH-1:0]     async_in,
    output wire [WIDTH-1:0]     sync_out
);

    // Primer y segundo flip-flop del sincronizador.
    //
    // async_in viene de fuera de la FPGA y puede cambiar
    // en cualquier instante respecto al reloj.
    //
    // El primer FF puede entrar en metastabilidad.
    // El segundo reduce la probabilidad de
    // que esa metastabilidad llegue al resto del circuito.

    (* async_reg = "true" *)
    reg [WIDTH-1:0] sync_ff1;

    (* async_reg = "true" *)
    reg [WIDTH-1:0] sync_ff2;


    always @(posedge clk) begin

        if (rst) begin
            sync_ff1 <= {WIDTH{1'b0}};
            sync_ff2 <= {WIDTH{1'b0}};
        end
        else begin
            sync_ff1 <= async_in;
            sync_ff2 <= sync_ff1;
        end

    end


    assign sync_out = sync_ff2;

endmodule