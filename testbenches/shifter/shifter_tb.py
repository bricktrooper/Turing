import log
import cocotb

from math import pow
from clock import Clock

def print_io(input, output, direction, iterations, rotate):
	log.info(f"input      : {input}")
	log.info(f"output     : {output}")
	log.info(f"direction  : {direction}")
	log.info(f"iterations : {iterations}")
	log.info(f"rotate     : {rotate}")

async def sweep(dut, clock):
	clock.reset()
	N = dut.N
	VALUES = int(pow(2, N))
	LEFT = 1
	RIGHT = 0

	dut.i_reset <= 1
	await clock.next()
	dut.i_reset <= 0
	dut.i_start <= 1

	# LEFT SHIFT #

	rotate = 0
	direction = 1
	out = bin(0b1011 << 1)
	print(out[0:3])

	for rotate in (0,1):
		for direction in (LEFT, RIGHT):
			for iterations in range(VALUES):
				for value in range(VALUES):
					#print(rotate, direction, iterations, value)

					#dut.i_value <= value
					#dut.i_rotate <= rotate
					#dut.i_direction <= direction

					#cycles = 0
					#while cycles == 0 or not dut.o_finished.value:
					#	await clock.next(hold = True)   # hold to allow o_finished to change
					#	cycles += 1

					expected = value >> iterations

					#actual = dut.o_value.value.integer

					#if actual != expected:
					#	log.error(f"{value} >> {iterations} != {actual}")
					#	print_io(value, actual, direction, iterations, rotate)
					#	exit(-1)

					#log.success(f"{value} >> {iterations} == {expected}")

					#if cycles != N:
					#	log.error(f"Latency was {cycles} cycles instead of {N}")
					#	exit(-1)

	dut.i_start <= 0
	await clock.next()

	# ROTATOR #

@cocotb.test()
async def testbench(dut):
	clock = Clock(dut.i_clock, 10)
	clock.print()
	clock.start()

	await sweep(dut, clock)

	clock.stop()