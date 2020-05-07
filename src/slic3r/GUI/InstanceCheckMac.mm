#import "InstanceCheck.hpp"
#import "InstanceCheckMac.h"
#import "GUI_App.hpp"

@implementation OtherInstanceMessageHandlerMac

-(instancetype) init
{
	self = [super init];
	return self;
}
-(void)add_observer:(NSString *)version_hash
{
	//NSLog(@"adding observer");
	NSString *nsver = @"OtherPrusaSlicerInstanceMessage" + version_hash
	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(message_update:) name:nsver object:nil suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];
}

-(void)message_update:(NSNotification *)msg
{
	//NSLog(@"recieved msg %@", msg);	
	//demiaturize all windows
	for(NSWindow* win in [NSApp windows])
	{
		if([win isMiniaturized])
		{
			[win deminiaturize:self];
		}
	}
	//bring window to front 
	[[NSApplication sharedApplication] activateIgnoringOtherApps : YES];
	//pass message  
	Slic3r::GUI::wxGetApp().other_instance_message_handler()->handle_message(std::string([msg.userInfo[@"data"] UTF8String]));
}

@end

namespace Slic3r {

void send_message_mac(const std::string &msg, const std::string &version)
{
	NSString *nsmsg = [NSString stringWithCString:msg.c_str() encoding:[NSString defaultCStringEncoding]];
	NSString *nsver = @"OtherPrusaSlicerInstanceMessage" + [NSString stringWithCString:version.c_str() encoding:[NSString defaultCStringEncoding]];
	//NSLog(@"sending msg %@", nsmsg);
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:nsver object:nil userInfo:[NSDictionary dictionaryWithObject:nsmsg forKey:@"data"] deliverImmediately:YES];
}

namespace GUI {
void OtherInstanceMessageHandler::register_for_messages(const std::string &version_hash)
{
	m_impl_osx = [[OtherInstanceMessageHandlerMac alloc] init];
	if(m_impl_osx) {
		NSString *nsver = [NSString stringWithCString:version_hash.c_str() encoding:[NSString defaultCStringEncoding]];
		[m_impl_osx add_observer:nsver];
	}
}

void OtherInstanceMessageHandler::unregister_for_messages()
{
	//NSLog(@"unreegistering other instance messages");
	if (m_impl_osx) {
        [m_impl_osx release];
        m_impl_osx = nullptr;
    } else {
		NSLog(@"unreegister not required");
	}
}
}//namespace GUI
}//namespace Slicer


