[ORG 0x7c00]
[BITS 16]

struc mmapEntry
    .baseAddr resq 1
    .length resq 1
    .type resd 1
    .attr resd 1
endstruc

_start:
    jmp .flyOverBPB
    nop

; Currently we do not neet FAT information so we ignore BPB and zero it out
times 87 db 0

.flyOverBPB:
    cli
    cld

; Various BIOS's may set up cs:ip differently (not the case for sgabios though)
    jmp 0x0:farJumpRefreshSegmentRegs

%include "multiboot.asm"

multiboot_info_ptr: times multiboot_info_size * 1 db 0

farJumpRefreshSegmentRegs:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax

; Set up the stack
    mov sp, 0x7000

; We expect disk BIOS drive number
    cmp dl, 0x80
    jne error
    mov dword [multiboot_info_ptr + multiboot_info.boot_device], 0x8000ffff

    sti

    call getMmap

    jmp $

%include "mmap.asm"
%include "gdt.asm"

error:
    hlt
    jmp error

; Pad till 510th byte
times 510-($-$$) db 0

; Boot Signature
dw 0xaa55
