# Algoritmo de Euclides por restas sucesivas.
# Entradas: $a0=X, $a1=Y (enteros no negativos)
# Salida de la subrutina: $v0=MCD(X,Y)
# Casos especiales: MCD(0,n)=n, MCD(0,0)=0.

.data
cases:     .word 18,48,6, 48,18,6, 21,21,21, 0,37,37, 24,0,24
           .word 0,0,0, 49,35,7, 255,1,1, 255,254,1
n_cases:   .word 9
msg_case:  .asciiz "MCD("
msg_sep:   .asciiz ", "
msg_eq:    .asciiz ") = "
msg_ok:    .asciiz " [PASS]\n"
msg_fail:  .asciiz " [FAIL]\n"
msg_final: .asciiz "Errores: "
msg_nl:    .asciiz "\n"

.text
.globl main
main:
    la   $s0, cases        # puntero a la tabla
    lw   $s1, n_cases      # cantidad de casos
    li   $s2, 0            # contador de errores

next_case:
    beq  $s1, $zero, finish
    lw   $s3, 0($s0)       # entrada X original
    lw   $s4, 4($s0)       # entrada Y original
    lw   $s5, 8($s0)       # MCD esperado
    move $a0, $s3
    move $a1, $s4
    jal  gcd               # $v0 = MCD
    move $s6, $v0          # guardar resultado antes de syscalls

    li   $v0, 4
    la   $a0, msg_case
    syscall
    li   $v0, 1
    move $a0, $s3
    syscall
    li   $v0, 4
    la   $a0, msg_sep
    syscall
    li   $v0, 1
    move $a0, $s4
    syscall
    li   $v0, 4
    la   $a0, msg_eq
    syscall
    li   $v0, 1
    move $a0, $s6
    syscall

    bne  $s6, $s5, failed
    li   $v0, 4
    la   $a0, msg_ok
    syscall
    j    advance
failed:
    addiu $s2, $s2, 1
    li   $v0, 4
    la   $a0, msg_fail
    syscall
advance:
    addiu $s0, $s0, 12    # siguiente tripleta X,Y,esperado
    addiu $s1, $s1, -1
    j    next_case

finish:
    li   $v0, 4
    la   $a0, msg_final
    syscall
    li   $v0, 1
    move $a0, $s2
    syscall
    li   $v0, 4
    la   $a0, msg_nl
    syscall
    li   $v0, 10           # finalizar programa
    syscall

# Algoritmo: while (X != Y) { if (X < Y) Y -= X; else X -= Y; }
gcd:
    beq  $a0, $zero, return_y
    beq  $a1, $zero, return_x
loop:
    beq  $a0, $a1, return_x
    sltu $t0, $a0, $a1
    bne  $t0, $zero, subtract_y
    subu $a0, $a0, $a1
    j    loop
subtract_y:
    subu $a1, $a1, $a0
    j    loop
return_x:
    move $v0, $a0
    jr   $ra
return_y:
    move $v0, $a1
    jr   $ra
