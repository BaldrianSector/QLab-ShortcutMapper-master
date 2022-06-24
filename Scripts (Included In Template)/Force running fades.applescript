set userDuration to 1 -- This is the time the fade(s) will be forced to complete in

tell front workspace
	set fadeCues to {}
	set originalPreWaits to {}
	set originalDurations to {}
	set originalContinueModes to {}
	repeat with eachCue in (active cues as list) -- Extract just the Fade Cues
		if q type of eachCue is "Fade" then
			set end of fadeCues to eachCue
		end if
	end repeat
	repeat with eachCue in fadeCues
		stop eachCue
		set end of originalPreWaits to pre wait of eachCue
		set end of originalDurations to duration of eachCue
		set end of originalContinueModes to continue mode of eachCue
		set pre wait of eachCue to 0
		set duration of eachCue to userDuration
		set continue mode of eachCue to do_not_continue
		start eachCue
	end repeat
	delay userDuration + 0.1 -- Give the cue(s) time to complete before resetting to the original variables
	repeat with i from 1 to count fadeCues
		set eachCue to item i of fadeCues
		stop eachCue -- In case of Post Wait…
		set pre wait of eachCue to item i of originalPreWaits
		set duration of eachCue to item i of originalDurations
		set continue mode of eachCue to item i of originalContinueModes
	end repeat
end tell