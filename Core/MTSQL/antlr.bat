call antlr_ora.bat
java antlr.Tool mtsql_refactor_lexer.g
java antlr.Tool mtsql_lexer.g
java antlr.Tool mtsql_parser.g
java antlr.Tool mtsql_tree.g
java antlr.Tool mtsql_compile.g
java antlr.Tool mtsql_exec.g
java antlr.Tool rewrite_query.g
java antlr.Tool generate_query.g
