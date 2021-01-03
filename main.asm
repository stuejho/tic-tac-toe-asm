            %include    "linux.asm"

            section     .data

            section     .text
            global      _start
_start:
            mov         eax, SYS_EXIT
            mov         ebx, $0
            int         LINUX_SYSCALL
