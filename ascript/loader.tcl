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
############ Defining variables ######################

set atempo(line) "**********************************"

# For debugging puporose, you can set atempo(action) to "die" or "putlog". If you are
# playing with the script & making some major changes & don't want the bot to die every
# time you make a mistake - feel free to "set atempo(action) putlog". You will be only
# warned about tcl errors. Attention! If you have a warning - it means that BOT is not
# fully functional or not functional at all. Only for advanced users.
set atempo(action) die

#Used when you do not want to edit eggdrop config every time you add or remove a script.
#0 - ALL scripts in the folder 'ascript' (prefixed with 'a&a_') will be autoloaded on rehash.
#1 - ONLY original a&a light scripts & scripts you specify in config  will be loaded.
set atempo(loadstrict) 1

#reporting errors on scripts loading
#0 - basic info about possible error in loaded script
#1 - more detailed info about possible error in loaded script
set atempo(adv_err_report) 0

############ Checking Compatibility ##################

putlog $atempo(line)

if { $numversion < 1061700} {

	die "Warning! You must have at least 1.6.17 eggdrop/windrop version. Download @ http://geteggdrop.com. BOT shutdowned."
}

if { [info tclversion] < "8.1"} {

	die "Warning! You must have at least 8.1 TCL version. BOT shutdowned."

}
if {![string equal $atempo(action) die] && ![string equal $atempo(action) putlog]} {

	die "Heh ;) Debugging ?! 1st debug your tcl knowledge & rtfm. Action can be set to 'die' or 'putlog' ONLY."
}

############ Checking config/settings/botnick files ##

if {![info exists atempo(config_error)] || $atempo(config_error)} {

	$atempo(action) "Warning! eggdrop.conf file is missing or has errors. BOT shutdowned. Error: $atempo(config_error_info)"
}

if {![info exists atempo(settings_error)] || $atempo(settings_error)} {

	$atempo(action) "Warning! settings.conf file is missing or has errors. BOT shutdowned. Error: $atempo(settings_error_info)"
}

if {![info exists owner] || ![info exists settings(suppchan)]  || ![info exists settings(homechan)] || [string equal -nocase $owner Edit_Me_Pls] ||  [string equal -nocase $settings(suppchan) "#Edit_Me_Pls"] || [string equal -nocase $settings(homechan) "#Edit_Me_Pls"] } {

	$atempo(action) "Warning! settings.conf file MUST be edited."
}

if {![info exists nick] || ![info exists botnet-nick]  || ![info exists realname] || [string equal -nocase $nick Edit_Me_Pls]} {

	$atempo(action) "Warning! botnick.conf file MUST be edited."
}

############ Script auto-loader ######################

set atempo(dirname) [file dirname [info script]]
if { $atempo(loadstrict)} {

	set atempo(files) "\
		$atempo(dirname)/a&a_01_a_core.tcl \
		$atempo(dirname)/a&a_02_a_binds.tcl \
		$atempo(dirname)/a&a_03_a_xservice.tcl \
		$atempo(dirname)/a&a_03_b_qservice.tcl \
		$atempo(dirname)/a&a_03_c_noservice.tcl \
		$atempo(dirname)/a&a_04_a_dict_en.tcl \
		$atempo(dirname)/a&a_04_b_dict_ro.tcl \
		$atempo(dirname)/a&a_10_a_owner.tcl \
		$atempo(dirname)/a&a_11_a_global_N.tcl \
		$atempo(dirname)/a&a_12_a_global_n.tcl \
		$atempo(dirname)/a&a_13_a_global_m.tcl \
		$atempo(dirname)/a&a_14_a_global_o.tcl \
		$atempo(dirname)/a&a_15_a_global_l.tcl \
		$atempo(dirname)/a&a_16_a_global_v.tcl \
		$atempo(dirname)/a&a_17_a_global_s.tcl \
		$atempo(dirname)/a&a_18_a_global_Q.tcl \
		$atempo(dirname)/a&a_20_a_local_N.tcl \
		$atempo(dirname)/a&a_21_a_local_X.tcl \
		$atempo(dirname)/a&a_22_a_local_n.tcl \
		$atempo(dirname)/a&a_23_a_local_m.tcl \
		$atempo(dirname)/a&a_24_a_local_o.tcl \
		$atempo(dirname)/a&a_25_a_local_l.tcl \
		$atempo(dirname)/a&a_26_a_local_v.tcl \
		$atempo(dirname)/a&a_27_a_local_q.tcl \
		$atempo(dirname)/a&a_28_a_local_s.tcl \
		$atempo(dirname)/a&a_41_a_info.tcl \
		$atempo(dirname)/a&a_42_a_botnet.tcl \
		$atempo(dirname)/a&a_43_a_stats.tcl \
		$atempo(dirname)/a&a_44_a_seen.tcl \
	"
} {	set atempo(files) [lsort [glob -directory $atempo(dirname) a&a_*.tcl]] }

putlog "*loading a&a light eggdrop script*"
putlog $atempo(line)

set atempo(errors) 0

foreach script $atempo(files) {

	if {![file readable $script] || ![file isfile $script]} {

		incr atempo(errors)
		putlog "- FAILED TO LOAD ${script}. File unreadable or doesn't exist"


	} elseif {![catch {source $script} state]} {

		if { [string equal $state skipped]} {continue}

		putlog "+ LOADED $state"
		set atempo(loaded,$state) 1

	} else {

		incr atempo(errors)
		putlog "- FAILED TO LOAD ${script}. Error: [iif $atempo(adv_err_report) $errorInfo $state]"
	}
}

putlog $atempo(line)

############ Checking core files for errors ##########

if {![info exists atempo(loaded,core)]} {

	$atempo(action) "Warning! $atempo(dirname)/a&a_01_a_core.tcl core script file is missing or has errors & was NOT loaded. BOT shutdowned."
}

if {![info exists atempo(loaded,binds)]} {

	$atempo(action) "Warning! $atempo(dirname)/a&a_02_a_binds.tcl core script file is missing or has errors & was NOT loaded. BOT shutdowned."
}

if {![info exists "atempo(loaded,en dictionary)"]} {

	$atempo(action) "Warning! $atempo(dirname)/a&a_04_a_dict_en.tcl core script file is missing or has errors & was NOT loaded. BOT shutdowned."
}

############ Checking other files for errors #########

if {!$atempo(errors)} {

	putlog "*a&a light loaded successfully :)*" } {
	putlog "*a&a light loaded with errors :( *"
}

putlog $atempo(line)

############ Unset temp vars #########################

unset atempo