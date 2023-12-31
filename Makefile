
shell_source_files := $(shell find src/implementations/shell -name *.c)
shell_object_files := $(patsubst src/implementations/shell/%.c, build/shell/%.o, $(shell_source_files))

kernel_source_files := $(shell find src/implementations/kernel -name *.c)
kernel_object_files := $(patsubst src/implementations/kernel/%.c, build/kernel/%.o, $(kernel_source_files))

x86_64_c_source_files := $(shell find src/implementations/x86_64 -name *.c)
x86_64_c_object_files := $(patsubst src/implementations/x86_64/%.c, build/x86_64/%.o, $(x86_64_c_source_files))

x86_64_asm_source_files := $(shell find src/implementations/x86_64 -name *.asm)
x86_64_asm_object_files := $(patsubst src/implementations/x86_64/%.asm, build/x86_64/%.o, $(x86_64_asm_source_files))

x86_64_object_files := $(x86_64_c_object_files) $(x86_64_asm_object_files)

$(shell_object_files): build/shell/%.o : src/implementations/shell/%.c
	mkdir -p $(dir $@) && \
	gcc -m64 -c -I src/interface -ffreestanding $(patsubst build/shell/%.o, src/implementations/shell/%.c, $@) -o $@

$(kernel_object_files): build/kernel/%.o : src/implementations/kernel/%.c
	mkdir -p $(dir $@) && \
	gcc -m64 -c -I src/interface -ffreestanding $(patsubst build/kernel/%.o, src/implementations/kernel/%.c, $@) -o $@

$(x86_64_c_object_files): build/x86_64/%.o : src/implementations/x86_64/%.c
	mkdir -p $(dir $@) && \
	gcc -m64 -c -I src/interface -ffreestanding $(patsubst build/x86_64/%.o, src/implementations/x86_64/%.c, $@) -o $@

$(x86_64_asm_object_files): build/x86_64/%.o : src/implementations/x86_64/%.asm
	mkdir -p $(dir $@) && \
	nasm -f elf64 $(patsubst build/x86_64/%.o, src/implementations/x86_64/%.asm, $@) -o $@

.PHONY: build-x86_64
build-x86_64: $(shell_object_files) $(kernel_object_files) $(x86_64_object_files)
	mkdir -p dist/x86_64 && \
	ld -n -o dist/x86_64/kernel.bin -T targets/x86_64/linker.ld $(shell_object_files) $(kernel_object_files) $(x86_64_object_files) && \
	cp dist/x86_64/kernel.bin targets/x86_64/iso/boot/kernel.bin && \
	grub-mkrescue /usr/lib/grub/i386-pc -o dist/x86_64/kernel.iso targets/x86_64/iso
