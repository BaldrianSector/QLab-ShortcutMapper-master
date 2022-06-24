tell application id "com.figure53.QLab.4" to tell front workspace
	set selectedCues to (selected as list)
	repeat with eachCue in selectedCues
		if q type of eachCue is "Group" and mode of eachCue is "Timeline" or q type of eachCue is "Light" then
			if eachCue is running then
				pause eachCue
			end if
			load eachCue time ((the pre wait of eachCue) + (the duration of eachCue))
			start eachCue
		end if
	end repeat
end tell