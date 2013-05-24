#ifndef _TEST_H_
#define _TEST_H_

#include <string>
#include <iostream>

#include "MTSQLInterpreter.h"
#include "testFrame.h"

class PrimitiveFunction;

#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )

class UnitTestMTSQLParser
{
private:
	bool ParseProgram(const std::string& str);
	void UnitTest1();
	void UnitTestSelectStatement();
public:
	UnitTestMTSQLParser();
	void RunTests();
};

class UnitTestMTSQLAnalyzer
{
private:
	void AnalyzeProgram(const std::string& str);
	void UnitTest1();
public:
	UnitTestMTSQLAnalyzer();
	void RunTests();
};

class UnitTestMTSQLExecution
{
private:
	void ArithmeticTests();
	void ConditionalTests();
	void LogicalTests();
	void ExecuteProgram(const std::wstring& str, const std::vector<RuntimeValue>& inputs, const std::vector<RuntimeValue>& outputs);
public:
	UnitTestMTSQLExecution();
	void RunTests();
};

class TestStandardLibrary
{
private:
  RuntimeValue execute(PrimitiveFunction * f, const std::vector<RuntimeValue>& args);
	void VerifyStandardLibraryContents();
	void TestSubstr();
	void TestUpper();
	void TestLower();
public:
	TestStandardLibrary();
	void RunTests();
};


class MTSQLTestGlobalCompileEnvironment : public GlobalCompileEnvironment
{
private:
	MTFrame * mFrame;
public:
	Frame* createFrame()
	{
		delete mFrame;
		return (mFrame=new MTFrame);
	}

	MTFrame* getFrame()
	{
		return mFrame;
	}

	bool isOkToLogError()
	{
		return true;
	}
	bool isOkToLogWarning()
	{
		return true;
	}
	bool isOkToLogInfo()
	{
		return false;
	}
	bool isOkToLogDebug()
	{
		return false;
	}
	void logError(const string& str)
	{
		cerr << "Error: " << str << endl;
	}

	void logWarning(const string& str)
	{
		cout << "Warning: " << str << endl;
	}

	void logInfo(const string& str)
	{
// 		cout << "Info: " << str << endl;
	}

	void logDebug(const string& str)
	{
// 		cout << "Info: " << str << endl;
	}

	MTSQLTestGlobalCompileEnvironment()
	{
		mFrame = NULL;
	}
	
  ~MTSQLTestGlobalCompileEnvironment()
	{
		delete mFrame;
	}
};

class MTSQLTestGlobalRuntimeEnvironment : public GlobalRuntimeEnvironment
{
	VectorActivationRecord mActivationRecord;
public:

	MTSQLTestGlobalRuntimeEnvironment(std::size_t sz=100) : mActivationRecord(NULL, sz)
	{
	}

	VectorActivationRecord* getActivationRecord()
	{
		return &mActivationRecord;
	}

	MTPipelineLib::IMTSQLRowsetPtr getRowset()
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(__uuidof(ROWSETLib::MTSQLRowset));
		rowset->Init(L"config\\ProductCatalog");
		return MTPipelineLib::IMTSQLRowsetPtr(reinterpret_cast<MTPipelineLib::IMTSQLRowset *>(rowset.GetInterfacePtr()));
	}

	bool isOkToLogError()
	{
		return true;
	}
	bool isOkToLogWarning()
	{
		return true;
	}
	bool isOkToLogInfo()
	{
		return true;
	}
	bool isOkToLogDebug()
	{
		return true;
	}
	void logError(const string& str)
	{
		cerr << "Error: " << str << endl;
	}

	void logWarning(const string& str)
	{
		cout << "Warning: " << str << endl;
	}

	void logInfo(const string& str)
	{
		cout << "Info: " << str << endl;
	}

	void logDebug(const string& str)
	{
		cout << "Info: " << str << endl;
	}
};

#endif
