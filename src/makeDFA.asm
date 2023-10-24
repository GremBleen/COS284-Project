%include "constants.inc" ; Includes the constants.inc file which contains the defn for structs
global makeDFA
extern initDfa
extern countTransitions

section .data
    newNumStates: dd 0
    newNumTransitions: dd 0
    transCount: dd 0
    statesCount: dd 0
    dfa1NumStates: dd 0
    dfa2NumStates: dd 0
    dfa1NumTransitions: dd 0
    dfa2NumTransitions: dd 0
    iSave: dd 0
    jSave: dd 0

section .text
    ; bool makeDFA(DFA *dfa1 , DFA *dfa2)

    ; Input registers:
    ; rdi = dfa1
    ; rsi = dfa2
    
makeDFA:
    push rbp      ; Save the base pointer
    mov rbp, rsp ; Set the base pointer to the stack pointer
    push r12      ; Save the callee saved registers
    push r13
    push r14

;=============================================
    mov r12, rdi
    mov r13, rsi
    ; int newNumStates = dfa1->numStates * dfa2->numStates;
    mov eax, [r12 + DFA.numStates] ; eax = dfa1->numStates
    mov ebx, [r13 + DFA.numStates] ; ebx = dfa2->numStates
    imul eax, ebx ; eax = dfa1->numStates * dfa2->numStates
    mov [newNumStates], eax ; newNumStates = dfa1->numStates * dfa2->numStates

    mov rdi, r12
    mov rsi, r13
    call countTransitions
    mov [newNumTransitions], eax ; newNumTransitions = countTransitions(dfa1, dfa2)

    ;DFA* combDfa = malloc(sizeof(DFA));
    mov rdi, newNumStates ; rdi = newNumStates
    mov rsi, newNumTransitions ; rsi = newNumTransitions
    call initDfa ; rax = combDfa

    mov r14, rax ; r14 = combDfa

    ; Save nums
    mov eax, [r12 + DFA.numStates]
    mov [dfa1NumStates], eax
    mov eax, [r12 + DFA.numTransitions]
    mov [dfa1NumTransitions], eax
    mov eax, [r13 + DFA.numStates]
    mov [dfa2NumStates], eax
    mov eax, [r13 + DFA.numTransitions]

    xor ecx, ecx ; i = 0
    cmp ecx, [dfa1NumStates] ; i < dfa1->numStates
    jge .endLoop1

    .loop1:
        ; State* s1 = dfa1->states[i];
        imul ebx, ecx, State_size ; ebx = i * State_size
        lea r8, [r12 + DFA.states + rbx] ; r8 = &dfa1->states[i]
        
        xor edx, edx ; j = 0
        cmp edx, [dfa2NumStates] ; j < dfa2->numStates
        jge .endLoop2

        .loop2:
            ; State* s2 = dfa2->states[j];
            imul ebx, edx, State_size ; ebx = j * State_size
            lea r9, [r13 + DFA.states + rbx] ; r9 = &dfa2->states[j]

            ;combDFA->states[count]->id = statesCount;
            mov eax, [statesCount] ; eax = statesCount
            imul ebx, eax, State_size ; ebx = statesCount * State_size
            lea r10, [r14 + DFA.states + rbx] ; r10 = &combDFA->states[count]
            mov [r10 + State.id], eax ; combDFA->states[count]->id = statesCount

            ;if((dfa1->states[i]->isAccepting && !dfa2->states[j]->isAccepting) || (!dfa1->states[i]->isAccepting && dfa2->states[j]->isAccepting))
            mov al, [r8 + State.isAccepting] ; al = dfa1->states[i]->isAccepting
            mov bl, [r9 + State.isAccepting] ; bl = dfa2->states[j]->isAccepting
            cmp al, bl ; cmp dfa1->states[i]->isAccepting, dfa2->states[j]->isAccepting
            je .accepting

            .notAccepting:
                ;combDFA->states[count]->isAccepting = false;
                mov byte [r10 + State.isAccepting], 0 ; combDFA->states[count]->isAccepting = false
                jmp .endNotAccepting

            .accepting:
                ;combDFA->states[count]->isAccepting = true;
                mov byte [r10 + State.isAccepting], 1 ; combDFA->states[count]->isAccepting = true

            .endNotAccepting:


            mov [iSave], ecx ; save i
            mov [jSave], edx ; save j

            xor ecx, ecx ; k = 0
            cmp ecx, [dfa1NumTransitions] ; k < dfa1->numTransitions
            jge .endLoop3 
             
            .loop3:
                ; Transition* t1 = dfa1->transitions[k];
                imul ebx, ecx, Transition_size ; ebx = k * Transition_size
                lea r10, [r12 + DFA.transitions + rbx] ; r10 = &dfa1->transitions[k]

                xor edx, edx ; l = 0
                cmp edx, [dfa2NumTransitions] ; l < dfa2->numTransitions
                jge .endLoop4

                .loop4:
                    ; Transition* t2 = dfa2->transitions[l];
                    imul ebx, edx, Transition_size ; ebx = l * Transition_size
                    lea r11, [r13 + DFA.transitions + rbx] ; r11 = &dfa2->transitions[l]

                    ; if(t1->from == state1->id && t2->from == state2->id)
                    mov eax, [r10 + Transition.from] ; eax = t1->from
                    cmp eax, [r8 + State.id] ; cmp t1->from, s1->id
                    jne .endLoop4
                    mov eax, [r11 + Transition.from] ; eax = t2->from
                    cmp eax, [r9 + State.id] ; cmp t2->from, s2->id
                    jne .endLoop4

                    ;if (t1->symbol == t2->symbol)
                    mov al, [r10 + Transition.symbol] ; al = t1->symbol
                    mov bl, [r11 + Transition.symbol] ; bl = t2->symbol
                    cmp al, bl ; cmp t1->symbol, t2->symbol
                    jne .endLoop4 

                    ;combDFA->transitions[transCount]->from = statesCount;
                    mov eax, [statesCount] ; eax = statesCount
                    imul ebx, eax, Transition_size ; ebx = statesCount * Transition_size
                    lea r11, [r14 + DFA.transitions + rbx] ; r11 = &combDFA->transitions[transCount]
                    mov [r11 + Transition.from], eax ; combDFA->transitions[transCount]->from = statesCount

                    ;comDFA->transitions[transCount]->symbol = t1->symbol;
                    mov al, [r10 + Transition.symbol] ; al = t1->symbol
                    mov [r11 + Transition.symbol], al ; combDFA->transitions[transCount]->symbol = t1->symbol

                    ;combDFA->transitions[transCount]->to = (dfa1->numStates * i) + j;
                    mov eax, [dfa1NumStates] ; eax = dfa1->numStates
                    mov ebx, [iSave] ; ebx = i
                    imul ebx, eax ; ebx = dfa1->numStates * i
                    add ebx, [jSave] ; ebx = (dfa1->numStates * i) + j
                    mov [r11 + Transition.to], ebx ; combDFA->transitions[transCount]->to = (dfa1->numStates * i) + j

                    ;transCount++
                    mov eax, [transCount]
                    inc eax
                    mov [transCount], eax ; Trans++

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
            
            ;statesCount++;
            mov eax, [statesCount]
            inc eax
            mov [statesCount], eax ; statesCount++

            inc edx ; j++
            cmp edx, [dfa2NumStates] ; j < dfa2->numStates
            jl .loop2
        .endLoop2:

        inc ecx ; i++
        cmp ecx, [dfa2NumStates] ; i < dfa1->numStates
        jl .loop1
    .endLoop1:

    mov rax, r14 ; rax = combDfa

;=============================================
    pop r14
    pop r13
    pop r12
    leave ; Restore the base pointer
    ret   ; Return``