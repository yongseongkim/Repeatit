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
            if let collectionView = collectionView {
                self.view.addSubview(collectionView)
                collectionView.snp.makeConstraints { (make) in
                    make.top.equalTo(self.view)
                    make.right.equalTo(self.view)
                    make.bottom.equalTo(self.view)
                    make.left.equalTo(self.view)
                }
            }
            self.collectionView?.backgroundColor = UIColor.white
            self.collectionView?.dataSource = self
            self.collectionView?.delegate = self
            self.collectionView?.register(DocumentFileCell.self)
        }
    }
    fileprivate var directories = [FileDisplayItem]()
    public var displayManager: FileDisplayManager?
    public var selectedPaths: [String]?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        self.displayManager?.delegate = self
        self.displayManager?.loadCurrentPathContents()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "MoveHere", style: .done, target: self, action: #selector(doneButtonTapped))
    }
    
    func cancelButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonTapped() {
        if let paths = self.selectedPaths {
            self.displayManager?.moveFiles(paths: paths)
        }
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
        collectionView.deselectItem(at: indexPath, animated: false)
        let item = self.directories[indexPath.row]
        if let path = self.displayManager?.directoryPath(directoryName: item.name) {
            let viewController = DocumentFilesMoveDestinationViewController()
            viewController.selectedPaths = self.selectedPaths
            viewController.displayManager = FileDisplayManager(rootPath: path)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
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
