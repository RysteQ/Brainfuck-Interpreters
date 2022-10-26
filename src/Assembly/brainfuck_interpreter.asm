global _start

section .text

_start:
    pop rax
    cmp rax, 2
    jne _no_input_file

    ; get the filename
    pop rdi
    pop rdi
    call _read_file_rdi_to_rsi

    ; run the program
    call _brainfuck_interpreter_rsi

    ; exit
    call _exit

_brainfuck_interpreter_rsi:
    ; prepare the memory register
    mov rdi, memory_buffer

    _brainfuck_interpreter_rsi_loop:
        mov ah, byte [rsi]

        ; find the corresponding action
        cmp ah, byte INCREMENT_MEMORY_CELL
        je _brainfuck_interpreter_rsi_increment_memory_cell
        cmp ah, byte DECREMENT_MEMORY_CELL
        je _brainfuck_interpreter_rsi_decrement_memory_cell
        cmp ah, byte NEXT_MEMORY_CELL
        je _brainfuck_interpreter_rsi_next_memory_cell
        cmp ah, byte PREVIOUS_MEMORY_CELL
        je _brainfuck_interpreter_rsi_previous_memory_cell
        cmp ah, byte PRINT_MEMORY_CELL
        je _brainfuck_interpreter_rsi_print_memory_cell
        cmp ah, byte READ_TO_MEMORY_CELL
        je _brainfuck_interpreter_rsi_read_to_memory_cell
        cmp ah, byte OPEN_BRACKET
        je _brainfuck_interpreter_rsi_opening_bracket
        cmp ah, byte CLOSE_BRACKET
        je _brainfuck_interpreter_rsi_closing_bracket

        ; check if the end of the file was reached
        cmp ah, byte NULL_TERMINATOR
        je _exit

        jmp _brainfuck_interpreter_rsi_next_instruction

    _brainfuck_interpreter_rsi_increment_memory_cell:
        mov ah, byte [rdi]
        inc ah
        mov [rdi], byte ah

        jmp _brainfuck_interpreter_rsi_next_instruction

    _brainfuck_interpreter_rsi_decrement_memory_cell:
        mov ah, byte [rdi]
        dec ah
        mov [rdi], byte ah

        jmp _brainfuck_interpreter_rsi_next_instruction

    _brainfuck_interpreter_rsi_next_memory_cell:
        inc rdi

        jmp _brainfuck_interpreter_rsi_next_instruction

    _brainfuck_interpreter_rsi_previous_memory_cell:
        dec rdi

        jmp _brainfuck_interpreter_rsi_next_instruction

    _brainfuck_interpreter_rsi_print_memory_cell:
        push rdi
        push rsi

        mov rax, 1
        mov rsi, rdi
        mov rdi, 1
        mov rdx, 1
        syscall

        pop rsi
        pop rdi

        jmp _brainfuck_interpreter_rsi_next_instruction

    _brainfuck_interpreter_rsi_read_to_memory_cell:
        push rdi
        push rsi

        xor rax, rax
        mov rdi, 1
        mov rsi, input_buffer
        mov rdx, 1
        syscall

        pop rsi
        pop rdi

        mov ah, byte [input_buffer]
        mov [rdi], byte ah

        jmp _brainfuck_interpreter_rsi_next_instruction

    _brainfuck_interpreter_rsi_opening_bracket:
        push rax
        mov ah, byte [rdi]
        
        cmp ah, byte 0
        je _brainfuck_interpreter_rsi_opening_bracket_loop
        pop rax
        jmp _brainfuck_interpreter_rsi_next_instruction
        
        _brainfuck_interpreter_rsi_opening_bracket_loop:
            inc rsi
            mov ah, byte [rsi]

            ; find the closing bracket, if it is not found (aka it finds the NULL TERMINATOR) then exit the program
            cmp ah, byte OPEN_BRACKET
            je _brainfuck_interpreter_rsi_opening_bracket_loop_open_bracket
            cmp ah, byte CLOSE_BRACKET
            je _brainfuck_interpreter_rsi_opening_bracket_loop_close_bracket
            cmp ah, byte NULL_TERMINATOR
            je _exit
            jmp _brainfuck_interpreter_rsi_opening_bracket_loop

            _brainfuck_interpreter_rsi_opening_bracket_loop_open_bracket:
                ; increment the opening brackets
                push rdi
                mov rdi, [opening_brackets]
                inc rdi
                mov [opening_brackets], rdi
                pop rdi

                jmp _brainfuck_interpreter_rsi_opening_bracket_loop

            _brainfuck_interpreter_rsi_opening_bracket_loop_close_bracket:
                ; check if the closing bracket was found
                mov ah, byte [opening_brackets]
                cmp ah, 0
                je _brainfuck_interpreter_rsi_next_instruction

                ; if it wasn't found then decrement the opening brackets
                push rdi
                mov rdi, [opening_brackets]
                dec rdi
                mov [opening_brackets], rdi
                pop rdi

                jmp _brainfuck_interpreter_rsi_opening_bracket_loop

    _brainfuck_interpreter_rsi_closing_bracket:
        push rax
        mov ah, byte [rdi]

        ; check if the rax is zero, if it isnt then find the corresponding opening bracket
        cmp ah, byte 0
        jne _brainfuck_interpreter_rsi_closing_bracket_loop

        ; if it is then go to the next instruction
        pop rax
        jmp _brainfuck_interpreter_rsi_next_instruction

        _brainfuck_interpreter_rsi_closing_bracket_loop:
            dec rsi
            mov ah, byte [rsi]

            cmp ah, byte CLOSE_BRACKET
            je _brainfuck_interpreter_rsi_closing_bracket_loop_close_bracket
            cmp ah, byte OPEN_BRACKET
            je _brainfuck_interpreter_rsi_closing_bracket_loop_open_bracket
            cmp ah, byte NULL_TERMINATOR
            je _exit
            jmp _brainfuck_interpreter_rsi_closing_bracket_loop

            _brainfuck_interpreter_rsi_closing_bracket_loop_close_bracket:
                ; increment the closing brackets value
                push rdi
                mov rdi, [closing_brackets]
                inc rdi
                mov [closing_brackets], rdi
                pop rdi

                jmp _brainfuck_interpreter_rsi_closing_bracket_loop

            _brainfuck_interpreter_rsi_closing_bracket_loop_open_bracket:
                mov ah, byte [closing_brackets]
                cmp ah, byte 0
                je _brainfuck_interpreter_rsi_next_instruction

                ; decrement the closing brackets value
                push rdi
                mov rdi, [closing_brackets]
                dec rdi
                mov [closing_brackets], rdi
                pop rdi
                
                jmp _brainfuck_interpreter_rsi_closing_bracket_loop

    _brainfuck_interpreter_rsi_next_instruction:
        inc rsi
        jmp _brainfuck_interpreter_rsi_loop

    ret

_print_rsi:
    ; save the values of some registers to the stacl
    push rax
    push rdi
    push rdx
    push rsi
    
    ; prepare some registers
    xor rdx, rdx

    _print_rsi_count_chars_loop:
        inc rdx

        ; check if the end of the string was reached
        mov rax, [rsi]
        cmp rax, NULL_TERMINATOR
        je _print_rsi_print_string

        ; go to the next character
        inc rsi

        jmp _print_rsi_count_chars_loop

    _print_rsi_print_string:
        ; print the string
        mov rax, 1
        mov rdi, 1
        pop rsi
        syscall

    _print_rsi_exit:
        ; get the previously saved values from the stack
        pop rdx
        pop rdi
        pop rax

        ; return
        ret

_read_file_rdi_to_rsi:
    ; open the file
    mov rax, 2
    mov rsi, 0
    mov rdx, 0444o
    syscall

    ; read the file contents
    push rax
    mov rdi, rax
    xor rax, rax
    mov rsi, file_data_buffer
    mov rdx, file_data_buffer_size
    syscall

    ; close the file
    mov rax, 3
    pop rdi
    syscall

    ; return
    ret

_no_input_file:
    mov rsi, no_input_file_error_message
    call _print_rsi
    call _exit

_exit:
    ; exit
    mov rax, 60
    xor rdi, rdi
    syscall

section .data
no_input_file_error_message: db "No input file detected", NEW_LINE, NULL_TERMINATOR
file_data_buffer: times 100000 db 0
file_data_buffer_size equ $- file_data_buffer

memory_buffer: times 30000 db 0
input_buffer: db 0
opening_brackets: dw 0
closing_brackets: dw 0

NEXT_MEMORY_CELL equ '>'
PREVIOUS_MEMORY_CELL equ '<'
INCREMENT_MEMORY_CELL equ '+'
DECREMENT_MEMORY_CELL equ '-'
PRINT_MEMORY_CELL equ '.'
READ_TO_MEMORY_CELL equ ','
OPEN_BRACKET equ '['
CLOSE_BRACKET equ ']'

NEW_LINE equ 10
NULL_TERMINATOR equ 0