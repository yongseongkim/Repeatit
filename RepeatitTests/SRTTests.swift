//
//  SRTTests.swift
//  RepeatitTests
//
//  Created by YongSeong Kim on 2020/08/25.
//

import XCTest

class SRTTests: XCTestCase {
    private var sampleContentsForParser: String = ""
    private var sampleURLForSRTController: URL?

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let parserSamplePath = Bundle(for: type(of: self)).path(forResource: "sampleForParserTest", ofType: "srt")!
        let sampleData = try! Data(contentsOf: URL(fileURLWithPath: parserSamplePath))
        self.sampleContentsForParser = String(data: sampleData, encoding: .utf8) ?? ""

        // TODO: Use Inmemory system for SRTController Test.
        let sampleURLForSRTConrtroller = URL(fileURLWithPath: Bundle(for: type(of: self)).path(forResource: "sampleForSRTControllerTest", ofType: "srt")!)
        let copyOfSampleURL = sampleURLForSRTConrtroller.deletingLastPathComponent().appendingPathComponent("copySampleForSRTControllerTest.srt")
        self.sampleURLForSRTController = copyOfSampleURL
        try? FileManager.default.removeItem(at: copyOfSampleURL)
        try? FileManager.default.copyItem(at: sampleURLForSRTConrtroller, to: copyOfSampleURL)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testParser() throws {
        let parser = SRTParser()
        let result = parser.parse(contents: sampleContentsForParser)
        XCTAssertEqual(result.components.count, 17)
        XCTAssertEqual(result.components.filter { $0.caption == "Wanna believe" }.count, 2)
    }

    func testWriter() throws {
        let writer = SRTWriter()
        let result = writer.convert(components: [
            .init(
                startMillis: 34000,
                endMillis: 39000,
                caption: "Lorem Ipsum is simply dummy text of the printing and typesetting industry."
            ),
            .init(
                startMillis: 634200,
                endMillis: 644300,
                caption: "Lorem Ipsum is simply dummy text of the printing and typesetting industry."
            ),
            .init(
                startMillis: 94100,
                endMillis: 99000,
                caption: "Lorem Ipsum is simply dummy text of the printing and typesetting industry.\nLorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book."
            ),
            .init(
                startMillis: 924000,
                endMillis: 939000,
                caption: "Lorem Ipsum is simply dummy text of the printing and typesetting industry."
            )
        ])
        var expected = ""
        expected += "1\n"
        expected += "00:00:34,000 --> 00:00:39,000\n"
        expected += "Lorem Ipsum is simply dummy text of the printing and typesetting industry.\n"
        expected += "\n"
        expected += "2\n"
        expected += "00:01:34,100 --> 00:01:39,000\n"
        expected += "Lorem Ipsum is simply dummy text of the printing and typesetting industry.\n"
        expected += "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.\n"
        expected += "\n"
        expected += "3\n"
        expected += "00:10:34,200 --> 00:10:44,300\n"
        expected += "Lorem Ipsum is simply dummy text of the printing and typesetting industry.\n"
        expected += "\n"
        expected += "4\n"
        expected += "00:15:24,000 --> 00:15:39,000\n"
        expected += "Lorem Ipsum is simply dummy text of the printing and typesetting industry.\n"
        XCTAssertEqual(result, expected)
    }

    func testBoth() throws {
        let parser = SRTParser()
        let originalContents = parser.parse(contents: sampleContentsForParser)
        let writer = SRTWriter()
        let writerResult = writer.convert(components: originalContents.components)
        let targetContents = parser.parse(contents: writerResult)
        XCTAssertEqual(originalContents.components.count, targetContents.components.count)
        for idx in 0..<max(originalContents.components.count, targetContents.components.count) {
            let originalComponent = originalContents.components[idx]
            let targetComponent = targetContents.components[idx]
            XCTAssertEqual(String(describing: originalComponent), String(describing: targetComponent))
        }
    }

    func testControllerAdd() throws {
        guard let sampleURLForSRTController = self.sampleURLForSRTController else { return }
        let controller = SRTController(url: sampleURLForSRTController, duration: 1000000)
        // If a new component starts before a previous component ends, the previous component's end millis should be updated.
        // And the new component's start millis is the next component's start millis.
        controller.addComponent(at: 14000)
        XCTAssertEqual(controller.components.count, 6)
        XCTAssertEqual(controller.components[0].endMillis, 14000)
        XCTAssertEqual(controller.components[1].endMillis, controller.components[2].startMillis)
        // If a new component's starts after a previous component ends, the previous component's end millis don't need to be updated.
        controller.addComponent(at: 27000)
        XCTAssertEqual(controller.components.count, 7)
        XCTAssertEqual(controller.components[2].endMillis, 25000)
        XCTAssertEqual(controller.components[3].endMillis, controller.components[4].startMillis)
        controller.addComponent(at: 34000)
        XCTAssertEqual(controller.components.count, 8)
        XCTAssertEqual(controller.components[4].endMillis, 34000)
        XCTAssertEqual(controller.components[5].endMillis, controller.components[6].startMillis)
        controller.addComponent(at: 47000)
        XCTAssertEqual(controller.components.count, 9)
        XCTAssertEqual(controller.components[6].endMillis, 45000)
        XCTAssertEqual(controller.components[7].endMillis, controller.components[8].startMillis)
        // When inserting a new component at last index, the new component's end millis is duration.
        controller.addComponent(at: 57000)
        XCTAssertEqual(controller.components.count, 10)
        XCTAssertEqual(controller.components[8].endMillis, 55000)
        XCTAssertEqual(controller.components[9].endMillis, 1000000)
    }

    func testControllerRemove() throws {
        guard let sampleURLForSRTController = self.sampleURLForSRTController else { return }
        let controller = SRTController(url: sampleURLForSRTController, duration: 10000)
        controller.removeComponent(at: 10000)
        XCTAssertEqual(controller.components.count, 4)
        controller.removeComponent(at: 20000)
        XCTAssertEqual(controller.components.count, 3)
        controller.removeComponent(at: 30000)
        XCTAssertEqual(controller.components.count, 2)
        controller.removeComponent(at: 40000)
        XCTAssertEqual(controller.components.count, 1)
        controller.removeComponent(at: 50000)
        XCTAssertEqual(controller.components.count, 0)
    }
}
