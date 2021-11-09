[ORG 0x7c00]
[BITS 16]

_start:
    jmp .flyOverBPB
    nop

; Currently we do not neet FAT information so we ignore BPB and zero it out
times 87 db 0

.flyOverBPB:
    cli

; Various BIOS's may set up cs:ip differently (not the case for sgabios though)
    jmp 0x0:farJumpRefreshSegmentRegs

%include "multiboot.asm"

multiboot_info_ptr: times multiboot_info_size * 1 db 0
elfPreloadArea: dd 0
elfPreloadAreaLength: dd 0

farJumpRefreshSegmentRegs:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax

; Set up the stack
    mov bp, 0x7000
    mov sp, bp

; We expect disk BIOS drive number

    sti

    mov byte [dap_ptr + dap.packetSize], 0x10
    mov word [dap_ptr + dap.sectorsCount], 0x3
    mov word [dap_ptr + dap.bufferSegment], 0x0
    mov word [dap_ptr + dap.bufferOffset], unrealModeStage
    mov byte [dap_ptr + dap.startLBA], 0x1

    call diskOps.LBARead

    call getMmap

    jmp 0x0:unrealModeStage

%include "mmap.asm"
%include "disk.asm"

error:
    hlt
    jmp error

; Pad till 510th byte
times 510-($-$$) db 0

; Boot Signature
dw 0xaa55

unrealModeStage:
    cli
    mov eax, GDT32Desc

    lgdt [eax]

    ; set PE bit
    mov eax, cr0
    or al, 1
    mov cr0, eax

    push ds
    mov ax, 0x10
    mov ds, ax

    ; Back to Real Mode
    and al,0xfe
    mov  cr0, eax

    pop ds

    sti

    mov esi, elfPreloadArea
    mov eax, 0x8200
    mov ebx, dword [esi]
    cmp ebx, eax
    jge .loadELF

    mov dword [esi], eax
    add dword [esi + 4], ebx
    sub dword [esi + 4], eax

.loadELF:
    call loadUK
    jmp $

%include "gdt.asm"

ELFMetadata:
.entry:
    dd 0

.phoff:
    dd 0

.phentsize:
    dw 0

.phnum:
    dw 0

%include "elf.asm"

; Pad till 510th byte
times 1536 - ($ - $$) db 0

APEntry:
times 512 db 0x90
