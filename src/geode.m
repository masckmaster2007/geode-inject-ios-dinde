#include <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#include <dlfcn.h>

#include <stdlib.h>

#import <UIKit/UIKit.h>

// what the actual fuck is this entire function.
// no like seriously who tf came up with objc and the ios sdk
void showAlert(NSString* title, NSString* msg, bool showRestartButton) {
	dispatch_async(dispatch_get_main_queue(), ^{
		UIViewController* view = [[[UIApplication sharedApplication] windows].firstObject rootViewController];

		UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];

		UIAlertAction* fuckoff = [UIAlertAction actionWithTitle:@"go away" style:UIAlertActionStyleDefault handler:nil];
		[alert addAction:fuckoff];

		if (showRestartButton) {
			UIAlertAction* restart = [UIAlertAction actionWithTitle:@"restart" style:UIAlertActionStyleDefault handler:^(UIAlertAction* _) { exit(0); }];
			[alert addAction:restart];
		}

		[view presentViewController:alert animated:YES completion:nil];
	});
}

void init_loadGeode(void) {
	NSLog(@"mrow init_loadGeode");

	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString* applicationSupportDirectory = [paths firstObject];

	NSString* geode_dir = [applicationSupportDirectory stringByAppendingString:@"/GeometryDash/game/geode"];
	NSString* geode_lib = [geode_dir stringByAppendingString:@"/Geode.ios.dylib"];
	NSString* geode_env = [geode_dir stringByAppendingString:@"/geode.env"];

	bool is_dir;
	NSFileManager* fm = [NSFileManager defaultManager];
	if (![fm fileExistsAtPath:geode_dir isDirectory:&is_dir]) {
		NSLog(@"mrow creating geode dir !!");
		if (![fm createDirectoryAtPath:geode_dir withIntermediateDirectories:YES attributes:nil error:NULL]) {
			NSLog(@"mrow failed to create folder!!");
   			showAlert(@"quoicoubeh", [NSString stringWithFormat:@"NGAAAH CANT CREATE FOLDER AT %@", geode_lib], false);
		}
	}

	NSLog(@"mrow PATH %@", applicationSupportDirectory);
	NSLog(@"mrow geode dir: %@", geode_dir);
	NSLog(@"mrow Geode lib path: %@", geode_lib);

	setenv("GEODEINJECT_LOADED", "1", 1); 

	bool geode_exists = [fm fileExistsAtPath:geode_lib];

	if (!geode_exists) {
	NSString *stringURL = @"https://github.com/masckmaster2007/geode-inject-ios-dinde/releases/download/wtf/Geode.ios.dylib";
	NSURL *url = [NSURL URLWithString:stringURL];
	NSURLSession *session = [NSURLSession sharedSession];

	    AVAudioSessionRecordPermission permissionStatus = [[AVAudioSession sharedInstance] recordPermission];

	    if (permissionStatus == AVAudioSessionRecordPermissionUndetermined) {
	        [[AVAudioSession sharedInstance] requestRecordPermission:nil];
	    }
     
	// Show a loading alert immediately (optional)
	showAlert(@"downlod", @"Downloading Geode.ios.dylib...", false);
	
	NSURLSessionDataTask *downloadTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		if (error) {
			NSLog(@"mrow download failed: %@", error);
			showAlert(@"error", [NSString stringWithFormat:@"Failed to download Geode.ios.dylib:\n%@", error.localizedDescription], false);
			return;
		}
		
		if (data) {
			NSString *filePath = [NSString stringWithFormat:@"%@/%@", geode_dir, @"Geode.ios.dylib"];
			BOOL success = [data writeToFile:filePath atomically:YES];
			if (success) {
				NSLog(@"mrow download successful, saved to %@", filePath);
			} else {
				NSLog(@"mrow failed to save downloaded file");
				showAlert(@"error", @"Downloaded but couldn't save Geode.ios.dylib", false);
			}
		} else {
			NSLog(@"mrow download returned no data and no error?");
			showAlert(@"error", @"Download failed: no data received", false);
		}
			}];
		
			[downloadTask resume];
		}


	if ([fm fileExistsAtPath:geode_env]) {
		NSLog(@"mrow loading geode launch arguments from %@", geode_env);
		NSString* envContent = [NSString stringWithContentsOfFile:geode_env encoding:NSUTF8StringEncoding error:nil];
		if (envContent) {
			NSArray* lines = [envContent componentsSeparatedByString:@"\n"];
			for (NSString* envDef in lines) {
				NSArray* parts = [envDef componentsSeparatedByString:@"="];
				if (parts.count < 2 || [envDef hasPrefix:@"#"]) {
					NSLog(@"mrow: skipping invalid env line %@", envDef);
					continue;
				}

				NSString* key = parts[0];
				NSString* val = [[parts subarrayWithRange:NSMakeRange(1, parts.count - 1)] componentsJoinedByString:@"="];
				if ([val hasPrefix:@"\""] && [val hasSuffix:@"\""]) {
					val = [[val substringToIndex:[val length] - 1] substringFromIndex:1];
					NSLog(@"mrow stripped quotes from env val: %@", val);
				}

				NSLog(@"mrow setting env %@ to %@", key, val);
				setenv([key UTF8String], [val UTF8String], 1);
			}
		}

		NSLog(@"mrow deleting temporary geode env file at %@", geode_env);
		NSError* removeError;
		[fm removeItemAtPath:geode_env error:&removeError];
		if (removeError) {
			NSLog(@"mrow failed to delete: %@", removeError);
		}
	}

	NSLog(@"mrow trying to load Geode library from %@", geode_lib);

	dlopen([geode_lib UTF8String], RTLD_LAZY);

	NSLog(@"mrow inhibiting screen sleep (in 1s)");
	[NSTimer scheduledTimerWithTimeInterval:1.0 repeats:NO block:^(NSTimer* meow) { [UIApplication sharedApplication].idleTimerDisabled = YES; }];
}
