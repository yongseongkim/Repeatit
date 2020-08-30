//
//  LRCComponent.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/07/20.
//

import Foundation

struct LRCMetadata {
    /*
     [ti:가사(노래) 제목] [ti:Intentions (Feat. Quavo)]
     [ar:가사 아티스트] [ar:Justin Bieber]
     [al:노래의 앨범] [al:Intentions]
     [au:가사 작성자] [au:Justin Bieber, Quavious Marshall, Jason Boyd, Dominic Jordan, Jimmy Giannos]
     [la:언어] [la:EN]
     [by:LRC파일의 작성자] [by:yongseongkim]
     [offset:+/- ms단위로 전체 오브셋조정]
     [re:LRC를 작성한 플레이어나 편집기] [re:Repeatit]
     [ve:프로그렘 버전] [ve:1.0.0]
     */
    let title: String?
    let aritst: String?
    let album: String?
    let author: String?
    let language: String?
    let writtenBy: String?
    let editor: String?
    let versionOfEditor: String?
    let offsetMillis: Int?

    init(params: [String: String]) {
        title = params["ti"]
        aritst = params["ar"] ?? ""
        album = params["al"] ?? ""
        author = params["au"] ?? ""
        language = params["la"] ?? ""
        writtenBy = params["by"] ?? ""
        editor = params["re"] ?? Bundle.main.infoDictionary?["CFBundleName"] as? String
        versionOfEditor = params["ve"] ?? Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        offsetMillis = Int(params["offset"] ?? "")
    }

    init(
        title: String? = nil,
        artist: String? = nil,
        album: String? = nil,
        author: String? = nil,
        language: String? = nil,
        writtenBy: String? = nil,
        editor: String? = nil,
        versionOfEditor: String? = nil,
        offsetMillis: Int? = nil
    ) {
        self.title = title
        self.aritst = artist
        self.album = album
        self.author = author
        self.language = language
        self.writtenBy = writtenBy
        self.editor = editor
        self.versionOfEditor = versionOfEditor
        self.offsetMillis = offsetMillis
    }

    func toParams() -> [String: String] {
        var params = [String: String]()
        if title != nil {
            params["ti"] = title
        }
        if aritst != nil {
            params["ar"] = aritst
        }
        if album != nil {
            params["al"] = album
        }
        if author != nil {
            params["au"] = author
        }
        if language != nil {
            params["la"] = language
        }
        if writtenBy != nil {
            params["by"] = writtenBy
        }
        if editor != nil {
            params["re"] = editor
        }
        if versionOfEditor != nil {
            params["ve"] = versionOfEditor
        }
        if let offset = offsetMillis {
            params["offset"] = "\(offset)"
        }
        return params
    }
}

struct LRCLine {
    /*
     [00:13.01]Picture perfect‚ you don′t need no filter
     [00:16.71]Gorgeous‚ make them drop dead‚ you a killer
     [00:19.71]Shower you with all my attention
     [00:22.60]Yeah‚ these are my only intentions
     [00:26.01]Stay in the kitchen cookin′ up‚ got your own bread
     */
    let millis: Int
    let lyrics: String

    func update(millis: Int? = nil, lyrics: String? = nil) -> LRCLine {
        return LRCLine(
            millis: millis ?? self.millis,
            lyrics: lyrics ?? self.lyrics
        )
    }
}

extension LRCLine: Equatable {
}
