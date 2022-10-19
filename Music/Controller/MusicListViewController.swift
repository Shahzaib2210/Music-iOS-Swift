//
//  ViewController.swift
//  Music
//
//  Created by Shahzaib Mumtaz on 15/09/2022.
//

import UIKit
import MediaPlayer
import MediaAccessibility
import AVFoundation

class MusicListViewController: UIViewController {
    
    //************************************************//
    // MARK:- Creating Outlets.
    //************************************************//
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchSong: UISearchBar!
    
    //************************************************//
    // MARK: Creating properties.
    //************************************************//
    
    var music = [MusicModel]()
    var searchMusic = [MusicModel]()
    var isSearching = false
    
    //************************************************//
    // MARK:- View life Cycle
    //************************************************//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GetSongsDetail()
        searchSong.delegate = self
        
        tableView.register(MusicTableViewCell.nib(),
                           forCellReuseIdentifier: MusicTableViewCell.identifier)
        
        self.tableView.estimatedRowHeight = 20.0
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    
    //************************************************//
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isSearching = false
    }
    
    //************************************************//
}

extension MusicListViewController: UITableViewDelegate, UITableViewDataSource {
    
    //************************************************//
    // MARK:- UITableview delegate and datesource
    //************************************************//
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    //************************************************//
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching {
            return searchMusic.count
        } else {
            return music.count
        }
    }
    
    //************************************************//
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MusicTableViewCell.identifier, for: indexPath) as! MusicTableViewCell
        
        if isSearching {
            cell.musicImage.image = searchMusic[indexPath.row].songImage
            cell.musicNameLabel.text = searchMusic[indexPath.row].songName
        } else {
            cell.musicImage.image = music[indexPath.row].songImage
            cell.musicNameLabel.text = music[indexPath.row].songName
        }
        return cell
    }
    
    //************************************************//
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "MusicPlayerViewController") as! MusicPlayerViewController
        
        if isSearching {
            vc.name = searchMusic[indexPath.row].songName
            vc.currentSongImage = searchMusic[indexPath.row].songImage
        } else {
            vc.name = music[indexPath.row].songName
            vc.currentSongImage = music[indexPath.row].songImage
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //************************************************//
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // set initial cell
        cell.alpha = 0
        
        // set final cell
        UIView.animate(withDuration: 0.5) {
            cell.alpha = 1.0
        }
    }
    
    //************************************************//
}

extension MusicListViewController {
    
    //************************************************//
    // MARK:- Custom Methods
    //************************************************//
    
    func GetSongsDetail() {
        let folderPath = URL(fileURLWithPath: Bundle.main.resourcePath!)
        
        do {
            let audioPath = try FileManager.default.contentsOfDirectory(at: folderPath, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            for audio in audioPath {
                var myAudio = audio.absoluteString
                
                if myAudio.contains(".mp3") {
                    let findAudioName = myAudio.components(separatedBy: "/")
                    myAudio = findAudioName[findAudioName.count-1]
                    myAudio = myAudio.replacingOccurrences(of: "%20", with: " ")
                    myAudio = myAudio.replacingOccurrences(of: ".mp3", with: "")
                }
                
                let asset = AVAsset(url: audio as URL) as AVAsset
                
                for metaDataItems in asset.commonMetadata {
                    
                    if metaDataItems.commonKey == .commonKeyArtwork {
                        let imageData = metaDataItems.value as! NSData
                        let image2: UIImage = UIImage(data: imageData as Data)!
                        music.append(MusicModel(songImage: image2, songName: myAudio))
                    }
                }
            }
        }
        catch {
            print("Error Getting Songs")
        }
    }
    
    //************************************************//
}

extension MusicListViewController: UISearchBarDelegate {
    
    //************************************************//
    // MARK:- SearchBar delegate.
    //************************************************//
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        isSearching = true
        searchMusic = music.filter({$0.songName?.lowercased().prefix(searchText.count) ?? "" == searchText.lowercased()})
        tableView.reloadData()
    }
    
    //************************************************//
}
