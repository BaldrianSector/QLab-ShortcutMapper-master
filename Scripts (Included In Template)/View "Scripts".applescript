set userCueList to "Scripts" -- Use this to specify the name of the cue list

tell application id "com.figure53.QLab.4" to tell front workspace
	set current cue list to first cue list whose q name is userCueList
end tell