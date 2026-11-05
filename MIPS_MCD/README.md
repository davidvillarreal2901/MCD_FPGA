# MCD en MIPS (MARS)

Implementacion software del algoritmo mediante restas sucesivas.

1. Abrir `mcd.asm` en [MARS](https://computerscience.missouristate.edu/mars-mips-simulator.htm).
2. Usar **Assemble** y despues **Run** (modo predeterminado, sin delayed branching).
3. Comprobar nueve pruebas, todas `PASS`, y el mensaje final `Errores: 0`.

Subrutina `gcd`: entradas `$a0`, `$a1`; salida `$v0`; modificacion de `$t0`.
El programa principal usa syscalls MARS para mostrar los resultados de cada prueba.

Para probar un par propio, agregar `X,Y,MCD_esperado` a la tabla `cases` y aumentar `n_cases`.

Casos especiales extendidos: `MCD(0,n)=n`, `MCD(0,0)=0`.
