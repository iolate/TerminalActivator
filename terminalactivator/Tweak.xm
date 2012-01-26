#import <Foundation/Foundation.h>
#import <libactivator/libactivator2.h>
#import <objc/message.h>

#define SettingPath @"/var/mobile/Library/Preferences/kr.iolate.TerminalActivator.plist"

@interface TerminalActivator : NSObject <LAEventDataSource>
{
    NSDictionary* dicList;
    NSMutableArray* addLists;
}

+(TerminalActivator *)sharedInstance;

- (void)loadSetting;
- (NSDictionary *)dicList;

- (NSString *)localizedTitleForEventName:(NSString *)eventName;
- (NSString *)localizedGroupForEventName:(NSString *)eventName;
- (NSString *)localizedDescriptionForEventName:(NSString *)eventName;
- (BOOL)eventWithNameIsHidden:(NSString *)eventName;
- (BOOL)eventWithName:(NSString *)eventName isCompatibleWithMode:(NSString *)eventMode;
@end

static void reloadSettingNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	[[TerminalActivator sharedInstance] loadSetting];
}

static void callEvent(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	
    NSString* nName = (NSString *)name;
    
    NSLog(@"callEvent %@", name);
    NSDictionary* dic = [[TerminalActivator sharedInstance] dicList];
    
    if ([[dic allKeys] containsObject:nName])
    {
        NSString* sEvent = [dic objectForKey:nName];
        
        NSMutableArray* splitS;
        
        if ([sEvent rangeOfString:@"."].length)
            splitS = [NSMutableArray arrayWithArray:[sEvent componentsSeparatedByString:@"."]];
        else
            splitS = [NSMutableArray arrayWithObjects:@"", sEvent, nil];
        
        
        if ([[splitS objectAtIndex:0] isEqualToString:@"libactivator"]) {
            [splitS removeObjectAtIndex:0];
            
            NSString* lEvent = [splitS componentsJoinedByString:@"."];
            
            LAEvent *event = [[[LAEvent alloc] initWithName:@"TerminalActivator" mode:[LASharedActivator currentEventMode]] autorelease];
            id<LAListener> listener = [LASharedActivator listenerForName:lEvent];
            objc_msgSend(listener, NSSelectorFromString(@"activator:receiveEvent:forListenerName:"), LASharedActivator, event, lEvent);
        }
        
    }
}
static TerminalActivator* sharedInstance;

@implementation TerminalActivator

+(TerminalActivator *)sharedInstance
{
    return sharedInstance; 
}

+ (void)load
{
    if ((self = [TerminalActivator class]) && [[LAActivator sharedInstance] isRunningInsideSpringBoard]) {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        
        sharedInstance = [[self alloc] init];

        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &reloadSettingNotification, CFSTR("kr.iolate.terminalactivator.reloadsetting"), NULL, CFNotificationSuspensionBehaviorCoalesce);
        
        [pool release]; 
        
    }
    
}

-(void)loadSetting
{
    if (dicList)
    {
        [dicList release];
        dicList = nil;
    }
    
    if([[NSFileManager defaultManager] fileExistsAtPath:SettingPath])
        dicList = [[NSDictionary alloc] initWithContentsOfFile:SettingPath];
    else
        dicList = [[NSDictionary alloc] init];
    
    NSArray* keys = [dicList allKeys];
    if ([keys count])
    {
        for (NSString* nName in keys)
        {
            if (![addLists containsObject:nName])
            {
                CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &callEvent, (CFStringRef)nName, NULL, CFNotificationSuspensionBehaviorCoalesce);
                [addLists addObject:nName];
            }
        }
    }
}

-(NSDictionary *)dicList
{
    if (dicList)
        return dicList;
    else
    {
        [self loadSetting];
        return dicList;
    }
}
-(id) init
{
    if ((self = [super init]))
    {
        [LASharedActivator registerEventDataSource:self forEventName:@"kr.iolate.terminalactivator.event"];
        addLists = [[NSMutableArray alloc] init];
        
        [self loadSetting];
    }
    return self;
}

- (void) dealloc
{
    if (LASharedActivator.runningInsideSpringBoard) {
        
        [LASharedActivator unregisterEventDataSourceWithEventName:@"kr.iolate.terminalactivator.event"];
        
    }
    
    [dicList release];
    [addLists release];
    
    [super dealloc];
}

- (NSString *)localizedTitleForEventName:(NSString *)eventName
{
    if ([eventName isEqualToString:@"kr.iolate.terminalactivator.event"])
        return @"TerminalActivator";
    else
        return @"TerminalActivator";
    
}

- (NSString *)localizedGroupForEventName:(NSString *)eventName
{
	return @"TerminalActivator";
}

- (NSString *)localizedDescriptionForEventName:(NSString *)eventName
{
    return nil;
}

- (BOOL)eventWithNameIsHidden:(NSString *)eventName
{
	return YES;
}

- (BOOL)eventWithName:(NSString *)eventName isCompatibleWithMode:(NSString *)eventMode
{
    return YES;
}

@end