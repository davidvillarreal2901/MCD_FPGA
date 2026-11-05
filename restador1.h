#ifndef RESTADOR1_H
#define RESTADOR1_H
#include <systemc.h>

// Restador completo de 1 bit (equivale a Restador_1bit.v)
SC_MODULE(restador1) {
    sc_in<bool>  a;      // minuendo
    sc_in<bool>  b;      // sustraendo
    sc_in<bool>  bin;    // borrow de entrada
    sc_out<bool> d;      // diferencia
    sc_out<bool> bout;   // borrow de salida

    void proc() {
        bool va = a.read(), vb = b.read(), vin = bin.read();
        d.write(va ^ vb ^ vin);
        bout.write((!va & vb) | ((!va | vb) & vin));
    }

    SC_CTOR(restador1) {
        SC_METHOD(proc);
        sensitive << a << b << bin;
    }
};
#endif
