import log
import cocotb

from clock import Clock

def predict_output(N, left, right):
	greater = left > right
	equal = left == right
	less = left < right
	greater_equal = left >= right
	not_equal = left != right
	less_equal = left <= right
	return (greater, equal, less, greater_equal, not_equal, less_equal)

def print_io(N, left, right, greater, equal, less, greater_equal, not_equal, less_equal):
	log.info("============== I/O ==============")
	log.info(f"N               : {N} b")
	log.info(f"i_left          : {left}")
	log.info(f"i_right         : {right}")
	log.info(f"o_greater       : {greater}")
	log.info(f"o_equal         : {equal}")
	log.info(f"o_less          : {less}")
	log.info(f"o_greater_equal : {greater_equal}")
	log.info(f"o_not_equal     : {not_equal}")
	log.info(f"o_less_equal    : {less_equal}")
	log.info("=================================")

def verify(N, left, right, greater, equal, less, greater_equal, not_equal, less_equal):
	(expected_greater, expected_equal, expected_less, expected_greater_equal, expected_not_equal, expected_less_equal) = predict_output(N, left, right)

	# greater than
	if greater != expected_greater:
		log.error(f"{left} > {right} is not {bool(greater)}")
		print_io(N, left, right, greater, equal, less, greater_equal, not_equal, less_equal)
		exit(-1)

	log.success(f"{left} > {right} is {bool(greater)}")

	# equal to
	if equal != expected_equal:
		log.error(f"{left} == {right} is not {bool(equal)}")
		print_io(N, left, right, greater, equal, less, greater_equal, not_equal, less_equal)
		exit(-1)

	log.success(f"{left} == {right} is {bool(equal)}")

	# less than
	if less != expected_less:
		log.error(f"{left} < {right} is not {bool(less)}")
		print_io(N, left, right, greater, equal, less, greater_equal, not_equal, less_equal)
		exit(-1)

	log.success(f"{left} < {right} is {bool(less)}")

	# greater than or equal to
	if greater_equal != expected_greater_equal:
		log.error(f"{left} >= {right} is not {bool(greater_equal)}")
		print_io(N, left, right, greater, equal, less, greater_equal, not_equal, less_equal)
		exit(-1)

	log.success(f"{left} >= {right} is {bool(greater_equal)}")

	# not equal to
	if not_equal != expected_not_equal:
		log.error(f"{left} != {right} is not {bool(not_equal)}")
		print_io(N, left, right, greater, equal, less, greater_equal, not_equal, less_equal)
		exit(-1)

	log.success(f"{left} != {right} is {bool(not_equal)}")

	# less than or equal to
	if less_equal != expected_less_equal:
		log.error(f"{left} <= {right} is not {bool(less_equal)}")
		print_io(N, left, right, greater, equal, less, greater_equal, not_equal, less_equal)
		exit(-1)

	log.success(f"{left} <= {right} is {bool(less_equal)}")

async def sweep(dut, clock):
	clock.reset()
	N = int(dut.N)
	VALUES = 2 ** N

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

			verify(N, left, right, greater, equal, less, greater_equal, not_equal, less_equal)

@cocotb.test()
async def testbench(dut):
	clock = Clock(dut.i_clock, 10)
	clock.print()
	clock.start()

	await sweep(dut, clock)

	clock.stop()
