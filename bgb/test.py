import connect,sys
from lumberjack import log

count = 0
total = 0

def header(text):
	log(text,"*","cyan")

def assume(name,cond,val):
	global count,total
	total+=1
	try:
		assert cond==val
		log("Test \"{}\" passed!".format(name),"!","green")
		count+=1
	except:
		log("Test \"{}\" failed!".format(name),"X")
		pass

header("Testing ControllerState object")
test = connect.ControllerState(0x00)
assume("no buttons are on at x=00",any(getattr(test,k) for k in test.BUTTONS),False)
assume("str(test) == \"--------\"",str(test),"--------")
test.value = 0xFF
assume("all buttons are on at x=FF",all(getattr(test,k) for k in test.BUTTONS),True)
assume("str(test) == \"UDLRABSs\"",str(test),"UDLRABSs")
header("Misc tests")
connect.VERBOSE = False
assume("Any input returns 0",all(connect.out(x,None)==0 for x in range(256)),True)

log("{!s}/{!s} ({!s}%) tests passed.".format(count,total,round((count/total)*100,2)))
