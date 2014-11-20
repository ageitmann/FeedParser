//
//  TestSimpleRSSFeedParserDelegate.swift
//  FeedParser
//
//  Created by Andreas Geitmann on 19.11.14.
//  Copyright (c) 2014 simutron IT-Service. All rights reserved.
//

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import FeedParser
import XCTest

class TestSimpleRSSFeedParserDelegate: NSObject, FeedParserDelegate  {
    
    var newsFeed:NewsFeed = NewsFeed()
    
    func didStartFeedParsing(parser:FeedParser) {
        
    }
    
    func didFinishFeedParsing(parser:FeedParser, newsFeed:NewsFeed?) {
        self.newsFeed = newsFeed!
        
        XCTAssertNotNil(self.newsFeed, "Newsfeed parsed.")
        XCTAssertEqual(self.newsFeed.feedType, FeedType.RSS, "RSS found.")
        XCTAssertEqual(self.newsFeed.link, "http://www.feedforall.com", "Link found")
        // Note: in the example file, there are no guid defined, link as key is double used
        XCTAssertEqual(self.newsFeed.entries.count, 2, "2 Entries found")
    }
    
    
    func anErrorOccured(parser:FeedParser, error:NSError) {
        println("Error: \(error.description)")
    }
    
}
