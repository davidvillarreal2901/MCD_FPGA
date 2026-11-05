#ifndef OR8_H
#define OR8_H
#include <systemc.h>

// OR de 8 bits en arbol de 3 niveles (equivale a Or_8bit.v)
SC_MODULE(or8) {
    sc_in<sc_uint<8> > a;
    sc_out<bool>       y;

    void proc() {
        sc_uint<8> v = a.read();
        bool n0 = v[0] | v[1];
        bool n1 = v[2] | v[3];
        bool n2 = v[4] | v[5];
        bool n3 = v[6] | v[7];
        bool m0 = n0 | n1;
        bool m1 = n2 | n3;
        y.write(m0 | m1);
    }

    SC_CTOR(or8) {
        SC_METHOD(proc);
        sensitive << a;
    }
};
#endif
