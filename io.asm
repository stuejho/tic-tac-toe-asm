            %include    "linux.asm"

; PURPOSE:  Prints a given character string to STDOUT.
; 
; INPUT:    The address of the character string.
;
; RETURNS:  
;
; PROCESS:
;   Registers used:
;       eax - character count
;       cl - current character
;       edx - current character address
            global      print
            section     .data
            section     .text
            ST_STR_ADDR equ 8       ; parameter location on stack
print:
            ; prologue
            push        ebp
            mov         ebp, esp

            mov         eax, [ebp + ST_STR_ADDR]
            push        eax
            call        count_chars ; count the number of characters
            add         esp, 4      ; re-adjust stack pointer

            ; print given string
            mov         edx, eax    ; store output of count_chars in edx
            mov         eax, SYS_WRITE
            mov         ebx, STDOUT
            mov         ecx, [ebp + ST_STR_ADDR]
            int         LINUX_SYSCALL

            ; epilogue
            mov         esp, ebp
            pop         ebp
            ret
            
; PURPOSE:  Prints a given character string to STDOUT
;           with an additional newline character output.
; 
; INPUT:    The address of the character string.
;
; RETURNS:  
;
; PROCESS:
;   Registers used:
;       eax - character count
;       cl - current character
;       edx - current character address
            global      print_line
            section     .data
            section     .text
            ST_STR_ADDR equ 8       ; parameter location on stack
print_line:
            ; prologue
            push        ebp
            mov         ebp, esp

            mov         eax, [ebp + ST_STR_ADDR]
            push        eax
            call        count_chars ; count the number of characters
            add         esp, 4      ; re-adjust stack pointer

            ; print given string
            mov         edx, eax    ; store output of count_chars in edx
            mov         eax, SYS_WRITE
            mov         ebx, STDOUT
            mov         ecx, [ebp + ST_STR_ADDR]
            int         LINUX_SYSCALL

            ; print newline character
            call print_newline

            ; epilogue
            mov         esp, ebp
            pop         ebp
            ret

; PURPOSE:  Prints a newline character to STDOUT. 
; 
; INPUT:    None.
;
; RETURNS:  1 if successful, -1 else.
;
; PROCESS:
;   Registers used:
;       eax - syscall number
;       ebx - target file descriptor, STDOUT
;       ecx - address of newline character code
;       edx - number of bytes to write, 1
            global      print_newline
            section     .data
            newline     db 0xA
            section     .text
print_newline:
            ; prologue
            push        ebp
            mov         ebp, esp

            ; print new line character
            mov         eax, SYS_WRITE
            mov         ebx, STDOUT 
            mov         ecx, newline
            mov         edx, 1
            int         LINUX_SYSCALL

            ; epilogue
            mov         esp, ebp
            pop         ebp
            ret
            
; PURPOSE:  Count the number of characters before a null byte
; 
; INPUT:    The address of the character string.
;
; RETURNS:  The number of characters counted.
;
; PROCESS:
;   Registers used:
;       eax - character count
;       cl - current character
;       edx - current character address
            global      count_chars
            section     .data
            section     .text
            CC_ST_STR_ADDR equ 8    ; parameter location on stack
count_chars:
            ; prologue
            push        ebp
            mov         ebp, esp

            ; set count to 0 and move address to edx
            xor         eax, eax
            mov         edx, [ebp + CC_ST_STR_ADDR]

count_loop:
            mov         cl, [edx]   ; get current character
            cmp         cl, 0       ; is it the null character?
            je          count_loop_end
            inc         eax         ; increment count
            inc         edx         ; increment pointer
            jmp         count_loop  ; continue looping

count_loop_end:
            ; epilogue
            mov         esp, ebp
            pop         ebp
            ret
