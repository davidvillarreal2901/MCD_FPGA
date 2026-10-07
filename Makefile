#Definiciones generales
BUILD = build

SURFER = /Applications/surfer

#Rutas de los archivos de simulación del verilog del drive
SIM = $(BUILD)/tb_mcd
VCD = $(BUILD)/tb_mcd.vcd

#Rutas de los archivos de simulación del verilog del touch	
SIM_TOUCH = $(BUILD)/tb_touch_frontend
VCD_TOUCH = $(BUILD)/tb_touch_frontend.vcd

#Rutas de los archivos de simulación del verilog del input_control
SIM_INPUT = $(BUILD)/tb_input_control
VCD_INPUT = $(BUILD)/tb_input_control.vcd

.PHONY: sim wave sim-touch wave-touch sim-input wave-input clean

$(BUILD):
	mkdir -p $(BUILD)

#-----------------MCD
sim: $(BUILD)
	iverilog -g2012 \
		-I rtl/core \
		-o $(SIM) \
		sim/tb_mcd.v
	vvp $(SIM)

wave:
	test -f $(VCD)
	$(SURFER) $(VCD)


#-----------------Touch
sim-touch: $(BUILD)
	iverilog -g2012 \
		-I rtl/ui \
		-o $(SIM_TOUCH) \
		rtl/ui/sync_2ff.v \
		rtl/ui/edge_pulse.v \
		rtl/ui/touch_frontend.v \
		sim/tb_touch_frontend.v
	vvp $(SIM_TOUCH)

wave-touch:
	test -f $(VCD_TOUCH)
	$(SURFER) $(VCD_TOUCH)


#-----------------Input Control
sim-input: $(BUILD)
	iverilog -g2012 \
		-I rtl/ui \
		-o $(SIM_INPUT) \
		rtl/ui/input_control.v \
		sim/tb_input_control.v
	vvp $(SIM_INPUT)


wave-input:
	test -f $(VCD_INPUT)
	$(SURFER) $(VCD_INPUT)

#-----------------clean
clean:
	rm -rf $(BUILD)