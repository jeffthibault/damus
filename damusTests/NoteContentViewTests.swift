//
//  NoteContentViewTests.swift
//  damusTests
//
//  Created by Daniel D’Aquino on 2023-08-02.
//

import XCTest
@testable import damus

class NoteContentViewTests: XCTestCase {
    func testRenderBlocksWithNonLatinHashtags() {
        let content = "Damusはかっこいいです #cool #かっこいい"
        let note = NostrEvent(content: content, keypair: test_keypair, tags: [["t", "かっこいい"]])!
        let parsed: Blocks = parse_note_content(content: .init(note: note, privkey: test_keypair.privkey))

        let testState = test_damus_state()
        
        let text: NoteArtifactsSeparated = render_blocks(blocks: parsed, profiles: testState.profiles)
        let attributedText: AttributedString = text.content.attributed
        
        let runs: AttributedString.Runs = attributedText.runs
        let runArray: [AttributedString.Runs.Run] = Array(runs)
        print(runArray.description)
        XCTAssertEqual(runArray[1].link?.absoluteString, "damus:t:cool", "Latin-character hashtag is missing. Runs description :\(runArray.description)")
        XCTAssertEqual(runArray[3].link?.absoluteString.removingPercentEncoding!, "damus:t:かっこいい", "Non-latin-character hashtag is missing. Runs description :\(runArray.description)")
    }

}
