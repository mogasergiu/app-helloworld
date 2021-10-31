MMAP_SIGNATURE equ 0x534d4150
MMAP_ENTRY_COUNT_PTR equ 0x7000
MMAP_PTR equ 0x7001

%include "multiboot.asm"

getMmap:
    xor ax, ax
    mov di, MMAP_PTR
    mov edx, MMAP_SIGNATURE
    xor ebx, ebx
    lea si, word [multiboot_info_ptr + multiboot_info.mmap_length]
    mov byte [si], 0x0

.scanRegions:
    mov eax, 0xe820
    mov ecx, 0x18

    int 0x15

    test ebx, ebx
    je .doneScanning

    add di, 24
    add byte [si], 24
    jmp .scanRegions

.doneScanning:
    add byte [si], 24
    mov dword [multiboot_info_ptr + multiboot_info.mmap_addr], MMAP_PTR
    ret

