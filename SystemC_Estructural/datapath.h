#ifndef DATAPATH_H
#define DATAPATH_H

#include <systemc.h>

#include "mux2.h"
#include "reg8.h"
#include "restador8.h"
#include "or8.h"

SC_MODULE(Datapath) {

    // Entradas externas
    sc_in<bool> clk;
    sc_in<bool> reset;

    sc_in<sc_uint<8>> x_in;
    sc_in<sc_uint<8>> y_in;

    // Senales de control
    sc_in<bool> SEL;
    sc_in<bool> INIT;
    sc_in<bool> LOAD_X;
    sc_in<bool> LOAD_Y;

    // Salidas
    sc_out<sc_uint<8>> X;
    sc_out<sc_uint<8>> Y;

    sc_out<bool> EQ;
    sc_out<bool> CARRY;

    // Senales internas
    sc_signal<sc_uint<8>> x_reg_s;
    sc_signal<sc_uint<8>> y_reg_s;

    sc_signal<sc_uint<8>> op_a_s;
    sc_signal<sc_uint<8>> op_b_s;

    sc_signal<sc_uint<8>> result_s;

    sc_signal<sc_uint<8>> x_d_s;
    sc_signal<sc_uint<8>> y_d_s;

    sc_signal<bool> borrow_s;
    sc_signal<bool> result_nonzero_s;

    // Componentes estructurales
    Reg8 reg_x;
    Reg8 reg_y;

    Mux2 mux_a;
    Mux2 mux_b;

    Mux2 mux_x;
    Mux2 mux_y;

    Restador8 restador;

    Or8 detector_cero;

    // Publicar valores de los registros
    void publicar_registros() {
        X.write(x_reg_s.read());
        Y.write(y_reg_s.read());
    }

    // Generar indicadores
    void generar_indicadores() {
        EQ.write(!result_nonzero_s.read());
        CARRY.write(borrow_s.read());
    }

    SC_CTOR(Datapath)
        : reg_x("reg_x"),
          reg_y("reg_y"),
          mux_a("mux_a"),
          mux_b("mux_b"),
          mux_x("mux_x"),
          mux_y("mux_y"),
          restador("restador"),
          detector_cero("detector_cero") {

        // Registro X
        reg_x.clk(clk);
        reg_x.reset(reset);
        reg_x.load(LOAD_X);
        reg_x.D(x_d_s);
        reg_x.Q(x_reg_s);

        // Registro Y
        reg_y.clk(clk);
        reg_y.reset(reset);
        reg_y.load(LOAD_Y);
        reg_y.D(y_d_s);
        reg_y.Q(y_reg_s);

        // Multiplexor del operando A
        mux_a.A(x_reg_s);
        mux_a.B(y_reg_s);
        mux_a.SEL(SEL);
        mux_a.Y(op_a_s);

        // Multiplexor del operando B
        mux_b.A(y_reg_s);
        mux_b.B(x_reg_s);
        mux_b.SEL(SEL);
        mux_b.Y(op_b_s);

        // Restador compartido
        restador.A(op_a_s);
        restador.B(op_b_s);
        restador.R(result_s);
        restador.borrow(borrow_s);

        // Detector de cero
        detector_cero.A(result_s);
        detector_cero.R(result_nonzero_s);

        // Multiplexor de entrada del registro X
        mux_x.A(result_s);
        mux_x.B(x_in);
        mux_x.SEL(INIT);
        mux_x.Y(x_d_s);

        // Multiplexor de entrada del registro Y
        mux_y.A(result_s);
        mux_y.B(y_in);
        mux_y.SEL(INIT);
        mux_y.Y(y_d_s);

        // Publicacion de registros
        SC_METHOD(publicar_registros);
        sensitive << x_reg_s << y_reg_s;

        // Indicadores de estado
        SC_METHOD(generar_indicadores);
        sensitive << result_nonzero_s << borrow_s;
    }
};

#endif
