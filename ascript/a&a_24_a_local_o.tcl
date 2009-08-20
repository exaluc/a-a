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

a:command -add op   pub:op    1026 541 |o
a:command -add deop pub:deop  1025 540 |o

############ Command Procs ###########################

proc pub:op {hand chan args x mix} {

	if {![botisop $chan]} {a:tell $x 96 $chan; return "FAILED: opless"}

	set whom   [lrange $args 0 end]
	set opped  ""
	set nohere ""
	set d	   ""
	set talk   1

	if {[string first * $whom] > -1 } { set whom [a:check -regx $whom $chan]; set talk 0} elseif {
	    $whom=="" || [string equal -nocase $whom me]} { set whom [split [lindex $x 0]]}

	foreach z $whom {
		if {![onchan $z $chan]}				 { lappend nohere  $z} elseif {
		     [isop   $z $chan]}				 { lappend opped   $z} elseif {
		     [matchattr [nick2hand $z $chan] d|d $chan]} { lappend d       $z} else   {
								   pushmode $chan +o $z
		}
	}

	flushmode $chan

	if {$nohere  != "" && $talk} {a:tell $x 90 "[join $nohere]"}
	if {$opped   != "" && $talk} {a:tell $x 97 "[join $opped]"}
	if {$d       != "" && $talk} {a:tell $x 288 "[join $d]"}

	return "[join [lrange $whom 0 2]] ..."
}

proc pub:deop {hand chan args x mix} {

	if {![botisop $chan]} {a:tell $x 96 $chan; return "FAILED: opless"}

	set whom    [lrange $args 0 end]
	set opped   ""
	set nohere  ""
	set higher  ""
	set a	    ""
	set talk    1

	if { [string first * $whom] > -1 } { set whom [a:check -regx $whom $chan]; set talk 0} elseif {
	     $whom=="" ||  [string equal -nocase $whom me]} { set whom [split [lindex $x 0]]}
	if { [llength $whom] > 3 && [channel get $chan chanserv]} {a:tell $x 100 $chan; return "FAILED: massdeop protection caution"}

	foreach z $whom {
		if {![isbotnick $z] } {
			if {![onchan $z $chan]}				      { lappend nohere  $z} elseif {
			    ![isop   $z $chan]}                               { lappend opped   $z} elseif {
		            ![a:level  $x $chan $z [nick2hand $z] [a:translate $hand $chan 222 deop] $talk]} {lappend higher  $z} elseif {
			     [matchattr [nick2hand $z $chan] aW|a $chan]}     { lappend a       $z} else   {
										pushmode $chan -o $z
			}
		}
	}

	flushmode $chan

	if {$nohere != "" && $talk} { a:tell $x 90  "[join $nohere]"}
	if {$opped  != "" && $talk} { a:tell $x 99  "[join $opped]"}
	if {$a      != "" && $talk} { a:tell $x 287 "[join $a]"}
	return "[join [lrange $whom 0 2]] ..."
}

return "local o commands"