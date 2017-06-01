//
//  CocoaDebugSettings.m
//  CocoaDebugKit
//
//  Created by Patrick Kladek on 19.04.16.
//  Copyright (c) 2016 Patrick Kladek. All rights reserved.
//

#import "CocoaDebugSettings.h"


static CPColor *NSColorFromHexString(NSString *inColorString)
{
	CPColor *result = nil;
	unsigned colorCode = 0;
	unsigned char redByte, greenByte, blueByte, alphaByte;
	
	if (nil != inColorString)
	{
		NSScanner *scanner = [NSScanner scannerWithString:inColorString];
		(void) [scanner scanHexInt:&colorCode]; // ignore error
	}
	redByte = (unsigned char)(colorCode >> 24);
	greenByte = (unsigned char)(colorCode >> 16);
	blueByte = (unsigned char)(colorCode >> 8);
	alphaByte = (unsigned char)(colorCode);		// masks off high bits
	
	result = [CPColor colorWithRed:(CGFloat)redByte / 0xff green:(CGFloat)greenByte / 0xff blue:(CGFloat)blueByte / 0xff alpha:(CGFloat)alphaByte / 0xff];
	return result;
}


@interface CocoaDebugSettings ()
{
	NSDictionary *settings;
}

@end



@implementation CocoaDebugSettings

+ (CocoaDebugSettings *)sharedSettings
{
	__strong static id _sharedObject = nil;
	
	static dispatch_once_t p = 0;

	dispatch_once(&p, ^{
		_sharedObject = [[self alloc] init];
	});
	
	return _sharedObject;
}

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		_lineSpace				= 7;
		_highlightKeywords		= true;
		_highlightNumbers		= true;
		
		_textColor				= [CPColor blackColor];
		_textFont				= [CPFont fontWithName:@"Menlo" size:12];
		
		_keywordColor			= [CPColor colorWithRed:0.592 green:0.000 blue:0.496 alpha:1.000];
		_keywordFont			= [CPFont fontWithName:@"Menlo" size:12];
		
		_numberColor			= [CPColor colorWithRed:0.077 green:0.000 blue:0.766 alpha:1.000];
		_numberFont				= [CPFont fontWithName:@"Menlo" size:12];
		
		_propertyNameColor		= [CPColor grayColor];
		_propertyNameFont		= [CPFont fontWithName:@"Menlo" size:12];
		
		_titleColor				= [CPColor whiteColor];
		_titleFont				= [CPFont fontWithName:@"Menlo-Bold" size:13];
		
		
		_frameColor				= [CPColor blueColor];
		_backgroundColor		= [CPColor whiteColor];
		_imageSize				= CPMakeSize(30, 30);
		
		_maxSizeOfField			= CGSizeMake(300, 500);
		_maxDataLenght			= [NSNumber numberWithInteger:50];
		_convertDataToImage		= true;
		_propertyNameContains 	= @[@"image", @"icon"];
		
		_dateFormat				= @"yyyy-MM-dd 'at' HH:mm";
		_numberOfBitsPerColorComponent = 8;
		
		_save = NO;
		_saveUrl = [NSURL fileURLWithPath:[@"~/Desktop" stringByExpandingTildeInPath]];
		_saveAsPDF = NO;
		
		_debuggedObjects 		= [NSMutableDictionary dictionary];
	}
	return self;
}

- (BOOL)loadSettings:(NSURL *)url
{
	_url = url;
	
	settings = [NSDictionary dictionaryWithContentsOfURL:_url];
	
	if (settings)
	{
		[self importSettings];
		return YES;
	}
	
	return NO;
}

- (BOOL)saveSettings:(NSURL *)url
{
	@throw @"not implemented";
	return NO;
}

- (void)importSettings
{
	if ([settings valueForKeyPath:@"debugView.keywords.highlight"]) {
		_highlightKeywords = [[settings valueForKeyPath:@"debugView.keywords.highlight"] boolValue];
	}
	
	if ([settings valueForKeyPath:@"debugView.keywords.color"]) {
		_keywordColor = NSColorFromHexString([settings valueForKeyPath:@"debugView.keywords.color"]);
	}
	
	if ([settings valueForKeyPath:@"debugView.keywords.font"] && [settings valueForKeyPath:@"debugView.keywords.size"]) {
		_keywordFont = [CPFont fontWithName:[settings valueForKeyPath:@"debugView.keywords.font"] size:[[settings valueForKeyPath:@"debugView.keywords.size"] integerValue]];
	}
	
	
	
	
	if ([settings valueForKeyPath:@"debugView.numbers.highlight"]) {
		_highlightNumbers = [[settings valueForKeyPath:@"debugView.numbers.highlight"] boolValue];
	}
	
	if ([settings valueForKeyPath:@"debugView.numbers.color"]) {
		_numberColor = NSColorFromHexString([settings valueForKeyPath:@"debugView.numbers.color"]);
	}
	
	if ([settings valueForKeyPath:@"debugView.numbers.font"] && [settings valueForKeyPath:@"debugView.numbers.size"]) {
		_numberFont = [CPFont fontWithName:[settings valueForKeyPath:@"debugView.numbers.font"] size:[[settings valueForKeyPath:@"debugView.numbers.size"] integerValue]];
	}
	
	
	
	
	
	if ([settings valueForKeyPath:@"debugView.text.color"]) {
		_textColor = NSColorFromHexString([settings valueForKeyPath:@"debugView.text.color"]);
	}
	
	if ([settings valueForKeyPath:@"debugView.text.font"] && [settings valueForKeyPath:@"debugView.text.size"]) {
		_textFont = [CPFont fontWithName:[settings valueForKeyPath:@"debugView.text.font"] size:[[settings valueForKeyPath:@"debugView.text.size"] integerValue]];
	}
	
	
	
	
	if ([settings valueForKeyPath:@"debugView.propertyName.color"]) {
		_propertyNameColor = NSColorFromHexString([settings valueForKeyPath:@"debugView.propertyName.color"]);
	}
	
	if ([settings valueForKeyPath:@"debugView.propertyName.font"] && [settings valueForKeyPath:@"debugView.propertyName.size"]) {
		_propertyNameFont = [CPFont fontWithName:[settings valueForKeyPath:@"debugView.propertyName.font"] size:[[settings valueForKeyPath:@"debugView.propertyName.size"] integerValue]];
	}
	
	
	
	if ([settings valueForKeyPath:@"debugView.title.color"]) {
		_titleColor = NSColorFromHexString([settings valueForKeyPath:@"debugView.title.color"]);
	}
	
	if ([settings valueForKeyPath:@"debugView.title.font"] && [settings valueForKeyPath:@"debugView.title.size"]) {
		_titleFont = [CPFont fontWithName:[settings valueForKeyPath:@"debugView.title.font"] size:[[settings valueForKeyPath:@"debugView.title.size"] integerValue]];
	}
	
	
	
	if ([settings valueForKeyPath:@"debugView.image.size"]) {
		_imageSize = CPSizeFromString([settings valueForKeyPath:@"debugView.image.size"]);
	}
	
	
	
	
	if ([settings valueForKeyPath:@"debugView.appearance.lineSpace"]) {
		_lineSpace = [[settings valueForKeyPath:@"debugView.appearance.lineSpace"] integerValue];
	}
	
	if ([settings valueForKeyPath:@"debugView.appearance.backgroundColor"]) {
		_backgroundColor = NSColorFromHexString([settings valueForKeyPath:@"debugView.appearance.backgroundColor"]);
	}
	
	if ([settings valueForKeyPath:@"debugView.appearance.frameColor"]) {
		_frameColor = NSColorFromHexString([settings valueForKeyPath:@"debugView.appearance.frameColor"]);
	}
	
	if ([settings valueForKeyPath:@"debugView.appearance.numberOfBitsPerColorComponent"]) {
		_numberOfBitsPerColorComponent = [[settings valueForKeyPath:@"debugView.appearance.numberOfBitsPerColorComponent"] integerValue];
	}
	
	
	
	
	if ([settings valueForKeyPath:@"debugDescription.NSData.cutLenght"])
	{
		_maxDataLenght = [settings valueForKeyPath:@"debugDescription.NSData.cutLenght"];
	}
	
	if ([settings valueForKeyPath:@"debugView.image.dataToImage"]) {
		_convertDataToImage = [[settings valueForKeyPath:@"debugView.image.dataToImage"] boolValue];
	}
	
	if ([settings valueForKeyPath:@"debugView.image.propertyNameContains"]) {
		_propertyNameContains = [settings valueForKeyPath:@"debugView.image.propertyNameContains"];
	}
	
	
	if ([settings valueForKeyPath:@"debugView.appearance.save"]) {
		_save = [[settings valueForKeyPath:@"debugView.appearance.save"] boolValue];
	}
	
	if ([settings valueForKeyPath:@"debugView.appearance.path"]) {
		_saveUrl = [NSURL fileURLWithPath:[[settings valueForKeyPath:@"debugView.appearance.path"] stringByExpandingTildeInPath]];
	}
	
	if ([settings valueForKeyPath:@"debugView.appearance.usePDF"]) {
		_saveAsPDF = [[settings valueForKeyPath:@"debugView.appearance.usePDF"] boolValue];
	}
	
	if ([settings valueForKeyPath:@"debugView.appearance.maxFieldSize.width"] && [settings valueForKeyPath:@"debugView.appearance.maxFieldSize.height"]) {
		_maxSizeOfField.width = [[settings valueForKeyPath:@"debugView.appearance.maxFieldSize.width"] floatValue];
		_maxSizeOfField.height = [[settings valueForKeyPath:@"debugView.appearance.maxFieldSize.height"] floatValue];
	}

	
	
	if ([settings valueForKeyPath:@"debugView.NSDate.format"]) {
		_dateFormat = [settings valueForKeyPath:@"debugView.NSDate.format"];
	}
}

@end
