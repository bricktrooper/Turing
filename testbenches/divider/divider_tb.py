import log
import cocotb

from math import floor
from clock import Clock

def predict_output(N, dividend, divisor):
	if divisor == 0:
		quotient = 0    # don't care
		remainder = 0   # don't care
		undefined = 1
	else:
		quotient = floor(dividend / divisor)
		remainder = dividend % divisor
		undefined = 0
	return (quotient, remainder, undefined)

def print_io(N, dividend, divisor, quotient, remainder, undefined):
	log.info("============== I/O ==============")
	log.info(f"N           : {N} b")
	log.info(f"i_dividend  : {dividend}")
	log.info(f"i_divisor   : {divisor}")
	log.info(f"o_quotient  : {quotient}")
	log.info(f"o_remainder : {remainder}")
	log.info(f"o_undefined : {undefined}")
	log.info("=================================")

def verify(N, cycles, dividend, divisor, quotient, remainder, undefined):
	(expected_quotient, expected_remainder, expected_undefined) = predict_output(N, dividend, divisor)

	undefined_string = None
	if undefined == 1:
		undefined_string = "undefined"
	else:
		undefined_string = "defined"

	# check divide by zero (undefined)
	if undefined != expected_undefined:
		log.error(f"{dividend} / {divisor} is not {undefined_string}")
		log.error(f"{dividend} % {divisor} is not {undefined_string}")
		print_io(N, dividend, divisor, quotient, remainder, undefined)
		exit(-1)

	if undefined:
		log.success(f"{dividend} / {divisor} is {undefined_string}")
		log.success(f"{dividend} % {divisor} is {undefined_string}")
		return

	# check quotient
	if quotient != expected_quotient:
		log.error(f"{dividend} / {divisor} != {quotient}")
		print_io(N, dividend, divisor, quotient, remainder, undefined)
		exit(-1)

	log.success(f"{dividend} / {divisor} = {quotient}")

	# check remainder (modulus)
	if remainder !=expected_remainder:
		log.error(f"{dividend} % {divisor} != {remainder}")
		print_io(N, dividend, divisor, quotient, remainder, undefined)
		exit(-1)

	log.success(f"{dividend} % {divisor} = {remainder}")

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

	for dividend in range(VALUES):
		for divisor in range(VALUES):
			dut.i_dividend <= dividend
			dut.i_divisor <= divisor

			cycles = 0
			while cycles == 0 or not dut.o_finished.value:
				await clock.next(hold = True)   # hold to allow o_finished to change
				cycles += 1

			undefined = dut.o_undefined.value.integer
			quotient = dut.o_quotient.value.integer
			remainder = dut.o_remainder.value.integer

			verify(N, cycles, dividend, divisor, quotient, remainder, undefined)

	dut.i_start <= 0
	await clock.next()

@cocotb.test()
async def testbench(dut):
	clock = Clock(dut.i_clock, 10)
	clock.print()
	clock.start()

	await sweep(dut, clock)

	clock.stop()
