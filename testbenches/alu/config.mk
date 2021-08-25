DUT = ALU_TB
TB = alu_tb

CIRCUITS = ../../circuits

SRC += $(CIRCUITS)/adder.v
SRC += $(CIRCUITS)/subtractor.v
SRC += $(CIRCUITS)/multiplier.v
SRC += $(CIRCUITS)/divider.v
SRC += $(CIRCUITS)/comparator.v
SRC += $(CIRCUITS)/shifter.v
SRC += $(CIRCUITS)/alu.v
SRC += alu_tb.v
