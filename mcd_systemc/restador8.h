#ifndef RESTADOR8_H
#define RESTADOR8_H
#include <systemc.h>
#include "restador1.h"

// Restador de 8 bits ripple-borrow: d = a - b, bout = 1 si a < b
// (equivale a Restador_8bit.v)
SC_MODULE(restador8) {
    sc_in<sc_uint<8> >  a;
    sc_in<sc_uint<8> >  b;
    sc_out<sc_uint<8> > d;
    sc_out<bool>        bout;

    sc_vector<restador1>        rb;        // 8 restadores de 1 bit
    sc_vector<sc_signal<bool> > a_b, b_b, d_b;
    sc_vector<sc_signal<bool> > borrow;    // borrow[i] = borrow de entrada del bit i

    void split() {                          // sc_uint<8> -> bits, borrow[0] = 0
        for (int i = 0; i < 8; i++) {
            a_b[i].write(a.read()[i]);
            b_b[i].write(b.read()[i]);
        }
        borrow[0].write(false);
    }
    void join() {                           // bits -> sc_uint<8>, bout = borrow[8]
        sc_uint<8> v = 0;
        for (int i = 0; i < 8; i++) v[i] = d_b[i].read();
        d.write(v);
        bout.write(borrow[8].read());
    }

    SC_CTOR(restador8) : rb("rb", 8), a_b("a_b", 8), b_b("b_b", 8),
                         d_b("d_b", 8), borrow("borrow", 9) {
        for (int i = 0; i < 8; i++) {
            rb[i].a(a_b[i]);
            rb[i].b(b_b[i]);
            rb[i].bin(borrow[i]);
            rb[i].d(d_b[i]);
            rb[i].bout(borrow[i + 1]);
        }
        SC_METHOD(split);
        sensitive << a << b;
        SC_METHOD(join);
        for (int i = 0; i < 8; i++) sensitive << d_b[i];
        sensitive << borrow[8];
    }
};
#endif
