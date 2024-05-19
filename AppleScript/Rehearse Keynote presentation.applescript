use AppleScript version "2.4" -- Yosemite (10.10) or later
use framework "Foundation"
use scripting additions

global filemanager
global NSNotFound
global theLogFilePath
global theLogFileHandle
global maxLogFileSize
global theKeynoteDoc
global theLastSlideNumber
global theLastClickTime
global theLastBreakTime
global theStartTime
global isQuitting
global theTotalDurationOfBreaks
global theDurationDuringLastBreak
global theLogResults
global theLogFilePosition

on stringFromDate(dateObj)
	set formatter to current application's NSDateFormatter's alloc()'s init()
	formatter's setDateFormat:"dd-MM-YYYY HH:mm:ss"
	set usLocale to current application's NSLocale's alloc()'s initWithLocaleIdentifier:"en_US_POSIX"
	formatter's setLocale:usLocale
	
	return (formatter's stringFromDate:dateObj) as text
end stringFromDate

on expandTilde(givenPath)
	set tempCocoaString to current application's NSString's stringWithString:givenPath
	return (tempCocoaString's stringByExpandingTildeInPath) as string
end expandTilde

on displayError(errorMessage, errorDetails, dismissAfter, cancelSriptExecution)
	display alert errorMessage message errorDetails as critical buttons {"OK"} default button "OK" giving up after dismissAfter
	if cancelSriptExecution then
		error number -128
	end if
end displayError

on writeLog(theNewText)
	set theData to ((current application's NSString's alloc()'s initWithString:(theNewText & linefeed))'s dataUsingEncoding:(current application's NSUTF8StringEncoding))
	theLogFileHandle's writeData:theData |error|:(missing value)
end writeLog

to floor(n)
	-- floor: "truncates" downwards to closest integer
	set i to n div 1
	if n < 0 then
		set f to n mod 1
		if f < 0 then
			set f to 1
		else
			set f to 0
		end if
		return (n - f) div 1
	else
		return n div 1
	end if
end floor

on durationStringFromNumberSecond(theDuration)
	set theMinutes to text -1 thru -2 of ("00" & floor((theDuration / 60)))
	set theSeconds to text -1 thru -2 of ("00" & ((theDuration - theMinutes * 60) as integer))
	return (theMinutes & ":" & theSeconds) as string
end durationStringFromNumberSecond

on sortTheArray:theArray byIdx:theArrayIdx
	set theArrayUnsorted to current application's NSMutableArray's arrayWithArray:theArray
	set theArraySorted to current application's NSMutableArray's arrayWithArray:theArray
	set theLength to theArray's |count|()
	repeat with theFirstIdx from (theLength) - 1 to 0 by -1
		set theCurrentValue to ((theArrayUnsorted's objectAtIndex:0)'s objectAtIndex:(theArrayIdx - 1))
		set theIdx to 0
		repeat with theSecIdx from 1 to theFirstIdx
			set theTestValue to ((theArrayUnsorted's objectAtIndex:theSecIdx)'s objectAtIndex:(theArrayIdx - 1))
			if (theTestValue's compare:theCurrentValue) is equal to current application's NSOrderedAscending then
				set theCurrentValue to theTestValue
				set theIdx to theSecIdx
			end if
		end repeat
		(theArraySorted's replaceObjectAtIndex:(theLength - theFirstIdx - 1) withObject:(theArrayUnsorted's objectAtIndex:theIdx))
		(theArrayUnsorted's removeObjectAtIndex:theIdx)
	end repeat
	return theArraySorted
end sortTheArray:byIdx:

on sortTheArray:theArray byKey:theArrayKey withOrdering:theOrdering
	set theArrayUnsorted to current application's NSMutableArray's arrayWithArray:theArray
	set theArraySorted to current application's NSMutableArray's arrayWithArray:theArray
	set theLength to theArray's |count|()
	repeat with theFirstIdx from (theLength) - 1 to 0 by -1
		set theCurrentValue to ((theArrayUnsorted's objectAtIndex:0)'s valueForKey:theArrayKey)
		set theIdx to 0
		repeat with theSecIdx from 1 to theFirstIdx
			set theTestValue to ((theArrayUnsorted's objectAtIndex:theSecIdx)'s valueForKey:theArrayKey)
			if (theTestValue's compare:theCurrentValue) is equal to theOrdering then
				set theCurrentValue to theTestValue
				set theIdx to theSecIdx
			end if
		end repeat
		(theArraySorted's replaceObjectAtIndex:(theLength - theFirstIdx - 1) withObject:(theArrayUnsorted's objectAtIndex:theIdx))
		(theArrayUnsorted's removeObjectAtIndex:theIdx)
	end repeat
	return theArraySorted
end sortTheArray:byKey:withOrdering:

on storeResults()
	theLogFileHandle's seekToOffset:theLogFilePosition |error|:(missing value)
	writeLog("=== Rehearsal started (" & stringFromDate(theStartTime) & ")===")
	writeLog("N	Total	Net t.	Break	Slide")
	set theLogResultsList to theLogResults's allValues()
	repeat with theRecord in (my sortTheArray:theLogResultsList byKey:"theLastSlideNumber" withOrdering:(current application's NSOrderedAscending))
		set theRecord to theRecord as record
		my writeLog((theRecord's theLastSlideNumber as string) & "	" & my durationStringFromNumberSecond(theRecord's theTotalDurationWithBreaks) & "	" & my durationStringFromNumberSecond(theRecord's theTotalDurationWithoutBreaks) & "	" & my durationStringFromNumberSecond(theRecord's theDurationDuringLastBreak) & "	" & my durationStringFromNumberSecond(theRecord's theSlideDuration)) -- my stringFromDate(thePresentTime))
	end repeat
end storeResults

on logProgress()
	tell application "Keynote"
		set theCurrentSlideNumber to ((current slide of theKeynoteDoc)'s slide number) as number
		set isPlaying to (playing is true)
		set thePresentTime to current application's NSDate's |date|
		if not isPlaying and theLastBreakTime is missing value then
			--my writeLog("Paused at " & my stringFromDate(thePresentTime))
			--my writeLog("theDurationDuringLastBreak: " & theDurationDuringLastBreak)
			set theLastBreakTime to thePresentTime
		end if
		if isPlaying and theLastBreakTime is not missing value then
			set theDurationDuringLastBreak to theDurationDuringLastBreak + (thePresentTime's timeIntervalSinceDate:theLastBreakTime)
			--my writeLog("Resumed at " & my stringFromDate(thePresentTime) & " when last break was " & my stringFromDate(theLastBreakTime))
			--my writeLog("theDurationDuringLastBreak: " & theDurationDuringLastBreak)
			set theLastBreakTime to missing value
		end if
		if (isPlaying and theCurrentSlideNumber is not theLastSlideNumber) or isQuitting then
			--my writeLog(my stringFromDate(thePresentTime) & " (next slide)")
			set theSlideDuration to (thePresentTime's timeIntervalSinceDate:theLastClickTime) - theDurationDuringLastBreak
			set theTotalDurationOfBreaks to theTotalDurationOfBreaks + theDurationDuringLastBreak
			set theTotalDurationWithBreaks to thePresentTime's timeIntervalSinceDate:theStartTime
			set theTotalDurationWithoutBreaks to theTotalDurationWithBreaks - theTotalDurationOfBreaks
			
			set theOldRecord to theLogResults's valueForKey:(theLastSlideNumber as string)
			if theOldRecord is not missing value then
				set theOldRecord to theOldRecord as record
				set theSlideDuration to theSlideDuration + (theOldRecord's |theSlideDuration|)
				set theDurationDuringLastBreak to theDurationDuringLastBreak + (theOldRecord's |theDurationDuringLastBreak|)
			end if
			theLogResults's setObject:{|theLastSlideNumber|:theLastSlideNumber, |theTotalDurationWithBreaks|:theTotalDurationWithBreaks, |theTotalDurationWithoutBreaks|:theTotalDurationWithoutBreaks, |theDurationDuringLastBreak|:theDurationDuringLastBreak, |theSlideDuration|:theSlideDuration} forKey:(theLastSlideNumber as string)
			
			set theDurationDuringLastBreak to 0
			set theLastClickTime to thePresentTime
			set theLastSlideNumber to theCurrentSlideNumber
			
			my storeResults()
		end if
	end tell
end logProgress

on stopLogging()
	set isQuitting to true
	logProgress()
	set theLogFileAlias to (POSIX file theLogFilePath) as alias
	tell application "Finder"
		open file theLogFileAlias
	end tell
end stopLogging

on idle
	logProgress()
	return 0.2
end idle

on quit
	stopLogging()
	continue quit
end quit

on run
	set filemanager to current application's NSFileManager's defaultManager
	set NSNotFound to a reference to 9.22337203685477E+18 + 5807
	set isQuitting to false
	set theTotalDurationOfBreaks to 0
	set theDurationDuringLastBreak to 0
	set theLastBreakTime to missing value
	set theLogResults to current application's NSMutableDictionary's new()
	
	tell application "Keynote"
		if not (exists front document) then displayError("No Keynote presentation found", "You must first open a Keynote document you want to rehearse.", 15, true)
		if playing is false then tell the front document to start
		
		set theKeynoteDoc to front document
		
		set theKeynoteFilePath to theKeynoteDoc's file
		set theLogFilePath to (((current application's NSString's stringWithString:(theKeynoteFilePath's POSIX path))'s stringByDeletingLastPathComponent())'s stringByAppendingPathComponent:"rehearsal_log.txt") as string
		
		set theLastSlideNumber to ((current slide of theKeynoteDoc)'s slide number) as number
	end tell
	
	
	set theLogFileHandle to current application's NSFileHandle's fileHandleForWritingAtPath:theLogFilePath
	if theLogFileHandle is missing value then
		filemanager's createFileAtPath:theLogFilePath |contents|:(missing value) attributes:(missing value)
		set theLogFileHandle to current application's NSFileHandle's fileHandleForWritingAtPath:theLogFilePath
	end if
	
	theLogFileHandle's seekToEndOfFile()
	set {missing value, theLogFilePosition} to theLogFileHandle's getOffset:(reference) |error|:(missing value)
	
	set theLastClickTime to current application's NSDate's |date|
	set theStartTime to theLastClickTime
	
	set doDebug to false
	--set doDebug to true
	if doDebug then
		repeat with k from 1 to 4
			logProgress()
			delay 1
		end repeat
		stopLogging()
	end if
	
end run

