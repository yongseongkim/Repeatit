//
//  FileDestinationFileListViewController.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 4. 16..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import SnapKit
import Then
import URLNavigator

class FileDestinationFileListViewController: UIViewController {

    //MARK: UI Componenets
    fileprivate let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
        ).then { (view) in
            view.backgroundColor = UIColor.white
            view.register(FileCell.self)
            view.allowsMultipleSelection = true
            view.contentInset = UIEdgeInsetsMake(64, 0, FileDestinationViewController.optionViewHeight , 0)
            view.alwaysBounceVertical = true
    }
    
    //MARK: Properties
    public var currentURL: URL = URL.documentsURL
    fileprivate var directories = [File]()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.addSubview(self.collectionView)
        self.updateConstraints()
        self.bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = self.currentURL.lastPathComponent
        self.loadDirectories()
    }
    
    func updateConstraints() {
        self.collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
    }
    
    func bind() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    func enterForeground() {
        self.collectionView.reloadData()
    }
    
    func loadDirectories() {
        self.directories = FileManager.default.loadDirectories(url: self.currentURL)
        self.collectionView.reloadData()
    }
}

extension FileDestinationFileListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.directories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.deqeueResuableCell(forIndexPath: indexPath) as FileCell
        cell.file = self.directories[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.mainWidth, height: FileCell.height())
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.deqeueResuableCell(forIndexPath: indexPath) as FileCell
        cell.isSelected = false
        let destinationViewController = FileDestinationFileListViewController()
        destinationViewController.currentURL = self.currentURL.appendingPathComponent(self.directories[indexPath.row].url.lastPathComponent)
        Navigator.push(destinationViewController)
    }
}
