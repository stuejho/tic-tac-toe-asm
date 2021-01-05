            %include    "linux.asm"

            section     .data
            ; board constants
            board       db  "   1   2   3 ", 0xa
                        db  "a    |   |   ", 0xa
                        db  "  ---+---+---", 0xa
                        db  "b    |   |   ", 0xa
                        db  "  ---+---+---", 0xa
                        db  "c    |   |   ", 0xa
            BOARD_LEN   equ $ - board
            B_00_OFFSET db  17                  ; offset of a1
            B_01_OFFSET db  21                  ; offset of a2
            B_02_OFFSET db  25                  ; offset of a3
            B_10_OFFSET db  45                  ; offset of b1
            B_11_OFFSET db  49                  ; offset of b2
            B_12_OFFSET db  53                  ; offset of b3
            B_20_OFFSET db  73                  ; offset of c1
            B_21_OFFSET db  77                  ; offset of c2
            B_22_OFFSET db  81                  ; offset of c3
            ROW_0_NAME  equ "a"
            ROW_1_NAME  equ "b"
            ROW_2_NAME  equ "c"
            SPACE       equ " "
            BAR         equ "|"
            COLON       equ ":"
            X_NAME      equ "X"
            O_NAME      equ "O"
            X_WIN_VAL   equ 1
            O_WIN_VAL   equ 2
            X_PROMPT    dw  "X > ", 0
            O_PROMPT    dw  "O > ", 0
            X_WIN_STR   db  "X wins!", 0
            O_WIN_STR   db  "O wins!", 0
            INVALID_PRMT    db "Invalid input, try again > ", 0
            OCCUPIED_PRMT   db "Already marked, try another spot > ", 0
            AGAIN_PRMT      db "Would you like to play again? [y/n] > "
            AGAIN_PRMT_LEN  equ $ - AGAIN_PRMT
            YES         equ "y"
            NO          equ "n"
            ; position/score variables/constants
            x_dat       dw  0b0000_0000_0000_0000       ; [15..9] - track score, [8..0] - board placement
            o_dat       dw  0b0000_0000_0000_0000       ; row 0 - 0, 1, 2; row 1 - 3, 4, 5; row 2 - 6, 7, 8
            score_bit   equ 0b0000_0010_0000_0000       ; used to increment score
            reset_mask  equ 0b1111_1110_0000_0000       ; used to reset positions
            win_row_0   equ 0b0000_0000_0000_0111       ; row 0 win
            win_row_1   equ 0b0000_0000_0011_1000       ; row 1 win
            win_row_2   equ 0b0000_0001_1100_0000       ; row 2 win
            win_col_0   equ 0b0000_0000_0100_1001       ; column 0 win
            win_col_1   equ 0b0000_0000_1001_0010       ; column 1 win
            win_col_2   equ 0b0000_0001_0010_0100       ; column 2 win
            win_maj_d   equ 0b0000_0001_0001_0001       ; major diagonal win
            win_min_d   equ 0b0000_0000_0101_0100       ; minor diagonal win

            section     .bss
            BOARD_BFR   resb 14     ; store line to write, 13 characters plus null byte
            OUTPUT_BFR  resb 16     ; general output buffer
            INPUT_BFR   resb 3      ; 2 bytes to store character, 1 byte for newline
            INPUT_BFR_SIZE  equ 3   ; input buffer size in bytes

            section     .text
            global      _start
            ; I/O helpers
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

; PURPOSE:  Runs the Tic-Tac-Toe game.
;
; INPUT:    None.
;
; RETURNS:  Nothing.
;
; PROCESS:  (1) Prints the current board
;           (2) Gets user input
;           (3) Determines game status
;               (a) If a player has won, increment their
;                   score and prompt for another game
;               (b) Else, continue the next turn
run_game:
            call        print_board
            call        get_input
            call        check_status                ; returns 0 (no winner), 1 (x win), 2 (o win)
            ; determine whether a player has won
chk_x:      cmp         eax, X_WIN_VAL              ; see if return value of check_status is 1 (x win) 
            jne         chk_o                       ; x didn't win, so see if o did
            add         dword [x_dat], score_bit    ; increment x's score
            call        print_board                 ; print the winning board
            push        X_WIN_STR                   ; x won, get their victory string ready
            jmp         process_win
chk_o:      cmp         eax, O_WIN_VAL              ; see if return value of check_status is 2 (o win)
            jne         run_game                    ; x and o did not win, so continue to the next turn
            add         dword [o_dat], score_bit    ; increment o's score
            call        print_board                 ; print the winning board
            push        O_WIN_STR                   ; o won, get their victory string ready
process_win:
            call        print_line                  ; print the appropriate win string pushed
            add         esp, 4                      ; set stack pointer back to previous position
            call        print_scores                ; print both player scores
            ; ask the user if they want to play again
            call        check_again
            test        eax, eax
            jz          end_game 
reset_game: and         word [x_dat], reset_mask    ; clear x positions
            and         word [o_dat], reset_mask    ; clear o positions
            ; clear board
            xor         eax, eax                    ; clear eax register
            xor         ecx, ecx                    ; ecx = 0
clear_board:cmp         ecx, 9                      ; run loop 9 times
            jge         new_game                    ; end of loop 
            ; set SPACE
            mov         al, [B_00_OFFSET + ecx]     ; al = offset value
            mov         byte [board + eax], SPACE   ; modify character to space

            inc         ecx                         ; ecx = ecx + 1
            jmp         clear_board
new_game:   jmp         run_game                    ; start new game
end_game:
            ret

; PURPOSE:  Prints the current board to the console.
;
; INPUT:    None.
;
; RETURNS:  Nothing.
;
; PROCESS:  (1) Call SYS_WRITE with values in eax, ebx, ecx, edx
print_board:
            ; print board using syscall
            mov         eax, SYS_WRITE
            mov         ebx, STDOUT
            mov         ecx, board
            mov         edx, BOARD_LEN
            int         LINUX_SYSCALL

            ; return
            ret

; PURPOSE:  Prints the scores of both players.
;
; INPUT:    None.
;
; RETURNS:  Nothing.
;
; PROCESS:
;   Registers used:
;       edi - address of board string buffer
;       ax - store score value
print_scores:
            ; print X's score ("X: ")
            mov         edi, OUTPUT_BFR     ; store address of buffer in edi
            mov         byte [edi], X_NAME  ; 0: "X"
            inc         edi
            mov         byte [edi], COLON   ; 1: ":"
            inc         edi
            mov         byte [edi], SPACE   ; 2: " "
            inc         edi 
            mov         byte [edi], 0       ; 3: null terminator

            push        OUTPUT_BFR
            call        print               ; prints "X: "
            add         esp, 4
            ; score number + newline
            mov         ax, [x_dat]         ; get score into ax
            shr         ax, 9               ; shift position bits out
            ; ret

            push        OUTPUT_BFR          ; address to store converted string
            push        eax                 ; value to convert (use full register)
            call        int_to_string       ; converts value to string; result in buffer
            add         esp, 8

            push        OUTPUT_BFR
            call        print_line          ; prints the score + newline
            add         esp, 4

            ; print O's score ("O: ")
            mov         edi, OUTPUT_BFR     ; store address of buffer in edi
            mov         byte [edi], O_NAME  ; 0: "O"
            inc         edi
            mov         byte [edi], COLON   ; 1: ":"
            inc         edi
            mov         byte [edi], SPACE   ; 2: " "
            inc         edi 
            mov         byte [edi], 0       ; 3: null terminator

            push        OUTPUT_BFR
            call        print               ; prints "O: "
            add         esp, 4
            ; score number + newline
            mov         ax, [o_dat]         ; get score into ax
            shr         ax, 9               ; shift position bits out

            push        OUTPUT_BFR          ; address to store converted string
            push        eax                 ; value to convert
            call        int_to_string       ; converts value to string; result in buffer
            add         esp, 8

            push        OUTPUT_BFR
            call        print_line          ; prints the score + newline
            add         esp, 4

            ret

; PURPOSE:  Gets input from the current player
;           and updates their position.
;
; INPUT:    None.
;
; OUTPUT:   Nothing.
;
; PROCESS:  (1) Turn determination
;               ax - x player data
;               bx - o player data
;               ah, al - test x placement parity, overall parity
;               ah, bl - test o placement parity, overall parity
;               [ebp - 4] - stores data address of current player
;               [ebp - 8] - player name
;           (2) Prompt for user input
;               eax, ebx, ecx, edu - standard system call parameters
;           (3) Process input
;               al - row letter input
;               bl - column number input
;               ecx/cl - number of bits to left-shift
;               edx - left-shifted position bit
;               eax - address of current player data 
;           (4) Set token in data and on board
;               eax - address of current player data
;               al  - offset of board offset
;               bl  - player token
get_input:
            push        ebp
            mov         ebp, esp
            sub         esp, 8          ; SPACE to store address of current player

            ; determine player turn
            mov         ax, [x_dat]     ; load player data
            mov         bx, [o_dat]     ; load player data
            shl         ax, 7           ; clear out 7 most-significant bits of eax
            shr         ax, 7
            shl         bx, 7           ; clear out 7 most-significant bits of ebx
            shr         bx, 7
            xor         al, ah          ; parity(ax) = parity(ah ^ al)
            xor         bl, bh          ; parity(bx) = parity(bh ^ bl)
            xor         al, bl          ; parity(al + bl) = player turn
            jp          x_turn          ; even parity => X's turn
o_turn:     mov         dword [ebp - 4], o_dat  ; store address of player data
            mov         byte [ebp - 8], O_NAME
            push        O_PROMPT        ; odd parity => O's turn
            jmp         proc_turn
x_turn:     mov         dword [ebp - 4], x_dat  ; store address of player data
            mov         byte [ebp - 8], X_NAME
            push        X_PROMPT
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
            mov         al, [INPUT_BFR]     ; first character read (row letter)
            mov         bl, [INPUT_BFR + 1] ; second character read (column number)
            ; row check
chk_row_0:  cmp         al, ROW_0_NAME
            jne         chk_row_1
            xor         ecx, ecx            ; shift 0 bits
            jmp         chk_col_0
chk_row_1:  cmp         al, ROW_1_NAME
            jne         chk_row_2
            mov         ecx, 3              ; shift 3 bits
            jmp         chk_col_0
chk_row_2:  cmp         al, ROW_2_NAME
            push        INVALID_PRMT
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
            push        INVALID_PRMT
            jne         proc_turn           ; invalid input, so try again
            add         ecx, 2              ; shift 2 more bits
            ; now, ecx should have the number of bits to shift
shift_bits: mov         edx, 1              ; will left-shift 0b1 to get correct position
            shl         edx, cl             ; edx has been shifted, now has bit to set

            ; make sure this position is not already taken
            ; if occupied, print out a message
x_pos_chk:  test        edx, [x_dat]
            jz          o_pos_chk
            push        OCCUPIED_PRMT
            jmp         proc_turn
o_pos_chk:  test        edx, [o_dat]
            jz          set_token
            push        OCCUPIED_PRMT
            jmp         proc_turn

            ; set token on board
set_token:  mov         eax, [ebp - 4]      ; eax = address of player data
            or          [eax], edx          ; set player data position bit
            xor         eax, eax            ; clear eax
            mov         al, [B_00_OFFSET + ecx] ; set al to offset value
            mov         bl, [ebp - 8]       ; ebx = player token
            mov         [board + eax], bl   ; modify character at board + offset

            call        print_newline

end_input:  mov         esp, ebp
            pop         ebp
            ret

; PURPOSE:  Determines whether a player has won the game.
;
; INPUT:    None
;
; OUTPUT:   0 - no player has won
;           X_WIN_VAL (1) - X won
;           O_WIN_VAL (2) - O won
;
; PROCESS:  (1) Check x
;               ax - stores current x data
;           (2) Check y
;               ax - stores current o data
;           (3) Return value
;               eax - store return value
check_status:
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
x_win:      mov         eax, X_WIN_VAL
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
o_win:      mov         eax, O_WIN_VAL      ; set return value
return_status:
            ; eax has return value
            ret

; PURPOSE:  Asks the user if they would like to play again.
;
; INPUT:    None.
;
; RETURNS:  0 - No
;           1 - Yes
;
; PROCESS:  (1) Print prompt
;               eax, ebx, ecx, edx - standard system call parameters
;           (2) Read input
;               eax, ebx, ecx, edx - standard system call parameters
;           (3) Process input
;               eax - store return value
;               dl - store input character
check_again:
            ; print prompt
            mov         eax, SYS_WRITE
            mov         ebx, STDOUT
            mov         ecx, AGAIN_PRMT
            mov         edx, AGAIN_PRMT_LEN
            int         LINUX_SYSCALL

            ; read input
            mov         eax, SYS_READ
            mov         ebx, STDIN
            mov         ecx, INPUT_BFR
            mov         edx, INPUT_BFR_SIZE
            int         LINUX_SYSCALL

            ; process input
            xor         eax, eax            ; eax = 0
            mov         dl, [INPUT_BFR]
check_yes:  cmp         dl, YES             ; input was y?
            jne         check_no
            mov         eax, 1              ; eax = 1
            jmp         check_end
check_no:   cmp         dl, NO              ; input was n?
            jne         check_again

            ; eax has result
check_end:  ret
