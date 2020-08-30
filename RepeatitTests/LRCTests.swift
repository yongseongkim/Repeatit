//
//  LRCTests.swift
//  RepeatitTests
//
//  Created by YongSeong Kim on 2020/07/21.
//

import XCTest

class LRCTests: XCTestCase {
    private var sampleContentsForParser: String = ""

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let samplePath = Bundle(for: type(of: self)).path(forResource: "sampleForParserTest", ofType: "lrc")!
        let sampleData = try! Data(contentsOf: URL(fileURLWithPath: samplePath))
        self.sampleContentsForParser = String(data: sampleData, encoding: .utf8) ?? ""
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParserOnShortLyrics() throws {
        let contents = """
            [ti:Intentions (Feat. Quavo)]
            [ar:Justin Bieber]
            [al:Intentions]
            [au:Justin Bieber, Quavious Marshall, Jason Boyd, Dominic Jordan, Jimmy Giannos]
            [by:yongseongkim]
            [la:EN]
            [re:Repeatit]
            [ve:1.0.0]

            [00:13.01]Picture perfect‚ you don′t need no filter
            [00:16.71]Gorgeous‚ make them drop dead‚ you a killer
            [00:19.71]Shower you with all my attention
            [00:22.60]Yeah‚ these are my only intentions
            [00:26.01]Stay in the kitchen cookin′ up‚ got your own bread
            [00:29.61]Heart full of equity‚ You are an asset
        """
        let parser = LRCParser()
        let result = parser.parse(contents: contents)
        XCTAssertEqual(result.metadata.title,"Intentions (Feat. Quavo)")
        XCTAssertEqual(result.metadata.aritst, "Justin Bieber")
        XCTAssertEqual(result.metadata.album, "Intentions")
        XCTAssertEqual(result.metadata.author, "Justin Bieber, Quavious Marshall, Jason Boyd, Dominic Jordan, Jimmy Giannos")
        XCTAssertEqual(result.metadata.writtenBy, "yongseongkim")
        XCTAssertEqual(result.metadata.language, "EN")
        XCTAssertEqual(result.metadata.editor, "Repeatit")
        XCTAssertEqual(result.metadata.versionOfEditor, "1.0.0")
        XCTAssertEqual(result.lines.count, 6)
    }

    func testParserOnLongLyrics() throws {
        let parser = LRCParser()
        let result = parser.parse(contents: sampleContentsForParser)
        XCTAssertEqual(result.metadata.title, "Intentions (Feat. Quavo)")
        XCTAssertEqual(result.metadata.aritst, "Justin Bieber")
        XCTAssertEqual(result.metadata.album, "Intentions")
        XCTAssertEqual(result.metadata.author, "Justin Bieber, Quavious Marshall, Jason Boyd, Dominic Jordan, Jimmy Giannos")
        XCTAssertEqual(result.metadata.writtenBy, "yongseongkim")
        XCTAssertEqual(result.metadata.language, "EN")
        XCTAssertEqual(result.metadata.editor, "Repeatit")
        XCTAssertEqual(result.metadata.versionOfEditor, "1.0.0")
        XCTAssertEqual(result.lines.count, 58)
    }

    func testParserPerformanceOn3minutesSong() throws {
        measure {
            let parser = LRCParser()
            let _ = parser.parse(contents: sampleContentsForParser)
        }
    }

    func testWriterConvert() throws {
        let writer = LRCWriter()
        let result = writer.convert(
            metadata: .init(
                title: "Intentions (Feat. Quavo)",
                artist: "Justin Bieber",
                album: "Intentions",
                author: "Justin Bieber, Quavious Marshall, Jason Boyd, Dominic Jordan, Jimmy Giannos",
                language: "EN",
                writtenBy: "yongseongkim",
                editor: "Repeatit",
                versionOfEditor: "1.0.0",
                offsetMillis: 1000),
            lines: [
                .init(millis: 1000, lyrics: "1초"),
                .init(millis: 2500, lyrics: "2.5초"),
                .init(millis: 3550, lyrics: "3.55초")
            ]
        )
        var expected = ""
        expected += "[al:Intentions]\n"
        expected += "[ar:Justin Bieber]\n"
        expected += "[au:Justin Bieber, Quavious Marshall, Jason Boyd, Dominic Jordan, Jimmy Giannos]\n"
        expected += "[by:yongseongkim]\n"
        expected += "[la:EN]\n"
        expected += "[offset:1000]\n"
        expected += "[re:Repeatit]\n"
        expected += "[ti:Intentions (Feat. Quavo)]\n"
        expected += "[ve:1.0.0]\n"
        expected += "\n"
        expected += "[00:01.00]1초\n"
        expected += "[00:02.50]2.5초\n"
        expected += "[00:03.55]3.55초\n"
        XCTAssertEqual(result, expected)
    }

    func testBoth() throws {
        let parser = LRCParser()
        let originalContents = parser.parse(contents: sampleContentsForParser)
        let writer = LRCWriter()
        let writerResult = writer.convert(metadata: originalContents.metadata, lines: originalContents.lines)
        let targetContents = parser.parse(contents: writerResult)
        XCTAssertEqual(originalContents.metadata.title, targetContents.metadata.title)
        XCTAssertEqual(originalContents.metadata.album, targetContents.metadata.album)
        XCTAssertEqual(originalContents.metadata.aritst, targetContents.metadata.aritst)
        XCTAssertEqual(originalContents.metadata.author, targetContents.metadata.author)
        XCTAssertEqual(originalContents.metadata.editor, targetContents.metadata.editor)
        XCTAssertEqual(originalContents.metadata.language, targetContents.metadata.language)
        XCTAssertEqual(originalContents.lines.count, targetContents.lines.count)
        XCTAssertEqual(originalContents.metadata.offsetMillis, targetContents.metadata.offsetMillis)
        for idx in 0..<max(originalContents.lines.count, targetContents.lines.count) {
            let originalLine = originalContents.lines[idx]
            let targetLine = targetContents.lines[idx]
            XCTAssertEqual(String(describing: originalLine), String(describing: targetLine))
        }
    }
}
