//
//  ViewController.swift
//  Downloadr
//
//  Created by Akan Akysh on 8/26/19.
//  Copyright © 2019 Akysh Akan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UITableViewController {
    
    var musicData: [MusicModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        
        setupNavigationBar()
        
        tableView.register(CustomCell.self, forCellReuseIdentifier: CustomCell.cellId)
        fetchData()
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.0, green: 0.0, blue: 0.0 , alpha: 1.0)
        navigationController?.navigationBar.topItem?.title = "Downloadr"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    
    func fetchData() {
        DispatchQueue.main.async {
            //request using alamofire and snapkit frameworks
            Alamofire.request("http://vibze.github.io/downloadr-task/tracks.json").responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let data = json["tracks"]
                    data.array?.forEach({ (music) in
                        let music = MusicModel(title: music["title"].stringValue, artist: music["artist"].stringValue, url: music["url"].url!, download: Download(isDownloading: false, isDownloaded: false))
                        self.musicData.append(music)
                    })
                    self.tableView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            })
        }
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        let musicUrl = musicData[sender.tag].url
        let isDownloaded = musicData[sender.tag].download.isDownloaded
        if isDownloaded {
            deleteMusicFromFileSystem(url: musicUrl, forIndex: sender.tag)
        } else {
            saveMusicToFileSystem(url: musicUrl, forIndex: sender.tag)
        }
    }
    
    // MARK: Saving music
    func saveMusicToFileSystem(url audioUrl: URL, forIndex index: Int) {
        
        let documentDirectoryUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let destinationUrl = documentDirectoryUrl.appendingPathComponent(audioUrl.lastPathComponent)
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (destinationUrl, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download(audioUrl, to:destination)
            .downloadProgress { (progress) in
                if let customCell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? CustomCell {
                    self.musicData[index].download.isDownloading = true
                    self.musicData[index].download.isDownloaded = false
                    
                    customCell.updateButtonState(isDownloading: self.musicData[index].download.isDownloading, isDownloaded: self.musicData[index].download.isDownloaded)
                    customCell.updateDisplay(progress: Float(progress.fractionCompleted))
                }
            }
            .responseData { (data) in
                if let customCell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? CustomCell {
                    self.musicData[index].download.isDownloading = false
                    self.musicData[index].download.isDownloaded = true
                    
                    customCell.updateButtonState(isDownloading: self.musicData[index].download.isDownloading, isDownloaded: self.musicData[index].download.isDownloaded)
                }
                print("File path: \(destinationUrl.path)")
        }
    }
    
    
    // MARK: Deleting music
    func deleteMusicFromFileSystem(url audioUrl: URL, forIndex index: Int) {
        var audioPath = ""
        
        let directories: [String] = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true)
        
        if directories.count > 0 {
            let directory = directories.first!
            audioPath = directory.appendingFormat("/" + audioUrl.lastPathComponent)
        } else {
            print("Could not find local directory to delete audio")
        }
        
        do {
            // delete file
            try FileManager.default.removeItem(atPath: audioPath)
            if let customCell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? CustomCell {
                musicData[index].download.isDownloaded = false
                customCell.updateButtonState(isDownloading: self.musicData[index].download.isDownloading, isDownloaded: self.musicData[index].download.isDownloaded)
            }
        } catch let error as NSError{
            print("An error took place: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: table view functions
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomCell.cellId, for: indexPath) as! CustomCell
        
        cell.titleLabel.text = self.musicData[indexPath.row].title
        cell.artisLabel.text = self.musicData[indexPath.row].artist
        cell.actionButton.tag = indexPath.row
        cell.actionButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        cell.updateButtonState(isDownloading: self.musicData[indexPath.row].download.isDownloading, isDownloaded: self.musicData[indexPath.row].download.isDownloaded)
        
        
        return cell
    }
    

}
