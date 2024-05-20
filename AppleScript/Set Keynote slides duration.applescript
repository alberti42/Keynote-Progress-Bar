use AppleScript version "2.4" -- Yosemite (10.10) or later
use framework "Foundation"

-- Import custom framework for creating progress bar images
use framework "KeynoteProgressBarHelper"

use scripting additions

-- Function to check if running on Apple Silicon (ARM)
on isAppleSilicon()
	set processInfo to current application's NSProcessInfo's processInfo()
	set architecture to processInfo's |operatingSystemVersionString|() as string
	try
		-- Check if the processor architecture contains 'arm64'
		set result to do shell script "uname -m"
		if result is "arm64" then
			return true
		else
			return false
		end if
	on error
		return false
	end try
end isAppleSilicon

-- Function to check if running on Intel
on isIntel()
	return not isAppleSilicon()
end isIntel

--Function to find the presenter notes
on findPresenterNotes()
	set thePresenterNotes to missing value
	if my isAppleSilicon() then
		
		tell application "System Events"
			tell application process "Keynote"
				set frontmost to true
				set scrollareas to scroll areas of (item 1 of (splitter groups of (item 1 of first window of (windows whose value of attribute "AXMain" is true))))
				
				repeat with scrollarea in scrollareas
					-- Check if the scroll area contains a text area, which is typical for presenter notes
					set textAreas to text areas of scrollarea
					
					set theAXIdentifier to (attributes of scrollarea whose name is "AXIdentifier") as list
					if (count of theAXIdentifier) > 0 then
						if value of first item of theAXIdentifier is "_NS:8" then
							set thePresenterNotes to scrollarea
						end if
					end if
				end repeat
			end tell
		end tell
		
	else if my isIntel() then
		
		tell application "System Events"
			tell application process "Keynote"
				set frontmost to true
				set scrollareas to scroll areas of (item 1 of (splitter groups of (item 1 of first window of (windows whose value of attribute "AXMain" is true))))
				
				repeat with scrollarea in scrollareas
					-- Check if the scroll area contains a text area, which is typical for presenter notes
					set textAreas to text areas of scrollarea
					if (count of textAreas) > 0 then
						-- Further verify by checking if the text area has the right characteristics
						set textArea to item 1 of textAreas
						set roleDescription to (value of attribute "AXRoleDescription" of textArea) as string
						if roleDescription is "text entry area" then
							set thePresenterNotes to scrollarea
							exit repeat
						end if
					end if
				end repeat
				
				
			end tell
		end tell
	end if
	return thePresenterNotes
end findPresenterNotes

-- Defines the total number of steps for the progress reporting.
on setTotalStepsForProgress(totalSteps)
	set progress total steps to totalSteps
end setTotalStepsForProgress

-- Updates the progress subtitle and number of completed steps for the progress reporting.
on updateProgress(completedSteps, progressTitle, progressSubtitle)
	set progress description to progressTitle
	set progress additional description to progressSubtitle
	set progress completed steps to completedSteps
end updateProgress

-- Displays an error alert.
on displayError(errorMessage, errorDetails, dismissAfter, cancelSriptExecution)
	tell application "Keynote" to display alert errorMessage message errorDetails as critical buttons {"OK"} default button "OK" giving up after dismissAfter
	if cancelSriptExecution then
		error number -128
	end if
end displayError

on showPresenterNotes:theStatus
	set didToggled to false
	
	tell application "System Events" to tell application process "Keynote"
		set frontmost to true
		
		set theViewMenu to menu 1 of menu bar item "View" of menu bar 1
		if theStatus then
			set theItem to (menu items of theViewMenu whose name is "Show Presenter Notes")
			if (count of theItem) > 0 then
				click item 1 of theItem
				set didToggled to true
			end if
		else
			set theItem to (menu items of theViewMenu whose name is "Hide Presenter Notes")
			if (count of theItem) > 0 then
				click item 1 of theItem
				set didToggled to true
			end if
		end if
		
	end tell
	
	tell application "System Events"
		repeat
			if theStatus then
				set theString to "Hide Presenter Notes"
			else
				set theString to "Show Presenter Notes"
			end if
			if (count of (menu items of theViewMenu whose name is theString)) = 1 then
				exit repeat
			end if
			delay 0.1
		end repeat
	end tell
	
	return didToggled
end showPresenterNotes:

on run
	set theNullObj to current application's NSNull's |null|()
	
	tell application "Keynote"
		if not (exists front document) then my displayError("Critial error: Set Keynote slides duration", "You must first open a Keynote document.", 15, true)
		if playing is true then tell the front document to stop
		
		set theKeynoteDoc to front document
		
		set theCurrentSlide to current slide of theKeynoteDoc
		
		set theSlides to slides of theKeynoteDoc whose skipped is false
		
		set theKeynoteFilePath to theKeynoteDoc's file
		
		set theLogFilePath to (((current application's NSString's stringWithString:(theKeynoteFilePath's POSIX path))'s stringByDeletingLastPathComponent())'s stringByAppendingPathComponent:"rehearsal_log.txt") as string
		
		set theRehearsalLog to current application's NSString's stringWithContentsOfFile:theLogFilePath
		
		if theRehearsalLog is missing value then
			my displayError("Critial error: Set Keynote slides duration", "You first need to rehearse your presentation and create a log file 'rehearsal_log.txt'.", 15, true)
		end if
		set theLastRehearsal to (theRehearsalLog's rangeOfString:"===" options:(current application's NSBackwardsSearch))'s location
		
		set stringScanner to (current application's NSScanner's scannerWithString:theRehearsalLog)
		(stringScanner's setCharactersToBeSkipped:(current application's NSCharacterSet's characterSetWithCharactersInString:(":	
")))
		
		stringScanner's setScanLocation:theLastRehearsal
		
		(* skip first two preamble line*)
		set {hasScanned, theStringFound} to (stringScanner's scanUpToCharactersFromSet:(current application's NSCharacterSet's newlineCharacterSet) intoString:(specifier))
		set {hasScanned, theStringFound} to (stringScanner's scanUpToCharactersFromSet:(current application's NSCharacterSet's newlineCharacterSet) intoString:(specifier))
		
		set theDurationsLog to (current application's NSMutableDictionary's new)
		
		repeat
			set {theResult, theSlideNumber} to (stringScanner's scanInteger:(specifier))
			if theResult is false then
				exit repeat
			end if
			stringScanner's setScanLocation:((stringScanner's scanLocation()) + 1)
			
			(* Total *)
			set {theResult, theInt} to (stringScanner's scanInteger:(specifier))
			stringScanner's setScanLocation:((stringScanner's scanLocation()) + 1)
			set {theResult, theInt} to (stringScanner's scanInteger:(specifier))
			stringScanner's setScanLocation:((stringScanner's scanLocation()) + 1)
			
			(* Net total *)
			set {theResult, theInt} to (stringScanner's scanInteger:(specifier))
			stringScanner's setScanLocation:((stringScanner's scanLocation()) + 1)
			set {theResult, theInt} to (stringScanner's scanInteger:(specifier))
			stringScanner's setScanLocation:((stringScanner's scanLocation()) + 1)
			
			(* Break *)
			set {theResult, theInt} to (stringScanner's scanInteger:(specifier))
			stringScanner's setScanLocation:((stringScanner's scanLocation()) + 1)
			set {theResult, theInt} to (stringScanner's scanInteger:(specifier))
			stringScanner's setScanLocation:((stringScanner's scanLocation()) + 1)
			
			(* Slide duration *)
			set {theResult, theMinutes} to (stringScanner's scanInteger:(specifier))
			stringScanner's setScanLocation:((stringScanner's scanLocation()) + 1)
			set {theResult, theSeconds} to (stringScanner's scanInteger:(specifier))
			stringScanner's setScanLocation:((stringScanner's scanLocation()) + 1)
			set theDuration to theMinutes + theSeconds / 60
			
			theDurationsLog's setObject:theDuration forKey:(theSlideNumber as string)
		end repeat
		
		set previousFrontmostProcess to missing value
		set wasPresenterNotesToggled to false
		set thePasteboard to current application's NSPasteboard's generalPasteboard()
		
		-- Keep track of the app that was previously in front
		tell application "System Events" to set previousFrontmostProcess to (first process where it is frontmost)
		
		-- Open the presenter notes and store whether the presenter notes were toggled (meaning they were closed)
		set wasPresenterNotesToggled to (my showPresenterNotes:true)
		
		-- Find the presenter notes
		--set thePresenterNotes to my findPresenterNotes()
		
		set delimiters to (current application's NSCharacterSet's characterSetWithCharactersInString:("{};="))
		set whiteSpaces to (current application's NSCharacterSet's whitespaceCharacterSet())
		
		my setTotalStepsForProgress(count of theSlides)
		my updateProgress(0, "Parsing slides", "Slide " & 0 & " out of " & (count of theSlides))
		
		set idx to 0
		(* Parse all commands in the presenter notes to find the position of the `duration` field  *)
		repeat with theSlide in theSlides
			set theSlideNumber to slide number of theSlide
			set theTotalNumberOfSlides to (theDurationsLog's |count|())
			set theDuration to (theDurationsLog's valueForKey:((theSlideNumber) as string))
			if theDuration is not missing value then
				set current slide of theKeynoteDoc to theSlide
				
				set theDuration to ((((theDuration's doubleValue()) * 100) as integer) / 100) as string
				
				(* Check if the presenter note is empty, then it just writes the default note configuration, otherwise extend them by emulating typing *)
				if (((current application's NSString's alloc()'s initWithString:(presenter notes of theSlide))'s stringByTrimmingCharactersInSet:whiteSpaces)'s isEqualToString:"") then
					set presenter notes of theSlide to "{progress bar; duration=" & theDuration & "}" & linefeed
				else
					set theNotes to (presenter notes of theSlide as string)
					
					set theDurationPosition to missing value
					
					set stringScanner to (current application's NSScanner's scannerWithString:theNotes)
					--(stringScanner's setCharactersToBeSkipped:(missing value))
					
					set {hasScanned, theStringFound} to (stringScanner's scanUpToCharactersFromSet:(delimiters) intoString:(specifier))
					set {hasScanned, theStringFound} to (stringScanner's scanString:"{" intoString:(specifier))
					
					if hasScanned then
						set {hasScanned, theStringFound} to (stringScanner's scanString:"progress bar" intoString:(specifier))
						
						if hasScanned then
							set {hasScanned, theStringFound} to (stringScanner's scanString:";" intoString:(specifier))
							
							if hasScanned then
								
								set theCmdWithArg to missing value
								
								set theNumOpen to 1
								repeat
									set {hasScanned, theStringFound} to (stringScanner's scanUpToCharactersFromSet:(delimiters) intoString:(specifier))
									if theStringFound is not missing value then
										set theStringFound to (theStringFound's stringByTrimmingCharactersInSet:whiteSpaces)
									end if
									set {hasScanned, theCharFound} to (stringScanner's scanCharactersFromSet:delimiters intoString:(specifier))
									
									if hasScanned then
										
										(stringScanner's setScanLocation:((stringScanner's scanLocation()) - (theCharFound's |length|()) + 1))
										
										if (theCharFound's hasPrefix:"{") then
											if theNumOpen is 1 then
												set theOpenLocation to stringScanner's scanLocation()
											end if
											set theNumOpen to theNumOpen + 1
										else if (theCharFound's hasPrefix:"}") then
											
											set theNumOpen to theNumOpen - 1
											
											if theNumOpen is 1 then
												set theStringFound to (stringScanner's |string|()'s substringWithRange:{location:theOpenLocation, |length|:((stringScanner's scanLocation()) - theOpenLocation - 1)})
												set theCharFound to (theCharFound's substringFromIndex:1)
											end if
										end if
										
										if theNumOpen ≤ 1 then
											
											if (theCharFound's hasPrefix:"=") then
												set theCmdWithArg to theStringFound
											else
												if theCmdWithArg is not missing value then
													if (theCmdWithArg's isEqualToString:"duration") then
														set theDurationPosition to {(stringScanner's scanLocation()) - (theStringFound's |length|()) - 1, theStringFound's |length|()}
													end if
													
													--(theCmds's setObject:theStringFound forKey:theCmdWithArg)
													set theCmdWithArg to missing value
												else
													if theStringFound is not missing value then
														--(theCmds's setObject:(theNullObj) forKey:theStringFound)
													end if
													
												end if
											end if
											
										end if
										
										if theNumOpen is 0 then
											exit repeat
										end if
									else
										my displayError("Critial error: Set Keynote slides duration", "Error: Command {progress bar; ...} not properly terminated by a curly bracket at slide number " & slide number of theSlide & ".", 15, true)
										exit repeat
									end if
								end repeat
							end if
						end if
					end if
					
					if theDurationPosition is missing value then
						my displayError("Critial error: Set Keynote slides duration", "Error: Command {progress bar; ...} was not found, or was not properly configured with the duration of the slide " & slide number of theSlide & ".", 15, true)
					end if
					set progressBarHelper to current application's ProgressBarKeynoteUI's alloc()'s init()
					if not (progressBarHelper's findPresenterNotesTextArea() as boolean) then
						my displayError("Error: Unable to find presenter notes", "Tried finding presenter notes but failed.", 15, true)
					end if
					set thePresenterNotes to (progressBarHelper's getPresenterNotesTextArea())
					if thePresenterNotes is missing value then
						my displayError("Error: Unable to identify the scroll area of the presenter notes", "No matching scroll area found in the Keynote window.", 15, true)
					end if
					if not (progressBarHelper's focusOnPresenterNotesScrollArea() as boolean) then
						my displayError("Error: Unable to focus presenter notes", "Tried focusing the presenter notes for 1 second but failed.", 15, true)
					end if
					
					(*
					-- This code only works on Apple Silicon but not Apple Intel
					-- Therefore, we use the alternative written in Objective-C
					
					-- Find the presenter notes
					set thePresenterNotes to my findPresenterNotes()

					tell application "System Events"
						repeat
							set focused of thePresenterNotes to true
							if focused of thePresenterNotes is true then
								exit repeat
							end if
						end repeat
					end tell
					*)
					
					tell application "System Events" to tell application process "Keynote"
						key code 126 using {command down} -- arrow up
						
						--log (first item of theDurationPosition)
						--log (second item of theDurationPosition)
						
						repeat with i from 1 to (first item of theDurationPosition)
							key code 124 -- arrow right							
						end repeat
						
						--delay 0.02
						
						repeat with i from 1 to (second item of theDurationPosition)
							key code 117 -- forward delete
						end repeat
						
						--delay 0.02
						
						keystroke theDuration
						delay 0.05
					end tell
					
				end if
				set idx to idx + 1
			end if
			
			my updateProgress(theSlideNumber, "Parsing slides", "Slide " & idx & " out of " & theTotalNumberOfSlides)
			
		end repeat
		
		if wasPresenterNotesToggled then
			(my showPresenterNotes:false)
		end if
		
		if previousFrontmostProcess is not missing value then
			tell application "System Events" to set the frontmost of previousFrontmostProcess to true
		end if
		
		set current slide of front document to theCurrentSlide
	end tell
end run

