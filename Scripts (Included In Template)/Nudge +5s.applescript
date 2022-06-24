-- Only works properly when run as a separate process!-- NB: the OSC command will NOT WORK if the workspace has a Passcodeset userNudge to 5tell application id "com.figure53.QLab.4" to tell front workspace	repeat with eachCue in (selected as list)		if q type of eachCue is not "Script" then -- Protect the script from running on itself			try								if running of eachCue is true then					pause eachCue					set startFlag to true				else					set startFlag to false				end if								(* -- AppleScript method, which inadvertently resets Audio Cues to their programmed levels				set currentTime to action elapsed of eachCue				load eachCue time currentTime + userNudge
				*)								set currentTime to ((action elapsed of eachCue) - (pre wait of eachCue)) -- loadActionAt method adds pre wait back to time argument!				set eachID to uniqueID of eachCue				tell me to do shell script "echo '/cue_id/" & eachID & "/loadActionAt " & currentTime + userNudge & "' | nc -u -w 0 localhost 53535"								if startFlag is true then					start eachCue				end if							end try		end if	end repeatend tell