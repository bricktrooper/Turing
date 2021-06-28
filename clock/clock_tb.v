module ClockTB;

	parameter CLOCK_PERIOD = 10;

	reg i_enable;
	wire o_clock;

	Clock #(.PERIOD(CLOCK_PERIOD)) clock
	(
		.i_enable(i_enable),
		.o_clock(o_clock)
	);

	initial begin
		$dumpfile("clock.vcd");
		$dumpvars(0);

		// test enable
		i_enable = 1;
		# (CLOCK_PERIOD * 4);
		i_enable = 0;
		# (CLOCK_PERIOD * 2);

		// test gating
		i_enable = 1;
		# (CLOCK_PERIOD / 10)
		i_enable = 0;
		# (CLOCK_PERIOD * 2)
		i_enable = 1;
		# (CLOCK_PERIOD * 2)

		$finish;
	end

endmodule
