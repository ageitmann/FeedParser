//
//  NewsFeedEntry.swift
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

import UIKit

public class NewsFeedEntry: NSObject {

    // required attributes
    public var title:String = ""
    public var link:String = ""
    public var id:String = ""
    public var lastUpdated:NSDate = NSDate()
    public var summary:String = ""
    
    // optional attributes
    public var content:String?
    public var images:[NewsImage] = [NewsImage]()    
}
