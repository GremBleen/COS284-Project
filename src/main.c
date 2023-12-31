#include <stdio.h>

extern float testDeliverable1();
extern float testDeliverable2();
extern float testDeliverable3();

int main()
{
    // char* filename = "dfa1.txt";
    // DFA *temp = readDfa(filename);

    if (testDeliverable1() < 29 || testDeliverable2() < 29)
    {
        printf("Warning: Previous Deliverables are not fully correct and might affect Deliverable 3\n");
    }

    float marks = testDeliverable3();
    printf("Total Marks %.f\n", marks);

    return 0;
}

// bool sameLanguage(DFA *dfa1 , DFA *dfa2)
// {
//     DFA* combDFA = makeDFA(dfa1,dfa2);

//     return reachesAccepting(combDFA, combDFA->startState);
// }

// bool reachesAccepting(dfa, int id)
// {
//     for(int i = 0; i < dfa->numTransitions; i++)
//     {
//         if(id == dfa->transitions[i]->from)
//         {
//             int to = dfa->transitions[i]->to;
//             if(dfa->states[to]->isAccepting)
//             {
//                 return true;
//             }
//             else
//             {
//                 return reachesAccepting(dfa, i);
//             }
//         }
//     }
// }

// combDFA* makeDFA(dfa1, dfa2)
// {
//     int newNumStates = dfa1->numStates * dfa2->numStates;
//     DFA *combDfa = malloc(sizeof(DFA));
//     combDFA->numStates = newNumStates;

//     int count = 0;
//     int transCount = 0;
//     for(int i = 0; i < dfa1->numStates; i++)
//     {
//         State* s1 = dfa1->states[i];
//         for(int j = 0; j < dfa2->numStates; j++)
//         {
//             State* s2 = dfa2->states[j];
//             combDfa->states[count]->id = count;
//             if((dfa1->states[i]->isAccepting && !dfa2->states[j]->isAccepting) || (!dfa1->states[i]->isAccepting && dfa2->states[j]->isAccepting))
//             {
//                 combDfa->states[count]->isAccepting = true;
//             }
//             else
//             {
//                 combDfa->states[count]->isAccepting = false;
//             }
//             count++;

//             for(int k = 0; k < dfa1->numTransitions; k++)
//             {
//                 Transition* t1 = dfa1->transitions[k];
//                 for(int l = 0; l < dfa2->numTransitions; l++)
//                 {
//                     Transition* t2 = dfa2->transitions[l];
//                     if(t1->from == state1->id && t2->from == state2->id)
//                     {
//                         if(t1->symbol == t2->symbol)
//                         {
//                             combDfa->transitions[transCount]->from = count;
//                             combDfa->transitions[transCount]->to = (i * dfa2->numStates) + j ;
//                             combDfa->transitions[transCount]->symbol = t1->symbol;
//                             transCount++;
//                         }
//                     }
//                 }
//             }
//         }
//     }

//     combDFA->numStates = count + 1;
//     combDFA->numTransitions = transCount + 1;
//     combDFA->startState = 0;
    
//     return combDFA;
// }