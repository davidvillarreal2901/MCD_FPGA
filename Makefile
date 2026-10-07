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

#Rutas de los archivos de simulación del verilog del sistema completo
SIM_SYSTEM = $(BUILD)/tb_mcd_system
VCD_SYSTEM = $(BUILD)/tb_mcd_system.vcd

#Rutas de los archivos de simulación del verilog del button_frontend
SIM_BUTTON = $(BUILD)/tb_button_frontend
VCD_BUTTON = $(BUILD)/tb_button_frontend.vcd

#Rutas de los archivos de síntesis para la placa Colorlight
COLORLIGHT_BUILD  = $(BUILD)/colorlight
COLORLIGHT_TOP    = top_colorlight

COLORLIGHT_JSON   = $(COLORLIGHT_BUILD)/$(COLORLIGHT_TOP).json
COLORLIGHT_CONFIG = $(COLORLIGHT_BUILD)/$(COLORLIGHT_TOP).config
COLORLIGHT_BIT    = $(COLORLIGHT_BUILD)/$(COLORLIGHT_TOP).bit


.PHONY: sim wave sim-touch wave-touch sim-input wave-input sim-system wave-system sim-button wave-button clean
.PHONY: colorlight-synth colorlight-pnr colorlight-bit colorlight-load

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

#-----------------System
sim-system: $(BUILD)
	iverilog -g2012 \
		-I rtl/core \
		-I rtl/ui \
		-I rtl/system \
		-o $(SIM_SYSTEM) \
		rtl/ui/sync_2ff.v \
		rtl/ui/edge_pulse.v \
		rtl/ui/debounce.v \
		rtl/ui/touch_frontend.v \
		rtl/ui/button_frontend.v \
		rtl/ui/input_control.v \
		rtl/core/mcd_top.v \
		rtl/system/mcd_system.v \
		sim/tb_mcd_system.v
	vvp $(SIM_SYSTEM)

wave-system:
	test -f $(VCD_SYSTEM)
	$(SURFER) $(VCD_SYSTEM)

#-----------------Button
sim-button: $(BUILD)
	iverilog -g2012 \
		-I rtl/ui \
		-o $(SIM_BUTTON) \
		rtl/ui/sync_2ff.v \
		rtl/ui/edge_pulse.v \
		rtl/ui/debounce.v \
		rtl/ui/button_frontend.v \
		sim/tb_button_frontend.v
	vvp $(SIM_BUTTON)


wave-button:
	test -f $(VCD_BUTTON)
	$(SURFER) $(VCD_BUTTON)

#-----------------Colorlight
colorlight-synth:
	mkdir -p $(COLORLIGHT_BUILD)

	yosys -p "\
		read_verilog \
			-Irtl/core \
			-Irtl/ui \
			-Irtl/system \
			rtl/ui/sync_2ff.v \
			rtl/ui/edge_pulse.v \
			rtl/ui/debounce.v \
			rtl/ui/touch_frontend.v \
			rtl/ui/button_frontend.v \
			rtl/ui/input_control.v \
			rtl/core/mcd_top.v \
			rtl/system/mcd_system.v \
			boards/colorlight_i9/top_colorlight.v; \
		synth_ecp5 \
			-top $(COLORLIGHT_TOP) \
			-json $(COLORLIGHT_JSON); \
		stat"


colorlight-pnr: colorlight-synth
	nextpnr-ecp5 \
		--45k \
		--package CABGA381 \
		--json $(COLORLIGHT_JSON) \
		--lpf boards/colorlight_i9/colorlight_i9.lpf \
		--textcfg $(COLORLIGHT_CONFIG) \
		--freq 25


colorlight-bit: colorlight-pnr
	ecppack \
		$(COLORLIGHT_CONFIG) \
		$(COLORLIGHT_BIT)


colorlight-load: colorlight-bit
	openFPGALoader \
		-b colorlight-i9 \
		$(COLORLIGHT_BIT)

#-----------------clean
clean:
	rm -rf $(BUILD)