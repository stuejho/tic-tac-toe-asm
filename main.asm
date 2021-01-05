            %include    "linux.asm"
            %include    "constants.asm"

            section     .data
            row_0_name  equ "a"
            row_1_name  equ "b"
            row_2_name  equ "c"
            space       equ " "
            bar         equ "|"
            colon       equ ":"
            x_name      equ "X"
            o_name      equ "O"
            x_win_val   equ 1
            o_win_val   equ 2
            x_prompt    dw  "X > ", 0
            o_prompt    dw  "O > ", 0
            x_win_str   db  "X wins!", 0
            o_win_str   db  "O wins!", 0
            invalid_prompt  db "Invalid input, try again > ", 0
            x_dat       dw  0b0000_0000_0000_0000       ; track score, board placement
            o_dat       dw  0b0000_0000_0000_0000       ; track score, board placement
            score_bit   equ 0b0000_0010_0000_0000       ; used to increment score
            reset_mask  equ 0b1111_1110_0000_0000       ; used to increment score
            win_row_0   equ 0b0000_0000_0000_0111
            win_row_1   equ 0b0000_0000_0011_1000
            win_row_2   equ 0b0000_0001_1100_0000
            win_col_0   equ 0b0000_0000_0100_1001
            win_col_1   equ 0b0000_0000_1001_0010
            win_col_2   equ 0b0000_0001_0010_0100
            win_maj_d   equ 0b0000_0001_0001_0001
            win_min_d   equ 0b0000_0000_0101_0100

            section     .bss
            BOARD_BFR   resb 14     ; store line to write, 13 characters plus null byte
            INPUT_BFR   resb 3      ; 2 bytes to store character, 1 byte for newline
            INPUT_BFR_SIZE  equ 3

            section     .text
            global      _start
            extern      print
            extern      print_line
            extern      print_newline
            extern      int_to_string
_start:
            ; call main game loop
            call        run_game

            ; exit game
            mov         eax, SYS_EXIT
            mov         ebx, 0
            int         LINUX_SYSCALL

run_game:
            call        print_board
            call        get_input
            call        check_status
chk_x:      cmp         eax, x_win_val
            jne         chk_o
            add         dword [x_dat], score_bit
            call        print_board     ; print the winning board
            push        x_win_str
            jmp         process_win
chk_o:      cmp         eax, o_win_val
            jne         run_game
            add         dword [o_dat], score_bit
            call        print_board     ; print the winning board
            push        o_win_str
process_win:
            call        print_line      ; print the appropriate win string pushed
            add         esp, 4          ; set stack pointer back to previous position
            call        print_scores
            ; ask the user if they want to play again
reset_game: and         word [x_dat], reset_mask
            and         word [o_dat], reset_mask
            jmp         run_game

end_game:
            ret

; PURPOSE:  Prints the current board to the console.
;
; INPUT:    None.
;
; RETURNS:  Nothing.
;
; PROCESS:
;   Registers used:
;   eax:    x data
;   ebx:    o data
;   ecx:    loop counter
;   edi:    destination index
            LCL_X_DAT   equ 4
            LCL_O_DAT   equ 8
print_board:
            push        ebp
            mov         ebp, esp

            ; load in data for x and o
            mov         eax, [x_dat]
            mov         ebx, [o_dat]

            ; save eax and ebx
            push        ebx
            push        eax

            ; column numbers
            push        c_numbers
            call        print_line
            add         esp, 4

            ; restore eax and ebx
            pop         eax
            pop         ebx
           
            ; first row
            mov         edi, BOARD_BFR  ; starting address of buffer
            mov         ecx, 3          ; ecx = 3

            ; row name and first space
            mov         byte [edi], row_0_name
            inc         edi
            mov         byte [edi], space
            inc         edi
row_0_loop: test        ecx, ecx        ; loop test, while ecx > 0
            jz          row_0_end

            ; [space]
            mov         byte [edi], space
            inc         edi

            ; symbol
row_0_x:    test        eax, 1          ; see if an x is placed
            jz          row_0_o
            mov         byte [edi], x_name
            jmp         row_0_after
row_0_o:    test        ebx, 1          ; see if an o is placed
            jz          row_0_space 
            mov         byte [edi], o_name
            jmp         row_0_after
row_0_space:mov         byte [edi], space
row_0_after:shr         eax, 1          ; right shift eax and ebx one bit
            shr         ebx, 1
            inc         edi             ; increment counter

            ; [space]
            mov         byte [edi], space
            inc         edi

            ; [bar]
            mov         byte [edi], bar 
            inc         edi

            dec         ecx
            jmp         row_0_loop
row_0_end:  mov         byte [edi - 1], 0  ; make last character a null byte 
row_0_print:
            ; save contents of eax and ebx
            push        ebx
            push        eax

            ; print row 0
            push        BOARD_BFR
            call        print_line
            add         esp, 4            

            ; first separator
            push        h_line
            call        print_line
            add         esp, 4

            ; restore eax and ebx
            pop         eax
            pop         ebx

            ; second row
            mov         edi, BOARD_BFR  ; starting address of buffer
            mov         ecx, 3          ; ecx = 3

            ; row name and first space
            mov         byte [edi], row_1_name
            inc         edi
            mov         byte [edi], space
            inc         edi
row_1_loop: test        ecx, ecx        ; loop test, while ecx > 0
            jz          row_1_end

            ; [space]
            mov         byte [edi], space
            inc         edi

            ; symbol
row_1_x:    test        eax, 1          ; see if an x is placed
            jz          row_1_o
            mov         byte [edi], x_name
            jmp         row_1_after
row_1_o:    test        ebx, 1          ; see if an o is placed
            jz          row_1_space 
            mov         byte [edi], o_name
            jmp         row_1_after
row_1_space:mov         byte [edi], space
row_1_after:shr         eax, 1          ; right shift eax and ebx one bit
            shr         ebx, 1
            inc         edi             ; increment counter

            ; [space]
            mov         byte [edi], space
            inc         edi

            ; [bar]
            mov         byte [edi], bar 
            inc         edi

            dec         ecx
            jmp         row_1_loop
row_1_end:  mov         byte [edi - 1], 0  ; make last character a null byte 
row_1_print:
            ; save contents of eax and ebx
            push        ebx
            push        eax

            ; print row 1
            push        BOARD_BFR
            call        print_line
            add         esp, 4            

            ; second separator
            push        h_line
            call        print_line
            add         esp, 4

            ; restore eax and ebx
            pop         eax
            pop         ebx

            ; third row
            mov         edi, BOARD_BFR  ; starting address of buffer
            mov         ecx, 3          ; ecx = 3

            ; row name and first space
            mov         byte [edi], row_2_name
            inc         edi
            mov         byte [edi], space
            inc         edi
row_2_loop: test        ecx, ecx        ; loop test, while ecx > 0
            jz          row_2_end

            ; [space]
            mov         byte [edi], space
            inc         edi

            ; symbol
row_2_x:    test        eax, 1          ; see if an x is placed
            jz          row_2_o
            mov         byte [edi], x_name
            jmp         row_2_after
row_2_o:    test        ebx, 1          ; see if an o is placed
            jz          row_2_space 
            mov         byte [edi], o_name
            jmp         row_2_after
row_2_space:mov         byte [edi], space
row_2_after:shr         eax, 1          ; right shift eax and ebx one bit
            shr         ebx, 1
            inc         edi             ; increment counter

            ; [space]
            mov         byte [edi], space
            inc         edi

            ; [bar]
            mov         byte [edi], bar 
            inc         edi

            dec         ecx
            jmp         row_2_loop
row_2_end:  mov         byte [edi - 1], 0  ; make last character a null byte 
row_2_print:
            ; print row 3
            push        BOARD_BFR
            call        print_line
            add         esp, 4            

            mov         esp, ebp
            pop         ebp
            ret

print_scores:
            ; print X's score ("X: ")
            mov         edi, BOARD_BFR
            mov         byte [edi], x_name
            inc         edi
            mov         byte [edi], colon
            inc         edi
            mov         byte [edi], space
            inc         edi 
            mov         byte [edi], 0

            push        BOARD_BFR
            call        print
            add         esp, 4
            ; score number + newline
            mov         ax, [x_dat]
            shr         ax, 9
            ; ret

            push        BOARD_BFR
            push        eax
            call        int_to_string
            add         esp, 8

            push        BOARD_BFR
            call        print_line
            add         esp, 4

            ; print O's score ("O: ")
            mov         edi, BOARD_BFR
            mov         byte [edi], o_name
            inc         edi
            mov         byte [edi], colon
            inc         edi
            mov         byte [edi], space
            inc         edi 
            mov         byte [edi], 0

            push        BOARD_BFR
            call        print
            add         esp, 4
            ; score number + newline
            mov         ax, [o_dat]
            shr         ax, 9

            push        BOARD_BFR
            push        eax
            call        int_to_string
            add         esp, 8

            push        BOARD_BFR
            call        print_line
            add         esp, 4

            ret

get_input:
            push        ebp
            mov         ebp, esp
            sub         esp, 4          ; space to store address of current player

            ; determine player turn
            mov         ax, [x_dat]     ; load player data
            mov         bx, [o_dat]     ; load player data
            shl         ax, 7           ; clear out 7 most-significant bits of eax
            shr         ax, 7
            shl         bx, 7           ; clear out 7 most-significant bits of ebx
            shr         bx, 7
            xor         al, ah          ; parity(ax) = parity(ah ^ al)
            xor         bl, bh          ; parity(bx) = parity(bh ^ bl)
            add         al, bl          ; parity(al + bl) = player turn
            jp          x_turn          ; even parity => X's turn
o_turn:     mov         dword [ebp - 4], o_dat  ; address of player data
            push        o_prompt        ; odd parity => O's turn
            jmp         proc_turn
x_turn:     mov         dword [ebp - 4], x_dat  ; address of player data
            push        x_prompt
            ; print player prompt
proc_turn:  call        print
            add         esp, 4          ; pushed a prompt, so "pop" it out
            ; read input
            mov         eax, SYS_READ
            mov         ebx, STDIN
            mov         ecx, INPUT_BFR
            mov         edx, INPUT_BFR_SIZE
            int         LINUX_SYSCALL
            ; process input,
            ; will shift an addend value N bits to the right,
            ; storing this number in ecx
            mov         al, [INPUT_BFR]     ; first character
            mov         bl, [INPUT_BFR + 1] ; second character
            ; row check
chk_row_0:  cmp         al, row_0_name
            jne         chk_row_1
            xor         ecx, ecx            ; shift 0 bits 
            jmp         chk_col_0
chk_row_1:  cmp         al, row_1_name
            jne         chk_row_2
            mov         ecx, 3              ; shift 3 bits
            jmp         chk_col_0
chk_row_2:  cmp         al, row_2_name
            push        invalid_prompt
            jne         proc_turn           ; invalid input, so try again
            mov         ecx, 6
            ; column check
chk_col_0:  cmp         bl, "1"
            jne         chk_col_1
            ; add         ecx, 0            ; no change necessary
            jmp         shift_bits
chk_col_1   cmp         bl, "2"
            jne         chk_col_2
            inc         ecx                 ; shift 1 more bit
            jmp         shift_bits
chk_col_2:  cmp         bl, "3"
            push        invalid_prompt
            jne         proc_turn           ; invalid input, so try again
            add         ecx, 2              ; shift 2 more bits
            ; now, ecx should have the number of bits to shift
shift_bits: mov         edx, 1
            shl         edx, cl
            mov         eax, [ebp - 4]
            or          [eax], edx

            call        print_newline

end_input:  mov         esp, ebp
            pop         ebp
            ret

check_status:
            push        ebp
            mov         ebp, esp
            ; set return value to 0 initially
            xor         eax, eax
            ; see if x has a winning combination
check_x:    mov         ax, [x_dat]         ; store current x data
            not         ax                  ; flip bits for comparison
            test        ax, win_row_0
            jz          x_win               ; 0 result means all bits selected by mask
            test        ax, win_row_1
            jz          x_win
            test        ax, win_row_2
            jz          x_win
            test        ax, win_col_0
            jz          x_win
            test        ax, win_col_1
            jz          x_win
            test        ax, win_col_2
            jz          x_win
            test        ax, win_maj_d
            jz          x_win
            test        ax, win_min_d
            jz          x_win
            jmp         check_o
x_win:      mov         eax, x_win_val
            jmp         return_status
check_o:    ; see if o has a winning combination
            mov         ax, [o_dat]         ; store current o data
            not         ax                  ; flip bits for comparison
            test        ax, win_row_0
            jz          o_win               ; 0 result means all bits selected by mask
            test        ax, win_row_1
            jz          o_win
            test        ax, win_row_2
            jz          o_win
            test        ax, win_col_0
            jz          o_win
            test        ax, win_col_1
            jz          o_win
            test        ax, win_col_2
            jz          o_win
            test        ax, win_maj_d
            jz          o_win
            test        ax, win_min_d
            jz          o_win
            jmp         return_status
o_win:      mov         eax, o_win_val
return_status:
            mov         esp, ebp
            pop         ebp
            ret
