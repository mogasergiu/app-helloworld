[BITS 16]

GDT32Start:
.nullDesc:
    dd 0x0
    dd 0x0

.codeDesc:
    dw 0xffff
    dw 0x0000
    db 0x0
    db 10011010b
    db 11001111b
    db 0x0

.dataDesc:
    dw 0xffff
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0
GDT32End:

GDT32Desc:
; Size of the Global Descriptor Table minus 1
    dw GDT32End - GDT32Start - 1

; The starting address of the Global Descriptor Table
    dw GDT32Start
