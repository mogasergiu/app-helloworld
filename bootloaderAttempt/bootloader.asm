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

    cli

    ; Enable the A20 line
    in al, 0x92
    or al, 2
    out 0x92, al

    mov eax, GDT32Desc

    lgdt [eax]

    ; set Protection Enable bit in Control Register 0
    mov eax, cr0
    or al, 1
    mov cr0, eax

    ; Jump to Protected Mode and update cs register
    jmp 0x8:startProtectedMode

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

[BITS 32]

struc multibootMmapEntry
    .size resd 1
    .address resq 1
    .length resq 1
    .type resd 1
endstruc

startProtectedMode:
    mov ax, 0x10
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov gs, ax
    mov fs, ax

    mov eax, 0x2BADB002

    mov edi, 0x9500
    mov esi, multiboot_info_ptr
    mov ecx, multiboot_info_size
    rep movsb

    mov edi, 0x9000
    mov esi, 0x7000
    mov ecx, 0xa8
.fillMmap:
    mov dword [edi + multibootMmapEntry.size], 20
    mov ebx, dword [esi + mmapEntry.baseAddrLow]
    mov dword [edi + multibootMmapEntry.address], ebx
    mov ebx, dword [esi + mmapEntry.baseAddrHigh]
    mov dword [edi + multibootMmapEntry.address + 4], ebx
    mov ebx, dword [esi + mmapEntry.length]
    mov dword [edi + multibootMmapEntry.length], ebx
    mov ebx, dword [esi + mmapEntry.length + 4]
    mov dword [edi + multibootMmapEntry.length + 4], ebx
    mov ebx, dword [esi + mmapEntry.type]
    mov dword [edi + multibootMmapEntry.type], ebx
    sub ecx, 24
    add edi, 24
    add esi, 24
    cmp ecx, 0
    jg .fillMmap

    mov ebx, 0x9500

    mov ecx, 0x100000
    mov ecx, dword [ecx + 28]

    jmp ecx

    jmp error
    
; Pad till 510th byte
times 1536 - ($ - $$) db 0

[BITS 16]

APEntry:
times 512 db 0x90
