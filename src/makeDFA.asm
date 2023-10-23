%include "constants.inc" ; Includes the constants.inc file which contains the defn for structs
global makeDFA

section .data
    newNumStates: dd 0

section .text
    ; bool makeDFA(DFA *dfa1 , DFA *dfa2)

    ; Input registers:
    ; rdi = dfa1
    ; rsi = dfa2
    
sameLanguage:
    push rbp      ; Save the base pointer
    mov  rbp, rsp ; Set the base pointer to the stack pointer
    push r12      ; Save the callee saved registers
    push r13
    push r14

;=============================================
    mov r12, rdi
    mov r13, rsi
    ; int newNumStates = dfa1->numStates * dfa2->numStates;
    mov eax, [r12 + DFA.numStates]
    mov ebx, [r13 + DFA.numStates]
    imul eax, ebx
    mov [newNumStates], eax



;=============================================
    pop r12
    leave ; Restore the base pointer
    ret   ; Return``