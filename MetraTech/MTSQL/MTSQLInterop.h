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
* Created by: David Blair
*
* $Date$
* $Author$
* $Revision$
*
* @index | MTSQLINTEROP
***************************************************************************/

#ifndef _MTSQLINTEROP_H
#define _MTSQLINTEROP_H

#ifdef WIN32
// only include this header one time
#pragma once
#endif

#pragma unmanaged
#include <metralite.h>
#include <functional>
#include <map>
#include <MTSQLInterpreter.h>
#include <MTSQLException.h>
#include <stdutils.h>
#import <Rowset.tlb> rename ( "EOF", "RowsetEOF" )

#pragma managed
#include <vcclr.h>


class MTSQLInterpreter;
class MTSQLExecutable;
class CLRACtivationRecord;

using namespace std;

namespace MetraTech
{
    namespace MTSQL
    {
      class CLRGlobalCompileEnvironment;
      class CLRActivationRecord;

      class CLRValueFrame : public Frame
      {
      private:
        map<string, AccessPtr> mHash;
      public:
        // TODO: Configure with allowable parameters
        CLRValueFrame() 
        {
        }

        virtual AccessPtr allocateVariable(const std::string& str, int ty);

        ~CLRValueFrame() 
        {
        }
      };

      class CLRActivationRecord : public ActivationRecord
      {
      protected:
        map<const Access *, gcroot<System::Object^> > mRuntimeEnv;
        ActivationRecord* mStaticLink;

      public:
        void copyTo(gcroot<System::Collections::Hashtable^> table);

        virtual gcroot<System::Object^> getValue(const Access * access);
        virtual void setValue(const Access * access, gcroot<System::Object^> val);
        void getLongValue(const Access * access, RuntimeValue * value);
        void getLongLongValue(const Access * access, RuntimeValue * value);
        void getDoubleValue(const Access * access, RuntimeValue * value);
        void getDecimalValue(const Access * access, RuntimeValue * value);
        void getStringValue(const Access * access, RuntimeValue * value);
        void getWStringValue(const Access * access, RuntimeValue * value);
        void getBooleanValue(const Access * access, RuntimeValue * value);
        void getDatetimeValue(const Access * access, RuntimeValue * value);
        void getTimeValue(const Access * access, RuntimeValue * value);
        void getEnumValue(const Access * access, RuntimeValue * value);
        void getBinaryValue(const Access * access, RuntimeValue * value);
        void setLongValue(const Access * access, const RuntimeValue * value);
        void setLongLongValue(const Access * access, const RuntimeValue * value);
        void setDoubleValue(const Access * access, const RuntimeValue * value);
        void setDecimalValue(const Access * access, const RuntimeValue * value);
        void setStringValue(const Access * access, const RuntimeValue * value);
        void setWStringValue(const Access * access, const RuntimeValue * value);
        void setBooleanValue(const Access * access, const RuntimeValue * value);
        void setDatetimeValue(const Access * access, const RuntimeValue * value);
        void setTimeValue(const Access * access, const RuntimeValue * value);
        void setEnumValue(const Access * access, const RuntimeValue * value);
        void setBinaryValue(const Access * access, const RuntimeValue * value);
        ActivationRecord* getStaticLink();

        CLRActivationRecord(ActivationRecord* staticLink) : mStaticLink(staticLink)
        {
        }
      };
      class CLRTypeConvert
      {
      public:
        static void ConvertLong(System::Object ^ obj, RuntimeValue * value);
        static void ConvertLongLong(System::Object ^ obj, RuntimeValue * value);
        static void ConvertDouble(System::Object ^ obj, RuntimeValue * value);
        static void ConvertBool(System::Object ^ obj, RuntimeValue * value);
        static void ConvertDec(System::Object ^ obj, RuntimeValue * value);
        static void ConvertString(System::Object ^ obj, RuntimeValue * value);
        static void ConvertWString(System::Object ^ obj, RuntimeValue * value);
        static void ConvertDatetime(System::Object ^ obj, RuntimeValue * value);
        static void ConvertEnum(System::Object ^ obj, RuntimeValue * value);
        static System::Object ^ ConvertLong(const RuntimeValue * val);
        static System::Object ^ ConvertLongLong(const RuntimeValue * val);
        static System::Object ^ ConvertDouble(const RuntimeValue * val);
        static System::Object ^ ConvertBool(const RuntimeValue * val);
        static System::Object ^ ConvertDatetime(const RuntimeValue * val);
        static System::Object ^ ConvertDec(const RuntimeValue * val);
        static System::Object ^ ConvertString(const RuntimeValue * val);
        static System::Object ^ ConvertWString(const RuntimeValue * val);
        static System::Object ^ ConvertEnum(const RuntimeValue * val);
      };



        [System::Runtime::InteropServices::ComVisible(false)]
      public ref class MTSQLMethod
      {
      private:
        System::String^ mProgram;
        System::Type^ mType;
        System::Collections::ArrayList^ mParams;
        System::Collections::ArrayList^ mProgramParams;

        bool mIsCompiled;


        // Unmanaged pointers
        MTSQLInterpreter * mInterpreter;
        MTSQLExecutable * mExe;
        CLRGlobalCompileEnvironment * mEnv;
      public:

        property System::Type^ Type
        {
            virtual System::Type^ get()
            {
                return mType;
            }

            virtual void set(System::Type^ value) {
                mType = value;
                mIsCompiled = false;
            }
        }

        property System::String^ Program
        {
            virtual System::String^ get()
            {
                return mProgram;
            }

            virtual void set(System::String^ value ) {
                mProgram = value;
                mIsCompiled = false;
            }
        }

        property System::Collections::ArrayList^ ProgramParameters
        {
            virtual System::Collections::ArrayList^ get() 
                { return mProgramParams; }

            virtual void set(System::Collections::ArrayList^ value) 
            { 
                mProgramParams = value;
            }
        }

        void AddParam(System::String^ param);

        void Execute(System::Object^ obj);
        void Compile();

        // Execute with by-name binding of parameters
        void Execute(System::Object^ obj, System::Collections::Hashtable^ params);
        // Produces a new script by renaming the given variable.
        // Throws an exception if the MTSQL cannot be parsed
        System::String^ refactorRenameVariable(
                                System::String^ script,
                                System::String^ oldVariableName,
                                System::String^ newVariableName);

        // Produce a new script by converting string literals 
        // to wide string literals ("xyz" -> N"xyz") and 
        // VARCHAR declarations to NVARCHAR.  
        // Throws an exception if the MTSQL cannot be parsed
        System::String^ refactorVarchar(System::String^ script);

        MTSQLMethod()
        {
          mProgram = nullptr;
          mType = nullptr;
          mIsCompiled = false;
          mParams = gcnew System::Collections::ArrayList();
        }

        virtual ~MTSQLMethod();
      };

    }   
}

#endif /* _MTSQLINTEROP_H */
