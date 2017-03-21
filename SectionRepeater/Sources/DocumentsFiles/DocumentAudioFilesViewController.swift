//
//  DocumentAudioFilesViewController.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 2. 7..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import SnapKit

enum DocumentAudioFilesSectionType: Int {
    case Directory
    case File
}

class DocumentAudioFilesViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(DocumentAudioFilesCollectionViewCell.self)
        }
    }
    
    fileprivate var displayManager: FileDisplayManager?
    fileprivate var files = [FileDisplayItem]()
    fileprivate var directories = [FileDisplayItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.displayManager = Dependencies.sharedInstance().resolve(serviceType: FileDisplayManager.self)
        self.displayManager?.delegate = self
        self.displayManager?.loadCurrentPathContents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.displayManager?.loadCurrentPathContents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

extension DocumentAudioFilesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = DocumentAudioFilesSectionType(rawValue: section) else { return 0 }
        switch section {
        case .Directory:
            return self.directories.count
        case .File:
            return self.files.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = DocumentAudioFilesSectionType(rawValue: indexPath.section) else { return UICollectionViewCell() }
        let cell = collectionView.deqeueResuableCell(forIndexPath: indexPath) as DocumentAudioFilesCollectionViewCell
        cell.delegate = self
        switch section {
        case .Directory:
            cell.item = self.directories[indexPath.row]
        case .File:
            cell.item = self.files[indexPath.row]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = DocumentAudioFilesSectionType(rawValue: indexPath.section) else { return }
        switch section {
        case .Directory:
            let item = self.directories[indexPath.row]
            if (item.isParentDirectory){
                self.displayManager?.moveToParentDirectory()
                return
            }
            self.displayManager?.moveToDirectory(directoryName: item.name)
        case .File:
            let item = self.files[indexPath.row]
            let playerController = AudioPlayerViewController(nibName: AudioPlayerViewController.className(), bundle: nil)
            playerController.modalPresentationStyle = .custom
            playerController.item = AudioItem(url: URL(fileURLWithPath: item.path))
            self.present(playerController, animated: true, completion: nil)
        }
    }
}

extension DocumentAudioFilesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        return CGSize(width: screenWidth, height: DocumentAudioFilesCollectionViewCell.height())
    }
}

extension DocumentAudioFilesViewController: FileDisplayManagerDelegate {
    func didChangeCurrentPath(directories: [FileDisplayItem], files: [FileDisplayItem]) {
        self.directories = directories
        self.files = files
        self.collectionView.reloadData()
    }
}

extension DocumentAudioFilesViewController: DocumentAudioFilesCollectionViewCellDelegate {
    func didTappedDelete(item: FileDisplayItem?) {
        if let item = item {
            self.displayManager?.removeFile(item: item)
        }
        self.displayManager?.loadCurrentPathContents()
    }
}
