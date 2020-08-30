//
//  WebVTTTests.swift
//  RepeatitTests
//
//  Created by YongSeong Kim on 2020/07/23.
//

import XCTest

class WebVTTTests: XCTestCase {
    private var sampleContentsForParser: String = ""
    private var sampleURLForWebVTTControlelr: URL?

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let samplePath = Bundle(for: type(of: self)).path(forResource: "sampleForParserTest", ofType: "vtt")!
        let sampleData = try! Data(contentsOf: URL(fileURLWithPath: samplePath))
        self.sampleContentsForParser = String(data: sampleData, encoding: .utf8) ?? ""

        // TODO: Use Inmemory system for WebVTTController Test.
        let sampleURLForWebVTTControlelr = URL(fileURLWithPath: Bundle(for: type(of: self)).path(forResource: "sampleForWebVTTControllerTest", ofType: "vtt")!)
        let copyOfSampleURL = sampleURLForWebVTTControlelr.deletingLastPathComponent().appendingPathComponent("copySampleForWebVTTControlelrTest.vtt")
        self.sampleURLForWebVTTControlelr = copyOfSampleURL
        try? FileManager.default.removeItem(at: copyOfSampleURL)
        try? FileManager.default.copyItem(at: sampleURLForWebVTTControlelr, to: copyOfSampleURL)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParser() throws {
        let parser = SimpleWebVTTParser()
        let result = try! parser.parse(contents: sampleContentsForParser)
        XCTAssertEqual(result.title, "Some title")
        let notes = result.components.compactMap { $0 as? WebVTTNote }
        XCTAssertEqual(notes.count, 2)
        XCTAssertEqual(notes.first!.comment, "Bekind - Marshmello, Halsey\n2020.05.11\nUniversal Music Group")
        XCTAssertEqual(notes.last!.comment, "This is the last line in the file")
        let cues = result.components.compactMap { $0 as? WebVTTCue }
        XCTAssertEqual(cues.count, 15)

        XCTAssertEqual(cues.filter { !($0.identifier?.isEmpty ?? true) }.count, 3)
        XCTAssertGreaterThanOrEqual(cues.filter { $0.identifier == "3 cue identifier" }.count, 1)
        XCTAssertGreaterThanOrEqual(cues.filter { $0.payload.contains("\n") }.count, 1)
        // TODO: Is this specific case good?
        let settings = cues.compactMap { $0.settings }
        XCTAssertGreaterThanOrEqual(
            settings.filter { $0.vertical == nil && $0.line == "0" && $0.position == "20%" && $0.size == "60%" && $0.align == "start" }.count,
            1
        )
        XCTAssertGreaterThanOrEqual(
            settings.filter { $0.vertical == nil && $0.line == nil && $0.position == "10%,line-left" && $0.size == "35%" && $0.align == "left" }.count,
            1
        )
    }

    func testWriter() throws {
        let writer = SimpleWebVTTWriter()
        let result = writer.convert(
            title: "Test Write",
            components: [
                WebVTTNote(comment: "single comment"),
                WebVTTCue(
                    identifier: "1 identifier test",
                    startMillis: 34000,
                    endMillis: 39000,
                    payload: "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                    settings: nil
                ),
                WebVTTCue(
                    identifier: nil,
                    startMillis: 94100,
                    endMillis: 99000,
                    payload: "Lorem Ipsum is simply dummy text of the printing and typesetting industry.\nLorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
                    settings: .init(
                        vertical: "rl",
                        line: "0%",
                        position: "100%",
                        size: "60%",
                        align: "start"
                    )
                ),
                WebVTTNote(comment: "first line\nseconds line"),
                WebVTTCue(
                    identifier: "2 identifier test",
                    startMillis: 634200,
                    endMillis: 644300,
                    payload: "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                    settings: .init(
                        vertical: nil,
                        line: nil,
                        position: "35%,line-left",
                        size: nil,
                        align: "middle"
                    )
                ),
                WebVTTCue(
                    identifier: nil,
                    startMillis: 924000,
                    endMillis: 939000,
                    payload: "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
                    settings: nil
                ),
            ]
        )

        var expected = ""
        expected += "WEBVTT - Test Write\n"
        expected += "\n"
        expected += "NOTE single comment\n"
        expected += "\n"
        expected += "1 identifier test\n"
        expected += "00:34.000 --> 00:39.000\n"
        expected += "Lorem Ipsum is simply dummy text of the printing and typesetting industry.\n"
        expected += "\n"
        expected += "01:34.100 --> 01:39.000 vertical:rl line:0% position:100% size:60% align:start\n"
        expected += "Lorem Ipsum is simply dummy text of the printing and typesetting industry.\nLorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.\n"
        expected += "\n"
        expected += "NOTE\n"
        expected += "first line\n"
        expected += "seconds line\n"
        expected += "\n"
        expected += "2 identifier test\n"
        expected += "10:34.200 --> 10:44.300 position:35%,line-left align:middle\n"
        expected += "Lorem Ipsum is simply dummy text of the printing and typesetting industry.\n"
        expected += "\n"
        expected += "15:24.000 --> 15:39.000\n"
        expected += "Lorem Ipsum is simply dummy text of the printing and typesetting industry.\n"
        expected += "\n"
        XCTAssertEqual(result, expected)
    }

    func testBoth() throws {
        let parser = SimpleWebVTTParser()
        let originalContents = try parser.parse(contents: sampleContentsForParser)
        let writer = SimpleWebVTTWriter()
        let writerResult = writer.convert(title: originalContents.title, components: originalContents.components)
        let targetContents = try parser.parse(contents: writerResult)
        XCTAssertEqual(originalContents.title, targetContents.title)
        XCTAssertEqual(originalContents.components.count, targetContents.components.count)
        for idx in 0..<max(originalContents.components.count, targetContents.components.count) {
            let originalComponent = originalContents.components[idx]
            let targetComponent = targetContents.components[idx]
            XCTAssertEqual(String(describing: originalComponent), String(describing: targetComponent))
        }
    }

    func testControllerAdd() throws {
        guard let sampleURLForWebVTTControlelr = self.sampleURLForWebVTTControlelr else { return }
        let controller = WebVTTController(url: sampleURLForWebVTTControlelr, duration: 1000000)
        // If a new cues starts before a previous cue ends, the previous cue's end millis should be updated.
        // And the new cue's start millis is the next cue's start millis.
        controller.addCue(at: 14000)
        XCTAssertEqual(controller.cues.count, 6)
        XCTAssertEqual(controller.cues[0].endMillis, 14000)
        XCTAssertEqual(controller.cues[1].endMillis, controller.cues[2].startMillis)
        // If a new cue's starts after a previous cue ends, the cue component's end millis don't need to be updated.
        controller.addCue(at: 27000)
        XCTAssertEqual(controller.cues.count, 7)
        XCTAssertEqual(controller.cues[2].endMillis, 25000)
        XCTAssertEqual(controller.cues[3].endMillis, controller.cues[4].startMillis)
        controller.addCue(at: 34000)
        XCTAssertEqual(controller.cues.count, 8)
        XCTAssertEqual(controller.cues[4].endMillis, 34000)
        XCTAssertEqual(controller.cues[5].endMillis, controller.cues[6].startMillis)
        controller.addCue(at: 47000)
        XCTAssertEqual(controller.cues.count, 9)
        XCTAssertEqual(controller.cues[6].endMillis, 45000)
        XCTAssertEqual(controller.cues[7].endMillis, controller.cues[8].startMillis)
        // When inserting a new cue at last index, the new cue's end millis is duration.
        controller.addCue(at: 57000)
        XCTAssertEqual(controller.cues.count, 10)
        XCTAssertEqual(controller.cues[8].endMillis, 55000)
        XCTAssertEqual(controller.cues[9].endMillis, 1000000)
    }

    func testControllerRemove() throws {
        guard let sampleURLForWebVTTControlelr = self.sampleURLForWebVTTControlelr else { return }
        let controller = WebVTTController(url: sampleURLForWebVTTControlelr, duration: 100000)
        controller.removeCue(at: 10000)
        XCTAssertEqual(controller.cues.count, 4)
        XCTAssertEqual(controller.notes.count, 2)
        controller.removeCue(at: 20000)
        XCTAssertEqual(controller.cues.count, 3)
        XCTAssertEqual(controller.notes.count, 2)
        controller.removeCue(at: 30000)
        XCTAssertEqual(controller.cues.count, 2)
        XCTAssertEqual(controller.notes.count, 2)
        controller.removeCue(at: 40000)
        XCTAssertEqual(controller.cues.count, 1)
        XCTAssertEqual(controller.notes.count, 2)
        controller.removeCue(at: 50000)
        XCTAssertEqual(controller.cues.count, 0)
        XCTAssertEqual(controller.notes.count, 2)
    }
}
