import log
import cocotb

from math import pow, floor
from clock import Clock

async def sweep(dut, clock):
	clock.reset()
	N = dut.N
	VALUES = int(pow(2, N))

	dut.i_reset <= 1
	await clock.next()
	dut.i_reset <= 0
	dut.i_start <= 1

	dut.i_dividend <= 11
	dut.i_divisor <= 5
	#await clock.next()
	#dut.i_start <= 0
	await clock.next(int(N)+10)


	for dividend in range(VALUES):
		for divisor in range(VALUES):
			dut.i_dividend <= dividend
			dut.i_divisor <= divisor

			cycles = 0
			while cycles == 0 or not dut.o_finished.value:
				await clock.next(hold = True)   # hold to allow o_finished to change
				cycles += 1

			# check divide by zero
			divide_by_zero = dut.o_divide_by_zero.value.integer

			if divisor == 0:
				if divide_by_zero != 1:
					log.error(f"Divide by zero flag was not asserted for divisor = {divisor}")
					return
				else:
					log.info(f"Skip {dividend} / {divisor}")
					log.info(f"Skip {dividend} % {divisor}")
					continue

			if divisor != 0 and divide_by_zero != 0:
				log.error(f"Divide by zero flag was asserted for divisor = {divisor}")
				return

			# check quotient
			expected = floor(dividend / divisor)
			actual = dut.o_quotient.value.integer

			if actual != expected:
				log.error(f"{dividend} / {divisor} != {actual}")
				log.info(f"dividend  : {dividend}")
				log.info(f"divisor   : {divisor}")
				log.info(f"quotient  : {actual}")
				return

			log.success(f"{dividend} / {divisor} = {expected}")

			# check remainder (modulus)
			expected = dividend % divisor
			actual = dut.o_remainder.value.integer

			if actual != expected:
				log.error(f"{dividend} % {divisor} != {actual}")
				log.info(f"dividend  : {dividend}")
				log.info(f"divisor   : {divisor}")
				log.info(f"remainder : {actual}")
				return

			log.success(f"{dividend} % {divisor} = {expected}")

			if cycles != N:
				log.error(f"Latency was {cycles} cycles instead of {N}")
				return

	dut.i_start <= 0
	await clock.next()

@cocotb.test()
async def testbench(dut):
	clock = Clock(dut.i_clock, 10)
	clock.print()
	clock.start()

	await sweep(dut, clock)

	clock.stop()
