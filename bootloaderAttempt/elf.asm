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

struct Elf64_Phdr
    .p_type: resd 1; /*  Type  of  segment  */
    .p_flags: resd 1; /*  Segment  attributes  */
    .p_offset: resq 1; /*  Offset  in  file  */
    .p_vaddr: resq 1; /*  Virtual  address  in  memory  */
    .p_paddr: resq 1; /*  Reserved  */
    .p_filesz: resq 1; /*  Size  of  segment  in  file  */
    .p_memsz: resq 1; /*  Size  of  segment  in  memory  */
    .p_align: resq 1; /*  Alignment  of  segment  */
endstruc
