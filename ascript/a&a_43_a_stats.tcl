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

a:command -add stats      pub:stats      1067 536 |v

############ Command Procs ###########################

proc pub:stats {hand chan args x mix} {
	global settings

	set option  [lindex  $args 0]
	set period  [lindex  $args 1]
	set level   [lindex  $args 2]
	set limit   [lindex  $args 3]
	set value   [lindex  $args 4]
	set outchan [lindex $x 2]

	if { [string equal $option -all]} {set option all}
	if { $option == "" || ![string is alnum $option]} {a:usage $x stats ; return "FAILED: not all parameters specified"}
	if {![stats:channel -exists $chan]} {if {![string equal -nocase [lindex $x 2] $settings(homechan)]} {a:tell $x 238} ; return "FAILED: invalid chan ($chan)"}
	if {![regexp -- {^(channels|purge|join|reset|reload|templeave|time|joins|topics|traffic|traffics|users|bans|kicks|deops|ops|devoices|voices|banned|deopped|kicked|all)$} $option]} {a:usage $x stats ; return "FAILED: invalid parameters specified ($option)"}
	if {![regexp -- {^(hour|day|week|month|year)$} $period]} { set period day; set level [lindex $args 1]; set limit [lindex $args 2]; set value [lindex $args 3] }
	if {![a:check -digit $value] || ![regexp {^((min|max))$} $limit] || $level == ""} {

		if { [regexp -- {^(topics|bans|kicks|deops|ops|devoices|voices)$} $option]} {set limit min; set value 0     } elseif {
		     [regexp -- {^(banned|deopped|kicked)$} $option]}                       {set limit max; set value 2     } elseif {
		     [string equal $option users]}                                          {set limit min; set value 8     } elseif {
		     [string equal $option joins]}                                          {set limit min; set value 30    } elseif {
		     [string equal $option traffic]}                                        {set limit min; set value 100   } elseif {
		     [string equal $option traffics]}                                       {set limit min; set value 10000 } elseif {
		     [string equal $option channels] && ![check:v:gl $hand]}		    {return "FAILED: not enough access"} else {
											     set limit min; set value 0
		}
	}

	if { [string equal $level global]} {

		set temp ""

		if { [regexp -- {^(join|purge|temleave|all|channels)$} $option]} {return "FAILED: invalid option ($option)"}
		if { [string equal $option reset]}    {if { [check:N:gl $hand]}  {stats:channels -unload; foreach chan [channels] {stats:channel -add $chan}; a:tell $x 2} {return "FAILED: not enough access"}} elseif {
		     [string equal $option reload]}   {if { [check:N:gl $hand]}  {stats:channels -load; a:tell $x 153} {return "FAILED: not enough access"}} elseif {
		     [string equal $option users]}    {foreach chan [channels]   {set out [a:validate -secret $chan $outchan]; append temp " $out %b[stats:channel -get $chan maxusers]/[stats:average $option $chan $period $limit $value],"}; a:tell $x 240 "$option [string trimright $temp ,]"} elseif {
		     [string equal $option time]}     {foreach chan [channels]   {set out [a:validate -secret $chan $outchan]; append temp " $out %b[duration [stats:channel -get $chan time]],"}; a:tell $x 240 "$option [string trimright $temp ,]"} else {
					               foreach chan [channels]   {set out [a:validate -secret $chan $outchan]; append temp " $out %b[stats:channel -get $chan $option]/[stats:average $option $chan $period $limit $value],"}; a:tell $x 240 "$option [string trimright $temp ,]"
		}

		return "GLOBAL $option"

	} else {

		if { [string equal $option reload]}   {return "FAILED: ${option}, not available locally"} elseif {
		     [string equal $option join]}     {if { [stats:channel -get $chan joinwhom] == ""} {a:tell $x 238} {a:tell $x 241 "$chan $option »[join [ctime [stats:channel -get $chan jointime]]]« [stats:channel -get $chan joinwhom]"}} elseif {
		     [string equal $option reset]}    {if { [check:N:gl $hand]} {stats:channel -add $chan {}; a:tell $x 3 "$chan"} {return "FAILED: not enough access"}} elseif {
		     [string equal $option users]}    {a:tell $x 244 "$chan [stats:channel -get $chan maxusers] [stats:average users $chan $period $limit $value] »[duration [stats:channel -get $chan time]]«"} elseif {
		     [string equal $option time]}     {a:tell $x 243 "$chan »[duration [stats:channel -get $chan time]]«"} elseif {
		     [string equal $option all]}      {a:tell $x 245 "$chan »[stats:channel -get $chan joins]/[stats:average joins $chan $period $limit $value]« »[stats:channel -get $chan topics]/[stats:average topics $chan $period $limit $value]« »[stats:channel -get $chan traffic]/[stats:average traffic $chan $period $limit $value]« »[stats:channel -get $chan traffics]/[stats:average traffics $chan $period $limit $value]« »[stats:channel -get $chan maxusers]/[stats:average users $chan $period $limit $value]« »[stats:channel -get $chan bans]/[stats:average bans $chan $period $limit $value]« »[stats:channel -get $chan kicks]/[stats:average kicks $chan $period $limit $value]« »[stats:channel -get $chan deops]/[stats:average deops $chan $period $limit $value]« »[stats:channel -get $chan ops]/[stats:average ops $chan $period $limit $value]« »[stats:channel -get $chan devoices]/[stats:average devoices $chan $period $limit $value]« »[stats:channel -get $chan voices]/[stats:average voices $chan $period $limit $value]« »[stats:channel -get $chan banned]/[stats:average banned $chan $period $limit $value]« »[stats:channel -get $chan deopped]/[stats:average deopped $chan $period $limit $value]« »[stats:channel -get $chan kicked]/[stats:average kicked $chan $period $limit $value]« $period »[duration [stats:channel -get $chan time]]«"} elseif {
		     [string equal $option channels]} {set temp ""; foreach chan [stats:channel -all] { if {![validchan $chan] } {set chan %r${chan}%%} {set chan %b[a:validate -secret $chan $outchan]%%}; lappend temp "${chan}," } ; a:tell $x 248 "[llength $temp] [string trimright [join $temp] ,]"} elseif {
		     [string equal $option traffic] || [string equal $option traffics]}  {a:tell $x 247 "$chan [stats:channel -get $chan traffic] [stats:channel -get $chan traffics] [stats:average traffic $chan $period $limit $value] [stats:average traffics $chan $period $limit $value] $period »[duration [stats:average time $chan $period $limit $value]]«"} elseif {
    		     [string equal $option purge]   || [string equal $option templeave]} {if { [stats:channel -get $chan ${option}whom] == ""} {a:tell $x 238} {a:tell $x 242 "$chan $option »[join [ctime [stats:channel -get $chan ${option}time]]]« [stats:channel -get $chan ${option}whom] »[stats:channel -get $chan ${option}why]«"}} else {
						       a:tell $x 246 "$chan [stats:channel -get $chan $option] $option [stats:average $option $chan $period $limit $value] $option $period »[duration [stats:channel -get $chan time]]«"
		}

		return "$option"
	}
}

######################################################
############ STATS NAMESPACE START ###################
######################################################

namespace eval stats {

############ Initializing variables ##################

variable stats
variable infofile

if {![info exists ::infofile]} {set infofile "${::username}.info"} {set infofile $::infofile}

############ Timed routines ##########################

proc timed:01:hours {min hour day month year} {

	foreach chan [string tolower [channels]] {

		set length [llength [chanlist $chan]]

		if { [botonchan $chan]} {

			if { [stats:channel -get $chan maxusers] < $length } {stats:channel -set $chan maxusers $length}
			if { [stats:channel -get $chan time] < 3600} {stats:channel -set $chan users $length} {
				set temp [expr [stats:channel -get $chan users] + ($length - [stats:channel -get $chan users])/([stats:channel -get $chan time]/3600.0)]
				stats:channel -set $chan users [string range $temp 0 [expr [string first . $temp] +2]]
			}
			stats:channel -incr $chan time 3600
		}
	}
}

############ CORE ####################################

proc stats:channel {cmd {chan ""} {options ""} {value ""}} {
	variable stats

	set chan [string tolower $chan]

	switch -exact -- $cmd {

		-get	{ return $stats($chan,$options)}
		-set	{ set stats($chan,$options) $value}
		-incr	{ if { [a:check -digit $value]} {incr stats($chan,$options) $value} {incr stats($chan,$options)}}
		-exists { return [info exists stats($chan,channels)]}
		-all	{ set temp ""; foreach w [array names stats *,channels] {lappend temp $stats($w)}; return $temp}
		-clean  { catch {array unset stats $chan,channels}}
		-add	{ if {$chan == ""} {return 0}
			set stats($chan,channels)     $chan

			set statistics                 [lindex $options 1]

			set stats($chan,time)          [a:validate -digit [lindex $statistics 0]]
			set stats($chan,joins)         [a:validate -digit [lindex $statistics 1]]
			set stats($chan,topics)        [a:validate -digit [lindex $statistics 2]]
			set stats($chan,traffic)       [a:validate -digit [lindex $statistics 3]]
			set stats($chan,traffics)      [a:validate -digit [lindex $statistics 4]]
			set stats($chan,maxusers)      [a:validate -digit [lindex $statistics 5]]
			set stats($chan,users)         [a:validate -digit [lindex $statistics 6]]
			set stats($chan,bans)          [a:validate -digit [lindex $statistics 7]]
			set stats($chan,kicks)         [a:validate -digit [lindex $statistics 8]]
			set stats($chan,deops)         [a:validate -digit [lindex $statistics 9]]
			set stats($chan,ops)           [a:validate -digit [lindex $statistics 10]]
			set stats($chan,voices)        [a:validate -digit [lindex $statistics 11]]
			set stats($chan,devoices)      [a:validate -digit [lindex $statistics 12]]

			set stats($chan,banned)        [a:validate -digit [lindex $statistics 13]]
			set stats($chan,deopped)       [a:validate -digit [lindex $statistics 14]]
			set stats($chan,kicked)        [a:validate -digit [lindex $statistics 15]]

			set misc                       [lindex $options 2]

			set join                       [lindex $misc 0]
			set stats($chan,jointime)      [a:validate -digit [lindex $join 0]]
			set stats($chan,joinwhom)      [lindex $join 1]

			set purge                      [lindex $misc 1]
			set stats($chan,purgetime)     [a:validate -digit [lindex $purge 0]]
			set stats($chan,purgewhom)     [lindex $purge 1]
			set stats($chan,purgewhy)      [join [lindex $purge 2]]

			set templeave                  [lindex $misc 2]
			set stats($chan,templeavetime) [a:validate -digit [lindex $templeave 0]]
			set stats($chan,templeavewhom) [lindex $templeave 1]
			set stats($chan,templeavewhy)  [join [lindex $templeave 2]]

			set topic                      [lindex $misc 3]
			set stats($chan,topictime)     [a:validate -digit [lindex $topic 0]]
			set stats($chan,topicwhom)     [lindex $topic 1]
			set stats($chan,topictext)     [join [lindex $topic 2]]

			set stats($chan,url)	       [join [lindex $misc 4]]
			set stats($chan,faq)           [join [lindex $misc 5]]
			set stats($chan,fuck)          [join [lindex $misc 6]]
			set stats($chan,news)          [join [lindex $misc 7]]
			set stats($chan,desc)          [join [lindex $misc 8]]
			set stats($chan,mail)          [join [lindex $misc 9]]
			set stats($chan,slap)          [join [lindex $misc 10]]
			set stats($chan,kiss)          [join [lindex $misc 11]]
			set stats($chan,rules)         [join [lindex $misc 12]]
			set stats($chan,ban-reason)    [join [lindex $misc 13]]
			set stats($chan,output)        [join [lindex $misc 14]]

			return 1
		}
		default {return 0}
	}
}

proc stats:channels {cmd {chan ""} {options ""} {value ""}} {
	variable stats

	set chan [string tolower $chan]

	switch -exact -- $cmd {
		-unload { if { [info exists stats]} {unset stats}}
		-load	{ global status; variable infofile; stats:channels -unload; if {![catch {source $infofile}]} {return 1} {return 0}}
		-verify { foreach x [channels] {if {![stats:channel -exists $x]} {stats:channel -add $x}}}
		default {return 0}
	}

}

proc stats:average {options chan period limit value} {
	variable stats

	set time [stats:channel -get $chan time]

	if { [string equal $period year] } {set period 31536000.0 } elseif {
	     [string equal $period month]} {set period 2592000.0 } elseif {
	     [string equal $period week] } {set period 604800.0 } elseif {
	     [string equal $period day]  } {set period 86400.0 } elseif {
	     [string equal $period hour] } {set period 3600.0  } else {set period 86400.0 }

	if { $time < $period } {return "%bn/a%%"}

	set temp   [expr {[stats:channel -get $chan $options] * $period  / $time}]
	set result [string range $temp 0 [expr {[string first . $temp] + 2}]]

	if { [string equal $options users]} {set result [stats:channel -get $chan users]}
        if { [string equal $limit max]} {

	if { $result > $value} {return "%r${result}%%"} {return "${result}%%"}} {
	if { $result < $value} {return "%r${result}%%"} {return "${result}%%"}}
}

proc save {{foo ""}} {
	global username {quiet-save}; variable infofile; variable stats

	set file [open $infofile w]

		catch {
			puts $file "#Dynamic Info Channel File for $username -- written [ctime [unixtime]]\n"

			foreach chan [string tolower [channels]] {if {![info exists stats($chan,channels)]} {stats:channel -add $chan {}}}
			foreach chan [stats:channel -all] {

				puts $file "stats:channel -add [split $chan] {{RESERVED}\
					    {$stats($chan,time)\
					     $stats($chan,joins)\
					     $stats($chan,topics)\
					     $stats($chan,traffic)\
					     $stats($chan,traffics)\
					     $stats($chan,maxusers)\
					     $stats($chan,users)\
					     $stats($chan,bans)\
					     $stats($chan,kicks)\
					     $stats($chan,deops)\
					     $stats($chan,ops)\
					     $stats($chan,voices)\
					     $stats($chan,devoices)\
					     $stats($chan,banned)\
					     $stats($chan,deopped)\
					     $stats($chan,kicked)}\
					    {{$stats($chan,jointime) [split $stats($chan,joinwhom)]}\
					     {$stats($chan,purgetime) [split $stats($chan,purgewhom)] {[split $stats($chan,purgewhy)]}}\
					     {$stats($chan,templeavetime) [split $stats($chan,templeavewhom)] {[split $stats($chan,templeavewhy)]}}\
					     {$stats($chan,topictime) [split $stats($chan,topicwhom)] {[split $stats($chan,topictext)]}}\
					     {[split $stats($chan,url)]}\
					     {[split $stats($chan,faq)]}\
					     {[split $stats($chan,fuck)]}\
					     {[split $stats($chan,news)]}\
					     {[split $stats($chan,desc)]}\
					     {[split $stats($chan,mail)]}\
					     {[split $stats($chan,slap)]}\
					     {[split $stats($chan,kiss)]}\
					     {[split $stats($chan,rules)]}\
					     {[split $stats($chan,ban-reason)]}\
					     {[split $stats($chan,output)]}}}"
			}
				puts $file "\n#Disabled local & global commands\n"
				puts $file "[a:com:status -array]"

		       return ok
		} ok

	close $file

	if {![string equal $ok ok]} {
		a:log high "FAILED to write info file, error: $ok"
		a:announce -permowner ERROR "FAILED to write info file, error: $ok"
	} elseif {!${quiet-save}} {putlog "Writing info file ..."}

}

proc restore {} {
	variable infofile

	if { [file exists ${infofile}~bak]} {

		a:log routines "No infofile found, restoring from backup."
		file copy ${infofile}~bak $infofile} elseif {

	     [file exists ${infofile}~bak~bak]} {

		a:log routines "No infofile found, restoring from backup."
		file copy ${infofile}~bak~bak $infofile} elseif {

	     [file exists ${infofile}~bak~bak~bak]} {

		a:log routines "No infofile found, restoring from backup."
		file copy ${infofile}~bak~bak~bak $infofile} else {

		a:log routines "No infofile found, creating a new one."
		save
	}
}


############ Modes ###################################

proc modes {nick uhost hand chan mode target} {

	switch -- $mode {

		"-v"	{stats:channel -incr $chan devoices}
		"+v"	{stats:channel -incr $chan voices}
		"+o"	{stats:channel -incr $chan ops
			 if { [isbotnick $target]} {a:bind:topic nonick nouhost nohandspecified $chan "[topic $chan]"}
		}
		"-o"	{stats:channel -incr $chan deops
			 if { [isbotnick $target]} {stats:channel -incr $chan deopped}
		}
		"+b"	{stats:channel -incr $chan bans
			 if { [isbotnick $target]} {stats:channel -incr $chan banned}
		}
		"-b"	{ }
		default {a:flood -modes $chan $hand $uhost $nick}

	}
}

proc kicks {nick uhost hand chan target reason} {

	stats:channel -incr $chan kicks
	if { [isbotnick $target]} {stats:channel -incr $chan kicked}
}

############ Binded procs ############################

proc joins  {nick uhost hand chan}	 {stats:channel -incr $chan joins }
proc topics {nick uhost hand chan topic} {stats:channel -incr $chan topics }
proc pubm   {nick uhost hand chan arg}	 {

	stats:channel -incr $chan traffic
	stats:channel -incr $chan traffics [string length $arg]
}

############ Routines ################################

setudef flag stats

if {![file exists $infofile]} {restore}
if {![info exists stats]} {if { [stats:channels -load]} {a:log routines "Infofile loaded, proceeding..."}; stats:channels -verify}

namespace export stats:channel stats:average

}

namespace import -force ::stats::stats:channel ::stats::stats:average

######################################################
############ STATS NAMESPACE END #####################
######################################################


############ Binds ###################################

bind time - "00 * * * *"	::stats::timed:01:hours

bind mode -|- *			::stats::modes
bind kick -|- *			::stats::kicks

bind join -|- *			::stats::joins
bind topc -|- *			::stats::topics
bind pubm -|- *			::stats::pubm

bind evnt - save		::stats::save

return "stats module"