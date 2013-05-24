#ifndef INC_MTSQLLexer_hpp_
#define INC_MTSQLLexer_hpp_

#include <antlr/config.hpp>
/* $ANTLR 2.7.6 (2005-12-22): "mtsql_lexer.g" -> "MTSQLLexer.hpp"$ */
#include <antlr/CommonToken.hpp>
#include <antlr/InputBuffer.hpp>
#include <antlr/BitSet.hpp>
#include "MTSQLTokenTypes.hpp"
#include <antlr/CharScanner.hpp>
#line 1 "mtsql_lexer.g"

  #include "MTSQLInterpreter.h"

#line 16 "MTSQLLexer.hpp"
class CUSTOM_API MTSQLLexer : public ANTLR_USE_NAMESPACE(antlr)CharScanner, public MTSQLTokenTypes
{
#line 110 "mtsql_lexer.g"

private:
  Logger* mLog;
public:
  
	// Override the error and warning reporting
  virtual void reportError(const ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex)
  {
	mLog->logError(ex.toString());
  }

	/** Parser error-reporting function can be overridden in subclass */
  virtual void reportError(const ANTLR_USE_NAMESPACE(std)string& s)
  {
	mLog->logError(s);
  }

	/** Parser warning-reporting function can be overridden in subclass */
  virtual void reportWarning(const ANTLR_USE_NAMESPACE(std)string& s)
  {
	mLog->logWarning(s);
  }

  void setLog(Logger * log)
  {
	mLog = log;
  }
#line 20 "MTSQLLexer.hpp"
private:
	void initLiterals();
public:
	bool getCaseSensitiveLiterals() const
	{
		return false;
	}
public:
	MTSQLLexer(ANTLR_USE_NAMESPACE(std)istream& in);
	MTSQLLexer(ANTLR_USE_NAMESPACE(antlr)InputBuffer& ib);
	MTSQLLexer(const ANTLR_USE_NAMESPACE(antlr)LexerSharedInputState& state);
	ANTLR_USE_NAMESPACE(antlr)RefToken nextToken();
	public: void mAMPERSAND(bool _createToken);
	public: void mEQUALS(bool _createToken);
	public: void mNOTEQUALS(bool _createToken);
	public: void mNOTEQUALS2(bool _createToken);
	public: void mLTN(bool _createToken);
	public: void mLTEQ(bool _createToken);
	public: void mGT(bool _createToken);
	public: void mGTEQ(bool _createToken);
	public: void mMODULO(bool _createToken);
	public: void mSL_COMMENT(bool _createToken);
	public: void mML_COMMENT(bool _createToken);
	public: void mCARET(bool _createToken);
	public: void mCOMMA(bool _createToken);
	public: void mDOT(bool _createToken);
	public: void mLPAREN(bool _createToken);
	public: void mRPAREN(bool _createToken);
	public: void mMINUS(bool _createToken);
	public: void mPIPE(bool _createToken);
	public: void mPLUS(bool _createToken);
	public: void mSEMI(bool _createToken);
	public: void mSLASH(bool _createToken);
	public: void mSTAR(bool _createToken);
	public: void mSTRING_LITERAL(bool _createToken);
	public: void mENUM_LITERAL(bool _createToken);
	public: void mWSTRING_LITERAL(bool _createToken);
	public: void mTILDE(bool _createToken);
	public: void mWS(bool _createToken);
	public: void mID(bool _createToken);
	public: void mLOCALVAR(bool _createToken);
	public: void mGLOBALVAR(bool _createToken);
	public: void mNUM_INT(bool _createToken);
	protected: void mEXPONENT(bool _createToken);
	protected: void mFLOAT_SUFFIX(bool _createToken);
	protected: void mHEX_DIGIT(bool _createToken);
	protected: void mBIGINT_SUFFIX(bool _createToken);
private:
	
	static const unsigned long _tokenSet_0_data_[];
	static const ANTLR_USE_NAMESPACE(antlr)BitSet _tokenSet_0;
	static const unsigned long _tokenSet_1_data_[];
	static const ANTLR_USE_NAMESPACE(antlr)BitSet _tokenSet_1;
	static const unsigned long _tokenSet_2_data_[];
	static const ANTLR_USE_NAMESPACE(antlr)BitSet _tokenSet_2;
	static const unsigned long _tokenSet_3_data_[];
	static const ANTLR_USE_NAMESPACE(antlr)BitSet _tokenSet_3;
	static const unsigned long _tokenSet_4_data_[];
	static const ANTLR_USE_NAMESPACE(antlr)BitSet _tokenSet_4;
	static const unsigned long _tokenSet_5_data_[];
	static const ANTLR_USE_NAMESPACE(antlr)BitSet _tokenSet_5;
	static const unsigned long _tokenSet_6_data_[];
	static const ANTLR_USE_NAMESPACE(antlr)BitSet _tokenSet_6;
	static const unsigned long _tokenSet_7_data_[];
	static const ANTLR_USE_NAMESPACE(antlr)BitSet _tokenSet_7;
	static const unsigned long _tokenSet_8_data_[];
	static const ANTLR_USE_NAMESPACE(antlr)BitSet _tokenSet_8;
};

#endif /*INC_MTSQLLexer_hpp_*/
