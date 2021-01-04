            %include    "linux.asm"
            %include    "constants.asm"

            section     .data
            row_0_name  equ "a"
            row_1_name  equ "b"
            row_2_name  equ "c"
            space       equ " "
            bar         equ "|"
            x_name      equ "X"
            o_name      equ "O"
            x_dat       dw 0b1100_0011_0000_0000        ; track score, board placement
            o_dat       dw 0b1100_0010_0000_0000        ; track score, board placement
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

get_input:
            ; determine player turn
            mov         ax, [x_dat]
            mov         bx, [o_dat]
            shl         ax, 7          ; clear out 7 most-significant bits of eax
            shr         ax, 7
            shl         bx, 7          ; clear out 7 most-significant bits of ebx
            shr         bx, 7
            xor         al, ah         ; parity(ax) = parity(ah ^ al)
            xor         bl, bh         ; parity(bx) = parity(bh ^ bl)
            add         al, bl         ; parity(al + bl) = player turn
            jp          x_turn         ; even parity => X's turn
o_turn:                  ; odd parity => O's turn
            jmp         end_turn
x_turn:     
end_turn:
            
            ret
