tell application id "com.figure53.QLab.4" to tell front workspace
	
	-- Sets the prefixes for audio, light and video
	set audioPrefix to "[SOUND]"
	set lightPrefix to "[LIGHT]"
	set videoPrefix to "[VIDEO]"
	
	set selectedCues to (selected as list)
	repeat with eachCue in selectedCues
		if q type of eachCue is "group" then -- If cue type is group
			set cuesInGroup to cues of eachCue
			set prefix to ""
			-- Determine what kinds of cues are inside
			set audioCount to 0
			set lightCount to 0
			set videoCount to 0
			repeat with eachCueInGroup in cuesInGroup
				if q type of eachCueInGroup is "audio" then
					set audioCount to audioCount + 1
				else if q type of eachCueInGroup is "light" then
					set lightCount to lightCount + 1
				else if q type of eachCueInGroup is "midi" and message type of eachCueInGroup is msc then -- Count MSC as Light cue
					set lightCount to lightCount + 1
				else if q type of eachCueInGroup is "video" then
					set videoCount to videoCount + 1
					--checking targets of fade cues
				else if q type of eachCueInGroup is "fade" then
					--check cue target of fade cues
					if q type of cue target of eachCueInGroup is "audio" then
						set audioCount to audioCount + 1
					else if q type of cue target of eachCueInGroup is "video" then
						set videoCount to videoCount + 1
					end if --check cue target for fade cue
					-- Checking inside groups inside the group
				else if q type of eachCueInGroup is "group" then
					set cuesInTHATGroup to cues of eachCueInGroup
					repeat with eachCueInTHATGroup in cuesInTHATGroup
						if q type of eachCueInTHATGroup is "audio" then
							set audioCount to audioCount + 1
						else if q type of eachCueInTHATGroup is "light" then
							set lightCount to lightCount + 1
						else if q type of eachCueInTHATGroup is "midi" and message type of eachCueInTHATGroup is msc then -- Count MSC as Light cue
							set lightCount to lightCount + 1
						else if q type of eachCueInTHATGroup is "video" then
							set videoCount to videoCount + 1
							-- Checking targets of fade cues
						else if q type of eachCueInTHATGroup is "fade" then
							-- Check cue target of fade cues
							if q type of cue target of eachCueInTHATGroup is "audio" then
								set audioCount to audioCount + 1
							else if q type of cue target of eachCueInTHATGroup is "video" then
								set videoCount to videoCount + 1
							end if -- Check cue target for fade cue
						end if
					end repeat -- For eachCueInTHATGroup
				end if
			end repeat -- For eachCueInGroup
			-- Create the correct prefix
			if audioCount > 0 then set prefix to audioPrefix
			if lightCount > 0 then
				if prefix is "" then
					set prefix to lightPrefix
				else
					set prefix to prefix & " + " & lightPrefix
				end if
			end if
			if videoCount > 0 then
				if prefix is "" then
					set prefix to videoPrefix
				else
					set prefix to prefix & " + " & videoPrefix
				end if
			end if
			-- See if there is already a prefix, and remove it
			set existingName to q name of eachCue
			if existingName contains audioPrefix or existingName contains lightPrefix or existingName contains videoPrefix then
				set thetids to AppleScript's text item delimiters
				set AppleScript's text item delimiters to "] "
				set existingName to every text item of existingName
				set existingName to last item of existingName
				set AppleScript's text item delimiters to thetids
			end if -- If the cue name has already been given a prefix
			if prefix is not "" then
				set q name of eachCue to (prefix as text) & " " & existingName
			end if
		end if -- If eachCue is a group cue
	end repeat -- For eachCue
end tell