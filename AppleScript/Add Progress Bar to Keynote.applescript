-- {progress bar; duration=1; start; ChapterSeparation=30; FontFamily=Helvetica Neue; FlipUpsideDown=false; FontFamilyHighlightedChapter=Helvetica Neue Medium; SetAllPositionsEqual=true; NumberOfDots=80; DotSize=8; ContourWidth=0.2; FontSize=12; chapter=Introduction; CompletedDotFillColor={91,96,95,100}; UncompletedDotFillColor={91,96,95,30}; CompletedDotStrokeColor={0,0,0,100}; BaselineOffset=0; UncompletedDotStrokeColor={0,0,0,100}; Margins={0,0,0,0}; OverwriteAllImages=true;}

-- Import necessary frameworks
use framework "Foundation"
use framework "CoreImage"
use framework "AppKit"
use framework "CoreGraphics"

-- Import custom framework for creating progress bar images
use framework "KeynoteProgressBarHelper"

use scripting additions

-- Set default values for properties
property theDefaultDuration : 1
property theNumberOfDots : 80

property theMargins : {0, 0, 0, 0}
property theChapterSeparation : 30
property theDotSize : 8
property theContourWidth : 0.2

property theCompletedTextColorDefault : {0, 0, 0, 100}
property theUncompletedTextColorDefault : {0, 0, 0, 30}

property theCompletedDotFillColorDefault : {91, 96, 95, 100}
property theUncompletedDotFillColorDefault : {91, 96, 95, 30}

property theCompletedDotStrokeColorDefault : {0, 0, 0, 100}
property theUncompletedDotStrokeColorDefault : {0, 0, 0, 100}

property theFontFamily : "Helvetica Neue"
property theFontFamilyHighlightedChapter : "Helvetica Neue"
property theFontSize : 12
property theBaselineOffset : 0

property doFlipUpsideDown : false
property doResetSizeAndPosition : false
property doOverwriteAllImages : false
property doRemoveAll : false

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

-- Limit color values to a range of 0 to 255
on limitColor(theVal)
	if theVal > 255 then
		return 255
	else if theVal < 0 then
		return 0
	else
		return theVal
	end if
end limitColor

-- Limit alpha values to a range of 0 to 100
on limitAlpha(theVal)
	if theVal > 100 then
		return 100
	else if theVal < 0 then
		return 0
	else
		return theVal
	end if
end limitAlpha

-- Configure color from a string of values
on configureColor(theColorStr)
	set theColor to missing value
	if (theColorStr's |count|()) ≥ 3 then
		(theColorStr's setObject:(my limitColor((theColorStr's objectAtIndex:0)'s doubleValue())) / 255 atIndex:0)
		(theColorStr's setObject:(my limitColor((theColorStr's objectAtIndex:1)'s doubleValue())) / 255 atIndex:1)
		(theColorStr's setObject:(my limitColor((theColorStr's objectAtIndex:2)'s doubleValue())) / 255 atIndex:2)
		if (theColorStr's |count|()) = 4 then
			(theColorStr's setObject:(my limitAlpha((theColorStr's objectAtIndex:3)'s doubleValue())) / 100 atIndex:3)
		else
			(theColorStr's setObject:100 atIndex:3)
		end if
		set theColor to (current application's NSColor's colorWithSRGBRed:(theColorStr's objectAtIndex:0) green:(theColorStr's objectAtIndex:1) blue:(theColorStr's objectAtIndex:2) alpha:(theColorStr's objectAtIndex:3))
	end if
	return theColor
end configureColor
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

-- Rounds a value to the nearest integer.
on roundVal(theVal)
	if theVal > 0 then
		return (theVal + 0.5) div 1
	else
		return (theVal - 0.5) div 1
	end if
end roundVal

-- Returns the ceiling of a value.
on ceiling(theVal)
	if theVal mod 1 > 0 then
		return (theVal div 1) + 1
	else
		return (theVal div 1)
	end if
end ceiling

-- Returns the absolute value of a number.
on abs(numericVariable)
	if numericVariable < 0 then
		return -numericVariable
	else
		return numericVariable
	end if
end abs

-- Toggles the visibility of presenter notes.
on showPresenterNotes:theNewStatus
	set didToggled to false
	
	tell application "System Events"
		tell application process "Keynote"
			-- Ensure the application process is frontmost
			set frontmost to true
			
			-- Ensure the main window is active
			set theMainWindow to (first window whose value of attribute "AXMain" is true)
			
			-- Access the menu bar and the "View" menu
			set menuBar to menu bar 1
			set viewMenuItem to menu bar item "View" of menuBar
			set viewMenu to menu 1 of viewMenuItem
			
			-- Check if the "Show Presenter Notes" menu item exists
			if (exists menu item "Show Presenter Notes" of viewMenu) then
				if theNewStatus is true then
					set presenterNotesMenuItem to menu item "Show Presenter Notes" of viewMenu
					
					-- Click the "Show Presenter Notes" menu item
					perform action "AXPress" of presenterNotesMenuItem
					
					-- Record the change
					set didToggled to true
				end if
			else if (exists menu item "Hide Presenter Notes" of viewMenu) then
				if theNewStatus is false then
					set presenterNotesMenuItem to menu item "Hide Presenter Notes" of viewMenu
					
					-- Click the "Show Presenter Notes" menu item
					perform action "AXPress" of presenterNotesMenuItem
					
					-- Record the change
					set didToggled to true
				end if
			end if
		end tell
	end tell
	
	return didToggled
end showPresenterNotes:

--Function to find the presenter notes
on findPresenterNotes()
	set thePresenterNotes to missing value
	if my isAppleSilicon() then
		
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


-- Main script execution
on run
	
	set theNullObj to current application's NSNull's |null|()
	
	tell application "Keynote"
		
		if not (exists front document) then my displayError("Critical error: Progress Bar", "You must first open a Keynote document.", 15, true)
		if playing is true then tell the front document to stop
		
		set theCurrentSlide to current slide of front document
		
		set theDocWidth to width of front document
		set theDocHeight to height of front document
		
		set theSlides to slides of front document whose skipped is false
		set theSkippedSlides to slides of front document whose skipped is true
		
		set delimiters to (current application's NSCharacterSet's characterSetWithCharactersInString:("{};="))
		set whiteSpaces to (current application's NSCharacterSet's whitespaceCharacterSet())
		
		set theFirstSlide to missing value
		set theLastSlide to missing value
		
		set theCmdsSlides to current application's NSMutableArray's new
		
		set previousFrontmostProcess to missing value
		set wasPresenterNotesToggled to false
		set thePresenterNotes to missing value
		set thePasteboard to current application's NSPasteboard's generalPasteboard()
		
		set theDefaultConfiguration to "{progress bar; duration=" & theDefaultDuration & "}"
		
		my setTotalStepsForProgress(count of theSlides)
		my updateProgress(0, "Parsing slides", "Slide " & 0 & " out of " & (count of theSlides))
		
		(* Parse all commands in the presenter notes *)
		repeat with theSlide in theSlides
			
			set theCmds to current application's NSMutableDictionary's new
			
			set theSlideNum to (slide number of theSlide)
			(theCmds's setObject:theSlideNum forKey:"slide")
			
			set theNotes to (current application's NSString's alloc()'s initWithString:(presenter notes of theSlide))
			
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
											
											(theCmds's setObject:theStringFound forKey:theCmdWithArg)
											set theCmdWithArg to missing value
											
										else
											if theStringFound is not missing value then
												(theCmds's setObject:(theNullObj) forKey:theStringFound)
											end if
											
										end if
									end if
									
								end if
								
								if theNumOpen is 0 then
									exit repeat
								end if
							else
								my displayError("Critical error: Progress Bar", "Error: Command {progress bar; ...} not properly terminated by a curly bracket at slide number " & slide number of theSlide & ".", 15, true)
								exit repeat
							end if
						end repeat
					end if
				end if
			else
				
				(* Check if the presenter note is empty, then it just writes the default note configuration, otherwise extend them by emulating typing *)
				if (((current application's NSString's alloc()'s initWithString:(presenter notes of theSlide))'s stringByTrimmingCharactersInSet:whiteSpaces)'s isEqualToString:"") then
					set presenter notes of theSlide to theDefaultConfiguration & linefeed
				else
					set progressBarHelper to current application's ProgressBarKeynoteUI's alloc()'s init()
					
					if thePresenterNotes is missing value then
						tell application "System Events" to set previousFrontmostProcess to (first process where it is frontmost)
						
						-- Open the presenter notes and store whether the presenter notes were toggled (meaning they were closed)
						set wasPresenterNotesToggled to (my showPresenterNotes:true)
						
						-- Find the presenter notes
						-- set thePresenterNotes to my findPresenterNotes()
						
						if not (progressBarHelper's findPresenterNotesTextArea() as boolean) then
							my displayError("Error: Unable to find presenter notes", "Tried finding presenter notes but failed.", 15, true)
						end if
						set thePresenterNotes to (progressBarHelper's getPresenterNotesTextArea())
						
					end if
					
					if thePresenterNotes is missing value then
						my displayError("Error: Unable to identify the scroll area of the presenter notes", "No matching scroll area found in the Keynote window.", 15, true)
					end if
					
					
					set theNotes to (presenter notes of theSlide as string)
					
					(* Find out how many empty lines at the beginning *)
					repeat with i from 0 to (count of theNotes) - 1
						if (character (i + 1) of theNotes) ≠ linefeed then
							exit repeat
						end if
					end repeat
					
					set current slide of the front document to theSlide
					
					
					if not (progressBarHelper's focusOnPresenterNotesScrollArea() as boolean) then
						my displayError("Error: Unable to focus presenter notes", "Tried focusing the presenter notes for 1 second but failed.", 15, true)
					end if
					
					tell application "System Events" to tell application process "Keynote"
						key code 126 using {command down} -- arrow up
						-- key code 123 using {command down} -- arrow left
						
						keystroke theDefaultConfiguration
						
						if i = 0 then
							key code 36 -- enter
							key code 36 -- enter							
						else if i = 1 then
							key code 36 -- enter
						end if
						
					end tell
					
				end if
				
			end if
			
			(theCmdsSlides's addObject:theCmds)
			
			my updateProgress(theSlideNum, "Parsing slides", "Slide " & theSlideNum & " out of " & (count of theSlides))
			
			if theLastSlide is not missing value then
				log "Last slide processed: " & theLastSlide
				exit repeat
			end if
			
		end repeat
		
		if wasPresenterNotesToggled then
			(my showPresenterNotes:false)
		end if
		
		if previousFrontmostProcess is not missing value then
			tell application "System Events" to set the frontmost of previousFrontmostProcess to true
		end if
		
		(* Find start slide *)
		set i to 1
		repeat with theCmds in theCmdsSlides
			if (theCmds's valueForKey:("start")) is not missing value then
				set theFirstSlide to i
				
				(* Configure the initial parameters *)
				set theConf to (theCmds's valueForKey:("NumberOfDots"))
				if theConf is not missing value and not (theConf's isEqualTo:theNullObj) then
					set theNumberOfDots to theConf's intValue()
					if theNumberOfDots < 2 then
						set theNumberOfDots to 2
					end if
				end if
				set theConf to (theCmds's valueForKey:("DotSize"))
				if theConf is not missing value and not (theConf's isEqualTo:theNullObj) then
					set theDotSize to theConf's doubleValue()
					if theDotSize < 1 then
						set theDotSize to 1
					end if
				end if
				set theConf to (theCmds's valueForKey:("ContourWidth"))
				if theConf is not missing value and not (theConf's isEqualTo:theNullObj) then
					set theContourWidth to theConf's doubleValue()
					if theContourWidth < 0 then
						set theContourWidth to 0
					end if
				end if
				set theConf to (theCmds's valueForKey:("ChapterSeparation"))
				if theConf is not missing value and not (theConf's isEqualTo:theNullObj) then
					set theChapterSeparation to theConf's doubleValue()
					if theChapterSeparation < 0 then
						set theChapterSeparation to 0
					end if
				end if
				set theConf to (theCmds's valueForKey:("SetAllPositionsEqual"))
				if theConf is not missing value then
					if (theConf's isEqualTo:theNullObj) then
						set doResetSizeAndPosition to true
					else
						set doResetSizeAndPosition to theConf's boolValue()
					end if
				end if
				set theConf to (theCmds's valueForKey:("OverwriteAllImages"))
				if theConf is not missing value then
					if (theConf's isEqualTo:theNullObj) then
						set doOverwriteAllImages to true
					else
						set doOverwriteAllImages to theConf's boolValue()
					end if
				end if
				set theConf to (theCmds's valueForKey:("RemoveAll"))
				if theConf is not missing value then
					if (theConf's isEqualTo:theNullObj) then
						set doRemoveAll to true
					else
						set doRemoveAll to theConf's boolValue()
					end if
				end if
				set theConf to (theCmds's valueForKey:("Margins"))
				if theConf is not missing value and not (theConf's isEqualTo:theNullObj) then
					set theConf to (theConf's componentsSeparatedByString:",")
					if theConf's |count|() = 4 then
						set item 1 of theMargins to (theConf's objectAtIndex:0)'s doubleValue()
						set item 2 of theMargins to (theConf's objectAtIndex:1)'s doubleValue()
						set item 3 of theMargins to (theConf's objectAtIndex:2)'s doubleValue()
						set item 4 of theMargins to (theConf's objectAtIndex:3)'s doubleValue()
					end if
				end if
				set theConf to (theCmds's valueForKey:("FlipUpsideDown"))
				if theConf is not missing value then
					if (theConf's isEqualTo:theNullObj) then
						set doFlipUpsideDown to true
					else
						set doFlipUpsideDown to theConf's boolValue()
					end if
				end if
				--log (current application's NSFontManager's sharedFontManager())'s availableFontFamilies()'s |description|() as string			
				set theConf to (theCmds's valueForKey:("FontFamily"))
				if theConf is not missing value and not (theConf's isEqualTo:theNullObj) then
					set theFontFamily to theConf
				end if
				set theConf to (theCmds's valueForKey:("FontFamilyHighlightedChapter"))
				if theConf is not missing value and not (theConf's isEqualTo:theNullObj) then
					set theFontFamilyHighlightedChapter to theConf
				end if
				set theConf to (theCmds's valueForKey:("FontSize"))
				if theConf is not missing value and not (theConf's isEqualTo:theNullObj) then
					set theFontSize to theConf's doubleValue()
					if theFontSize < 1 then
						set theFontSize to 1
					end if
				end if
				set theConf to (theCmds's valueForKey:("BaselineOffset"))
				if theConf is not missing value and not (theConf's isEqualTo:theNullObj) then
					set theBaselineOffset to theConf's doubleValue()
				end if
				set theConf to (theCmds's valueForKey:"CompletedDotFillColor")
				if theConf is not missing value and not (theConf's isEqualTo:theNullObj) then
					set theConf to (theConf's componentsSeparatedByString:",")
					if theConf's |count|() = 3 or theConf's |count|() = 4 then set theCompletedDotFillColorDefault to theConf
				end if
				set theConf to (theCmds's valueForKey:"UncompletedDotFillColor")
				if theConf is not missing value and not (theConf's isEqualTo:theNullObj) then
					set theConf to (theConf's componentsSeparatedByString:",")
					if theConf's |count|() = 3 or theConf's |count|() = 4 then set theUncompletedDotFillColorDefault to theConf
				end if
				set theConf to (theCmds's valueForKey:"CompletedDotStrokeColor")
				if theConf is not missing value and not (theConf's isEqualTo:theNullObj) then
					set theConf to (theConf's componentsSeparatedByString:",")
					if theConf's |count|() = 3 or theConf's |count|() = 4 then set theCompletedDotStrokeColorDefault to theConf
				end if
				set theConf to (theCmds's valueForKey:"UncompletedDotStrokeColor")
				if theConf is not missing value and not (theConf's isEqualTo:theNullObj) then
					set theConf to (theConf's componentsSeparatedByString:",")
					if theConf's |count|() = 3 or theConf's |count|() = 4 then set theUncompletedDotStrokeColorDefault to theConf
				end if
				set theConf to (theCmds's valueForKey:"CompletedTextColor")
				if theConf is not missing value and not (theConf's isEqualTo:theNullObj) then
					set theConf to (theConf's componentsSeparatedByString:",")
					if theConf's |count|() = 3 or theConf's |count|() = 4 then set theCompletedTextColorDefault to theConf
				end if
				set theConf to (theCmds's valueForKey:"UncompletedTextColor")
				if theConf is not missing value and not (theConf's isEqualTo:theNullObj) then
					set theConf to (theConf's componentsSeparatedByString:",")
					if theConf's |count|() = 3 or theConf's |count|() = 4 then set theUncompletedTextColorDefault to theConf
				end if
				
				
				exit repeat
			else
				set i to i + 1
			end if
		end repeat
		
		(* Find last slide *)
		set i to 1
		repeat with theCmds in theCmdsSlides
			if (theCmds's valueForKey:("stop")) is not missing value then
				set theLastSlide to i
				exit repeat
			else
				set i to i + 1
			end if
		end repeat
		
		(* Do some consistency checks *)
		if theFirstSlide is missing value then my displayError("Critial error: Progress Bar", "The initial slide was not found. Use 'start' command to define the initial slide.", 15, true)
		if theLastSlide is missing value then my displayError("Critial error: Progress Bar", "The initial slide was not found. Use 'stop' command to define the last slide.", 15, true)
		if theFirstSlide > theLastSlide then my displayError("Critial error: Progress Bar", "The initial slide must preceedes the last slide. Check order 'start' and 'stop' commands.", 15, true)
		
		log "First slide processed: " & theFirstSlide
		log "Last slide processed: " & theLastSlide
		
		(* Remove cmds before start *)
		(theCmdsSlides's removeObjectsInRange:{location:0, |length|:(theFirstSlide - 1)})
		
		(* Remove cmds after end *)
		(theCmdsSlides's removeObjectsInRange:{location:(theLastSlide - theFirstSlide + 1), |length|:((theCmdsSlides's |count|()) - ((theLastSlide - theFirstSlide + 1)))})
		
		(* Fix durations to default values *)
		repeat with theCmds in theCmdsSlides
			set theDuration to (theCmds's valueForKey:("duration"))
			if theDuration is missing value then
				(theCmds's setObject:theDefaultDuration forKey:"duration")
			else
				(* Convert into number *)
				(theCmds's setObject:(my abs(theDuration's doubleValue())) forKey:"duration")
			end if
		end repeat
		
		(* Prepare chapters *)
		set theChapters to (current application's NSMutableArray's new)
		repeat with h from 0 to (theCmdsSlides's |count|()) - 1
			set theCmds to (theCmdsSlides's objectAtIndex:h)
			
			set theChapterTitle to (theCmds's valueForKey:("chapter"))
			if theChapterTitle is not missing value or h = 0 then
				if theChapterTitle is missing value then set theChapterTitle to ""
				set theCurrentChapter to (current application's NSMutableArray's new)
				(theChapters's addObject:(current application's NSMutableDictionary's alloc()'s initWithDictionary:{cmds:theCurrentChapter, title:theChapterTitle}))
			end if
			
			(theCurrentChapter's addObject:theCmds)
		end repeat
		
		(* Fix durations to account for Same as Previous *)
		
		set thePreviousSlide to 0
		repeat with h from 0 to (theCmdsSlides's |count|()) - 1
			set theCmds to (theCmdsSlides's objectAtIndex:h)
			set theSame to (theCmds's valueForKey:"SameAsPrevious")
			if theSame is not missing value then
				if (theSame's isEqualTo:theNullObj) then
					set theSame to true
				else
					set theSame to theSame as boolean
				end if
			else
				set theSame to false
			end if
			if theSame then
				set theDuration to ((theCmds's valueForKey:"duration")'s doubleValue())
				(theCmds's setValue:0 forKey:"duration")
				set theCmds to (theCmdsSlides's objectAtIndex:thePreviousSlide)
				(theCmds's setValue:(((theCmds's valueForKey:"duration")'s doubleValue()) + theDuration) forKey:"duration")
			else
				set thePreviousSlide to h
			end if
		end repeat
		
		(* Determine the durations *)
		set theTotalDuration to 0
		set theChapterNum to 1
		repeat with theChapter in theChapters
			set theDuration to 0
			
			repeat with theCmds in (theChapter's valueForKey:"cmds")
				set theDuration to theDuration + ((theCmds's valueForKey:("duration"))'s doubleValue())
			end repeat
			
			if theDuration is 0 then my displayError("Critical error: Progress Bar", "The chapter number " & theChapterNum & " has a zero duration. Change the duration of at least one slide to a nonzero value.", 15, true)
			
			set theTotalDuration to theTotalDuration + theDuration
			
			(theChapter's setValue:theDuration forKey:"duration")
			set theChapterNum to theChapterNum + 1
		end repeat
		
		(* Determine the number of dots per chapter and their relative durations *)
		set theIntCompletion to 0
		repeat with theChapter in theChapters
			set theDuration to ((theChapter's valueForKey:"duration")'s doubleValue())
			set theCompletion to theDuration / theTotalDuration
			--(theChapter's setValue:theCompletion forKey:"completion")
			
			(theChapter's setValue:((my roundVal((theIntCompletion + theCompletion) * theNumberOfDots)) - (my roundVal(theIntCompletion * theNumberOfDots))) forKey:"numDots")
			
			set theIntCompletion to theIntCompletion + theCompletion
			--log my roundVal(((theChapter's valueForKey:"duration")'s doubleValue()) / theTotalDuration * theNumberOfDots)
		end repeat
		
		(* Compute the number of completed dots *)
		set theChapterNum to 1
		repeat with theChapter in theChapters
			set theDuration to (theChapter's valueForKey:"duration")'s doubleValue()
			set theNumDots to (theChapter's valueForKey:"numDots")'s intValue()
			set thePartialDuration to 0
			repeat with theCmds in (theChapter's valueForKey:"cmds")
				set thePartialDuration to thePartialDuration + ((theCmds's valueForKey:"duration")'s doubleValue())
				(theCmds's setValue:(my ceiling(thePartialDuration / theDuration * theNumDots)) forKey:"dotIdx")
				(theCmds's setValue:theChapterNum forKey:"chapIdx")
			end repeat
			set theChapterNum to theChapterNum + 1
		end repeat
		
		log "Total duration: " & theTotalDuration & " minutes"
		
		display notification "Total duration: " & theTotalDuration & " minutes" with title "Parsing completed" -- subtitle ""
		
		set fileManager to current application's NSFileManager's defaultManager()
		
		set theTmpPath to (current application's NSTemporaryDirectory())'s stringByAppendingPathComponent:"org.Alberti.ProgressBar"
		
		set {theResult, isDir} to fileManager's fileExistsAtPath:theTmpPath isDirectory:(specifier)
		if theResult is false then
			set {theResult, theError} to fileManager's createDirectoryAtPath:theTmpPath withIntermediateDirectories:false attributes:(missing value) |error|:(specifier)
			if theResult is false then my displayError("Critical error: Progress Bar", theError's localizedDescription() as text, 15, true)
		else
			if isDir is false then
				my displayError("Critical error: Progress Bar", "The temporary folder could not be created because a file already exists at the chosen position.", 15, true)
			end if
		end if
		
		(* Insert the progress bar into the slides *)
		set theFontAttrsCompleted to current application's NSMutableDictionary's new()
		(theFontAttrsCompleted's setObject:theBaselineOffset forKey:(current application's NSBaselineOffsetAttributeName))
		
		set theFontAttrsUncompleted to current application's NSMutableDictionary's alloc()'s initWithDictionary:theFontAttrsCompleted
		set theFontAttrsCompletedHighlighted to current application's NSMutableDictionary's alloc()'s initWithDictionary:theFontAttrsCompleted
		
		
		if doRemoveAll then
			set theSlides to slides of front document
			
			set theNumSlidesBefore to (count of theSlides)
			set theNumSlidesAfter to 0
			set theNumSlides to 0
		else
			set theNumSlides to theCmdsSlides's |count|()
			set theNumSlidesBefore to (((theCmdsSlides's firstObject())'s valueForKey:"slide")'s intValue()) - 1
			set theNumSlidesAfter to (count of theSlides) - (((theCmdsSlides's lastObject())'s valueForKey:"slide")'s intValue())
		end if
		
		set marginT to (item 1 of theMargins) + theContourWidth + 1
		set marginR to (item 2 of theMargins) + theContourWidth + 1
		set marginB to (item 3 of theMargins) + theContourWidth + 1
		set marginL to (item 4 of theMargins) + theContourWidth + 1
		
		set theVerticalMargin to theContourWidth + 1
		
		set theNumSkippedSlides to count of theSkippedSlides
		
		my setTotalStepsForProgress(theNumSlidesBefore + theNumSlidesAfter + theNumSkippedSlides)
		my updateProgress(0, "Cleaning slides", "Slide " & 0 & " out of " & (theNumSlidesBefore + theNumSlidesAfter + theNumSkippedSlides))
		
		(* Remove progress bar before the start command *)
		repeat with k from 1 to theNumSlidesBefore
			set theOldImgs to (images of (item k of theSlides) whose file name starts with "ProgressBar-")
			set theProgressBars to (iWork items of (item k of theSlides) whose object text is "{progress bar}")
			
			repeat with j from (count of theProgressBars) to 1 by -1
				delete item j of theProgressBars
			end repeat
			
			repeat with j from (count of theOldImgs) to 1 by -1
				delete item j of theOldImgs
			end repeat
			
			my updateProgress(k, "Cleaning slides", "Slide " & k & " out of " & (theNumSlidesBefore + theNumSlidesAfter + theNumSkippedSlides))
		end repeat
		
		(* Remove progress bar of skipped slides *)
		repeat with k from 1 to theNumSkippedSlides
			set theOldImgs to (images of (item k of theSkippedSlides) whose file name starts with "ProgressBar-")
			set theProgressBars to (iWork items of (item k of theSkippedSlides) whose object text is "{progress bar}")
			
			repeat with j from (count of theProgressBars) to 1 by -1
				delete item j of theProgressBars
			end repeat
			
			repeat with j from (count of theOldImgs) to 1 by -1
				delete item j of theOldImgs
			end repeat
			
			my updateProgress(k, "Cleaning slides", "Slide " & k + theNumSlidesBefore & " out of " & (theNumSlidesBefore + theNumSlidesAfter + theNumSkippedSlides))
		end repeat
		
		(* Remove progress bar after the stop command *)
		repeat with k from 1 to theNumSlidesAfter
			set theOldImgs to (images of (item (k + (count of theSlides) - theNumSlidesAfter) of theSlides) whose file name starts with "ProgressBar-")
			set theProgressBars to (iWork items of (item (k + (count of theSlides) - theNumSlidesAfter) of theSlides) whose object text is "{progress bar}")
			
			repeat with j from (count of theProgressBars) to 1 by -1
				delete item j of theProgressBars
			end repeat
			
			repeat with j from (count of theOldImgs) to 1 by -1
				delete item j of theOldImgs
			end repeat
			
			my updateProgress(k + theNumSlidesBefore, "Cleaning slides", "Slide " & k + theNumSlidesBefore + theNumSkippedSlides & " out of " & (theNumSlidesBefore + theNumSlidesAfter + theNumSkippedSlides))
		end repeat
		
		my setTotalStepsForProgress(theNumSlides)
		my updateProgress(0, "Setting progress bar", "Slide " & 0 & " out of " & theNumSlides)
		
		set thePosition to missing value
		
		repeat with k from 1 to theNumSlides
			
			set theCmds to (theCmdsSlides's objectAtIndex:(k - 1))
			
			set theSlide to (theCmds's valueForKey:"slide")'s intValue()
			
			set theOldImgs to (images of (item theSlide of theSlides) whose file name starts with "ProgressBar-")
			set theProgressBars to (iWork items of (item theSlide of theSlides) whose object text is "{progress bar}")
			
			if (theCmds's valueForKey:"skipDrawing") is missing value then
				
				set theSame to (theCmds's valueForKey:"SameAsPrevious")
				if theSame is missing value then
					set thePreviousSlide to theSlide
					
					set theChapIdx to (theCmds's valueForKey:"chapIdx")'s intValue()
					set theDotIdx to (theCmds's valueForKey:"dotIdx")'s intValue()
					
					(* Fill color of completed dots *)
					set theCompletedDotFillColor to (theCmds's valueForKey:"CompletedDotFillColor")
					if theCompletedDotFillColor is not missing value then
						set theCompletedDotFillColor to (theCompletedDotFillColor's componentsSeparatedByString:",")
					else
						set theCompletedDotFillColor to (current application's NSMutableArray's alloc()'s initWithArray:theCompletedDotFillColorDefault)
					end if
					set theCompletedDotFillColor to my configureColor(theCompletedDotFillColor)
					
					(* Fill color of uncompleted dots *)
					set theUncompletedDotFillColor to (theCmds's valueForKey:"UncompletedDotFillColor")
					if theUncompletedDotFillColor is not missing value then
						set theUncompletedDotFillColor to (theUncompletedDotFillColor's componentsSeparatedByString:",")
					else
						set theUncompletedDotFillColor to (current application's NSMutableArray's alloc()'s initWithArray:theUncompletedDotFillColorDefault)
					end if
					set theUncompletedDotFillColor to my configureColor(theUncompletedDotFillColor)
					
					(* Stroke color of completed dots *)
					set theCompletedDotStrokeColor to (theCmds's valueForKey:"CompletedDotStrokeColor")
					if theCompletedDotStrokeColor is not missing value then
						set theCompletedDotStrokeColor to (theCompletedDotStrokeColor's componentsSeparatedByString:",")
					else
						set theCompletedDotStrokeColor to (current application's NSMutableArray's alloc()'s initWithArray:theCompletedDotStrokeColorDefault)
					end if
					set theCompletedDotStrokeColor to my configureColor(theCompletedDotStrokeColor)
					
					(* Stroke color of uncompleted dots *)
					set theUncompletedDotStrokeColor to (theCmds's valueForKey:"UncompletedDotStrokeColor")
					if theUncompletedDotStrokeColor is not missing value then
						set theUncompletedDotStrokeColor to (theUncompletedDotStrokeColor's componentsSeparatedByString:",")
					else
						set theUncompletedDotStrokeColor to (current application's NSMutableArray's alloc()'s initWithArray:theUncompletedDotStrokeColorDefault)
					end if
					set theUncompletedDotStrokeColor to my configureColor(theUncompletedDotStrokeColor)
					
					(* Text color of completed dots *)
					set theCompletedTextColor to (theCmds's valueForKey:"CompletedTextColor")
					if theCompletedTextColor is not missing value then
						set theCompletedTextColor to (theCompletedTextColor's componentsSeparatedByString:",")
					else
						set theCompletedTextColor to (current application's NSMutableArray's alloc()'s initWithArray:theCompletedTextColorDefault)
					end if
					set theCompletedTextColor to my configureColor(theCompletedTextColor)
					
					(* Text color of uncompleted dots *)
					set theUncompletedTextColor to (theCmds's valueForKey:"UncompletedTextColor")
					if theUncompletedTextColor is not missing value then
						set theUncompletedTextColor to (theUncompletedTextColor's componentsSeparatedByString:",")
					else
						set theUncompletedTextColor to (current application's NSMutableArray's alloc()'s initWithArray:theUncompletedTextColorDefault)
					end if
					set theUncompletedTextColor to my configureColor(theUncompletedTextColor)
					
					set theFont to (current application's NSFont's fontWithName:theFontFamily |size|:theFontSize)
					set theFontHighlighted to (current application's NSFont's fontWithName:theFontFamilyHighlightedChapter |size|:theFontSize * 1)
					(theFontAttrsCompleted's setObject:theFont forKey:(current application's NSFontAttributeName))
					(theFontAttrsCompleted's setObject:theCompletedTextColor forKey:(current application's NSForegroundColorAttributeName))
					(theFontAttrsCompletedHighlighted's setObject:theFontHighlighted forKey:(current application's NSFontAttributeName))
					(theFontAttrsCompletedHighlighted's setObject:theCompletedTextColor forKey:(current application's NSForegroundColorAttributeName))
					(theFontAttrsUncompleted's setObject:theFont forKey:(current application's NSFontAttributeName))
					(theFontAttrsUncompleted's setObject:theUncompletedTextColor forKey:(current application's NSForegroundColorAttributeName))
					
					set theTitleSize to ((current application's NSString's alloc()'s initWithString:"ABCDFGabcdfg")'s sizeWithAttributes:theFontAttrsCompletedHighlighted)
					set theHeight to (my ceiling((marginT + marginB + theDotSize + (theTitleSize's |height|) * 1.1)))
					
					if not doResetSizeAndPosition or thePosition is missing value then
						if (count of theProgressBars) > 0 then
							set theProgressBar to first item of theProgressBars
							
							set theWidth to (width of theProgressBar)
							
							set thePosition to position of theProgressBar as list
						else if (count of theOldImgs) > 0 then
							set theOldImg to first item of theOldImgs
							
							set theWidth to (width of theOldImg)
							
							set thePosition to position of theOldImg as list
						else if thePosition is missing value then
							set theWidth to (my ceiling(0.9 * (theDocWidth + (marginL + marginR))))
							
							set thePosition to {(theDocWidth - theWidth) / 2, theDocHeight - theHeight}
						end if
					end if
					
					set theBlockSep to ((theWidth - theChapterSeparation * ((theChapters's |count|()) - 1) - marginL - marginR - theDotSize) / (theNumberOfDots - 1))
					
					set theImgPath to (theTmpPath's stringByAppendingPathComponent:("ProgressBar-" & theSlide & ".pdf")) as string
					set thePDFimage to ((current application's ProgressBarPDFImage's alloc())'s initPDFwithSize:(current application's NSMakeSize(theWidth, theHeight)) andFilename:theImgPath)
					
					set theBGcolor to (theCmds's valueForKey:"BackgroundColor")
					if theBGcolor is not missing value and not (theBGcolor's isEqualTo:theNullObj) then
						set theBGcolor to my configureColor(theBGcolor's componentsSeparatedByString:",")
						if theBGcolor is not missing value then
							(thePDFimage's setFillColor:theBGcolor)
							(thePDFimage's setLineWidth:0)
							(thePDFimage's fillRect:(current application's NSMakeRect(0, 0, theWidth, theHeight)))
						end if
					end if
					
					(thePDFimage's setLineWidth:theContourWidth)
					
					(* https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/CocoaDrawingGuide/Paths/Paths.html#//apple_ref/doc/uid/TP40003290-CH206-BBCHFJJG *)
					
					set theOffset to marginL
					repeat with j from 0 to (theChapters's |count|()) - 1
						set theChapter to (theChapters's objectAtIndex:j)
						set theChapterTitle to (theChapter's valueForKey:"title")
						
						set theNumDots to (theChapter's valueForKey:"numDots")'s intValue()
						
						repeat with i from 0 to theNumDots - 1
							
							if j < (theChapIdx - 1) or (j = (theChapIdx - 1) and i ≤ (theDotIdx - 1)) then
								(thePDFimage's setFillColor:theCompletedDotFillColor andStrokeColor:theCompletedDotStrokeColor)
							else
								(thePDFimage's setFillColor:theUncompletedDotFillColor andStrokeColor:theUncompletedDotStrokeColor)
							end if
							
							set theXpos to theOffset + i * theBlockSep
							if doFlipUpsideDown then
								(thePDFimage's drawOvalInRect:(current application's NSMakeRect(theXpos, theHeight - marginT - theDotSize, theDotSize, theDotSize)))
							else
								(thePDFimage's drawOvalInRect:(current application's NSMakeRect(theXpos, marginB, theDotSize, theDotSize)))
							end if
							
						end repeat
						
						(* Set the color of the text *)
						if j < (theChapIdx - 1) then
							set theFontAttrs to theFontAttrsCompleted
						else if j = (theChapIdx - 1) then
							set theFontAttrs to theFontAttrsCompletedHighlighted
						else
							set theFontAttrs to theFontAttrsUncompleted
						end if
						
						set theTitleSize to (theChapterTitle's sizeWithAttributes:theFontAttrs)
						
						if doFlipUpsideDown then
							(thePDFimage's drawAttributedString:((current application's NSAttributedString's alloc())'s initWithString:theChapterTitle attributes:theFontAttrs) ¬
								inRect:(current application's NSMakeRect((theOffset + theXpos + theDotSize - (theTitleSize's |width|)) * 0.5, -theHeight + (theTitleSize's |height|), theWidth, theHeight)))
						else
							(thePDFimage's drawAttributedString:((current application's NSAttributedString's alloc())'s initWithString:theChapterTitle attributes:theFontAttrs) ¬
								inRect:(current application's NSMakeRect((theOffset + theXpos + theDotSize - (theTitleSize's |width|)) * 0.5, -theHeight + marginT + marginB + theDotSize + (theTitleSize's |height|) * 1.1, theWidth, theHeight)))
						end if
						
						set theOffset to theXpos + theChapterSeparation + theBlockSep
						
					end repeat
					
					thePDFimage's releasePDFimage()
				else
					set theImgPath to (theTmpPath's stringByAppendingPathComponent:("ProgressBar-" & thePreviousSlide & ".pdf")) as string
				end if
				
				if theResult is false then my displayError("Critical error: Progress Bar", "The progress bar could not be generated for slide number " & theSlide & ".", 15, true)
				if not doOverwriteAllImages and (count of theOldImgs) > 0 then
					set file name of (item 1 of theOldImgs) to POSIX file theImgPath
					set position of (item 1 of theOldImgs) to thePosition
					set height of (item 1 of theOldImgs) to theHeight
					set width of (item 1 of theOldImgs) to theWidth
				else
					tell (item theSlide) of theSlides to set theNewImg to make new image with properties {file:POSIX file theImgPath, position:thePosition, width:theWidth, height:theHeight}
				end if
				
			end if
			
			repeat with j from (count of theProgressBars) to 1 by -1
				delete item j of theProgressBars
			end repeat
			
			if doOverwriteAllImages then
				repeat with j from (count of theOldImgs) to 1 by -1
					delete item j of theOldImgs
				end repeat
			else
				repeat with j from (count of theOldImgs) to 2 by -1
					delete item j of theOldImgs
				end repeat
			end if
			
			my updateProgress(k, "Setting progress bar", "Slide " & k & " out of " & theNumSlides)
		end repeat
		
		set {theResult, theError} to fileManager's removeItemAtPath:theTmpPath |error|:(specifier)
		if theResult is false then my displayError("Critical error: Progress Bar", "The temporary folder could not be removed.", 15, true)
		
		set current slide of front document to theCurrentSlide
	end tell
	
end run
