GHDL=ghdl
GTKWAVE=gtkwave
WORKDIR=sim/work
WAVES=sim/waveform
TB=testbench

all: mkdir run

mkdir:
	mkdir -p $(WORKDIR) $(WAVES)

analyse: mkdir
	$(GHDL) -a --std=08 --workdir=$(WORKDIR) src/*.vhdl tb/*.vhdl

elaborate: mkdir
	$(GHDL) -e --std=08 --workdir=$(WORKDIR) $(TB)

run: analyse elaborate
	$(GHDL) -r --std=08 --workdir=$(WORKDIR) $(TB) --vcd=$(WAVES)/$(TB).vcd --stop-time=1000ns

view: mkdir
	$(GTKWAVE) $(WAVES)/$(TB).vcd

clean:
	rm -rf $(WORKDIR)/*.cf $(WAVES)/*.vcd
