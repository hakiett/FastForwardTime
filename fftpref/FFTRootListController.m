#import "prefs.h"
#import <spawn.h>
#import <AudioToolbox/AudioToolbox.h>

@interface FFTRootListController : PSListController {
UILabel* _label;
UILabel* underLabel;
}
- (void)HeaderCell;
@end

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation FFTRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}
/*	UIBarButtonItem *respringButton = [[UIBarButtonItem alloc]  initWithTitle:@"Respring" style:UIBarButtonItemStylePlain target:self action:@selector(respring)];
	respringButton.tintColor=[UIColor colorWithRed:1 green:0.17 blue:0.33 alpha:1];
	[UIView animateWithDuration:.5
												delay:0
											options:UIViewAnimationOptionCurveEaseInOut
									 animations:^{[self.navigationItem setRightBarButtonItem:respringButton];}
									 completion:nil];
	[(UINavigationItem *)self.navigationItem setRightBarButtonItem:respringButton];
	*/
	return _specifiers;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	// use icon instead of title text
	UIImage *icon = [UIImage imageNamed:@"icon.png" inBundle:self.bundle];
	self.navigationItem.titleView = [[UIImageView alloc] initWithImage:icon];

//	 add twitter button to the navbar
	UIImage *birdImage = [UIImage imageNamed:@"twitter.png" inBundle:self.bundle];
	UIBarButtonItem *birdButton = [[UIBarButtonItem alloc] initWithImage:birdImage style:UIBarButtonItemStylePlain target:self action:@selector(openTwitter)];
	birdButton.imageInsets = (UIEdgeInsets){2, 0, 0, 0};
	[self.navigationItem setRightBarButtonItem:birdButton];
}

- (void)HeaderCell // thanks julioverne! https://github.com/julioverne/LockAnim/blob/d0b5ad3b7bd80c4a4df73f13d0904fbf2e3f8801/lockanimsettings/LockAnimSettingsController.mm#L156
{
	@autoreleasepool {
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 120)];
	int width = [[UIScreen mainScreen] bounds].size.width;
	CGRect frame = CGRectMake(0, 20, width, 60);
		CGRect botFrame = CGRectMake(0, 55, width, 60);

		_label = [[UILabel alloc] initWithFrame:frame];
		[_label setNumberOfLines:1];
		_label.font = [UIFont fontWithName:@"GillSans" size:40];
		[_label setText:self.title];
		[_label setBackgroundColor:[UIColor clearColor]];
		_label.textColor = [UIColor blackColor];
		_label.textAlignment = NSTextAlignmentCenter;
		_label.alpha = 0;

		underLabel = [[UILabel alloc] initWithFrame:botFrame];
		[underLabel setNumberOfLines:1];
		underLabel.font = [UIFont fontWithName:@"GillSans-Light" size:26];
		[underLabel setText:@"Version 2.0.1"];
		[underLabel setBackgroundColor:[UIColor clearColor]];
		underLabel.textColor = [UIColor grayColor];
		underLabel.textAlignment = NSTextAlignmentCenter;
		underLabel.alpha = 0;

		[headerView addSubview:_label];
		[headerView addSubview:underLabel];

	[_table setTableHeaderView:headerView];

	[NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(increaseAlpha)
                                   userInfo:nil
                                    repeats:NO];

	}
}
- (void) loadView
{
	[super loadView];
	self.title = @"FastForwardTime";
	[self HeaderCell];
}
- (void)increaseAlpha
{
	[UIView animateWithDuration:0.5 animations:^{
		_label.alpha = 1;
	}completion:^(BOOL finished) {
		[UIView animateWithDuration:0.5 animations:^{
			underLabel.alpha = 1;
		}completion:nil];
	}];
}
- (void)graduallyAdjustBrightnessToValue:(CGFloat)endValue{
    CGFloat startValue = [[UIScreen mainScreen] brightness];

    CGFloat fadeInterval = 0.01;
    double delayInSeconds = 0.005;
    if (endValue < startValue)
        fadeInterval = -fadeInterval;

    CGFloat brightness = startValue;
    while (fabs(brightness-endValue)>0) {

        brightness += fadeInterval;

        if (fabs(brightness-endValue) < fabs(fadeInterval))
            brightness = endValue;

        dispatch_time_t dispatchTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(dispatchTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[UIScreen mainScreen] setBrightness:brightness];
        });
    }
    UIView *finalDarkScreen = [[UIView alloc] initWithFrame:[[UIApplication sharedApplication] keyWindow].bounds];
    finalDarkScreen.backgroundColor = [UIColor blackColor];
    finalDarkScreen.alpha = 0.3;

    //add it to the main window, but with no alpha
    [[[UIApplication sharedApplication] keyWindow] addSubview:finalDarkScreen];

    [UIView animateWithDuration:1.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         finalDarkScreen.alpha = 1.0f;
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                             //DIE
                        AudioServicesPlaySystemSound(1521);
                        sleep(1);
                             pid_t pid;
                             const char* args[] = {"killall", "-9", "backboardd", NULL};
                             posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
                         }
                     }];
}



- (void)respring {
    //make a visual effect view to fade in for the blur
    [self.view endEditing:YES]; //save changes to text fields and dismiss keyboard

    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];

    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];

    visualEffectView.frame = [[UIApplication sharedApplication] keyWindow].bounds;
    visualEffectView.alpha = 0.0;

    //add it to the main window, but with no alpha
    [[[UIApplication sharedApplication] keyWindow] addSubview:visualEffectView];

    //animate in the alpha
    [UIView animateWithDuration:3.5f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         visualEffectView.alpha = 1.0f;
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                             NSLog(@"Squiddy says hello"); // thanks squid for this amazing respring :)
                             //call the animation here for the screen fade and respring
                             [self graduallyAdjustBrightnessToValue:0.0f];
                         }
                     }];

    //sleep(15);

    //[[UIScreen mainScreen] setBrightness:0.0f]; //so the screen fades back in when the respringing is done
}

- (void)openTwitter {
	NSURL *url;

	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]]) {
		url = [NSURL URLWithString:@"tweetbot:///user_profile/kaitouiet"];
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]]) {
		url = [NSURL URLWithString:@"twitterrific:///profile?screen_name=kaitouiet"];
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]]) {
		url = [NSURL URLWithString:@"tweetings:///user?screen_name=kaitouiet"];
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
		url = [NSURL URLWithString:@"twitter://user?screen_name=kaitouiet"];
	} else {
		url = [NSURL URLWithString:@"http://mobile.twitter.com/kaitouiet"];
	}

	// [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
	[[UIApplication sharedApplication] openURL:url];
}


@end
