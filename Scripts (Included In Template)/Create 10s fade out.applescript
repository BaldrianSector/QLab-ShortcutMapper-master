set userDuration to 10
set userMinVolume to -120 -- Set what level you mean by "faded out" (you can adjust this to match the workspace "Min Volume Limit" if necessary)

tell application id "com.figure53.QLab.4" to tell front workspace
	try -- This protects against no selection (can't get last item of (selected as list))
		set originalCue to last item of (selected as list)
		set originalCueType to q type of originalCue
		if originalCueType is in {"Group", "Audio", "Mic", "Video"} then
			make type "Fade"
			set newCue to last item of (selected as list)
			set cue target of newCue to originalCue
			set duration of newCue to userDuration
			newCue setLevel row 0 column 0 db userMinVolume
			if originalCueType is not "Video" then
				set stop target when done of newCue to true
			end if
			set q name of newCue to "Fade out: " & q list name of originalCue
		else if originalCueType is "Fade" then
			set originalCueTarget to cue target of originalCue
			make type "Fade"
			set newCue to last item of (selected as list)
			set cue target of newCue to originalCueTarget
			set duration of newCue to userDuration
			newCue setLevel row 0 column 0 db userMinVolume
			if q type of originalCueTarget is not "Video" then
				set stop target when done of newCue to true
			end if
			set q name of newCue to "Fade out: " & q list name of originalCueTarget
		end if
	end try
end tell