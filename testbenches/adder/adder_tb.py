import log
import cocotb

from math import pow
from clock import Clock
from cocotb.binary import BinaryValue

def join(sum, carry):
	BITS = sum.n_bits
	value = BinaryValue(n_bits = BITS + 1,
	                    bigEndian = False,
						value = sum.integer + (carry.integer << BITS))
	return value.integer

async def sweep(dut, clock):
	clock.reset()
	N = dut.N
	VALUES = int(pow(2, N))

	for augend in range(VALUES):
		for addend in range(VALUES):
			dut.i_augend <= augend
			dut.i_addend <= addend
			await clock.next()

			expected = augend + addend
			actual = join(dut.o_sum.value, dut.o_carry.value)

			sum = dut.o_sum.value.integer
			carry = dut.o_carry.value.integer

			if actual != expected:
				log.error(f"{augend} + {addend} != {actual}")
				log.info(f"augend : {augend}")
				log.info(f"addend : {addend}")
				log.info(f"sum    : {sum}")
				log.info(f"carry  : {carry}")
				return

			log.success(f"{augend} + {addend} = {expected}")

@cocotb.test()
async def testbench(dut):
	clock = Clock(dut.i_clock, 10)
	clock.print()
	clock.start()

	await sweep(dut, clock)

	clock.stop()
