#ifndef RESTADOR8_H
#define RESTADOR8_H

#include <systemc.h>

SC_MODULE(Restador8) {

    sc_in<sc_uint<8>> A;
    sc_in<sc_uint<8>> B;

    sc_out<sc_uint<8>> R;
    sc_out<bool> borrow;

    void restar() {
        sc_uint<8> a = A.read();
        sc_uint<8> b = B.read();

        R.write(a - b);
        borrow.write(a < b);
    }

    SC_CTOR(Restador8) {
        SC_METHOD(restar);
        sensitive << A << B;
    }
};

#endif