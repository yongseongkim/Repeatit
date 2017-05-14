//
//  FilesMoveDestinationViewController.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 4. 16..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import SnapKit
import Then

class FilesMoveDestinationViewController: UIViewController {

    //MARK: UI Componenets
    fileprivate let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
        ).then { (view) in
            view.backgroundColor = UIColor.white
            view.register(FileCell.self)
            view.allowsMultipleSelection = true
            view.contentInset = UIEdgeInsetsMake(64, 0, 49 ,0)
    }
    
    //MARK: Properties
    public var currentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] {
        didSet {
            var directories = [File]()
            do {
                let fileNames = try FileManager.default.contentsOfDirectory(atPath: self.currentPath)
                for fileName in fileNames {
                    let url = URL(fileURLWithPath: currentPath.appendingFormat("/%@", fileName))
                    var isDir:ObjCBool = true
                    if (FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)) {
                        if (isDir.boolValue) {
                            directories.append(File(url: url, isDirectory: true))
                        }
                    }
                }
            } catch let error {
                print(error)
            }
            self.directories = directories
        }
    }
    fileprivate var directories = [File]()
    public var selectedPaths: [String]?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "MoveHere", style: .done, target: self, action: #selector(doneButtonTapped))
        AppDelegate.currentAppDelegate()?.notificationCenter.addObserver(self, selector: #selector(enterForeground), name: .onEnterForeground, object: nil)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    deinit {
        AppDelegate.currentAppDelegate()?.notificationCenter.addObserver(self, selector: #selector(enterForeground), name: .onEnterForeground, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.addSubview(self.collectionView)
        
        self.updateConstraint()
        self.bind()
    }
    
    func updateConstraint() {
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
    
    func cancelButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonTapped() {
        if let paths = self.selectedPaths {
            for path in paths {
                do {
                    if FileManager.default.fileExists(atPath: path) {
                        let url = URL(fileURLWithPath: path)
                        try FileManager.default.moveItem(atPath: path, toPath: String.init(format: "%@/%@", currentPath, url.lastPathComponent))
                    }
                } catch let error {
                    print(error)
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension FilesMoveDestinationViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.directories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.deqeueResuableCell(forIndexPath: indexPath) as FileCell
        cell.file = self.directories[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.mainScreenWidth(), height: FileCell.height())
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
