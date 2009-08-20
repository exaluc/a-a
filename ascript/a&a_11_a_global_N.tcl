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

a:command -add save     pub:save     1094 576 N
a:command -add backup   pub:backup   1062 577 N
a:command -add addbot   pub:addbot   1096 590 N
a:command -add botattr  pub:botattr  1099 593 N

############ Command Procs ###########################

proc pub:save {{hand ""} {chan ""} {args ""} {x ""} {mix ""}} {
	global  username

	save
	if { [llength $mix]} {a:tell $x 140; return "..."} {putcmdlog "<<${username}>> SAVE ROUTINE -- user, chan, info files"}
}

proc pub:backup {{hand ""} {chan ""} {args ""} {x ""} {mix ""}} {
	global infofile username

	if {[file exists $infofile]} {file copy -force -- ${infofile} ${infofile}~bak}
	backup

	putcmdlog "Backing up info file..."
	if { [llength $mix]} {a:tell $x 141; return "..."}
}

proc pub:addbot {hand chan args x mix} {
	global botnick settings handlen

	set who  [string range [lindex $args 0] 0 $settings(user_max_range)]
	set host [lindex $args 1]
	set link [lindex $args 2]
	set what 0

	if { $who == ""} {a:usage $x addbot; return "FAILED: not all parameters specified"}
	if { [getting-users]} { a:tell $x 6; return "FAILED: getting users" }
	if { [validuser $who]} { a:tell $x 50 $who; return "FAILED: hand already exists ($who)"}
	if { [string equal -nocase $host $settings(suppchan)] } { set host [lindex $args 2]; set link [lindex $args 3]; set what 1}
	if {![llength $host]} {
		if {![onchan $who $chan]}     { set host $who!$who@* } elseif {
		     [validuser [nick2hand $who]]} { a:tell $x 51 "$who [nick2hand  $who]" ; return "FAILED: nick is already known as ([nick2hand  $who])"} else {
			                                 set host  [a:maskhost -uhost [getchanhost $who]]
		}
	} elseif {![a:check -host $host]} {a:tell $x 15; return "FAILED: invalid host specified"}
	if { [string length $who] > $handlen } {a:tell $x 46 $who; return "FAILED: target length greater than setup handlen" }

	addbot $who $link
	setuser $who HOSTS $host

	if { $what && [check:x:xx $hand] } {chattr $who +oafPB}
	a:tell $x 163 "$who $host"
	return "$who with host $host"
}

proc pub:botattr {hand chan args x mix} {

	set target [lindex $args 0]
	set modes  [lindex $args 1]

	if { [getting-users]}			   { a:tell $x 6; return "FAILED: getting users" }
	if {![regexp {^[+-][spghalri]+$}  $modes]} { a:usage $x botattr ; return "FAILED: invalid BOT flags specified"}
	if {![check:b:gl $target]}		   { a:tell  $x 165 $target ; return "FAILED: invalid BOT specidied"}

	set flags [botattr $target $modes]
	setuser $target XTRA _FLAG "[unixtime] $modes BOT $hand"

	a:tell $x 40 "BOT $target $target $flags"
	return "$target $modes"
}

return "global N commands"