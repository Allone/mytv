#!/usr/bin/env python3
"""本地托管 Web 构建产物（不设置 COOP/COEP，避免跨域视频被拦截）。"""
import http.server, socketserver, os

os.chdir(os.path.join(os.path.dirname(__file__), 'build', 'web'))

class H(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
        super().end_headers()

socketserver.TCPServer.allow_reuse_address = True
httpd = socketserver.TCPServer(('0.0.0.0', 8081), H)
print('Serving on http://0.0.0.0:8081')
httpd.serve_forever()