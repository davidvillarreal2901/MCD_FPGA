BUILD = build

TB_MCD = sim/tb_mcd.v
SIM_MCD = $(BUILD)/tb_mcd
VCD_MCD = $(BUILD)/tb_mcd.vcd

.PHONY: sim wave clean

$(BUILD):
	mkdir -p $(BUILD)

sim: $(BUILD)
	iverilog -g2012 \
		-I rtl/core \
		-o $(SIM_MCD) \
		$(TB_MCD)
	vvp $(SIM_MCD)

wave:
	surfer $(VCD_MCD)

clean:
	rm -rf $(BUILD)