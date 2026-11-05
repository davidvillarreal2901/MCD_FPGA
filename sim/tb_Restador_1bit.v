`timescale 1ns/1ps

module tb_Restador_1bit;

    // ---------- Señales ----------
    reg  a, b, bin;          // entradas del DUT
    wire d, bout;            // salidas del DUT

    reg  [1:0] ref_r;        // modelo de referencia: a - b - bin en 2 bits
    reg  d_esp, bout_esp;    // salidas esperadas
    integer i, errores;

    // ---------- Dispositivo bajo prueba ----------
    Restador_1bit dut (
        .a   (a),
        .b   (b),
        .bin (bin),
        .d   (d),
        .bout(bout)
    );

    // ---------- Formas de onda (GTKWave) ----------
    initial begin
        $dumpfile("tb_Restador_1bit.vcd");
        $dumpvars(0, tb_Restador_1bit);
    end

    // ---------- Verificación contra el modelo de referencia ----------
    task verificar;
        begin
            ref_r    = {1'b0, a} - {1'b0, b} - {1'b0, bin};
            d_esp    = ref_r[0];   // bit de diferencia
            bout_esp = ref_r[1];   // bit de préstamo (el resultado negativo activa el bit alto)

            if (d !== d_esp || bout !== bout_esp) begin
                errores = errores + 1;
                $display("[%0d ns] ERROR: a=%b b=%b bin=%b | d=%b bout=%b | esperado d=%b bout=%b",
                         $time, a, b, bin, d, bout, d_esp, bout_esp);
            end else begin
                $display("[%0d ns] OK   : a=%b b=%b bin=%b | d=%b bout=%b",
                         $time, a, b, bin, d, bout);
            end
        end
    endtask

    // ---------- Estímulos: las 8 combinaciones ----------
    initial begin
        errores = 0;
        a = 0; b = 0; bin = 0;
        #10;

        for (i = 0; i < 8; i = i + 1) begin
            {a, b, bin} = i[2:0];
            #10;               // espera a que se estabilicen las salidas
            verificar;
        end

        // ---------- Resumen ----------
        if (errores == 0)
            $display("\nPRUEBA SUPERADA: las 8 combinaciones son correctas.");
        else
            $display("\nPRUEBA FALLIDA: %0d combinaciones con error.", errores);

        $finish;
    end

endmodule