tell application id "com.figure53.QLab.4" to tell front workspace
	try
		set thesecs to (notes of cue "LOGE") - (notes of cue "LOGS")
		
		set theHours to (thesecs div 3600)
		
		set theRemainderSeconds to (thesecs mod 3600) as integer
		set theMinutes to (theRemainderSeconds div 60)
		set theRemainderSeconds to (theRemainderSeconds mod 60)
		
		if length of (theHours as text) = 1 then
			set theHours to "0" & (theHours as text)
		end if
		if length of (theMinutes as text) = 1 then
			set theMinutes to "0" & (theMinutes as text)
		end if
		if length of (theRemainderSeconds as text) = 1 then
			set theRemainderSeconds to "0" & theRemainderSeconds as text
		end if
		set notes of cue "LOGD" to (theHours & ":" & theMinutes & ":" & theRemainderSeconds)
	end try
	
	
	
	
	set this_data to return & "Show duration: " & notes of cue "LOGD" & return
	set target_file to (((path to desktop folder) as string) & "SHOWLOGGER.txt")
	set append_data to true
	
	
	try
		set the target_file to the target_file as string
		-- set the open_target_file to open for access file target_file with write permission
		
		
		
		if append_data is false then set eof of the open_target_file to 0
		
		do shell script "echo " & this_data & " >>~/Desktop/SHOWLOGGER.txt"
		--write this_data to the open_target_file starting at eof
		--close access the open_target_file
		
		return true
	on error
		try
			close access file target_file
		end try
		return false
	end try
	
end tell