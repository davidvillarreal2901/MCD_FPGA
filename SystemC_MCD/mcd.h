#ifndef MCD_H
#define MCD_H

#include <systemc.h>
#include "datapath.h"
#include "control.h"

SC_MODULE(MCD) {

    sc_in<bool> clk;
    sc_in<bool> reset;
    sc_in<bool> start;

    sc_in<sc_uint<8>> x_in;
    sc_in<sc_uint<8>> y_in;

    sc_out<sc_uint<8>> x;
    sc_out<sc_uint<8>> y;
    sc_out<bool> done;

    // Senales internas
    sc_signal<bool> load_x_s;
    sc_signal<bool> load_y_s;
    sc_signal<bool> sub_x_s;
    sc_signal<bool> sub_y_s;

    sc_signal<bool> eq_s;
    sc_signal<bool> x_less_y_s;

    // Modulos
    Datapath dp;
    Control ctrl;

    SC_CTOR(MCD)
        : dp("datapath"), ctrl("control") {

        // Conexiones del datapath
        dp.clk(clk);
        dp.reset(reset);
        dp.load_x(load_x_s);
        dp.load_y(load_y_s);
        dp.sub_x(sub_x_s);
        dp.sub_y(sub_y_s);
        dp.x_in(x_in);
        dp.y_in(y_in);
        dp.x(x);
        dp.y(y);
        dp.eq(eq_s);
        dp.x_less_y(x_less_y_s);

        // Conexiones de la unidad de control
        ctrl.clk(clk);
        ctrl.reset(reset);
        ctrl.start(start);
        ctrl.eq(eq_s);
        ctrl.x_less_y(x_less_y_s);

        ctrl.load_x(load_x_s);
        ctrl.load_y(load_y_s);
        ctrl.sub_x(sub_x_s);
        ctrl.sub_y(sub_y_s);
        ctrl.done(done);
    }
};

#endif