set theMessage to "SHOW START"
set thedate to current date
set this_data to (thedate as string) & space & theMessage & return
set target_file to (((path to desktop folder) as string) & "SHOWLOGGER.txt")
set append_data to true
try
	set the target_file to the target_file as string
	set the open_target_file to open for access file target_file with write permission
	if append_data is false then set eof of the open_target_file to 0
	write this_data to the open_target_file starting at eof
	close access the open_target_file
	tell application id "com.figure53.QLab.4" to tell front workspace
		set notes of cue "LOGS" to (do shell script "date +%s") as integer
	end tell
	return true
on error
	try
		close access file target_file
	end try
	return false
end try
end