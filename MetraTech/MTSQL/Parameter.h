#ifndef _MTSQLPROGRAMPARAMETER_H
#define _MTSQLPROGRAMPARAMETER_H

#ifdef WIN32
// only include this header one time
#pragma once
#endif

#pragma managed

#include <MTSQLInterop.h>
#include <MTSQLParam.h>

namespace MetraTech
{
    namespace MTSQL
    {
	  using namespace System::Runtime::InteropServices;

      [Guid("2b3ca36e-725e-4c0f-bd9e-f72edbf70f4d")]
      public enum class ParameterDataType 
	  {
		Invalid = -1,
		Integer,
		Double,
		String,
		Boolean,
		Decimal,
		DateTime,
		Time,
		Enum,
		WideString,
		Null,
		BigInteger
	  };

      [Guid("eba47ca5-28b5-47d1-943f-503a87b1b719")]
      public enum class ParameterDirection 
	  {
		In,
		Out
	  };

	  [Guid("4634AC2F-FE2A-4b3b-85C1-857A578DFFF2")]
  	  public interface class IParameter
	  {
		property System::String ^ Name;
		property System::Object ^ Value;
		property ParameterDirection Direction;
		property ParameterDataType DataType;
	  };

	  [Guid("3F8E046B-EC55-4ad0-8B97-BEA3DF62BDB5")]
	  [ClassInterface(ClassInterfaceType::None)]
	  public ref class Parameter : public IParameter
      {
		  public:
			property System::String^ Name
			{
				virtual System::String^ get() { return mName; }
				virtual void set(System::String^ value)
				{
					//cut out the '@' at the beginning
					System::Text::StringBuilder^ str = gcnew System::Text::StringBuilder(value);
					mName = str->Remove(0, 1)->ToString();
				}
				
			}

			property System::Object^ Value
			{
				virtual System::Object^ get() { return mValue; }
				virtual void set(System::Object^ value) {
					mValue = value;
				}
			}
			
			property ParameterDirection Direction
			{
				virtual ParameterDirection get() { return mDirection; }
				virtual void set(ParameterDirection value) {
					mDirection = value;
				}
			}

			property ParameterDataType DataType
			{
				virtual ParameterDataType get() { return mDataType; }
				virtual void set(ParameterDataType value) {
					mDataType = value;
				}
			}

			virtual ~Parameter();

		  private:
			System::String^ mName;
			System::Object^ mValue;
			ParameterDirection mDirection;
			ParameterDataType mDataType;
			MTSQLParam * mParam;
	  };
    }
}

#endif
