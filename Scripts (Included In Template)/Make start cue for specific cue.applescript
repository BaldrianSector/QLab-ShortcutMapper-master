set referenceNumber to "" -- Enter reference cue number here

if referenceNumber is not "" then
	
	tell application id "com.figure53.QLab.4" to tell front workspace
		try
			set referenceCue to cue referenceNumber
			
			set referenceCueList to (q name of parent list) of referenceCue
			set referenceCueNumber to q number of referenceCue
			set referenceCueName to q name of referenceCue
			
			make type "Start"
			set newCue to last item of (selected as list)
			set cue target of newCue to referenceCue
			if referenceCueList is not "" then
				set nameString to referenceCueList
			end if
			if referenceCueNumber is not "" then
				set nameString to nameString & " | " & referenceCueNumber
			end if
			if referenceCueName is not "" then
				set nameString to nameString & " | " & referenceCueName
			end if
			
			set q name of newCue to nameString
			
		on error errormsg number errorno
			display dialog errormsg & errorno
		end try
	end tell
	
else
	
	set theDialogText to "No cue has been set as reference. Please set a reference cue number in your \"Make start cue for specific cue\" script."
	display dialog theDialogText with title "No referece cue has been set!" buttons {"OK"} default button "OK"
	
end if