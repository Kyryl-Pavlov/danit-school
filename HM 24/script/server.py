import os
import random
import socket
import string
from http.server import BaseHTTPRequestHandler, HTTPServer

class RequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-Type', 'text/plain')
        self.end_headers()
        
        hostname = socket.gethostname()
        random_str = ''.join(random.choices(string.ascii_letters + string.digits, k=10))
        response = f"Pod: {hostname} | Random String: {random_str}\n"
        self.wfile.write(response.encode('utf-8'))

def run():
    server_address = ('0.0.0.0', 8080)
    httpd = HTTPServer(server_address, RequestHandler)
    print("Serving on port 8080...")
    httpd.serve_forever()

if __name__ == '__main__':
    run()
