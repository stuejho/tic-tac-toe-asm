            ; Common Linux Definitions

            ; System Call Numbers
            SYS_EXIT    equ 1
            SYS_READ    equ 3
            SYS_WRITE   equ 4
            SYS_OPEN    equ 5
            SYS_CLOSE   equ 6
            SYS_BRK     equ 45

            ; System Call Interrupt Number
            LINUX_SYSCALL  equ 0x80

            ; Standard File Descriptors
            STDIN       equ 0
            STDOUT      equ 1
            STDERR      equ 2

            ; Common Status Codes
            END_OF_FILE equ 0
