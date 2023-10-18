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

struct combState
{
    int state1;
    int state2;
    bool isAccepting;
}

struct combDfa
{
    combState* states;
    Transition* transitionsDFA1;
    Transition* transitionsDFA2;
    int numStates;
    int numTransitionsDFA1;
    int numTransitionsDFA2;
    int startState;
}

bool sameLanguage(DFA *dfa1 , DFA *dfa2)
{
    combDFA* = makeDFA(dfa1,dfa2);


}

combDFA* makeDFA(dfa1, dfa2)
{
    int newNumStates = dfa1->numStates * dfa2->numStates;
    DFA *combDfa = malloc(sizeof(DFA));
    combDFA->numStates = newNumStates;

    int count = 0;
    for(int i = 0; i < dfa1->numStates; i++)
    {
        for(int j = 0; j < dfa2->numStates; j++)
        {
            combDfa->states[count]->id = count;
            if((dfa1->states[i]->isAccepting && !dfa2->states[j]->isAccepting) || (!dfa1->states[i]->isAccepting && dfa2->states[j]->isAccepting))
            {
                combDfa->states[count]->isAccepting = true;
            }
            else
            {
                combDfa->states[count]->isAccepting = false;
            }
            count++;

            for(int i = 0; i < dfa1->numTransitions; i++)
            {
                Transition* t1 = dfa1->transitions[i];
                for(int j = 0; j < dfa2->numTransitions; i++)
                {
                    Transition* t2 = dfa2->transitions[j];
                    if()
                }
            }
        }
    }

    return combDFA;
}

;=============================================
    leave ; Restore the base pointer
    ret   ; Return``