/* $ANTLR 2.7.6 (2005-12-22): "dataflow_annotator.g" -> "DataflowAnnotator.cpp"$ */
#include "DataflowAnnotator.hpp"
#include <antlr/Token.hpp>
#include <antlr/AST.hpp>
#include <antlr/NoViableAltException.hpp>
#include <antlr/MismatchedTokenException.hpp>
#include <antlr/SemanticException.hpp>
#include <antlr/BitSet.hpp>
#line 1 "dataflow_annotator.g"
#line 11 "DataflowAnnotator.cpp"
DataflowAnnotator::DataflowAnnotator()
	: ANTLR_USE_NAMESPACE(antlr)TreeParser() {
}

void DataflowAnnotator::program(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST program_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
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
		case SEQUENTIAL_FILE_OUTPUT:
		{
			sequentialFileOutputStatement(_t);
			_t = _retTree;
			break;
		}
		case SEQUENTIAL_FILE_SCAN:
		{
			sequentialFileScanStatement(_t);
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
		case SQL_EXEC_DIRECT:
		{
			sqlExecDirectStatement(_t);
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
		case UNROLL:
		{
			unrollStatement(_t);
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
			goto _loop3;
		}
		}
	}
	_loop3:;
	} // ( ... )*
	_retTree = _t;
}

void DataflowAnnotator::broadcastStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST broadcastStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 287 "dataflow_annotator.g"
	
	
#line 275 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t5 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,BROADCAST);
	_t = _t->getFirstChild();
#line 292 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": broadcast ";
	outputStatementOpen(id);
	
#line 286 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			broadcastArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop7;
		}
		
	}
	_loop7:;
	} // ( ... )*
#line 298 "dataflow_annotator.g"
	
	
#line 305 "DataflowAnnotator.cpp"
#line 301 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 310 "DataflowAnnotator.cpp"
	_t = __t5;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::collStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST collStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 315 "dataflow_annotator.g"
	
	
#line 322 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t11 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,COLL);
	_t = _t->getFirstChild();
#line 320 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": coll ";
	outputStatementOpen(id);
	
#line 333 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			collArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop13;
		}
		
	}
	_loop13:;
	} // ( ... )*
#line 325 "dataflow_annotator.g"
	
	
#line 352 "DataflowAnnotator.cpp"
#line 328 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 357 "DataflowAnnotator.cpp"
	_t = __t11;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::copyStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST copyStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 342 "dataflow_annotator.g"
	
	
#line 369 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t17 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,COPY);
	_t = _t->getFirstChild();
#line 347 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": copy;\n";
	
#line 379 "DataflowAnnotator.cpp"
	_t = __t17;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::devNullStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST devNullStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 353 "dataflow_annotator.g"
	
	
#line 391 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t19 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,DEVNULL);
	_t = _t->getFirstChild();
#line 358 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": devNull ";
	outputStatementOpen(id);
	
#line 402 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			devNullArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop21;
		}
		
	}
	_loop21:;
	} // ( ... )*
#line 363 "dataflow_annotator.g"
	
	
#line 421 "DataflowAnnotator.cpp"
#line 366 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 426 "DataflowAnnotator.cpp"
	_t = __t19;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::exportStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST exportStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 408 "dataflow_annotator.g"
	
	
#line 438 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t31 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,EXPORT);
	_t = _t->getFirstChild();
#line 413 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": export";
	outputStatementOpen(id);
	
#line 449 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			exportArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop33;
		}
		
	}
	_loop33:;
	} // ( ... )*
#line 418 "dataflow_annotator.g"
	
	
#line 468 "DataflowAnnotator.cpp"
#line 421 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 473 "DataflowAnnotator.cpp"
	_t = __t31;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::exportQueueStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST exportQueueStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 435 "dataflow_annotator.g"
	
	
#line 485 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t37 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,EXPORT_QUEUE);
	_t = _t->getFirstChild();
#line 440 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": export_queue";
	outputStatementOpen(id);
	
#line 496 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			exportQueueArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop39;
		}
		
	}
	_loop39:;
	} // ( ... )*
#line 445 "dataflow_annotator.g"
	
	
#line 515 "DataflowAnnotator.cpp"
#line 448 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 520 "DataflowAnnotator.cpp"
	_t = __t37;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::exprStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST exprStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 462 "dataflow_annotator.g"
	
	
#line 532 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t43 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,EXPR);
	_t = _t->getFirstChild();
#line 467 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": expr";
	outputStatementOpen(id);
	
#line 543 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			exprArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop45;
		}
		
	}
	_loop45:;
	} // ( ... )*
#line 472 "dataflow_annotator.g"
	
	
#line 562 "DataflowAnnotator.cpp"
#line 475 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 567 "DataflowAnnotator.cpp"
	_t = __t43;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::filterStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST filterStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 489 "dataflow_annotator.g"
	
	
#line 579 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t49 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,FILTER);
	_t = _t->getFirstChild();
#line 494 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": filter";
	outputStatementOpen(id);
	
#line 590 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			filterArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop51;
		}
		
	}
	_loop51:;
	} // ( ... )*
#line 499 "dataflow_annotator.g"
	
	
#line 609 "DataflowAnnotator.cpp"
#line 502 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 614 "DataflowAnnotator.cpp"
	_t = __t49;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::delayedGenerateStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST delayedGenerateStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST g = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t55 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp1_AST_in = _t;
	match(_t,DELAYED_GENERATE);
	_t = _t->getFirstChild();
	g = _t;
	match(_t,GENERATE);
	_t = _t->getNextSibling();
	_t = __t55;
	_t = _t->getNextSibling();
#line 519 "dataflow_annotator.g"
	
	if ((*mSymbol)[g->getText()].NumInputs == 0)
	{
	generateStatement(g);
	}
	else
	{
	expressionGenerateStatement(g);
	}
	
#line 644 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::groupByStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST groupByStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 583 "dataflow_annotator.g"
	
	
#line 654 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t69 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,GROUP_BY);
	_t = _t->getFirstChild();
#line 588 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": group_by";
	outputStatementOpen(id);
	
#line 665 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			groupByArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop71;
		}
		
	}
	_loop71:;
	} // ( ... )*
#line 593 "dataflow_annotator.g"
	
	
#line 684 "DataflowAnnotator.cpp"
#line 596 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 689 "DataflowAnnotator.cpp"
	_t = __t69;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::hashPartStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST hashPartStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 610 "dataflow_annotator.g"
	
	
#line 701 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t75 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,HASHPART);
	_t = _t->getFirstChild();
#line 615 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": hash_part";
	outputStatementOpen(id);
	
#line 712 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			hashPartArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop77;
		}
		
	}
	_loop77:;
	} // ( ... )*
#line 620 "dataflow_annotator.g"
	
	
#line 731 "DataflowAnnotator.cpp"
#line 623 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 736 "DataflowAnnotator.cpp"
	_t = __t75;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::hashRunningTotalStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST hashRunningTotalStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 637 "dataflow_annotator.g"
	
	std::vector<std::wstring> groupByKeys;
	
#line 749 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t81 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,HASH_RUNNING_TOTAL);
	_t = _t->getFirstChild();
#line 643 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": hash_running_total";
	outputStatementOpen(id);
	
#line 760 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			hashRunningTotalArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop83;
		}
		
	}
	_loop83:;
	} // ( ... )*
#line 648 "dataflow_annotator.g"
	
	
#line 779 "DataflowAnnotator.cpp"
#line 651 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 784 "DataflowAnnotator.cpp"
	_t = __t81;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::importStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST importStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 665 "dataflow_annotator.g"
	
	
#line 796 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t87 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,IMPORT);
	_t = _t->getFirstChild();
#line 670 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": import";
	outputStatementOpen(id);
	
#line 807 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			importArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop89;
		}
		
	}
	_loop89:;
	} // ( ... )*
#line 675 "dataflow_annotator.g"
	
	
#line 826 "DataflowAnnotator.cpp"
#line 678 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 831 "DataflowAnnotator.cpp"
	_t = __t87;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::importQueueStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST importQueueStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 692 "dataflow_annotator.g"
	
	
#line 843 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t93 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,IMPORT_QUEUE);
	_t = _t->getFirstChild();
#line 697 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": import_queue";
	outputStatementOpen(id);
	
#line 854 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			importQueueArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop95;
		}
		
	}
	_loop95:;
	} // ( ... )*
#line 702 "dataflow_annotator.g"
	
	
#line 873 "DataflowAnnotator.cpp"
#line 705 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 878 "DataflowAnnotator.cpp"
	_t = __t93;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::innerHashJoinStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST innerHashJoinStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 719 "dataflow_annotator.g"
	
	
#line 890 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t99 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,INNER_HASH_JOIN);
	_t = _t->getFirstChild();
#line 724 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": inner_hash_join";
	outputStatementOpen(id);
	
#line 901 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			innerHashJoinArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop101;
		}
		
	}
	_loop101:;
	} // ( ... )*
#line 729 "dataflow_annotator.g"
	
	
#line 920 "DataflowAnnotator.cpp"
#line 732 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 925 "DataflowAnnotator.cpp"
	_t = __t99;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::innerMergeJoinStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST innerMergeJoinStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 746 "dataflow_annotator.g"
	
	
#line 937 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t105 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,INNER_MERGE_JOIN);
	_t = _t->getFirstChild();
#line 751 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": inner_merge_join";
	outputStatementOpen(id);
	
#line 948 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			innerMergeJoinArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop107;
		}
		
	}
	_loop107:;
	} // ( ... )*
#line 756 "dataflow_annotator.g"
	
	
#line 967 "DataflowAnnotator.cpp"
#line 759 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 972 "DataflowAnnotator.cpp"
	_t = __t105;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::insertStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST insertStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 773 "dataflow_annotator.g"
	
	
#line 984 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t111 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,INSERT);
	_t = _t->getFirstChild();
#line 778 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": insert";
	outputStatementOpen(id);
	
#line 995 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			insertArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop113;
		}
		
	}
	_loop113:;
	} // ( ... )*
#line 783 "dataflow_annotator.g"
	
	
#line 1014 "DataflowAnnotator.cpp"
#line 786 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 1019 "DataflowAnnotator.cpp"
	_t = __t111;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::meterStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST meterStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 800 "dataflow_annotator.g"
	
	
#line 1031 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t117 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,METER);
	_t = _t->getFirstChild();
#line 805 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": meter";
	outputStatementOpen(id);
	
#line 1042 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			meterArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop119;
		}
		
	}
	_loop119:;
	} // ( ... )*
#line 810 "dataflow_annotator.g"
	
	
#line 1061 "DataflowAnnotator.cpp"
#line 813 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 1066 "DataflowAnnotator.cpp"
	_t = __t117;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::multiHashJoinStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST multiHashJoinStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 827 "dataflow_annotator.g"
	
	
#line 1078 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t123 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,MULTI_HASH_JOIN);
	_t = _t->getFirstChild();
#line 832 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": multi_hash_join";
	outputStatementOpen(id);
	
#line 1089 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			multiHashJoinArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop125;
		}
		
	}
	_loop125:;
	} // ( ... )*
#line 837 "dataflow_annotator.g"
	
	
#line 1108 "DataflowAnnotator.cpp"
#line 840 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 1113 "DataflowAnnotator.cpp"
	_t = __t123;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::printStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST printStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 854 "dataflow_annotator.g"
	
	
#line 1125 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t129 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,PRINT);
	_t = _t->getFirstChild();
#line 859 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": print ";
	outputStatementOpen(id);
	
#line 1136 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			printArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop131;
		}
		
	}
	_loop131:;
	} // ( ... )*
#line 865 "dataflow_annotator.g"
	
	
#line 1155 "DataflowAnnotator.cpp"
#line 868 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 1160 "DataflowAnnotator.cpp"
	_t = __t129;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::projectionStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST projectionStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 882 "dataflow_annotator.g"
	
	
#line 1172 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t135 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,PROJECTION);
	_t = _t->getFirstChild();
#line 887 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": project";
	outputStatementOpen(id);
	
#line 1183 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			projectionArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop137;
		}
		
	}
	_loop137:;
	} // ( ... )*
#line 892 "dataflow_annotator.g"
	
	
#line 1202 "DataflowAnnotator.cpp"
#line 895 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 1207 "DataflowAnnotator.cpp"
	_t = __t135;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::renameStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST renameStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 909 "dataflow_annotator.g"
	
	
#line 1219 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t141 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,RENAME);
	_t = _t->getFirstChild();
#line 914 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": rename";
	outputStatementOpen(id);
	
#line 1230 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			renameArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop143;
		}
		
	}
	_loop143:;
	} // ( ... )*
#line 919 "dataflow_annotator.g"
	
	
#line 1249 "DataflowAnnotator.cpp"
#line 922 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 1254 "DataflowAnnotator.cpp"
	_t = __t141;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::rightMergeAntiSemiJoinStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST rightMergeAntiSemiJoinStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 936 "dataflow_annotator.g"
	
	
#line 1266 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t147 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,RIGHT_MERGE_ANTI_SEMI_JOIN);
	_t = _t->getFirstChild();
#line 941 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": right_merge_anti_semi_join";
	outputStatementOpen(id);
	
#line 1277 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			rightMergeAntiSemiJoinArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop149;
		}
		
	}
	_loop149:;
	} // ( ... )*
#line 946 "dataflow_annotator.g"
	
	
#line 1296 "DataflowAnnotator.cpp"
#line 949 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 1301 "DataflowAnnotator.cpp"
	_t = __t147;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::rightMergeSemiJoinStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST rightMergeSemiJoinStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 963 "dataflow_annotator.g"
	
	
#line 1313 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t153 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,RIGHT_MERGE_SEMI_JOIN);
	_t = _t->getFirstChild();
#line 968 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": right_merge_semi_join";
	outputStatementOpen(id);
	
#line 1324 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			rightMergeSemiJoinArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop155;
		}
		
	}
	_loop155:;
	} // ( ... )*
#line 973 "dataflow_annotator.g"
	
	
#line 1343 "DataflowAnnotator.cpp"
#line 976 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 1348 "DataflowAnnotator.cpp"
	_t = __t153;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::rightOuterHashJoinStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST rightOuterHashJoinStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 990 "dataflow_annotator.g"
	
	
#line 1360 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t159 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,RIGHT_OUTER_HASH_JOIN);
	_t = _t->getFirstChild();
#line 995 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": right_outer_hash_join";
	outputStatementOpen(id);
	
#line 1371 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			rightOuterHashJoinArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop161;
		}
		
	}
	_loop161:;
	} // ( ... )*
#line 1000 "dataflow_annotator.g"
	
	
#line 1390 "DataflowAnnotator.cpp"
#line 1003 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 1395 "DataflowAnnotator.cpp"
	_t = __t159;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::rightOuterMergeJoinStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST rightOuterMergeJoinStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1017 "dataflow_annotator.g"
	
	
#line 1407 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t165 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,RIGHT_OUTER_MERGE_JOIN);
	_t = _t->getFirstChild();
#line 1022 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": right_outer_merge_join";
	outputStatementOpen(id);
	
#line 1418 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			rightOuterMergeJoinArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop167;
		}
		
	}
	_loop167:;
	} // ( ... )*
#line 1027 "dataflow_annotator.g"
	
	
#line 1437 "DataflowAnnotator.cpp"
#line 1030 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 1442 "DataflowAnnotator.cpp"
	_t = __t165;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::selectStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST selectStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 380 "dataflow_annotator.g"
	
	
#line 1454 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t25 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,SELECT);
	_t = _t->getFirstChild();
#line 385 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": select ";
	outputStatementOpen(id);
	
#line 1465 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			selectArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop27;
		}
		
	}
	_loop27:;
	} // ( ... )*
#line 391 "dataflow_annotator.g"
	
	
#line 1484 "DataflowAnnotator.cpp"
#line 394 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 1489 "DataflowAnnotator.cpp"
	_t = __t25;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::sequentialFileOutputStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sequentialFileOutputStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1044 "dataflow_annotator.g"
	
	
#line 1501 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t171 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,SEQUENTIAL_FILE_OUTPUT);
	_t = _t->getFirstChild();
#line 1049 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": sequential_file_write";
	outputStatementOpen(id);
	
#line 1512 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			sequentialFileOutputArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop173;
		}
		
	}
	_loop173:;
	} // ( ... )*
#line 1054 "dataflow_annotator.g"
	
	
#line 1531 "DataflowAnnotator.cpp"
#line 1057 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 1536 "DataflowAnnotator.cpp"
	_t = __t171;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::sequentialFileScanStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sequentialFileScanStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1071 "dataflow_annotator.g"
	
	
#line 1548 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t177 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,SEQUENTIAL_FILE_SCAN);
	_t = _t->getFirstChild();
#line 1076 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": sequential_file_scan";
	outputStatementOpen(id);
	
#line 1559 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			sequentialFileScanArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop179;
		}
		
	}
	_loop179:;
	} // ( ... )*
#line 1081 "dataflow_annotator.g"
	
	
#line 1578 "DataflowAnnotator.cpp"
#line 1084 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 1583 "DataflowAnnotator.cpp"
	_t = __t177;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::sortStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sortStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1098 "dataflow_annotator.g"
	
	
#line 1595 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t183 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,SORT);
	_t = _t->getFirstChild();
#line 1103 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": sort";
	outputStatementOpen(id);
	
#line 1606 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			sortArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop185;
		}
		
	}
	_loop185:;
	} // ( ... )*
#line 1108 "dataflow_annotator.g"
	
	
#line 1625 "DataflowAnnotator.cpp"
#line 1111 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 1630 "DataflowAnnotator.cpp"
	_t = __t183;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::sortGroupByStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sortGroupByStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1125 "dataflow_annotator.g"
	
	
#line 1642 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t189 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,SORT_GROUP_BY);
	_t = _t->getFirstChild();
#line 1130 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": sort_group_by";
	outputStatementOpen(id);
	
#line 1653 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			sortGroupByArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop191;
		}
		
	}
	_loop191:;
	} // ( ... )*
#line 1135 "dataflow_annotator.g"
	
	
#line 1672 "DataflowAnnotator.cpp"
#line 1138 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 1677 "DataflowAnnotator.cpp"
	_t = __t189;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::sortMergeStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sortMergeStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1152 "dataflow_annotator.g"
	
	
#line 1689 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t195 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,SORTMERGE);
	_t = _t->getFirstChild();
#line 1157 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": sort_merge";
	outputStatementOpen(id);
	
#line 1700 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			sortMergeArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop197;
		}
		
	}
	_loop197:;
	} // ( ... )*
#line 1162 "dataflow_annotator.g"
	
	
	{
	outputStatementClose(id);
	}
	
#line 1723 "DataflowAnnotator.cpp"
	_t = __t195;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::sortMergeCollStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sortMergeCollStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1179 "dataflow_annotator.g"
	
	
#line 1735 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t201 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,SORTMERGECOLL);
	_t = _t->getFirstChild();
#line 1184 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": sort_merge_col";
	outputStatementOpen(id);
	
#line 1746 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			sortMergeCollArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop203;
		}
		
	}
	_loop203:;
	} // ( ... )*
#line 1189 "dataflow_annotator.g"
	
	
#line 1765 "DataflowAnnotator.cpp"
#line 1192 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 1770 "DataflowAnnotator.cpp"
	_t = __t201;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::sqlExecDirectStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sqlExecDirectStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1206 "dataflow_annotator.g"
	
	
#line 1782 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t207 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,SQL_EXEC_DIRECT);
	_t = _t->getFirstChild();
#line 1211 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": sql_exec_direct";
	outputStatementOpen(id);
	
#line 1793 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			sqlExecDirectStatementList(_t);
			_t = _retTree;
		}
		else {
			goto _loop209;
		}
		
	}
	_loop209:;
	} // ( ... )*
#line 1216 "dataflow_annotator.g"
	
	
#line 1812 "DataflowAnnotator.cpp"
#line 1218 "dataflow_annotator.g"
	
	std::cout << "];\n";
	
#line 1817 "DataflowAnnotator.cpp"
	_t = __t207;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::switchStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST switchStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1252 "dataflow_annotator.g"
	
	
#line 1829 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t217 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,SWITCH);
	_t = _t->getFirstChild();
#line 1257 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": switch";
	outputStatementOpen(id);
	
#line 1840 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			switchArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop219;
		}
		
	}
	_loop219:;
	} // ( ... )*
#line 1262 "dataflow_annotator.g"
	
	
#line 1859 "DataflowAnnotator.cpp"
#line 1265 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 1864 "DataflowAnnotator.cpp"
	_t = __t217;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::taxwareStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST taxwareStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1279 "dataflow_annotator.g"
	
	
#line 1876 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t223 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,TAXWARE);
	_t = _t->getFirstChild();
#line 1284 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": taxware";
	outputStatementOpen(id);
	
#line 1887 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			taxwareArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop225;
		}
		
	}
	_loop225:;
	} // ( ... )*
#line 1290 "dataflow_annotator.g"
	
	
#line 1906 "DataflowAnnotator.cpp"
#line 1293 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 1911 "DataflowAnnotator.cpp"
	_t = __t223;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::unionAllStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST unionAllStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1307 "dataflow_annotator.g"
	
	
#line 1923 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t229 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,UNION_ALL);
	_t = _t->getFirstChild();
#line 1312 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": union_all";
	outputStatementOpen(id);
	
#line 1934 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			unionAllArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop231;
		}
		
	}
	_loop231:;
	} // ( ... )*
#line 1317 "dataflow_annotator.g"
	
	
#line 1953 "DataflowAnnotator.cpp"
#line 1320 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 1958 "DataflowAnnotator.cpp"
	_t = __t229;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::unrollStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST unrollStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1334 "dataflow_annotator.g"
	
	
#line 1970 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t235 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,UNROLL);
	_t = _t->getFirstChild();
#line 1339 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": unroll";
	outputStatementOpen(id);
	
#line 1981 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			unrollArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop237;
		}
		
	}
	_loop237:;
	} // ( ... )*
#line 1344 "dataflow_annotator.g"
	
	
#line 2000 "DataflowAnnotator.cpp"
#line 1347 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 2005 "DataflowAnnotator.cpp"
	_t = __t235;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::edgeStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST edgeStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
#line 1361 "dataflow_annotator.g"
	
	boost::tuple<std::string, boost::variant<int,std::string>, bool > lhs;
	boost::tuple<std::string, boost::variant<int,std::string>, bool > rhs;
	bool buffered = true;
	bool isBufferedArgPresent = false;
	
#line 2020 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t241 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp2_AST_in = _t;
	match(_t,ARROW);
	_t = _t->getFirstChild();
	lhs=arrowOrRefStatement(_t);
	_t = _retTree;
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case LBRACKET:
	{
		buffered=arrowArguments(_t);
		_t = _retTree;
#line 1370 "dataflow_annotator.g"
		
		isBufferedArgPresent = true;
		
#line 2040 "DataflowAnnotator.cpp"
		break;
	}
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	}
	rhs=nodeRefStatement(_t);
	_t = _retTree;
	_t = __t241;
	_t = _t->getNextSibling();
#line 1374 "dataflow_annotator.g"
	
	std::cout << " -> ";
	
	// Optional buffered argument
	if (isBufferedArgPresent)
	{
	std::cout << "[buffered=";
	if (buffered)
	std::cout << "true] ";
	else
	std::cout << "false] ";
	}
	
	// We are going to use the left-hand side of the edge statement as the
	// source for the datatype of flowing over the arrow. We might not
	// be successful in obtaining the metadata since it depends on
	// on a properly constructed script.
	std::map<std::string,DataflowSymbol >::const_iterator leftIt(mSymbol->find(lhs.get<0>()));
	if (leftIt != mSymbol->end())
	{
	// Using the operation from in the symbol table, get the port identified
	// by the lhs (by number or name).
	boost::shared_ptr<Port> lhsPort (
	lhs.get<1>().which() == 0 ? 
	leftIt->second.Op->GetOutputPorts()[boost::get<int>(lhs.get<1>())] :
	leftIt->second.Op->GetOutputPorts()[ASCIIToWide(boost::get<std::string>(lhs.get<1>()))]);
	
	outputPortMetadata(lhsPort);
	}
	
	// Destination operation
	std::cout << rhs.get<0>();
	
	// Port name or index
	if (rhs.get<2>())
	std::cout << "(" << rhs.get<1>() << ")";
	
	std::cout << "\n";
	
#line 2097 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::broadcastArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST broadcastArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t9 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t9;
	_t = _t->getNextSibling();
#line 310 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2119 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::nodeArgumentValue(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST nodeArgumentValue_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case NUM_INT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp3_AST_in = _t;
		match(_t,NUM_INT);
		_t = _t->getNextSibling();
		break;
	}
	case NUM_BIGINT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp4_AST_in = _t;
		match(_t,NUM_BIGINT);
		_t = _t->getNextSibling();
		break;
	}
	case NUM_FLOAT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp5_AST_in = _t;
		match(_t,NUM_FLOAT);
		_t = _t->getNextSibling();
		break;
	}
	case NUM_DECIMAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp6_AST_in = _t;
		match(_t,NUM_DECIMAL);
		_t = _t->getNextSibling();
		break;
	}
	case STRING_LITERAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp7_AST_in = _t;
		match(_t,STRING_LITERAL);
		_t = _t->getNextSibling();
		break;
	}
	case TK_TRUE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp8_AST_in = _t;
		match(_t,TK_TRUE);
		_t = _t->getNextSibling();
		break;
	}
	case TK_FALSE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp9_AST_in = _t;
		match(_t,TK_FALSE);
		_t = _t->getNextSibling();
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	_retTree = _t;
}

void DataflowAnnotator::collArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST collArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t15 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t15;
	_t = _t->getNextSibling();
#line 337 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2204 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::devNullArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST devNullArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t23 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t23;
	_t = _t->getNextSibling();
#line 375 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2226 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::selectArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST selectArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t29 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t29;
	_t = _t->getNextSibling();
#line 403 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2248 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::exportArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST exportArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t35 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t35;
	_t = _t->getNextSibling();
#line 430 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2270 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::exportQueueArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST exportQueueArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t41 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t41;
	_t = _t->getNextSibling();
#line 457 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2292 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::exprArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST exprArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t47 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t47;
	_t = _t->getNextSibling();
#line 484 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2314 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::filterArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST filterArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t53 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t53;
	_t = _t->getNextSibling();
#line 511 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2336 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::generateStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST generateStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 531 "dataflow_annotator.g"
	
	
#line 2346 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t57 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,GENERATE);
	_t = _t->getFirstChild();
#line 536 "dataflow_annotator.g"
	
	std::cout << id->getText() << ": generate";
	outputStatementOpen(id);
	
#line 2357 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			generateArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop59;
		}
		
	}
	_loop59:;
	} // ( ... )*
#line 541 "dataflow_annotator.g"
	
	
#line 2376 "DataflowAnnotator.cpp"
#line 544 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 2381 "DataflowAnnotator.cpp"
	_t = __t57;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::generateArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST generateArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t61 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t61;
	_t = _t->getNextSibling();
#line 553 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2405 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::expressionGenerateStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST expressionGenerateStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 558 "dataflow_annotator.g"
	
	
#line 2415 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t63 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,GENERATE);
	_t = _t->getFirstChild();
#line 563 "dataflow_annotator.g"
	
	
#line 2424 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			expressionGenerateArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop65;
		}
		
	}
	_loop65:;
	} // ( ... )*
#line 566 "dataflow_annotator.g"
	
	
#line 2443 "DataflowAnnotator.cpp"
#line 569 "dataflow_annotator.g"
	
	outputStatementClose(id);
	
#line 2448 "DataflowAnnotator.cpp"
	_t = __t63;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::expressionGenerateArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST expressionGenerateArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t67 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t67;
	_t = _t->getNextSibling();
#line 578 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2472 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::groupByArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST groupByArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t73 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t73;
	_t = _t->getNextSibling();
#line 605 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2494 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::hashPartArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST hashPartArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t79 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t79;
	_t = _t->getNextSibling();
#line 632 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2516 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::hashRunningTotalArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST hashRunningTotalArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t85 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t85;
	_t = _t->getNextSibling();
#line 660 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2538 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::importArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST importArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t91 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t91;
	_t = _t->getNextSibling();
#line 687 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2560 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::importQueueArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST importQueueArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t97 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t97;
	_t = _t->getNextSibling();
#line 714 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2582 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::innerHashJoinArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST innerHashJoinArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t103 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t103;
	_t = _t->getNextSibling();
#line 741 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2604 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::innerMergeJoinArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST innerMergeJoinArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t109 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t109;
	_t = _t->getNextSibling();
#line 768 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2626 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::insertArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST insertArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t115 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t115;
	_t = _t->getNextSibling();
#line 795 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2648 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::meterArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST meterArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t121 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t121;
	_t = _t->getNextSibling();
#line 822 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2670 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::multiHashJoinArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST multiHashJoinArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t127 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t127;
	_t = _t->getNextSibling();
#line 849 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2692 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::printArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST printArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t133 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t133;
	_t = _t->getNextSibling();
#line 877 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2714 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::projectionArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST projectionArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t139 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t139;
	_t = _t->getNextSibling();
#line 904 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2736 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::renameArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST renameArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t145 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t145;
	_t = _t->getNextSibling();
#line 931 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2758 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::rightMergeAntiSemiJoinArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST rightMergeAntiSemiJoinArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t151 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t151;
	_t = _t->getNextSibling();
#line 958 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2780 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::rightMergeSemiJoinArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST rightMergeSemiJoinArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t157 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t157;
	_t = _t->getNextSibling();
#line 985 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2802 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::rightOuterHashJoinArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST rightOuterHashJoinArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t163 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t163;
	_t = _t->getNextSibling();
#line 1012 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2824 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::rightOuterMergeJoinArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST rightOuterMergeJoinArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t169 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t169;
	_t = _t->getNextSibling();
#line 1039 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2846 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::sequentialFileOutputArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sequentialFileOutputArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t175 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t175;
	_t = _t->getNextSibling();
#line 1066 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2868 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::sequentialFileScanArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sequentialFileScanArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t181 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t181;
	_t = _t->getNextSibling();
#line 1093 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2890 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::sortArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sortArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t187 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t187;
	_t = _t->getNextSibling();
#line 1120 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2912 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::sortGroupByArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sortGroupByArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t193 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t193;
	_t = _t->getNextSibling();
#line 1147 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2934 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::sortMergeArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sortMergeArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t199 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t199;
	_t = _t->getNextSibling();
#line 1174 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2956 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::sortMergeCollArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sortMergeCollArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t205 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t205;
	_t = _t->getNextSibling();
#line 1201 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 2978 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::sqlExecDirectStatementList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sqlExecDirectStatementList_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1224 "dataflow_annotator.g"
	
	
#line 2988 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t211 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
#line 1229 "dataflow_annotator.g"
	
	if (!boost::algorithm::iequals(id->getText().c_str(), "statementlist")) 
	throw std::exception("Expected statementList");
	
	std::cout << "statementList=[";
	
#line 3001 "DataflowAnnotator.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			sqlExecDirectArgument(_t);
			_t = _retTree;
		}
		else {
			goto _loop213;
		}
		
	}
	_loop213:;
	} // ( ... )*
#line 1236 "dataflow_annotator.g"
	
	if (id->getNextSibling() != NULL)
	std::cout << ", ";
	
#line 3022 "DataflowAnnotator.cpp"
	_t = __t211;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void DataflowAnnotator::sqlExecDirectArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sqlExecDirectArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t215 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t215;
	_t = _t->getNextSibling();
#line 1247 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 3046 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::switchArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST switchArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t221 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t221;
	_t = _t->getNextSibling();
#line 1274 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 3068 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::taxwareArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST taxwareArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t227 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t227;
	_t = _t->getNextSibling();
#line 1302 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 3090 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::unionAllArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST unionAllArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t233 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t233;
	_t = _t->getNextSibling();
#line 1329 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 3112 "DataflowAnnotator.cpp"
	_retTree = _t;
}

void DataflowAnnotator::unrollArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST unrollArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t239 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t239;
	_t = _t->getNextSibling();
#line 1356 "dataflow_annotator.g"
	
	outputArgument(id, av);
	
#line 3134 "DataflowAnnotator.cpp"
	_retTree = _t;
}

/** Returns tuple identifying port: <operation name, port index or port name, isPortNameSpecified> */
boost::tuple<std::string, boost::variant<int,std::string>, bool >   DataflowAnnotator::arrowOrRefStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1416 "dataflow_annotator.g"
	boost::tuple<std::string, boost::variant<int,std::string>, bool >  rhs;
#line 3142 "DataflowAnnotator.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST arrowOrRefStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
#line 1416 "dataflow_annotator.g"
	
	boost::tuple<std::string, boost::variant<int,std::string>, bool > lhs;
	bool buffered = true;
	bool isBufferedArgPresent = false;
	
#line 3150 "DataflowAnnotator.cpp"
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case ARROW:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t244 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp10_AST_in = _t;
		match(_t,ARROW);
		_t = _t->getFirstChild();
		lhs=arrowOrRefStatement(_t);
		_t = _retTree;
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
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
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
		}
		rhs=nodeRefStatement(_t);
		_t = _retTree;
		_t = __t244;
		_t = _t->getNextSibling();
#line 1424 "dataflow_annotator.g"
		
		std::cout << " -> ";
		
		// Optional buffered argument
		if (isBufferedArgPresent)
		{
		std::cout << "[buffered=";
		if (buffered)
		std::cout << "true] ";
		else
		std::cout << "false] ";
		}
		
		std::map<std::string,DataflowSymbol >::const_iterator leftIt(mSymbol->find(lhs.get<0>()));
		if (leftIt != mSymbol->end())
		{
		boost::shared_ptr<Port> lhsPort (
		lhs.get<1>().which() == 0 ? 
		leftIt->second.Op->GetOutputPorts()[boost::get<int>(lhs.get<1>())] :
		leftIt->second.Op->GetOutputPorts()[ASCIIToWide(boost::get<std::string>(lhs.get<1>()))]);
		
		outputPortMetadata(lhsPort);
		}
		
		// Destination operation
		std::cout << rhs.get<0>();
		
		// Optional port name or index
		if (rhs.get<2>())
		std::cout << "(" << rhs.get<1>() << ")";
		
#line 3219 "DataflowAnnotator.cpp"
		break;
	}
	case ID:
	{
		rhs=nodeRefStatement(_t);
		_t = _retTree;
#line 1457 "dataflow_annotator.g"
		
		std::cout << rhs.get<0>();
		
		// if a node name or index was specified, echo it
		if (rhs.get<2>())
		std::cout << "(" << rhs.get<1>() << ")";
		
#line 3234 "DataflowAnnotator.cpp"
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	_retTree = _t;
	return rhs;
}

bool  DataflowAnnotator::arrowArguments(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1501 "dataflow_annotator.g"
	bool buffered;
#line 3249 "DataflowAnnotator.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST arrowArguments_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t250 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp11_AST_in = _t;
	match(_t,LBRACKET);
	_t = _t->getFirstChild();
	buffered=arrowBufferArgument(_t);
	_t = _retTree;
	_t = __t250;
	_t = _t->getNextSibling();
	_retTree = _t;
	return buffered;
}

/** Returns tuple identifying port: <operation name, port index or port name, isPortNameSpecified> */
boost::tuple<std::string, boost::variant<int,std::string>, bool >  DataflowAnnotator::nodeRefStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1467 "dataflow_annotator.g"
	boost::tuple<std::string, boost::variant<int,std::string>, bool > t;
#line 3268 "DataflowAnnotator.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST nodeRefStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST i = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST s = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1467 "dataflow_annotator.g"
	
	std::string nodeName;
	int portIndex(0);
	std::string portName;
	bool isPortIndexSpecified(false);
	
#line 3280 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t247 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case NUM_INT:
	{
		i = _t;
		match(_t,NUM_INT);
		_t = _t->getNextSibling();
#line 1476 "dataflow_annotator.g"
		
		portIndex = boost::lexical_cast<int>(i->getText()); 
		isPortIndexSpecified = true;
		
#line 3300 "DataflowAnnotator.cpp"
		break;
	}
	case STRING_LITERAL:
	{
		s = _t;
		match(_t,STRING_LITERAL);
		_t = _t->getNextSibling();
#line 1482 "dataflow_annotator.g"
		
		portName = s->getText().substr(1, s->getText().size()-2); 
		
#line 3312 "DataflowAnnotator.cpp"
		break;
	}
	case 3:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	}
	_t = __t247;
	_t = _t->getNextSibling();
#line 1487 "dataflow_annotator.g"
	
	if (portName.size() != 0)
	{
	t = boost::tuple<std::string, boost::variant<int,std::string>, bool >
	(id->getText(), portName, true);
	}
	else
	{
	t = boost::tuple<std::string, boost::variant<int,std::string>, bool >
	(id->getText(), portIndex, isPortIndexSpecified);
	}
	
#line 3340 "DataflowAnnotator.cpp"
	_retTree = _t;
	return t;
}

bool  DataflowAnnotator::arrowBufferArgument(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1506 "dataflow_annotator.g"
	bool buffered;
#line 3348 "DataflowAnnotator.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST arrowBufferArgument_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST av = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1506 "dataflow_annotator.g"
	
	buffered = true;
	
#line 3356 "DataflowAnnotator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t252 = _t;
	id = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	av = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	nodeArgumentValue(_t);
	_t = _retTree;
	_t = __t252;
	_t = _t->getNextSibling();
#line 1512 "dataflow_annotator.g"
	
	if (boost::algorithm::iequals(id->getText().c_str(), "buffered"))
	{
	if (av->getType() != TK_TRUE && av->getType() != TK_FALSE)
	{
	throw std::exception("'buffered' argument must be true/false");
	}
	buffered = av->getType() == TK_TRUE;
	}
	
#line 3378 "DataflowAnnotator.cpp"
	_retTree = _t;
	return buffered;
}

void DataflowAnnotator::initializeASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& )
{
}
const char* DataflowAnnotator::tokenNames[] = {
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
	"\"define\"",
	"\"in\"",
	"\"out\"",
	"\"string\"",
	"\"integer\"",
	"\"boolean\"",
	"\"sublist\"",
	"\"include\"",
	"AMPERSAND",
	"ARROW",
	"AT_SIGN",
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
	"LONGEST_PREFIX_MATCH",
	"MD5",
	"METER",
	"MULTI_HASH_JOIN",
	"PRINT",
	"PROJECTION",
	"RANGEPART",
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
	"SORT",
	"SORT_GROUP_BY",
	"SORTMERGE",
	"SORTMERGECOLL",
	"SORT_NEST",
	"SORT_ORDER_ASSERT",
	"SORT_RUNNING_TOTAL",
	"SQL_EXEC_DIRECT",
	"SWITCH",
	"TAXWARE",
	"UNION_ALL",
	"UNNEST",
	"UNROLL",
	"DELAYED_GENERATE",
	0
};



