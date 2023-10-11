%include "constants.inc" ; Includes the constants.inc file which contains the defn for structs
global  readDfa

section .data

section .text
    ; DFA* readDfa(const char *filename)

    ;Input registers:
    ; rdi = filename
    ; rsi = dfa

readDfa:
    push rbp      ; Save the base pointer
    mov  rbp, rsp ; Set the base pointer to the stack pointer

;=============================================
;TODO: Implement readDfa
;=============================================
    leave ; Restore the base pointer
    ret   ; Return