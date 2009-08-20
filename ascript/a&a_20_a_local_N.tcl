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

a:command -add purge    pub:purge    1038 555 |N
a:command -add disable	pub:disable  1061 579 |N
a:command -add enable	pub:enable   1095 580 |N

############ Command Procs ###########################

proc pub:purge {hand chan args x mix} {
	global settings

	set reason [join [lrange $args 0 end]]

	if {![isdynamic $chan]} { a:tell $x 129 $chan; return "FAILED: static chan ($chan)"}
	if { [channel get $chan locked] && ![check:N:gl $hand] && ![a:check -now [lindex $args 1]] } { a:tell $x 135 $chan; return "FAILED: locked chan ($chan)"}
	if { $reason == ""} { a:tell $x 19; return "FAILED: no reason supplied"}
	if { [check:m:gl $hand] && $settings(strict_reason) && ![a:check -reason [lindex $args 0]] } { a:tell $x 13; return "FAILED: invalid reason"}

	channel remove $chan
	a:com:alias  -clean $chan
	a:com:status -clean $chan
	stats:channel -set $chan purgetime [unixtime]
	stats:channel -set $chan purgewhom $hand
	stats:channel -set $chan purgewhy $reason
	pub:save

	putquick "part $chan :part on demand of $hand, reason: $reason; for any help apply on $settings(suppchan) & \037\00302$settings(homepage)"
	a:announce -home 128 "$hand [lindex $x 0] [lindex $mix 0] $chan $reason"

	return "$chan"
}

proc pub:disable {hand chan args x mix} {

	set cmd [lindex $args 0]
	set temp ""

	if {![string length $cmd]}  { a:usage $x disable; return "FAILED: not all parameters specified"}
	if {![a:command -exists $cmd] && ![string equal $cmd all]} {a:tell $x 18 $cmd; return "FAILED: invalid command specified ($cmd)"}
	if { [string equal -nocase [lindex $args 1] global] && [check:n:gl $hand]} {set chan "global"; set temp " globally" }
	if { [a:com:status -disabled $cmd $chan] && ![string equal $cmd all]} {a:tell $x 150 "${cmd}${temp}"; return "FAILED: command disabled already (${cmd}${temp})"}

	a:com:status -disable $cmd $chan

	if { [string equal $cmd all]} {a:tell $x 250} {a:tell $x 143 "${cmd}${temp}"}

	return "${cmd}${temp}"
}

proc pub:enable {hand chan args x mix} {

	set cmd  [lindex $args 0]
	set temp ""

	if {![string length $cmd]}  {a:usage $x enable; return "FAILED: not all parameters specified"}
	if {![a:command -exists $cmd] && ![string equal $cmd all]} {a:tell $x 18 $cmd; return "FAILED: invalid command specified ($cmd)"}
	if { [string equal -nocase [lindex $args 1] global] && [check:n:gl $hand]} {set chan "global"; set temp " globally"}
	if {![a:com:status -disabled $cmd $chan] && ![string equal $cmd all]} {a:tell $x 151 "${cmd}${temp}"; return "FAILED: command enabled already (${cmd}${temp})"}

	a:com:status -enable $cmd $chan

	if { [string equal $cmd all]} {a:tell $x 249} {a:tell $x 152 "${cmd}${temp}"}

	return "${cmd}${temp}"
}

return "local N commands"