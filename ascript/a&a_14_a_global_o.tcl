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

a:command -add adduser   pub:adduser  1032 543 o
a:command -add deluser   pub:deluser  1058 596 o
a:command -add chhandle  pub:chhandle 1068 586 o
a:command -add chpass    pub:chpass   1059 595 o

############ Command Procs ###########################

proc pub:adduser {hand chan args x mix} {
	global botnick settings handlen

	set whom [string range [lindex $args 0] 0 $settings(user_max_range)]
	set host [lindex $args 1]

	if { $whom == ""}			{ a:usage $x adduser ; return "FAILED: not all parameters specified"}
	if { [getting-users]}			{ a:tell $x 6; return "FAILED: getting users" }
	if { [validuser $whom]}			{ a:tell $x 50 "$whom"; return "FAILED: hand already exists"}
	if { $host == ""} {
		if {![onchan $whom $chan]}     { set host $whom!$whom@* } elseif {
		     [nick2hand $whom] != "*"} { a:tell $x 51 "$whom [nick2hand  $whom]"; return "FAILED: target is a known user"} else {
		    				 set host  [a:maskhost -uhost [getchanhost $whom]]
		}
	} elseif {![a:check -host $host]} {a:tell $x 15; return "FAILED: invalid mask specified"}
	if { [string length $whom] > $handlen } {a:tell $x 46 $whom; return "FAILED: target length greater than setup handlen" }

	adduser $whom $host
	chattr $whom $settings(flags_default)

	a:tell $x 39 "$whom $host"
	return "$whom with host $host"
}

proc pub:deluser {hand chan args x mix} {
	global owner

	set whom   [lindex $args 0]
	set how    [lindex $args 1]

	if { [getting-users]} { a:tell $x 6; return "FAILED: getting users" }
	if { $whom =="" }	      { a:usage $x deluser; return "FAILED: not all parameters specified" }
	set target [a:deluser $x $whom $how]
	if { $target == 0}     { return "FAILED: invalid hand ($whom)"}
	if {![a:level $x $chan $whom $target [a:translate $hand $chan 224]]} { return "FAILED: target access is higher ($target)"}
	if { [check:x:xx $target]} { a:tell $x 175 ; return "FAILED: unable to delete my owner" }

	deluser $target

	if { [string equal -nocase $target $hand]} {set x [a:modify -hand $x *]}

	a:tell $x 176 "$whom $target"

	return "$whom hand: $target"
}

proc pub:chpass {hand chan args x mix} {

	set whom [lindex $args 0]
	set pass [lindex $args 1]
	set how  [lindex $args 2]

	if { [getting-users]} {a:tell $x 6; return "FAILED: getting users" }
	if { $pass == ""}	{a:usage $x chpass; return "FAILED: not all parameters specified" }
	set target [a:deluser $x $whom $how]
	if {$target == 0} { return "FAILED: invalid hand ($whom)"}
	if {![a:level $x $chan $whom $target [a:translate $hand $chan 223]]} { return "FAILED: target access is higher ($target)"}

	if { [string equal $pass reset] || [string equal $pass none]} {
		setuser $target PASS ""
		a:tell $x 160 "$target [a:getxtra -uhost $target _PASS] [a:getxtra -hand $target _PASS] [a:getxtra -ctime $target _PASS]"
	} else {
		setuser $target PASS $pass
		a:tell $x 172 "$target $pass [a:getxtra -uhost $target _PASS] [a:getxtra -hand $target _PASS] [a:getxtra -ctime $target _PASS]"
	}

	setuser $target XTRA _PASS "[unixtime] [lindex $x 0]![lindex $mix 0] $hand"
	return "for $whom hand: $target ..."
}

proc pub:chhandle {hand chan args x mix} {
	global settings handlen

	set whom [lindex $args 0]
	set last [lindex $args 1]
	set how  [lindex $args 2]

	if { [getting-users]} {a:tell $x 6; return "FAILED: getting users" }
	if { $last == ""} {a:usage $x chhandle; return "FAILED: not all parameters specified"}
	if { [string length $last] > $settings(user_max_length)} { a:tell $x 69 ; return "FAILED: hand's length > $settings(user_max_length)"}

	set target [a:deluser $x $whom $how]

	if { $target == 0}                      { return "FAILED: invalid host hand or invalid hand" }
	if {![a:level $x $chan $whom $target [a:translate $hand $chan 225]]} { return "FAILED: target access is higher ($target)" }

	if { [validuser $last]}                 { a:tell $x 50 "$last" ; return "FAILED: hand already exist ($last)"}
	if { [check:x:xx $target]}		{ a:tell $x 158 ; return "FAILED: can not rename my owner ($target)" }
	if { [string length $last] > $handlen } { a:tell $x 46 $last; return "FAILED: target length greater than setup handlen" }

	chhandle $target $last

	if { [string equal $target $hand]}      { set x "[lrange $x 0 0] $last [lrange $x 2 2] [lrange $x 3 3]"}

	a:tell $x 159 "$target $last"
	return "$target to $last"
}


return "global o commands"