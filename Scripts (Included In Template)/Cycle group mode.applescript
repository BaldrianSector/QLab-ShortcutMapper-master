tell application id "com.figure53.QLab.4" to tell front workspace
	try
		set selectedCue to last item of (selected as list)
		if q type of selectedCue is "Group" then
			if mode of selectedCue is fire_first_go_to_next_cue then
				set theCues to cues of selectedCue
				set deltaTime to 0
				repeat with eachCue in theCues
					set eachPre to pre wait of eachCue
					set deltaTime to deltaTime + eachPre
					set pre wait of eachCue to deltaTime
					if continue mode of eachCue is auto_follow then
						set eachPost to duration of eachCue
					else
						set eachPost to post wait of eachCue
					end if
					set deltaTime to deltaTime + eachPost
					set post wait of eachCue to 0
					set continue mode of eachCue to do_not_continue
				end repeat
				set mode of selectedCue to timeline -- Can't set continue modes while mode is timeline, so have to do this here…
				if post wait of selectedCue is duration of selectedCue then -- Clear Post Wait if it looks like it's been set by "effective duration" script
					set post wait of selectedCue to 0
				end if
			else if mode of selectedCue is timeline then
				set theCues to cues of selectedCue
				set previousPre to 0
				set mode of selectedCue to fire_first_go_to_next_cue
				repeat with eachCue in theCues
					set eachPre to pre wait of eachCue
					set deltaTime to eachPre - previousPre
					set previousPre to eachPre
					set pre wait of eachCue to deltaTime
					if contents of eachCue is not last item of theCues then
						set continue mode of eachCue to auto_continue
					end if
				end repeat
			end if
		end if
	end try
end tell