# GameBoyGamesCom BGB link

This program will allow any user of the BGB emulator to use GBGC services. It also describes the protocol.

## Protocol

### Commands

|Command|ID|Has contents?|Contents|Response|
|-|-|-|-|-|
|`PING`|`00`|No|N/A|`PING`|
|`RETR`|`01`|Yes|URL of content, null terminated|`ACK` until recieving null, then `ACK_FIN`, then the data (with `END_PACKET` at the end of the data).|

### Responses

|Response|ID|Explanation|
|-|-|-|
|`PING`|`00`|Sent in response to a `PING` command. Can, in theory, be any non-FF value.|
|`ACK`|`01`|Sent as an acknowledgement of recieved data.|
|`ACK_FIN`|`02`|Used to acknowledge the end of a sequence of data.|
|`END_PACKET`|`FF`|Like `ACK_FIN`, but where not allowing the use of `02` does not make sense. (For example, in the transfer of program code.)|
