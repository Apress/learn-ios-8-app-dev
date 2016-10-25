//
//  AppDelegate.swift
//  DrumDub
//
//  Created by James Bucanek on 8/3/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import AVFoundation
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
	var window: UIWindow?

	func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
		// Configure the app's audio session.
		// The audio session sets the policies and behavour of the app's audio
		//	playback in respect to other audio, external events, and interruptions.
		// The audio session for this app never changes; set it up once at launch.
		let audioSession = AVAudioSession.sharedInstance()
		// Set the catagory to "playback": the app's audio is treated like the iPod
		//	music player. It continues to play if the user sets the silence/vibrate
		//	switch and if the screen locks, but will be interrupted for an alarm
		//	or incoming phone call.
		// Set the special option "mix with others": this permits other app
		//	sounds to be blended with the playback of the MPMusicPlayerController,
		//	without interrupting it or changing its volume ("ducking").
		audioSession.setCategory( AVAudioSessionCategoryPlayback,
					 withOptions: .MixWithOthers,
						   error: nil)

		return true
	}

	func applicationWillResignActive(application: UIApplication!) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication!) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication!) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication!) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication!) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}

