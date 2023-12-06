addi x8 , x0 , 12 
addi x9 , x0 , 9  
gcd:
beq x8 , x9 , stop
blt x8 , x9 , less
sub x8 , x8 , x9
j gcd
less:
sub x9 , x9 , x8
j gcd
stop: 
j stop