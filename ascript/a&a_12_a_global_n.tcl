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

a:command -add chattrgl	  pub:chattrgl	1008 578 n
a:command -add msg	  pub:msg	1093 600 n
a:command -add broadcast  pub:broadcast 1070 588 n
a:command -add nick       pub:nick      1071 589 n

############ Command Procs ###########################

proc pub:chattrgl {hand chan args x mix} {
	global owner botnick settings one

	set whom   [string range [lindex $args 0] 0 $settings(user_max_range)]
	set modes  [lindex $args 1]
	set how    [lindex $args 2]
	set one    0

	if {![regexp {^[\+\-yzrlhwecubtxjpdkfgvoamnNHPBLSXW]+$} $modes]} {a:usage $x chattrgl; return "FAILED: invalid flags ($modes)"}
	if { [getting-users]} { a:tell $x 6; return "FAILED: getting users" }

	set target [a:adduser $x $whom $how $chan]
	set y      "$whom $target $chan msg"

	if {$target == 0} { return "FAILED: invalid hand host or nick not online ($whom)"}
	if {![a:level $x $chan $whom $target [a:translate $hand $chan 229]]} { return "FAILED: target access is higher" }
	if {![check:x:xx $hand] } { set modes [string map {N {} B {} W {}} $modes] } elseif {
	     [regexp -- {\+[^-]*N} $modes]} {append modes +n}
	if {![check:N:gl $hand] } { set modes [string map {u {} j {} c {} n {} m {} o {} l {} v {} X {}} $modes]}

	set flags [chattr $target ${settings(flags_default)}$modes]
	setuser $target XTRA _FLAG "[unixtime] $modes GLOBALLY $hand"

		    a:tell $x 40 "GLOBAL $whom $target $flags"
	if {$one} { a:tell $y 142 "$target $flags"
		    a:tell $y 42 $botnick; a:tell $y 43 $botnick; a:tell $y 44 $botnick
		    a:tell $y 48 "$botnick $botnick $chan"
		    a:tell $y 49
	}

	return "$target $modes"
}

proc pub:broadcast {hand chan args x mix} {
	global owner

	set msg  [join [lrange $args 0 end]]

	if {$msg == ""} {a:usage $x broadcast; return "FAILED: not all parameters specified"}

	foreach chan [channels] { if { [botonchan $chan] && [isdynamic $chan]} {a:announce -chan 17 $chan "$msg" }}
	return "$msg"
}

proc pub:msg {hand chan args x mix} {

	set whom  [lindex $args 0]
	set what  [join [lrange $args 1 end]]

	if {$what == ""} {a:usage $x msg; return "FAILED: not all parameters specified"}

	puthelp "PRIVMSG $whom :$what"
	return "$whom $what"
}

proc pub:nick {hand chan args x mix} {
	global nick altnick

	set msg  [lindex $args 0]

	if {$msg == ""} {a:usage $x nick ; return "FAILED: not all parameters specified"}
	if {[string equal -nocase $msg altnick]}  { set msg $altnick}

	a:tell $x 161 $msg; set nick $msg; return "$msg"
}

return "global n commands"