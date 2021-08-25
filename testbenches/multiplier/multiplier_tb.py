import log
import cocotb

from clock import Clock

def predict_output(N, multiplicand, multiplier):
	if multiplicand * multiplier > (2 ** N) - 1:
		product = (multiplicand * multiplier) % (2 ** N)
		overflow = 1
	else:
		product = multiplicand * multiplier
		overflow = 0
	return (product, overflow)

def print_io(N, multiplicand, multiplier, product, overflow):
	log.info("============== I/O ==============")
	log.info(f"N              : {N} b")
	log.info(f"i_multiplicand : {multiplicand}")
	log.info(f"i_multiplier   : {multiplier}")
	log.info(f"o_product      : {product}")
	log.info(f"o_overflow     : {overflow}")
	log.info("=================================")

def verify(N, cycles, multiplicand, multiplier, product, overflow):
	(expected_product, expected_overflow) = predict_output(N, multiplicand, multiplier)

	overflow_string = None
	if overflow == 1:
		overflow_string = "with overflow"
	else:
		overflow_string = "without overflow"

	if product != expected_product:
		log.error(f"{multiplicand} * {multiplier} != {product} {overflow_string}")
		print_io(N, multiplicand, multiplier, product, overflow)
		exit(-1)

	if overflow != expected_overflow:
		log.error(f"{multiplicand} * {multiplier} != {product} {overflow_string}")
		print_io(N, multiplicand, multiplier, product, overflow)
		exit(-1)

	log.success(f"{multiplicand} * {multiplier} = {product} {overflow_string}")

	if cycles != N:
		log.error(f"Latency was {cycles} cycles instead of {N}")
		exit(-1)

async def sweep(dut, clock):
	clock.reset()
	N = int(dut.N)
	VALUES = 2 ** N

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

			product = dut.o_product.value.integer
			overflow = dut.o_overflow.value.integer

			verify(N, cycles, multiplicand, multiplier, product, overflow)

	dut.i_start <= 0
	await clock.next()

@cocotb.test()
async def testbench(dut):
	clock = Clock(dut.i_clock, 10)
	clock.print()
	clock.start()

	await sweep(dut, clock)

	clock.stop()
