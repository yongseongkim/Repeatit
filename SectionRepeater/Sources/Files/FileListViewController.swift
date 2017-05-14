//
//  FileListViewController.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 2. 7..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import URLNavigator

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
            view.allowsMultipleSelection = true
            view.register(FileCell.self)
    }
    fileprivate let optionView = FilesEditOptionView()
    
    //MARK: Properties
    fileprivate var directories = [File]()
    fileprivate var files = [File]()
    fileprivate var isEditingFiles = false {
        didSet {
            self.navigationController?.setNavigationBarHidden(isEditing, animated: true)
            self.optionView.isHidden = !isEditing
            for cell in self.collectionView.visibleCells {
                cell.isSelected = false
            }
            if isEditing {
                self.collectionView.contentInset = UIEdgeInsetsMake(FilesEditOptionView.height()
                    + FilesEditOptionView.edgeInset().top
                    + FilesEditOptionView.edgeInset().bottom + 20, 0, 49 ,0)
            } else {
                self.collectionView.contentInset = UIEdgeInsetsMake(64, 0, 49 ,0)
            }
            self.collectionView.reloadData()
        }
    }
    public var currentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] {
        didSet {
            self.loadFiles()
        }
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addButtonTapped)),
                                                   UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))]
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
        self.view.addSubview(self.optionView)
        
        self.bind()
        self.updateConstraint()
        self.isEditingFiles = false
        self.loadFiles()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
    }
    
    func updateConstraint() {
        self.collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        self.optionView.snp.makeConstraints({ (make) in
            make.top.equalTo(self.view).offset(25)
            make.left.equalTo(self.view).offset(10)
            make.right.equalTo(self.view).offset(-10)
            make.height.equalTo(FilesEditOptionView.height())
        })
    }
    
    func bind() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.optionView.delegate = self
    }
    
    func enterForeground() {
        self.collectionView.reloadData()
    }
    
    func editButtonTapped() {
        self.isEditingFiles = true
    }
    
    func addButtonTapped() {
        let alert = UIAlertController(title: "새폴더", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "폴더명을 입력해주세요."
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default) { [weak self] (action) in
            do {
                if let name = alert.textFields?.first?.text, let path = self?.currentPath {
                    let url = URL(fileURLWithPath: String(format: "%@/%@", path, name))
                    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
                }
            } catch let error {
                print(error)
            }
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func doneButtonTapped()  {
        self.isEditingFiles = false
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addButtonTapped)),
                                                   UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))]
    }
    
    fileprivate func loadFiles() {
        var directories = [File]()
        var files = [File]()
        do {
            let fileNames = try FileManager.default.contentsOfDirectory(atPath: self.currentPath)
            for fileName in fileNames {
                let url = URL(fileURLWithPath: self.currentPath.appendingFormat("/%@", fileName))
                var isDir:ObjCBool = true
                if (FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)) {
                    if (isDir.boolValue) {
                        directories.append(File(url: url, isDirectory: true))
                    } else {
                        files.append(File(url: url))
                    }
                }
            }
        } catch let error {
            print(error)
        }
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
        cell.editing = self.isEditingFiles
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
        if (isEditingFiles) {
            return
        }
        let cell = collectionView.deqeueResuableCell(forIndexPath: indexPath) as FileCell
        cell.isSelected = false
        switch section {
        case .Directory:
            let fileListViewController = FileListViewController()
            fileListViewController.currentPath = self.directories[indexPath.row].url.path
            Navigator.push(fileListViewController)
            return
        case .File:
            let playerController = AudioPlayerViewController(nibName: AudioPlayerViewController.className(), bundle: nil)
            playerController.modalPresentationStyle = .custom
            let context = PlayItemContext()
            context.audioItem = AudioItem(url: self.files[indexPath.row].url)
            playerController.context = context
            Navigator.present(playerController)
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.mainScreenWidth(), height: FileCell.height())
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension FileListViewController: FilesEditOptionViewDelegate {
    func optionMoveButtonTapped() {
        var paths = [String]()
        if let indexPaths = self.collectionView.indexPathsForSelectedItems {
            for indexPath in indexPaths {
                guard let section = FileSectionType(rawValue: indexPath.section) else { continue }
                switch section {
                case .Directory:
                    paths.append(self.directories[indexPath.row].url.path)
                    break
                case .File:
                    paths.append(self.files[indexPath.row].url.path)
                    break
                }
            }
        }
        let viewController = FilesMoveDestinationViewController()
        viewController.currentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        viewController.selectedPaths = paths
        let naviController = UINavigationController(rootViewController: viewController)
        self.present(naviController, animated: true, completion: nil)
    }
    
    func optionDeleteButtonTapped() {
        if let indexPaths = self.collectionView.indexPathsForSelectedItems {
            for indexPath in indexPaths {
                guard let section = FileSectionType(rawValue: indexPath.section) else { continue }
                do {
                    switch section {
                    case .Directory:
                        try FileManager.default.removeItem(at: self.directories[indexPath.row].url)
                        break
                    case .File:
                        try FileManager.default.removeItem(at: self.files[indexPath.row].url)
                        break
                    }
                } catch let error {
                    print(error)
                }
            }
        }
        self.isEditingFiles = false
    }
    
    func optionDoneButtonTapped() {
        self.isEditingFiles = false
    }
}
