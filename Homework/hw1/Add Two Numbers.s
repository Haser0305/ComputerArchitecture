.data
    star: .string "\0"
.text
init:
    mv t0, gp
    li t1, 8
    li t2, 2
    li t3, 3

    sw t1, 0(t0)

    addi t0, t0, 8    # move to next node base address
    sw t0, -4(t0)    # sw current addr to the previouse pointer
    sw t2, 0(t0)    # sw the new value to current node

    # follow above again
    addi t0, t0, 8
    sw t0, -4(t0)
    sw t3, 0(t0)

    # if need more test data, just repeat above 3 line of code, and replace the temp register

    # create l2 linked list
    li t1, 3
    li t2, 2
    li t3, 6
    li t4, 9

    addi t0, t0, 8
    sw zero, -4(t0)    # previouse node is last one, so point to null.
    sw t1, 0(t0)

    addi t0, t0, 8
    sw t0, -4(t0)
    sw t2, 0(t0)

    addi t0, t0, 8
    sw t0, -4(t0)
    sw t3, 0(t0)

    addi t0, t0, 8
    sw t0, -4(t0)
    sw t4, 0(t0)

    addi t0, t0, 8
    sw zero, -4(t0)    # put zero at the last node pointer


main:
    mv s3, gp    # s3 = l1
    jal ra, count_l1_len    # update s2 to the len of l1
    slli t0, s2, 3    # *8 to get the addr of l2
    add s4, gp, t0    # s4 => base addr of l2
    li s1, 0    # s1 = carry
    mv t3, s3    # do not modify s3, so use t3 in the future
    mv t4, s4    # as above
while:
    lw t0, 0(t3)    # laod l1 node
    lw t1, 0(t4)    # load l2 node
    add t0, t0, t1    # l1->val += l2->val
    add t0, t0, s1    # li->val += carry
    li s1, 0    # carry is used, so update to 0
    li t2, 10    # t2 in while is for checking the sum is greather then 10 or not
    blt t0, t2, no_carry    # no carry, skip 2 following instructions
    addi s1, s1, 1    # has carry, so s1 should be set 1
    addi t0, t0, -10    # update to the units digit
no_carry:
    sw t0, 0(t3)    # store the result in the node
    lw t0, 4(t3)    # load l1 next node addr
    lw t1, 4(t4)    # load l2 next node addr
    beq zero, t0, l1Null    # if the pointer is zero, this is the last node in l1
    beq zero, t1, l2Null    # same
    addi t3, t3, 8    # both list have next node, so put the addr of next node in t3
    addi t4, t4, 8    # same
    j while



createNode:
    # a0 is an input value. put the address of this node in a0
    add t0, gp, s0
    sw a0, 0(t0)
    add a0, gp, s0
    addi s0, s0, 8
    jr ra

l1Null:
    beq zero, t1, noMoreNode    # l2 is also null, just need to check the carry
    # l2 is not null
    sw t1, 4(t3)    # link last node in l1 to next l2 node
    mv a0, t1    # need to check whether the following nodes need to add carry or create a new node
    bgt s1, zero, checkCarry
    mv a1, s3
    j printAll


l2Null:
    beq zero, t0, noMoreNode    # l1 is also null
    # l1 is not null
    mv a0, t0    # l2 does not need to do anything more. just check l1
    bgt s1, zero, checkCarry
    mv a1, s3
    j printAll


checkCarry:
    # a0 is the base address that begin to check
    lw t0, 0(a0)
    li t1, 10    # t1 = 10
    add t0, t0, s1    # value + carry
    blt t0, t1, exitCheckCarry    # no carry anymore
    addi t0, t0, -10
    sw t0, 0(a0)
    lw a0, 4(a0)
    j checkCarry

exitCheckCarry:
    sw t0, 0(a0)   # store the last result in the latest node
    mv a1, gp    # print all values begin at l1
    j printAll


noMoreNode:
    # if both list do not have next node. just make sure to create a new node for carry
    mv a1, gp
    mv a0, s1
    bne s1, zero, createNode    # has carry

    j printAll

count_l1_len:
    # no input, update s2
    li s2, 0
    mv t1, s3
    addi t1, t1, 4
    lw, t0, 0(t1)    # t0 = nextNodeAddress
cllLoop:
    beq t0, zero, exitCllLoop
    addi s2, s2, 1
    addi t1, t1, 8
    lw t0, 0(t1)    # t0 = nextNodeAddress
    j cllLoop

exitCllLoop:
    addi s2, s2, 1
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