//
//  RestWebViewStep.swift
//  WebViewPlugin
//
//

import Foundation
import MobileWorkflowCore


// MARK: - Step properties configuration
public class WebViewRestWebViewMetadata: StepMetadata {
    enum CodingKeys: String, CodingKey {
        case url
    }
    
    let url: String
    
    init(id: String, title: String, url: String, next: PushLinkMetadata?, links: [LinkMetadata]) {
        self.url = url
        super.init(id: id, type: "io.app-rail.webview.rest-web-view", title: title, next: next, links: links)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decode(String.self, forKey: .url)
        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.url, forKey: .url)
        try super.encode(to: encoder)
    }
}

public extension StepMetadata {
    static func webViewRestWebView(id: String, title: String, url: String, next: PushLinkMetadata? = nil, links: [LinkMetadata] = []) -> WebViewRestWebViewMetadata {
        WebViewRestWebViewMetadata(
            id: id,
            title: title,
            url: url,
            next: next,
            links: links
        )
    }
}

public struct RestWebView: Codable, Identifiable {
    public let id: String
}


// MARK: - Step support declaration
public class RestWebViewStep: ObservableStep, BuildableStepWithMetadata {
    public let properties: WebViewRestWebViewMetadata
    var configuration: WebViewWebViewMetadata? = nil
    
    public required init(properties: WebViewRestWebViewMetadata, session: Session, services: StepServices) {
        self.properties = properties
        super.init(identifier: properties.id, session: session, services: services)
    }

    public override func instantiateViewController() -> StepViewController {
        MWWebViewController(step: self)
    }
}

extension RestWebViewStep: WebStepConfiguration {
    public func preloadConfiguration() async throws -> Bool {
        
        guard let fullURL = session.resolve(url: properties.url) else {
            return false
        }
        
        let task: URLAsyncTask<Data> = URLAsyncTask<Data>.build(url: fullURL, method: HTTPMethod.GET, session: session, parser: { $0 })
        let data = try await services.perform(task: task, session: session)
        
        guard var baseContent = (try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)) as? [String: Any] else {
            return false
        }
        //To avoid re-creating a model and re-use the static structure
        //we are copying id/title of the object into the server response
        if let title = self.title {
            baseContent["title"] = title
        }
        baseContent["id"] = self.identifier
        baseContent["type"] = self.properties.type
        
        let builtData = try JSONSerialization.data(withJSONObject: baseContent, options: .fragmentsAllowed)
        
        ARLogger.log("Loaded web configuration: \(String(data: builtData, encoding: .utf8))", level: .debug)
        
        self.configuration = try JSONDecoder().decode(WebViewWebViewMetadata.self, from: builtData)

        return true
    }
    
    public var hideNavigation: Bool {
        guard let configuration = self.configuration else {
            return true
        }
        return configuration.hideNavigation ?? false
    }
    
    public var hideNavigationBar: Bool {
        guard let configuration = self.configuration else {
            return true
        }
        return configuration.hideTopNavigationBar ?? false
    }
    
    public var resolvedUrl: URL? {
        guard let base = configuration?.url else { return nil }
        return session.resolve(url: base)
    }
    
    public var sharingEnabled: Bool {
        guard let configuration = self.configuration else {
            return false
        }
        return configuration.sharingEnabled ?? true
    }
    
    public var actions: [WebViewWebViewItem]? {
        configuration?.actions
    }
    
    public func translate(text: String) -> String {
        services.localizationService.translate(text) ?? text
    }
}
