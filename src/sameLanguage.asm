%include "constants.inc" ; Includes the constants.inc file which contains the defn for structs
global  sameLanguage

section .data

section .text
    ; bool sameLanguage(DFA *dfa1 , DFA *dfa2)

    ; Input registers:
    ; rdi = dfa1
    ; rsi = dfa2
    
sameLanguage:
    push rbp      ; Save the base pointer
    mov  rbp, rsp ; Set the base pointer to the stack pointer

;=============================================
;TODO: Implement sameLanguage
;=============================================
    leave ; Restore the base pointer
    ret   ; Return