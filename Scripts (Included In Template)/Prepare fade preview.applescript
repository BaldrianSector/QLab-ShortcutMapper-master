tell application id "com.figure53.QLab.4" to tell front workspace
	repeat with eachCue in (selected as list)
		if q type of eachCue is "Fade" then
			set eachCueTarget to cue target of eachCue
			if running of eachCueTarget is false then
				preview eachCueTarget
			end if
		end if
	end repeat
end tell