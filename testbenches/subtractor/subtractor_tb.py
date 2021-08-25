import log
import cocotb

from clock import Clock

def predict_output(N, minuend, subtrahend):
	if minuend < subtrahend:
		difference = (2 ** N) - (subtrahend - minuend)
		borrow = 1
	else:
		difference = minuend - subtrahend
		borrow = 0
	return (difference, borrow)

def print_io(N, minuend, subtrahend, difference, borrow):
	log.info("============== I/O ==============")
	log.info(f"N            : {N} b")
	log.info(f"i_minuend    : {minuend}")
	log.info(f"i_subtrahend : {subtrahend}")
	log.info(f"o_difference : {difference}")
	log.info(f"o_borrow     : {borrow}")
	log.info("=================================")

def verify(N, minuend, subtrahend, difference, borrow):
	(expected_difference, expected_borrow) = predict_output(N, minuend, subtrahend)

	borrow_string = None
	if borrow == 1:
		borrow_string = "with borrow"
	else:
		borrow_string = "without borrow"

	if difference != expected_difference:
		log.error(f"{minuend} - {subtrahend} != {difference} {borrow_string}")
		print_io(N, minuend, subtrahend, difference, borrow)
		exit(-1)

	if borrow != expected_borrow:
		log.error(f"{minuend} - {subtrahend} != {difference} {borrow_string}")
		print_io(N, minuend, subtrahend, difference, borrow)
		exit(-1)

	log.success(f"{minuend} - {subtrahend} = {difference} {borrow_string}")

async def sweep(dut, clock):
	clock.reset()
	N = int(dut.N)
	VALUES = 2 ** N

	for minuend in range(VALUES):
		for subtrahend in range(VALUES):
			dut.i_minuend <= minuend
			dut.i_subtrahend <= subtrahend
			await clock.next()

			difference = dut.o_difference.value.integer
			borrow = dut.o_borrow.value.integer

			verify(N, minuend, subtrahend, difference, borrow)

@cocotb.test()
async def testbench(dut):
	clock = Clock(dut.i_clock, 10)
	clock.print()
	clock.start()

	await sweep(dut, clock)

	clock.stop()
