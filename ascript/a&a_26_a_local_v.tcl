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

a:command -add whois      pub:whois      1021 503 |v
a:command -add voice      pub:voice      1020 504 |v
a:command -add devoice    pub:devoice    1019 505 |v
a:command -add chaninfo   pub:chaninfo   1017 507 |v
a:command -add botnet     pub:botnet     1006 516 |v
a:command -add admins     pub:admins     1087 531 |v
a:command -add say        pub:say        1030 545 |v
a:command -add act        pub:act        1029 546 |v
a:command -add list       pub:list       1101 602 |v
a:command -add fuck	  pub:fuck	 1111 612 |v
a:command -add kiss	  pub:kiss	 1112 613 |v
a:command -add slap	  pub:slap	 1113 614 |v
a:command -add version    pub:version    1014 524 |v
a:command -add uptime     pub:uptime     1090 532 |v
a:command -add remuser    pub:remuser    1076 585 |v


############ Command Procs ###########################

proc pub:whois {hand chan args x mix} {

	set who  [lindex $args 0]
	set now  [lindex $args 1]
	set how  [lindex $args 2]
	set say  0

	if { $who == ""} { a:usage $x whois; return "FAILED: not all parameters specified"}

	set target [a:deluser $x $who $now]
	if { $target == "0"}	  { return "FAILED: no such user ($who)" }

	if { [a:check -now $now]} {set how [lindex $args 2]} {set how  [lindex $args 1]}
	if { [a:check -info $how] && [check:v:gl $hand]} { set say 1 }

	set outa   ""
	set idents  [join [getuser $target HOSTS]]
	set output  [string toupper [getuser $target XTRA _PUB_OUT]]
	set flag    [join [lrange [getuser $target XTRA _FLAG] 1 3]]
	set hostchg [join [lrange [getuser $target XTRA _HOST] 1 3]]
	set hostlog [a:getxtra -uhost $target _AUTH]

	switch -- [getuser $target XTRA _LANG_OUT] {
		2	{set lang RO}
		default	{set lang EN}
	}

	if { [check:N:gl $target]} { lappend outa "[a:translate $hand $chan 199]"} elseif {
	     [check:B:gl $target]} { lappend outa "[a:translate $hand $chan 203]"} elseif {
	     [check:n:gl $target]} { lappend outa "[a:translate $hand $chan 200]"} elseif {
	     [check:m:gl $target]} { lappend outa "[a:translate $hand $chan 201]"} elseif {
	     [check:o:gl $target]} { lappend outa "[a:translate $hand $chan 202]"} elseif {
	     [check:v:gl $target]} { lappend outa "[a:translate $hand $chan 204]"}

	set outt $outa

	if { [matchattr  $target |N $chan]                  } { lappend outt "[a:translate $hand $chan 205 $chan]"}
	if { [check:S:ch $target $chan]                     } { lappend outt "[a:translate $hand $chan 206]"}
	if { [check:L:ch $target $chan]                     } { lappend outt "[a:translate $hand $chan 207]"}

	if { [passwdok $target ""] && ![check:b:gl $target] } { lappend outt "[a:translate $hand $chan 208]"} elseif {
	     [check:Q:gl $target]                           } { lappend outt "[a:translate $hand $chan 209]"} elseif {
	    ![check:b:gl $target]                           } { lappend outt "[a:translate $hand $chan 210]"}

	if { $flag != "" || $hostchg != ""		    } { lappend outt "[a:translate $hand $chan 84 ]"}
	if { $flag != ""			            } { lappend outt "[a:translate $hand $chan 81 "$flag [a:getxtra -ctime $target _FLAG]"]"}
	if { $hostchg != ""			            } { lappend outt "[a:translate $hand $chan 82 "$hostchg [a:getxtra -ctime $target _HOST]"]"}
	if { $hostlog != ""			            } { lappend outt "[a:translate $hand $chan 83 "$hostlog [a:getxtra -ctime $target _AUTH]"]"}
	if { $output == ""				    } { set output CHAN}

	set permident [iif [string length [getuser $target XTRA _PERMIDENT]] ON OFF]
	set antihack  [iif [check:A:gl $target] ON OFF]
	set reporting [iif [check:R:gl $target] ON OFF]

	if {![matchattr $target Blv] || $say		    } { a:tell $x 94 "$who $target [chattr $target $chan] $permident $antihack $reporting $lang $output $idents"}
	if {![matchattr $target Blv] || $say		    } { a:tell $x 101 "$who [join $outt]"} else {a:tell $x 93 "$who [join $outa]"}
	return "$who"
}

proc pub:voice {hand chan args x mix} {

	if {![botisop $chan]} {a:tell $x 96 $chan; return "FAILED: bot is not opped"}

	set whom   [lrange $args 0 end]
	set voiced ""
	set nohere ""
	set q	   ""
	set talk   1

	if {[string first * $whom] > -1 } { set whom [a:check -regx $whom $chan]; set talk 0} elseif {
	    $whom=="" ||  [string equal -nocase $whom me]} { set whom [split [lindex $x 0]]}

	foreach z $whom {
		if {![onchan  $z $chan]}			 { lappend nohere   $z} elseif {
		     [isvoice $z $chan]}			 { lappend voiced   $z} elseif {
		     [matchattr [nick2hand $z $chan] q|q $chan]} { lappend q        $z} else   {
								   pushmode $chan +v $z
		}
	}

	flushmode $chan

	if {$nohere != "" && $talk == 1} {a:tell $x 90  "[join $nohere]"}
	if {$voiced != "" && $talk == 1} {a:tell $x 92  "[join $voiced]"}
	if {$q      != "" && $talk == 1} {a:tell $x 285 "[join $q]"}

	return "[join [lrange $whom 0 2]] ..."
}

proc pub:devoice {hand chan args x mix} {

	if {![botisop $chan]} {a:tell $x 96 $chan; return "FAILED: bot is not opped"}

	set whom   [lrange $args 0 end]
	set voiced ""
	set nohere ""
	set g	   ""
	set talk   1

	if {[string first * $whom] > -1 } { set whom [a:check -regx $whom $chan]; set talk 0} elseif {
	    $whom=="" || [string equal -nocase $whom me]} { set whom [split [lindex $x 0]]}

	foreach z $whom {
		if {![onchan  $z $chan]}			 { lappend nohere $z} elseif {
		    ![isvoice $z $chan]}			 { lappend voiced $z} elseif {
		     [matchattr [nick2hand $z $chan] g|g $chan]} { lappend g      $z} else   {
								   pushmode $chan -v $z
		}
	}

	flushmode $chan

	if {$nohere != "" && $talk == 1} {a:tell $x 90 "[join $nohere]"}
	if {$voiced != "" && $talk == 1} {a:tell $x 91 "[join $voiced]"}
	if {$g      != "" && $talk == 1} {a:tell $x 286 "[join $g]"}

	return "[join [lrange $whom 0 2]] ..."
}

proc pub:chaninfo {hand chan args x mix} {

	set info ""

	lappend info "modes %b[channel get $chan chanmode]%%,"
	lappend info "idle-kick %b[channel get $chan idle-kick]%%,"
	lappend info "revenge-mode %b[channel get $chan revenge-mode]%%,"
	lappend info "flood-chan %b[channel get $chan flood-chan]%%,"
	lappend info "flood-ctcp %b[channel get $chan flood-ctcp]%%,"
	lappend info "flood-join %b[channel get $chan flood-join]%%,"
	lappend info "flood-kick %b[channel get $chan flood-kick]%%,"
	lappend info "flood-deop %b[channel get $chan flood-deop]%%,"
	lappend info "flood-nick %b[channel get $chan flood-nick]%%,"
	lappend info "aop-delay %b[channel get $chan aop-delay]%%,"
	lappend info "ban-time %b[channel get $chan ban-time]%%,"
	lappend info "exempt-time %b[channel get $chan exempt-time]%%,"
	lappend info "invite-time %b[channel get $chan invite-time ]%%,"

	a:tell $x 17 "[join $info] [join [lrange [channel info $chan] 19 65]]"

	return "..."
}

proc pub:botnet {hand chan args x mix} {
	global settings {botnet-nick} botnick

	set comm  [lindex $args 0]
	set uhost [lindex $mix  0]
	set mix   [lindex $args 1]

	if { $comm == ""} { a:usage $x botnet ; return "FAILED: not all parameters specified"}

	switch -exact -- $comm {

		link   {if {[check:n:gl $hand]} {

				if {$mix == "" }	  { a:usage $x botnet ; return "FAILED: not all parameters specified"        } elseif {
				    ![check:b:gl $mix] }  { a:tell $x 165 $mix; return "LINK FAILED: invalid bot ($mix)"             } elseif {
				     [islinked   $mix] }  { a:tell $x 170 $mix; return "LINK FAILED: bot is connected already ($mix)"} elseif {
				     [link       $mix] }  { a:tell $x 166 $mix; return "LINK $mix"                                   } else   {
							    a:tell $x 167 $mix; return "LINK FAILED: failed to connect to $mix"}}}
		unlink {if {[check:n:gl $hand]} {

				if {$mix == "" }	  { a:usage $x botnet ; return "FAILED: not all parameters specified"    } elseif {
				    ![check:b:gl $mix] }  { a:tell $x 165 $mix; return "UNLINK FAILED: invalid bot ($mix)"       } elseif {
				    ![islinked   $mix] }  { a:tell $x 171 $mix; return "UNLINK FAILED: bot not connected ($mix)" } else   {
		 		    unlink $mix "Unlink by $hand, for info apply on $settings(suppchan) or $settings(homepage)"; a:tell $x 168 $mix; return "UNLINK $mix"}}}
		!       -
		chat   { if { $mix != "" && [onchan $mix]} {set nick $mix} else {set nick [lindex $x 0]}
			 *ctcp:CHAT $nick $uhost $hand $botnick CHAT ""
			 return "CHAT $nick"}

		whom   {if { [whom 0] == "" } { a:tell $x 28 ; return "whom ..." }
			foreach n [whom 0] {
			a:tell $x 17 "%b[lindex $n 3] [lindex [split $n] 0]%% @ %b[lindex [split $n] 1]%% (Idle: [duration [expr [lindex $n 4] * 60]])" }
			return  "whom ..." }

		bots   {set total 1

			foreach n [bots] {

				if {[check:B:gl $n]} { incr total}}
				if { $total < 2 }    { set totaa 0}

				a:tell $x 27 "[expr [llength [bots]]+1] $total $settings(suppchan)"
				return "BOTS ..."}
		?      -
		info   {if {[check:n:gl $hand]} {set ip "[a:fix -ip2short [myip]]:[lindex [lindex [lindex [dcclist] 0] 4] 1]"; a:tell $x 17 "%b.+bot ${botnet-nick} $ip%% %%| %ball addbot ${botnet-nick} $settings(suppchan) [a:maskhost -uhost [lindex [split $::botname !] 1]] $ip"; return "INFO ..."}}
	}
}

proc pub:admins {hand chan args x mix} {

		set N ""; set n ""; set m ""
		set o ""; set d ""; set k ""
		set v ""; set l ""

		if { [string equal -nocase [lindex $args 0] global] && [check:v:gl $hand]} {

			set y [a:translate $hand $chan 72]
			foreach w [userlist lvdk-B] {if {[matchattr $w N]} {lappend N $w} elseif {
						         [matchattr $w n]} {lappend n $w} elseif {
						         [matchattr $w m]} {lappend m $w} elseif {
						         [matchattr $w o]} {lappend o $w} elseif {
						         [matchattr $w l]} {lappend l $w} elseif {
						         [matchattr $w d]} {lappend d $w} elseif {
						         [matchattr $w k]} {lappend k $w} else {
						                            lappend v $w}}} else {

			if {![llength [userlist -|vloN $chan]]} {a:tell $x 68 $chan; return "none"}

			set y $chan
			foreach w [userlist |lvdkN $chan] {if {[matchattr $w |N $chan]} {lappend N $w} elseif {
							       [matchattr $w |n $chan]} {lappend n $w} elseif {
							       [matchattr $w |m $chan]} {lappend m $w} elseif {
							       [matchattr $w |o $chan]} {lappend o $w} elseif {
							       [matchattr $w |l $chan]} {lappend l $w} elseif {
							       [matchattr $w |d $chan]} {lappend d $w} elseif {
							       [matchattr $w |k $chan]} {lappend k $w} else {
							                                 lappend v $w
								}
			}
		}

		if { [llength $N]} { a:tell $x 17 "$y [a:translate $hand $chan 211] [join $N]"}
		if { [llength $n]} { a:tell $x 17 "$y [a:translate $hand $chan 212] [join $n]"}
		if { [llength $m]} { a:tell $x 17 "$y [a:translate $hand $chan 213] [join $m]"}
		if { [llength $o]} { a:tell $x 17 "$y [a:translate $hand $chan 214] [join $o]"}
		if { [llength $l]} { a:tell $x 17 "$y [a:translate $hand $chan 218] [join $l]"}
		if { [llength $v]} { a:tell $x 17 "$y [a:translate $hand $chan 215] [join $v]"}
		if { [llength $d]} { a:tell $x 17 "$y [a:translate $hand $chan 216] [join $d]"}
		if { [llength $k]} { a:tell $x 17 "$y [a:translate $hand $chan 217] [join $k]"}

		return "$y ..."
}

proc pub:list {hand chan args x mix} {

		set what [lindex $args 0]
		set say  ""

		if { [string equal [lindex $args 1] global] && [check:v:gl $hand]} { set y  [a:translate $hand $chan 72]
			if { [string match {[fkdqvgloamnbXSNPHBL]} $what]} {set say [userlist $what]} elseif {
			     [string equal -nocase $what ban]} {
				if {![llength [banlist]]} { set say ""} else {
					foreach w   [banlist] {
						a:tell $x 86 "[lindex $w 0] [lindex $w 1]"
					}
				return "$y bans ..."
				}
			} else { a:usage $x list; return "FAILED: invalid parameters specified ($what)"}
		} else { set y  $chan
			if { [string match {[fkdqvgloamnXSNPHL]} $what]} {set say [userlist |$what $chan]} elseif {
			     [string equal -nocase $what ban] }  {
				if {![llength [banlist $chan]]} { set say ""} else {
					foreach w [banlist $chan] {
						a:tell $x 86 "[lindex $w 0] [lindex $w 1]"
					}
					return "$y bans ..."
				}
			} else { a:usage $x list; return "FAILED: invalid parameters specified ($what)"}
		}

		if {$say == ""} { set say [a:translate $hand $chan 85]}

		a:tell $x 17 "$y $what [a:translate $hand $chan 78]: %b[join $say]"
		return "$y $what ..."
}

proc pub:say {hand chan args x mix} {

	set what  [join [lrange $args 0 end]]

	if {$what == ""} { a:usage $x say; return "FAILED: not all parameters specified"}

	puthelp "PRIVMSG $chan :$what"
	return "$what"
}

proc pub:act {hand chan args x mix} {

	set what  [join [lrange $args 0 end]]

	if {$what == ""} { a:usage $x act; return "FAILED: not all parameters specified"}

	puthelp "PRIVMSG $chan :\001ACTION $what\001"
	return "$what"
}

proc pub:fuck {hand chan args x mix} {

	set what [stats:channel -get $chan fuck]
	set from [lindex $x 0]
	set whom [lindex $args 0]

	if { $what == ""} {if { [check:n:ch $hand $chan] } {a:tell $x 148 "fuck fuck"}; return "FAILED: empty" }
	if { $whom == ""} {set whom $from} elseif {
	     [a:check -info $whom]} {a:tell $x 17 $what; return "?"} elseif {
	    ![onchan $whom $chan]} {a:tell $x 90 $whom; return "FAILED: $whom not onchan"}

	puthelp "PRIVMSG $chan :\001ACTION [a:replace -all $what $whom $from]\001"; return "..."
}

proc pub:kiss {hand chan args x mix} {

	set what [stats:channel -get $chan kiss]
	set from [lindex $x 0]
	set whom [lindex $args 0]

	if { $what == ""} {if { [check:n:ch $hand $chan] } {a:tell $x 148 "kiss kiss"}; return "FAILED: empty" }
	if { $whom == ""} {set whom $from} elseif {
	     [a:check -info $whom]} {a:tell $x 17 $what; return "?"} elseif {
	    ![onchan $whom $chan]} {a:tell $x 90 $whom; return "FAILED: $whom not onchan"}

	puthelp "PRIVMSG $chan :\001ACTION [a:replace -all $what $whom $from]\001"; return "..."
}

proc pub:slap {hand chan args x mix} {

	set what [stats:channel -get $chan slap]
	set from [lindex $x 0]
	set whom [lindex $args 0]

	if { $what == ""} {if { [check:n:ch $hand $chan] } {a:tell $x 148 "slap slap"}; return "FAILED: empty" }
	if { $whom == ""} {set whom $from} elseif {
	     [a:check -info $whom]} {a:tell $x 17 $what; return "?"} elseif {
	    ![onchan $whom $chan]} {a:tell $x 90 $whom; return "FAILED: $whom not onchan"}

	puthelp "PRIVMSG $chan :\001ACTION [a:replace -all $what $whom $from]\001"; return "..."
}

proc pub:uptime {hand chan args x mix} {
	global uptime {server-online}

	if { [catch {exec uptime} server]} {set server "n/a"}

	a:tell $x 130 "»[duration [expr [unixtime] - $uptime]]« »[duration [expr [unixtime] - ${server-online}]]« $server"

	return "..."
}

proc pub:remuser {hand chan args x mix} {

	set whom   [lindex $args 0]
	set how    [lindex $args 1]

	if { [getting-users]} {a:tell $x 6; return "FAILED: getting users" }
	if { $whom == ""} {set whom [lindex $x 0]}
	if {![string equal $whom -all]} {set target [a:deluser $x $whom $how]} else {
		if {![check:N:ch $hand $chan]} {a:tell $x 102; return "FAILED: +N access required for all"} else {
			foreach w [userlist |vlfPHX-N $chan] {chattr $w |-[lindex [split [chattr $w $chan] |] 1] $chan; setuser $w XTRA _FLAG "[unixtime] remuser $chan $hand"}
			a:tell $x 113 $chan
			return "all"
		}
	}

	if { $target == 0} {return "FAILED: invalid hand host or nick not online ($whom)"}
	if {![a:level $x $chan $whom $target [a:translate $hand $chan 228]]} {return "FAILED: target access is higher" }
	if { [check:N:ch $target $chan] && ![check:m:gl $hand]} {a:tell $x 139; return "FAILED: target is chan manager"}

	set flags [lindex [split [chattr $target $chan] |] 1]
	if { [string equal $flags -]} {a:tell $x 110 "$whom $target $chan"; return "FAILED: target has no local acccess ($target)"}

	chattr $target |{-}$flags $chan
	setuser $target XTRA _FLAG "[unixtime] remuser $chan $hand"

	a:tell $x 109 "$whom $target $chan"
	return "$target"
}

proc pub:version {hand chan args x mix} {a:tell $x 60; return "..."}

return "local v commands"