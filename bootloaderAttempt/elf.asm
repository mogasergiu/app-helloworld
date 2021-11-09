[BITS 16]

struc Elf64_Ehdr
    .e_ident: resb 16; /*  ELF  identification  */
    .e_type: resw 1; /*  Object  file  type  */
    .e_machine: resw 1; /*  Machine  type  */
    .e_version: resd 1; /*  Object  file  version  */
    .e_entry: resq 1; /*  Entry  point  address  */
    .e_phoff: resq 1; /*  Program  header  offset  */
    .e_shoff: resq 1; /*  Section  header  offset  */
    .e_flags: resd 1; /*  Processor-specific  flags  */
    .e_ehsize: resw 1; /*  ELF  header  size  */
    .e_phentsize: resw 1; /*  Size  of  program  header  entry  */
    .e_phnum: resw 1; /*  Number  of  program  header  entries  */
    .e_shentsize: resw 1; /*  Size  of  section  header  entry  */
    .e_shnum: resw 1; /*  Number  of  section  header  entries  */
    .e_shstrndx: resw 1; /*  Section  name  string  table  index  */
endstruc

struc Elf64_Phdr
    .p_type: resd 1; /*  Type  of  segment  */
    .p_flags: resd 1; /*  Segment  attributes  */
    .p_offset: resq 1; /*  Offset  in  file  */
    .p_vaddr: resq 1; /*  Virtual  address  in  memory  */
    .p_paddr: resq 1; /*  Reserved  */
    .p_filesz: resq 1; /*  Size  of  segment  in  file  */
    .p_memsz: resq 1; /*  Size  of  segment  in  memory  */
    .p_align: resq 1; /*  Alignment  of  segment  */
endstruc

PT_LOAD equ 0x1
PT_TLS equ 0x7

loadUK:
    mov edi, dword [elfPreloadArea]
    mov ecx, 0x1
    mov ebx, 0x4
    mov gs, bx
    mov esi, dap_ptr
    mov word [esi + dap.sectorsCount], cx
    mov word [esi + dap.bufferSegment], 0x0
    mov dword [esi + dap.bufferOffset], edi
    mov word [esi + dap.startLBA], gs

    call diskOps.LBARead

    mov ebx, dword [edi + Elf64_Ehdr.e_entry]
    mov eax, ELFMetadata.entry
    mov dword [eax], ebx
    mov ebx, dword [edi + Elf64_Ehdr.e_phoff]
    mov eax, ELFMetadata.phoff
    mov dword [eax], ebx
    mov bx, word [edi + Elf64_Ehdr.e_phentsize]
    mov eax, ELFMetadata.phentsize
    mov word [eax], bx
    mov bx, word [edi + Elf64_Ehdr.e_phnum]
    mov eax, ELFMetadata.phnum
    mov word [eax], bx

    mov ax, word [edi + Elf64_Ehdr.e_phentsize]
    mov bx, word [edi +  Elf64_Ehdr.e_phnum]
    mul bx

    push ax
    push dx

    mov bx, 0x200
    div bx

    inc ax

    cmp dword [edi + Elf64_Ehdr.e_phoff], 0x200
    jl .loadPhdrs
    push ax
    mov ax, word [edi + Elf64_Ehdr.e_phoff]
    add edi, 2
    mov dx, word [edi + Elf64_Ehdr.e_phoff]
    div bx
    inc ax
    mov bx, gs
    add bx, ax
    mov gs, bx
    pop ax
    mov word [edi + Elf64_Ehdr.e_phoff], 0

.loadPhdrs:
    xor edx, edx
    mov dx, word [edi + Elf64_Ehdr.e_phoff]
    mov edi, dword [elfPreloadArea]
    mov word [esi + dap.sectorsCount], ax
    mov word [esi + dap.bufferSegment], 0x0
    mov dword [esi + dap.bufferOffset], edi
    mov word [esi + dap.startLBA], gs

    call diskOps.LBARead

    pop dx
    pop ax
    xor ecx, ecx
    mov cx, dx
    shl ecx, 16
    mov cx, ax
    mov bx, 0x200
    div bx

    mov ebx, ecx
    add ebx, edi

    mov eax, ELFMetadata.phnum
    mov cx, word [eax]
    mov eax, ELFMetadata.phoff
    add di, word [eax]
    add bx, word [eax]

    push bp
.beginLoadingPhdrs:
    push cx
    test byte [edi + Elf64_Phdr.p_type], PT_LOAD
    jz .nextPhdr
    cmp byte [edi + Elf64_Phdr.p_type], PT_TLS
    jg .nextPhdr

    mov ax, word [edi + Elf64_Phdr.p_filesz]
    mov dx, word [edi + Elf64_Phdr.p_filesz + 2]
    push bx
    mov ebx, 0x200
    div bx

    mov cx, ax
    add cx, 0x80
    add cx, 0x80
    mov eax, dword [edi + Elf64_Phdr.p_offset]
    xor edx, edx
    div ebx
    pop bx
    add ax, 4
    mov gs, ax

    xor ebp, ebp
.readDisk:
    mov esi, dap_ptr
    mov word [esi + dap.sectorsCount], 0x80
    mov word [esi + dap.bufferSegment], 0x0
    mov word [esi + dap.bufferOffset], bx
    mov word [esi + dap.startLBA], gs

    push dx
    push cx
    push bx
    call diskOps.LBARead
    pop bx
    pop cx
    pop dx

    mov ax, gs
    add ax, 0x80
    mov gs, ax

.memcpy:
    push cx
    mov esi, ebx
    add si, dx
    mov ecx, 0x10000
    mov eax, dword [edi + Elf64_Phdr.p_paddr]
    add eax, ebp

    push dx

.memcpyContinue:
    mov dl, byte [esi]
    mov byte [eax], dl
    inc esi
    inc eax
    dec ecx
    test ecx, ecx
    jnz .memcpyContinue

    pop dx
    pop cx

    add ebp, 0x10000
    sub cx, 0x80
    jg .readDisk

.nextPhdr:
    pop cx
    dec ecx
    add edi, Elf64_Phdr_size
    test ecx, ecx
    jnz .beginLoadingPhdrs

    pop bp

    ret
