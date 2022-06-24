set userCueList to "Main Cue List" -- Use this to specify the name of the cue list that receives the Start Cue(s)

-- Declarations

global dialogTitle
set dialogTitle to "Add Start Cues"

-- Main routine

tell application id "com.figure53.QLab.4" to tell front workspace
	try -- Check destination cue list exists
		set startCueList to first cue list whose q name is userCueList
	on error
		display dialog "The destination cue list \"" & userCueList & "\" does not exist." with title dialogTitle with icon 0 Â
			buttons {"OK"} default button "OK"
		return
	end try
	set startingSelection to selected
	set startingCueList to current cue list
	set originalCueList to q name of current cue list
	if originalCueList is not userCueList then
		set selectedCues to (selected as list)
		set current cue list to startCueList
		repeat with eachCue in selectedCues
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
		delay 1 -- Let you see it
		set selected to startingSelection
		set current cue list to startingCueList
	end if
	
end tell