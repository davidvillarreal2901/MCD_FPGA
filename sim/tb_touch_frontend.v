`timescale 1ns/1ps

module tb_touch_frontend;

    reg clk;
    reg rst;

    reg  [7:0] touch_raw;

    wire [7:0] touch_sync;
    wire [7:0] touch_pulse;


    // --------------------------------------------------
    // DUT
    // --------------------------------------------------

    touch_frontend #(
        .WIDTH(8)
    ) dut (
        .clk         (clk),
        .rst         (rst),
        .touch_raw   (touch_raw),
        .touch_sync  (touch_sync),
        .touch_pulse (touch_pulse)
    );


    // --------------------------------------------------
    // Reloj
    //
    // Colorlight:
    // 25 MHz -> período = 40 ns
    // --------------------------------------------------

    initial
        clk = 1'b0;

    always #20 clk = ~clk;


    // --------------------------------------------------
    // VCD
    // --------------------------------------------------

    initial begin

        $dumpfile("build/tb_touch_frontend.vcd");

        $dumpvars(0, tb_touch_frontend);

    end


    // --------------------------------------------------
    // Estímulos
    // --------------------------------------------------

    initial begin

        rst       = 1'b1;
        touch_raw = 8'b00000000;


        // Mantener reset varios ciclos.
        repeat (3)
            @(posedge clk);


        @(negedge clk);

        rst = 1'b0;


        // ==================================================
        // PRUEBA 1
        //
        // Presionar tecla 1 -> bit 0
        // ==================================================

        #13;

        touch_raw[0] = 1'b1;


        // Mantenerla presionada bastante tiempo.
        repeat (8)
            @(posedge clk);


        touch_raw[0] = 1'b0;


        repeat (5)
            @(posedge clk);


        // ==================================================
        // PRUEBA 2
        //
        // Volver a presionar tecla 1
        // ==================================================

        #7;

        touch_raw[0] = 1'b1;


        repeat (6)
            @(posedge clk);


        touch_raw[0] = 1'b0;


        repeat (5)
            @(posedge clk);


        // ==================================================
        // PRUEBA 3
        //
        // Presionar tecla 4 -> bit 3
        // ==================================================

        #11;

        touch_raw[3] = 1'b1;


        repeat (7)
            @(posedge clk);


        touch_raw[3] = 1'b0;


        repeat (5)
            @(posedge clk);


        // ==================================================
        // PRUEBA 4
        //
        // Dos teclas simultáneamente:
        // bit 2 y bit 7
        // ==================================================

        #9;

        touch_raw[2] = 1'b1;
        touch_raw[7] = 1'b1;


        repeat (7)
            @(posedge clk);


        touch_raw[2] = 1'b0;
        touch_raw[7] = 1'b0;


        repeat (5)
            @(posedge clk);


        $display("======================================");
        $display("Fin simulacion touch_frontend");
        $display("======================================");

        $finish;

    end

endmodule