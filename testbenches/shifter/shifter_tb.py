import log
import cocotb

from clock import Clock
from cocotb.binary import BinaryValue

LEFT = 1
RIGHT = 0

SHIFT = 0
ROTATE = 1

def get_symbol(direction, rotate):
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

def predict_result(N, value, direction, iterations, rotate):
	result = value
	mask = (2 ** N) - 1

	for i in range(iterations):
		if (rotate == SHIFT and direction == LEFT):
			result = (result << 1) & mask
		elif (rotate == SHIFT and direction == RIGHT):
			result = (result >> 1) & mask
		elif (rotate == ROTATE and direction == LEFT):
			msb = result & (0x1 << (N - 1)) != 0
			result = (result << 1) & mask
			if msb:
				result |= 0x1
		elif (rotate == ROTATE and direction == RIGHT):
			lsb = result & 0x1 != 0
			result = (result >> 1) & mask
			if lsb:
				result |= (0x1 << (N - 1))
		else:
			log.error(f"Invalid direction '{direction}' and/or rotate flag '{rotate}'")
			exit(-1)

	return result

def print_io(N, value, result, direction, iterations, rotate):
	log.info("============== I/O ==============")
	log.info(f"N            : {N} b")
	log.info(f"i_value      : {value}")
	log.info(f"o_result     : {result}")
	log.info(f"i_direction  : {direction}")
	log.info(f"i_iterations : {iterations}")
	log.info(f"i_rotate     : {rotate}")
	log.info("=================================")

def verify(N, cycles, value, result, direction, iterations, rotate):
	expected_result = predict_result(N, value, direction, iterations, rotate)

	symbol = get_symbol(direction, rotate)
	value = BinaryValue(n_bits = N, value = value, bigEndian = False)
	result = BinaryValue(n_bits = N, value = result, bigEndian = False)

	if result != expected_result:
		log.error(f"{value} {symbol} {iterations} != {result}")
		print_io(N, value, result, direction, iterations, rotate)
		exit(-1)

	log.success(f"{value} {symbol} {iterations} = {result}")

	if cycles != iterations:
		log.error(f"Latency was {cycles} cycles instead of {N}")
		exit(-1)

async def sweep(dut, clock):
	clock.reset()
	N = int(dut.N)
	VALUES = 2 ** N
	LEFT = 1
	RIGHT = 0

	dut.i_reset <= 1
	await clock.next()
	dut.i_reset <= 0
	dut.i_start <= 1

	# LEFT SHIFT #

	for rotate in (SHIFT, ROTATE):
		for direction in (LEFT, RIGHT):
			for value in range(VALUES):
				for iterations in range(VALUES):
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

					result = dut.o_result.value.integer
					verify(N, cycles, value, result, direction, iterations, rotate)

					await clock.next()   # wait an extra cycle for the busy register to clear

	dut.i_start <= 0
	await clock.next()

@cocotb.test()
async def testbench(dut):
	clock = Clock(dut.i_clock, 10)
	clock.print()
	clock.start()

	await sweep(dut, clock)

	clock.stop()
