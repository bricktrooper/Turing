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
	$(MAKE) WAVES=1 -C adder
	$(MAKE) WAVES=1 -C subtractor
	$(MAKE) WAVES=1 -C multiplier
	$(MAKE) WAVES=1 -C divider
	$(MAKE) WAVES=1 -C comparator
	$(MAKE) WAVES=1 -C shifter

.PHONY:
clean:
	$(MAKE) clean-all -C adder
	$(MAKE) clean-all -C subtractor
	$(MAKE) clean-all -C multiplier
	$(MAKE) clean-all -C divider
	$(MAKE) clean-all -C comparator
	$(MAKE) clean-all -C shifter
