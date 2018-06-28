//
//  XMLParser.swift
//  BGTArbetsprov
//
//  Created by Daniel T. Barwén on 2018-06-27.
//  Copyright © 2018 Daniel T. Barwén. All rights reserved.
//

import Foundation

struct RSSItem {
    var title : String
    var description : String
    var pubDate : String
}

class FeedParser : NSObject, XMLParserDelegate {
    
    private var rssItem : [RSSItem] = []
    private var currentElement = ""
    private var currentTitle : String = "" {
        didSet {
            currentTitle = currentTitle.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentDescription : String = "" {
        didSet {
            currentDescription = currentDescription.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var currentPubDate : String = "" {
        didSet {
            currentPubDate = currentPubDate.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    private var parserCompletionHandler : (([RSSItem]) -> Void )?
    
    func parseFeed(url: String, completionHandler: (([RSSItem]) -> Void)?) {
        self.parserCompletionHandler = completionHandler
        
        let request = URLRequest(url: URL(string: url)!)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                if let error = error {
                    print(error.localizedDescription)
                }
                return
            }
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        }
        task.resume()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if currentElement == "item" {
            currentTitle = ""
            currentDescription = ""
            currentPubDate = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
            case "title" : currentTitle += string
            case "description" : currentDescription += string
            case "pubDate" : currentPubDate += string
            default : break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let rssItem = RSSItem(title: currentTitle, description: currentDescription, pubDate: currentPubDate)
            self.rssItem.append(rssItem)
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        parserCompletionHandler?(rssItem)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription)
    }
    
}









