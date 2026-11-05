#ifndef MUX2_H
#define MUX2_H
#include <systemc.h>

// Multiplexor 2:1 parametrizable (equivale a mux2.v)
template <int WIDTH = 8>
SC_MODULE(mux2) {
    sc_in<sc_uint<WIDTH> >  d0;    // seleccionada cuando sel = 0
    sc_in<sc_uint<WIDTH> >  d1;    // seleccionada cuando sel = 1
    sc_in<bool>             sel;
    sc_out<sc_uint<WIDTH> > y;

    void proc() { y.write(sel.read() ? d1.read() : d0.read()); }

    SC_CTOR(mux2) {
        SC_METHOD(proc);
        sensitive << d0 << d1 << sel;
    }
};
#endif
