/* $ANTLR 2.7.6 (2005-12-22): "mtsql_refactor_lexer.g" -> "MTSQLRefactorLexer.cpp"$ */
#include "MTSQLRefactorLexer.hpp"
#include <antlr/CharBuffer.hpp>
#include <antlr/TokenStreamException.hpp>
#include <antlr/TokenStreamIOException.hpp>
#include <antlr/TokenStreamRecognitionException.hpp>
#include <antlr/CharStreamException.hpp>
#include <antlr/CharStreamIOException.hpp>
#include <antlr/NoViableAltForCharException.hpp>

#line 1 "mtsql_refactor_lexer.g"
#line 13 "MTSQLRefactorLexer.cpp"
MTSQLRefactorLexer::MTSQLRefactorLexer(ANTLR_USE_NAMESPACE(std)istream& in)
	: ANTLR_USE_NAMESPACE(antlr)CharScanner(new ANTLR_USE_NAMESPACE(antlr)CharBuffer(in),true)
{
	initLiterals();
}

MTSQLRefactorLexer::MTSQLRefactorLexer(ANTLR_USE_NAMESPACE(antlr)InputBuffer& ib)
	: ANTLR_USE_NAMESPACE(antlr)CharScanner(ib,true)
{
	initLiterals();
}

MTSQLRefactorLexer::MTSQLRefactorLexer(const ANTLR_USE_NAMESPACE(antlr)LexerSharedInputState& state)
	: ANTLR_USE_NAMESPACE(antlr)CharScanner(state,true)
{
	initLiterals();
}

void MTSQLRefactorLexer::initLiterals()
{
	literals["BEGIN"] = 10;
	literals["ENUM"] = 31;
	literals["DOUBLE"] = 28;
	literals["RETURNS"] = 65;
	literals["IF"] = 39;
	literals["RAISERROR"] = 63;
	literals["WHILE"] = 78;
	literals["UNION"] = 74;
	literals["CHAR"] = 18;
	literals["UPDATE"] = 87;
	literals["MAX"] = 50;
	literals["FROM"] = 34;
	literals["BY"] = 15;
	literals["LIKE"] = 49;
	literals["AS"] = 7;
	literals["DECLARE"] = 24;
	literals["DATETIME"] = 23;
	literals["ANY"] = 6;
	literals["BREAK"] = 14;
	literals["JOIN"] = 46;
	literals["NOT"] = 52;
	literals["ELSE"] = 29;
	literals["INTEGER"] = 44;
	literals["WITH"] = 79;
	literals["PROCEDURE"] = 62;
	literals["MODE"] = 85;
	literals["CREATE"] = 21;
	literals["THEN"] = 71;
	literals["ALL"] = 5;
	literals["EXISTS"] = 32;
	literals["SUM"] = 70;
	literals["CASE"] = 16;
	literals["SELECT"] = 67;
	literals["FOR"] = 86;
	literals["FULL"] = 35;
	literals["DECIMAL"] = 25;
	literals["MIN"] = 51;
	literals["NOWAIT"] = 89;
	literals["COUNT"] = 20;
	literals["NVARCHAR"] = 54;
	literals["ON"] = 55;
	literals["FALSE"] = 33;
	literals["DISTINCT"] = 27;
	literals["PRINT"] = 61;
	literals["BOOLEAN"] = 13;
	literals["TRUE"] = 73;
	literals["TIME"] = 72;
	literals["LOCK"] = 83;
	literals["AND"] = 4;
	literals["ASC"] = 8;
	literals["DESC"] = 26;
	literals["HAVING"] = 38;
	literals["TABLE"] = 84;
	literals["RIGHT"] = 66;
	literals["FUNCTION"] = 36;
	literals["END"] = 30;
	literals["INDEX"] = 41;
	literals["CONTINUE"] = 19;
	literals["OUTER"] = 58;
	literals["GROUP"] = 37;
	literals["IN"] = 40;
	literals["KEY"] = 47;
	literals["WHERE"] = 77;
	literals["SET"] = 68;
	literals["BIGINT"] = 12;
	literals["OUTPUT"] = 59;
	literals["PRECISION"] = 60;
	literals["LEFT"] = 48;
	literals["CROSS"] = 22;
	literals["WHEN"] = 76;
	literals["OF"] = 88;
	literals["AVG"] = 9;
	literals["ORDER"] = 57;
	literals["OR"] = 56;
	literals["IS"] = 45;
	literals["BETWEEN"] = 11;
	literals["NULL"] = 53;
	literals["VARCHAR"] = 75;
	literals["SOME"] = 69;
	literals["INNER"] = 42;
	literals["INTO"] = 43;
	literals["RETURN"] = 64;
	literals["CAST"] = 17;
}

ANTLR_USE_NAMESPACE(antlr)RefToken MTSQLRefactorLexer::nextToken()
{
	ANTLR_USE_NAMESPACE(antlr)RefToken theRetToken;
	for (;;) {
		ANTLR_USE_NAMESPACE(antlr)RefToken theRetToken;
		int _ttype = ANTLR_USE_NAMESPACE(antlr)Token::INVALID_TYPE;
		resetText();
		try {   // for lexical and char stream error handling
			switch ( LA(1)) {
			case 0x26 /* '&' */ :
			{
				mAMPERSAND(true);
				theRetToken=_returnToken;
				break;
			}
			case 0x3d /* '=' */ :
			{
				mEQUALS(true);
				theRetToken=_returnToken;
				break;
			}
			case 0x21 /* '!' */ :
			{
				mNOTEQUALS2(true);
				theRetToken=_returnToken;
				break;
			}
			case 0x25 /* '%' */ :
			{
				mMODULO(true);
				theRetToken=_returnToken;
				break;
			}
			case 0x5e /* '^' */ :
			{
				mCARET(true);
				theRetToken=_returnToken;
				break;
			}
			case 0x2c /* ',' */ :
			{
				mCOMMA(true);
				theRetToken=_returnToken;
				break;
			}
			case 0x28 /* '(' */ :
			{
				mLPAREN(true);
				theRetToken=_returnToken;
				break;
			}
			case 0x29 /* ')' */ :
			{
				mRPAREN(true);
				theRetToken=_returnToken;
				break;
			}
			case 0x7c /* '|' */ :
			{
				mPIPE(true);
				theRetToken=_returnToken;
				break;
			}
			case 0x2b /* '+' */ :
			{
				mPLUS(true);
				theRetToken=_returnToken;
				break;
			}
			case 0x3b /* ';' */ :
			{
				mSEMI(true);
				theRetToken=_returnToken;
				break;
			}
			case 0x2a /* '*' */ :
			{
				mSTAR(true);
				theRetToken=_returnToken;
				break;
			}
			case 0x27 /* '\'' */ :
			{
				mSTRING_LITERAL(true);
				theRetToken=_returnToken;
				break;
			}
			case 0x23 /* '#' */ :
			{
				mENUM_LITERAL(true);
				theRetToken=_returnToken;
				break;
			}
			case 0x7e /* '~' */ :
			{
				mTILDE(true);
				theRetToken=_returnToken;
				break;
			}
			case 0x9 /* '\t' */ :
			case 0xa /* '\n' */ :
			case 0xc /* '\14' */ :
			case 0xd /* '\r' */ :
			case 0x20 /* ' ' */ :
			{
				mWS(true);
				theRetToken=_returnToken;
				break;
			}
			default:
				if ((LA(1) == 0x56 /* 'V' */ ) && (LA(2) == 0x41 /* 'A' */ ) && (LA(3) == 0x52 /* 'R' */ ) && (LA(4) == 0x43 /* 'C' */ ) && (LA(5) == 0x48 /* 'H' */ ) && (LA(6) == 0x41 /* 'A' */ ) && (LA(7) == 0x52 /* 'R' */ ) && (true)) {
					mTK_VARCHAR(true);
					theRetToken=_returnToken;
				}
				else if ((LA(1) == 0x3c /* '<' */ ) && (LA(2) == 0x3e /* '>' */ )) {
					mNOTEQUALS(true);
					theRetToken=_returnToken;
				}
				else if ((LA(1) == 0x3c /* '<' */ ) && (LA(2) == 0x3d /* '=' */ )) {
					mLTEQ(true);
					theRetToken=_returnToken;
				}
				else if ((LA(1) == 0x3e /* '>' */ ) && (LA(2) == 0x3d /* '=' */ )) {
					mGTEQ(true);
					theRetToken=_returnToken;
				}
				else if ((LA(1) == 0x2d /* '-' */ ) && (LA(2) == 0x2d /* '-' */ )) {
					mSL_COMMENT(true);
					theRetToken=_returnToken;
				}
				else if ((LA(1) == 0x2f /* '/' */ ) && (LA(2) == 0x2a /* '*' */ )) {
					mML_COMMENT(true);
					theRetToken=_returnToken;
				}
				else if ((LA(1) == 0x4e /* 'N' */ ) && (LA(2) == 0x27 /* '\'' */ )) {
					mWSTRING_LITERAL(true);
					theRetToken=_returnToken;
				}
				else if ((LA(1) == 0x40 /* '@' */ ) && (_tokenSet_0.member(LA(2)))) {
					mLOCALVAR(true);
					theRetToken=_returnToken;
				}
				else if ((LA(1) == 0x40 /* '@' */ ) && (LA(2) == 0x40 /* '@' */ )) {
					mGLOBALVAR(true);
					theRetToken=_returnToken;
				}
				else if ((LA(1) == 0x3c /* '<' */ ) && (true)) {
					mLTN(true);
					theRetToken=_returnToken;
				}
				else if ((LA(1) == 0x3e /* '>' */ ) && (true)) {
					mGT(true);
					theRetToken=_returnToken;
				}
				else if ((LA(1) == 0x2e /* '.' */ ) && (true) && (true) && (true) && (true) && (true) && (true) && (true)) {
					mDOT(true);
					theRetToken=_returnToken;
				}
				else if ((LA(1) == 0x2d /* '-' */ ) && (true)) {
					mMINUS(true);
					theRetToken=_returnToken;
				}
				else if ((LA(1) == 0x2f /* '/' */ ) && (true)) {
					mSLASH(true);
					theRetToken=_returnToken;
				}
				else if ((_tokenSet_0.member(LA(1))) && (true) && (true) && (true) && (true) && (true) && (true) && (true)) {
					mID(true);
					theRetToken=_returnToken;
				}
				else if ((_tokenSet_1.member(LA(1))) && (true) && (true) && (true) && (true) && (true) && (true) && (true)) {
					mNUM_INT(true);
					theRetToken=_returnToken;
				}
			else {
				if (LA(1)==EOF_CHAR)
				{
					uponEOF();
					_returnToken = makeToken(ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE);
				}
				else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltForCharException(LA(1), getFilename(), getLine(), getColumn());}
			}
			}
			if ( !_returnToken )
				goto tryAgain; // found SKIP token

			_ttype = _returnToken->getType();
			_ttype = testLiteralsTable(_ttype);
			_returnToken->setType(_ttype);
			return _returnToken;
		}
		catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& e) {
				throw ANTLR_USE_NAMESPACE(antlr)TokenStreamRecognitionException(e);
		}
		catch (ANTLR_USE_NAMESPACE(antlr)CharStreamIOException& csie) {
			throw ANTLR_USE_NAMESPACE(antlr)TokenStreamIOException(csie.io);
		}
		catch (ANTLR_USE_NAMESPACE(antlr)CharStreamException& cse) {
			throw ANTLR_USE_NAMESPACE(antlr)TokenStreamException(cse.getMessage());
		}
tryAgain:;
	}
}

void MTSQLRefactorLexer::mAMPERSAND(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = AMPERSAND;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	match('&' /* charlit */ );
#line 179 "mtsql_refactor_lexer.g"
	
	mConvertedScript << text.substr(_begin, text.length()-_begin);
	
#line 333 "MTSQLRefactorLexer.cpp"
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mEQUALS(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = EQUALS;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	match('=' /* charlit */ );
#line 186 "mtsql_refactor_lexer.g"
	
	mConvertedScript << text.substr(_begin, text.length()-_begin);
	
#line 352 "MTSQLRefactorLexer.cpp"
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mNOTEQUALS(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = NOTEQUALS;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	match('<' /* charlit */ );
	match('>' /* charlit */ );
#line 194 "mtsql_refactor_lexer.g"
	
	mConvertedScript << text.substr(_begin, text.length()-_begin);
	
#line 372 "MTSQLRefactorLexer.cpp"
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mTK_VARCHAR(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = TK_VARCHAR;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	match("VARCHAR");
#line 202 "mtsql_refactor_lexer.g"
	
	if (mIsVarcharRefactor)
	{
	mConvertedScript << "N";
	}
	
	mConvertedScript << text.substr(_begin, text.length()-_begin);
	
#line 396 "MTSQLRefactorLexer.cpp"
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mNOTEQUALS2(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = NOTEQUALS2;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	match('!' /* charlit */ );
	match('=' /* charlit */ );
#line 215 "mtsql_refactor_lexer.g"
	
	mConvertedScript << text.substr(_begin, text.length()-_begin);
	
#line 416 "MTSQLRefactorLexer.cpp"
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mLTN(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = LTN;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	match('<' /* charlit */ );
#line 222 "mtsql_refactor_lexer.g"
	
	mConvertedScript << text.substr(_begin, text.length()-_begin);
	
#line 435 "MTSQLRefactorLexer.cpp"
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mLTEQ(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = LTEQ;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	match('<' /* charlit */ );
	match('=' /* charlit */ );
#line 229 "mtsql_refactor_lexer.g"
	
	mConvertedScript << text.substr(_begin, text.length()-_begin);
	
#line 455 "MTSQLRefactorLexer.cpp"
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mGT(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = GT;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	match('>' /* charlit */ );
#line 236 "mtsql_refactor_lexer.g"
	
	mConvertedScript << text.substr(_begin, text.length()-_begin);
	
#line 474 "MTSQLRefactorLexer.cpp"
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mGTEQ(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = GTEQ;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	match('>' /* charlit */ );
	match('=' /* charlit */ );
#line 243 "mtsql_refactor_lexer.g"
	
	mConvertedScript << text.substr(_begin, text.length()-_begin);
	
#line 494 "MTSQLRefactorLexer.cpp"
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mMODULO(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = MODULO;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	match('%' /* charlit */ );
#line 250 "mtsql_refactor_lexer.g"
	
	mConvertedScript << text.substr(_begin, text.length()-_begin);
	
#line 513 "MTSQLRefactorLexer.cpp"
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mSL_COMMENT(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = SL_COMMENT;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	match("--");
	{ // ( ... )*
	for (;;) {
		if ((_tokenSet_2.member(LA(1)))) {
			matchNot('\n' /* charlit */ );
		}
		else {
			goto _loop13;
		}
		
	}
	_loop13:;
	} // ( ... )*
	match('\n' /* charlit */ );
#line 258 "mtsql_refactor_lexer.g"
	newline();
#line 543 "MTSQLRefactorLexer.cpp"
#line 259 "mtsql_refactor_lexer.g"
	
	mConvertedScript << text.substr(_begin, text.length()-_begin);
	
#line 548 "MTSQLRefactorLexer.cpp"
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mML_COMMENT(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = ML_COMMENT;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	match("/*");
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == 0xd /* '\r' */ ) && (LA(2) == 0xa /* '\n' */ ) && ((LA(3) >= 0x3 /* '\3' */  && LA(3) <= 0xff)) && ((LA(4) >= 0x3 /* '\3' */  && LA(4) <= 0xff)) && (true) && (true) && (true) && (true)) {
			match('\r' /* charlit */ );
			match('\n' /* charlit */ );
#line 280 "mtsql_refactor_lexer.g"
			newline();
#line 570 "MTSQLRefactorLexer.cpp"
		}
		else if (((LA(1) == 0x2a /* '*' */ ) && ((LA(2) >= 0x3 /* '\3' */  && LA(2) <= 0xff)) && ((LA(3) >= 0x3 /* '\3' */  && LA(3) <= 0xff)))&&( LA(2)!='/' )) {
			match('*' /* charlit */ );
		}
		else if ((LA(1) == 0xd /* '\r' */ ) && ((LA(2) >= 0x3 /* '\3' */  && LA(2) <= 0xff)) && ((LA(3) >= 0x3 /* '\3' */  && LA(3) <= 0xff)) && (true) && (true) && (true) && (true) && (true)) {
			match('\r' /* charlit */ );
#line 281 "mtsql_refactor_lexer.g"
			newline();
#line 579 "MTSQLRefactorLexer.cpp"
		}
		else if ((LA(1) == 0xa /* '\n' */ )) {
			match('\n' /* charlit */ );
#line 282 "mtsql_refactor_lexer.g"
			newline();
#line 585 "MTSQLRefactorLexer.cpp"
		}
		else if ((_tokenSet_3.member(LA(1)))) {
			{
			match(_tokenSet_3);
			}
		}
		else {
			goto _loop17;
		}
		
	}
	_loop17:;
	} // ( ... )*
	match("*/");
#line 286 "mtsql_refactor_lexer.g"
	
	mConvertedScript << text.substr(_begin, text.length()-_begin);
	
#line 604 "MTSQLRefactorLexer.cpp"
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mCARET(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = CARET;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	match('^' /* charlit */ );
#line 294 "mtsql_refactor_lexer.g"
	
	mConvertedScript << text.substr(_begin, text.length()-_begin);
	
#line 623 "MTSQLRefactorLexer.cpp"
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mCOMMA(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = COMMA;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	match(',' /* charlit */ );
#line 301 "mtsql_refactor_lexer.g"
	
	mConvertedScript << text.substr(_begin, text.length()-_begin);
	
#line 642 "MTSQLRefactorLexer.cpp"
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mDOT(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = DOT;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	match('.' /* charlit */ );
#line 309 "mtsql_refactor_lexer.g"
	
	mConvertedScript << text.substr(_begin, text.length()-_begin);
	
#line 661 "MTSQLRefactorLexer.cpp"
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mLPAREN(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = LPAREN;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	match('(' /* charlit */ );
#line 319 "mtsql_refactor_lexer.g"
	
	mConvertedScript << text.substr(_begin, text.length()-_begin);
	
#line 680 "MTSQLRefactorLexer.cpp"
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mRPAREN(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = RPAREN;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	match(')' /* charlit */ );
#line 329 "mtsql_refactor_lexer.g"
	
	mConvertedScript << text.substr(_begin, text.length()-_begin);
	
#line 699 "MTSQLRefactorLexer.cpp"
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mMINUS(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = MINUS;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	match('-' /* charlit */ );
#line 337 "mtsql_refactor_lexer.g"
	
	mConvertedScript << text.substr(_begin, text.length()-_begin);
	
#line 718 "MTSQLRefactorLexer.cpp"
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mPIPE(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = PIPE;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	match('|' /* charlit */ );
#line 345 "mtsql_refactor_lexer.g"
	
	mConvertedScript << text.substr(_begin, text.length()-_begin);
	
#line 737 "MTSQLRefactorLexer.cpp"
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mPLUS(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = PLUS;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	match('+' /* charlit */ );
#line 353 "mtsql_refactor_lexer.g"
	
	mConvertedScript << text.substr(_begin, text.length()-_begin);
	
#line 756 "MTSQLRefactorLexer.cpp"
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mSEMI(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = SEMI;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	match(';' /* charlit */ );
#line 360 "mtsql_refactor_lexer.g"
	
	mConvertedScript << text.substr(_begin, text.length()-_begin);
	
#line 775 "MTSQLRefactorLexer.cpp"
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mSLASH(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = SLASH;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	match('/' /* charlit */ );
#line 368 "mtsql_refactor_lexer.g"
	
	mConvertedScript << text.substr(_begin, text.length()-_begin);
	
#line 794 "MTSQLRefactorLexer.cpp"
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mSTAR(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = STAR;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	match('*' /* charlit */ );
#line 375 "mtsql_refactor_lexer.g"
	
	mConvertedScript << text.substr(_begin, text.length()-_begin);
	
#line 813 "MTSQLRefactorLexer.cpp"
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mSTRING_LITERAL(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = STRING_LITERAL;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	match('\'' /* charlit */ );
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == 0xd /* '\r' */ ) && (LA(2) == 0xa /* '\n' */ ) && ((LA(3) >= 0x3 /* '\3' */  && LA(3) <= 0xff)) && (true) && (true) && (true) && (true) && (true)) {
			match('\r' /* charlit */ );
			match('\n' /* charlit */ );
#line 393 "mtsql_refactor_lexer.g"
			newline();
#line 835 "MTSQLRefactorLexer.cpp"
		}
		else if ((LA(1) == 0xd /* '\r' */ ) && ((LA(2) >= 0x3 /* '\3' */  && LA(2) <= 0xff)) && (true) && (true) && (true) && (true) && (true) && (true)) {
			match('\r' /* charlit */ );
#line 394 "mtsql_refactor_lexer.g"
			newline();
#line 841 "MTSQLRefactorLexer.cpp"
		}
		else if ((LA(1) == 0x27 /* '\'' */ ) && (LA(2) == 0x27 /* '\'' */ )) {
			match('\'' /* charlit */ );
			_saveIndex = text.length();
			match('\'' /* charlit */ );
			text.erase(_saveIndex);
		}
		else if ((LA(1) == 0xa /* '\n' */ )) {
			match('\n' /* charlit */ );
#line 395 "mtsql_refactor_lexer.g"
			newline();
#line 853 "MTSQLRefactorLexer.cpp"
		}
		else if ((_tokenSet_4.member(LA(1)))) {
			{
			match(_tokenSet_4);
			}
		}
		else {
			goto _loop32;
		}
		
	}
	_loop32:;
	} // ( ... )*
	match('\'' /* charlit */ );
#line 400 "mtsql_refactor_lexer.g"
	
	if (mIsVarcharRefactor)
	{
	mConvertedScript << "N";
	}
	
	mConvertedScript << text.substr(_begin, text.length()-_begin);
	
#line 877 "MTSQLRefactorLexer.cpp"
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mENUM_LITERAL(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = ENUM_LITERAL;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	match('#' /* charlit */ );
	{ // ( ... )*
	for (;;) {
		if ((_tokenSet_5.member(LA(1)))) {
			matchNot('#' /* charlit */ );
		}
		else {
			goto _loop35;
		}
		
	}
	_loop35:;
	} // ( ... )*
	match('#' /* charlit */ );
#line 412 "mtsql_refactor_lexer.g"
	
	mConvertedScript << text.substr(_begin, text.length()-_begin);
	
#line 909 "MTSQLRefactorLexer.cpp"
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mWSTRING_LITERAL(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = WSTRING_LITERAL;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	match('N' /* charlit */ );
	match('\'' /* charlit */ );
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == 0xd /* '\r' */ ) && (LA(2) == 0xa /* '\n' */ ) && ((LA(3) >= 0x3 /* '\3' */  && LA(3) <= 0xff)) && (true) && (true) && (true) && (true) && (true)) {
			match('\r' /* charlit */ );
			match('\n' /* charlit */ );
#line 424 "mtsql_refactor_lexer.g"
			newline();
#line 932 "MTSQLRefactorLexer.cpp"
		}
		else if ((LA(1) == 0xd /* '\r' */ ) && ((LA(2) >= 0x3 /* '\3' */  && LA(2) <= 0xff)) && (true) && (true) && (true) && (true) && (true) && (true)) {
			match('\r' /* charlit */ );
#line 425 "mtsql_refactor_lexer.g"
			newline();
#line 938 "MTSQLRefactorLexer.cpp"
		}
		else if ((LA(1) == 0x27 /* '\'' */ ) && (LA(2) == 0x27 /* '\'' */ )) {
			match('\'' /* charlit */ );
			_saveIndex = text.length();
			match('\'' /* charlit */ );
			text.erase(_saveIndex);
		}
		else if ((LA(1) == 0xa /* '\n' */ )) {
			match('\n' /* charlit */ );
#line 426 "mtsql_refactor_lexer.g"
			newline();
#line 950 "MTSQLRefactorLexer.cpp"
		}
		else if ((_tokenSet_4.member(LA(1)))) {
			{
			match(_tokenSet_4);
			}
		}
		else {
			goto _loop39;
		}
		
	}
	_loop39:;
	} // ( ... )*
	match('\'' /* charlit */ );
#line 431 "mtsql_refactor_lexer.g"
	
	mConvertedScript << text.substr(_begin, text.length()-_begin);
	
#line 969 "MTSQLRefactorLexer.cpp"
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mTILDE(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = TILDE;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	match('~' /* charlit */ );
#line 438 "mtsql_refactor_lexer.g"
	
	mConvertedScript << text.substr(_begin, text.length()-_begin);
	
#line 988 "MTSQLRefactorLexer.cpp"
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mWS(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = WS;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	{ // ( ... )+
	int _cnt44=0;
	for (;;) {
		switch ( LA(1)) {
		case 0x20 /* ' ' */ :
		{
			match(' ' /* charlit */ );
			break;
		}
		case 0x9 /* '\t' */ :
		{
			match('\t' /* charlit */ );
			break;
		}
		case 0xc /* '\14' */ :
		{
			match('\14' /* charlit */ );
			break;
		}
		case 0xa /* '\n' */ :
		case 0xd /* '\r' */ :
		{
			{
			if ((LA(1) == 0xd /* '\r' */ ) && (LA(2) == 0xa /* '\n' */ ) && (true) && (true) && (true) && (true) && (true) && (true)) {
				match("\r\n");
			}
			else if ((LA(1) == 0xd /* '\r' */ ) && (true) && (true) && (true) && (true) && (true) && (true) && (true)) {
				match('\r' /* charlit */ );
			}
			else if ((LA(1) == 0xa /* '\n' */ )) {
				match('\n' /* charlit */ );
			}
			else {
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltForCharException(LA(1), getFilename(), getLine(), getColumn());
			}
			
			}
#line 452 "mtsql_refactor_lexer.g"
			newline();
#line 1041 "MTSQLRefactorLexer.cpp"
			break;
		}
		default:
		{
			if ( _cnt44>=1 ) { goto _loop44; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltForCharException(LA(1), getFilename(), getLine(), getColumn());}
		}
		}
		_cnt44++;
	}
	_loop44:;
	}  // ( ... )+
#line 454 "mtsql_refactor_lexer.g"
	
	mConvertedScript << text.substr(_begin, text.length()-_begin);
	
#line 1057 "MTSQLRefactorLexer.cpp"
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mID(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = ID;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	{
	switch ( LA(1)) {
	case 0x61 /* 'a' */ :
	case 0x62 /* 'b' */ :
	case 0x63 /* 'c' */ :
	case 0x64 /* 'd' */ :
	case 0x65 /* 'e' */ :
	case 0x66 /* 'f' */ :
	case 0x67 /* 'g' */ :
	case 0x68 /* 'h' */ :
	case 0x69 /* 'i' */ :
	case 0x6a /* 'j' */ :
	case 0x6b /* 'k' */ :
	case 0x6c /* 'l' */ :
	case 0x6d /* 'm' */ :
	case 0x6e /* 'n' */ :
	case 0x6f /* 'o' */ :
	case 0x70 /* 'p' */ :
	case 0x71 /* 'q' */ :
	case 0x72 /* 'r' */ :
	case 0x73 /* 's' */ :
	case 0x74 /* 't' */ :
	case 0x75 /* 'u' */ :
	case 0x76 /* 'v' */ :
	case 0x77 /* 'w' */ :
	case 0x78 /* 'x' */ :
	case 0x79 /* 'y' */ :
	case 0x7a /* 'z' */ :
	{
		matchRange('a','z');
		break;
	}
	case 0x41 /* 'A' */ :
	case 0x42 /* 'B' */ :
	case 0x43 /* 'C' */ :
	case 0x44 /* 'D' */ :
	case 0x45 /* 'E' */ :
	case 0x46 /* 'F' */ :
	case 0x47 /* 'G' */ :
	case 0x48 /* 'H' */ :
	case 0x49 /* 'I' */ :
	case 0x4a /* 'J' */ :
	case 0x4b /* 'K' */ :
	case 0x4c /* 'L' */ :
	case 0x4d /* 'M' */ :
	case 0x4e /* 'N' */ :
	case 0x4f /* 'O' */ :
	case 0x50 /* 'P' */ :
	case 0x51 /* 'Q' */ :
	case 0x52 /* 'R' */ :
	case 0x53 /* 'S' */ :
	case 0x54 /* 'T' */ :
	case 0x55 /* 'U' */ :
	case 0x56 /* 'V' */ :
	case 0x57 /* 'W' */ :
	case 0x58 /* 'X' */ :
	case 0x59 /* 'Y' */ :
	case 0x5a /* 'Z' */ :
	{
		matchRange('A','Z');
		break;
	}
	case 0x5f /* '_' */ :
	{
		match('_' /* charlit */ );
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltForCharException(LA(1), getFilename(), getLine(), getColumn());
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		switch ( LA(1)) {
		case 0x61 /* 'a' */ :
		case 0x62 /* 'b' */ :
		case 0x63 /* 'c' */ :
		case 0x64 /* 'd' */ :
		case 0x65 /* 'e' */ :
		case 0x66 /* 'f' */ :
		case 0x67 /* 'g' */ :
		case 0x68 /* 'h' */ :
		case 0x69 /* 'i' */ :
		case 0x6a /* 'j' */ :
		case 0x6b /* 'k' */ :
		case 0x6c /* 'l' */ :
		case 0x6d /* 'm' */ :
		case 0x6e /* 'n' */ :
		case 0x6f /* 'o' */ :
		case 0x70 /* 'p' */ :
		case 0x71 /* 'q' */ :
		case 0x72 /* 'r' */ :
		case 0x73 /* 's' */ :
		case 0x74 /* 't' */ :
		case 0x75 /* 'u' */ :
		case 0x76 /* 'v' */ :
		case 0x77 /* 'w' */ :
		case 0x78 /* 'x' */ :
		case 0x79 /* 'y' */ :
		case 0x7a /* 'z' */ :
		{
			matchRange('a','z');
			break;
		}
		case 0x41 /* 'A' */ :
		case 0x42 /* 'B' */ :
		case 0x43 /* 'C' */ :
		case 0x44 /* 'D' */ :
		case 0x45 /* 'E' */ :
		case 0x46 /* 'F' */ :
		case 0x47 /* 'G' */ :
		case 0x48 /* 'H' */ :
		case 0x49 /* 'I' */ :
		case 0x4a /* 'J' */ :
		case 0x4b /* 'K' */ :
		case 0x4c /* 'L' */ :
		case 0x4d /* 'M' */ :
		case 0x4e /* 'N' */ :
		case 0x4f /* 'O' */ :
		case 0x50 /* 'P' */ :
		case 0x51 /* 'Q' */ :
		case 0x52 /* 'R' */ :
		case 0x53 /* 'S' */ :
		case 0x54 /* 'T' */ :
		case 0x55 /* 'U' */ :
		case 0x56 /* 'V' */ :
		case 0x57 /* 'W' */ :
		case 0x58 /* 'X' */ :
		case 0x59 /* 'Y' */ :
		case 0x5a /* 'Z' */ :
		{
			matchRange('A','Z');
			break;
		}
		case 0x5f /* '_' */ :
		{
			match('_' /* charlit */ );
			break;
		}
		case 0x30 /* '0' */ :
		case 0x31 /* '1' */ :
		case 0x32 /* '2' */ :
		case 0x33 /* '3' */ :
		case 0x34 /* '4' */ :
		case 0x35 /* '5' */ :
		case 0x36 /* '6' */ :
		case 0x37 /* '7' */ :
		case 0x38 /* '8' */ :
		case 0x39 /* '9' */ :
		{
			matchRange('0','9');
			break;
		}
		default:
		{
			goto _loop48;
		}
		}
	}
	_loop48:;
	} // ( ... )*
#line 464 "mtsql_refactor_lexer.g"
	
	mConvertedScript << text.substr(_begin, text.length()-_begin);
	
#line 1238 "MTSQLRefactorLexer.cpp"
	_ttype = testLiteralsTable(_ttype);
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mLOCALVAR(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = LOCALVAR;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	match('@' /* charlit */ );
	{
	switch ( LA(1)) {
	case 0x61 /* 'a' */ :
	case 0x62 /* 'b' */ :
	case 0x63 /* 'c' */ :
	case 0x64 /* 'd' */ :
	case 0x65 /* 'e' */ :
	case 0x66 /* 'f' */ :
	case 0x67 /* 'g' */ :
	case 0x68 /* 'h' */ :
	case 0x69 /* 'i' */ :
	case 0x6a /* 'j' */ :
	case 0x6b /* 'k' */ :
	case 0x6c /* 'l' */ :
	case 0x6d /* 'm' */ :
	case 0x6e /* 'n' */ :
	case 0x6f /* 'o' */ :
	case 0x70 /* 'p' */ :
	case 0x71 /* 'q' */ :
	case 0x72 /* 'r' */ :
	case 0x73 /* 's' */ :
	case 0x74 /* 't' */ :
	case 0x75 /* 'u' */ :
	case 0x76 /* 'v' */ :
	case 0x77 /* 'w' */ :
	case 0x78 /* 'x' */ :
	case 0x79 /* 'y' */ :
	case 0x7a /* 'z' */ :
	{
		matchRange('a','z');
		break;
	}
	case 0x41 /* 'A' */ :
	case 0x42 /* 'B' */ :
	case 0x43 /* 'C' */ :
	case 0x44 /* 'D' */ :
	case 0x45 /* 'E' */ :
	case 0x46 /* 'F' */ :
	case 0x47 /* 'G' */ :
	case 0x48 /* 'H' */ :
	case 0x49 /* 'I' */ :
	case 0x4a /* 'J' */ :
	case 0x4b /* 'K' */ :
	case 0x4c /* 'L' */ :
	case 0x4d /* 'M' */ :
	case 0x4e /* 'N' */ :
	case 0x4f /* 'O' */ :
	case 0x50 /* 'P' */ :
	case 0x51 /* 'Q' */ :
	case 0x52 /* 'R' */ :
	case 0x53 /* 'S' */ :
	case 0x54 /* 'T' */ :
	case 0x55 /* 'U' */ :
	case 0x56 /* 'V' */ :
	case 0x57 /* 'W' */ :
	case 0x58 /* 'X' */ :
	case 0x59 /* 'Y' */ :
	case 0x5a /* 'Z' */ :
	{
		matchRange('A','Z');
		break;
	}
	case 0x5f /* '_' */ :
	{
		match('_' /* charlit */ );
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltForCharException(LA(1), getFilename(), getLine(), getColumn());
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		switch ( LA(1)) {
		case 0x61 /* 'a' */ :
		case 0x62 /* 'b' */ :
		case 0x63 /* 'c' */ :
		case 0x64 /* 'd' */ :
		case 0x65 /* 'e' */ :
		case 0x66 /* 'f' */ :
		case 0x67 /* 'g' */ :
		case 0x68 /* 'h' */ :
		case 0x69 /* 'i' */ :
		case 0x6a /* 'j' */ :
		case 0x6b /* 'k' */ :
		case 0x6c /* 'l' */ :
		case 0x6d /* 'm' */ :
		case 0x6e /* 'n' */ :
		case 0x6f /* 'o' */ :
		case 0x70 /* 'p' */ :
		case 0x71 /* 'q' */ :
		case 0x72 /* 'r' */ :
		case 0x73 /* 's' */ :
		case 0x74 /* 't' */ :
		case 0x75 /* 'u' */ :
		case 0x76 /* 'v' */ :
		case 0x77 /* 'w' */ :
		case 0x78 /* 'x' */ :
		case 0x79 /* 'y' */ :
		case 0x7a /* 'z' */ :
		{
			matchRange('a','z');
			break;
		}
		case 0x41 /* 'A' */ :
		case 0x42 /* 'B' */ :
		case 0x43 /* 'C' */ :
		case 0x44 /* 'D' */ :
		case 0x45 /* 'E' */ :
		case 0x46 /* 'F' */ :
		case 0x47 /* 'G' */ :
		case 0x48 /* 'H' */ :
		case 0x49 /* 'I' */ :
		case 0x4a /* 'J' */ :
		case 0x4b /* 'K' */ :
		case 0x4c /* 'L' */ :
		case 0x4d /* 'M' */ :
		case 0x4e /* 'N' */ :
		case 0x4f /* 'O' */ :
		case 0x50 /* 'P' */ :
		case 0x51 /* 'Q' */ :
		case 0x52 /* 'R' */ :
		case 0x53 /* 'S' */ :
		case 0x54 /* 'T' */ :
		case 0x55 /* 'U' */ :
		case 0x56 /* 'V' */ :
		case 0x57 /* 'W' */ :
		case 0x58 /* 'X' */ :
		case 0x59 /* 'Y' */ :
		case 0x5a /* 'Z' */ :
		{
			matchRange('A','Z');
			break;
		}
		case 0x5f /* '_' */ :
		{
			match('_' /* charlit */ );
			break;
		}
		case 0x30 /* '0' */ :
		case 0x31 /* '1' */ :
		case 0x32 /* '2' */ :
		case 0x33 /* '3' */ :
		case 0x34 /* '4' */ :
		case 0x35 /* '5' */ :
		case 0x36 /* '6' */ :
		case 0x37 /* '7' */ :
		case 0x38 /* '8' */ :
		case 0x39 /* '9' */ :
		{
			matchRange('0','9');
			break;
		}
		case 0x24 /* '$' */ :
		{
			match('$' /* charlit */ );
			break;
		}
		case 0x23 /* '#' */ :
		{
			match('#' /* charlit */ );
			break;
		}
		default:
		{
			goto _loop52;
		}
		}
	}
	_loop52:;
	} // ( ... )*
#line 474 "mtsql_refactor_lexer.g"
	
	string varName = text.substr(_begin, text.length()-_begin);
	if (mIsVariableRenamed && varName.compare(mOldVariableName) == 0)
	{
	varName = mNewVariableName;
	}
	mConvertedScript << varName;
	
#line 1436 "MTSQLRefactorLexer.cpp"
	_ttype = testLiteralsTable(_ttype);
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mGLOBALVAR(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = GLOBALVAR;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	match('@' /* charlit */ );
	match('@' /* charlit */ );
	{
	switch ( LA(1)) {
	case 0x61 /* 'a' */ :
	case 0x62 /* 'b' */ :
	case 0x63 /* 'c' */ :
	case 0x64 /* 'd' */ :
	case 0x65 /* 'e' */ :
	case 0x66 /* 'f' */ :
	case 0x67 /* 'g' */ :
	case 0x68 /* 'h' */ :
	case 0x69 /* 'i' */ :
	case 0x6a /* 'j' */ :
	case 0x6b /* 'k' */ :
	case 0x6c /* 'l' */ :
	case 0x6d /* 'm' */ :
	case 0x6e /* 'n' */ :
	case 0x6f /* 'o' */ :
	case 0x70 /* 'p' */ :
	case 0x71 /* 'q' */ :
	case 0x72 /* 'r' */ :
	case 0x73 /* 's' */ :
	case 0x74 /* 't' */ :
	case 0x75 /* 'u' */ :
	case 0x76 /* 'v' */ :
	case 0x77 /* 'w' */ :
	case 0x78 /* 'x' */ :
	case 0x79 /* 'y' */ :
	case 0x7a /* 'z' */ :
	{
		matchRange('a','z');
		break;
	}
	case 0x41 /* 'A' */ :
	case 0x42 /* 'B' */ :
	case 0x43 /* 'C' */ :
	case 0x44 /* 'D' */ :
	case 0x45 /* 'E' */ :
	case 0x46 /* 'F' */ :
	case 0x47 /* 'G' */ :
	case 0x48 /* 'H' */ :
	case 0x49 /* 'I' */ :
	case 0x4a /* 'J' */ :
	case 0x4b /* 'K' */ :
	case 0x4c /* 'L' */ :
	case 0x4d /* 'M' */ :
	case 0x4e /* 'N' */ :
	case 0x4f /* 'O' */ :
	case 0x50 /* 'P' */ :
	case 0x51 /* 'Q' */ :
	case 0x52 /* 'R' */ :
	case 0x53 /* 'S' */ :
	case 0x54 /* 'T' */ :
	case 0x55 /* 'U' */ :
	case 0x56 /* 'V' */ :
	case 0x57 /* 'W' */ :
	case 0x58 /* 'X' */ :
	case 0x59 /* 'Y' */ :
	case 0x5a /* 'Z' */ :
	{
		matchRange('A','Z');
		break;
	}
	case 0x5f /* '_' */ :
	{
		match('_' /* charlit */ );
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltForCharException(LA(1), getFilename(), getLine(), getColumn());
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		switch ( LA(1)) {
		case 0x61 /* 'a' */ :
		case 0x62 /* 'b' */ :
		case 0x63 /* 'c' */ :
		case 0x64 /* 'd' */ :
		case 0x65 /* 'e' */ :
		case 0x66 /* 'f' */ :
		case 0x67 /* 'g' */ :
		case 0x68 /* 'h' */ :
		case 0x69 /* 'i' */ :
		case 0x6a /* 'j' */ :
		case 0x6b /* 'k' */ :
		case 0x6c /* 'l' */ :
		case 0x6d /* 'm' */ :
		case 0x6e /* 'n' */ :
		case 0x6f /* 'o' */ :
		case 0x70 /* 'p' */ :
		case 0x71 /* 'q' */ :
		case 0x72 /* 'r' */ :
		case 0x73 /* 's' */ :
		case 0x74 /* 't' */ :
		case 0x75 /* 'u' */ :
		case 0x76 /* 'v' */ :
		case 0x77 /* 'w' */ :
		case 0x78 /* 'x' */ :
		case 0x79 /* 'y' */ :
		case 0x7a /* 'z' */ :
		{
			matchRange('a','z');
			break;
		}
		case 0x41 /* 'A' */ :
		case 0x42 /* 'B' */ :
		case 0x43 /* 'C' */ :
		case 0x44 /* 'D' */ :
		case 0x45 /* 'E' */ :
		case 0x46 /* 'F' */ :
		case 0x47 /* 'G' */ :
		case 0x48 /* 'H' */ :
		case 0x49 /* 'I' */ :
		case 0x4a /* 'J' */ :
		case 0x4b /* 'K' */ :
		case 0x4c /* 'L' */ :
		case 0x4d /* 'M' */ :
		case 0x4e /* 'N' */ :
		case 0x4f /* 'O' */ :
		case 0x50 /* 'P' */ :
		case 0x51 /* 'Q' */ :
		case 0x52 /* 'R' */ :
		case 0x53 /* 'S' */ :
		case 0x54 /* 'T' */ :
		case 0x55 /* 'U' */ :
		case 0x56 /* 'V' */ :
		case 0x57 /* 'W' */ :
		case 0x58 /* 'X' */ :
		case 0x59 /* 'Y' */ :
		case 0x5a /* 'Z' */ :
		{
			matchRange('A','Z');
			break;
		}
		case 0x5f /* '_' */ :
		{
			match('_' /* charlit */ );
			break;
		}
		case 0x30 /* '0' */ :
		case 0x31 /* '1' */ :
		case 0x32 /* '2' */ :
		case 0x33 /* '3' */ :
		case 0x34 /* '4' */ :
		case 0x35 /* '5' */ :
		case 0x36 /* '6' */ :
		case 0x37 /* '7' */ :
		case 0x38 /* '8' */ :
		case 0x39 /* '9' */ :
		{
			matchRange('0','9');
			break;
		}
		case 0x24 /* '$' */ :
		{
			match('$' /* charlit */ );
			break;
		}
		case 0x23 /* '#' */ :
		{
			match('#' /* charlit */ );
			break;
		}
		default:
		{
			goto _loop56;
		}
		}
	}
	_loop56:;
	} // ( ... )*
#line 489 "mtsql_refactor_lexer.g"
	
	string varName = text.substr(_begin, text.length()-_begin);
	if (mIsVariableRenamed && varName.compare(mOldVariableName) == 0)
	{
	varName = mNewVariableName;
	}
	mConvertedScript << varName;
	
#line 1635 "MTSQLRefactorLexer.cpp"
	_ttype = testLiteralsTable(_ttype);
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mNUM_INT(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = NUM_INT;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
#line 500 "mtsql_refactor_lexer.g"
	bool isDecimal=false;
#line 1651 "MTSQLRefactorLexer.cpp"
	
	switch ( LA(1)) {
	case 0x2e /* '.' */ :
	{
		match('.' /* charlit */ );
#line 502 "mtsql_refactor_lexer.g"
		_ttype = DOT;
#line 1659 "MTSQLRefactorLexer.cpp"
		{
		if (((LA(1) >= 0x30 /* '0' */  && LA(1) <= 0x39 /* '9' */ ))) {
			{ // ( ... )+
			int _cnt60=0;
			for (;;) {
				if (((LA(1) >= 0x30 /* '0' */  && LA(1) <= 0x39 /* '9' */ ))) {
					matchRange('0','9');
#line 503 "mtsql_refactor_lexer.g"
					_ttype = NUM_DECIMAL;
#line 1669 "MTSQLRefactorLexer.cpp"
				}
				else {
					if ( _cnt60>=1 ) { goto _loop60; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltForCharException(LA(1), getFilename(), getLine(), getColumn());}
				}
				
				_cnt60++;
			}
			_loop60:;
			}  // ( ... )+
			{
			if ((LA(1) == 0x45 /* 'E' */  || LA(1) == 0x65 /* 'e' */ )) {
				mEXPONENT(false);
#line 503 "mtsql_refactor_lexer.g"
				_ttype = NUM_FLOAT;
#line 1684 "MTSQLRefactorLexer.cpp"
			}
			else {
			}
			
			}
			{
			if ((_tokenSet_6.member(LA(1)))) {
				mFLOAT_SUFFIX(false);
#line 503 "mtsql_refactor_lexer.g"
				_ttype = NUM_FLOAT;
#line 1695 "MTSQLRefactorLexer.cpp"
			}
			else {
			}
			
			}
		}
		else {
		}
		
		}
		break;
	}
	case 0x30 /* '0' */ :
	case 0x31 /* '1' */ :
	case 0x32 /* '2' */ :
	case 0x33 /* '3' */ :
	case 0x34 /* '4' */ :
	case 0x35 /* '5' */ :
	case 0x36 /* '6' */ :
	case 0x37 /* '7' */ :
	case 0x38 /* '8' */ :
	case 0x39 /* '9' */ :
	{
		{
		switch ( LA(1)) {
		case 0x30 /* '0' */ :
		{
			match('0' /* charlit */ );
#line 504 "mtsql_refactor_lexer.g"
			isDecimal = true;
#line 1726 "MTSQLRefactorLexer.cpp"
			{
			switch ( LA(1)) {
			case 0x58 /* 'X' */ :
			case 0x78 /* 'x' */ :
			{
				{
				switch ( LA(1)) {
				case 0x78 /* 'x' */ :
				{
					match('x' /* charlit */ );
					break;
				}
				case 0x58 /* 'X' */ :
				{
					match('X' /* charlit */ );
					break;
				}
				default:
				{
					throw ANTLR_USE_NAMESPACE(antlr)NoViableAltForCharException(LA(1), getFilename(), getLine(), getColumn());
				}
				}
				}
				{ // ( ... )+
				int _cnt67=0;
				for (;;) {
					if ((_tokenSet_7.member(LA(1))) && (true) && (true) && (true) && (true) && (true) && (true) && (true)) {
						mHEX_DIGIT(false);
					}
					else {
						if ( _cnt67>=1 ) { goto _loop67; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltForCharException(LA(1), getFilename(), getLine(), getColumn());}
					}
					
					_cnt67++;
				}
				_loop67:;
				}  // ( ... )+
				break;
			}
			case 0x30 /* '0' */ :
			case 0x31 /* '1' */ :
			case 0x32 /* '2' */ :
			case 0x33 /* '3' */ :
			case 0x34 /* '4' */ :
			case 0x35 /* '5' */ :
			case 0x36 /* '6' */ :
			case 0x37 /* '7' */ :
			{
				{ // ( ... )+
				int _cnt69=0;
				for (;;) {
					if (((LA(1) >= 0x30 /* '0' */  && LA(1) <= 0x37 /* '7' */ ))) {
						matchRange('0','7');
					}
					else {
						if ( _cnt69>=1 ) { goto _loop69; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltForCharException(LA(1), getFilename(), getLine(), getColumn());}
					}
					
					_cnt69++;
				}
				_loop69:;
				}  // ( ... )+
				break;
			}
			default:
				{
				}
			}
			}
			break;
		}
		case 0x31 /* '1' */ :
		case 0x32 /* '2' */ :
		case 0x33 /* '3' */ :
		case 0x34 /* '4' */ :
		case 0x35 /* '5' */ :
		case 0x36 /* '6' */ :
		case 0x37 /* '7' */ :
		case 0x38 /* '8' */ :
		case 0x39 /* '9' */ :
		{
			{
			matchRange('1','9');
			}
			{ // ( ... )*
			for (;;) {
				if (((LA(1) >= 0x30 /* '0' */  && LA(1) <= 0x39 /* '9' */ ))) {
					matchRange('0','9');
				}
				else {
					goto _loop72;
				}
				
			}
			_loop72:;
			} // ( ... )*
#line 519 "mtsql_refactor_lexer.g"
			isDecimal=true;
#line 1825 "MTSQLRefactorLexer.cpp"
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltForCharException(LA(1), getFilename(), getLine(), getColumn());
		}
		}
		}
		{
		if ((LA(1) == 0x4c /* 'L' */  || LA(1) == 0x6c /* 'l' */ )) {
			{
			switch ( LA(1)) {
			case 0x6c /* 'l' */ :
			{
				match('l' /* charlit */ );
				{
				if ((LA(1) == 0x6c /* 'l' */ )) {
					match('l' /* charlit */ );
#line 521 "mtsql_refactor_lexer.g"
					_ttype = NUM_BIGINT;
#line 1846 "MTSQLRefactorLexer.cpp"
				}
				else {
				}
				
				}
				break;
			}
			case 0x4c /* 'L' */ :
			{
				match('L' /* charlit */ );
				{
				if ((LA(1) == 0x4c /* 'L' */ )) {
					match('L' /* charlit */ );
#line 521 "mtsql_refactor_lexer.g"
					_ttype = NUM_BIGINT;
#line 1862 "MTSQLRefactorLexer.cpp"
				}
				else {
				}
				
				}
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltForCharException(LA(1), getFilename(), getLine(), getColumn());
			}
			}
			}
		}
		else if (((_tokenSet_8.member(LA(1))))&&(isDecimal)) {
			{
			switch ( LA(1)) {
			case 0x2e /* '.' */ :
			{
				match('.' /* charlit */ );
#line 525 "mtsql_refactor_lexer.g"
				_ttype = NUM_DECIMAL;
#line 1885 "MTSQLRefactorLexer.cpp"
				{ // ( ... )*
				for (;;) {
					if (((LA(1) >= 0x30 /* '0' */  && LA(1) <= 0x39 /* '9' */ ))) {
						matchRange('0','9');
					}
					else {
						goto _loop79;
					}
					
				}
				_loop79:;
				} // ( ... )*
				{
				if ((LA(1) == 0x45 /* 'E' */  || LA(1) == 0x65 /* 'e' */ )) {
					mEXPONENT(false);
#line 525 "mtsql_refactor_lexer.g"
					_ttype = NUM_FLOAT;
#line 1903 "MTSQLRefactorLexer.cpp"
				}
				else {
				}
				
				}
				{
				if ((_tokenSet_6.member(LA(1)))) {
					mFLOAT_SUFFIX(false);
#line 525 "mtsql_refactor_lexer.g"
					_ttype = NUM_FLOAT;
#line 1914 "MTSQLRefactorLexer.cpp"
				}
				else {
				}
				
				}
				break;
			}
			case 0x45 /* 'E' */ :
			case 0x65 /* 'e' */ :
			{
				mEXPONENT(false);
				{
				if ((_tokenSet_6.member(LA(1)))) {
					mFLOAT_SUFFIX(false);
				}
				else {
				}
				
				}
#line 526 "mtsql_refactor_lexer.g"
				_ttype = NUM_FLOAT;
#line 1936 "MTSQLRefactorLexer.cpp"
				break;
			}
			case 0x44 /* 'D' */ :
			case 0x46 /* 'F' */ :
			case 0x64 /* 'd' */ :
			case 0x66 /* 'f' */ :
			{
				mFLOAT_SUFFIX(false);
#line 527 "mtsql_refactor_lexer.g"
				_ttype = NUM_FLOAT;
#line 1947 "MTSQLRefactorLexer.cpp"
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltForCharException(LA(1), getFilename(), getLine(), getColumn());
			}
			}
			}
		}
		else {
		}
		
		}
#line 530 "mtsql_refactor_lexer.g"
		
		mConvertedScript << text.substr(_begin, text.length()-_begin);
		
#line 1965 "MTSQLRefactorLexer.cpp"
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltForCharException(LA(1), getFilename(), getLine(), getColumn());
	}
	}
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mEXPONENT(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = EXPONENT;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	{
	switch ( LA(1)) {
	case 0x65 /* 'e' */ :
	{
		match('e' /* charlit */ );
		break;
	}
	case 0x45 /* 'E' */ :
	{
		match('E' /* charlit */ );
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltForCharException(LA(1), getFilename(), getLine(), getColumn());
	}
	}
	}
	{
	switch ( LA(1)) {
	case 0x2b /* '+' */ :
	{
		match('+' /* charlit */ );
		break;
	}
	case 0x2d /* '-' */ :
	{
		match('-' /* charlit */ );
		break;
	}
	case 0x30 /* '0' */ :
	case 0x31 /* '1' */ :
	case 0x32 /* '2' */ :
	case 0x33 /* '3' */ :
	case 0x34 /* '4' */ :
	case 0x35 /* '5' */ :
	case 0x36 /* '6' */ :
	case 0x37 /* '7' */ :
	case 0x38 /* '8' */ :
	case 0x39 /* '9' */ :
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltForCharException(LA(1), getFilename(), getLine(), getColumn());
	}
	}
	}
	{ // ( ... )+
	int _cnt87=0;
	for (;;) {
		if (((LA(1) >= 0x30 /* '0' */  && LA(1) <= 0x39 /* '9' */ ))) {
			matchRange('0','9');
		}
		else {
			if ( _cnt87>=1 ) { goto _loop87; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltForCharException(LA(1), getFilename(), getLine(), getColumn());}
		}
		
		_cnt87++;
	}
	_loop87:;
	}  // ( ... )+
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mFLOAT_SUFFIX(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = FLOAT_SUFFIX;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	switch ( LA(1)) {
	case 0x66 /* 'f' */ :
	{
		match('f' /* charlit */ );
		break;
	}
	case 0x46 /* 'F' */ :
	{
		match('F' /* charlit */ );
		break;
	}
	case 0x64 /* 'd' */ :
	{
		match('d' /* charlit */ );
		break;
	}
	case 0x44 /* 'D' */ :
	{
		match('D' /* charlit */ );
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltForCharException(LA(1), getFilename(), getLine(), getColumn());
	}
	}
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mHEX_DIGIT(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = HEX_DIGIT;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	{
	switch ( LA(1)) {
	case 0x30 /* '0' */ :
	case 0x31 /* '1' */ :
	case 0x32 /* '2' */ :
	case 0x33 /* '3' */ :
	case 0x34 /* '4' */ :
	case 0x35 /* '5' */ :
	case 0x36 /* '6' */ :
	case 0x37 /* '7' */ :
	case 0x38 /* '8' */ :
	case 0x39 /* '9' */ :
	{
		matchRange('0','9');
		break;
	}
	case 0x41 /* 'A' */ :
	case 0x42 /* 'B' */ :
	case 0x43 /* 'C' */ :
	case 0x44 /* 'D' */ :
	case 0x45 /* 'E' */ :
	case 0x46 /* 'F' */ :
	{
		matchRange('A','F');
		break;
	}
	case 0x61 /* 'a' */ :
	case 0x62 /* 'b' */ :
	case 0x63 /* 'c' */ :
	case 0x64 /* 'd' */ :
	case 0x65 /* 'e' */ :
	case 0x66 /* 'f' */ :
	{
		matchRange('a','f');
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltForCharException(LA(1), getFilename(), getLine(), getColumn());
	}
	}
	}
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}

void MTSQLRefactorLexer::mBIGINT_SUFFIX(bool _createToken) {
	int _ttype; ANTLR_USE_NAMESPACE(antlr)RefToken _token; ANTLR_USE_NAMESPACE(std)string::size_type _begin = text.length();
	_ttype = BIGINT_SUFFIX;
	ANTLR_USE_NAMESPACE(std)string::size_type _saveIndex;
	
	match("LL");
	if ( _createToken && _token==ANTLR_USE_NAMESPACE(antlr)nullToken && _ttype!=ANTLR_USE_NAMESPACE(antlr)Token::SKIP ) {
	   _token = makeToken(_ttype);
	   _token->setText(text.substr(_begin, text.length()-_begin));
	}
	_returnToken = _token;
	_saveIndex=0;
}


const unsigned long MTSQLRefactorLexer::_tokenSet_0_data_[] = { 0UL, 0UL, 2281701374UL, 134217726UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
// A B C D E F G H I J K L M N O P Q R S T U V W X Y Z _ a b c d e f g 
// h i j k l m n o p q r s t u v w x y z 
const ANTLR_USE_NAMESPACE(antlr)BitSet MTSQLRefactorLexer::_tokenSet_0(_tokenSet_0_data_,10);
const unsigned long MTSQLRefactorLexer::_tokenSet_1_data_[] = { 0UL, 67059712UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
// . 0 1 2 3 4 5 6 7 8 9 
const ANTLR_USE_NAMESPACE(antlr)BitSet MTSQLRefactorLexer::_tokenSet_1(_tokenSet_1_data_,10);
const unsigned long MTSQLRefactorLexer::_tokenSet_2_data_[] = { 4294966264UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
// 0x3 0x4 0x5 0x6 0x7 0x8 0x9 0xb 0xc 0xd 0xe 0xf 0x10 0x11 0x12 0x13 
// 0x14 0x15 0x16 0x17 0x18 0x19 0x1a 0x1b 0x1c 0x1d 0x1e 0x1f   ! \" # 
// $ % & \' ( ) * + , - . / 0 1 2 3 4 5 6 7 8 9 : ; < = > ? @ A B C D E 
// F G H I J K L M N O P Q R S T U V W X Y Z [ 0x5c ] ^ _ ` a b c d e f 
// g h i j k l m n o p q r s t u v w x y z { | } 
const ANTLR_USE_NAMESPACE(antlr)BitSet MTSQLRefactorLexer::_tokenSet_2(_tokenSet_2_data_,16);
const unsigned long MTSQLRefactorLexer::_tokenSet_3_data_[] = { 4294958072UL, 4294966271UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
// 0x3 0x4 0x5 0x6 0x7 0x8 0x9 0xb 0xc 0xe 0xf 0x10 0x11 0x12 0x13 0x14 
// 0x15 0x16 0x17 0x18 0x19 0x1a 0x1b 0x1c 0x1d 0x1e 0x1f   ! \" # $ % 
// & \' ( ) + , - . / 0 1 2 3 4 5 6 7 8 9 : ; < = > ? @ A B C D E F G H 
// I J K L M N O P Q R S T U V W X Y Z [ 0x5c ] ^ _ ` a b c d e f g h i 
// j k l m n o p q r s t u v w x y z { | } 
const ANTLR_USE_NAMESPACE(antlr)BitSet MTSQLRefactorLexer::_tokenSet_3(_tokenSet_3_data_,16);
const unsigned long MTSQLRefactorLexer::_tokenSet_4_data_[] = { 4294958072UL, 4294967167UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
// 0x3 0x4 0x5 0x6 0x7 0x8 0x9 0xb 0xc 0xe 0xf 0x10 0x11 0x12 0x13 0x14 
// 0x15 0x16 0x17 0x18 0x19 0x1a 0x1b 0x1c 0x1d 0x1e 0x1f   ! \" # $ % 
// & ( ) * + , - . / 0 1 2 3 4 5 6 7 8 9 : ; < = > ? @ A B C D E F G H 
// I J K L M N O P Q R S T U V W X Y Z [ 0x5c ] ^ _ ` a b c d e f g h i 
// j k l m n o p q r s t u v w x y z { | } 
const ANTLR_USE_NAMESPACE(antlr)BitSet MTSQLRefactorLexer::_tokenSet_4(_tokenSet_4_data_,16);
const unsigned long MTSQLRefactorLexer::_tokenSet_5_data_[] = { 4294967288UL, 4294967287UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 4294967295UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
// 0x3 0x4 0x5 0x6 0x7 0x8 0x9 0xa 0xb 0xc 0xd 0xe 0xf 0x10 0x11 0x12 0x13 
// 0x14 0x15 0x16 0x17 0x18 0x19 0x1a 0x1b 0x1c 0x1d 0x1e 0x1f   ! \" $ 
// % & \' ( ) * + , - . / 0 1 2 3 4 5 6 7 8 9 : ; < = > ? @ A B C D E F 
// G H I J K L M N O P Q R S T U V W X Y Z [ 0x5c ] ^ _ ` a b c d e f g 
// h i j k l m n o p q r s t u v w x y z { | } 
const ANTLR_USE_NAMESPACE(antlr)BitSet MTSQLRefactorLexer::_tokenSet_5(_tokenSet_5_data_,16);
const unsigned long MTSQLRefactorLexer::_tokenSet_6_data_[] = { 0UL, 0UL, 80UL, 80UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
// D F d f 
const ANTLR_USE_NAMESPACE(antlr)BitSet MTSQLRefactorLexer::_tokenSet_6(_tokenSet_6_data_,10);
const unsigned long MTSQLRefactorLexer::_tokenSet_7_data_[] = { 0UL, 67043328UL, 126UL, 126UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
// 0 1 2 3 4 5 6 7 8 9 A B C D E F a b c d e f 
const ANTLR_USE_NAMESPACE(antlr)BitSet MTSQLRefactorLexer::_tokenSet_7(_tokenSet_7_data_,10);
const unsigned long MTSQLRefactorLexer::_tokenSet_8_data_[] = { 0UL, 16384UL, 112UL, 112UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
// . D E F d e f 
const ANTLR_USE_NAMESPACE(antlr)BitSet MTSQLRefactorLexer::_tokenSet_8(_tokenSet_8_data_,10);

