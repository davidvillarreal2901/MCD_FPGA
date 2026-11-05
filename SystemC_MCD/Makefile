# Compilar desde SystemC_MCD: make test
# macOS / Homebrew: brew install systemc
# Linux: instalar libsystemc-dev y libsystemc
CXX ?= c++
SYSTEMC_PREFIX ?= $(shell if command -v brew >/dev/null 2>&1; then brew --prefix systemc 2>/dev/null; elif test -f /usr/include/systemc.h; then echo /usr; else echo /usr/local; fi)
CXXFLAGS ?= -std=c++17 -O2 -Wall -Wextra
CPPFLAGS += -I$(SYSTEMC_PREFIX)/include -I../mcd_systemc
LDFLAGS += -L$(SYSTEMC_PREFIX)/lib -Wl,-rpath,$(SYSTEMC_PREFIX)/lib
LDLIBS += -lsystemc -pthread
WAVE_VIEWER ?= surfer
BIN = build/mcd_tb

.PHONY: all test wave clean
all: $(BIN)

$(BIN): mcd_tb.cpp control.h datapath.h mcd.h ../mcd_systemc/stim.h ../mcd_systemc/mon.h
	mkdir -p build
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) mcd_tb.cpp -o $@ $(LDFLAGS) $(LDLIBS)

test: $(BIN)
	./$(BIN)

wave: build/mcd.vcd
	$(WAVE_VIEWER) $<

build/mcd.vcd: $(BIN)
	./$(BIN)

clean:
	rm -rf build
