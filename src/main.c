#include <stdio.h>

extern float testDeliverable1();
extern float testDeliverable2();
extern float testDeliverable3();

// for testing purposes:
#include "dfa.h"
extern DFA *readDfa(const char *filename);

int main()
{
    char* filename = "dfa1.txt";
    DFA *temp = readDfa(filename);

    // if (testDeliverable1() < 29 || testDeliverable2() < 29)
    // {
    //     printf("Warning: Previous Deliverables are not fully correct and might affect Deliverable 3\n");
    // }

    // float marks = testDeliverable3();
    // printf("Total Marks %.f\n", marks);

    return 0;
}