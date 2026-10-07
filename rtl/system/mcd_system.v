//Este es pa conectar touch + input_control + mcd_top

module mcd_system (
    input  wire       clk,
    input  wire       rst,

    // Entradas físicas provenientes de los botoncitos
    input  wire [7:0] touch_raw,

    // Por ahora el botón ya entra como pulso limpio.
    // Más adelante agregaré sincronización + debounce.
    input  wire       button_pulse,

    // Valor que irá a los 8 LED
    output wire [7:0] led_value,

    // Salidas de observación
    output wire [7:0] A_value,
    output wire [7:0] B_value,
    output wire [7:0] mcd_value,

    output wire       start_out,
    output wire       done_out,

    output wire [1:0] ui_state,

    // También las dejo visibles pa' simulación
    output wire [7:0] touch_sync_out,
    output wire [7:0] touch_pulse_out
);

    // Señales internas


    wire [7:0] touch_sync;
    wire [7:0] touch_pulse;

    wire [7:0] A;
    wire [7:0] B;

    wire [7:0] mcd;

    wire start;
    wire done;



    // Interfaz de las teclas capacitivas
    //
    // touch_raw:
    // señal física/asíncrona proveniente del TTP226.
    //
    // touch_sync:
    // señal ya sincronizada con clk.
    //
    // touch_pulse:
    // pulso de un ciclo por cada nueva pulsación.


    touch_frontend #(
        .WIDTH(8)
    ) u_touch (
        .clk         (clk),
        .rst         (rst),
        .touch_raw   (touch_raw),
        .touch_sync  (touch_sync),
        .touch_pulse (touch_pulse)
    );



    // Control de interfaz
    //
    // EDIT_A:
    //     las teclas modifican A.
    //
    // EDIT_B:
    //     las teclas modifican B.
    //
    // RUN:
    //     genera start y espera done.
    //
    // RESULT:
    //     muestra el MCD.


    input_control u_input (
        .clk          (clk),
        .rst          (rst),

        .touch_pulse  (touch_pulse),
        .button_pulse (button_pulse),

        .done         (done),
        .mcd          (mcd),

        .A            (A),
        .B            (B),
        .start        (start),

        .led_value    (led_value),
        .ui_state     (ui_state)
    );



    // Núcleo MCD del Drive


    mcd_top u_mcd (
        .clk   (clk),
        .rst   (rst),
        .start (start),

        .A     (A),
        .B     (B),

        .MCD   (mcd),
        .done  (done)
    );



    // Señales visibles desde fuera


    assign A_value         = A;
    assign B_value         = B;

    assign mcd_value       = mcd;

    assign start_out       = start;
    assign done_out        = done;

    assign touch_sync_out  = touch_sync;
    assign touch_pulse_out = touch_pulse;

endmodule
