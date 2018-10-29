import connect,sys
from lumberjack import log

count = 0
total = 0

def assume(cmd,id,resp,rid):
	global count,total
	total+=1
	try:
		assert connect.gbgc(id,None)==rid
		log("Test \"{}->{}\" passed!".format(cmd,resp),"!","green")
		count+=1
	except:
		log("Test failed: {} command should recieve response {}".format(cmd,resp),"X")
		pass

assume("PING",0,"PING",0)
assume("RETR",1,"ACK",1)
assume("A",ord("A"),"ACK",1)
assume("B",ord("B"),"ACK",1)
assume("<END>",0,"ACK_FIN",2)
assume("<any char>",0,"A",ord("A"))
assume("<any char>",0,"B",ord("B"))
assume("<any char>",0,"END_PACKET",0xFF)
log("{!s}/{!s} ({!s}%) tests passed.".format(count,total,round((count/total)*100,2)))
