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

a:command -add die                pub:die                1063 581 N
a:command -add rehash             pub:rehash             1064 582 N
a:command -add restart            pub:restart            1065 583 N
a:command -add reload             pub:reload             1066 584 N
a:command -add autocleanuserlist  pub:autoclean:userlist 1103 604 N
a:command -add autocleanchanlist  pub:autoclean:chanlist 1105 606 N

############ Command Procs ###########################

proc  pub:die  {hand chan args x mix} {
	global settings

	if {![llength $args]} {set args "Shutdown by $hand, for info apply on $settings(suppchan) or $settings(homepage)"}

	die $args; return "$args" }

proc pub:rehash   {hand chan args x mix}	{ a:tell $x 154 ; rehash ; return "..."}
proc pub:restart  {hand chan args x mix}	{                 restart; return "..." }
proc pub:reload   {hand chan args x mix}	{ a:tell $x 156 ; reload ; return "..." }

proc pub:autoclean:userlist {{hand ""} {chan ""} {args ""} {x ""} {mix ""}} {
	global settings username

	if {!$settings(auto_clean_users)} { if { [llength $mix]} {a:tell $x 63 userlist; return "FAILED: disabled in config"} {return}}

	set e 0

	foreach u [userlist -vlfLNB&-N&-ha] {

		if {![handonchan $u] && [expr [unixtime] - [a:validate -digit [lindex [getuser $u LASTON] 0]]] > [expr $settings(auto_clean_users) * 86400] } {
			 deluser $u; incr e
		}
	}

	if { [llength $mix]} {a:tell $x 67 $e; return "$e"} {putcmdlog "<<${username}>> AUTO CLEANING USERLIST ROUTINE -- $e user(s) erased"}
}

proc pub:autoclean:chanlist {{hand ""} {chan ""} {args ""} {x ""} {mix ""}} {
	global settings username

	if {!$settings(auto_clean_chans)} { if { [llength $mix]} {a:tell $x 63 channels}; return "FAILED: disabled in config"}

	set e 0
	set f 0
	set channels ""
	set stats ""

	foreach chan [string tolower [channels]] {
		if {![channel get $chan locked]} {
			if { [stats:channel -get $chan users] < $settings(chan_min_users) && [stats:channel -get $chan time] > 3600} {
				stats:channel -set $chan purgetime [unixtime]
				stats:channel -set $chan purgewhom $username
				stats:channel -set $chan purgewhy "less than $settings(chan_min_users) average users"
				putquick "part $chan :automated chan part, reason: less than $settings(chan_min_users) average users; for any help apply on $settings(suppchan) & \037\00302$settings(homepage)"
				channel remove $chan
				incr f
				lappend channels $chan} elseif {
			     $settings(lonely) && [botonchan $chan]} { set z 0
			foreach y [chanlist $chan] {incr z [check:B:gl [nick2hand  $y $chan]]}
			    if {$z > 1 } {
				stats:channel -set $chan purgetime [unixtime]
				stats:channel -set $chan purgewhom $username
				stats:channel -set $chan purgewhy "found $z $settings(suppchan) BOTs"
				putquick "part $chan :automated chan part, reason: found $z $settings(suppchan) BOTs; for any help apply on $settings(suppchan) & \037\00302$settings(homepage)"
				channel remove $chan
				incr f
			    }
			}
		}
	}

	foreach chan [stats:channel -all] {
		if {![validchan $chan]} {

			if { ([expr [unixtime] - [a:validate -digit [stats:channel -get $chan purgetime]]] > [expr $settings(auto_clean_chans) * 86400]) || [stats:channel -get $chan time] < 86400} {stats:channel -clean $chan; a:command -clean $chan; incr e; lappend stats $chan}
		}
	}

	if { [llength $mix]} {a:tell $x 87 "$f [join $channels] $e [join $stats]"; return "$f channels: [join $channels] & $e stats channels stats: [join $stats]"} {putcmdlog "<<${username}>> AUTO CLEANING CHANNLESLIST ROUTINE -- $f channels: [join $channels] & $e stats channels stats: [join $stats]"} }



return "owner commands"