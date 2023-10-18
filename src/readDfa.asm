%include "constants.inc" ; Includes the constants.inc file which contains the defn for structs
global  readDfa

section .data
    fd: dd 0
    fsize: dd 0

section .text

getNextNumber:
    ; INPUT:
    ; rdi = rdi
    ; rsi = rsi
    ; rdx = [rsp + filedata]
    ; rbx = rbx
    ; rcx = rcx

    extern malloc, free

    push rbp      ; Save the base pointer
    mov  rbp, rsp ; Set the base pointer to the stack pointer
    sub rsp, 64

    temp equ 0
    rdi_backup equ 8
    rsi_backup equ 16
    rbx_backup equ 24
    rcx_backup equ 32
    rax_backup equ 40
    r12_backup equ 48
    r13_backup equ 56

    mov [rsp + r12_backup], r12
    mov [rsp + r13_backup], r13

    ; This loop is used to dertermine how many characters makes up the number of states
    xor r8, r8 ; clearing r8
    mov r8, rcx ; setting r8 to rcx

    l1_loop_1:
        mov al, [rdi + r8]
        cmp al, ','
        je l1_loop_1_end
        cmp al, 10 ; '\n'
        je l1_loop_1_end
        cmp al, '0'
        jge end_if_gNN_1 
        if_gNN_1:
            cmp r15, 0
            je file_error
            jmp file_error_delete
        end_if_gNN_1:
        cmp al, '9'
        jle end_if_gNN_2
        if_gNN_2:
            cmp r15, 0
            je file_error
            jmp file_error_delete
        end_if_gNN_2:
        inc r8
        jmp l1_loop_1
    l1_loop_1_end:

    cmp r8, rcx
    jne end_if_gNN_3

    if_gNN_3:
        cmp r15, 0
        je file_error
        jmp file_error_delete
    end_if_gNN_3:

    ; saving values before function call
    mov [rsp + rdi_backup], rdi
    mov [rsp + rsi_backup], rsi
    mov [rsp + rbx_backup], rbx
    mov [rsp + rcx_backup], rcx

    ; moving the value of r8 into a callee saved register
    mov r13, r8
    sub r13, rcx

    ; calling malloc
    mov rdi, r13
    ; Allocating memory for each byte
    call malloc
    mov [rsp + temp], rax

    ; restoring values from stack
    mov rdi, [rsp + rdi_backup]
    mov rsi, [rsp + rsi_backup]
    mov rbx, [rsp + rbx_backup]
    mov rcx, [rsp + rcx_backup]

    ; loop through it until ',' again, adding each digit to the array
    
    xor r9, r9 ; Setting r9 to 0
    
    l1_loop_2:
        mov al, [rdi + rcx]
        cmp al, ','
        je l1_loop_2_end
        cmp al, 10 ; '\n'
        je l1_loop_2_end
        mov r10, [rsp + temp]
        mov byte[r10 + r9], al
        inc r9
        inc rcx
        jmp l1_loop_2
    l1_loop_2_end:

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
    
    ; saving values to stack
    mov [rsp + rdi_backup], rdi
    mov [rsp + rsi_backup], rsi
    mov [rsp + rbx_backup], rbx
    mov [rsp + rcx_backup], rcx
    mov [rsp + rax_backup], rax

    ; freeing temp
    mov rdi, [rsp + temp]
    call free

    ; restoring values from stack
    mov rdi, [rsp + rdi_backup]
    mov rsi, [rsp + rsi_backup]
    mov rbx, [rsp + rbx_backup]
    mov rcx, [rsp + rcx_backup]
    mov rax, [rsp + rax_backup]
    mov r12, [rsp + r12_backup]
    mov r13, [rsp + r13_backup]

    leave
    ret

readDfa:
    ; DFA* readDfa(const char *filename)

    ;Input registers:
    ; rdi = filename

    extern open, lseek, read, close, initDfa
    push rbp      ; Save the base pointer
    mov  rbp, rsp ; Set the base pointer to the stack pointer
    sub rsp, 96

    r12_data equ 0
    numStates equ 8
    numTransitions equ 12
    filedata equ 16
    r13_data equ 24
    rcx_backup1 equ 32
    rsi_backup1 equ 48
    rdi_backup1 equ 56
    dfa equ 64
    r15_data equ 72
    r14_data equ 80

    ; saving the value stored in r12
    mov [rsp + r12_data], r12
    mov [rsp + r13_data], r13
    mov [rsp + r15_data], r15
    mov [rsp + r14_data], r14
    xor r12, r12
    xor r15, r15

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

            cmp rbx, 0
            je l1

            cmp rbx, 1
            je l2

            cmp rbx, 2
            je l3

            jmp ln

            ; case l1 is for the first line (Number of states and Number of transitions)
            l1:

                mov rdx, [rsp + filedata]
                call getNextNumber
                mov [rsp + numStates], eax
                mov al, byte[rdi + rcx]
                cmp al, 10 ; '\n'
                je file_error
                inc rcx ; increment rcx to get past ',' or '\n'
                
                mov rdx, [rsp + filedata]
                call getNextNumber
                mov [rsp + numTransitions], eax
                mov al, byte[rdi + rcx]
                cmp al, ','
                je file_error
                inc rcx

                mov [rsp + rcx_backup1], rcx
                mov [rsp + rsi_backup1], rsi
                mov [rsp + rdi_backup1], rdi

                xor rdi, rdi
                xor rsi, rsi

                mov edi, [rsp + numStates]
                mov esi, [rsp + numTransitions]
                call initDfa
                mov [rsp + dfa], rax

                inc r15 ; setting r15 to 1 indicating that if the process is aborted, need to delete dfa
                
                ; resetting values
                mov rcx, [rsp + rcx_backup1]
                mov rsi, [rsp + rsi_backup1]
                mov rdi, [rsp + rdi_backup1]

                inc rbx ; increment row
                jmp end_switch

            ; case l2 is for the second line (States)
            l2:
                xor r12, r12
                xor r13, r13
                xor rax, rax
                mov eax, [rsp + numStates]
                mov r13, rax
                cmp r12, r13
                jg file_error_delete

                l2_loop_1:
                    cmp r12, r13
                    je l2_loop_1_end
                    mov rdx, [rsp + filedata]
                    call getNextNumber

                    mov r8, [rsp + dfa]
                    mov r9, [r8 + DFA.states]
                    xor r10, r10
                    imul r10, r12, State_size
                    mov [r9 + r10 + State.id], eax

                    inc r12
                    mov al, byte[rdi + rcx]
                    cmp al, 10 ; '\n'
                    jne end_if_1
                    if_1:
                        cmp r12, r13
                        jne file_error_delete
                        jmp l2_loop_1
                    end_if_1:
                    inc rcx ; NOTE: Possible issue where ',\n' does not error
                    jmp l2_loop_1
                l2_loop_1_end:

                mov al, byte[rdi + rcx]
                cmp al, 10 ; '\n'
                jne file_error_delete

                inc rcx

                inc rbx ; increment row
                jmp end_switch
            
            ; case l3 is for the third line (Accepting states)
            l3:
                
                ; loop through until '\n'
                
                xor r12, r12
                xor r13, r13

                mov rdx, [rsp + filedata]
                mov r8, rcx
                xor r9, r9

                l3_loop_1:
                    mov al, [rdi + r8]
                    cmp al, ','
                    jne end_if_2
                    if_2:
                        cmp r9b, ','
                        je file_error_delete
                        inc r12
                        inc r8
                        mov r9b, al
                        jmp l3_loop_1
                    end_if_2
                    cmp al, 10 ; '\n'
                    jne end_if_3
                    if_3:
                        cmp r9b, ','
                        je file_error_delete
                        inc r12
                        inc r8
                        mov r9b, al
                        jmp l3_loop_1_end
                    end_if_3:
                    cmp al, '0'
                    jl file_error_delete
                    cmp al, '9'
                    jg file_error_delete
                    inc r8
                    mov r9b, al 
                    jmp l3_loop_1
                l3_loop_1_end:

                cmp r12, 0
                je file_error_delete

                xor r14, r14

                l3_loop_2:
                    cmp r13, r12
                    jge l3_loop_2_end

                    mov rdx, [rsp + filedata]
                    call getNextNumber

                    mov r8, [rsp + dfa]
                    mov r9, [r8 + DFA.states]
                    xor r10, r10
                    xor r11, r11 ; counter
                    
                    l3_loop_2_1:
                        cmp r11, [rsp + numStates]
                        jge file_error_delete ; if the state was not found in dfa, jump to error

                        imul r10, r11, State_size

                        mov r14, [r9 + r10 + State.id]
                        cmp rax, r14
                        jne end_found

                        found:
                            mov r14, 1
                            mov [r9 + r10 + State.isAccepting], r14
                            jmp l3_loop_2_1_end
                        end_found:

                        inc r11
                    l3_loop_2_1_end:

                    mov al, [rdi + rcx]
                    cmp al, ','
                    jne end_if_4
                    if_4:
                        inc rcx
                    end_if_4:
                    inc r13
                    jmp l3_loop_2
                l3_loop_2_end:

                mov al, byte[rdi + rcx]
                cmp al, 10 ; '\n'
                jne file_error_delete

                inc rbx ; increment row
                jmp end_switch

            ; case ln is for the nth line (Transitions)
            ln:
                ; TODO:
                ; loop for however many transitions were specified
                    ; Set the corresponding Transition member variables
                ; check if at end of file
                    ; if not, throw error
                

                inc rbx ; increment row

            end_switch:
            
            jmp while

        _endwhile:

        ; cleanup - free all malloc'd data

        mov rdi, [rsp + filedata]
        call free

        ; closing the file
        mov edi, [fd]
        call close
        jmp end

    file_error_delete:
        mov rdi, [rsp + dfa]
        call free

    file_error:
        mov rdi, [rsp + filedata]
        call free

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
    mov r15, [rsp + r15_data]
    mov r14, [rsp + r14_data]
    leave ; Restore the base pointer
    ret   ; Return