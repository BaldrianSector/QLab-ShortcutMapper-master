tell application id "com.figure53.QLab.4" to tell front workspace
        if (count selected) is greater than 0 then -- Checks of any cues are selected
                set selectedCues to (selected as list)
                set firstCue to first item of selectedCues
                set selected to firstCue -- Moves the selection to the top of the selectedCues
                moveSelectionUp -- Selects the above cue
                set aboveCue to last item of (selected as list)
                if aboveCue is not firstCue then -- Error protection if cue is first cue of cue list
                        if q type of aboveCue is "Group" then -- Checks if cue above selected is a group
                                repeat with eachCue in selectedCues
                                        if parent of eachCue is not aboveCue then -- Prevents moving if already in group
                                                set thecueID to uniqueID of eachCue
                                                move cue id thecueID of parent of eachCue to end of aboveCue -- Sets group cue to parent
                                        end if
                                end repeat
                        else
                                if parent of aboveCue is not parent list of aboveCue then -- Checks if aboveCue is in a group
                                        repeat with eachCue in selectedCues
                                                if parent of eachCue is not parent of aboveCue then -- Prevents moving if already in group
                                                        set thecueID to uniqueID of eachCue
                                                        move cue id thecueID of parent of eachCue to parent of aboveCue -- Sets parent group cue to parent
                                                end if
                                        end repeat
                                end if
                        end if
                end if
                set selected to selectedCues -- Returns played to selectedCues
        end if
end tell