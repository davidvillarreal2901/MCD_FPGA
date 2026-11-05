#ifndef MUX2_H
#define MUX2_H

#include <systemc.h>

SC_MODULE(Mux2) {

    // Entradas de 8 bits
    sc_in<sc_uint<8>> A;
    sc_in<sc_uint<8>> B;

    // Selector
    sc_in<bool> SEL;

    // Salida de 8 bits
    sc_out<sc_uint<8>> Y;

    // Funcion combinacional
    void seleccionar() {
        if (SEL.read())
            Y.write(B.read());
        else
            Y.write(A.read());
    }

    SC_CTOR(Mux2) {
        SC_METHOD(seleccionar);

        sensitive << A << B << SEL;
    }
};

#endif
