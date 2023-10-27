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
    t1TO: dd 0
    t2TO: dd 0

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

    xor eax, eax ; eax = 0
    mov [statesCount], eax
    mov [transCount], eax

    mov r8, [r12 + DFA.states]
    mov r9, [r13 + DFA.states]
    mov r10, [r12 + DFA.transitions]
    mov r11, [r13 + DFA.transitions]

    ; int newNumStates = dfa1->numStates * dfa2->numStates;
    mov eax, [r12 + DFA.numStates] ; eax = dfa1->numStates
    mov ebx, [r13 + DFA.numStates] ; ebx = dfa2->numStates
    imul eax, ebx ; eax = dfa1->numStates * dfa2->numStates
    mov [newNumStates], eax ; newNumStates = dfa1->numStates * dfa2->numStates

    mov rdi, r12
    mov rsi, r13
    call countTransitions
    mov [newNumTransitions], eax ; newNumTransitions = countTransitions(dfa1, dfa2)

    ; Save nums
    mov eax, [r12 + DFA.numStates]
    mov [dfa1NumStates], eax
    mov eax, [r12 + DFA.numTransitions]
    mov [dfa1NumTransitions], eax
    mov eax, [r13 + DFA.numStates]
    mov [dfa2NumStates], eax
    mov eax, [r13 + DFA.numTransitions]
    mov [dfa2NumTransitions], eax

    ;DFA* combDfa = malloc(sizeof(DFA));
    mov edi, [newNumStates] ; rdi = newNumStates
    mov esi, [newNumTransitions] ; rsi = newNumTransitions
    call initDfa ; rax = combDfa

    mov r14, rax ; r14 = combDfa

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

            ;combDFA->states[count]->id = statesCount;
            xor ebx, ebx ; ebx = 0
            mov eax, [statesCount]
            imul ebx, eax, State_size ; ebx = statesCount * State_size
            mov rax, [r14 + DFA.states]
            lea r10, [rax + rbx] ; r10 = &combDFA->states[count]
            mov eax, [statesCount] ; eax = statesCount
            mov [r10 + State.id], eax ; combDFA->states[count]->id = statesCount

            ;if((dfa1->states[i]->isAccepting && !dfa2->states[j]->isAccepting) || (!dfa1->states[i]->isAccepting && dfa2->states[j]->isAccepting))
            xor eax, eax ; eax = 0
            xor ebx, ebx ; ebx = 0
            mov al, byte [r8 + State.isAccepting] ; al = dfa1->states[i]->isAccepting
            mov bl, byte [r9 + State.isAccepting] ; bl = dfa2->states[j]->isAccepting
            cmp al, bl ; cmp dfa1->states[i]->isAccepting, dfa2->states[j]->isAccepting
            jne .accepting

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
                mov rax, [r12 + DFA.transitions]
                lea r10, [rax + rbx] ; r10 = &dfa1->transitions[k]
                mov eax, [r10 + Transition.to] ; eax = t1->to
                mov [t1TO], eax ; t1TO = t1->to

                xor edx, edx ; l = 0
                cmp edx, [dfa2NumTransitions] ; l < dfa2->numTransitions
                jge .endLoop4

                .loop4:
                    ; Transition* t2 = dfa2->transitions[l];
                    imul ebx, edx, Transition_size ; ebx = l * Transition_size
                    mov rax, [r13 + DFA.transitions]
                    lea r11, [rax + rbx] ; r11 = &dfa2->transitions[l]
                    mov eax, [r11 + Transition.to] ; eax = t2->to
                    mov [t2TO], eax ; t2TO = t2->to

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

                    ;combDFA->transitions[transCount]->from = (dfa1->numStates * i) + j;
                    mov eax, [transCount] ; eax = statesCount
                    imul ebx, eax, Transition_size ; ebx = statesCount * Transition_size
                    mov rax, [r14 + DFA.transitions]
                    lea r11, [rax + rbx] ; r11 = &combDFA->transitions[transCount]
                    mov eax, [dfa2NumStates] ; eax = dfa1->numStates
                    imul eax, [iSave] ; eax = dfa2->numStates * i
                    add eax, [jSave]
                    mov [r11 + Transition.from], eax ; combDFA->transitions[transCount]->from = statesCount

                    ;comDFA->transitions[transCount]->symbol = t1->symbol;
                    xor eax, eax ; eax = 0
                    mov al, [r10 + Transition.symbol] ; al = t1->symbol
                    mov [r11 + Transition.symbol], al ; combDFA->transitions[transCount]->symbol = t1->symbol

                    ;combDFA->transitions[transCount]->to = (dfa1->numStates * t1->to) + t2->to;
                    mov eax, [dfa2NumStates] ; eax = dfa1->numStates
                    imul eax, [t1TO]
                    mov ebx, eax ; ebx = dfa1->numStates * i
                    add ebx, [t2TO] ; ebx = (dfa1->numStates * i) + j
                    mov [r11 + Transition.to], ebx ; combDFA->transitions[transCount]->to = (dfa1->numStates * i) + j

                    ;transCount++
                    mov eax, [transCount]
                    inc eax
                    cmp eax, [newNumTransitions]
                    jge .failedCMP
                    mov [transCount], eax ; Trans++

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
            
            ;statesCount++;
            mov eax, [statesCount]
            inc eax
            mov [statesCount], eax ; statesCount++

            inc edx ; j++
            cmp edx, [dfa2NumStates] ; j < dfa2->numStates
            jl .loop2
        .endLoop2:

        inc ecx ; i++
        cmp ecx, [dfa1NumStates] ; i < dfa1->numStates
        jl .loop1
    .endLoop1:

    mov rax, r14 ; rax = combDfa
    mov r12, [r14 + DFA.states] ; FOR DEBUG
    mov r13, [r14 + DFA.transitions] ; FOR DEBUG

;=============================================
    pop r14
    pop r13
    pop r12
    leave ; Restore the base pointer
    ret   ; Return``