//
//  FileListEditViewController.swift
//  ListenNRepeat
//
//  Created by KimYongSeong on 2017. 7. 13..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import Foundation

import UIKit
import URLNavigator
import RealmSwift

class FileListEditViewController: UIViewController {
    
    //MARK: UI Componenets
    fileprivate let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
        ).then { (view) in
            view.backgroundColor = UIColor.white
            view.register(FileCell.self)
            view.alwaysBounceVertical = true
            view.allowsMultipleSelection = true
    }
    fileprivate let optionView = FileEditOptionView()
    
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
        
        let doneButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44)).then { (button) in
            button.setImage(UIImage(named: "btn_common_x_44pt"), for: .normal)
            button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        }
        self.navigationItem.rightBarButtonItems = [spaceButton, UIBarButtonItem(customView: doneButton)]
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
        self.view.addSubview(self.optionView)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(self.view)
        }
        if let navigationBarHeight = self.navigationController?.navigationBar.frame.height {
            let topOffset = navigationBarHeight + UIApplication.shared.statusBarFrame.height
            self.collectionView.contentInset = UIEdgeInsets(top: topOffset, left: 0, bottom: FileEditOptionView.height(), right: 0)
        }
        self.optionView.delegate = self
        self.optionView.snp.makeConstraints { (make) in
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(FileEditOptionView.height())
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = self.currentURL.lastPathComponent
        self.loadFiles()
    }
    
    func enterForeground() {
        self.loadFiles()
    }
    
    func doneButtonTapped() {
        self.dismiss(animated: false, completion: nil)
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

extension FileListEditViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
        cell.editing = true
        switch section {
        case .Directory:
            cell.file = self.directories[indexPath.row]
        case .File:
            cell.file = self.files[indexPath.row]
        }
        return cell
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

extension FileListEditViewController: FileEditOptionViewDelegate {
    func optionAddButtonTapped() {
        let alert = UIAlertController(title: "New Folder", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "What is new folder name?"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default) { [weak self] (action) in
            do {
                if let name = alert.textFields?.first?.text, let targetURL = URL(string: name, relativeTo: self?.currentURL) {
                    try FileManager.default.createDirectory(at: targetURL, withIntermediateDirectories: true, attributes: nil)
                    self?.loadFiles()
                }
            } catch let error {
                print(error)
            }
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func optionEditButtonTapped() {
        guard let selectedItems = self.collectionView.indexPathsForSelectedItems else { return }
        if selectedItems.count > 1 {
            // 선택된 아이템이 2개 이상인 경우 edit할 수 없다.
            return
        }
        guard let indexPath = selectedItems.first else { return }
        guard let section = FileSectionType(rawValue: indexPath.section) else { return }
        let target = (section == .Directory) ? self.directories[indexPath.row] : self.files[indexPath.row]
        let alert = UIAlertController(title: "Rename", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = target.url.lastPathComponent
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default) { [weak self] (action) in
            if let name = alert.textFields?.first?.text {
                File.rename(file: target, rename: name)
                self?.loadFiles()
            }
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func optionMoveButtonTapped() {
        var files = [File]()
        if let indexPaths = self.collectionView.indexPathsForSelectedItems {
            for indexPath in indexPaths {
                guard let section = FileSectionType(rawValue: indexPath.section) else { continue }
                let target = (section == .Directory) ? self.directories[indexPath.row] : self.files[indexPath.row]
                files.append(target)
            }
        }
        if (files.count > 0) {
            let naviController = FileDestinationViewController(rootViewController: FileDestinationFileListViewController())
            naviController.selectedFiles = files
            self.present(naviController, animated: true, completion: nil)
        }
    }
    
    func optionDeleteButtonTapped() {
        let alert = UIAlertController(title: "Delete", message: "Do you really delete files?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default) { [weak self] (action) in
            guard let weakSelf = self else { return }
            if let indexPaths = weakSelf.collectionView.indexPathsForSelectedItems {
                let files = indexPaths.map({ (ip) -> File in
                    return (FileSectionType(rawValue: ip.section)! == .Directory) ? weakSelf.directories[ip.row] : weakSelf.files[ip.row]
                })
                File.delete(files: files)
            }
            weakSelf.loadFiles()
        })
        self.present(alert, animated: true, completion: nil)
    }
}
