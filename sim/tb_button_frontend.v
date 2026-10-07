`timescale 1ns/1ps

module tb_button_frontend;

    reg clk;
    reg rst;

    reg button_n;

    wire button_pulse;
    wire button_sync;
    wire button_clean;


    // ============================================================
    // DUT
    // ============================================================

    button_frontend #(
        .DEBOUNCE_COUNT(4)
    ) dut (
        .clk          (clk),
        .rst          (rst),
        .button_n     (button_n),

        .button_pulse (button_pulse),
        .button_sync  (button_sync),
        .button_clean (button_clean)
    );


    // 25 MHz
    initial clk = 1'b0;
    always #20 clk = ~clk;


    // ============================================================
    // VCD
    // ============================================================

    initial begin

        $dumpfile("build/tb_button_frontend.vcd");
        $dumpvars(0, tb_button_frontend);

    end


    initial begin

        rst      = 1'b1;

        // Activo en bajo:
        // 1 = botón libre.
        button_n = 1'b1;


        repeat (4)
            @(posedge clk);


        @(negedge clk);
        rst = 1'b0;


        // ========================================================
        // Simular rebote al PRESIONAR
        // ========================================================

        #13 button_n = 1'b0;

        #17 button_n = 1'b1;
        #15 button_n = 1'b0;
        #18 button_n = 1'b1;
        #14 button_n = 1'b0;


        // Ahora permanece realmente presionado.
        repeat (10)
            @(posedge clk);


        // ========================================================
        // Simular rebote al SOLTAR
        // ========================================================

        #11 button_n = 1'b1;

        #16 button_n = 1'b0;
        #13 button_n = 1'b1;
        #18 button_n = 1'b0;
        #12 button_n = 1'b1;


        // Ahora permanece realmente liberado.
        repeat (10)
            @(posedge clk);


        // ========================================================
        // Segunda pulsación limpia
        // ========================================================

        @(negedge clk);

        button_n = 1'b0;


        repeat (8)
            @(posedge clk);


        @(negedge clk);

        button_n = 1'b1;


        repeat (8)
            @(posedge clk);


        $display("==============================");
        $display("Fin simulacion button_frontend");
        $display("==============================");

        $finish;

    end

endmodule