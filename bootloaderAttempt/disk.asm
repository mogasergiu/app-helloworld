[BITS 16]

struc dap
    .packetSize: resb 1

    .reserve: resb 1

    ; Number of sectors to transfer
    .sectorsCount: resw 1 
    
    ; Memory buffer destination address
    .bufferOffset: resw 1
    .bufferSegment: resw 1

    ; LBA Block to read
    .startLBA: resq 1

    ; (EDD-3.0, optional) 64-bit flat address of transfer buffer
    ; used if memory buffer destination address  is 0xffff:0xffff
    .eddLow: resd 1
    .eddHigh: resd 1
endstruc

dap_ptr: times dap_size * 1 db 0

diskOps:

; Reset the disk to first sector
.resetDisk:
    ; Select reset disk function
    mov ah, 0x0

    ; dl has been pre-set by the BIOS to the correct drive value

    ; Call BIOS routine
    int 0x13

    ; If the Carry Flag is present, it means there was an error - retry reset
    jc .resetDisk

    ret

; Read disk in CHS addressing manner
.CHSRead:
    ; First reset drive
    call .resetDisk

    ; Choose the proper sector to read into
    mov ax, word [dap_ptr + dap.bufferSegment]
    mov es, ax

    ; Choose offset of sector to read ATA into
    mov bx, word [dap_ptr + dap.bufferOffset]

    ; Select CHS sector reading BIOS function
    mov ah, 0x2

    ; Select the number of sectors to read
    mov al, byte [dap_ptr + dap.sectorsCount]
    
    ; Select sector track to read
    mov ch, 0x0

    ; Select which sector to read on the track
    mov cl, 0x2

    ; Select head number
    mov dh, 0x0

    ; Call the BIOS routine
    int 0x13

    ; If the Carry Flag is set, it means there was an error - retry read
    jc .CHSRead

    ret

; Read disk in LBA addressing manner
.LBARead:
    ; First reset drive
    call .resetDisk

    ; First, let's verify that LBA is supported (dl already set by BIOS)
    ; IBM/MS Installation Check
    mov ah, 0x41
    mov bx, 0x55aa

    ; Call BIOS function
    int 0x13

    ; If extensions are not supported, Carry Flag will be set
    jc error

    ; dl already set by BIOS
    ; Select IBM/MS  Extended Read function
    mov ah, 0x42

    ; Select desired Disk Address Packet Structure
    mov si, dap_ptr

    ; Call BIOS function
    int 0x13

    ; If Carry Flag is set, it means we got an error - retry reading
    jc .CHSRead

    ret
