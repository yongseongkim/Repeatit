//
//  Dependencies.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 3. 19..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import Swinject

class Dependencies {
    static fileprivate var instance: Dependencies?
    class func sharedInstance() -> Dependencies {
        if let instance = instance {
            return instance
        }
        let created = Dependencies()
        created.container = Container()
        created.setup()
        self.instance = created
        return created
    }

    fileprivate var container: Container?
    func setup() {
        guard let container = self.container else { return }
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        container.register(AudioManager.self) { _ in AudioManager() }.inObjectScope(.container)
        container.register(FileDisplayManager.self) { _ in FileDisplayManager(rootPath: documentsPath) }
    }
    
    func resolve<Service>(serviceType: Service.Type) -> Service? {
        return self.container?.resolve(serviceType)
    }
}
