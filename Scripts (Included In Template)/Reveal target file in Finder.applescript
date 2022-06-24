tell application id "com.figure53.QLab.4" to tell front workspace
	try -- This protects against no selection (can't get last item of (selected as list))
		set selectedCue to last item of (selected as list)
		set fileTarget to file target of selectedCue
		tell application "Finder"
			reveal fileTarget
			activate
		end tell
	end try
end tell