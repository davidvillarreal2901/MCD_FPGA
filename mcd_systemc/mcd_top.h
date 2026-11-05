#ifndef MCD_TOP_H
#define MCD_TOP_H
#include <systemc.h>
#include "datapath.h"
#include "fsm.h"

// Top: unidad de control + camino de datos (equivale a mcd_top.v)
SC_MODULE(mcd_top) {
    sc_in<bool>         clk;
    sc_in<bool>         rst;
    sc_in<bool>         start;
    sc_in<sc_uint<8> >  A;
    sc_in<sc_uint<8> >  B;
    sc_out<sc_uint<8> > MCD;
    sc_out<bool>        done;

    sc_signal<bool> sel, ldX, ldY, op;    // control: FSM -> datapath
    sc_signal<bool> zero, neq, lt;        // estado:  datapath -> FSM

    fsm      ctrl;
    datapath dp;

    SC_CTOR(mcd_top) : ctrl("ctrl"), dp("dp") {
        ctrl.clk(clk);   ctrl.rst(rst);   ctrl.start(start);
        ctrl.zero(zero); ctrl.neq(neq);   ctrl.lt(lt);
        ctrl.sel(sel);   ctrl.ldX(ldX);   ctrl.ldY(ldY);
        ctrl.op(op);     ctrl.done(done);

        dp.clk(clk); dp.rst(rst);
        dp.A(A);     dp.B(B);
        dp.sel(sel); dp.ldX(ldX); dp.ldY(ldY); dp.op(op);
        dp.neq(neq); dp.lt(lt);   dp.zero(zero);
        dp.MCD(MCD);
    }
};
#endif
