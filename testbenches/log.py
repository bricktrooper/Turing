import colours
import inspect

# ===================== CONSTANTS ===================== #

COLOURS = {
	"ERROR":   colours.RED,
	"WARNING": colours.YELLOW,
	"SUCCESS": colours.GREEN,
	"DEBUG":   colours.BLUE,
	"INFO":    colours.CYAN,
	"NOTE":    colours.MAGENTA
}

LEVELS = {
	"ERROR",
	"WARNING",
	"SUCCESS",
	"DEBUG",
	"INFO",
	"NOTE"
}

PREFIXES = {
	"ERROR":   "X",
	"WARNING": "!",
	"SUCCESS": "~",
	"DEBUG":   "#",
	"INFO":    ">",
	"NOTE":    "@"
}

# ===================== FLAGS ===================== #

SUPPRESSED = {
	"ERROR":   False,
	"WARNING": False,
	"SUCCESS": False,
	"DEBUG":   False,
	"INFO":    False,
	"NOTE":    False
}

TRACE = {
	"FILE":   False,
	"LINE":   False,
	"CALLER": False
}

ENABLE_LOGS = True
ENABLE_TRACE = False
ENABLE_COLOUR = True

# ===================== INTERNAL FUNCTIONS ===================== #

def get_trace():
	if not ENABLE_TRACE:
		return ""

	stack = inspect.stack()
	file = ""
	line = ""
	caller = ""

	if TRACE["FILE"]:
		file = str(stack[3][1]) + ":"
	if TRACE["LINE"]:
		line = str(stack[3][2]) + ":"
	if TRACE["CALLER"]:
		caller = str(stack[3][3])
		if caller == "<module>":
			caller = "__main__"
		caller += ":"

	return "{}{}{} ".format(file, line, caller)

def get_prefix(level):
	if ENABLE_COLOUR:
		return "{}{}{} ".format(COLOURS[level], PREFIXES[level], colours.RESET)
	else:
		return "{} ".format(PREFIXES[level])


def format_message(level, message):
	if SUPPRESSED[level] or not ENABLE_LOGS:
		return ""
	else:
		return "{}{}{}\r\n".format(get_trace(), get_prefix(level), str(message))

def print_invalid_level(level):
	print("'{}' is an invalid log level".format(level))
	print("Valid log levels: {}".format(LEVELS))

# ===================== LOGGING API ===================== #

def enable():
	global ENABLE_LOGS
	ENABLE_LOGS = True

def disable():
	global ENABLE_LOGS
	ENABLE_LOGS = False

def suppress(level):
	if level in LEVELS:
		SUPPRESSED[level] = True
	else:
		print_invalid_level(level)
		raise Exception("Invalid log level")

def show(level):
	if level in LEVELS:
		SUPPRESSED[level] = False
	else:
		print_invalid_level(level)
		raise Exception("Invalid log level")

def colourize():
	global ENABLE_COLOUR
	ENABLE_COLOUR = True

def colourless():
	global ENABLE_COLOUR
	ENABLE_COLOUR = False

def trace(file, line, caller):
	TRACE["FILE"] = file
	TRACE["LINE"] = line
	TRACE["CALLER"] = caller

	global ENABLE_TRACE
	if file or line or caller:
		ENABLE_TRACE = True
	else:
		ENABLE_TRACE = False

def error(message):
	print(format_message("ERROR", message), end = "")

def warning(message):
	print(format_message("WARNING", message), end = "")

def success(message):
	print(format_message("SUCCESS", message), end = "")

def debug(message):
	print(format_message("DEBUG", message), end = "")

def info(message):
	print(format_message("INFO", message), end = "")

def note(message):
	print(format_message("NOTE", message), end = "")
