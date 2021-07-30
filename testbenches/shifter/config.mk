DUT = ShifterTB
TB = shifter_tb

CIRCUITS = ../../circuits

SRC += $(CIRCUITS)/shifter.v
SRC += $(CIRCUITS)/adder.v
SRC += $(CIRCUITS)/comparator.v
SRC += shifter_tb.v
