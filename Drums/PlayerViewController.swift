//
//  PlayerViewController.swift
//  Drums
//
//  Created by chang on 2019/1/5.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController, ChangeSong {
    // Change song delegate
    
    func changeSong(songFile: String, songAlbum: String,songNumber:Int) {
        self.songAlbum = songAlbum
        self.songFile = songFile
        self.songNumber = songNumber
        NotificationCenter.default.removeObserver(self)
        
        findSongPath()
        updatePlayerUI()
        observeCurrentTime()
        audioPlayer?.play()
        playButton.setImage(UIImage(named: "icons8-pause"), for: UIControl.State.normal)
    }
    
    // Audio Player
    var audioPlayer:AVPlayer?
    var playerItem:AVPlayerItem?
    var recyclePlay = false
    
    // Receive song file
    var songFile = "Aimer - Choucho Musubi"
    var songAlbum = "Chouchou musubi"
    var songNumber = 0
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var songLengthLabel: UILabel!
    @IBOutlet weak var songProgressSlider: UISlider!
    @IBOutlet weak var songName: UILabel!
    @IBOutlet weak var songInfoView: UIView!{
        didSet {
            makeShadow(object: songInfoView, offset: CGSize(width: 0, height: 10))
        }
    }
    @IBOutlet weak var shadowView: UIView!{
        didSet {
            makeShadow(object: shadowView, offset: CGSize(width: 10, height: 10))
        }
    }
    @IBOutlet weak var songImage: UIImageView! {
        didSet {
            makeCircle(object: songImage)
        }
    }
    
    @IBOutlet weak var recycleButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet var playerButton: [UIButton]! {
        didSet {
            for button in playerButton {
                makeCircle(object: button)
            }
        }
    }
    // MARK: - IBAction
    
    // Player Action
    @IBAction func playAndPause(_ sender: UIButton) {
        
        if audioPlayer?.rate == 0 {
            playButton.setImage(UIImage(named: "icons8-pause"), for: UIControl.State.normal)
            audioPlayer?.play()
        } else {
            playButton.setImage(UIImage(named: "icons8-play"), for: UIControl.State.normal)
            audioPlayer?.pause()
        }
    }
    
    @IBAction func changeCurrentTime(_ sender: UISlider) {
        let seconds = Int64(songProgressSlider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        audioPlayer?.seek(to: targetTime)
    }
    
    @IBAction func changePlayType(_ sender: UIButton) {
        
        recyclePlay = !recyclePlay
        
        if recyclePlay {
            recycleButton.tintColor = UIColor.purple
        } else {
            recycleButton.tintColor = UIColor.white
        }
        
    }
    
    @IBAction func previous(_ sender: UIButton) {
        
        if let playlistVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlaylistViewController") as? PlaylistViewController {
            
            songNumber -= 1
            
            if songNumber < 0 {
                songNumber  = playlistVC.playlist.count - 1
            }
            
            songFile = playlistVC.playlist[songNumber].songFile
            songAlbum = playlistVC.playlist[songNumber].songImage
            changeSong(songFile: songFile, songAlbum: songAlbum,songNumber: songNumber)
            
        }
        
    }
    
    @IBAction func next(_ sender: UIButton) {
        
        if let playlistVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlaylistViewController") as? PlaylistViewController {
            
            if songNumber >= playlistVC.playlist.count - 1 {
                songNumber  = 0
            } else {
                songNumber += 1
                
            }
            songFile = playlistVC.playlist[songNumber].songFile
            songAlbum = playlistVC.playlist[songNumber].songImage
            changeSong(songFile: songFile, songAlbum: songAlbum,songNumber: songNumber)
            
        }
        
    }
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setGradientLayer()
        findSongPath()
        updatePlayerUI()
        observeCurrentTime()

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Functions
    
    // Make a gradient background
    
    func setGradientLayer() {
        let color1 = #colorLiteral(red: 0.631372549, green: 0.5490196078, blue: 0.8196078431, alpha: 1).cgColor
        let color2 = #colorLiteral(red: 0.9843137255, green: 0.7607843137, blue: 0.9215686275, alpha: 1).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.frame
        gradientLayer.colors = [color1,color2]
        
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // Make circle shape & border
    
    func makeCircle(object:UIView) {
        object.layer.cornerRadius = 20
        object.clipsToBounds = true
        object.layer.borderWidth = 3
        object.layer.borderColor = UIColor.white.cgColor
    }
    
    func makeShadow(object:UIView,offset:CGSize){
        object.layer.shadowOffset = offset
        object.layer.shadowColor = UIColor.black.cgColor
        object.layer.shadowOpacity = 0.5
        object.layer.shadowRadius = 10
    }
    
    // Find song the path
    
    func findSongPath() {
        
        if let path = Bundle.main.path(forResource: songFile, ofType: ".mp3"){
            let url = URL(fileURLWithPath: path)
            playerItem = AVPlayerItem(url: url)
            audioPlayer = AVPlayer(playerItem: playerItem)
        } else {
            let alertController = UIAlertController(title: "錯誤", message: "找不到此歌曲。", preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    func observeCurrentTime() {
        audioPlayer?.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main, using: { (CMTime) in
            if self.audioPlayer!.currentItem?.status == .readyToPlay {
                let currentTime = CMTimeGetSeconds(self.audioPlayer!.currentTime())
                self.songProgressSlider.value = Float(currentTime)
                self.currentTimeLabel.text = self.formatConversion(time: currentTime)
            }
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(playToEndTime), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    func updatePlayerUI() {
        
        let duration = playerItem!.asset.duration
        let seconds = CMTimeGetSeconds(duration)
        songProgressSlider.minimumValue = 0
        songProgressSlider.maximumValue = Float(seconds)
        songProgressSlider.isContinuous = true
        
        songLengthLabel.text = formatConversion(time: seconds)
        songImage.image = UIImage(named: songAlbum)
        songName.text = songFile
        
    }
    
    @objc func playToEndTime() {
        if recyclePlay {
            let targetTime:CMTime = CMTimeMake(value: 0, timescale: 1)
            audioPlayer?.seek(to: targetTime)
            audioPlayer?.play()
        } else {
            if let playlistVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlaylistViewController") as? PlaylistViewController {
                
                if songNumber >= playlistVC.playlist.count - 1 {
                    songNumber  = 0
                } else {
                    songNumber += 1
                    
                }
                songFile = playlistVC.playlist[songNumber].songFile
                songAlbum = playlistVC.playlist[songNumber].songImage
                changeSong(songFile: songFile, songAlbum: songAlbum,songNumber: songNumber)
                
            }
        }
    }
    
    func formatConversion(time:Float64) -> String {
        
        let songLength = Int(time)
        let minutes = Int(songLength / 60)
        let seconds = Int(songLength % 60)
        
        var time = ""
        
        if minutes < 10 {
            time = "0\(minutes):"
        } else {
            time = "\(minutes)"
        }
        
        if seconds < 10 {
            time += "0\(seconds)"
        } else {
            time += "\(seconds)"
        }
        return time
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
