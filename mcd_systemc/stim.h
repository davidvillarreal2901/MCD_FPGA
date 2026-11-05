#ifndef STIM_H
#define STIM_H
#include <systemc.h>
#include <cstdlib>

// Generador de estimulos (Stimulus Generator) para mcd_top.
// Aplica reset y luego una serie de pruebas (A, B, start), esperando "done"
// entre prueba y prueba. Cambia las entradas en el flanco de bajada del reloj.
SC_MODULE(stim) {
    sc_in<bool>         clk;
    sc_in<bool>         done;     // realimentacion desde el DUV (para secuenciar)
    sc_out<bool>        rst;
    sc_out<bool>        start;
    sc_out<sc_uint<8> > A;
    sc_out<sc_uint<8> > B;

    // Una prueba completa: carga A y B, levanta start, espera done, baja start
    void run_test(unsigned a_in, unsigned b_in) {
        wait();                              // siguiente flanco de bajada
        A.write(a_in);
        B.write(b_in);
        start.write(true);

        int cycles = 0;                      // timeout de seguridad
        wait();
        while (!done.read() && cycles < 2000) {
            wait();
            cycles++;
        }

        wait();
        start.write(false);                  // la FSM regresa a IDLE
        wait();
    }

    void StimGen() {
        // Reset
        rst.write(true);
        start.write(false);
        A.write(0);
        B.write(0);
        wait(); wait(); wait();
        rst.write(false);
        wait();

        // Pruebas dirigidas
        static const unsigned dir[][2] = {
            { 48,  18}, { 17,   5}, {  0,   9}, {  9,   0}, {  0,   0},
            {  1,   1}, {255, 255}, {255,   1}, {  1, 255}, {100,  75},
            { 12,   8}, {  8,  12}, { 35,  14}, { 81,  27}, { 64,  48},
            { 97,  13}, {250, 100}, {200, 150}, {144,  60}, { 21,  14},
            {  7,  49}, { 49,   7}, {128,  64}, {255,  85}, {170, 102},
            {221, 119}, {253,  11}, { 90,  45}, { 42,  56}, { 30,  18},
            { 15,  25}, {144,  89}, {233, 144}
        };
        for (unsigned i = 0; i < sizeof(dir) / sizeof(dir[0]); i++)
            run_test(dir[i][0], dir[i][1]);

        // Pruebas aleatorias (semilla fija para que sea reproducible)
        std::srand(2026);
        for (int i = 0; i < 10; i++)
            run_test(std::rand() % 256, std::rand() % 256);

        wait(); wait();
        sc_stop();                           // avisa al kernel que termine
    }

    SC_CTOR(stim) {
        SC_THREAD(StimGen);
        sensitive << clk.neg();
    }
};
#endif
