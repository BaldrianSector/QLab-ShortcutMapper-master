tell application id "com.figure53.QLab.4" to tell front workspace
	set selectedCues to (selected as list)
	repeat with eachCue in selectedCues
		set notes of eachCue to the clipboard
	end repeat
end tell