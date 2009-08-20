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

a:command -add server   pub:server   1089 533 v
a:command -add ignore   pub:ignore   1081 529 v

############ Command Procs ###########################

proc pub:server {hand chan args x mix} { global server ; a:tell $x 71 $server; return "..."}

proc pub:ignore {hand chan args x mix} {

	set whom   [lindex $args 0]

	if { $whom == ""} { a:usage $x ignore; return "FAILED: not all parameters specified"}

	switch  -- $whom {

		-l	-
		-list	{ if { [llength [ignorelist]]} {foreach w [ignorelist] {a:tell $x 278 "[lindex $w 0] [lindex $w 4] [lindex $w 1], expires: [iif [lindex $w 2] [duration [expr [lindex $w 2] - [unixtime]]] never]"}} {a:tell $x 277}
			  return list
		}

		-r	 -
		-remove	{ set mask [lindex $args 1]
			  if { $mask == ""} {a:usage $x ignore; return "FAILED: not all parameters specified"}
			  if {![isignore $mask]} {a:tell $x 279 $mask; return "FAILED: nonexistent mask ($mask)"}

			  killignore  $mask
			  a:tell $x 280 $mask
			  return "REMOVE $mask"
		}

		-a	-
		-add	{ set mask   [lindex $args 1]
		  	  set time   [lindex $args 2]
			  set reason [join [lrange $args 3 end]]

			  if {![a:check -digit $time]}  {set time 60; set reason "[lrange $args 1 end]"}
			  if { $reason == ""}		{set reason "No reason supplied" }
			  if {![a:check -host $mask]}   {global botnick; a:tell $x 15 $botnick; return "FAILED: invalid hostmask"}
			  if { [isignore $mask]}        {a:tell $x 275 $mask; return "FAILED: mask exists already" }

			  newignore $mask $hand $reason $time

			  a:tell $x 276 $mask
			  return "$mask for $time ($reason)"
		}

		default {a:usage $x ignore; return "FAILED: not all parameters specified"}
	}
}

return "global v commands"