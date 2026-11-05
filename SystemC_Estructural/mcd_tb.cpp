#include <systemc.h>
#include <cstdlib>
#include "mcd.h"

int sc_main(int argc, char* argv[]) {

    // Valores de prueba
    int valor_x = 48;
    int valor_y = 18;

    if (argc >= 3) {
        valor_x = atoi(argv[1]);
        valor_y = atoi(argv[2]);
    }

    sc_clock clk("clk", 10, SC_NS);

    sc_signal<bool> reset;
    sc_signal<bool> start;

    sc_signal<sc_uint<8>> x_in;
    sc_signal<sc_uint<8>> y_in;

    sc_signal<sc_uint<8>> X;
    sc_signal<sc_uint<8>> Y;

    sc_signal<bool> done;

    MCD mcd("mcd");

    mcd.clk(clk);
    mcd.reset(reset);
    mcd.start(start);

    mcd.x_in(x_in);
    mcd.y_in(y_in);

    mcd.X(X);
    mcd.Y(Y);

    mcd.done(done);

    // Inicializacion
    reset.write(true);
    start.write(false);

    x_in.write(valor_x);
    y_in.write(valor_y);

    // Archivo de trazas
    sc_trace_file* trace =
        sc_create_vcd_trace_file("mcd_estructural");

    sc_trace(trace, clk, "clk");
    sc_trace(trace, reset, "reset");
    sc_trace(trace, start, "start");

    sc_trace(trace, x_in, "X_in");
    sc_trace(trace, y_in, "Y_in");

    sc_trace(trace, X, "X");
    sc_trace(trace, Y, "Y");

    sc_trace(trace, done, "done");

    // Reinicio
    sc_start(10, SC_NS);

    reset.write(false);
    start.write(true);

    // Ejecucion
    bool terminado = false;

    for (int i = 0; i < 50; i++) {

        sc_start(10, SC_NS);

        cout << "Tiempo: " << sc_time_stamp()
             << " | X = " << X.read()
             << " | Y = " << Y.read()
             << " | done = " << done.read()
             << endl;

        if (done.read()) {
            cout << "\nMCD encontrado: "
                 << X.read() << endl;

            terminado = true;
            break;
        }
    }

    if (!terminado) {
        cout << "\nERROR: No se completo el calculo."
             << endl;
    }

    start.write(false);

    sc_start(10, SC_NS);

    sc_close_vcd_trace_file(trace);

    return terminado ? 0 : 1;
}