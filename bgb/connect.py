import argparse,bgblink,time
from lumberjack import log

def out(x,o):
	log("{:02X}".format(x),">","cyan")
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
