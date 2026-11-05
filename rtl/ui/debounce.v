//Este es porque los pulsadores no son perfectos, y generan rebotes. 
//Este módulo se encarga de filtrar esos rebotes, y generar un pulso
//limpio de un ciclo por cada pulsación.

module debounce #(
    parameter integer COUNT_MAX = 250000
)(
    input  wire clk,
    input  wire rst,

    input  wire signal_in,
    output reg  signal_out
);

    // Número de bits necesarios para contar hasta COUNT_MAX.
    localparam integer COUNT_WIDTH =
        (COUNT_MAX <= 1) ? 1 : $clog2(COUNT_MAX);

    reg [COUNT_WIDTH-1:0] counter;


    always @(posedge clk) begin

        if (rst) begin

            counter    <= 0;
            signal_out <= 1'b0;

        end
        else begin

            // Si la entrada coincide con la salida estable,
            // no hay ningún cambio pendiente.
            if (signal_in == signal_out) begin

                counter <= 0;

            end

            // Si son distintas, espero que el nuevo valor
            // permanezca estable durante COUNT_MAX ciclos.
            else begin

                if (counter == COUNT_MAX - 1) begin

                    signal_out <= signal_in;
                    counter    <= 0;

                end
                else begin

                    counter <= counter + 1'b1;

                end

            end

        end

    end

endmodule