%include "constants.inc" ; Includes the constants.inc file which contains the defn for structs
global  sameLanguage
extern  makeDFA
extern  reachesAccepting
extern  free

section .data
  save: db 0

section .text
    ; bool sameLanguage(DFA *dfa1 , DFA *dfa2)
    ; bool sameLanguage(DFA *dfa1 , DFA *dfa2)
    ; {
    ;     DFA* combDFA = makeDFA(dfa1,dfa2);
    ;     return reachesAccepting(combDFA, combDFA->startState);
    ; }

    ; Input registers:
    ; rdi = dfa1
    ; rsi = dfa2
    
sameLanguage:
    push rbp      ; Save the base pointer
    mov  rbp, rsp ; Set the base pointer to the stack pointer
    push r12      ; Save the callee saved registers

;=============================================
; Code we will implement:
    call makeDFA
    mov r12, rax

    mov rdi, r12                    ; combDFA loaded
    mov rsi, [r12 + DFA.startState] ; combDFA->startState loaded
    mov edx, 0
    call reachesAccepting

    cmp al, 1             ; if an accept is reachable return false as they not same language
    jne sameLanguage_true

    sameLanguage_false:
      mov eax, 0           ; return false
      jmp end_sameLanguage

    sameLanguage_true:
      mov eax, 1 ; return true
      
    end_sameLanguage:
      
    mov [save], eax

    mov r8, [r12 + DFA.states]
    mov r9, [r12 + DFA.transitions]
    
    mov rdi, r12
    call free

    mov eax, [save]

    ;return rax

;=============================================
    pop r12
    leave     ; Restore the base pointer
    ret       ; Return``