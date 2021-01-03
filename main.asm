            %include    "linux.asm"

            section     .data

            section     .text
            global      _start
_start:
            ; call main game loop
            call run_game

            ; exit game
            mov         eax, SYS_EXIT
            mov         ebx, $0
            int         LINUX_SYSCALL

run_game:
            call print_board
            call get_input
            call process_input
            ret

print_board:
            ret

get_input:
            ret

process_input:
            ret
