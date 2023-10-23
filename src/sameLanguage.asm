%include "constants.inc" ; Includes the constants.inc file which contains the defn for structs
global  sameLanguage
extern makeDFA
extern reachesAccepting

section .data

section .text
    ; bool sameLanguage(DFA *dfa1 , DFA *dfa2)

    ; Input registers:
    ; rdi = dfa1
    ; rsi = dfa2
    
sameLanguage:
    push rbp      ; Save the base pointer
    mov  rbp, rsp ; Set the base pointer to the stack pointer
    push r12      ; Save the callee saved registers

;=============================================
; Code we will implement:

; bool sameLanguage(DFA *dfa1 , DFA *dfa2)
; {
;     DFA* combDFA = makeDFA(dfa1,dfa2);

;     return reachesAccepting(combDFA, combDFA->startState);
; }
    call makeDFA
    mov r12, rax

    mov rdi, r12 ; combDFA loaded
    mov rsi, [r12 + DFA.startState] ; combDFA->startState loaded   
    call reachesAccepting

    ;return rax 

;=============================================
    pop r12
    leave ; Restore the base pointer
    ret   ; Return``