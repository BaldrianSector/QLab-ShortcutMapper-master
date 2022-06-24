-- Best run as a separate process so it can be happening in the background

-- This script can optionally convert note numbers in MIDI Cues to note names: use the variables below to set the behaviour

set userMIDIPatch to false -- Set to false to use QLab default for the cues made, or set to 1-8 for MIDI patch 1-8
set userMinimumTimeBetweenCues to 0.01 -- How long to allow between MIDI Cues when sending clusters (eg: Bank/PC)?
set userHowManyPossible to 1000 -- Limit series with increment of 0 to this many cues!
set userMIDIConversionMode to item 3 of {"Numbers", "Names", "Both"} -- Use this to choose how MIDI note values will be included in cue names
set userNote60Is to item 1 of {"C3", "C4"} -- Use this to set which note name corresponds to note 60

-- Explanations

set theExplanation to "This script will create a series of MIDI Cues which increment the parameter you specify.

For example, you can generate quickly a series of Program Changes for recalling scenes on a mixing desk, " & Â
	"or a series of Note Ons for triggering a sampler or some other device."

-- Declarations

global dialogTitle
set dialogTitle to "Go ahead make MIDI"

global userMIDIConversionMode, noteNames, octaveConvention
set noteNames to {"C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"}
if userNote60Is is "C3" then
	set octaveConvention to -2
else
	set octaveConvention to -1
end if

set kindChoices to {"Note On: fixed note number, incrementing velocity", "Note On: fixed velocity, incrementing note number", Â
	"Control Change: fixed controller number, incrementing value", "Control Change: fixed value, incrementing controller number", "Program Change", Â
	"Bank Select (Coarse) / Program Change, ie: CC00 + Program Change"}
set kindCommands to {"Note On", "Note On", "Control Change", "Control Change", "Program Change", "CC00/PC"}
set kindByteOne to {"fixed", "variable", "fixed", "variable", "variable", "variable"}
set kindByteTwo to {"variable", "fixed", "variable", "fixed", "", ""}
set kindQuestionHeader to {"Making Note On cues with incrementing velocity.", "Making Note On cues with incrementing note number.", Â
	"Making Control Change cues with incrementing value.", "Making Control Change cues with incrementing controller number.", Â
	"Making Program Change cues.", "Making Bank Select (Coarse) / Program Change cues."}
set kindQuestionOne to {"Enter the fixed note number:", "Enter the note number for the first cue:", "Enter the fixed controller number:", Â
	"Enter the controller number for the first cue:", "Enter the Program Change number for the first cue:", Â
	"Enter the combined Bank Select (Coarse) / Program Change number for the first cue (eg: for Bank 2 Program 3 enter 2 * 128 + 3 = 259):"}
set kindQuestionTwo to {"Enter the velocity for the first cue:", "Enter the fixed velocity:", "Enter the value for the first cue:", "Enter the fixed value:", "", ""}
set kindQuestionInc to "Enter the increment:"
set kindQuestionMany to "Enter the number of cues to create (maximum "
set channelChoices to {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16}

-- Find out what we are doing

tell application id "com.figure53.QLab.4" to tell front workspace
	
	if q type of current cue list is "Cart" then return -- This will stop the script if we're in a cart, as it doesn't make sense to continue!
	
	set theKind to my pickFromList(kindChoices, theExplanation & return & return & "Choose which kind of series would you like to make:")
	
	repeat with i from 1 to count kindChoices
		if theKind is item i of kindChoices then
			set commandType to item i of kindCommands
			if commandType is "CC00/PC" then
				set byteOneMax to 127 * 128 + 127
			else
				set byteOneMax to 127
			end if
			set byteOne to item i of kindByteOne
			set byteTwo to item i of kindByteTwo
			set questionHeader to item i of kindQuestionHeader
			set questionOne to item i of kindQuestionOne
			set questionTwo to item i of kindQuestionTwo
			set questionInc to kindQuestionInc
			set questionMany to kindQuestionMany
			exit repeat
		end if
	end repeat
	
	set theChannel to my pickFromList(channelChoices, questionHeader & return & return & "Choose the MIDI channel for the cues:")
	
	set byteOneStart to my enterANumberWithRangeWithCustomButton(questionHeader & return & return & questionOne, "", Â
		0, true, byteOneMax, true, true, {}, "OK")
	set currentByteOne to byteOneStart
	set byteOneIncrement to 0
	
	if byteOne is "variable" then
		set byteOneIncrement to my enterANumberWithRangeWithCustomButton(questionHeader & return & return & questionInc, "", Â
			-byteOneStart, true, (byteOneMax - byteOneStart), true, true, {}, "OK")
		if byteOneIncrement < 0 then
			set howManyPossible to 1 - (round (byteOneStart / byteOneIncrement) rounding up)
		else if byteOneIncrement > 0 then
			set howManyPossible to 1 + (round ((byteOneMax - byteOneStart) / byteOneIncrement) rounding down)
		else
			set howManyPossible to userHowManyPossible
		end if
	end if
	
	if byteTwo is not "" then
		set byteTwoStart to my enterANumberWithRangeWithCustomButton(questionHeader & return & return & questionTwo, "", Â
			0, true, 127, true, true, {}, "OK")
	else
		set byteTwoStart to 0
	end if
	set currentByteTwo to byteTwoStart
	set byteTwoIncrement to 0
	
	if byteTwo is "variable" then
		set byteTwoIncrement to my enterANumberWithRangeWithCustomButton(questionHeader & return & return & questionInc, "", Â
			-byteTwoStart, true, (127 - byteTwoStart), true, true, {}, "OK")
		if byteTwoIncrement < 0 then
			set howManyPossible to 1 - (round (byteTwoStart / byteTwoIncrement) rounding up)
		else if byteTwoIncrement > 0 then
			set howManyPossible to 1 + (round ((127 - byteTwoStart) / byteTwoIncrement) rounding down)
		else
			set howManyPossible to userHowManyPossible
		end if
	end if
	
	set howMany to my enterANumberWithRangeWithCustomButton(questionHeader & return & return & questionMany & howManyPossible & "):", "", Â
		1, true, howManyPossible, true, true, {}, "OK")
	
	set customNaming to text returned of (display dialog questionHeader & return & return & Â
		"Enter a base string for naming the cues, or press return to use the default naming option:" with title Â
		dialogTitle default answer "" buttons {"Cancel", "OK"} default button "OK" cancel button "Cancel")
	if customNaming is not "" then
		if customNaming does not end with " " and (byteOneIncrement is not 0 or byteTwoIncrement is not 0) then
			set customNaming to customNaming & " "
		end if
	end if
	
	-- Do it
	
	display dialog "One moment callerÉ" with title dialogTitle with icon 1 buttons {"OK"} default button "OK" giving up after 1
	
	if commandType is not "CC00/PC" then
		
		set theCommand to commandType
		
		repeat howMany times
			
			make type "MIDI"
			set newCue to last item of (selected as list)
			if userMIDIPatch is not false then
				set patch of newCue to userMIDIPatch
			end if
			set channel of newCue to theChannel
			set byte one of newCue to currentByteOne
			set nameString to "Channel " & theChannel & " | " & theCommand & " | "
			if theCommand is "Note On" then
				set command of newCue to note_on
				set byte two of newCue to currentByteTwo
				set nameString to nameString & my convertMIDINoteValues(currentByteOne, currentByteTwo)
			else if theCommand is "Control Change" then
				set command of newCue to control_change
				set byte two of newCue to currentByteTwo
				set nameString to nameString & currentByteOne & " @ " & currentByteTwo
			else if theCommand is "Program Change" then
				set command of newCue to program_change
				set nameString to nameString & currentByteOne
			end if
			if customNaming is "" then
				set q name of newCue to nameString
			else if byteOneIncrement is not 0 then
				set q name of newCue to customNaming & currentByteOne
			else if byteTwoIncrement is not 0 then
				set q name of newCue to customNaming & currentByteTwo
			else
				set q name of newCue to customNaming
			end if
			set currentByteOne to currentByteOne + byteOneIncrement
			set currentByteTwo to currentByteTwo + byteTwoIncrement
			
		end repeat
		
	else
		
		repeat howMany times
			
			set currentBank to currentByteOne div 128
			set currentProgram to currentByteOne mod 128
			
			make type "Group"
			set groupCue to last item of (selected as list)
			set mode of groupCue to timeline
			
			make type "MIDI"
			set newCue to last item of (selected as list)
			if userMIDIPatch is not false then
				set patch of newCue to userMIDIPatch
			end if
			set channel of newCue to theChannel
			set command of newCue to control_change
			set byte one of newCue to 0
			set byte two of newCue to currentBank
			set q name of newCue to "Channel " & theChannel & " | Control Change | 0 @ " & currentBank
			set newCueID to uniqueID of newCue
			move cue id newCueID of parent of newCue to end of groupCue
			
			make type "MIDI"
			set newCue to last item of (selected as list)
			if userMIDIPatch is not false then
				set patch of newCue to userMIDIPatch
			end if
			set channel of newCue to theChannel
			set command of newCue to program_change
			set byte one of newCue to currentProgram
			set q name of newCue to "Channel " & theChannel & " | Program Change | " & currentProgram
			set newCueID to uniqueID of newCue
			move cue id newCueID of parent of newCue to end of groupCue
			set pre wait of newCue to userMinimumTimeBetweenCues
			
			if customNaming is "" then
				set q name of groupCue to "Channel " & theChannel & Â
					" | Bank | " & currentBank & " | Program Change | " & currentProgram & " | Combined value: " & currentByteOne
			else if byteOneIncrement is not 0 then
				set q name of groupCue to customNaming & currentByteOne
			else
				set q name of groupCue to customNaming
			end if
			
			set currentByteOne to currentByteOne + byteOneIncrement
			
		end repeat
		
	end if
	
	display dialog "Done." with title dialogTitle with icon 1 buttons {"OK"} default button "OK" giving up after 60
	
end tell

-- Subroutines

(* === INPUT === *)

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

(* === TEXT WRANGLING === *)

on configureNoteNameString(noteNumber) -- [Shared subroutine]
	set theOctave to (noteNumber div 12) + octaveConvention
	set theNote to item (noteNumber mod 12 + 1) of noteNames
	set noteNameString to theNote & theOctave
	return noteNameString
end configureNoteNameString

on convertMIDINoteValues(noteNumber, noteVelocity) -- [Shared subroutine]
	if userMIDIConversionMode is "Numbers" then
		return noteNumber & " @ " & noteVelocity
	else if userMIDIConversionMode is "Names" then
		return my configureNoteNameString(noteNumber) & " @ " & noteVelocity
	else if userMIDIConversionMode is "Both" then
		return noteNumber & " @ " & noteVelocity & " | " & my configureNoteNameString(noteNumber)
	end if
end convertMIDINoteValues