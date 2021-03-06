//
//  UICollectionView+Extension.swift
//  Repeatit
//
//  Created by KimYongSeong on 2017. 2. 7..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit

extension UICollectionView {
    func register<T: UICollectionViewCell>(_: T.Type) {
        let nibName = String(describing: T.self)
        if Bundle.main.path(forResource: nibName, ofType: "nib") != nil {
            let nib = UINib(nibName: nibName, bundle: nil)
            register(nib, forCellWithReuseIdentifier: nibName)
            return
        }
        register(T.self, forCellWithReuseIdentifier: nibName)
    }

    func registerHeader<T: UICollectionReusableView>(_: T.Type) {
        let nibName = String(describing: T.self)
        if Bundle.main.path(forResource: nibName, ofType: "nib") != nil {
            let nib = UINib(nibName: nibName, bundle: nil)
            register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: nibName)
            return
        }
        register(T.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: nibName)
    }

    func deqeueResuableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(String(describing: T.self))")
        }
        return cell
    }

    func deqeueResuableHeader<T: UICollectionReusableView>(forIndexPath indexPath: IndexPath) -> T {
        guard let header = dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: String(describing: T.self), for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(String(describing: T.self))")
        }
        return header
    }
}
