walker doc_genie {
    has repo_name;
    has repo_path;
    has file_tree;
    has ccg;
    has readme_summary;

    start {
        markdown = "# Project Documentation\n\n";

        if readme_summary != null {
            markdown += "## Project Overview\n";
            markdown += readme_summary + "\n\n";
        }

        markdown += "## File Tree\n";
        for folder, files in file_tree {
            markdown += "- `" + folder + "/`\n";
            for f in files {
                markdown += "  - `" + f + "`\n";
            }
        }

        markdown += "\n## Code Relationships\n";
        for file, graph in ccg {
            for func, calls in graph.get("calls") {
                markdown += "- `" + func}` in `" + file + "` calls: " + calls.join(", ") + "\n";
            }
        }

        markdown += "\n## Diagram\n";
        markdown += "```mermaid\n";
        markdown += "graph TD\n";
        for file, graph in ccg {
            for func, calls in graph.get("calls") {
                for callee in calls {
                    markdown += "    " + func + " --> " + callee + "\n";
                }
            }
        }
        markdown += "```\n";

        py diagram_gen.save_markdown(markdown, "./outputs/" + repo_name + "/docs.md");
        log "Documentation saved with README summary.";
    }
}