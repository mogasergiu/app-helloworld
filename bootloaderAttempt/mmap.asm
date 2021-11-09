MMAP_SIGNATURE equ 0x534d4150
MMAP_PTR equ 0x7000

%include "multiboot.asm"

struc mmapEntry
    .baseAddrLow resd 1
    .baseAddrHigh resd 1
    .length resq 1
    .type resd 1
    .attr resd 1
endstruc

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

.findElfPreloadArea:
    mov eax, 1
    cmp eax, dword [edi + mmapEntry.type]
    jne .keepScanning

    xor eax, eax
    test eax, dword [edi + mmapEntry.baseAddrHigh]
    jne .keepScanning

    mov eax, dword [edi + mmapEntry.baseAddrLow]
    cmp eax, 0x100000
    jge .keepScanning

    add eax, dword [edi + mmapEntry.length]
    cmp eax, 0x100000
    jge .keepScanning

    mov eax, dword [edi + mmapEntry.baseAddrLow]
    mov dword [elfPreloadArea], eax

    mov eax, dword [edi + mmapEntry.length]
    mov dword [elfPreloadAreaLength], eax

.keepScanning:
    add di, 24
    add byte [si], 24
    jmp .scanRegions

.doneScanning:
    add byte [si], 24
    mov dword [multiboot_info_ptr + multiboot_info.mmap_addr], 0x9000
    ret

