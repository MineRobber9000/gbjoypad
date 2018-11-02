SECTION "WRAM",WRAM0[$c000]
wCurrentJoypadState::
	ds 1
wSendByLinkCable::
	ds 1
wJoypadOutputString::
	ds 8 ; max length: UDLRABSs
