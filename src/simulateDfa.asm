%include "constants.inc" ; Includes the constants.inc file which contains the defn for structs
global  simulateDfa

section .data

section .text
    ; bool simulateDfa(DFA *dfa , const char *inputString)

    ; Input registers:
    ; rdi = dfa
    ; rsi = inputString
    
simulateDfa:
    push rbp      ; Save the base pointer
    mov  rbp, rsp ; Set the base pointer to the stack pointer

;=============================================
;TODO: Implement simulateDfa
;=============================================
    leave ; Restore the base pointer
    ret   ; Return