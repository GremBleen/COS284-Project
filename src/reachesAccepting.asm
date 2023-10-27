%include "constants.inc" ; Includes the constants.inc file which contains the defn for structs
global reachesAccepting

section .data
    state: dd 0
    toId: dd 0
    numCalls: dd 0

section .text
    ; bool reachesAccepting(DFA *dfa, int state, numCalls)
    ; {
    ;     if(dfa->states[state]->isAccepting)
    ;     {
    ;         return true
    ;     }

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
    ;             if(if numCalls < dfa->numtransitions))
    ;               {
    ;                 if(reachesAccepting(dfa, to, numCalls + 1))
    ;                    {
    ;                     return true;
    ;                   }
    ;                 }
    ;         }
    ;     }
    ; }
    ; }

    ; Input registers:
    ; rdi = dfa
    ; rsi = state
    ; rdx = numCalls
    
reachesAccepting:
    push rbp      ; Save the base pointer
    mov  rbp, rsp ; Set the base pointer to the stack pointer
    push r12      ; Save r12

;=============================================
    mov r12, rdi
    mov [state], rsi
    mov [numCalls], rdx

    imul ebx, [state], State_size ; edx = state * State_size
    mov rax, [r12 + DFA.states]
    lea r8, [rax + rbx]
    cmp byte [r8 + State.isAccepting], 1 ; [rbx + State.isAccepting] = dfa->states[state]->isAccepting
    je for_loop.accepting
    
    xor ecx, ecx ; i = 0
    cmp ecx, [r12 + DFA.numTransitions]
    for_loop:
        ;if(id == dfa->transitions[i]->from)
        imul ebx, ecx, Transition_size ; ebx = i * Transition_size
        mov rax, [r12 + DFA.transitions] ; rax = dfa->transitions
        lea r8, [rax + rbx] ; r8 = dfa->transitions[i]
        mov eax, [state]
        cmp eax, [r8 + Transition.from]
        jne .mismatchID 

        ;int toId = dfa->transitions[i]->to;    
        mov eax, [r8 + Transition.to] ; eax = dfa->transitions[i]->to
        mov [toId], eax

        ;if(dfa->states[toId]->isAccepting)
        imul ebx, eax, State_size ; ebx = toId * State_size
        mov rax, [r12 + DFA.states] ; rax = dfa->states
        lea r9, [rax + rbx] ; r9 = dfa->states[toId]

        xor eax, eax ; eax = 0
        mov al, byte [r9 + State.isAccepting] ; al = dfa->states[toID]->isAccepting
        cmp al, 1
        je .accepting

        ;if (numCalls < dfa->numtransitions)
        mov eax, [numCalls]
        mov ebx, 1000
        ; mov ebx, [r12 + DFA.numTransitions]
        ; imul ebx, [r12 + DFA.numTransitions]
        cmp eax, ebx
        jge end_for_loop

        ;else if( reachesAccepting(dfa, toId) )
        .notAccepting:
            mov rdi, r12 ; dfa
            mov rsi, [toId] ; toId
            mov edx, [numCalls]
            inc edx ; numCalls++
            mov [numCalls], edx

            call reachesAccepting
            cmp al, 1
            je end

        ;return true
        .accepting:
            mov eax, 1
            jmp end

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