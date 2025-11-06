import os
import git

def clone_repo(url, repo_path):
    if os.path.exists(repo_path):
        return "Repo already cloned."
    try:
        git.Repo.clone_from(url, repo_path)
        return "Cloned successfully."
    except Exception as e:
        return f"Clone failed: {str(e)}"

def generate_file_tree(repo_path):
    tree = {}
    for root, dirs, files in os.walk(repo_path):
        dirs[:] = [d for d in dirs if d not in ['.git', 'node_modules', '__pycache__']]
        rel_root = os.path.relpath(root, repo_path)
        tree[rel_root] = files
    return tree

def find_entry_points(file_tree):
    entry_points = []
    for folder, files in file_tree.items():
        for f in files:
            if f in ["main.py", "app.py"]:
                entry_points.append(os.path.join(folder, f))
    return entry_points

def summarize_readme(repo_path):
    readme_path = os.path.join(repo_path, "README.md")
    if not os.path.exists(readme_path):
        return "No README.md found."

    with open(readme_path, "r", encoding="utf-8") as f:
        content = f.read()

    lines = [line.strip() for line in content.splitlines() if line.strip()]
    summary = "\n".join(lines[:10]) if lines else "README is empty."
    return summary