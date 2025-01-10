/* Protected Mode Loading Hello World APP */
.code16 # 16-bit code

.global start
start:
    movw %cs, %ax # move code segment to AX
    movw %ax, %ds # move AX to data segment
    movw %ax, %es # move AX to extra segment
    movw %ax, %ss # move AX to stack segment
    cli # clear interrupts
    inb $0x92, %al # read from port 0x92 (A20 line setup)
    orb $0x02, %al # set bit 1 of AL
    outb %al, $0x92 # write back to port 0x92
    data32 addr32 lgdt gdtDesc # load GDT register with gdtDesc
    movl %cr0, %eax # move control register 0 to EAX
    orb $0x01, %al # set protection enable bit
    movl %eax, %cr0 # move EAX back to control register 0
    data32 ljmp $0x08, $start32 # long jump to start32 with new code segment

.code32 # 32-bit code
start32:
    movw $0x10, %ax # set data segment selector
    movw %ax, %ds # move AX to data segment
    movw %ax, %es # move AX to extra segment
    movw %ax, %fs # move AX to FS segment
    movw %ax, %ss # move AX to stack segment
    movw $0x18, %ax # set graphics data segment selector
    movw %ax, %gs # move AX to GS segment
    
    movl $0x1ffffc, %eax # set stack pointer
    movl %eax, %esp # move EAX to stack pointer
    
    jmp bootMain # jump to bootMain in boot.c

.p2align 2 # align the next data on a 4-byte boundary
gdt: # Global Descriptor Table (GDT) definition
    .word 0, 0 # empty entry
    .byte 0, 0, 0, 0

    .word 0xffff, 0 # code segment entry
    .byte 0, 0x9a, 0xcf, 0 # access byte and flags for code segment

    .word 0xffff, 0 # data segment entry
    .byte 0, 0x92, 0xcf, 0 # access byte and flags for data segment

    .word 0xffff, 0x8000 # graphics segment entry
    .byte 0x0b, 0x92, 0xcf, 0 # access byte and flags for graphics segment

gdtDesc: # GDT descriptor
    .word (gdtDesc - gdt - 1) # size of the table, 2 bytes, 65536-1 bytes, 8192 entries
    .long gdt # offset, i.e. linear address of the table itself