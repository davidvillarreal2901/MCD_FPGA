#ifndef FSM_H
#define FSM_H
#include <systemc.h>

// Unidad de control (FSM Moore) del MCD (equivale a fsm.v)
SC_MODULE(fsm) {
    sc_in<bool>  clk;
    sc_in<bool>  rst;     // reset sincrono, activo en alto
    sc_in<bool>  start;

    // Estado proveniente del datapath
    sc_in<bool>  zero;
    sc_in<bool>  neq;
    sc_in<bool>  lt;

    // Control hacia el datapath
    sc_out<bool> sel;
    sc_out<bool> ldX;
    sc_out<bool> ldY;
    sc_out<bool> op;
    sc_out<bool> done;

    enum { S0_IDLE = 0, S1_LOAD, S2_CHECK, S3_SUBY, S4_SUBX, S5_DONE };

    sc_signal<sc_uint<3> > state, next_state;

    // Registro de estado
    void state_reg() {
        if (rst.read()) state.write(S0_IDLE);
        else            state.write(next_state.read());
    }

    // Logica de siguiente estado
    void next_logic() {
        sc_uint<3> ns = state.read();
        switch (state.read().to_uint()) {
            case S0_IDLE:  if (start.read()) ns = S1_LOAD;            break;
            case S1_LOAD:  ns = S2_CHECK;                             break;
            case S2_CHECK:
                if (zero.read() || !neq.read()) ns = S5_DONE;
                else if (lt.read())             ns = S3_SUBY;   // X < Y
                else                            ns = S4_SUBX;   // X > Y
                break;
            case S3_SUBY:  ns = S2_CHECK;                             break;
            case S4_SUBX:  ns = S2_CHECK;                             break;
            case S5_DONE:  if (!start.read()) ns = S0_IDLE;           break;
            default:       ns = S0_IDLE;
        }
        next_state.write(ns);
    }

    // Salidas (Moore)
    void out_logic() {
        bool o_sel = false, o_ldX = false, o_ldY = false, o_op = false, o_done = false;
        switch (state.read().to_uint()) {
            case S1_LOAD: o_sel = false; o_ldX = true; o_ldY = true;           break; // X<-A, Y<-B
            case S3_SUBY: o_sel = true;  o_ldY = true; o_op = true;            break; // Y<-Y-X
            case S4_SUBX: o_sel = true;  o_ldX = true; o_op = false;           break; // X<-X-Y
            case S5_DONE: o_done = true;                                       break;
            default: break;
        }
        sel.write(o_sel); ldX.write(o_ldX); ldY.write(o_ldY);
        op.write(o_op);   done.write(o_done);
    }

    SC_CTOR(fsm) {
        SC_METHOD(state_reg);
        sensitive << clk.pos();
        dont_initialize();

        SC_METHOD(next_logic);
        sensitive << state << start << zero << neq << lt;

        SC_METHOD(out_logic);
        sensitive << state;
    }
};
#endif
