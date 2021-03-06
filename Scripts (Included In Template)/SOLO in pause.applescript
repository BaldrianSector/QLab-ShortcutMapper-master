tell application id "com.figure53.QLab.4" to tell front workspace
	
	-- Make a list of selected cues, including one layer of children
	
	set selectedIDs to {}
	repeat with eachCue in (selected as list)
		if q type of eachCue is not "Group" then
			set end of selectedIDs to uniqueID of eachCue
		else
			set selectedIDs to selectedIDs & uniqueID of cues of eachCue
		end if
	end repeat
	
	-- Make a list of active cues that aren't Group Cues and aren't selected
	
	set alreadyPaused to false
	set activeIDs to {}
	set activeCues to (active cues as list)
	repeat with eachCue in activeCues
		if q type of eachCue is not "Group" then
			set eachID to uniqueID of eachCue
			if eachID is not in selectedIDs then
				set end of activeIDs to eachID
			end if
		end if
	end repeat
	
	-- If any of the "active cues" are paused, start them and set a flag not to pause any
	
	repeat with eachID in activeIDs
		if paused of cue id eachID is true then
			start cue id eachID
			set alreadyPaused to true
		end if
	end repeat
	
	-- If none of the "active cues" were paused, pause them all
	
	if alreadyPaused is false then
		repeat with eachID in activeIDs
			pause cue id eachID
		end repeat
	end if
	
end tell