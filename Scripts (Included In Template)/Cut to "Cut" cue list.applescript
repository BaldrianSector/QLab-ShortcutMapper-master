set userCutList to "Cut" -- Use this to set the name of the cue list to which to move cut cues

-- Declarations

global dialogTitle
set dialogTitle to "Move cut cues"

-- Main routine

tell application id "com.figure53.QLab.4" to tell front workspace
	
	try
		set cutList to first cue list whose q name is userCutList
	on error
		display dialog "The destination cue list can not be found�" with title dialogTitle with icon 0 buttons {"OK"} default button "OK" giving up after 5
		return
	end try
	if current cue list is not cutList then
		set selectedCues to (selected as list)
		set selectedCueIDs to {}
		repeat with eachCue in selectedCues
			set end of selectedCueIDs to uniqueID of eachCue
		end repeat
		repeat with eachCueID in selectedCueIDs
			set eachParentID to uniqueID of parent of cue id eachCueID
			if eachParentID is not in selectedCueIDs then -- If the parent cue is being cut too, keep the nested structure
				move cue id eachCueID of cue id eachParentID to end of cutList
			end if
		end repeat
	end if
end tell