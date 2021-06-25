SIM = iverilog

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
FLAGS += -Wfloating-nets

FLAGS += -g 2005

SRC += adder.v
SRC += adder_tb.v

EXE = adder.sim

ART = $(EXE)

all: $(EXE) simulate

$(EXE): $(SRC)
	@echo "COMPILE: $(SRC)"
	@$(SIM) $(FLAGS) -o $@ $^

.PHONY:
simulate:
	@echo "SIMULATE: $(EXE)"
	@./$(EXE)

.PHONY:
clean:
	@echo "RM $(ART)"
	@rm -rf $(ART)

.PHONY:
clean-all:
	@echo "RM $(ART) $(wildcard *.vcd)"
	@rm -rf $(ART) *.vcd
