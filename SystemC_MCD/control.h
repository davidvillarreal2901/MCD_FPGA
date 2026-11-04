#ifndef CONTROL_H
#define CONTROL_H

#include <systemc.h>

SC_MODULE(Control) {
    sc_in<bool> clk;
    sc_in<bool> reset;
    sc_in<bool> start;
    sc_in<bool> eq;
    sc_in<bool> x_less_y;

    sc_out<bool> load_x;
    sc_out<bool> load_y;
    sc_out<bool> sub_x;
    sc_out<bool> sub_y;
    sc_out<bool> done;

    enum State {
        IDLE,
        LOAD,
        CHECK_EQUAL,
        CHECK_LESS,
        SUB_X,
        SUB_Y,
        DONE
    };

    sc_signal<State> state;
    sc_signal<State> next_state;

    void state_register() {
        if (reset.read())
            state.write(IDLE);
        else
            state.write(next_state.read());
    }

    void next_state_logic() {
        switch (state.read()) {
            case IDLE:
                next_state.write(start.read() ? LOAD : IDLE);
                break;

            case LOAD:
                next_state.write(CHECK_EQUAL);
                break;

            case CHECK_EQUAL:
                next_state.write(
                    eq.read() ? DONE : CHECK_LESS);
                break;

            case CHECK_LESS:
                next_state.write(
                    x_less_y.read() ? SUB_Y : SUB_X);
                break;

            case SUB_X:
            case SUB_Y:
                next_state.write(CHECK_EQUAL);
                break;

            case DONE:
                next_state.write(
                    start.read() ? DONE : IDLE);
                break;

            default:
                next_state.write(IDLE);
                break;
        }
    }

    void output_logic() {
        load_x.write(state.read() == LOAD);
        load_y.write(state.read() == LOAD);
        sub_x.write(state.read() == SUB_X);
        sub_y.write(state.read() == SUB_Y);
        done.write(state.read() == DONE);
    }

    SC_CTOR(Control) {
        state.write(IDLE);
        next_state.write(IDLE);

        SC_METHOD(state_register);
        sensitive << clk.pos();
        dont_initialize();

        SC_METHOD(next_state_logic);
        sensitive << state << start << eq << x_less_y;

        SC_METHOD(output_logic);
        sensitive << state;
    }
};

#endif