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
* Created by: David Blair
*
* $Date: 10/23/2002 9:55:13 AM$
* $Author: Boris$
* $Revision: 3$
***************************************************************************/

#include <RuntimeValue.h>

#pragma managed

#include "MTSQLInterop.h"
#include "Parameter.h"

namespace MetraTech
{
    namespace MTSQL
    {

      void CLRTypeConvert::ConvertLong(System::Object ^ obj, RuntimeValue * value)
      {
        try
        {
          System::Int32^ ptr = safe_cast<System::Int32 ^>(obj);
          value->assignLong(*ptr);
        }
        catch(System::InvalidCastException^)
        {
          try
          {
			System::Int16^ ptr = safe_cast<System::Int16 ^>(obj);
			value->assignLong(*ptr);
        }
          catch(System::InvalidCastException^)
          {
            ConvertDec(obj, value);
          }
        }

      }
      void CLRTypeConvert::ConvertLongLong(System::Object ^ obj, RuntimeValue * value)
      {
        try
        {
		  System::Int64^ ptr = safe_cast<System::Int64 ^>(obj);
          value->assignLongLong(*ptr);
        }
        catch(System::InvalidCastException^)
        {
          try
          {
            System::Int32^ ptr = safe_cast<System::Int32 ^>(obj);
            value->assignLongLong(*ptr);
          }
          catch(System::InvalidCastException^)
          {
            System::Int16^ ptr = safe_cast<System::Int16 ^>(obj);
            value->assignLongLong(*ptr);
          }
        }

      }
      void CLRTypeConvert::ConvertDouble(System::Object ^ obj, RuntimeValue * value)
      {
        value->assignDouble(*safe_cast<System::Double ^>(obj));
      }
      void CLRTypeConvert::ConvertBool(System::Object ^ obj, RuntimeValue * value)
      {
        value->assignBool(*safe_cast<System::Boolean ^>(obj));
      }
      void CLRTypeConvert::ConvertDec(System::Object ^ obj, RuntimeValue * value)
      {
        // Use the marshalling interfaces to convert to VARIANT, then to RuntimeValue...
        System::IntPtr pVariant = System::Runtime::InteropServices::Marshal::AllocCoTaskMem(sizeof(VARIANT));
        System::Runtime::InteropServices::Marshal::GetNativeVariantForObject(obj, pVariant);
        DECIMAL decVal = (DECIMAL)_variant_t(*((VARIANT *)pVariant.ToPointer()));
        System::Runtime::InteropServices::Marshal::FreeCoTaskMem(pVariant);
        value->assignDec(&decVal);
      }
      void CLRTypeConvert::ConvertString(System::Object ^ obj, RuntimeValue * value)
      {
        pin_ptr<const wchar_t> chars = PtrToStringChars(safe_cast<System::String ^>(obj));
        std::wstring wideStr = chars;
        value->assignString(ascii(wideStr));
      }
      void CLRTypeConvert::ConvertWString(System::Object ^ obj, RuntimeValue * value)
      {
        pin_ptr<const wchar_t> chars = PtrToStringChars(safe_cast<System::String ^>(obj));
        std::wstring wideStr = chars;
        value->assignWString(wideStr);
      }
      void CLRTypeConvert::ConvertDatetime(System::Object ^ obj, RuntimeValue * value)
      {
        // Use the marshalling interfaces to convert to VARIANT, then to RuntimeValue...
        System::IntPtr pVariant = System::Runtime::InteropServices::Marshal::AllocCoTaskMem(sizeof(VARIANT));
        System::Runtime::InteropServices::Marshal::GetNativeVariantForObject(obj, pVariant);
        DATE dtVal = (DATE)_variant_t(*((VARIANT *)pVariant.ToPointer()));
        System::Runtime::InteropServices::Marshal::FreeCoTaskMem(pVariant);
        value->assignDatetime(dtVal);
      }
      void CLRTypeConvert::ConvertEnum(System::Object ^ obj, RuntimeValue * value)
      {
        try
        {
          value->assignEnum(*safe_cast<System::Int32 ^>(obj));
        }
        catch(System::InvalidCastException ^)
        {
          System::Int64 ^ val64 = safe_cast<System::Int64 ^>(obj);
          __int64 local64 = (__int64)*val64;

          value->assignEnum((__int32)local64);
        }
      }
      System::Object ^ CLRTypeConvert::ConvertLong(const RuntimeValue * val)
      {
        return val->getLong();
      }
      System::Object ^ CLRTypeConvert::ConvertLongLong(const RuntimeValue * val)
      {
        return val->getLongLong();
      }
      System::Object ^ CLRTypeConvert::ConvertDouble(const RuntimeValue * val)
      {
        return val->getDouble();
      }
      System::Object ^ CLRTypeConvert::ConvertBool(const RuntimeValue * val)
      {
        return val->getBool();
      }
      System::Object ^ CLRTypeConvert::ConvertDatetime(const RuntimeValue * val)
      {
        VARIANT dtVal;
        V_DATE(&dtVal) = val->getDatetime();
        V_VT(&dtVal) = VT_DATE;
        return System::Runtime::InteropServices::Marshal::GetObjectForNativeVariant(System::IntPtr(&dtVal));
      }
      System::Object ^ CLRTypeConvert::ConvertDec(const RuntimeValue * val)
      {
        // Use the marshalling interfaces to convert to VARIANT, then to Object...
        VARIANT decVal;
        V_DECIMAL(&decVal) = val->getDec();
        V_VT(&decVal) = VT_DECIMAL;
        return System::Runtime::InteropServices::Marshal::GetObjectForNativeVariant(System::IntPtr(&decVal));
      }
      System::Object ^ CLRTypeConvert::ConvertString(const RuntimeValue * val)
      {
        return gcnew System::String(val->getStringPtr());
      }
      System::Object ^ CLRTypeConvert::ConvertWString(const RuntimeValue * val)
      {
        return gcnew System::String(val->getWStringPtr());
      }
      System::Object ^ CLRTypeConvert::ConvertEnum(const RuntimeValue * val)
      {
        return val->getEnum();
      }

      class SymbolAccess : public Access
      {
      private:
        string mName;
      public:
        SymbolAccess(const string & str) : mName(str)
        {
        }

        string getAccess() const { return mName; }
      };

      AccessPtr CLRValueFrame::allocateVariable(const std::string& str, int ty)
      {
        if (ty == RuntimeValue::TYPE_BINARY) return nullAccess;
        AccessPtr access = mHash[str];
        if (access == nullAccess)
        {
          access = AccessPtr(new SymbolAccess(str));
          mHash[str] = access;
        }
        return access;

      }


      void CLRActivationRecord::copyTo(gcroot<System::Collections::Hashtable^> table)
      {
        for(map<const Access *, gcroot<System::Object^> >::iterator it = mRuntimeEnv.begin();
          it != mRuntimeEnv.end();
          it++)
        {
			System::String^ sKey = gcnew System::String((static_cast<SymbolAccess*>((Access *)it->first))->getAccess().c_str());
			table->Add(sKey, it->second);
		}
      }

      gcroot<System::Object^> CLRActivationRecord::getValue(const Access * access)
      {
        gcroot<System::Object^> out = mRuntimeEnv[access];
        return out;
      }
      void CLRActivationRecord::setValue(const Access * access, gcroot<System::Object^> val)
      {
        mRuntimeEnv[access] = val;
      }

      void CLRActivationRecord::getLongValue(const Access * access, RuntimeValue * value)
      {
        CLRTypeConvert::ConvertLong(getValue(access), value);
      }
      void CLRActivationRecord::getLongLongValue(const Access * access, RuntimeValue * value)
      {
        CLRTypeConvert::ConvertLongLong(getValue(access), value);
      }
      void CLRActivationRecord::getDoubleValue(const Access * access, RuntimeValue * value)
      {
        CLRTypeConvert::ConvertDouble(getValue(access), value);
      }
      void CLRActivationRecord::getDecimalValue(const Access * access, RuntimeValue * value)
      {
        CLRTypeConvert::ConvertDec(getValue(access), value);
      }
      void CLRActivationRecord::getStringValue(const Access * access, RuntimeValue * value)
      {
        CLRTypeConvert::ConvertString(getValue(access), value);
      }
      void CLRActivationRecord::getWStringValue(const Access * access, RuntimeValue * value)
      {
        CLRTypeConvert::ConvertWString(getValue(access), value);
      }
      void CLRActivationRecord::getBooleanValue(const Access * access, RuntimeValue * value)
      {
        CLRTypeConvert::ConvertBool(getValue(access), value);
      }
      void CLRActivationRecord::getDatetimeValue(const Access * access, RuntimeValue * value)
      {
        CLRTypeConvert::ConvertDatetime(getValue(access), value);
      }
      void CLRActivationRecord::getTimeValue(const Access * access, RuntimeValue * value)
      {
        value->assignTime(100);
      }
      void CLRActivationRecord::getEnumValue(const Access * access, RuntimeValue * value)
      {
        CLRTypeConvert::ConvertEnum(getValue(access), value);
      }
      void CLRActivationRecord::getBinaryValue(const Access * access, RuntimeValue * value)
      {
      }
      void CLRActivationRecord::setLongValue(const Access * access, const RuntimeValue * val)
      {
        setValue(access, CLRTypeConvert::ConvertLong(val));
      }
      void CLRActivationRecord::setLongLongValue(const Access * access, const RuntimeValue * val)
      {
        setValue(access, CLRTypeConvert::ConvertLongLong(val));
      }
      void CLRActivationRecord::setDoubleValue(const Access * access, const RuntimeValue * val)
      {
        setValue(access, CLRTypeConvert::ConvertDouble(val));
      }
      void CLRActivationRecord::setDecimalValue(const Access * access, const RuntimeValue * val)
      {
        setValue(access, CLRTypeConvert::ConvertDec(val));
      }
      void CLRActivationRecord::setStringValue(const Access * access, const RuntimeValue * val)
      {
        setValue(access, CLRTypeConvert::ConvertString(val));
      }
      void CLRActivationRecord::setWStringValue(const Access * access, const RuntimeValue * val)
      {
        setValue(access, CLRTypeConvert::ConvertWString(val));
      }
      void CLRActivationRecord::setBooleanValue(const Access * access, const RuntimeValue * val)
      {
        setValue(access, CLRTypeConvert::ConvertBool(val));
      }
      void CLRActivationRecord::setDatetimeValue(const Access * access, const RuntimeValue * val)
      {
        setValue(access, CLRTypeConvert::ConvertDatetime(val));
      }
      void CLRActivationRecord::setTimeValue(const Access * access, const RuntimeValue * val)
      {
        //		setValue(access, CLRTypeConvert::ConvertTime(val));
      }
      void CLRActivationRecord::setEnumValue(const Access * access, const RuntimeValue * val)
      {
        setValue(access, CLRTypeConvert::ConvertEnum(val));
      }
      void CLRActivationRecord::setBinaryValue(const Access * access, const RuntimeValue * val)
      {
      }

      ActivationRecord* CLRActivationRecord::getStaticLink() 
      {
        return mStaticLink;
      }

      struct PropertyInfoCompare : public std::binary_function<bool, 
        gcroot<System::Reflection::PropertyInfo^>, 
        gcroot<System::Reflection::PropertyInfo^> > 
      {
        bool operator()(const gcroot<System::Reflection::PropertyInfo^>& x, const gcroot<System::Reflection::PropertyInfo^>& y) const
        {
          return x->GetHashCode() < y->GetHashCode();
        }
      };

      class CLRPropertyAccess : public Access
      {
      private:
        gcroot<System::Reflection::PropertyInfo^> mAccess;
        CLRPropertyAccess(gcroot<System::Reflection::PropertyInfo^> access) : mAccess(access) {}
      public:

        gcroot<System::Reflection::PropertyInfo^> GetPropertyInfo() const 
        {
          return mAccess;
        }

        friend class CLRPropertyAccessFactory;
      };

      class CLRPropertyAccessFactory
      {
      private:
        std::map<gcroot<System::Reflection::PropertyInfo^>, AccessPtr, PropertyInfoCompare> mMap;
      public:
        AccessPtr create(gcroot<System::Reflection::PropertyInfo^> access)
        {
          AccessPtr mtAccess=mMap[access];
          if (mtAccess == nullAccess)
          {
            mtAccess = AccessPtr(new CLRPropertyAccess(access));
            mMap[access] = mtAccess;
          }
          return mtAccess;
        }

        ~CLRPropertyAccessFactory()
        {
        }
      };

      class CLRTypeFrame : public Frame
      {
      private:
        gcroot<System::Type^> mClrType;
        CLRPropertyAccessFactory* mFactory;
      public:
        // We do not own the factory object
        CLRTypeFrame(CLRPropertyAccessFactory * factory, gcroot<System::Type^> clrType) 
        {
          mFactory = factory;
          mClrType = clrType;
        }

        AccessPtr allocateVariable(const std::string& var, int ty)
        {
          if (ty == RuntimeValue::TYPE_BINARY) return nullAccess;
          // All MTSQL variables begin with @.  Truncate this
          // leading character to make it valid for use as a
          // property name.
          // Look up the property in the type.
          // TODO: Handle AmbiguousMatchException
          gcroot<System::Reflection::PropertyInfo ^> pinfo = mClrType->GetProperty(gcnew System::String(var.substr(1, var.size()-1).c_str()));
          // TODO: Check the CLR type against the MTSQL type.
          return mFactory->create(pinfo);
        }

        ~CLRTypeFrame() 
        {
        }
      };

      class CLRObjectActivationRecord : public ActivationRecord
      {
      private:
        ActivationRecord* mStaticLink;
        gcroot<System::Object ^> mObject;

      public:
        CLRObjectActivationRecord(ActivationRecord* staticLink, gcroot<System::Object^> obj) : mStaticLink(staticLink), mObject(obj)
        {
        }


        void getLongValue(const Access * access, RuntimeValue * value)
        {
          try
          {
            System::Object^ obj = (static_cast<const CLRPropertyAccess *>(access))->GetPropertyInfo()->GetValue(mObject, nullptr);
            CLRTypeConvert::ConvertLong(obj, value);
          }
          catch(System::InvalidCastException^ )//ex)
          {
            throw MTSQLException("TODO: Throw specific exception");
          }
        }
        void getLongLongValue(const Access * access, RuntimeValue * value)
        {
          try
          {
            System::Object^ obj = (static_cast<const CLRPropertyAccess *>(access))->GetPropertyInfo()->GetValue(mObject, nullptr);
            CLRTypeConvert::ConvertLongLong(obj, value);
          }
          catch(System::InvalidCastException^ )//ex)
          {
            throw MTSQLException("TODO: Throw specific exception");
          }
        }
        void getDoubleValue(const Access * access, RuntimeValue * value)
        {
          try
          {
            System::Object^ obj = (static_cast<const CLRPropertyAccess *>(access))->GetPropertyInfo()->GetValue(mObject, nullptr);
            CLRTypeConvert::ConvertDouble(obj, value);
          }
          catch(System::InvalidCastException^ )//ex)
          {
            throw MTSQLException("TODO: Throw specific exception");
          }
        }
        void getDecimalValue(const Access * access, RuntimeValue * value)
        {
          try
          {
            System::Object^ obj = (static_cast<const CLRPropertyAccess *>(access))->GetPropertyInfo()->GetValue(mObject, nullptr);
            CLRTypeConvert::ConvertDec(obj, value);
          }
          catch(System::InvalidCastException^ )//ex)
          {
            throw MTSQLException("TODO: Throw specific exception");
          }
        }
        void getStringValue(const Access * access, RuntimeValue * value)
        {
          try
          {
            System::Object^ obj = (static_cast<const CLRPropertyAccess *>(access))->GetPropertyInfo()->GetValue(mObject, nullptr);
            CLRTypeConvert::ConvertString(obj, value);
          }
          catch(System::InvalidCastException^ )//ex)
          {
            throw MTSQLException("TODO: Throw specific exception");
          }
        }
        void getWStringValue(const Access * access, RuntimeValue * value)
        {
          try
          {
            System::Object^ obj = (static_cast<const CLRPropertyAccess *>(access))->GetPropertyInfo()->GetValue(mObject, nullptr);
            CLRTypeConvert::ConvertWString(obj, value);
          }
          catch(System::InvalidCastException^ )//ex)
          {
            throw MTSQLException("TODO: Throw specific exception");
          }
        }
        void getBooleanValue(const Access * access, RuntimeValue * value)
        {
          try
          {
            System::Object^ obj = (static_cast<const CLRPropertyAccess *>(access))->GetPropertyInfo()->GetValue(mObject, nullptr);
            CLRTypeConvert::ConvertBool(obj, value);
          }
          catch(System::InvalidCastException^ )//ex)
          {
            throw MTSQLException("TODO: Throw specific exception");
          }
        }
        void getDatetimeValue(const Access * access, RuntimeValue * value)
        {
          try
          {
            System::Object^ obj = (static_cast<const CLRPropertyAccess *>(access))->GetPropertyInfo()->GetValue(mObject, nullptr);
            CLRTypeConvert::ConvertBool(obj, value);
          }
          catch(System::InvalidCastException^ )//ex)
          {
            throw MTSQLException("TODO: Throw specific exception");
          }
        }
        void getTimeValue(const Access * access, RuntimeValue * value)
        {
          try
          {
            // 			System::Object* obj = (static_cast<const CLRPropertyAccess *>(access))->GetPropertyInfo()->GetValue(mObject, nullptr);
            // 			value->assignTime(*__try_cast<System::TimeSpan *>(obj, value));
            value->assignTime(100);
          }
          catch(System::InvalidCastException^ )//ex)
          {
            throw MTSQLException("TODO: Throw specific exception");
          }
        }
        void getEnumValue(const Access * access, RuntimeValue * value)
        {
          try
          {
            System::Object^ obj = (static_cast<const CLRPropertyAccess *>(access))->GetPropertyInfo()->GetValue(mObject, nullptr);
          }
          catch(System::InvalidCastException^ )//ex)
          {
            throw MTSQLException("TODO: Throw specific exception");
          }
        }
        void getBinaryValue(const Access * access, RuntimeValue * value)
        {
        }
        void setLongValue(const Access * access, const RuntimeValue * val)
        {
          try
          {
            (static_cast<const CLRPropertyAccess *>(access))->GetPropertyInfo()->SetValue(mObject, CLRTypeConvert::ConvertLong(val), nullptr);
          }
          catch(System::InvalidCastException^ )//ex)
          {
            throw MTSQLException("TODO: Throw specific exception");
          }
        }
        void setLongLongValue(const Access * access, const RuntimeValue * val)
        {
          try
          {
            (static_cast<const CLRPropertyAccess *>(access))->GetPropertyInfo()->SetValue(mObject, CLRTypeConvert::ConvertLongLong(val), nullptr);
          }
          catch(System::InvalidCastException^ )//ex)
          {
            throw MTSQLException("TODO: Throw specific exception");
          }
        }
        void setDoubleValue(const Access * access, const RuntimeValue * val)
        {
          try
          {
            (static_cast<const CLRPropertyAccess *>(access))->GetPropertyInfo()->SetValue(mObject, CLRTypeConvert::ConvertDouble(val), nullptr);
          }
          catch(System::InvalidCastException^ )//ex)
          {
            throw MTSQLException("TODO: Throw specific exception");
          }
        }
        void setDecimalValue(const Access * access, const RuntimeValue * val)
        {
          try
          {
            (static_cast<const CLRPropertyAccess *>(access))->GetPropertyInfo()->SetValue(mObject, CLRTypeConvert::ConvertDec(val), nullptr);
          }
          catch(System::InvalidCastException^ )//ex)
          {
            throw MTSQLException("TODO: Throw specific exception");
          }
        }
        void setStringValue(const Access * access, const RuntimeValue * val)
        {
          try
          {
            (static_cast<const CLRPropertyAccess *>(access))->GetPropertyInfo()->SetValue(mObject, CLRTypeConvert::ConvertString(val), nullptr);
          }
          catch(System::InvalidCastException^ )//ex)
          {
            throw MTSQLException("TODO: Throw specific exception");
          }
        }
        void setWStringValue(const Access * access, const RuntimeValue * val)
        {
          try
          {
            (static_cast<const CLRPropertyAccess *>(access))->GetPropertyInfo()->SetValue(mObject, CLRTypeConvert::ConvertWString(val), nullptr);
          }
          catch(System::InvalidCastException^ )//ex)
          {
            throw MTSQLException("TODO: Throw specific exception");
          }
        }
        void setBooleanValue(const Access * access, const RuntimeValue * val)
        {
          try
          {
            (static_cast<const CLRPropertyAccess *>(access))->GetPropertyInfo()->SetValue(mObject, CLRTypeConvert::ConvertBool(val), nullptr);
          }
          catch(System::InvalidCastException^ )//ex)
          {
            throw MTSQLException("TODO: Throw specific exception");
          }
        }
        void setDatetimeValue(const Access * access, const RuntimeValue * val)
        {
          try
          {
            // Use the marshalling interfaces to convert to VARIANT, then to Object...
            (static_cast<const CLRPropertyAccess *>(access))->GetPropertyInfo()->SetValue(mObject, CLRTypeConvert::ConvertDatetime(val), nullptr);
          }
          catch(System::InvalidCastException^ )//ex)
          {
            throw MTSQLException("TODO: Throw specific exception");
          }
        }
        void setTimeValue(const Access * access, const RuntimeValue * val)
        {
        }
        void setEnumValue(const Access * access, const RuntimeValue * val)
        {
          try
          {
            // Use the marshalling interfaces to convert to VARIANT, then to Object...
            (static_cast<const CLRPropertyAccess *>(access))->GetPropertyInfo()->SetValue(mObject, CLRTypeConvert::ConvertEnum(val), nullptr);
          }
          catch(System::InvalidCastException^ )//ex)
          {
            throw MTSQLException("TODO: Throw specific exception");
          }
        }
        void setBinaryValue(const Access * access, const RuntimeValue * val)
        {
        }

        ActivationRecord* getStaticLink() 
        {
          return mStaticLink;
        }
      };

      // The Method frame combines a value frame that holds
      // input and output parameters of the methods and an
      // object frame that holds member properties accessed
      // by the method.
      class CLRMethodFrame : public Frame
      {
      private:
        CLRTypeFrame * mTypeFrame;
        CLRPropertyAccessFactory *mFactory;
        CLRValueFrame * mValueFrame;
        gcroot<System::Collections::ArrayList^> mParams;
      public:
        CLRMethodFrame(gcroot<System::Type ^> type, gcroot<System::Collections::ArrayList^> params)
        {
          mParams = params;
          mFactory = new CLRPropertyAccessFactory();
          mTypeFrame = new CLRTypeFrame(mFactory, type);
          mValueFrame = new CLRValueFrame();
        }

        ~CLRMethodFrame()
        {
          delete mTypeFrame; 
          delete mFactory;
          delete mValueFrame;
        }

        AccessPtr allocateVariable(const std::string& str, int ty)
        {
          if(mParams->Contains(gcnew System::String(str.c_str()))) return mValueFrame->allocateVariable(str, ty);
          else return mTypeFrame->allocateVariable(str, ty);
        }
      };

      class CLRMethodActivationRecord : public ActivationRecord
      {
      private:
        CLRActivationRecord *mValueRecord;
        CLRObjectActivationRecord *mObjectRecord;
      public:

        CLRActivationRecord* getValueRecord()
        {
          return mValueRecord;
        }

        void getLongValue(const Access * access, RuntimeValue * value)
        {
          // Ick.  Use RTTI to dispatch.
          if(NULL != dynamic_cast<const CLRPropertyAccess *>(access))
          {
            mObjectRecord->getLongValue(access, value);
          }
          else
          {
            mValueRecord->getLongValue(access, value);
          }
        }
        void getLongLongValue(const Access * access, RuntimeValue * value)
        {
          // Ick.  Use RTTI to dispatch.
          if(NULL != dynamic_cast<const CLRPropertyAccess *>(access))
          {
            mObjectRecord->getLongLongValue(access, value);
          }
          else
          {
            mValueRecord->getLongLongValue(access, value);
          }
        }
        void getDoubleValue(const Access * access, RuntimeValue * value)
        {
          // Ick.  Use RTTI to dispatch.
          if(NULL != dynamic_cast<const CLRPropertyAccess *>(access))
          {
            mObjectRecord->getDoubleValue(access, value);
          }
          else
          {
            mValueRecord->getDoubleValue(access, value);
          }
        }
        void getDecimalValue(const Access * access, RuntimeValue * value)
        {
          // Ick.  Use RTTI to dispatch.
          if(NULL != dynamic_cast<const CLRPropertyAccess *>(access))
          {
            mObjectRecord->getDecimalValue(access, value);
          }
          else
          {
            mValueRecord->getDecimalValue(access, value);
          }
        }
        void getStringValue(const Access * access, RuntimeValue * value)
        {
          // Ick.  Use RTTI to dispatch.
          if(NULL != dynamic_cast<const CLRPropertyAccess *>(access))
          {
            mObjectRecord->getStringValue(access, value);
          }
          else
          {
            mValueRecord->getStringValue(access, value);
          }
        }
        void getWStringValue(const Access * access, RuntimeValue * value)
        {
          // Ick.  Use RTTI to dispatch.
          if(NULL != dynamic_cast<const CLRPropertyAccess *>(access))
          {
            mObjectRecord->getWStringValue(access, value);
          }
          else
          {
            mValueRecord->getWStringValue(access, value);
          }
        }
        void getBooleanValue(const Access * access, RuntimeValue * value)
        {
          // Ick.  Use RTTI to dispatch.
          if(NULL != dynamic_cast<const CLRPropertyAccess *>(access))
          {
            mObjectRecord->getBooleanValue(access, value);
          }
          else
          {
            mValueRecord->getBooleanValue(access, value);
          }
        }
        void getDatetimeValue(const Access * access, RuntimeValue * value)
        {
          // Ick.  Use RTTI to dispatch.
          if(NULL != dynamic_cast<const CLRPropertyAccess *>(access))
          {
            mObjectRecord->getDatetimeValue(access, value);
          }
          else
          {
            mValueRecord->getDatetimeValue(access, value);
          }
        }
        void getTimeValue(const Access * access, RuntimeValue * value)
        {
          // Ick.  Use RTTI to dispatch.
          if(NULL != dynamic_cast<const CLRPropertyAccess *>(access))
          {
            mObjectRecord->getTimeValue(access, value);
          }
          else
          {
            mValueRecord->getTimeValue(access, value);
          }
        }
        void getEnumValue(const Access * access, RuntimeValue * value)
        {
          // Ick.  Use RTTI to dispatch.
          if(NULL != dynamic_cast<const CLRPropertyAccess *>(access))
          {
            mObjectRecord->getEnumValue(access, value);
          }
          else
          {
            mValueRecord->getEnumValue(access, value);
          }
        }
        void getBinaryValue(const Access * access, RuntimeValue * value)
        {
        }
        void setLongValue(const Access * access, const RuntimeValue * val)
        {
          // Ick.  Use RTTI to dispatch.
          if(NULL != dynamic_cast<const CLRPropertyAccess *>(access))
          {
            mObjectRecord->setLongValue(access, val);
          }
          else
          {
            mValueRecord->setLongValue(access, val);
          }
        }
        void setLongLongValue(const Access * access, const RuntimeValue * val)
        {
          // Ick.  Use RTTI to dispatch.
          if(NULL != dynamic_cast<const CLRPropertyAccess *>(access))
          {
            mObjectRecord->setLongLongValue(access, val);
          }
          else
          {
            mValueRecord->setLongLongValue(access, val);
          }
        }
        void setDoubleValue(const Access * access, const RuntimeValue * val)
        {
          // Ick.  Use RTTI to dispatch.
          if(NULL != dynamic_cast<const CLRPropertyAccess *>(access))
          {
            mObjectRecord->setDoubleValue(access, val);
          }
          else
          {
            mValueRecord->setDoubleValue(access, val);
          }
        }
        void setDecimalValue(const Access * access, const RuntimeValue * val)
        {
          // Ick.  Use RTTI to dispatch.
          if(NULL != dynamic_cast<const CLRPropertyAccess *>(access))
          {
            mObjectRecord->setDecimalValue(access, val);
          }
          else
          {
            mValueRecord->setDecimalValue(access, val);
          }
        }
        void setStringValue(const Access * access, const RuntimeValue * val)
        {
          // Ick.  Use RTTI to dispatch.
          if(NULL != dynamic_cast<const CLRPropertyAccess *>(access))
          {
            mObjectRecord->setStringValue(access, val);
          }
          else
          {
            mValueRecord->setStringValue(access, val);
          }
        }
        void setWStringValue(const Access * access, const RuntimeValue * val)
        {
          // Ick.  Use RTTI to dispatch.
          if(NULL != dynamic_cast<const CLRPropertyAccess *>(access))
          {
            mObjectRecord->setWStringValue(access, val);
          }
          else
          {
            mValueRecord->setWStringValue(access, val);
          }
        }
        void setBooleanValue(const Access * access, const RuntimeValue * val)
        {
          // Ick.  Use RTTI to dispatch.
          if(NULL != dynamic_cast<const CLRPropertyAccess *>(access))
          {
            mObjectRecord->setBooleanValue(access, val);
          }
          else
          {
            mValueRecord->setBooleanValue(access, val);
          }
        }
        void setDatetimeValue(const Access * access, const RuntimeValue * val)
        {
          // Ick.  Use RTTI to dispatch.
          if(NULL != dynamic_cast<const CLRPropertyAccess *>(access))
          {
            mObjectRecord->setDatetimeValue(access, val);
          }
          else
          {
            mValueRecord->setDatetimeValue(access, val);
          }
        }
        void setTimeValue(const Access * access, const RuntimeValue * val)
        {
          // Ick.  Use RTTI to dispatch.
          if(NULL != dynamic_cast<const CLRPropertyAccess *>(access))
          {
            mObjectRecord->setTimeValue(access, val);
          }
          else
          {
            mValueRecord->setTimeValue(access, val);
          }
        }
        void setEnumValue(const Access * access, const RuntimeValue * val)
        {
          // Ick.  Use RTTI to dispatch.
          if(NULL != dynamic_cast<const CLRPropertyAccess *>(access))
          {
            mObjectRecord->setEnumValue(access, val);
          }
          else
          {
            mValueRecord->setEnumValue(access, val);
          }
        }
        void setBinaryValue(const Access * access, const RuntimeValue * val)
        {
        }

        ActivationRecord* getStaticLink() 
        {
          return NULL;
        }

        // This constructor does not take a static link, hence
        // this activation record must correspond to a global scope
        CLRMethodActivationRecord(gcroot<System::Object^> obj) 
        {
          mValueRecord = new CLRActivationRecord(nullptr);
          mObjectRecord = new CLRObjectActivationRecord(nullptr, obj);
        }

        ~CLRMethodActivationRecord()
        {
			delete mValueRecord;
			delete mObjectRecord;
        }
      };



      class CLRGlobalCompileEnvironment : public GlobalCompileEnvironment
      {
      private:
        CLRMethodFrame *mFrame;

        std::vector<string> mErrors;
        std::vector<string> mWarnings;
        std::vector<string> mInfos;
        std::vector<string> mDebugs;
      public:

        CLRGlobalCompileEnvironment(gcroot<System::Type ^> type, gcroot<System::Collections::ArrayList^> params)
        {
          mFrame = new CLRMethodFrame(type, params);
        }

        ~CLRGlobalCompileEnvironment()
        {
          //delete mFrame;
        }

        CLRMethodFrame* getMethodFrame()
        {
          return mFrame;
        }

        Frame* createFrame()
        {
          return getMethodFrame();
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
          mErrors.push_back(str);
        }

        void logWarning(const string& str)
        {
          mWarnings.push_back(str);
        }

        void logInfo(const string& str)
        {
          mInfos.push_back(str);
        }

        void logDebug(const string& str)
        {
          mDebugs.push_back(str);
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


      class CLRGlobalRuntimeEnvironment : public GlobalRuntimeEnvironment
      {
        CLRMethodActivationRecord mObjectRecord;

        std::vector<string> mErrors;
        std::vector<string> mWarnings;
        std::vector<string> mInfos;
        std::vector<string> mDebugs;


      public:

        CLRGlobalRuntimeEnvironment(gcroot<System::Object^> obj) : mObjectRecord(obj)
        {
        }

        CLRMethodActivationRecord* getCLRMethodActivationRecord()
        {
          return &mObjectRecord;
        }

        ActivationRecord* getActivationRecord()
        {
          return getCLRMethodActivationRecord();
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
          mErrors.push_back(str);
        }

        void logWarning(const string& str)
        {
          mWarnings.push_back(str);
        }

        void logInfo(const string& str)
        {
          mInfos.push_back(str);
        }

        void logDebug(const string& str)
        {
          mDebugs.push_back(str);
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

      void MTSQLMethod::AddParam(System::String^ param)
      {
        mParams->Add(param);
      }

      System::String^ MTSQLMethod::refactorRenameVariable(
                                System::String^ script,
                                System::String^ oldVariableName,
                                System::String^ newVariableName)
      {
        mEnv = new CLRGlobalCompileEnvironment(mType, mParams);
		mInterpreter = new MTSQLInterpreter(mEnv);

		pin_ptr<const wchar_t> scriptChars = PtrToStringChars(script);
		std::string scriptString = ascii(scriptChars);

		pin_ptr<const wchar_t> oldNameChars = PtrToStringChars(oldVariableName);
		std::string oldNameString = ascii(oldNameChars);

		pin_ptr<const wchar_t> newNameChars = PtrToStringChars(newVariableName);
		std::string newNameString = ascii(newNameChars);

        std::string newScript = scriptString;

        try
        {
          newScript = mInterpreter->refactorRenameVariable(scriptString,
                                                           oldNameString,
                                                           newNameString);
        }
        catch(System::Exception^ e)
        {
          throw e;
        }

        return gcnew System::String(newScript.c_str());
      }

      System::String^ MTSQLMethod::refactorVarchar(System::String^ script)
      {
        mEnv = new CLRGlobalCompileEnvironment(mType, mParams);
		mInterpreter = new MTSQLInterpreter(mEnv);

		pin_ptr<const wchar_t> scriptChars = PtrToStringChars(script);
		std::string scriptString = ascii(scriptChars);

        std::string newScript = scriptString;

        try
        {
          newScript = mInterpreter->refactorVarchar(scriptString);
        }
        catch(System::Exception^ e)
        {
          throw e;
        }

        return gcnew System::String(newScript.c_str());
      }

      void MTSQLMethod::Compile()
      {
		  
        if(!mIsCompiled)
        {
          delete mEnv;
          delete mInterpreter;

		  pin_ptr<const wchar_t> chars = PtrToStringChars(mProgram);
		  std::wstring wideStr = chars;

          mEnv = new CLRGlobalCompileEnvironment(mType, mParams);
		  mInterpreter = new MTSQLInterpreter(mEnv);


          mExe = mInterpreter->analyze(wideStr.c_str());
         
          //create program params
          mProgramParams = gcnew System::Collections::ArrayList();
          std::vector<MTSQLParam> params = mInterpreter->getProgramParams();
          std::vector<MTSQLParam>::iterator it;
          for(it = params.begin(); it != params.end(); it++)
          {
            Parameter^ managedptr = gcnew Parameter();
            managedptr->Name = gcnew System::String((*it).GetName().c_str());
            managedptr->Direction = ((ParameterDirection)(*it).GetDirection());
            managedptr->DataType = (ParameterDataType)((*it).GetType());
            mProgramParams->Add(managedptr);
          }
          if (NULL == mExe) 
          {
            System::Text::StringBuilder^ builder = gcnew System::Text::StringBuilder();
            builder->Append("Compile Failure: ");
            builder->Append(gcnew System::String(mEnv->dumpErrors().c_str()));
            throw gcnew System::ApplicationException(builder->ToString());
          }

          mIsCompiled = true;
					
        }
      }

      void MTSQLMethod::Execute(System::Object^ obj, System::Collections::Hashtable^ params)
      {
        Compile();

        // TODO: Check the correct number of parameters is being set.

        CLRGlobalRuntimeEnvironment renv(obj);

        // Set parameters in the runtime environment
        for(System::Collections::IEnumerator^ e = params->GetEnumerator();e->MoveNext();)
        {
          System::Collections::DictionaryEntry^ de = safe_cast<System::Collections::DictionaryEntry^> (e->Current);
          // Create an access to the parameter from the frame
          RuntimeValue tmp;
          CLRTypeConvert::ConvertString(de->Key, &tmp);
          // TODO: convert CLR type to MTSQL type.  Right now no one is checking this value
          // so we can cheat.
          AccessPtr access = mEnv->getMethodFrame()->allocateVariable(tmp.getStringPtr(), RuntimeValue::TYPE_INTEGER);
          // ... and set the value in the activation record.
          renv.getCLRMethodActivationRecord()->getValueRecord()->setValue(access.get(), de->Value);
        }


        try {
          mExe->exec(&renv);
        } catch (MTSQLException& ex){
          System::Text::StringBuilder^ builder = gcnew System::Text::StringBuilder();
          builder->Append("Runtime Failure: ");
          builder->Append(gcnew System::String(ex.toString().c_str()));
          throw gcnew System::ApplicationException(builder->ToString());
        }

        renv.getCLRMethodActivationRecord()->getValueRecord()->copyTo(params);
      }

      void MTSQLMethod::Execute(System::Object^ obj)
      {
        Execute(obj, gcnew System::Collections::Hashtable());
      }

      MTSQLMethod::~MTSQLMethod()
      {
        // Interpreter cleans up executables.
        delete mEnv;
        delete mInterpreter;
      }
    }
}
