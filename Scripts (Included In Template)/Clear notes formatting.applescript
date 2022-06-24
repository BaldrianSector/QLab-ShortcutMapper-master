tell application id "com.figure53.QLab.4" to tell front workspace
        set selectedCues to (selected as list)
        repeat with eachcue in selectedCues
                set the notes of eachcue to notes of eachcue
        end repeat
end tell