%include "constants.inc" ; Includes the constants.inc file which contains the defn for structs
global simulateDfa
extern strlen

section .data
    sizeOfString dd 0
    currentChar db 0

section .text
    ; bool simulateDfa(DFA *dfa , const char *inputString)
    ; State* currentState = dfa->states[startState];
    ; int sizeOfString = strlen(inputString);

    ; for(int i = 0; i < sizeOfString; i++)
    ; {
    ;     char currentChar = inputString[i];
    ;     for(int j = 0; j < dfa->numTransitions; j++)
    ;     {
    ;         if(currentState->id == dfa->Transitions[j]->from && currentChar == dfa->Transitions[j]->symbol)
    ;         {
    ;             currentState = dfa->States[dfa->Transitions[j]->to];
    ;             break;
    ;         }
    ;     }
    ;    return currentState->isAccepting;
    ; } 

    ; Input registers:
    ; rdi = dfa
    ; rsi = inputString

simulateDfa:
    push rbp ; Save the base pointer
    mov rbp, rsp ; Set the base pointer to the stack pointer
    push r12
    push r13
    push r14
    xor r12, r12 ; r12 = 0
    xor r13, r13 ; r13 = 0
    xor r14, r14 ; r14 = 0
    
    sub rsp, 64

    .dfa equ 0
    .inputString equ 8
    .currentState equ 16
;=============================================
    ; r12 = dfa
    ; r13 = inputString
    ; r14 = currentState

    ; Storing variables:
    mov [rsp + .dfa], rdi
    mov [rsp + .inputString], rsi
    mov rax, [rsp + .dfa]
    mov r14, [rax + DFA.states]
    mov [rsp + .currentState], r14

    ; Check if numStates is 0 or numTransitions is 0
    mov r12, [rsp + .dfa]
    mov eax, [r12 + DFA.numStates]
    cmp eax, 0
    je returnFalse
    mov eax, [r12 + DFA.numTransitions]
    cmp eax, 0
    je returnFalse

    ; Determine length of inputString
    mov rdi, [rsp + .inputString]
    call strlen
    mov [sizeOfString], eax

    ; for(int i = 0; i < sizeOfString; i++)
    mov rax, [rsp + .dfa] ; rax = dfa
    mov r12, [rax + DFA.states] ; r12 = dfa->states

    xor ecx, ecx ; ecx = 0
    cmp ecx, [sizeOfString] ; i < sizeOfString
    jge endLoop1
    
    loop1:
        ; char currentChar = inputString[i];
        xor eax, eax ; eax = 0
        mov r13, [rsp + simulateDfa.inputString] ; r13 = inputString
        mov al, [r13 + rcx] ; al = inputString[i]
        mov [currentChar], al ; currentChar = inputString[i]

        ; for(int j = 0; j < dfa->numTransitions; j++)
        xor ebx, ebx ; ebx = 0
        mov r12, [rsp + simulateDfa.dfa] ; r12 = dfa
        cmp ebx, [r12 + DFA.numTransitions] ; j < dfa->numTransitions
        jge endLoop2

        loop2:
            ; if(currentState->id == dfa->Transitions[j]->from && currentChar == dfa->Transitions[j]->symbol)
            mov rax, [rsp + simulateDfa.dfa]
            mov r12, [rax + DFA.transitions] ; r12 = dfa->transitions

            xor edx, edx ; edx = 0
            imul edx, ebx, Transition_size ; edx = j * sizeof(Transition)
            lea r8, [r12 + rdx] ; r8 = dfa->transitions[j]

            mov edx, [r8 + Transition.from] ; edx = dfa->transitions[j]->from
            mov r14, [rsp + simulateDfa.currentState] ; r13 = currentState
            mov eax, [r14 + State.id] ; eax = currentState->id
            cmp eax, edx ; currentState->id == dfa->transitions[j]->from
            jne .failTransition
            
            xor eax, eax ; eax = 0
            mov al, [r8 + Transition.symbol] ; dl = dfa->transitions[j]->symbol
            cmp al, [currentChar] ; currentChar == dfa->transitions[j]->symbol
            jne .failTransition

            ; currentState = dfa->States[dfa->Transitions[j]->to];
            mov rax, [rsp + simulateDfa.dfa]
            mov r12, [rax + DFA.states] ; r12 = dfa->states
            mov edx, [r8 + Transition.to] ; edx = dfa->transitions[j]->to
            lea r14, [r12 + rdx * State_size] ; rax = dfa->states[dfa->transitions[j]->to]
            mov [rsp + simulateDfa.currentState], r14 ; currentState = dfa->states[dfa->transitions[j]->to]
            jmp endLoop2 ; break

            .failTransition:
            inc ebx ; j++
            mov r12, [rsp + simulateDfa.dfa]
            cmp ebx, [r12 + DFA.numTransitions] ; j < dfa->numTransitions
            jl loop2
        endLoop2:

        inc ecx ; i++
        cmp ecx, [sizeOfString] ; i < sizeOfString
        jl loop1
    endLoop1:
    jmp return
    
    returnFalse:
        xor eax, eax ; return 0
        jmp endSimulateDfa

    return:
        mov r14, [rsp + simulateDfa.currentState]
        mov eax, [r14 + State.isAccepting] ; return currentState->isAccepting

    endSimulateDfa:
    
;=============================================
    pop r15 ; Restore the callee saved registers
    pop r14
    pop r13
    pop r12
    leave ; Restore the base pointer
    ret ; Return