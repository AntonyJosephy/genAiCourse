walker main {
    has url;
    has repo_name;
    has repo_path;

    can repo_mapper, code_analyzer, doc_genie;

    start {
        url = <input_url>;
        repo_name = extract_repo_name(url);
        repo_path = "/tmp/" + repo_name;

        spawn repo_mapper with {
            url: url,
            repo_path: repo_path
        };

        wait repo_mapper.done;

        log "Planning analysis based on README summary:\n" + repo_mapper.readme_summary;

        spawn code_analyzer with {
            repo_path: repo_path,
            priority_files: repo_mapper.entry_points
        };

        wait code_analyzer.done;

        spawn doc_genie with {
            repo_name: repo_name,
            repo_path: repo_path,
            file_tree: repo_mapper.file_tree,
            ccg: code_analyzer.ccg,
            readme_summary: repo_mapper.readme_summary
        };

        wait doc_genie.done;
        log "Documentation generated at ./outputs/" + repo_name + "/docs.md";
    }
}