#ifndef DATAPATH_H
#define DATAPATH_H
#include <systemc.h>
#include "mux2.h"
#include "reg8.h"
#include "or8.h"
#include "restador8.h"

// Camino de datos del MCD (equivale a datapath.v)
SC_MODULE(datapath) {
    sc_in<bool>         clk;
    sc_in<bool>         rst;
    sc_in<sc_uint<8> >  A;
    sc_in<sc_uint<8> >  B;

    // Control desde la UC
    sc_in<bool>         sel;     // 0: carga A/B, 1: carga R
    sc_in<bool>         ldX;
    sc_in<bool>         ldY;
    sc_in<bool>         op;      // 0: P-Q = X-Y, 1: P-Q = Y-X

    // Estado hacia la UC
    sc_out<bool>        neq;     // 1 si X != Y
    sc_out<bool>        lt;      // 1 si P < Q (borrow del restador)
    sc_out<bool>        zero;    // 1 si X == 0 o Y == 0

    sc_out<sc_uint<8> > MCD;

    // Senales internas
    sc_signal<sc_uint<8> > X, Y, x_in, y_in, P, Q, R;
    sc_signal<bool>        or_x, or_y;

    // Submodulos
    mux2<8>   mux_x, mux_y, mux_p, mux_q;
    reg8<8>   regX, regY;
    restador8 sub;
    or8       or_r, or_xx, or_yy;

    void proc_zero() { zero.write(!(or_x.read() & or_y.read())); }
    void proc_mcd()  { MCD.write(X.read() | Y.read()); }

    SC_CTOR(datapath)
        : mux_x("mux_x"), mux_y("mux_y"), mux_p("mux_p"), mux_q("mux_q"),
          regX("regX"), regY("regY"), sub("sub"),
          or_r("or_r"), or_xx("or_xx"), or_yy("or_yy")
    {
        // MUX de entrada a los registros
        mux_x.d0(A); mux_x.d1(R); mux_x.sel(sel); mux_x.y(x_in);
        mux_y.d0(B); mux_y.d1(R); mux_y.sel(sel); mux_y.y(y_in);

        // Registros
        regX.clk(clk); regX.rst(rst); regX.ld(ldX); regX.d(x_in); regX.q(X);
        regY.clk(clk); regY.rst(rst); regY.ld(ldY); regY.d(y_in); regY.q(Y);

        // MUX de operandos del restador
        mux_p.d0(X); mux_p.d1(Y); mux_p.sel(op); mux_p.y(P);   // minuendo
        mux_q.d0(Y); mux_q.d1(X); mux_q.sel(op); mux_q.y(Q);   // sustraendo

        // Restador R = P - Q
        sub.a(P); sub.b(Q); sub.d(R); sub.bout(lt);

        // neq = OR de los bits de R
        or_r.a(R); or_r.y(neq);

        // Deteccion de cero: NAND(|X, |Y)
        or_xx.a(X); or_xx.y(or_x);
        or_yy.a(Y); or_yy.y(or_y);

        SC_METHOD(proc_zero);
        sensitive << or_x << or_y;
        SC_METHOD(proc_mcd);
        sensitive << X << Y;
    }
};
#endif
