`timescale 1ns/1ps
`include "mcd_top.v"

module tb_mcd;

    // ---------------- Señales ----------------
    reg        clk = 0;
    reg        rst = 1;
    reg        start = 0;
    reg  [7:0] A = 0, B = 0;
    wire [7:0] MCD;
    wire       done;

    // ---------------- DUT ----------------
    mcd_top dut (
        .clk  (clk),
        .rst  (rst),
        .start(start),
        .A    (A),
        .B    (B),
        .MCD  (MCD),
        .done (done)
    );

    // ---------------- Reloj: periodo 10 ns ----------------
    always #5 clk = ~clk;

    // ---------------- Contadores ----------------
    integer n_tests = 0;
    integer n_ok    = 0;
    integer n_err   = 0;
    integer cycles;
    integer i;

    // ---------------- Modelo de referencia (solo simulacion) ----------------
    function [7:0] gcd_ref;
        input [7:0] a;
        input [7:0] b;
        reg   [7:0] x, y;
        begin
            x = a;
            y = b;
            if (x == 0)
                gcd_ref = y;
            else if (y == 0)
                gcd_ref = x;
            else begin
                while (x != y) begin
                    if (x < y) y = y - x;
                    else       x = x - y;
                end
                gcd_ref = x;
            end
        end
    endfunction

    // ---------------- Tarea: una prueba completa ----------------
    task run_test;
        input [7:0] a_in;
        input [7:0] b_in;
        reg   [7:0] expected;
        begin
            n_tests  = n_tests + 1;
            expected = gcd_ref(a_in, b_in);

            @(negedge clk);
            A     = a_in;
            B     = b_in;
            start = 1;

            // Espera done (con timeout de seguridad)
            cycles = 0;
            @(negedge clk);
            while (!done && cycles < 2000) begin
                @(negedge clk);
                cycles = cycles + 1;
            end

            if (done && (MCD === expected)) begin
                n_ok = n_ok + 1;
                $display("[%0t] OK    #%0d  MCD(%3d,%3d) = %3d  (%0d ciclos)",
                         $time, n_tests, a_in, b_in, MCD, cycles);
            end else begin
                n_err = n_err + 1;
                $display("[%0t] ERROR #%0d  MCD(%3d,%3d) = %3d, esperado %3d  (done=%b)",
                         $time, n_tests, a_in, b_in, MCD, expected, done);
            end

            // Baja start para que la FSM regrese a IDLE
            @(negedge clk);
            start = 0;
            @(negedge clk);
        end
    endtask

    // ---------------- Estimulos ----------------
    initial begin
        $dumpfile("build/tb_mcd.vcd");
        $dumpvars(0, tb_mcd);

        // Reset
        repeat (3) @(negedge clk);
        rst = 0;
        @(negedge clk);

        $display("========== Pruebas dirigidas ==========");
        run_test( 48,  18);   //  1  -> 6
        run_test( 17,   5);   //  2  -> 1 (primos entre si)
        run_test(  0,   9);   //  3  -> 9 (A = 0)
        run_test(  9,   0);   //  4  -> 9 (B = 0)
        run_test(  0,   0);   //  5  -> 0
        run_test(  1,   1);   //  6  -> 1
        run_test(255, 255);   //  7  -> 255 (iguales, maximo)
        run_test(255,   1);   //  8  -> 1 (peor caso en iteraciones)
        run_test(  1, 255);   //  9  -> 1
        run_test(100,  75);   // 10  -> 25
        run_test( 12,   8);   // 11  -> 4
        run_test(  8,  12);   // 12  -> 4 (orden invertido)
        run_test( 35,  14);   // 13  -> 7
        run_test( 81,  27);   // 14  -> 27 (uno divide al otro)
        run_test( 64,  48);   // 15  -> 16
        run_test( 97,  13);   // 16  -> 1 (ambos primos)
        run_test(250, 100);   // 17  -> 50
        run_test(200, 150);   // 18  -> 50
        run_test(144,  60);   // 19  -> 12
        run_test( 21,  14);   // 20  -> 7
        run_test(  7,  49);   // 21  -> 7
        run_test( 49,   7);   // 22  -> 7
        run_test(128,  64);   // 23  -> 64 (potencias de 2)
        run_test(255,  85);   // 24  -> 85
        run_test(170, 102);   // 25  -> 34
        run_test(221, 119);   // 26  -> 17
        run_test(253,  11);   // 27  -> 11
        run_test( 90,  45);   // 28  -> 45
        run_test( 42,  56);   // 29  -> 14
        run_test( 30,  18);   // 30  -> 6
        run_test( 15,  25);   // 31  -> 5
        run_test(144,  89);   // 32  -> 1 (Fibonacci consecutivos)
        run_test(233, 144);   // 33  -> 1 (Fibonacci consecutivos)

        $display("========== Pruebas aleatorias ==========");
        for (i = 0; i < 10; i = i + 1)
            run_test($urandom % 256, $urandom % 256);

        // ---------------- Resumen ----------------
        $display("=======================================");
        $display("Total pruebas: %0d | OK: %0d | ERRORES: %0d", n_tests, n_ok, n_err);
        if (n_err == 0)
            $display("RESULTADO: TODAS LAS PRUEBAS PASARON");
        else
            $display("RESULTADO: HAY ERRORES");
        $display("=======================================");
        $finish;
    end

    // Watchdog global
    initial begin
        #5_000_000;
        $display("TIMEOUT global del testbench");
        $finish;
    end

endmodule