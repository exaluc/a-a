# +-------------------------------------------------------------------------------------+
# |                                                                                     |
# |                         a&a (light) script v0.04.00 Beta 1                          |
# |                                                                                     |
# +-------------------------------------------------------------------------------------+
# |                                                                                     |
# |             Creative Commons Copyright 2002-2009 by UniversaliA aka aqwzsx          |
# |                               http://ascript.name                                   |
# |                                                                                     |
# +-------------------------------------------------------------------------------------+
# |                                                                                     |
# |        Website             @  http://ascript.name                                   |
# |        Forum & support     @  http://ascript.name/forum                             |
# |        Features & bugs     @  http://ascript.name/bugs                              |
# |                                                                                     |
# +-------------------------------------------------------------------------------------+
# |                                                                                     |
# |                    #a&a & #botlending @ Undernet/Quakenet IRC                       |
# |                                                                                     |
# +-------------------------------------------------------------------------------------+
############ Command Binds ###########################

a:command -add join    pub:join     1060 594 m
a:command -add jump    pub:jump     1088 575 m
a:command -add silence pub:silence  1010 510 m

############ Command Procs ###########################

proc pub:join {hand chan args x mix} {
	global settings

	if { [validchan $chan]} {a:tell $x 174 $chan ; return "FAILED: invalid chan specified ($chan)" }
	if { [llength [channels]] >= $settings(max_chans) } {a:tell $x 80; return "FAILED: channels limit reached" }

	stats:channel -add $chan {}
	stats:channel -set $chan jointime [unixtime]
	stats:channel -set $chan joinwhom $hand

	channel add $chan +secure
	pub:save

	a:announce -home 173 "$hand [lindex $x 0] [lindex $mix 0] $chan"
	return "$chan"
}

proc pub:jump {hand chan args x mix} {

	set serv [lindex $args 0]

	if { $serv == ""} {a:usage $x jump; return "FAILED: not all parameters specified"}

	jump $serv; return "$serv"
}

proc pub:silence {hand chan args x mix} {

	set cmd [lindex $args 0]

	switch -- $cmd {
		on	{putquick "SILENCE +*!*@*" -next}
		off	{puthelp "SILENCE -*!*@*"}
		default {a:usage $x silence; return "FAILED: not all (wrong) parameters specified"}
	}

	a:tell $x 296 [string toupper $cmd]; return "$cmd"
}

return "global m commands"