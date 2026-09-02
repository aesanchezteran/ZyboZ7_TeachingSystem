@ Hello in ARM ISA
.text
.global _start
.global main

_start:
main:
    LDR R0, =0x41200000  @ GPIO base address
    MOV R1, #0xFF        @ Value to write
    STR R1, [R0]         @ Store to GPIO
here:
    B here               @ Infinite loop

.ltorg
