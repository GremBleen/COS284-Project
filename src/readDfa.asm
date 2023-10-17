%include "constants.inc" ; Includes the constants.inc file which contains the defn for structs
global  readDfa

section .data
    fd: dd 0
    fsize: dd 0

section .text

getNextNumber:
    ; INPUT:
    ; rdi = 

readDfa:
    ; DFA* readDfa(const char *filename)

    ;Input registers:
    ; rdi = filename

    extern open, lseek, malloc, free, read, close
    push rbp      ; Save the base pointer
    mov  rbp, rsp ; Set the base pointer to the stack pointer
    sub rsp, 64

    r12_data equ 0
    states equ 8
    transitions equ 16
    numStates equ 20
    numTransitions equ 24
    startState equ 28
    filedata equ 32
    temp equ 40
    r13_data equ 48

    ; saving the value stored in r12
    mov [rsp + r12_data], r12
    mov [rsp + r13_data], r13
    xor r12, r12

;=============================================

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
        xor rbx, rbx ; rbx -> row counter

        while:
            cmp rcx, rsi
            jge _endwhile
            ; mov al, [rdi+rcx] ; essentially getting the the ith bit of the file
            ; TODO: populate and create dfa using the data in here

            mov r8, rbx
            cmp r8, 0
            je l1

            dec r8
            cmp r8, 0
            je l2

            dec r8
            cmp r8, 0
            je l3

            jmp ln

            ; case l1 is for the first line (Number of states and Number of transitions)
            l1:
                ; This loop is used to dertermine how many characters makes up the number of states
                xor r8, r8 ; clearing r8
                mov r8, rcx ; setting r8 to rcx
  
                l1_loop_1:
                    mov al, [rdi+r8]
                    cmp al, ','
                    je l1_loop_1_end
                    cmp al, '0'
                    jl file_error
                    cmp al, '9'
                    jg file_error
                    inc r8
                    jmp l1_loop_1
                l1_loop_1_end:

                cmp r8, rcx

                je file_error

                ; moving the value of rcx into a callee saved register
                mov r12, rcx

                ; moving the value of r8 into a callee saved register
                mov r13, r8

                ; calling malloc
                mov rdi, r8
                ; Allocating memory for each byte
                call malloc
                mov [rsp+temp], rax

                mov rdi, [rsp + filedata] ; resetting rdi to hold the file
                mov rcx, r12 ; loading the value stored in r12 back into rcx

                ; loop through it until ',' again, adding each digit to the array
                
                xor r9, r9 ; Setting r9 to 0
                
                l1_loop_2:
                    mov al, [rdi + rcx]
                    cmp al, ','
                    je l1_loop_2_end
                    mov r10, [rsp + temp]
                    mov byte[r10 + r9], al
                    inc r9
                    inc rcx
                    jmp l1_loop_2
                l1_loop_2_end:
                
                ; increment rcx to get past comma
                inc rcx

                ; loop through each of the digits, subtracting '0', multiply each by 10^n and add
                xor r8, r8 ; clear r8
                dec r13 ; decrement r13 so that it aligns with indices
                xor r11, r11 ; clearing r11 -> counter
                xor r9, r9
                mov r9, [rsp + temp]

                xor rax, rax ; clear rax - will be used as accumulator
                
                l1_loop_3:
                    cmp r13, 0
                    jl l1_loop_3_end
                    mov r8b, byte[r9 + r13]
                    sub r8, '0'
                    mov r10, 0
                    l1_loop_3_1:
                        cmp r10, r11
                        jge l1_loop_3_1_end
                        imul r8, 10
                        inc r10
                        jmp l1_loop_3_1
                    l1_loop_3_1_end:
                    add rax, r8 ; add r8 to rax
                    inc r11
                    dec r13
                    jmp l1_loop_3
                l1_loop_3_end:

                mov [rsp + numStates], rax

                ; free the memory allocated
                mov rdi, [rsp+temp]
                call free

                inc rbx ; increment row
                jmp end_switch

            ; case l2 is for the second line (States)
            l2:
                ; loop for line 2 while rcx != '\n'

                inc rbx ; increment row
                jmp end_switch
            
            ; case l3 is for the third line (Accepting states)
            l3:
                ; loop for line 3 while rcx != '\n'

                inc rbx ; increment row
                jmp end_switch

            ; case ln is for the nth line (Transitions)
            ln:
                ; loop for line n while rcx != '\n'

                inc rbx ; increment row

            end_switch:
            
            jmp while

        _endwhile:

        ; closing the file
        mov edi, [fd]
        call close
        jmp end

    file_error:
        mov edi, [fd]
        call close
        
        mov rax, 0

        jmp end

    file_not_found:
        mov rax, 0 ; set the return to 0 -> null

;=============================================

    end:
    mov r12, [rsp + r12_data]
    mov r13, [rsp + r13_data]
    leave ; Restore the base pointer
    ret   ; Return