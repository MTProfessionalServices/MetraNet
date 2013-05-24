/* $ANTLR 2.7.6 (2005-12-22): "dataflow_analyze.g" -> "DataflowTreeParser.cpp"$ */
#include "DataflowTreeParser.hpp"
#include <antlr/Token.hpp>
#include <antlr/AST.hpp>
#include <antlr/NoViableAltException.hpp>
#include <antlr/MismatchedTokenException.hpp>
#include <antlr/SemanticException.hpp>
#include <antlr/BitSet.hpp>
#line 1 "dataflow_analyze.g"
#line 11 "DataflowTreeParser.cpp"
DataflowTreeParser::DataflowTreeParser()
	: ANTLR_USE_NAMESPACE(antlr)TreeParser() {
}

void DataflowTreeParser::program(RefMyAST _t) {
	RefMyAST program_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST program_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	{
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == INCLUDE_COMPOSITE)) {
			includeCompositeStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			{
			if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
				_t = ASTNULL;
			switch ( _t->getType()) {
			case SEMI:
			{
				RefMyAST tmp1_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
				match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SEMI);
				_t = _t->getNextSibling();
				break;
			}
			case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
			case OPERATOR:
			case INCLUDE_COMPOSITE:
			case STEP_DECL:
			case STEPS_BEGIN:
			case ARROW:
			case ACCOUNT_RESOLUTION:
			case BROADCAST:
			case COLL:
			case COMPOSITE:
			case COPY:
			case DEVNULL:
			case EXPORT:
			case EXPORT_QUEUE:
			case EXPR:
			case FILTER:
			case GENERATE:
			case GROUP_BY:
			case HASHPART:
			case HASH_RUNNING_TOTAL:
			case ID_GENERATOR:
			case IMPORT:
			case IMPORT_QUEUE:
			case INNER_HASH_JOIN:
			case INNER_MERGE_JOIN:
			case INSERT:
			case LOAD_ERROR:
			case LOAD_USAGE:
			case LONGEST_PREFIX_MATCH:
			case MD5:
			case METER:
			case MULTI_HASH_JOIN:
			case PRINT:
			case PROJECTION:
			case RANGEPART:
			case RATE_CALCULATION:
			case RATE_SCHEDULE_RESOLUTION:
			case RENAME:
			case RIGHT_MERGE_ANTI_SEMI_JOIN:
			case RIGHT_MERGE_SEMI_JOIN:
			case RIGHT_OUTER_HASH_JOIN:
			case RIGHT_OUTER_MERGE_JOIN:
			case SELECT:
			case SEQUENTIAL_FILE_DELETE:
			case SEQUENTIAL_FILE_OUTPUT:
			case SEQUENTIAL_FILE_RENAME:
			case SEQUENTIAL_FILE_SCAN:
			case SESSION_SET_BUILDER:
			case SORT:
			case SORT_GROUP_BY:
			case SORTMERGE:
			case SORTMERGECOLL:
			case SORT_NEST:
			case SORT_ORDER_ASSERT:
			case SORT_RUNNING_TOTAL:
			case SUBSCRIPTION_RESOLUTION:
			case SQL_EXEC_DIRECT:
			case SWITCH:
			case TAXWARE:
			case UNION_ALL:
			case UNNEST:
			case UNROLL:
			case WRITE_ERROR:
			case WRITE_PRODUCT_VIEW:
			{
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
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
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case OPERATOR:
		{
			compositeDeclaration(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case STEP_DECL:
		{
			stepDeclaration(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		default:
		{
			goto _loop7;
		}
		}
	}
	_loop7:;
	} // ( ... )*
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	if ((_tokenSet_0.member(_t->getType()))) {
		mainScript(_t);
		_t = _retTree;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
	}
	else if ((_t->getType() == ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE)) {
	}
	else {
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	
	}
	}
	RefMyAST tmp2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp2_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp2_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE);
	_t = _t->getNextSibling();
	program_AST = RefMyAST(currentAST.root);
	returnAST = program_AST;
	_retTree = _t;
}

void DataflowTreeParser::includeCompositeStatement(RefMyAST _t) {
	RefMyAST includeCompositeStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST includeCompositeStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST filename = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST filename_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	{
	RefMyAST tmp3_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp3_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp3_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp3_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp3_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),INCLUDE_COMPOSITE);
	_t = _t->getNextSibling();
	filename = _t;
	RefMyAST filename_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	filename_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(filename));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(filename_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),STRING_LITERAL);
	_t = _t->getNextSibling();
	}
	includeCompositeStatement_AST = RefMyAST(currentAST.root);
	returnAST = includeCompositeStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::compositeDeclaration(RefMyAST _t) {
	RefMyAST compositeDeclaration_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST compositeDeclaration_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST compositeNameId = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST compositeNameId_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 352 "dataflow_analyze.g"
	
	// We are processing a composite declaration.
	// We make a new symbol table to hold the operator definitions.
	// This will be stored as part of the composite definition.
	std::map<std::wstring, DataflowSymbol> *compositeSymbolTable =
	new std::map<std::wstring, DataflowSymbol>;
	
	// All operators that we encountered will be stored to this table.
	mActiveSymbolTable = compositeSymbolTable;
	
#line 224 "DataflowTreeParser.cpp"
	
	RefMyAST __t18 = _t;
	RefMyAST tmp4_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp4_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp4_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp4_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp4_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST18 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),OPERATOR);
	_t = _t->getFirstChild();
	compositeNameId = _t;
	RefMyAST compositeNameId_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	compositeNameId_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(compositeNameId));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(compositeNameId_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
	_t = _t->getNextSibling();
	compositeParameters(_t);
	_t = _retTree;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
	compositeBody(_t);
	_t = _retTree;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
	currentAST = __currentAST18;
	_t = __t18;
	_t = _t->getNextSibling();
#line 365 "dataflow_analyze.g"
	
	// When we reach this point, we have finished parsing the composite.
	// Our symbol table is loaded with the encountered operators.
	// Save the symbol table underneath the composite definition.
	// Ownership of symbol table is given to the composite definition.
	// Update the symbol table input/output port counts to reflect
	// composite parameters.
	mCompositeDictionary->setSymbolTableAndUpdateForComposite(
	ASCIIToWide(compositeNameId->getText()), compositeSymbolTable);
	
	// We are done processing the composite declaration.
	// We now assume we are processing script.
	mActiveSymbolTable = mMainSymbolTable;
	
#line 267 "DataflowTreeParser.cpp"
	compositeDeclaration_AST = RefMyAST(currentAST.root);
	returnAST = compositeDeclaration_AST;
	_retTree = _t;
}

void DataflowTreeParser::stepDeclaration(RefMyAST _t) {
	RefMyAST stepDeclaration_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST stepDeclaration_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t43 = _t;
	RefMyAST tmp5_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp5_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp5_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp5_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp5_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST43 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),STEP_DECL);
	_t = _t->getFirstChild();
	id = _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
	_t = _t->getNextSibling();
#line 437 "dataflow_analyze.g"
	
	// Create a map symbol for the operators in this step
	// and make this be the active symbol table.
	std::map<std::wstring, DataflowSymbol> 
	*symbolTable = new std::map<std::wstring, DataflowSymbol>;
	
	(*mMapOfSymbolTables)[ASCIIToWide(id_AST->getText())] = symbolTable;
	mActiveSymbolTable = symbolTable;
	
#line 308 "DataflowTreeParser.cpp"
	stepBody(_t);
	_t = _retTree;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
	currentAST = __currentAST43;
	_t = __t43;
	_t = _t->getNextSibling();
#line 447 "dataflow_analyze.g"
	
	// Now that we've finished with the step, set the symbol table
	// back to that of the main script.
	mActiveSymbolTable = mMainSymbolTable;
	
#line 321 "DataflowTreeParser.cpp"
	stepDeclaration_AST = RefMyAST(currentAST.root);
	returnAST = stepDeclaration_AST;
	_retTree = _t;
}

void DataflowTreeParser::mainScript(RefMyAST _t) {
	RefMyAST mainScript_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST mainScript_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	{
	dataFlowBody(_t);
	_t = _retTree;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
	}
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case STEPS_BEGIN:
	{
		controlFlow(_t);
		_t = _retTree;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		break;
	}
	case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	mainScript_AST = RefMyAST(currentAST.root);
	returnAST = mainScript_AST;
	_retTree = _t;
}

void DataflowTreeParser::dataFlowBody(RefMyAST _t) {
	RefMyAST dataFlowBody_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST dataFlowBody_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case ACCOUNT_RESOLUTION:
		{
			accountResolutionStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case BROADCAST:
		{
			broadcastStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case COLL:
		{
			collStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case COMPOSITE:
		{
			compositeStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case COPY:
		{
			copyStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case DEVNULL:
		{
			devNullStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case EXPORT:
		{
			exportStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case EXPORT_QUEUE:
		{
			exportQueueStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case EXPR:
		{
			exprStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case FILTER:
		{
			filterStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case GENERATE:
		{
			generateStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case GROUP_BY:
		{
			groupByStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case HASHPART:
		{
			hashPartStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case HASH_RUNNING_TOTAL:
		{
			hashRunningTotalStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case ID_GENERATOR:
		{
			idGeneratorStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case IMPORT:
		{
			importStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case IMPORT_QUEUE:
		{
			importQueueStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case INNER_HASH_JOIN:
		{
			innerHashJoinStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case INNER_MERGE_JOIN:
		{
			innerMergeJoinStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case INSERT:
		{
			insertStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case LOAD_ERROR:
		{
			loadErrorStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case LOAD_USAGE:
		{
			loadUsageStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case LONGEST_PREFIX_MATCH:
		{
			longestPrefixMatchStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case MD5:
		{
			md5Statement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case METER:
		{
			meterStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case MULTI_HASH_JOIN:
		{
			multiHashJoinStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case PRINT:
		{
			printStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case PROJECTION:
		{
			projectionStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case RANGEPART:
		{
			rangePartStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case RATE_CALCULATION:
		{
			rateCalculationStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case RATE_SCHEDULE_RESOLUTION:
		{
			rateScheduleResolutionStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case RENAME:
		{
			renameStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case RIGHT_MERGE_ANTI_SEMI_JOIN:
		{
			rightMergeAntiSemiJoinStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case RIGHT_MERGE_SEMI_JOIN:
		{
			rightMergeSemiJoinStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case RIGHT_OUTER_HASH_JOIN:
		{
			rightOuterHashJoinStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case RIGHT_OUTER_MERGE_JOIN:
		{
			rightOuterMergeJoinStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case SELECT:
		{
			selectStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case SEQUENTIAL_FILE_DELETE:
		{
			sequentialFileDeleteStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case SEQUENTIAL_FILE_OUTPUT:
		{
			sequentialFileOutputStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case SEQUENTIAL_FILE_RENAME:
		{
			sequentialFileRenameStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case SEQUENTIAL_FILE_SCAN:
		{
			sequentialFileScanStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case SESSION_SET_BUILDER:
		{
			sessionSetBuilderStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case SORT:
		{
			sortStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case SORT_GROUP_BY:
		{
			sortGroupByStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case SORTMERGE:
		{
			sortMergeStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case SORTMERGECOLL:
		{
			sortMergeCollStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case SORT_NEST:
		{
			sortNestStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case SORT_ORDER_ASSERT:
		{
			sortOrderAssertStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case SORT_RUNNING_TOTAL:
		{
			sortRunningTotalStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case SQL_EXEC_DIRECT:
		{
			sqlExecDirectStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case SUBSCRIPTION_RESOLUTION:
		{
			subscriptionResolutionStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case SWITCH:
		{
			switchStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case TAXWARE:
		{
			taxwareStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case UNION_ALL:
		{
			unionAllStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case UNNEST:
		{
			unnestStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case UNROLL:
		{
			unrollStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case WRITE_ERROR:
		{
			writeErrorStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case WRITE_PRODUCT_VIEW:
		{
			writeProductViewStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case ARROW:
		{
			edgeStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		default:
		{
			goto _loop14;
		}
		}
	}
	_loop14:;
	} // ( ... )*
	dataFlowBody_AST = RefMyAST(currentAST.root);
	returnAST = dataFlowBody_AST;
	_retTree = _t;
}

void DataflowTreeParser::controlFlow(RefMyAST _t) {
	RefMyAST controlFlow_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST controlFlow_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST tmp6_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp6_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp6_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp6_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp6_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),STEPS_BEGIN);
	_t = _t->getNextSibling();
	controlFlowBody(_t);
	_t = _retTree;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
	RefMyAST tmp7_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp7_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp7_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp7_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp7_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),STEPS_END);
	_t = _t->getNextSibling();
	controlFlow_AST = RefMyAST(currentAST.root);
	returnAST = controlFlow_AST;
	_retTree = _t;
}

void DataflowTreeParser::accountResolutionStatement(RefMyAST _t) {
	RefMyAST accountResolutionStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST accountResolutionStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t58 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST58 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ACCOUNT_RESOLUTION);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp8_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp8_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp8_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp8_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp8_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop61;
		}
		
	}
	_loop61:;
	} // ( ... )*
#line 503 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 901 "DataflowTreeParser.cpp"
	currentAST = __currentAST58;
	_t = __t58;
	_t = _t->getNextSibling();
	accountResolutionStatement_AST = RefMyAST(currentAST.root);
	returnAST = accountResolutionStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::broadcastStatement(RefMyAST _t) {
	RefMyAST broadcastStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST broadcastStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t63 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST63 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),BROADCAST);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp9_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp9_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp9_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp9_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp9_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop66;
		}
		
	}
	_loop66:;
	} // ( ... )*
#line 513 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 982 "DataflowTreeParser.cpp"
	currentAST = __currentAST63;
	_t = __t63;
	_t = _t->getNextSibling();
	broadcastStatement_AST = RefMyAST(currentAST.root);
	returnAST = broadcastStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::collStatement(RefMyAST _t) {
	RefMyAST collStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST collStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t68 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST68 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLL);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp10_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp10_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp10_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp10_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp10_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop71;
		}
		
	}
	_loop71:;
	} // ( ... )*
#line 523 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 1063 "DataflowTreeParser.cpp"
	currentAST = __currentAST68;
	_t = __t68;
	_t = _t->getNextSibling();
	collStatement_AST = RefMyAST(currentAST.root);
	returnAST = collStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::compositeStatement(RefMyAST _t) {
	RefMyAST compositeStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST compositeStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t343 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST343 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COMPOSITE);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp11_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp11_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp11_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp11_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp11_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop346;
		}
		
	}
	_loop346:;
	} // ( ... )*
#line 1077 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 1144 "DataflowTreeParser.cpp"
	currentAST = __currentAST343;
	_t = __t343;
	_t = _t->getNextSibling();
	compositeStatement_AST = RefMyAST(currentAST.root);
	returnAST = compositeStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::copyStatement(RefMyAST _t) {
	RefMyAST copyStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST copyStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t73 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST73 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COPY);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp12_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp12_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp12_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp12_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp12_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop76;
		}
		
	}
	_loop76:;
	} // ( ... )*
#line 533 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 1225 "DataflowTreeParser.cpp"
	currentAST = __currentAST73;
	_t = __t73;
	_t = _t->getNextSibling();
	copyStatement_AST = RefMyAST(currentAST.root);
	returnAST = copyStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::devNullStatement(RefMyAST _t) {
	RefMyAST devNullStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST devNullStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t78 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST78 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),DEVNULL);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp13_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp13_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp13_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp13_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp13_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop81;
		}
		
	}
	_loop81:;
	} // ( ... )*
#line 543 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 1306 "DataflowTreeParser.cpp"
	currentAST = __currentAST78;
	_t = __t78;
	_t = _t->getNextSibling();
	devNullStatement_AST = RefMyAST(currentAST.root);
	returnAST = devNullStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::exportStatement(RefMyAST _t) {
	RefMyAST exportStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST exportStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t108 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST108 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),EXPORT);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp14_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp14_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp14_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp14_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp14_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop111;
		}
		
	}
	_loop111:;
	} // ( ... )*
#line 603 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 1387 "DataflowTreeParser.cpp"
	currentAST = __currentAST108;
	_t = __t108;
	_t = _t->getNextSibling();
	exportStatement_AST = RefMyAST(currentAST.root);
	returnAST = exportStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::exportQueueStatement(RefMyAST _t) {
	RefMyAST exportQueueStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST exportQueueStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t113 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST113 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),EXPORT_QUEUE);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp15_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp15_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp15_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp15_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp15_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop116;
		}
		
	}
	_loop116:;
	} // ( ... )*
#line 613 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 1468 "DataflowTreeParser.cpp"
	currentAST = __currentAST113;
	_t = __t113;
	_t = _t->getNextSibling();
	exportQueueStatement_AST = RefMyAST(currentAST.root);
	returnAST = exportQueueStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::exprStatement(RefMyAST _t) {
	RefMyAST exprStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST exprStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t118 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST118 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),EXPR);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp16_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp16_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp16_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp16_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp16_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop121;
		}
		
	}
	_loop121:;
	} // ( ... )*
#line 623 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 1549 "DataflowTreeParser.cpp"
	currentAST = __currentAST118;
	_t = __t118;
	_t = _t->getNextSibling();
	exprStatement_AST = RefMyAST(currentAST.root);
	returnAST = exprStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::filterStatement(RefMyAST _t) {
	RefMyAST filterStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST filterStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t123 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST123 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),FILTER);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp17_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp17_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp17_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp17_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp17_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop126;
		}
		
	}
	_loop126:;
	} // ( ... )*
#line 633 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 1630 "DataflowTreeParser.cpp"
	currentAST = __currentAST123;
	_t = __t123;
	_t = _t->getNextSibling();
	filterStatement_AST = RefMyAST(currentAST.root);
	returnAST = filterStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::generateStatement(RefMyAST _t) {
	RefMyAST generateStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST generateStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t128 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST128 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),GENERATE);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp18_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp18_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp18_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp18_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp18_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop131;
		}
		
	}
	_loop131:;
	} // ( ... )*
#line 643 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 1711 "DataflowTreeParser.cpp"
	currentAST = __currentAST128;
	_t = __t128;
	_t = _t->getNextSibling();
	generateStatement_AST = RefMyAST(currentAST.root);
#line 647 "dataflow_analyze.g"
	
	generateStatement_AST = RefMyAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->create(DELAYED_GENERATE,"DELAYED_GENERATE")))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(generateStatement_AST))));
	
#line 1720 "DataflowTreeParser.cpp"
	currentAST.root = generateStatement_AST;
	if ( generateStatement_AST!=RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) &&
		generateStatement_AST->getFirstChild() != RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		  currentAST.child = generateStatement_AST->getFirstChild();
	else
		currentAST.child = generateStatement_AST;
	currentAST.advanceChildToEnd();
	generateStatement_AST = RefMyAST(currentAST.root);
	returnAST = generateStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::groupByStatement(RefMyAST _t) {
	RefMyAST groupByStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST groupByStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t133 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST133 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),GROUP_BY);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp19_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp19_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp19_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp19_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp19_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop136;
		}
		
	}
	_loop136:;
	} // ( ... )*
#line 656 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 1805 "DataflowTreeParser.cpp"
	currentAST = __currentAST133;
	_t = __t133;
	_t = _t->getNextSibling();
	groupByStatement_AST = RefMyAST(currentAST.root);
	returnAST = groupByStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::hashPartStatement(RefMyAST _t) {
	RefMyAST hashPartStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST hashPartStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t138 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST138 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),HASHPART);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp20_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp20_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp20_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp20_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp20_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop141;
		}
		
	}
	_loop141:;
	} // ( ... )*
#line 666 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 1886 "DataflowTreeParser.cpp"
	currentAST = __currentAST138;
	_t = __t138;
	_t = _t->getNextSibling();
	hashPartStatement_AST = RefMyAST(currentAST.root);
	returnAST = hashPartStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::hashRunningTotalStatement(RefMyAST _t) {
	RefMyAST hashRunningTotalStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST hashRunningTotalStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t143 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST143 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),HASH_RUNNING_TOTAL);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp21_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp21_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp21_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp21_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp21_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop146;
		}
		
	}
	_loop146:;
	} // ( ... )*
#line 676 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 1967 "DataflowTreeParser.cpp"
	currentAST = __currentAST143;
	_t = __t143;
	_t = _t->getNextSibling();
	hashRunningTotalStatement_AST = RefMyAST(currentAST.root);
	returnAST = hashRunningTotalStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::idGeneratorStatement(RefMyAST _t) {
	RefMyAST idGeneratorStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST idGeneratorStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t148 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST148 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID_GENERATOR);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp22_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp22_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp22_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp22_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp22_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop151;
		}
		
	}
	_loop151:;
	} // ( ... )*
#line 686 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 2048 "DataflowTreeParser.cpp"
	currentAST = __currentAST148;
	_t = __t148;
	_t = _t->getNextSibling();
	idGeneratorStatement_AST = RefMyAST(currentAST.root);
	returnAST = idGeneratorStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::importStatement(RefMyAST _t) {
	RefMyAST importStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST importStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t153 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST153 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),IMPORT);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp23_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp23_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp23_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp23_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp23_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop156;
		}
		
	}
	_loop156:;
	} // ( ... )*
#line 696 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 2129 "DataflowTreeParser.cpp"
	currentAST = __currentAST153;
	_t = __t153;
	_t = _t->getNextSibling();
	importStatement_AST = RefMyAST(currentAST.root);
	returnAST = importStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::importQueueStatement(RefMyAST _t) {
	RefMyAST importQueueStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST importQueueStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t158 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST158 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),IMPORT_QUEUE);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp24_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp24_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp24_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp24_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp24_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop161;
		}
		
	}
	_loop161:;
	} // ( ... )*
#line 706 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 2210 "DataflowTreeParser.cpp"
	currentAST = __currentAST158;
	_t = __t158;
	_t = _t->getNextSibling();
	importQueueStatement_AST = RefMyAST(currentAST.root);
	returnAST = importQueueStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::innerHashJoinStatement(RefMyAST _t) {
	RefMyAST innerHashJoinStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST innerHashJoinStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t163 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST163 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),INNER_HASH_JOIN);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp25_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp25_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp25_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp25_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp25_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop166;
		}
		
	}
	_loop166:;
	} // ( ... )*
#line 716 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 2291 "DataflowTreeParser.cpp"
	currentAST = __currentAST163;
	_t = __t163;
	_t = _t->getNextSibling();
	innerHashJoinStatement_AST = RefMyAST(currentAST.root);
	returnAST = innerHashJoinStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::innerMergeJoinStatement(RefMyAST _t) {
	RefMyAST innerMergeJoinStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST innerMergeJoinStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t168 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST168 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),INNER_MERGE_JOIN);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp26_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp26_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp26_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp26_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp26_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop171;
		}
		
	}
	_loop171:;
	} // ( ... )*
#line 726 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 2372 "DataflowTreeParser.cpp"
	currentAST = __currentAST168;
	_t = __t168;
	_t = _t->getNextSibling();
	innerMergeJoinStatement_AST = RefMyAST(currentAST.root);
	returnAST = innerMergeJoinStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::insertStatement(RefMyAST _t) {
	RefMyAST insertStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST insertStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t173 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST173 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),INSERT);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp27_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp27_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp27_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp27_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp27_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop176;
		}
		
	}
	_loop176:;
	} // ( ... )*
#line 736 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 2453 "DataflowTreeParser.cpp"
	currentAST = __currentAST173;
	_t = __t173;
	_t = _t->getNextSibling();
	insertStatement_AST = RefMyAST(currentAST.root);
	returnAST = insertStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::loadErrorStatement(RefMyAST _t) {
	RefMyAST loadErrorStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST loadErrorStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t178 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST178 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),LOAD_ERROR);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp28_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp28_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp28_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp28_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp28_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop181;
		}
		
	}
	_loop181:;
	} // ( ... )*
#line 746 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 2534 "DataflowTreeParser.cpp"
	currentAST = __currentAST178;
	_t = __t178;
	_t = _t->getNextSibling();
	loadErrorStatement_AST = RefMyAST(currentAST.root);
	returnAST = loadErrorStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::loadUsageStatement(RefMyAST _t) {
	RefMyAST loadUsageStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST loadUsageStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t183 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST183 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),LOAD_USAGE);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp29_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp29_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp29_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp29_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp29_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop186;
		}
		
	}
	_loop186:;
	} // ( ... )*
#line 756 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 2615 "DataflowTreeParser.cpp"
	currentAST = __currentAST183;
	_t = __t183;
	_t = _t->getNextSibling();
	loadUsageStatement_AST = RefMyAST(currentAST.root);
	returnAST = loadUsageStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::longestPrefixMatchStatement(RefMyAST _t) {
	RefMyAST longestPrefixMatchStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST longestPrefixMatchStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t188 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST188 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),LONGEST_PREFIX_MATCH);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp30_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp30_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp30_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp30_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp30_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop191;
		}
		
	}
	_loop191:;
	} // ( ... )*
#line 766 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 2696 "DataflowTreeParser.cpp"
	currentAST = __currentAST188;
	_t = __t188;
	_t = _t->getNextSibling();
	longestPrefixMatchStatement_AST = RefMyAST(currentAST.root);
	returnAST = longestPrefixMatchStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::md5Statement(RefMyAST _t) {
	RefMyAST md5Statement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST md5Statement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t193 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST193 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),MD5);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp31_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp31_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp31_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp31_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp31_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop196;
		}
		
	}
	_loop196:;
	} // ( ... )*
#line 776 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 2777 "DataflowTreeParser.cpp"
	currentAST = __currentAST193;
	_t = __t193;
	_t = _t->getNextSibling();
	md5Statement_AST = RefMyAST(currentAST.root);
	returnAST = md5Statement_AST;
	_retTree = _t;
}

void DataflowTreeParser::meterStatement(RefMyAST _t) {
	RefMyAST meterStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST meterStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t198 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST198 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),METER);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp32_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp32_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp32_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp32_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp32_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop201;
		}
		
	}
	_loop201:;
	} // ( ... )*
#line 786 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 2858 "DataflowTreeParser.cpp"
	currentAST = __currentAST198;
	_t = __t198;
	_t = _t->getNextSibling();
	meterStatement_AST = RefMyAST(currentAST.root);
	returnAST = meterStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::multiHashJoinStatement(RefMyAST _t) {
	RefMyAST multiHashJoinStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST multiHashJoinStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t203 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST203 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),MULTI_HASH_JOIN);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp33_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp33_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp33_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp33_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp33_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop206;
		}
		
	}
	_loop206:;
	} // ( ... )*
#line 796 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 2939 "DataflowTreeParser.cpp"
	currentAST = __currentAST203;
	_t = __t203;
	_t = _t->getNextSibling();
	multiHashJoinStatement_AST = RefMyAST(currentAST.root);
	returnAST = multiHashJoinStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::printStatement(RefMyAST _t) {
	RefMyAST printStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST printStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t208 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST208 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),PRINT);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp34_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp34_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp34_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp34_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp34_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop211;
		}
		
	}
	_loop211:;
	} // ( ... )*
#line 806 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 3020 "DataflowTreeParser.cpp"
	currentAST = __currentAST208;
	_t = __t208;
	_t = _t->getNextSibling();
	printStatement_AST = RefMyAST(currentAST.root);
	returnAST = printStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::projectionStatement(RefMyAST _t) {
	RefMyAST projectionStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST projectionStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t213 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST213 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),PROJECTION);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp35_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp35_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp35_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp35_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp35_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop216;
		}
		
	}
	_loop216:;
	} // ( ... )*
#line 816 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 3101 "DataflowTreeParser.cpp"
	currentAST = __currentAST213;
	_t = __t213;
	_t = _t->getNextSibling();
	projectionStatement_AST = RefMyAST(currentAST.root);
	returnAST = projectionStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::rangePartStatement(RefMyAST _t) {
	RefMyAST rangePartStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST rangePartStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t218 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST218 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),RANGEPART);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp36_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp36_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp36_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp36_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp36_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop221;
		}
		
	}
	_loop221:;
	} // ( ... )*
#line 826 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 3182 "DataflowTreeParser.cpp"
	currentAST = __currentAST218;
	_t = __t218;
	_t = _t->getNextSibling();
	rangePartStatement_AST = RefMyAST(currentAST.root);
	returnAST = rangePartStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::rateCalculationStatement(RefMyAST _t) {
	RefMyAST rateCalculationStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST rateCalculationStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t223 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST223 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),RATE_CALCULATION);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp37_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp37_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp37_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp37_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp37_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop226;
		}
		
	}
	_loop226:;
	} // ( ... )*
#line 836 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 3263 "DataflowTreeParser.cpp"
	currentAST = __currentAST223;
	_t = __t223;
	_t = _t->getNextSibling();
	rateCalculationStatement_AST = RefMyAST(currentAST.root);
	returnAST = rateCalculationStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::rateScheduleResolutionStatement(RefMyAST _t) {
	RefMyAST rateScheduleResolutionStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST rateScheduleResolutionStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t228 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST228 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),RATE_SCHEDULE_RESOLUTION);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp38_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp38_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp38_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp38_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp38_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop231;
		}
		
	}
	_loop231:;
	} // ( ... )*
#line 846 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 3344 "DataflowTreeParser.cpp"
	currentAST = __currentAST228;
	_t = __t228;
	_t = _t->getNextSibling();
	rateScheduleResolutionStatement_AST = RefMyAST(currentAST.root);
	returnAST = rateScheduleResolutionStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::renameStatement(RefMyAST _t) {
	RefMyAST renameStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST renameStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t233 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST233 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),RENAME);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp39_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp39_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp39_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp39_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp39_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop236;
		}
		
	}
	_loop236:;
	} // ( ... )*
#line 856 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 3425 "DataflowTreeParser.cpp"
	currentAST = __currentAST233;
	_t = __t233;
	_t = _t->getNextSibling();
	renameStatement_AST = RefMyAST(currentAST.root);
	returnAST = renameStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::rightMergeAntiSemiJoinStatement(RefMyAST _t) {
	RefMyAST rightMergeAntiSemiJoinStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST rightMergeAntiSemiJoinStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t238 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST238 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),RIGHT_MERGE_ANTI_SEMI_JOIN);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp40_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp40_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp40_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp40_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp40_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop241;
		}
		
	}
	_loop241:;
	} // ( ... )*
#line 867 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 3506 "DataflowTreeParser.cpp"
	currentAST = __currentAST238;
	_t = __t238;
	_t = _t->getNextSibling();
	rightMergeAntiSemiJoinStatement_AST = RefMyAST(currentAST.root);
	returnAST = rightMergeAntiSemiJoinStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::rightMergeSemiJoinStatement(RefMyAST _t) {
	RefMyAST rightMergeSemiJoinStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST rightMergeSemiJoinStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t243 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST243 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),RIGHT_MERGE_SEMI_JOIN);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp41_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp41_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp41_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp41_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp41_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop246;
		}
		
	}
	_loop246:;
	} // ( ... )*
#line 877 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 3587 "DataflowTreeParser.cpp"
	currentAST = __currentAST243;
	_t = __t243;
	_t = _t->getNextSibling();
	rightMergeSemiJoinStatement_AST = RefMyAST(currentAST.root);
	returnAST = rightMergeSemiJoinStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::rightOuterHashJoinStatement(RefMyAST _t) {
	RefMyAST rightOuterHashJoinStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST rightOuterHashJoinStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t248 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST248 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),RIGHT_OUTER_HASH_JOIN);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp42_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp42_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp42_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp42_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp42_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop251;
		}
		
	}
	_loop251:;
	} // ( ... )*
#line 887 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 3668 "DataflowTreeParser.cpp"
	currentAST = __currentAST248;
	_t = __t248;
	_t = _t->getNextSibling();
	rightOuterHashJoinStatement_AST = RefMyAST(currentAST.root);
	returnAST = rightOuterHashJoinStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::rightOuterMergeJoinStatement(RefMyAST _t) {
	RefMyAST rightOuterMergeJoinStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST rightOuterMergeJoinStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t253 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST253 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),RIGHT_OUTER_MERGE_JOIN);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp43_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp43_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp43_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp43_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp43_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop256;
		}
		
	}
	_loop256:;
	} // ( ... )*
#line 897 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 3749 "DataflowTreeParser.cpp"
	currentAST = __currentAST253;
	_t = __t253;
	_t = _t->getNextSibling();
	rightOuterMergeJoinStatement_AST = RefMyAST(currentAST.root);
	returnAST = rightOuterMergeJoinStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::selectStatement(RefMyAST _t) {
	RefMyAST selectStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST selectStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t83 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST83 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SELECT);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp44_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp44_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp44_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp44_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp44_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop86;
		}
		
	}
	_loop86:;
	} // ( ... )*
#line 553 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 3830 "DataflowTreeParser.cpp"
	currentAST = __currentAST83;
	_t = __t83;
	_t = _t->getNextSibling();
	selectStatement_AST = RefMyAST(currentAST.root);
	returnAST = selectStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::sequentialFileDeleteStatement(RefMyAST _t) {
	RefMyAST sequentialFileDeleteStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST sequentialFileDeleteStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t88 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST88 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SEQUENTIAL_FILE_DELETE);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp45_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp45_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp45_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp45_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp45_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop91;
		}
		
	}
	_loop91:;
	} // ( ... )*
#line 563 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 3911 "DataflowTreeParser.cpp"
	currentAST = __currentAST88;
	_t = __t88;
	_t = _t->getNextSibling();
	sequentialFileDeleteStatement_AST = RefMyAST(currentAST.root);
	returnAST = sequentialFileDeleteStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::sequentialFileOutputStatement(RefMyAST _t) {
	RefMyAST sequentialFileOutputStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST sequentialFileOutputStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t93 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST93 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SEQUENTIAL_FILE_OUTPUT);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp46_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp46_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp46_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp46_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp46_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop96;
		}
		
	}
	_loop96:;
	} // ( ... )*
#line 573 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 3992 "DataflowTreeParser.cpp"
	currentAST = __currentAST93;
	_t = __t93;
	_t = _t->getNextSibling();
	sequentialFileOutputStatement_AST = RefMyAST(currentAST.root);
	returnAST = sequentialFileOutputStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::sequentialFileRenameStatement(RefMyAST _t) {
	RefMyAST sequentialFileRenameStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST sequentialFileRenameStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t98 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST98 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SEQUENTIAL_FILE_RENAME);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp47_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp47_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp47_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp47_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp47_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop101;
		}
		
	}
	_loop101:;
	} // ( ... )*
#line 583 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 4073 "DataflowTreeParser.cpp"
	currentAST = __currentAST98;
	_t = __t98;
	_t = _t->getNextSibling();
	sequentialFileRenameStatement_AST = RefMyAST(currentAST.root);
	returnAST = sequentialFileRenameStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::sequentialFileScanStatement(RefMyAST _t) {
	RefMyAST sequentialFileScanStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST sequentialFileScanStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t103 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST103 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SEQUENTIAL_FILE_SCAN);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp48_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp48_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp48_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp48_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp48_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop106;
		}
		
	}
	_loop106:;
	} // ( ... )*
#line 593 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 4154 "DataflowTreeParser.cpp"
	currentAST = __currentAST103;
	_t = __t103;
	_t = _t->getNextSibling();
	sequentialFileScanStatement_AST = RefMyAST(currentAST.root);
	returnAST = sequentialFileScanStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::sessionSetBuilderStatement(RefMyAST _t) {
	RefMyAST sessionSetBuilderStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST sessionSetBuilderStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t258 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST258 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SESSION_SET_BUILDER);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp49_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp49_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp49_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp49_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp49_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop261;
		}
		
	}
	_loop261:;
	} // ( ... )*
#line 907 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 4235 "DataflowTreeParser.cpp"
	currentAST = __currentAST258;
	_t = __t258;
	_t = _t->getNextSibling();
	sessionSetBuilderStatement_AST = RefMyAST(currentAST.root);
	returnAST = sessionSetBuilderStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::sortStatement(RefMyAST _t) {
	RefMyAST sortStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST sortStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t263 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST263 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SORT);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp50_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp50_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp50_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp50_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp50_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop266;
		}
		
	}
	_loop266:;
	} // ( ... )*
#line 917 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 4316 "DataflowTreeParser.cpp"
	currentAST = __currentAST263;
	_t = __t263;
	_t = _t->getNextSibling();
	sortStatement_AST = RefMyAST(currentAST.root);
	returnAST = sortStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::sortGroupByStatement(RefMyAST _t) {
	RefMyAST sortGroupByStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST sortGroupByStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t268 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST268 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SORT_GROUP_BY);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp51_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp51_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp51_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp51_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp51_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop271;
		}
		
	}
	_loop271:;
	} // ( ... )*
#line 927 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 4397 "DataflowTreeParser.cpp"
	currentAST = __currentAST268;
	_t = __t268;
	_t = _t->getNextSibling();
	sortGroupByStatement_AST = RefMyAST(currentAST.root);
	returnAST = sortGroupByStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::sortMergeStatement(RefMyAST _t) {
	RefMyAST sortMergeStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST sortMergeStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t273 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST273 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SORTMERGE);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp52_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp52_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp52_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp52_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp52_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop276;
		}
		
	}
	_loop276:;
	} // ( ... )*
#line 937 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 4478 "DataflowTreeParser.cpp"
	currentAST = __currentAST273;
	_t = __t273;
	_t = _t->getNextSibling();
	sortMergeStatement_AST = RefMyAST(currentAST.root);
	returnAST = sortMergeStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::sortMergeCollStatement(RefMyAST _t) {
	RefMyAST sortMergeCollStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST sortMergeCollStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t278 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST278 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SORTMERGECOLL);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp53_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp53_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp53_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp53_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp53_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop281;
		}
		
	}
	_loop281:;
	} // ( ... )*
#line 947 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 4559 "DataflowTreeParser.cpp"
	currentAST = __currentAST278;
	_t = __t278;
	_t = _t->getNextSibling();
	sortMergeCollStatement_AST = RefMyAST(currentAST.root);
	returnAST = sortMergeCollStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::sortNestStatement(RefMyAST _t) {
	RefMyAST sortNestStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST sortNestStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t283 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST283 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SORT_NEST);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp54_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp54_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp54_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp54_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp54_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop286;
		}
		
	}
	_loop286:;
	} // ( ... )*
#line 957 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 4640 "DataflowTreeParser.cpp"
	currentAST = __currentAST283;
	_t = __t283;
	_t = _t->getNextSibling();
	sortNestStatement_AST = RefMyAST(currentAST.root);
	returnAST = sortNestStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::sortOrderAssertStatement(RefMyAST _t) {
	RefMyAST sortOrderAssertStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST sortOrderAssertStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t288 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST288 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SORT_ORDER_ASSERT);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp55_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp55_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp55_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp55_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp55_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop291;
		}
		
	}
	_loop291:;
	} // ( ... )*
#line 967 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 4721 "DataflowTreeParser.cpp"
	currentAST = __currentAST288;
	_t = __t288;
	_t = _t->getNextSibling();
	sortOrderAssertStatement_AST = RefMyAST(currentAST.root);
	returnAST = sortOrderAssertStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::sortRunningTotalStatement(RefMyAST _t) {
	RefMyAST sortRunningTotalStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST sortRunningTotalStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t293 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST293 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SORT_RUNNING_TOTAL);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp56_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp56_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp56_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp56_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp56_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop296;
		}
		
	}
	_loop296:;
	} // ( ... )*
#line 977 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 4802 "DataflowTreeParser.cpp"
	currentAST = __currentAST293;
	_t = __t293;
	_t = _t->getNextSibling();
	sortRunningTotalStatement_AST = RefMyAST(currentAST.root);
	returnAST = sortRunningTotalStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::sqlExecDirectStatement(RefMyAST _t) {
	RefMyAST sqlExecDirectStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST sqlExecDirectStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t298 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST298 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SQL_EXEC_DIRECT);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp57_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp57_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp57_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp57_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp57_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop301;
		}
		
	}
	_loop301:;
	} // ( ... )*
#line 987 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 4883 "DataflowTreeParser.cpp"
	currentAST = __currentAST298;
	_t = __t298;
	_t = _t->getNextSibling();
	sqlExecDirectStatement_AST = RefMyAST(currentAST.root);
	returnAST = sqlExecDirectStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::subscriptionResolutionStatement(RefMyAST _t) {
	RefMyAST subscriptionResolutionStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST subscriptionResolutionStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t303 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST303 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SUBSCRIPTION_RESOLUTION);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp58_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp58_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp58_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp58_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp58_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop306;
		}
		
	}
	_loop306:;
	} // ( ... )*
#line 997 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 4964 "DataflowTreeParser.cpp"
	currentAST = __currentAST303;
	_t = __t303;
	_t = _t->getNextSibling();
	subscriptionResolutionStatement_AST = RefMyAST(currentAST.root);
	returnAST = subscriptionResolutionStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::switchStatement(RefMyAST _t) {
	RefMyAST switchStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST switchStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t308 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST308 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SWITCH);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp59_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp59_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp59_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp59_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp59_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop311;
		}
		
	}
	_loop311:;
	} // ( ... )*
#line 1007 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 5045 "DataflowTreeParser.cpp"
	currentAST = __currentAST308;
	_t = __t308;
	_t = _t->getNextSibling();
	switchStatement_AST = RefMyAST(currentAST.root);
	returnAST = switchStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::taxwareStatement(RefMyAST _t) {
	RefMyAST taxwareStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST taxwareStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t313 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST313 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),TAXWARE);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp60_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp60_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp60_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp60_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp60_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop316;
		}
		
	}
	_loop316:;
	} // ( ... )*
#line 1017 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 5126 "DataflowTreeParser.cpp"
	currentAST = __currentAST313;
	_t = __t313;
	_t = _t->getNextSibling();
	taxwareStatement_AST = RefMyAST(currentAST.root);
	returnAST = taxwareStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::unionAllStatement(RefMyAST _t) {
	RefMyAST unionAllStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST unionAllStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t318 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST318 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),UNION_ALL);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp61_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp61_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp61_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp61_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp61_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop321;
		}
		
	}
	_loop321:;
	} // ( ... )*
#line 1027 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 5207 "DataflowTreeParser.cpp"
	currentAST = __currentAST318;
	_t = __t318;
	_t = _t->getNextSibling();
	unionAllStatement_AST = RefMyAST(currentAST.root);
	returnAST = unionAllStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::unnestStatement(RefMyAST _t) {
	RefMyAST unnestStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST unnestStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t323 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST323 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),UNNEST);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp62_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp62_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp62_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp62_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp62_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop326;
		}
		
	}
	_loop326:;
	} // ( ... )*
#line 1037 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 5288 "DataflowTreeParser.cpp"
	currentAST = __currentAST323;
	_t = __t323;
	_t = _t->getNextSibling();
	unnestStatement_AST = RefMyAST(currentAST.root);
	returnAST = unnestStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::unrollStatement(RefMyAST _t) {
	RefMyAST unrollStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST unrollStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t328 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST328 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),UNROLL);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp63_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp63_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp63_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp63_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp63_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop331;
		}
		
	}
	_loop331:;
	} // ( ... )*
#line 1047 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 5369 "DataflowTreeParser.cpp"
	currentAST = __currentAST328;
	_t = __t328;
	_t = _t->getNextSibling();
	unrollStatement_AST = RefMyAST(currentAST.root);
	returnAST = unrollStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::writeErrorStatement(RefMyAST _t) {
	RefMyAST writeErrorStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST writeErrorStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t333 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST333 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),WRITE_ERROR);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp64_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp64_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp64_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp64_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp64_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop336;
		}
		
	}
	_loop336:;
	} // ( ... )*
#line 1057 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 5450 "DataflowTreeParser.cpp"
	currentAST = __currentAST333;
	_t = __t333;
	_t = _t->getNextSibling();
	writeErrorStatement_AST = RefMyAST(currentAST.root);
	returnAST = writeErrorStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::writeProductViewStatement(RefMyAST _t) {
	RefMyAST writeProductViewStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST writeProductViewStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t338 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST338 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),WRITE_PRODUCT_VIEW);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp65_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp65_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp65_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp65_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp65_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		RefMyAST id2_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		id2_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id2));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id2_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop341;
		}
		
	}
	_loop341:;
	} // ( ... )*
#line 1067 "dataflow_analyze.g"
	
	addOperator(id);
	
#line 5531 "DataflowTreeParser.cpp"
	currentAST = __currentAST338;
	_t = __t338;
	_t = _t->getNextSibling();
	writeProductViewStatement_AST = RefMyAST(currentAST.root);
	returnAST = writeProductViewStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::edgeStatement(RefMyAST _t) {
	RefMyAST edgeStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST edgeStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1122 "dataflow_analyze.g"
	
	boost::tuple<std::wstring, int, int> lhs; 
	//     tuple<operator name, line number, column number>
	boost::tuple<std::wstring, boost::variant<int,std::wstring>, int, int> rhs;
	//     tuple<operator name, <port int, port name>, line number, column number>
	
#line 5552 "DataflowTreeParser.cpp"
	
	RefMyAST __t358 = _t;
	RefMyAST tmp66_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp66_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp66_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp66_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp66_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST358 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ARROW);
	_t = _t->getFirstChild();
	lhs=arrowOrRefStatement(_t);
	_t = _retTree;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case LBRACKET:
	{
		arrowArguments(_t);
		_t = _retTree;
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
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case LCURLY:
	{
		annotationArguments(_t);
		_t = _retTree;
		break;
	}
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	rhs=nodeRefStatement(_t);
	_t = _retTree;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
	currentAST = __currentAST358;
	_t = __t358;
	_t = _t->getNextSibling();
#line 1131 "dataflow_analyze.g"
	
	std::map<std::wstring,DataflowSymbol >::iterator leftIt(mActiveSymbolTable->find(lhs.get<0>()));
	std::map<std::wstring,DataflowSymbol >::iterator rightIt(mActiveSymbolTable->find(rhs.get<0>()));
	
	if (leftIt == mActiveSymbolTable->end())
	throw DataflowArrowUndefOperatorException(lhs.get<0>(),lhs.get<1>(), 
	lhs.get<2>(), mFilename);
	if (rightIt == mActiveSymbolTable->end())
	throw DataflowArrowUndefOperatorException(rhs.get<0>(),rhs.get<2>(), 
	rhs.get<3>(), mFilename);
	
	// Update the number of inputs and outputs.
	leftIt->second.NumOutputs += 1;
	rightIt->second.NumInputs += 1;
	
#line 5632 "DataflowTreeParser.cpp"
	edgeStatement_AST = RefMyAST(currentAST.root);
	returnAST = edgeStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::compositeParameters(RefMyAST _t) {
	RefMyAST compositeParameters_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST compositeParameters_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if (((_t->getType() >= INPUT && _t->getType() <= SUBLIST_DECL))) {
			compositeParameterSpec(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop21;
		}
		
	}
	_loop21:;
	} // ( ... )*
	compositeParameters_AST = RefMyAST(currentAST.root);
	returnAST = compositeParameters_AST;
	_retTree = _t;
}

void DataflowTreeParser::compositeBody(RefMyAST _t) {
	RefMyAST compositeBody_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST compositeBody_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	{
	dataFlowBody(_t);
	_t = _retTree;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
	}
	compositeBody_AST = RefMyAST(currentAST.root);
	returnAST = compositeBody_AST;
	_retTree = _t;
}

void DataflowTreeParser::compositeParameterSpec(RefMyAST _t) {
	RefMyAST compositeParameterSpec_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST compositeParameterSpec_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case INPUT:
	{
		compositeParameterInputSpec(_t);
		_t = _retTree;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		break;
	}
	case OUTPUT:
	{
		compositeParameterOutputSpec(_t);
		_t = _retTree;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		break;
	}
	case STRING_DECL:
	case INTEGER_DECL:
	case BOOLEAN_DECL:
	case SUBLIST_DECL:
	{
		compositeArgSpec(_t);
		_t = _retTree;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	compositeParameterSpec_AST = RefMyAST(currentAST.root);
	returnAST = compositeParameterSpec_AST;
	_retTree = _t;
}

void DataflowTreeParser::compositeParameterInputSpec(RefMyAST _t) {
	RefMyAST compositeParameterInputSpec_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST compositeParameterInputSpec_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST operatorId = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST operatorId_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t25 = _t;
	RefMyAST tmp67_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp67_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp67_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp67_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp67_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST25 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),INPUT);
	_t = _t->getFirstChild();
	RefMyAST tmp68_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp68_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp68_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp68_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp68_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),STRING_LITERAL);
	_t = _t->getNextSibling();
	RefMyAST tmp69_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp69_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp69_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp69_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp69_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),IS);
	_t = _t->getNextSibling();
	operatorId = _t;
	RefMyAST operatorId_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	operatorId_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(operatorId));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(operatorId_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
	_t = _t->getNextSibling();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case NUM_INT:
	{
		RefMyAST tmp70_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp70_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp70_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp70_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp70_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),NUM_INT);
		_t = _t->getNextSibling();
		break;
	}
	case STRING_LITERAL:
	{
		RefMyAST tmp71_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp71_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp71_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp71_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp71_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),STRING_LITERAL);
		_t = _t->getNextSibling();
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	currentAST = __currentAST25;
	_t = __t25;
	_t = _t->getNextSibling();
	compositeParameterInputSpec_AST = RefMyAST(currentAST.root);
	returnAST = compositeParameterInputSpec_AST;
	_retTree = _t;
}

void DataflowTreeParser::compositeParameterOutputSpec(RefMyAST _t) {
	RefMyAST compositeParameterOutputSpec_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST compositeParameterOutputSpec_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST operatorId = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST operatorId_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t28 = _t;
	RefMyAST tmp72_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp72_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp72_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp72_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp72_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST28 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),OUTPUT);
	_t = _t->getFirstChild();
	RefMyAST tmp73_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp73_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp73_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp73_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp73_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),STRING_LITERAL);
	_t = _t->getNextSibling();
	RefMyAST tmp74_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp74_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp74_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp74_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp74_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),IS);
	_t = _t->getNextSibling();
	operatorId = _t;
	RefMyAST operatorId_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	operatorId_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(operatorId));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(operatorId_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
	_t = _t->getNextSibling();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case NUM_INT:
	{
		RefMyAST tmp75_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp75_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp75_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp75_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp75_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),NUM_INT);
		_t = _t->getNextSibling();
		break;
	}
	case STRING_LITERAL:
	{
		RefMyAST tmp76_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp76_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp76_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp76_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp76_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),STRING_LITERAL);
		_t = _t->getNextSibling();
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	currentAST = __currentAST28;
	_t = __t28;
	_t = _t->getNextSibling();
	compositeParameterOutputSpec_AST = RefMyAST(currentAST.root);
	returnAST = compositeParameterOutputSpec_AST;
	_retTree = _t;
}

void DataflowTreeParser::compositeArgSpec(RefMyAST _t) {
	RefMyAST compositeArgSpec_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST compositeArgSpec_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case STRING_DECL:
	{
		compositeArgSpecString(_t);
		_t = _retTree;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		break;
	}
	case INTEGER_DECL:
	{
		compositeArgSpecInt(_t);
		_t = _retTree;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		break;
	}
	case BOOLEAN_DECL:
	{
		compositeArgSpecBool(_t);
		_t = _retTree;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		break;
	}
	case SUBLIST_DECL:
	{
		compositeArgSpecSublist(_t);
		_t = _retTree;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	compositeArgSpec_AST = RefMyAST(currentAST.root);
	returnAST = compositeArgSpec_AST;
	_retTree = _t;
}

void DataflowTreeParser::compositeArgSpecString(RefMyAST _t) {
	RefMyAST compositeArgSpecString_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST compositeArgSpecString_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t33 = _t;
	RefMyAST tmp77_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp77_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp77_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp77_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp77_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST33 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),STRING_DECL);
	_t = _t->getFirstChild();
	RefMyAST tmp78_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp78_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp78_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp78_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp78_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),DOLLAR_SIGN);
	_t = _t->getNextSibling();
	RefMyAST tmp79_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp79_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp79_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp79_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp79_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
	_t = _t->getNextSibling();
	currentAST = __currentAST33;
	_t = __t33;
	_t = _t->getNextSibling();
	compositeArgSpecString_AST = RefMyAST(currentAST.root);
	returnAST = compositeArgSpecString_AST;
	_retTree = _t;
}

void DataflowTreeParser::compositeArgSpecInt(RefMyAST _t) {
	RefMyAST compositeArgSpecInt_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST compositeArgSpecInt_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t35 = _t;
	RefMyAST tmp80_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp80_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp80_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp80_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp80_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST35 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),INTEGER_DECL);
	_t = _t->getFirstChild();
	RefMyAST tmp81_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp81_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp81_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp81_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp81_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),DOLLAR_SIGN);
	_t = _t->getNextSibling();
	RefMyAST tmp82_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp82_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp82_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp82_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp82_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
	_t = _t->getNextSibling();
	currentAST = __currentAST35;
	_t = __t35;
	_t = _t->getNextSibling();
	compositeArgSpecInt_AST = RefMyAST(currentAST.root);
	returnAST = compositeArgSpecInt_AST;
	_retTree = _t;
}

void DataflowTreeParser::compositeArgSpecBool(RefMyAST _t) {
	RefMyAST compositeArgSpecBool_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST compositeArgSpecBool_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t37 = _t;
	RefMyAST tmp83_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp83_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp83_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp83_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp83_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST37 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),BOOLEAN_DECL);
	_t = _t->getFirstChild();
	RefMyAST tmp84_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp84_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp84_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp84_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp84_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),DOLLAR_SIGN);
	_t = _t->getNextSibling();
	RefMyAST tmp85_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp85_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp85_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp85_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp85_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
	_t = _t->getNextSibling();
	currentAST = __currentAST37;
	_t = __t37;
	_t = _t->getNextSibling();
	compositeArgSpecBool_AST = RefMyAST(currentAST.root);
	returnAST = compositeArgSpecBool_AST;
	_retTree = _t;
}

void DataflowTreeParser::compositeArgSpecSublist(RefMyAST _t) {
	RefMyAST compositeArgSpecSublist_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST compositeArgSpecSublist_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t39 = _t;
	RefMyAST tmp86_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp86_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp86_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp86_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp86_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST39 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SUBLIST_DECL);
	_t = _t->getFirstChild();
	RefMyAST tmp87_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp87_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp87_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp87_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp87_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),DOLLAR_SIGN);
	_t = _t->getNextSibling();
	RefMyAST tmp88_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp88_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp88_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp88_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp88_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
	_t = _t->getNextSibling();
	currentAST = __currentAST39;
	_t = __t39;
	_t = _t->getNextSibling();
	compositeArgSpecSublist_AST = RefMyAST(currentAST.root);
	returnAST = compositeArgSpecSublist_AST;
	_retTree = _t;
}

void DataflowTreeParser::stepBody(RefMyAST _t) {
	RefMyAST stepBody_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST stepBody_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST tmp89_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp89_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp89_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp89_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp89_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),LPAREN);
	_t = _t->getNextSibling();
	{
	dataFlowBody(_t);
	_t = _retTree;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
	}
	RefMyAST tmp90_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp90_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp90_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp90_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp90_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),RPAREN);
	_t = _t->getNextSibling();
	stepBody_AST = RefMyAST(currentAST.root);
	returnAST = stepBody_AST;
	_retTree = _t;
}

void DataflowTreeParser::controlFlowBody(RefMyAST _t) {
	RefMyAST controlFlowBody_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST controlFlowBody_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case STEP:
		{
			stepStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		case IF_BEGIN:
		{
			ifStatement(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			break;
		}
		default:
		{
			goto _loop49;
		}
		}
	}
	_loop49:;
	} // ( ... )*
	controlFlowBody_AST = RefMyAST(currentAST.root);
	returnAST = controlFlowBody_AST;
	_retTree = _t;
}

void DataflowTreeParser::stepStatement(RefMyAST _t) {
	RefMyAST stepStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST stepStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	{
	id = _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),STEP);
	_t = _t->getNextSibling();
	}
	stepStatement_AST = RefMyAST(currentAST.root);
	returnAST = stepStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::ifStatement(RefMyAST _t) {
	RefMyAST ifStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST ifStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST tmp91_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp91_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp91_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp91_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp91_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),IF_BEGIN);
	_t = _t->getNextSibling();
	RefMyAST tmp92_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp92_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp92_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp92_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp92_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),LPAREN);
	_t = _t->getNextSibling();
	ifPredicate(_t);
	_t = _retTree;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
	RefMyAST tmp93_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp93_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp93_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp93_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp93_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),RPAREN);
	_t = _t->getNextSibling();
	RefMyAST tmp94_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp94_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp94_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp94_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp94_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),THEN);
	_t = _t->getNextSibling();
	controlFlowBody(_t);
	_t = _retTree;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case ELSE:
	{
		RefMyAST tmp95_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp95_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp95_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp95_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp95_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ELSE);
		_t = _t->getNextSibling();
		controlFlowBody(_t);
		_t = _retTree;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		break;
	}
	case IF_END:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	RefMyAST tmp96_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp96_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp96_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp96_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp96_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),IF_END);
	_t = _t->getNextSibling();
	ifStatement_AST = RefMyAST(currentAST.root);
	returnAST = ifStatement_AST;
	_retTree = _t;
}

void DataflowTreeParser::ifPredicate(RefMyAST _t) {
	RefMyAST ifPredicate_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST ifPredicate_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case BANG:
	{
		RefMyAST tmp97_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp97_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp97_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp97_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp97_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),BANG);
		_t = _t->getNextSibling();
		break;
	}
	case PREDICATE_DOES_FILE_EXIST:
	case PREDICATE_IS_FILE_EMPTY:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case PREDICATE_DOES_FILE_EXIST:
	{
		RefMyAST tmp98_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp98_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp98_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp98_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp98_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),PREDICATE_DOES_FILE_EXIST);
		_t = _t->getNextSibling();
		break;
	}
	case PREDICATE_IS_FILE_EMPTY:
	{
		RefMyAST tmp99_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp99_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp99_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp99_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp99_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),PREDICATE_IS_FILE_EMPTY);
		_t = _t->getNextSibling();
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	RefMyAST tmp100_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp100_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp100_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp100_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp100_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),LPAREN);
	_t = _t->getNextSibling();
	ifArgument(_t);
	_t = _retTree;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
	RefMyAST tmp101_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp101_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp101_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp101_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp101_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),RPAREN);
	_t = _t->getNextSibling();
	ifPredicate_AST = RefMyAST(currentAST.root);
	returnAST = ifPredicate_AST;
	_retTree = _t;
}

void DataflowTreeParser::ifArgument(RefMyAST _t) {
	RefMyAST ifArgument_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST ifArgument_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case STRING_LITERAL:
	{
		ifArgumentValue(_t);
		_t = _retTree;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		break;
	}
	case DOLLAR_SIGN:
	{
		argumentVariable(_t);
		_t = _retTree;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	ifArgument_AST = RefMyAST(currentAST.root);
	returnAST = ifArgument_AST;
	_retTree = _t;
}

void DataflowTreeParser::nodeArgument(RefMyAST _t) {
	RefMyAST nodeArgument_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST nodeArgument_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t348 = _t;
	RefMyAST tmp102_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp102_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp102_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp102_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp102_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST348 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_FALSE:
	case TK_TRUE:
	case NUM_DECIMAL:
	case NUM_FLOAT:
	case NUM_BIGINT:
	case STRING_LITERAL:
	case ID:
	case NUM_INT:
	{
		nodeArgumentValue(_t);
		_t = _retTree;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		break;
	}
	case DOLLAR_SIGN:
	{
		argumentVariable(_t);
		_t = _retTree;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	currentAST = __currentAST348;
	_t = __t348;
	_t = _t->getNextSibling();
	nodeArgument_AST = RefMyAST(currentAST.root);
	returnAST = nodeArgument_AST;
	_retTree = _t;
}

void DataflowTreeParser::nodeArgumentValue(RefMyAST _t) {
	RefMyAST nodeArgumentValue_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST nodeArgumentValue_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case NUM_INT:
	{
		RefMyAST tmp103_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp103_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp103_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp103_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp103_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),NUM_INT);
		_t = _t->getNextSibling();
		nodeArgumentValue_AST = RefMyAST(currentAST.root);
		break;
	}
	case NUM_BIGINT:
	{
		RefMyAST tmp104_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp104_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp104_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp104_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp104_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),NUM_BIGINT);
		_t = _t->getNextSibling();
		nodeArgumentValue_AST = RefMyAST(currentAST.root);
		break;
	}
	case NUM_FLOAT:
	{
		RefMyAST tmp105_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp105_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp105_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp105_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp105_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),NUM_FLOAT);
		_t = _t->getNextSibling();
		nodeArgumentValue_AST = RefMyAST(currentAST.root);
		break;
	}
	case NUM_DECIMAL:
	{
		RefMyAST tmp106_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp106_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp106_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp106_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp106_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),NUM_DECIMAL);
		_t = _t->getNextSibling();
		nodeArgumentValue_AST = RefMyAST(currentAST.root);
		break;
	}
	case STRING_LITERAL:
	{
		RefMyAST tmp107_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp107_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp107_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp107_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp107_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),STRING_LITERAL);
		_t = _t->getNextSibling();
		nodeArgumentValue_AST = RefMyAST(currentAST.root);
		break;
	}
	case TK_TRUE:
	{
		RefMyAST tmp108_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp108_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp108_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp108_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp108_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),TK_TRUE);
		_t = _t->getNextSibling();
		nodeArgumentValue_AST = RefMyAST(currentAST.root);
		break;
	}
	case TK_FALSE:
	{
		RefMyAST tmp109_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp109_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp109_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp109_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp109_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),TK_FALSE);
		_t = _t->getNextSibling();
		nodeArgumentValue_AST = RefMyAST(currentAST.root);
		break;
	}
	case ID:
	{
		{ // ( ... )+
		int _cnt352=0;
		for (;;) {
			if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
				_t = ASTNULL;
			if ((_t->getType() == ID)) {
				nodeArgument(_t);
				_t = _retTree;
				astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
			}
			else {
				if ( _cnt352>=1 ) { goto _loop352; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));}
			}
			
			_cnt352++;
		}
		_loop352:;
		}  // ( ... )+
		nodeArgumentValue_AST = RefMyAST(currentAST.root);
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	returnAST = nodeArgumentValue_AST;
	_retTree = _t;
}

void DataflowTreeParser::argumentVariable(RefMyAST _t) {
	RefMyAST argumentVariable_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST argumentVariable_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST tmp110_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp110_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp110_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp110_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp110_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),DOLLAR_SIGN);
	_t = _t->getNextSibling();
	RefMyAST tmp111_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp111_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp111_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp111_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp111_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
	_t = _t->getNextSibling();
	argumentVariable_AST = RefMyAST(currentAST.root);
	returnAST = argumentVariable_AST;
	_retTree = _t;
}

void DataflowTreeParser::ifArgumentValue(RefMyAST _t) {
	RefMyAST ifArgumentValue_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST ifArgumentValue_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST tmp112_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp112_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp112_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp112_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp112_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),STRING_LITERAL);
	_t = _t->getNextSibling();
	ifArgumentValue_AST = RefMyAST(currentAST.root);
	returnAST = ifArgumentValue_AST;
	_retTree = _t;
}

boost::tuple<std::wstring, int, int >  DataflowTreeParser::arrowOrRefStatement(RefMyAST _t) {
#line 1149 "dataflow_analyze.g"
	boost::tuple<std::wstring, int, int > t;
#line 6606 "DataflowTreeParser.cpp"
	RefMyAST arrowOrRefStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST arrowOrRefStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1149 "dataflow_analyze.g"
	
	boost::tuple<std::wstring, int, int> lhs;
	//     tuple<operator name, line number, column number>
	boost::tuple<std::wstring, boost::variant<int,std::wstring>, int, int> rhs;
	//     tuple<operator name, <port int, port name>, line number, column number>
	
#line 6618 "DataflowTreeParser.cpp"
	
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case ARROW:
	{
		RefMyAST __t362 = _t;
		RefMyAST tmp113_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		RefMyAST tmp113_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		tmp113_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		tmp113_AST_in = _t;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp113_AST));
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST362 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ARROW);
		_t = _t->getFirstChild();
		lhs=arrowOrRefStatement(_t);
		_t = _retTree;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		{
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case LBRACKET:
		{
			arrowArguments(_t);
			_t = _retTree;
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
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		}
		}
		}
		{
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case LCURLY:
		{
			annotationArguments(_t);
			_t = _retTree;
			break;
		}
		case ID:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
		}
		}
		}
		rhs=nodeRefStatement(_t);
		_t = _retTree;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		currentAST = __currentAST362;
		_t = __t362;
		_t = _t->getNextSibling();
#line 1158 "dataflow_analyze.g"
		
		t = boost::tuple<std::wstring, int, int >(rhs.get<0>(), rhs.get<2>(), rhs.get<3>());
		
		std::map<std::wstring,DataflowSymbol >::iterator leftIt(mActiveSymbolTable->find(lhs.get<0>()));
		std::map<std::wstring,DataflowSymbol >::iterator rightIt(mActiveSymbolTable->find(rhs.get<0>()));
		
		if (leftIt == mActiveSymbolTable->end())
		throw DataflowArrowUndefOperatorException(lhs.get<0>(), lhs.get<1>(), 
		lhs.get<2>(), mFilename);
		if (rightIt == mActiveSymbolTable->end())
		throw DataflowArrowUndefOperatorException(rhs.get<0>(), rhs.get<2>(), 
		rhs.get<3>(), mFilename);
		
		// Update the number of inputs and outputs.
		leftIt->second.NumOutputs += 1;
		rightIt->second.NumInputs += 1;
		
#line 6705 "DataflowTreeParser.cpp"
		arrowOrRefStatement_AST = RefMyAST(currentAST.root);
		break;
	}
	case ID:
	{
		rhs=nodeRefStatement(_t);
		_t = _retTree;
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
#line 1177 "dataflow_analyze.g"
		
		t = boost::tuple<std::wstring, int, int >(rhs.get<0>(), rhs.get<2>(), rhs.get<3>());
		
#line 6718 "DataflowTreeParser.cpp"
		arrowOrRefStatement_AST = RefMyAST(currentAST.root);
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	returnAST = arrowOrRefStatement_AST;
	_retTree = _t;
	return t;
}

void DataflowTreeParser::arrowArguments(RefMyAST _t) {
	RefMyAST arrowArguments_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST arrowArguments_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t366 = _t;
	RefMyAST tmp114_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp114_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp114_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp114_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp114_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST366 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),LBRACKET);
	_t = _t->getFirstChild();
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			nodeArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop368;
		}
		
	}
	_loop368:;
	} // ( ... )*
	currentAST = __currentAST366;
	_t = __t366;
	_t = _t->getNextSibling();
	arrowArguments_AST = RefMyAST(currentAST.root);
	returnAST = arrowArguments_AST;
	_retTree = _t;
}

void DataflowTreeParser::annotationArguments(RefMyAST _t) {
	RefMyAST annotationArguments_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST annotationArguments_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t370 = _t;
	RefMyAST tmp115_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp115_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp115_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp115_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp115_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST370 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),LCURLY);
	_t = _t->getFirstChild();
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			annotationArgument(_t);
			_t = _retTree;
			astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(returnAST));
		}
		else {
			goto _loop372;
		}
		
	}
	_loop372:;
	} // ( ... )*
	currentAST = __currentAST370;
	_t = __t370;
	_t = _t->getNextSibling();
	annotationArguments_AST = RefMyAST(currentAST.root);
	returnAST = annotationArguments_AST;
	_retTree = _t;
}

boost::tuple<std::wstring, boost::variant<int,std::wstring>, int, int >  DataflowTreeParser::nodeRefStatement(RefMyAST _t) {
#line 1198 "dataflow_analyze.g"
	boost::tuple<std::wstring, boost::variant<int,std::wstring>, int, int > t;
#line 6817 "DataflowTreeParser.cpp"
	RefMyAST nodeRefStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST nodeRefStatement_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST i = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST i_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST s = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST s_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1198 "dataflow_analyze.g"
	
	std::wstring nodeName;
	int portIndex(0);
	std::wstring portName;
	int lineNumber;
	int columnNumber;
	
#line 6836 "DataflowTreeParser.cpp"
	
	RefMyAST __t376 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	id_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(id));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(id_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST376 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
	_t = _t->getFirstChild();
#line 1208 "dataflow_analyze.g"
	
	nodeName = ASCIIToWide(id_AST->getText());
	lineNumber = id->getLine();
	columnNumber = id->getColumn();
	
#line 6854 "DataflowTreeParser.cpp"
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case NUM_INT:
	{
		i = _t;
		RefMyAST i_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		i_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(i));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(i_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),NUM_INT);
		_t = _t->getNextSibling();
#line 1214 "dataflow_analyze.g"
		
		portIndex = boost::lexical_cast<int>(i_AST->getText()); 
		
#line 6871 "DataflowTreeParser.cpp"
		break;
	}
	case STRING_LITERAL:
	{
		s = _t;
		RefMyAST s_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
		s_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(s));
		astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(s_AST));
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),STRING_LITERAL);
		_t = _t->getNextSibling();
#line 1219 "dataflow_analyze.g"
		
		portName = ASCIIToWide(s_AST->getText().substr(1, s_AST->getText().size()-2));
		
#line 6886 "DataflowTreeParser.cpp"
		break;
	}
	case 3:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	currentAST = __currentAST376;
	_t = __t376;
	_t = _t->getNextSibling();
#line 1224 "dataflow_analyze.g"
	
	if (portName.size() != 0)
	{
	t = boost::tuple<std::wstring, boost::variant<int,std::wstring>, int, int >(nodeName, portName, lineNumber, columnNumber);
	}
	else
	{
	t = boost::tuple<std::wstring, boost::variant<int,std::wstring>, int, int >(nodeName, portIndex, lineNumber, columnNumber);
	}
	
#line 6913 "DataflowTreeParser.cpp"
	nodeRefStatement_AST = RefMyAST(currentAST.root);
	returnAST = nodeRefStatement_AST;
	_retTree = _t;
	return t;
}

void DataflowTreeParser::annotationArgument(RefMyAST _t) {
	RefMyAST annotationArgument_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	returnAST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	RefMyAST annotationArgument_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t374 = _t;
	RefMyAST tmp116_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp116_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp116_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp116_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp116_AST));
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST374 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
	_t = _t->getFirstChild();
	RefMyAST tmp117_AST = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST tmp117_AST_in = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	tmp117_AST = astFactory->create(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	tmp117_AST_in = _t;
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(tmp117_AST));
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
	_t = _t->getNextSibling();
	currentAST = __currentAST374;
	_t = __t374;
	_t = _t->getNextSibling();
	annotationArgument_AST = RefMyAST(currentAST.root);
	returnAST = annotationArgument_AST;
	_retTree = _t;
}

void DataflowTreeParser::initializeASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& factory )
{
	factory.setMaxNodeType(126);
}
const char* DataflowTreeParser::tokenNames[] = {
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
	"DELAYED_GENERATE",
	0
};

const unsigned long DataflowTreeParser::_tokenSet_0_data_[] = { 75497474UL, 0UL, 4294967294UL, 872153087UL, 0UL, 0UL, 0UL, 0UL };
// EOF "steps" ARROW ACCOUNT_RESOLUTION BROADCAST COLL COMPOSITE COPY DEVNULL 
// EXPORT EXPORT_QUEUE EXPR FILTER GENERATE GROUP_BY HASHPART HASH_RUNNING_TOTAL 
// ID_GENERATOR IMPORT IMPORT_QUEUE INNER_HASH_JOIN INNER_MERGE_JOIN INSERT 
// LOAD_ERROR LOAD_USAGE LONGEST_PREFIX_MATCH MD5 METER MULTI_HASH_JOIN 
// PRINT PROJECTION RANGEPART RATE_CALCULATION RATE_SCHEDULE_RESOLUTION 
// RENAME RIGHT_MERGE_ANTI_SEMI_JOIN RIGHT_MERGE_SEMI_JOIN RIGHT_OUTER_HASH_JOIN 
// RIGHT_OUTER_MERGE_JOIN SELECT SEQUENTIAL_FILE_DELETE SEQUENTIAL_FILE_OUTPUT 
// SEQUENTIAL_FILE_RENAME SEQUENTIAL_FILE_SCAN SESSION_SET_BUILDER SORT 
// SORT_GROUP_BY SORTMERGE SORTMERGECOLL SORT_NEST SORT_ORDER_ASSERT SORT_RUNNING_TOTAL 
// SUBSCRIPTION_RESOLUTION SQL_EXEC_DIRECT SWITCH TAXWARE UNION_ALL UNNEST 
// UNROLL WRITE_ERROR WRITE_PRODUCT_VIEW 
const ANTLR_USE_NAMESPACE(antlr)BitSet DataflowTreeParser::_tokenSet_0(_tokenSet_0_data_,8);


