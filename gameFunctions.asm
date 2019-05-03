section .data
    x: db "X", 0
    o: db "O", 0
    bar: db "|"
    newLine: db 10
    strX: db "Vez do jogador X", 0xA, 0x0
	strO: db "Vez do jogador O", 0xA, 0x0
    err2: db "Posicao digitada invalida", 0xA, 0x0
    str2: db "Digite a posicao que deseja jogar: ", 0x0
    turn: db 1
    plays: db 0
    pc_active: db 0
    clean: times 50 db 0xa

section .text
    read_number:        ; > rax
        push r13
        mov r13, rsp
        sub rsp, 1
        dec r13

        mov rax, 0
        mov rdi, 0
        mov rsi, r13
        mov rdx, 2
        syscall

        mov al, byte[r13]
        sub al, 0x30
        add rsp, 1
        pop r13
        ret
    
    strlen:             ;rdi = *str
        xor rax, rax
        .loop:
            inc rax
            cmp byte[rdi + rax], 0
            jne .loop
        .end:
        ret
    clean_scream:
        mov rax, 1
        mov rdi, 1
        mov rsi, clean
        mov rdx, 50
        syscall
        ret

    print_char:         ;rdi = *char
        mov rax, 1
        mov rsi, rdi
        mov rdi, 1
        mov rdx, 1
        syscall
        ret
    
    print_string:       ;rdi = *string
        call strlen
        mov rdx, rax
        mov rsi, rdi
        mov rax, 1
        mov rdi, 1
        syscall
        ret

    print_number:
        push r11
        mov rdi, rsp
        sub rsp, 2
        dec rdi
        mov rax, r12
        add rax, 0x30
        mov byte[rdi], 0
        dec rdi
        mov byte[rdi], al

        call print_char

        add rsp, 2
        pop r11
        ret

    print_tab:          ; rdi = *tab
        mov r11, rdi    ; r11 salva o ponteiro
        mov r12, 1
        mov r10, 1      ; r10 serve como contador do laço

        .loop:          ; r10 < 10

            cmp byte[r11 + r10 - 1], 1
            jne .not_x
            call print_x

        .not_x:

            cmp byte[r11 + r10 - 1], -1
            jne .not_o
            call print_o
        
        .not_o:

            cmp byte[r11 + r10 - 1], 0
            jne .not_nothing
            call print_number

        .not_nothing:
            xor rdx, rdx
            mov rax, r10
            mov rbx, 3
            div rbx
            cmp rdx, 0
            je .not_printBar
            call print_bar
        .not_printBar:
            xor rdx, rdx
            mov rax, r10
            mov rbx, 3
            div rbx
            cmp rdx, 0
            jne .not_newline
            call print_newline
        .not_newline:

            inc r10
            inc r12
            cmp r10, 10
            jl .loop
        
        end_loop:

        ret

    print_x:
        push r11
        mov rdi, x
        call print_char
        pop r11
        ret
    print_o:
        push r11
        mov rdi, o
        call print_char
        pop r11
        ret
    print_bar:
        push r11
        mov rdi, bar
        call print_char
        pop r11
        ret
    print_newline:
        push r11
        mov rdi, newLine
        call print_char
        pop r11
        ret
    show_turn:
        .x_vef:
            cmp byte[turn], 1
            jne .o_vef
            mov rdi, strX
            call print_string
            ret
        .o_vef:
            cmp byte[turn], 2
            jne .end
            mov rdi, strO
            call print_string
        .end:
            ret
    check_valid_position:   ;rdi = position
        xor rax, rax
        cmp dil, 1
        jl .invalid

        cmp dil, 9
        jg .invalid

        ret
        .invalid:
            mov rax, 1
            ret

    play:                   ;rdi = tab; > rax
        cmp byte[pc_active], 1
        jne .not_pc
        cmp byte[turn], 2
        jne .not_pc
        jmp play_pc

        .not_pc:
        push r15
        push r14
        mov r15, rdi
        mov rdi, str2
        call print_string
        call read_number
        mov r14, rax
        mov rdi, rax
        call check_valid_position
        cmp rax, 0
        jne .invalid
        cmp byte[r15 + r14 - 1], 0
        jne .invalid
        
        jmp .valid
        .invalid:
            call clean_scream
            mov rdi, err2
            call print_string
            mov rdi, r15
            call print_tab
            mov rdi, r15
            pop r14
            pop r15
            jmp play

        .valid:
           cmp byte[turn], 1
           je .play_x
           jmp .play_o
        .play_x:
            mov byte[r15 + r14 - 1], 1
            mov byte[turn], 2
            inc byte[plays]
            jmp .ret
        .play_o:
            mov byte[r15 + r14 - 1], -1
            mov byte[turn], 1
            inc byte[plays]
            jmp .ret
        .ret:
            pop r14
            pop r15
            ret

    play_pc:
        push r14
        mov r14, rdi
        .repeat:
            call gerate_9rand
            cmp byte[r14 + rax], 0
            jne .repeat
            mov byte[r14 + rax], -1
            mov byte[turn], 1
            inc byte[plays]
            pop r14
            ret

    check_is_velha:         ; > .rax
        xor rax, rax
        cmp byte[plays], 9
        jne .end
        mov rax, 1
        .end:
            ret

    convert_matrix3index_to_arrayindex:  ;rdi = i, rsi = j; T = 3;> rax
        mov rax, 3
        mul rdi
        add rax, rsi
        ret
    
    check_iswin:    ;rdi = tab; > rax 0=false; 1=x; 2=o
        mov r11, rdi
        xor rax, rax
        .check_row:
            xor rdi, rdi    ;i
            xor rsi, rsi    ;j
            xor r9, r9    ;sum

            .loop1:
                xor rsi, rsi
                .loop2:
                    push rdi
                    push rsi
                    call convert_matrix3index_to_arrayindex
                    pop rsi
                    pop rdi
                    add r9b, byte[r11 + rax]
                    inc rsi
                    cmp rsi, 3
                    jne .loop2
                .end2:
                call .vef

                cmp rax, 0
                je .continue

                ret         ;exist win

                .continue:
                    xor r9, r9
                    inc rdi
                    cmp rdi, 3
                    jne .loop1
            .end1:

        .check_column:
            xor rdi, rdi    ;i
            xor rsi, rsi    ;j
            xor r9, r9      ;jum

            .loop3:
                xor rdi, rdi
                .loop4:
                    push rdi
                    push rsi
                    call convert_matrix3index_to_arrayindex
                    pop rsi
                    pop rdi
                    add r9b, byte[r11 + rax]
                    inc rdi
                    cmp rdi, 3
                    jne .loop4
                .end4:
                call .vef

                cmp rax, 0
                je .continue2

                ret

                .continue2:
                    xor r9, r9
                    inc rsi
                    cmp rsi, 3
                    jne .loop3
            .end3:

        .check_diagonals1:
            xor rdi, rdi    ;i
            xor rsi, rsi    ;j
            xor r9, r9      ;jum
            .loop5:
                push rdi
                push rsi
                call convert_matrix3index_to_arrayindex
                pop rsi
                pop rdi
                add r9b, byte[r11 + rax]
                inc rdi
                mov rsi, rdi
                cmp rdi, 3
                jne .loop5
            .end5:
            call .vef

            cmp rax, 0
            je .check_diagonals2
            ret

        .check_diagonals2:
            xor rdi, rdi
            mov rsi, 2
            xor r9, r9
            push rdi
            push rsi
            call convert_matrix3index_to_arrayindex
            pop rsi
            pop rdi
            add r9b, byte[r11 + rax]
            xchg rdi, rsi
            push rdi
            push rsi
            call convert_matrix3index_to_arrayindex
            pop rsi
            pop rdi
            add r9b, byte[r11 + rax]
            mov rdi, 1
            mov rsi, 1
            push rdi
            push rsi
            call convert_matrix3index_to_arrayindex
            pop rsi
            pop rdi
            add r9b, byte[r11 + rax]

            call .vef
            ret

        .vef:
            cmp r9b, 3
            je .x_
            cmp r9b, -3
            je .o_
            jmp .n_
            .x_:
                mov rax, 1
                ret
            .o_:
                mov rax, 2
                ret
            .n_:    
                mov rax, 0
                ret

    reset_tab:  ;rdi = *tab
        xor rcx, rcx
        .loop:
            mov byte[rdi + rcx], 0
            inc rcx
            cmp rcx, 9
            jne .loop
        .end:
        mov byte[plays], 0
        mov byte[turn], 1
        ret


    gerate_9rand:
        mov rax, 201
        xor rdi, rdi
        syscall

        mov rdi, 9
        div rdi
        mov rax, rdx
        ret

    set_pc_active: ;rdi = 0(false), 1(true)
        mov byte[pc_active], dil
        ret

