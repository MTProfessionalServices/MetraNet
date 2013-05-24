// ComMtsqlInterpreter.cpp : Implementation of CComMtsqlInterpreter
#include "StdAfx.h"
#include "COMInterpreter.h"
#include "ComMtsqlInterpreter.h"
#include "MTSQLInterpreter.h"
#include "MTSQLSelectCommand.h"
#include "BatchQuery.h"
#include <OdbcException.h>
#include "RuntimeValue.h"
#include <autologger.h>

#include <map>
#include <strstream>
using namespace std;

extern char gComInterpreterLogMsg[] = "COMInterpreter";
extern char gComInterpreterLogMsgDir[] = "logging\\";

#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )

class MTOffsetAccess : public Access
{
private:
	std::vector<_variant_t>::size_type mAccess;
	MTOffsetAccess(std::vector<_variant_t>::size_type access) : mAccess(access) {}
public:

	std::vector<_variant_t>::size_type getAccess() const 
	{
		return mAccess;
	}

	friend class MTOffsetAccessFactory;
};

class MTOffsetAccessFactory
{
private:
	std::map<std::vector<_variant_t>::size_type, AccessPtr> mMap;
public:
	AccessPtr create(std::vector<_variant_t>::size_type access)
	{
		AccessPtr mtAccess=mMap[access];
		if (mtAccess == nullAccess)
		{
			mtAccess = AccessPtr(new MTOffsetAccess(access));
			mMap[access] = mtAccess;
		}
		return mtAccess;
	}

	~MTOffsetAccessFactory()
	{
	}
};


class DispatchFrame : public Frame
{
private:
	map<_bstr_t, std::vector<_variant_t>::size_type> mAllocatedVariables;
	MTOffsetAccessFactory* mFactory;
public:
	// We do not own the factory object
	DispatchFrame(MTOffsetAccessFactory* factory) 
	{
		mFactory = factory;
	}

	AccessPtr allocateVariable(const std::string& var, int )
	{
		// First try to find the string in the list.  We will
		// not allow a variable to be allocated more than once.
		_bstr_t key(var.c_str());
		if(mAllocatedVariables.find(key) == mAllocatedVariables.end())
		{
			mAllocatedVariables[key] = mAllocatedVariables.size();
		}
		return mFactory->create(mAllocatedVariables[key]);
	}

	std::vector<_variant_t>::size_type lookupVariable(_bstr_t var)
	{
		if(mAllocatedVariables.find(var) == mAllocatedVariables.end())
		{
			return std::vector<_variant_t>::size_type(-1);
		}
		return mAllocatedVariables[var];
	}

	~DispatchFrame() 
	{
	}
};

class VariantActivationRecord : public ActivationRecord
{
private:
	ActivationRecord* mStaticLink;
	std::vector<_variant_t> mRuntimeEnv;

	_variant_t mNullVariant;

public:
	VariantActivationRecord(ActivationRecord* staticLink) : mStaticLink(staticLink)
	{
		VARIANT var;
		V_VT(&var) = VT_NULL;
		mNullVariant = var;
	}

	void getLongValue(const Access * access, RuntimeValue * value)
	{
		try {
			_variant_t val = getValue(access);
			if (V_VT(&val) == VT_NULL || V_VT(&val) == VT_EMPTY) 
				return value->assignNull();
			else 
				return value->assignLong(long(val));
		} catch(_com_error& err) {
			throw MTSQLComException(err.Error());
		}
	}
	void getLongLongValue(const Access * access, RuntimeValue * value)
	{
		try {
			_variant_t val = getValue(access);
			if (V_VT(&val) == VT_NULL || V_VT(&val) == VT_EMPTY) 
				return value->assignNull();
			else 
				return value->assignLongLong(__int64(val));
		} catch(_com_error& err) {
			throw MTSQLComException(err.Error());
		}
	}
	void getDoubleValue(const Access * access, RuntimeValue * value)
	{
		try {
			_variant_t val = getValue(access);
			if (V_VT(&val) == VT_NULL || V_VT(&val) == VT_EMPTY) 
				return value->assignNull();
			else 
				return value->assignDouble((double(val)));
		} catch(_com_error& err) {
			throw MTSQLComException(err.Error());
		}
	}
	void getDecimalValue(const Access * access, RuntimeValue * value)
	{
		try {
			_variant_t val = getValue(access);
			if (V_VT(&val) == VT_NULL || V_VT(&val) == VT_EMPTY) 
				return value->assignNull();
			else 
				return value->assignDec(&DECIMAL(val));
		} catch(_com_error& err) {
			throw MTSQLComException(err.Error());
		}
	}
	void getStringValue(const Access * access, RuntimeValue * value)
	{
		try {
			_variant_t val = getValue(access);
			if (V_VT(&val) == VT_NULL || V_VT(&val) == VT_EMPTY) 
				return value->assignNull();
			else 
				return value->assignString(std::string((const char *) _bstr_t(val)));
		} catch(_com_error& err) {
			throw MTSQLComException(err.Error());
		}
	}
	void getWStringValue(const Access * access, RuntimeValue * value)
	{
		try {
			_variant_t val = getValue(access);
			if (V_VT(&val) == VT_NULL || V_VT(&val) == VT_EMPTY) 
				return value->assignNull();
			else 
				return value->assignWString((const wchar_t *) _bstr_t(val));
		} catch(_com_error& err) {
			throw MTSQLComException(err.Error());
		}
	}
	void getBooleanValue(const Access * access, RuntimeValue * value)
	{
		try {
			_variant_t val = getValue(access);
			if (V_VT(&val) == VT_NULL || V_VT(&val) == VT_EMPTY) 
				return value->assignNull();
			else 
				return value->assignBool(bool(val));
		} catch(_com_error& err) {
			throw MTSQLComException(err.Error());
		}
	}
	void getDatetimeValue(const Access * access, RuntimeValue * value)
	{
		try {
			_variant_t val = getValue(access);
			if (V_VT(&val) == VT_NULL || V_VT(&val) == VT_EMPTY) 
				return value->assignNull();
			else 
				return value->assignDatetime(DATE(val));
		} catch(_com_error& err) {
			throw MTSQLComException(err.Error());
		}
	}
	void getTimeValue(const Access * access, RuntimeValue * value)
	{
		try {
			_variant_t val = getValue(access);
			if (V_VT(&val) == VT_NULL || V_VT(&val) == VT_EMPTY) 
				return value->assignNull();
			else 
				return value->assignTime(long(val));
		} catch(_com_error& err) {
			throw MTSQLComException(err.Error());
		}
	}
	void getEnumValue(const Access * access, RuntimeValue * value)
	{
		try {
			_variant_t val = getValue(access);
			if (V_VT(&val) == VT_NULL || V_VT(&val) == VT_EMPTY) 
				return value->assignNull();
			else 
				return value->assignEnum(long(val));
		} catch(_com_error& err) {
			throw MTSQLComException(err.Error());
		}
	}
	void getBinaryValue(const Access * access, RuntimeValue * value)
	{
    throw std::runtime_error("BINARY unsupported");
	}
	void setLongValue(const Access * access, const RuntimeValue * value)
	{
		setValue(access, value->isNullRaw() ? mNullVariant : _variant_t(value->getLong()));
	}
	void setLongLongValue(const Access * access, const RuntimeValue * value)
	{
		setValue(access, value->isNullRaw() ? mNullVariant : _variant_t(value->getLongLong()));
	}
	void setDoubleValue(const Access * access, const RuntimeValue * value)
	{
		setValue(access, value->isNullRaw() ? mNullVariant : _variant_t(value->getDouble()));
	}
	void setDecimalValue(const Access * access, const RuntimeValue * value)
	{
		setValue(access, value->isNullRaw() ? mNullVariant : _variant_t(value->getDec()));
	}
	void setStringValue(const Access * access, const RuntimeValue * value)
	{
		setValue(access, value->isNullRaw() ? mNullVariant : _variant_t(_bstr_t(value->getStringPtr())));
	}
	void setWStringValue(const Access * access, const RuntimeValue * value)
	{
		setValue(access, value->isNullRaw() ? mNullVariant : _variant_t(_bstr_t(value->getWStringPtr())));
	}
	void setBooleanValue(const Access * access, const RuntimeValue * value)
	{
		setValue(access, value->isNullRaw() ? mNullVariant : _variant_t(value->getBool()));
	}
	void setDatetimeValue(const Access * access, const RuntimeValue * value)
	{
		setValue(access, value->isNullRaw() ? mNullVariant : _variant_t(value->getDatetime(), VT_DATE));
	}
	void setTimeValue(const Access * access, const RuntimeValue * value)
	{
		setValue(access, value->isNullRaw() ? mNullVariant : _variant_t(value->getTime()));
	}
	void setEnumValue(const Access * access, const RuntimeValue * value)
	{
		setValue(access, value->isNullRaw() ? mNullVariant : _variant_t(value->getEnum()));
	}
	void setBinaryValue(const Access * access, const RuntimeValue * value)
	{
    throw std::runtime_error("BINARY unsupported");
	}

	_variant_t getValue(const Access * access)
	{
		std::vector<_variant_t>::size_type idx = (reinterpret_cast<const MTOffsetAccess *>(access))->getAccess();
		if(idx >= mRuntimeEnv.size())
		{
			return mNullVariant;
		}
		else
		{
			return mRuntimeEnv.at(idx);
		}
	}

	void setValue(const Access * access, _variant_t val)
	{
		std::vector<_variant_t>::size_type pos = (reinterpret_cast<const MTOffsetAccess *>(access))->getAccess();
		if (pos >= mRuntimeEnv.size()) mRuntimeEnv.resize(pos+1);
		mRuntimeEnv.at(pos) = val;
	}

	ActivationRecord* getStaticLink() 
	{
		return mStaticLink;
	}
};

class DispatchGlobalCompileEnvironment : public GlobalCompileEnvironment
{
private:
	MTOffsetAccessFactory *mFactory;
	DispatchFrame *mFrame;

	DispatchFrame* getFrame()
	{
		return mFrame;
	}

	MTAutoInstance<MTAutoLoggerImpl<gComInterpreterLogMsg,gComInterpreterLogMsgDir> > mLogger;

	std::vector<string> mErrors;
	std::vector<string> mWarnings;
	std::vector<string> mInfos;
	std::vector<string> mDebugs;
public:

	DispatchGlobalCompileEnvironment()
	{
		mFactory = new MTOffsetAccessFactory();
		mFrame = new DispatchFrame(mFactory);
	}

	~DispatchGlobalCompileEnvironment()
	{
		delete mFrame;
		delete mFactory;
	}

	std::vector<_variant_t>::size_type lookupVariable(_bstr_t var)
	{
		return getFrame()->lookupVariable(var);
	}

	Frame* createFrame()
	{
		return getFrame();
	}

	MTOffsetAccessFactory* getFactory()
	{
		return mFactory;
	}

	void logError(const string& str)
	{
		mErrors.push_back(str);
    mLogger->LogThis(LOG_ERROR, str.c_str());
	}

	void logWarning(const string& str)
	{
		mWarnings.push_back(str);
    mLogger->LogThis(LOG_WARNING, str.c_str());
	}

	void logInfo(const string& str)
	{
		mInfos.push_back(str);
    mLogger->LogThis(LOG_INFO, str.c_str());
	}

	void logDebug(const string& str)
	{
		mDebugs.push_back(str);
    mLogger->LogThis(LOG_DEBUG, str.c_str());
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


	std::string dumpErrors()
	{
		// Print the errors in the order in which they arrived
		std::string dump;
		for(vector<string>::size_type i = 0; i < mErrors.size(); i++)
		{
			dump.append(mErrors[i]);
			dump.append("\n");
		}
		return dump;
	}
};

class DispatchGlobalRuntimeEnvironment : public GlobalRuntimeEnvironment
{
	VariantActivationRecord mActivationRecord;
	std::vector<string> mErrors;
	std::vector<string> mWarnings;
	std::vector<string> mInfos;
	std::vector<string> mDebugs;
	MTAutoInstance<MTAutoLoggerImpl<gComInterpreterLogMsg,gComInterpreterLogMsgDir> > mLogger;

public:

	DispatchGlobalRuntimeEnvironment() : mActivationRecord(NULL)
	{
	}
	ActivationRecord* getActivationRecord()
	{
		return getVariantActivationRecord();
	}

	MTPipelineLib::IMTSQLRowsetPtr getRowset()
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(__uuidof(ROWSETLib::MTSQLRowset));
		rowset->Init(L"config\\ProductCatalog");
		return MTPipelineLib::IMTSQLRowsetPtr(reinterpret_cast<MTPipelineLib::IMTSQLRowset *>(rowset.GetInterfacePtr()));
	}

	VariantActivationRecord* getVariantActivationRecord()
	{
		return &mActivationRecord;
	}

	void logError(const string& str)
	{
		mErrors.push_back(str);
    mLogger->LogThis(LOG_ERROR, str.c_str());
	}

	void logWarning(const string& str)
	{
		mWarnings.push_back(str);
    mLogger->LogThis(LOG_WARNING, str.c_str());
	}

	void logInfo(const string& str)
	{
		mInfos.push_back(str);
    mLogger->LogThis(LOG_INFO, str.c_str());
	}

	void logDebug(const string& str)
	{
		mDebugs.push_back(str);
    mLogger->LogThis(LOG_DEBUG, str.c_str());
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


	std::string dumpErrors()
	{
		// Print the errors in the order in which they arrived
		std::string dump;
		for(vector<string>::size_type i = 0; i < mErrors.size(); i++)
		{
			dump.append(mErrors[i]);
			dump.append("\n");
		}
		return dump;
	}
};

/////////////////////////////////////////////////////////////////////////////
// CComMtsqlInterpreter

void CComMtsqlInterpreter::Cleanup()
{
	delete mInterpreter;
  mInterpreter = NULL;
  for(unsigned int i=0; i<mCompileEnvironment.size(); i++)
  {
    delete mCompileEnvironment[i];
  }
  mCompileEnvironment.clear();
  for(unsigned int i=0; i<mRuntimeEnvironment.size(); i++)
  {
    delete mRuntimeEnvironment[i];
  }
  mRuntimeEnvironment.clear();
  mCurrentRequest=-1;
  delete mQuery;
  mQuery = NULL;
}

void CComMtsqlInterpreter::PushRequest()
{
  mCompileEnvironment.push_back(new DispatchGlobalCompileEnvironment());
  mRuntimeEnvironment.push_back(new DispatchGlobalRuntimeEnvironment());
  mCurrentRequest++;
}

CComMtsqlInterpreter::~CComMtsqlInterpreter()
{
  Cleanup();
}

HRESULT CComMtsqlInterpreter::GetIDsOfNames(            
			/* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR __RPC_FAR *rgszNames,
            /* [in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID __RPC_FAR *rgDispId)
{
	for(UINT i=0; i<cNames; i++)
	{
		_bstr_t name(rgszNames[i]);
		std::vector<_variant_t>::size_type index;
		if(name == _bstr_t("SupportVarchar")) 
		{
			rgDispId[i] = 5;
		}
		else if(name == _bstr_t("SetRequest")) 
		{
			rgDispId[i] = 4;
		}
		else if(name == _bstr_t("PushRequest")) 
		{
			rgDispId[i] = 3;
		}
		else if (name == _bstr_t("Query"))
		{
			rgDispId[i] = 2;
		}
		else if (name == _bstr_t("Program"))
		{
			rgDispId[i] = 1;
		}
		else if (name == _bstr_t("Execute"))
		{
			rgDispId[i] = 0;
		}
		else if (mCurrentRequest >= 0 && mCompileEnvironment[0] != NULL && 
						 std::vector<_variant_t>::size_type(-1) != (index=mCompileEnvironment[0]->lookupVariable(_bstr_t("@") + name)))
		{
			rgDispId[i] = 6 + index;
		}
		else
		{
			return DISP_E_UNKNOWNNAME;
		}
	}
	return S_OK;
}


HRESULT CComMtsqlInterpreter::GetTypeInfo(            
			/* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo __RPC_FAR *__RPC_FAR *ppTInfo)
{
	*ppTInfo = NULL;
	return S_OK;
}

HRESULT CComMtsqlInterpreter::GetTypeInfoCount(UINT __RPC_FAR *  pctinfo)
{
	*pctinfo = 0;
	return S_OK;
}

	
HRESULT CComMtsqlInterpreter::Invoke( 
            /* [in] */ DISPID dispIdMember,
            /* [in] */ REFIID riid,
            /* [in] */ LCID lcid,
            /* [in] */ WORD wFlags,
            /* [out][in] */ DISPPARAMS __RPC_FAR *pDispParams,
            /* [out] */ VARIANT __RPC_FAR *pVarResult,
            /* [out] */ EXCEPINFO __RPC_FAR *pExcepInfo,
            /* [out] */ UINT __RPC_FAR *puArgErr)
{
	if (riid != IID_NULL)			// Unknown Interface request
	{
		return DISP_E_UNKNOWNINTERFACE;
	}

	// Special case for the Execute method
	if(dispIdMember == 0)
	{
    if(mIsQuery)
    {
      std::vector<ActivationRecord*> activations;
      for(unsigned int i=0; i<mRuntimeEnvironment.size(); i++)
      {
        activations.push_back(mRuntimeEnvironment[i]->getActivationRecord());
      }
      try 
      {
        mQuery->ExecuteQuery(activations);
      }
      catch (std::exception & odbcException)
      {
				// Return the error somehow
				if (pExcepInfo)
				{
					memset(pExcepInfo, 0, sizeof(EXCEPINFO));
					pExcepInfo->wCode = 2000;
					pExcepInfo->bstrSource = ::SysAllocString(L"ComMtsqlInterpreter");
					_bstr_t bstrErrorDump(odbcException.what());
					pExcepInfo->bstrDescription = ::SysAllocString((wchar_t *)bstrErrorDump);
				}
				return DISP_E_EXCEPTION;
      }
    }
    else
    {
    for(unsigned int i=0; i<mRuntimeEnvironment.size(); i++)
    {
      try {
//         mExecutable->exec(mRuntimeEnvironment[i]);
        mExecutable->codeGenerate(mCompileEnvironment[0]);
//         TestRuntimeEnvironment renv(mRuntimeEnvironment[i]->getActivationRecord());
        mExecutable->execCompiled(mRuntimeEnvironment[i]);
//         MTSQLRegisterMachine machine;
//         machine.Execute(prog, &renv, mRuntimeEnvironment[i]);
//         for(unsigned int i=0; i<prog.size(); i++)
//         {
//           MTSQLInstruction * inst = prog[i];
//           prog[i] = NULL;
//           delete inst;
//         }
      } catch (MTSQLUserException& uex) {
				// Return the error somehow
				if (pExcepInfo)
				{
					memset(pExcepInfo, 0, sizeof(EXCEPINFO));
					pExcepInfo->wCode = 2000;
					pExcepInfo->bstrSource = ::SysAllocString(L"ComMtsqlInterpreter");
					// Grab the HRESULT of the exception and append to the message
					_bstr_t bstrErrorDump(uex.toString().c_str());
					TCHAR atchBuf[2048];
					DWORD dwRet = ::FormatMessage(
						FORMAT_MESSAGE_FROM_SYSTEM,
						NULL,
						uex.GetHRESULT(),
						MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
						(LPTSTR) atchBuf,
						2048,
						0);
					if(dwRet != 0)
					{
						if (bstrErrorDump != _bstr_t(L"")) bstrErrorDump += _bstr_t(L": ");
						bstrErrorDump += _bstr_t(atchBuf);
					}
					else
					{
						if (bstrErrorDump != _bstr_t(L"")) 
							bstrErrorDump += _bstr_t(L": Error Not Found");
						else
							bstrErrorDump += _bstr_t(L"Error Not Found");
					}
					pExcepInfo->bstrDescription = ::SysAllocString((wchar_t *)bstrErrorDump);
				}
				return DISP_E_EXCEPTION;
      } catch (MTSQLException& ex) {
				// Return the error somehow
				if (pExcepInfo)
				{
					memset(pExcepInfo, 0, sizeof(EXCEPINFO));
					pExcepInfo->wCode = 2000;
					pExcepInfo->bstrSource = ::SysAllocString(L"ComMtsqlInterpreter");
					_bstr_t bstrErrorDump(ex.toString().c_str());
					pExcepInfo->bstrDescription = ::SysAllocString((wchar_t *)bstrErrorDump);
				}
				return DISP_E_EXCEPTION;
      }
    }
    }
	}

	// Special case for the Program property
	else if(dispIdMember == 1)
	{
		if (DISPATCH_PROPERTYGET & wFlags)
		{
			if(pVarResult)
			{	
				_variant_t varResult(mProgram);
				VariantClear (pVarResult);
				VariantCopy (pVarResult, &(varResult.Detach()));
			}
		}
		if (DISPATCH_PROPERTYPUT & wFlags)
		{
      mIsQuery = false;
			mProgram = pDispParams->rgvarg[0].bstrVal;
      Cleanup();
      PushRequest();
      try 
      {
        mInterpreter = new MTSQLInterpreter(mCompileEnvironment[0]);
        mInterpreter->setSupportVarchar(mSupportVarchar);
       //go from bstr to const wchar_t *
        mExecutable = mInterpreter->analyze((const wchar_t *)mProgram);

        if (mExecutable == NULL)
        {
          // Return the error somehow
          if (pExcepInfo)
          {
            memset(pExcepInfo, 0, sizeof(EXCEPINFO));
            pExcepInfo->wCode = 2000;
            pExcepInfo->bstrSource = ::SysAllocString(L"ComMtsqlInterpreter");
            _bstr_t bstrErrorDump(mCompileEnvironment[0]->dumpErrors().c_str());
            pExcepInfo->bstrDescription = ::SysAllocString((wchar_t *)bstrErrorDump);
          }
          return DISP_E_EXCEPTION;
        }
      }
      catch(std::exception& stlException)
      {
				if (pExcepInfo)
				{
					memset(pExcepInfo, 0, sizeof(EXCEPINFO));
					pExcepInfo->wCode = 2000;
					pExcepInfo->bstrSource = ::SysAllocString(L"ComMtsqlInterpreter");
					_bstr_t bstrErrorDump(stlException.what());
					pExcepInfo->bstrDescription = ::SysAllocString((wchar_t *)bstrErrorDump);
				}
				return DISP_E_EXCEPTION;
			}
    }  
	}
  // Query
  else if (dispIdMember == 2)
  {
		if (DISPATCH_PROPERTYGET & wFlags)
		{
			if(pVarResult)
			{	
				_variant_t varResult(mProgram);
				VariantClear (pVarResult);
				VariantCopy (pVarResult, &(varResult.Detach()));
			}
		}
		if (DISPATCH_PROPERTYPUT & wFlags)
		{
      mIsQuery = true;
			mProgram = pDispParams->rgvarg[0].bstrVal;
      Cleanup();
      PushRequest();
      try
      {
        mInterpreter = new MTSQLInterpreter(mCompileEnvironment[0]);
        mInterpreter->setSupportVarchar(mSupportVarchar);
        mInterpreter->setTempTable("foo", "bar");
        if (NULL == mInterpreter->analyze((const wchar_t *)mProgram) || NULL == (mQuery=mInterpreter->analyzeQuery()))

        {
          // Return the error somehow
          if (pExcepInfo)
          {
            memset(pExcepInfo, 0, sizeof(EXCEPINFO));
            pExcepInfo->wCode = 2000;
            pExcepInfo->bstrSource = ::SysAllocString(L"ComMtsqlInterpreter");
            _bstr_t bstrErrorDump(mCompileEnvironment[0]->dumpErrors().c_str());
            pExcepInfo->bstrDescription = ::SysAllocString((wchar_t *)bstrErrorDump);
          }
          return DISP_E_EXCEPTION;
        }
      }
      catch(std::exception& stlException)
      {
				if (pExcepInfo)
				{
					memset(pExcepInfo, 0, sizeof(EXCEPINFO));
					pExcepInfo->wCode = 2000;
					pExcepInfo->bstrSource = ::SysAllocString(L"ComMtsqlInterpreter");
					_bstr_t bstrErrorDump(stlException.what());
					pExcepInfo->bstrDescription = ::SysAllocString((wchar_t *)bstrErrorDump);
				}
				return DISP_E_EXCEPTION;
			}
    }
  }
  // PushRequest
  else if (dispIdMember == 3)
  {
    PushRequest();
  }
  // SetRequest
  else if (dispIdMember == 4)
  {
    if(pDispParams->rgvarg[0].intVal < 0 || (unsigned int)pDispParams->rgvarg[0].intVal >= mCompileEnvironment.size())
    {
				// Return the error somehow
				if (pExcepInfo)
				{
					memset(pExcepInfo, 0, sizeof(EXCEPINFO));
					pExcepInfo->wCode = 2000;
					pExcepInfo->bstrSource = ::SysAllocString(L"ComMtsqlInterpreter");
					pExcepInfo->bstrDescription = ::SysAllocString(L"Invalid Request Id");
				}
      return DISP_E_EXCEPTION;
    }
    mCurrentRequest = pDispParams->rgvarg[0].intVal;
  }
	// All dispId > 5 are program properties
	else if (dispIdMember == 5)
	{
		if (DISPATCH_PROPERTYGET & wFlags)
		{
			if(pVarResult)
			{	
				_variant_t varResult(mSupportVarchar ? VARIANT_TRUE : VARIANT_FALSE, VT_BOOL); 
				VariantClear (pVarResult);
				VariantCopy (pVarResult, &(varResult.Detach()));
			}
		}
		if (DISPATCH_PROPERTYPUT & wFlags)
		{
			_variant_t varArg(pDispParams->rgvarg[0]);
			mSupportVarchar = bool(varArg);
		}
	}
	else if (dispIdMember > 5)
	{
		// First, locate the Access that we can use to
		// get the value in the Environment.
		AccessPtr access = mCompileEnvironment[0]->getFactory()->create(dispIdMember - 6);
		if (DISPATCH_PROPERTYGET & wFlags)
		{
			if(pVarResult)
			{	
				_variant_t varResult = mRuntimeEnvironment[mCurrentRequest]->getVariantActivationRecord()->getValue(access.get());
				VariantClear (pVarResult);
				VariantCopy (pVarResult, &(varResult.Detach()));
			}
		}
		if (DISPATCH_PROPERTYPUT & wFlags)
		{
			_variant_t varArg(pDispParams->rgvarg[0]);
			mRuntimeEnvironment[mCurrentRequest]->getVariantActivationRecord()->setValue(access.get(), varArg);
		}
	}
	return S_OK;
}
