walker repo_mapper {
    has url;
    has repo_path;
    has file_tree;
    has entry_points;
    has readme_summary;

    start {
        py git_utils.clone_repo(url, repo_path);
        file_tree = py git_utils.generate_file_tree(repo_path);
        entry_points = py git_utils.find_entry_points(file_tree);
        readme_summary = py git_utils.summarize_readme(repo_path);
        log "README Summary:\n" + readme_summary;
    }
}