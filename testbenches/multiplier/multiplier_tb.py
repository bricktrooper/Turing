import log
import cocotb

from math import pow, prod
from clock import Clock
from cocotb.binary import BinaryValue

def calculate_product(N, multiplicand, multiplier):
	product = BinaryValue(n_bits = 2 * N, value = multiplicand * multiplier, bigEndian = False)
	overflow = int(product[(2 * N) - 1 : N] != 0)
	product = product[N - 1 : 0].integer
	return (product, overflow)

def print_io(multiplicand, multiplier, product, overflow):
	log.info(f"multiplicand : {multiplicand}")
	log.info(f"multiplier   : {multiplier}")
	log.info(f"product      : {product}")
	log.info(f"overflow     : {overflow}")

async def sweep(dut, clock):
	clock.reset()
	N = int(dut.N)
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

			(expected_product, expected_overflow) = calculate_product(N, multiplicand, multiplier)
			actual_product = dut.o_product.value.integer
			actual_overflow = dut.o_overflow.value.integer

			has_overflow = None
			if actual_overflow == 1:
				has_overflow = "with"
			else:
				has_overflow = "without"

			if actual_product != expected_product or actual_overflow != expected_overflow:
				log.error(f"{multiplicand} * {multiplier} != {actual_product} {has_overflow} overflow")
				print_io(multiplicand, multiplier, actual_product, actual_overflow)
				exit(-1)

			log.success(f"{multiplicand} * {multiplier} = {actual_product} {has_overflow} overflow")

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
