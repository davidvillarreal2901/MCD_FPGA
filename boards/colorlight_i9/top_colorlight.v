module top_colorlight (
    // Reloj y reset de la placa
    input  wire       clk25,
    input  wire       cpu_reset_n,

    // TTP226
    input  wire [7:0] touch,

    // Pulsador NEXT / START activo en bajo
    input  wire       button_n,

    // 8 LED externos
    output wire [7:0] led,

    // LED D2 de la Colorlight, activo en bajo
    output wire       user_led_n
);

    // Reset
    //
    // La Colorlight entrega cpu_reset_n activo en bajo.
    // El sistema utiliza rst activo en alto.

    wire rst;

    assign rst = ~cpu_reset_n;

    // Señales del sistema

    wire [7:0] A_value;
    wire [7:0] B_value;
    wire [7:0] mcd_value;

    wire       start;
    wire       done;

    wire [1:0] ui_state;

    wire [7:0] touch_sync;
    wire [7:0] touch_pulse;

    wire button_sync;
    wire button_clean;
    wire button_pulse;



    // Sistema completo
    //
    // 25 MHz / 250000 = 10 ms de debounce


    mcd_system #(
        .BUTTON_DEBOUNCE_COUNT(250000)
    ) u_system (
        .clk              (clk25),
        .rst              (rst),

        .touch_raw        (touch),
        .button_n         (button_n),

        .led_value        (led),

        .A_value          (A_value),
        .B_value          (B_value),
        .mcd_value        (mcd_value),

        .start_out        (start),
        .done_out         (done),

        .ui_state         (ui_state),

        .touch_sync_out   (touch_sync),
        .touch_pulse_out  (touch_pulse),

        .button_sync_out  (button_sync),
        .button_clean_out (button_clean),
        .button_pulse_out (button_pulse)
    );


    // LED integrado D2
    //
    // Se mantiene encendido mientras estemos mostrando RESULT.
    //
    // ui_state:
    // 00 = EDIT_A
    // 01 = EDIT_B
    // 10 = RUN
    // 11 = RESULT
    //
    // El LED físico es activo en bajo.

    assign user_led_n = ~(ui_state == 2'd3);

endmodule
