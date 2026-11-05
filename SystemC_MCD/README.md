Implementación del algoritmo MCD en SystemC. Incluye unidad de control, datapath, y banco de pruebas.

##Comandos

```bash
cd SystemC_MCD
make test
make wave  # GTKWave; alternativa: make wave WAVE_VIEWER=/ruta/surfer
make clean
```

## Archivos

- `control.h`: FSM Moore de 7 estados, senales de control y finalizacion.
- `datapath.h`: registros de 8 bits, restas y comparaciones.
- `mcd.h`: DUV que interconecta control y datapath.
- `stim.h`: generador de estimulos y comprobacion automatica de 9 vectores.
- `mon.h`: monitor de cambios de estado visibles en X, Y y done.
- `mcd_tb.cpp`: `sc_main`, conexiones `sc_clock`/`sc_signal` y trazas.
- `Makefile`: compilacion, ejecucion y apertura del VCD.

## Requisitos

En macOS: `brew install systemc`. En Debian/Ubuntu: `sudo apt install libsystemc-dev gtkwave`.
Si SystemC no se detecta automaticamente: `make SYSTEMC_PREFIX=/ruta/al/prefijo`.
