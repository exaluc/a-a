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
############ Parser ##################################

proc a:parser {nick uhost hand chan dir comm arg} {

	if { [check:b:gl $hand]} {return}

	set option  [lindex $arg 0]
	set chan1st $chan

	global settings

	if { [string match "#*" $option]} {set args [lrange $arg 1 end]; set chan $option} { set args $arg}

	if {![a:command -exists $comm] || [a:com:status -inactive $comm $chan] || \
	    ($settings(flood) && [a:flood -commands $chan $hand $uhost $nick $dir])} {return}

	set x "[split $nick] [split $hand] [split $chan1st] $dir"

	if { [validchan $chan] } {
		if {![botonchan $chan] && ![string match {|[suU]} [a:command -level $comm]] && ![regexp -nocase -- {^(purge|comeback|templeave|xremuser|xban|xkick|stats|chaninfo|chanset|suspend|admins|list|enable|disable)$} $comm]} {
		      if { [check:v:ch $hand $chan]} {a:tell $x 21 "$chan"; putcmdlog "<<$hand>> $nick!$uhost $chan INACTIVE CHAN ($chan)"}
		      return
		}
	} elseif {![string equal $comm join] && ![string equal $comm stats]} {
			if { [check:v:gl $hand]} {a:tell $x 20 "$chan"}
			return
	}

	if { [check:S:ch $hand $chan] && ![check:N:gl $hand]} { a:tell $x 149; return}

	set mix	"[split $uhost]"

	switch -glob -- [a:command -level $comm] {
		{|[us]}  {set report [catch {[a:command -proc $comm] $hand $chan $args $x $mix} execute]}
		|*       {if { [check:[string index [a:command -level $comm] 1]:ch $hand $chan] && [a:authorised $nick $uhost $hand]} { set report [catch {[a:command -proc $comm] $hand $chan $args $x $mix} execute]} {return}}
		default  {if { [check:[a:command -level $comm]:gl $hand] && [a:authorised $nick $uhost $hand]}                        { set report [catch {[a:command -proc $comm] $hand $chan $args $x $mix} execute]} {return}}
	}

	putcmdlog "<<$hand>> $nick!$uhost $chan [string toupper $comm] $execute"

	if {$report && $settings(tcl_error_warn)} {a:announce -permowner ERROR "<<$hand>> $nick!$uhost $chan $dir >>> [a:command -proc $comm] >>> $comm $args >>> $::errorInfo"}
}

proc a:parse:anti  {nick uhost hand chan text args}  {

	if {![validchan $chan] || ![botisop $chan] || [check:fo:ch $hand $chan $nick]} {return}

	if { [channel get $chan antipub]       &&  [string match "*#*"  $text]}		       {set why "antipub" }      elseif {
	     [channel get $chan anticolour]    &&  [string match *\003* $text]}		       {set why "anticolour" }   elseif {
	     [channel get $chan antirepeat]    &&  [a:flood -repeat $chan $hand $uhost $text]} {set why "antirepeat" }   elseif {
	     [channel get $chan antinotice]    &&  [string equal [lindex $args 0] notice]}     {set why "antinotice" }   elseif {
	     [channel get $chan antiunderline] &&  [string match *\037* $text]}		       {set why "antiunderline"} elseif {
	     [channel get $chan antibold]      &&  [string match *\002* $text]}		       {set why "antibold" }     elseif {
	     [channel get $chan antireverse]   &&  [string match *\026* $text]}		       {set why "antireverse" }  elseif {
	     [channel get $chan antiurl]       && ([string match *www.*.* $text] || [string match *http://*.* $text])} {set why "antiurl" } else {return}

	global username

	newchanban $chan [a:maskhost -host $uhost] $username "channel $why protection enabled" [channel get $chan ban-time] sticky
	putcmdlog "<<${username}>> $why protection -- $chan ${nick}!${uhost}"
}

proc a:flood {cmd chan {hand ""} {uhost ""} {nick ""} {arg ""}} {
	global flood username

	switch -- $cmd {
		-commands {
			  if {![isdynamic $chan] && [string equal $arg pub]} {return 0} elseif {
			      ![info exists flood(10s,chan,${chan})]} {set flood(10s,chan,${chan}) 1} {incr flood(10s,chan,${chan})}

			  if {![info exists flood(30s,uhost,${uhost})]} {set flood(30s,uhost,${uhost}) 1} {incr flood(30s,uhost,${uhost})}

			  if { $flood(30s,uhost,${uhost}) <= $flood(user) || ([check:v:ch $hand $chan]  && \
			      ($flood(30s,uhost,${uhost}) <= $flood(user,local)  || [check:v:gl $hand])  && \
			       $flood(30s,uhost,${uhost}) <= $flood(user,global)) } {
			       if { $flood(10s,chan,${chan}) > $flood(channel)} {return 1} {return 0}
			  }

			  a:log actions "BOT - antiflood protection -- ignoring ${nick}!${uhost}"

			  set host  "*!*@[lindex [split $uhost @] 1]"

			  if {![info exists flood(24h,host,$host)]} {set flood(24h,host,$host) 1} {incr flood(24h,host,$host)}
			  if { $flood(24h,host,$host) > 3} {newignore $host $username  "commands flood from this host" 1440} elseif {
			      ![check:v:ch $hand $chan]}   {newignore $uhost $username "commands flood from this host" 360 } elseif {
			      ![check:v:gl $hand]}	   {newignore $uhost $username "commands flood from this host" 60 } else {
							    newignore $uhost $username "commands flood from this host" 15
			  }
			  return 1
		}
		-topic	{ if {![info exists flood(1m,topic,$chan,$uhost)]} {set flood(1m,topic,$chan,$uhost) 1; return 0}; incr flood(1m,topic,$chan,$uhost)
			  if { $flood(1m,topic,$chan,$uhost) > $flood(topic)} {
				if { [matchattr $hand f|f $chan]} {chattr $hand -f|-f $chan; setuser $hand XTRA _FLAG "[unixtime] -f $chan $username"}
				newchanban $chan *!${uhost} ${username} "channel topic protection enabled" [channel get $chan ban-time] sticky
				return 1} {return 0}
		}
		-need	{ global need
			  if {![info exists need(1h,need,$chan)]} {set need(1h,need,$chan) 0; return 0}; incr need(1h,need,$chan)
			  if { $need(1h,need,$chan) > 6} {array unset need 1h,need,$chan; return 1} {return 0}
		}
		-modes	{ if { [check:m:ch $hand $chan] || [isbotnick $nick] || !$flood(modes)} {return 0}
			  if {![info exists flood(1m,modes,$chan,$uhost)]} {set flood(1m,modes,$chan,$uhost) 1; return 0} ; incr flood(1m,modes,$chan,$uhost)
			  if { $flood(1m,modes,$chan,$uhost) > $flood(modes)} {
				if { [matchattr $hand |f $chan]} {chattr $hand |-f $chan}
				newchanban $chan *!${uhost} ${username} "channel modes protection enabled" [channel get $chan ban-time] sticky
				return 1} {return 0}
		}
		-repeat { if {![info exists flood(1m,repeat,$chan,$uhost,$nick)]} {set flood(1m,repeat,$chan,$uhost,$nick) 1; return 0} ; incr flood(1m,repeat,$chan,$uhost,$nick)
			  if  {$flood(1m,repeat,$chan,$uhost,$nick) > 2} {return 1} {return 0}
		}
		default {return 0}
	}
}

proc a:level {x c g h l {talk 1}} {

	set f [lindex $x 1]
	set h [lindex $h 0]

	if {![validuser $f] || [string equal -nocase $f $h] || ![check:v:ch $h $c]} {return 1}

	global settings

	if { [check:x:xx $h] && ![check:x:xx $f]} {if {$talk} { a:tell $x 164 "»$l« $g $h $settings(suppchan) FOUNDER"}; return 0 } elseif {
	     [check:N:gl $h] && ![check:N:gl $f]} {if {$talk} { a:tell $x 164 "»$l« $g $h $settings(suppchan) MANAGER"}; return 0 } elseif {
	     [check:L:gl $h] && ![check:N:gl $f]} {if {$talk} { a:tell $x 164 "»$l« $g $h GLOBALY LOCKED"}             ; return 0 } elseif {
	     [check:B:gl $h] && ![check:N:gl $f]} {if {$talk} { a:tell $x 164 "»$l« $g $h $settings(suppchan) BOT"}    ; return 0 } elseif {
	     [check:n:gl $h] && ![check:N:gl $f]} {if {$talk} { a:tell $x 164 "»$l« $g $h $settings(suppchan) OWNER"}  ; return 0 } elseif {
	     [check:m:gl $h] && ![check:n:gl $f]} {if {$talk} { a:tell $x 164 "»$l« $g $h $settings(suppchan) MASTER"} ; return 0 } elseif {
	     [check:o:gl $h] && ![check:m:gl $f]} {if {$talk} { a:tell $x 164 "»$l« $g $h $settings(suppchan) OP"}     ; return 0 } elseif {
	     [check:l:gl $h] && ![check:o:gl $f]} {if {$talk} { a:tell $x 164 "»$l« $g $h $settings(suppchan) HALFOP"} ; return 0 } elseif {
	     [check:v:gl $h] && ![check:l:gl $f]} {if {$talk} { a:tell $x 164 "»$l« $g $h $settings(suppchan) HELPER"} ; return 0 } elseif {
	     [check:P:gl $h] && ![check:v:gl $f]} {if {$talk} { a:tell $x 164 "»$l« $g $h GLOBALY PROTECTED"}          ; return 0 } elseif {
    	     [check:N:ch $h $c] && ![check:m:gl $f]	    } {if {$talk} { a:tell $x 164 "»$l« $g $h $c MANAGER"}     ; return 0 } elseif {
    	     [check:L:ch $h $c] && ![matchattr $f mN|N $c]  } {if {$talk} { a:tell $x 164 "»$l« $g $h LOCALY LOCKED"}  ; return 0 } elseif {
    	     [check:n:ch $h $c] && ![matchattr $f mN|N $c]  } {if {$talk} { a:tell $x 164 "»$l« $g $h $c OWNER"}       ; return 0 } elseif {
    	     [check:m:ch $h $c] && ![matchattr $f mN|nN $c] } {if {$talk} { a:tell $x 164 "»$l« $g $h $c MASTER"}      ; return 0 } elseif {
    	     [check:o:ch $h $c] && ![matchattr $f oN|mN $c] } {if {$talk} { a:tell $x 164 "»$l« $g $h $c OP"}          ; return 0 } elseif {
	     [check:l:ch $h $c] && ![matchattr $f lN|oN $c] } {if {$talk} { a:tell $x 164 "»$l« $g $h $c OP"}          ; return 0 } elseif {
       	     [check:v:ch $h $c] && ![matchattr $f lN|lN $c] } {if {$talk} { a:tell $x 164 "»$l« $g $h $c VOICE"}       ; return 0 } else {return 1}
}

############ Command proc ############################

proc a:command {cmd {com ""} {proc ""} {help ""} {usage ""} {level ""}} {
	global comm

	set com  [string tolower $com]
	set proc [string tolower $proc]

	switch -exact -- $cmd {
		-level     { return $comm($com,level)}
		-exists    { return [info exists comm($com,commands)]}
		-proc	   { return $comm($com,proc)}
		-help	   { return $comm($com,help)}
		-usage	   { return $comm($com,usage)}
		-all	   { set temp ""; foreach w [array names comm *,commands] {lappend temp $comm($w)}; return $temp}
		-unload	   { if {[info exists comm]} {unset comm}}
		-add	   { set comm($com,commands) "$com"
			     set comm($com,level)    "$level"
			     set comm($com,help)     "$help"
			     set comm($com,usage)    "$usage"
			     set comm($com,proc)     "$proc"
		}
		default	  { return 0}
	}
}

proc a:com:status {cmd {com ""} {chan ""} {mix ""}} {
	global status

	set com  [string tolower $com]
	set chan [string tolower $chan]

	switch -exact -- $cmd {
		-disabled  {if {([info exists status($chan,$com,disabled)] || [info exists status($chan,all,disabled)]) && ![string equal -nocase $com enable]} {return 1} {return 0}}
		-inactive  {if {([info exists status($chan,$com,disabled)] || [info exists status($chan,all,disabled)] || [info exists status(global,$com,disabled)] || [info exists status(global,all,disabled)]) && ![string equal $com enable]} {return 1} {return 0}}
		-disable   {if { [string equal $com -all]} {catch {array unset status *,$chan,disabled }; set status($chan,all,disabled) 1} {set status($chan,$com,disabled) 1}}
		-enable    {if { [string equal $com -all]} {catch {array unset status *,$chan,disabled }} {catch {unset status($chan,$com,disabled)}}}
		-clean     {catch {array unset status $com,*}}
		-autoclean {set list ""; foreach chan [channels] {if { [llength [set a [array get status $chan,*]]]} {lappend list $a}}; catch {array unset status}; array set status [join $list]; return 1}
		-array     {set status(version) $::settings(numversion); return [list array set status [array get status]]}
		default    {return 0}
	}
}

proc a:com:alias {cmd {com ""} {chan ""} {mix ""}} {
	global alias

	set com  [string tolower $com]
	set chan [string tolower $chan]

	switch -exact -- $cmd {
		-check	   -
		-exists	   -
		-add	   -
		-remove    -
		-list	   -
		-count     -
		-clean	   -
		-autoclean -
		-array	   -
		default    {return 0}
	}
}

############ Output procs ############################

proc a:announce {com a {b ""} {c ""} {d ""}} {
	global owner settings

	switch -exact -- [string tolower $com] {

		-home	{ if {$settings(report)} { a:tell "{} * [split $settings(homechan)] pub" $a $b }}
		-chan	{ a:tell "{} * [split $b] pub" $a $c}
		-owner	{ foreach manager [userlist R&N $b] {sendnote $a $manager "[a:translate $manager $b $c $d]"}}
		-user   { if { [check:R:gl $b]} {sendnote $a $b "[a:translate $b $settings(homechan) $c $d]"}}
		-permowner {foreach manager [split $owner ", "] {if {[check:R:gl $manager]} {sendnote $a $manager $b}}}
	}
}

#a part of code (c) hex@forestnet.org
proc a:tell {x id {arg ""}} {
	global say botnick

	set nick [lindex $x 0]
	set hand [lindex $x 1]
	set chan [lindex $x 2]
	set dir  [lindex $x 3]
	set q    [getuser $hand XTRA _LANG_OUT]

	if {$q == ""} {set z $say(lang.1.${id})} else { set z $say(lang.${q}.${id})}

	set txt    [a:lang $z $arg]

	switch -exact -- [getuser $hand XTRA _COL_OUT] {
			none	{set txt [string map {%B {} %b {} %r {} %u {} %% {}} $txt]}
			bold	{set txt [string map {%B \002 %b \002 %r \002 %u \002 %% \002} $txt]}
			1	{set txt [string map {%B \002 %b \00302\002 %r \00304\002 %u \037 %% \002\003} $txt]}
			2	{set txt [string map {%B \002 %b \00306 %r \00315 %u \037 %% \003} $txt]}
			default	{set txt [string map {%B \002 %b \00302 %r \00304 %u \037 %% \003} $txt]}
	}

	set msgmax [expr 495 - [string length "$botnick![getchanhost $botnick] $chan $nick"]]

	while {$txt != ""} {

		if { [string length $txt] > $msgmax} {
			set msg [string range $txt 0 [string last \x20 [string range $txt 0 $msgmax]]]
			set txt [string trim [string range $txt [string length $msg] end]]} {
			set msg "$txt"
			set txt ""
		}

		switch -exact -- $dir {

			pub {
				switch -exact -- [getuser $hand XTRA _PUB_OUT] {

					msg	{puthelp "PRIVMSG $nick :$msg"}
					note	{puthelp "NOTICE $nick :$msg"}
					default {puthelp "PRIVMSG $chan :$nick $msg"}
				}
			}

			msg {
				switch -exact -- [getuser $hand XTRA _MSG_OUT] {

					chan	{puthelp "PRIVMSG $chan :$nick $msg"}
					note	{puthelp "NOTICE $nick :$msg"}
					default {puthelp "PRIVMSG $nick :$msg"}
				}
			}
		}
	}
}

proc a:translate {hand chan id {arg ""}} {
	global say

	set lang [getuser $hand XTRA _LANG_OUT]

	if {$lang == ""} {set talk $say(lang.1.${id})} else {
			  set talk $say(lang.${lang}.${id})}
	return [a:lang $talk $arg]
}

proc a:lang {x y} {

	set c [string last « $x]
	if {![string length $y] || !$c=="-1"} {return $x}
	set a -1
	set b -1
	set y [string map {» \{ « \} } [split $y]]
	set z ""

	for {set i 0} { $i < [string length $x] } { incr i } {
		if {[string index $x $i] == "«" } { incr b
			  if {$i!=$c} {
				append z "[lindex $y $b]"  } {
				append z "[join [lrange $y $b end]]" }} {
				append z "[string index $x $i]" }}

	return "$z"
}

############ Check access level ######################

proc check:x:xx {hand}      { global owner ; if { [matchattr $hand N ] && ([lsearch -exact [split [string tolower $owner] ", "] [string tolower $hand]] != -1)} {return 1} else {return 0}}

proc check:Q:gl {hand}      {return [matchattr $hand Q ]}
proc check:A:gl {hand}      {return [matchattr $hand A ]}
proc check:R:gl {hand}      {return [matchattr $hand R ]}
proc check:I:gl {hand}      {return [matchattr $hand I ]}
proc check:W:gl {hand}      {return [matchattr $hand W ]}
proc check:L:gl {hand}      {return [matchattr $hand L ]}
proc check:S:gl {hand}      {return [matchattr $hand S ]}
proc check:X:gl {hand}      {return [matchattr $hand XN]}
proc check:P:gl {hand}      {return [matchattr $hand P ]}
proc check:H:gl {hand}      {return [matchattr $hand H ]}
proc check:N:gl {hand}      {return [matchattr $hand N ]}
proc check:n:gl {hand}      {return [matchattr $hand nN]}
proc check:m:gl {hand}      {return [matchattr $hand m ]}
proc check:o:gl {hand}      {return [matchattr $hand o ]}
proc check:l:gl {hand}      {return [matchattr $hand l ]}
proc check:B:gl {hand}      {return [matchattr $hand B ]}
proc check:b:gl {hand}      {return [matchattr $hand b ]}
proc check:v:gl {hand}      {return [matchattr $hand vl]}
proc check:s:gl {hand}      {return [matchattr $hand vl]}
proc check:d:gl {hand}      {return [matchattr $hand d ]}
proc check:k:gl {hand}      {return [matchattr $hand k ]}

proc check:U:ch {hand chan} {return [validuser $hand]}
proc check:S:ch {hand chan} {return [matchattr $hand S|S   $chan] }
proc check:L:ch {hand chan} {return [matchattr $hand L|L   $chan] }
proc check:P:ch {hand chan} {return [matchattr $hand P|P   $chan] }
proc check:H:ch {hand chan} {return [matchattr $hand H|H   $chan] }
proc check:X:ch {hand chan} {return [matchattr $hand XN|XN $chan] }
proc check:N:ch {hand chan} {return [matchattr $hand m|N   $chan] }
proc check:n:ch {hand chan} {return [matchattr $hand m|nN  $chan] }
proc check:m:ch {hand chan} {return [matchattr $hand o|m   $chan] }
proc check:o:ch {hand chan} {return [matchattr $hand o|o   $chan] }
proc check:l:ch {hand chan} {return [matchattr $hand l|l   $chan] }
proc check:v:ch {hand chan} {return [matchattr $hand vl|vl $chan] }
proc check:p:ch {hand chan} {return [matchattr $hand p|p   $chan] }

proc check:f:ch  {hand chan nick} { if { [matchattr $hand fvloPHBNW|fnPHN $chan] || [isbotnick $nick] || $nick == ""} {return 1} else {return 0}}
proc check:fo:ch {hand chan nick} { if { [matchattr $hand fvloPHBNW|floPHN $chan] || [isbotnick $nick] || $nick == "" || [isop $nick $chan]} {return 1} else {return 0}}

############ Procs ###################################

proc a:check {cmd {a ""} {b ""} {c ""}} {

	switch -exact -- $cmd {
		-now    { if { [string equal -nocase $a !] || [string equal -nocase $a -now]} {return 1} {return 0}}
		-info   { if { [string equal -nocase $a ?] || [string equal -nocase $a info]} {return 1} {return 0}}
		-host   { return [regexp -- {.+!+[^@]+@[^@][[:alnum:]*-\.\?]+[[:alnum:]*]$} $a]}
		-ip     { return [regexp -- {^\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}$} $a]}
		-regx   { set c ""; foreach x [chanlist $b] {if {[string match -nocase $a $x]} {lappend c $x}}; return $c}
		-digit  { if { [scan $a "%f%s" f g] == 1} {return 1}  {return 0}}
		-mail   { return [string match -nocase *?@?*.??* $a]}
		-url    { return [string match -nocase http://?*.??* $a]}
		-reason { return [regexp -- {^(flood-(deop|kick|ban|chan|bot)|no-(op|access|ppl|need)|take|invite|key|limit|abuse|banned|opless|blacklist|other)$} $a]}
		default { return 0}
	}
}

proc a:validate {cmd a {b ""}}  {

	switch -exact -- $cmd {
		-hand	{if { [validuser $a]} {return $a} {return *}}
		-digit  {if { [scan $a "%f%s" f g] == 1} {return $a} {return 0}}
		-secret { if {![channel get $a secret] || ![isdynamic $b] || [string equal -nocase $a $b]} {return $a} {return +secret}}
		default {return 0}
	}
}

proc a:modify {cmd x a {b ""}} {

	switch -exact -- $cmd {
		-nick	  {return "[split $a] [split [lindex $x 1]] [split [lindex $x 2]] [split [lindex $x 3]]"}
		-hand	  {return "[split [lindex $x 0]] [split $a] [split [lindex $x 2]] [split [lindex $x 3]]"}
		-nickhand {return "[split $a] [split $b] [split [lindex $x 2]] [split [lindex $x 3]]"}
		default   {return 0}
	}
}

proc a:replace {cmd a b {c ""} {d ""}} {

	switch -exact -- $cmd {
		-nick   {regsub -all -nocase -- %nick% $a $b a; return "$a"}
		-chan   {regsub -all -nocase -- %chan% $a $b a; return "$a"}
		-all	{regsub -all -nocase -- %nick% $a $b a; regsub -all -nocase -- %from% $a $c a; return "$a"}
	}
}

proc iif {a b {c ""}} {if {$a} {return $b} {return $c}}

#copyright for -ip2short & -bytes2kb uknown (taken a lot of time ago from web)

proc a:fix {cmd {a ""}} {

	switch -exact -- $cmd {

		-ip2short {return "[expr ($a >> 24) & 255].[expr ($a >> 16) & 255].[expr ($a >> 8) & 255].[expr $a & 255]"}
		-bytes2kb {if {wide($a) < 1000} {return ${a}b}
			    foreach unit {K M G T P E} {
				set a [expr {$a/1024.}]
				if {$a < 1000} {
				    set a [string range $a 0 3]
				    regexp {(.+)\.$} $a -> a
				    return $a$unit
				}
			    }
			    return Inf
		}
		default	{return 0}
	}
}

proc a:maskhost {cmd {a ""} {b ""} {c ""}} {

	switch -exact -- $cmd {

		-host	 {if {[string match -nocase *@*.users.*.org $a]} { return "*!*[join [regexp -inline -- {@[^@].+} $a]]"} elseif {
			      [regexp {^.+@\w.+\d[\.-]\d.+[[:alpha:]]$} $a]}    { return "*![regexp -inline -- {^[^\@]+} $a]@*[regexp -inline -- {\.[^\.]+\.[^\.]+$} $a]"} else {
										  return [maskhost $a]}}
		-uhost	 {if {[string match -nocase *@*.users.*.org $a]} { return "*!*[join [regexp -inline -- {@[^@].+} $a]]"} else {return *!$a}}
		default  {return "*!*[join [regexp -inline -- {@[^@].+} $a]]"}
	}
}

proc a:deluser {x f g} {

	if {[onchan $f [lindex $x 2]]} {
		if { [nick2hand $f] != "*"} { return [nick2hand $f] } elseif {
		     [validuser $f]}        {
			if {[a:check -now $g]} { return $f }  else {
					      a:tell $x 22 $f ; return 0 }} else  {
					      a:tell $x 23 $f ; return 0 }} elseif {
			[validuser $f] }    { return $f } else {
					      a:tell $x 23 $f ; return 0
	}
}

proc a:adduser {x f g h} {
	global one settings

	if { [onchan $f $h]} {
		if { [validuser [nick2hand $f]]} { return [nick2hand $f]} elseif {
		     [validuser $f]} {
			if { [a:check -now $g]}  { return $f } else { a:tell $x 22 $f; return 0}
		} else {
			if { [string length $f] > $::handlen } {a:tell $x 46 $f; return 0}
			set host [a:maskhost -uhost [getchanhost $f]]
			adduser $f $host; chattr $f $settings(flags_default); set one 1
			a:tell $x 24 $f ; return $f
		}
	} elseif { [validuser $f]} { return $f
	} else   {   a:tell $x 25 $f ; return 0
	}
}

proc a:log  {cmd text}  {
	global botnet log username

	if {![info exists log($cmd)]} {set log($cmd) 1}

	putloglev $log($cmd) * "\[$username\] [string toupper $cmd] $text"
}

proc a:getxtra {cmd b {c ""}} {

	switch -exact -- $cmd {
		-ctime  {return [ctime [lindex [split [getuser $b XTRA $c]] 0]]}
		-uhost  {return [lindex [split [getuser $b XTRA $c]] 1]}
		-hand   {return [lindex [split [getuser $b XTRA $c]] 2]}
		default {return [split [getuser $cmd XTRA $b]]}
	}
}

proc a:botnet:get {} {
}

proc a:botnet:put {} {
}

proc a:counterspy {chan} {

	if { [channel get $chan inactive] && ![channel get $chan suspended] && ![string match -nocase *[list channel set $chan -inactive]*  [utimers]]} {channel set $chan -inactive}
}

proc a:opless {chan} {

	if {![botisop $chan] && ![channel get $chan locked]} {foreach z [chanlist $chan] {if {[isop $z $chan] } {a:announce -chan $chan 125 "$chan [a:maskhost -uhost [lindex [split $::botname !] 1]]"; break}}}
}

proc iif {a b {c ""}} {

	if {$a} {return $b} {return $c}
}

############ Authorisation check #####################

proc a:authorised {nick uhost hand} {
	global botnick settings

	if {![validuser $hand]} {return 0} elseif {
	     [check:Q:gl $hand] && [string equal -nocase [a:getxtra -uhost $hand _AUTH] ${nick}!${uhost}]} {return 1} elseif {
	     [string match -nocase [getuser $hand XTRA _PERMIDENT] $nick!$uhost]} {return 1} else {
	     a:tell "[split $nick] [split $hand] [split $settings(homechan)] msg" 5 $botnick; return 0}
}

############ Help procs ##############################

proc a:help {x comm} {
	global botnick settings

	if { $comm == ""} {a:tell $x 145 "$botnick ${settings(cmdpfix)} $botnick ${settings(cmdpfix)}"} elseif {
	     [a:command -exists $comm]} {a:tell $x [a:command -help $comm] $settings(compage)${comm}
	} else {a:tell $x 18 $comm}
}

proc a:usage {x comm} {
	global botnick settings

	if { $comm == ""} {a:tell $x 146 "$botnick ${settings(cmdpfix)} $botnick ${settings(cmdpfix)}"} elseif {
	     [a:command -exists $comm]} {a:tell $x [a:command -usage $comm] "${settings(cmdpfix)} $settings(compage)${comm}"
	} else {a:tell $x 18 $comm}
}

############ Bind procs ##############################

proc a:bind:msgm {nick uhost hand arg} {
	global settings

	set dir  msg
	set arg  [split [string trim $arg]]
	set com  [lindex $arg 0]
	set chan [lindex $arg 1]

	if { [string match "#*" $chan]}	{ set chan $chan ; set args [lrange $arg 2 end]} else {set chan $settings(homechan) ; set args [lrange $arg 1 end]}

	a:parser $nick $uhost $hand $chan $dir $com $args
}

proc a:bind:msg:promote {nick uhost hand arg} {
	global owner

	if { [llength [userlist N]] || ![validuser $hand] || ![matchattr $hand n]|| ![info exists owner]} {return}

	if { [lsearch -exact [split [string tolower $owner] ", "] [string tolower $hand]] != -1} {
		chattr $hand +Nf
		puthelp "NOTICE $nick :YOU ARE THE MANAGER ON THIS BOT NOW"
		catch { unbind msg  n|- promote a:bind:msg:promote }
	}
}

proc a:bind:act  {nick uhost hand chan keyword arg} {

	if { [channel get $chan antiaction] && [botisop $chan] && ![check:fo:ch $hand $chan $nick]} {
		global username
		newchanban $chan [a:maskhost -host $uhost] $username "channel antiaction protection enabled" [channel get $chan ban-time] sticky
		return
	}

	a:bind:pubm $nick $uhost $hand $chan $arg

	global settings
	if { $settings(cmd_me)} {a:bind:botnick $nick $uhost $hand $chan $arg}
}

proc a:bind:pubm {nick uhost hand chan arg} { a:parse:anti $nick $uhost $hand $chan $arg }

proc a:bind:cmdpfix {nick uhost hand chan arg} {

	set arg  [split [string trim $arg]]

	a:parser $nick $uhost $hand $chan pub [string range [lindex $arg 0] 1 end] [lrange $arg 1 end]
}

proc a:bind:botnick {nick uhost hand chan arg} {

	set arg  [split [string trim $arg]]

	a:parser $nick $uhost $hand $chan pub [lindex $arg 0] [lrange $arg 1 end]
}

proc a:bind:for {nick uhost hand chan arg} {

	set who [expr [string first : $arg] -1]
	set go  0

	global botnick

	foreach x [string range $arg 4 $who] {
		if { [string match -nocase $x $botnick]} {

			set cmd  [expr $who + 2]
			set temp [string wordend $arg $cmd]

			a:parser $nick $uhost $hand $chan pub [string trim [string range $arg $cmd $temp]] [split [string trim [string range $arg $temp end]]]

			break
		}
	}
}

proc a:bind:skip {nick uhost hand chan arg} {

	set who [expr [string first : $arg] -1]

	global botnick

	foreach x [string range $arg 4 $who] {if { [string match -nocase $x $botnick]} {return}}

	set cmd  [expr $who + 2]
	set temp [string wordend $arg $cmd]

	a:parser $nick $uhost $hand $chan pub [string trim [string range $arg $cmd $temp]] [split [string trim [string range $arg $temp end]]]
}

proc a:bind:notice {nick uhost hand arg dest} {

	if { [validchan $dest]}  {a:parse:anti $nick $uhost $hand $dest $arg notice}
}

############ Connect IRC #############################

proc a:routine:preconnect {type} {
	global nick altnick settings

	if {$settings(counterspy)} {
		set nick    "[string range $settings(nick) 0 6][rand 99999]"
		set altnick "[string range $settings(nick) 0 6][rand 99999]"
	}
}

proc a:routine:connect {type} {
	global botnick username settings

	putquick "MODE $botnick $settings(server_modes)"
	if {$settings(counterspy)} {foreach z [channels] {channel set $z +inactive}; channel set $settings(homechan) -inactive}
	bind pub  -|- $botnick a:bind:botnick; putcmdlog "<<${username}>> BIND ROUTINE -- $botnick"
	if { $settings(away) != ""} {puthelp "AWAY :${settings(away)}"}
	foreach w [userlist Q] {chattr $w -Q}
}

proc a:routine:userfile {type} {

	if { [userlist N] == ""} {
		bind msg  n|- promote a:bind:msg:promote
	}

	if { [userlist R] == "" && [llength [userlist -b]] > 0} {
		foreach user [userlist -b] {chattr $user +R}
	}
}

############ Timed routines ##########################

proc a:timed:10:seconds {} {
	global flood

	if { [info exists flood] } { array unset flood chan,*; array unset flood 10s,*}

	utimer 10 a:timed:10:seconds
}

proc a:timed:30:seconds {} {
	global flood

	if  { [info exists flood]} { array unset flood 30s,*}

	utimer 30 a:timed:30:seconds
}

proc a:timed:01:minutes {min hour day month year} {
	global flood


	if {![string match *a:timed:30:seconds* [utimers]]} {a:timed:30:seconds}
	if {![string match *a:timed:10:seconds* [utimers]]} {a:timed:10:seconds}
	if { [info exists flood]} {array unset flood 1m,*}

	foreach chan [channels] {
		if { [channel get $chan limit] && [botisop $chan]} {

			if {![set floatmargin [channel get $chan floatmargin]]} {set floatmargin 3}
			if {![set floatgrace [channel get $chan floatgrace]]  } {set floatgrace  1}
			set floatmax     [channel get $chan floatmax]
			set onchan       [llength [chanlist $chan]]
			set limit_to_set [expr $floatmargin + $onchan]

			if { [string match *l* [lindex [getchanmode $chan] 0]]} {
				set setlimit [string range [getchanmode $chan] [expr [string last " " [getchanmode $chan]] + 1] end]
			} else {
				set setlimit 0
			}

			if {!$floatmax || $limit_to_set <= $floatmax } {
				if { [expr {abs([expr $limit_to_set - $setlimit])}] > $floatgrace || [expr $setlimit - $onchan] < 1 } {pushmode $chan "+l" "$limit_to_set"}
			} elseif {!$setlimit || $setlimit > $floatmax || $limit_to_set > $floatmax} {pushmode $chan "+l" "$floatmax"}
		}

		set idledeop [channel get $chan idle-deop]
		if { $idledeop && [botisop $chan]} {
			foreach nick [chanlist $chan] {
				if { [isop $nick $chan] && [getchanidle $nick $chan] >= $idledeop && ![isbotnick $nick] && ![matchattr [nick2hand $nick $chan] aB|a $chan]} {pushmode $chan -o $nick; pushmode $chan +v $nick}

			}
		}
	}
}

proc a:timed:10:minutes {min hour day month year} {

}

proc a:timed:01:hours {min hour day month year} {
	global username need

	putcmdlog "<<${username}>> TIMED ROUTINE -- 1 HOUR"

	if { [info exists need]} {array unset need 1h,*}

	foreach chan [string tolower [channels]] {

		if { [botonchan $chan]} {
			a:opless $chan
			if { [channel get $chan topic] && [channel get $chan enforcetopic]} {puthelp "TOPIC $chan :[stats:channel -get $chan topictext]"}
		} else {
			a:counterspy $chan}
	}
}

proc a:timed:24:hours {min hour day month year} {
	global username flood

	putcmdlog "<<${username}>> TIMED ROUTINE -- 24 HOURS"

	if { [info exists flood]} {array unset flood 24h,* }

	pub:autoclean:chanlist
	pub:autoclean:userlist
	pub:backup
}

proc a:timed:10:days {min hour day month year} {
	global infofile chanfile userfile username

	putcmdlog "<<${username}>> TIMED ROUTINE -- 10 DAYS"
	putcmdlog "<<${username}>> BACKING UP -- user, chan, info files"

	if { [file exists ${infofile}~bak]} {file copy -force -- ${infofile}~bak ${infofile}~bak~bak} elseif {
	     [file exists ${infofile}]    } {file copy -force -- ${infofile}     ${infofile}~bak~bak
	}

	if { [file exists ${userfile}~bak]} {file copy -force -- ${userfile}~bak ${userfile}~bak~bak} elseif {
	     [file exists ${userfile}]    } {file copy -force -- ${userfile}     ${userfile}~bak~bak
	}

	if { [file exists ${chanfile}~bak]} {file copy -force -- ${chanfile}~bak ${chanfile}~bak~bak} elseif {
	     [file exists ${chanfile}]    } {file copy -force -- ${chanfile}     ${chanfile}~bak~bak
	}
}

proc a:timed:30:days {min hour day month year} {
	global infofile chanfile userfile username

	putcmdlog "<<${username}>> TIMED ROUTINE -- 30 DAYS"
	putcmdlog "<<${username}>> BACKING UP -- user, chan, info files"

	if { [file exists ${infofile}~bak~bak]} {file copy -force -- ${infofile}~bak~bak ${infofile}~bak~bak~bak} elseif {
	     [file exists ${infofile}~bak]    } {file copy -force -- ${infofile}~bak     ${infofile}~bak~bak~bak} elseif {
	     [file exists ${infofile}]        } {file copy -force -- ${infofile}         ${infofile}~bak~bak~bak
	}

	if { [file exists ${userfile}~bak~bak]} {file copy -force -- ${userfile}~bak~bak ${userfile}~bak~bak~bak} elseif {
	     [file exists ${userfile}~bak]    } {file copy -force -- ${userfile}~bak     ${userfile}~bak~bak~bak} elseif {
	     [file exists ${userfile}]        } {file copy -force -- ${userfile}         ${userfile}~bak~bak~bak
	}

	if { [file exists ${chanfile}~bak~bak]} {file copy -force -- ${chanfile}~bak~bak ${chanfile}~bak~bak~bak} elseif {
	     [file exists ${chanfile}~bak]    } {file copy -force -- ${chanfile}~bak     ${chanfile}~bak~bak~bak} elseif {
	     [file exists ${chanfile}]        } {file copy -force -- ${chanfile}         ${chanfile}~bak~bak~bak
	}
}

############ Sign procs ##############################

proc a:bind:joins {nick uhost hand chan} {
	global settings username

	if { $settings(lonely) && [check:B:gl $hand] && ![isbotnick $nick] && ![channel get $chan locked]} {
			putcmdlog "<<${username}>> AUTO purge CHAN ROUTINE -- $chan chan removed, joined $settings(suppchan) BOT ($hand)"
			stats:channel -set $chan purgetime [unixtime]
			stats:channel -set $chan purgewhom $username
			stats:channel -set $chan purgewhy "another $settings(suppchan) BOT joinned ($hand)"
			putquick "part $chan :automated chan part, reason: another $settings(suppchan) BOT joinned ($hand)\; for any help apply on $settings(suppchan) & $settings(homepage)"
			channel remove $chan} elseif {
	      [channel get $chan op] && [botisop $chan] } {pushmode $chan +o $nick} elseif {
	      [channel get $chan voice] && [botisop $chan] } {pushmode $chan +v $nick
	}
}

proc a:bind:sign {nick uhost hand chan arg} {

	if {![isbotnick $nick]} {
		a:parse:anti $nick $uhost $hand $chan $arg
		if { [check:Q:gl $hand] && [string equal -nocase [a:getxtra -uhost $hand _AUTH] ${nick}!${uhost}]} {
			chattr $hand -Q
			putcmdlog "<<$hand>> $nick!$uhost $chan SIGNED OFF"
		}
	}
}

proc a:bind:parts {nick uhost hand chan arg} {

	if {![isbotnick $nick]} {
		a:parse:anti $nick $uhost $hand $chan $arg
		if { [check:Q:gl $hand] && ![onchan $nick] && [string equal -nocase [a:getxtra -uhost $hand _AUTH] ${nick}!${uhost}]} {
			chattr $hand -Q
			putcmdlog "<<$hand>> $nick!$uhost $chan PART all channels"
		}
	}
}

proc a:bind:nick {nick uhost hand chan newnick} {
	global username

	if { [isbotnick $nick]} {
		catch { unbind pub  -|- $nick a:bind:botnick }
			  bind pub  -|- $newnick a:bind:botnick
		putcmdlog "<<$username>> BIND ROUTINE -- $nick >> $newnick"
	} elseif {
	    [check:Q:gl $hand] && [string equal -nocase [a:getxtra -uhost $hand _AUTH] ${nick}!${uhost}]} {
		putcmdlog "<<$hand>> $nick!$uhost $chan CHANGED NICK to $newnick"
		setuser $hand XTRA _AUTH "[lindex [getuser $hand XTRA _AUTH] 0] ${newnick}!${uhost}"
	}
}

return "core"