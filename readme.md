# Guidelines

This repository will contain all the codes written in the coming processor design labs.

## Compilation

RTL can be compiled with the command: 

``` 
vlog names_of_all_system_verilog_files
```

or simply:

``` 
vlog *.sv 
```

Compilation creates a ``` work ``` folder in your current working directory in which all the files generated after compilation are stored.
 
## Simulation

The compiled RTL can be simulated with command:

``` 
vsim -c name_of_toplevel_module -do "run -all"
```

Simulation creates a ``` .vcd ``` file. This files contains all the simulation behaviour of design.

## Viewing the VCD Waveform File

To view the waveform of the design run the command:

```
gtkwave dumfile_name.vcd
```

This opens a waveform window. Pull the required signals in the waveform and verify the behaviour of the design.

# Test cases



## For conditional jumps: 

```
addi x1, x0, 2
addi x2, x0, 0
loop:
add x2, x2, x1
addi x1, x1, -1
bne x0, x1, loop

```
### Dump
```
00200093
00000113
00110133
fff08093
fe101ce3
```
### Result:
```
result x2 -> 3
```


## For storing 32bit immediate in register

### Code
``` 
# Generating 32 - bit constant
#y = 0x12345678 ;
lui x6 , 0x12345
	addi x6 , x6 , 0x678
# Generating 32 - bit constant
# y = 0x12345A78 ;
lui x7 , 0x12346
addi x7 , x7 , 0xFFFFFA78
```

### Dump
```
12345337
67830313
123463b7
a7838393
```
###     Result
```
 (x6)->0x12345678

 (x7)->0x12345a78

```

## For finding a gcd of two numbers

### Code

```
addi x8 , x0 , 12   //first number
addi x9 , x0 , 9   //second number
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
#gcd will be saved in x8
```

### Dump
```
00c00413
00900493
00940c63
00944663
40940433
ff5ff06f
408484b3
fedff06f
0000006f
```

### Result: 
```
x8 will contain the result of gcd
````

## store testing:

### Code

```
li x10, 0x1234
# Store the value in x10 to memory
sw x10, 0x0(x10)

```

### Dump
```
00001537
23450513
00a52023
```

### Result :
```
x10-> 0x00001234
```

