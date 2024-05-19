//
//  ProgressBarKeynoteUI.m
//  KeynoteProgressBarHelper
//
//  Created by Andrea Alberti on 18.05.24.
//  Copyright © 2024 Andrea Alberti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include <ApplicationServices/ApplicationServices.h>
#import "ProgressBarKeynoteUI.h"

/*
void simulateMouseClick(CGPoint position) {
    CGEventRef clickDown = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, position, kCGMouseButtonLeft);
    CGEventRef clickUp = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseUp, position, kCGMouseButtonLeft);
    
    CGEventPost(kCGHIDEventTap, clickDown);
    CGEventPost(kCGHIDEventTap, clickUp);
    
    CFRelease(clickDown);
    CFRelease(clickUp);
}

CGPoint getElementPositide on(AXUIElementRef element) {
    CFTypeRef positionValue;
    CGPoint position = CGPointZero;
    if (AXUIElementCopyAttributeValue(element, kAXPositionAttribute, &positionValue) == kAXErrorSuccess) {
        AXValueGetValue((AXValueRef)positionValue, kAXValueCGPointType, &position);
        CFRelease(positionValue);
    }
    return position;
}
*/

#ifdef DEBUG
void getAttribute(AXUIElementRef elRef, CFStringRef attribute, NSString *format, ...) {
    // Get and log the specified attribute
    CFTypeRef value = NULL;
    AXUIElementCopyAttributeValue(elRef, attribute, &value);
    
    va_list args;
    va_start(args, format);
    
    if (value != NULL) {
        NSString *valueString = (__bridge_transfer NSString *)value;
        NSString *logMessage = [[NSString alloc] initWithFormat:format arguments:args];
        NSLog(@"%@ %@", logMessage, valueString);
    } else {
        NSString *logMessage = [[NSString alloc] initWithFormat:format arguments:args];
        NSLog(@"%@ does not have the specified attribute.", logMessage);
    }
    
    va_end(args);
    
    if (value != NULL) {
        CFRelease(value);
    }
}
#endif


@implementation ProgressBarKeynoteUI

- (instancetype)init {
    self = [super init];
    if (self) {
        _presenterNotesTextArea = NULL;
    }
    return self;
}

- (void)dealloc {
    if (_presenterNotesTextArea) {
        CFRelease(_presenterNotesTextArea);
    }
}

- (BOOL)findPresenterNotesTextArea {
    AXUIElementRef keynoteApp = AXUIElementCreateApplication([[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.iWork.Keynote"].firstObject processIdentifier]);
    AXUIElementRef mainWindow = NULL;
    AXUIElementCopyAttributeValue(keynoteApp, kAXMainWindowAttribute, (CFTypeRef *)&mainWindow);
    
    if (mainWindow != NULL) {
        CFStringRef windowTitle = NULL;
        AXUIElementCopyAttributeValue(mainWindow, kAXTitleAttribute, (CFTypeRef *)&windowTitle);
        
#ifdef DEBUG
        if (windowTitle != NULL) {
            NSLog(@"Main window title: %@", (__bridge NSString *)windowTitle);
            CFRelease(windowTitle);
        } else {
            NSLog(@"Failed to get the main window title.");
        }
#endif
        
        CFArrayRef mainWindowChildren = NULL;
        AXUIElementCopyAttributeValue(mainWindow, kAXChildrenAttribute, (CFTypeRef *)&mainWindowChildren);
        
        if (mainWindowChildren != NULL) {
            CFIndex mainWindowChildrenCount = CFArrayGetCount(mainWindowChildren);
#ifdef DEBUG
            NSLog(@"Main window children count: %ld", mainWindowChildrenCount);
#endif
            
            for (CFIndex i = 0; i < mainWindowChildrenCount; i++) {
                AXUIElementRef mainWindowChild = CFArrayGetValueAtIndex(mainWindowChildren, i);
                CFTypeRef mainWindowChildRole = NULL;
                AXUIElementCopyAttributeValue(mainWindowChild, kAXRoleAttribute, &mainWindowChildRole);
                if (mainWindowChildRole != NULL) {
                    NSString *roleString = (__bridge_transfer NSString *)mainWindowChildRole;
                    if ([roleString isEqualToString:(__bridge NSString *)kAXSplitGroupRole]) {
                        
                        /* Splitter Group */
                        
#ifdef DEBUG
                        getAttribute(mainWindowChild, kAXRoleDescriptionAttribute, @"\n\nRole description of splitter group %ld:", i);
                        //getAttribute(mainWindowChild, kAXIdentifierAttribute, @"\n\nAXIdentifier of splitter group %ld:", i);
#endif
                        
                        CFArrayRef splitGroupChildren = NULL;
                        AXUIElementCopyAttributeValue(mainWindowChild, kAXChildrenAttribute, (CFTypeRef *)&splitGroupChildren);
                        
                        if (splitGroupChildren != NULL) {
                            CFIndex splitGroupChildrenCount = CFArrayGetCount(splitGroupChildren);
#ifdef DEBUG
                            NSLog(@"Splitter group children count in splitter group %ld: %ld", i, splitGroupChildrenCount);
#endif
                            
                            for (CFIndex j = 0; j < splitGroupChildrenCount; j++) {
                                AXUIElementRef splitGroupChild = CFArrayGetValueAtIndex(splitGroupChildren, j);
                                CFTypeRef splitGroupChildRole = NULL;
                                AXUIElementCopyAttributeValue(splitGroupChild, kAXRoleAttribute, &splitGroupChildRole);
                                if (splitGroupChildRole != NULL) {
                                    NSString *scrollAreaRoleString = (__bridge_transfer NSString *)splitGroupChildRole;
                                    if ([scrollAreaRoleString isEqualToString:(__bridge NSString *)kAXScrollAreaRole]) {
                                        
                                        /* Scroll Area */
                                        
#ifdef DEBUG
                                        getAttribute(splitGroupChild, kAXRoleDescriptionAttribute, @"\n\n===\nRole description of scroll area %ld of splitter group %ld:", j, i);
                                        getAttribute(splitGroupChild, kAXIdentifierAttribute, @"AXIdentifier of scroll area %ld of splitter group %ld:", j, i);
#endif
                                        
                                        CFArrayRef scrollAreaChildren = NULL;
                                        AXUIElementCopyAttributeValue(splitGroupChild, kAXChildrenAttribute, (CFTypeRef *)&scrollAreaChildren);
                                        
                                        if (scrollAreaChildren != NULL) {
                                            CFIndex scrollAreaChildrenCount = CFArrayGetCount(scrollAreaChildren);
#ifdef DEBUG
                                            NSLog(@"Scroll area children count in scroll area %ld of splitter group %ld: %ld", j, i, scrollAreaChildrenCount);
#endif
                                            
                                            for (CFIndex k = 0; k < scrollAreaChildrenCount; k++) {
                                                AXUIElementRef scrollAreaChild = CFArrayGetValueAtIndex(scrollAreaChildren, k);
                                                
                                                CFTypeRef scrollAreaChildRole = NULL;
                                                AXUIElementCopyAttributeValue(scrollAreaChild, kAXRoleAttribute, &scrollAreaChildRole);
                                                
                                                if (scrollAreaChildRole != NULL) {
                                                    NSString *scrollAreaChildRoleString = (__bridge_transfer NSString *)scrollAreaChildRole;
                                                    if ([scrollAreaChildRoleString isEqualToString:(__bridge NSString *)kAXTextAreaRole]) {
                                                        
                                                        /* Text area */
#ifdef DEBUG
                                                        getAttribute(scrollAreaChild, kAXRoleDescriptionAttribute, @"---\nRole description of text area %ld in scroll area %ld of splitter group %ld:", k, j, i);
                                                        //getAttribute(scrollAreaChild, kAXIdentifierAttribute, @"AXIdentifier of scroll bar %ld in scroll area %ld of splitter group %ld:", k, j, i);
#endif
                                                        
#ifdef DEBUG
                                                        NSLog(@"FOUND text area %ld in scroll area %ld of splitter group %ld", k, j, i);
#endif
                                                        self.presenterNotesTextArea = (AXUIElementRef)CFRetain(scrollAreaChild);
                                                        
                                                        
                                                        CFRelease(scrollAreaChildRole);
                                                        CFRelease(splitGroupChildRole);
                                                        CFRelease(mainWindowChildRole);
                                                        CFRelease(scrollAreaChildren);
                                                        CFRelease(splitGroupChildren);
                                                        CFRelease(mainWindowChildren);
                                                        CFRelease(mainWindow);
                                                        CFRelease(keynoteApp);
                                                        return YES;
                                                    }
                                                    CFRelease(scrollAreaChildRole);
                                                }
                                            }
                                            CFRelease(scrollAreaChildren);
                                        }
                                    }
                                    CFRelease(splitGroupChildRole);
                                }
                            }
                            CFRelease(splitGroupChildren);
                        }
                    }
                    CFRelease(mainWindowChildRole);
                }
            }
            CFRelease(mainWindowChildren);
        }
        CFRelease(mainWindow);
    }
    CFRelease(keynoteApp);
    return NO;
}

- (BOOL)focusOnPresenterNotesScrollArea {
    if (self.presenterNotesTextArea != NULL) {
        AXError result = AXUIElementSetAttributeValue(self.presenterNotesTextArea, kAXFocusedAttribute, kCFBooleanTrue);
        if (result == kAXErrorSuccess) {
            // Wait for the element to gain focus, with a timeout
            const int maxRetries = 10; // Maximum number of retries
            const useconds_t waitInterval = 100000; // Wait interval in microseconds (100ms)
            
            for (int retry = 0; retry < maxRetries; retry++) {
                CFTypeRef focusedValue = NULL;
                AXError focusCheckResult = AXUIElementCopyAttributeValue(self.presenterNotesTextArea, kAXFocusedAttribute, &focusedValue);
                
                if (focusCheckResult == kAXErrorSuccess && focusedValue == kCFBooleanTrue) {
                    if (focusedValue != NULL) {
                        CFRelease(focusedValue);
                    }
                    return YES; // Focus was successfully set
                }
                
                if (focusedValue != NULL) {
                    CFRelease(focusedValue);
                }
                
                usleep(waitInterval); // Wait before retrying
            }
        }
    }
    return NO; // Failed to set focus or verify focus within the timeout
}


/*
- (BOOL)showPresenterNotes:(BOOL)show {
    AXUIElementRef keynoteApp = AXUIElementCreateApplication([[NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.iWork.Keynote"].firstObject processIdentifier]);
    
    if (keynoteApp == NULL) {
        return NO;
    }
    
    AXUIElementRef menuBar = NULL;
    AXError error = AXUIElementCopyAttributeValue(keynoteApp, kAXMenuBarAttribute, (CFTypeRef *)&menuBar);
    
    if (error != kAXErrorSuccess || menuBar == NULL) {
        CFRelease(keynoteApp);
        return NO;
    }
    
    CFArrayRef menuBarItems = NULL;
    error = AXUIElementCopyAttributeValue(menuBar, kAXChildrenAttribute, (CFTypeRef *)&menuBarItems);
    
    if (error != kAXErrorSuccess || menuBarItems == NULL) {
        CFRelease(menuBar);
        CFRelease(keynoteApp);
        return NO;
    }
    
    CFIndex itemCount = CFArrayGetCount(menuBarItems);
    BOOL success = NO;
    
    for (CFIndex i = 0; i < itemCount; i++) {
        AXUIElementRef menuBarItem = CFArrayGetValueAtIndex(menuBarItems, i);
        CFStringRef title = NULL;
        AXUIElementCopyAttributeValue(menuBarItem, kAXTitleAttribute, (CFTypeRef *)&title);
        
        if (title && CFStringCompare(title, CFSTR("View"), 0) == kCFCompareEqualTo) {
            CGPoint viewMenuPosition = getElementPosition(menuBarItem);
            simulateMouseClick(viewMenuPosition);
            
            CFArrayRef viewMenuItems = NULL;
            error = AXUIElementCopyAttributeValue(menuBarItem, kAXChildrenAttribute, (CFTypeRef *)&viewMenuItems);
            
            if (error == kAXErrorSuccess && viewMenuItems != NULL) {
                CFIndex viewMenuItemCount = CFArrayGetCount(viewMenuItems);
                
                for (CFIndex j = 0; j < viewMenuItemCount; j++) {
                    AXUIElementRef viewMenuItem = CFArrayGetValueAtIndex(viewMenuItems, j);
                    CFTypeRef submenu = NULL;
                    AXUIElementCopyAttributeValue(viewMenuItem, kAXChildrenAttribute, (CFTypeRef *)&submenu);
                    
                    if (submenu != NULL) {
                        CFArrayRef submenuItems = (CFArrayRef)submenu;
                        CFIndex submenuItemCount = CFArrayGetCount(submenuItems);
                        
                        for (CFIndex k = 0; k < submenuItemCount; k++) {
                            AXUIElementRef submenuItem = CFArrayGetValueAtIndex(submenuItems, k);
                            CFStringRef submenuItemTitle = NULL;
                            AXUIElementCopyAttributeValue(submenuItem, kAXTitleAttribute, (CFTypeRef *)&submenuItemTitle);
                            
                            if (submenuItemTitle) {
                                NSLog(@"Submenu item title: %@", submenuItemTitle);
                                if ((show && CFStringCompare(submenuItemTitle, CFSTR("Show Presenter Notes"), 0) == kCFCompareEqualTo) ||
                                    (!show && CFStringCompare(submenuItemTitle, CFSTR("Hide Presenter Notes"), 0) == kCFCompareEqualTo)) {
                                    CGPoint submenuItemPosition = getElementPosition(submenuItem);
                                    simulateMouseClick(submenuItemPosition);
                                    success = YES;
                                    CFRelease(submenuItemTitle);
                                    break;
                                }
                                CFRelease(submenuItemTitle);
                            }
                        }
                        
                        CFRelease(submenu);
                    }
                    
                    if (success) {
                        break;
                    }
                }
                
                CFRelease(viewMenuItems);
            }
        }
        
        if (title) {
            CFRelease(title);
        }
        
        if (success) {
            break;
        }
    }
    
    CFRelease(menuBarItems);
    CFRelease(menuBar);
    CFRelease(keynoteApp);
    
    return success;
}
*/

@end