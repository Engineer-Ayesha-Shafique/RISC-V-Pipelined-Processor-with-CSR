![logo](https://riscv.org/wp-content/uploads/2018/06/RISC-V-Logo-2.png)
_________________

# RISC-V Pipelined Processor RV32I core with CSR

This is a Pipelined Processor with CSR support running the RV32I implementation, hence a 32-bit CPU, written in __SystemVerilog__. It was made for learning purposes, it's not intended for production under the supervision of our respected Mentor [ @hamza-akhtar-dev ](https://github.com/hamza-akhtar-dev). Developed and Tested on [ModelSim](https://www.mentor.com/company/higher_ed/modelsim-student-edition).

## RISC-V reference

I recommend 100% to read the [RISC-V Reference Manual](https://github.com/riscv/riscv-isa-manual/releases/download/Ratified-IMAFDQC/riscv-spec-20191213.pdf), maybe not complete but those sections mentioning the RV32I implementation.

## Architecture

The architecture was heavily inspired by the 32-bit [Single Cycle MIPS processor](https://media.cheggcdn.com/media/b82/b820d7ac-b4c9-4dd7-af10-e3b3fbe250ff/phpPVaajI) explained in [Digital Design and Computer Architecture book](https://www.amazon.com/Digital-Design-Computer-Architecture-Harris/dp/0123944244/ref=pd_lpo_1?pd_rd_w=SEXjq&content-id=amzn1.sym.116f529c-aa4d-4763-b2b6-4d614ec7dc00&pf_rd_p=116f529c-aa4d-4763-b2b6-4d614ec7dc00&pf_rd_r=82ZAPW9VP21TKQM08AAT&pd_rd_wg=9EFiQ&pd_rd_r=75b9df90-d341-4fb2-b6dd-8ef3d3fa4219&pd_rd_i=0123944244&psc=1). Note that instruction and data are stored in separate memories.


### Documentation
The documentation consists of three documents:
1. User-Level ISA Specification <br/>
There is the user-level ISA specification. The most important thing is that it discusses the basic instructions and core elements. Here are highlighted instructions for RV32I, RV32E, RV64I and RV128I. What ISA means is in [Terms needing explanation](#terms).
Link v2.2 [13.12.2020]: https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf
2. Privileged ISA specification <br/>
It describes the elements of the processor, which are related to the management of priority levels. It's used to how to start the operating system. Also are defined here as interrupt handling or physical memory management.
Link v1.10 [13.12.2020]: https://riscv.org/wp-content/uploads/2017/05/riscv-privileged-v1.10.pdf
3. Debug specification <br/>
Describes a standard, that enables debugging.
Link 0.13.2 [13.12.2020]: https://riscv.org/wp-content/uploads/2019/03/riscv-debug-release.pdf


## How to work


Add Risc V assembly code in 

```
sim/asm_code.s
```

Remember to update path of bin folder of modelsim in Makefile

```
conv_to_machine:  #converts assembly code to machine code

#this make does not call this makefile but in that folder
	cd docs/assembly_to_machine/ && $(MAKE)

compile:
	/yourpath/modelsim_ase/bin/vlog *.sv

simulate:
	/yourpath/modelsim_ase/bin/vsim -c  tb_processor -do "run -all"	

run: conv_to_machine compile simulate

```

### For linux Users

RTL can be compiled and simulated with the command: 

```
sudo make run
```
#### Viewing the VCD Waveform File

To view the waveform of the design run the command:

```
sudo make wave
```

This opens a waveform window. Pull the required signals in the waveform and verify the behaviour of the design. If it won't work in IDE terminal open linux system terminal and re-run the command. Gtkwave has some issue in IDE say VS code, etc.

### For Windows Users

#### Compilation

RTL can be compiled with the command: 

``` 
vlog names_of_all_system_verilog_files
```

or simply:

``` 
vlog *.sv 
```

Compilation creates a ``` work ``` folder in your current working directory in which all the files generated after compilation are stored.
 
#### Simulation

The compiled RTL can be simulated with command:

``` 
vsim -c name_of_toplevel_module -do "run -all"
```

Simulation creates a ``` .vcd ``` file. This files contains all the simulation behaviour of design.

#### Viewing the VCD Waveform File

To view the waveform of the design run the command:

```
gtkwave dumfile_name.vcd
```

This opens a waveform window. Pull the required signals in the waveform and verify the behaviour of the design.

