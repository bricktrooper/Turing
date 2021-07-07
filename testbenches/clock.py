import log
import cocotb

from cocotb.triggers import RisingEdge
from cocotb.triggers import Timer

class Clock:

	TIME_UNIT = "ns"
	HOLD_TIME = 1

	def __init__(self, signal, period):
		self.signal = signal
		self.period = period
		self.frequency =  1000 / float(period)
		self.process = None

	def reset(self):
		self.signal <= 0

	async def next(self, cycles = 1, hold = False):
		for i in range(cycles):
			await RisingEdge(self.signal)
			if hold:
				await self.stall(Clock.HOLD_TIME)

	async def stall(self, ps = 1):
		await Timer(ps, "ps")

	async def run(self):
		while True:
			self.signal <= 1
			await Timer(self.period / 2, "ns")
			self.signal <= 0
			await Timer(self.period / 2, "ns")

	def start(self):
		if self.process != None:
			log.error("The clock is already running")
		else:
			self.process = cocotb.fork(self.run())

	def stop(self):
		if self.process == None:
			log.error("The clock has already stopped")
		else:
			self.process.kill()
			self.process = None

	def print(self):
		log.info("======= CLOCK =======")
		log.info("Period:    %.1f ns" % (self.period))
		log.info("Frequency: %.1f MHz" % (self.frequency))
		log.info("=====================")
