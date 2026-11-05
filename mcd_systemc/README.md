# Algoritmo de Euclides (MCD) en VHDL y Verilog

Este repositorio contiene la implementación del algoritmo de Euclides para calcular el **Máximo Común Divisor (MCD)** de dos números enteros no negativos ($A, B \geq 0$).

El proyecto incluye una versión inicial en **VHDL** y una implementación posterior en **Verilog**, adaptada para su simulación, síntesis e implementación sobre una FPGA **Colorlight i9**.

Ya veremos ese cinco, profe 😎.

## Implementación en FPGA

El sistema completo se integra mediante el módulo `mcd_system`, que conecta el núcleo del algoritmo con la interfaz de usuario y los periféricos utilizados en la FPGA.

- **FPGA:** Colorlight i9
- **Entrada de datos:** panel táctil capacitivo de 8 entradas
- **Control:** pulsador físico
- **Salida:** arreglo de 8 LEDs
- **Algoritmo:** Euclides mediante restas sucesivas
- **Core principal:** `mcd_top`
- **Integración del sistema:** `mcd_system`

## Estructura del repositorio

```text
MCD_FPGA/
├── VHDLCode/
├── boards/
├── docs/
│   └── svg/
├── rtl/
│   ├── core/
│   ├── peripherals/
│   ├── system/
│   └── ui/
├── sim/
├── Makefile
└── README.md
```

### `VHDLCode`

Contiene la implementación inicial realizada en VHDL, utilizada como punto de partida para el desarrollo posterior en Verilog.

### `boards`

Contiene los archivos específicos de la tarjeta FPGA, como el módulo `top` y la asignación física de pines.

Actualmente se incluye la configuración para la **Colorlight i9**, pero esta separación permite agregar soporte para otras FPGA sin modificar el núcleo del algoritmo.

### `docs`

Contiene archivos de apoyo y documentación del proyecto, entre estos el PDF del informe.

Dentro de `docs/svg` se encuentran diagramas generados a partir del diseño, incluyendo:

- vistas jerárquicas del MCD;
- vistas jerárquicas del sistema completo;
- diagramas sintetizados a nivel de compuertas.

Los diagramas de compuertas pueden ser bastante grandes, por lo que se recomienda abrir los archivos `.svg` directamente en un navegador.

### `rtl`

Contiene la implementación principal en Verilog.

- `core/`: módulos correspondientes al algoritmo del MCD, incluyendo el datapath, la FSM, registros, multiplexores, restador y el módulo `mcd_top`.
- `system/`: integración entre el núcleo del algoritmo y la interfaz del sistema mediante `mcd_system`.
- `ui/`: módulos encargados del manejo de las entradas físicas, incluyendo sincronización, detección de flancos, debounce y control de la interfaz.
- `peripherals/`: contiene trabajo adicional relacionado con periféricos, incluyendo una implementación de I2C reutilizada de un proyecto anterior. Esta parte no se alcanzó a integrar completamente en la entrega actual y requiere algunos ajustes, entre ellos la adaptación del reloj.

### `sim`

Contiene los testbench utilizados para verificar tanto módulos individuales como el sistema completo.

Se incluyen pruebas para:

- núcleo MCD.
- interfaz táctil.
- pulsador.
- control de entrada.
- sistema completo.

### `build`

Cuando se completa el flujo de trabajo se crea una carpeta build que contiene todo lo que se le sube a la fpga, estos no se incluyen en el github para que cada cual pueda usar las herramientas que más le gusten, pero de ser necesario podemos subirla, quedamos pendientes.

## Uso del Makefile

El `Makefile` permite ejecutar las principales etapas del proyecto sin escribir manualmente todos los comandos de Icarus Verilog, Yosys, nextpnr y openFPGALoader.

### Simulación del núcleo MCD

```bash
make sim
```

Abrir las formas de onda en Surfer:

```bash
make wave
```

### Simulación del panel táctil

```bash
make sim-touch
make wave-touch
```

### Simulación del controlador de entrada

```bash
make sim-input
make wave-input
```

### Simulación del pulsador

```bash
make sim-button
make wave-button
```

### Simulación del sistema completo

```bash
make sim-system
make wave-system
```

Esta simulación verifica la integración entre el panel táctil, el pulsador, el controlador de interfaz y el núcleo del MCD.

## Implementación en la Colorlight i9

### Síntesis

```bash
make colorlight-synth
```

Realiza la síntesis del diseño mediante **Yosys** para la arquitectura ECP5.

### Place and Route

```bash
make colorlight-pnr
```

Ejecuta `nextpnr-ecp5`, utilizando la asignación de pines definida en:

```text
boards/colorlight_i9/colorlight_i9.lpf
```

### Generación del bitstream

```bash
make colorlight-bit
```

Genera el archivo:

```text
build/colorlight/top_colorlight.bit
```

### Programación de la FPGA

```bash
make colorlight-load
```

Este comando ejecuta automáticamente las etapas necesarias y finalmente carga el bitstream en la Colorlight i9 mediante `openFPGALoader`.

### Limpiar archivos generados

```bash
make clean
```

Elimina la carpeta `build/` y todos los archivos generados durante simulación, síntesis y place and route.

## Generación de diagramas SVG

Los diagramas incluidos en `docs/svg` fueron generados con **Yosys** y **NetlistSVG**. Estos comandos se ejecutan desde la raíz del repositorio.

### Vista jerárquica del núcleo MCD

```bash
mkdir -p build/svg && \
yosys -p "read_verilog -Irtl/core rtl/core/mcd_top.v; \
prep -top mcd_top; \
write_json build/svg/mcd_top.json" && \
netlistsvg build/svg/mcd_top.json -o build/svg/mcd_top.svg && \
open -a "Arc" build/svg/mcd_top.svg
```

### Vista jerárquica del sistema completo

```bash
mkdir -p build/svg && \
yosys -p "read_verilog \
-Irtl/core \
-Irtl/ui \
-Irtl/system \
rtl/ui/sync_2ff.v \
rtl/ui/edge_pulse.v \
rtl/ui/debounce.v \
rtl/ui/touch_frontend.v \
rtl/ui/button_frontend.v \
rtl/ui/input_control.v \
rtl/core/mcd_top.v \
rtl/system/mcd_system.v \
boards/colorlight_i9/top_colorlight.v; \
prep -top top_colorlight; \
write_json build/svg/top_colorlight_hier.json" && \
netlistsvg build/svg/top_colorlight_hier.json -o build/svg/top_colorlight_hier.svg && \
open -a "Arc" build/svg/top_colorlight_hier.svg
```

### Núcleo MCD a nivel de compuertas

```bash
mkdir -p build/svg && \
yosys -p "
read_verilog -Irtl/core rtl/core/mcd_top.v;
hierarchy -check -top mcd_top;
proc;
flatten;
memory_map;
opt;
opt_expr;
techmap;
opt;
abc -g AND,OR,XOR;
clean;
write_json build/svg/mcd_top_gates_flat.json
" && \
netlistsvg build/svg/mcd_top_gates_flat.json \
-o build/svg/mcd_top_gates_flat.svg && \
open -a "Arc" build/svg/mcd_top_gates_flat.svg
```

### Sistema completo a nivel de compuertas

```bash
mkdir -p build/svg && \
yosys -p "
read_verilog \
-Irtl/core \
-Irtl/ui \
-Irtl/system \
rtl/ui/sync_2ff.v \
rtl/ui/edge_pulse.v \
rtl/ui/debounce.v \
rtl/ui/touch_frontend.v \
rtl/ui/button_frontend.v \
rtl/ui/input_control.v \
rtl/core/mcd_top.v \
rtl/system/mcd_system.v \
boards/colorlight_i9/top_colorlight.v;

hierarchy -check -top top_colorlight;
proc;
flatten;
memory_map;
opt;
opt_expr;
techmap;
opt;
abc -g AND,OR,XOR;
clean;
write_json build/svg/top_colorlight_gates_flat.json
" && \
netlistsvg build/svg/top_colorlight_gates_flat.json \
-o build/svg/top_colorlight_gates_flat.svg && \
open -a "Arc" build/svg/top_colorlight_gates_flat.svg
```

Los dos últimos diagramas utilizan `flatten` y `abc -g AND,OR,XOR` para llevar el diseño a un nivel lógico más bajo. Debido al tamaño del sistema completo, el SVG resultante puede ser muy grande.

> En macOS se usa `open -a "Arc"` para abrir los SVG. En Linux se puede reemplazar esta parte por el navegador o visor de SVG disponible.

## Herramientas utilizadas

Todo este flujo de implementación fue realizado con herramientas open source y se utilizó y cargó desde macOS🍎. También puede ejecutarse en Linux🐧 instalando las herramientas:

- Icarus Verilog
- Surfer (O GTKWAVE)
- Yosys
- NetlistSVG
- nextpnr-ecp5
- Project Trellis / ecppack
- openFPGALoader

También se generaron algunos diagramas desde Quartus. Estos pueden consultarse en el PDF del informe adjunto en la carpeta `docs`.
