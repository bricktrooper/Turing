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

FLAGS += -g 2005

ART += sim_build
ART += results.xml
ART += __pycache__
ART += ../__pycache__

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

clean::
	@rm -rf $(ART)

clean-all: clean
	@rm -rf *.vcd
