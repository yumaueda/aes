verilator := verilator
vflags_common := -Wall -sv --top-module round
vflags_lint := $(vflags_common) --lint-only
vflags_sim := $(vflags_common) -cc --trace

rtl_dir := ./src/rtl
tb_dir := ./src/tb
rtl_src := $(wildcard $(rtl_dir)/*.sv)
tb_src := $(wildcard $(tb_dir)/*.cpp)

lint:
	$(verilator) $(vflags_lint) $(rtl_src)

sim:
	$(verilator) $(vflags_sim) --exe $(tb_src) $(rtl_src)
	make -j -C obj_dir -f Vround.mk Vround
	./obj_dir/Vround
	gtkwave round.vcd

clean:
	rm -f round.vcd
	rm -rf obj_dir

.PHONY: lint sim clean
