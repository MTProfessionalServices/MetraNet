/* $ANTLR 2.7.6 (2005-12-22): "dataflow_parser.g" -> "DataflowParser.cpp"$ */
#include "DataflowParser.hpp"
#include <antlr/NoViableAltException.hpp>
#include <antlr/SemanticException.hpp>
#include <antlr/ASTFactory.hpp>
#line 1 "dataflow_parser.g"
#line 8 "DataflowParser.cpp"
DataflowParser::DataflowParser(ANTLR_USE_NAMESPACE(antlr)TokenBuffer& tokenBuf, int k)
: ANTLR_USE_NAMESPACE(antlr)LLkParser(tokenBuf,k)
{
}

DataflowParser::DataflowParser(ANTLR_USE_NAMESPACE(antlr)TokenBuffer& tokenBuf)
: ANTLR_USE_NAMESPACE(antlr)LLkParser(tokenBuf,3)
{
}

DataflowParser::DataflowParser(ANTLR_USE_NAMESPACE(antlr)TokenStream& lexer, int k)
: ANTLR_USE_NAMESPACE(antlr)LLkParser(lexer,k)
{
}

DataflowParser::DataflowParser(ANTLR_USE_NAMESPACE(antlr)TokenStream& lexer)
: ANTLR_USE_NAMESPACE(antlr)LLkParser(lexer,3)
{
}

DataflowParser::DataflowParser(const ANTLR_USE_NAMESPACE(antlr)ParserSharedInputState& state)
: ANTLR_USE_NAMESPACE(antlr)LLkParser(state,3)
{
}

void DataflowParser::program() {
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST program_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	try {      // for error handling
		{
		switch ( LA(1)) {
		case BOM:
		{
			match(BOM);
#line 254 "dataflow_parser.g"
			mEncoding = CP_UTF8;
#line 47 "DataflowParser.cpp"
			break;
		}
		case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
		case OPERATOR:
		case INCLUDE_COMPOSITE:
		case STEP_DECL:
		case STEPS_BEGIN:
		case ID:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		}
		}
		{ // ( ... )*
		for (;;) {
			if ((LA(1) == INCLUDE_COMPOSITE)) {
				includeCompositeStatement();
				astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
				{
				switch ( LA(1)) {
				case SEMI:
				{
					match(SEMI);
					break;
				}
				case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
				case OPERATOR:
				case INCLUDE_COMPOSITE:
				case STEP_DECL:
				case STEPS_BEGIN:
				case ID:
				{
					break;
				}
				default:
				{
					throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
				}
				}
				}
			}
			else {
				goto _loop5;
			}
			
		}
		_loop5:;
		} // ( ... )*
		{ // ( ... )*
		for (;;) {
			switch ( LA(1)) {
			case OPERATOR:
			{
				compositeDeclaration();
				astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
				break;
			}
			case STEP_DECL:
			{
				stepDeclaration();
				astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
				break;
			}
			default:
				if ((LA(1) == ID) && (_tokenSet_0.member(LA(2)))) {
					nodeStatement();
					astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
					{
					switch ( LA(1)) {
					case SEMI:
					{
						match(SEMI);
						break;
					}
					case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
					case OPERATOR:
					case STEP_DECL:
					case STEPS_BEGIN:
					case ID:
					{
						break;
					}
					default:
					{
						throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
					}
					}
					}
				}
				else if ((LA(1) == ID) && (LA(2) == ARROW || LA(2) == LPAREN)) {
					edgeStatement();
					astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
					{
					switch ( LA(1)) {
					case SEMI:
					{
						match(SEMI);
						break;
					}
					case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
					case OPERATOR:
					case STEP_DECL:
					case STEPS_BEGIN:
					case ID:
					{
						break;
					}
					default:
					{
						throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
					}
					}
					}
				}
			else {
				goto _loop9;
			}
			}
		}
		_loop9:;
		} // ( ... )*
		{
		switch ( LA(1)) {
		case STEPS_BEGIN:
		{
			controlFlow();
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		}
		}
		RefMyAST tmp5_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp5_AST = astFactory->create(LT(1));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp5_AST));
		match(ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE);
		program_AST = RefMyAST(currentAST.root);
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		recover(ex,_tokenSet_1);
	}
	returnAST = program_AST;
}

void DataflowParser::includeCompositeStatement() {
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST includeCompositeStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)RefToken  filename = ANTLR_USE_NAMESPACE(antlr)nullToken;
	RefMyAST filename_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	{
	RefMyAST tmp6_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp6_AST = astFactory->create(LT(1));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp6_AST));
	match(INCLUDE_COMPOSITE);
	filename = LT(1);
	filename_AST = astFactory->create(filename);
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(filename_AST));
	match(STRING_LITERAL);
	}
#line 272 "dataflow_parser.g"
	
	std::wstring fname;
	::ASCIIToWide(fname, filename->getText().c_str(), -1, mEncoding);
	if (fname.size() >= 2)
	{
	fname = fname.substr(1, fname.size()-2); 
	}
	
	// Locate the include file
	std::wstring outFullPath;
	if (!mInterpreter->resolveIncludeFile(mFilename, fname, outFullPath))
	{
	std::wstringstream out;
	out << L"\nFile not found: \"" << fname << L"\".  This file "
	L"must be in (1) extensions\\*\\config\\Metraflow\\"
	L"Composites\\ or in (2) config\\MetraFlow\\*\\Composites "
	L"or in (3) the local working directory  "
	L"or in (4) the same directory as given MetraFlow script file.";
	throw (DataflowGeneralException(filename->getLine(),
	filename->getColumn(), 
	mFilename,
	out.str()));
	}
	boost::filesystem::wpath fullPath(outFullPath, boost::filesystem::native);
	
	// Check if this is a circular import file reference.
	if (mInterpreter->isFileIncludeInProgress(fullPath.native_file_string()))
	{
	std::wstringstream out;
	out << L"\nImported files references are circular: \"" 
	<< fullPath.native_file_string() << L"\"";
	throw (DataflowGeneralException(filename->getLine(),
	filename->getColumn(), 
	mFilename,
	out.str()));
	}
	
	// Check if we've already imported this file.
	if (!mInterpreter->isFileAlreadyIncluded(fullPath.native_file_string()))
	{
	boost::filesystem::ifstream f(fullPath);
	
	if (mInterpreter->includeComposite(fullPath.native_file_string(), f, mEncoding) != 0)
	{
	throw (DataflowGeneralException(filename->getLine(),
	filename->getColumn(), 
	mFilename,
	L"Include of composite failed."));
	}
	}
	
#line 273 "DataflowParser.cpp"
	includeCompositeStatement_AST = RefMyAST(currentAST.root);
	returnAST = includeCompositeStatement_AST;
}

void DataflowParser::nodeStatement() {
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST nodeStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)RefToken  id = ANTLR_USE_NAMESPACE(antlr)nullToken;
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)RefToken  id2 = ANTLR_USE_NAMESPACE(antlr)nullToken;
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 560 "dataflow_parser.g"
	
	std::string opType;
	int opTypeLine=1;
	int opTypeCol=1;
	
#line 292 "DataflowParser.cpp"
	
	{
	id = LT(1);
	id_AST = astFactory->create(id);
	astFactory->makeASTRoot(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	match(ID);
#line 569 "dataflow_parser.g"
	
	opType = id_AST->getText(); 
	opTypeLine = id->getLine(); 
	opTypeCol = id->getColumn(); 
	
#line 305 "DataflowParser.cpp"
	{
	switch ( LA(1)) {
	case COLON:
	{
		RefMyAST tmp7_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp7_AST = astFactory->create(LT(1));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp7_AST));
		match(COLON);
		id2 = LT(1);
		id2_AST = astFactory->create(id2);
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ID);
#line 575 "dataflow_parser.g"
		
		opType = id2_AST->getText(); 
		opTypeLine = id2->getLine(); 
		opTypeCol = id2->getColumn(); 
		
#line 324 "DataflowParser.cpp"
		break;
	}
	case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
	case OPERATOR:
	case STEP_DECL:
	case STEPS_BEGIN:
	case LBRACKET:
	case RPAREN:
	case SEMI:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	{
	switch ( LA(1)) {
	case LBRACKET:
	{
		match(LBRACKET);
		{
		switch ( LA(1)) {
		case ID:
		{
			arguments();
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case RBRACKET:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		}
		}
		match(RBRACKET);
		break;
	}
	case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
	case OPERATOR:
	case STEP_DECL:
	case STEPS_BEGIN:
	case RPAREN:
	case SEMI:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	}
	nodeStatement_AST = RefMyAST(currentAST.root);
#line 583 "dataflow_parser.g"
	
	std::wstring wOpType;
	::ASCIIToWide(wOpType, opType.c_str(), -1, mEncoding);
	
	if (boost::algorithm::iequals(opType.c_str(), "account_lookup"))
	{
	nodeStatement_AST->setType(ACCOUNT_RESOLUTION);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "broadcast") || 
	boost::algorithm::iequals(opType.c_str(), "bcast"))
	{
	nodeStatement_AST->setType(BROADCAST);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "coll"))
	{
	nodeStatement_AST->setType(COLL);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "copy"))
	{
	nodeStatement_AST->setType(COPY);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "devnull"))
	{
	nodeStatement_AST->setType(DEVNULL);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "export"))
	{
	nodeStatement_AST->setType(EXPORT);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "export_queue"))
	{
	nodeStatement_AST->setType(EXPORT_QUEUE);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "expr"))
	{
	nodeStatement_AST->setType(EXPR);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "filter"))
	{
	nodeStatement_AST->setType(FILTER);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "generate"))
	{
	nodeStatement_AST->setType(GENERATE);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "group_by") ||
	boost::algorithm::iequals(opType.c_str(), "hash_group_by"))
	{
	nodeStatement_AST->setType(GROUP_BY);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "hashpart") ||
	boost::algorithm::iequals(opType.c_str(), "hash_part"))
	{
	nodeStatement_AST->setType(HASHPART);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "hash_running_total"))
	{
	nodeStatement_AST->setType(HASH_RUNNING_TOTAL);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "id_generator"))
	{
	nodeStatement_AST->setType(ID_GENERATOR);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "import"))
	{
	nodeStatement_AST->setType(IMPORT);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "import_queue"))
	{
	nodeStatement_AST->setType(IMPORT_QUEUE);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "inner_hash_join"))
	{
	nodeStatement_AST->setType(INNER_HASH_JOIN);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "inner_merge_join"))
	{
	nodeStatement_AST->setType(INNER_MERGE_JOIN);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "insert"))
	{
	nodeStatement_AST->setType(INSERT);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "load_error"))
	{
	nodeStatement_AST->setType(LOAD_ERROR);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "load_usage"))
	{
	nodeStatement_AST->setType(LOAD_USAGE);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "longest_prefix_match"))
	{
	nodeStatement_AST->setType(LONGEST_PREFIX_MATCH);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "md5"))
	{
	nodeStatement_AST->setType(MD5);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "meter"))
	{
	nodeStatement_AST->setType(METER);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "multi_hash_join"))
	{
	nodeStatement_AST->setType(MULTI_HASH_JOIN);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "print"))
	{
	nodeStatement_AST->setType(PRINT);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "proj") ||
	boost::algorithm::iequals(opType.c_str(), "project") ||
	boost::algorithm::iequals(opType.c_str(), "projection"))
	{
	nodeStatement_AST->setType(PROJECTION);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "rangepart"))
	{
	nodeStatement_AST->setType(RANGEPART);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "parameter_table_lookup"))
	{
	nodeStatement_AST->setType(RATE_CALCULATION);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "rate_schedule_lookup"))
	{
	nodeStatement_AST->setType(RATE_SCHEDULE_RESOLUTION);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "rename"))
	{
	nodeStatement_AST->setType(RENAME);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "right_merge_anti_semi_join"))
	{
	nodeStatement_AST->setType(RIGHT_MERGE_ANTI_SEMI_JOIN);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "right_merge_semi_join"))
	{
	nodeStatement_AST->setType(RIGHT_MERGE_SEMI_JOIN);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "right_outer_hash_join") ||
	boost::algorithm::iequals(opType.c_str(), "right_hash_join"))
	{
	nodeStatement_AST->setType(RIGHT_OUTER_HASH_JOIN);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "right_outer_merge_join") ||
	boost::algorithm::iequals(opType.c_str(), "right_merge_join"))
	{
	nodeStatement_AST->setType(RIGHT_OUTER_MERGE_JOIN);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "select"))
	{
	nodeStatement_AST->setType(SELECT);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "sequential_file_delete"))
	{
	nodeStatement_AST->setType(SEQUENTIAL_FILE_DELETE);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "sequential_file_write"))
	{
	nodeStatement_AST->setType(SEQUENTIAL_FILE_OUTPUT);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "sequential_file_rename"))
	{
	nodeStatement_AST->setType(SEQUENTIAL_FILE_RENAME);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "sequential_file_scan"))
	{
	nodeStatement_AST->setType(SEQUENTIAL_FILE_SCAN);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "session_set_builder"))
	{
	nodeStatement_AST->setType(SESSION_SET_BUILDER);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "sort_group_by"))
	{
	nodeStatement_AST->setType(SORT_GROUP_BY);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "sortmerge") ||
	boost::algorithm::iequals(opType.c_str(), "sort_merge"))
	{
	nodeStatement_AST->setType(SORTMERGE);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "sortmergecoll") ||
	boost::algorithm::iequals(opType.c_str(), "sort_merge_coll"))
	{
	nodeStatement_AST->setType(SORTMERGECOLL);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "sort"))
	{
	nodeStatement_AST->setType(SORT);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "sort_nest"))
	{
	nodeStatement_AST->setType(SORT_NEST);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "assert_sort_order"))
	{
	nodeStatement_AST->setType(SORT_ORDER_ASSERT);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "sort_running_total"))
	{
	nodeStatement_AST->setType(SORT_RUNNING_TOTAL);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "sql_exec_direct"))
	{
	nodeStatement_AST->setType(SQL_EXEC_DIRECT);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "subscription_lookup"))
	{
	nodeStatement_AST->setType(SUBSCRIPTION_RESOLUTION);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "switch"))
	{
	nodeStatement_AST->setType(SWITCH);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "taxware"))
	{
	nodeStatement_AST->setType(TAXWARE);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "unionall") ||
	boost::algorithm::iequals(opType.c_str(), "union_all"))
	{
	nodeStatement_AST->setType(UNION_ALL);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "unnest"))
	{
	nodeStatement_AST->setType(UNNEST);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "unroll"))
	{
	nodeStatement_AST->setType(UNROLL);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "write_error"))
	{
	nodeStatement_AST->setType(WRITE_ERROR);
	}
	else if (boost::algorithm::iequals(opType.c_str(), "write_product_view"))
	{
	nodeStatement_AST->setType(WRITE_PRODUCT_VIEW);
	}
	else if (mCompositeDictionary->isDefined(wOpType.c_str()))
	{ 
	nodeStatement_AST->setType(COMPOSITE);
	}
	
	else
	{
	throw DataflowGeneralException(
	opTypeLine,
	opTypeCol,
	mFilename,
	L"Encountered unknown operator: " + wOpType);
	}
	
#line 645 "DataflowParser.cpp"
	nodeStatement_AST = RefMyAST(currentAST.root);
	returnAST = nodeStatement_AST;
}

void DataflowParser::edgeStatement() {
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST edgeStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	nodeDefOrRef();
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
	{ // ( ... )+
	int _cnt77=0;
	for (;;) {
		if ((LA(1) == ARROW)) {
			RefMyAST tmp10_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
			tmp10_AST = astFactory->create(LT(1));
			astFactory->makeASTRoot(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp10_AST));
			match(ARROW);
			{
			switch ( LA(1)) {
			case LBRACKET:
			{
				arrowArguments();
				astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
				break;
			}
			case LCURLY:
			case ID:
			{
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
			{
			switch ( LA(1)) {
			case LCURLY:
			{
				arrowAnnotation();
				astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
				break;
			}
			case ID:
			{
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
			nodeDefOrRef();
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			if ( _cnt77>=1 ) { goto _loop77; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());}
		}
		
		_cnt77++;
	}
	_loop77:;
	}  // ( ... )+
	edgeStatement_AST = RefMyAST(currentAST.root);
	returnAST = edgeStatement_AST;
}

void DataflowParser::compositeDeclaration() {
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST compositeDeclaration_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)RefToken  id = ANTLR_USE_NAMESPACE(antlr)nullToken;
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 325 "dataflow_parser.g"
	
	// We start forming a composite definition.  We will add
	// this to the composite dictionary when completed.
	mActiveCompositeDefinition = new CompositeDefinition(mFilename);
	
#line 729 "DataflowParser.cpp"
	
	{
	RefMyAST tmp11_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp11_AST = astFactory->create(LT(1));
	astFactory->makeASTRoot(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp11_AST));
	match(OPERATOR);
	id = LT(1);
	id_AST = astFactory->create(id);
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	match(ID);
	match(LBRACKET);
	{
	switch ( LA(1)) {
	case INPUT:
	case OUTPUT:
	case STRING_DECL:
	case INTEGER_DECL:
	case BOOLEAN_DECL:
	case SUBLIST_DECL:
	{
		compositeParameters();
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		break;
	}
	case RBRACKET:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	match(RBRACKET);
	compositeBody();
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
	}
#line 333 "dataflow_parser.g"
	
	// Check if this composite has already been declared.
	const CompositeDefinition* defn = 
	mCompositeDictionary->getDefinition(ASCIIToWide(id->getText()));
	
	if (defn != NULL)
	{
	throw DataflowRedefinedCompositeException(
	ASCIIToWide(id->getText()),
	defn->getLineNumber(),
	defn->getColumnNumber(),
	mFilename,
	id->getLine(),
	id->getColumn());
	}
	
	mActiveCompositeDefinition->setName(ASCIIToWide(id->getText()));
	mActiveCompositeDefinition->setLocation(id->getLine(), id->getColumn(), L"");
	
	// We need to add the composite name to the dictionary
	// in the parsing phrase so that we can identify operators
	// referring to composites and set the operator type appropriately.
	mCompositeDictionary->add(mActiveCompositeDefinition);
	
	// The dictionary now has ownership of the pointer and is reasonable
	// for freeing.
	mActiveCompositeDefinition = NULL;
	
#line 797 "DataflowParser.cpp"
	compositeDeclaration_AST = RefMyAST(currentAST.root);
	returnAST = compositeDeclaration_AST;
}

void DataflowParser::stepDeclaration() {
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST stepDeclaration_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)RefToken  id = ANTLR_USE_NAMESPACE(antlr)nullToken;
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	{
	RefMyAST tmp14_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp14_AST = astFactory->create(LT(1));
	astFactory->makeASTRoot(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp14_AST));
	match(STEP_DECL);
	id = LT(1);
	id_AST = astFactory->create(id);
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	match(ID);
	match(LBRACKET);
	match(RBRACKET);
	stepBody();
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
	}
#line 464 "dataflow_parser.g"
	
	// Add the step to the workflow known steps.
	if (!mWorkflow->addStepDeclaration(ASCIIToWide(id->getText())))
	{
	throw DataflowRedefinedStepException(
	ASCIIToWide(id->getText()),
	mFilename,
	id->getLine(),
	id->getColumn());
	}
	
#line 835 "DataflowParser.cpp"
	stepDeclaration_AST = RefMyAST(currentAST.root);
	returnAST = stepDeclaration_AST;
}

void DataflowParser::controlFlow() {
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST controlFlow_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST tmp17_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp17_AST = astFactory->create(LT(1));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp17_AST));
	match(STEPS_BEGIN);
	controlFlowBody();
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
	RefMyAST tmp18_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp18_AST = astFactory->create(LT(1));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp18_AST));
	match(STEPS_END);
	controlFlow_AST = RefMyAST(currentAST.root);
	returnAST = controlFlow_AST;
}

void DataflowParser::compositeParameters() {
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST compositeParameters_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	{
	compositeParameterSpec();
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == COMMA)) {
			match(COMMA);
			compositeParameterSpec();
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop19;
		}
		
	}
	_loop19:;
	} // ( ... )*
	}
	compositeParameters_AST = RefMyAST(currentAST.root);
	returnAST = compositeParameters_AST;
}

void DataflowParser::compositeBody() {
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST compositeBody_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	match(LPAREN);
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == ID) && (_tokenSet_2.member(LA(2)))) {
			nodeStatement();
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			{
			switch ( LA(1)) {
			case SEMI:
			{
				match(SEMI);
				break;
			}
			case RPAREN:
			case ID:
			{
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
		}
		else if ((LA(1) == ID) && (LA(2) == ARROW || LA(2) == LPAREN)) {
			edgeStatement();
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			{
			switch ( LA(1)) {
			case SEMI:
			{
				match(SEMI);
				break;
			}
			case RPAREN:
			case ID:
			{
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
		}
		else {
			goto _loop32;
		}
		
	}
	_loop32:;
	} // ( ... )*
	match(RPAREN);
	compositeBody_AST = RefMyAST(currentAST.root);
	returnAST = compositeBody_AST;
}

void DataflowParser::compositeParameterSpec() {
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST compositeParameterSpec_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	{
	switch ( LA(1)) {
	case INPUT:
	{
		compositeParameterInputSpec();
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		break;
	}
	case OUTPUT:
	{
		compositeParameterOutputSpec();
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		break;
	}
	case STRING_DECL:
	case INTEGER_DECL:
	case BOOLEAN_DECL:
	case SUBLIST_DECL:
	{
		compositeArgSpec();
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	compositeParameterSpec_AST = RefMyAST(currentAST.root);
	returnAST = compositeParameterSpec_AST;
}

void DataflowParser::compositeParameterInputSpec() {
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST compositeParameterInputSpec_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)RefToken  paramName = ANTLR_USE_NAMESPACE(antlr)nullToken;
	RefMyAST paramName_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)RefToken  operatorId = ANTLR_USE_NAMESPACE(antlr)nullToken;
	RefMyAST operatorId_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)RefToken  i = ANTLR_USE_NAMESPACE(antlr)nullToken;
	RefMyAST i_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)RefToken  s = ANTLR_USE_NAMESPACE(antlr)nullToken;
	RefMyAST s_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 373 "dataflow_parser.g"
	
	int portIndex(0);
	std::wstring portName;
	int portLine, portCol;
	
#line 1006 "DataflowParser.cpp"
	
	RefMyAST tmp24_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp24_AST = astFactory->create(LT(1));
	astFactory->makeASTRoot(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp24_AST));
	match(INPUT);
	paramName = LT(1);
	paramName_AST = astFactory->create(paramName);
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(paramName_AST));
	match(STRING_LITERAL);
	RefMyAST tmp25_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp25_AST = astFactory->create(LT(1));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp25_AST));
	match(IS);
	operatorId = LT(1);
	operatorId_AST = astFactory->create(operatorId);
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(operatorId_AST));
	match(ID);
	match(LPAREN);
	{
	switch ( LA(1)) {
	case NUM_INT:
	{
		i = LT(1);
		i_AST = astFactory->create(i);
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(i_AST));
		match(NUM_INT);
#line 382 "dataflow_parser.g"
		
		portIndex = boost::lexical_cast<int>(i_AST->getText()); 
		portLine = i_AST->getLine();
		portCol = i_AST->getColumn();
		
#line 1039 "DataflowParser.cpp"
		break;
	}
	case STRING_LITERAL:
	{
		s = LT(1);
		s_AST = astFactory->create(s);
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(s_AST));
		match(STRING_LITERAL);
#line 388 "dataflow_parser.g"
		
		portLine = s_AST->getLine();
		portCol = s_AST->getColumn();
		::ASCIIToWide(portName, s_AST->getText().substr(1, s_AST->getText().size()-2).c_str(), -1, mEncoding);
		
#line 1054 "DataflowParser.cpp"
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	match(RPAREN);
#line 395 "dataflow_parser.g"
	
	mActiveCompositeDefinition->addInput(
	ASCIIToWide(paramName->getText().substr(1, paramName->getText().size()-2)),
	ASCIIToWide(operatorId->getText()), portName, portIndex,
	paramName->getLine(), paramName->getColumn(),
	operatorId->getLine(), operatorId->getColumn(),
	portLine, portCol);
	
#line 1073 "DataflowParser.cpp"
	compositeParameterInputSpec_AST = RefMyAST(currentAST.root);
	returnAST = compositeParameterInputSpec_AST;
}

void DataflowParser::compositeParameterOutputSpec() {
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST compositeParameterOutputSpec_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)RefToken  paramName = ANTLR_USE_NAMESPACE(antlr)nullToken;
	RefMyAST paramName_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)RefToken  operatorId = ANTLR_USE_NAMESPACE(antlr)nullToken;
	RefMyAST operatorId_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)RefToken  i = ANTLR_USE_NAMESPACE(antlr)nullToken;
	RefMyAST i_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)RefToken  s = ANTLR_USE_NAMESPACE(antlr)nullToken;
	RefMyAST s_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 404 "dataflow_parser.g"
	
	int portIndex(0);
	std::wstring portName;
	int portLine, portCol;
	
#line 1096 "DataflowParser.cpp"
	
	RefMyAST tmp28_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp28_AST = astFactory->create(LT(1));
	astFactory->makeASTRoot(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp28_AST));
	match(OUTPUT);
	paramName = LT(1);
	paramName_AST = astFactory->create(paramName);
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(paramName_AST));
	match(STRING_LITERAL);
	RefMyAST tmp29_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp29_AST = astFactory->create(LT(1));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp29_AST));
	match(IS);
	operatorId = LT(1);
	operatorId_AST = astFactory->create(operatorId);
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(operatorId_AST));
	match(ID);
	match(LPAREN);
	{
	switch ( LA(1)) {
	case NUM_INT:
	{
		i = LT(1);
		i_AST = astFactory->create(i);
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(i_AST));
		match(NUM_INT);
#line 413 "dataflow_parser.g"
		
		portIndex = boost::lexical_cast<int>(i_AST->getText()); 
		portLine = i_AST->getLine();
		portCol = i_AST->getColumn();
		
#line 1129 "DataflowParser.cpp"
		break;
	}
	case STRING_LITERAL:
	{
		s = LT(1);
		s_AST = astFactory->create(s);
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(s_AST));
		match(STRING_LITERAL);
#line 419 "dataflow_parser.g"
		
		portLine = s_AST->getLine();
		portCol = s_AST->getColumn();
		::ASCIIToWide(portName, s_AST->getText().substr(1, s_AST->getText().size()-2).c_str(), -1, mEncoding);
		
#line 1144 "DataflowParser.cpp"
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	match(RPAREN);
#line 426 "dataflow_parser.g"
	
	mActiveCompositeDefinition->addOutput(
	ASCIIToWide(paramName->getText().substr(1, paramName->getText().size()-2)),
	ASCIIToWide(operatorId->getText()), portName, portIndex,
	paramName->getLine(), paramName->getColumn(),
	operatorId->getLine(), operatorId->getColumn(),
	portLine, portCol);
	
#line 1163 "DataflowParser.cpp"
	compositeParameterOutputSpec_AST = RefMyAST(currentAST.root);
	returnAST = compositeParameterOutputSpec_AST;
}

void DataflowParser::compositeArgSpec() {
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST compositeArgSpec_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)RefToken  variableId = ANTLR_USE_NAMESPACE(antlr)nullToken;
	RefMyAST variableId_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 435 "dataflow_parser.g"
	
	OperatorArgType argType;
	
#line 1178 "DataflowParser.cpp"
	
	{
	switch ( LA(1)) {
	case STRING_DECL:
	{
		RefMyAST tmp32_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp32_AST = astFactory->create(LT(1));
		astFactory->makeASTRoot(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp32_AST));
		match(STRING_DECL);
#line 440 "dataflow_parser.g"
		argType = OPERATOR_ARG_TYPE_STRING;
#line 1190 "DataflowParser.cpp"
		break;
	}
	case INTEGER_DECL:
	{
		RefMyAST tmp33_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp33_AST = astFactory->create(LT(1));
		astFactory->makeASTRoot(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp33_AST));
		match(INTEGER_DECL);
#line 441 "dataflow_parser.g"
		argType = OPERATOR_ARG_TYPE_INTEGER;
#line 1201 "DataflowParser.cpp"
		break;
	}
	case BOOLEAN_DECL:
	{
		RefMyAST tmp34_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp34_AST = astFactory->create(LT(1));
		astFactory->makeASTRoot(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp34_AST));
		match(BOOLEAN_DECL);
#line 442 "dataflow_parser.g"
		argType = OPERATOR_ARG_TYPE_BOOLEAN;
#line 1212 "DataflowParser.cpp"
		break;
	}
	case SUBLIST_DECL:
	{
		RefMyAST tmp35_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp35_AST = astFactory->create(LT(1));
		astFactory->makeASTRoot(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp35_AST));
		match(SUBLIST_DECL);
#line 443 "dataflow_parser.g"
		argType = OPERATOR_ARG_TYPE_SUBLIST;
#line 1223 "DataflowParser.cpp"
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	RefMyAST tmp36_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp36_AST = astFactory->create(LT(1));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp36_AST));
	match(DOLLAR_SIGN);
	variableId = LT(1);
	variableId_AST = astFactory->create(variableId);
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(variableId_AST));
	match(ID);
#line 445 "dataflow_parser.g"
	
	mActiveCompositeDefinition->addArg(argType,
	ASCIIToWide(variableId->getText()),
	variableId->getLine(),
	variableId->getColumn());
	
	mArgEnvironment->storeEnvironmentalSettingForArg(ASCIIToWide(variableId->getText()));
	
#line 1249 "DataflowParser.cpp"
	compositeArgSpec_AST = RefMyAST(currentAST.root);
	returnAST = compositeArgSpec_AST;
}

void DataflowParser::stepBody() {
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST stepBody_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST tmp37_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp37_AST = astFactory->create(LT(1));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp37_AST));
	match(LPAREN);
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == ID) && (_tokenSet_2.member(LA(2)))) {
			nodeStatement();
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			{
			switch ( LA(1)) {
			case SEMI:
			{
				match(SEMI);
				break;
			}
			case RPAREN:
			case ID:
			{
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
		}
		else if ((LA(1) == ID) && (LA(2) == ARROW || LA(2) == LPAREN)) {
			edgeStatement();
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			{
			switch ( LA(1)) {
			case SEMI:
			{
				match(SEMI);
				break;
			}
			case RPAREN:
			case ID:
			{
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
		}
		else {
			goto _loop39;
		}
		
	}
	_loop39:;
	} // ( ... )*
	RefMyAST tmp40_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp40_AST = astFactory->create(LT(1));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp40_AST));
	match(RPAREN);
	stepBody_AST = RefMyAST(currentAST.root);
	returnAST = stepBody_AST;
}

void DataflowParser::controlFlowBody() {
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST controlFlowBody_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	{ // ( ... )*
	for (;;) {
		switch ( LA(1)) {
		case ID:
		{
			stepStatement();
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case IF_BEGIN:
		{
			ifStatement();
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		default:
		{
			goto _loop43;
		}
		}
	}
	_loop43:;
	} // ( ... )*
	controlFlowBody_AST = RefMyAST(currentAST.root);
	returnAST = controlFlowBody_AST;
}

void DataflowParser::stepStatement() {
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST stepStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)RefToken  id = ANTLR_USE_NAMESPACE(antlr)nullToken;
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 531 "dataflow_parser.g"
	
	std::wstring opType;
	int opTypeLine=1;
	int opTypeCol=1;
	
#line 1368 "DataflowParser.cpp"
	
	{
	id = LT(1);
	id_AST = astFactory->create(id);
	astFactory->makeASTRoot(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	match(ID);
#line 540 "dataflow_parser.g"
	
	::ASCIIToWide(opType, id_AST->getText().c_str(), -1, mEncoding);
	opTypeLine = id->getLine(); 
	opTypeCol = id->getColumn(); 
	id_AST->setType(STEP);
	
#line 1382 "DataflowParser.cpp"
	}
	{
	switch ( LA(1)) {
	case SEMI:
	{
		match(SEMI);
		break;
	}
	case IF_BEGIN:
	case IF_END:
	case ELSE:
	case STEPS_END:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
#line 548 "dataflow_parser.g"
	
	if (!mWorkflow->isKnownStep(opType.c_str()))
	{
	throw DataflowGeneralException(
	id_AST->getLine(),
	id_AST->getColumn(),
	mFilename,
	L"Encountered unrecognized step: " + opType);
	}
	
#line 1416 "DataflowParser.cpp"
	stepStatement_AST = RefMyAST(currentAST.root);
	returnAST = stepStatement_AST;
}

void DataflowParser::ifStatement() {
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST ifStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST tmp42_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp42_AST = astFactory->create(LT(1));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp42_AST));
	match(IF_BEGIN);
	RefMyAST tmp43_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp43_AST = astFactory->create(LT(1));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp43_AST));
	match(LPAREN);
	ifPredicate();
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
	RefMyAST tmp44_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp44_AST = astFactory->create(LT(1));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp44_AST));
	match(RPAREN);
	RefMyAST tmp45_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp45_AST = astFactory->create(LT(1));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp45_AST));
	match(THEN);
	controlFlowBody();
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
	{
	switch ( LA(1)) {
	case ELSE:
	{
		RefMyAST tmp46_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp46_AST = astFactory->create(LT(1));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp46_AST));
		match(ELSE);
		controlFlowBody();
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		break;
	}
	case IF_END:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	RefMyAST tmp47_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp47_AST = astFactory->create(LT(1));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp47_AST));
	match(IF_END);
	{
	switch ( LA(1)) {
	case SEMI:
	{
		match(SEMI);
		break;
	}
	case IF_BEGIN:
	case IF_END:
	case ELSE:
	case STEPS_END:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	ifStatement_AST = RefMyAST(currentAST.root);
	returnAST = ifStatement_AST;
}

void DataflowParser::ifPredicate() {
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST ifPredicate_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)RefToken  id = ANTLR_USE_NAMESPACE(antlr)nullToken;
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	{
	switch ( LA(1)) {
	case BANG:
	{
		RefMyAST tmp49_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp49_AST = astFactory->create(LT(1));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp49_AST));
		match(BANG);
		break;
	}
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	id = LT(1);
	id_AST = astFactory->create(id);
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	match(ID);
	RefMyAST tmp50_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp50_AST = astFactory->create(LT(1));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp50_AST));
	match(LPAREN);
	ifArgument();
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
	RefMyAST tmp51_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp51_AST = astFactory->create(LT(1));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp51_AST));
	match(RPAREN);
#line 511 "dataflow_parser.g"
	
	if (boost::algorithm::iequals(id_AST->getText(), "doesFileExist"))
	{
	id_AST->setType(PREDICATE_DOES_FILE_EXIST);
	}
	else if (boost::algorithm::iequals(id_AST->getText(), "isFileEmpty"))
	{
	id_AST->setType(PREDICATE_IS_FILE_EMPTY);
	}
	else
	{
	throw DataflowGeneralException(
	id_AST->getLine(),
	id_AST->getColumn(),
	mFilename,
	L"Encountered unrecognized if predicate: " + ASCIIToWide(id_AST->getText()));
	}
	
#line 1557 "DataflowParser.cpp"
	ifPredicate_AST = RefMyAST(currentAST.root);
	returnAST = ifPredicate_AST;
}

void DataflowParser::ifArgument() {
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST ifArgument_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	{
	switch ( LA(1)) {
	case STRING_LITERAL:
	{
		ifArgumentValue();
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		break;
	}
	case DOLLAR_SIGN:
	{
		argumentVariable();
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	ifArgument_AST = RefMyAST(currentAST.root);
	returnAST = ifArgument_AST;
}

void DataflowParser::arguments() {
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST arguments_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	argument();
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == COMMA)) {
			match(COMMA);
			argument();
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop59;
		}
		
	}
	_loop59:;
	} // ( ... )*
	arguments_AST = RefMyAST(currentAST.root);
	returnAST = arguments_AST;
}

void DataflowParser::argument() {
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST argument_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST tmp53_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp53_AST = astFactory->create(LT(1));
	astFactory->makeASTRoot(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp53_AST));
	match(ID);
	match(EQUALS);
	{
	switch ( LA(1)) {
	case TK_FALSE:
	case TK_TRUE:
	case NUM_DECIMAL:
	case NUM_FLOAT:
	case NUM_BIGINT:
	case LBRACKET:
	case STRING_LITERAL:
	case NUM_INT:
	{
		argumentValue();
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		break;
	}
	case DOLLAR_SIGN:
	{
		argumentVariable();
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	argument_AST = RefMyAST(currentAST.root);
	returnAST = argument_AST;
}

void DataflowParser::argumentValue() {
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST argumentValue_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	switch ( LA(1)) {
	case NUM_INT:
	{
		RefMyAST tmp55_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp55_AST = astFactory->create(LT(1));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp55_AST));
		match(NUM_INT);
		argumentValue_AST = RefMyAST(currentAST.root);
		break;
	}
	case NUM_BIGINT:
	{
		RefMyAST tmp56_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp56_AST = astFactory->create(LT(1));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp56_AST));
		match(NUM_BIGINT);
		argumentValue_AST = RefMyAST(currentAST.root);
		break;
	}
	case NUM_FLOAT:
	{
		RefMyAST tmp57_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp57_AST = astFactory->create(LT(1));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp57_AST));
		match(NUM_FLOAT);
		argumentValue_AST = RefMyAST(currentAST.root);
		break;
	}
	case NUM_DECIMAL:
	{
		RefMyAST tmp58_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp58_AST = astFactory->create(LT(1));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp58_AST));
		match(NUM_DECIMAL);
		argumentValue_AST = RefMyAST(currentAST.root);
		break;
	}
	case STRING_LITERAL:
	{
		RefMyAST tmp59_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp59_AST = astFactory->create(LT(1));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp59_AST));
		match(STRING_LITERAL);
		argumentValue_AST = RefMyAST(currentAST.root);
		break;
	}
	case TK_TRUE:
	{
		RefMyAST tmp60_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp60_AST = astFactory->create(LT(1));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp60_AST));
		match(TK_TRUE);
		argumentValue_AST = RefMyAST(currentAST.root);
		break;
	}
	case TK_FALSE:
	{
		RefMyAST tmp61_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp61_AST = astFactory->create(LT(1));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp61_AST));
		match(TK_FALSE);
		argumentValue_AST = RefMyAST(currentAST.root);
		break;
	}
	case LBRACKET:
	{
		match(LBRACKET);
		arguments();
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		match(RBRACKET);
		argumentValue_AST = RefMyAST(currentAST.root);
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	returnAST = argumentValue_AST;
}

void DataflowParser::argumentVariable() {
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST argumentVariable_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST tmp64_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp64_AST = astFactory->create(LT(1));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp64_AST));
	match(DOLLAR_SIGN);
	RefMyAST tmp65_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp65_AST = astFactory->create(LT(1));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp65_AST));
	match(ID);
	argumentVariable_AST = RefMyAST(currentAST.root);
	returnAST = argumentVariable_AST;
}

void DataflowParser::ifArgumentValue() {
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST ifArgumentValue_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST tmp66_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp66_AST = astFactory->create(LT(1));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp66_AST));
	match(STRING_LITERAL);
	ifArgumentValue_AST = RefMyAST(currentAST.root);
	returnAST = ifArgumentValue_AST;
}

void DataflowParser::annotationArguments() {
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST annotationArguments_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	annotationArgument();
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == COMMA)) {
			match(COMMA);
			annotationArgument();
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop69;
		}
		
	}
	_loop69:;
	} // ( ... )*
	annotationArguments_AST = RefMyAST(currentAST.root);
	returnAST = annotationArguments_AST;
}

void DataflowParser::annotationArgument() {
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST annotationArgument_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST tmp68_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp68_AST = astFactory->create(LT(1));
	astFactory->makeASTRoot(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp68_AST));
	match(ID);
	annotationArgumentDataType();
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
	annotationArgument_AST = RefMyAST(currentAST.root);
	returnAST = annotationArgument_AST;
}

void DataflowParser::annotationArgumentDataType() {
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST annotationArgumentDataType_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	if ((LA(1) == ID) && (LA(2) == COMMA || LA(2) == RCURLY)) {
		RefMyAST tmp69_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp69_AST = astFactory->create(LT(1));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp69_AST));
		match(ID);
		annotationArgumentDataType_AST = RefMyAST(currentAST.root);
	}
	else if ((LA(1) == ID) && (LA(2) == ID)) {
		{
		RefMyAST tmp70_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp70_AST = astFactory->create(LT(1));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp70_AST));
		match(ID);
		RefMyAST tmp71_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp71_AST = astFactory->create(LT(1));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp71_AST));
		match(ID);
		}
		annotationArgumentDataType_AST = RefMyAST(currentAST.root);
	}
	else {
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	
	returnAST = annotationArgumentDataType_AST;
}

void DataflowParser::nodeDefOrRef() {
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST nodeDefOrRef_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST tmp72_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp72_AST = astFactory->create(LT(1));
	astFactory->makeASTRoot(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp72_AST));
	match(ID);
	{
	switch ( LA(1)) {
	case LPAREN:
	{
		match(LPAREN);
		{
		switch ( LA(1)) {
		case NUM_INT:
		{
			RefMyAST tmp74_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
			tmp74_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp74_AST));
			match(NUM_INT);
			break;
		}
		case STRING_LITERAL:
		{
			RefMyAST tmp75_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
			tmp75_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp75_AST));
			match(STRING_LITERAL);
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		}
		}
		match(RPAREN);
		break;
	}
	case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
	case OPERATOR:
	case STEP_DECL:
	case STEPS_BEGIN:
	case ARROW:
	case RPAREN:
	case SEMI:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	nodeDefOrRef_AST = RefMyAST(currentAST.root);
	returnAST = nodeDefOrRef_AST;
}

void DataflowParser::arrowArguments() {
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST arrowArguments_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST tmp77_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp77_AST = astFactory->create(LT(1));
	astFactory->makeASTRoot(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp77_AST));
	match(LBRACKET);
	arguments();
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
	match(RBRACKET);
	arrowArguments_AST = RefMyAST(currentAST.root);
	returnAST = arrowArguments_AST;
}

void DataflowParser::arrowAnnotation() {
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST arrowAnnotation_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST tmp79_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp79_AST = astFactory->create(LT(1));
	astFactory->makeASTRoot(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp79_AST));
	match(LCURLY);
	annotationArguments();
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
	match(RCURLY);
	arrowAnnotation_AST = RefMyAST(currentAST.root);
	returnAST = arrowAnnotation_AST;
}

void DataflowParser::initializeASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& factory )
{
	factory.setMaxNodeType(125);
}
const char* DataflowParser::tokenNames[] = {
	"<0>",
	"EOF",
	"<2>",
	"NULL_TREE_LOOKAHEAD",
	"\"FALSE\"",
	"\"TRUE\"",
	"NUM_DECIMAL",
	"NUM_FLOAT",
	"NUM_BIGINT",
	"\"is\"",
	"\"operator\"",
	"\"in\"",
	"\"out\"",
	"\"string\"",
	"\"integer\"",
	"\"boolean\"",
	"\"sublist\"",
	"\"include\"",
	"\"step\"",
	"\"if\"",
	"\"endif\"",
	"\"else\"",
	"\"then\"",
	"\"steps\"",
	"\"endsteps\"",
	"AMPERSAND",
	"ARROW",
	"BANG",
	"BOM",
	"DOLLAR_SIGN",
	"EQUALS",
	"NOTEQUALS",
	"NOTEQUALS2",
	"LTN",
	"LTEQ",
	"GT",
	"GTEQ",
	"MODULO",
	"SL_COMMENT",
	"ML_COMMENT",
	"CARET",
	"COMMA",
	"DOT",
	"LBRACKET",
	"LCURLY",
	"\'(\'",
	"RBRACKET",
	"RCURLY",
	"\')\'",
	"MINUS",
	"PIPE",
	"PLUS",
	"COLON",
	"SEMI",
	"SLASH",
	"STAR",
	"STRING_LITERAL",
	"TILDE",
	"WS",
	"ID",
	"NUM_INT",
	"EXPONENT",
	"FLOAT_SUFFIX",
	"BIGINT_SUFFIX",
	"HEX_DIGIT",
	"ACCOUNT_RESOLUTION",
	"BROADCAST",
	"COLL",
	"COMPOSITE",
	"COPY",
	"DEVNULL",
	"EXPORT",
	"EXPORT_QUEUE",
	"EXPR",
	"FILTER",
	"GENERATE",
	"GROUP_BY",
	"HASHPART",
	"HASH_RUNNING_TOTAL",
	"ID_GENERATOR",
	"IMPORT",
	"IMPORT_QUEUE",
	"INNER_HASH_JOIN",
	"INNER_MERGE_JOIN",
	"INSERT",
	"LOAD_ERROR",
	"LOAD_USAGE",
	"LONGEST_PREFIX_MATCH",
	"MD5",
	"METER",
	"MULTI_HASH_JOIN",
	"PRINT",
	"PROJECTION",
	"RANGEPART",
	"RATE_CALCULATION",
	"RATE_SCHEDULE_RESOLUTION",
	"RENAME",
	"RIGHT_MERGE_ANTI_SEMI_JOIN",
	"RIGHT_MERGE_SEMI_JOIN",
	"RIGHT_OUTER_HASH_JOIN",
	"RIGHT_OUTER_MERGE_JOIN",
	"SELECT",
	"SEQUENTIAL_FILE_DELETE",
	"SEQUENTIAL_FILE_OUTPUT",
	"SEQUENTIAL_FILE_RENAME",
	"SEQUENTIAL_FILE_SCAN",
	"SESSION_SET_BUILDER",
	"SORT",
	"SORT_GROUP_BY",
	"SORTMERGE",
	"SORTMERGECOLL",
	"SORT_NEST",
	"SORT_ORDER_ASSERT",
	"SORT_RUNNING_TOTAL",
	"STEP",
	"SUBSCRIPTION_RESOLUTION",
	"SQL_EXEC_DIRECT",
	"SWITCH",
	"TAXWARE",
	"UNION_ALL",
	"UNNEST",
	"UNROLL",
	"PREDICATE_DOES_FILE_EXIST",
	"PREDICATE_IS_FILE_EMPTY",
	"WRITE_ERROR",
	"WRITE_PRODUCT_VIEW",
	0
};

const unsigned long DataflowParser::_tokenSet_0_data_[] = { 8651778UL, 137365504UL, 0UL, 0UL };
// EOF "operator" "step" "steps" LBRACKET COLON SEMI ID 
const ANTLR_USE_NAMESPACE(antlr)BitSet DataflowParser::_tokenSet_0(_tokenSet_0_data_,4);
const unsigned long DataflowParser::_tokenSet_1_data_[] = { 2UL, 0UL, 0UL, 0UL };
// EOF 
const ANTLR_USE_NAMESPACE(antlr)BitSet DataflowParser::_tokenSet_1(_tokenSet_1_data_,4);
const unsigned long DataflowParser::_tokenSet_2_data_[] = { 0UL, 137431040UL, 0UL, 0UL };
// LBRACKET RPAREN COLON SEMI ID 
const ANTLR_USE_NAMESPACE(antlr)BitSet DataflowParser::_tokenSet_2(_tokenSet_2_data_,4);


