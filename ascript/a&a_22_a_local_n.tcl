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

a:command -add templeave  pub:templeave 1037 550 |n
a:command -add comeback   pub:comeback  1036 551 |n
a:command -add chanset    pub:chanset   1034 553 |n
a:command -add cycle      pub:cycle     1100 601 |n

############ Command Procs ###########################

proc pub:templeave {hand chan args x mix} {
	global settings

	set reason [join [lrange $args 0 end]]

	if {![isdynamic $chan]} { a:tell $x 129 $chan; return "FAILED: static chan ($chan)"}
	if { [channel get $chan inactive]} { a:tell $x 21 $chan; return "FAILED: chan already innactive ($chan)"}
	if { $reason == ""} { a:tell $x 19; return "FAILED: no reason supplied"}
	if { [check:m:gl $hand] && $settings(strict_reason) && ![a:check -reason [lindex $args 0]] } { a:tell $x 13; return "FAILED: invalid reason"}

	stats:channel -set $chan templeavetime [unixtime]
	stats:channel -set $chan templeavewhom $hand
	stats:channel -set $chan templeavewhy $reason

	a:tell $x 122 $chan

	putquick "part $chan :templeft on demand of $hand, reason: $reason; for any help apply on $settings(suppchan) & \037\00302$settings(homepage)"
	channel set $chan +inactive
	return "$chan"
}

proc pub:comeback {hand chan args x mix} {

	set mix [lindex $args 0]

	if {![channel get $chan inactive] && ![a:check -now $mix]} {a:tell $x 124 $chan ; return "FAILED: chan already active ($chan)"}
	if { [channel get $chan suspended]} {a:tell $x 127 $chan ; return "FAILED: chan suspended ($chan)"}
	channel set $chan -inactive
	putquick "join $chan";		     a:tell $x 123 $chan ; return "$chan"
}

proc pub:chanset {hand chan args x mix} {

	set mode   [string tolower [lindex $args 0]]
	set opti   [lindex $args 1]

	if { [regexp -- {^[+-](auto(op|voice)|bitch|cycle|revenge(bot|)|dontkickops|nodesynch|(dynamic|enforce|user)bans|inactive|protect(friends|ops)|secret|greet|seen|anti(pub|colour|bold|underline|notice|url|reverse|repeat|action)|limit|secure|voice|op|enforcetopic)$} $mode]} {channel set $chan $mode} elseif {
     	     [regexp -- {^(rules|url|faq|fuck|news|desc|mail|slap|kiss)$} $mode]} {if { [string equal $opti none] || $opti == ""} {set opti ""; a:tell $x 136 "$chan $mode"; stats:channel -set $chan $mode $opti; return "$mode none"} {set opti [join [lrange $args 1 end]]; stats:channel -set $chan $mode $opti}} elseif {
	    ([regexp -- {^aop-delay|flood-(chan|deop|kick|join|nick|ctcp)$} $mode] && [regexp {^\d{1,2}\:\d{1,3}$} $opti]) || \
	    ([regexp -- {^(ban|exempt|invite)-time$} $mode] && [a:check -digit $opti]) || \
	    ([string equal $mode stopnethack-mode] && [string match {[0-6]} $opti]) || \
	    ([string equal $mode idle-kick] && [a:check -digit $opti]) || \
	    ([string equal $mode idle-deop] && [a:check -digit $opti])  || \
	    ([string equal $mode revenge-mode] && [string match {[0-3]} $opti])} {channel set $chan $mode $opti} elseif {
	     [string equal $mode -inactive] && [channel get $chan suspended]} {a:tell $x 127 $chan ; return "FAILED: chan suspended ($chan)"} elseif {
	     [string equal $mode +suspended] && [check:m:gl $hand]} {channel set $chan +inactive +suspended} elseif {
	     [string equal $mode -suspended] && [check:m:gl $hand]} {channel set $chan -inactive -suspended} elseif {
	     [string equal $mode floatmargin]} { if {![string match {[3-9]} $opti]   } {a:help $x chanset ; return "FAILED: wrong options ($mode $opti)"} {channel set $chan $mode $opti}} elseif {
	     [string equal $mode floatgrace] } { if {![string match {[1-6]} $opti]   } {a:help $x chanset ; return "FAILED: wrong options ($mode $opti)"} {channel set $chan $mode $opti}} elseif {
	     [string equal $mode floatmax]   } { if {![string is digit -strict $opti]} {a:help $x chanset ; return "FAILED: wrong options ($mode $opti)"} {channel set $chan $mode $opti}} elseif {
	     [string equal $mode chanmode] || [string equal $mode mode] && [regexp {^[+-]+[ntrimlkpsD+-]+$} $opti]} {channel set $chan chanmode $opti} elseif {
	     [string match {[-+]locked} $mode] && [check:N:gl $hand] } {channel set $chan $mode } else {a:help $x chanset ; return "FAILED: wrong options ($mode $opti)"}

	a:tell $x 126 "$chan $mode $opti"
	return "$mode $opti"
}

proc pub:cycle {hand chan args x mix} {
	global settings

	set time [lindex $args 0]

	if {![isdynamic $chan]} {a:tell $x 129 $chan; return "FAILED: static chan ($chan)"}
	if {![a:check -digit $time] || $time < 7 || $time > 72000} {set time 9}

	putquick "part $chan :cycling on demand of $hand, be back in $time seconds; for any help apply on $settings(suppchan) & \037\00302$settings(homepage)"
	channel set $chan +inactive
	utimer $time [list channel set $chan -inactive]
	return "$chan for $time"
}


return "local n commands"