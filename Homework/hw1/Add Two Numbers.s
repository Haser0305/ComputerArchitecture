.data
    star: .string "\0"
    l1_len: .word 3
    l2_len: .word 3

.text

init:
    li t0, 1
    li t1, 2
    li t2, 3
    
    sw t0, 0(gp)
    sw t1, 8(gp)
    sw t2, 16(gp)

    mv t0, gp
    addi t0, t0, 8
    sw t0, -4(t0)
    addi t0 , t0, 8
    sw t0, -4(t0)
    sw zero, 4(t0)
    
    
    li t0, 3
    li t1, 2
    li t2, 1
    
    sw t0, 24(gp)
    sw t1, 32(gp)
    sw t2, 40(gp)

    mv t0, gp
    addi t0, t0, 32
    sw t0, -4(t0)
    addi t0 , t0, 8
    sw t0, -4(t0)
    sw zero, 4(t0)
    
    li s0, 48
    

main:
    mv s3, gp    # s3 = l1
    addi s4, gp, 24    # s4 = l2
    li s1, 0    # s1 = carry
while:
    lw t0, 0(s3)    # laod l1 node
    lw t1, 0(s4)    # load l2 node
    add t0, t0, t1    # l1->val += l2->val
    add t0, t0, s1    # li->val += carry
    li s1, 0
    li t2, 10
    blt t0, t2, no_carry
    addi s1, s1, 1
    addi t0, t0, -10
no_carry:
    sw t0, 0(s3)
    lw t0, 4(s3)    # load l1 next node
    lw t1, 4(s4)    # load l2 next node
    beq zero, t0, l1Null
    beq zero, t1, l2Null
    addi s3, s3, 8
    addi s4, s4, 8
    j while

    

createNode:
    # a0 is an input value. put the address of this node in a0
    add t0, gp, s0
    sw a0, 0(t0)
    add a0, gp, s0
    addi s0, s0, 8
    jr ra

l1Null:
    beq zero, t1, noMoreNode    # l2 is also null
    # l2 is not null
    sw t1, 4(s3)
    mv a0, t1
    j checkCarry
    
    
l2Null:
    beq zero, t0, noMoreNode    # l1 is also null
    # l1 is not null
    mv a0, t0
    j checkCarry
    
    
checkCarry:
    # a0 is the base address that begin to check
    lw t0, 0(a0)
    li t1, 10    # t1 = 10
    add t0, t0, s1    # value + carry
    blt t0, t1, exitCheckCarry    # no carry again
    addi t0, t0, -10
    sw t0, 0(a0)
    j checkCarry
    
exitCheckCarry:
    sw t0, 0(a0)
    mv a1, gp
    j printAll
    

noMoreNode:
    mv a1, gp
    mv a0, s1
    bne s1, zero, createNode
    
    j printAll
    
count_l1_len:
    li s2, 0
    lw, t0, 4(s3)    # t0 = nextNodeAddress
cllLoop:
    beq t0, zero, exitCllLoop
    addi s2, s2, 1
    addi t0, t0, 4    # t0 = nextNodeAddress
    j cllLoop
    
exitCllLoop:
    jr ra
    

printAll:
    # a1 is the base address
    li a7, 1
    lw a0, 0(a1)
    ecall
    li a7, 4
    la a0, star
    ecall
    
    lw t1, 4(a1)
    beq t1, zero, exit
    lw a1, 4(a1)
    j printAll

    
exit:
    li a7, 10
    ecall
    