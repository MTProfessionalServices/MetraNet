/* $ANTLR 2.7.6 (2005-12-22): "dataflow_generate.g" -> "DataflowTreeGenerator.cpp"$ */
#include "DataflowTreeGenerator.hpp"
#include <antlr/Token.hpp>
#include <antlr/AST.hpp>
#include <antlr/NoViableAltException.hpp>
#include <antlr/MismatchedTokenException.hpp>
#include <antlr/SemanticException.hpp>
#include <antlr/BitSet.hpp>
#line 1 "dataflow_generate.g"
#line 11 "DataflowTreeGenerator.cpp"
DataflowTreeGenerator::DataflowTreeGenerator()
	: ANTLR_USE_NAMESPACE(antlr)TreeParser() {
}

void DataflowTreeGenerator::program(RefMyAST _t) {
	RefMyAST program_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	
	{
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == INCLUDE_COMPOSITE)) {
			includeCompositeStatement(_t);
			_t = _retTree;
			{
			if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
				_t = ASTNULL;
			switch ( _t->getType()) {
			case SEMI:
			{
				RefMyAST tmp1_AST_in = _t;
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
			case DELAYED_GENERATE:
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
			break;
		}
		case STEP_DECL:
		{
			stepDeclaration(_t);
			_t = _retTree;
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
	}
	else if ((_t->getType() == ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE)) {
	}
	else {
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	
	}
	}
	RefMyAST tmp2_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE);
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::includeCompositeStatement(RefMyAST _t) {
	RefMyAST includeCompositeStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST filename = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	{
	RefMyAST tmp3_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),INCLUDE_COMPOSITE);
	_t = _t->getNextSibling();
	filename = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),STRING_LITERAL);
	_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void DataflowTreeGenerator::compositeDeclaration(RefMyAST _t) {
	RefMyAST compositeDeclaration_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST compositeNameId = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 653 "dataflow_generate.g"
	
	std::map<std::wstring, DataflowSymbol> *compositeSymbolTable;
	
	// We create a new design plan for the composite and make this the
	// active plan.  We will later store this plan as part of the 
	// composite definition.
	DesignTimePlan* compositePlan = new DesignTimePlan();
	mActivePlan = compositePlan;
	
#line 193 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t18 = _t;
	RefMyAST tmp4_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),OPERATOR);
	_t = _t->getFirstChild();
	compositeNameId = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
	_t = _t->getNextSibling();
#line 666 "dataflow_generate.g"
	
	std::wstring wCompositeName = ASCIIToWide(compositeNameId->getText());
	compositeSymbolTable = 
	mCompositeDictionary->getSymbolTable(wCompositeName);
	
	// All operators in the composite have already been stored
	// in this table during the dataflow_analyze.g stage.
	mActiveSymbolTable = compositeSymbolTable;
	mActiveCompositeName = wCompositeName;
	mIsCompositeBeingParsed = true;
	
#line 214 "DataflowTreeGenerator.cpp"
	compositeParameters(_t);
	_t = _retTree;
	compositeBody(_t);
	_t = _retTree;
	_t = __t18;
	_t = _t->getNextSibling();
#line 679 "dataflow_generate.g"
	
	// We reach this point when the composite definition has finished parsing.
	// Set the name of the plan to match the name of the composite.
	compositePlan->setName(ASCIIToWide(compositeNameId->getText()));
	
	// Set the plan of the composite.
	// Ownership of the plan is given to the composite definition.
	// This also performs any needed final bookkeeping of the definition.
	mCompositeDictionary->setDesignTimePlan(ASCIIToWide(compositeNameId->getText()),
	compositePlan);
	
	// We are done preparing the composite declaration.
	// We now assume we are processing script.
	mActiveSymbolTable = mScriptSymbolTable;
	mActivePlan = mScriptPlan;
	mActiveCompositeName = L"";
	mIsCompositeBeingParsed = false;
	
#line 240 "DataflowTreeGenerator.cpp"
	_retTree = _t;
}

void DataflowTreeGenerator::stepDeclaration(RefMyAST _t) {
	RefMyAST stepDeclaration_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t43 = _t;
	RefMyAST tmp5_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),STEP_DECL);
	_t = _t->getFirstChild();
	id = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
	_t = _t->getNextSibling();
#line 755 "dataflow_generate.g"
	
	mActiveSymbolTable = (*mMapOfSymbolTables)[ASCIIToWide(id->getText())];
	mActivePlan = new DesignTimePlan();
	mActivePlan->setName(ASCIIToWide(id->getText()));
	mIsCompositeBeingParsed = false;
	
#line 262 "DataflowTreeGenerator.cpp"
	stepBody(_t);
	_t = _retTree;
	_t = __t43;
	_t = _t->getNextSibling();
#line 762 "dataflow_generate.g"
	
	mWorkflow->setDesignTimePlan(ASCIIToWide(id->getText()), mActivePlan);
	mActiveSymbolTable = mScriptSymbolTable;
	mActivePlan = mScriptPlan;
	
#line 273 "DataflowTreeGenerator.cpp"
	_retTree = _t;
}

void DataflowTreeGenerator::mainScript(RefMyAST _t) {
	RefMyAST mainScript_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
#line 514 "dataflow_generate.g"
	
	mActiveCompositeName = L"";
	mIsCompositeBeingParsed = false;
	
#line 284 "DataflowTreeGenerator.cpp"
	
	{
	dataFlowBody(_t);
	_t = _retTree;
	}
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case STEPS_BEGIN:
	{
		controlFlow(_t);
		_t = _retTree;
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
	_retTree = _t;
}

void DataflowTreeGenerator::dataFlowBody(RefMyAST _t) {
	RefMyAST dataFlowBody_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case ACCOUNT_RESOLUTION:
		{
			accountResolutionStatement(_t);
			_t = _retTree;
			break;
		}
		case BROADCAST:
		{
			broadcastStatement(_t);
			_t = _retTree;
			break;
		}
		case COLL:
		{
			collStatement(_t);
			_t = _retTree;
			break;
		}
		case COMPOSITE:
		{
			compositeStatement(_t);
			_t = _retTree;
			break;
		}
		case COPY:
		{
			copyStatement(_t);
			_t = _retTree;
			break;
		}
		case DEVNULL:
		{
			devNullStatement(_t);
			_t = _retTree;
			break;
		}
		case EXPORT:
		{
			exportStatement(_t);
			_t = _retTree;
			break;
		}
		case EXPORT_QUEUE:
		{
			exportQueueStatement(_t);
			_t = _retTree;
			break;
		}
		case EXPR:
		{
			exprStatement(_t);
			_t = _retTree;
			break;
		}
		case FILTER:
		{
			filterStatement(_t);
			_t = _retTree;
			break;
		}
		case DELAYED_GENERATE:
		{
			delayedGenerateStatement(_t);
			_t = _retTree;
			break;
		}
		case GROUP_BY:
		{
			groupByStatement(_t);
			_t = _retTree;
			break;
		}
		case HASHPART:
		{
			hashPartStatement(_t);
			_t = _retTree;
			break;
		}
		case HASH_RUNNING_TOTAL:
		{
			hashRunningTotalStatement(_t);
			_t = _retTree;
			break;
		}
		case ID_GENERATOR:
		{
			idGeneratorStatement(_t);
			_t = _retTree;
			break;
		}
		case IMPORT:
		{
			importStatement(_t);
			_t = _retTree;
			break;
		}
		case IMPORT_QUEUE:
		{
			importQueueStatement(_t);
			_t = _retTree;
			break;
		}
		case INNER_HASH_JOIN:
		{
			innerHashJoinStatement(_t);
			_t = _retTree;
			break;
		}
		case INNER_MERGE_JOIN:
		{
			innerMergeJoinStatement(_t);
			_t = _retTree;
			break;
		}
		case INSERT:
		{
			insertStatement(_t);
			_t = _retTree;
			break;
		}
		case LOAD_ERROR:
		{
			loadErrorStatement(_t);
			_t = _retTree;
			break;
		}
		case LOAD_USAGE:
		{
			loadUsageStatement(_t);
			_t = _retTree;
			break;
		}
		case LONGEST_PREFIX_MATCH:
		{
			longestPrefixMatchStatement(_t);
			_t = _retTree;
			break;
		}
		case MD5:
		{
			md5Statement(_t);
			_t = _retTree;
			break;
		}
		case METER:
		{
			meterStatement(_t);
			_t = _retTree;
			break;
		}
		case MULTI_HASH_JOIN:
		{
			multiHashJoinStatement(_t);
			_t = _retTree;
			break;
		}
		case PRINT:
		{
			printStatement(_t);
			_t = _retTree;
			break;
		}
		case PROJECTION:
		{
			projectionStatement(_t);
			_t = _retTree;
			break;
		}
		case RANGEPART:
		{
			rangePartStatement(_t);
			_t = _retTree;
			break;
		}
		case RATE_CALCULATION:
		{
			rateCalculationStatement(_t);
			_t = _retTree;
			break;
		}
		case RATE_SCHEDULE_RESOLUTION:
		{
			rateScheduleResolutionStatement(_t);
			_t = _retTree;
			break;
		}
		case RENAME:
		{
			renameStatement(_t);
			_t = _retTree;
			break;
		}
		case RIGHT_MERGE_ANTI_SEMI_JOIN:
		{
			rightMergeAntiSemiJoinStatement(_t);
			_t = _retTree;
			break;
		}
		case RIGHT_MERGE_SEMI_JOIN:
		{
			rightMergeSemiJoinStatement(_t);
			_t = _retTree;
			break;
		}
		case RIGHT_OUTER_HASH_JOIN:
		{
			rightOuterHashJoinStatement(_t);
			_t = _retTree;
			break;
		}
		case RIGHT_OUTER_MERGE_JOIN:
		{
			rightOuterMergeJoinStatement(_t);
			_t = _retTree;
			break;
		}
		case SELECT:
		{
			selectStatement(_t);
			_t = _retTree;
			break;
		}
		case SEQUENTIAL_FILE_DELETE:
		{
			sequentialFileDeleteStatement(_t);
			_t = _retTree;
			break;
		}
		case SEQUENTIAL_FILE_OUTPUT:
		{
			sequentialFileOutputStatement(_t);
			_t = _retTree;
			break;
		}
		case SEQUENTIAL_FILE_RENAME:
		{
			sequentialFileRenameStatement(_t);
			_t = _retTree;
			break;
		}
		case SEQUENTIAL_FILE_SCAN:
		{
			sequentialFileScanStatement(_t);
			_t = _retTree;
			break;
		}
		case SESSION_SET_BUILDER:
		{
			sessionSetBuilderStatement(_t);
			_t = _retTree;
			break;
		}
		case SORT:
		{
			sortStatement(_t);
			_t = _retTree;
			break;
		}
		case SORT_GROUP_BY:
		{
			sortGroupByStatement(_t);
			_t = _retTree;
			break;
		}
		case SORTMERGE:
		{
			sortMergeStatement(_t);
			_t = _retTree;
			break;
		}
		case SORTMERGECOLL:
		{
			sortMergeCollStatement(_t);
			_t = _retTree;
			break;
		}
		case SORT_NEST:
		{
			sortNestStatement(_t);
			_t = _retTree;
			break;
		}
		case SORT_ORDER_ASSERT:
		{
			sortOrderAssertStatement(_t);
			_t = _retTree;
			break;
		}
		case SORT_RUNNING_TOTAL:
		{
			sortRunningTotalStatement(_t);
			_t = _retTree;
			break;
		}
		case SQL_EXEC_DIRECT:
		{
			sqlExecDirectStatement(_t);
			_t = _retTree;
			break;
		}
		case SUBSCRIPTION_RESOLUTION:
		{
			subscriptionResolutionStatement(_t);
			_t = _retTree;
			break;
		}
		case SWITCH:
		{
			switchStatement(_t);
			_t = _retTree;
			break;
		}
		case TAXWARE:
		{
			taxwareStatement(_t);
			_t = _retTree;
			break;
		}
		case UNION_ALL:
		{
			unionAllStatement(_t);
			_t = _retTree;
			break;
		}
		case UNNEST:
		{
			unnestStatement(_t);
			_t = _retTree;
			break;
		}
		case UNROLL:
		{
			unrollStatement(_t);
			_t = _retTree;
			break;
		}
		case WRITE_ERROR:
		{
			writeErrorStatement(_t);
			_t = _retTree;
			break;
		}
		case WRITE_PRODUCT_VIEW:
		{
			writeProductViewStatement(_t);
			_t = _retTree;
			break;
		}
		case ARROW:
		{
			edgeStatement(_t);
			_t = _retTree;
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
	_retTree = _t;
}

void DataflowTreeGenerator::controlFlow(RefMyAST _t) {
	RefMyAST controlFlow_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	
	RefMyAST tmp6_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),STEPS_BEGIN);
	_t = _t->getNextSibling();
	controlFlowBody(_t);
	_t = _retTree;
	RefMyAST tmp7_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),STEPS_END);
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::accountResolutionStatement(RefMyAST _t) {
	RefMyAST accountResolutionStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1019 "dataflow_generate.g"
	
	DesignTimeAccountResolution * op(NULL);
	
#line 708 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t70 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ACCOUNT_RESOLUTION);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp8_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1025 "dataflow_generate.g"
	
	op = new DesignTimeAccountResolution(ASCIIToWide(id->getText()));
	addToSymbolTable(op, id);
	
#line 744 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop73;
		}
		
	}
	_loop73:;
	} // ( ... )*
#line 1030 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	op->expand(*mScriptInterpreter);
	
#line 765 "DataflowTreeGenerator.cpp"
	_t = __t70;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::broadcastStatement(RefMyAST _t) {
	RefMyAST broadcastStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1037 "dataflow_generate.g"
	
	DesignTimeBroadcastPartitioner * op(NULL);
	
#line 779 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t75 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),BROADCAST);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp9_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1043 "dataflow_generate.g"
	
	op = new DesignTimeBroadcastPartitioner();
	addToSymbolTable(op, id);
	
#line 815 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop78;
		}
		
	}
	_loop78:;
	} // ( ... )*
#line 1048 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 835 "DataflowTreeGenerator.cpp"
	_t = __t75;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::collStatement(RefMyAST _t) {
	RefMyAST collStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1054 "dataflow_generate.g"
	
	DesignTimeNondeterministicCollector * op(NULL);
	
#line 849 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t80 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLL);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp10_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1060 "dataflow_generate.g"
	
	op = new DesignTimeNondeterministicCollector();
	addToSymbolTable(op, id);
	
#line 885 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop83;
		}
		
	}
	_loop83:;
	} // ( ... )*
#line 1065 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 905 "DataflowTreeGenerator.cpp"
	_t = __t80;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::compositeStatement(RefMyAST _t) {
	RefMyAST compositeStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 2256 "dataflow_generate.g"
	
	DesignTimeComposite * op(NULL);
	std::wstring defnName;
	const CompositeDefinition* definition;
	
#line 921 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t367 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COMPOSITE);
	_t = _t->getFirstChild();
#line 2264 "dataflow_generate.g"
	
	defnName = ASCIIToWide(id->getText());
	
#line 931 "DataflowTreeGenerator.cpp"
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp11_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
#line 2268 "dataflow_generate.g"
		
		defnName = ASCIIToWide(id2->getText());
		
#line 948 "DataflowTreeGenerator.cpp"
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
#line 2272 "dataflow_generate.g"
	
	definition = mCompositeDictionary->getDefinition(defnName.c_str());
	
	// We should never encounter undefined composite at this point.
	if (definition == NULL)
	{
	reportInternalError(L"Encountered unknown composite.", id);
	}
	
	op = new DesignTimeComposite(
	definition,
	(*mActiveSymbolTable)[ASCIIToWide(id->getText())].NumInputs,
	(*mActiveSymbolTable)[ASCIIToWide(id->getText())].NumOutputs);
	addToSymbolTable(op, id);      
	
#line 978 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			compositeArgument(_t,definition, op);
			_t = _retTree;
		}
		else {
			goto _loop370;
		}
		
	}
	_loop370:;
	} // ( ... )*
#line 2288 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 998 "DataflowTreeGenerator.cpp"
	_t = __t367;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::copyStatement(RefMyAST _t) {
	RefMyAST copyStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1071 "dataflow_generate.g"
	
	DesignTimeCopy * op(NULL);
	
#line 1012 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t85 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COPY);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp12_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1077 "dataflow_generate.g"
	
	op = new DesignTimeCopy((*mActiveSymbolTable)[ASCIIToWide(id->getText())].NumOutputs);
	addToSymbolTable(op, id);
	
#line 1048 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop88;
		}
		
	}
	_loop88:;
	} // ( ... )*
#line 1082 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 1068 "DataflowTreeGenerator.cpp"
	_t = __t85;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::devNullStatement(RefMyAST _t) {
	RefMyAST devNullStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1088 "dataflow_generate.g"
	
	DesignTimeDevNull * op(NULL);
	
#line 1082 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t90 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),DEVNULL);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp13_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1094 "dataflow_generate.g"
	
	op = new DesignTimeDevNull();
	addToSymbolTable(op, id);
	
#line 1118 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop93;
		}
		
	}
	_loop93:;
	} // ( ... )*
#line 1099 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 1138 "DataflowTreeGenerator.cpp"
	_t = __t90;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::exportStatement(RefMyAST _t) {
	RefMyAST exportStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1122 "dataflow_generate.g"
	
	DesignTimeRecordExporter* op(NULL);
	
#line 1152 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t100 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),EXPORT);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp14_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1128 "dataflow_generate.g"
	
	op = new DesignTimeRecordExporter();
	addToSymbolTable(op, id);
	
#line 1188 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop103;
		}
		
	}
	_loop103:;
	} // ( ... )*
#line 1133 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 1208 "DataflowTreeGenerator.cpp"
	_t = __t100;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::exportQueueStatement(RefMyAST _t) {
	RefMyAST exportQueueStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1139 "dataflow_generate.g"
	
	DesignTimeQueueExport* op(NULL);
	
#line 1222 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t105 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),EXPORT_QUEUE);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp15_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1145 "dataflow_generate.g"
	
	op = new DesignTimeQueueExport();
	addToSymbolTable(op, id);
	
#line 1258 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop108;
		}
		
	}
	_loop108:;
	} // ( ... )*
#line 1150 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 1278 "DataflowTreeGenerator.cpp"
	_t = __t105;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::exprStatement(RefMyAST _t) {
	RefMyAST exprStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1156 "dataflow_generate.g"
	
	DesignTimeExpression * op(NULL);
	
#line 1292 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t110 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),EXPR);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp16_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1162 "dataflow_generate.g"
	
	op = new DesignTimeExpression();
	addToSymbolTable(op, id);
	
#line 1328 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop113;
		}
		
	}
	_loop113:;
	} // ( ... )*
#line 1167 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 1348 "DataflowTreeGenerator.cpp"
	_t = __t110;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::filterStatement(RefMyAST _t) {
	RefMyAST filterStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1173 "dataflow_generate.g"
	
	DesignTimeFilter * op(NULL);
	
#line 1362 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t115 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),FILTER);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp17_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1179 "dataflow_generate.g"
	
	op = new DesignTimeFilter();
	addToSymbolTable(op, id);
	
#line 1398 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop118;
		}
		
	}
	_loop118:;
	} // ( ... )*
#line 1184 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 1418 "DataflowTreeGenerator.cpp"
	_t = __t115;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::delayedGenerateStatement(RefMyAST _t) {
	RefMyAST delayedGenerateStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST g = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t120 = _t;
	RefMyAST tmp18_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),DELAYED_GENERATE);
	_t = _t->getFirstChild();
	g = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),GENERATE);
	_t = _t->getNextSibling();
	_t = __t120;
	_t = _t->getNextSibling();
#line 1193 "dataflow_generate.g"
	
	if ((*mActiveSymbolTable)[ASCIIToWide(g->getText())].NumInputs == 0)
	{
	generateStatement(g);
	}
	else
	{
	expressionGenerateStatement(g);
	}
	
#line 1448 "DataflowTreeGenerator.cpp"
	_retTree = _t;
}

void DataflowTreeGenerator::groupByStatement(RefMyAST _t) {
	RefMyAST groupByStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1239 "dataflow_generate.g"
	
	DesignTimeHashGroupBy * op(NULL);
	
#line 1460 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t132 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),GROUP_BY);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp19_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1245 "dataflow_generate.g"
	
	op = new DesignTimeHashGroupBy((*mActiveSymbolTable)[ASCIIToWide(id->getText())].NumInputs);
	addToSymbolTable(op, id);
	
#line 1496 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop135;
		}
		
	}
	_loop135:;
	} // ( ... )*
#line 1250 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 1516 "DataflowTreeGenerator.cpp"
	_t = __t132;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::hashPartStatement(RefMyAST _t) {
	RefMyAST hashPartStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1256 "dataflow_generate.g"
	
	DesignTimeHashPartitioner * op(NULL);
	
#line 1530 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t137 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),HASHPART);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp20_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1262 "dataflow_generate.g"
	
	op = new DesignTimeHashPartitioner();
	addToSymbolTable(op, id);
	
#line 1566 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop140;
		}
		
	}
	_loop140:;
	} // ( ... )*
#line 1267 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 1586 "DataflowTreeGenerator.cpp"
	_t = __t137;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::hashRunningTotalStatement(RefMyAST _t) {
	RefMyAST hashRunningTotalStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1273 "dataflow_generate.g"
	
	DesignTimeHashRunningAggregate * op(NULL);
	
#line 1600 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t142 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),HASH_RUNNING_TOTAL);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp21_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1279 "dataflow_generate.g"
	
	op = new DesignTimeHashRunningAggregate((*mActiveSymbolTable)[ASCIIToWide(id->getText())].NumInputs);
	addToSymbolTable(op, id);
	
#line 1636 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop145;
		}
		
	}
	_loop145:;
	} // ( ... )*
#line 1284 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 1656 "DataflowTreeGenerator.cpp"
	_t = __t142;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::idGeneratorStatement(RefMyAST _t) {
	RefMyAST idGeneratorStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1290 "dataflow_generate.g"
	
	DesignTimeIdGenerator* op(NULL);
	
#line 1670 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t147 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID_GENERATOR);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp22_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1296 "dataflow_generate.g"
	
	op = new DesignTimeIdGenerator();
	addToSymbolTable(op, id);
	
#line 1706 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop150;
		}
		
	}
	_loop150:;
	} // ( ... )*
#line 1301 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 1726 "DataflowTreeGenerator.cpp"
	_t = __t147;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::importStatement(RefMyAST _t) {
	RefMyAST importStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1307 "dataflow_generate.g"
	
	DesignTimeRecordImporter* op(NULL);
	
#line 1740 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t152 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),IMPORT);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp23_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1313 "dataflow_generate.g"
	
	op = new DesignTimeRecordImporter();
	addToSymbolTable(op, id);
	
#line 1776 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop155;
		}
		
	}
	_loop155:;
	} // ( ... )*
#line 1318 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 1796 "DataflowTreeGenerator.cpp"
	_t = __t152;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::importQueueStatement(RefMyAST _t) {
	RefMyAST importQueueStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1324 "dataflow_generate.g"
	
	DesignTimeQueueImport* op(NULL);
	
#line 1810 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t157 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),IMPORT_QUEUE);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp24_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1330 "dataflow_generate.g"
	
	op = new DesignTimeQueueImport();
	addToSymbolTable(op, id);
	
#line 1846 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop160;
		}
		
	}
	_loop160:;
	} // ( ... )*
#line 1335 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 1866 "DataflowTreeGenerator.cpp"
	_t = __t157;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::innerHashJoinStatement(RefMyAST _t) {
	RefMyAST innerHashJoinStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1341 "dataflow_generate.g"
	
	DesignTimeHashJoin * op(NULL);
	
#line 1880 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t162 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),INNER_HASH_JOIN);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp25_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1347 "dataflow_generate.g"
	
	op = new DesignTimeHashJoin();
	addToSymbolTable(op, id);
	op->SetProbeSpecificationType(
	DesignTimeHashJoinProbeSpecification::INNER_JOIN);
	
#line 1918 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop165;
		}
		
	}
	_loop165:;
	} // ( ... )*
#line 1354 "dataflow_generate.g"
	
	int nInputs = (*mActiveSymbolTable)[ASCIIToWide(id->getText())].NumInputs;
	mActivePlan->push_back(op);
	op->CreatePorts(nInputs);
	
	// If we are not in a composite, then we have already processed
	// the arguments and mProbes is complete.  If we are in a composite,
	// we have to hold off on AddProbeSpecification() until the arguments
	// are processed.
	if (!mIsCompositeBeingParsed)
	{
	for (int i=0; i<nInputs-1; i++)
	{
	op->AddProbeSpecification(i);
	}
	}
	
#line 1952 "DataflowTreeGenerator.cpp"
	_t = __t162;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::innerMergeJoinStatement(RefMyAST _t) {
	RefMyAST innerMergeJoinStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1374 "dataflow_generate.g"
	
	DesignTimeSortMergeJoin * op(NULL);
	
#line 1966 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t167 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),INNER_MERGE_JOIN);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp26_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1380 "dataflow_generate.g"
	
	op = new DesignTimeSortMergeJoin();
	addToSymbolTable(op, id);
	
#line 2002 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop170;
		}
		
	}
	_loop170:;
	} // ( ... )*
#line 1385 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 2022 "DataflowTreeGenerator.cpp"
	_t = __t167;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::insertStatement(RefMyAST _t) {
	RefMyAST insertStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1391 "dataflow_generate.g"
	
	DesignTimeDatabaseInsert * op(NULL);
	
#line 2036 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t172 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),INSERT);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp27_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1397 "dataflow_generate.g"
	
	op = new DesignTimeDatabaseInsert();
	addToSymbolTable(op, id);
	
#line 2072 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop175;
		}
		
	}
	_loop175:;
	} // ( ... )*
#line 1402 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 2092 "DataflowTreeGenerator.cpp"
	_t = __t172;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::loadErrorStatement(RefMyAST _t) {
	RefMyAST loadErrorStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1408 "dataflow_generate.g"
	
	DesignTimeLoadError * op(NULL);
	
#line 2106 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t177 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),LOAD_ERROR);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp28_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1414 "dataflow_generate.g"
	
	op = new DesignTimeLoadError(ASCIIToWide(id->getText()));
	addToSymbolTable(op, id);
	
#line 2142 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop180;
		}
		
	}
	_loop180:;
	} // ( ... )*
#line 1419 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	op->expand(*mScriptInterpreter);
	
#line 2163 "DataflowTreeGenerator.cpp"
	_t = __t177;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::loadUsageStatement(RefMyAST _t) {
	RefMyAST loadUsageStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1426 "dataflow_generate.g"
	
	DesignTimeUsageLoader * op(NULL);
	
#line 2177 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t182 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),LOAD_USAGE);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp29_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1432 "dataflow_generate.g"
	
	op = new DesignTimeUsageLoader(ASCIIToWide(id->getText()));
	addToSymbolTable(op, id);
	
#line 2213 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop185;
		}
		
	}
	_loop185:;
	} // ( ... )*
#line 1437 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	op->expand(*mScriptInterpreter);
	
#line 2234 "DataflowTreeGenerator.cpp"
	_t = __t182;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::longestPrefixMatchStatement(RefMyAST _t) {
	RefMyAST longestPrefixMatchStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1444 "dataflow_generate.g"
	
	DesignTimeLongestPrefixMatch * op = NULL;;
	
#line 2248 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t187 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),LONGEST_PREFIX_MATCH);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp30_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1450 "dataflow_generate.g"
	
	op = new DesignTimeLongestPrefixMatch();
	addToSymbolTable(op, id);
	
#line 2284 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop190;
		}
		
	}
	_loop190:;
	} // ( ... )*
#line 1455 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 2304 "DataflowTreeGenerator.cpp"
	_t = __t187;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::md5Statement(RefMyAST _t) {
	RefMyAST md5Statement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1461 "dataflow_generate.g"
	
	DesignTimeMD5Hash * op = NULL;;
	
#line 2318 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t192 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),MD5);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp31_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1467 "dataflow_generate.g"
	
	op = new DesignTimeMD5Hash();
	addToSymbolTable(op, id);
	
#line 2354 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop195;
		}
		
	}
	_loop195:;
	} // ( ... )*
#line 1472 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 2374 "DataflowTreeGenerator.cpp"
	_t = __t192;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::meterStatement(RefMyAST _t) {
	RefMyAST meterStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1478 "dataflow_generate.g"
	
	Metering * op;
	boost::shared_ptr<DatabaseMeteringStagingDatabase> db;
	std::vector<std::wstring> services;
	std::vector<std::wstring> keys;
	
#line 2391 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t197 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),METER);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp32_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1487 "dataflow_generate.g"
	
	op = new Metering();
	op->SetIsOutputPortNeeded((*mActiveSymbolTable)[ASCIIToWide(id->getText())].NumOutputs > 0);
	addToSymbolTable(op, id);
	mMetering.push_back(op);
	
#line 2429 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			meterArgument(_t,op,services,keys);
			_t = _retTree;
		}
		else {
			goto _loop200;
		}
		
	}
	_loop200:;
	} // ( ... )*
#line 1494 "dataflow_generate.g"
	
	op->SetServices(services);
	op->SetKeys(keys);
	db = boost::shared_ptr<DatabaseMeteringStagingDatabase> (new DatabaseMeteringStagingDatabase(services, DatabaseMeteringStagingDatabase::STREAMING));
	op->Generate(*mActivePlan, db);
	mDbs.push_back(db);
	
#line 2453 "DataflowTreeGenerator.cpp"
	_t = __t197;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::multiHashJoinStatement(RefMyAST _t) {
	RefMyAST multiHashJoinStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1657 "dataflow_generate.g"
	
	DesignTimeHashJoin * op(NULL);
	
#line 2467 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t205 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),MULTI_HASH_JOIN);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp33_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1663 "dataflow_generate.g"
	
	op = new DesignTimeHashJoin();
	addToSymbolTable(op, id);
	op->SetIsMultiHashJoin();
	
#line 2504 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop208;
		}
		
	}
	_loop208:;
	} // ( ... )*
#line 1669 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
	int nInputs = (*mActiveSymbolTable)[ASCIIToWide(id->getText())].NumInputs;
	op->CreatePorts(nInputs);
	
	// If we are not in a composite, then we have already processed
	// the arguments and mProbes is complete.  If we are in a composite,
	// we have to hold off on AddProbeSpecification() until the arguments
	// are processed.
	if (!mIsCompositeBeingParsed)
	{
	for (int i=0; i<nInputs-1; i++)
	{
	op->AddProbeSpecification(i);
	}
	}
	
#line 2539 "DataflowTreeGenerator.cpp"
	_t = __t205;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::printStatement(RefMyAST _t) {
	RefMyAST printStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1690 "dataflow_generate.g"
	
	DesignTimePrint * op(NULL);
	
#line 2553 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t210 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),PRINT);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp34_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1696 "dataflow_generate.g"
	
	op = new DesignTimePrint();
	addToSymbolTable(op, id);
	
#line 2589 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop213;
		}
		
	}
	_loop213:;
	} // ( ... )*
#line 1701 "dataflow_generate.g"
	
	(mActivePlan)->push_back(op);
	
#line 2609 "DataflowTreeGenerator.cpp"
	_t = __t210;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::projectionStatement(RefMyAST _t) {
	RefMyAST projectionStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1707 "dataflow_generate.g"
	
	DesignTimeProjection * op(NULL);
	
#line 2623 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t215 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),PROJECTION);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp35_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1713 "dataflow_generate.g"
	
	op = new DesignTimeProjection();
	addToSymbolTable(op, id);
	
#line 2659 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop218;
		}
		
	}
	_loop218:;
	} // ( ... )*
#line 1718 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 2679 "DataflowTreeGenerator.cpp"
	_t = __t215;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::rangePartStatement(RefMyAST _t) {
	RefMyAST rangePartStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1724 "dataflow_generate.g"
	
	DesignTimeRangePartitioner * op(NULL);
	
#line 2693 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t220 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),RANGEPART);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp36_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1730 "dataflow_generate.g"
	
	op = new DesignTimeRangePartitioner();
	addToSymbolTable(op, id);
	
#line 2729 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop223;
		}
		
	}
	_loop223:;
	} // ( ... )*
#line 1735 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 2749 "DataflowTreeGenerator.cpp"
	_t = __t220;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::rateCalculationStatement(RefMyAST _t) {
	RefMyAST rateCalculationStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1741 "dataflow_generate.g"
	
	DesignTimeRateCalculation * op(NULL);
	
#line 2763 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t225 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),RATE_CALCULATION);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp37_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1747 "dataflow_generate.g"
	
	op = new DesignTimeRateCalculation(ASCIIToWide(id->getText()));
	addToSymbolTable(op, id);
	
#line 2799 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop228;
		}
		
	}
	_loop228:;
	} // ( ... )*
#line 1752 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	op->expand(*mScriptInterpreter);
	
#line 2820 "DataflowTreeGenerator.cpp"
	_t = __t225;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::rateScheduleResolutionStatement(RefMyAST _t) {
	RefMyAST rateScheduleResolutionStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1759 "dataflow_generate.g"
	
	DesignTimeRateScheduleResolution * op(NULL);
	
#line 2834 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t230 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),RATE_SCHEDULE_RESOLUTION);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp38_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1765 "dataflow_generate.g"
	
	op = new DesignTimeRateScheduleResolution(ASCIIToWide(id->getText()));
	addToSymbolTable(op, id);
	
#line 2870 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop233;
		}
		
	}
	_loop233:;
	} // ( ... )*
#line 1770 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	op->expand(*mScriptInterpreter);
	
#line 2891 "DataflowTreeGenerator.cpp"
	_t = __t230;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::renameStatement(RefMyAST _t) {
	RefMyAST renameStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1777 "dataflow_generate.g"
	
	DesignTimeRename * op(NULL);
	std::vector<std::wstring> from;
	std::vector<std::wstring> to;
	
#line 2907 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t235 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),RENAME);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp39_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1785 "dataflow_generate.g"
	
	op = new DesignTimeRename();
	addToSymbolTable(op, id);
	
#line 2943 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop238;
		}
		
	}
	_loop238:;
	} // ( ... )*
#line 1790 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	op->handleToFromArgs();
	
#line 2964 "DataflowTreeGenerator.cpp"
	_t = __t235;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::rightMergeAntiSemiJoinStatement(RefMyAST _t) {
	RefMyAST rightMergeAntiSemiJoinStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1797 "dataflow_generate.g"
	
	DesignTimeSortMergeJoin * op(NULL);
	
#line 2978 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t240 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),RIGHT_MERGE_ANTI_SEMI_JOIN);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp40_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1803 "dataflow_generate.g"
	
	op = new DesignTimeSortMergeJoin();
	addToSymbolTable(op, id);
	op->SetJoinType(DesignTimeSortMergeJoin::RIGHT_ANTI_SEMI);
	
#line 3015 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop243;
		}
		
	}
	_loop243:;
	} // ( ... )*
#line 1809 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 3035 "DataflowTreeGenerator.cpp"
	_t = __t240;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::rightMergeSemiJoinStatement(RefMyAST _t) {
	RefMyAST rightMergeSemiJoinStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1815 "dataflow_generate.g"
	
	DesignTimeSortMergeJoin * op(NULL);
	
#line 3049 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t245 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),RIGHT_MERGE_SEMI_JOIN);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp41_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1821 "dataflow_generate.g"
	
	op = new DesignTimeSortMergeJoin();
	addToSymbolTable(op, id);
	op->SetJoinType(DesignTimeSortMergeJoin::RIGHT_SEMI);
	
#line 3086 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop248;
		}
		
	}
	_loop248:;
	} // ( ... )*
#line 1827 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 3106 "DataflowTreeGenerator.cpp"
	_t = __t245;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::rightOuterHashJoinStatement(RefMyAST _t) {
	RefMyAST rightOuterHashJoinStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1833 "dataflow_generate.g"
	
	DesignTimeHashJoin * op(NULL);
	DesignTimeHashJoinProbeSpecification spec;
	
#line 3121 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t250 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),RIGHT_OUTER_HASH_JOIN);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp42_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1840 "dataflow_generate.g"
	
	op = new DesignTimeHashJoin();
	addToSymbolTable(op, id);
	op->SetProbeSpecificationType(
	DesignTimeHashJoinProbeSpecification::RIGHT_OUTER);
	
#line 3159 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop253;
		}
		
	}
	_loop253:;
	} // ( ... )*
#line 1847 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
	int nInputs = (*mActiveSymbolTable)[ASCIIToWide(id->getText())].NumInputs;
	op->CreatePorts(nInputs);
	for(int i=0; i<nInputs-1; i++)
	{
	op->AddProbeSpecification(i);
	}
	
#line 3186 "DataflowTreeGenerator.cpp"
	_t = __t250;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::rightOuterMergeJoinStatement(RefMyAST _t) {
	RefMyAST rightOuterMergeJoinStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1860 "dataflow_generate.g"
	
	DesignTimeSortMergeJoin * op(NULL);
	
#line 3200 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t255 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),RIGHT_OUTER_MERGE_JOIN);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp43_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1866 "dataflow_generate.g"
	
	op = new DesignTimeSortMergeJoin();
	addToSymbolTable(op, id);
	op->SetJoinType(DesignTimeSortMergeJoin::RIGHT_OUTER);
	
#line 3237 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop258;
		}
		
	}
	_loop258:;
	} // ( ... )*
#line 1872 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 3257 "DataflowTreeGenerator.cpp"
	_t = __t255;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::selectStatement(RefMyAST _t) {
	RefMyAST selectStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1105 "dataflow_generate.g"
	
	DesignTimeDatabaseSelect * op(NULL);
	
#line 3271 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t95 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SELECT);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp44_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1111 "dataflow_generate.g"
	
	op = new DesignTimeDatabaseSelect();
	addToSymbolTable(op, id);
	
#line 3307 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop98;
		}
		
	}
	_loop98:;
	} // ( ... )*
#line 1116 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 3327 "DataflowTreeGenerator.cpp"
	_t = __t95;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::sequentialFileDeleteStatement(RefMyAST _t) {
	RefMyAST sequentialFileDeleteStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1878 "dataflow_generate.g"
	
	DesignTimeDataFileDelete * op(NULL);
	
#line 3341 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t260 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SEQUENTIAL_FILE_DELETE);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp45_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1884 "dataflow_generate.g"
	
	op = new DesignTimeDataFileDelete();
	addToSymbolTable(op, id);
	
#line 3377 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop263;
		}
		
	}
	_loop263:;
	} // ( ... )*
#line 1889 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 3397 "DataflowTreeGenerator.cpp"
	_t = __t260;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::sequentialFileOutputStatement(RefMyAST _t) {
	RefMyAST sequentialFileOutputStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1895 "dataflow_generate.g"
	
	DesignTimeDataFileExport * op(NULL);
	
#line 3411 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t265 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SEQUENTIAL_FILE_OUTPUT);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp46_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1901 "dataflow_generate.g"
	
	op = new DesignTimeDataFileExport();
	addToSymbolTable(op, id);
	
#line 3447 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop268;
		}
		
	}
	_loop268:;
	} // ( ... )*
#line 1906 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 3467 "DataflowTreeGenerator.cpp"
	_t = __t265;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::sequentialFileRenameStatement(RefMyAST _t) {
	RefMyAST sequentialFileRenameStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1912 "dataflow_generate.g"
	
	DesignTimeDataFileRename * op(NULL);
	
#line 3481 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t270 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SEQUENTIAL_FILE_RENAME);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp47_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1918 "dataflow_generate.g"
	
	op = new DesignTimeDataFileRename();
	addToSymbolTable(op, id);
	
#line 3517 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop273;
		}
		
	}
	_loop273:;
	} // ( ... )*
#line 1923 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 3537 "DataflowTreeGenerator.cpp"
	_t = __t270;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::sequentialFileScanStatement(RefMyAST _t) {
	RefMyAST sequentialFileScanStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1929 "dataflow_generate.g"
	
	DesignTimeDataFileScan * op(NULL);
	
#line 3551 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t275 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SEQUENTIAL_FILE_SCAN);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp48_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1935 "dataflow_generate.g"
	
	op = new DesignTimeDataFileScan();
	addToSymbolTable(op, id);
	
#line 3587 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop278;
		}
		
	}
	_loop278:;
	} // ( ... )*
#line 1940 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 3607 "DataflowTreeGenerator.cpp"
	_t = __t275;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::sessionSetBuilderStatement(RefMyAST _t) {
	RefMyAST sessionSetBuilderStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1946 "dataflow_generate.g"
	
	DesignTimeSessionSetBuilder * op(NULL);
	
#line 3621 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t280 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SESSION_SET_BUILDER);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp49_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1952 "dataflow_generate.g"
	
	op = new DesignTimeSessionSetBuilder((*mActiveSymbolTable)[ASCIIToWide(id->getText())].NumInputs);
	addToSymbolTable(op, id);
	
#line 3657 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop283;
		}
		
	}
	_loop283:;
	} // ( ... )*
#line 1957 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 3677 "DataflowTreeGenerator.cpp"
	_t = __t280;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::sortStatement(RefMyAST _t) {
	RefMyAST sortStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1963 "dataflow_generate.g"
	
	DesignTimeExternalSort * op(NULL);
	
#line 3691 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t285 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SORT);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp50_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1969 "dataflow_generate.g"
	
	op = new DesignTimeExternalSort();
	addToSymbolTable(op, id);
	
#line 3727 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop288;
		}
		
	}
	_loop288:;
	} // ( ... )*
#line 1974 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 3747 "DataflowTreeGenerator.cpp"
	_t = __t285;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::sortGroupByStatement(RefMyAST _t) {
	RefMyAST sortGroupByStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1980 "dataflow_generate.g"
	
	DesignTimeSortGroupBy * op(NULL);
	
#line 3761 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t290 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SORT_GROUP_BY);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp51_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1986 "dataflow_generate.g"
	
	op = new DesignTimeSortGroupBy();
	addToSymbolTable(op, id);
	
#line 3797 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop293;
		}
		
	}
	_loop293:;
	} // ( ... )*
#line 1991 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 3817 "DataflowTreeGenerator.cpp"
	_t = __t290;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::sortMergeStatement(RefMyAST _t) {
	RefMyAST sortMergeStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1997 "dataflow_generate.g"
	
	DesignTimeSortMerge * op(NULL);
	
#line 3831 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t295 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SORTMERGE);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp52_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 2003 "dataflow_generate.g"
	
	op = new DesignTimeSortMerge((*mActiveSymbolTable)[ASCIIToWide(id->getText())].NumInputs);
	addToSymbolTable(op, id);
	
#line 3867 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop298;
		}
		
	}
	_loop298:;
	} // ( ... )*
#line 2008 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 3887 "DataflowTreeGenerator.cpp"
	_t = __t295;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::sortMergeCollStatement(RefMyAST _t) {
	RefMyAST sortMergeCollStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 2014 "dataflow_generate.g"
	
	DesignTimeSortMergeCollector * op(NULL);
	
#line 3901 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t300 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SORTMERGECOLL);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp53_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 2020 "dataflow_generate.g"
	
	op = new DesignTimeSortMergeCollector();
	addToSymbolTable(op, id);
	
#line 3937 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop303;
		}
		
	}
	_loop303:;
	} // ( ... )*
#line 2025 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 3957 "DataflowTreeGenerator.cpp"
	_t = __t300;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::sortNestStatement(RefMyAST _t) {
	RefMyAST sortNestStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 2031 "dataflow_generate.g"
	
	DesignTimeSortNest * op(NULL);
	
#line 3971 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t305 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SORT_NEST);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp54_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 2037 "dataflow_generate.g"
	
	op = new DesignTimeSortNest();
	addToSymbolTable(op, id);
	
#line 4007 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop308;
		}
		
	}
	_loop308:;
	} // ( ... )*
#line 2042 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 4027 "DataflowTreeGenerator.cpp"
	_t = __t305;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::sortOrderAssertStatement(RefMyAST _t) {
	RefMyAST sortOrderAssertStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 2048 "dataflow_generate.g"
	
	DesignTimeAssertSortOrder * op(NULL);
	
#line 4041 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t310 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SORT_ORDER_ASSERT);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp55_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 2054 "dataflow_generate.g"
	
	op = new DesignTimeAssertSortOrder();
	addToSymbolTable(op, id);
	
#line 4077 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop313;
		}
		
	}
	_loop313:;
	} // ( ... )*
#line 2059 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 4097 "DataflowTreeGenerator.cpp"
	_t = __t310;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::sortRunningTotalStatement(RefMyAST _t) {
	RefMyAST sortRunningTotalStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 2065 "dataflow_generate.g"
	
	DesignTimeSortRunningAggregate * op(NULL);
	
#line 4111 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t315 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SORT_RUNNING_TOTAL);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp56_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 2071 "dataflow_generate.g"
	
	op = new DesignTimeSortRunningAggregate((*mActiveSymbolTable)[ASCIIToWide(id->getText())].NumInputs);
	addToSymbolTable(op, id);
	
#line 4147 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop318;
		}
		
	}
	_loop318:;
	} // ( ... )*
#line 2076 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 4167 "DataflowTreeGenerator.cpp"
	_t = __t315;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::sqlExecDirectStatement(RefMyAST _t) {
	RefMyAST sqlExecDirectStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 2082 "dataflow_generate.g"
	
	DesignTimeTransactionalInstall * op(NULL);
	
#line 4181 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t320 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SQL_EXEC_DIRECT);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp57_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 2088 "dataflow_generate.g"
	
	op = new DesignTimeTransactionalInstall((*mActiveSymbolTable)[ASCIIToWide(id->getText())].NumInputs - 1);
	addToSymbolTable(op, id);
	
#line 4217 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop323;
		}
		
	}
	_loop323:;
	} // ( ... )*
#line 2093 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 4237 "DataflowTreeGenerator.cpp"
	_t = __t320;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::subscriptionResolutionStatement(RefMyAST _t) {
	RefMyAST subscriptionResolutionStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 2099 "dataflow_generate.g"
	
	DesignTimeSubscriptionResolution * op(NULL);
	
#line 4251 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t325 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SUBSCRIPTION_RESOLUTION);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp58_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 2105 "dataflow_generate.g"
	
	op = new DesignTimeSubscriptionResolution(ASCIIToWide(id->getText()));
	addToSymbolTable(op, id);
	
#line 4287 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop328;
		}
		
	}
	_loop328:;
	} // ( ... )*
#line 2110 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	op->expand(*mScriptInterpreter);
	
#line 4308 "DataflowTreeGenerator.cpp"
	_t = __t325;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::switchStatement(RefMyAST _t) {
	RefMyAST switchStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 2117 "dataflow_generate.g"
	
	DesignTimeSwitch * op(NULL);
	
#line 4322 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t330 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SWITCH);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp59_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 2123 "dataflow_generate.g"
	
	op = new DesignTimeSwitch((*mActiveSymbolTable)[ASCIIToWide(id->getText())].NumOutputs);
	addToSymbolTable(op, id);
	
#line 4358 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop333;
		}
		
	}
	_loop333:;
	} // ( ... )*
#line 2128 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 4378 "DataflowTreeGenerator.cpp"
	_t = __t330;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::taxwareStatement(RefMyAST _t) {
	RefMyAST taxwareStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 2134 "dataflow_generate.g"
	
	DesignTimeTaxware * op(NULL);
	
#line 4392 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t335 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),TAXWARE);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp60_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 2140 "dataflow_generate.g"
	
	op = new DesignTimeTaxware();
	addToSymbolTable(op, id);
	
#line 4428 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop338;
		}
		
	}
	_loop338:;
	} // ( ... )*
#line 2145 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 4448 "DataflowTreeGenerator.cpp"
	_t = __t335;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::unionAllStatement(RefMyAST _t) {
	RefMyAST unionAllStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 2151 "dataflow_generate.g"
	
	DesignTimeUnionAll * op(NULL);
	
#line 4462 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t340 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),UNION_ALL);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp61_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 2157 "dataflow_generate.g"
	
	op = new DesignTimeUnionAll((*mActiveSymbolTable)[ASCIIToWide(id->getText())].NumInputs);
	addToSymbolTable(op, id);
	
#line 4498 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop343;
		}
		
	}
	_loop343:;
	} // ( ... )*
#line 2162 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 4518 "DataflowTreeGenerator.cpp"
	_t = __t340;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::unnestStatement(RefMyAST _t) {
	RefMyAST unnestStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 2168 "dataflow_generate.g"
	
	DesignTimeUnnest * op(NULL);
	
#line 4532 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t345 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),UNNEST);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp62_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 2174 "dataflow_generate.g"
	
	op = new DesignTimeUnnest();
	addToSymbolTable(op, id);
	
#line 4568 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop348;
		}
		
	}
	_loop348:;
	} // ( ... )*
#line 2179 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 4588 "DataflowTreeGenerator.cpp"
	_t = __t345;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::unrollStatement(RefMyAST _t) {
	RefMyAST unrollStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 2185 "dataflow_generate.g"
	
	DesignTimeUnroll * op(NULL);
	
#line 4602 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t350 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),UNROLL);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp63_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 2191 "dataflow_generate.g"
	
	op = new DesignTimeUnroll();
	addToSymbolTable(op, id);
	
#line 4638 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop353;
		}
		
	}
	_loop353:;
	} // ( ... )*
#line 2196 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 4658 "DataflowTreeGenerator.cpp"
	_t = __t350;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::writeErrorStatement(RefMyAST _t) {
	RefMyAST writeErrorStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 2202 "dataflow_generate.g"
	
	DesignTimeWriteError * op(NULL);
	
#line 4672 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t355 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),WRITE_ERROR);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp64_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 2208 "dataflow_generate.g"
	
	op = new DesignTimeWriteError(ASCIIToWide(id->getText()),
	(*mActiveSymbolTable)[ASCIIToWide(id->getText())].NumInputs);
	addToSymbolTable(op, id);
	
#line 4709 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop358;
		}
		
	}
	_loop358:;
	} // ( ... )*
#line 2214 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	op->expand(*mScriptInterpreter);
	
#line 4730 "DataflowTreeGenerator.cpp"
	_t = __t355;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::writeProductViewStatement(RefMyAST _t) {
	RefMyAST writeProductViewStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 2221 "dataflow_generate.g"
	
	DesignTimeWriteProductView * op(NULL);
	
#line 4744 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t360 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),WRITE_PRODUCT_VIEW);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp65_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 2227 "dataflow_generate.g"
	
	op = new DesignTimeWriteProductView(ASCIIToWide(id->getText()));
	addToSymbolTable(op, id);
	
#line 4780 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop363;
		}
		
	}
	_loop363:;
	} // ( ... )*
#line 2232 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	op->expand(*mScriptInterpreter);
	
#line 4801 "DataflowTreeGenerator.cpp"
	_t = __t360;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::edgeStatement(RefMyAST _t) {
	RefMyAST edgeStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
#line 2371 "dataflow_generate.g"
	
	//     tuple<operator name, <port id, port name>, line number, column number>
	boost::tuple<std::wstring, boost::variant<int,std::wstring>, int, int > lhs;
	boost::tuple<std::wstring, boost::variant<int,std::wstring>, int, int > rhs;
	bool buffered = true;
	
#line 4816 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t378 = _t;
	RefMyAST tmp66_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ARROW);
	_t = _t->getFirstChild();
	lhs=arrowOrRefStatement(_t);
	_t = _retTree;
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case LBRACKET:
	{
		buffered=arrowArguments(_t);
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
	_t = __t378;
	_t = _t->getNextSibling();
#line 2380 "dataflow_generate.g"
	
	std::map<std::wstring,DataflowSymbol >::const_iterator leftIt(mActiveSymbolTable->find(lhs.get<0>()));
	std::map<std::wstring,DataflowSymbol >::const_iterator rightIt(mActiveSymbolTable->find(rhs.get<0>()));
	
	// Verify that the referenced operator exists
	if (leftIt == mActiveSymbolTable->end())
	throw DataflowArrowUndefOperatorException(lhs.get<0>(), lhs.get<2>(), 
	lhs.get<3>(), mFilename);
	if (rightIt == mActiveSymbolTable->end())
	throw DataflowArrowUndefOperatorException(rhs.get<0>(), rhs.get<2>(), 
	lhs.get<3>(), mFilename);
	
	// Verify that the referenced ports exists
	verifyPortExists(leftIt->second.Op->GetOutputPorts(), lhs, false);
	verifyPortExists(rightIt->second.Op->GetInputPorts(), rhs, true);
	
	boost::shared_ptr<Port> lhsPort (
	lhs.get<1>().which() == 0 ? 
			leftIt->second.Op->GetOutputPorts()[boost::get<int>(lhs.get<1>())] :
			leftIt->second.Op->GetOutputPorts()[boost::get<std::wstring>(lhs.get<1>())]);
	
	boost::shared_ptr<Port> rhsPort (
	rhs.get<1>().which() == 0 ? 
			rightIt->second.Op->GetInputPorts()[boost::get<int>(rhs.get<1>())] :
			rightIt->second.Op->GetInputPorts()[boost::get<std::wstring>(rhs.get<1>())]);
	
	mActivePlan->push_back(new DesignTimeChannel(lhsPort, rhsPort, buffered));
	
#line 4877 "DataflowTreeGenerator.cpp"
	_retTree = _t;
}

void DataflowTreeGenerator::compositeParameters(RefMyAST _t) {
	RefMyAST compositeParameters_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if (((_t->getType() >= INPUT && _t->getType() <= SUBLIST_DECL))) {
			compositeParameterSpec(_t);
			_t = _retTree;
		}
		else {
			goto _loop21;
		}
		
	}
	_loop21:;
	} // ( ... )*
	_retTree = _t;
}

void DataflowTreeGenerator::compositeBody(RefMyAST _t) {
	RefMyAST compositeBody_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	
	{
	dataFlowBody(_t);
	_t = _retTree;
	}
	_retTree = _t;
}

void DataflowTreeGenerator::compositeParameterSpec(RefMyAST _t) {
	RefMyAST compositeParameterSpec_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case INPUT:
	{
		compositeParameterInputSpec(_t);
		_t = _retTree;
		break;
	}
	case OUTPUT:
	{
		compositeParameterOutputSpec(_t);
		_t = _retTree;
		break;
	}
	case STRING_DECL:
	case INTEGER_DECL:
	case BOOLEAN_DECL:
	case SUBLIST_DECL:
	{
		compositeArgSpec(_t);
		_t = _retTree;
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	_retTree = _t;
}

void DataflowTreeGenerator::compositeParameterInputSpec(RefMyAST _t) {
	RefMyAST compositeParameterInputSpec_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST operatorId = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t25 = _t;
	RefMyAST tmp67_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),INPUT);
	_t = _t->getFirstChild();
	RefMyAST tmp68_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),STRING_LITERAL);
	_t = _t->getNextSibling();
	RefMyAST tmp69_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),IS);
	_t = _t->getNextSibling();
	operatorId = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
	_t = _t->getNextSibling();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case NUM_INT:
	{
		RefMyAST tmp70_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),NUM_INT);
		_t = _t->getNextSibling();
		break;
	}
	case STRING_LITERAL:
	{
		RefMyAST tmp71_AST_in = _t;
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
	_t = __t25;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::compositeParameterOutputSpec(RefMyAST _t) {
	RefMyAST compositeParameterOutputSpec_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST operatorId = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t28 = _t;
	RefMyAST tmp72_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),OUTPUT);
	_t = _t->getFirstChild();
	RefMyAST tmp73_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),STRING_LITERAL);
	_t = _t->getNextSibling();
	RefMyAST tmp74_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),IS);
	_t = _t->getNextSibling();
	operatorId = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
	_t = _t->getNextSibling();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case NUM_INT:
	{
		RefMyAST tmp75_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),NUM_INT);
		_t = _t->getNextSibling();
		break;
	}
	case STRING_LITERAL:
	{
		RefMyAST tmp76_AST_in = _t;
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
	_t = __t28;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::compositeArgSpec(RefMyAST _t) {
	RefMyAST compositeArgSpec_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case STRING_DECL:
	{
		compositeArgSpecString(_t);
		_t = _retTree;
		break;
	}
	case INTEGER_DECL:
	{
		compositeArgSpecInt(_t);
		_t = _retTree;
		break;
	}
	case BOOLEAN_DECL:
	{
		compositeArgSpecBool(_t);
		_t = _retTree;
		break;
	}
	case SUBLIST_DECL:
	{
		compositeArgSpecSublist(_t);
		_t = _retTree;
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	_retTree = _t;
}

void DataflowTreeGenerator::compositeArgSpecString(RefMyAST _t) {
	RefMyAST compositeArgSpecString_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	
	RefMyAST __t33 = _t;
	RefMyAST tmp77_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),STRING_DECL);
	_t = _t->getFirstChild();
	RefMyAST tmp78_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),DOLLAR_SIGN);
	_t = _t->getNextSibling();
	RefMyAST tmp79_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
	_t = _t->getNextSibling();
	_t = __t33;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::compositeArgSpecInt(RefMyAST _t) {
	RefMyAST compositeArgSpecInt_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	
	RefMyAST __t35 = _t;
	RefMyAST tmp80_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),INTEGER_DECL);
	_t = _t->getFirstChild();
	RefMyAST tmp81_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),DOLLAR_SIGN);
	_t = _t->getNextSibling();
	RefMyAST tmp82_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
	_t = _t->getNextSibling();
	_t = __t35;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::compositeArgSpecBool(RefMyAST _t) {
	RefMyAST compositeArgSpecBool_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	
	RefMyAST __t37 = _t;
	RefMyAST tmp83_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),BOOLEAN_DECL);
	_t = _t->getFirstChild();
	RefMyAST tmp84_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),DOLLAR_SIGN);
	_t = _t->getNextSibling();
	RefMyAST tmp85_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
	_t = _t->getNextSibling();
	_t = __t37;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::compositeArgSpecSublist(RefMyAST _t) {
	RefMyAST compositeArgSpecSublist_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	
	RefMyAST __t39 = _t;
	RefMyAST tmp86_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),SUBLIST_DECL);
	_t = _t->getFirstChild();
	RefMyAST tmp87_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),DOLLAR_SIGN);
	_t = _t->getNextSibling();
	RefMyAST tmp88_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
	_t = _t->getNextSibling();
	_t = __t39;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::stepBody(RefMyAST _t) {
	RefMyAST stepBody_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	
	RefMyAST tmp89_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),LPAREN);
	_t = _t->getNextSibling();
	{
	dataFlowBody(_t);
	_t = _retTree;
	}
	RefMyAST tmp90_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),RPAREN);
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::controlFlowBody(RefMyAST _t) {
	RefMyAST controlFlowBody_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case STEP:
		{
			stepStatement(_t);
			_t = _retTree;
			break;
		}
		case IF_BEGIN:
		{
			ifStatement(_t);
			_t = _retTree;
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
	_retTree = _t;
}

void DataflowTreeGenerator::stepStatement(RefMyAST _t) {
	RefMyAST stepStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 2239 "dataflow_generate.g"
	
	std::wstring stepName;
	
#line 5207 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t365 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),STEP);
	_t = _t->getFirstChild();
#line 2245 "dataflow_generate.g"
	
	stepName = ASCIIToWide(id->getText());
	
#line 5217 "DataflowTreeGenerator.cpp"
	_t = __t365;
	_t = _t->getNextSibling();
#line 2249 "dataflow_generate.g"
	
	WorkflowInstructionStep* instruction = 
	new WorkflowInstructionStep(mWorkflow, stepName, stepName);
	mWorkflow->addInstruction(instruction);
	
#line 5226 "DataflowTreeGenerator.cpp"
	_retTree = _t;
}

void DataflowTreeGenerator::ifStatement(RefMyAST _t) {
	RefMyAST ifStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
#line 788 "dataflow_generate.g"
	
	WorkflowInstructionIf* ifInstruct = NULL;
	WorkflowInstructionJump* jumpInstruct = NULL;
	WorkflowPredicate* predicate = NULL;
	boost::int32_t ifNumber;
	boost::int32_t jumpNumber;
	
#line 5240 "DataflowTreeGenerator.cpp"
	
	RefMyAST tmp91_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),IF_BEGIN);
	_t = _t->getNextSibling();
#line 798 "dataflow_generate.g"
	
	ifInstruct = new WorkflowInstructionIf(mWorkflow, L"if");
	mWorkflow->addInstruction(ifInstruct);
	ifNumber = mWorkflow->getLastInstructionNumber();
	
#line 5251 "DataflowTreeGenerator.cpp"
	RefMyAST tmp92_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),LPAREN);
	_t = _t->getNextSibling();
	ifPredicate(_t,&predicate);
	_t = _retTree;
#line 805 "dataflow_generate.g"
	
	ifInstruct->setPredicate(predicate);
	
#line 5261 "DataflowTreeGenerator.cpp"
	RefMyAST tmp93_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),RPAREN);
	_t = _t->getNextSibling();
	RefMyAST tmp94_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),THEN);
	_t = _t->getNextSibling();
	controlFlowBody(_t);
	_t = _retTree;
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case ELSE:
	{
		RefMyAST tmp95_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ELSE);
		_t = _t->getNextSibling();
#line 812 "dataflow_generate.g"
		
		// After executing the if-true body we need to jump over the else part
		// We'll set the jump amount later
		jumpInstruct = new WorkflowInstructionJump(mWorkflow, L"jump over else");
		mWorkflow->addInstruction(jumpInstruct);
		jumpNumber = mWorkflow->getLastInstructionNumber();
		
		// add an instruct that appears at the end of the if true body
		// to jump over else statement part.  We'll set jump amount later.
		ifInstruct->setNumberToJump(mWorkflow->getLastInstructionNumber() -
		ifNumber + 1);
		
#line 5292 "DataflowTreeGenerator.cpp"
		controlFlowBody(_t);
		_t = _retTree;
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
	RefMyAST tmp96_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),IF_END);
	_t = _t->getNextSibling();
#line 827 "dataflow_generate.g"
	
	if (jumpInstruct)  // this is the else case
	{                  // after executing if true body, we jump over else part
	jumpInstruct->setNumberToJump(mWorkflow->getLastInstructionNumber() -
	jumpNumber + 1);
	}
	else
	{
	// this is the no-else if statement
	// if the predicate is not true, we jump over the if body
	ifInstruct->setNumberToJump(mWorkflow->getLastInstructionNumber() -
	ifNumber + 1);
	}
	
#line 5325 "DataflowTreeGenerator.cpp"
	_retTree = _t;
}

void DataflowTreeGenerator::ifPredicate(RefMyAST _t,
	WorkflowPredicate** predicate
) {
	RefMyAST ifPredicate_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
#line 862 "dataflow_generate.g"
	
	WorkflowPredicateNot *notPredicate = NULL;
	
#line 5337 "DataflowTreeGenerator.cpp"
	
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case BANG:
	{
		RefMyAST tmp97_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),BANG);
		_t = _t->getNextSibling();
#line 868 "dataflow_generate.g"
		
		notPredicate = new WorkflowPredicateNot();
		
#line 5352 "DataflowTreeGenerator.cpp"
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
		doesFileExistPredicate(_t,predicate);
		_t = _retTree;
		break;
	}
	case PREDICATE_IS_FILE_EMPTY:
	{
		isFileEmptyPredicate(_t,predicate);
		_t = _retTree;
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
#line 874 "dataflow_generate.g"
	
	if (notPredicate)
	{
	notPredicate->setOperand(*predicate);
	*predicate = notPredicate;
	}
	
#line 5396 "DataflowTreeGenerator.cpp"
	_retTree = _t;
}

void DataflowTreeGenerator::ifArgument(RefMyAST _t,
	WorkflowPredicate* predicate
) {
	RefMyAST ifArgument_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST variableId = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case STRING_LITERAL:
	{
		id = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),STRING_LITERAL);
		_t = _t->getNextSibling();
#line 846 "dataflow_generate.g"
		
		// Pass the string (without opening and ending quotes) to the predicate
		std::string s = id->getText();
		if (s.length() > 2)
		{
		predicate->setStringParameter(ASCIIToWide(s.substr(1, s.length()-2)));
		}
		
#line 5425 "DataflowTreeGenerator.cpp"
		break;
	}
	case DOLLAR_SIGN:
	{
		RefMyAST tmp98_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),DOLLAR_SIGN);
		_t = _t->getNextSibling();
		variableId = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
#line 856 "dataflow_generate.g"
		
		predicate->setVariableParameter(ASCIIToWide(variableId->getText()));
		
#line 5440 "DataflowTreeGenerator.cpp"
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	_retTree = _t;
}

void DataflowTreeGenerator::doesFileExistPredicate(RefMyAST _t,
	WorkflowPredicate** predicate
) {
	RefMyAST doesFileExistPredicate_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	{
	id = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),PREDICATE_DOES_FILE_EXIST);
	_t = _t->getNextSibling();
#line 887 "dataflow_generate.g"
	
	*predicate = new WorkflowPredicateDoesFileExist();
	
#line 5466 "DataflowTreeGenerator.cpp"
	RefMyAST tmp99_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),LPAREN);
	_t = _t->getNextSibling();
	ifArgument(_t,*predicate);
	_t = _retTree;
	RefMyAST tmp100_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),RPAREN);
	_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void DataflowTreeGenerator::isFileEmptyPredicate(RefMyAST _t,
	WorkflowPredicate** predicate
) {
	RefMyAST isFileEmptyPredicate_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	{
	id = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),PREDICATE_IS_FILE_EMPTY);
	_t = _t->getNextSibling();
#line 898 "dataflow_generate.g"
	
	*predicate = new WorkflowPredicateIsFileEmpty();
	
#line 5493 "DataflowTreeGenerator.cpp"
	RefMyAST tmp101_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),LPAREN);
	_t = _t->getNextSibling();
	ifArgument(_t,*predicate);
	_t = _retTree;
	RefMyAST tmp102_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),RPAREN);
	_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void DataflowTreeGenerator::operatorArgument(RefMyAST _t,
	DesignTimeOperator * op
) {
	RefMyAST operatorArgument_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST av = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST variableId = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 905 "dataflow_generate.g"
	
	OperatorArg* opArgSubList = NULL;
	
#line 5517 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t62 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
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
	case NUM_INT:
	{
		av = (_t == ASTNULL) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
		nodeArgumentValue(_t);
		_t = _retTree;
#line 913 "dataflow_generate.g"
		
		OperatorArg *arg = formOperatorArg(id, av);
		
		if (mIsCompositeBeingParsed)
		{
		op->addPendingArg(arg);
		}
		else
		{
		op->handleUnresolvedArg(*arg);
		delete arg;
		}
		
#line 5552 "DataflowTreeGenerator.cpp"
		break;
	}
	case 3:
	case ID:
	{
		{ // ( ... )*
		for (;;) {
			if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
				_t = ASTNULL;
			if ((_t->getType() == ID)) {
				operatorArgumentList(_t,&opArgSubList);
				_t = _retTree;
			}
			else {
				goto _loop65;
			}
			
		}
		_loop65:;
		} // ( ... )*
#line 929 "dataflow_generate.g"
		
		opArgSubList->setName(ASCIIToWide(id->getText()),
		id->getLine(),
		id->getColumn());
		
		// If not in a composite
		if (mIsCompositeBeingParsed)
		{
		op->addPendingArg(opArgSubList);
		}
		else
		{
		op->handleUnresolvedArg(*opArgSubList);
		delete opArgSubList;
		}
		
#line 5590 "DataflowTreeGenerator.cpp"
		break;
	}
	case DOLLAR_SIGN:
	{
		RefMyAST tmp103_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),DOLLAR_SIGN);
		_t = _t->getNextSibling();
		variableId = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
#line 951 "dataflow_generate.g"
		
		if (mIsCompositeBeingParsed)
		{
		// Make sure that the referenced composite argument exists.
		if (!mCompositeDictionary->doesArgExist(mActiveCompositeName,
		ASCIIToWide(variableId->getText())))
		{
		throw (DataflowInvalidArgumentException(
		variableId->getLine(),
		variableId->getColumn(),
		mFilename,
		op->GetName(),
		ASCIIToWide(variableId->getText())));
		}
		
		OperatorArgType argType = mCompositeDictionary->
		getArgType(mActiveCompositeName,
		ASCIIToWide(variableId->getText()));
		
		OperatorArg *arg = new OperatorArg(OPERATOR_ARG_TYPE_VARIABLE,
		ASCIIToWide(variableId->getText()), 
		ASCIIToWide(id->getText()),
		argType,
		id->getLine(), id->getColumn(),
		variableId->getLine(), 
		variableId->getColumn(),
		mFilename);
		op->addPendingArg(arg);
		}
		else
		{
		// We don't really know the type of argument to use.
		// We will assume a string.
		OperatorArg *arg = new OperatorArg(OPERATOR_ARG_TYPE_VARIABLE,
		ASCIIToWide(variableId->getText()), 
		ASCIIToWide(id->getText()),
		OPERATOR_ARG_TYPE_STRING,
		id->getLine(), id->getColumn(),
		variableId->getLine(), 
		variableId->getColumn(),
		mFilename);
		
		op->handleUnresolvedArg(*arg);
		delete arg;
		}
		
#line 5648 "DataflowTreeGenerator.cpp"
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	_t = __t62;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::nodeArgumentValue(RefMyAST _t) {
	RefMyAST nodeArgumentValue_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case NUM_INT:
	{
		RefMyAST tmp104_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),NUM_INT);
		_t = _t->getNextSibling();
		break;
	}
	case NUM_BIGINT:
	{
		RefMyAST tmp105_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),NUM_BIGINT);
		_t = _t->getNextSibling();
		break;
	}
	case NUM_FLOAT:
	{
		RefMyAST tmp106_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),NUM_FLOAT);
		_t = _t->getNextSibling();
		break;
	}
	case NUM_DECIMAL:
	{
		RefMyAST tmp107_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),NUM_DECIMAL);
		_t = _t->getNextSibling();
		break;
	}
	case STRING_LITERAL:
	{
		RefMyAST tmp108_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),STRING_LITERAL);
		_t = _t->getNextSibling();
		break;
	}
	case TK_TRUE:
	{
		RefMyAST tmp109_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),TK_TRUE);
		_t = _t->getNextSibling();
		break;
	}
	case TK_FALSE:
	{
		RefMyAST tmp110_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),TK_FALSE);
		_t = _t->getNextSibling();
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	_retTree = _t;
}

void DataflowTreeGenerator::operatorArgumentList(RefMyAST _t,
	OperatorArg** opArgSubList
) {
	RefMyAST operatorArgumentList_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST av = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t67 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
	_t = _t->getFirstChild();
	{
	av = (_t == ASTNULL) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
#line 1005 "dataflow_generate.g"
	
	if ((*opArgSubList) == NULL)
	{
	*opArgSubList = new OperatorArg(OPERATOR_ARG_TYPE_SUBLIST);
	}
	
	OperatorArg *arg = formOperatorArg(id, av);
	(*opArgSubList)->addSubListArg(*arg);
	delete arg;
	
#line 5751 "DataflowTreeGenerator.cpp"
	}
	_t = __t67;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::generateStatement(RefMyAST _t) {
	RefMyAST generateStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1205 "dataflow_generate.g"
	
	DesignTimeGenerator * op(NULL);
	
#line 5766 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t122 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),GENERATE);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp111_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1211 "dataflow_generate.g"
	
	op = new DesignTimeGenerator();
	addToSymbolTable(op, id);
	
#line 5802 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop125;
		}
		
	}
	_loop125:;
	} // ( ... )*
#line 1216 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 5822 "DataflowTreeGenerator.cpp"
	_t = __t122;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::expressionGenerateStatement(RefMyAST _t) {
	RefMyAST expressionGenerateStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST id2 = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 1222 "dataflow_generate.g"
	
	DesignTimeExpressionGenerator * op(NULL);
	
#line 5836 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t127 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),GENERATE);
	_t = _t->getFirstChild();
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COLON:
	{
		RefMyAST tmp112_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),COLON);
		_t = _t->getNextSibling();
		id2 = _t;
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
#line 1228 "dataflow_generate.g"
	
	op = new DesignTimeExpressionGenerator();
	addToSymbolTable(op, id);
	
#line 5872 "DataflowTreeGenerator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			operatorArgument(_t,op);
			_t = _retTree;
		}
		else {
			goto _loop130;
		}
		
	}
	_loop130:;
	} // ( ... )*
#line 1233 "dataflow_generate.g"
	
	mActivePlan->push_back(op);
	
#line 5892 "DataflowTreeGenerator.cpp"
	_t = __t127;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::meterArgument(RefMyAST _t,
	Metering * op, std::vector<std::wstring>& services, std::vector<std::wstring>& keys
) {
	RefMyAST meterArgument_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST av = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST variableId = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	
	RefMyAST __t202 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
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
	case NUM_INT:
	{
		av = (_t == ASTNULL) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
		nodeArgumentValue(_t);
		_t = _retTree;
#line 1508 "dataflow_generate.g"
		
		if (boost::algorithm::iequals(id->getText().c_str(), "service"))
		{
		if (av->getType() != STRING_LITERAL)
		{
		reportInvalidArgumentValue(op, id, av, L"Expected a string.");
		}
		std::wstring wstrArg=ASCIIToWide(av->getText().substr(1, av->getText().size()-2));
		services.push_back(wstrArg);
		}
		else if (boost::algorithm::iequals(id->getText().c_str(), "key"))
		{
		if (av->getType() != STRING_LITERAL)
		{
		reportInvalidArgumentValue(op, id, av, L"Expected a string.");
		}
		std::wstring wstrArg=ASCIIToWide(av->getText().substr(1, av->getText().size()-2));
		keys.push_back(wstrArg);
		}
		else if (boost::algorithm::iequals(id->getText().c_str(), "stageOnly"))
		{
		if (av->getType() != TK_TRUE && av->getType() != TK_FALSE)
		{
		reportInvalidArgumentValue(op, id, av, L"Expected true or false.");
		}
		op->SetStageOnly(av->getType() == TK_TRUE);
		}
		else if (boost::algorithm::iequals(id->getText().c_str(), "targetCommitSize"))
		{
		if (av->getType() != NUM_INT)
		{
		reportInvalidArgumentValue(op, id, av, L"Expected an integer.");
		}
		boost::int32_t val(boost::lexical_cast<boost::int32_t>(av->getText()));
		op->SetTargetCommitSize(val);
		}
		else if (boost::algorithm::iequals(id->getText().c_str(), "targetMessageSize"))
		{
		if (av->getType() != NUM_INT)
		{
		reportInvalidArgumentValue(op, id, av, L"Expected an integer.");
		}
		boost::int32_t val(boost::lexical_cast<boost::int32_t>(av->getText()));
		op->SetTargetMessageSize(val);
		}
		else if (boost::algorithm::iequals(id->getText().c_str(), "collectionID"))
		{
		if (av->getType() != NUM_INT ||
		av->getText().size() != 34 ||
		av->getText().substr(0,2) != std::string("0x"))
		{
		reportInvalidArgumentValue(op, id, av, L"Expected a binary(16) value.");
		}
		std::vector<boost::uint8_t> val;
		for(std::size_t idx=2; idx<34; idx+=2)
		{
		boost::uint32_t tmp1 = GetHexValue(av->getText()[idx]);
		if (tmp1 > 15) 
		{
		reportInvalidArgumentValue(op, id, av, L"Expected a binary(16) value.");
		}
		
		boost::uint32_t tmp2 = GetHexValue(av->getText()[idx+1]);
		if (tmp2 > 15) 
		{
		reportInvalidArgumentValue(op, id, av, L"Expected a binary(16) value.");
		}
		val.push_back((boost::uint8_t)((tmp1<<4) + tmp2));
		}
		op->SetCollectionID(val);
		}
		
		else if (boost::algorithm::iequals(id->getText().c_str(), 
		"collectionIDEncoded"))
		{
		if (av->getType() != STRING_LITERAL)
		{
		reportInvalidArgumentValue(op, id, av, L"Expected a string.");
		}
		
		std::string encoded = av->getText().substr(1, av->getText().size()-2);
		
		processCollectionIDEncodedParameter(op, id, encoded);
		}
		
		else if (boost::algorithm::iequals(id->getText().c_str(), "generateSummaryTable"))
		{
		if (av->getType() != TK_TRUE && av->getType() != TK_FALSE)
		{
		reportInvalidArgumentValue(op, id, av, L"Expected true or false.");
		}
		op->SetGenerateSummaryTable(av->getType() == TK_TRUE);
		}
		
		else if (boost::algorithm::iequals(id->getText().c_str(), "areEnumsBeingUsed"))
		{
		if (av->getType() != TK_TRUE && av->getType() != TK_FALSE)
		{
		reportInvalidArgumentValue(op, id, av, L"Expected true or false.");
		}
		op->SetAreEnumsBeingUsed(av->getType() == TK_TRUE);
		}
		else if (boost::algorithm::iequals(id->getText().c_str(), "mode"))
		{
		processModeParameter(op, id, av);
		}
		else if (boost::algorithm::iequals(id->getText().c_str(), "isAuthorizationNeeded"))
		{
		if (av->getType() != TK_TRUE && av->getType() != TK_FALSE)
		{
		reportInvalidArgumentValue(op, id, av, L"Expected true or false.");
		}
		op->SetIsAuthNeeded(av->getType() == TK_TRUE);
		}
		else
		{
		throw (DataflowInvalidArgumentException(
		id->getLine(),
		id->getColumn(),
		mFilename,
		op->GetName(),
		ASCIIToWide(id->getText())));
		}
		
#line 6050 "DataflowTreeGenerator.cpp"
		break;
	}
	case DOLLAR_SIGN:
	{
		RefMyAST tmp113_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),DOLLAR_SIGN);
		_t = _t->getNextSibling();
		variableId = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
#line 1634 "dataflow_generate.g"
		
		// We only support the use of the $<name> argument for the 
		// encoded collection ID.
		if (!boost::algorithm::iequals(id->getText().c_str(), 
		"collectionIDEncoded"))
		{
		reportInvalidArgument(op, id, 
		L"You can only use the $variable for collectionIDEncoded.");
		}
		
		// Get the environment so we know how to convert this
		// $<name> into a string value.
		ArgEnvironment *env = ArgEnvironment::getActiveEnvironment();
		std::wstring wideStr = env->getValue(ASCIIToWide(variableId->getText()));
		std::string encoded;
		::WideStringToUTF8(wideStr, encoded);
		
		processCollectionIDEncodedParameter(op, id, encoded);
		
#line 6081 "DataflowTreeGenerator.cpp"
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	_t = __t202;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowTreeGenerator::compositeArgument(RefMyAST _t,
	const CompositeDefinition* defn,
                  DesignTimeComposite *op
) {
	RefMyAST compositeArgument_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST av = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST variableId = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 2294 "dataflow_generate.g"
	
	OperatorArg* opArgSubList = NULL;
	
#line 6107 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t372 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
	_t = _t->getFirstChild();
#line 2301 "dataflow_generate.g"
	
	// Make sure that the referenced composite argument exists.
	if (!defn->doesArgExist(ASCIIToWide(id->getText())))
	{
	throw (DataflowInvalidArgumentException(
	id->getLine(),
	id->getColumn(),
	mFilename,
	op->GetName(),
	ASCIIToWide(id->getText())));
	}
	
	
#line 6127 "DataflowTreeGenerator.cpp"
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
	case NUM_INT:
	{
		av = (_t == ASTNULL) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
		nodeArgumentValue(_t);
		_t = _retTree;
#line 2316 "dataflow_generate.g"
		
		OperatorArg *arg = formOperatorArg(id, av);
		
		// The DesignTimeComposite is given ownership of the pointer.
		op->addArg(arg);
		
#line 6150 "DataflowTreeGenerator.cpp"
		break;
	}
	case 3:
	case ID:
	{
		{ // ( ... )*
		for (;;) {
			if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
				_t = ASTNULL;
			if ((_t->getType() == ID)) {
				operatorArgumentList(_t,&opArgSubList);
				_t = _retTree;
			}
			else {
				goto _loop375;
			}
			
		}
		_loop375:;
		} // ( ... )*
#line 2325 "dataflow_generate.g"
		
		opArgSubList->setName(ASCIIToWide(id->getText()),
		id->getLine(),
		id->getColumn());
		// The DesignTimeComposite is given ownership of the pointer.
		op->addArg(opArgSubList);
		
#line 6179 "DataflowTreeGenerator.cpp"
		break;
	}
	case DOLLAR_SIGN:
	{
		RefMyAST tmp114_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),DOLLAR_SIGN);
		_t = _t->getNextSibling();
		variableId = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
		_t = _t->getNextSibling();
#line 2335 "dataflow_generate.g"
		
		OperatorArgType argType = defn->getArgType(ASCIIToWide(id->getText()));
		
		OperatorArg *arg = new OperatorArg(OPERATOR_ARG_TYPE_VARIABLE,
		ASCIIToWide(id->getText()), 
		ASCIIToWide(variableId->getText()),
		argType,
		variableId->getLine(), 
		variableId->getColumn(),
		id->getLine(), 
		id->getColumn(),
		mFilename);
		
		op->addArg(arg);
		
#line 6206 "DataflowTreeGenerator.cpp"
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	}
	_t = __t372;
	_t = _t->getNextSibling();
	_retTree = _t;
}

boost::tuple<std::wstring, boost::variant<int,std::wstring>, int, int >   DataflowTreeGenerator::arrowOrRefStatement(RefMyAST _t) {
#line 2411 "dataflow_generate.g"
	boost::tuple<std::wstring, boost::variant<int,std::wstring>, int, int >  rhs;
#line 6223 "DataflowTreeGenerator.cpp"
	RefMyAST arrowOrRefStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
#line 2411 "dataflow_generate.g"
	
	boost::tuple<std::wstring, boost::variant<int,std::wstring>, int, int > lhs;
	bool buffered = true;
	
#line 6230 "DataflowTreeGenerator.cpp"
	
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case ARROW:
	{
		RefMyAST __t381 = _t;
		RefMyAST tmp115_AST_in = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ARROW);
		_t = _t->getFirstChild();
		lhs=arrowOrRefStatement(_t);
		_t = _retTree;
		{
		if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case LBRACKET:
		{
			buffered=arrowArguments(_t);
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
		_t = __t381;
		_t = _t->getNextSibling();
#line 2418 "dataflow_generate.g"
		
		std::map<std::wstring,DataflowSymbol >::const_iterator leftIt(mActiveSymbolTable->find(lhs.get<0>()));
		std::map<std::wstring,DataflowSymbol >::const_iterator rightIt(mActiveSymbolTable->find(rhs.get<0>()));
		
		// Verify operator exists
		if (leftIt == mActiveSymbolTable->end())
		throw DataflowArrowUndefOperatorException(lhs.get<0>(), lhs.get<2>(), 
		lhs.get<3>(), mFilename);
		if (rightIt == mActiveSymbolTable->end())
		throw DataflowArrowUndefOperatorException(rhs.get<0>(), rhs.get<2>(), 
		lhs.get<3>(), mFilename);
		
		// Verify that the referenced ports exists
		verifyPortExists(leftIt->second.Op->GetOutputPorts(), lhs, false);
		verifyPortExists(rightIt->second.Op->GetInputPorts(), rhs, true);
		
		boost::shared_ptr<Port> lhsPort (
		lhs.get<1>().which() == 0 ? 
				leftIt->second.Op->GetOutputPorts()[boost::get<int>(lhs.get<1>())] :
				leftIt->second.Op->GetOutputPorts()[boost::get<std::wstring>(lhs.get<1>())]);
		
		boost::shared_ptr<Port> rhsPort (
		rhs.get<1>().which() == 0 ? 
				rightIt->second.Op->GetInputPorts()[boost::get<int>(rhs.get<1>())] :
				rightIt->second.Op->GetInputPorts()[boost::get<std::wstring>(rhs.get<1>())]);
		
		mActivePlan->push_back(new DesignTimeChannel(lhsPort, rhsPort, buffered));
		
#line 6296 "DataflowTreeGenerator.cpp"
		break;
	}
	case ID:
	{
		rhs=nodeRefStatement(_t);
		_t = _retTree;
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(ANTLR_USE_NAMESPACE(antlr)RefAST(_t));
	}
	}
	_retTree = _t;
	return rhs;
}

bool  DataflowTreeGenerator::arrowArguments(RefMyAST _t) {
#line 2489 "dataflow_generate.g"
	bool buffered;
#line 6317 "DataflowTreeGenerator.cpp"
	RefMyAST arrowArguments_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	
	RefMyAST __t387 = _t;
	RefMyAST tmp116_AST_in = _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),LBRACKET);
	_t = _t->getFirstChild();
	buffered=arrowBufferArgument(_t);
	_t = _retTree;
	_t = __t387;
	_t = _t->getNextSibling();
	_retTree = _t;
	return buffered;
}

boost::tuple<std::wstring, boost::variant<int,std::wstring>, int, int >  DataflowTreeGenerator::nodeRefStatement(RefMyAST _t) {
#line 2451 "dataflow_generate.g"
	boost::tuple<std::wstring, boost::variant<int,std::wstring>, int, int > t;
#line 6335 "DataflowTreeGenerator.cpp"
	RefMyAST nodeRefStatement_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST i = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST s = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 2451 "dataflow_generate.g"
	
	std::wstring nodeName;
	int portIndex(0);
	std::wstring portName;
	int lineNumber;
	int columnNumber;
	
#line 6348 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t384 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
	_t = _t->getFirstChild();
#line 2461 "dataflow_generate.g"
	
	nodeName = ASCIIToWide(id->getText());
	lineNumber = id->getLine();
	columnNumber = id->getColumn();
	
#line 6360 "DataflowTreeGenerator.cpp"
	{
	if (_t == RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case NUM_INT:
	{
		i = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),NUM_INT);
		_t = _t->getNextSibling();
#line 2467 "dataflow_generate.g"
		
		portIndex = boost::lexical_cast<int>(i->getText()); 
		
#line 6374 "DataflowTreeGenerator.cpp"
		break;
	}
	case STRING_LITERAL:
	{
		s = _t;
		match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),STRING_LITERAL);
		_t = _t->getNextSibling();
#line 2472 "dataflow_generate.g"
		
		portName = ASCIIToWide(s->getText().substr(1, s->getText().size()-2));
		
#line 6386 "DataflowTreeGenerator.cpp"
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
	_t = __t384;
	_t = _t->getNextSibling();
#line 2477 "dataflow_generate.g"
	
	if (portName.size() != 0)
	{
	t = boost::tuple<std::wstring, boost::variant<int,std::wstring>, int, int >(nodeName, portName, lineNumber, columnNumber);
	}
	else
	{
	t = boost::tuple<std::wstring, boost::variant<int,std::wstring>, int, int >(nodeName, portIndex, lineNumber, columnNumber);
	}
	
#line 6412 "DataflowTreeGenerator.cpp"
	_retTree = _t;
	return t;
}

bool  DataflowTreeGenerator::arrowBufferArgument(RefMyAST _t) {
#line 2494 "dataflow_generate.g"
	bool buffered;
#line 6420 "DataflowTreeGenerator.cpp"
	RefMyAST arrowBufferArgument_AST_in = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	RefMyAST id = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
	RefMyAST av = RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST);
#line 2494 "dataflow_generate.g"
	
	buffered = true;
	
#line 6428 "DataflowTreeGenerator.cpp"
	
	RefMyAST __t389 = _t;
	id = (_t == RefMyAST(ASTNULL)) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	match(ANTLR_USE_NAMESPACE(antlr)RefAST(_t),ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? RefMyAST(ANTLR_USE_NAMESPACE(antlr)nullAST) : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t389;
	_t = _t->getNextSibling();
#line 2500 "dataflow_generate.g"
	
	if (boost::algorithm::iequals(id->getText().c_str(), "buffered"))
	{
	if (av->getType() != TK_TRUE && av->getType() != TK_FALSE)
	{
	throw DataflowInvalidArrowArgumentValueException(
	id->getLine(), id->getColumn(), mFilename,
	ASCIIToWide(id->getText()), ASCIIToWide(av->getText()), L"Expected true or false.");
	}
	buffered = av->getType() == TK_TRUE;
	}
	
#line 6452 "DataflowTreeGenerator.cpp"
	_retTree = _t;
	return buffered;
}

void DataflowTreeGenerator::initializeASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& )
{
}
const char* DataflowTreeGenerator::tokenNames[] = {
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

const unsigned long DataflowTreeGenerator::_tokenSet_0_data_[] = { 75497474UL, 0UL, 4294965246UL, 1945894911UL, 0UL, 0UL, 0UL, 0UL };
// EOF "steps" ARROW ACCOUNT_RESOLUTION BROADCAST COLL COMPOSITE COPY DEVNULL 
// EXPORT EXPORT_QUEUE EXPR FILTER GROUP_BY HASHPART HASH_RUNNING_TOTAL 
// ID_GENERATOR IMPORT IMPORT_QUEUE INNER_HASH_JOIN INNER_MERGE_JOIN INSERT 
// LOAD_ERROR LOAD_USAGE LONGEST_PREFIX_MATCH MD5 METER MULTI_HASH_JOIN 
// PRINT PROJECTION RANGEPART RATE_CALCULATION RATE_SCHEDULE_RESOLUTION 
// RENAME RIGHT_MERGE_ANTI_SEMI_JOIN RIGHT_MERGE_SEMI_JOIN RIGHT_OUTER_HASH_JOIN 
// RIGHT_OUTER_MERGE_JOIN SELECT SEQUENTIAL_FILE_DELETE SEQUENTIAL_FILE_OUTPUT 
// SEQUENTIAL_FILE_RENAME SEQUENTIAL_FILE_SCAN SESSION_SET_BUILDER SORT 
// SORT_GROUP_BY SORTMERGE SORTMERGECOLL SORT_NEST SORT_ORDER_ASSERT SORT_RUNNING_TOTAL 
// SUBSCRIPTION_RESOLUTION SQL_EXEC_DIRECT SWITCH TAXWARE UNION_ALL UNNEST 
// UNROLL WRITE_ERROR WRITE_PRODUCT_VIEW DELAYED_GENERATE 
const ANTLR_USE_NAMESPACE(antlr)BitSet DataflowTreeGenerator::_tokenSet_0(_tokenSet_0_data_,8);


