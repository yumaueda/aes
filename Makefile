verilator := verilator
vflags_common := -Wall -sv
vflags_lint := $(vflags_common) --lint-only
vflags_sim := $(vflags_common) -cc --trace

rtl_dir := ./src/rtl
tb_dir := ./src/tb
rtl_src := $(wildcard $(rtl_dir)/*.sv)

lint:
	$(verilator) $(vflags_lint) --top-module cipher $(rtl_src)

sim:
	$(verilator) $(vflags_sim) --top-module round\
		--exe $(tb_dir)/sim_round.cpp $(addprefix $(rtl_dir)/, round.sv\
		addroundkey.sv subbytes.sv sbox.sv shiftrows.sv mixcolumns.sv\
		mapcolumn.sv polymult.sv)
	make -j -C obj_dir -f Vround.mk Vround
	$(verilator) $(vflags_sim) --top-module keyexp\
		--exe $(tb_dir)/sim_keyexp.cpp $(addprefix $(rtl_dir)/, keyexp.sv\
		keyexpunit.sv sbox.sv)
	make -j -C obj_dir -f Vkeyexp.mk Vkeyexp
	./obj_dir/Vround
	./obj_dir/Vkeyexp

clean:
	rm -f sim_round.vcd
	rm -f sim_keyexp_128.vcd
	rm -rf obj_dir

.PHONY: lint sim clean
