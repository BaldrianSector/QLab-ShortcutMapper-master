tell application id "com.figure53.qlab.4"
	try
		display dialog "Use + and - to add or subtract, or no sign to set rate value explicitly." default answer "1" with title "Set/Change Rate" buttons {"Cancel", "OK"} default button "OK" cancel button "Cancel"
		
		set changeAmount to text returned of result
		
		repeat with eachCue in (selected of front workspace as list)
			set currentRate to rate of eachCue
			if changeAmount starts with "+" then
				set rate of eachCue to (currentRate + changeAmount)
			else if changeAmount starts with "-" then
				set rate of eachCue to (currentRate + changeAmount)
			else if changeAmount starts with "*" then
				set rate of eachCue to text 2 thru end of changeAmount as real
			else
				set rate of eachCue to changeAmount
			end if
		end repeat
	end try
end tell