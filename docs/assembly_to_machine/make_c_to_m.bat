rmdir -r build
mkdir build
riscv64-unknown-elf-as -c -o build/startup.o src/startup.s -march=rv32i -mabi=ilp32
riscv64-unknown-elf-gcc -c -o build/factorial.o src/factorial.c -march=rv32i -mabi=ilp32
riscv64-unknown-elf-gcc -o build/factorial.elf build/factorial.o build/startup.o -T linker.ld -nostdlib -march=rv32i -mabi=ilp32
riscv64-unknown-elf-objcopy -O binary --only-section=.data* --only-section=.text* build/factorial.elf build/factorial.bin
python3 maketxt.py build/factorial.bin > build/factorial.txt
riscv64-unknown-elf-objdump -S -s build/factorial.elf > build/factorial.dump