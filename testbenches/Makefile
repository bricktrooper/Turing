.PHONY:
simulate:
	$(MAKE) -C adder
	$(MAKE) -C subtractor
	$(MAKE) -C multiplier
	$(MAKE) -C divider
	$(MAKE) -C comparator
	$(MAKE) -C shifter

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
