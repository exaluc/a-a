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

if {![string equal -nocase $network quakenet]} {return}

#>>>>>>>>>>> edit all the settings bellow

set chanserv(nick)  "Q"
set chanserv(login) "Q@CServe.quakenet.org"
set chanserv(uhost) "Q!TheQBot@CServe.quakenet.org"

#>>>>>>>>>>> stop editing.

######################################################
############ QSERV NAMESPACE START ###################
######################################################

namespace eval qserv {

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

	if { [botonchan $chan] && ![onchan $chanserv(nick) $chan]} {a:tell $x 137 "$chanserv(nick) $chan" } elseif {
	    ![botonchan $chan] && ![channel get $chan chanserv]} {a:tell $x 137 "$chanserv(nick) $chan"} elseif {
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

	if {![string match *qserv::execute* [utimers]]} {execute}
}

proc execute {} {
	variable chanserv

	if { [llength $chanserv(list) ] > 0} {
		putserv "PRIVMSG $chanserv(nick) :[lindex $chanserv(list) 0] [lindex $chanserv(list) 1] [lindex $chanserv(list) 2]"
		set chanserv(list) [lreplace $chanserv(list) 0 2]
		utimer 3 ::qserv::execute
	}
}

proc chanserv {cmd {chan ""}} {
	variable chanserv

	switch -exact -- $cmd {
		-onchan { if { [validchan $chan] && [onchan $chanserv(nick) $chan]} {channel set $chan +chanserv; return 1} {return 0}}
		-logged { return $chanserv(log)}
		{init-server}	-
		-login  { set chanserv(log) 0
			  puthelp "PRIVMSG $chanserv(login) :auth $chanserv(user) $chanserv(pass)"
			  a:log chanserv "$chanserv(nick) SERVICE ROUTINE -- logging"
		}
		-automode {foreach x [channels] {if { [chanserv -onchan $x]} {queue chanlev $x $chanserv(user) +a; }}}
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


############ Sign procs ##############################

proc joins {nick uhost hand chan}     {

	if { [isbotnick $nick]}  {
		if {![channel get $chan chanserv] && ![string match -nocase *[list chanserv -onchan $chan]* [utimers]]} {utimer 150 [list chanserv -onchan $chan]}} elseif {
	     [check:W:gl $hand]} {channel set $chan +chanserv }

}

proc parts {nick uhost hand chan arg} { channel set $chan -chanserv }

############ Binded procs ############################
proc no {nick host hand text dest} {channel set [lindex [split $text] 2] -chanserv}

proc login {{a ""} {b ""} {c ""} {d ""} {e ""}} {
	variable chanserv

		set chanserv(log) 0
		putquick "PRIVMSG $chanserv(login) :auth $chanserv(user) $chanserv(pass)"
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

	a:log chanserv "$chanserv(nick) SERVICE ROUTINE -- [lindex $text 3]"
}

namespace export chanserv

}

namespace import -force ::qserv::chanserv


######################################################
############ QSERV NAMESPACE END #####################
######################################################

############ Binds ###################################

bind time - "00 * * * *"					 ::qserv::1_hour
bind time - "00 01 * * *"					 ::qserv::24_hours

bind evnt - userfile-loaded					 chanserv
bind evnt - init-server						 chanserv

#bind mode -|- *						 ::qserv::modes
#bind kick -|- *						 ::qserv::kicks
#bind need -|- *						 ::qserv::need

bind part W|- *							 ::qserv::parts
bind join *|- *							 ::qserv::joins

#bind notc W|- "*Your access * has been suspended*"		 ::qserv::suspended
#bind notc W|- "*The NOOP flag is set on*"			 ::qserv::noop
#bind notc W|- "*The STRICTOP flag is set on*"			 ::qserv::strictop
#bind notc W|- "*you have insufficient access *"		 ::qserv::check_access
#bind notc W|- "*You have insufficient access to remove the ban*" ::qserv::banned
#bind notc W|- "*isn't allowed to be opped on*"			 ::qserv::banned_74
#bind notc W|- "Channels:*"					 ::qserv::access
bind notc W|- "*Channel #* is unknown or suspended."		 ::qserv::no
#bind notc W|- "*You're deopped by *"				 ::qserv::deopped

bind notc W|- "*You must be logged in to use *"			 ::qserv::login
bind notc W|- "You are now logged in as*"			 ::qserv::logged
bind notc W|- "AUTH is not available once you have authed*"	 ::qserv::logged

#bind notc W|- "*CHANNEL: * -- AUTOMODE: *"			 ::qserv::take_chan
#bind notc W|- "*LAST MODIFIED: *"				 ::qserv::take_user
#bind notc W|- "*USER: * ACCESS: *"				 ::qserv::take_access

############ OVERWRITTEN PROCS #######################

#proc a:counterspy {chan} {
#	global settings
#
#	if { $settings(counterspy)} { if { [channel get $chan inactive] && [chanserv -logged] && ![channel get $chan suspended] && ![string match -nocase *[list channel set $chan -inactive]* [utimers]]} {channel set $chan -inactive; putquick "join $chan"}} elseif {
#	     [channel get $chan inactive] && ![channel get $chan suspended] && ![string match -nocase *[list channel set $chan -inactive]*  [utimers]]} {channel set $chan -inactive}
#}

#proc a:opless {chan} {
#
#	if {![botisop $chan] && ![chanserv -onchan $chan] && ![channel get $chan locked]} {foreach z [chanlist $chan] {if {[isop $z $chan] } {a:announce -chan 125 $chan "$chan [a:maskhost -uhost [lindex [split $::botname !] 1]]"; break}}}
#}


# fix for eggdrop +x mode uhost selfupdate in $botname, rare issue

bind raw - 396 raw:396:a
proc raw:396:a {from keyword text} {utimer 30 "raw:396:b [lindex $text 1]"}
proc raw:396:b {host} {
	global botname

	if {![string equal -nocase [lindex [split $botname @] 1] $host] && [botonchan]} {
		foreach x [channels] {if { [botonchan $x]} {putquick "part $x :refreshing my uhost"; break}}

	}
}

return "qservice module"