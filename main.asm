            %include    "linux.asm"
            %include    "constants.asm"

            section     .data
            row_0_name  equ "a"
            row_1_name  equ "b"
            row_2_name  equ "c"
            space       equ " "
            bar         equ "|"
            row_0_0     equ 0b00000001
            row_0_1     equ 0b00000010
            row_0_2     equ 0b00000100
            row_1_0     equ 0b00001000
            row_1_1     equ 0b00010000
            row_1_2     equ 0b00100000
            row_2_0     equ 0b01000000
            row_2_1     equ 0b10000000
            row_2_2     equ 0b00000001
            x_name      equ "X"
            o_name      equ "O"
            x_pos       db 0        ; track board placement - TTT1-TTT8
            o_pos       db 0        ; track board placement - TTT1-TTT8
            x_score_pos db 0        ; upper 7 bits - x score, least-significant bit - TTT9
            o_score_pos db 0        ; upper 7 bits - o score, least-significant bit - TTT9
            section     .bss
            BOARD_BFR   resb 14     ; store line to write, 13 characters plus null byte
            section     .text
            global      _start
            extern      print_line
_start:
            ; call main game loop
            call        run_game

            ; exit game
            mov         eax, SYS_EXIT
            mov         ebx, 0
            int         LINUX_SYSCALL

run_game:
            call print_board
            call get_input
            call process_input
            ret

print_board:
            push        ebp
            mov         ebp, esp

            ; local variable
            sub         esp, 4

            ; column numbers
            push        c_numbers
            call        print_line
            add         esp, 4 
           
            ; first row
            ; row name and first space
            lea         eax, BOARD_BFR 
            push        eax
            call        print_row_0
            sub         esp, 4

            ; first separator
            push        h_line
            call        print_line
            add         esp, 4

            ; second row
            lea         eax, BOARD_BFR 
            push        eax
            call        print_row_1
            sub         esp, 4

            ; second separator
            push        h_line
            call        print_line
            add         esp, 4

            ; third row
            lea         eax, BOARD_BFR 
            push        eax
            call        print_row_2
            sub         esp, 4

            mov         esp, ebp
            pop         ebp
            ret

print_row_0:
            push        ebp
            mov         ebp, esp

            mov         eax, [ebp + 8]

            ; a 
            mov         byte [eax], row_0_name 
            inc         eax
            ; [space]
            mov         byte [eax], space
            inc         eax
            ; [space]
            mov         byte [eax], space
            inc         eax
            ; 0, 0
chk_x_0_0:  mov         ebx, [x_pos]
            test        ebx, row_0_0    ; see if x has placed a token here
            jz          chk_o_0_0       ; not equal, so see if o
            mov         byte [eax], x_name
            jmp         finish_0_0
chk_o_0_0:  mov         ebx, [o_pos]
            test        ebx, row_0_0
            jz          space_0_0
            mov         byte [eax], o_name
            jmp         finish_0_0
space_0_0:  mov         byte [eax], space
finish_0_0: inc         eax             ; increment for token placement
            ; [space]
            mov         byte [eax], space
            inc         eax
            ; [bar]
            mov         byte [eax], bar
            inc         eax
            ; [space]
            mov         byte [eax], space
            inc         eax
            ; 0, 1
chk_x_0_1:  mov         ebx, [x_pos]
            test        ebx, row_0_1    ; see if x has placed a token here
            jz          chk_o_0_1       ; not equal, so see if o
            mov         byte [eax], x_name
            jmp         finish_0_1
chk_o_0_1:  mov         ebx, [o_pos]
            test        ebx, row_0_1
            jz          space_0_1
            mov         byte [eax], o_name
            jmp         finish_0_1
space_0_1:  mov         byte [eax], space
finish_0_1: inc         eax             ; increment for token placement
            ; [space]
            mov         byte [eax], space
            inc         eax
            ; [bar]
            mov         byte [eax], bar
            inc         eax
            ; [space]
            mov         byte [eax], space
            inc         eax
            ; 0, 2
chk_x_0_2:  mov         ebx, [x_pos]
            test        ebx, row_0_2    ; see if x has placed a token here
            jz          chk_o_0_2       ; not equal, so see if o
            mov         byte [eax], x_name
            jmp         finish_0_2
chk_o_0_2:  mov         ebx, [o_pos]
            test        ebx, row_0_2
            jz          space_0_2
            mov         byte [eax], o_name
            jmp         finish_0_2
space_0_2:  mov         byte [eax], space
finish_0_2: inc         eax             ; increment for token placement
            ; [space]
            mov         byte [eax], space
            inc         eax

            ; null character
            mov         byte [eax], 0

            ; print
            mov         eax, [ebp + 8]
            push        eax
            call        print_line
            add         esp, 4

            mov         esp, ebp
            pop         ebp
            ret

print_row_1:
            push        ebp
            mov         ebp, esp

            mov         eax, [ebp + 8]

            ; b  
            mov         byte [eax], row_1_name 
            inc         eax
            ; [space]
            mov         byte [eax], space
            inc         eax
            ; [space]
            mov         byte [eax], space
            inc         eax
            ; 1, 0
chk_x_1_0:  mov         ebx, [x_pos]
            test        ebx, row_1_0    ; see if x has placed a token here
            jz          chk_o_1_0       ; not equal, so see if o
            mov         byte [eax], x_name
            jmp         finish_1_0
chk_o_1_0:  mov         ebx, [o_pos]
            test        ebx, row_1_0
            jz          space_1_0
            mov         byte [eax], o_name
            jmp         finish_1_0
space_1_0:  mov         byte [eax], space
finish_1_0: inc         eax             ; increment for token placement
            ; [space]
            mov         byte [eax], space
            inc         eax
            ; [bar]
            mov         byte [eax], bar
            inc         eax
            ; [space]
            mov         byte [eax], space
            inc         eax
            ; 1, 1
chk_x_1_1:  mov         ebx, [x_pos]
            test        ebx, row_1_1    ; see if x has placed a token here
            jz          chk_o_1_1       ; not equal, so see if o
            mov         byte [eax], x_name
            jmp         finish_1_1
chk_o_1_1:  mov         ebx, [o_pos]
            test        ebx, row_1_1
            jz          space_1_1
            mov         byte [eax], o_name
            jmp         finish_1_1
space_1_1:  mov         byte [eax], space
finish_1_1: inc         eax             ; increment for token placement
            ; [space]
            mov         byte [eax], space
            inc         eax
            ; [bar]
            mov         byte [eax], bar
            inc         eax
            ; [space]
            mov         byte [eax], space
            inc         eax
            ; 1, 2
chk_x_1_2:  mov         ebx, [x_pos]
            test        ebx, row_1_2    ; see if x has placed a token here
            jz          chk_o_1_2       ; not equal, so see if o
            mov         byte [eax], x_name
            jmp         finish_1_2
chk_o_1_2:  mov         ebx, [o_pos]
            test        ebx, row_1_2
            jz          space_1_2
            mov         byte [eax], o_name
            jmp         finish_1_2
space_1_2:  mov         byte [eax], space
finish_1_2: inc         eax             ; increment for token placement
            ; [space]
            mov         byte [eax], space
            inc         eax

            ; null character
            mov         byte [eax], 0

            ; print
            mov         eax, [ebp + 8]
            push        eax
            call        print_line
            add         esp, 4

            mov         esp, ebp
            pop         ebp
            ret


print_row_2:
            push        ebp
            mov         ebp, esp

            mov         eax, [ebp + 8]

            ; c  
            mov         byte [eax], row_2_name 
            inc         eax
            ; [space]
            mov         byte [eax], space
            inc         eax
            ; [space]
            mov         byte [eax], space
            inc         eax
            ; 2, 0
chk_x_2_0:  mov         ebx, [x_pos]
            test        ebx, row_2_0    ; see if x has placed a token here
            jz          chk_o_2_0       ; not equal, so see if o
            mov         byte [eax], x_name
            jmp         finish_2_0
chk_o_2_0:  mov         ebx, [o_pos]
            test        ebx, row_2_0
            jz          space_2_0
            mov         byte [eax], o_name
            jmp         finish_2_0
space_2_0:  mov         byte [eax], space
finish_2_0: inc         eax             ; increment for token placement
            ; [space]
            mov         byte [eax], space
            inc         eax
            ; [bar]
            mov         byte [eax], bar
            inc         eax
            ; [space]
            mov         byte [eax], space
            inc         eax
            ; 2, 1
chk_x_2_1:  mov         ebx, [x_pos]
            test        ebx, row_2_1    ; see if x has placed a token here
            jz          chk_o_2_1       ; not equal, so see if o
            mov         byte [eax], x_name
            jmp         finish_2_1
chk_o_2_1:  mov         ebx, [o_pos]
            test        ebx, row_2_1
            jz          space_2_1
            mov         byte [eax], o_name
            jmp         finish_2_1
space_2_1:  mov         byte [eax], space
finish_2_1: inc         eax             ; increment for token placement
            ; [space]
            mov         byte [eax], space
            inc         eax
            ; [bar]
            mov         byte [eax], bar
            inc         eax
            ; [space]
            mov         byte [eax], space
            inc         eax
            ; 2, 2
chk_x_2_2:  mov         ebx, [x_score_pos] ; use extra bit
            test        ebx, row_2_2    ; see if x has placed a token here
            jz          chk_o_2_2       ; not equal, so see if o
            mov         byte [eax], x_name
            jmp         finish_2_2
chk_o_2_2:  mov         ebx, [o_score_pos] ; extra bit
            test        ebx, row_2_2
            jz          space_2_2
            mov         byte [eax], o_name
            jmp         finish_2_2
space_2_2:  mov         byte [eax], space
finish_2_2: inc         eax             ; increment for token placement
            ; [space]
            mov         byte [eax], space
            inc         eax

            ; null character
            mov         byte [eax], 0

            ; print
            mov         eax, [ebp + 8]
            push        eax
            call        print_line
            add         esp, 4

            mov         esp, ebp
            pop         ebp
            ret

get_input:
            ret

process_input:
            ret
