import log
import cocotb

from math import pow
from clock import Clock
from cocotb.binary import BinaryValue

def join(carry, sum):
	BITS = sum.n_bits
	value = BinaryValue(n_bits = BITS + 1,
	                    bigEndian = False,
						value = sum.integer + (carry.integer << BITS))
	return value

async def sweep(dut, clock):
	clock.reset()
	N = dut.N
	VALUES = int(pow(2, N))

	for x in range(VALUES):
		for y in range(VALUES):
			dut.augend <= x
			dut.addend <= y
			await clock.next()

			expected = x + y
			actual = join(dut.carry.value, dut.sum.value)

			if actual != expected:
				log.error("%u + %u != %u" % (x, y, actual))
				return

			log.success("%u + %u == %u" % (x, y, expected))


@cocotb.test()
async def testbench(dut):
	clock = Clock(dut.clock, 10)
	clock.print()
	clock.start()

	await sweep(dut, clock)

	clock.stop()
