            %include    "linux.asm"
            %include    "constants.asm"

            section     .data

            section     .text
            global      _start
            extern      print_line
_start:
            ; call main game loop
            call	run_game

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
            ; column numbers
            
            push        h_line
            call        print_line
            add         esp, 4

            ret

get_input:
            ret

process_input:
            ret
