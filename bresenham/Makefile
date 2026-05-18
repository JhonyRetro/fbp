GHDL=ghdl
GTKWAVE=gtkwave
WORKDIR=sim/work
WAVES=sim/waveform
TB=testbench

all: mkdir run

mkdir:
	mkdir -p $(WORKDIR) $(WAVES)

analyse: mkdir
	$(GHDL) -a --workdir=$(WORKDIR) src/*.vhdl tb/*.vhdl

elaborate: mkdir
	$(GHDL) -e --workdir=$(WORKDIR) $(TB)

run: analyse elaborate
	$(GHDL) -r --workdir=$(WORKDIR) $(TB) --vcd=$(WAVES)/$(TB).vcd

view: mkdir
	$(GTKWAVE) $(WAVES)/$(TB).vcd

clean:
	rm -rf $(WORKDIR)/*.cf $(WAVES)/*.vcd
