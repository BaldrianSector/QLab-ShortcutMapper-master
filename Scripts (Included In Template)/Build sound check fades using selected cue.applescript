tell application id "com.figure53.qlab.4" to tell front workspace
	
	set theCheckCue to last item of (selected as list)
	
	-- make sure we're going to sound check with an audio cue
	if q type of theCheckCue is not "Audio" then
		display dialog "Select an Audio cue before running this cue." with title "Sound Check" with icon 1 buttons {"OK"} default button 1
	else
		
		set theFadeTime to 0.5
		
		set numberOfOutputs to text returned of (display dialog "Check how many outputs?" with title "Sound Check" with icon 1 default answer "" buttons {"Cancel", "OK"} cancel button 1 default button 2) as number
		
		-- set all the output masters of the check cue to silent
		repeat with theOutput from 1 to numberOfOutputs
			do shell script "echo /cue/selected/level/0/" & theOutput & " -inf >/dev/udp/localhost/53535"
		end repeat
		
		-- set all the crosspoints of the check cue to 0db
		repeat with theInput from 1 to 2
			repeat with theOutput from 1 to numberOfOutputs
				do shell script "echo /cue/selected/level/" & theInput & "/" & theOutput & " 0 >/dev/udp/localhost/53535"
			end repeat
		end repeat
		
		repeat with theOutput from 1 to numberOfOutputs
			make type "Fade"
			set newCue to last item of (selected as list)
			set cue target of newCue to theCheckCue
			set duration of newCue to theFadeTime
			set q name of newCue to "Output " & theOutput
			
			-- set all the output masters of the fade cue to silent
			repeat with x from 1 to numberOfOutputs
				newCue setLevel row 0 column x db -120
			end repeat
			
			-- set the output we want to check to 0db
			newCue setLevel row 0 column theOutput db 0
			
			set stop target when done of newCue to false
		end repeat
		
		-- make a "done" cue
		make type "Fade"
		set newCue to last item of (selected as list)
		set cue target of newCue to theCheckCue
		set duration of newCue to theFadeTime
		set q name of newCue to "Done"
		
		-- set all the output masters of the fade cue to silent
		repeat with x from 1 to numberOfOutputs
			newCue setLevel row 0 column x db -120
		end repeat
		set stop target when done of newCue to true
		
		set playback position of current cue list to theCheckCue
		
		display dialog "Ready for sound check." with title "Sound Check" with icon 1 buttons {"OK"} default button 1
		
	end if
end tell