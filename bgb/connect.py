import argparse,bgblink,time
from lumberjack import log as l

bittest = lambda x,p: ((x&(1<<p))==(1<<p))

VERBOSE = True # can be set to False in test script
CONTROL_LAST = 0x100

def log(*args):
	if not VERBOSE:
		return
	return l(*args)

class ControllerState:
	BUTTONS = {"up":6,"down":7,"left":5,"right":4,"a":0,"b":1,"select":3,"start":2}
	BUTTONS_ORD = "up down left right a b select start".split()
	BUTTONS_STR = "UDLRABSs"
	def __init__(self,v):
		self.value = v

	def __getattr__(self,k):
		if k in self.BUTTONS:
			return bittest(self.value,self.BUTTONS[k])
		return super(ControllerState,self).__getattr__(k)

	def __str__(self):
		i = 0
		r = ""
		while i<len(self.BUTTONS_ORD):
			button = self.BUTTONS_ORD[i]
			if bittest(self.value,self.BUTTONS[button]):
				r+=self.BUTTONS_STR[i]
			else:
				r+="-"
			i+=1
		return r

cont = ControllerState(0x00)

def out(x,o):
	global CONTROL_LAST,cont
	if x != CONTROL_LAST:
		cont.value = x
		log("{:02X} {!s}".format(x,cont),">","cyan")
		CONTROL_LAST = x
	return 0

if __name__=="__main__":
	try:
		parser = argparse.ArgumentParser(description="Outputs recieved values from the serial port.",epilog="Host and port default to 127.0.0.1:8765.")
#		parser.add_argument("--verbose","-v",action="store_true",help="Whether or not this program should print pretty logs or not.")
		parser.add_argument("host",default="127.0.0.1",nargs="?",help="Host to connect to.")
		parser.add_argument("port",default=8765,type=int,nargs="?",help="Port to connect to.")
		args = parser.parse_args()
		VERBOSE = True
		log("Connecting to host \"{}\" and port {!s}".format(args.host,args.port))
		link = bgblink.BGBLinkCable(args.host,args.port)
		link.setExchangeHandler(out)
		log("Connecting...")
		link.start()
		log("Connected!","*","green")
		while True:
			time.sleep(10)
	except Exception as e:
		VERBOSE = True
		log("An error occurred: \"{}: {!s}\"".format(e.__class__.__name__,e),"X")
		pass
