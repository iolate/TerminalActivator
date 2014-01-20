#import <Foundation/Foundation.h>
#import <Preferences/Preferences.h>
#import <UIKit/UIKit.h>
#import <libactivator/libactivator.h>

#define SettingPath @"/var/mobile/Library/Preferences/kr.iolate.TerminalActivator.plist"
#define LS(a) a

@interface TerminalActivatorSettingsListController: PSListController {
}
@end

@implementation TerminalActivatorSettingsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"TerminalActivatorSettings" target:self] retain];
	}
	return _specifiers;
}
@end

@interface LAEventSettingsController ()
- (void)updateHeader;
@end

@interface eventActivator : LAEventSettingsController
{
    NSString* num;
}

- (id)initWithName:(NSString *)mName;
//- (id)initWithModes:(NSArray *)modes eventName:(NSString *)eventName;
- (void)viewWillDisappear:(BOOL)animated;
- (void)updateHeader;
- (void)setRootController:(id)fp8;

@property(nonatomic, retain) NSString* num;
@end

@interface AddNoties : PSViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
    UITableView *_tableView;
    NSMutableDictionary* dicList;
    NSMutableString *_title;
    UIView *window;
    UIView *__view;
    
    UIAlertView* urlAlert;
    UITextField* urlText;
}

+(AddNoties *)sharedInstance;
- (void)loadSetting;
- (id)init;
- (id) view;
- (id)_tableView;
- (id) navigationTitle;

@property(nonatomic, retain) UIAlertView* urlAlert;
@property(nonatomic, retain) UITextField* urlText;
@end


@implementation eventActivator
@synthesize num;
-(id)initWithName:(NSString *)mName
{   
    NSString* assignedLName = @"";
    num = [[NSString alloc] initWithString:mName];
    
    LAEvent *event = [[[LAEvent alloc] initWithName:@"kr.iolate.terminalactivator.event"] autorelease];
    [LASharedActivator unassignEvent:event];
    
    NSDictionary* dic;
    
    if([[NSFileManager defaultManager] fileExistsAtPath:SettingPath])
        dic = [[NSMutableDictionary alloc] initWithContentsOfFile:SettingPath];
    else
        dic = [[NSMutableDictionary alloc] init];
    
    if ([[dic allKeys] containsObject:mName]) {
        assignedLName = [dic objectForKey:mName];
        
        if (assignedLName.length > 12)
            if ([[assignedLName substringToIndex:12] isEqualToString:@"libactivator"])
                assignedLName = [assignedLName substringFromIndex:13];
    }
    
    
    [dic release];
    if (![assignedLName isEqualToString:@""])
        [LASharedActivator assignEvent:event toListenerWithName:assignedLName];
    
    //===============================================
    
    LAEventSettingsController* superObject = [super initWithModes:[NSArray arrayWithObjects:@"springboard", @"lockscreen", @"application", nil] eventName:@"kr.iolate.terminalactivator.event"];
    
    superObject.navigationItem.title = @"TerminalActivator";
    
    return (eventActivator *)superObject;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    LAEvent *event = [[[LAEvent alloc] initWithName:@"kr.iolate.terminalactivator.event"] autorelease];
    
    [LASharedActivator unassignEvent:event];
}

- (void)updateHeader
{
    [super updateHeader];

    LAEvent *event = [[[LAEvent alloc] initWithName:@"kr.iolate.terminalactivator.event"] autorelease];

    NSString* listenerName = [LASharedActivator assignedListenerNameForEvent:event];
    
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithContentsOfFile:SettingPath];

    if (listenerName) {
        [dic setObject:[NSString stringWithFormat:@"libactivator.%@", listenerName] forKey:num];
    }else
    {
        listenerName = @"";
        [dic setObject:@"" forKey:num];
    }
    [dic writeToFile:SettingPath atomically:NO];
    [dic release];
    
    [[AddNoties sharedInstance] loadSetting];
    [[[AddNoties sharedInstance] _tableView] reloadData];

    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("kr.iolate.terminalactivator.reloadsetting"), NULL, NULL, true);

}

- (void)setRootController:(id)fp8
{
    //for iOS4
    return;
}

@end


static AddNoties* sharedInstance;

@implementation AddNoties
@synthesize urlAlert, urlText;
+(AddNoties *)sharedInstance
{
    return sharedInstance;
}

-(void)loadSetting
{
    if (dicList)
    {
        [dicList release];
        dicList = nil;
    }
    
    if([[NSFileManager defaultManager] fileExistsAtPath:SettingPath])
       dicList = [[NSMutableDictionary alloc] initWithContentsOfFile:SettingPath];
    else
       dicList = [[NSMutableDictionary alloc] init];

}

-(id) init
{
    if ((self = [super init])) {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        
        sharedInstance = self;
        dicList = nil;
        
        [self loadSetting];     
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 416) style:UITableViewStylePlain];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        
        __view = nil;
		window = [[UIApplication sharedApplication] keyWindow];
		if (window == nil) {
			__view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-64)];
			[__view addSubview:_tableView];
			window = __view;
		}
        
        if(!_title)
			_title = [[NSMutableString alloc] init];
        
		[_title setString:LS(@"TerminalActivator")];
        
        if ([self respondsToSelector:@selector(navigationItem)]) {
			[[self navigationItem] setTitle:_title];
		}
        
        [pool drain];
    }
    
    return self;
}

- (id) view {
    if (__view)
        return __view;
    
    return _tableView;
}

- (id) _tableView {
    return _tableView;
}

- (id) navigationTitle {
    return _title;
}

-(void)showAlertView
{
    if (urlAlert)
    {
        [urlAlert release];
        urlAlert = nil;
    }
    
    if (urlText)
    {
        [urlText release];
        urlText = nil;
    }
    
    urlAlert = [[UIAlertView alloc] initWithTitle:LS(@"New Noti Name")
                                          message:@"\n\n"
                                         delegate:self
                                cancelButtonTitle:LS(@"Cancel")
                                otherButtonTitles:LS(@"Complete"), nil];
    
    urlText = [[UITextField alloc] initWithFrame:CGRectMake(25.0f, 55.0f, 230.0f, 31.0f)];
    
    [urlText setBorderStyle:UITextBorderStyleRoundedRect];
    urlAlert.tag = 1;
    urlText.tag = 1;
    urlText.delegate = self;
    urlText.text = @"";
    urlText.clearButtonMode = UITextFieldViewModeAlways;
    [urlAlert addSubview:urlText];
    
    [urlAlert show];
    [urlText becomeFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 1) {
        if ([[dicList allKeys] containsObject:urlText.text]) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"AppDialer"
                                                            message:LS(@"This name is existed.")
                                                           delegate:self
                                                  cancelButtonTitle:LS(@"OK")
                                                  otherButtonTitles:nil];
            alert.tag = 2;
            [alert show];
            [alert release];
        }else {
            [dicList setObject:@"" forKey:urlText.text];
            
            [dicList writeToFile:SettingPath atomically:NO];
            
            [_tableView reloadData];
            
            //NSString* numText = [NSString stringWithString:urlText.text];
            
            eventActivator *vac = [[[eventActivator alloc] initWithName:[NSString stringWithString:urlText.text]] autorelease];
            [self pushController:vac];
        }
        
        [urlAlert dismissWithClickedButtonIndex:0 animated:YES];
    }
        
    
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex { 
	if (alertView.tag == 1 && buttonIndex == 1) {

        if ([[dicList allKeys] containsObject:urlText.text]) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"AppDialer"
                                                            message:LS(@"This name is existed.")
                                                           delegate:self
                                                  cancelButtonTitle:LS(@"OK")
                                                  otherButtonTitles:nil];
            alert.tag = 2;
            [alert show];
            [alert release];
        }else {
            [dicList setObject:@"" forKey:urlText.text];
            
            [dicList writeToFile:SettingPath atomically:NO];
            
            [_tableView reloadData];
            
            //NSString* numText = [NSString stringWithString:urlText.text];
            
            eventActivator *vac = [[[eventActivator alloc] initWithName:[NSString stringWithString:urlText.text]] autorelease];
            [self pushController:vac];
        }
        
    }else if (alertView.tag == 2){
        [self showAlertView];
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (id) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) return 1;
	else {
    	if(![[dicList allKeys] count])
            return 0;
        
    	return [[dicList allKeys] count];
    }
}

- (id) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellInsert = @"CellInsert";
    static NSString* Cell = @"Cell";
    
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
    	cell = [tableView dequeueReusableCellWithIdentifier:CellInsert];
    	if (cell == nil) {
    		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellInsert] autorelease];
            
    		UIButton* addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    		addButton.frame = CGRectMake(17, 8, 29, 29);
    		[cell addSubview:addButton];
    		//[addButton release];
    	}
    	
    	
    	cell.textLabel.text = [NSString stringWithFormat:@"        %@", LS(@"Add Item")];;
    	
    } else {
    	cell = [tableView dequeueReusableCellWithIdentifier:Cell];
    	if (cell == nil) {
    	    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:Cell] autorelease];
    	    
    	    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    	}
        
    	NSString* numString = [NSString stringWithString:[[[dicList allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:[indexPath row]]];
        cell.textLabel.text = numString;
        
        NSString* actionName;
        actionName = [dicList objectForKey:numString];
        
        NSMutableArray* splitS;
        if ([actionName rangeOfString:@"."].length)
            splitS = [NSMutableArray arrayWithArray:[actionName componentsSeparatedByString:@"."]];
        else
            splitS = [NSMutableArray arrayWithObjects:@"", actionName, nil];
        
        /*if ([[splitS objectAtIndex:0] isEqualToString:@"appdialer"]) {
            [splitS removeObjectAtIndex:0];
            
            cell.detailTextLabel.text = @"";
        }else  */
        if ([[splitS objectAtIndex:0] isEqualToString:@"libactivator"]) {
            [splitS removeObjectAtIndex:0];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", LS(@"Activator"), [LASharedActivator localizedTitleForListenerName:[splitS componentsJoinedByString:@"."]]];
        }else
        {
            cell.detailTextLabel.text = @"";
        }
    }
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {  
    if (indexPath.section == 0)
    	return  UITableViewCellEditingStyleInsert;
    else
    	return UITableViewCellEditingStyleDelete;
}  

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
    	[self showAlertView];
    } else {
        NSString* numText = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
        
        eventActivator *vac = [[[eventActivator alloc] initWithName:numText] autorelease];
        [self pushController:vac];
        
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.section == 1)
    	return YES;
    else
    	return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSString *identifier = [[[dicList allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:indexPath.row];
        
        if ([[dicList allKeys] containsObject:identifier]) {
            
            [dicList removeObjectForKey:identifier];
            [dicList writeToFile:SettingPath atomically:NO];
            
            CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("kr.iolate.terminalactivator.reloadsetting"), NULL, NULL, true);
        }
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }  
}

- (void) dealloc {
    [dicList release];
    [_tableView release];
    [_title release];
    [__view release];
    
    [super dealloc];
}
@end