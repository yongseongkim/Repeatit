//
//  FileListViewController.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 2. 7..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import URLNavigator
import RealmSwift

enum FileSectionType: Int {
    case Directory
    case File
}

class FileListViewController: UIViewController {
    
    //MARK: UI Componenets
    fileprivate let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
        ).then { (view) in
            view.backgroundColor = UIColor.white
            view.register(FileCell.self)
            view.alwaysBounceVertical = true
    }
    
    //MARK: Properties
    fileprivate var directories = [File]()
    fileprivate var files = [File]()
    fileprivate let currentURL: URL
    
    convenience init() {
        self.init(url: URL.documentsURL)
    }

    init(url: URL) {
        self.currentURL = url
        super.init(nibName: nil, bundle: nil)

        let spaceButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spaceButton.width = -12
        if (UIScreen.mainWidth >= 414) {
            spaceButton.width = -16
        }
        let optionButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44)).then { (button) in
            button.setImage(UIImage(named: "btn_file_options_44pt"), for: .normal)
            button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        }
        self.navigationItem.rightBarButtonItems = [spaceButton, UIBarButtonItem(customView: optionButton)]
        NotificationCenter.default.addObserver(self, selector: #selector(enterForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.addSubview(self.collectionView)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        self.updateContentInset()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = self.currentURL.lastPathComponent
        self.loadFiles()
    }
    
    func enterForeground() {
        self.loadFiles()
    }
    
    func editButtonTapped() {
        self.present(UINavigationController(rootViewController: FileListEditViewController(url: self.currentURL)), animated: false, completion: nil)
    }
    
    public func updateContentInset() {
        guard let navigationBarHeight = self.navigationController?.navigationBar.frame.height else { return }
        let topOffset = navigationBarHeight + UIApplication.shared.statusBarFrame.height
        if PlayerView.isVisible() {
            self.collectionView.contentInset = UIEdgeInsetsMake(topOffset, 0, PlayerView.height(), 0)
            self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(topOffset, 0, PlayerView.height(), 0)
        } else {
            self.collectionView.contentInset = UIEdgeInsetsMake(topOffset, 0, 0, 0)
            self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(topOffset, 0, PlayerView.height(), 0)
        }
    }
    
    public func getSelectedFileCount() -> Int {
        guard let indexPaths = self.collectionView.indexPathsForSelectedItems else { return 0 }
        return indexPaths.count
    }
    
    public func getSelectedFiles() -> [File]? {
        guard let indexPaths = self.collectionView.indexPathsForSelectedItems else { return nil }
        var files = [File]()
        for indexPath in indexPaths {
            guard let file = (collectionView.deqeueResuableCell(forIndexPath: indexPath) as FileCell).file else { continue }
            files.append(file)
        }
        return files
    }
    
    fileprivate func loadFiles() {
        let (directories, files) = FileManager.default.loadFiles(url: self.currentURL)
        self.directories = directories
        self.files = files
        self.collectionView.reloadData()
    }
}

extension FileListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = FileSectionType(rawValue: section) else { return 0 }
        switch section {
        case .Directory:
            return self.directories.count
        case .File:
            return self.files.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = FileSectionType(rawValue: indexPath.section) else { return UICollectionViewCell() }
        let cell = collectionView.deqeueResuableCell(forIndexPath: indexPath) as FileCell
        switch section {
        case .Directory:
            cell.file = self.directories[indexPath.row]
        case .File:
            cell.file = self.files[indexPath.row]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = FileSectionType(rawValue: indexPath.section) else { return }
        let cell = collectionView.deqeueResuableCell(forIndexPath: indexPath) as FileCell
        cell.isSelected = false
        switch section {
        case .Directory:
            let fileListViewController = FileListViewController(url: self.currentURL.appendingPathComponent(self.directories[indexPath.row].url.lastPathComponent))
            Navigator.push(fileListViewController)
            return
        case .File:
            do {
                try Player.shared.play(items: PlayerItem.items(files: self.files), startAt: indexPath.row)
                let playerController = PlayerViewController(nibName: PlayerViewController.className(), bundle: nil)
                playerController.modalPresentationStyle = .custom
                Navigator.present(playerController)
            } catch let error {
                print(error)
            }
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.mainWidth, height: FileCell.height())
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
