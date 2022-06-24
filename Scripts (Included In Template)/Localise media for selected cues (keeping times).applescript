-- QLab retains slice points within the duration of a new File Target but resets the start & end times (this script maintains start & end times)

-- Declarations

global dialogTitle, sharedPath
set dialogTitle to "Localise media"

set foldersExist to {null, null, null}
set theSubfolders to {"audio", "video", "midi file"}
set theCueTypes to {"Audio", "Video", "MIDI File"}

-- Main routine

tell front workspace
	
	-- Establish the path to the current workspace
	
	set workspacePath to path
	if workspacePath is missing value then
		display dialog "The current workspace has not yet been saved anywhere." with title dialogTitle with icon 0 Â
			buttons {"OK"} default button "OK" giving up after 5
		return
	end if
	
	-- Get the path that should prefix all media file paths
	
	tell application "System Events"
		set sharedPath to path of container of file workspacePath
	end tell
	
	-- Work through the selected cues
	
	display dialog "One moment callerÉ" with title dialogTitle with icon 1 buttons {"OK"} default button "OK" giving up after 1
	
	repeat with eachCue in (selected as list)
		
		set eachType to q type of eachCue
		
		if eachType is in theCueTypes then
			
			-- Identify which item of the declared lists to use
			
			repeat with i from 1 to 3
				if eachType is item i of theCueTypes then
					set eachIndice to i
					set eachSubfolder to item eachIndice of theSubfolders
					exit repeat
				end if
			end repeat
			
			-- Get the existing target (the try protects against missing File Targets)
			
			try
				
				set eachFile to file target of eachCue as alias
				tell application "System Events"
					set eachName to name of eachFile
				end tell
				
				-- Check for appropriate subfolder next to workspace and make it if it doesn't exist
				
				if item eachIndice of foldersExist is null then
					set item eachIndice of foldersExist to my checkForFolder(eachSubfolder)
					if item eachIndice of foldersExist is false then
						my makeFolder(eachSubfolder)
					end if
				end if
				
				-- If the file is not already in place, copy it to the appropriate subfolder
				
				if my checkForFile(eachSubfolder, eachName) is false then
					my copyFile(eachSubfolder, eachFile, eachName)
				end if
				
				-- Record the new file location
				
				set eachNewTarget to sharedPath & eachSubfolder & ":" & eachName
				
				-- Replace the targets (keeping the times)
				
				if eachType is not "MIDI File" then
					set currentStart to start time of eachCue
					set currentEnd to end time of eachCue
				end if
				
				set file target of eachCue to eachNewTarget
				
				if eachType is not "MIDI File" then
					set start time of eachCue to currentStart
					set end time of eachCue to currentEnd
				end if
				
			end try
			
		end if
		
	end repeat
	
	display dialog "Done." with title dialogTitle with icon 1 buttons {"OK"} default button "OK" giving up after 5
	
end tell

-- Subroutines

(* === FILE WRANGLING === *)

on checkForFile(theSuffix, theName) -- [Shared subroutine]
	tell application "System Events"
		return exists file (sharedPath & theSuffix & ":" & theName)
	end tell
end checkForFile

on checkForFolder(theSuffix) -- [Shared subroutine]
	tell application "System Events"
		return exists folder (sharedPath & theSuffix)
	end tell
end checkForFolder

on makeFolder(theFolder) -- [Shared subroutine]
	tell application "Finder"
		make new folder at sharedPath with properties {name:theFolder}
	end tell
end makeFolder

on copyFile(theSuffix, theFile, theName) -- [Shared subroutine]
	do shell script "cp -p " & quoted form of POSIX path of theFile & " " & quoted form of POSIX path of (sharedPath & theSuffix & ":" & theName)
end copyFile