//
//  MWWebStep.swift
//  MWWebPlugin
//
//  Created by Xavi Moll on 23/12/20.
//

import Foundation
import MobileWorkflowCore

public class MWWebStep: MWStep {
    
    let url: String
    let actions: [WebViewWebViewItem]
    let hideNavigation: Bool
    let hideNavigationBar: Bool
    let sharingEnabled: Bool
    let session: Session
    let services: StepServices
    
    var resolvedUrl: URL? {
        self.session.resolve(url: url)
    }
    
    init(identifier: String,
         url: String,
         actions: [WebViewWebViewItem],
         hideNavigation: Bool,
         hideNavigationBar: Bool,
         sharingEnabled: Bool,
         session: Session,
         services: StepServices) {
        self.url = url
        self.actions = actions
        self.session = session
        self.services = services
        self.hideNavigation = hideNavigation
        self.hideNavigationBar = hideNavigationBar
        self.sharingEnabled = sharingEnabled
        super.init(identifier: identifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func instantiateViewController() -> StepViewController {
        MWWebViewController(step: self)
    }
    
    public func translate(text: String) -> String {
        return self.services.localizationService.translate(text) ?? text
    }
}

extension MWWebStep: BuildableStep {
    
    public static var mandatoryCodingPaths: [CodingKey] {
        ["url"]
    }
    
    public static func build(stepInfo: StepInfo, services: StepServices) throws -> Step {
        guard let url = stepInfo.data.content["url"] as? String else {
            throw ParseError.invalidStepData(cause: "Mandatory 'url' property not found")
        }
        let hideNavigation = stepInfo.data.content["hideNavigation"] as? Bool ?? false
        let hideNavigationBar = stepInfo.data.content["hideTopNavigationBar"] as? Bool ?? false
        let sharingEnabled = stepInfo.data.content["sharingEnabled"] as? Bool ?? false
        
        let actions: [WebViewWebViewItem]
        if let storedActions = stepInfo.data.content["actions"] as? [[String: Any]] {
            actions = try storedActions.map({ try WebViewWebViewItem.parse($0) })
        } else {
            actions = []
        }
        
        return MWWebStep(identifier: stepInfo.data.identifier,
                         url: url,
                         actions: actions,
                         hideNavigation: hideNavigation,
                         hideNavigationBar: hideNavigationBar,
                         sharingEnabled: sharingEnabled,
                         session: stepInfo.session,
                         services: services)
    }
}

enum L10n {
    enum WebView {
        static let unableToResolveUrl = "Unable to resolve URL"
    }
}

public enum WebViewError: LocalizedError {
    case unableToResolveURL
    
    public var errorDescription: String? {
        return self.description
    }
    
    public var description: String {
        switch self {
        case .unableToResolveURL:
            return L10n.WebView.unableToResolveUrl
        }
    }
}

public struct WebViewWebViewItem: Codable {
    enum CodingKeys: String, CodingKey {
        case materialIconName
        case method
        case sfSymbolName
        case url
    }
    
    let materialIconName: String
    let method: String
    let sfSymbolName: String
    let url: String

    public static func webViewWebViewItem(materialIconName: String, method: String, sfSymbolName: String, url: String) -> WebViewWebViewItem {
        WebViewWebViewItem(
            materialIconName: materialIconName,
            method: method,
            sfSymbolName: sfSymbolName,
            url: url
        )
    }
    
    internal static func parse(_ stored: [String: Any]) throws -> WebViewWebViewItem {
        let data = try JSONSerialization.data(withJSONObject: stored, options: .fragmentsAllowed)
        return try JSONDecoder().decode(WebViewWebViewItem.self, from: data)
    }
}

public class WebViewWebViewMetadata: StepMetadata {
    enum CodingKeys: CodingKey {
        case url
        case actions
        case hideNavigation
        case hideTopNavigationBar
        case sharingEnabled
    }
    
    let url: String
    let actions: [WebViewWebViewItem]?
    let hideNavigation: Bool?
    let hideTopNavigationBar: Bool?
    let sharingEnabled: Bool?
    
    init(id: String, title: String, url: String, actions: [WebViewWebViewItem]?, hideNavigation: Bool?, hideTopNavigationBar: Bool?, sharingEnabled: Bool?, next: PushLinkMetadata?, links: [LinkMetadata]) {
        self.url = url
        self.actions = actions
        self.hideNavigation = hideNavigation
        self.hideTopNavigationBar = hideTopNavigationBar
        self.sharingEnabled = sharingEnabled
        super.init(id: id, type: "io.mobileworkflow.WebView", title: title, next: next, links: links)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decode(String.self, forKey: .url)
        self.actions = try container.decode([WebViewWebViewItem].self, forKey: .actions)
        self.hideNavigation = try container.decodeIfPresent(Bool.self, forKey: .hideNavigation)
        self.hideTopNavigationBar = try container.decodeIfPresent(Bool.self, forKey: .hideTopNavigationBar)
        self.sharingEnabled = try container.decodeIfPresent(Bool.self, forKey: .sharingEnabled)
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.url, forKey: .url)
        try container.encodeIfPresent(self.actions, forKey: .actions)
        try container.encodeIfPresent(self.hideNavigation, forKey: .hideNavigation)
        try container.encodeIfPresent(self.hideTopNavigationBar, forKey: .hideTopNavigationBar)
        try container.encodeIfPresent(self.sharingEnabled, forKey: .sharingEnabled)
        try super.encode(to: encoder)
    }
}

public extension StepMetadata {
    static func webViewWebView(id: String, title: String, url: String, actions: [WebViewWebViewItem]? = nil, hideNavigation: Bool? = nil, hideTopNavigationBar: Bool? = nil, sharingEnabled: Bool? = nil, next: PushLinkMetadata? = nil, links: [LinkMetadata] = []) -> WebViewWebViewMetadata {
        WebViewWebViewMetadata(id: id, title: title, url: url, actions: actions, hideNavigation: hideNavigation, hideTopNavigationBar: hideTopNavigationBar, sharingEnabled: sharingEnabled, next: next, links: links)
    }
}
