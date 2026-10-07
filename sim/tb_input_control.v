`timescale 1ns/1ps

module tb_input_control;

    reg clk;
    reg rst;

    reg [7:0] touch_pulse;
    reg       button_pulse;

    reg       done;
    reg [7:0] mcd;

    wire [7:0] A;
    wire [7:0] B;
    wire       start;

    wire [7:0] led_value;
    wire [1:0] ui_state;


    input_control dut (
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


    // 25 MHz
    initial clk = 1'b0;
    always #20 clk = ~clk;


    // VCD
    initial begin

        $dumpfile("build/tb_input_control.vcd");
        $dumpvars(0, tb_input_control);

    end


    // --------------------------------------------------
    // Tarea: generar un toque
    // --------------------------------------------------

    task touch(input [7:0] value);

        begin

            @(negedge clk);
            touch_pulse = value;

            @(negedge clk);
            touch_pulse = 8'd0;

        end

    endtask


    // --------------------------------------------------
    // Tarea: pulsar botón
    // --------------------------------------------------

    task press_button;

        begin

            @(negedge clk);
            button_pulse = 1'b1;

            @(negedge clk);
            button_pulse = 1'b0;

        end

    endtask


    // --------------------------------------------------
    // Simulación
    // --------------------------------------------------

    initial begin

        rst          = 1'b1;
        touch_pulse  = 8'd0;
        button_pulse = 1'b0;

        done         = 1'b0;
        mcd          = 8'd0;


        repeat (3)
            @(posedge clk);


        @(negedge clk);
        rst = 1'b0;


        // ==================================================
        // EDIT_A
        //
        // Queremos A = 48 = 00110000
        // bits 5 y 4
        // ==================================================

        touch(8'b00100000); // bit 5
        touch(8'b00010000); // bit 4


        // Debe quedar:
        // A = 00110000 = 48


        // Pasar a B
        press_button();


        // ==================================================
        // EDIT_B
        //
        // Queremos B = 18 = 00010010
        // bits 4 y 1
        // ==================================================

        touch(8'b00010000); // bit 4
        touch(8'b00000010); // bit 1


        // Debe quedar:
        // B = 00010010 = 18


        // Comenzar cálculo
        press_button();


        // Esperar unos ciclos como si el MCD estuviera trabajando.
        repeat (10)
            @(posedge clk);


        // Simular resultado del core.
        @(negedge clk);

        mcd  = 8'd6;
        done = 1'b1;


        @(negedge clk);

        done = 1'b0;


        // Permanecer mostrando resultado.
        repeat (5)
            @(posedge clk);


        // ==================================================
        // Nueva operación
        // ==================================================

        press_button();


        repeat (5)
            @(posedge clk);


        $display("--------------------------------");
        $display("A     = %d", A);
        $display("B     = %d", B);
        $display("state = %d", ui_state);
        $display("--------------------------------");

        $finish;

    end

endmodule