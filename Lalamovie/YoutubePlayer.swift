//
//  YoutubePlayer.swift
//  Lalamovie (FIXED for Error 153!)
//
//  Created by Yashit Chawla on 09/11/25.
//

import SwiftUI
import WebKit

struct YoutubePlayer: UIViewRepresentable {
    
    let videoId: String
    
    func makeUIView(context: Context) -> WKWebView {
        // Create configuration with user script
        let userContentController = WKUserContentController()
        
        // JavaScript to add referrerpolicy to iframe
        let script = WKUserScript(
            source: """
            var iframes = document.getElementsByTagName('iframe');
            for (var i = 0; i < iframes.length; i++) {
                var url = iframes[i].src;
                if (url.includes('youtube.com/embed/')) {
                    iframes[i].setAttribute('referrerpolicy', 'strict-origin-when-cross-origin');
                }
            }
            """,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        userContentController.addUserScript(script)
        
        // Create configuration
        let config = WKWebViewConfiguration()
        config.userContentController = userContentController
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        // Create webview
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = context.coordinator
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard !videoId.isEmpty else { return }
        
        // HTML with referrerpolicy ALREADY SET in iframe
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1">
            <style>
                * { 
                    margin: 0; 
                    padding: 0; 
                }
                body { 
                    background: black; 
                }
                .video-container {
                    position: relative;
                    padding-bottom: 56.25%; /* 16:9 Aspect Ratio */
                    height: 0;
                    overflow: hidden;
                    max-width: 100%;
                }
                .video-container iframe {
                    position: absolute;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    border: 0;
                }
            </style>
        </head>
        <body>
            <div class="video-container">
                <iframe 
                    src="https://www.youtube.com/embed/\(videoId)?playsinline=1&rel=0" 
                    frameborder="0"
                    referrerpolicy="strict-origin-when-cross-origin"
                    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                    allowfullscreen>
                </iframe>
            </div>
        </body>
        </html>
        """
        
        uiView.loadHTMLString(html, baseURL: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("❌ WebView failed:", error.localizedDescription)
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("❌ WebView provisional failed:", error.localizedDescription)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("✅ WebView loaded successfully!")
        }
    }
}

// PREVIEW
#Preview {
    YoutubePlayer(videoId: "dQw4w9WgXcQ")
        .frame(height: 250)
}
