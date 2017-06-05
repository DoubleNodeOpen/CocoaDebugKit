//
//  CocoaDebugDescription.m
//  CocoaDebugKit
//
//  Created by Patrick Kladek on 19.04.16.
//  Copyright (c) 2016 Patrick Kladek. All rights reserved.
//

#import "CocoaDebugDescription.h"
#import "CocoaPropertyEnumerator.h"
#import "CocoaDebugSettings.h"
#import "NSObject+CPAdditions.h"


@interface CocoaDebugDescription ()
{
	CocoaPropertyEnumerator *propertyEnumerator;
	NSMutableArray *lines;
	NSInteger typeLength;
}

@end



@implementation CocoaDebugDescription

+ (CocoaDebugDescription *)debugDescription
{
	CocoaDebugDescription *description = [[self alloc] init];
	return description;
}

+ (CocoaDebugDescription *)debugDescriptionForObject:(NSObject *)obj
{
	CocoaDebugDescription *description = [[self alloc] init];
	[description addAllPropertiesFromObject:obj];
	return description;
}

- (instancetype)init
{
	self = [super init];
	if (self)
	{
		propertyEnumerator = [[CocoaPropertyEnumerator alloc] init];
		lines = [NSMutableArray array];
		typeLength = 0;
		
		CocoaDebugSettings *settings = [CocoaDebugSettings sharedSettings];
		
		self.dataMaxLength	= settings.maxDataLength;
		self.save			= settings.save;
		self.saveUrl		= settings.saveUrl;
	}
	return self;
}


- (void)addAllPropertiesFromObject:(NSObject *)obj
{
	_obj = obj;
	
	Class currentClass = [obj class];
	
	while (currentClass != nil && currentClass != [NSObject class])
	{
		[propertyEnumerator enumeratePropertiesFromClass:currentClass allowed:nil block:^(NSString *type, NSString *name) {
			[self addProperty:name type:type fromObject:obj];
		}];
		
		currentClass = [currentClass superclass];
	}
}

- (void)addProperty:(NSString *)name type:(NSString *)type fromObject:(NSObject *)obj
{
	if (!_obj) {
		_obj = obj;
	}
	
	
	Class class = NSClassFromString(type);
	
	if ([class isSubclassOfClass:[NSData class]])
	{
		NSData *data = [obj valueForKey:name];
		
		// cut length to 100 byte
		if ([data length] > self.dataMaxLength.unsignedIntegerValue)
		{
			data = [data subdataWithRange:NSMakeRange(0, self.dataMaxLength.unsignedIntegerValue)];
		}
		
		[self addDescriptionLine:[CocoaPropertyLine lineWithType:type name:name value:[data description]]];
		return;
	}
	
	if ([class isSubclassOfClass:[CPImage class]])
	{
		CPImage *image = [obj valueForKey:name];
		NSString *imageDescription = [NSString stringWithFormat:@"size: %.0fx%.0f", image.size.width, image.size.height];
		[self addDescriptionLine:[CocoaPropertyLine lineWithType:type name:name value:imageDescription]];
		return;
	}
	
	
	id value = [obj valueForKey:name];
	NSString *description = [[value description] stringByReplacingOccurrencesOfString:@"\n" withString:[NSString stringWithFormat:@"\n%@", [self _spaceFromLength:4]]];
	[self addDescriptionLine:[CocoaPropertyLine lineWithType:type name:name value:description]];
}

- (NSString *)stringRepresentation
{
	NSMutableString *string = [NSMutableString stringWithFormat:@"<%p> %@ {\n", _obj, _obj.cp_className];
	for (CocoaPropertyLine *line in lines)
	{
		NSUInteger deltaLength = ((NSUInteger)typeLength - (line.type.length + line.name.length));
		[string appendFormat:@"\t%@%@ %@ = %@\n", line.type, [self _spaceFromLength:deltaLength], line.name, line.value];
	}
	
	[string appendString:@"}"];
	return string;
}




- (void)saveDebugDescription
{
	NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
	NSString *appVersion = [infoDict objectForKey:@"CFBundleShortVersionString"]; 	// example: 1.0.0
	NSString *buildNumber = [infoDict objectForKey:@"CFBundleVersion"]; 			// example: 42
	
	NSURL *url = [_saveUrl URLByAppendingPathComponent:appVersion];
	url = [url URLByAppendingPathComponent:buildNumber];
	
	NSError *error;
	if (![[NSFileManager defaultManager] createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error])
	{
		NSLog(@"%@", error);
		return;
	}
	
	NSString *className = [_obj cp_className];
	
	NSDictionary *debuggedObjects = [[CocoaDebugSettings sharedSettings] debuggedObjects];
	NSInteger debuggedCount = [[debuggedObjects valueForKey:className] integerValue];
	debuggedCount++;
	[debuggedObjects setValue:[NSNumber numberWithInteger:debuggedCount] forKey:className];
	url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@ %li.txt", className, (long)debuggedCount]];
	
	[self saveDebugDescriptionToUrl:url error:nil];
}

- (BOOL)saveDebugDescriptionToUrl:(NSURL *)url error:(NSError **)error
{
	return [[self stringRepresentation] writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:error];
}

#pragma mark - Private

- (NSString *)_spaceFromLength:(NSUInteger)length
{
	NSMutableString *string = [[NSMutableString alloc] initWithCapacity:length];
	for (NSUInteger i = 0; i < length; i++) {
		[string appendString:@" "];
	}
	return string;
}

- (void)addDescriptionLine:(CocoaPropertyLine *)line
{
	if ((NSInteger)(line.type.length + line.name.length) > typeLength) {
		typeLength = (NSInteger)(line.type.length + line.name.length);
	}
	
	[lines addObject:line];
}

@end
