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
         hideNavigation: Bool,
         hideNavigationBar: Bool,
         sharingEnabled: Bool,
         session: Session,
         services: StepServices) {
        self.url = url
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
        return MWWebStep(identifier: stepInfo.data.identifier,
                         url: url,
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

public class WebViewWebViewMetadata: StepMetadata {
    enum CodingKeys: CodingKey {
        case url
        case hideNavigation
        case hideTopNavigationBar
        case sharingEnabled
    }
    
    let url: String
    let hideNavigation: Bool?
    let hideTopNavigationBar: Bool?
    let sharingEnabled: Bool?
    
    init(id: String, title: String, url: String, hideNavigation: Bool?, hideTopNavigationBar: Bool?, sharingEnabled: Bool?, next: PushLinkMetadata?, links: [LinkMetadata]) {
        self.url = url
        self.hideNavigation = hideNavigation
        self.hideTopNavigationBar = hideTopNavigationBar
        self.sharingEnabled = sharingEnabled
        super.init(id: id, type: "io.mobileworkflow.WebView", title: title, next: next, links: links)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decode(String.self, forKey: .url)
        self.hideNavigation = try container.decodeIfPresent(Bool.self, forKey: .hideNavigation)
        self.hideTopNavigationBar = try container.decodeIfPresent(Bool.self, forKey: .hideTopNavigationBar)
        self.sharingEnabled = try container.decodeIfPresent(Bool.self, forKey: .sharingEnabled)
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.url, forKey: .url)
        try container.encodeIfPresent(self.hideNavigation, forKey: .hideNavigation)
        try container.encodeIfPresent(self.hideTopNavigationBar, forKey: .hideTopNavigationBar)
        try container.encodeIfPresent(self.sharingEnabled, forKey: .sharingEnabled)
        try super.encode(to: encoder)
    }
}

public extension StepMetadata {
    static func webViewWebView(id: String, title: String, url: String, hideNavigation: Bool?, hideTopNavigationBar: Bool?, sharingEnabled: Bool?, next: PushLinkMetadata?, links: [LinkMetadata]) -> WebViewWebViewMetadata {
        WebViewWebViewMetadata(id: id, title: title, url: url, hideNavigation: hideNavigation, hideTopNavigationBar: hideTopNavigationBar, sharingEnabled: sharingEnabled, next: next, links: links)
    }
}
