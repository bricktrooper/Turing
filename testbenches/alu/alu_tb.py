import log
import cocotb

from clock import Clock
from adder import adder_tb as adder

def verify(N, cycles, opcode, A, B, Y):
	(sum, carry) = adder.predict_output(N, A, B)
	if Y != sum:
		log.error(f"{A} + {B} != {Y}")
		exit(-1)
	log.success(f"{A} + {B} = {Y}")

async def sweep(dut, clock):
	N = int(dut.N)
	MAX_VALUE = 2 ** N

	for opcode in range(1):
		for A in range(MAX_VALUE):
			for B in range(MAX_VALUE):
				dut.opcode <= opcode
				dut.start <= 1
				dut.A <= A
				dut.B <= B

				cycles = 0
				while cycles == 0 or not dut.finished.value:
					await clock.next()
					cycles = cycles + 1

				Y = dut.Y.value.integer
				verify(N, cycles, opcode, A, B, Y)

				dut.start <= 0

@cocotb.test()
async def testbench(dut):
	clock = Clock(dut.clock, 10)
	clock.print()
	clock.start()

	dut.reset <= 1
	await clock.next()
	dut.reset <= 0

	await sweep(dut, clock)

	#await clock.next(dut.N.value)

	clock.stop()
