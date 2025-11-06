from tree_sitter import Language, Parser
import os

Language.build_library(
    'build/my-languages.so',
    ['vendor/tree-sitter-python']
)

PY_LANGUAGE = Language('build/my-languages.so', 'python')
parser = Parser()
parser.set_language(PY_LANGUAGE)

def parse_file(file_path):
    with open(file_path, 'r') as f:
        code = f.read()
    tree = parser.parse(bytes(code, "utf8"))
    return tree

def build_ccg(tree):
    # Placeholder: return dummy graph structure
    return {
        "calls": {
            "train_model": ["load_data", "fit_model"],
            "evaluate": ["load_data", "predict"]
        }
    }