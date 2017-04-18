//
//  DocumentFilesMoveDestinationViewController.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 4. 16..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import SnapKit

class DocumentFilesMoveDestinationViewController: UIViewController {
    
    fileprivate var collectionView: UICollectionView? {
        didSet {
            self.collectionView?.dataSource = self
            self.collectionView?.delegate = self
            self.collectionView?.register(DocumentFileCell.self)
        }
    }
    fileprivate var displayManager: FileDisplayManager?
    fileprivate var directories = [FileDisplayItem]()

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
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "AddFolder", style: .done, target: self, action: #selector(addButtonTapped))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "MoveHere", style: .done, target: self, action: #selector(doneButtonTapped))
    }
    
    func addButtonTapped() {
    }
    
    func doneButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension DocumentFilesMoveDestinationViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.directories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.deqeueResuableCell(forIndexPath: indexPath) as DocumentFileCell
        cell.item = self.directories[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = self.directories[indexPath.row]
        if (item.isParentDirectory){
            self.displayManager?.moveToParentDirectory()
            return
        }
        self.displayManager?.moveToDirectory(directoryName: item.name)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.mainScreenWidth(), height: DocumentFileCell.height())
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension DocumentFilesMoveDestinationViewController: FileDisplayManagerDelegate {
    func didChangeCurrentPath(directories: [FileDisplayItem], files: [FileDisplayItem]) {
        self.directories = directories
        self.collectionView?.reloadData()
    }
}
