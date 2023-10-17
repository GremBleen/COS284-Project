%include "constants.inc" ; Includes the constants.inc file which contains the defn for structs
extern strlen
global  simulateDfa

section .data
    dfa:          dq 0
    inputString:  dq 0
    currentState: dq 0
    sizeOfString: dd 0

section .text
    ; bool simulateDfa(DFA *dfa , const char *inputString)

    ; Input registers:
    ; rdi = dfa
    ; rsi = inputString
    
simulateDfa:
    push rbp      ; Save the base pointer
    mov  rbp, rsp ; Set the base pointer to the stack pointer
    push r12      ; Save the callee saved registers
    push r13
    push r14
    push r15

;=============================================
    ; Structure I will implement:
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
    ;     return currentState->isAccepting;
    ; } 

    ; Storing Variables:
    mov [dfa], rdi              ; Store the dfa
    mov [inputString], rsi      ; Store the inputString
    lea rax, [dfa + DFA.states] ; Store the states array
    lea [currentState], [rax + dfa.startState] ; currentState = dfa->states[startState]
    
    lea rdi, [inputString]      ; rdi = inputString
    call strlen                 ; call strlen
    mov [sizeOfString], rax     ; sizeOfString = strlen(inputString)
    lea r15, [dfa + DFA.states] ; Store States array

    ; for(int i = 0; i < sizeOfString; i++)
    xor rcx, rcx ; i = 0
    cmp rcx, [sizeOfString] ; i < sizeOfString
    jge .endLoop1
    .loop1:
        ; char currentChar = inputString[i];
        xor eax, eax ; rax = 0
        mov al, [inputString + rcx] ; rax = currentChar
        mov [currentChar], al

        ; for(int j = 0; j < dfa->numTransitions; j++)
        xor r12, r12 ; j = 0
        cmp r12, [dfa + DFA.numTransitions] ; j < dfa->numTransitions
        jge .endLoop2
        .loop2:
            ; if(currentState->id == dfa->Transitions[j]->from && currentChar == dfa->Transitions[j]->symbol)
            lea r13, [dfa + DFA.transitions] ; Store Transitions array
            lea r14, [r13 + r12 * 8] ; Store transitions[j]
            cmp [currentState + State.id], [r14 + Transition.from] ; currentState->id == dfa->Transitions[j]->from
            jne .failTransition ; if not equal, jump to failTransition
            cmp rax, [r14 + Transition.symbol] ; currentChar == dfa->Transitions[j]->symbol
            jne .failTransition ; if not equal, jump to failTransition

            ; currentState = dfa->States[dfa->Transitions[j]->to]
            mov edx, [r14 + Transition.to] ; edx = dfa->Transitions[j]->to
            lea r15, [dfa + DFA.states] ; Store States array
            lea [currentState], [r15 + rdx * 8] ; currentState = dfa->States[dfa->Transitions[j]->to]
            jmp .endLoop2 ; break

            .failTransition:
            inc r12 ; j++
            cmp r12, [dfa + DFA.numTransitions] ; j < dfa->numTransitions
            jl .loop3
        .endLoop2:
    
        inc rcx ; i++
        cmp rcx, [sizeOfString] ; i < sizeOfString
        jl .loop1
    .endLoop1:

    mov eax, [currentState + State.isAccepting] ; return currentState->isAccepting

;=============================================
    pop r15         ; Restore the callee saved registers
    pop r14 
    pop r13
    pop r12
    leave ; Restore the base pointer
    ret   ; Return