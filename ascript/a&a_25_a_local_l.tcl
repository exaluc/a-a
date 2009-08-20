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

a:command -add kick   pub:kick   1024 539 |l
a:command -add ban    pub:ban    1023 538 |l
a:command -add unban  pub:unban  1022 537 |l
a:command -add invite pub:invite 1028 547 |l

############ Command Procs ###########################

proc pub:kick {hand chan args x mix} {
	global botnick

	set whom    [lindex $args 0]
	set reason  [join [lrange $args 1 end]]

	if {![botisop $chan]}				    { a:tell $x 96 $chan    ; return "FAILED: opless"}
	if {![string length $whom]}			    { a:usage $x kick       ; return "FAILED: not all parameters specified"}
	if {![onchan $whom]}				    { a:tell $x 103 "$whom" ; return "FAILED: nick is not on chan ($whom)"}
	if { $reason == ""}	    { set reason "No reason supplied" }
	if {![a:level $x $chan $whom [nick2hand $whom] [a:translate $hand $chan 222 kick]]} { return "FAILED: target access is higher" }

	set reason [a:translate $hand $chan 17 "($hand/\002[lindex $x 0]\002) $reason"]
	putserv "KICK $chan $whom :$reason"

	return "$whom"
}

proc pub:ban {hand chan args x mix} {
	global botnick owner

	set whom   [lindex $args 0]
	set time   [lindex $args 1]
	set reason [lrange $args 2 end]
	set option none
	set add    ""

	if { $whom == ""} { a:usage $x ban ; return "FAILED: not all parameters specified"}
	if {![botisop $chan]} { a:tell $x 96 $chan; return "FAILED: opless"}
	if { [string map {* {} . {} ! {} @ {} ? {}} $whom] == ""} {a:tell $x 190; return "FAILED: mass ban caution"}
	if {![a:level $x $chan $whom [nick2hand $whom] [a:translate $hand $chan 222 ban]]}  { return "FAILED: target access is higher" }
	if {![onchan $whom $chan]} { set theban $whom; a:tell $x 95} else { set theban "*!*[string range [getchanhost $whom $chan] [string first @ [getchanhost $whom $chan]] end]" }
	if {![a:check -digit $time]} { set time "[channel get $chan ban-time]m"; set reason "[lrange $args 1 end]"}
	if { [string equal [lindex $reason 0] sticky] }	{ set option sticky; set add "\[sticky\] "; set reason [lrange $reason 1 end]}
	if { $reason == ""} { set reason "No reason supplied" }
	if { [string equal [lindex $reason 0] global] && [check:n:gl $hand]}  {
		if {![llength [lrange $reason 1 end]]} { set reason "global No reason supplied" }
		set reason [join [a:translate $hand $chan 111 "$hand/\002[lindex $x 0]\002 $time ${add}\[globally\] [lrange $reason 1 end]"]]
		newban $theban $hand $reason $time $option; return "global_$whom for $time, $reason" } else {
		set reason [join [a:translate $hand $chan 111 "$hand/\002[lindex $x 0]\002 $time ${add}$reason"]]
		newchanban $chan $theban $hand $reason $time $option ; return "$whom $reason"
	}
}

proc pub:unban {hand chan args x mix} {

	set theban  [lindex $args 0]
	set chanban 0
	set botban  0
	set go      1

	if {![string length $theban]} { a:usage $x unban ; return "FAILED: not all parameters specified"}
	if { [string equal -nocase [lindex $args 1] global] && [check:n:gl $hand]}  {
		foreach b [banlist]		    { set a [lindex $b 0] ; if {[string match -nocase $theban $a]} {killban $a ; incr botban }}} else {
		foreach b [banlist $chan]	    { set a [lindex $b 0] ; if {[string match -nocase $theban $a]} {killchanban $chan $a ; incr botban }; set go 0}
	}
	if { [botisop $chan]} {
		foreach b [chanbans $chan] {set b [lindex $b 0]; if { [string match -nocase $theban $b] && ($go || ![isban $b]) } {incr chanban; pushmode $chan -b $b}}
	} else {a:tell $x 132 "$chan"}

	if {($botban > 0) || ($chanban > 0)} {
		a:tell $x 115 "$botban $chanban" ; return "$theban, $botban BotBAN \& $chanban ChanBAN"} {
		a:tell $x 114 ; return "FAILED: no such ban ($theban)"
	}
}

proc pub:invite {hand chan args x mix} {

	set whom  [lindex $args 0]

	if { $whom=="" || $whom=="me"} { set whom [lindex $x 0] }
	if {![botisop $chan]} { a:tell $x 96 $chan; return "FAILED: bot is not opped" }
	if { [onchan $whom $chan]} { a:tell $x 53 "$whom $chan" ; return "FAILED: nick already on chan" }

	puthelp "invite $whom $chan"
	a:tell $x 52 "$whom $chan"
	return "$whom $chan"
}

return "local l commands"