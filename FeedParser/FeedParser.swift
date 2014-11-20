//
//  FeedParser.swift
//  FeedParser
//
//  Created by Andreas Geitmann on 18.11.14.
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

public protocol FeedParserDelegate {

    func didStartFeedParsing(parser:FeedParser)
    func didFinishFeedParsing(parser:FeedParser, newsFeed:NewsFeed?)
    
    func anErrorOccured(parser:FeedParser, error:NSError)
}

enum ParseMode {
    case FEED, ENTRY, IMAGE
}

public class FeedParser: NSObject, NSXMLParserDelegate {
    public var newsFeed:NewsFeed = NewsFeed()
    public var delegate:FeedParserDelegate?
    
    var parseMode:ParseMode = ParseMode.FEED
    var currentContent:String = ""
    var tmpEntry:NewsFeedEntry = NewsFeedEntry()
    var lastParseMode:ParseMode?
    var tmpImage:NewsImage?
    
    // MARK: - Public Functions
    public func parseFeedFromUrl(urlString:String) {
        self.delegate?.didStartFeedParsing(self)

        self.newsFeed.url = urlString
        
        var feedUrl = NSURL(string: urlString)
        var parser = NSXMLParser(contentsOfURL: feedUrl)
        parser?.delegate = self
        parser?.parse()
    }

    
    public func parseFeedFromFile(fileString:String) {
        self.delegate?.didStartFeedParsing(self)
        
        self.newsFeed.url = fileString
        
        var feedUrl = NSURL(fileURLWithPath: fileString)
        var parser = NSXMLParser(contentsOfURL: feedUrl)
        parser?.delegate = self
        parser?.parse()
    }
    
    // MARK: - NSXMLParserDelegate 
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: NSDictionary!) {
        
        self.currentContent = ""
        
        switch self.newsFeed.feedType {
        case FeedType.ATOM:
            switch elementName {
            case "entry":
                self.tmpEntry = NewsFeedEntry()
                self.parseMode = ParseMode.ENTRY
            case "link":
                switch self.parseMode {
                case ParseMode.FEED:
                    self.newsFeed.link = attributeDict.valueForKey("href") as String
                    break
                case ParseMode.ENTRY:
                    self.tmpEntry.link = attributeDict.valueForKey("href") as String
                    break
                case ParseMode.IMAGE:
                    break
                }
            case "title", "updated", "id", "summary", "content", "author", "name":
                // Element is not needed for parsing
                break
            default:
                println("Element's name is \(elementName)")
                println("Element's attributes are \(attributeDict)")
            }
        case FeedType.RSS:
            switch elementName {
            case "item":
                self.tmpEntry = NewsFeedEntry()
                self.parseMode = ParseMode.ENTRY
            case "image":
                self.lastParseMode = self.parseMode
                self.parseMode = ParseMode.IMAGE
                self.tmpImage = NewsImage()
            default:
                println("Element's name is \(elementName)")
                println("Element's attributes are \(attributeDict)")
            }
        default:
            switch elementName {
            case "feed":
                self.newsFeed.feedType = FeedType.ATOM
            case "channel":
                self.newsFeed.feedType = FeedType.RSS
            case "title", "updated", "id", "summary", "content":
                // Element is not needed for parsing
                break
            default:
                println("Element's name is \(elementName)")
                println("Element's attributes are \(attributeDict)")
            }
        }
    }
    
    public func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName:String!) {
        
        switch self.newsFeed.feedType {
        case FeedType.ATOM:
            switch elementName {
                case "title":
                    switch self.parseMode {
                    case ParseMode.FEED:
                        self.newsFeed.title = self.currentContent
                    case ParseMode.ENTRY:
                        self.tmpEntry.title = self.currentContent
                    case ParseMode.IMAGE:
                        break
                    }
                case "updated":
                    switch self.parseMode {
                    case ParseMode.FEED:
                        self.newsFeed.lastUpdated = self.parseRFC3339DateFromString(self.currentContent)!
                        break
                    case ParseMode.ENTRY:
                        self.tmpEntry.lastUpdated = self.parseRFC3339DateFromString(self.currentContent)!
                        break
                    case ParseMode.IMAGE:
                        break
                    }
                case "id":
                    switch self.parseMode {
                    case ParseMode.FEED:
                        self.newsFeed.id = self.currentContent
                        break
                    case ParseMode.ENTRY:
                        self.tmpEntry.id = self.currentContent
                        break
                    case ParseMode.IMAGE:
                        break
                    }
                case "summary":
                    switch self.parseMode {
                    case ParseMode.FEED:
                        break
                    case ParseMode.ENTRY:
                        self.tmpEntry.summary = self.currentContent
                        break
                    case ParseMode.IMAGE:
                        break
                    }
                case "content":
                    switch self.parseMode {
                    case ParseMode.FEED:
                        break
                    case ParseMode.ENTRY:
                        self.tmpEntry.content = self.currentContent
                        break
                    case ParseMode.IMAGE:
                        break
                    }
                case "entry":
                    switch self.parseMode {
                    case ParseMode.FEED:
                        break
                    case ParseMode.ENTRY:
                        self.newsFeed.entries[self.tmpEntry.id] = self.tmpEntry
                        break
                    case ParseMode.IMAGE:
                        break
                    }
                case "link", "feed", "author", "name":
                    // Content not used, value is stored in attribute
                    break
                default:
                    println("UNKNOWN END Element \(elementName)")
            }
        case FeedType.RSS:
            switch elementName {
            case "guid":
                switch self.parseMode {
                case ParseMode.FEED:
                    self.newsFeed.id = self.currentContent
                case ParseMode.ENTRY:
                    self.tmpEntry.id = self.currentContent
                case ParseMode.IMAGE:
                    break
                }
            case "link":
                switch self.parseMode {
                case ParseMode.FEED:
                    self.newsFeed.link = self.currentContent
                case ParseMode.ENTRY:
                    self.tmpEntry.link = self.currentContent
                case ParseMode.IMAGE:
                    self.tmpImage?.link? = self.currentContent
                }
            case "title":
                switch self.parseMode {
                case ParseMode.FEED:
                    self.newsFeed.title = self.currentContent
                case ParseMode.ENTRY:
                    self.tmpEntry.title = self.currentContent
                case ParseMode.IMAGE:
                    self.tmpImage?.title? = self.currentContent
                }
            case "url":
                switch self.parseMode {
                case ParseMode.FEED:
                    break
                case ParseMode.ENTRY:
                    break
                case ParseMode.IMAGE:
                    self.tmpImage?.url = self.currentContent
                }                
            case "description":
                switch self.parseMode {
                case ParseMode.FEED:
                    self.newsFeed.summary = self.currentContent
                    break
                case ParseMode.ENTRY:
                    self.tmpEntry.summary = self.currentContent
                    break
                case ParseMode.IMAGE:
                    break
                }
            case "pubDate":
                switch self.parseMode {
                case ParseMode.FEED:
                    self.newsFeed.lastUpdated = self.parseRFC822DateFromString(self.currentContent)!
                    break
                case ParseMode.ENTRY:
                    self.tmpEntry.lastUpdated = self.parseRFC822DateFromString(self.currentContent)!
                    break
                case ParseMode.IMAGE:
                    break
                }
            case "language":
                switch self.parseMode {
                case ParseMode.FEED:
                    self.newsFeed.language = self.currentContent
                case ParseMode.ENTRY:
                    break
                case ParseMode.IMAGE:
                    break
                }
            case "image":
                self.parseMode = self.lastParseMode!
                if (self.parseMode == ParseMode.FEED) {
                    self.newsFeed.images.append(self.tmpImage!)
                } else if (self.parseMode == ParseMode.ENTRY) {
                    self.tmpEntry.images.append(self.tmpImage!)
                }
            case "item":
                switch self.parseMode {
                case ParseMode.FEED:
                    break
                case ParseMode.ENTRY:
                    if self.tmpEntry.id.isEmpty {
                        self.newsFeed.entries[self.tmpEntry.link] = self.tmpEntry
                    } else {
                        self.newsFeed.entries[self.tmpEntry.id] = self.tmpEntry
                    }
                    break
                case ParseMode.IMAGE:
                    break
                }
            case "channel", "rss":
                // Content not used, value is stored in attribute
                break
            default:
                println("UNKNOWN END Element \(elementName)")
            }
        default:
            println("UNKNOWN feedType \(self.newsFeed.feedType)")
        }
    }
    
    public func parser(parser: NSXMLParser!, foundCharacters string: String!) {
            self.currentContent += string
    }
    
    public func parser(parser: NSXMLParser!, parseErrorOccurred parseError: NSError!) {
        println("Error: \(parseError.description)")
        self.delegate?.anErrorOccured(self, error: parseError)
    }
    
    public func parserDidEndDocument(parser: NSXMLParser!) {
        self.delegate?.didFinishFeedParsing(self, newsFeed: self.newsFeed)
    }
    
    // MARK: - Private Functions
    private func parseRFC3339DateFromString(string:String) -> NSDate? {
        let enUSPOSIXLocale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        let rfc3339DateFormatter = NSDateFormatter()
        rfc3339DateFormatter.locale = enUSPOSIXLocale
        rfc3339DateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        rfc3339DateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        
        return rfc3339DateFormatter.dateFromString(string)
    }
    
    private func parseRFC822DateFromString(string:String) -> NSDate? {
        var dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        return dateFormat.dateFromString(string)
    }


}
