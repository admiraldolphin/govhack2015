//
//  AudioJigger.swift
//  QuestionTime
//
//  Created by Tim Nugent on 4/07/2015.
//  Copyright (c) 2015 Secret Lab. All rights reserved.
//

import UIKit
import AVFoundation

enum Effects : String
{
    case Zinger = "effect_mad_zinger"
    case Countdown = "effect_countdown_to_gamestart"
    case Selection = "effect_click"
    case Ticking = "effect_ticking"
    case Booing = "effect_booing"
    case HereHere = "effect_here_here"
    case murmur = "effect_murmuring"
}

protocol AudioJiggerDelegate {
    func jiggerFinishedPlayingEffect(effect:Effects)
}

class AudioJigger: NSObject,AVAudioPlayerDelegate {
    
    static var sharedJigger = {
        return AudioJigger()
    }()
    
    var delegate : AudioJiggerDelegate?
    var musicPlayer : AVAudioPlayer?
    var effectsPlayer : AVAudioPlayer?
    var currentEffect : Effects?
    
    override init()
    {
        super.init()
    }
    
    func playBackgroundMusic()
    {
        self.playMusic("music_background")
    }
    func playActionMusic()
    {
        self.playMusic("music_action")
    }
    
    func playEffect(theEffect:Effects)
    {
        let effectName = theEffect.rawValue
        let musicURL = NSBundle.mainBundle().URLForResource(effectName, withExtension: "wav")
        var error : NSError?
        let effect = AVAudioPlayer(contentsOfURL: musicURL, error: &error)
        self.currentEffect = theEffect
        
        if let theError = error
        {
            println("Bugger")
        }
        else
        {
            if let currentEffect = self.effectsPlayer
            {
                currentEffect.stop()
            }
            effect.delegate = self
            effect.play()
            self.effectsPlayer = effect
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        if flag
        {
            if let theEffect = self.currentEffect
            {
                self.delegate?.jiggerFinishedPlayingEffect(theEffect)
            }
        }
    }
    
    func playMusic(musicName:String)
    {
        #if TARGET_IPHONE_SIMULATOR

        let musicURL = NSBundle.mainBundle().URLForResource(musicName, withExtension: "mp3")
        var error : NSError?
        let newMusic = AVAudioPlayer(contentsOfURL: musicURL, error: &error)
        
        if let theError = error
        {
            println("Bugger")
        }
        else
        {
            newMusic.numberOfLoops = -1
            newMusic.volume = 0.1
            // really ought to ramp down the old one and spin up the new
            // meh
            if let theMusic = self.musicPlayer
            {
                // geddit? I stopped the music!
                theMusic.stop()
            }
            self.musicPlayer = newMusic
            self.musicPlayer?.play()
        }
        #endif

    }
}
