# Algoritmo de Euclides (MCD) en VHDL y Verilog

Este repositorio contiene el código en **VHDL** y **Verilog** para la implementación del algoritmo de Euclides, utilizado para calcular el Máximo Común Divisor (MCD) de dos números enteros no negativos ($A, B \ge 0$).

## Estructura e Implementación en FPGA

El proyecto incluye el módulo integrador **`mcd_system`**, el cual engloba tanto la lógica principal del cálculo como la infraestructura requerida para su ejecución en la FPGA **Colorlight i9**:

* **Módulo integrador:** `mcd_system` (conecta el core del algoritmo y la topología de la FPGA).
* **Entrada de datos:** Teclado táctil capacitivo.
* **Visualización / Salida:** Arreglo de LEDs.
