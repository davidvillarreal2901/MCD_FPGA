#include <systemc.h>
#include "datapath.h"

int sc_main(int argc, char* argv[]) {
    sc_clock clk("clk", 10, SC_NS);

    sc_signal<bool> reset;
    sc_signal<bool> load_x, load_y;
    sc_signal<bool> sub_x, sub_y;

    sc_signal<sc_uint<8>> x_in, y_in;
    sc_signal<sc_uint<8>> x, y;

    sc_signal<bool> eq, x_less_y;

    Datapath dp("dp");

    dp.clk(clk);
    dp.reset(reset);
    dp.load_x(load_x);
    dp.load_y(load_y);
    dp.sub_x(sub_x);
    dp.sub_y(sub_y);
    dp.x_in(x_in);
    dp.y_in(y_in);
    dp.x(x);
    dp.y(y);
    dp.eq(eq);
    dp.x_less_y(x_less_y);

    reset.write(true);
    load_x.write(false);
    load_y.write(false);
    sub_x.write(false);
    sub_y.write(false);
    x_in.write(0);
    y_in.write(0);

    sc_trace_file* trace = sc_create_vcd_trace_file("datapath");
    sc_trace(trace, clk, "clk");
    sc_trace(trace, reset, "reset");
    sc_trace(trace, load_x, "load_x");
    sc_trace(trace, load_y, "load_y");
    sc_trace(trace, sub_x, "sub_x");
    sc_trace(trace, sub_y, "sub_y");
    sc_trace(trace, x, "X");
    sc_trace(trace, y, "Y");
    sc_trace(trace, eq, "EQ");
    sc_trace(trace, x_less_y, "X_less_Y");

    // Mantener reset durante un ciclo
    sc_start(10, SC_NS);
    reset.write(false);

    // Cargar X=48 e Y=18
    x_in.write(48);
    y_in.write(18);
    load_x.write(true);
    load_y.write(true);
    sc_start(10, SC_NS);

    load_x.write(false);
    load_y.write(false);

    cout << "Despues de cargar: X=" << x.read()
         << " Y=" << y.read() << endl;

    // Primera resta: X = X - Y
    sub_x.write(true);
    sc_start(10, SC_NS);
    sub_x.write(false);

    cout << "Primera resta de X: X=" << x.read()
         << " Y=" << y.read() << endl;

    // Segunda resta: X = X - Y
    sub_x.write(true);
    sc_start(10, SC_NS);
    sub_x.write(false);

    cout << "Segunda resta de X: X=" << x.read()
         << " Y=" << y.read() << endl;

    // Resta de Y: Y = Y - X
    sub_y.write(true);
    sc_start(10, SC_NS);
    sub_y.write(false);

    cout << "Resta de Y: X=" << x.read()
         << " Y=" << y.read() << endl;

    cout << "EQ=" << eq.read()
         << " X_less_Y=" << x_less_y.read() << endl;

    sc_close_vcd_trace_file(trace);

    return 0;
}
