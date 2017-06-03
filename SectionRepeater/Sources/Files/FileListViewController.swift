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
            view.register(FileCell.self)
    }
    fileprivate let optionView = FilesEditOptionView()
    
    //MARK: Properties
    fileprivate var directories = [File]()
    fileprivate var files = [File]()
    fileprivate var isEditingFiles = false {
        didSet {
            self.navigationController?.setNavigationBarHidden(isEditingFiles, animated: true)
            self.optionView.isHidden = !isEditingFiles
            for cell in self.collectionView.visibleCells {
                cell.isSelected = false
            }
            if isEditingFiles {
                self.collectionView.contentInset = UIEdgeInsetsMake(FilesEditOptionView.height()
                    + FilesEditOptionView.edgeInset().top
                    + FilesEditOptionView.edgeInset().bottom + 20, 0, 49 ,0)
            } else {
                self.collectionView.contentInset = UIEdgeInsetsMake(64, 0, 49 ,0)
            }
            self.collectionView.allowsMultipleSelection = isEditingFiles
            self.loadFiles(url: self.currentURL)
        }
    }
    fileprivate let player = Dependencies.sharedInstance().resolve(serviceType: Player.self)
    public var currentURL: URL = URL.documentsURL

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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = self.currentURL.lastPathComponent
        self.loadFiles(url: self.currentURL)
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
                if let name = alert.textFields?.first?.text, let targetURL = URL(string: name, relativeTo: self?.currentURL) {
                    try FileManager.default.createDirectory(at: targetURL, withIntermediateDirectories: true, attributes: nil)
                    if let currentURL = self?.currentURL {
                        self?.loadFiles(url: currentURL)
                    }
                }
            } catch let error {
                print(error)
            }
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func doneButtonTapped()  {
        self.isEditingFiles = false
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
        let cell = collectionView.deqeueResuableCell(forIndexPath: indexPath) as FileCell
        cell.isSelected = false
        guard let section = FileSectionType(rawValue: indexPath.section) else { return }
        if (isEditingFiles) {
            return
        }
        switch section {
        case .Directory:
            let fileListViewController = FileListViewController()
            fileListViewController.currentURL = self.currentURL.appendingPathComponent(self.directories[indexPath.row].url.lastPathComponent)
            Navigator.push(fileListViewController)
            return
        case .File:
            do {
                try self.player?.play(items: PlayerItem.items(files: self.files), startAt: indexPath.row)
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
        return CGSize(width: UIScreen.mainScreenWidth(), height: FileCell.height())
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension FileListViewController: LoadFilesProtocol {
    func didLoadFiles(directories: [File], files: [File]) {
        self.directories = directories
        self.files = files
        self.collectionView.reloadData()
    }
}

extension FileListViewController: FilesEditOptionViewDelegate {
    func optionEditButtonTapped() {
        guard let selectedItems = self.collectionView.indexPathsForSelectedItems else { return }
        if selectedItems.count > 1 {
            // 선택된 아이템이 2개 이상인 경우 edit할 수 없다.
            return
        }
        guard let indexPath = selectedItems.first else { return }
        var file: File? = nil
        guard let section = FileSectionType(rawValue: indexPath.section) else { return }
        switch section {
        case .Directory:
            file = self.directories[indexPath.row]
            break
        case .File:
            file = self.files[indexPath.row]
            break
        }
        let alert = UIAlertController(title: "Rename", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = file?.url.lastPathComponent
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default) { [weak self] (action) in
            do {
                if let name = alert.textFields?.first?.text, let targetFile = file {
                    let targetURL = URL(fileURLWithPath: String(format: "%@/%@", targetFile.url.deletingLastPathComponent().path, name))
                    try FileManager.default.moveItem(at: targetFile.url, to: targetURL)
                    if let currentURL = self?.currentURL {
                        self?.loadFiles(url: currentURL)
                    }
                }
            } catch let error {
                print(error)
            }
        })
        self.present(alert, animated: true, completion: nil)
    }
    
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
