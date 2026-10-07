//Este es pa' la lógico del módulo touch, conectar el sincronizador y
//el detector de flancos. Esto es para que ahorita que ponga el input_control
//solo me preocupoe por conectar, no por sincronizar y etc etc.

module touch_frontend #(
    parameter WIDTH = 8
)(
    input  wire                 clk,
    input  wire                 rst,

    input  wire [WIDTH-1:0]     touch_raw,

    output wire [WIDTH-1:0]     touch_sync,
    output wire [WIDTH-1:0]     touch_pulse
);


    // --------------------------------------------------
    // Sincronización
    // --------------------------------------------------

    sync_2ff #(
        .WIDTH(WIDTH)
    ) u_sync (
        .clk      (clk),
        .rst      (rst),
        .async_in (touch_raw),
        .sync_out (touch_sync)
    );


    // --------------------------------------------------
    // Detección de flanco
    // --------------------------------------------------

    edge_pulse #(
        .WIDTH(WIDTH)
    ) u_edge (
        .clk       (clk),
        .rst       (rst),
        .signal_in (touch_sync),
        .pulse_out (touch_pulse)
    );


endmodule