set userDuration to 1 -- This is the time remaining to which to load the Fade Cue(s) before starting them

tell application id "com.figure53.QLab.4" to tell front workspace
	repeat with eachCue in (selected as list)
		if q type of eachCue is "Fade" then
			set eachCueTarget to cue target of eachCue
			if running of eachCueTarget is false then
				load eachCueTarget time pre wait of eachCueTarget
				start eachCueTarget
			end if
			stop eachCue -- In case the Fade Cue is a follow-on from its target
			set eachDuration to ((pre wait of eachCue) + (duration of eachCue)) -- Include the Pre Wait for effective duration!
			if eachDuration > userDuration then
				load eachCue time eachDuration - userDuration
			end if
			start eachCue
		end if
	end repeat
end tell