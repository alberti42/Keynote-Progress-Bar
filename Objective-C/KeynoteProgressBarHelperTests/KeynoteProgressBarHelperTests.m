//
//  KeynoteProgressBarHelperTests.m
//  KeynoteProgressBarHelperTests
//
//  Created by Andrea Alberti on 15.01.19.
//  Copyright © 2019 Andrea Alberti. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <KeynoteProgressBarHelper/KeynoteProgressBarHelper.h>
#import <KeynoteProgressBarHelper/ProgressBarKeynoteUI.h>

@interface KeynoteProgressBarHelperTests : XCTestCase

@end

@implementation KeynoteProgressBarHelperTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testOpenPresenter {
    ProgressBarKeynoteUI* p = [[ProgressBarKeynoteUI alloc] init];
    BOOL result = [p togglePresenterNotes:true];
    XCTAssertTrue(result, @"Failed to open the presenter notes.");
}


- (void)testKeynoteUI {
    NSLog(@"\n\n=============");
    NSLog(@"Testing Keynote UI control functionalities");

    ProgressBarKeynoteUI* p = [[ProgressBarKeynoteUI alloc] init];
    
    // Test showing presenter notes
    // BOOL showPresenterNotesSuccess = [p showPresenterNotes:YES];
    // XCTAssertTrue(showPresenterNotesSuccess, @"Failed to show presenter notes.");
    
    
    // Check if the presenter notes scroll area is found
    BOOL foundTextArea = [p findPresenterNotesTextArea];
    XCTAssertTrue(foundTextArea, @"Failed to find the presenter notes text area.");
    
    // Check if the focus is set on the presenter notes scroll area
    BOOL focusSet = [p focusOnPresenterNotesScrollArea];
    XCTAssertTrue(focusSet, @"Failed to set focus on the presenter notes text area.");
    

    NSLog(@"\n\n=============");
}


- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    
    NSLog(@"\n\n=============");
    NSLog(@"Logging!");
    
    ProgressBarPDFImage* p = [[ProgressBarPDFImage alloc] initPDFwithSize:NSMakeSize(200, 200) andFilename:[@"~/test.pdf" stringByExpandingTildeInPath]];
    
    [p setLineWidth:0];
    [p setFillColor:[NSColor redColor] andStrokeColor:[NSColor blueColor]];
    [p drawOvalInRect:NSMakeRect(0, 0, 100, 100)];
    
    NSFont* theFont = [NSFont fontWithName:@"Helvetica" size:12];
    
    NSDictionary* attr = @{ NSFontAttributeName : theFont };
    
    [p drawAttributedString:[[NSAttributedString alloc] initWithString:@"Hello" attributes:attr] inRect:NSMakeRect(0, 0, 100, 100)];
    
    [p releasePDFimage];
    
    NSLog(@"\n\n=============");
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
