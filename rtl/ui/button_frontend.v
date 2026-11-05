module button_frontend #(
    parameter integer DEBOUNCE_COUNT = 250000
)(
    input  wire clk,
    input  wire rst,

    // Botón físico activo en bajo.
    input  wire button_n,

    // Pulso de un ciclo por cada pulsación válida.
    output wire button_pulse,

    // Las dejo visibles para simulación/debug.
    output wire button_sync,
    output wire button_clean
);

    wire button_n_sync;
    wire button_pressed;

    // Sincronización

    sync_2ff #(
        .WIDTH(1)
    ) u_sync (
        .clk      (clk),
        .rst      (rst),
        .async_in (button_n),
        .sync_out (button_n_sync)
    );


    // El pin físico es activo en bajo:
    //
    // button_n = 0 -> pulsado
    //
    // Internamente lo dejaré como activo en alto:
    //
    // button_pressed = 1 -> pulsado
    assign button_pressed = ~button_n_sync;

    assign button_sync = button_pressed;

    // Antirrebote
    debounce #(
        .COUNT_MAX(DEBOUNCE_COUNT)
    ) u_debounce (
        .clk        (clk),
        .rst        (rst),
        .signal_in  (button_pressed),
        .signal_out (button_clean)
    );

    // Pulso de un solo ciclo

    edge_pulse #(
        .WIDTH(1)
    ) u_edge (
        .clk       (clk),
        .rst       (rst),
        .signal_in (button_clean),
        .pulse_out (button_pulse)
    );

endmodule