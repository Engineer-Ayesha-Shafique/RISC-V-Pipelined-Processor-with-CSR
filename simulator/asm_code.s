j configure
j main
j h1  #timer interrupt handler
j h2  #external interrupt handler

main:
   addi x3, x0, 5                  #the number for which we want to find factorial, n
   blt x3, x0, negative_and_zero   #if n < 1 then return 1
   beq x3, x0, negative_and_zero   #if n == 0 then return 1

   addi x1, x0, 2                  #used for comparison
   beq x3, x1, two                 #find factorial of 2

   add x4, x0, x3                  #result will be stored in this register
   add x2, x0, x3                  #copy of n
   addi x5, x5, 1                  #used for comparison

   find:                           #used for n-1    (n)(n-1) ... 2
      addi x2, x2, -1
      add x3, x0, x4               #copy contents of x4 in x3
      j multiply

   done:                           #checks if the factorial is found
      bne x2, x1, find
      j stop

   add x4, x4, x3


   multiply:                       #used for repeated additions, checks if multiplication is completed
      add x7, x0, x2

   multiply1:                      #used for repeated additions
      addi x7, x7, -1
      add x4, x4, x3
      bne x7, x5, multiply1
      j done
      
   negative_and_zero:              #exception handler
      addi x4, x0, 1               #give factorial of negative numbers =  1
      j stop
   two:
      addi x4, x0, 2
   stop:
      addi x1, x0, 1
      slli x2, x1, 10     #chip select of data memory
      sw x4, 0(x2)
      j exit

h1:
    # lui x1, 0xfffff
    # addi x1, x1, 0xff

    # addi x10, x0, 10
    # xor x10, x10, x1  #toggle x10
    # nop
    addi x20, x0, 20
    mret
h2:
    addi x21, x0, 10
    mret

exit:
    j exit

configure:
    addi x22, x0, 8
    csrrw x0, mstatus, x22 #mie

    addi x23, x0, 1
    slli x24, x23, 7     #timer interrupt enable, mie[7]
    slli x25, x23, 11    #external interrupt enable, mie[11]
    add x26, x24, x25     #both timer and external interrupts

    csrrw x0, mie, x26  #mtie and meie

    j main