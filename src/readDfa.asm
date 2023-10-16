%include "constants.inc" ; Includes the constants.inc file which contains the defn for structs
global  readDfa

section .data
    fd: dd 0
    fsize: dd 0

section .text
readDfa:
    ; DFA* readDfa(const char *filename)

    ;Input registers:
    ; rdi = filename
    ; rsi = dfa

    extern open, lseek, malloc, read, close
    push rbp      ; Save the base pointer
    mov  rbp, rsp ; Set the base pointer to the stack pointer
    sub rsp, 48

    r12_data equ 0
    states equ 8
    transitions equ 16
    numStates equ 20
    numTransitions equ 24
    startState equ 28
    filedata equ 32

    ; saving the value stored in r12
    mov [rsp+r12_data], r12
    xor r12, r12

    ; storing the filename in r12 (callee saved register)
    mov r12, rdi

; So here is my idea:
; 1. Check if the file can be openned
;   true:
;       2. Read the first line (states and transitions) assign these to registers
;       3. Iterate through the second line while < states
;       4. Go through third line and assign accepting states (may be more than 1)
;       5. Loop while less than the transitions in the first line, adding them to the dfa
;       6. Set the start state as 0
;   false:
;     return NULL

    ; call the open function with read permission
    mov rsi, 0 ; set the flag to 0 - read permission
    call open ; call open function

    ; compare result to 0, if less than, jump to end of function
    cmp eax, 0
    jl file_not_found

    file_found:
        mov [fd], eax

        ; calling lseek (to get the amount of characters in file that need to be iterated through)
        ; long lseek(int fd, long offset, int whence)
        mov rdi, [fd] ; moving file descriptor into rdi
        xor esi, esi ; setting offset to 0
        mov edx, 2 ; setting whence to 2 -> offset relative to end of file
        call lseek

        mov [fsize], rax ; saving the file size

        ; calling malloc to allocate memory to all characters in file
        ; void *malloc(size_t size)
        mov rdi, rax ;
        call malloc

        ; storing the memory allocated onto the stack
        mov [rsp+filedata], rax

        ; calling lseek to set to point to beginning of file
        ; long lseek(int fd, long offset, int whence)
        mov edi, [fd]
        xor esi, esi ; setting offset to 0
        xor edx, edx ; setting whence to 0 -> offset relative to start of file
        call lseek

        ; calling read
        ; int read(int fd, void *data, long count)
        ; NOTE: To access the contents of the file after read is called, use [rsp+filedata]
        mov edi, [fd]
        mov rax, [rsp+filedata]
        mov rsi, rax
        mov rdx, [fsize]
        call read

        ; resetting lseek to poin to beginning of file
        mov edi, [fd]
        xor esi, esi ; setting offset to 0
        xor edx, edx ; setting whence to 0 -> offset relative to start of file
        call lseek

        ; preparing for looping through the file
        xor rcx, rcx ; rcx -> counter
        mov rsi, [fsize] ; rsi -> bitsize of file
        mov rdi, [rsp+filedata] ; rdi -> pointer to the first bit in the file

        while:
            cmp rcx, rsi
            jge _endwhile
            mov al, [rdi+rcx] ; essentially getting the the ith bit of the file
            ; TODO: populate and create dfa using the data in here
            inc rcx
            jmp while

        _endwhile:
        

        ; Getting the first line (states and transitions)



        ; Getting the second line (ID's of states)


        ; Getting the third line (accepting states)


        ; Loop through the next lines and populate transitions

        ; closing the file
        mov edi, [fd]
        call close
        jmp end

    file_not_found:
        mov rax, 0 ; set the return to 0 -> null

    end:

    mov r12, [rsp+r12_data]
    leave ; Restore the base pointer
    ret   ; Return