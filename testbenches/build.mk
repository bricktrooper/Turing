include config.mk

ifeq ($(SRC),)
$(error 'SRC' was not specified)
else ifeq ($(DUT),)
$(error 'DUT' was not specified)
else ifeq ($(TB),)
$(error 'TB' was not specified)
endif

FLAGS += -Wanachronisms
FLAGS += -Wimplicit
FLAGS += -Wimplicit-dimensions
FLAGS += -Wmacro-redefinition
FLAGS += -Wmacro-replacement
FLAGS += -Wportbind
FLAGS += -Wselect-range
FLAGS += -Wtimescale
FLAGS += -Winfloop
FLAGS += -Wsensitivity-entire-vector
FLAGS += -Wsensitivity-entire-array
#FLAGS += -Wfloating-nets

FLAGS += -g2005

ifeq ($(WAVES),1)
FLAGS += -D WAVES
endif

ART += sim_build
ART += results.xml
ART += __pycache__
ART += ../__pycache__
ART += *.out

SIM ?= icarus
TOPLEVEL_LANG ?= verilog
VERILOG_SOURCES = $(SRC)
TOPLEVEL = $(DUT)
MODULE = $(TB)
COMPILE_ARGS = $(FLAGS)

export COCOTB_LOG_LEVEL = ERROR
export COCOTB_REDUCED_LOG_FMT
export PYTHONPATH = ../

include $(shell cocotb-config --makefiles)/Makefile.sim

simulate: sim

waves: simulate

compile: $(SRC)
	@for source in $(SRC); do echo "IVERILOG $$source"; done
	@iverilog $(FLAGS) -o sim.out $^

clean::
	@for artifact in $(ART); do echo "RM $$artifact"; done
	@rm -rf $(ART)

clean-waves: clean
	@echo "RM *.vcd"
	@rm -rf *.vcd
