walker api_entry {
    can main;

    http POST "/generate_docs" {
        param url;
        spawn main with { url: url };
        return "Documentation generation started for " + url;
    }
}