-- This script can not be run as a separate process as this creates a new instance each time, resetting the property used to store the marked cue

-- Declarations

global dialogTitle
set dialogTitle to "Mark/Jump"
property storedCue : false

-- Main routine

tell application id "com.figure53.QLab.4" to tell front workspace
	set selectedCues to (selected as list)
	if (count selectedCues) is 0 then -- There is no selected cue: we are jumping
		if storedCue is not false then
			my jumpToCue()
		end if
	else
		if storedCue is false then -- There is no stored cue: we are marking
			my markCue(every item of selectedCues)
		else -- There is a stored cue, but we'll check what is required
			set theButton to button returned of (display dialog "Jump to stored cue?" with title dialogTitle with icon 1 Â
				buttons {"Mark", "OK"} default button "OK")
			if theButton is "OK" then -- We are jumping
				my jumpToCue()
			else -- We are marking
				my markCue(every item of selectedCues)
			end if
		end if
	end if
end tell

-- Subroutines

(* === PROCESSING === *)

on markCue(cueToMark)
	tell application id "com.figure53.QLab.4" to tell front workspace
		set storedCue to cueToMark
	end tell
end markCue

on jumpToCue()
	tell application id "com.figure53.QLab.4" to tell front workspace
		try
			set selected to storedCue -- This will throw an error if the cue has been deleted
		on error
			set storedCue to false -- Clear the stored cue if it wasn't found
		end try
	end tell
end jumpToCue  