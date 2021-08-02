import log
import cocotb

from math import pow, floor
from clock import Clock

async def sweep(dut, clock):
	clock.reset()
	N = int(dut.N)
	VALUES = int(pow(2, N))

	dut.i_reset <= 1
	await clock.next()
	dut.i_reset <= 0
	dut.i_start <= 1

	for dividend in range(VALUES):
		for divisor in range(VALUES):
			dut.i_dividend <= dividend
			dut.i_divisor <= divisor

			cycles = 0
			while cycles == 0 or not dut.o_finished.value:
				await clock.next(hold = True)   # hold to allow o_finished to change
				cycles += 1

			# check divide by zero (undefined)
			undefined = dut.o_undefined.value.integer

			if divisor == 0:
				if undefined != 1:
					log.error(f"Undefined was not asserted for divisor = {divisor}")
					exit(-1)
				else:
					log.info(f"Skip {dividend} / {divisor}")
					log.info(f"Skip {dividend} % {divisor}")
					continue

			if divisor != 0 and undefined != 0:
				log.error(f"Undefined was asserted for divisor = {divisor}")
				exit(-1)

			# check quotient
			expected = floor(dividend / divisor)
			actual = dut.o_quotient.value.integer

			if actual != expected:
				log.error(f"{dividend} / {divisor} != {actual}")
				log.info(f"dividend  : {dividend}")
				log.info(f"divisor   : {divisor}")
				log.info(f"quotient  : {actual}")
				exit(-1)

			log.success(f"{dividend} / {divisor} = {expected}")

			# check remainder (modulus)
			expected = dividend % divisor
			actual = dut.o_remainder.value.integer

			if actual != expected:
				log.error(f"{dividend} % {divisor} != {actual}")
				log.info(f"dividend  : {dividend}")
				log.info(f"divisor   : {divisor}")
				log.info(f"remainder : {actual}")
				exit(-1)

			log.success(f"{dividend} % {divisor} = {expected}")

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
