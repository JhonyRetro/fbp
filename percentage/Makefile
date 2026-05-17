GHDL=ghdl
GTKWAVE=gtkwave
WORKDIR=sim/work
WAVES=sim/waveform
TB=tb

all: run

analyse:
	$(GHDL) -a --workdir=$(WORKDIR) src/*.vhdl tb/*.vhdl

elaborate:
	$(GHDL) -e --workdir=$(WORKDIR) $(TB)

run: analyse elaborate
	$(GHDL) -r --workdir=$(WORKDIR) $(TB) --vcd=$(WAVES)/$(TB).vcd

view:
	$(GTKWAVE) $(WAVES)/$(TB).vcd

clean:
	rm -rf $(WORKDIR)/*.cf $(WAVES)/*.vcd
