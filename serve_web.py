#!/usr/bin/env python3
"""本地托管 Web 构建产物，使用 credentialless 以允许跨域视频流。"""
import http.server, socketserver, os

os.chdir(os.path.join(os.path.dirname(__file__), 'build', 'web'))

class H(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
        self.send_header('Cross-Origin-Embedder-Policy', 'credentialless')
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        super().end_headers()

socketserver.TCPServer.allow_reuse_address = True
httpd = socketserver.TCPServer(('0.0.0.0', 8081), H)
print('Serving on http://0.0.0.0:8081')
httpd.serve_forever()