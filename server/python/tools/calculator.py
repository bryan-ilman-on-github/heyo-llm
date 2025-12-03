import math
import ast
import operator
from typing import Any, Dict, Union

from .base import BaseTool


class CalculatorTool(BaseTool):
    """Safe mathematical expression evaluator."""

    name = "calculate"
    description = "Evaluate mathematical expressions accurately. Supports arithmetic, trigonometry, logarithms, and more."

    # Allowed operators
    OPERATORS = {
        ast.Add: operator.add,
        ast.Sub: operator.sub,
        ast.Mult: operator.mul,
        ast.Div: operator.truediv,
        ast.FloorDiv: operator.floordiv,
        ast.Mod: operator.mod,
        ast.Pow: operator.pow,
        ast.USub: operator.neg,
        ast.UAdd: operator.pos,
    }

    # Allowed functions and constants
    FUNCTIONS = {
        # Basic math
        'abs': abs,
        'round': round,
        'min': min,
        'max': max,
        'sum': sum,
        'pow': pow,

        # Trigonometry
        'sin': math.sin,
        'cos': math.cos,
        'tan': math.tan,
        'asin': math.asin,
        'acos': math.acos,
        'atan': math.atan,
        'atan2': math.atan2,
        'sinh': math.sinh,
        'cosh': math.cosh,
        'tanh': math.tanh,
        'asinh': math.asinh,
        'acosh': math.acosh,
        'atanh': math.atanh,

        # Exponential and logarithmic
        'exp': math.exp,
        'log': math.log,
        'log10': math.log10,
        'log2': math.log2,
        'sqrt': math.sqrt,

        # Other
        'ceil': math.ceil,
        'floor': math.floor,
        'factorial': math.factorial,
        'gcd': math.gcd,
        'degrees': math.degrees,
        'radians': math.radians,

        # Constants
        'pi': math.pi,
        'e': math.e,
        'tau': math.tau,
        'inf': math.inf,
    }

    @property
    def parameters(self) -> Dict[str, Any]:
        return {
            "type": "object",
            "required": ["expression"],
            "properties": {
                "expression": {
                    "type": "string",
                    "description": "Mathematical expression to evaluate, e.g., 'sqrt(189)', '2+2*3', 'sin(pi/2)'"
                }
            }
        }

    def execute(self, expression: str = "", **kwargs) -> str:
        if not expression:
            return "Error: No expression provided"

        try:
            result = self._safe_eval(expression)
            # Format result nicely
            if isinstance(result, float):
                # Avoid scientific notation for reasonable numbers
                if abs(result) < 1e10 and abs(result) > 1e-10 or result == 0:
                    # Remove trailing zeros
                    formatted = f"{result:.15g}"
                else:
                    formatted = f"{result:.10e}"
                return formatted
            return str(result)
        except Exception as e:
            return f"Error: {str(e)}"

    def _safe_eval(self, expression: str) -> Union[int, float]:
        """Safely evaluate a mathematical expression."""
        # Parse the expression into an AST
        try:
            tree = ast.parse(expression, mode='eval')
        except SyntaxError as e:
            raise ValueError(f"Invalid expression syntax: {e}")

        return self._eval_node(tree.body)

    def _eval_node(self, node: ast.AST) -> Union[int, float]:
        """Recursively evaluate an AST node."""
        # Numbers (ast.Constant for Python 3.8+)
        if isinstance(node, ast.Constant):
            if isinstance(node.value, (int, float)):
                return node.value
            raise ValueError(f"Unsupported constant type: {type(node.value)}")

        # Legacy Num node (Python < 3.8) - check if it exists
        if hasattr(ast, 'Num') and isinstance(node, ast.Num):
            return node.n

        # Names (variables/constants like pi, e)
        if isinstance(node, ast.Name):
            name = node.id.lower()
            if name in self.FUNCTIONS:
                value = self.FUNCTIONS[name]
                if isinstance(value, (int, float)):
                    return value
                raise ValueError(f"'{node.id}' is a function, not a constant")
            raise ValueError(f"Unknown variable: {node.id}")

        # Binary operations (a + b, a * b, etc.)
        if isinstance(node, ast.BinOp):
            left = self._eval_node(node.left)
            right = self._eval_node(node.right)
            op_type = type(node.op)
            if op_type not in self.OPERATORS:
                raise ValueError(f"Unsupported operator: {op_type.__name__}")
            return self.OPERATORS[op_type](left, right)

        # Unary operations (-a, +a)
        if isinstance(node, ast.UnaryOp):
            operand = self._eval_node(node.operand)
            op_type = type(node.op)
            if op_type not in self.OPERATORS:
                raise ValueError(f"Unsupported unary operator: {op_type.__name__}")
            return self.OPERATORS[op_type](operand)

        # Function calls (sin(x), sqrt(x), etc.)
        if isinstance(node, ast.Call):
            if not isinstance(node.func, ast.Name):
                raise ValueError("Only simple function calls are allowed")

            func_name = node.func.id.lower()
            if func_name not in self.FUNCTIONS:
                raise ValueError(f"Unknown function: {node.func.id}")

            func = self.FUNCTIONS[func_name]
            if not callable(func):
                raise ValueError(f"'{func_name}' is not a function")

            args = [self._eval_node(arg) for arg in node.args]
            return func(*args)

        raise ValueError(f"Unsupported expression type: {type(node).__name__}")
