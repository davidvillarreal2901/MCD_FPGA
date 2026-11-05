//Este es el módulo pa' capturar los datos
//de entrada de la interfaz, según los botones.
//
module input_control (
    input  wire       clk,
    input  wire       rst,

    input  wire [7:0] touch_pulse,
    input  wire       button_pulse,

    input  wire       done,
    input  wire [7:0] mcd,

    output reg  [7:0] A,
    output reg  [7:0] B,
    output reg        start,

    output reg  [7:0] led_value,
    output reg  [1:0] ui_state
);

    // Estados de la interfaz
    localparam EDIT_A = 2'd0;
    localparam EDIT_B = 2'd1;
    localparam RUN    = 2'd2;
    localparam RESULT = 2'd3;


//------------------------------------Lógica secuencial


    always @(posedge clk) begin

        if (rst) begin

            A        <= 8'd0;
            B        <= 8'd0;
            start    <= 1'b0;
            ui_state <= EDIT_A;

        end
        else begin

            // start debe durar solo un ciclo.
            start <= 1'b0;

            case (ui_state)

                // Editar A
                // Cada toque invierte el bit correspondiente.


                EDIT_A: begin

                    A <= A ^ touch_pulse;

                    if (button_pulse)
                        ui_state <= EDIT_B;

                end


                // Editar B

                EDIT_B: begin

                    B <= B ^ touch_pulse;

                    if (button_pulse) begin
                        start    <= 1'b1;   //Esta si es en 1 pa' pasar de IDLE a LOAD
                        ui_state <= RUN;
                    end

                end


                // Esperar a que el MCD termine


                RUN: begin

                    if (done)
                        ui_state <= RESULT;

                end

                // Mostrar resultado.
                // Un nuevo toque del botón reinicia A y B.


                RESULT: begin

                    if (button_pulse) begin
                        A        <= 8'd0;
                        B        <= 8'd0;
                        ui_state <= EDIT_A;
                    end

                end


                // Seguridad
                default: begin

                    A        <= 8'd0;
                    B        <= 8'd0;
                    start    <= 1'b0;
                    ui_state <= EDIT_A;

                end

            endcase

        end

    end



    // Valor que será mostrado en los 8 LEDs


    always @(*) begin

        case (ui_state)

            EDIT_A:
                led_value = A;

            EDIT_B:
                led_value = B;

            RUN:
                led_value = 8'd0;

            RESULT:
                led_value = mcd;

            default:
                led_value = 8'd0;

        endcase

    end

endmodule