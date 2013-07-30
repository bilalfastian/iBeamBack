//
//  BadgeView.m
//  iBeamBack
//
//  Created by Bilal Nazir on 4/14/11.
//  Copyright 2011 iBeamBack. All rights reserved.
//

#import "BadgeView.h"

@interface BadgeView ()
//
// private methods
//
- (void)initState;
- (CGPathRef)createBadgePathForTextSize:(CGSize)inSize;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation BadgeView

@synthesize value=_value;
@synthesize shadow=_shadow;
@synthesize shine=_shine;
@synthesize font=_font;
@synthesize fillColor=_fillColor;
@synthesize strokeColor=_strokeColor;
@synthesize textColor=_textColor;
@synthesize alignment=_alignment;
@dynamic badgeSize;
@synthesize pad=_pad;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) 
	{
        // Initialization code
		
		[self initState];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
	if (self) 
	{
        // Initialization code
		[self initState];
    }
    return self;
}


#pragma mark -- private methods --

- (void)initState;
{	
	self.opaque = NO;
	self.pad = 4;
	self.font = [UIFont boldSystemFontOfSize:16];
	self.shadow = YES;
	self.shine = YES;
	self.alignment = UITextAlignmentCenter;
	self.fillColor = [UIColor redColor];
	self.strokeColor = [UIColor whiteColor];
	self.textColor = [UIColor whiteColor];
	
	self.backgroundColor = [UIColor clearColor];
}

- (void)dealloc 
{
	[_font release];
	[_fillColor release];
	[_strokeColor release];
	[_textColor release];
	
    [super dealloc];
}


- (void)drawRect:(CGRect)rect 
{
	CGRect viewBounds = self.bounds;
	
	CGContextRef curContext = UIGraphicsGetCurrentContext();
    
	NSString* numberString = [NSString stringWithFormat:@"%d",self.value];
	
	
	CGSize numberSize = [numberString sizeWithFont:self.font];
    
	CGPathRef badgePath = [self createBadgePathForTextSize:numberSize];
	
	CGRect badgeRect = CGPathGetBoundingBox(badgePath);
	
	badgeRect.origin.x = 0;
	badgeRect.origin.y = 0;
	badgeRect.size.width = ceil( badgeRect.size.width );
	badgeRect.size.height = ceil( badgeRect.size.height );
	
	
	CGContextSaveGState( curContext );
	CGContextSetLineWidth( curContext, 2.0 );
	CGContextSetStrokeColorWithColor(  curContext, self.strokeColor.CGColor  );
	CGContextSetFillColorWithColor( curContext, self.fillColor.CGColor );
    
	CGPoint ctm;
	
	switch (self.alignment) 
	{
		default:
		case UITextAlignmentCenter:
			ctm = CGPointMake( round((viewBounds.size.width - badgeRect.size.width)/2), round((viewBounds.size.height - badgeRect.size.height)/2) );
			break;
		case UITextAlignmentLeft:
			ctm = CGPointMake( 0, round((viewBounds.size.height - badgeRect.size.height)/2) );
			break;
		case UITextAlignmentRight:
			ctm = CGPointMake( (viewBounds.size.width - badgeRect.size.width), round((viewBounds.size.height - badgeRect.size.height)/2) );
			break;
	}
	
	CGContextTranslateCTM( curContext, ctm.x, ctm.y);
    
	if (self.shadow)
	{
		CGContextSaveGState( curContext );
        
		CGSize blurSize;
		blurSize.width = 0;
		blurSize.height = -3;
		UIColor* blurColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
		
		CGContextSetShadowWithColor( curContext, blurSize, 4, blurColor.CGColor );
		
		CGContextBeginPath( curContext );
		CGContextAddPath( curContext, badgePath );
		CGContextClosePath( curContext );
		
		CGContextDrawPath( curContext, kCGPathFillStroke );
		CGContextRestoreGState(curContext); 
	}
	
	CGContextBeginPath( curContext );
	CGContextAddPath( curContext, badgePath );
	CGContextClosePath( curContext );
	CGContextDrawPath( curContext, kCGPathFillStroke );
    
	//
	// add shine to badge
	//
	
	if (self.shine)
	{
		CGContextBeginPath( curContext );
		CGContextAddPath( curContext, badgePath );
		CGContextClosePath( curContext );
		CGContextClip(curContext);
		
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
		CGFloat shinyColorGradient[8] = {1, 1, 1, 0.8, 1, 1, 1, 0}; 
		CGFloat shinyLocationGradient[2] = {0, 1}; 
		CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, 
                                                                     shinyColorGradient, 
                                                                     shinyLocationGradient, 2);
		
		CGContextSaveGState(curContext); 
		CGContextBeginPath(curContext); 
		CGContextMoveToPoint(curContext, 0, 0); 
		
		CGFloat shineStartY = badgeRect.size.height*0.25;
		CGFloat shineStopY = shineStartY + badgeRect.size.height*0.4;
		
		CGContextAddLineToPoint(curContext, 0, shineStartY); 
		CGContextAddCurveToPoint(curContext, 0, shineStopY, 
                                 badgeRect.size.width, shineStopY, 
                                 badgeRect.size.width, shineStartY); 
		CGContextAddLineToPoint(curContext, badgeRect.size.width, 0); 
		CGContextClosePath(curContext); 
		CGContextClip(curContext); 
		CGContextDrawLinearGradient(curContext, gradient, 
									CGPointMake(badgeRect.size.width / 2.0, 0), 
									CGPointMake(badgeRect.size.width / 2.0, shineStopY), 
									kCGGradientDrawsBeforeStartLocation); 
		CGContextRestoreGState(curContext); 
		
		CGColorSpaceRelease(colorSpace); 
		CGGradientRelease(gradient); 
		
	}
	CGContextRestoreGState( curContext );
	CGPathRelease(badgePath);
	
	CGContextSaveGState( curContext );
	CGContextSetFillColorWithColor( curContext, self.textColor.CGColor );
    
	CGPoint textPt = CGPointMake( ctm.x + (badgeRect.size.width - numberSize.width)/2 , ctm.y + (badgeRect.size.height - numberSize.height)/2 );
	
	[numberString drawAtPoint:textPt withFont:self.font];
    
	CGContextRestoreGState( curContext );
    
}


- (CGPathRef)createBadgePathForTextSize:(CGSize)inSize
{
	const CGFloat kPi = 3.14159265;
	
	CGFloat arcRadius = ceil((inSize.height+self.pad)/2.0);
	
	CGFloat badgeWidthAdjustment = inSize.width - inSize.height/2.0;
	CGFloat badgeWidth = 2.0*arcRadius;
	
	if ( badgeWidthAdjustment > 0.0 )
	{
		badgeWidth += badgeWidthAdjustment;
	}
	else
	{
		badgeWidthAdjustment = 0;
	}
	
	
	CGMutablePathRef badgePath = CGPathCreateMutable();
	
	CGPathMoveToPoint( badgePath, NULL, arcRadius, 0 );
	CGPathAddArc( badgePath, NULL, arcRadius, arcRadius, arcRadius, 3.0*kPi/2.0, kPi/2.0, YES);
	CGPathAddLineToPoint( badgePath, NULL, badgeWidth-arcRadius, 2.0*arcRadius);
	CGPathAddArc( badgePath, NULL, badgeWidth-arcRadius, arcRadius, arcRadius, kPi/2.0, 3.0*kPi/2.0, YES);
	CGPathAddLineToPoint( badgePath, NULL, arcRadius, 0 );
	
	return badgePath;
	
}

#pragma mark -- property methods --

- (void)setValue:(NSUInteger)inValue
{
	_value = inValue;
	
	[self setNeedsDisplay];
}

- (CGSize)badgeSize
{
	NSString* numberString = [NSString stringWithFormat:@"%d",self.value];
	
	
	CGSize numberSize = [numberString sizeWithFont:self.font];
	
	CGPathRef badgePath = [self createBadgePathForTextSize:numberSize];
	
	CGRect badgeRect = CGPathGetBoundingBox(badgePath);
	
	badgeRect.origin.x = 0;
	badgeRect.origin.y = 0;
	badgeRect.size.width = ceil( badgeRect.size.width );
	badgeRect.size.height = ceil( badgeRect.size.height );
	
	CGPathRelease(badgePath);
	
	return badgeRect.size;
}

@end

