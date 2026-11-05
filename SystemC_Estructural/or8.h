#ifndef OR8_H
#define OR8_H

#include <systemc.h>

SC_MODULE(Or8) {

    // Entrada de 8 bits
    sc_in<sc_uint<8>> A;

    // Salida: indica si el resultado es diferente de cero
    sc_out<bool> R;

    // OR de reduccion de los ocho bits
    void operar() {
        bool resultado = false;

        for (int i = 0; i < 8; i++) {
            resultado = resultado || A.read()[i];
        }

        R.write(resultado);
    }

    SC_CTOR(Or8) {
        SC_METHOD(operar);
        sensitive << A;
    }
};

#endif