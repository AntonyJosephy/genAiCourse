import os

def generate_markdown(file_tree, ccg):
    md = "# Project Documentation\n\n"
    md += "## File Tree\n"
    for folder, files in file_tree.items():
        md += f"- `{folder}/`\n"
        for f in files:
            md += f"  - `{f}`\n"

    md += "\n## Code Relationships\n"
    for file, graph in ccg.items():
        for func, calls in graph.get("calls", {}).items():
            md += f"- `{func}` in `{file}` calls: {', '.join(calls)}\n"

    md += "\n## Diagram\n"
    md += "```mermaid\n"
    md += "graph TD\n"
    for file, graph in ccg.items():
        for func, calls in graph.get("calls", {}).items():
            for callee in calls:
                md += f"    {func} --> {callee}\n"
    md += "```\n"
    return md

def save_markdown(md, path):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as f:
        f.write(md)