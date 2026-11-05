#ifndef MCD_H
#define MCD_H

#include <systemc.h>
#include "datapath.h"
#include "control.h"

SC_MODULE(MCD) {

    // Entradas externas
    sc_in<bool> clk;
    sc_in<bool> reset;
    sc_in<bool> start;

    sc_in<sc_uint<8>> x_in;
    sc_in<sc_uint<8>> y_in;

    // Salidas externas
    sc_out<sc_uint<8>> X;
    sc_out<sc_uint<8>> Y;
    sc_out<bool> done;

    // Senales internas de control
    sc_signal<bool> SEL_s;
    sc_signal<bool> INIT_s;
    sc_signal<bool> LOAD_X_s;
    sc_signal<bool> LOAD_Y_s;

    // Indicadores del datapath
    sc_signal<bool> EQ_s;
    sc_signal<bool> CARRY_s;

    // Instancias
    Datapath dp;
    Control ctrl;

    SC_CTOR(MCD)
        : dp("datapath"),
          ctrl("control") {

        // Conexion del datapath
        dp.clk(clk);
        dp.reset(reset);

        dp.x_in(x_in);
        dp.y_in(y_in);

        dp.SEL(SEL_s);
        dp.INIT(INIT_s);
        dp.LOAD_X(LOAD_X_s);
        dp.LOAD_Y(LOAD_Y_s);

        dp.X(X);
        dp.Y(Y);

        dp.EQ(EQ_s);
        dp.CARRY(CARRY_s);

        // Conexion de la unidad de control
        ctrl.clk(clk);
        ctrl.reset(reset);
        ctrl.start(start);

        ctrl.EQ(EQ_s);
        ctrl.CARRY(CARRY_s);

        ctrl.SEL(SEL_s);
        ctrl.INIT(INIT_s);
        ctrl.LOAD_X(LOAD_X_s);
        ctrl.LOAD_Y(LOAD_Y_s);

        ctrl.done(done);
    }
};

#endif