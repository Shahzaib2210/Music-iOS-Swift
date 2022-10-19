//
//  MusicPlayerViewController.swift
//  Music
//
//  Created by Shahzaib Mumtaz on 15/09/2022.
//

import UIKit
import MediaPlayer
import MediaAccessibility
import AVFoundation

class MusicPlayerViewController: UIViewController {
    
    //************************************************//
    // MARK:- Creating Outlets.
    //************************************************//
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var songPlayProgress: UIProgressView!
    @IBOutlet weak var currentPlayTime: UILabel!
    @IBOutlet weak var seekBackward: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var seekForwad: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var volumePercentage: UILabel!
    @IBOutlet weak var muteSpeaker: UIImageView!
    @IBOutlet weak var backPressedLabel: UILabel!
    
    //************************************************//
    // MARK: Creating properties.
    //************************************************//
    
    var audioPlayer = AVAudioPlayer()
    
    var name:String?
    var currentSongImage:UIImage?
    
    var index: Int = 0
    var audioPlay: Bool = true
    var currentTime: Int = 0
    var totalMusicProgress: Int = 0
    var totalProgress: Float = 0.0
    
    var pauseProgress: Float = 0.0
    var pauseTime: Int = 0
    
    var SongProgressTimer  = Timer()
    
    //************************************************//
    // MARK:- View life Cycle
    //************************************************//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = name
        songImage.image = currentSongImage
        songImage.layer.cornerRadius = 10
        volumePercentage.isHidden = true
        
        playPauseButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
        
        PlayingSong()
        audioPlayer.play()
        audioPlayer.volume = 0.5
        audioPlay = false
        
        songPlayProgress.progress = 0.0
        
        SongProgressTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                                 target: self,
                                                 selector: #selector(updateProgressBar),
                                                 userInfo: nil,
                                                 repeats: true)
        setupLabelTap()
    }
    
    //************************************************//
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        audioPlayer.stop()
        SongProgressTimer.invalidate()
    }
    
    //************************************************//
    // MARK:- Custom Methods, IBActions and Selectors.
    //************************************************//
    
    func setupLabelTap() {
        
        let backLabel = UITapGestureRecognizer(target: self, action: #selector(self.labelTapped(_:)))
        self.backPressedLabel.isUserInteractionEnabled = true
        self.backPressedLabel.addGestureRecognizer(backLabel)
    }
    
    //************************************************//
    
    @objc func labelTapped(_ sender: UITapGestureRecognizer) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //************************************************//
    
    @objc func updateProgressBar() {
        
        if currentTime < totalMusicProgress {
            currentTime += 1
            songPlayProgress.progress = Float(currentTime) / Float(totalMusicProgress)
            pauseProgress = Float(currentTime) / Float(totalMusicProgress)
            pauseTime = currentTime
            let (m,s) = secondsToHoursMinutesSeconds(currentTime)
            if s < 10 {
                currentPlayTime.text = "0\(m):0\(s)"
            } else {
                currentPlayTime.text = "0\(m):\(s)"
            }
        }
        else {
            SongProgressTimer.invalidate()
            playPauseButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        }
        
    }
    
    //************************************************//
    
    @IBAction func btnSeekForwadTapped(_ sender: UIButton) {
        currentTime += 10
        audioPlayer.currentTime += 10
    }
    
    //************************************************//
    
    @IBAction func BtnPlayPauseButtonTapped(_ sender: UIButton) {
        
        if audioPlay {
            audioPlayer.play()
            playPauseButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
            audioPlay = false
            
            SongProgressTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                                     target: self,
                                                     selector: #selector(updateProgressBar),
                                                     userInfo: nil,
                                                     repeats: true)
        }
        else {
            audioPlayer.pause()
            
            songPlayProgress.progress = pauseProgress
            
            let (m,s) = secondsToHoursMinutesSeconds(pauseTime)
            if s < 10 {
                currentPlayTime.text = "0\(m):0\(s)"
            } else {
                currentPlayTime.text = "0\(m):\(s)"
            }
            
            SongProgressTimer.invalidate()
            
            playPauseButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            audioPlay = true
        }
    }
    
    //************************************************//
    
    @IBAction func btnSeekBackwardTapped(_ sender: UIButton) {
        currentTime -= 10
        audioPlayer.currentTime -= 10
    }
    
    //************************************************//
    
    @IBAction func VolumeSliderChanged(_ sender: UISlider) {
        let value = volumeSlider.value
        audioPlayer.volume = value
        volumePercentage.text = "\(Int(value * 100))%"
        
        if sender.isTracking {
            
            volumePercentage.isHidden = false
            
            if volumePercentage.text == "0%" {
                muteSpeaker.image = UIImage(systemName: "speaker.slash")
            } else {
                muteSpeaker.image = UIImage(systemName: "volume.2")
            }
            
        } else {
            volumePercentage.isHidden = true
        }
    }
    
    //************************************************//
}

extension MusicPlayerViewController {
    
    // MARK :- Function to get path to directory
    
    func getDirectory() -> URL {
        let folderPath = URL(fileURLWithPath: Bundle.main.resourcePath!)
        return folderPath
    }
    
    //************************************************//
    
    // MARK :- Function to Play Song
    
    func PlayingSong() {
        do {
            let audioPath = Bundle.main.path(forResource: name, ofType: ".mp3")!
            try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath) as URL )
            let audioAsset = AVURLAsset.init(url: NSURL(fileURLWithPath: audioPath) as URL, options: nil)
            let duration = audioAsset.duration
            let durationInSeconds = CMTimeGetSeconds(duration)
            totalProgress = Float(durationInSeconds)
            let original = Int(durationInSeconds)
            totalMusicProgress = original
        }
        catch {
            print("Error")
        }
    }
    
    //************************************************//
    
    // MARK :- Second into Minutes and hours
    
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int) {
        return ((seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    //************************************************//
}
