import log
import cocotb

from math import pow
from clock import Clock
from cocotb.binary import BinaryValue

def join(difference, borrow):
	BITS = difference.n_bits
	value = BinaryValue(n_bits = BITS + 1,
	                    bigEndian = False,
						value = difference.integer + (borrow.integer << BITS))
	return value.signed_integer

async def sweep(dut, clock):
	clock.reset()
	N = dut.N
	VALUES = int(pow(2, N))

	for minuend in range(VALUES):
		for subtrahend in range(VALUES):
			dut.i_minuend <= minuend
			dut.i_subtrahend <= subtrahend
			await clock.next()

			expected = minuend - subtrahend
			actual = join(dut.o_difference.value, dut.o_borrow.value)

			difference = dut.o_difference.value.integer
			borrow = dut.o_borrow.value.integer

			if actual != expected:
				log.error(f"{minuend} - {subtrahend} != {actual}")
				log.info(f"minuend    : {minuend}")
				log.info(f"subtrahend : {subtrahend}")
				log.info(f"difference : {difference}")
				log.info(f"borrow     : {borrow}")
				exit(-1)

			log.success(f"{minuend} - {subtrahend} = {expected}")

@cocotb.test()
async def testbench(dut):
	clock = Clock(dut.i_clock, 10)
	clock.print()
	clock.start()

	await sweep(dut, clock)

	clock.stop()
