# Makefile - MCD en SystemC
# Uso:
#   make            compila
#   make run        compila y simula (genera mcd_sc.vcd)
#   make wave       abre las formas de onda en GTKWave
#   make clean
#
# Si SystemC esta instalado en otra ruta (p. ej. /usr/local/systemc-2.3.4):
#   make SYSTEMC_HOME=/usr/local/systemc-2.3.4

SYSTEMC_HOME ?= /usr
SC_INC  := $(SYSTEMC_HOME)/include
SC_LIBS := $(wildcard $(SYSTEMC_HOME)/lib-linux64 $(SYSTEMC_HOME)/lib64 \
                      $(SYSTEMC_HOME)/lib $(SYSTEMC_HOME)/lib/x86_64-linux-gnu)

CXX      ?= g++
CXXFLAGS ?= -std=c++17 -O2 -Wall -Wno-deprecated
CXXFLAGS += -I$(SC_INC) -I.
LDFLAGS  := $(foreach d,$(SC_LIBS),-L$(d) -Wl,-rpath,$(d))
LDLIBS   := -lsystemc -lm

TARGET := mcd_sim
SRC    := main.cc
HDRS   := mux2.h reg8.h or8.h restador1.h restador8.h datapath.h fsm.h mcd_top.h stim.h mon.h
VCD    := mcd_sc.vcd

all: $(TARGET)

$(TARGET): $(SRC) $(HDRS)
	$(CXX) $(CXXFLAGS) $(SRC) -o $@ $(LDFLAGS) $(LDLIBS)

run: $(TARGET)
	./$(TARGET)

wave: run
	GSETTINGS_BACKEND=memory gtkwave $(VCD) &

clean:
	rm -f $(TARGET) $(VCD)

.PHONY: all run wave clean
