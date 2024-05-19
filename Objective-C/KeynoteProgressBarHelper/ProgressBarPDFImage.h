//
//  ProgressBarImage.h
//  KeynoteProgressBarHelper
//
//  Created by Andrea Alberti on 15.01.19.
//  Copyright © 2019 Andrea Alberti. All rights reserved.
//

#import <Foundation/Foundation.h>

//NS_ASSUME_NONNULL_BEGIN

@interface ProgressBarPDFImage : NSObject
{

}

- (id)initPDFwithSize:(NSSize)size andFilename:(NSString*)filename;
- (void)setLineWidth:(CGFloat)width;
- (void)setFillColor:(NSColor*)fillColor andStrokeColor:(NSColor*)strokeColor;
- (void)setStrokeColor:(NSColor*)strokeColor;
- (void)setFillColor:(NSColor*)fillColor;
- (void)drawOvalInRect:(NSRect)rect;
- (void)fillRect:(NSRect)rect;
- (void)drawAttributedString:(NSAttributedString*)string inRect:(NSRect)rect;
- (void)releasePDFimage;

@end

//NS_ASSUME_NONNULL_END
