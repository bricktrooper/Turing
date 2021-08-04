from re import L
from warnings import resetwarnings
import log
import cocotb

from math import pow
from clock import Clock
from cocotb.binary import BinaryValue

LEFT = 1
RIGHT = 0

SHIFT = 0
ROTATE = 1

def print_io(input, output, direction, iterations, rotate):
	log.info(f"input      : {input}")
	log.info(f"output     : {output}")
	log.info(f"direction  : {direction}")
	log.info(f"iterations : {iterations}")
	log.info(f"rotate     : {rotate}")

def calculate_shift(N, value, iterations, direction):
	result = None
	if (direction == LEFT):
		result = BinaryValue(n_bits = N + iterations, value = value << iterations, bigEndian = False)
		result = result[N - 1 : 0]
	elif (direction == RIGHT):
		result = BinaryValue(n_bits = N, value = value >> iterations, bigEndian = False)
	else:
		log.error(f"Invalid direction '{direction}'")
		exit(-1)

	return result

def calculate_rotation(N, value, iterations, direction):
	result = BinaryValue(n_bits = N, value = value, bigEndian = False)
	for i in range(iterations):
		result = BinaryValue(n_bits = N, value = result.integer, bigEndian = False)
		msb = result[N - 1].integer
		lsb = result[0].integer
		result = calculate_shift(N, result, 1, direction)
		if (direction == LEFT):
			result[0] = msb
		elif (direction == RIGHT):
			result[N - 1] = lsb
		else:
			log.error(f"Invalid direction '{direction}'")
			exit(-1)
	return result

def calculate_expected(N, value, iterations, direction, rotate):
	if (rotate == SHIFT):
		return calculate_shift(N, value, iterations, direction)
	elif (rotate == ROTATE):
		return calculate_rotation(N, value, iterations, direction)
	else:
		log.error(f"Invalid rotate flag '{rotate}'")
		exit(-1)

def get_symbol(value, iterations, direction, rotate):
	if (rotate == SHIFT and direction == LEFT):
		return "<<"
	elif (rotate == SHIFT and direction == RIGHT):
		return ">>"
	elif (rotate == ROTATE and direction == LEFT):
		return "<<|"
	elif (rotate == ROTATE and direction == RIGHT):
		return "|>>"
	else:
		log.error(f"Invalid direction '{direction}' and/or rotate flag '{rotate}'")
		exit(-1)

async def sweep(dut, clock):
	clock.reset()
	N = int(dut.N)
	VALUES = int(pow(2, N))
	LEFT = 1
	RIGHT = 0

	dut.i_reset <= 1
	await clock.next()
	dut.i_reset <= 0
	dut.i_start <= 1

	# LEFT SHIFT #

	for rotate in (SHIFT, ROTATE):
		for direction in (LEFT, RIGHT):
			for iterations in range(VALUES):
				for value in range(VALUES):
					dut.i_value <= value
					dut.i_iterations <= iterations
					dut.i_rotate <= rotate
					dut.i_direction <= direction

					cycles = 0
					if iterations == 0:
						await clock.stall()   # finishes instantaneously so allow o_finished to change
					else:
						while cycles == 0 or not dut.o_finished.value:
							await clock.next(hold = True)   # hold to allow o_finished to change
							cycles += 1

					expected = calculate_expected(N, value, iterations, direction, rotate)
					actual = dut.o_value.value.integer
					symbol = get_symbol(N, iterations, direction, rotate)
					value = BinaryValue(n_bits = N, value = value, bigEndian = False)

					if actual != expected:
						log.error(f"{value} {symbol} {iterations} != {actual}")
						print_io(value, actual, direction, iterations, rotate)
						exit(-1)

					log.success(f"{value} {symbol} {iterations} = {expected}")

					if cycles != iterations:
						log.error(f"Latency was {cycles} cycles instead of {iterations}")
						exit(-1)

					await clock.next()   # wait an extra cycle for the busy register to clear

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
