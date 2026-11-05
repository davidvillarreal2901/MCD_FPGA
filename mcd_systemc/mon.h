#ifndef MON_H
#define MON_H
#include <systemc.h>
#include <cstdio>

// Monitor autoverificable para mcd_top.
// Observa las senales, mide los ciclos de cada operacion y compara MCD con un
// modelo de referencia cuando done sube. Imprime el resumen al terminar la
// simulacion (end_of_simulation).
SC_MODULE(mon) {
    sc_in_clk           clk;
    sc_in<bool>         start;
    sc_in<bool>         done;
    sc_in<sc_uint<8> >  A;
    sc_in<sc_uint<8> >  B;
    sc_in<sc_uint<8> >  MCD;

    int  n_tests, n_ok, n_err;
    int  cycles;
    bool running, prev_start, prev_done;

    // Modelo de referencia (solo simulacion)
    static unsigned gcd_ref(unsigned a, unsigned b) {
        unsigned x = a & 0xFF, y = b & 0xFF;
        if (x == 0) return y;
        if (y == 0) return x;
        while (x != y) {
            if (x < y) y -= x;
            else       x -= y;
        }
        return x;
    }

    void Monitor() {
        while (true) {
            wait();                                   // flanco de bajada
            bool s = start.read(), d = done.read();

            if (s && !prev_start) {                   // empieza una prueba
                if (running) {                        // la anterior nunca termino
                    n_err++;
                    std::printf("[%s] ERROR #%d  TIMEOUT (done nunca subio)\n",
                                sc_time_stamp().to_string().c_str(), n_tests);
                }
                n_tests++;
                cycles  = 0;
                running = true;
            } else if (running) {
                cycles++;
            }

            if (d && !prev_done && running) {         // termino la prueba
                unsigned a = A.read().to_uint();
                unsigned b = B.read().to_uint();
                unsigned got = MCD.read().to_uint();
                unsigned exp = gcd_ref(a, b);
                if (got == exp) {
                    n_ok++;
                    std::printf("[%s] OK    #%d  MCD(%3u,%3u) = %3u  (%d ciclos)\n",
                                sc_time_stamp().to_string().c_str(), n_tests, a, b, got, cycles);
                } else {
                    n_err++;
                    std::printf("[%s] ERROR #%d  MCD(%3u,%3u) = %3u, esperado %3u\n",
                                sc_time_stamp().to_string().c_str(), n_tests, a, b, got, exp);
                }
                running = false;
            }
            prev_start = s;
            prev_done  = d;
        }
    }

    // Callback del kernel al terminar la simulacion
    void end_of_simulation() {
        if (running) {
            n_err++;
            std::printf("ERROR #%d  la simulacion termino con una prueba sin completar\n", n_tests);
        }
        std::printf("=======================================\n");
        std::printf("Total pruebas: %d | OK: %d | ERRORES: %d\n", n_tests, n_ok, n_err);
        std::printf(n_err == 0 ? "RESULTADO: TODAS LAS PRUEBAS PASARON\n"
                               : "RESULTADO: HAY ERRORES\n");
        std::printf("=======================================\n");
    }

    SC_CTOR(mon) : n_tests(0), n_ok(0), n_err(0), cycles(0),
                   running(false), prev_start(false), prev_done(false) {
        SC_THREAD(Monitor);
        sensitive << clk.neg();
        dont_initialize();
        std::printf("========== MCD: pruebas ==========\n");
    }
};
#endif
