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
    
    State* currentState1 = dfa1->startState;
    State* currentState2 = dfa2->startState;

    char* input = "";

    while(true)
    {
        input += getNextTransitionSymbol(currentState1, currentState2);
        
        bool dfa1IsAccepting = simulateDfa(dfa1, input);
        bool dfa2IsAccepting = simulateDfa(dfa2, input);

        if(dfa1IsAccepting == dfa2IsAccepting)
        {
            return true;
        }
        else if(isNexttransition == null)
        {
            return false;
        }
    }

    char getNextTransitionSymbol(dfa1, dfa2)
    {

    }

;=============================================
    leave ; Restore the base pointer
    ret   ; Return