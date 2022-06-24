-- Best run as a separate process so it can be happening in the background, as it is quite slow

set qLabMaxAudioChannels to 64

tell application id "com.figure53.QLab.4" to tell front workspace
	repeat with eachCue in (selected as list)
		try
			if audio input channels of eachCue is 1 then
				repeat with i from 1 to qLabMaxAudioChannels
					setLevel eachCue row 1 column i db 0
				end repeat
			else if audio input channels of eachCue is 2 then
				repeat with i from 1 to qLabMaxAudioChannels
					setLevel eachCue row 1 column i db -6
					setLevel eachCue row 2 column i db -6
				end repeat
			end if
		end try
	end repeat
end tell