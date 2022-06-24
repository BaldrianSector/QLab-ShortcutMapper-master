set userDefaultIncrement to 1 -- Use this to specify the default increment between numbers presented in the dialog

-- Declarations

global dialogTitle
set dialogTitle to "Renumber with a prefix"

-- Check the Clipboard for a previous prefix

try
	set clipboardContents to the clipboard as text
on error
	set clipboardContents to ""
end try

if clipboardContents contains return or clipboardContents contains linefeed then -- Slight protection against spurious Clipboard contents
	set clipboardContents to ""
end if

-- Main routine

set startingNumber to enterSomeTextWithIcon("Enter the Cue Number for the first selected cue:", clipboardContents, true)

set thePrefix to startingNumber
set theSuffix to ""
set nonNumberFound to false

repeat with i from (count characters of startingNumber) to 1 by -1
	if character i of startingNumber is not in characters of "0123456789" then
		set nonNumberFound to true
		set thePrefix to (characters 1 thru i of startingNumber) as text
		try -- If the last character is not a number then theSuffix remains as ""
			set theSuffix to (characters (i + 1) thru end of startingNumber) as text
		end try
		exit repeat
	end if
end repeat

if nonNumberFound is false then -- Edge case where the text entered is a number with no prefix
	set thePrefix to ""
	set theSuffix to startingNumber
end if

set theSuffix to theSuffix as integer

set theIncrement to enterANumberWithIcon("Enter the increment:", userDefaultIncrement)

tell front workspace
	
	set selectedCues to (selected as list)
	
	-- Clear existing Cue Numbers
	
	repeat with eachCue in selectedCues
		set q number of eachCue to ""
	end repeat
	
	-- Get a list of numbers that can't be used
	
	set allNumbers to q number of cues
	set allNumbersRef to a reference to allNumbers
	
	-- Renumber the cues
	
	repeat with eachCue in selectedCues
		set newNumber to (thePrefix & theSuffix) as text
		repeat until newNumber is not in allNumbersRef -- If the number is in use, then skip it
			set theSuffix to theSuffix + theIncrement
			set newNumber to (thePrefix & theSuffix) as text
		end repeat
		set q number of eachCue to newNumber
		set theSuffix to theSuffix + theIncrement
	end repeat
	
end tell

-- Copy the prefix to the Clipboard

set the clipboard to startingNumber as text

-- Subroutines

(* === INPUT === *)

on enterANumberWithIcon(thePrompt, defaultAnswer) -- [Shared subroutine]
	tell application id "com.figure53.QLab.4"
		set theQuestion to ""
		repeat until theQuestion is not ""
			set theQuestion to text returned of (display dialog thePrompt with title dialogTitle with icon 1 Â
				default answer defaultAnswer buttons {"Cancel", "OK"} default button "OK" cancel button "Cancel")
			try
				set theAnswer to theQuestion as number
			on error
				set theQuestion to ""
			end try
		end repeat
		return theAnswer
	end tell
end enterANumberWithIcon

on enterSomeTextWithIcon(thePrompt, defaultAnswer, emptyAllowed) -- [Shared subroutine]
	tell application id "com.figure53.QLab.4"
		set theAnswer to ""
		repeat until theAnswer is not ""
			set theAnswer to text returned of (display dialog thePrompt with title dialogTitle with icon 1 Â
				default answer defaultAnswer buttons {"Cancel", "OK"} default button "OK" cancel button "Cancel")
			if emptyAllowed is true then exit repeat
		end repeat
		return theAnswer
	end tell
end enterSomeTextWithIcon