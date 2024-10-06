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

#if defined(__arm64__) || defined(__aarch64__)
// Code for Apple Silicon (ARM)
#define IS_APPLE_SILICON 1
#define IS_INTEL 0
#else
// Code for Intel
#define IS_APPLE_SILICON 0
#define IS_INTEL 1
#endif


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
                        
                        // Splitter Group //
                        
#ifdef DEBUG
                        getAttribute(mainWindowChild, kAXRoleDescriptionAttribute, @"\n\nRole description of splitter group %ld:", i);
                        //getAttribute(mainWindowChild, kAXIdentifierAttribute, @"\n\nAXIdentifier of splitter group %ld:", i);
#endif
                        
                        CFArrayRef splitGroupChildren = NULL;
                        AXUIElementCopyAttributeValue(mainWindowChild, kAXChildrenAttribute, (CFTypeRef *)&splitGroupChildren);
                        
                        if (splitGroupChildren != NULL) {
                            CFIndex splitGroupChildrenCount = CFArrayGetCount(splitGroupChildren);
#ifdef DEBUG
                            NSLog(@"Children count of splitter group %ld: %ld", i, splitGroupChildrenCount);
#endif
                            
                            for (CFIndex j = 0; j < splitGroupChildrenCount; j++) {
                                AXUIElementRef splitGroupChild = CFArrayGetValueAtIndex(splitGroupChildren, j);
                                CFTypeRef splitGroupChildRole = NULL;
                                AXUIElementCopyAttributeValue(splitGroupChild, kAXRoleAttribute, &splitGroupChildRole);
                                if (splitGroupChildRole != NULL) {
                                    NSString *scrollAreaRoleString = (__bridge_transfer NSString *)splitGroupChildRole;
                                    if ([scrollAreaRoleString isEqualToString:(__bridge NSString *)kAXScrollAreaRole]) {
                                        // Scroll Area //
#ifdef DEBUG
                                        getAttribute(splitGroupChild, kAXRoleDescriptionAttribute, @"\n\n===\nRole description of scroll area %ld of splitter group %ld:", j, i);
                                        getAttribute(splitGroupChild, kAXIdentifierAttribute, @"AXIdentifier of scroll area %ld of splitter group %ld:", j, i);
#endif
                                        CFTypeRef identifierAttribute = NULL;
                                        AXUIElementCopyAttributeValue(splitGroupChild, kAXIdentifierAttribute, &identifierAttribute);
                                        
                                        if (identifierAttribute != NULL) {
                                            NSString *identifierAttributeString = (__bridge_transfer NSString *)identifierAttribute;
                                            if ([identifierAttributeString isEqualToString:@"_NS:8"]) {
#ifdef DEBUG
                                                NSLog(@"FOUND scroll area %ld of splitter group %ld", j, i);
#endif
                                                self.presenterNotesTextArea = (AXUIElementRef)CFRetain(splitGroupChild);
                                                
                                                CFRelease(splitGroupChildRole);
                                                CFRelease(mainWindowChildRole);
                                                CFRelease(splitGroupChildren);
                                                CFRelease(mainWindowChildren);
                                                CFRelease(mainWindow);
                                                CFRelease(keynoteApp);
                                                CFRelease(identifierAttribute);
                                                return YES;
                                            }
                                            CFRelease(identifierAttribute);
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

- (BOOL)togglePresenterNotes:(BOOL)show {
    NSArray *runningApps = [NSRunningApplication runningApplicationsWithBundleIdentifier:@"com.apple.iWork.Keynote"];
    if (runningApps.count == 0) {
        return NO;
    }

    NSRunningApplication *keynoteAppInstance = runningApps.firstObject;
    if (!keynoteAppInstance) {
        return NO;
    }

    // Bring Keynote to the front
    [keynoteAppInstance activateWithOptions:(NSApplicationActivateIgnoringOtherApps | NSApplicationActivateAllWindows)];
    
    // Small delay to ensure the app is frontmost
    // [NSThread sleepForTimeInterval:0.01];
    
    // Loop to wait until the app is frontmost
    for (int i = 0; i < 100; i++) { // maximum of 1 seconds
        // Do not fix this deprecated command with the new behavior because it would stop working.
        // We would need to add a delay afterward with [NSThread sleepForTimeInterval:0.01] to make it work.
        // It seems that the new implementation is asynchronous and stops working for our application.
        NSDictionary *activeAppInfo = [[NSWorkspace sharedWorkspace] activeApplication];
        NSString *activeAppBundleIdentifier = activeAppInfo[@"NSApplicationBundleIdentifier"];
        
        //NSRunningApplication *frontmostApp = [[NSWorkspace sharedWorkspace] frontmostApplication];
        //NSString *frontmostAppBundleIdentifier = frontmostApp.bundleIdentifier;
        
        if ([activeAppBundleIdentifier isEqualToString:@"com.apple.iWork.Keynote"]) {
            break;
        }
        [NSThread sleepForTimeInterval:0.01];
    }
        
    AXUIElementRef keynoteApp = AXUIElementCreateApplication([keynoteAppInstance processIdentifier]);

    if (keynoteApp == NULL) {
        return NO;
    }

    // Bring the frontmost document to the foreground
    AXUIElementRef mainWindow = NULL;
    AXError error = AXUIElementCopyAttributeValue(keynoteApp, kAXMainWindowAttribute, (CFTypeRef *)&mainWindow);

    if (error != kAXErrorSuccess || mainWindow == NULL) {
        CFRelease(keynoteApp);
        return NO;
    }

    // Ensure the main window is focused
    AXUIElementSetAttributeValue(mainWindow, kAXFocusedAttribute, kCFBooleanTrue);
    CFRelease(mainWindow);

    AXUIElementRef menuBar = NULL;
    error = AXUIElementCopyAttributeValue(keynoteApp, kAXMenuBarAttribute, (CFTypeRef *)&menuBar);

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
            CFArrayRef viewMenuItems = NULL;
            error = AXUIElementCopyAttributeValue(menuBarItem, kAXChildrenAttribute, (CFTypeRef *)&viewMenuItems);

            if (error == kAXErrorSuccess && viewMenuItems != NULL) {
                CFIndex viewMenuItemCount = CFArrayGetCount(viewMenuItems);

                for (CFIndex j = 0; j < viewMenuItemCount; j++) {
                    AXUIElementRef viewMenuItem = CFArrayGetValueAtIndex(viewMenuItems, j);
                    CFArrayRef submenuItems = NULL;
                    AXUIElementCopyAttributeValue(viewMenuItem, kAXChildrenAttribute, (CFTypeRef *)&submenuItems);

                    if (submenuItems != NULL) {
                        CFIndex submenuItemCount = CFArrayGetCount(submenuItems);

                        for (CFIndex k = 0; k < submenuItemCount; k++) {
                            AXUIElementRef submenuItem = CFArrayGetValueAtIndex(submenuItems, k);
                            CFStringRef submenuItemTitle = NULL;
                            AXUIElementCopyAttributeValue(submenuItem, kAXTitleAttribute, (CFTypeRef *)&submenuItemTitle);

                            if (submenuItemTitle) {
#ifdef DEBUG
                                //NSLog(@"Submenu item title: %@", submenuItemTitle); // Print submenu item titles
#endif

                                if (show) {
                                    if(CFStringCompare(submenuItemTitle, CFSTR("Show Presenter Notes"), 0) == kCFCompareEqualTo) {
                                        AXUIElementPerformAction(submenuItem, kAXPressAction);
#ifdef DEBUG
                                    NSLog(@"Triggering menu item: %@", submenuItemTitle);
#endif
                                    }
                                } else
                                {
                                    if(CFStringCompare(submenuItemTitle, CFSTR("Hide Presenter Notes"), 0) == kCFCompareEqualTo) {
#ifdef DEBUG
                                    NSLog(@"Triggering menu item: %@", submenuItemTitle);
#endif
                                        AXUIElementPerformAction(submenuItem, kAXPressAction);
                                    }
                                }
                                success = YES;
                                CFRelease(submenuItemTitle);
                            }
                        }

                        CFRelease(submenuItems);
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

- (AXUIElementRef)getPresenterNotesTextArea {
    return self.presenterNotesTextArea;
}

@end
