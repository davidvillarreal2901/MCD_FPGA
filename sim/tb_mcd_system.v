`timescale 1ns/1ps

module tb_mcd_system;

    reg clk;
    reg rst;

    reg [7:0] touch_raw;
    reg       button_n;


    wire [7:0] led_value;

    wire [7:0] A_value;
    wire [7:0] B_value;
    wire [7:0] mcd_value;

    wire       start_out;
    wire       done_out;

    wire [1:0] ui_state;

    wire [7:0] touch_sync_out;
    wire [7:0] touch_pulse_out;

    wire button_sync_out;
    wire button_clean_out;
    wire button_pulse_out;


    // ============================================================
    // DUT
    // ============================================================

    mcd_system #(
    // Pequeño únicamente para simulación.
    .BUTTON_DEBOUNCE_COUNT(4)
    ) dut (
        .clk             (clk),
        .rst             (rst),

        .touch_raw       (touch_raw),
        .button_n    (button_n),

        .led_value       (led_value),

        .A_value         (A_value),
        .B_value         (B_value),
        .mcd_value       (mcd_value),

        .start_out       (start_out),
        .done_out        (done_out),

        .ui_state        (ui_state),

        .touch_sync_out  (touch_sync_out),
        .touch_pulse_out (touch_pulse_out),

        .button_sync_out  (button_sync_out),
        .button_clean_out (button_clean_out),
        .button_pulse_out (button_pulse_out)
    );


    // ============================================================
    // Clock
    //
    // Colorlight:
    // 25 MHz
    //
    // T = 40 ns
    // ============================================================

    initial
        clk = 1'b0;

    always #20 clk = ~clk;


    // ============================================================
    // VCD
    // ============================================================

    initial begin

        $dumpfile("build/tb_mcd_system.vcd");
        $dumpvars(0, tb_mcd_system);

    end


    // ============================================================
    // Simular una pulsación del TTP226
    //
    // La entrada permanece en 1 varios ciclos, como ocurriría
    // cuando una persona mantiene el dedo sobre la tecla.
    //
    // El touch_frontend deberá generar solamente un touch_pulse.
    // ============================================================

    task touch_bit(input integer bit_number);

        begin

            // Cambiamos la señal fuera del flanco de reloj.
            @(negedge clk);
            #7;

            touch_raw[bit_number] = 1'b1;


            // Mantener la tecla pulsada.
            repeat (5)
                @(posedge clk);


            @(negedge clk);
            #5;

            touch_raw[bit_number] = 1'b0;


            // Dar tiempo para sincronizar también la liberación.
            repeat (4)
                @(posedge clk);

        end

    endtask


    // ============================================================
    // Simular pulsación del botón NEXT / START
    //
    // Ya tenemos el botón real
    // ============================================================

    task press_button;

        begin

            // --------------------------------------------------------
            // Rebote al presionar
            // --------------------------------------------------------

            @(negedge clk);

            #7  button_n = 1'b0;
            #9  button_n = 1'b1;
            #8  button_n = 1'b0;
            #7  button_n = 1'b1;
            #9  button_n = 1'b0;


            // Mantener pulsado el tiempo suficiente para superar
            // el debounce.
            repeat (8)
                @(posedge clk);


            // --------------------------------------------------------
            // Rebote al soltar
            // --------------------------------------------------------

            @(negedge clk);

            #6  button_n = 1'b1;
            #8  button_n = 1'b0;
            #7  button_n = 1'b1;
            #9  button_n = 1'b0;
            #8  button_n = 1'b1;


            // Dejarlo liberado.
            repeat (8)
                @(posedge clk);

        end

    endtask


    // ============================================================
    // Test principal
    // ============================================================

    initial begin

        rst          = 1'b1;
        touch_raw    = 8'd0;
        button_n     = 1'b1;


        // --------------------------------------------------------
        // RESET
        // --------------------------------------------------------

        repeat (3)
            @(posedge clk);


        @(negedge clk);

        rst = 1'b0;


        // ========================================================
        // CARGAR A = 48
        //
        // 48 = 00110000
        //
        // bit 5 = 1
        // bit 4 = 1
        // ========================================================

        touch_bit(5);
        touch_bit(4);


        // Verificación
        if (A_value !== 8'd48) begin

            $display(
                "ERROR: A deberia ser 48 y es %d",
                A_value
            );

            $fatal;

        end
        else begin

            $display(
                "OK: A = %d = %b",
                A_value,
                A_value
            );

        end


        // ========================================================
        // NEXT
        //
        // EDIT_A -> EDIT_B
        // ========================================================

        press_button();


        // ========================================================
        // CARGAR B = 18
        //
        // 18 = 00010010
        //
        // bit 4 = 1
        // bit 1 = 1
        // ========================================================

        touch_bit(4);
        touch_bit(1);


        if (B_value !== 8'd18) begin

            $display(
                "ERROR: B deberia ser 18 y es %d",
                B_value
            );

            $fatal;

        end
        else begin

            $display(
                "OK: B = %d = %b",
                B_value,
                B_value
            );

        end


        // ========================================================
        // START
        //
        // EDIT_B -> RUN
        // ========================================================

        press_button();


        $display(
            "MCD iniciado con A=%d, B=%d",
            A_value,
            B_value
        );


        // ========================================================
        // ESPERAR AL MCD REAL
        //
        // Ya NO asignamos manualmente:
        //
        //     mcd  = 6;
        //     done = 1;
        //
        // mcd_top debe producirlos.
        // ========================================================

        wait (done_out === 1'b1);


        // Dar un pequeño tiempo para que se estabilicen
        // las señales combinacionales.
        #1;


        $display(
            "DONE recibido. MCD = %d",
            mcd_value
        );


        // ========================================================
        // VERIFICAR RESULTADO
        // ========================================================

        if (mcd_value !== 8'd6) begin

            $display(
                "ERROR: MCD(48,18) deberia ser 6 y es %d",
                mcd_value
            );

            $fatal;

        end
        else begin

            $display(
                "OK: MCD(48,18) = %d",
                mcd_value
            );

        end


        // input_control ve done y pasa a RESULT
        @(posedge clk);
        #1;


        if (ui_state !== 2'd3) begin

            $display(
                "ERROR: la interfaz no llego a RESULT"
            );

            $fatal;

        end


        if (led_value !== 8'd6) begin

            $display(
                "ERROR: LEDs deberian mostrar 6 y muestran %d",
                led_value
            );

            $fatal;

        end


        $display(
            "OK: LEDs = %b",
            led_value
        );


        // Mantener resultado visible.
        repeat (5)
            @(posedge clk);


        // ========================================================
        // NUEVA OPERACIÓN
        //
        // RESULT -> EDIT_A
        // ========================================================

        press_button();


        @(posedge clk);
        #1;


        if (
            A_value !== 8'd0 ||
            B_value !== 8'd0
        ) begin

            $display(
                "ERROR: A y B no se reiniciaron"
            );

            $fatal;

        end


        // ========================================================
        // FIN
        // ========================================================

        $display("");
        $display("========================================");
        $display(" SISTEMA COMPLETO: PRUEBA SUPERADA");
        $display(" A   = 48");
        $display(" B   = 18");
        $display(" MCD = 6");
        $display("========================================");
        $display("");

        $finish;

    end


    // ============================================================
    // Watchdog
    //
    // Evita que la simulación quede esperando eternamente
    // si nunca aparece done.
    // ============================================================

    initial begin

        #100000;

        $display("ERROR: timeout de simulacion");

        $fatal;

    end

endmodule