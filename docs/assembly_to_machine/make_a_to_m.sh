

rm -r build
mkdir build
riscv64-unknown-elf-as -c -o build/asm_code.o ../../sim/asm_code.s -march=rv32i -mabi=ilp32
riscv64-unknown-elf-gcc -o build/asm_code.elf build/asm_code.o -T linker.ld -nostdlib -march=rv32i -mabi=ilp32 > /dev/null
riscv64-unknown-elf-objcopy -O binary --only-section=.data* --only-section=.text* build/asm_code.elf build/asm_code.bin
python3 maketxt.py build/asm_code.bin > build/asm_code.txt
riscv64-unknown-elf-objdump -S -s build/asm_code.elf > build/asm_code.dump

cp build/asm_code.txt ../../sim/machine_codes.txt
cp ../../sim/machine_codes.txt ../../sim/machine_codes.mem