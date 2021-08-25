import log
import cocotb

from clock import Clock

def predict_output(N, augend, addend):
	if augend + addend >  (2 ** N) - 1:
		carry = 1
	else:
		carry = 0
	sum = (augend + addend) % (2 ** N)
	return (sum, carry)

def print_io(N, augend, addend, sum, carry):
	log.info("============== I/O ==============")
	log.info(f"N        : {N} b")
	log.info(f"i_augend : {augend}")
	log.info(f"i_addend : {addend}")
	log.info(f"o_sum    : {sum}")
	log.info(f"o_carry  : {carry}")
	log.info("=================================")

def verify(N, augend, addend, sum, carry):
	(expected_sum, expected_carry) = predict_output(N, augend, addend)

	carry_string = None
	if carry == 1:
		carry_string = "with carry"
	else:
		carry_string = "without carry"

	if sum != expected_sum:
		log.error(f"{augend} + {addend} != {sum} {carry_string}")
		print_io(N, augend, addend, sum, carry)
		exit(-1)

	if carry != expected_carry:
		log.error(f"{augend} + {addend} != {sum} {carry_string}")
		print_io(N, augend, addend, sum, carry)
		exit(-1)

	log.success(f"{augend} + {addend} = {sum} {carry_string}")

async def sweep(dut, clock):
	clock.reset()
	N = int(dut.N)
	VALUES = 2 ** N

	for augend in range(VALUES):
		for addend in range(VALUES):
			dut.i_augend <= augend
			dut.i_addend <= addend
			await clock.next()

			sum = dut.o_sum.value.integer
			carry = dut.o_carry.value

			verify(N, augend, addend, sum, carry)

@cocotb.test()
async def testbench(dut):
	clock = Clock(dut.i_clock, 10)
	clock.print()
	clock.start()

	await sweep(dut, clock)

	clock.stop()
