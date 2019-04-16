//
//  PersonaViewController.swift
//  wkwebview
//
//  Copyright (c) 2019 Persona Identities Inc. All rights reserved.
//

import UIKit
import WebKit

class PersonaViewController: UIViewController, WKNavigationDelegate {
    let webView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // load the Persona url
        let url = URL(string: generatePersonaInitializationURL())
        let request = URLRequest(url: url!)

        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = false

        webView.frame = view.frame
        webView.scrollView.bounces = false
        self.view.addSubview(webView)
        webView.load(request)
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // getUrlParams :: parse query parameters into a Dictionary
    func getUrlParams(url: URL) -> Dictionary<String, String> {
        var paramsDictionary = [String: String]()
        let queryItems = URLComponents(string: (url.absoluteString))?.queryItems
        queryItems?.forEach { paramsDictionary[$0.name] = $0.value }
        return paramsDictionary
    }

    // generatePersonaInitializationURL :: create the Persona url with query parameters
    func generatePersonaInitializationURL() -> String {
        let config = [
            "blueprint-id": "blu_PDGZKPEASz266wmRcPbuwjPP",
            "redirect-uri": "https://personademo.com",
            "is-webview": "true",
        ]

        // Build a dictionary with the Persona configuration options
        // See the Persona docs (http://documentation.withpersona.com) for full documentation.
        var components = URLComponents()
        components.scheme = "https"
        // NOTE: Change host to sandbox.withpersona.com for the Sandbox environment
        components.host = "withpersona.com"
        components.path = "/verify"
        components.queryItems = config.map { URLQueryItem(name: $0, value: $1) }
        return components.string!
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping ((WKNavigationActionPolicy) -> Void)) {

        let actionType = navigationAction.request.url?.host;
        let queryParams = getUrlParams(url: navigationAction.request.url!)

        if (actionType == "personademo.com") {
            // User succeeded verification
            print("Inquiry Id: \(queryParams["inquiry-id"]!)");
            print("Subject: \(queryParams["subject"]!)");

            // Do nothing
            // You will likely want to transition the view at this point.
            decisionHandler(.cancel)
        } else {
            // Unknown case - do not override URL loading
            decisionHandler(.allow)
        }
    }
}
