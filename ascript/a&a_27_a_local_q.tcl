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

a:command -add auth	  pub:auth	 1002 518 |u
a:command -add pass	  pub:pass	 1004 519 |u
a:command -add output     pub:output	 1018 506 |U
a:command -add flags      pub:flags	 1016 508 |U
a:command -add newpass    pub:newpass    1005 502 |U
a:command -add newhandle  pub:newhandle  1104 605 |U
a:command -add access     pub:access     1075 599 |U
a:command -add host	  pub:host	 1009 509 |U
a:command -add userset    pub:userset	 1084 616 |U
a:command -add userinfo   pub:userinfo	 1085 617 |U

############ Command Procs ###########################

proc pub:auth {hand chan args x mix} {
	global botnick settings

	set ident [string range [lindex $args 1] 0 $settings(user_max_range)]
	set pass  [string range [lindex $args 0] 0 29]
	set nick  [string range [lindex $x 0] 0 $settings(user_max_range)]
	set host  [a:maskhost -host [lindex $mix 0]]

	if { $pass == ""} { a:usage $x auth; return "FAILED: no password specified"}

	if { $ident != ""}    {
		if {![validuser $ident]} {a:tell $x 9; return "FAILED: invalid hand ($ident)" }
	} elseif {
		[validuser $hand] } {set ident $hand
	} elseif {
		[validuser $nick] } {set ident $nick
	} else {
		a:tell $x 7 $botnick; return "FAILED: unknown user"
	}

	if { [check:A:gl $ident] && ![string equal -nocase $ident $hand]} {
		a:announce -user ANTIHACK $ident 155 "${nick}![lindex $mix 0] $ident $pass"
		a:tell $x 45
		return "FAILED: antihack"
	}

	if { [passwdok  $ident ""] } { a:tell $x 8 $botnick; return "FAILED: no password set yet"} elseif {
	     $settings(paranoia) && [check:v:gl $ident] && ![isvoice $nick $settings(homechan)] && ![isop $nick $settings(homechan)]} {a:tell $x 45; return "FAILED: global user antihack"} elseif {
	     [passwdok $ident $pass] } {
		if {![string length [getuser $ident XTRA _AUTH]] } {
			a:tell $x 61 "$botnick $pass $ident"} {
			a:tell $x 4 "$ident [a:getxtra -uhost $ident _AUTH] [a:getxtra -ctime $ident _AUTH]"
		}
		setuser $ident HOSTS
		setuser $ident HOSTS $host
		if { [getuser $ident XTRA _PERMIDENT] != ""} { setuser $ident HOSTS [getuser $ident XTRA _PERMIDENT]}
		setuser $ident XTRA _AUTH "[unixtime] $nick![lindex $mix 0]"
		chattr  $ident +Q
		return "as $ident succeeded"
	} else {
		a:tell $x 10; return "FAILED: wrong password for $ident"
	}
}

proc pub:pass {hand chan args x mix} {
	global botnick

	set pass [lindex $args 0]

	if { $pass == "" }        { a:usage $x pass; return "FAILED: no password specified"}
	if {![validuser $hand]}   { a:tell $x 108; return "FAILED: invalid hand" }
	if {![passwdok $hand ""]} { a:tell $x 12; return "FAILED: password already set" } else {

		setuser $hand PASS $pass
		setuser $hand XTRA _PASS "[unixtime] [lindex $x 0]![lindex $mix 0] $hand"
		a:tell $x 26 "$hand $pass"
		a:tell $x 43 $botnick
		return "..."
	}
}

proc pub:newpass {hand chan args x mix} {

	set newpass  [string range [lindex $args 1] 0 29]
	set oldpass  [lindex $args 0]

	if { $newpass == ""} { a:usage $x newpass ; return "FAILED: no password specified"}
	if {![passwdok $hand $oldpass]} { a:tell $x 10; return "FAILED: wrong password specified" }

	a:tell $x 16 "$newpass [a:getxtra -uhost $hand _PASS] [a:getxtra -hand $hand _PASS] [a:getxtra -ctime $hand _PASS]"

	setuser $hand PASS $newpass
	setuser $hand XTRA _PASS "[unixtime] [lindex $x 0]![lindex $mix 0] $hand"
	return "..."
}

proc pub:newhandle {hand chan args x mix} {

	set newhandle  [lindex $args 0]

	if { [getting-users]} {a:tell $x 6;  return "FAILED: getting users" }
	if { $newhandle == ""} {a:usage $x newhandle ; return "FAILED: no newhandle specified"}
	if { [validuser $newhandle]} { a:tell $x 50 $newhandle ; return "FAILED: hand already exist ($newhandle)"}

	a:tell $x 159 "$hand $newhandle"
	chhandle $hand $newhandle

	return "$newhandle"
}

proc pub:userset {hand chan args x mix} {

	set option  [lindex $args 0]
	set option1 [lindex $args 1]
	set option2 [lindex $args 2]
	set how     [lindex $args 3]
	set whom    $option2

	if {![string length $option1]} {a:usage $x userset; return "FAILED: not all parameters specified"}
	if { [getting-users]} {a:tell $x 6; return "FAILED: getting users" }
	if { $whom != "" && [check:o:gl $hand] && ![string equal -nocase $option info]} { set temp [a:deluser $x $whom $how]
		if {$temp == 0} {return "FAILED: invalid hand or invalid hand host ($whom)" }
		if { [a:level $x $chan $whom $temp [a:translate $hand $chan 220 $option]]} {set target $temp} {return "FAILED: target access is higher ($temp)"}} {set target $hand; set whom [lindex $x 0]
	}

	switch -exact -- $option {

		-a	-
		antihack
			{if { [string equal -nocase $option1 on]}  {chattr $target +A; a:tell $x 186 "antihack $whom $target ON"; return "antihack ON for $target"} elseif {
			      [string equal -nocase $option1 off]} {chattr $target -A; a:tell $x 186 "antihack $whom $target OFF"; return "antihack OFF for $target"
			 }
		}
		-r	-
		reporting
			{if { [string equal -nocase $option1 on]}  {chattr $target +R; a:tell $x 186 "reporting $whom $target ON"; return "reporting ON for $target"} elseif {
			      [string equal -nocase $option1 off]} {chattr $target -R; a:tell $x 186 "reporting $whom $target OFF"; return "reporting OFF for $target"
			 }
		}
		-p	-
		permident
			{set nick [lindex  $x 0]
			 if { [string equal -nocase $option1 on]}  {set option1 [a:maskhost -host [getchanhost $nick]]} elseif {
			      [string equal -nocase $option1 off]} {setuser $target XTRA _PERMIDENT ""; a:tell $x 186 "permident $whom $target OFF"; return "permident OFF for $target"
			 }
			 if { [a:check -host $option1]}  {
				setuser $target XTRA _PERMIDENT $option1
				setuser $target HOSTS $option1
				a:tell $x 75 "$whom $target $option1"; return "permident to $option1 for $target" } else { a:tell $x 15; return "FAILED: invalid hostmask"
			}

		}
		-m	-
		mail	{if { [string equal -nocase $option1 off]} {
				setuser $target XTRA _MAIL ""; a:tell $x 186 "mail $whom $target OFF"; return "mail OFF for $target"} elseif {
			     ![a:check -mail $option1]} {a:tell $x 282; return "FAILED: invalid mail"} else {
				setuser $target XTRA _MAIL $option1; a:tell $x 186 "mail $whom $target $option1"; return "mail for $target ..."
			 }
		}
		-u	-
		url	{if { [string equal -nocase $option1 off]} {
				setuser $target XTRA _URL ""; a:tell $x 186 "url $whom $target OFF"; return "url OFF for $target"} elseif {
			     ![a:check -url $option1]} {a:tell $x 281; return "FAILED: invalid url"} else {
				setuser $target XTRA _URL $option1; a:tell $x 186 "url $whom $target $option1"; return "url for $target ..."
			 }
		}
		-i	-
		invisible
			{if { [string equal -nocase $option1 on]}  {chattr $target +I; a:tell $x 186 "invisible $whom $target ON"; return "invisible ON for $target"} elseif {
			      [string equal -nocase $option1 off]} {chattr $target -I; a:tell $x 186 "invisible $whom $target OFF"; return "invisible OFF for $target"
			 }
		}
		info	{if { [string equal -nocase $option1 off]} {
					setchaninfo $target $chan "none"; a:tell $x 186 "info $whom $target OFF"; return "info OFF for $target"
			} else {
				if { [string equal -nocase $option1 -global] || [string equal -nocase $option1 -g]} {
					if { [string equal -nocase $option2 off]} {
						setuser $target INFO ""
						a:tell $x 186 "info-global $whom $target OFF"; return "info-global OFF for $target"
					} else {
						set info [join [lrange $args 2 end]]
						setuser $target INFO $info
					a:tell $x 186 "info-global $whom $target $info"; return "info-global for $target ..."
					}
				} else {
					set info [join [lrange $args 1 end]]
					setchaninfo $target $chan $info
					a:tell $x 186 "info $whom $target $info"; return "info for $target ..."
				}
			}
		}
	}

	a:usage $x userset; return "FAILED: wrong usage"
}

proc pub:userinfo {hand chan args x mix} {

	set option  [lindex $args 0]
	set option1 [lindex $args 1]
	set how     [lindex $args 2]
	set target  $hand
	set whom    [lindex $x 0]

	if {![string length $option]} {a:usage $x userinfo; return "FAILED: not all parameters specified"}
	if { [getting-users]} {a:tell $x 6; return "FAILED: getting users" }
	if { [string equal $option1 -global]} {
		set option1 [lindex $args 2]
		set how     [lindex $args 3]
	}
	if { $option1 != ""} {
		set temp [a:deluser $x $option1 $how]
		if { $temp == 0} {return "FAILED: invalid hand or invalid hand host ($whom)" }
		if { [check:v:gl $hand] || ([regexp -- {^(mail|url|info|-m|-i|-u)$} $option] && ![check:I:gl $temp])} {
			set target $temp
			set whom $option1
		}
	}

	switch -exact -- $option {

		-r	-
		reporting
			{ a:tell $x 186 "reporting $whom $target [iif [check:R:gl $target] ON OFF]"; return reporting}
		-a	-
		antihack
			{ a:tell $x 186 "antihack $whom $target [iif [check:A:gl $target] ON OFF]"; return antihack}
		-p	-
		permident
			{ set permident [getuser $target XTRA _PERMIDENT]
			  a:tell $x 186 "permident $whom $target [iif [string length $permident] $permident OFF]"; return permident}
		-m	-
		mail	{ set mail [getuser $target XTRA _MAIL]
			  a:tell $x 186 "mail $whom $target [iif [string length $mail] $mail OFF]"; return mail}
		-u	-
		url	{ set url [getuser $target XTRA _URL]
			  a:tell $x 186 "url $whom $target [iif [string length $url] $url OFF]"; return url}
		-i	-
		invisible
			{ a:tell $x 186 "invisible $whom $target [iif [check:I:gl $target] ON OFF]"; return invisible}
		info	{ if { [string equal -nocase [lindex $args 1] -global] || [string equal -nocase $option1 -g]} {
				set info [getuser $target INFO]; a:tell $x 186 "info-global $whom $target [iif [expr [string length $info] > 0] $info OFF]"
			  } else {
				set info [getchaninfo $target $chan]; a:tell $x 186 "info $whom $target [iif [expr [string length $info] > 0] $info OFF]"
			  }
		}	  return info

		-all	{ set permident [iif [string length [getuser $target XTRA _PERMIDENT]] ON OFF]
			  set antihack  [iif [check:A:gl $target] ON OFF]
			  set reporting [iif [check:R:gl $target] ON OFF]
			  set invisble  [iif [check:I:gl $target] ON OFF]
			  set info	[iif [expr [string length [getuser $target INFO]] > 0] YES NO]
			  set mail	[iif [expr [string length [getuser $target XTRA _MAIL]] > 0] YES NO]
			  set url	[iif [expr [string length [getuser $target XTRA _URL]] > 0] YES NO]
			  set pub	[string toupper [getuser $target XTRA _PUB_OUT]]

			  if { $pub == ""} { set pub CHAN}

			  switch -- [getuser $target XTRA _LANG_OUT] {
				2	{set lang RO}
				default	{set lang EN}
			  }

			 a:tell $x 76 "$whom $target $permident $antihack $reporting $invisble [notes $target] $lang $pub $mail $url $info"; return all
		}

		default {a:usage $x userinfo; return "FAILED: wrong usage"}
	}
}

proc pub:output {hand chan args x mix} {

	switch -exact -- [string tolower [lindex $args 0]] {

		-l	-
		lang	{ set lang [string tolower [lindex $args 1]]
			  switch -exact -- $lang {

				ro	{setuser $hand XTRA _LANG_OUT 2}
				en	{setuser $hand XTRA _LANG_OUT 1}
				?	-
				info	{a:tell $x 1; return "LANG info"}
				default {a:usage $x output ; return "FAILED: not all, wrong parameters specified"}
			  }
			  a:tell $x 1; return "LANG $lang"
		}
		-r	-
		reply	{ set what [string tolower [lindex $args 1]]
			  set how  [string tolower [lindex $args 2]]

			  if {![regexp -nocase -- {^(msg|note|chan)$} $how]} {a:usage $x output ; return "FAILED: not all, wrong parameters specified"}

			  switch -exact -- $what {

				chan	{setuser $hand XTRA _PUB_OUT $how}
				msg	{setuser $hand XTRA _MSG_OUT $how}
				default {a:usage $x output ; return "FAILED: not all, wrong parameters specified"}
			  }
			  a:tell $x 89 "$what $how"; return "REPLY $what 2 $how"
		}
		default {a:usage $x output ; return "FAILED: not all, wrong parameters specified"}
	}
}

proc pub:host {hand chan args x mix} {

	set option [lindex $args 0]
	set host   [lindex $args 1]
	set whom   [lindex $args 2]
	set how    [lindex $args 3]
	set nick   [lindex $x 0]

	if { [getting-users]} { a:tell $x 6; return "FAILED: getting users" }
	if { [regexp -nocase -- {^(-info|-i|\?)$} $option] } {set whom [lindex $args 1]; set how [lindex $args 2]}

	if { [string length $whom] && [check:o:gl $hand]} {
		set temp [a:deluser $x $whom $how]
		if { $temp == 0} { return "FAILED: invalid hand or invalid hand host ($whom)" }
		if { [a:level $x $chan $whom $temp [a:translate $hand $chan 221]]} {set target $temp} {return "FAILED: target access is higher ($temp)"}
	} {
		set target $hand; set whom $nick}

	switch -exact -- $option {

		-a	-
		-add	{ if {![a:check -host $host]} {global botnick; a:tell $x 15 $botnick; return "FAILED: invalid hostmask"}

			  setuser $target XTRA _HOST "[unixtime] addhost $host $hand"
			  setuser $target HOSTS $host
			  set hosts [getuser $target HOSTS]

			  a:tell $x 14 "$host $whom $target $hosts"; return "add $host to $target"
			}
		-d	-
		-delete { if {![string match *!*@* $host]} {global botnick; a:tell $x 15 $botnick; return "FAILED: invalid hostmask"}
			  setuser $target XTRA _HOST "[unixtime] delhost $host $hand"

			  set ok [delhost $target $host]
			  if { [getuser $target XTRA _PERMIDENT] != ""} { setuser $target HOSTS [getuser $target XTRA _PERMIDENT]}
			  set hosts [getuser $target HOSTS]

			  if {$ok} {a:tell $x 73 "$host $whom $target $hosts"; return "delete $host from $target"} {
				    a:tell $x 180 "$host $whom $target $hosts"; return "delete failed, $host from $target"
			  }
			}
		-r	-
		-reset { if {![a:check -host $host]} {global botnick; a:tell $x 15 $botnick; return "FAILED: invalid hostmask"}
			 setuser $target HOSTS
			 setuser $target HOSTS $host

			 if {[getuser $target XTRA _PERMIDENT] != ""} { setuser $target HOSTS [getuser $target XTRA _PERMIDENT]}

			 setuser $target XTRA _HOST "[unixtime] resethost $host $hand"
			 set hosts [getuser $target HOSTS]

			 a:tell $x 74 "$whom $target $hosts"; return "reset to $host for $target"
			}
		-i	-
		-info	{a:tell $x 70 "$whom $target [getuser $target HOSTS]"; return "info for $whom as $target"}

		default {a:usage $x host; return "FAILED: not all, wrong parameters specified"}
	}
}

proc pub:access {hand chan args x mix} {

	set whom  [lindex $args 0]
	set how   [lindex $args 1]
	set flags ""

	if { $whom == "" || ![check:v:gl $hand]} {set whom [lindex $x 0]}

	set target [a:deluser $x $whom $how]
	if {$target == 0} {return "FAILED: no such user ($whom)"}

	foreach n [channels] {

		set temp [lindex [split [chattr $target $n] |] 1]

		set n [a:validate -secret $n [lindex $x 2]]
		if {![string equal $temp -]} {lappend flags "$n (${temp})," }
	}

	set flag [chattr $target]

	if { $flags == ""} {set flags none}
	if { [string equal $flag -]} {set flag none}

	a:tell $x 179 "$whom $target $flag [string trimright [join $flags] ,]"

	return "$target"
}

proc pub:flags {hand chan args x mix} {
	global settings

	set whom [lindex $args 0]
	set how  [lindex $args 1]

	if {$whom == "" || [string equal $whom me]} {set whom [lindex $x 0]}
	set target  [a:deluser $x $whom $how]
	if { $target == 0} {return "FAILED: no such user ($whom)"}

	set globals [string map { - {}} [lindex [split [chattr $target $chan] |] 0]]
	set locals  [string map { - {}} [lindex [split [chattr $target $chan] |] 1]]
	set g_flags ""
	set c_flags ""

	if {![string length $globals] } { set g_flags "[a:translate $hand $chan 85]" } {
		for {set z 0} {$z<[string length $globals]} {incr z} {
			switch -- [string index $globals $z] {
				f {lappend g_flags "f > friend," }
				d {lappend g_flags "d > deny op," }
				k {lappend g_flags "k > auto ban," }
				q {lappend g_flags "q > deny voice," }
				o {lappend g_flags "o > $settings(suppchan) OP," }
				a {lappend g_flags "a > auto-op," }
				l {lappend g_flags "l > $settings(suppchan) HALF OP," }
				g {lappend g_flags "g > auto-voice," }
				v {lappend g_flags "v > $settings(suppchan) HELPER," }
				B {lappend g_flags "B > $settings(suppchan) BOT," }
				b {lappend g_flags "b > BOT," }
				m {lappend g_flags "m > $settings(suppchan) MASTER," }
				t {lappend g_flags "t > botnet master," }
				n {lappend g_flags "n > $settings(suppchan) OWNER," }
		 		x {lappend g_flags "x > file-area access," }
		 		j {lappend g_flags "j > file-area master," }
		 		N {lappend g_flags "N > $settings(suppchan) MANAGER," }
				P {lappend g_flags "P > protected user," }
				H {lappend g_flags "H > heavy protected," }
				L {lappend g_flags "L > LOCKED," }
				X {lappend g_flags "X > X commands access," }
		 		S {lappend g_flags "S > SUSPENDED," }
		 		Q {lappend g_flags "Q > authenticated user," }
			}
		}
	}

	if {![string length $locals] } { set c_flags "[a:translate $hand $chan 85]" } {
		for {set z 0} {$z < [string length $locals]} {incr z} {
			switch -- [string index $locals $z] {
				f {lappend c_flags "f > friend," }
				g {lappend c_flags "g > auto-voice," }
				d {lappend c_flags "d > auto deop," }
				k {lappend c_flags "k > auto ban," }
				q {lappend c_flags "q > deny voice," }
				v {lappend c_flags "v > voiced \(100 X\)," }
				o {lappend c_flags "o > operator \(400 X\) ," }
				a {lappend c_flags "a > auto-op," }
				l {lappend c_flags "l > half op," }
				m {lappend c_flags "m > master \(450 X\)," }
				n {lappend c_flags "n > owner \(499 X\)," }
				N {lappend c_flags "N > MANAGER \(500 X\)," }
				H {lappend c_flags "H > heavy protected," }
				P {lappend c_flags "P > protected user," }
				L {lappend c_flags "L > LOCKED," }
				X {lappend c_flags "X > X commands access," }
		 		S {lappend c_flags "S > SUSPENDED," }
			}
		}
	}

	a:tell $x 88 "$whom $target »[string trimright [join $g_flags] ","]« [string trimright [join $c_flags] ","]"
	return "$target"
}

return "local q commands"