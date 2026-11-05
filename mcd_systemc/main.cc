// main.cc - conecta stim + mcd_top (DUV) + mon y arranca la simulacion
#include <systemc.h>
#include "stim.h"
#include "mcd_top.h"
#include "mon.h"

int sc_main(int argc, char* argv[]) {
    sc_set_time_resolution(1, SC_PS);

    sc_signal<bool>        rst, start, done;
    sc_signal<sc_uint<8> > A, B, MCD;
    sc_clock               TestClk("TestClock", 10, SC_NS, 0.5);   // 10 ns

    // Generador de estimulos
    stim Stim1("Stimulus");
    Stim1.clk(TestClk);
    Stim1.done(done);
    Stim1.rst(rst);
    Stim1.start(start);
    Stim1.A(A);
    Stim1.B(B);

    // Design Under Verification
    mcd_top DUV("DUV");
    DUV.clk(TestClk);
    DUV.rst(rst);
    DUV.start(start);
    DUV.A(A);
    DUV.B(B);
    DUV.MCD(MCD);
    DUV.done(done);

    // Monitor
    mon Monitor1("Monitor");
    Monitor1.clk(TestClk);
    Monitor1.start(start);
    Monitor1.done(done);
    Monitor1.A(A);
    Monitor1.B(B);
    Monitor1.MCD(MCD);

    // Trazas VCD para GTKWave
    sc_trace_file* tf = sc_create_vcd_trace_file("mcd_sc");
    tf->set_time_unit(1, SC_NS);
    sc_trace(tf, TestClk, "clk");
    sc_trace(tf, rst,     "rst");
    sc_trace(tf, start,   "start");
    sc_trace(tf, A,       "A");
    sc_trace(tf, B,       "B");
    sc_trace(tf, MCD,     "MCD");
    sc_trace(tf, done,    "done");
    sc_trace(tf, DUV.ctrl.state, "state");
    sc_trace(tf, DUV.sel,  "sel");
    sc_trace(tf, DUV.ldX,  "ldX");
    sc_trace(tf, DUV.ldY,  "ldY");
    sc_trace(tf, DUV.op,   "op");
    sc_trace(tf, DUV.zero, "zero");
    sc_trace(tf, DUV.neq,  "neq");
    sc_trace(tf, DUV.lt,   "lt");
    sc_trace(tf, DUV.dp.X, "X");
    sc_trace(tf, DUV.dp.Y, "Y");
    sc_trace(tf, DUV.dp.R, "R");

    sc_start();                 // corre hasta que stim llame a sc_stop()

    sc_close_vcd_trace_file(tf);
    return Monitor1.n_err == 0 ? 0 : 1;
}
