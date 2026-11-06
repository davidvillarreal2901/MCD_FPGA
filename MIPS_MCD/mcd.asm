# MCD / GCD en MIPS (MARS 4.5)
# 33 casos dirigidos comunes con Verilog y SystemC
# 10 casos pseudoaleatorios generados y verificados en MIPS
# Algoritmo bajo prueba: Euclides por RESTAS sucesivas
# Oraculo de las pruebas aleatorias: Euclides por RESIDUOS
# Dominio de las entradas: 0..255
# Convencion de subrutinas: $a0 y $a1 entradas, $v0 salida
# Se usan nop tras saltos para permitir tambien 'delayed branching'.

.data
# Cada grupo: X, Y, MCD esperado.
cases:
    .word  48, 18,  6,   17,  5,  1,    0,  9,  9
    .word   9,  0,  9,    0,  0,  0,    1,  1,  1
    .word 255,255,255,  255,  1,  1,    1,255,  1
    .word 100, 75, 25,   12,  8,  4,    8, 12,  4
    .word  35, 14,  7,   81, 27, 27,   64, 48, 16
    .word  97, 13,  1,  250,100, 50,  200,150, 50
    .word 144, 60, 12,   21, 14,  7,    7, 49,  7
    .word  49,  7,  7,  128, 64, 64,  255, 85, 85
    .word 170,102, 34,  221,119, 17,  253, 11, 11
    .word  90, 45, 45,   42, 56, 14,   30, 18,  6
    .word  15, 25,  5,  144, 89,  1,  233,144,  1
n_cases:    .word 33

msg_direct: .asciiz "=== 33 pruebas dirigidas ===\n"
msg_random: .asciiz "=== 10 pruebas pseudoaleatorias ===\n"
msg_case:   .asciiz "MCD("
msg_sep:    .asciiz ", "
msg_eq:     .asciiz ") = "
msg_ok:     .asciiz " [PASS]\n"
msg_fail:   .asciiz " [FAIL]  Esperado: "
msg_summary:.asciiz "=== Total: 43 pruebas | Errores: "
msg_nl:     .asciiz "\n"

.text
.globl main
main:
    # Registros persistentes utilizados por main:
    # $s0 = puntero a tabla; $s1 = pruebas dirigidas pendientes
    # $s2 = errores acumulados
    # $s3 = X original; $s4 = Y original
    # $s5 = MCD esperado; $s6 = MCD obtenido
    # $s7 = pruebas pseudoaleatorias pendientes
    la    $s0, cases
    lw    $s1, n_cases
    li    $s2, 0

    li    $v0, 4
    la    $a0, msg_direct
    syscall

directed_loop:
    beq   $s1, $zero, random_setup
    nop
    lw    $s3, 0($s0)
    lw    $s4, 4($s0)
    lw    $s5, 8($s0)

    move  $a0, $s3
    move  $a1, $s4
    jal   gcd
    nop
    move  $s6, $v0

    jal   report_case            # $v0 = 0 PASS; 1 FAIL
    nop
    addu  $s2, $s2, $v0          # acumular los errores

    addiu $s0, $s0, 12           # siguiente tripleta: 3 x 4 bytes
    addiu $s1, $s1, -1
    j     directed_loop
    nop

random_setup:
    li    $v0, 4
    la    $a0, msg_random
    syscall

    # Syscall 40: semilla fija para que MARS sea reproducible.
    # Los 10 valores son pseudoaleatorios, no necesariamente iguales
    # a los producidos por rand() en C++ o $urandom en Verilog.
    li    $v0, 40
    li    $a0, 0                # generador numero 0
    li    $a1, 2026             # semilla
    syscall

    li    $s7, 10

random_loop:
    beq   $s7, $zero, finish
    nop

    # Syscall 42: devuelve un entero en [0, 256) mediante $a0.
    li    $v0, 42
    li    $a0, 0
    li    $a1, 256
    syscall
    move  $s3, $a0             # X aleatorio

    li    $v0, 42
    li    $a0, 0
    li    $a1, 256
    syscall
    move  $s4, $a0             # Y aleatorio

    # Referencia independiente: Euclides con residuo.
    move  $a0, $s3
    move  $a1, $s4
    jal   gcd_ref
    nop
    move  $s5, $v0             # resultado esperado

    # Implementacion bajo prueba: Euclides con restas.
    move  $a0, $s3
    move  $a1, $s4
    jal   gcd
    nop
    move  $s6, $v0             # resultado calculado

    jal   report_case
    nop
    addu  $s2, $s2, $v0

    addiu $s7, $s7, -1
    j     random_loop
    nop

finish:
    li    $v0, 4
    la    $a0, msg_summary
    syscall
    li    $v0, 1
    move  $a0, $s2
    syscall
    li    $v0, 4
    la    $a0, msg_nl
    syscall
    li    $v0, 10
    syscall

# ------------------------------------------------------------
# gcd: algoritmo restas sucesivas
#       X == 0 -> Y; Y == 0 -> X; (0,0) -> 0
# ------------------------------------------------------------
gcd:
    beq   $a0, $zero, gcd_return_y
    nop
    beq   $a1, $zero, gcd_return_x
    nop

gcd_loop:
    beq   $a0, $a1, gcd_return_x
    nop
    sltu  $t0, $a0, $a1          # t0=1 si X < Y (sin signo)
    bne   $t0, $zero, gcd_subtract_y
    nop
    subu  $a0, $a0, $a1          # X = X - Y
    j     gcd_loop
    nop

gcd_subtract_y:
    subu  $a1, $a1, $a0          # Y = Y - X
    j     gcd_loop
    nop

gcd_return_x:
    move  $v0, $a0
    jr    $ra
    nop

gcd_return_y:
    move  $v0, $a1
    jr    $ra
    nop

# ------------------------------------------------------------
# gcd_ref: oraculo de pruebas aleatorias (Euclides por modulo)
#          Solo se usa para obtener el valor esperado.
# ------------------------------------------------------------
gcd_ref:
    beq   $a0, $zero, ref_return_y
    nop

ref_loop:
    beq   $a1, $zero, ref_return_x
    nop
    divu  $a0, $a1               # HI = X % Y; LO = X / Y
    mfhi  $t1                    # residuo
    move  $a0, $a1               # X = Y
    move  $a1, $t1               # Y = residuo
    j     ref_loop
    nop

ref_return_x:
    move  $v0, $a0
    jr    $ra
    nop

ref_return_y:
    move  $v0, $a1
    jr    $ra
    nop

# ------------------------------------------------------------
# report_case: imprime resultado y verifica contra $s5.
# Entrada: $s3 = X, $s4 = Y, $s5 = esperado, $s6 = obtenido
# Retorno: $v0 = 0 si coincide, 1 si no coincide
# No altera registros $s* (convencion de llamada).
# ------------------------------------------------------------
report_case:
    li    $v0, 4
    la    $a0, msg_case
    syscall
    li    $v0, 1
    move  $a0, $s3
    syscall
    li    $v0, 4
    la    $a0, msg_sep
    syscall
    li    $v0, 1
    move  $a0, $s4
    syscall
    li    $v0, 4
    la    $a0, msg_eq
    syscall
    li    $v0, 1
    move  $a0, $s6
    syscall

    bne   $s6, $s5, report_fail
    nop
    li    $v0, 4
    la    $a0, msg_ok
    syscall
    li    $v0, 0                # PASS
    jr    $ra
    nop

report_fail:
    li    $v0, 4
    la    $a0, msg_fail
    syscall
    li    $v0, 1
    move  $a0, $s5
    syscall
    li    $v0, 4
    la    $a0, msg_nl
    syscall
    li    $v0, 1                # FAIL
    jr    $ra
    nop
