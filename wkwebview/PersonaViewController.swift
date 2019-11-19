//
//  PersonaViewController.swift
//  wkwebview
//
//  Copyright (c) 2019 Persona Identities Inc. All rights reserved.
//

import UIKit
import WebKit

class PersonaViewController: UIViewController {

    lazy private var webView: WKWebView = {
        let webView = WKWebView()
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = false
        webView.frame = view.frame
        webView.scrollView.bounces = false
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add the web view
        view.addSubview(webView)

        // Load the Persona URL request
        let request = createPersonaInitializationURLRequest()
        webView.load(request)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - WKWebView Navigation Methods

extension PersonaViewController: WKNavigationDelegate {

    /// Handle navigation actions from the web view.
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        guard let host = navigationAction.request.url?.host, host == "personademo.com" else {
            // Unknown case - do not override URL loading
            decisionHandler(.allow)
            return
        }

        // User succeeded verification.
        // Parse the query parameters and print them out.
        let queryParams = parseQueryParameters(url: navigationAction.request.url)
        if let inquiryId = queryParams?["inquiry-id"] {
            print("Inquiry Id: \(inquiryId)")
        }
        if let subject = queryParams?["subject"] {
            print("Subject: \(subject)")
        }
        if let referenceId = queryParams?["reference-id"] {
            print("Reference ID: \(referenceId)")
        }

        // You will likely want to transition the view at this point.
        decisionHandler(.cancel)
    }
}

// MARK: - Helper Methods

extension PersonaViewController {

    /// Creates the Persona URL request with query parameters
    private func createPersonaInitializationURLRequest() -> URLRequest {
        let config = [
            "template-id": "tmpl_JAZjHuAT738Q63BdgCuEJQre",
            "environment": "sandbox",
            "redirect-uri": "https://personademo.com",
            "is-webview": "true"
        ]

        // Build a dictionary with the Persona configuration options
        // See the Persona docs (http://documentation.withpersona.com) for full documentation.
        var components = URLComponents()
        components.scheme = "https"
        components.host = "withpersona.com"
        components.path = "/verify"
        components.queryItems = config.map { URLQueryItem(name: $0, value: $1) }

        let urlString = components.string!
        let url = URL(string: urlString)!
        return URLRequest(url: url)
    }

    /// Parses query parameters into a Dictionary
    private func parseQueryParameters(url: URL?) -> [String: String]? {
        guard let url = url, let items = URLComponents(string: (url.absoluteString))?.queryItems else {
            return nil
        }
        var paramsDictionary: [String: String] = [:]
        items.forEach { paramsDictionary[$0.name] = $0.value }
        return paramsDictionary
    }
}
