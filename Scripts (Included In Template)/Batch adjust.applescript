-- ###FIXME### Impact of housing such a large script in the workspace unknown!
-- ###FIXME### Testing has not been _exhaustive_, for obvious reasons!
-- ###FIXME### Unclear whether script can run in the background while you continue working in QLab (or elsewhere)
-- ###TODO### Add Gangs, MSC command formats?
-- ###TODO### Include "considering case" option for searches

-- Best run as a separate process so it can be happening in the background

set userEscapeHatchInterval to 50 -- Set the number of cues to process between each progress report / opportunity to cancel

-- Explanations

set theExplanation to "This script will attempt to batch adjust properties of the currently selected cues according to your instructions.

There is some error protection, but it is impossible to make this process completely idiot-proof. You should be warned if something threw an error, " & Â
	"but it's not possible to track exactly what it was."

-- Declarations

global dialogTitle, qLabMaxAudioInputs, qLabMaxAudioChannels, userEscapeHatchInterval, startTime, ohDear, abortAbort, qlab_data_path
set dialogTitle to "Batch adjust selected"

global qlab_data_path
set qlab_data_path to "private/tmp/qlab_data.txt"

set qLabMaxAudioInputs to 24
set qLabMaxAudioChannels to 64

global subChoiceTimesParameter, subChoiceMIDIParameter, subChoiceMIDICommand, subChoiceAutoload, subChoiceArmed, subChoiceContinueMode, subChoiceMode
(* These lists are also used for lookup within the chosen handlers *)

set processChoices to {"Levels", "File Target", "File Target (keeping times)", "Name", "Number", "Notes", "Times", "MIDI", "MSC Device ID", Â
	"Auto-load", "Armed", "Continue Mode", "Mode", "Patch", "Camera Patch", "Light Levels Text", "Network OSC Message", "Script Text", "ÉFinished adjusting", "** Set flag to process ALL CUES! **"}
(* Although batch adjusting of Continue Mode is now built-in, it only operates on selected cues Ð so keeping it for now as this script can affect ALL cues *)

set subChoiceName to {"Set/reset", "Add prefix", "Add suffix", "Search & replace", "Make series"}
set subChoiceNumber to {"Add prefix", "Add suffix", "Search & replace", "Make series"}
set subChoiceNotes to {"Set", "Clear", "Add prefix", "Add suffix", "Search & replace", "Clear Formatting"}
set subChoiceTimesParameter to {"Pre Wait", "Duration", "Post Wait"} -- These values can be customised as they are never used explicitly
set subChoiceTimes to {"Set", "Scale", "Add/subtract amount"}
set subChoiceMIDIParameter to {"Command", "Channel", "Byte One", "Byte Two", "Byte Combo", Â
	"End Value"} -- These values can be customised as they are never used explicitly
set subChoiceMIDICommand to {"Note On", "Note Off", "Program Change", "Control Change", Â
	"Key Pressure", "Channel Pressure", "Pitch Bend"} -- These values can be customised as they are never used explicitly
set subChoiceMIDI to {"Set", "Scale", "Add/subtract amount", "Make series"}
set subChoiceAutoload to {"On", "Off"} -- These values can be customised as they are never used explicitly
set subChoiceArmed to {"Armed", "Disarmed"} -- These values can be customised as they are never used explicitly
set subChoiceContinueMode to {"Do not continue", "Auto-continue", "Auto-follow"} -- These values can be customised as they are never used explicitly
set subChoiceMode to {"Timeline - Start all children simultaneously", "Start first child and enter into group", "Start first child and go to next cue", Â
	"Start random child and go to next cue"} -- These values can be customised as they are never used explicitly
set subChoiceCameraPatch to {1, 2, 3, 4, 5, 6, 7, 8}
set subChoiceCommandText to {"Search & replace (All text)", Â
	"Search & replace (Instrument Names only)"} -- These values can be customised as they are never used explicitly
set subChoiceOSCMessage to {"Set/reset", "Add prefix", "Add suffix", "Search & replace", "Make series"} -- Needs some protection to only run on network type cues
set subChoiceScript to {"Search & replace"}

-- NB: use "false " rather than "false" in lists presented to pickFromList()

-- Preamble

set theProcess to ""
set firstTime to true
repeat until theProcess is "ÉFinished adjusting"
	
	set ohDear to false -- A simple flag to detect problems
	set abortAbort to false -- A flag for aborting!
	
	-- Test for a selection; modify options if only one cue selected
	
	if firstTime is true then -- Only need to do this step once
		
		tell application id "com.figure53.QLab.4"
			set theSelection to (selected of front workspace as list)
		end tell
		
		set theSelectionRef to a reference to theSelection
		set countSelection to count theSelectionRef
		if countSelection is 0 then
			return
		end if
		
		if countSelection is 1 then
			set subChoiceName to items 1 through -2 of subChoiceName -- Remove "Make series"
			set subChoiceNumber to items 1 through -2 of subChoiceNumber -- Remove "Make series"
			set subChoiceMIDI to items 1 through -2 of subChoiceMIDI -- Remove "Make series"
			set subChoiceOSCMessage to items 1 through -2 of subChoiceOSCMessage -- Remove "Make series"
		end if
		
	end if
	
	-- Choose a process
	
	set theProcess to pickFromList(processChoices, theExplanation & return & return & Â
		"So that you can run more than one process, you'll keep coming back to this screen until you hit any \"Cancel\" button, " & Â
		"or choose \"ÉFinished adjusting\"." & return & return & "Choose a property category:")
	
	-- Deal with "process ALL CUES" flag
	
	if firstTime is true then -- Only need to do this step once
		
		set processChoices to items 1 through -2 of processChoices -- Remove "** Set flag to process ALL CUES! **"
		
		if theProcess is "** Set flag to process ALL CUES! **" then
			
			tell application id "com.figure53.QLab.4"
				set theSelection to (cues of front workspace as list)
			end tell
			
			set theExplanation to "WARNING: acting on ALL CUES!" & return & "WARNING: acting on ALL CUES!" & return & "WARNING: acting on ALL CUES!"
			
		end if
		
		set firstTime to false
		
	end if
	
	-- Find out more about what we're doing, and then call a subroutine to do itÉ
	
	if theProcess is "Levels" then
		
		adjustLevels(theSelectionRef, "selected cues")
		
	else if theProcess is "File Target" then
		
		adjustFileTarget(theSelectionRef, "Set", "selected cues")
		
	else if theProcess is "File Target (keeping times)" then
		
		adjustFileTarget(theSelectionRef, "Change", "selected cues")
		
	else if theProcess is "Name" then
		
		set theChoice to pickFromList(subChoiceName, "Choose how you would like to adjust the names of the selected cues:")
		
		if theChoice is "Set/reset" then
			adjustSetName(theSelectionRef, "selected cues")
		else if theChoice is "Add prefix" then
			adjustPrefixName(theSelectionRef, "selected cues")
		else if theChoice is "Add suffix" then
			adjustSuffixName(theSelectionRef, "selected cues")
		else if theChoice is "Search & replace" then
			adjustSearchReplaceName(theSelectionRef, "selected cues")
		else if theChoice is "Make series" then
			adjustSeriesName(theSelectionRef, "selected cues")
		end if
		
	else if theProcess is "Number" then
		
		set theChoice to pickFromList(subChoiceNumber, "Choose how you would like to adjust the Cue Numbers of the selected cues:")
		
		if theChoice is "Add prefix" then
			adjustPrefixNumber(theSelectionRef, "selected cues")
		else if theChoice is "Add suffix" then
			adjustSuffixNumber(theSelectionRef, "selected cues")
		else if theChoice is "Search & replace" then
			adjustSearchReplaceNumber(theSelectionRef, "selected cues")
		else if theChoice is "Make series" then
			adjustSeriesNumber(theSelectionRef, "selected cues")
		end if
		
	else if theProcess is "Notes" then
		
		set theChoice to pickFromList(subChoiceNotes, "Choose how you would like to adjust the Notes of the selected cues " & Â
			"(NB: scripting of Notes is plain-text only):")
		
		if theChoice is "Set" then
			adjustSetNotes(theSelectionRef, "selected cues")
		else if theChoice is "Clear" then
			adjustClearNotes(theSelectionRef, "selected cues")
		else if theChoice is "Add prefix" then
			adjustPrefixNotes(theSelectionRef, "selected cues")
		else if theChoice is "Add suffix" then
			adjustSuffixNotes(theSelectionRef, "selected cues")
		else if theChoice is "Search & replace" then
			adjustSearchReplaceNotes(theSelectionRef, "selected cues")
		else if theChoice is "Clear Formatting" then
			adjustClearFormattingNotes(theSelectionRef, "selected cues")
		end if
		
	else if theProcess is "Times" then
		
		set parameterChoice to pickFromList(subChoiceTimesParameter, "Choose the time parameter to adjust:")
		set theChoice to pickFromList(subChoiceTimes, "Choose how you would like to adjust the " & parameterChoice & " of the selected cues:")
		
		if theChoice is "Set" then
			adjustSetTime(theSelectionRef, parameterChoice, "selected cues")
		else if theChoice is "Scale" then
			adjustScaleTime(theSelectionRef, parameterChoice, "selected cues")
		else if theChoice is "Add/subtract amount" then
			adjustAddSubractTime(theSelectionRef, parameterChoice, "selected cues")
		end if
		
	else if theProcess is "MIDI" then
		
		-- subChoiceMIDIParameter = {"Command", "Channel", "Byte One", "Byte Two", "Byte Combo", "End Value"}
		
		set parameterChoice to pickFromList(subChoiceMIDIParameter, Â
			"Choose the MIDI parameter to adjust (\"" & item 5 of subChoiceMIDIParameter & "\" will only affect pitch bend commands):")
		if parameterChoice is item 1 of subChoiceMIDIParameter then
			set theChoice to item 1 of subChoiceMIDIParameter
		else if parameterChoice is item 2 of subChoiceMIDIParameter then
			set theChoice to "Set" -- The other options don't make a lot of sense for channel!
		else
			set theChoice to pickFromList(subChoiceMIDI, "Choose how you would like to adjust the " & parameterChoice & " of the selected cues:")
		end if
		
		if theChoice is item 1 of subChoiceMIDIParameter then
			adjustSetMIDICommand(theSelectionRef, "selected cues")
		else if theChoice is "Set" then
			adjustSetMIDI(theSelectionRef, parameterChoice, "selected cues")
		else if theChoice is "Scale" then
			adjustScaleMIDI(theSelectionRef, parameterChoice, "selected cues")
		else if theChoice is "Add/subtract amount" then
			adjustAddSubractMIDI(theSelectionRef, parameterChoice, "selected cues")
		else if theChoice is "Make series" then
			adjustSeriesMIDI(theSelectionRef, parameterChoice, "selected cues")
		end if
		
	else if theProcess is "MSC Device ID" then
		
		adjustDeviceID(theSelectionRef, "selected cues")
		
	else if theProcess is "Auto-load" then
		
		set parameterChoice to pickFromList(subChoiceAutoload, "Set Auto-load of the selected cues to:")
		
		adjustAutoload(theSelectionRef, parameterChoice, "selected cues")
		
	else if theProcess is "Armed" then
		
		set parameterChoice to pickFromList(subChoiceArmed, "Set Armed of the selected cues to:")
		
		adjustArmed(theSelectionRef, parameterChoice, "selected cues")
		
	else if theProcess is "Continue Mode" then
		
		set parameterChoice to pickFromList(subChoiceContinueMode, "Set the Continue Mode of the selected cues to:")
		
		adjustContinueMode(theSelectionRef, parameterChoice, "selected cues")
		
	else if theProcess is "Mode" then
		
		set parameterChoice to pickFromList(subChoiceMode, "Set the Mode of the selected cues to:")
		
		adjustMode(theSelectionRef, parameterChoice, "selected cues")
		
	else if theProcess is "Patch" then
		
		adjustPatch(theSelectionRef, "selected cues")
		
	else if theProcess is "Camera Patch" then
		
		set parameterChoice to pickFromList(subChoiceCameraPatch, "Set the Camera Patch of the selected cues to:")
		
		adjustCameraPatch(theSelectionRef, parameterChoice, "selected cues")
		
	else if theProcess is "Light Levels Text" then
		
		set theChoice to pickFromList(subChoiceCommandText, "Choose how you would like to adjust the Command Text of the selected cues:")
		
		if theChoice is "Search & replace (All text)" then
			adjustSearchReplaceCommandText(theSelectionRef, "selected cues", false)
		else if theChoice is "Search & replace (Instrument Names only)" then
			adjustSearchReplaceCommandText(theSelectionRef, "selected cues", true)
			
		end if
		
	else if theProcess is "Network OSC Message" then
		
		set theChoice to pickFromList(subChoiceOSCMessage, "Choose how you would like to adjust the OSC Message of the selected cues:")
		
		if theChoice is "Set/reset" then
			adjustSetOSCMessage(theSelectionRef, "selected cues")
		else if theChoice is "Add prefix" then
			adjustPrefixOSCMessage(theSelectionRef, "selected cues")
		else if theChoice is "Add suffix" then
			adjustSuffixOSCMessage(theSelectionRef, "selected cues")
		else if theChoice is "Search & replace" then
			adjustSearchReplaceOSCMessage(theSelectionRef, "selected cues")
		else if theChoice is "Make series" then
			adjustSeriesOSCMessage(theSelectionRef, "selected cues")
		end if
		
	else if theProcess is "Script Text" then
		
		set theChoice to pickFromList(subChoiceScript, "Choose how you would like to adjust the Script of the selected cues:")
		
		if theChoice is "Search & replace" then
			adjustSearchReplaceScript(theSelectionRef, "selected cues")
		end if
		
	end if
	
end repeat

-- Subroutines

(* === INPUT === *)

on enterAnInteger(thePrompt, defaultAnswer) -- [Shared subroutine]
	tell application id "com.figure53.QLab.4"
		set theQuestion to ""
		repeat until theQuestion is not ""
			set theQuestion to text returned of (display dialog thePrompt with title dialogTitle default answer defaultAnswer buttons {"Cancel", "OK"} Â
				default button "OK" cancel button "Cancel")
			try
				set theAnswer to theQuestion as integer
			on error
				set theQuestion to ""
			end try
		end repeat
		return theAnswer
	end tell
end enterAnInteger

on enterANumber(thePrompt, defaultAnswer) -- [Shared subroutine]
	tell application id "com.figure53.QLab.4"
		set theQuestion to ""
		repeat until theQuestion is not ""
			set theQuestion to text returned of (display dialog thePrompt with title dialogTitle default answer defaultAnswer buttons {"Cancel", "OK"} Â
				default button "OK" cancel button "Cancel")
			try
				set theAnswer to theQuestion as number
			on error
				set theQuestion to ""
			end try
		end repeat
		return theAnswer
	end tell
end enterANumber

on enterANumberWithRangeWithCustomButton(thePrompt, defaultAnswer, Â
	lowRange, acceptEqualsLowRange, highRange, acceptEqualsHighRange, integerOnly, customButton, defaultButton) -- [Shared subroutine]
	tell application id "com.figure53.QLab.4"
		set theQuestion to ""
		repeat until theQuestion is not ""
			set {theQuestion, theButton} to {text returned, button returned} of (display dialog thePrompt with title dialogTitle Â
				default answer defaultAnswer buttons (customButton as list) & {"Cancel", "OK"} default button defaultButton cancel button "Cancel")
			if theButton is customButton then
				set theAnswer to theButton
				exit repeat
			end if
			try
				if integerOnly is true then
					set theAnswer to theQuestion as integer -- Detects non-numeric strings
					if theAnswer as text is not theQuestion then -- Detects non-integer input
						set theQuestion to ""
					end if
				else
					set theAnswer to theQuestion as number -- Detects non-numeric strings
				end if
				if lowRange is not false then
					if acceptEqualsLowRange is true then
						if theAnswer < lowRange then
							set theQuestion to ""
						end if
					else
						if theAnswer ² lowRange then
							set theQuestion to ""
						end if
					end if
				end if
				if highRange is not false then
					if acceptEqualsHighRange is true then
						if theAnswer > highRange then
							set theQuestion to ""
						end if
					else
						if theAnswer ³ highRange then
							set theQuestion to ""
						end if
					end if
				end if
			on error
				set theQuestion to ""
			end try
		end repeat
		return theAnswer
	end tell
end enterANumberWithRangeWithCustomButton

on enterARatio(thePrompt, defaultAnswer) -- [Shared subroutine]
	tell application id "com.figure53.QLab.4"
		set theQuestion to ""
		repeat until theQuestion is not ""
			set theQuestion to text returned of (display dialog thePrompt with title dialogTitle default answer defaultAnswer buttons {"Cancel", "OK"} Â
				default button "OK" cancel button "Cancel")
			try
				set theAnswer to theQuestion as number
				if theAnswer ² 0 then
					set theQuestion to ""
				end if
			on error
				set theQuestion to ""
			end try
		end repeat
		return theAnswer
	end tell
end enterARatio

on enterATimeWithCustomButton(thePrompt, defaultAnswer, customButton) -- [Shared subroutine]
	tell application id "com.figure53.QLab.4"
		set theQuestion to ""
		repeat until theQuestion is not ""
			set {theQuestion, theButton} to {text returned, button returned} of (display dialog thePrompt with title dialogTitle Â
				default answer defaultAnswer buttons (customButton as list) & {"Cancel", "OK"} default button "OK" cancel button "Cancel")
			if theButton is customButton then
				set theAnswer to theButton
				exit repeat
			end if
			try
				set theAnswer to theQuestion as number
				if theAnswer < 0 then
					set theQuestion to ""
				end if
			on error
				if theQuestion contains ":" then
					set theAnswer to my makeSecondsFromM_S(theQuestion)
					if theAnswer is false then
						set theQuestion to ""
					end if
				else
					set theQuestion to ""
				end if
			end try
		end repeat
		return theAnswer
	end tell
end enterATimeWithCustomButton

on enterSomeText(thePrompt, defaultAnswer, emptyAllowed) -- [Shared subroutine]
	tell application id "com.figure53.QLab.4"
		set theAnswer to ""
		repeat until theAnswer is not ""
			set theAnswer to text returned of (display dialog thePrompt with title dialogTitle default answer defaultAnswer buttons {"Cancel", "OK"} Â
				default button "OK" cancel button "Cancel")
			if emptyAllowed is true then exit repeat
		end repeat
		return theAnswer
	end tell
end enterSomeText

on pickFromList(theChoice, thePrompt) -- [Shared subroutine]
	tell application id "com.figure53.QLab.4"
		choose from list theChoice with prompt thePrompt with title dialogTitle default items item 1 of theChoice
		if result is not false then
			return item 1 of result
		else
			error number -128
		end if
	end tell
end pickFromList

(* === OUTPUT === *)

on startTheClock() -- [Shared subroutine]
	tell application id "com.figure53.QLab.4"
		display dialog "One moment callerÉ" with title dialogTitle with icon 1 buttons {"OK"} default button "OK" giving up after 1
	end tell
	set startTime to current date
end startTheClock

on countdownTimer(thisStep, totalSteps, whichCuesString) -- [Shared subroutine]
	set timeTaken to round (current date) - startTime rounding as taught in school
	set timeString to my makeMSS(timeTaken)
	tell application id "com.figure53.QLab.4"
		if frontmost then
			display dialog "Time elapsed: " & timeString & " Ð " & thisStep & " of " & totalSteps & " " & whichCuesString & Â
				" doneÉ" with title dialogTitle with icon 1 buttons {"Cancel", "OK"} default button "OK" cancel button "Cancel" giving up after 1
		end if
	end tell
end countdownTimer

on finishedDialogBespoke()
	set timeTaken to round (current date) - startTime rounding as taught in school
	set timeString to my makeNiceT(timeTaken)
	tell application id "com.figure53.QLab.4"
		activate
		if abortAbort is true then
			display dialog "Process aborted due to errors!" with title dialogTitle with icon 0 buttons {"OK"} default button "OK" giving up after 120
		else
			if ohDear is true then
				set ohDearString to " There were some errors, so you should check the results."
				set ohDearIcon to 0
			else
				set ohDearString to ""
				set ohDearIcon to 1
			end if
			display dialog "Done." & ohDearString & return & return & "(That took " & timeString & ".)" with title dialogTitle with icon ohDearIcon Â
				buttons {"OK"} default button "OK" giving up after 60
		end if
	end tell
end finishedDialogBespoke

(* === PROCESSING === *)

on adjustLevels(cuesToProcess, whichCuesString)
	
	tell application id "com.figure53.QLab.4"
		
		-- Get the levels
		
		set validEntry to false
		set previousTry to ""
		repeat until validEntry is true
			
			set levelsString to my enterSomeText("Enter the levels you wish to adjust as
\"row/column/delta\" or \"row/column/@level\"; you can separate multiple entries with spaces.

For example, \"0/0/-10 0/2/@-20\" will take 10dB from the Master level (row 0 column 0) and set the Output 2 level (row 0 column 2) to -20dB.", Â
				previousTry, false)
			set previousTry to levelsString
			
			-- Convert string to array
			
			set currentTIDs to AppleScript's text item delimiters
			set AppleScript's text item delimiters to space
			set levelsWords to text items of levelsString
			set howManyLevels to count levelsWords
			set AppleScript's text item delimiters to "/"
			set backToText to levelsWords as text
			set levelsArray to text items of backToText
			set countLevelsArray to count levelsArray
			set AppleScript's text item delimiters to currentTIDs
			
			-- Check for validity
			
			if howManyLevels * 3 is countLevelsArray then -- First hurdle
				set validEntry to true
				try
					repeat with i from 1 to countLevelsArray by 3
						set eachRow to (item i of levelsArray) as number
						set eachColumn to (item (i + 1) of levelsArray) as number
						set eachLevel to item (i + 2) of levelsArray
						if eachRow < 0 or eachRow > qLabMaxAudioInputs then -- Check for valid row
							set validEntry to false
							exit repeat
						end if
						if eachColumn < 0 or eachColumn > qLabMaxAudioChannels then -- Check for valid column
							set validEntry to false
							exit repeat
						end if
						if eachLevel does not start with "@" then -- Check for valid level
							if (eachLevel as number) is 0 then -- Delta level can't be 0 (also checks string is a number)
								set validEntry to false
								exit repeat
							end if
						else
							set finalCheck to (rest of characters of eachLevel as text) as number -- Rest of string after @ must be a number
						end if
					end repeat
				on error
					set validEntry to false
				end try
			end if
			
			-- Alert and go back if invalid
			
			if validEntry is false then
				
				display dialog "\"" & levelsString & "\" is not a valid entry! Try again." with title dialogTitle with icon 0 Â
					buttons {"OK"} default button "OK" giving up after 5
				
			else
				
				-- Final check that the levels have been interpreted correctly
				
				set pleaseConfirm to ""
				repeat with i from 1 to countLevelsArray by 3
					set eachRow to (item i of levelsArray) as number
					set eachColumn to (item (i + 1) of levelsArray) as number
					set eachLevel to item (i + 2) of levelsArray
					if eachRow is 0 then
						if eachColumn is 0 then
							set eachLine to "Master Level"
						else
							set eachLine to "Output " & eachColumn & " Level"
						end if
					else
						if eachColumn is 0 then
							set eachLine to "Input " & eachRow & " Level"
						else
							set eachLine to "Crosspoint Level: Input " & eachRow & " to Output " & eachColumn
						end if
					end if
					if eachLevel does not start with "@" then
						set eachLine to "> Add " & eachLevel & "dB to " & eachLine
					else
						set eachLine to "> Set " & eachLine & " @ " & (rest of characters of eachLevel as text) & "dB"
					end if
					set pleaseConfirm to pleaseConfirm & eachLine
					if (i + 2) is not countLevelsArray then
						set pleaseConfirm to pleaseConfirm & return
					end if
				end repeat
				
				set goBack to button returned of (display dialog "Please confirm you wish to adjust levels thus for the " & whichCuesString & ":" & Â
					return & return & pleaseConfirm with title dialogTitle with icon 0 buttons {"Cancel", "No, no! Stop! That's not right! Go back!", "OK"} Â
					default button "OK" cancel button "Cancel")
				if goBack is "No, no! Stop! That's not right! Go back!" then
					set validEntry to false
				end if
				
			end if
			
		end repeat
		
		-- Now, to business
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			try -- Skip over cues that don't take levels!
				repeat with j from 1 to countLevelsArray by 3
					set eachRow to (item j of levelsArray) as number
					set eachColumn to (item (j + 1) of levelsArray) as number
					set eachLevel to item (j + 2) of levelsArray
					set currentLevel to getLevel eachCue row eachRow column eachColumn Â
						-- This check will throw an error and exit the j repeat if the cue doesn't take levels
					if eachLevel does not start with "@" then
						set eachLevel to currentLevel + eachLevel
					else
						set eachLevel to (rest of characters of eachLevel as text) as number
					end if
					try -- This try will throw a detectable error if the next line doesn't work
						setLevel eachCue row eachRow column eachColumn db eachLevel Â
							-- We're relying on QLab's ability to ignore spurious levels like "-200" or "+50"
						-- ###FIXME### As of 4.4.1, QLab appears to accept any negative value for Min Volume Limit and hence here too
					on error
						set ohDear to true
					end try
				end repeat
			end try
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustLevels

on adjustFileTarget(cuesToProcess, changeType, whichCuesString)
	
	tell application id "com.figure53.QLab.4"
		
		if changeType is "Change" then
			set promptHeader to "CHANGE File Target: start/end times maintainedÉ"
		else
			set promptHeader to "SET File Target: this process will not maintain the start/end times!"
		end if
		
		set theTarget to choose file of type "public.audio" with prompt promptHeader & return & return & Â
			"Please select the File Target to set for the " & whichCuesString & ":" without invisibles
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		set checkTheFirst to true
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			if q type of eachCue is not "Group" then -- Setting File Target on a Group Cue (or cue list) affects all Audio Cues in it!
				try -- Skip over cues that don't take File Targets!
					
					if changeType is "Change" then
						set currentStart to start time of eachCue
						set currentEnd to end time of eachCue
					end if
					
					set file target of eachCue to theTarget Â
						-- QLab doesn't appear to throw any errors even if the cue doesn't take a File Target, so no detection is possible
					
					if checkTheFirst is true then -- Check the first one worked (ie: didn't break the cue!) before going any further
						if broken of eachCue is true then -- This protects against (some) inappropriate files
							set abortAbort to true
							exit repeat
						end if
					end if
					
					if changeType is "Change" then
						set start time of eachCue to currentStart
						set end time of eachCue to currentEnd
					end if
					
				end try
				set checkTheFirst to false -- We need to check the first cue that took a target, not the first cue we tried
			end if
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustFileTarget

on adjustSetName(cuesToProcess, whichCuesString)
	
	tell application id "com.figure53.QLab.4"
		
		set theName to my enterSomeText("Enter the name you wish to set for the " & whichCuesString & Â
			" (return an empty string to reset to default names):", "", true)
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			try -- This try will throw a detectable error if the next line doesn't work (hard to think of a reason why it wouldn't though!)
				set q name of eachCue to theName
			on error
				set ohDear to true
			end try
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustSetName

on adjustPrefixName(cuesToProcess, whichCuesString)
	
	tell application id "com.figure53.QLab.4"
		
		set thePrefix to my enterSomeText("Enter the string you wish to add to the beginning of the names of the " & whichCuesString & Â
			" (include a space at the end if you expect one):", "", false)
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			set currentName to q list name of eachCue
			try -- This try will throw a detectable error if the next line doesn't work (hard to think of a reason why it wouldn't though!)
				set q name of eachCue to thePrefix & currentName
			on error
				set ohDear to true
			end try
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustPrefixName

on adjustSuffixName(cuesToProcess, whichCuesString)
	
	tell application id "com.figure53.QLab.4"
		
		set theSuffix to my enterSomeText("Enter the string you wish to add to the end of the names of the " & whichCuesString & Â
			" (include a space at the beginning if you expect one):", "", false)
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			set currentName to q list name of eachCue
			try -- This try will throw a detectable error if the next line doesn't work (hard to think of a reason why it wouldn't though!)
				set q name of eachCue to currentName & theSuffix
			on error
				set ohDear to true
			end try
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustSuffixName

on adjustSearchReplaceName(cuesToProcess, whichCuesString)
	
	tell application id "com.figure53.QLab.4"
		
		set searchFor to my enterSomeText("Enter the search string you wish to replace in the names of the " & whichCuesString & " (not case-sensitive):", Â
			"", false)
		set replaceWith to my enterSomeText("Enter the string with which you wish to replace all occurrences of \"" & Â
			searchFor & "\" in the names of the " & whichCuesString & ":", "", true)
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		set currentTIDs to AppleScript's text item delimiters
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			set currentName to q list name of eachCue
			set AppleScript's text item delimiters to searchFor
			set searchedName to text items of currentName
			set AppleScript's text item delimiters to replaceWith
			set theName to searchedName as text
			set AppleScript's text item delimiters to currentTIDs
			try -- This try will throw a detectable error if the next line doesn't work (hard to think of a reason why it wouldn't though!)
				set q name of eachCue to theName
			on error
				set ohDear to true
			end try
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustSearchReplaceName

on adjustSeriesName(cuesToProcess, whichCuesString)
	
	tell application id "com.figure53.QLab.4"
		
		set validEntry to false
		set previousBaseName to ""
		set previousStartNumber to ""
		set previousIncrement to ""
		set previousPadding to ""
		repeat until validEntry is true
			set baseName to my enterSomeText("Enter the base of the name series you wish to set for the " & whichCuesString & Â
				" (include a space at the end if you expect one):", previousBaseName, false)
			set startNumber to my enterAnInteger("Enter an integer with which to start the series:", previousStartNumber)
			set theIncrement to my enterAnInteger("Enter the increment for each step (an integer):", previousIncrement)
			set thePadding to my enterANumberWithRangeWithCustomButton("Enter the minimum number of digits Ð an integer between 1 & 10 " & Â
				"(eg: entering 2 will result in the series 01, 02, etc):", previousPadding, 1, true, 10, true, true, {}, "OK")
			set previousBaseName to baseName
			set previousStartNumber to startNumber
			set previousIncrement to theIncrement
			set previousPadding to thePadding
			set counterConfirm1 to my padNumber(startNumber, thePadding)
			set pleaseConfirm1 to "> " & baseName & counterConfirm1
			set counterConfirm2 to my padNumber(startNumber + theIncrement, thePadding)
			set pleaseConfirm2 to "> " & baseName & counterConfirm2
			set counterConfirm3 to my padNumber(startNumber + 2 * theIncrement, thePadding)
			set pleaseConfirm3 to "> " & baseName & counterConfirm3
			set pleaseConfirm to pleaseConfirm1 & return & pleaseConfirm2 & return & pleaseConfirm3 & return & "> É"
			set goBack to button returned of (display dialog "Please confirm you wish to set the names as a series of this ilk for the " & whichCuesString & Â
				":" & return & return & pleaseConfirm with title dialogTitle with icon 0 buttons {"Cancel", "No, no! Stop! That's not right! Go back!", "OK"} Â
				default button "OK" cancel button "Cancel")
			if goBack is "OK" then
				set validEntry to true
			end if
		end repeat
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			set theCounter to startNumber + (i - 1) * theIncrement
			set theCounter to my padNumber(theCounter, thePadding)
			set theName to baseName & theCounter
			try -- This try will throw a detectable error if the next line doesn't work (hard to think of a reason why it wouldn't though!)
				set q name of eachCue to theName
			on error
				set ohDear to true
			end try
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustSeriesName

on adjustPrefixNumber(cuesToProcess, whichCuesString)
	
	tell application id "com.figure53.QLab.4"
		
		set thePrefix to my enterSomeText("Enter the string you wish to add to the beginning of the Cue Numbers of the " & whichCuesString & Â
			" (include a space at the end if you expect one):" & return & return & Â
			"(NB: if the Cue Number proposed already exists it won't be changed.)", "", false)
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			set currentNumber to q number of eachCue
			try -- This try will throw a detectable error if the next line doesn't work (hard to think of a reason why it wouldn't though!)
				set q number of eachCue to thePrefix & currentNumber
			on error
				set ohDear to true
			end try
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustPrefixNumber

on adjustSuffixNumber(cuesToProcess, whichCuesString)
	
	tell application id "com.figure53.QLab.4"
		
		set theSuffix to my enterSomeText("Enter the string you wish to add to the end of the Cue Numbers of the " & whichCuesString & Â
			" (include a space at the beginning if you expect one):" & return & return & Â
			"(NB: if the Cue Number proposed already exists it won't be changed.)", "", false)
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			set currentNumber to q number of eachCue
			try -- This try will throw a detectable error if the next line doesn't work (hard to think of a reason why it wouldn't though!)
				set q number of eachCue to currentNumber & theSuffix
			on error
				set ohDear to true
			end try
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustSuffixNumber

on adjustSearchReplaceNumber(cuesToProcess, whichCuesString)
	
	tell application id "com.figure53.QLab.4"
		
		set searchFor to my enterSomeText("Enter the search string you wish to replace in the numbers of the " & whichCuesString & " (not case-sensitive):", Â
			"", false)
		set replaceWith to my enterSomeText("Enter the string with which you wish to replace all occurrences of \"" & Â
			searchFor & "\" in the numbers of the " & whichCuesString & ":", "", true)
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		set currentTIDs to AppleScript's text item delimiters
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			set currentNumber to q number of eachCue
			set AppleScript's text item delimiters to searchFor
			set searchedNumber to text items of currentNumber
			set AppleScript's text item delimiters to replaceWith
			set theNumber to searchedNumber as text
			set AppleScript's text item delimiters to currentTIDs
			try -- This try will throw a detectable error if the next line doesn't work (hard to think of a reason why it wouldn't though!)
				set q number of eachCue to theNumber
			on error
				set ohDear to true
			end try
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustSearchReplaceNumber

on adjustSeriesNumber(cuesToProcess, whichCuesString)
	
	tell application id "com.figure53.QLab.4"
		
		set validEntry to false
		set previousBaseName to ""
		set previousStartNumber to ""
		set previousIncrement to ""
		set previousPadding to ""
		repeat until validEntry is true
			set baseName to my enterSomeText("Enter the base of the Cue Number series you wish to set for the " & whichCuesString & Â
				" (include a space at the end if you expect one):", previousBaseName, false)
			set startNumber to my enterAnInteger("Enter an integer with which to start the series:", previousStartNumber)
			set theIncrement to my enterAnInteger("Enter the increment for each step (an integer):", previousIncrement)
			set thePadding to my enterANumberWithRangeWithCustomButton("Enter the minimum number of digits Ð an integer between 1 & 10 " & Â
				"(eg: entering 2 will result in the series 01, 02, etc):", previousPadding, 1, true, 10, true, true, {}, "OK")
			set previousBaseName to baseName
			set previousStartNumber to startNumber
			set previousIncrement to theIncrement
			set previousPadding to thePadding
			set counterConfirm1 to my padNumber(startNumber, thePadding)
			set pleaseConfirm1 to "> " & baseName & counterConfirm1
			set counterConfirm2 to my padNumber(startNumber + theIncrement, thePadding)
			set pleaseConfirm2 to "> " & baseName & counterConfirm2
			set counterConfirm3 to my padNumber(startNumber + 2 * theIncrement, thePadding)
			set pleaseConfirm3 to "> " & baseName & counterConfirm3
			set pleaseConfirm to pleaseConfirm1 & return & pleaseConfirm2 & return & pleaseConfirm3 & return & "> É"
			set goBack to button returned of (display dialog Â
				"Please confirm you wish to set the Cue Numbers as a series of this ilk for the " & whichCuesString & ":" & return & return & Â
				pleaseConfirm with title dialogTitle with icon 0 buttons {"Cancel", "No, no! Stop! That's not right! Go back!", "OK"} Â
				default button "OK" cancel button "Cancel")
			if goBack is "OK" then
				set validEntry to true
			end if
		end repeat
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		set j to 0
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			set existingCueNumber to true
			repeat while existingCueNumber is true
				set theCounter to startNumber + j * theIncrement
				set theCounter to my padNumber(theCounter, thePadding)
				set theName to baseName & theCounter
				try -- This try will throw a detectable error if the next line doesn't work (hard to think of a reason why it wouldn't though!)
					set q number of eachCue to theName
					if q number of eachCue is theName then -- Check the number has stuck; if it's already in use go round again
						set existingCueNumber to false
					else
						set j to j + 1
						set existingCueNumber to true
					end if
				on error
					set ohDear to true
				end try
			end repeat
			set j to j + 1
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustSeriesNumber

on adjustSetNotes(cuesToProcess, whichCuesString)
	
	tell application id "com.figure53.QLab.4"
		
		set theNotes to my enterSomeText("Enter the Notes you wish to set for the " & whichCuesString & ":", "", false)
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			try -- This try will throw a detectable error if the next line doesn't work (hard to think of a reason why it wouldn't though!)
				set notes of eachCue to theNotes
			on error
				set ohDear to true
			end try
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustSetNotes

on adjustClearNotes(cuesToProcess, whichCuesString)
	
	tell application id "com.figure53.QLab.4"
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			try -- This try will throw a detectable error if the next line doesn't work (hard to think of a reason why it wouldn't though!)
				set notes of eachCue to ""
			on error
				set ohDear to true
			end try
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustClearNotes

on adjustPrefixNotes(cuesToProcess, whichCuesString)
	
	tell application id "com.figure53.QLab.4"
		
		set thePrefix to my enterSomeText("Enter the string you wish to add to the beginning of the Notes of the " & whichCuesString & Â
			" (include a space at the end if you expect one):", "", false)
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			set currentNotes to notes of eachCue
			try -- This try will throw a detectable error if the next line doesn't work (hard to think of a reason why it wouldn't though!)
				set notes of eachCue to thePrefix & currentNotes
			on error
				set ohDear to true
			end try
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustPrefixNotes

on adjustSuffixNotes(cuesToProcess, whichCuesString)
	
	tell application id "com.figure53.QLab.4"
		
		set theSuffix to my enterSomeText("Enter the string you wish to add to the end of the Notes of the " & whichCuesString & Â
			" (include a space at the beginning if you expect one):", "", false)
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			set currentNotes to notes of eachCue
			try -- This try will throw a detectable error if the next line doesn't work (hard to think of a reason why it wouldn't though!)
				set notes of eachCue to currentNotes & theSuffix
			on error
				set ohDear to true
			end try
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustSuffixNotes

on adjustSearchReplaceNotes(cuesToProcess, whichCuesString)
	
	tell application id "com.figure53.QLab.4"
		
		set searchFor to my enterSomeText("Enter the search string you wish to replace in the Notes of the " & whichCuesString & " (not case-sensitive):", "", false)
		set replaceWith to my enterSomeText("Enter the string with which wish to replace all occurrences of \"" & Â
			searchFor & "\" in the Notes of the " & whichCuesString & ":", "", true)
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		set currentTIDs to AppleScript's text item delimiters
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			set currentNotes to notes of eachCue
			set AppleScript's text item delimiters to searchFor
			set searchedNotes to text items of currentNotes
			set AppleScript's text item delimiters to replaceWith
			set theNotes to searchedNotes as text
			set AppleScript's text item delimiters to currentTIDs
			try -- This try will throw a detectable error if the next line doesn't work (hard to think of a reason why it wouldn't though!)
				set notes of eachCue to theNotes
			on error
				set ohDear to true
			end try
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustSearchReplaceNotes

on adjustClearFormattingNotes(cuesToProcess, whichCuesString)
	
	tell application id "com.figure53.QLab.4" to tell front workspace
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			try -- This try will throw a detectable error if the next line doesn't work (hard to think of a reason why it wouldn't though!)
				set the notes of eachCue to notes of eachCue
			on error
				set ohDear to true
			end try
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustClearFormattingNotes

on adjustSetTime(cuesToProcess, theParameter, whichCuesString)
	
	-- subChoiceTimesParameter = {"Pre Wait", "Duration", "Post Wait"}
	
	tell application id "com.figure53.QLab.4"
		
		if theParameter is item 3 of subChoiceTimesParameter then -- Special option to set Post Waits to the same time as the Duration
			set specialCase to "Set to Duration"
		else
			set specialCase to {}
		end if
		
		set thetime to my enterATimeWithCustomButton("Enter the time you wish to set as the " & theParameter & Â
			" for the " & whichCuesString & " (seconds or minutes:seconds):", "", specialCase)
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			try -- This try will throw a detectable error if the appropriate line doesn't work
				if theParameter is item 1 of subChoiceTimesParameter then
					set pre wait of eachCue to thetime
				else if theParameter is item 2 of subChoiceTimesParameter then
					set duration of eachCue to thetime
				else if theParameter is item 3 of subChoiceTimesParameter then
					if thetime is specialCase then
						set theDuration to duration of eachCue
						set post wait of eachCue to theDuration
					else
						set post wait of eachCue to thetime
					end if
				end if
			on error
				set ohDear to true
			end try
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustSetTime

on adjustScaleTime(cuesToProcess, theParameter, whichCuesString)
	
	-- subChoiceTimesParameter = {"Pre Wait", "Duration", "Post Wait"}
	
	tell application id "com.figure53.QLab.4"
		
		set theMultiplicand to my enterARatio("Enter the ratio with which you wish to scale the " & theParameter & Â
			" for the " & whichCuesString & " (eg: 1.1 will make them 10% longer):", "")
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			try -- This try will throw a detectable error if the appropriate line doesn't work
				if theParameter is item 1 of subChoiceTimesParameter then
					set currentTime to pre wait of eachCue
					set pre wait of eachCue to currentTime * theMultiplicand
				else if theParameter is item 2 of subChoiceTimesParameter then
					set currentTime to duration of eachCue
					set duration of eachCue to currentTime * theMultiplicand
				else if theParameter is item 3 of subChoiceTimesParameter then
					set currentTime to post wait of eachCue
					set post wait of eachCue to currentTime * theMultiplicand
				end if
			on error
				set ohDear to true
			end try
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustScaleTime

on adjustAddSubractTime(cuesToProcess, theParameter, whichCuesString)
	
	-- subChoiceTimesParameter = {"Pre Wait", "Duration", "Post Wait"}
	
	tell application id "com.figure53.QLab.4"
		
		set theAddend to my enterANumber("Enter the number of seconds you wish to add to " & theParameter & " for the " & whichCuesString & ":", "")
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			try -- This try will throw a detectable error if the appropriate line doesn't work
				if theParameter is item 1 of subChoiceTimesParameter then
					set currentTime to pre wait of eachCue
					set pre wait of eachCue to currentTime + theAddend
				else if theParameter is item 2 of subChoiceTimesParameter then
					set currentTime to duration of eachCue
					set duration of eachCue to currentTime + theAddend
				else if theParameter is item 3 of subChoiceTimesParameter then
					set currentTime to post wait of eachCue
					set post wait of eachCue to currentTime + theAddend
				end if
			on error
				set ohDear to true
			end try
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustAddSubractTime

on adjustSetMIDICommand(cuesToProcess, whichCuesString)
	
	tell application id "com.figure53.QLab.4"
		
		set theParameter to my pickFromList(subChoiceMIDICommand, "Set the MIDI Command of the selected cues to:")
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			try -- Skip over cues that don't take MIDI!
				if message type of eachCue is not voice then -- This will throw an error if eachCue isn't a MIDI Cue
					error -- This rejects MSC & SysEx cues
				end if
				try -- This try will throw a detectable error if the appropriate line doesn't work
					if theParameter is item 1 of subChoiceMIDICommand then
						set command of eachCue to note_on
					else if theParameter is item 2 of subChoiceMIDICommand then
						set command of eachCue to note_off
					else if theParameter is item 3 of subChoiceMIDICommand then
						set command of eachCue to program_change
					else if theParameter is item 4 of subChoiceMIDICommand then
						set command of eachCue to control_change
					else if theParameter is item 5 of subChoiceMIDICommand then
						set command of eachCue to key_pressure
					else if theParameter is item 6 of subChoiceMIDICommand then
						set command of eachCue to channel_pressure
					else if theParameter is item 7 of subChoiceMIDICommand then
						set command of eachCue to pitch_bend
					end if
				on error
					set ohDear to true
				end try
			end try
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustSetMIDICommand

on adjustSetMIDI(cuesToProcess, theParameter, whichCuesString) -- This is the only one that handles "Channel"
	
	-- subChoiceMIDIParameter = {"Command", "Channel", "Byte One", "Byte Two", "Byte Combo", "End Value"}
	
	tell application id "com.figure53.QLab.4"
		
		if theParameter is item 2 of subChoiceMIDIParameter then
			set theMin to 1
			set theMax to 16
		else if theParameter is item 5 of subChoiceMIDIParameter then
			set theMin to -8192
			set theMax to 8191
		else
			set theMin to 0
			set theMax to 127
		end if
		
		set theInteger to my enterANumberWithRangeWithCustomButton("Enter the value to which you wish to set the " & theParameter & Â
			" for the " & whichCuesString & ":", "", theMin, true, theMax, true, true, {}, "OK")
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			try -- Skip over cues that don't take MIDI!
				if message type of eachCue is not voice then -- This will throw an error if eachCue isn't a MIDI Cue
					error -- This rejects MSC & SysEx cues
				end if
				try -- This try will throw a detectable error if the appropriate line doesn't work
					if theParameter is item 2 of subChoiceMIDIParameter then
						set channel of eachCue to theInteger
					else if theParameter is item 3 of subChoiceMIDIParameter then
						if command of eachCue is not pitch_bend then
							set byte one of eachCue to theInteger
						end if
					else if theParameter is item 4 of subChoiceMIDIParameter then
						if command of eachCue is not pitch_bend then
							set byte two of eachCue to theInteger
						end if
					else if theParameter is item 5 of subChoiceMIDIParameter then
						if command of eachCue is pitch_bend then
							set byte combo of eachCue to theInteger + 8192 -- Pitch bend of 0 in the Inspector is reported to AppleScript as 8192
						end if
					else if theParameter is item 6 of subChoiceMIDIParameter then
						if command of eachCue is not pitch_bend then
							set end value of eachCue to theInteger
						else
							set end value of eachCue to theInteger + 8192
						end if
					end if
				on error
					set ohDear to true
				end try
			end try
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustSetMIDI

on adjustScaleMIDI(cuesToProcess, theParameter, whichCuesString)
	
	-- subChoiceMIDIParameter = {"Command", "Channel", "Byte One", "Byte Two", "Byte Combo", "End Value"}
	
	tell application id "com.figure53.QLab.4"
		
		set theMultiplicand to my enterARatio("Enter the ratio with which you wish to scale the " & theParameter & Â
			" for the " & whichCuesString & " (eg: 1.1 will make them 10% larger):", "")
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			try -- Skip over cues that don't take MIDI!
				if message type of eachCue is not voice then -- This will throw an error if eachCue isn't a MIDI Cue
					error -- This rejects MSC & SysEx cues
				end if
				try -- This try will throw a detectable error if the appropriate line doesn't work
					if theParameter is item 3 of subChoiceMIDIParameter then
						if command of eachCue is not pitch_bend then
							set currentValue to byte one of eachCue
							set byte one of eachCue to currentValue * theMultiplicand
						end if
					else if theParameter is item 4 of subChoiceMIDIParameter then
						if command of eachCue is not pitch_bend then
							set currentValue to byte two of eachCue
							set byte two of eachCue to currentValue * theMultiplicand
						end if
					else if theParameter is item 5 of subChoiceMIDIParameter then
						if command of eachCue is pitch_bend then
							set currentValue to (byte combo of eachCue) - 8192
							set byte combo of eachCue to currentValue * theMultiplicand + 8192
						end if
					else if theParameter is item 6 of subChoiceMIDIParameter then
						if command of eachCue is not pitch_bend then
							set currentValue to end value of eachCue
							set end value of eachCue to currentValue * theMultiplicand
						else
							set currentValue to ((end value of eachCue) - 8192)
							set end value of eachCue to (currentValue * theMultiplicand) + 8192
						end if
					end if
				on error
					set ohDear to true
				end try
			end try
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustScaleMIDI

on adjustAddSubractMIDI(cuesToProcess, theParameter, whichCuesString)
	
	-- subChoiceMIDIParameter = {"Command", "Channel", "Byte One", "Byte Two", "Byte Combo", "End Value"}
	
	tell application id "com.figure53.QLab.4"
		
		set theAddend to my enterAnInteger("Enter the integer you wish to add to " & theParameter & " for the " & whichCuesString & ":", "")
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			try -- Skip over cues that don't take MIDI!
				if message type of eachCue is not voice then -- This will throw an error if eachCue isn't a MIDI Cue
					error -- This rejects MSC & SysEx cues
				end if
				try -- This try will throw a detectable error if the appropriate line doesn't work
					if theParameter is item 3 of subChoiceMIDIParameter then
						set currentValue to byte one of eachCue
						set byte one of eachCue to currentValue + theAddend
					else if theParameter is item 4 of subChoiceMIDIParameter then
						set currentValue to byte two of eachCue
						set byte two of eachCue to currentValue + theAddend
					else if theParameter is item 5 of subChoiceMIDIParameter then
						set currentValue to byte combo of eachCue
						set byte combo of eachCue to currentValue + theAddend
					else if theParameter is item 6 of subChoiceMIDIParameter then
						set currentValue to end value of eachCue
						set end value of eachCue to currentValue + theAddend
					end if
				on error
					set ohDear to true
				end try
			end try
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustAddSubractMIDI

on adjustSeriesMIDI(cuesToProcess, theParameter, whichCuesString)
	
	-- subChoiceMIDIParameter = {"Command", "Channel", "Byte One", "Byte Two", "Byte Combo", "End Value"}
	
	tell application id "com.figure53.QLab.4"
		
		if theParameter is item 5 of subChoiceMIDIParameter then
			set theMin to -8192
			set theMax to 8191
		else
			set theMin to 0
			set theMax to 127
		end if
		
		set startNumber to my enterANumberWithRangeWithCustomButton("Enter the value to which you wish to set the " & theParameter & Â
			" of the first of the " & whichCuesString & ":", "", theMin, true, theMax, true, true, {}, "OK")
		set theIncrement to my enterAnInteger("Enter the increment for each step:", "")
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			set theCounter to startNumber + (i - 1) * theIncrement -- We're relying on QLab to hit a ceiling/floor for this
			try -- Skip over cues that don't take MIDI!
				if message type of eachCue is not voice then -- This will throw an error if eachCue isn't a MIDI Cue
					error -- This rejects MSC & SysEx cues
				end if
				try -- This try will throw a detectable error if the appropriate line doesn't work
					if theParameter is item 2 of subChoiceMIDIParameter then
						set channel of eachCue to theCounter
					else if theParameter is item 3 of subChoiceMIDIParameter then
						if command of eachCue is not pitch_bend then
							set byte one of eachCue to theCounter
						end if
					else if theParameter is item 4 of subChoiceMIDIParameter then
						if command of eachCue is not pitch_bend then
							set byte two of eachCue to theCounter
						end if
					else if theParameter is item 5 of subChoiceMIDIParameter then
						if command of eachCue is pitch_bend then
							set byte combo of eachCue to theCounter + 8192 -- Pitch bend of 0 in the Inspector is reported to AppleScript as 8192
						end if
					else if theParameter is item 6 of subChoiceMIDIParameter then
						if command of eachCue is not pitch_bend then
							set end value of eachCue to theCounter
						else
							set end value of eachCue to theCounter + 8192
						end if
					end if
				on error
					set ohDear to true
				end try
			end try
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustSeriesMIDI

on adjustDeviceID(cuesToProcess, whichCuesString)
	
	tell application id "com.figure53.QLab.4"
		
		set theParameter to my enterANumberWithRangeWithCustomButton("Enter the MSC Device ID you wish to set for the " & whichCuesString & Â
			" (an integer from 0 to 127):", "", 0, true, 127, true, true, {}, "OK")
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			if message type of eachCue is msc then
				try -- This try will throw a detectable error if the appropriate line doesn't work (hard to think of a reason why it wouldn't though!)
					set deviceID of eachCue to theParameter
				on error
					set ohDear to true
				end try
			end if
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustDeviceID

on adjustAutoload(cuesToProcess, theParameter, whichCuesString)
	
	-- subChoiceAutoload = {"On", "Off"}
	
	tell application id "com.figure53.QLab.4"
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			try -- This try will throw a detectable error if the appropriate line doesn't work (hard to think of a reason why it wouldn't though!)
				if theParameter is item 1 of subChoiceAutoload then
					set autoload of eachCue to true
				else if theParameter is item 2 of subChoiceAutoload then
					set autoload of eachCue to false
				end if
			on error
				set ohDear to true
			end try
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustAutoload

on adjustArmed(cuesToProcess, theParameter, whichCuesString)
	
	-- subChoiceArmed = {"Armed", "Disarmed"}
	
	tell application id "com.figure53.QLab.4"
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			try -- This try will throw a detectable error if the appropriate line doesn't work (hard to think of a reason why it wouldn't though!)
				if theParameter is item 1 of subChoiceArmed then
					set armed of eachCue to true
				else if theParameter is item 2 of subChoiceArmed then
					set armed of eachCue to false
				end if
			on error
				set ohDear to true
			end try
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustArmed

on adjustContinueMode(cuesToProcess, theParameter, whichCuesString)
	
	-- subChoiceContinueMode = {"Do not continue", "Auto-continue", "Auto-follow"}
	
	tell application id "com.figure53.QLab.4"
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			try -- This try will throw a detectable error if the appropriate line doesn't work (hard to think of a reason why it wouldn't though!)
				if theParameter is item 1 of subChoiceContinueMode then
					set continue mode of eachCue to do_not_continue
				else if theParameter is item 2 of subChoiceContinueMode then
					set continue mode of eachCue to auto_continue
				else if theParameter is item 3 of subChoiceContinueMode then
					set continue mode of eachCue to auto_follow
				end if
			on error
				set ohDear to true
			end try
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustContinueMode

on adjustMode(cuesToProcess, theParameter, whichCuesString)
	
	-- subChoiceMode = {"Timeline - Start all children simultaneously","Start first child and enter into group", "Start first child and go to next cue" ,
	(* "Start random child and go to next cue"} *)
	
	tell application id "com.figure53.QLab.4"
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			try -- Skip over cues that aren't Groups
				if mode of eachCue is not cue_list then -- Don't adjust cue lists!
					try -- This try will throw a detectable error if the appropriate line doesn't work
						if theParameter is item 1 of subChoiceMode then
							set mode of eachCue to timeline
						else if theParameter is item 2 of subChoiceMode then
							set mode of eachCue to fire_first_enter_group
						else if theParameter is item 3 of subChoiceMode then
							set mode of eachCue to fire_first_go_to_next_cue
						else if theParameter is item 4 of subChoiceMode then
							set mode of eachCue to fire_random
						end if
					on error
						set ohDear to true
					end try
				end if
			end try
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustMode

on adjustPatch(cuesToProcess, whichCuesString)
	
	tell application id "com.figure53.QLab.4"
		
		set theParameter to my enterANumberWithRangeWithCustomButton("Enter the patch you wish to set for the " & whichCuesString & Â
			" (1-8, 1-16 for Network Cues):", "", 1, true, false, false, true, {}, "OK")
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			if q type of eachCue is in {"Audio", "Mic", "Video", "Network", "MIDI", "MIDI File", "Timecode"} then
				try -- This try will throw a detectable error if the appropriate line doesn't work (hard to think of a reason why it wouldn't though!)
					set patch of eachCue to theParameter
				on error
					set ohDear to true
				end try
			end if
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustPatch

on adjustCameraPatch(cuesToProcess, theParameter, whichCuesString)
	
	-- subChoiceCameraPatch = {1, 2, 3, 4, 5, 6, 7, 8}
	
	tell application id "com.figure53.QLab.4"
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			if q type of eachCue is "Camera" then
				try -- This try will throw a detectable error if the appropriate line doesn't work (hard to think of a reason why it wouldn't though!)
					set camera patch of eachCue to theParameter
				on error
					set ohDear to true
				end try
			end if
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustCameraPatch

on adjustSearchReplaceCommandText(cuesToProcess, whichCuesString, instrumentNamesONLY)
	
	tell application id "com.figure53.QLab.4"
		
		if instrumentNamesONLY is true then
			set searchFor to my enterSomeText("Enter the search string you wish to replace in the Instrument Names in the Command Text of the " & Â
				whichCuesString & " (not case-sensitive):", "", false)
			set replaceWith to my enterSomeText("Enter the string with which wish to replace all occurrences of \"" & Â
				searchFor & "\" in Instrument Names in the the Command Text of the " & whichCuesString & ":", "", true)
			set searchFor to searchFor & " = "
			set replaceWith to replaceWith & " = "
		else
			set searchFor to my enterSomeText("Enter the search string you wish to replace in the Command Text of the " & whichCuesString & Â
				" (not case-sensitive):", "", false)
			set replaceWith to my enterSomeText("Enter the string with which wish to replace all occurrences of \"" & Â
				searchFor & "\" in the Command Text of the " & whichCuesString & ":", "", true)
		end if
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		set currentTIDs to AppleScript's text item delimiters
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			if q type of eachCue is "Light" then
				try -- This try will throw a detectable error if something doesn't work
					set currentCommandText to command text of eachCue
					if currentCommandText is not missing value then -- Skip cues that are empty
						set AppleScript's text item delimiters to searchFor
						set searchedCommandText to text items of currentCommandText
						set AppleScript's text item delimiters to replaceWith
						set theCommandText to searchedCommandText as text
						set AppleScript's text item delimiters to currentTIDs
						set command text of eachCue to theCommandText
					end if
				on error
					set ohDear to true
				end try
			end if
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustSearchReplaceCommandText

on adjustSetOSCMessage(cuesToProcess, whichCuesString)
	
	tell application id "com.figure53.QLab.4"
		
		set theOSCMessage to my enterSomeText("Enter the OSC message you wish to set for the " & whichCuesString & Â
			" (return an empty string to reset to default names):", "", true)
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			if q type of eachCue is "Network" then
				try -- This try will throw a detectable error if the next line doesn't work (hard to think of a reason why it wouldn't though!)
					set custom message of eachCue to theOSCMessage
				on error
					set ohDear to true
				end try
			end if
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustSetOSCMessage

on adjustPrefixOSCMessage(cuesToProcess, whichCuesString)
	
	tell application id "com.figure53.QLab.4"
		
		set thePrefix to my enterSomeText("Enter the string you wish to add to the beginning of the OSC Messages of the " & whichCuesString & Â
			" (include a space at the end if you expect one):", "", false)
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			if q type of eachCue is "Network" then
				set currentOSCMessage to custom message of eachCue
				try -- This try will throw a detectable error if the next line doesn't work (hard to think of a reason why it wouldn't though!)
					set custom message of eachCue to thePrefix & currentOSCMessage
				on error
					set ohDear to true
				end try
			end if
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustPrefixOSCMessage

on adjustSuffixOSCMessage(cuesToProcess, whichCuesString)
	
	tell application id "com.figure53.QLab.4"
		
		set theSuffix to my enterSomeText("Enter the string you wish to add to the end of the OSC Messages of the " & whichCuesString & Â
			" (include a space at the beginning if you expect one):", "", false)
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			if q type of eachCue is "Network" then
				set currentOSCMessage to custom message of eachCue
				try -- This try will throw a detectable error if the next line doesn't work (hard to think of a reason why it wouldn't though!)
					set custom message of eachCue to currentOSCMessage & theSuffix
				on error
					set ohDear to true
				end try
			end if
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustSuffixOSCMessage

on adjustSearchReplaceOSCMessage(cuesToProcess, whichCuesString)
	
	tell application id "com.figure53.QLab.4"
		
		set searchFor to my enterSomeText("Enter the search string you wish to replace in the OSC Messages of the " & whichCuesString & " (not case-sensitive):", Â
			"", false)
		set replaceWith to my enterSomeText("Enter the string with which you wish to replace all occurrences of \"" & Â
			searchFor & "\" in the theOSC to custom message of eachcue of the " & whichCuesString & ":", "", true)
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		set currentTIDs to AppleScript's text item delimiters
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			if q type of eachCue is "Network" then
				set theOSC to custom message of eachCue
				set AppleScript's text item delimiters to searchFor
				set the item_list to every text item of theOSC
				set AppleScript's text item delimiters to replaceWith
				set custom message of eachCue to the item_list as string
				set AppleScript's text item delimiters to currentTIDs
				try -- This try will throw a detectable error if the next line doesn't work (hard to think of a reason why it wouldn't though!)
				on error
					set ohDear to true
				end try
			end if
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustSearchReplaceOSCMessage

on adjustSeriesOSCMessage(cuesToProcess, whichCuesString) -- ###Counts cues regardless of cue types###
	
	tell application id "com.figure53.QLab.4"
		
		set validEntry to false
		set previousBaseOSCMessage to ""
		set previousStartOSCMessage to ""
		set previousIncrement to ""
		set previousPadding to ""
		repeat until validEntry is true
			set baseOSCMessage to my enterSomeText("Enter the base of the name series you wish to set for the " & whichCuesString & Â
				" (include a space at the end if you expect one):", previousBaseOSCMessage, false)
			set startOSCMessage to my enterAnInteger("Enter an integer with which to start the series:", previousStartOSCMessage)
			set theIncrement to my enterAnInteger("Enter the increment for each step (an integer):", previousIncrement)
			set thePadding to my enterANumberWithRangeWithCustomButton("Enter the minimum number of digits Ð an integer between 1 & 10 " & Â
				"(eg: entering 2 will result in the series 01, 02, etc):", previousPadding, 1, true, 10, true, true, {}, "OK")
			set previousBaseOSCMessage to baseOSCMessage
			set previousStartOSCMessage to startOSCMessage
			set previousIncrement to theIncrement
			set previousPadding to thePadding
			set counterConfirm1 to my padNumber(startOSCMessage, thePadding)
			set pleaseConfirm1 to "> " & baseOSCMessage & counterConfirm1
			set counterConfirm2 to my padNumber(startOSCMessage + theIncrement, thePadding)
			set pleaseConfirm2 to "> " & baseOSCMessage & counterConfirm2
			set counterConfirm3 to my padNumber(startOSCMessage + 2 * theIncrement, thePadding)
			set pleaseConfirm3 to "> " & baseOSCMessage & counterConfirm3
			set pleaseConfirm to pleaseConfirm1 & return & pleaseConfirm2 & return & pleaseConfirm3 & return & "> É"
			set goBack to button returned of (display dialog "Please confirm you wish to set the names as a series of this ilk for the " & whichCuesString & Â
				":" & return & return & pleaseConfirm with title dialogTitle with icon 0 buttons {"Cancel", "No, no! Stop! That's not right! Go back!", "OK"} Â
				default button "OK" cancel button "Cancel")
			if goBack is "OK" then
				set validEntry to true
			end if
		end repeat
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			if q type of eachCue is "Network" then
				set theCounter to startOSCMessage + (i - 1) * theIncrement
				set theCounter to my padNumber(theCounter, thePadding)
				set theOSCMessage to baseOSCMessage & theCounter
				try -- This try will throw a detectable error if the next line doesn't work (hard to think of a reason why it wouldn't though!)
					set custom message of eachCue to theOSCMessage
				on error
					set ohDear to true
				end try
			end if
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustSeriesOSCMessage

on adjustSearchReplaceScript(cuesToProcess, whichCuesString)
	
	tell application id "com.figure53.QLab.4"
		
		set searchFor to my enterSomeText("Enter the search string you wish to replace in the Script of the " & whichCuesString & " (not case-sensitive):", Â
			"", false)
		set replaceWith to my enterSomeText("Enter the string with which you wish to replace all occurrences of \"" & Â
			searchFor & "\" in the theScript to script source of eachcue of the " & whichCuesString & ":", "", true)
		
		my startTheClock()
		
		set countCues to count cuesToProcess
		set currentTIDs to AppleScript's text item delimiters
		
		repeat with i from 1 to countCues
			set eachCue to item i of cuesToProcess
			if q type of eachCue is "Script" then
				set theScript to script source of eachCue
				set AppleScript's text item delimiters to searchFor
				set the item_list to every text item of theScript
				set AppleScript's text item delimiters to replaceWith
				set script source of eachCue to the item_list as string
				set AppleScript's text item delimiters to currentTIDs
				try -- This try will throw a detectable error if the next line doesn't work (hard to think of a reason why it wouldn't though!)
				on error
					set ohDear to true
				end try
			end if
			if i mod userEscapeHatchInterval is 0 and (countCues - i) > userEscapeHatchInterval / 2 then -- Countdown timer (and opportunity to escape)
				my countdownTimer(i, countCues, whichCuesString)
			end if
		end repeat
		
		my finishedDialogBespoke()
		
	end tell
	
end adjustSearchReplaceScript

(* === WRITING DATA === *)

on qlab_data(this_data)
	try
		do shell script "touch private/tmp/qlab_data.txt"
		set the target_file to "private/tmp/qlab_data.txt" as POSIX file
		set the open_target_file to Â
			open for access file target_file with write permission
		set eof of the open_target_file to 0
		write this_data as Çclass utf8È to the open_target_file starting at eof
		close access the open_target_file
		return true
	on error
		try
			close access file target_file
		end try
		return false
		display dialog this_data
	end try
end qlab_data

(* === TIME === *)

on makeMSS(howLong) -- [Shared subroutine]
	set howManyMinutes to howLong div 60
	set howManySeconds to howLong mod 60 div 1
	return (howManyMinutes as text) & ":" & my padNumber(howManySeconds, 2)
end makeMSS

on makeNiceT(howLong) -- [Shared subroutine]
	if howLong < 1 then
		return "less than a second"
	end if
	set howManyHours to howLong div 3600
	if howManyHours is 0 then
		set hourString to ""
	else if howManyHours is 1 then
		set hourString to "1 hour"
	else
		set hourString to (howManyHours as text) & " hours"
	end if
	set howManyMinutes to howLong mod 3600 div 60
	if howManyMinutes is 0 then
		set minuteString to ""
	else if howManyMinutes is 1 then
		set minuteString to "1 minute"
	else
		set minuteString to (howManyMinutes as text) & " minutes"
	end if
	set howManySeconds to howLong mod 60 div 1
	if howManySeconds is 0 then
		set secondString to ""
	else if howManySeconds is 1 then
		set secondString to "1 second"
	else
		set secondString to (howManySeconds as text) & " seconds"
	end if
	set theAmpersand to ""
	if hourString is not "" then
		if minuteString is not "" and secondString is not "" then
			set theAmpersand to ", "
		else if minuteString is not "" or secondString is not "" then
			set theAmpersand to " and "
		end if
	end if
	set theOtherAmpersand to ""
	if minuteString is not "" and secondString is not "" then
		set theOtherAmpersand to " and "
	end if
	return hourString & theAmpersand & minuteString & theOtherAmpersand & secondString
end makeNiceT

on makeSecondsFromM_S(howLong) -- [Shared subroutine]
	try
		set currentTIDs to AppleScript's text item delimiters
		set AppleScript's text item delimiters to ":"
		set theMinutes to first text item of howLong
		set theSeconds to rest of text items of howLong as text
		set AppleScript's text item delimiters to currentTIDs
		return theMinutes * 60 + theSeconds
	on error
		return false
	end try
end makeSecondsFromM_S

(* === TEXT WRANGLING === *)

on padNumber(theNumber, minimumDigits) -- [Shared subroutine]
	set paddedNumber to theNumber as text
	repeat while (count paddedNumber) < minimumDigits
		set paddedNumber to "0" & paddedNumber
	end repeat
	return paddedNumber
end padNumber