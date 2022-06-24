set userDuration to 1 -- This is the time the fade(s) will be forced to complete in
set userEnterIntoGroups to true -- Set this to false if you don't want the script to act on Fade Cues within selected Group Cues

tell application id "com.figure53.QLab.4" to tell front workspace
	set cuesToProcess to (selected as list)
	set processedIDs to {}
	set fadeCues to {}
	set originalPreWaits to {}
	set originalDurations to {}
	set originalContinueModes to {}
	set i to 0
	repeat until i = (count cuesToProcess) -- Extract just the Fade Cues
		set eachCue to item (i + 1) of cuesToProcess
		set eachType to q type of eachCue
		if eachType is "Fade" then
			set eachID to uniqueID of eachCue
			if eachID is not in processedIDs then
				set end of fadeCues to eachCue
				set end of processedIDs to eachID
			end if
		else if userEnterIntoGroups is true and eachType is "Group" then
			set cuesToProcess to cuesToProcess & cues of eachCue
		end if
		set i to i + 1
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