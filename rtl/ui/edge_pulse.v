// Este módulo detecta flancos ascendentes de una señal de entrada
// y genera un único pulso de un ciclo de reloj en la salida.

// Compara el valor actual de cada entrada con su valor del ciclo 
// anterior y genera un pulso de un solo ciclo cuando detecta una 
// transición ascendente de 0 a 1.

module edge_pulse #(
    parameter WIDTH = 8
)(
    input  wire                 clk,
    input  wire                 rst,
    input  wire [WIDTH-1:0]     signal_in,
    output wire [WIDTH-1:0]     pulse_out
);

    reg [WIDTH-1:0] previous;


    always @(posedge clk) begin

        if (rst)
            previous <= {WIDTH{1'b0}};
        else
            previous <= signal_in;

    end


    // Detecta únicamente transición 0 -> 1.
    //
    // actual  anterior
    //
    //   0        0    -> 0
    //   0        1    -> 0
    //   1        0    -> 1   <--- flanco ascendente
    //   1        1    -> 0

    assign pulse_out = signal_in & ~previous;

endmodule