tell application id "com.figure53.QLab.4" to tell front workspace
	
	if q type of current cue list is "Cart" then return -- This will stop the script if we're in a cart, as it doesn't make sense to continue!
	
	try -- This protects against no selection (can't get last item of (selected as list))
		
		set selectedCue to last item of (selected as list)
		
		-- Get cursor position
		
		set loadTime to (pre wait of selectedCue) + (percent action elapsed of selectedCue) * (duration of selectedCue)
		-- ###FIXME### As of 4.4.1, "action elapsed" reports differently between clicking in waveform and loading to time when rate ­ 1
		
		set parentCue to parent of selectedCue
		
		-- If the cue is in a "Start first child and go to next cue" Group Cue, all the cues before it will need to be loaded too;
		(* this won't detect if the cues before selectedCue won't in fact follow on into it! *)
		
		if mode of parentCue is fire_first_go_to_next_cue then
			repeat with eachChild in cues of parentCue
				if contents of eachChild is selectedCue then exit repeat
				set loadTime to loadTime + (pre wait of eachChild)
				set eachContinueMode to continue mode of eachChild
				if eachContinueMode is auto_continue then
					set loadTime to loadTime + (post wait of eachChild)
				else if eachContinueMode is auto_follow then
					set loadTime to loadTime + (duration of eachChild)
				end if
			end repeat
		end if
		
		-- Go up the hierarchy until you find a Group Cue directly in a cue list
		
		repeat until q type of parent of parentCue is "Cue List" -- This will throw an error if the selected cue is directly in a cue list
			set loadTime to loadTime + (pre wait of parentCue)
			set parentCue to parent of parentCue
		end repeat
		
		set loadTime to loadTime + (pre wait of parentCue) -- Also include the top level cue's Pre Wait
		
		-- Load the cue
		
		stop selectedCue
		set selected to parentCue
		load parentCue time loadTime
		
		-- Copy the load time to the Clipboard
		
		set the clipboard to loadTime as text
		
	end try
	
end tell