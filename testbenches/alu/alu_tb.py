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

	clock.stop()
