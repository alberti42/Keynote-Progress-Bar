//
//  ProgressBarImage.m
//  KeynoteProgressBarHelper
//
//  Created by Andrea Alberti on 15.01.19.
//  Copyright © 2019 Andrea Alberti. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ProgressBarPDFImage.h"

@interface ProgressBarPDFImage ()

@property (nonatomic, retain) NSString* filename;

@end

@implementation ProgressBarPDFImage
{
    NSBitmapImageRep* theOffscreenRep;
    CGContextRef pdfContext;
    NSSize size;
    CFDataRef boxData;
    CFMutableDictionaryRef pageDictionary;
}

@synthesize filename;

#pragma mark PDF image implementation

- (id)initPDFwithSize:(NSSize)size andFilename:(NSString*)filename
{
    if (self = [super init]) {
        self->size = size;
        
        [self setFilename: filename];
        
        [self initPDFfile];
    }
    return self;
}

- (void)initPDFfile
{
    CFStringRef path = CFStringCreateWithCString (NULL, [filename UTF8String], kCFStringEncodingUTF8);
    CFURLRef url = CFURLCreateWithFileSystemPath (NULL, path, kCFURLPOSIXPathStyle, 0);
   
    CFRelease(path);
    
    CFMutableDictionaryRef myDictionary = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(myDictionary, kCGPDFContextTitle, CFSTR("Keynote Progress Bar Image"));
    CFDictionarySetValue(myDictionary, kCGPDFContextCreator, CFSTR("(c) Andrea Alberti"));
    
    CGRect pageRect = CGRectMake(0, 0, self->size.width, self->size.height);
    
    self->pdfContext = CGPDFContextCreateWithURL(url, &pageRect, myDictionary);
    
    CFRelease(myDictionary);
    CFRelease(url);
    
    self->pageDictionary = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    self->boxData = CFDataCreate(NULL,(const UInt8 *)&pageRect, sizeof (CGRect));
    
    CFDictionarySetValue(self->pageDictionary, kCGPDFContextMediaBox, boxData);
    
    CGPDFContextBeginPage (self->pdfContext, self->pageDictionary);
}

- (void)setLineWidth:(CGFloat)width
{
    CGContextSetLineWidth(self->pdfContext,width);
}

- (void)setFillColor:(NSColor*)fillColor
{
    CGContextRef pdfContext = self->pdfContext;
    CGContextSetFillColorWithColor(pdfContext, [fillColor CGColor]);
}

- (void)setStrokeColor:(NSColor*)strokeColor
{
    CGContextRef pdfContext = self->pdfContext;
    CGContextSetStrokeColorWithColor(pdfContext, [strokeColor CGColor]);
}

- (void)setFillColor:(NSColor*)fillColor andStrokeColor:(NSColor*)strokeColor
{
    CGContextRef pdfContext = self->pdfContext;
    CGContextSetFillColorWithColor(pdfContext, [fillColor CGColor]);
    CGContextSetStrokeColorWithColor(pdfContext, [strokeColor CGColor]);
}

- (void)drawOvalInRect:(NSRect)rect
{
    CGContextRef pdfContext = self->pdfContext;
    CGPathRef path = CGPathCreateWithEllipseInRect(NSRectToCGRect(rect), nil);
    CGContextAddPath(pdfContext, path);
    CGContextDrawPath(pdfContext,kCGPathFillStroke);
    CFRelease(path);
}

- (void)fillRect:(NSRect)rect
{
    CGContextFillRect(self->pdfContext,rect);
}

- (void)drawAttributedString:(NSAttributedString*)string inRect:(NSRect)rect
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, NSRectToCGRect(rect));
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)string);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [string length]), path, NULL);
    
    CTFrameDraw(frame, self->pdfContext);
    
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
}

- (void)releasePDFimage
{
    CGPDFContextEndPage (self->pdfContext);
    CGContextRelease (self->pdfContext);
    CFRelease(self->pageDictionary);
    CFRelease(self->boxData);
}

#pragma mark PNG image implementation

/*
 
 - (bool)saveAsPNGWithFilename:(NSString*) thePath
 {
 NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1] forKey:NSImageCompressionFactor];
 NSData* imageData = [self->theOffscreenRep representationUsingType:NSBitmapImageFileTypePNG properties:options];
 
 return [imageData writeToFile:thePath atomically:false];
 }
 
 - (void)drawIntoBitmap
 {
 NSRect imgRect = NSMakeRect(0.0, 0.0, [self->theOffscreenRep pixelsWide], [self->theOffscreenRep pixelsHigh]);
 NSSize imgSize = imgRect.size;
 
 // set offscreen context
 NSGraphicsContext *g = [NSGraphicsContext graphicsContextWithBitmapImageRep:theOffscreenRep];
 [NSGraphicsContext saveGraphicsState];
 [NSGraphicsContext setCurrentContext:g];
 
 // draw first stroke with Cocoa
 NSPoint p1 = NSMakePoint(NSMaxX(imgRect), NSMinY(imgRect));
 NSPoint p2 = NSMakePoint(NSMinX(imgRect), NSMaxY(imgRect));
 [NSBezierPath strokeLineFromPoint:p1 toPoint:p2];
 
 // draw second stroke with Core Graphics
 CGContextRef ctx = [g CGContext];
 CGContextBeginPath(ctx);
 CGContextMoveToPoint(ctx, 0.0, 0.0);
 CGContextAddLineToPoint(ctx, imgSize.width, imgSize.height);
 CGContextClosePath(ctx);
 CGContextStrokePath(ctx);
 
 // done drawing, so set the current context back to what it was
 [NSGraphicsContext restoreGraphicsState];
 
 // create an NSImage and add the rep to it
 NSImage *img = [[NSImage alloc] initWithSize:imgSize];
 [img addRepresentation:theOffscreenRep];
 
 }
 */

/*
- (id)initWithPathImage:(NSString*)thePath
{
    if (self = [super init]) {
        
        NSRect imgRect = NSMakeRect(0.0, 0.0, 100.0, 150.0);
        NSSize imgSize = imgRect.size;
        
        self->theOffscreenRep = [[NSBitmapImageRep alloc]
                                 initWithBitmapDataPlanes:NULL
                                 pixelsWide:imgSize.width
                                 pixelsHigh:imgSize.height
                                 bitsPerSample:8
                                 samplesPerPixel:4
                                 hasAlpha:YES
                                 isPlanar:NO
                                 colorSpaceName:NSDeviceRGBColorSpace
                                 bitmapFormat:NSBitmapFormatAlphaFirst
                                 bytesPerRow:0
                                 bitsPerPixel:0];
        
        
        [self drawIntoBitmap];
        
        bool result = [self saveAsPNGWithFilename:[thePath stringByAppendingPathExtension:@"png"]];
        
        [self drawIntoPDF:[thePath stringByAppendingPathExtension:@"pdf"]];
        
        NSLog(result ? @"Yes" : @"No");
        
        
        NSLog(@"Done: %@\n\n\n",thePath);
    }
    
    return self;
}
*/


@end


