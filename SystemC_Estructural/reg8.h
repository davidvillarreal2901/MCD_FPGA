#ifndef REG8_H
#define REG8_H

#include <systemc.h>

SC_MODULE(Reg8) {

    // Entradas
    sc_in<bool> clk;
    sc_in<bool> reset;
    sc_in<bool> load;
    sc_in<sc_uint<8>> D;

    // Salida
    sc_out<sc_uint<8>> Q;

    // Registro interno
    sc_uint<8> data;

    void almacenar() {

        if (reset.read()) {
            data = 0;
        }
        else if (load.read()) {
            data = D.read();
        }

        Q.write(data);
    }

    SC_CTOR(Reg8) {

        data = 0;

        SC_METHOD(almacenar);
        sensitive << clk.pos();
        dont_initialize();
    }
};

#endif