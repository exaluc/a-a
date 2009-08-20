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
############ Loading check ###########################

if {![info exists ::xserv::chanserv]} {return skipped}

############ Command Binds ###########################

a:command -add xop         pub:xop        1056 556 |X
a:command -add xdeop       pub:xdeop      1055 557 |X
a:command -add xkick       pub:xkick      1054 558 |X
a:command -add xban        pub:xban       1053 559 |X
a:command -add xunban      pub:xunban     1052 560 |X
a:command -add xvoice      pub:xvoice     1051 561 |X
a:command -add xdevoice    pub:xdevoice   1050 562 |X
a:command -add xtopic      pub:xtopic     1049 563 |X
a:command -add xclearmode  pub:xclearmode 1048 564 |X
a:command -add xadduser    pub:xadduser   1047 565 |X
a:command -add xremuser    pub:xremuser   1046 566 |X
a:command -add xmodify     pub:xmodify    1045 567 |X
a:command -add xautomode   pub:xautomode  1044 568 |X
a:command -add xsuspend    pub:xsuspend   1043 569 |X
a:command -add xunsuspend  pub:xunsuspend 1042 570 |X
a:command -add xsupport    pub:xsupport   1041 571 |X
a:command -add xautotopic  pub:xautotopic 1040 572 |X
a:command -add xdesc       pub:xdesc      1057 573 |X
a:command -add xurl        pub:xurl       1039 574 |X
a:command -add xlog        pub:xlog       1098 592 |X
a:command -add xinfo       pub:xinfo      1083 548 |X

############ Command Procs ###########################

proc pub:xop {hand chan args x mix} {

	set whom    [lrange $args 0 end]
	set oppless ""
	set opped   ""
	set nohere  ""
	set d       ""
	set talk    1

	if { [string first * $whom] > -1 } { set whom [a:check -regx $whom $chan]; set talk 0} elseif {
	$whom == "" || [string equal me $whom]} {set whom [split [lindex $x 0]]}

	foreach z $whom {
		if {![onchan $z $chan]}				 { lappend nohere  $z} elseif {
		     [isop   $z $chan]}				 { lappend opped   $z} elseif {
		     [matchattr [nick2hand $z $chan] d|d $chan]} { lappend d       $z} else   {
								   lappend oppless $z
		}
	}

	if {$nohere  != "" && $talk == 1} {a:tell $x 90 "[join $nohere]"}
	if {$opped   != "" && $talk == 1} {a:tell $x 97 "[join $opped]"}
	if {$d       != "" && $talk}      {a:tell $x 288 "[join $d]"}
	if {$oppless != "" }              {::xserv::put op $chan "[join $oppless]" $x; return "[join [lrange $oppless 0 2]] ..."} {
										       return "FAILED: no nick to xop"
	}
}

proc pub:xdeop {hand chan args x mix} {

	set whom    [lrange $args 0 end]
	set oppless ""
	set opped   ""
	set nohere  ""
	set higher  ""
	set a       ""
	set talk    1

	if { [string first * $whom] > -1 } { set whom [a:check -regx $whom $chan]; set talk 0} elseif {
	$whom == "" || [string equal me $whom]} {set whom [split [lindex $x 0]]}

	foreach z $whom {
		if {![isbotnick  $z]} {
			if {![onchan     $z $chan]}                          { lappend nohere  $z} elseif {
			    ![isop       $z $chan]}                          { lappend opped   $z} elseif {
			    ![a:level $x $chan $z [nick2hand $z] [a:translate $hand $chan 222 xdeop] $talk]} { lappend higher  $z} elseif {
			     [matchattr [nick2hand $z $chan] aW|a $chan]}    { lappend a       $z} else   {
									       lappend oppless $z
			}
		}
	}

	if {$nohere  != "" && $talk == 1} { a:tell $x 90 "[join $nohere]"}
	if {$opped   != "" && $talk == 1} { a:tell $x 99 "[join $opped]"}
	if {$a       != "" && $talk}      { a:tell $x 287 "[join $a]"}
	if {$oppless != "" }              {::xserv::put deop $chan "[join $oppless]" $x; return "[join [lrange $oppless 0 2]] ..."} {
											 return "FAILED: no nick to xdeop"
	}
}

proc pub:xvoice {hand chan args x mix} {

	set whom      [lrange $args 0 end]
	set voiceless ""
	set voiced    ""
	set nohere    ""
	set q	      ""
	set talk      1

	if { [string first * $whom] > -1 } { set whom [a:check -regx $whom $chan]; set talk 0} elseif {
	$whom == "" || [string equal me $whom]} {set whom [split [lindex $x 0]]}

	foreach z $whom {
		if {![onchan  $z $chan]}			 { lappend nohere    $z} elseif {
		     [isvoice $z $chan]}			 { lappend voiced    $z} elseif {
		     [matchattr [nick2hand $z $chan] q|q $chan]} { lappend q         $z} else   {
								   lappend voiceless $z
		}
	}

	if {$nohere    != "" && $talk == 1} {a:tell $x 90 "[join $nohere]"}
	if {$voiced    != "" && $talk == 1} {a:tell $x 92 "[join $voiced]"}
	if {$q         != "" && $talk == 1} {a:tell $x 285 "[join $q]"}
	if {$voiceless != "" }              {::xserv::put voice $chan "[join $voiceless]" $x; return "[join [lrange $voiceless 0 2]] ..." } {
											      return "FAILED: no nick to xvoice"
	}
}

proc pub:xdevoice {hand chan args x mix} {

	set whom      [lrange $args 0 end]
	set voiceless ""
	set voiced    ""
	set nohere    ""
	set g         ""
	set talk      1

	if { [string first * $whom] > -1 } { set whom [a:check -regx $whom $chan]; set talk 0} elseif {
	$whom == "" || [string equal me $whom]} {set whom [split [lindex $x 0]]}

	foreach z $whom {
		if {![onchan  $z $chan]}			 { lappend nohere    $z} elseif {
		    ![isvoice $z $chan]}			 { lappend voiced    $z} elseif {
		     [matchattr [nick2hand $z $chan] g|g $chan]} { lappend g         $z} else   {
								   lappend voiceless $z
		}
	}

	if {$nohere    != "" && $talk == 1} {a:tell $x 90  "[join $nohere]" }
	if {$voiced    != "" && $talk == 1} {a:tell $x 91  "[join $voiced]" }
	if {$g         != "" && $talk == 1} {a:tell $x 286 "[join $g]"}
	if {$voiceless != "" }              {::xserv::put devoice $chan "[join $voiceless]" $x; return "[join [lrange $voiceless 0 2]] ..." } {
												return "FAILED: no nick to xdevoice"
	}
}

proc pub:xkick {hand chan args x mix} {

	set whom    [lindex $args 0]
	set reason  [join [lrange $args 1 end]]

	if { $whom == ""} {a:usage $x xkick; return "FAILED: not all parameters specified"}
	if {![onchan $whom]} {a:tell $x 103 "$whom" ; return "FAILED: nick is not on chan ($whom)"}
	if { $reason == ""} {set reason "No reason" }
	if {![a:level $x $chan $whom [nick2hand $whom] [a:translate $hand $chan 222 xkick]]} { return "FAILED: target access is higher" }

	set reason "$reason from [lindex $x 0] (hand: $hand)"

	return [::xserv::put kick $chan "$whom :$reason" $x]
}

proc pub:xban {hand chan args x mix} {

	set whom     [lindex  $args 0]
	set duration [lindex  $args 1]
	set level    [lindex  $args 2]
	set reason   [join [lrange $args 3 end]]

	if { $whom == ""} {a:usage $x xban ; return "FAILED: not all parameters specified"}
	if { [string map {* {} . {} ! {} @ {} ? {}} $whom] == ""} {a:tell $x 190; return "FAILED: mass ban caution"}
	if {![a:level $x $chan $whom [nick2hand $whom] [a:translate $hand $chan 222 xban]]} {return "FAILED: target access is higher" }
	if {![regexp {^(\d+)$} $level]}    {set level 75;   set reason [join [lrange $args 2 end]]}
	if {![regexp {^(\d+)$} $duration]} {set duration 3; set reason [join [lrange $args 1 end]]}
	if {![string length $reason]}      {set reason "No reason" }
	if { $duration > 336} {set duration 336}; if { $duration < 1} {set duration 1}
	if { $level > 500   } {set level 400}   ; if { $level < 1 }   {set level 44}

	set reason "(by ${hand}/\002[lindex $x 0]\002 at ${level} X level) \[${duration}\] $reason"

	return [::xserv::put ban $chan "$whom $duration $level $reason" $x]
}

proc pub:xunban {hand chan args x mix} {

	set whom [lindex $args 0]

	if { $whom == ""} { a:usage $x xunban; return "FAILED: not all parameters specified"}
	if { [string equal * $whom]} { set whom *!*@*}

	return [::xserv::put unban $chan "$whom" $x]
}

proc pub:xtopic {hand chan args x mix} {

	set topic [join $args]

	if  { $topic == ""} { a:usage $x xtopic; return "FAILED: not all parameters specified" }

	return [::xserv::put topic $chan "$topic" $x]
}

proc pub:xurl {hand chan args x mix} {

	set url [join $args]

	if { $url == ""} { a:usage $x xurl; return "FAILED: not all parameters specified" }

	return [::xserv::put set $chan "url $url" $x]
}

proc pub:xclearmode {hand chan args x mix} {return [::xserv::put clearmode $chan "" $x]}

proc pub:xadduser {hand chan args x mix} {

	set who    [lindex  $args 0]
	set level  [lindex  $args 1]

	if { $who == ""}		{a:usage $x xadduser; return "FAILED: not all parameters specified"}
	if {![regexp {^(\d+)$} $level]} {set level 111 }
	if { $level >  498 }            {set level 400 }

	return [::xserv::put adduser $chan "$who $level" $x]
}

proc pub:xremuser {hand chan args x mix} {

	set who [lindex $args 0]

	if { $who == ""} { a:usage $x xremuser; return "FAILED: not all parameters specified" }

	return [::xserv::put remuser $chan $who $x]
}

proc pub:xmodify {hand chan args x mix} {

	set who    [lindex  $args 0]
	set level  [lindex  $args 1]

	if { $who == ""}		{a:usage $x xmodify; return "FAILED: not all parameters specified"}
	if {![regexp {^(\d+)$} $level]} {set level 270 }
	if { $level >  498 }            {set level 400 }

	return [::xserv::put modinfo $chan "access $who $level" $x]
}

proc pub:xautomode {hand chan args x mix} {

	set who    [lindex  $args 0]
	set mode   [lindex  $args 1]

	if { $who == "" || ![regexp {^(op|voice|none)$} $mode]} { a:usage $x xautomode; return "FAILED: not all or invalid parameters specified" }

	return [::xserv::put modinfo $chan "automode $who $mode" $x]
}

proc pub:xsuspend {hand chan args x mix} {

	set who      [lindex  $args 0]
	set duration [lindex  $args 1]

	if {![string length $who]}         { a:usage $x xsuspend; return "FAILED: not all parameters specified" }
	if {![regexp {^(\d+)$} $duration]} { set duration 24 }
	if { $duration > 8928} {set duration 8928}

	return [::xserv::put suspend $chan "$who $duration h" $x]
}

proc pub:xunsuspend {hand chan args x mix} {

	set who [lindex $args 0]

	if { $who == ""} {a:usage $x xunsuspend; return "FAILED: not all parameters specified"}

	return [::xserv::put unsuspend $chan $who $x]
}

proc pub:xsupport {hand chan args x mix} {
	global ::xserv::chanserv

	set what [lindex $args 0]

	if { [botonchan $chan] && [onchan $chanserv(nick) $chan]} {a:tell $x 53 "$chanserv(nick) $chan"; return "FAILED: $chanserv(nick) already on $chan"}
	if {![regexp {^(yes|no)$} $what]} {a:usage $x xsupport; return "FAILED: not all or invalid parameters specified"}

	return [::xserv::put support $chan $what $x]
}

proc pub:xautotopic {hand chan args x mix} {

	set what [lindex $args 0]

	if {![regexp {^(on|off)$} $what]} {a:usage $x xautotopic; return "FAILED: not all parameters specified"}

	return [::xserv::put set $chan "autotopic $what" $x]
}

proc pub:xdesc {hand chan args x mix} {

	set what [join [lrange $args 0 end]]

	if { $what == ""} { a:usage $x xdesc; return "FAILED: not all parameters specified"}

	return [::xserv::put set $chan "description $what" $x]
}


proc pub:xlog {hand chan args x mix} {
	global ::xserv::chanserv

	if {!$chanserv(log) || ([check:N:gl $hand] && [a:check -now [lindex $args 0]])} {
		::xserv::login
		a:tell $x 185 $chanserv(nick)
		return "..."
	} else {
		a:tell $x 184 $chanserv(nick)
		return "FAILED: already logged"
	}
}

proc pub:xinfo {hand chan args x mix} {

	if {![check:v:gl $hand]} {return "FAILED: not enough access"}

	global botnick

	::xserv::queue info =${botnick}

	return "..."
}

return "local X commands"