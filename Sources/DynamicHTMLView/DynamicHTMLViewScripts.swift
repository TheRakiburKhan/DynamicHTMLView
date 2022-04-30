//
//  DynamicHTMLViewScripts.swift
//  
//
//  Created by Rakibur Khan on 1/May/22.
//

import Foundation
import WebKit

struct DynamicHTMLViewScripts {
    //strings
    private static let viewportScriptString = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); meta.setAttribute('initial-scale', '1.0'); meta.setAttribute('maximum-scale', '1.0'); meta.setAttribute('minimum-scale', '1.0'); meta.setAttribute('user-scalable', 'no'); document.getElementsByTagName('head')[0].appendChild(meta);"
    
    private static let disableSelectionScriptString = "document.documentElement.style.webkitUserSelect='none';"
    
    private static let disableCalloutScriptString = "document.documentElement.style.webkitTouchCallout='none';"
    
    private static let addToOnloadScriptString = "function addLoadEvent(func) { var oldonload = window.onload; if (typeof window.onload != 'function') { window.onload = func; } else { window.onload = function() { if (oldonload) { oldonload(); } func(); } } } addLoadEvent(nameOfSomeFunctionToRunOnPageLoad); addLoadEvent(function() { }); "
    
    private static let heigthOnLoadScriptString = "window.onload= function () {window.webkit.messageHandlers.\(DynamicHTMLViewScriptMessage.HandlerName.onContentHeightChange.rawValue).postMessage({justLoaded:true,height: document.body.offsetHeight});};"
    
    private static let heigthOnResizeScriptString = "function incrementCounter() {window.webkit.messageHandlers.\(DynamicHTMLViewScriptMessage.HandlerName.onContentHeightChange.rawValue).postMessage({height: document.body.offsetHeight});}; document.body.onresize = incrementCounter;"
    
    static let getContentHeightScriptString = "document.body.offsetHeight"
    
    //scripts
    static let viewportScript = WKUserScript(source: viewportScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    
    static let disableSelectionScript = WKUserScript(source: disableSelectionScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    
    static let disableCalloutScript = WKUserScript(source: disableCalloutScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    
    static let addToOnloadScript = WKUserScript(source: addToOnloadScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    
    static let heigthOnLoadScript = WKUserScript(source: heigthOnLoadScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    
    static let heigthOnResizeScript = WKUserScript(source: heigthOnResizeScriptString, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    
}
