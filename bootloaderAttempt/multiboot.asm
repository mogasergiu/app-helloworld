[BITS 16]

MULTIBOOT_INFO_SIZE equ 120

struc multiboot_info
    .flags: resd 1

    .mem_lower: resd 1
    .mem_upper: resd 1

    .boot_device: resd 1

    .cmdline: resd 1

    .mods_count: resd 1
    .mods_addr: resd 1

;struct multiboot_elf_section_header_table {
    .num: resd 1
    .size: resd 1
    .addr: resd 1
    .shndx: resd 1
;}

    .mmap_length: resd 1
    .mmap_addr: resd 1

    .drives_length: resd 1
    .drivers_addr: resd 1

    .config_table: resd 1

    .boot_loader_name: resd 1

    .apm_table: resd 1

    .vbe_control_info: resd 1
    .vbe_mode_info: resd 1
    .vbe_mode: resw 1
    .vbe_interface_seg: resw 1
    .vbe_interface_off: resw 1
    .vbe_interface_len: resw 1

    .framebuffer_addr: resq 1
    .framebuffer_pitch: resd 1
    .framebuffer_width: resd 1
    .framebuffer_height: resd 1
    .framebuffer_bpp: resb 1
    .framebuffer_type: resb 1

    .framebuffer_red_mask_position: resb 1
    .framebuffer_red_mask_size: resb 1
    .framebuffer_green_mask_position: resb 1
    .framebuffer_green_mask_size: resb 1
    .framebuffer_blue_mask_position: resb 1
    .framebuffer_blue_mask_size: resb 1
endstruc

