%include "constants.inc" ; Includes the constants.inc file which contains the defn for structs
global countTransitions

section .data
    numTrans: dd 0
    dfa1NumStates: dd 0
    dfa2NumStates: dd 0
    dfa1NumTransitions: dd 0
    dfa2NumTransitions: dd 0
    iSave: dd 0
    jSave: dd 0

section .text
    ; bool countTransitions(DFA *dfa1, DFA* dfa2)
    ; for(int i = 0; i < dfa1->numStates; i++)
    ; {
    ;     State* s1 = dfa1->states[i];
    ;     for(int j = 0; j < dfa2->numStates; j++)
    ;     {
    ;         State* s2 = dfa2->states[j];
    ;         count++;

    ;         for(int k = 0; k < dfa1->numTransitions; k++)
    ;         {
    ;             Transition* t1 = dfa1->transitions[k];
    ;             for(int l = 0; l < dfa2->numTransitions; l++)
    ;             {
    ;                 Transition* t2 = dfa2->transitions[l];
    ;                 if(t1->from == state1->id && t2->from == state2->id)
    ;                 {
    ;                     if(t1->symbol == t2->symbol)
    ;                     {
    ;                         transCount++;
    ;                     }
    ;                 }
    ;             }
    ;         }
    ;     }
    ; }

    ; Input registers:
    ; rdi = dfa
    ; rsi = state
    
countTransitions:
    push rbp      ; Save the base pointer
    mov  rbp, rsp ; Set the base pointer to the stack pointer
    push r12      ; Save r12
    push r13      ; Save r13

;=============================================
    mov r12, rdi ; r12 = dfa1
    mov r13, rsi ; r13 = dfa2

    ; for(int i = 0; i < dfa1->numStates; i++)
    mov eax, [r12 + DFA.numStates]
    mov [dfa1NumStates], eax
    mov eax, [r12 + DFA.numTransitions]
    mov [dfa1NumTransitions], eax
    mov eax, [r13 + DFA.numStates]
    mov [dfa2NumStates], eax
    mov eax, [r13 + DFA.numTransitions]
    mov [dfa2NumTransitions], eax

    xor ecx, ecx ; i = 0
    cmp ecx, [dfa1NumStates] ; i < dfa1->numStates
    jge .endLoop1

    .loop1:
        ; State* s1 = dfa1->states[i];
        imul ebx, ecx, State_size ; ebx = i * State_size
        mov rax, [r12 + DFA.states]
        lea r8, [rax + rbx] ; r8 = &dfa1->states[i]
        
        xor edx, edx ; j = 0
        cmp edx, [dfa2NumStates] ; j < dfa2->numStates
        jge .endLoop2

        .loop2:
            ; State* s2 = dfa2->states[j];
            imul ebx, edx, State_size ; ebx = j * State_size
            mov rax, [r13 + DFA.states]
            lea r9, [rax + rbx] ; r9 = &dfa2->states[j]

            mov [iSave], ecx ; save i
            mov [jSave], edx ; save j

            xor ecx, ecx ; k = 0
            cmp ecx, [dfa1NumTransitions] ; k < dfa1->numTransitions
            jge .endLoop3
             
            .loop3:
                ; Transition* t1 = dfa1->transitions[k];
                imul ebx, ecx, Transition_size ; ebx = k * Transition_size
                mov rax, [r12 + DFA.transitions]
                lea r10, [rax + rbx] ; r10 = &dfa1->transitions[k]

                xor edx, edx ; l = 0
                cmp edx, [dfa2NumTransitions] ; l < dfa2->numTransitions
                jge .endLoop4

                .loop4:
                    ; Transition* t2 = dfa2->transitions[l];
                    imul ebx, edx, Transition_size ; ebx = l * Transition_size
                    mov rax, [r13 + DFA.transitions]
                    lea r11, [rax + rbx] ; r11 = &dfa2->transitions[l]

                    ; if(t1->from == state1->id && t2->from == state2->id)
                    mov eax, [r10 + Transition.from] ; eax = t1->from
                    cmp eax, [r8 + State.id] ; cmp t1->from, s1->id
                    jne .failedCMP
                    mov eax, [r11 + Transition.from] ; eax = t2->from
                    cmp eax, [r9 + State.id] ; cmp t2->from, s2->id
                    jne .failedCMP

                    ;if (t1->symbol == t2->symbol)
                    xor eax, eax ; eax = 0
                    xor ebx, ebx ; ebx = 0
                    mov al, [r10 + Transition.symbol] ; al = t1->symbol
                    mov bl, [r11 + Transition.symbol] ; bl = t2->symbol
                    cmp al, bl ; cmp t1->symbol, t2->symbol
                    jne .failedCMP

                    mov eax, [numTrans]
                    inc eax
                    mov [numTrans], eax ; Trans++

                    .failedCMP:
                    inc edx ; l++
                    cmp edx, [dfa2NumTransitions] ; l < dfa2->numTransitions
                    jl .loop4
                .endLoop4:

                inc ecx ; k++
                cmp ecx, [dfa1NumTransitions] ; k < dfa1->numTransitions
                jl .loop3
            .endLoop3: 

            mov ecx, [iSave] ; restore i
            mov edx, [jSave] ; restore j
            
            inc edx ; j++
            cmp edx, [dfa2NumStates] ; j < dfa2->numStates
            jl .loop2
        .endLoop2:

        inc ecx ; i++
        cmp ecx, [dfa2NumStates] ; i < dfa1->numStates
        jl .loop1
    .endLoop1:

    mov eax, [dfa1NumTransitions]
    mov ebx, [dfa2NumTransitions]
    imul ebx, eax
    mov eax, [numTrans]
    cmp eax, ebx
    jg tooMany

    jmp end

    tooMany:
        mov eax, ebx

    end:

    ;return rax
;=============================================
    pop r13
    pop r12
    leave ; Restore the base pointer
    ret   ; Return``