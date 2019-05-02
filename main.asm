%include "gameFunctions.asm"
global _start
section .data
	
	tab: times 9 db 0
	str1: db "Digite 1 para jogar, 2 para jogar com o computador: ", 0x0
	str3: db "Deu velha", 0xA, 0x0
	str4: db "X ganhou", 0xA, 0x0
	str5: db "O Ganhou", 0xA, 0x0
	str6: db "Digite 1 para jogar novamente, 2 para sair: ", 0xA, 0x0
	err1: db "Opcao digitada invalida", 0xA, 0x0

section .text
_start:

	call clean_scream

	mov rdi, tab
	call reset_tab

	mov rdi, str1
	call print_string
	call read_number
	
	cmp rax, 2
	je .pc
	cmp rax, 1
	je .solo
	jmp .invalid

	.pc:
		mov rdi, 1
		call set_pc_active
		jmp .game
	.solo:
		mov rdi, 0
		call set_pc_active
		jmp .game

	.game:

		call clean_scream
		call show_turn
		call print_newline

		mov rdi, tab
		call print_tab
		mov rdi, tab
		call play

		call check_is_velha
		cmp rax, 1
		je .velha

		mov rdi, tab
		call check_iswin
		cmp rax, 1
		je .x_win
		cmp rax, 2
		je .o_win

		jmp .game


	.invalid:
		mov rdi, err1
		call print_string
		jmp _start

	 .velha:
	 	call clean_scream
		mov rdi, str3
		call print_string
		jmp .end

	.x_win:
		call clean_scream
		mov rdi, str4
		call print_string
		jmp .end

	.o_win:
		call clean_scream
		mov rdi, str5
		call print_string
		jmp .end

	.end:
		mov rdi, str6
		call print_string

		call read_number
		cmp rax, 1
		je .replay
		cmp rax, 2
		je .exit
		jmp .invalid_

		.replay:
			mov rdi, tab
			call reset_tab
			jmp _start

		.invalid_:
			mov rdi, err1
			call print_string
			jmp .end
	.exit:
		mov rax, 60
		mov rdi, 0
		syscall

