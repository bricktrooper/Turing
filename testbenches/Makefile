.PHONY:
compile:
	$(MAKE) compile -C adder
	$(MAKE) compile -C subtractor
	$(MAKE) compile -C multiplier
	$(MAKE) compile -C divider
	$(MAKE) compile -C comparator
	$(MAKE) compile -C shifter

.PHONY:
simulate:
	$(MAKE) simulate -C adder
	$(MAKE) simulate -C subtractor
	$(MAKE) simulate -C multiplier
	$(MAKE) simulate -C divider
	$(MAKE) simulate -C comparator
	$(MAKE) simulate -C shifter

.PHONY:
waves:
	$(MAKE) simulate WAVES=1 -C adder
	$(MAKE) simulate WAVES=1 -C subtractor
	$(MAKE) simulate WAVES=1 -C multiplier
	$(MAKE) simulate WAVES=1 -C divider
	$(MAKE) simulate WAVES=1 -C comparator
	$(MAKE) simulate WAVES=1 -C shifter

.PHONY:
clean:
	$(MAKE) clean WAVES=1 -C adder
	$(MAKE) clean WAVES=1 -C subtractor
	$(MAKE) clean WAVES=1 -C multiplier
	$(MAKE) clean WAVES=1 -C divider
	$(MAKE) clean WAVES=1 -C comparator
	$(MAKE) clean WAVES=1 -C shifter
