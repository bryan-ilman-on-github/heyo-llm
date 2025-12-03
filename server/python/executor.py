#!/usr/bin/env python3
"""
Heyo Python Tool Executor Service

A lightweight HTTP server that executes Python-based tools.
Called by the Go backend for tool execution.
"""

import json
import logging
from http.server import HTTPServer, BaseHTTPRequestHandler
from typing import Dict, Any, Optional
import sys
import os

# Add parent directory to path for imports
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from tools.calculator import CalculatorTool
from tools.code_exec import CodeInterpreterTool

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class ToolRegistry:
    """Registry of available tools."""

    def __init__(self):
        self._tools: Dict[str, Any] = {}

    def register(self, tool):
        """Register a tool instance."""
        self._tools[tool.name] = tool
        logger.info(f"Registered tool: {tool.name}")

    def get(self, name: str) -> Optional[Any]:
        """Get a tool by name."""
        return self._tools.get(name)

    def list_tools(self) -> list:
        """List all registered tools."""
        return [tool.to_schema() for tool in self._tools.values()]


# Global registry
registry = ToolRegistry()


def setup_tools():
    """Register all available tools."""
    registry.register(CalculatorTool())
    registry.register(CodeInterpreterTool(timeout=30))


class ExecutorHandler(BaseHTTPRequestHandler):
    """HTTP request handler for tool execution."""

    def do_POST(self):
        """Handle POST requests."""
        if self.path == '/execute':
            self._handle_execute()
        elif self.path == '/tools':
            self._handle_list_tools()
        else:
            self._send_error(404, "Not found")

    def do_GET(self):
        """Handle GET requests."""
        if self.path == '/health':
            self._send_json({"status": "ok"})
        elif self.path == '/tools':
            self._send_json(registry.list_tools())
        else:
            self._send_error(404, "Not found")

    def _handle_execute(self):
        """Execute a tool."""
        try:
            # Parse request body
            content_length = int(self.headers.get('Content-Length', 0))
            body = self.rfile.read(content_length).decode('utf-8')
            request = json.loads(body)

            tool_name = request.get('tool')
            args = request.get('args', {})

            if not tool_name:
                self._send_error(400, "Missing 'tool' field")
                return

            # Get tool
            tool = registry.get(tool_name)
            if not tool:
                self._send_error(404, f"Unknown tool: {tool_name}")
                return

            # Execute tool
            logger.info(f"Executing tool: {tool_name} with args: {args}")
            result = tool.execute(**args)
            logger.info(f"Tool {tool_name} result: {result[:100]}..." if len(result) > 100 else f"Tool {tool_name} result: {result}")

            self._send_json({
                "success": True,
                "result": result
            })

        except json.JSONDecodeError as e:
            self._send_error(400, f"Invalid JSON: {e}")
        except Exception as e:
            logger.exception(f"Error executing tool: {e}")
            self._send_json({
                "success": False,
                "error": str(e)
            })

    def _handle_list_tools(self):
        """List available tools."""
        self._send_json(registry.list_tools())

    def _send_json(self, data: Any, status: int = 200):
        """Send a JSON response."""
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(json.dumps(data).encode('utf-8'))

    def _send_error(self, status: int, message: str):
        """Send an error response."""
        self._send_json({"success": False, "error": message}, status)

    def log_message(self, format, *args):
        """Override to use our logger."""
        logger.info(f"{self.address_string()} - {format % args}")


def main():
    """Start the executor service."""
    port = int(os.environ.get('PORT', 8002))

    # Register tools
    setup_tools()

    # Start server
    server = HTTPServer(('0.0.0.0', port), ExecutorHandler)
    logger.info(f"Python Executor starting on port {port}")
    logger.info(f"Registered {len(registry.list_tools())} tools")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        logger.info("Shutting down...")
        server.shutdown()


if __name__ == '__main__':
    main()
