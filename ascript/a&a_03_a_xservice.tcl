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
############ Settings ################################

if {[string equal -nocase $network quakenet]} {return}

#>>>>>>>>>>> edit all the settings bellow

set chanserv(nick)  "X"
set chanserv(login) "X@channels.undernet.org"
set chanserv(uhost) "X!cservice@undernet.org"

#>>>>>>>>>>> stop editing.

######################################################
############ XSERV NAMESPACE START ###################
######################################################

namespace eval xserv {

############ Initializing variables ##################

variable chanserv

if {![info exists chanserv(log)]}  { set chanserv(log)  0 }
if {![info exists chanserv(list)]} { set chanserv(list) ""}

set chanserv(nick) $::chanserv(nick)
set chanserv(user) $::chanserv(user)
set chanserv(pass) $::chanserv(pass)

set chanserv(login) $::chanserv(login)
set chanserv(uhost) $::chanserv(uhost)

unset ::chanserv(pass) ::chanserv(user) ::chanserv(login) ::chanserv(uhost)

############ Timed routines ##########################

proc 1_hour {min hour day month year} {
	variable chanserv

	if { [info exists chanserv]} { array unset chanserv 1h,*}
	if {!$chanserv(log)} {login}

}

proc 24_hours {min hour day month year} {

	chanserv -automode
}

############ CORE ####################################

proc put {command chan args x} {
   	variable chanserv

	if { [botonchan $chan] && ![onchan $chanserv(nick) $chan] && ![string equal -nocase $command support]} {a:tell $x 137 "$chanserv(nick) $chan" } elseif {
	    ![botonchan $chan] && ![channel get $chan chanserv] && ![string equal -nocase $command support]} {a:tell $x 137 "$chanserv(nick) $chan"} elseif {
	     $chanserv(log) } {
		if { [llength $chanserv(list)] < 45 } {
		     if {![regexp {^(op|deop|voice|devoice)$} $command]} {a:tell $x 188 "$chanserv(nick) $command $chan $args"}
		     queue $command $chan $args
		     return "$args" }  else {
		     a:announce -home 187 "$chanserv(nick) $chanserv(nick) $command $chan $args"
		     return "FAILED: have $chanserv(nick) comamnds flood, info: ignoring $command $chan $args"	}} else {
		a:announce -home 189 "$command $chan $args"
		return "FAILED: not logged to $chanserv(nick), info: ignoring $command $chan $args"
	}
}

proc queue {command chan args} {
   	variable chanserv

	lappend chanserv(list) $command $chan [join $args]

	if {![string match *xserv::execute* [utimers]]} {execute}
}

proc execute {} {
	variable chanserv

	if { [llength $chanserv(list) ] > 0} {
		putserv "PRIVMSG $chanserv(nick) :[lindex $chanserv(list) 0] [lindex $chanserv(list) 1] [lindex $chanserv(list) 2]"
		set chanserv(list) [lreplace $chanserv(list) 0 2]
		utimer 3 ::xserv::execute
	}
}

proc chanserv  {cmd {chan ""}} {
	variable chanserv

	switch -exact -- $cmd {
		-onchan { if { [validchan $chan] && [onchan $chanserv(nick) $chan]} {channel set $chan +chanserv; return 1} {return 0}}
		-logged { return $chanserv(log)}
		{init-server}	-
		-login  { set chanserv(log) 0
			  puthelp "PRIVMSG $chanserv(login) :login $chanserv(user) $chanserv(pass)"
			  a:log chanserv "$chanserv(nick) SERVICE ROUTINE -- logging"
		}
		-automode {foreach x [channels] {if { [chanserv -onchan $x]} {queue modinfo $x automode $chanserv(user) op}}}
		{userfile-loaded} {
			set go 0

			if {![validuser $chanserv(nick)]} {
				set go 1} elseif {
			     ![check:W:gl $chanserv(nick)] || ![matchattr $chanserv(nick) f]} {
				set go 1
				deluser $chanserv(nick)
			}
			if {$go} {
				addbot $chanserv(nick) 111.111.111.111:111
				setuser $chanserv(nick) HOSTS $chanserv(uhost)
				chattr $chanserv(nick) +oafLW
				a:log chanserv "$chanserv(nick) SERVICE ROUTINE -- autoadding as channel service"
			}

		}
	}
}

proc flood {cmd chan} {
	variable chanserv

	set chan [string tolower $chan]

	switch -exact -- $cmd {

		-access {if {![info exists chanserv(1h,access,$chan)]} {set chanserv(1h,access,$chan) 1; return 0} ; incr chanserv(1h,access,$chan)
			 if { $chanserv(1h,access,$chan) > 3} {return 1} {return 0}
		}
		default {return 0}
	}
}

############ Modes ###################################

proc modes {nick uhost hand chan mode target} {
	global settings

	switch -- $mode {

		"-v" { }
		"+v" { }
		"+o" { }
		"-o" { if { [isbotnick $target]} {
				if {![check:W:gl $hand]} {
					a:announce -home 192 "DEOPPED $chan ${nick}!${uhost} [chattr $hand $chan]"
					a:log abuse "DEOPPED -- ${nick}!${uhost} on $chan"
				}
				if {![check:f:ch $hand $chan $nick] && [channel get $chan chanserv] && ![a:flood -punish $chan $nick]} {
					queue kick $chan "$nick please do not DEOP ${target}, I am $settings(suppchan) BOT - for more info $settings(homepage)"
					queue ban $chan "$nick 24 74 please do not DEOP ${target}, I am $settings(suppchan) BOT - for more info $settings(homepage)"}
			return
			}

			set hand_protected [nick2hand $target $chan]

			if { [check:f:ch $hand $chan $nick] || ![check:P:ch $hand_protected $chan]} {return}
			if { [botisop $chan]} {
				if { [check:H:ch $hand_protected $chan] } {
					pushmode  $chan +b [a:maskhost -- [getchanhost $nick $chan]]
					pushmode  $chan -o $nick
					pushmode  $chan +o $target
					utimer 3 [list puthelp "KICK $chan $nick :please do not DEOP $target - heavy protected user"]} {
					pushmode  $chan -o $nick
					pushmode  $chan +o $target
				}
				a:log actions "${nick}!${uhost} $chan DEOPPED protected user $target -- punishing"} elseif {
			     [channel get $chan chanserv]} {
				queue ban $chan "$nick 24 74 please do not DEOP $target - protected user"
				queue op  $chan $target
				a:log actions "${nick}!${uhost} $chan DEOPPED protected user $target -- 74 ${::chanserv(nick)}ban"
			}
		}

		"+b" {  set banhost $target
			set hand_protected [finduser $target]
			set target [hand2nick $hand_protected $chan]

			if { [isbotnick $target]} {
				if {![check:W:gl $hand]} {}
				if {![check:f:ch $hand $chan $nick] && [channel get $chan chanserv] && ![a:flood -punish $chan $nick]} {
					queue kick $chan "$nick please do not BAN ${target}, I am $settings(suppchan) BOT - for more info $settings(homepage)"
					queue ban $chan "$nick 24 74 please do not BAN ${target}, I am $settings(suppchan) BOT - for more info $settings(homepage)"
				}
				a:announce -home 192 "BANNED $chan ${nick}!${uhost} [chattr $hand $chan]"
				a:log abuse "BANNED -- ${nick}!${uhost} on $chan"
				return
			}
			if { [check:f:ch $hand $chan $nick] || ![check:P:ch $hand_protected $chan]} {return}
			if { [botisop $chan]} {
				if { [check:H:ch $hand_protected $chan] } {
					pushmode  $chan +b [a:maskhost -- [getchanhost $nick $chan]]
					pushmode  $chan -o $nick
					pushmode  $chan -b $banhost
					utimer 3 [list puthelp "KICK $chan $nick :PLEASE DO NOT BAN $target - heavy protected user"]} {
					pushmode  $chan -b $banhost
					pushmode  $chan -o $nick
				}
				a:log actions "${nick}!${uhost} $chan BANNED protected user $target -- punishing"} elseif {
			     [channel get $chan chanserv]} {
				queue ban $chan  "$nick 24 74 please do not BAN $target - protected user"
				queue unban $chan $target
				a:log actions "${nick}!${uhost} $chan BANNED protected user $target -- 74 ${::chanserv(nick)}banning"
			}
		}

		"+k" { if { [channel get $chan secure] && ![check:f:ch $hand $chan $nick]} {
				if { [botisop $chan] } {
					pushmode $chan -o $nick
					pushmode $chan -k $target
					a:log actions "${nick}!${uhost} $chan SET a key -- punishing" } elseif {
				     [channel get $chan chanserv]} {
					variable chanserv
					queue clearmode $chan ""
					queue ban $chan  "$nick 24 74 please do not put any key here (only users with +n or +f flags can do it )"
					a:log actions "${nick}!${uhost} $chan SET a key -- $chanserv(nick) deopping"
				}
			}
		}
		"+i"  {if { [channel get $chan secure] && ![check:f:ch $hand $chan $nick]} {
				if { [botisop $chan]} {
					pushmode $chan -o $nick
					pushmode $chan -i
					a:log actions "${nick}!${uhost} $chan SET invite -- punishing" } elseif {
				     [channel get $chan chanserv]} {
					variable chanserv
					queue clearmode $chan ""
					queue ban  $chan "$nick 24 74 please do not put any invite here (only users with +n or +f flags can do it )"
					a:log actions "${nick}!${uhost} $chan SET invite -- $chanserv(nick) deopping"
				}
			}
		}

		"+l" {	if { [channel get $chan secure] && ![check:f:ch $hand $chan $nick] && $target <= [llength [chanlist $chan]]} {
				if { [botisop $chan]} {
					pushmode $chan -o $nick
					pushmode $chan +l [expr [llength [chanlist $chan]] + 7]
					a:log actions "${nick}!${uhost} $chan SET limit -- punishing"} elseif {
				     [channel get $chan chanserv]} {
					variable chanserv
					queue clearmode $chan ""
					queue ban $chan  "$nick 24 74 please do not change the limit (only users with +n or +f flags can do it )"
					a:log actions "${nick}!${uhost} $chan CHANGED limit -- $chanserv(nick) deopping"
				}
			}
		}

		"-l" { if { [channel get $chan secure] && ![check:f:ch $hand $chan $nick] && [channel get $chan limit]} {
				if { [botisop $chan]} {
					pushmode $chan -o $nick
					pushmode $chan +l [expr [llength [chanlist $chan]] + 7]
					a:log actions "${nick}!${uhost} $chan UNSET limit -- punishing"} elseif {
				     [channel get $chan chanserv]} {
					variable chanserv
					queue ban $chan  "$nick 24 74 please do not change the limit (only users with +n or +f flags can do it )"
					a:log actions "${nick}!${uhost} $chan CHANGED limit -- $chanserv(nick) deopping"
				}
			}
		}
	}
}

proc kicks {nick uhost hand chan target reason} {
	global settings; variable chanserv

	if { [isbotnick $target]} {
		if {![check:W:gl $hand]} {
			if {![check:f:ch $hand $chan $nick] && [channel get $chan chanserv]} {
				queue kick $chan "$nick please do not KICK ${target}, I am $settings(suppchan) BOT - for more info $settings(homepage)"
				queue ban $chan "$nick 24 74 please do not KICK ${target}, I am $settings(suppchan) BOT - for more info $settings(homepage)"
			}
			a:announce -home 219 "KICKED $chan ${nick}!${uhost} [chattr $hand $chan] $reason"
			a:log abuse "KICKED -- ${nick}!${uhost} on $chan"
		} else {
			set user [string trim [lindex $reason 0] ()]

			if { [string equal -nocase "###" $user]} {
				global username

				channel set $chan +inactive -bitch idle-deop 0
				stats:channel -set $chan templeavetime [unixtime]
				stats:channel -set $chan templeavewhom $username
				stats:channel -set $chan templeavewhy "${chanserv(nick)}MASSDEOPPRO enabled"

				a:announce -home 260 "${chanserv(nick)} $chan"
				a:log abuse "${chanserv(nick)} MASSDEOPPRO enabled -- $chan templeft"
			} elseif {
			    ![string equal -nocase $user $chanserv(user)]} {
				a:announce -home 181 "${chanserv(nick)}KICKED $chan $chanserv(nick) $user [join [lrange $reason 1 end]]"
				a:log abuse "${chanserv(nick)}KICKED -- user $user on $chan"
				if { [channel get $chan secure]} {queue access $chan $user -modif}
			}
		}
		return
	}

	set hand_protected [nick2hand $target $chan]

	if { [check:f:ch $hand $chan $nick] || ![check:P:ch $hand_protected $chan]} {return}
	if { [botisop $chan]} {
		if { [check:H:ch $hand_protected $chan] } {
			pushmode  $chan +b [a:maskhost -uhost [getchanhost $nick $chan]]
			pushmode  $chan -o $nick
			utimer 3 [list puthelp "KICK $chan $nick :please do not kick $target - heavy protected user"]} {
		}
		a:log actions "${nick}!${uhost} $chan KICKED protected user $target -- punishing"} elseif {
	     [channel get $chan chanserv]} {
		queue ban $chan "$nick 24 74 please do not kick $target - protected user"
		a:log actions "${nick}!${uhost} $chan KICKED protected user $target - 74 ${chanserv(nick)}ban"
	}
}

############ Needs ###################################

proc need {chan need} {
	global botnick username; variable chanserv

	switch  --  $need {
		limit	 -
		key	 -
		invite	{
			if {![isdynamic $chan] } {return} elseif {
			     [channel get $chan chanserv] } {
				queue clearmode $chan
				queue invite $chan

				a:announce -home 195 "$need $chan $chanserv(nick)"
				a:log actions "[string toupper $need] ROUTINE -- ${chan}, clearmode through $chanserv(nick)"} elseif {
			     [a:flood -need $chan]} {
				channel set $chan +inactive
				a:log abuse "[string toupper $need] ROUTINE -- $chan templeft"
				stats:channel -set $chan templeavetime [unixtime]
				stats:channel -set $chan templeavewhom $username
				stats:channel -set $chan templeavewhy "[string toupper $need] on $chan"
				a:announce -home 191 "[string toupper $need] $chan"
			}
		}

		op	{ if { [onchan $chanserv(nick) $chan]} {queue op $chan $botnick}}
		unban	{
			if {![isdynamic $chan] } {return} elseif {
			     [channel get $chan chanserv] } {
				queue unban $chan $botnick
				queue invite $chan

				a:announce -home 196 "$need $chan $chanserv(nick)"
				a:log abuse "${chanserv(nick)}banned -- ${chan}, unbanning through $chanserv(nick)"} elseif {
			     [a:flood -need $chan]} {
				channel set $chan +inactive
				a:log abuse "banned -- $chan templeft"
				stats:channel -set $chan templeavetime [unixtime]
				stats:channel -set $chan templeavewhom $username
				stats:channel -set $chan templeavewhy "[string toupper $need] on $chan"
				a:announce -home 194 "[string toupper $need] $chan"
			}
		}
	}
}

############ Sign procs ##############################

proc joins {nick uhost hand chan}     {

	if { [isbotnick $nick]}  {
		if {![channel get $chan chanserv] && ![string match -nocase *[list chanserv -onchan $chan]* [utimers]]} {utimer 150 [list chanserv -onchan $chan]}} elseif {
	     [check:W:gl $hand]} {channel set $chan +chanserv }

}

proc parts {nick uhost hand chan arg} { channel set $chan -chanserv }

############ Binded procs ############################

proc suspended {nick host hand text dest} {
	global username settings; variable chanserv

	set chan [lindex $text 3]

	if {![channel get $chan inactive]} {
		putquick "part $chan :${chanserv(nick)}suspended, be back in one hour; for any help apply on $settings(suppchan) & \037\00302$settings(homepage)"
		channel set $chan +inactive
		a:announce -home 191 "${chanserv(nick)}SUSPENDED $chan"
		stats:channel -set $chan templeavetime [unixtime]
		stats:channel -set $chan templeavewhom $username
		stats:channel -set $chan templeavewhy "${chanserv(nick)}SUSPENDED"
		a:log abuse "${chanserv(nick)}SUSPENDED -- $chan templeft"
	}
}

proc noop {nick host hand text dest} {
	global settings username; variable chanserv

	set chan [lindex $text 6]

	if {![channel get $chan inactive]} {
		putquick "part $chan :${chanserv(nick)}NOOP enabled, be back in one hour; for any help apply on $settings(suppchan) & \037\00302$settings(homepage)"
		channel set $chan +inactive
		a:announce -home 191 "${chanserv(nick)}NOOP $chan"
		stats:channel -set $chan templeavetime [unixtime]
		stats:channel -set $chan templeavewhom $username
		stats:channel -set $chan templeavewhy "${chanserv(nick)}NOOP"
		a:log abuse "${chanserv(nick)}NOOP -- $chan templeft"
	}
}

proc strictop {nick host hand text dest} {set chan [lindex $text 6]; channel set $chan -autoop -op; foreach x [userlist |a $chan] {chattr $x -a|-a $chan}}

proc check_access {nick host hand text dest} {
	global username; variable chanserv

	set temp ""

	if {![info exists chanserv(check)]} {
		set chanserv(check) 1
		timer 5 "unset ::xserv::chanserv(check)"

		foreach chan [channels] {
			if { [channel get $chan chanserv] && ![channel get $chan inactive] && (![botonchan $chan] || ![botisop $chan])} {
				append temp " $chan"

				if { [flood -access $chan]} {
					channel set $chan +inactive +suspended
					stats:channel -set $chan templeavetime [unixtime]
					stats:channel -set $chan templeavewhom $username
					stats:channel -set $chan templeavewhy "${chanserv(nick)}NO-ACCESS"
					a:log abuse "${chanserv(nick)} no access -- $chan suspended"
					return
				}
			}
		}

		if { [string length $temp]} {

			a:log actions "$chanserv(nick) SERVICE NOACCESS ROUTINE -- verifying accesses"
			a:announce -home 193 "$chanserv(nick) $temp"
		}
	}
}

proc banned {nick host hand text dest} {
	global username; variable chanserv

	set chan [string trimright [lindex $text 10] 's]

	if { [validchan $chan] && ![channel get $chan inactive] && ![botonchan $chan]} {

		channel set $chan +inactive
		stats:channel -set $chan templeavetime [unixtime]
		stats:channel -set $chan templeavewhom $username
		stats:channel -set $chan templeavewhy "${chanserv(nick)}BANNED at higher access"
		a:announce -home 77 $chan
		a:log abuse "${chanserv(nick)}BANNED @ higher access -- $chan templeft"
	}

}

proc banned_74 { nick host hand text dest} {
	global botnick; variable chanserv

	set chan  [lindex $text 7]
	set who   [lindex $text 0]
	set hand1 [nick2hand $who]


	if { [isbotnick $who]} {
		a:announce -home 198 "$chan $chanserv(nick)"
		a:log abuse "74 ${chanserv(nick)}BANNED -- ${chan}, unbanning through $chanserv(nick)"
		queue unban $chan $botnick} elseif {
	     [matchattr $hand1 a|a $chan]} {chattr  $hand1 -a|-a $chan} else {channel set $chan -autoop -op
	}
}

proc access {nick host hand text dest} {a:announce -home 197 [iif [string match "*#*" $text] [join [lrange $text 1 end]] none]}
proc no {nick host hand text dest} {channel set [lindex [split $text] 2] -chanserv}

proc deopped {nick host hand text dest} {
	variable chanserv

	set chan  [lindex $text 6]

	if {![validchan $chan]} {return}

	set who   [lindex $text 3]
	set user  [string trim [lindex $text 4] ()]
	set uhost [getchanhost $who $chan]
	set hand1 [nick2hand $who]

	if {![string equal -nocase $user $chanserv(user)]} {queue suspend $chan $user 12 h}

	a:announce -home 182 "${chanserv(nick)}DEOPPED $chan ${who}!${uhost} $chanserv(nick) $user  [chattr $hand1 $chan]"
	a:log abuse "${chanserv(nick)}DEOPPED -- ${who}!${uhost} $chan"
}

proc login {{a ""} {b ""} {c ""} {d ""} {e ""}} {
	variable chanserv

		set chanserv(log) 0
		putquick "PRIVMSG $chanserv(login) :login $chanserv(user) $chanserv(pass)"
		a:log chanserv "$chanserv(nick) SERVICE ROUTINE -- logging"
}

proc logged {nikk host hand text dest} {
	global nick altnick settings; variable chanserv

	if {$settings(counterspy)} {
		set nick	  "${settings(nick)}"
		set altnick	  "${settings(altnick)}"
	}

	set chanserv(log) 1

	foreach z [channels] {if {![channel get $z suspended] && ![string match -nocase *[list channel set $z -inactive]*  [utimers]]} {channel set $z -inactive}}

	a:log chanserv "$chanserv(nick) SERVICE ROUTINE -- [lindex $text 3] logged"
}


############ Take ####################################

proc take_chan   {nick host hand text dest} {variable chanserv; set chanserv(takechan) [lindex [split $text] 1]}
proc take_access {nick host hand text dest} {variable chanserv; set chanserv(takeaccess) [lindex [split $text] 3]; set chanserv(takeuser) [lindex [split $text] 1]}
proc take_user   {nick host hand text dest} {
	variable chanserv

	set suspend [string trim [lindex [split $text] 2] ()]

	if {![validchan $chanserv(takechan)]} {return} elseif {
	     [a:check -digit $chanserv(takeaccess)] } {
		if {$chanserv(takeaccess) < 498} {
			queue remuser $chanserv(takechan) $chanserv(takeuser)
			queue suspend $chanserv(takechan) $suspend 240 h
			a:announce -owner TAKEOVER $chanserv(takechan) 256 "$chanserv(takechan) $chanserv(takeuser) $chanserv(takeaccess) $suspend" } elseif {
		    $chanserv(takeaccess) < 499} {
			queue remuser $chanserv(takechan) $chanserv(takeuser)
			a:announce -owner TAKEOVER $chanserv(takechan) 257 "$chanserv(takechan) $chanserv(takeuser) $chanserv(takeaccess) $suspend" } {
			a:announce -owner TAKEOVER $chanserv(takechan) 258 "$chanserv(takechan) $chanserv(takeuser) $chanserv(takeaccess) $suspend"
		}
	}
}

namespace export chanserv

}

namespace import -force ::xserv::chanserv

######################################################
############ XSERV NAMESPACE END #####################
######################################################

############ Binds ###################################

bind time - "00 * * * *"					 ::xserv::1_hour
bind time - "00 01 * * *"					 ::xserv::24_hours

bind evnt - userfile-loaded					 chanserv
bind evnt - init-server						 chanserv

bind mode -|- *							 ::xserv::modes
bind kick -|- *							 ::xserv::kicks
bind need -|- *							 ::xserv::need

bind part W|- *							 ::xserv::parts
bind join *|- *							 ::xserv::joins

bind notc W|- "*Your access * has been suspended*"		 ::xserv::suspended
bind notc W|- "*The NOOP flag is set on*"			 ::xserv::noop
bind notc W|- "*The STRICTOP flag is set on*"			 ::xserv::strictop
bind notc W|- "*you have insufficient access *"			 ::xserv::check_access
bind notc W|- "*You have insufficient access to remove the ban*" ::xserv::banned
bind notc W|- "*isn't allowed to be opped on*"			 ::xserv::banned_74
bind notc W|- "Channels:*"					 ::xserv::access
bind notc W|- "*#* doesn't appear to be registered*"		 ::xserv::no
bind notc W|- "*You're deopped by *"				 ::xserv::deopped

bind notc W|- "*You must be logged in to use *"			 ::xserv::login
bind notc W|- "AUTHENTICATION SUCCESSFUL*"			 ::xserv::logged
bind notc W|- "*You are already authenticated*"			 ::xserv::logged

bind notc W|- "*CHANNEL: * -- AUTOMODE: *"			 ::xserv::take_chan
bind notc W|- "*LAST MODIFIED: *"				 ::xserv::take_user
bind notc W|- "*USER: * ACCESS: *"				 ::xserv::take_access

############ OVERWRITTEN PROCS #######################

proc a:counterspy {chan} {
	global settings

	if { $settings(counterspy)} { if { [channel get $chan inactive] && [chanserv -logged] && ![channel get $chan suspended] && ![string match -nocase *[list channel set $chan -inactive]* [utimers]]} {channel set $chan -inactive; putquick "join $chan"}} elseif {
	     [channel get $chan inactive] && ![channel get $chan suspended] && ![string match -nocase *[list channel set $chan -inactive]*  [utimers]]} {channel set $chan -inactive}
}

proc a:opless {chan} {

	if {![botisop $chan] && ![chanserv -onchan $chan] && ![channel get $chan locked]} {foreach z [chanlist $chan] {if {[isop $z $chan] } {a:announce -chan 125 $chan "$chan [a:maskhost -uhost [lindex [split $::botname !] 1]]"; break}}}
}

# fix for eggdrop +x mode uhost selfupdate in $botname, rare issue

bind raw - 396 raw:396:a
proc raw:396:a {from keyword text} {utimer 30 "raw:396:b [lindex $text 1]"}
proc raw:396:b {host} {
	global botname

	if {![string equal -nocase [lindex [split $botname @] 1] $host] && [botonchan]} {
		foreach x [channels] {if { [botonchan $x]} {putquick "part $x :refreshing my uhost"; break}}

	}
}

return "xservice module"