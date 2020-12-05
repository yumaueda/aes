verilator := verilator
vflags_common := -Wall -sv
vflags_lint := $(vflags_common) --lint-only
vflags_sim := $(vflags_common) -cc --trace

rtl_dir := ./src/rtl
tb_dir := ./src/tb
rtl_src := $(wildcard $(rtl_dir)/*.sv)

lint:
	$(verilator) $(vflags_lint) --top-module round $(rtl_src)
	$(verilator) $(vflags_lint) --top-module keyexp $(rtl_src)

sim:
	$(verilator) $(vflags_sim) --top-module round\
		--exe $(tb_dir)/sim_round.cpp $(rtl_src)
	$(verilator) $(vflags_sim) --top-module keyexp\
		--exe $(tb_dir)/sim_keyexp.cpp $(rtl_src)
	make -j -C obj_dir -f Vround.mk Vround
	make -j -C obj_dir -f Vkeyexp.mk Vkeyexp
	./obj_dir/Vround
	./obj_dir/Vkeyexp

clean:
	rm -f round.vcd
	rm -rf obj_dir

.PHONY: lint sim clean
