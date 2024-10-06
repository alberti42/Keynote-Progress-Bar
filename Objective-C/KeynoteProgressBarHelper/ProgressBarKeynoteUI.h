//
//  ProgressBarKeynoteUI.h
//  KeynoteProgressBarHelper
//
//  Created by Andrea Alberti on 18.05.24.
//  Copyright © 2024 Andrea Alberti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface ProgressBarKeynoteUI : NSObject

@property (nonatomic) AXUIElementRef presenterNotesTextArea;

- (BOOL)findPresenterNotesTextArea;
- (BOOL)focusOnPresenterNotesScrollArea;
- (BOOL)togglePresenterNotes:(BOOL)show;
- (BOOL)getAccessibilityStatus;
- (AXUIElementRef)getPresenterNotesTextArea;

@end

