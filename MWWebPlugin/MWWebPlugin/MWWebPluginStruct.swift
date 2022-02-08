//
//  MWWebPlugin.swift
//  MWWebPlugin
//
//  Created by Xavi Moll on 23/12/20.
//

import Foundation
import MobileWorkflowCore

public struct MWWebPluginStruct: Plugin {
    public static var allStepsTypes: [StepType] {
        return MWWebStepType.allCases
    }
}

public enum MWWebStepType: String, StepType, CaseIterable {
    
    case web = "io.mobileworkflow.WebView"
    
    public var typeName: String {
        return self.rawValue
    }
    
    public var stepClass: BuildableStep.Type {
        switch self {
        case .web: return MWWebStep.self
        }
    }
}
