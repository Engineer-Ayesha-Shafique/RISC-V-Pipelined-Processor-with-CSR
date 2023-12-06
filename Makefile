conv_to_machine:  #converts assembly code to machine code

#this make does not call this makefile but in that folder
	cd docs/assembly_to_machine/ && $(MAKE)

compile:
	/home/dell/intelFPGA/20.1/modelsim_ase/bin/vlog *.sv

simulate:
	/home/dell/intelFPGA/20.1/modelsim_ase/bin/vsim -c  tb_processor -do "run -all"	

run: conv_to_machine compile simulate

