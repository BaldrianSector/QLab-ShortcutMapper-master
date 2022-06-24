using terms from application "Finder"
	set themessage to "-----------------------------------------------------------" & return & "SHOW FILE: " & name of front document of application id "com.figure53.QLab.4" as string
end using terms from
set this_data to themessage & return & return
set target_file to (((path to desktop folder) as string) & "SHOWLOGGER.txt")
set append_data to true
try
	set the target_file to the target_file as string
	set the open_target_file to open for access file target_file with write permission
	if append_data is false then set eof of the open_target_file to 0
	write this_data to the open_target_file starting at eof
	close access the open_target_file
	return true
on error
	try
		close access file target_file
	end try
	return false
end try
