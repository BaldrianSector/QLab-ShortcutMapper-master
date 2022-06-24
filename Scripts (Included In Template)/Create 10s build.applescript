set userDuration to 10
set userLevel to 5
set userLevelAsText to " +" & userLevel & "dB"
set userKindString to "Build: "

tell application id "com.figure53.QLab.4" to tell front workspace
	try -- This protects against no selection (can't get last item of (selected as list))
		set originalCue to last item of (selected as list)
		set originalCueType to q type of originalCue
		if originalCueType is "Group" then
			make type "Fade"
			set newCue to last item of (selected as list)
			set fade mode of newCue to relative
			set cue target of newCue to originalCue
			set duration of newCue to userDuration
			newCue setLevel row 0 column 0 db userLevel
			set q name of newCue to userKindString & q list name of originalCue & userLevelAsText
		else if originalCueType is in {"Audio", "Mic", "Video"} then
			make type "Fade"
			set newCue to last item of (selected as list)
			set fade mode of newCue to relative
			set cue target of newCue to originalCue
			set duration of newCue to userDuration
			set currentLevel to originalCue getLevel row 0 column 0
			newCue setLevel row 0 column 0 db userLevel
			set q name of newCue to userKindString & q list name of originalCue & userLevelAsText
		else if originalCueType is "Fade" then
			set originalCueTarget to cue target of originalCue
			if q type of originalCueTarget is not "Group" then
				make type "Fade"
				set newCue to last item of (selected as list)
				set fade mode of newCue to relative
				set cue target of newCue to originalCueTarget
				set duration of newCue to userDuration
				set currentLevel to originalCue getLevel row 0 column 0
				newCue setLevel row 0 column 0 db userLevel
				set q name of newCue to userKindString & q list name of originalCueTarget & userLevelAsText
			end if
		end if
	end try
end tell