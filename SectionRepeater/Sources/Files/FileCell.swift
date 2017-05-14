//
//  DocumentFileCell.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 4. 16..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxGesture
import URLNavigator

class FileCell: UICollectionViewCell {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    public var editing: Bool = false
    fileprivate var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.bind()
    }
    
    public var file: File? {
        didSet {
            if let file = file {
                coverImageView.image = nil
                nameLabel.text = file.name
            } else {
                coverImageView.image = nil
                nameLabel.text = ""
            }
        }
    }
    
    func bind() {
//        self.contentView.rx.tapGesture()
//            .when(.recognized)
//            .subscribe(onNext: { [weak self] (tap) in
//                guard let `self` = self else { return }
//                if (self.editing) {
//                    self.isSelected = !self.isSelected
//                    return
//                }
//                guard let file = self.file else { return }
//                if file.isDirectory {
//                    let documentsViewController = DocumentsViewController()
//                    documentsViewController.currentPath = file.url.path
//                    Navigator.push(documentsViewController)
//                } else {
//                    let context = PlayItemContext()
//                    context.audioItem = AudioItem(url: file.url)
//                    let playerController = AudioPlayerViewController(nibName: AudioPlayerViewController.className(), bundle: nil)
//                    playerController.modalPresentationStyle = .custom
//                    playerController.context = context
//                    Navigator.present(playerController)
//                }
//            })
//            .disposed(by: self.disposeBag)
    }
    
    override var isSelected: Bool {
        didSet {
            if (isSelected && editing) {
                self.coverImageView.isHidden = true
                self.selectedImageView.isHidden = false
            } else {
                self.coverImageView.isHidden = false
                self.selectedImageView.isHidden = true
            }
        }
    }
    
    class func height() -> CGFloat {
        return 50
    }
}
