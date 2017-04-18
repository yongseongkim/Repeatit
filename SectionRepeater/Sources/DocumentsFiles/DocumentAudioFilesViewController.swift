//
//  DocumentAudioFilesViewController.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 2. 7..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit

enum DocumentAudioFilesSectionType: Int {
    case Directory
    case File
}

class DocumentAudioFilesViewController: UIViewController {
    fileprivate var collectionView: UICollectionView? {
        didSet {
            self.collectionView?.dataSource = self
            self.collectionView?.delegate = self
            self.collectionView?.register(DocumentFileCell.self)
        }
    }
    fileprivate var displayManager: FileDisplayManager?
    fileprivate var files = [FileDisplayItem]()
    fileprivate var directories = [FileDisplayItem]()
    fileprivate var isEditingFiles = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.left.equalTo(self.view)
        }
        self.collectionView = collectionView
        
        self.displayManager = Dependencies.sharedInstance().resolve(serviceType: FileDisplayManager.self)
        self.displayManager?.delegate = self
        self.displayManager?.loadCurrentPathContents()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(editButtonTapped))
        
        AppDelegate.currentAppDelegate()?.notificationCenter.addObserver(self, selector: #selector(enterForeground), name: .onEnterForeground, object: nil)
    }
    
    deinit {
        AppDelegate.currentAppDelegate()?.notificationCenter.addObserver(self, selector: #selector(enterForeground), name: .onEnterForeground, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.displayManager?.loadCurrentPathContents()
    }
    
    func enterForeground() {
        self.collectionView?.reloadData()
    }
    
    func editButtonTapped() {
        self.isEditingFiles = true
        self.collectionView?.reloadData()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Move", style: .plain, target: self, action: #selector(moveButtonTapped))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
    }
    
    func doneButtonTapped() {
        self.isEditingFiles = false
        self.collectionView?.reloadData()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(editButtonTapped))
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func moveButtonTapped() {
        var paths = [String]()
//        if let rows = self.tableView?.indexPathsForSelectedRows {
//            for indexPath in rows {
//                let cell = self.tableView?.cellForRow(at: indexPath) as! DocumentFileCell
//                paths.append(cell.item.path)
//            }
//            let viewController = UINavigationController(rootViewController: DocumentFilesMoveDestinationViewController())
//            self.present(viewController, animated: true, completion: nil)
//        }
    }
}

extension DocumentAudioFilesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
        let cell = collectionView.deqeueResuableCell(forIndexPath: indexPath) as DocumentFileCell
        switch section {
        case .Directory:
            cell.item = self.directories[indexPath.row]
        case .File:
            cell.item = self.files[indexPath.row]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (self.isEditingFiles) {
            return
        }
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.mainScreenWidth(), height: DocumentFileCell.height())
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension DocumentAudioFilesViewController: FileDisplayManagerDelegate {
    func didChangeCurrentPath(directories: [FileDisplayItem], files: [FileDisplayItem]) {
        self.directories = directories
        self.files = files
        self.collectionView?.reloadData()
    }
}
