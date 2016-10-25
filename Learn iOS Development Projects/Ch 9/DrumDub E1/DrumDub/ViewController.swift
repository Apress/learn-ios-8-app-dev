//
//  ViewController.swift
//  DrumDub
//
//  Created by James Bucanek on 8/3/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import AVFoundation
import UIKit
import MediaPlayer


class ViewController: UIViewController, MPMediaPickerControllerDelegate {
                            
	override func viewDidLoad() {
		super.viewDidLoad()

		activateAudioSession()

		let center = NSNotificationCenter.defaultCenter()
		center.addObserver( self,
				  selector: "playbackStateDidChange:",
					  name: MPMusicPlayerControllerPlaybackStateDidChangeNotification,
					object: musicPlayer)
		center.addObserver( self,
				  selector: "playingItemDidChange:",
					  name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification,
					object: musicPlayer)
		musicPlayer.beginGeneratingPlaybackNotifications()

		center.addObserver( self,
				  selector: "audioInterruption:",
					  name: AVAudioSessionInterruptionNotification,
					object: nil)
		center.addObserver( self,
				  selector: "audioRouteChange:",
					  name: AVAudioSessionRouteChangeNotification,
					object: nil)
	}

	// MARK: Music Picker

	@IBAction func selectTrack(sender: AnyObject!) {
		let picker = MPMediaPickerController(mediaTypes: .AnyAudio)
		picker.delegate = self
		picker.allowsPickingMultipleItems = false
		picker.prompt = "Choose a song"

		presentViewController(picker, animated: true, completion: nil)
	}
	
	func mediaPicker(mediaPicker: MPMediaPickerController!, didPickMediaItems mediaItemCollection: MPMediaItemCollection!) {
		// Called when the user chooses a song from their iPod library
		if let songChoices = mediaItemCollection {
			if songChoices.count != 0 {
				// Set the music player's play list to the one song the user picked
				musicPlayer.setQueueWithItemCollection(songChoices)
				// Start the music playing
				musicPlayer.play()
			}
		}
		// Dismiss the media picker
		dismissViewControllerAnimated(true, completion: nil)
	}

	func mediaPickerDidCancel(mediaPicker: MPMediaPickerController!) {
		// Called when the user declines to choose a song from their iPod library

		// Dismiss the media picker
		dismissViewControllerAnimated(true, completion: nil)
	}

	// MARK: Music Player

	@IBOutlet var playButton: UIBarButtonItem!
	@IBOutlet var pauseButton: UIBarButtonItem!
	@IBOutlet var albumView: UIImageView!
	@IBOutlet var songLabel: UILabel!
	@IBOutlet var albumLabel: UILabel!
	@IBOutlet var artistLabel: UILabel!

	let musicPlayer = MPMusicPlayerController.systemMusicPlayer()

	@IBAction func play(sender: AnyObject!) {
		musicPlayer.play()
	}

	@IBAction func pause(sender: AnyObject!) {
		musicPlayer.pause()
	}
	
	func playbackStateDidChange(notification: NSNotification) {
		// Called when the player state (playing, paused, seeking, ...) changes

		// Determine if the music player is playing or not by looking at its playbackState
		let playing = ( musicPlayer.playbackState == .Playing )

		// Enable the play button if the player is NOT playing
		playButton!.enabled = !playing
		// Enable the pause button if it IS playing
		pauseButton!.enabled = playing
	}
	
	func playingItemDidChange(notification: NSNotification) {
		// Called whenever the currently playing item changes

		// Get the item playing
		let nowPlaying = musicPlayer.nowPlayingItem

		// Get the album artwork
		var albumImage: UIImage!
		if let artwork = nowPlaying?.valueForProperty(MPMediaItemPropertyArtwork) as? MPMediaItemArtwork {
			// A song is playing and there's album artwork: get an optimally sized image for the view
			albumImage = artwork.imageWithSize(albumView.bounds.size)
		}
		if albumImage == nil {
			// Nothing's playing or no artwork is available: show a placeholder image
			albumImage = UIImage(named: "noartwork")
		}
		albumView.image = albumImage

		// Set the song title, album title, and artist
		songLabel.text = nowPlaying?.valueForProperty(MPMediaItemPropertyTitle) as? NSString
		albumLabel.text = nowPlaying?.valueForProperty(MPMediaItemPropertyAlbumTitle) as? NSString
		artistLabel.text = nowPlaying?.valueForProperty(MPMediaItemPropertyArtist) as? NSString
	}

	// MARK: Audio Players

	let soundNames = [ "snare", "bass", "tambourine", "maraca" ]
	var players = [AVAudioPlayer]()

	@IBAction func bang(sender: AnyObject!) {
		if let button = sender as? UIButton {
			let index = button.tag-1
			if index >= 0 && index < players.count {
				let player = players[index]
				player.pause()
				player.currentTime = 0.0
				player.play()
			}
		}
	}

	func createAudioPlayers() {
		destroyAudioPlayers()
		for soundName in soundNames {
			if let soundURL = NSBundle.mainBundle().URLForResource(soundName, withExtension: "m4a") {
				let player = AVAudioPlayer(contentsOfURL: soundURL, error: nil)
				//player.delegate = self	-- this app doesn't need any player delegate functions
				player.prepareToPlay()
				players.append(player)
			}
		}
	}

	func destroyAudioPlayers() {
		players = []
	}

	// MARK: Audio Session

	func activateAudioSession() {
		// While not strictly necessary, the documentation for AVAudioSession
		//	recommends explicitely activating the audio session when your
		//	app starts, and again whenever it's been interrupted or routing
		//	has changed. This gives your app an opportunity to take defensive
		//	action should the audio session be unusable, for some strange reason.
		let active = AVAudioSession.sharedInstance().setActive(true, error: nil)

		if active {
			// The session is active
			if players.count == 0 {
				// If the AVAudioPlayers need to be created, do it now
				createAudioPlayers()
			}
		} else {
			// The session failed to activate
			// Throw away our audio players on the theory that they're now unusable
			destroyAudioPlayers()
		}

		// Enable the four sound buttons when the audio session is active,
		//  and disable them if it isn't.
		for i in 0..<players.count {
			if let button = view.viewWithTag(i+1) as? UIButton {
				button.enabled = active
			}
		}
	}

	func audioInterruption(notification: NSNotification) {
		if let typeValue = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? NSNumber {
			if let type = AVAudioSessionInterruptionType(rawValue: typeValue.unsignedLongValue) {
				switch type {
					case .Began:
						// The audio session was interrupted (by an alarm or incoming phone call).
						// Respond by stopping the players, so they won't resume playing
						//	when the interruption ends.
						for player in players {
							player.pause()
						}
					case .Ended:
						// The interruption has ended; resume the audio session
						activateAudioSession()
				}
			}
		}
	}

	func audioRouteChange(notification: NSNotification) {
		if let reasonValue = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? NSNumber {
			if reasonValue.unsignedLongValue == AVAudioSessionRouteChangeReason.OldDeviceUnavailable.rawValue {
				// The reason == audio route is no longer available
				// In English, it means that someone unplugged their headphones, pulled their iPod
				//	out of a stereo dock, walked out of range of their Bluetooth speakers, etc.
				// Our response is to stop all audio players (consistent with Apple's UI guidelines)
				for player in players {
					player.pause()
				}
			}
		}
	}

}

