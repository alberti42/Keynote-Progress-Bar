//
//  App_for_testing_componentsTests.m
//  App for testing componentsTests
//
//  Created by Andrea Alberti on 06.10.24.
//  Copyright © 2024 Andrea Alberti. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <KeynoteProgressBarHelper/KeynoteProgressBarHelper.h>

@interface App_for_testing_componentsTests : XCTestCase

@end

@implementation App_for_testing_componentsTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}


- (void)testAccessibilityPermissions {
    ProgressBarKeynoteUI* p = [[ProgressBarKeynoteUI alloc] init];
        
    BOOL result = [p getAccessibilityStatus];
    XCTAssertTrue(result, @"The app is not trusted for Accessibility, please grant permissions in System Preferences.");
}

- (void)testOpenClosePresenter {
    BOOL result;
    
    ProgressBarKeynoteUI* p = [[ProgressBarKeynoteUI alloc] init];
    result = [p togglePresenterNotes:true];
    XCTAssertTrue(result, @"Failed to open the presenter notes.");
    
    [NSThread sleepForTimeInterval:1.0];
    result = [p togglePresenterNotes:false];
    XCTAssertTrue(result, @"Failed to close the presenter notes.");
}

- (void)testKeynoteUI {
    NSLog(@"\n\n=============");
    NSLog(@"Testing Keynote UI control functionalities");

    ProgressBarKeynoteUI* p = [[ProgressBarKeynoteUI alloc] init];
    
    BOOL result = [p togglePresenterNotes:true];
    XCTAssertTrue(result, @"Failed to open the presenter notes.");
    NSLog(@"Presenter notes opened successfully");
  
    // Check if the presenter notes scroll area is found
    BOOL foundTextArea = [p findPresenterNotesTextArea];
    XCTAssertTrue(foundTextArea, @"Failed to find the presenter notes text area.");
    NSLog(@"Found presenter notes");
    
    // Check if the focus is set on the presenter notes scroll area
    BOOL focusSet = [p focusOnPresenterNotesScrollArea];
    XCTAssertTrue(focusSet, @"Failed to set focus on the presenter notes text area.");
    NSLog(@"Set focus on presenter notes");

    NSLog(@"\n\n=============");
}

- (void)testPDFimages {
    
    NSLog(@"\n\n=============");
    NSLog(@"Testing creation of PDF images ...");
    
    ProgressBarPDFImage* p = [[ProgressBarPDFImage alloc] initPDFwithSize:NSMakeSize(900, 30) andFilename:[@"~/Downloads/ProgressBar-1.pdf" stringByExpandingTildeInPath]];
    
    double blockSep = 15.28;
    double Xpos;
    
    [p setLineWidth:0.2];
    for(int i=0; i<8; i++){
        Xpos = 41.2 + i*blockSep;
        [p setFillColor:[NSColor colorWithRed:91/255. green:96/255. blue: 95/255. alpha:100/255.] andStrokeColor:[NSColor colorWithRed:0/255. green:0/255. blue: 0/255. alpha:100/255.] ];
        [p drawOvalInRect:NSMakeRect(Xpos, 1.2, 7.0, 7.0)];
    }
    
    NSFont* theFont = [NSFont fontWithName:@"Helvetica" size:18];
    
    NSDictionary* attr = @{ NSFontAttributeName : theFont };
    
    [p drawAttributedString:[[NSAttributedString alloc] initWithString:@"Introduction" attributes:attr] inRect:NSMakeRect(51.14, -0.3, 911., 35.)];
    
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
