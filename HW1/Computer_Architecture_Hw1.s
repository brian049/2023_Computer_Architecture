.data
    #.align 8
    xx1: .word 0x00000000
    xx2: .word 0x3F99999A    
    xx3: .word 0x40B60000
    
    y1: .word 0x3F99999A
    y2: .word 0x40B60000
    y3: .word 0x3FC90000
    
    sign_mask: .word 0x80000000
    exp_mask: .word 0x7F800000
    man_mask: .word 0x007FFFFF
    man16_mask: .word 0x007F0000
    r_mask: .word 0xFF800000
    divisor: .word 0x100
    mul_use: .word 0x00800000
    mul_use2: .word 0x01000000
    mul_use3: .word 0x3F800000
    ans:    .string "multipication(x1*y1, x2*y2, x3*y3) answer is: \n"
    strin:     .string "input FP32(first 3 is x, least 3 is y): "
    strout:     .string "output bfloat16(first 3 is x, least 3 is y): "
    str1:     .string "zero"
    str2:     .string "infinity or NaN"
    str3:     .string "\n"

.text

main:
    
    addi sp, sp, -12
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)
    sw s0, 12(sp)
    
    # print
    la a0, strin
    li a7, 4
    ecall
    
    #next line
    la a0, str3
    li a7, 4
    ecall
    
load_xx1:
    # Load xx1 into a0
    lw a0, xx1
    li a7, 34
    ecall
    
    add x5, a0, x0 # x5=a0
    
    #next line
    la a0, str3
    li a7, 4
    ecall
    
load_xx2:  
    # Load xx2 into x18
    lw a0, xx2
    li a7, 34
    ecall
    
    add x18, a0, x0 # x18=a0
    
    #next line
    la a0, str3
    li a7, 4
    ecall
    
load_xx3:  
    # Load xx3 into x19
    lw a0, xx3
    li a7, 34
    ecall
    
    add x19, a0, x0 # x19=a0
    
    #next line
    la a0, str3
    li a7, 4
    ecall
    
    #next line
    la a0, str3
    li a7, 4
    ecall
    
load_y1:
    # Load y1 into x20
    lw a0, y1
    li a7, 34
    ecall
    
    add x20, a0, x0 # x20=a0
    
    #next line
    la a0, str3
    li a7, 4
    ecall
    
load_y2:
    # Load y2 into x21
    lw a0, y2
    li a7, 34
    ecall
    
    add x21, a0, x0 # x21=a0
    
    #next line
    la a0, str3
    li a7, 4
    ecall
    
load_y3:
    # Load y3 into x22
    lw a0, y3
    li a7, 34
    ecall
    
    add x22, a0, x0 # x22=a0
    
    #next line
    la a0, str3
    li a7, 4
    ecall

    # print
    la a0, strout
    li a7, 4
    ecall
    
    # counting to zero meaning remaining fp32 numbers
    addi x30, x0, 6
    li x24, 1
    li x25, 2
    li x26, 3
    li x27, 4
    li x28, 5
    
is_it_zero_or_infinity_or_NaN:
    # Load exp and man into a0 and a1
    lw a0, exp_mask
    lw a1, man_mask

change:
    beq x30, x28, change_to_xx2
    beq x30, x27, change_to_xx3
    beq x30, x26, change_to_y1
    beq x30, x25, change_to_y2
    beq x30, x24, change_to_y3
    
continue:
    and x6, x5, a0     # exp
    and x7, x5, a1     # man
    
    # Check for zero
    beqz x6, zero_case
    beqz x7, zero_case

Normalize:
    # Check for infinity or NaN
    li a0, 0x7F800000
    beq x6, a0, infinity_nan_case

    # Normalized number
    add a0, x0, x5
    add x6, a0, x0
    
    lw a0, r_mask
    and x6, x6, a0     # r_mask

    # r /= 0x100
    srli x6, x6, 8
    
    add a0, x0, x5
    add x5, a0, x6     # y = x + r

    # Mask the lower 16 bits of y
    li t6, 0xFFFF0000
    and x5, x5, t6

    #next line
    la a0, str3
    li a7, 4
    ecall
    
    sw x5, 0(x8)
    
    lw a0, 0(x8)
    li a7, 34
    ecall
    
    addi x8, x8, 8
    
    j done

zero_case:
    #next line
    la a0, str3
    li a7, 4
    ecall
    
    sw x5, 0(x8)
    addi x8, x8, 8
    
    la a0, str1
    li a7, 4
    ecall
    
    j done

infinity_nan_case:
    #next line
    la a0, str3
    li a7, 4
    ecall
    
    sw x5, 0(x8)
    addi x8, x8, 8
    
    la a0, str2
    li a7, 4
    ecall
    
    j done

done:
    addi x30, x30, -1
    bnez x30, is_it_zero_or_infinity_or_NaN

    add t1, x0, x0    # initialize t1
    addi x8, x8, -48
    nop
    nop
    nop
    nop
    nop
mul:
    lw x29, 0(x8)
    lw x30, 24(x8)
    addi x8, x8, 8
    
mul_real:
    lw t0, sign_mask
    lw t1, exp_mask
    lw t2, man16_mask
    lw x18, sign_mask
    lw x19, exp_mask
    lw x20, man16_mask
    
    and t0, x29, t0
    and t1, x29, t1
    and t2, x29, t2

    and x18, x30, x18
    and x19, x30, x19
    and x20, x30, x20
    
    lw x21, mul_use    # 0x00800000
    or t2, t2, x21
    or x20, x20, x21
    xor x21, t0, x18    # x21 = final sign
    
    add x23, x0, x0  
      
    # mul 0 condition
    bnez x29, count_zero1
    add x16, x0, x0
    j mul_done
count_zero1:
    bnez x30, mul_loop_start
    add x16, x0, x0
    j mul_done
    
mul_loop_start:
    beqz t2, mul_final

    andi x22, t2, 1
    beqz x22, no_addition
    add x23, x23, x20

no_addition:
    srli t2, t2, 1
    srli x20, x20, 1
    
    slli x23, x23, 1
    j mul_loop_start

    
mul_final:
    lw x24, mul_use2    # 0x01000000
    nop
    nop
    and x24, x23, x24
    and x25, x25, x0
    nop
    beqz x24, pass_exp_plus
    lw x25, mul_use    # exponent+1
    srli x23, x23, 1
    nop
    nop
pass_exp_plus:
    lw x24, man16_mask
    nop
    nop
    and x23, x23, x24
    lw x24, mul_use3    # 0x3F800000
    
    add t1, t1, x19
    add t1, t1, x25
    sub t1, t1, x24
    
    add x16, x0, x0
    nop
    nop
    or x16, t1, x16
    nop
    nop
    or x16, x16, x23
    nop
    nop
    or x16, x16, x21
    nop
    nop
mul_done:
    sw x16, 0(a3)
    addi a3, a3, 8

    addi x26, x26, -1
    bnez x26, mul
    
    
    #next line
    la a0, str3
    li a7, 4
    ecall
    
    #next line
    la a0, ans
    li a7, 4
    ecall
    
    lw a0, -24(a3)
    li a7, 34
    ecall
    #next line
    la a0, str3
    li a7, 4
    ecall
    
    lw a0, -16(a3)
    li a7, 34
    ecall
    #next line
    la a0, str3
    li a7, 4
    ecall
    
    lw a0, -8(a3)
    li a7, 34
    ecall
    #next line
    la a0, str3
    li a7, 4
    ecall
    
    lw ra, 0(sp)
    lw a0, 4(sp)
    lw a1, 8(sp)
    lw s0, 12(sp)
    addi sp, sp, 12
    # Exit
    li a7, 10
    ecall
 
change_to_xx2:
    add x5, x0, x18
    j continue
    
change_to_xx3:
    add x5, x0, x19
    j continue
    
change_to_y1:
    add x5, x0, x20
    j continue
    
change_to_y2:
    add x5, x0, x21
    j continue
    
change_to_y3:
    add x5, x0, x22
    j continue
 