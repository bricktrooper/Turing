import log
import cocotb

from math import pow
from clock import Clock

def print_io(left, right, greater, equal, less, greater_equal, not_equal, less_equal):
	log.info(f"left          : {left}")
	log.info(f"right         : {right}")
	log.info(f"greater       : {greater}")
	log.info(f"equal         : {equal}")
	log.info(f"less          : {less}")
	log.info(f"greater_equal : {greater_equal}")
	log.info(f"not_equal     : {not_equal}")
	log.info(f"less_equal    : {less_equal}")

async def sweep(dut, clock):
	clock.reset()
	N = dut.N
	VALUES = int(pow(2, N))

	for left in range(VALUES):
		for right in range(VALUES):
			dut.i_left <= left
			dut.i_right <= right
			await clock.next()

			# get output values
			greater = dut.o_greater.value
			equal = dut.o_equal.value
			less = dut.o_less.value
			greater_equal = dut.o_greater_equal.value
			not_equal = dut.o_not_equal.value
			less_equal = dut.o_less_equal.value

			# greater than
			expected = left > right
			actual = greater

			if actual != expected:
				log.error(f"{left} > {right} is not {bool(actual)}")
				print_io(left, right, greater, equal, less, greater_equal, not_equal, less_equal)
				return

			log.success(f"{left} > {right} is {bool(actual)}")

			# equal to
			expected = left == right
			actual = equal

			if actual != expected:
				log.error(f"{left} == {right} is not {bool(actual)}")
				print_io(left, right, greater, equal, less, greater_equal, not_equal, less_equal)
				return

			log.success(f"{left} == {right} is {bool(actual)}")

			# less than
			expected = left < right
			actual = less

			if actual != expected:
				log.error(f"{left} < {right} is not {bool(actual)}")
				print_io(left, right, greater, equal, less, greater_equal, not_equal, less_equal)
				return

			log.success(f"{left} < {right} is {bool(actual)}")

			# greater than or equal to
			expected = left >= right
			actual = greater_equal

			if actual != expected:
				log.error(f"{left} >= {right} is not {bool(actual)}")
				print_io(left, right, greater, equal, less, greater_equal, not_equal, less_equal)
				return

			log.success(f"{left} >= {right} is {bool(actual)}")

			# not equal to
			expected = left != right
			actual = not_equal

			if actual != expected:
				log.error(f"{left} != {right} is not {bool(actual)}")
				print_io(left, right, greater, equal, less, greater_equal, not_equal, less_equal)
				return

			log.success(f"{left} != {right} is {bool(actual)}")

			# less than or equal to
			expected = left <= right
			actual = less_equal

			if actual != expected:
				log.error(f"{left} <= {right} is not {bool(actual)}")
				print_io(left, right, greater, equal, less, greater_equal, not_equal, less_equal)
				return

			log.success(f"{left} <= {right} is {bool(actual)}")

@cocotb.test()
async def testbench(dut):
	clock = Clock(dut.i_clock, 10)
	clock.print()
	clock.start()

	await sweep(dut, clock)

	clock.stop()
