/**************************************************************************
* @doc MTSQLINTEROP
*
* @module |
*
*
* Copyright 2002 by MetraTech Corporation
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
* NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech Corporation MAKES NO
* REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
* PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
* DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
* COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech Corporation,
* and USER agrees to preserve the same.
*
* Created by: Boris Partensky
*
* $Date: 10/23/2002 12:09:59 PM$
* $Author: Boris$
* $Revision: 3$
*
* @index | MTSQLINTEROP
***************************************************************************/

#ifndef _MTSQLADJUSTMENTENGINE_H
#define _MTSQLADJUSTMENTENGINE_H

#include <MTSQLInterop.h>

#ifdef WIN32
// only include this header one time
#pragma once
#endif

#pragma unmanaged
  #include <metralite.h>
  #include "Parameter.h"
  #include <stdutils.h>
  #import <Rowset.tlb> rename ( "EOF", "RowsetEOF" )

#pragma managed
  #include <AdjustmentLogger.h>



//class MTSQLInterpreter;
//class MTSQLExecutable;
//class AdjustmentActivationRecord;
//class MetraTech::MTSQL::CLRActivationRecord;
//using namespace MetraTech::MTSQL;

namespace MetraTech
{
    namespace MTSQL
    {

      class AdjustmentAccess : public Access
      {
        friend class AdjustmentActivationRecord;
      public:
        AdjustmentAccess(string aName) : mName(aName) {}
        string getAccess() const { return mName; }

      protected:
        string mName;

      };
      class AdjustmentFrame : public CLRValueFrame
      {
      private:
        std::map<std::string, AccessPtr> mAccesses;
      public:
        AdjustmentFrame() {}
        AccessPtr allocateVariable(const std::string& var, int )
        {
          string str =  (var[0] == L'@') ? var.substr(1, var.size()-1) : var;
          if (mAccesses.find(str) == mAccesses.end())
          {
            mAccesses[str] = AccessPtr(new AdjustmentAccess(str));
          }
          return mAccesses.find(str)->second;
        }
      };
      class AdjustmentActivationRecord : public CLRActivationRecord
      {
      public:
        AdjustmentActivationRecord() : CLRActivationRecord(nullptr)
        {
        }
		void copyTo(System::Collections::Hashtable^ params);
        virtual ActivationRecord* getStaticLink() { 
          return nullptr;
        }
        virtual gcroot<System::Object^> getValue(const Access * access);
        virtual void setValue(const Access * access, gcroot<System::Object^> val);
      private:
        map<string, gcroot<System::Object^> > mParams;
      };

      class  AdjustmentGlobalCompileEnvironment : public GlobalCompileEnvironment
      {
      public:
        AdjustmentGlobalCompileEnvironment()
        {
          pFrame = new AdjustmentFrame;
        }
        virtual ~AdjustmentGlobalCompileEnvironment()
        {
          delete pFrame;
        }
        Frame* createFrame()
        {
          return pFrame;
        }
				bool isOkToLogDebug()
				{
					return true;
				}

				bool isOkToLogInfo()
				{
					return true;
				}

				bool isOkToLogWarning()
				{
					return true;
				}

				bool isOkToLogError()
				{
					return true;
				}

        virtual  void logDebug(const std::string& str)
        {
          LogAdjustmentDebug(str);
        }

        virtual void logInfo(const std::string& str)
        {
          LogAdjustmentInfo(str);
        }

        virtual void logWarning(const std::string& str)
        {
          LogAdjustmentWarning(str);
        }

        virtual void logError(const std::string& str)
        {
          LogAdjustmentError(str);
          mErrors.push_back(str);
        }
        std::string dumpErrors();
      private:
        AdjustmentFrame* pFrame;
        std::vector<string> mErrors;
      };
      class AdjustmentGlobalRuntimeEnvironment : public GlobalRuntimeEnvironment
      {
      public:
        AdjustmentGlobalRuntimeEnvironment()
        {}

        // construct runtime from the instance
        virtual ActivationRecord* getActivationRecord()
        {
          return &mRecord;
        }
        AdjustmentActivationRecord* getAdjustmentActivationRecord()
        {
          return &mRecord;
        }

				MTPipelineLib::IMTSQLRowsetPtr getRowset()
				{
					ROWSETLib::IMTSQLRowsetPtr rowset(__uuidof(ROWSETLib::MTSQLRowset));
					rowset->Init(L"config\\ProductCatalog");
					return MTPipelineLib::IMTSQLRowsetPtr(reinterpret_cast<MTPipelineLib::IMTSQLRowset *>(rowset.GetInterfacePtr()));
				}

				bool isOkToLogDebug()
				{
					return true;
				}

				bool isOkToLogInfo()
				{
					return true;
				}

				bool isOkToLogWarning()
				{
					return true;
				}

				bool isOkToLogError()
				{
					return true;
				}

        virtual  void logDebug(const std::string& str)
        {
          LogAdjustmentDebug(str);
        }

        virtual void logInfo(const std::string& str)
        {
          LogAdjustmentInfo(str);
        }

        virtual void logWarning(const std::string& str)
        {
          LogAdjustmentWarning(str);
        }

        virtual void logError(const std::string& str)
        {
          LogAdjustmentError(str);
          mErrors.push_back(str);
        }
        std::string dumpErrors();

      protected:
        AdjustmentActivationRecord mRecord;
      private:
        std::vector<string> mErrors;
      };

    	[System::Runtime::InteropServices::ComVisible(false)]
      public interface class IExecutionEngine
      {
        void Compile(System::String^ aProgram);
        void Execute();
        property System::Collections::Hashtable^ ProgramParameters;
      };

  	[System::Runtime::InteropServices::ComVisible(false)]
    public ref class ExecutionEngine : public IExecutionEngine
    {
    private:
      System::Collections::Hashtable ^ mParams;
      System::Collections::Hashtable ^ mProgramParams;
      bool mIsCompiled;

      // Unmanaged pointers
      MTSQLInterpreter * mInterpreter;
      MTSQLExecutable * mExe;
      AdjustmentGlobalCompileEnvironment * mEnv;
    public:

	  property System::Collections::Hashtable^ ProgramParameters
      {
		  virtual System::Collections::Hashtable^ get() 
			{ return mProgramParams; }
		  virtual void set(System::Collections::Hashtable^ value)
			{ mProgramParams = value; }
      }


      virtual void SetParam(System::String^ name, System::String^ value);

      virtual void Execute();
      virtual void Compile(System::String^ aProgram);

      ExecutionEngine()
      {
        mIsCompiled = false;
        mParams = gcnew System::Collections::Hashtable();
        mEnv = new AdjustmentGlobalCompileEnvironment();
        mInterpreter = new MTSQLInterpreter(mEnv);
      }

      virtual ~ExecutionEngine();
    };


    }  
}

#endif /* _MTSQLINTEROP_H */
