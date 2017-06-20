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
    }
    fileprivate let optionView = FilesEditOptionView()
    
    //MARK: Properties
    fileprivate var directories = [File]()
    fileprivate var files = [File]()
    fileprivate var isEditingFiles = false {
        didSet {
            self.navigationController?.setNavigationBarHidden(self.isEditingFiles, animated: true)
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let `self` = self else { return }
                let offset = self.isEditingFiles ? CGFloat(0) : -FilesEditOptionView.height()
                self.optionView.snp.updateConstraints({ (make) in
                    make.top.equalTo(self.view).offset(offset)
                })
                self.view.layoutIfNeeded()
            }
            for cell in self.collectionView.visibleCells {
                cell.isSelected = false
            }
            self.collectionView.allowsMultipleSelection = isEditingFiles
            self.loadFiles()
        }
    }
    fileprivate let player = Dependencies.sharedInstance().resolve(serviceType: Player.self)!
    fileprivate let currentURL: URL
    
    convenience init() {
        self.init(url: URL.documentsURL)
    }

    init(url: URL) {
        self.currentURL = url
        self.optionView.currentURL = self.currentURL
        super.init(nibName: nil, bundle: nil)
        let optionButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44)).then { (button) in
            button.setImage(UIImage(named: "btn_common_option_44pt"), for: .normal)
            button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: optionButton)
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
        self.updateConstraints()
        self.updateContentInset()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = self.currentURL.lastPathComponent
        self.loadFiles()
    }
    
    func updateConstraints() {
        self.collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        self.optionView.snp.makeConstraints({ (make) in
            make.top.equalTo(self.view).offset(-FilesEditOptionView.height())
            make.left.equalTo(self.view).offset(0)
            make.right.equalTo(self.view).offset(0)
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
    
    func doneButtonTapped()  {
        self.isEditingFiles = false
    }
    
    public func updateContentInset() {
        if PlayerView.isVisible() {
            self.collectionView.contentInset = UIEdgeInsetsMake(FilesEditOptionView.height(), 0, PlayerView.height(), 0)
        } else {
            self.collectionView.contentInset = UIEdgeInsetsMake(FilesEditOptionView.height(), 0, 0, 0)
        }
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
        if (isEditingFiles) {
            self.optionView.selectedIndexPaths = self.collectionView.indexPathsForSelectedItems
            return
        }
        let cell = collectionView.deqeueResuableCell(forIndexPath: indexPath) as FileCell
        guard let section = FileSectionType(rawValue: indexPath.section) else { return }
        cell.isSelected = false
        switch section {
        case .Directory:
            let fileListViewController = FileListViewController(url: self.currentURL.appendingPathComponent(self.directories[indexPath.row].url.lastPathComponent))
            Navigator.push(fileListViewController)
            return
        case .File:
            do {
                try self.player.play(items: PlayerItem.items(files: self.files), startAt: indexPath.row)
                let playerController = PlayerViewController(nibName: PlayerViewController.className(), bundle: nil)
                playerController.modalPresentationStyle = .custom
                Navigator.present(playerController)
            } catch let error {
                print(error)
            }
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if (isEditingFiles) {
            self.optionView.selectedIndexPaths = self.collectionView.indexPathsForSelectedItems
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.mainWidth, height: FileCell.height())
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension FileListViewController: FilesEditOptionViewDelegate {
    func optionAddButtonTapped() {
        let alert = UIAlertController(title: "새폴더", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "폴더명을 입력해주세요."
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
        if let indexPaths = self.collectionView.indexPathsForSelectedItems {
            let files = indexPaths.map({ (ip) -> File in
                return (FileSectionType(rawValue: ip.section)! == .Directory) ? self.directories[ip.row] : self.files[ip.row]
            })
            File.delete(files: files)
        }
        self.isEditingFiles = false
    }
    
    func optionDoneButtonTapped() {
        self.isEditingFiles = false
    }
}
