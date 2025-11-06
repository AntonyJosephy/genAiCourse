walker code_analyzer {
    has repo_path;
    has priority_files;
    has ccg;
    has analyzed_files;

    start {
        ccg = {};
        analyzed_files = [];

        log "Starting analysis with entry-point files...";
        for f in priority_files {
            analyze_file(f);
        }

        log "Iteratively analyzing related files...";
        loop {
            has_new = false;
            for file, graph in ccg {
                for func, calls in graph.get("calls") {
                    for callee in calls {
                        callee_file = guess_file_for_function(callee);
                        if callee_file != null and callee_file not in analyzed_files {
                            analyze_file(callee_file);
                            has_new = true;
                        }
                    }
                }
            }
            if not has_new {
                break;
            }
        }

        log "Iterative analysis complete. Total files analyzed: " + analyzed_files.len();
    }

    func analyze_file(file_path) {
        full_path = repo_path + "/" + file_path;
        parsed = py parser.parse_file(full_path);
        ccg[file_path] = py parser.build_ccg(parsed);
        analyzed_files.append(file_path);
        log "Analyzed: " + file_path;
    }

    func guess_file_for_function(func_name) {
        for folder, files in py git_utils.generate_file_tree(repo_path) {
            for f in files {
                if func_name in f and f.endswith(".py") {
                    return folder + "/" + f;
                }
            }
        }
        return null;
    }
}