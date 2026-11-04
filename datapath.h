#ifndef DATAPATH_H
#define DATAPATH_H

#include <systemc.h>

SC_MODULE(Datapath) {
    // Entradas
    sc_in<bool> clk;
    sc_in<bool> reset;
    sc_in<bool> load_x;
    sc_in<bool> load_y;
    sc_in<bool> sub_x;
    sc_in<bool> sub_y;

    sc_in<sc_uint<8>> x_in;
    sc_in<sc_uint<8>> y_in;

    // Salidas
    sc_out<sc_uint<8>> x;
    sc_out<sc_uint<8>> y;
    sc_out<bool> eq;
    sc_out<bool> x_less_y;

    // Registros internos
    sc_uint<8> x_reg;
    sc_uint<8> y_reg;

    // Proceso secuencial del datapath
    void actualizar() {
        if (reset.read()) {
            x_reg = 0;
            y_reg = 0;
        } else {
            if (load_x.read()) {
                x_reg = x_in.read();
            }

            if (load_y.read()) {
                y_reg = y_in.read();
            }

            if (sub_x.read()) {
                x_reg = x_reg - y_reg;
            }

            if (sub_y.read()) {
                y_reg = y_reg - x_reg;
            }
        }

        // Escribir los valores de los registros
        x.write(x_reg);
        y.write(y_reg);

        // Comparaciones
        eq.write(x_reg == y_reg);
        x_less_y.write(x_reg < y_reg);
    }

    SC_CTOR(Datapath) {
        x_reg = 0;
        y_reg = 0;

        SC_METHOD(actualizar);
        sensitive << clk.pos();
        dont_initialize();
    }
};

#endif