linter := verilator
lflags := --lint-only -Wall -sv

top_module := round

rtl_dir := ./src/rtl
tb_dir := ./src/tb
rtl_src := $(wildcard $(rtl_dir)/*.sv)
tb_src := $(wildcard $(tb_dir)/*.sv)

.PHONY: lint
lint:
	$(linter) $(lflags) --top-module $(top_module) $(rtl_src)

.PHONY: clean
clean:
	rm -rf obj_dir
