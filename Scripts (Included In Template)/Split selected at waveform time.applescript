-- Only works properly when run as a separate process!

tell application id "com.figure53.QLab.4" to tell front workspace
	
	try -- This protects against no selection (can't get last item of (selected as list))
		
		set selectedCue to last item of (selected as list)
		
		if q type of selectedCue is not "Audio" then error -- Need to escape the whole script
		
		set startTime to start time of selectedCue
		set endTime to end time of selectedCue
		
		set splitTime to startTime + ((percent action elapsed of selectedCue) * (duration of selectedCue)) * (rate of selectedCue)
		-- ###FIXME### As of 4.4.1, "action elapsed" reports differently between clicking in waveform and loading to time when rate ­ 1
		
		if splitTime - startTime ² 1.0E-3 or endTime - splitTime ² 1.0E-3 then error -- No point splitting if within 1ms of top/tail
		-- "percent action elapsed" reports 99.999% not 100% when a cue is loaded to its end time, so 1ms is a limit imposed by this rounding error
		
		stop selectedCue -- Just to make it clearer what's going on
		
		-- Now, a slightly bodgy way of making sure that focus is not in the Inspector Ð so copy/paste works properly Ð and only one cue selected
		
		moveSelectionUp
		if last item of (selected as list) is not selectedCue then -- Selected cue was at the top of a cue list!
			moveSelectionDown
		end if
		
	on error
		
		return -- Don't go any furtherÉ
		
	end try
	
end tell

-- Use UI scripting to copy & paste (yuck!)

try
	tell application "System Events" to tell (first application process whose bundle identifier is "com.figure53.QLab.4")
		-- set frontmost to true -- ###TESTING### Need this line if testing from Script Editor!
		click menu item "Copy" of menu 1 of menu bar item "Edit" of menu bar 1
		click menu item "Paste" of menu 1 of menu bar item "Edit" of menu bar 1
	end tell
on error
	my displayAlert("UI scripting failed!", "You need to adjust your privacy settings to allow QLab to control your computerÉ", "critical", {"Cancel", "OK"}, 2, 1)
	tell application "System Preferences"
		activate
		reveal anchor "Privacy_Assistive" of pane id "com.apple.preference.security"
	end tell
	return
end try

-- Set the times

tell application id "com.figure53.QLab.4" to tell front workspace
	set copiedCue to last item of (selected as list)
	set end time of selectedCue to splitTime
	set start time of copiedCue to splitTime
end tell

-- Subroutines

(* === ERROR HANDLING === *)

on displayAlert(theWarning, theMessage, theIcon, theButtons, defaultButton, cancelButton) -- [Shared subroutine]
	tell application id "com.figure53.QLab.4"
		if cancelButton is "" then
			if theIcon is "critical" then -- Triangle with app icon
				display alert theWarning message theMessage as critical buttons theButtons Â
					default button item defaultButton of theButtons
			else if theIcon is "informational" then -- App icon
				display alert theWarning message theMessage as informational buttons theButtons Â
					default button item defaultButton of theButtons
			else if theIcon is "warning" then -- App icon
				display alert theWarning message theMessage as warning buttons theButtons Â
					default button item defaultButton of theButtons
			end if
		else
			if theIcon is "critical" then
				display alert theWarning message theMessage as critical buttons theButtons Â
					default button item defaultButton of theButtons cancel button item cancelButton of theButtons
			else if theIcon is "informational" then
				display alert theWarning message theMessage as informational buttons theButtons Â
					default button item defaultButton of theButtons cancel button item cancelButton of theButtons
			else if theIcon is "warning" then
				display alert theWarning message theMessage as warning buttons theButtons Â
					default button item defaultButton of theButtons cancel button item cancelButton of theButtons
			end if
		end if
	end tell
end displayAlert