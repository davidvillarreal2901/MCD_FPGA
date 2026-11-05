#ifndef REG8_H
#define REG8_H
#include <systemc.h>

// Registro con load enable y reset sincrono activo en alto (equivale a Reg_8bit.v)
template <int WIDTH = 8>
SC_MODULE(reg8) {
    sc_in<bool>             clk;
    sc_in<bool>             rst;
    sc_in<bool>             ld;
    sc_in<sc_uint<WIDTH> >  d;
    sc_out<sc_uint<WIDTH> > q;

    sc_uint<WIDTH> state;          // contenido interno

    void proc() {
        if (rst.read())
            state = 0;
        else if (ld.read())
            state = d.read();
        // si ld = 0, conserva su valor
        q.write(state);
    }

    SC_CTOR(reg8) : state(0) {
        SC_METHOD(proc);
        sensitive << clk.pos();
        dont_initialize();
    }
};
#endif
