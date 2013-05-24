rem java antlr.Tool -glib mtsql_lexer.g  mtsql_lexer_oracle.g
java antlr.Tool -o . -glib mtsql_parser.g mtsql_parser_oracle.g
java antlr.Tool -glib mtsql_tree.g mtsql_tree_oracle.g
java antlr.Tool -glib generate_query.g generate_query_oracle.g

java antlr.Tool -glib rewrite_query.g rewrite_query_oracle.g