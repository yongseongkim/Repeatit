//
//  Observable+Extension.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/03/02.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import RxSwift

extension ObservableType {
    func withPrevious(startWith first: Element) -> Observable<(Element, Element)> {
        return scan((first, first)) { ($0.1, $1) }.skip(1)
    }
}
