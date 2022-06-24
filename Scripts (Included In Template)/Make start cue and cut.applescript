tell application id "com.figure53.QLab.4" to tell front workspace -- Make start cue(s) targeting selected cue(s)
	
	set originalCueList to q name of current cue list
	set originalSelectedCues to (selected as list)
	set originalSelectedCuesCount to (count originalSelectedCues)
	
	if originalSelectedCuesCount is not 0 then
		
		repeat with eachCue in originalSelectedCues
			make type "Start"
			set newCue to last item of (selected as list)
			set cue target of newCue to eachCue
			set nameString to "Start"
			if originalCueList is not "" then
				set nameString to nameString & " | " & originalCueList
			end if
			set eachNumber to q number of eachCue
			if eachNumber is not "" then
				set nameString to nameString & " | Q " & eachNumber
			end if
			set eachName to q list name of eachCue
			if eachName is not "" then
				set nameString to nameString & " | " & eachName
			end if
			set q name of newCue to nameString
		end repeat
		
	end if
	
	tell application "System Events" -- Select new cues and press "x" using shift
		
		repeat (originalSelectedCuesCount - 1) times
			key code 126 using shift down -- Select new cues
		end repeat
		keystroke "x" using command down -- Cut cues
		
	end tell
	
end tell

delay 0.1

tell application id "com.figure53.QLab.4" to tell front workspace
	
	set selected to originalSelectedCues
	
end tell