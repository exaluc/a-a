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

a:command -add time     pub:time      1086 530 |s
a:command -add ping     pub:ping      1091 534 |s
a:command -add help     pub:help      1077 520 |s
a:command -add usage    pub:usage     1078 521 |s
a:command -add info     pub:info      1079 522 |s
a:command -add commands pub:commands  1080 523 |s
a:command -add url      pub:url	      1106 607 |s
a:command -add news     pub:news      1107 608 |s
a:command -add desc     pub:desc      1108 609 |s
a:command -add mail     pub:mail      1109 610 |s
a:command -add faq      pub:faq	      1110 611 |s
a:command -add rules    pub:rules     1114 615 |s

############ Command Procs ###########################

proc pub:time   {hand chan args x mix} { a:tell $x 17 "[ctime [unixtime]]" ; return "..."}

proc pub:help  {hand chan args x mix} {
	global botnick settings

	set comm [lindex $args 0]

	if { $comm == ""} {a:tell $x 145 "$botnick ${settings(cmdpfix)} $botnick ${settings(cmdpfix)}"; return "FAILED: no command specified" } elseif {
	     [a:command -exists $comm]} {a:tell $x [a:command -help $comm] $settings(compage)${comm}; return "$comm"} else {a:tell $x 18 $comm; return "FAILED: no such command"
	}
}

proc pub:usage {hand chan args x mix} {
	global botnick settings

	set comm [lindex $args 0]

	if { $comm == ""} {a:tell $x 146 "$botnick ${settings(cmdpfix)} $botnick ${settings(cmdpfix)}";return "FAILED: no command specified" } elseif {
	     [a:command -exists $comm]} {a:tell $x [a:command -usage $comm] "${settings(cmdpfix)} $settings(compage)${comm}"; return "$comm"} else {a:tell $x 18 $comm; return "FAILED: no such command"
	}
}

proc pub:info {hand chan args x mix} {
	global botnick settings

	set comm [lindex $args 0]

	if { $comm == ""} {a:tell $x 147 "$botnick ${settings(cmdpfix)} $botnick ${settings(cmdpfix)}"; return "FAILED: no command specified" } elseif {
	     [a:command -exists $comm]} { a:usage $x $comm; a:help $x $comm; return "$comm"} else {a:tell $x 18 $comm; return "FAILED: no such command"
	}
}

proc pub:commands {hand chan args x mix} {

	set  N ""; set  n ""; set  m ""; set  o ""; set   l ""; set  v ""; set  s ""; set  Q ""; set z ""
	set _N ""; set _n ""; set _m ""; set _o ""; set  _l ""; set _v ""; set _s ""; set _u ""; set _X ""

	set x "[split [lindex $x 0]] [split [lindex $x 1]] [split [lindex $x 1]] msg"

		foreach w [a:command -all] {
			if {[a:command -level $w] == "x"}  {lappend z  [lindex [split $w ,] 0]} elseif {
			    [a:command -level $w] == "N"}  {lappend N  [lindex [split $w ,] 0]} elseif {
			    [a:command -level $w] == "n"}  {lappend n  [lindex [split $w ,] 0]} elseif {
			    [a:command -level $w] == "m"}  {lappend m  [lindex [split $w ,] 0]} elseif {
			    [a:command -level $w] == "o"}  {lappend o  [lindex [split $w ,] 0]} elseif {
			    [a:command -level $w] == "l"}  {lappend l  [lindex [split $w ,] 0]} elseif {
			    [a:command -level $w] == "v"}  {lappend v  [lindex [split $w ,] 0]} elseif {
			    [a:command -level $w] == "s"}  {lappend s  [lindex [split $w ,] 0]} elseif {
			    [a:command -level $w] == "Q"}  {lappend Q  [lindex [split $w ,] 0]} elseif {
			    [a:command -level $w] == "|N"} {lappend _N [lindex [split $w ,] 0]} elseif {
			    [a:command -level $w] == "|X"} {lappend _X [lindex [split $w ,] 0]} elseif {
			    [a:command -level $w] == "|n"} {lappend _n [lindex [split $w ,] 0]} elseif {
			    [a:command -level $w] == "|m"} {lappend _m [lindex [split $w ,] 0]} elseif {
			    [a:command -level $w] == "|o"} {lappend _o [lindex [split $w ,] 0]} elseif {
			    [a:command -level $w] == "|l"} {lappend _l [lindex [split $w ,] 0]} elseif {
			    [a:command -level $w] == "|v"} {lappend _v [lindex [split $w ,] 0]} elseif {
			    [a:command -level $w] == "|s"} {lappend _s [lindex [split $w ,] 0]} elseif {
			    [a:command -level $w] == "|U"} {lappend _u [lindex [split $w ,] 0]} elseif {
			    [a:command -level $w] == "|u"} {lappend _u [lindex [split $w ,] 0]} }

		if { [check:x:xx $hand] && $z != ""}        { a:tell $x 62 "x $z" }
		if { [check:N:gl $hand] && $N != ""}        { a:tell $x 62 "N $N" }
		if { [check:n:gl $hand] && $n != ""}        { a:tell $x 62 "n $n" }
		if { [check:m:gl $hand] && $m != ""}        { a:tell $x 62 "m $m" }
		if { [check:o:gl $hand] && $o != ""}        { a:tell $x 62 "o $o" }
		if { [check:o:gl $hand] && $l != ""}        { a:tell $x 62 "l $l" }
		if { [check:v:gl $hand] && $v != ""}        { a:tell $x 62 "v $v" }
		if { [check:v:gl $hand] && $s != ""}        { a:tell $x 62 "s $s" }
		if { [check:Q:gl $hand] && $Q != ""}        { a:tell $x 62 "Q $Q" }
		if { [check:N:ch $hand $chan] && $_N != ""} { a:tell $x 65 "N $_N" }
		if { [check:X:ch $hand $chan] && $_X != ""} { a:tell $x 65 "X $_X" }
		if { [check:n:ch $hand $chan] && $_n != ""} { a:tell $x 65 "n $_n" }
		if { [check:m:ch $hand $chan] && $_m != ""} { a:tell $x 65 "m $_m" }
		if { [check:o:ch $hand $chan] && $_o != ""} { a:tell $x 65 "o $_o" }
		if { [check:l:ch $hand $chan] && $_l != ""} { a:tell $x 65 "l $_l" }
		if { [check:v:ch $hand $chan] && $_v != ""} { a:tell $x 65 "v $_v" }
		if { $_u != "" }			    { a:tell $x 17 "$_u" }
		if { $_s != "" }			    { a:tell $x 17 "$_s" }


		return "..."
}

proc pub:url  {hand chan args x mix} {

	set what [stats:channel -get $chan url]
	set whom [lindex $args 0]

	if { $what == ""} {if {[check:n:ch $hand $chan] } {a:tell $x 148 "url url"} ; return "FAILED: empty"}
	if { $whom != "" && [onchan $whom $chan] && [check:v:ch $hand $chan]} {set x [a:modify -nickhand $x $whom [nick2hand $whom $chan]]}

	a:tell $x 17 $what; return "..."
}

proc pub:news  {hand chan args x mix} {

	set what [stats:channel -get $chan news]
	set whom [lindex $args 0]

	if { $what == ""} {if {[check:n:ch $hand $chan] } {a:tell $x 148 "news news"} ; return "FAILED: empty" }
	if { $whom != "" && [onchan $whom $chan] && [check:v:ch $hand $chan]} {set x [a:modify -nickhand $x $whom [nick2hand $whom $chan]]}

	a:tell $x 17 $what; return "..."
}

proc pub:desc  {hand chan args x mix} {

	set what [stats:channel -get $chan desc]
	set whom [lindex $args 0]

	if { $what == ""} {if {[check:n:ch $hand $chan] } {a:tell $x 148 "desc desc"} ; return "FAILED: empty" }
	if { $whom != "" && [onchan $whom $chan] && [check:v:ch $hand $chan]} {set x [a:modify -nickhand $x $whom [nick2hand $whom $chan]]}

	a:tell $x 17 $what; return "..."
}

proc pub:mail  {hand chan args x mix} {

	set what [stats:channel -get $chan mail]
	set whom [lindex $args 0]

	if { $what == ""} {if {[check:n:ch $hand $chan] } {a:tell $x 148 "mail mail"} ; return "FAILED: empty" }
	if { $whom != "" && [onchan $whom $chan] && [check:v:ch $hand $chan]} {set x [a:modify -nickhand $x $whom [nick2hand $whom $chan]]}

	a:tell $x 17 $what; return "..."

}

proc pub:faq  {hand chan args x mix} {

	set what [stats:channel -get $chan faq]
	set whom [lindex $args 0]

	if { $what == ""} {if {[check:n:ch $hand $chan] } {a:tell $x 148 "faq faq"} ; return "FAILED: empty" }
	if { $whom != "" && [onchan $whom $chan] && [check:v:ch $hand $chan]} {set x [a:modify -nickhand $x $whom [nick2hand $whom $chan]]}

	a:tell $x 17 $what; return "..."
}

proc pub:rules  {hand chan args x mix} {

	set what [stats:channel -get $chan rules]
	set whom [lindex $args 0]

	if { $what == ""} {if {[check:n:ch $hand $chan] } {a:tell $x 148 "rules rules"} ; return "FAILED: empty" }
	if { $whom != "" && [onchan $whom $chan] && [check:v:ch $hand $chan]} {set x [a:modify -nickhand $x $whom [nick2hand $whom $chan]]}

	a:tell $x 17 $what; return "..."
}

# -------------------------
#  www.bot.net.ru (c) DlMA
# -------------------------

set ping(maxbuf) 10
set ping(timeout) 300000

for {set i 0} {$i < $ping(maxbuf)} {incr i} { set pingbuf($i) 0 }

proc pub:ping {hand chan args x mix} {
	global ping pingbuf

	set who [lindex $x 0]

	for {set i 0} {$i < $ping(maxbuf)} {incr i} {
		if {$pingbuf($i)!=0 && [expr {abs([expr [clock clicks -milliseconds] - [lindex $pingbuf($i) 2]])}] > $ping(timeout)} {set pingbuf($i) 0}
		if {$pingbuf($i)==0} {
			set rand [expr round(rand()*1000000)]
			set pingbuf($i) "[list $x] $rand [clock clicks -milliseconds]"
			putserv "PRIVMSG $who :\001PING ${i}.${rand}.C!\001"
			return $who
		}
	}
}

proc pub:ping:SubRoutine {nick uhost hand dest key arg} {
	global ping pingbuf

	set arg  [split $arg "."]
	set rand [lindex $arg 1]
	set i    [lindex $arg 0]

	if { [llength $arg]!=3 || ![string equal [lindex $arg 2] C!] || ![a:check -digit $i] || ![a:check -digit $rand] || $i>=$ping(maxbuf) || $i<0 || [lindex $pingbuf($i) 1]!=$rand || ![string equal [lindex [lindex $pingbuf($i) 0] 0] $nick]} { return "FAILED: invalid ping ($arg)" }

	a:tell [lindex $pingbuf($i) 0] 131 "[expr {abs([expr ([clock clicks -milliseconds] - [lindex $pingbuf($i) 2]) / 1000.000])}]"
	set pingbuf($i) 0
}

return "local s commands"