tell application id "com.figure53.QLab.4" to tell front workspace

	set selectedCues to (selected as list)
	
	if (count selectedCues) is not 0 then
		
		set selected to last item of selectedCues -- Protect against default behaviour
		make type "Group"
		set groupCue to last item of (selected as list)
		set groupCueIsIn to parent of groupCue
		
		set cueNumber to q number of first item of selectedCues
		set q number of first item of selectedCues to ""
		set q number of groupCue to cueNumber
		
		set cueNames to {}
		repeat with i from 1 to (count selectedCues)
			set eachName to q list name of item i of selectedCues
			if eachName is not "" then
				set end of cueNames to eachName
			end if
		end repeat
		set currentTIDs to AppleScript's text item delimiters
		set AppleScript's text item delimiters to " & "
		set q name of groupCue to cueNames as text
		set AppleScript's text item delimiters to currentTIDs
		
		set cueNotes to notes of first item of selectedCues
		set notes of first item of selectedCues to ""
		set notes of groupCue to cueNotes
		
		repeat with eachCue in selectedCues
			if contents of eachCue is not groupCueIsIn then -- Skip a Group Cue that contains the new Group Cue
				set eachCueID to uniqueID of eachCue
				move cue id eachCueID of parent of eachCue to end of groupCue
			end if
		end repeat
		
	end if
	
end tell