//
//  ProgressBarImage.m
//  KeynoteProgressBarHelper
//
//  Created by Andrea Alberti on 15.01.19.
//  Copyright © 2019 Andrea Alberti. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ProgressBarImage.h"

@implementation ProgressBarImage

- (void)drawGrassIntoBitmap:(NSBitmapImageRep*) bitmap
{
    NSLog(@"%@",@"hello");
    
    NSGraphicsContext* ctx = [NSGraphicsContext graphicsContextWithBitmapImageRep: bitmap];
    
    [[NSColor colorWithRed: 124 / 255 green: 252 / 255 blue: 0 alpha: 1.0] set];
    
    NSBezierPath* path = [NSBezierPath bezierPath];
    
    [path moveToPoint:NSMakePoint(0,0)];
    
    for i in stride(from: 0, through: SIZE.width, by: 40)
    {
        path.lineToPoint(NSPoint(x: CGFloat(i + 20), y: CGFloat(arc4random_uniform(400))))
        path.lineToPoint(NSPoint(x: i + 40, y: 0))
    }
    
    
    /*
    
    
    let path = NSBezierPath()
    
    path.moveToPoint(NSPoint(x: 0, y: 0))
    
    for i in stride(from: 0, through: SIZE.width, by: 40)
    {
        path.lineToPoint(NSPoint(x: CGFloat(i + 20), y: CGFloat(arc4random_uniform(400))))
        path.lineToPoint(NSPoint(x: i + 40, y: 0))
    }
    
    path.stroke()
    path.fill()
    */
}


- (id)initWithPathImage:(NSString*)thePath
{
    if (self = [super init]) {
        
        
        CGSize SIZE = CGSizeMake(800, 400);
        
        
        NSBitmapImageRep* grass;
        
        grass = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes: nil pixelsWide: SIZE.width pixelsHigh: SIZE.height bitsPerSample: 8 samplesPerPixel: 4 hasAlpha: true isPlanar: false colorSpaceName: NSDeviceRGBColorSpace bytesPerRow: 0 bitsPerPixel: 0];
        
        [self drawGrassIntoBitmap: grass];
        //saveAsPNGWithName(Process.arguments[1], grass!)
        
        
        
        NSLog(@"Done: %@\n\n\n",thePath);
    }
    
    return self;
}

@end


