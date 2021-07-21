import log
import cocotb

from math import pow
from clock import Clock

async def sweep(dut, clock):
	clock.reset()
	N = dut.N
	VALUES = int(pow(2, N))

	dut.i_reset <= 1
	await clock.next()
	dut.i_reset <= 0
	dut.i_start <= 1

	for multiplicand in range(VALUES):
		for multiplier in range(VALUES):
			dut.i_multiplicand <= multiplicand
			dut.i_multiplier <= multiplier

			cycles = 0
			while cycles == 0 or not dut.o_finished.value:
				await clock.next(hold = True)   # hold to allow o_finished to change
				cycles += 1

			expected = multiplicand * multiplier
			actual = dut.o_product.value.integer

			if actual != expected:
				log.error(f"{multiplicand} * {multiplier} != {actual}")
				log.info(f"multiplicand : {multiplicand}")
				log.info(f"multiplier   : {multiplier}")
				log.info(f"product      : {actual}")
				exit(-1)

			log.success(f"{multiplicand} * {multiplier} = {expected}")

			if cycles != N:
				log.error(f"Latency was {cycles} cycles instead of {N}")
				exit(-1)

	dut.i_start <= 0
	await clock.next()

@cocotb.test()
async def testbench(dut):
	clock = Clock(dut.i_clock, 10)
	clock.print()
	clock.start()

	await sweep(dut, clock)

	clock.stop()
