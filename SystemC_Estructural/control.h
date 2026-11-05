#ifndef CONTROL_H
#define CONTROL_H

#include <systemc.h>

SC_MODULE(Control) {

    // Entradas
    sc_in<bool> clk;
    sc_in<bool> reset;
    sc_in<bool> start;

    sc_in<bool> EQ;
    sc_in<bool> CARRY;

    // Salidas de control
    sc_out<bool> SEL;
    sc_out<bool> INIT;
    sc_out<bool> LOAD_X;
    sc_out<bool> LOAD_Y;
    sc_out<bool> done;

    // Estados de la maquina
    enum State {
        IDLE,
        LOAD,
        CHECK_EQUAL,
        COMPARE,
        SUB_X,
        SUB_Y,
        DONE
    };

    sc_signal<State> state;
    sc_signal<State> next_state;

    // Registro de estados
    void state_register() {
        if (reset.read())
            state.write(IDLE);
        else
            state.write(next_state.read());
    }

    // Logica de transicion
    void next_state_logic() {

        switch (state.read()) {

            case IDLE:
                next_state.write(
                    start.read() ? LOAD : IDLE
                );
                break;

            case LOAD:
                next_state.write(CHECK_EQUAL);
                break;

            case CHECK_EQUAL:
                next_state.write(
                    EQ.read() ? DONE : COMPARE
                );
                break;

            case COMPARE:
                next_state.write(
                    CARRY.read() ? SUB_Y : SUB_X
                );
                break;

            case SUB_X:
            case SUB_Y:
                next_state.write(CHECK_EQUAL);
                break;

            case DONE:
                next_state.write(
                    start.read() ? DONE : IDLE
                );
                break;

            default:
                next_state.write(IDLE);
                break;
        }
    }

    // Logica de salidas
    void output_logic() {

        SEL.write(state.read() == SUB_Y);

        INIT.write(state.read() == LOAD);

        LOAD_X.write(
            state.read() == LOAD ||
            state.read() == SUB_X
        );

        LOAD_Y.write(
            state.read() == LOAD ||
            state.read() == SUB_Y
        );

        done.write(state.read() == DONE);
    }

    SC_CTOR(Control) {

        state.write(IDLE);
        next_state.write(IDLE);

        SC_METHOD(state_register);
        sensitive << clk.pos();
        dont_initialize();

        SC_METHOD(next_state_logic);
        sensitive << state << start << EQ << CARRY;

        SC_METHOD(output_logic);
        sensitive << state;
    }
};

#endif