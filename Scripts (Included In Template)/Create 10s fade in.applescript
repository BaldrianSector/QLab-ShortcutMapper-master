set userDuration to 10
set userMinVolume to -120 -- Set what level you mean by "faded out" (you can adjust this to match the workspace "Min Volume Limit" if necessary)

tell application id "com.figure53.QLab.4" to tell front workspace
	try -- This protects against no selection (can't get last item of (selected as list))
		set originalCue to last item of (selected as list)
		if q type of originalCue is in {"Audio", "Mic", "Video"} then
			set originalCueLevel to originalCue getLevel row 0 column 0
			originalCue setLevel row 0 column 0 db userMinVolume
			set originalPreWait to pre wait of originalCue
			make type "Fade"
			set newCue to last item of (selected as list)
			set cue target of newCue to originalCue
			set pre wait of newCue to originalPreWait
			set duration of newCue to userDuration
			newCue setLevel row 0 column 0 db originalCueLevel
			set q name of newCue to "Fade in: " & q list name of originalCue
		end if
	end try
end tell