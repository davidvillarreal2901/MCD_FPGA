#include <systemc.h>
#include "mcd.h"

//Incluyo el stim y el mon
#include "../mcd_systemc/stim.h"
#include "../mcd_systemc/mon.h"

int sc_main(int argc, char* argv[]) {

    sc_clock clk("clk", 10, SC_NS);

    sc_signal<bool> reset;
    sc_signal<bool> start;

    sc_signal<sc_uint<8>> x_in;
    sc_signal<sc_uint<8>> y_in;

    sc_signal<sc_uint<8>> x;
    sc_signal<sc_uint<8>> y;

    sc_signal<bool> done;

    MCD mcd("mcd");

    mcd.clk(clk);
    mcd.reset(reset);
    mcd.start(start);
    mcd.x_in(x_in);
    mcd.y_in(y_in);
    mcd.x(x);
    mcd.y(y);
    mcd.done(done);

    //-------------------------Acá meto las señales para el sim.h y el mon.h

    // Generador de estimulos compartido
    stim stimulus("stimulus");
    stimulus.clk(clk);
    stimulus.done(done);
    stimulus.rst(reset);
    stimulus.start(start);
    stimulus.A(x_in);
    stimulus.B(y_in);

    // Monitor autoverificable compartido
    mon monitor("monitor");
    monitor.clk(clk);
    monitor.start(start);
    monitor.done(done);
    monitor.A(x_in);
    monitor.B(y_in);
    monitor.MCD(x);  // Cuando done=1, x contiene el MCD

    //----------------------------------------------------------------------

    // Valores iniciales
    reset.write(true);
    start.write(false);
    x_in.write(18);
    y_in.write(48);

    // Registrar las senales en el archivo VCD
    sc_trace_file* trace = sc_create_vcd_trace_file("mcd");
    sc_trace(trace, clk, "clk");
    sc_trace(trace, reset, "reset");
    sc_trace(trace, start, "start");
    sc_trace(trace, x_in, "X_in");
    sc_trace(trace, y_in, "Y_in");
    sc_trace(trace, x, "X");
    sc_trace(trace, y, "Y");
    sc_trace(trace, done, "done");

    // Reiniciar el sistema
    sc_start(10, SC_NS);
    reset.write(false);

    // Iniciar el calculo
    start.write(true);

    // Observar la ejecucion durante 500 ns
    for (int i = 0; i < 50; i++) {
        sc_start(10, SC_NS);

        cout << "Tiempo: " << sc_time_stamp()
             << " | X = " << x.read()
             << " | Y = " << y.read()
             << " | done = " << done.read()
             << endl;

        if (done.read()) {
            cout << "\nMCD encontrado: "
                 << x.read() << endl;
            break;
        }
    }

    start.write(false);
    sc_start(10, SC_NS);

    sc_close_vcd_trace_file(trace);

    return 0;
}
