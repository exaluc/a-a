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
############ ROUTINE BINDS ###########################

bind msgm -|- *             a:bind:msgm
bind pubm -|- *		    a:bind:pubm
bind pubm -|-  "% for*:*"   a:bind:for
bind pubm -|-  "% skip*:*"  a:bind:skip
bind ctcp -|- "ACTION"	    a:bind:act
bind pub  -|-  all          a:bind:botnick
bind notc -|-  *	    a:bind:notice

foreach cmdpfix $settings(cmdpfix) {
	bind pubm -|- "% ${cmdpfix}*" a:bind:cmdpfix
}

set settings(cmdpfix) [lindex [split $settings(cmdpfix)] 0]

############ EVENT BINDS #############################

bind evnt - connect-server  a:routine:preconnect
bind evnt - init-server     a:routine:connect
bind evnt - userfile-loaded a:routine:userfile

############ TIME BINDS ##############################

bind time - "* * * * *"     a:timed:01:minutes
bind time - "*0 * * * *"    a:timed:10:minutes
bind time - "00 * * * *"    a:timed:01:hours
bind time - "00 01 * * *"   a:timed:24:hours
bind time - "00 02 *2 * *"  a:timed:10:days
bind time - "00 03 03 * *"  a:timed:30:days

############ MODE BINDS ##############################

bind topc -|- * a:bind:topic

############ SIGN BINDS ##############################

bind nick -|- * a:bind:nick
bind sign -|- * a:bind:sign
bind part -|- * a:bind:parts
bind join -|- *	a:bind:joins

############ MIX BINDS ###############################

bind ctcr -|- ping pub:ping:SubRoutine

############ MSG UNBINDS #############################

catch { unbind msg - ident   *msg:ident}
catch { unbind msg - addhost *msg:addhost}
catch { unbind msg - help    *msg:help}
catch { unbind msg - invite  *msg:invite}
catch { unbind msg - op      *msg:op}
catch { unbind msg - voice   *msg:voice}
catch { unbind msg - whois   *msg:whois}
catch { unbind msg - info    *msg:info}
catch { unbind msg - pass    *msg:pass}

############ DCC UNBINDS #############################

catch { unbind dcc   n|- die     *dcc:die}
	bind   dcc   N|- die     *dcc:die
catch { unbind dcc   n|- +chan   *dcc:+chan}
catch { unbind dcc   n|- -chan   *dcc:-chan}
catch { unbind dcc   m|m adduser *dcc:adduser}
catch { unbind dcc   m|m deluser *dcc:deluser}
catch { unbind dcc   m|- rehash  *dcc:rehash}
	bind   dcc   N|- rehash  *dcc:rehash
catch { unbind dcc   m|- restart *dcc:restart}
	bind   dcc   N|- restart *dcc:restart
catch { unbind dcc  mt|m chattr  *dcc:chattr}
	bind   dcc   N|- chattr  *dcc:chattr
catch { unbind dcc   n|n chanset *dcc:chanset}
	bind   dcc   N|- chanset *dcc:chanset

catch { unbind dcc   n|- tcl	 *dcc:tcl}
catch { unbind dcc   n|- set	 *dcc:set}
catch { unbind dcc   n|- simul	 *dcc:simul}

if {$settings(counterspy)} {

	catch { unbind dcc  ot|o whois   *dcc:whois}
		bind   dcc  vt|- whois   *dcc:whois
	catch { unbind dcc  ot|o match   *dcc:match}
		bind   dcc  vt|- match   *dcc:match
	catch { unbind dcc   -|- bots    *dcc:bots}
		bind   dcc   t|- bots    *dcc:bots
}

return binds