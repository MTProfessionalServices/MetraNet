/**************************************************************************
* MTSQLINTEROP
*
* Copyright 1997-2002 by MetraTech Corp.
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
* $Date$
* $Author$
* $Revision$
***************************************************************************/

#pragma unmanaged
#include <functional>
#include <map>
#include <MTSQLInterpreter.h>
#include <MTSQLException.h>
#include <RuntimeValue.h>

#include <stdutils.h>
#pragma managed

#include <Parameter.h>
#include <ExecutionEngine.h>
#include <vcclr.h>

using namespace MetraTech::MTSQL;

namespace MetraTech
{
    namespace MTSQL
    {
      void ExecutionEngine::SetParam(System::String^ name, System::String^ value)
      {
        
      }

      void ExecutionEngine::Compile(System::String^ aProgram)
      {
		if(true)
        {
          pin_ptr<const wchar_t> chars = PtrToStringChars(aProgram);
          std::wstring wideStr = chars;
          mExe = mInterpreter->analyze(wideStr.c_str());
          if (NULL == mExe) 
          {
            System::Text::StringBuilder^ builder = gcnew System::Text::StringBuilder();
            builder->Append("Compile Failure: ");
            builder->Append(gcnew System::String(mEnv->dumpErrors().c_str()));

            System::String^ errors = builder->ToString();
            LogAdjustmentError(errors);
            throw gcnew System::ApplicationException(errors);
          }
          mExe->codeGenerate(mEnv);
          //create program params
          mProgramParams = gcnew System::Collections::Hashtable();
          std::vector<MTSQLParam> params = mInterpreter->getProgramParams();
          std::vector<MTSQLParam>::iterator it;
          for(it = params.begin(); it != params.end(); it++)
          {
            Parameter^ managedptr = gcnew Parameter();
			std::string nm = (*it).GetName();
            managedptr->Name = gcnew System::String(nm.c_str());
            managedptr->Direction = ((ParameterDirection)(*it).GetDirection());
            managedptr->DataType = (ParameterDataType)((*it).GetType());
            mProgramParams->Add(managedptr->Name, managedptr);
          }

          mIsCompiled = true;
        }
      }

      void ExecutionEngine::Execute()
      {
        // Set parameters in the runtime environment
        AdjustmentGlobalRuntimeEnvironment renv;
        for(System::Collections::IDictionaryEnumerator^ e = mProgramParams->GetEnumerator();e->MoveNext();)
        {
			Parameter^ param = dynamic_cast<Parameter^>(e->Value);

          // Create an access to the parameter from the frame
          RuntimeValue val;
          CLRTypeConvert::ConvertString(param->Name, &val);
          // TODO: Convert the CLR type to the correct MTSQL type.  Note that right now
          // no one is checking the value we pass in so it doesn't matter.
          AccessPtr access = mEnv->createFrame()->allocateVariable(val.getStringPtr(), RuntimeValue::TYPE_INTEGER);

		  // clears output parameters in case of multiple executions
          if(param->Direction == (ParameterDirection) DIRECTION_OUT)
				param->Value = nullptr;

          // sets the value in the activation record
		  renv.getAdjustmentActivationRecord()->setValue(access.get(), param->Value);
        }

        try {
          mExe->execCompiled(&renv);
        } catch (MTSQLException& ex){
          System::Text::StringBuilder^ builder = gcnew System::Text::StringBuilder();
          builder->Append("Runtime Failure: ");
          builder->Append(gcnew System::String(ex.toString().c_str()));
          System::String^ errors = builder->ToString();
          LogAdjustmentError(errors);
          throw gcnew System::ApplicationException(errors);
        }
        renv.getAdjustmentActivationRecord()->copyTo(mProgramParams);
      }

      ExecutionEngine::~ExecutionEngine()
      {
        // Interpreter cleans up executables.
        delete mEnv;
        delete mInterpreter;
      }


      //ENVIRONMENT
	  void AdjustmentActivationRecord::copyTo(System::Collections::Hashtable^ params)
      {
        for(map<string, gcroot<System::Object^> >::iterator it = mParams.begin();
          it != mParams.end();
          it++)
        {
          //env will contain parameters in every scope of the program. We only care about
          //OUTPUT parameters, specified in procedure parameter list.
          System::String^ envvarname = gcnew System::String(it->first.c_str());
          if(!params->ContainsKey(envvarname))
			  continue;
		  else
		  {
			System::Object ^ Obj = params[envvarname];
			Parameter ^ paramObj = static_cast<Parameter ^>(Obj);
			if((ParameterDirection) paramObj->Direction != (ParameterDirection) DIRECTION_OUT)
				continue;

			// Add new Value to the Key pair<String, System::object>
			paramObj->Value = it->second;
		  }
        }

      }

      gcroot<System::Object^> AdjustmentActivationRecord::getValue(const Access * access)
      {
        std::string key = ( dynamic_cast<const AdjustmentAccess*>(access))->mName;
        gcroot<System::Object^> out = mParams[key];
        System::Object^ obj = out;
        //TODO: throw custom exception
        return out;

      }
      void AdjustmentActivationRecord::setValue(const Access * access, gcroot<System::Object^> val)
      {
		Access * tmp = const_cast<Access*>(access); // get rid of const
		AdjustmentAccess * tmp1 = static_cast<AdjustmentAccess*>(tmp);
        std::string key = tmp1->getAccess();
        mParams[key] = val;
        CLRActivationRecord::setValue(access, val);
      }

      std::string AdjustmentGlobalCompileEnvironment::dumpErrors()
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

      std::string AdjustmentGlobalRuntimeEnvironment::dumpErrors()
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
    }
}
