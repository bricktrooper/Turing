import log
import cocotb

from math import pow
from clock import Clock
from cocotb.binary import BinaryValue

@cocotb.test()
async def testbench(dut):
	clock = Clock(dut.clock, 10)
	clock.print()
	clock.start()

	#await sweep(dut, clock)
	# TODO: Rewrite the sweep tests but give them the module IO signals as arguments so we can reuse the tests here
	dut.A <= 7
	dut.B <= 3
	dut.opcode <= 1
	await clock.next(dut.N.value)
	#print(dut.Y.value.integer)

	clock.stop()
