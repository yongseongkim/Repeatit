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
import URLNavigator

class FilesMoveDestinationViewController: UIViewController {

    //MARK: UI Componenets
    fileprivate let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
        ).then { (view) in
            view.backgroundColor = UIColor.white
            view.register(FileCell.self)
            view.allowsMultipleSelection = true
            view.contentInset = UIEdgeInsetsMake(64, 0, 119 , 0)
    }
    fileprivate let moveHereButton = UIButton().then { (button) in
        button.setTitle("MoveHere", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.contentHorizontalAlignment = .center
        button.backgroundColor = UIColor.greenery
    }
    
    //MARK: Properties
    public var relativePath: String = ""
    fileprivate var currentURL: URL {
        get {
            return URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]).appendingPathComponent(relativePath)
        }
    }
    fileprivate var directories = [File]()
    public var selectedPaths: [String]?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelButtonTapped))
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
        self.view.addSubview(self.moveHereButton)
        
        self.updateConstraint()
        self.bind()
        self.loadOnlyDirectories(url: self.currentURL)
    }
    
    func updateConstraint() {
        self.collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        self.moveHereButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view.snp.centerX)
            make.bottom.equalTo(self.view).offset(-20)
            make.width.equalTo(240)
            make.height.equalTo(40)
        }
    }
    
    func bind() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.moveHereButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }
    
    func enterForeground() {
        self.collectionView.reloadData()
    }
    
    func cancelButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonTapped() {
        guard let paths = self.selectedPaths else { return }
        for path in paths {
            do {
                if FileManager.default.fileExists(atPath: path) {
                    let url = URL(fileURLWithPath: path)
                    try FileManager.default.moveItem(atPath: path, toPath: self.currentURL.appendingPathComponent(url.lastPathComponent).path)
                }
            } catch let error {
                print(error)
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension FilesMoveDestinationViewController: LoadFilesProtocol {
    func didLoadFiles(directories: [File], files: [File]) {
        self.directories = directories
        self.collectionView.reloadData()
    }
}

extension FilesMoveDestinationViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.deqeueResuableCell(forIndexPath: indexPath) as FileCell
        cell.isSelected = false
        let destinationViewController = FilesMoveDestinationViewController()
        destinationViewController.selectedPaths = self.selectedPaths
        destinationViewController.relativePath = self.relativePath.appending(String(format: "/%@", self.directories[indexPath.row].url.lastPathComponent))
        Navigator.push(destinationViewController)
    }
}
