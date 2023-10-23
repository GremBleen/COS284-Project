%include "constants.inc" ; Includes the constants.inc file which contains the defn for structs
global reachesAccepting

section .data
    state: dd 0
    toId: dd 0

section .text
    ; bool reachesAccepting(DFA *dfa, int state)
    ; {
    ;     for(int i = 0; i < dfa->numTransitions; i++)
    ;     {
    ;     if(id == dfa->transitions[i]->from)
    ;     {
    ;         int to = dfa->transitions[i]->to;
    ;         if(dfa->states[to]->isAccepting)
    ;         {
    ;             return true;
    ;         }
    ;         else
    ;         {
    ;             if(reachesAccepting(dfa, i))
    ;               {
    ;              return true;}
    ;         }
    ;     }
    ; }
    ; }

    ; Input registers:
    ; rdi = dfa
    ; rsi = state
    
reachesAccepting:
    push rbp      ; Save the base pointer
    mov  rbp, rsp ; Set the base pointer to the stack pointer
    push r12      ; Save r12

;=============================================
    mov r12, rdi
    mov [state], rsi
    xor ecx, ecx ; i = 0
    cmp ecx, [r12 + DFA.numTransitions]
    for_loop:
        ;if(id == dfa->transitions[i]->from)
        mov eax, [state] ; eax = id
        imul edx, ecx, Transition_size ; edx = i * Transition_size
        cmp eax, [r12 + DFA.transitions + rdx + Transition.from] ; eax = id, [r12 + DFA.transitions + rdx + Transition.from] = dfa->transitions[i]->from
        jne .mismatchID

        ;int toId = dfa->transitions[i]->to;    
        mov eax, [r12 + DFA.transitions + rdx + Transition.to]
        mov [toId], eax ; toId = dfa->transitions[i]->to

        ;if(dfa->states[toId]->isAccepting)
        mov eax, [toId] ; eax = toId 
        imul edx, eax, State_size ; edx = toId * State_size
        cmp byte [r12 + DFA.states + rdx + State.isAccepting], 1 ; [r12 + DFA.states + rdx + State.isAccepting] = dfa->states[toId]->isAccepting
        je .notAccepting

        ;return true
        .accepting:
            mov eax, 1
            jmp end

        ;else if( reachesAccepting(dfa, toId) )
        .notAccepting:
            mov rdi, r12 ; dfa
            mov rsi, [toId] ; toId
            call reachesAccepting
            cmp byte [rax], 1
            je end

        .mismatchID:
        inc ecx ; i++
        cmp ecx, [r12 + DFA.numTransitions]
        jl for_loop
    end_for_loop:
    
    mov eax, 0

    end:

    ;return rax
;=============================================
    pop r12
    leave ; Restore the base pointer
    ret   ; Return``