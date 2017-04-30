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
            if let collectionView = collectionView {
                self.view.addSubview(collectionView)
                collectionView.snp.makeConstraints { (make) in
                    make.top.equalTo(self.view)
                    make.left.equalTo(self.view)
                    make.right.equalTo(self.view)
                    make.bottom.equalTo(self.view)
                }
            }
            self.collectionView?.backgroundColor = UIColor.white
            self.collectionView?.dataSource = self
            self.collectionView?.delegate = self
            self.collectionView?.register(DocumentFileCell.self)
            self.collectionView?.allowsMultipleSelection = true
        }
    }
    fileprivate var optionView: DocumentFileEditOptionView? {
        didSet {
            if let optionView = optionView {
                self.view.addSubview(optionView)
                optionView.delegate = self
                optionView.snp.makeConstraints({ (make) in
                    make.top.equalTo(self.view).offset(25)
                    make.left.equalTo(self.view).offset(10)
                    make.right.equalTo(self.view).offset(-10)
                    make.height.equalTo(DocumentFileEditOptionView.height())
                })
            }
        }
    }
    
    public var displayManager: FileDisplayManager?
    fileprivate var files = [FileDisplayItem]()
    fileprivate var directories = [FileDisplayItem]()
    fileprivate var isEditingFiles = false {
        didSet {
            self.navigationController?.setNavigationBarHidden(isEditingFiles, animated: true)
            self.optionView?.isHidden = !isEditingFiles
            if let cells = self.collectionView?.visibleCells {
                for cell in cells {
                    cell.isSelected = false
                }
            }
            if isEditingFiles {
                self.collectionView?.contentInset = UIEdgeInsetsMake(DocumentFileEditOptionView.height()
                    + DocumentFileEditOptionView.edgeInset().top
                    + DocumentFileEditOptionView.edgeInset().bottom + 20, 0, 49 ,0)
            } else {
                self.collectionView?.contentInset = UIEdgeInsetsMake(64, 0, 49 ,0)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        self.optionView = DocumentFileEditOptionView(frame: self.view.bounds)
        self.isEditingFiles = false
        self.displayManager?.delegate = self
        self.displayManager?.loadCurrentPathContents()
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addButtonTapped)),
                                                   UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))]
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
    }
    
    func addButtonTapped() {
        weak var weakSelf = self
        let alert = UIAlertController(title: "새폴더", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "폴더명을 입력해주세요."
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default) { (action) in
            if let name = alert.textFields?.first?.text, let displayManager = weakSelf?.displayManager {
                if (displayManager.createDirectory(name: name)) {
                    weakSelf?.collectionView?.reloadData()
                }
            }
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func doneButtonTapped()  {
        self.isEditingFiles = false
        self.collectionView?.reloadData()
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addButtonTapped)),
                                                   UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))]
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
        cell.editing = self.isEditingFiles
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
        collectionView.deselectItem(at: indexPath, animated: false)
        guard let section = DocumentAudioFilesSectionType(rawValue: indexPath.section) else { return }
        switch section {
        case .Directory:
            let item = self.directories[indexPath.row]
            if let path = self.displayManager?.directoryPath(directoryName: item.name) {
                let documentsViewController = DocumentAudioFilesViewController()
                documentsViewController.displayManager = FileDisplayManager(rootPath: path)
                self.navigationController?.pushViewController(documentsViewController, animated: true)
            }
        case .File:
            let context = PlayItemContext()
            context.audioItem = AudioItem(url: URL(fileURLWithPath: self.files[indexPath.row].path))
            let playerController = AudioPlayerViewController(nibName: AudioPlayerViewController.className(), bundle: nil)
            playerController.modalPresentationStyle = .custom
            playerController.context = context
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

extension DocumentAudioFilesViewController: DocumentFileEditOptionViewDelegate {
    func optionMoveButtonTapped() {
        var paths = [String]()
        if let indexPaths = self.collectionView?.indexPathsForSelectedItems {
            for indexPath in indexPaths {
                if let cell = self.collectionView?.cellForItem(at: indexPath) as? DocumentFileCell {
                    if let path = cell.item?.path {
                        paths.append(path)
                    }
                }
            }
        }
        let viewController = DocumentFilesMoveDestinationViewController()
        viewController.displayManager = Dependencies.sharedInstance().resolve(serviceType: FileDisplayManager.self)
        viewController.selectedPaths = paths
        let naviController = UINavigationController(rootViewController: viewController)
        self.present(naviController, animated: true, completion: nil)
    }
    
    func optionDeleteButtonTapped() {
        if let indexPaths = self.collectionView?.indexPathsForSelectedItems {
            for indexPath in indexPaths {
                if let cell = self.collectionView?.cellForItem(at: indexPath) as? DocumentFileCell, let item = cell.item {
                    self.displayManager?.deleteFile(item: item)
                }
            }
        }
        self.isEditingFiles = false
    }
    
    func optionDoneButtonTapped() {
        self.isEditingFiles = false
    }
}
