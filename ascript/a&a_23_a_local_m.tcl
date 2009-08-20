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

a:command -add chattr     pub:chattr    1007 542 |m
a:command -add clearmode  pub:clearmode 1031 544 |m
a:command -add topic      pub:topic     1072 549 |m

############ Command Procs ###########################

proc pub:chattr {hand chan args x mix} {
	global settings one

	set whom   [string range [lindex $args 0] 0 $settings(user_max_range)]
	set modes  [lindex $args 1]
	set how    [lindex $args 2]
	set count  0
	set one    0

	if {![regexp -- {^[\+\-lrzyqewdkfgvoamnNHPLSX]+$} $modes]} {a:usage $x chattr ; return "FAILED: invalid flags ($modes)"}
	if { [getting-users]} { a:tell $x 6; return "FAILED: getting users" }

	set target [a:adduser $x $whom $how $chan]
	set y      "[split $whom] [split $target] [split $chan] msg"

	if { $target == 0} { return "FAILED: invalid hand host or nick not online ($whom)"}
	if {![a:level $x $chan $whom $target [a:translate $hand $chan 229]]} { return "FAILED: target access is higher" }

	if { [string match *N* $modes]}		    {
		if {![check:m:gl $hand]}	    { a:tell $x 64 ; set modes [string map {N {}} $modes] } elseif {
		     [regexp -- {\+[^-]*N} $modes]} { if {[llength [userlist |N $chan]] > 0 && ![check:N:gl $hand]} {a:tell $x 56; set modes [string map {N {}} $modes]} {append modes +n}
		}
	}

	if { [string match {*[nXLS]*} $modes] && ![check:N:ch $hand $chan] } { a:tell $x 57; set modes [string map {n {} X {} L {} S {}} $modes]}
	if { [string match {*[mPH]*}  $modes] && ![check:n:ch $hand $chan] } { a:tell $x 58; set modes [string map {m {} H {} P {}} $modes]}

	set flags [chattr $target |$modes $chan]
	setuser $target XTRA _FLAG "[unixtime] $modes $chan $hand"

		    a:tell $x 40 "LOCAL $whom $target $flags"
	if {$one} { global botnick
		    a:tell $y 41 "$target $flags $chan"
		    a:tell $y 42 $botnick; a:tell $y 43 $botnick; a:tell $y 44 $botnick
		    a:tell $y 48 "$botnick $botnick $chan"
		    a:tell $y 49
	}

	return "$target $modes"
}

proc pub:clearmode {hand chan args x mix} {

	if {![botisop $chan]} { a:tell $x 96 $chan; return "FAILED: bot is not opped" }

	putserv "MODE $chan -[lindex [split [getchanmode $chan] +] 1] "
	a:tell $x 104 $chan
	return "..."
}

proc pub:topic {hand chan args x mix} {
	global botnick

	set option [string tolower [lindex $args 0]]
	set args   [join $args]

	if {![string length $option]} { a:usage $x topic; return "FAILED: not all parameters specified" }
	if { [a:check -info $option]} { set option -info }

	switch -exact -- $option {

		-lock    { if {![channel get $chan topic] } {
				channel set $chan +topic
				stats:channel -set $chan topicwhom "$hand"
				stats:channel -set $chan topictext "[topic $chan]"
				a:tell $x 54 "$chan [topic $chan]"; return "LOCK" } else {
				a:tell $x 55 $chan; return "FAILED TO LOCK: locked already"
			}
		}
		-enforce { if {![botisop $chan]}      { a:tell $x 96 $chan; return "FAILED: bot is not opped" }
			  if { [stats:channel -get $chan topictext]==""} {
				a:tell $x 121 $chan; return "FAILED TO ENFORCE: no topic"} else {
				putserv "TOPIC $chan :[stats:channel -get $chan topictext]"; return "ENFORCE"
			}
		}
		-unlock  { if { [channel get $chan topic]} {
				channel set $chan -topic
				a:tell $x 116 $chan; return "UNLOCK"} else {
				a:tell $x 117 $chan; return "FAILED TO UNLOCK: not locked"
			}
		}
		-info    { if { [stats:channel -get $chan topictext] != "" } {
				a:tell $x 118 "[stats:channel -get $chan topictext]"
				a:tell $x 119 "[stats:channel -get $chan topicwhom] [iif [channel get $chan topic] + -]topic [iif [channel get $chan enforcetopic] + -]enforcetopic"; return "INFO"} else {
				a:tell $x 120; return "FAILED TO INFO: no info"
			}
		}
	}

	if {![botisop $chan]}      { a:tell $x 96 $chan; return "FAILED: bot is not opped" }
	if { [channel get $chan topic] } {
		a:tell $x 119 "[stats:channel -get $chan topicwhom] [iif [channel get $chan topic] + -]topic [iif [channel get $chan enforcetopic] + -]enforcetopic"
		stats:channel -set $chan topicwhom $hand
		stats:channel -set $chan topictext $args
	}

	putserv "TOPIC $chan :[join $args]"
	return "[join $args]"
}

proc a:bind:topic {nick uhost hand chan topic} {

	if { [channel get $chan topic] } {
		if { $topic != [stats:channel -get $chan topictext] } {
			if { [isbotnick $nick]} {return 0} elseif {
			    ([check:m:ch $hand $chan] && [a:authorised $nick $uhost $hand]) || [check:B:gl $hand ]} {
				putcmdlog "<<$hand>> $nick!$uhost $chan TOPIC RElocked"
				if {![check:B:gl $hand ]} {a:tell "[split $nick] [split $hand] [split $chan] pub" 119 "[stats:channel -get $chan topicwhom] [iif [channel get $chan topic] + -]topic [iif [channel get $chan enforcetopic] + -]enforcetopic"}
				stats:channel -set $chan topicwhom $hand
				stats:channel -set $chan topictext $topic
			} elseif {
			     [botisop $chan] } {
				putcmdlog "<<$hand>> $nick!$uhost $chan TOPIC REgained"
				puthelp "TOPIC $chan :[stats:channel -get $chan topictext]"
				if {![string equal $hand nohandspecified]} {
					if {![a:flood -topic $chan $hand $uhost]} {a:tell "[split $nick] [split $hand] [split $chan] pub" 119 "[stats:channel -get $chan topicwhom] [iif [channel get $chan topic] + -]topic [iif [channel get $chan enforcetopic] + -]enforcetopic"}}
			}
		}
	}
}

return "local m commands"