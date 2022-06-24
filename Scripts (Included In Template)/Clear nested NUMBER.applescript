set userEnterIntoGroups to true -- Set this to false if you don't want the script to act on children of selected Group Cues

tell application id "com.figure53.QLab.4" to tell front workspace
	set cuesToProcess to (selected as list)
	set selectedCount to count cuesToProcess
	set currentCueList to current cue list
	set i to 0
	repeat until i = (count cuesToProcess)
		set eachCue to item (i + 1) of cuesToProcess
		if i < selectedCount then -- Don't need to check parentage of cues added to the list as children of selected Group Cues
			if parent of eachCue is not currentCueList then
				set q number of eachCue to ""
			end if
		else
			set q number of eachCue to ""
		end if
		if userEnterIntoGroups is true then
			if q type of eachCue is "Group" then
				set cuesToProcess to cuesToProcess & cues of eachCue
			end if
		end if
		set i to i + 1
	end repeat
end tell