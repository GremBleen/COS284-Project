%include "constants.inc" ; Includes the constants.inc file which contains the defn for structs
global  sameLanguage

section .data

section .text
    ; bool sameLanguage(DFA *dfa1 , DFA *dfa2)

    ; Input registers:
    ; rdi = dfa1
    ; rsi = dfa2
    
sameLanguage:
    push rbp      ; Save the base pointer
    mov  rbp, rsp ; Set the base pointer to the stack pointer

;=============================================
; Code we will implement:
    ; char* getAlphabet(dfa){
    ;     char* input = new char*[1];
    ;     int size = 1;

    ;     for(int i =0; i < dfa->numTransitions; i++)
    ;     {
    ;         char symbol = dfa->transitions[i]->symbol;

    ;         for(int j = 0; j < size; j++)
    ;         {
    ;             if(symbol == input[j])
    ;             {
    ;                 break;
    ;             }
    ;             else if(j == size - 1)
    ;             {
    ;                 char* new = new char*[size + 1];
    ;                 for(int k = 0; k < size; k++)
    ;                 {
    ;                     new[k] = input[k];
    ;                 }
    ;                 new[size] = symbol;
    ;                 delete input;
    ;                 input = new;
    ;                 size++;
    ;                 break;
    ;             }
    ;         }
    ;     }
    ;     return input;
    ; }



;=============================================
    leave ; Restore the base pointer
    ret   ; Return``