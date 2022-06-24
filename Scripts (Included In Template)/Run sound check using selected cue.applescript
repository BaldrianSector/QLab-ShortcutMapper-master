tell application id "com.figure53.qlab.4" to tell front workspace
	set theCheckCue to last item of (selected as list)
	
	-- make sure we're going to sound check with an audio cue
	if q type of theCheckCue is not "Audio" then
		display dialog "Select an Audio cue before running this cue." with title "Sound Check" with icon 1 buttons {"OK"} default button 1
	else
		
		-- warn user that sound check is about to begin	
		display dialog "Sound check with the selected cue will begin with output #1 at 0db." & return & "Be sure the master level is set appropriately. All other audio levels of this cue will be overwritten." with title "Sound check" with icon 1 buttons {"Cancel", "Begin"} cancel button 1 default button 2
		
		-- set all the output masters of the check cue to silent
		repeat with theOutput from 1 to 64
			do shell script "echo /cue/selected/level/0/" & theOutput & " -inf >/dev/udp/localhost/53535"
		end repeat
		
		-- set all the crosspoints of the check cue to 0db
		repeat with theInput from 1 to 2
			repeat with theOutput from 1 to 64
				do shell script "echo /cue/selected/level/" & theInput & "/" & theOutput & " 0 >/dev/udp/localhost/53535"
			end repeat
		end repeat
		
		-- start checking
		set currentOutput to 1
		do shell script "echo /cue/selected/start >/dev/udp/localhost/53535"
		
		repeat
			if currentOutput < 1 then
				set currentOutput to 64
			else if currentOutput > 64 then
				set currentOutput to 1
			end if
			
			do shell script "echo /cue/selected/level/0/" & currentOutput & " 0 >/dev/udp/localhost/53535"
			
			display dialog "Checking output: " & currentOutput with title "Sound check" with icon 1 buttons {"End", "Previous", "Next"} default button 3
			
			if result = {button returned:"End"} then
				do shell script "echo /cue/selected/level/0/" & currentOutput & " -inf >/dev/udp/localhost/53535"
				do shell script "echo /cue/selected/stop >/dev/udp/localhost/53535"
				error number -128
			else if result = {button returned:"Previous"} then
				do shell script "echo /cue/selected/level/0/" & currentOutput & " -inf >/dev/udp/localhost/53535"
				set currentOutput to currentOutput - 1
				
			else if result = {button returned:"Next"} then
				do shell script "echo /cue/selected/level/0/" & currentOutput & " -inf >/dev/udp/localhost/53535"
				set currentOutput to currentOutput + 1
			end if
			
		end repeat
	end if
end tell
