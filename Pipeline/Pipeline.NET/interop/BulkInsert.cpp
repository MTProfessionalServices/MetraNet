/**************************************************************************
 * BULKINSERT
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
 * Created by: 
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include "BulkInsert.h"

#include <vcclr.h>

#include <stdutils.h>
#include <MTDec.h>


namespace MetraTech
{
namespace DataAccess
{

// make a smart pointer type for ITransaction
_COM_SMARTPTR_TYPEDEF(ITransaction, __uuidof(ITransaction));


IBulkInsert ^ BulkInsertManager::CreateBulkInsert(System::String^ logicalServerName)
{
	IBulkInsert^ bulkInsert;
	
	ConnectionInfo ^ info = gcnew ConnectionInfo(logicalServerName);
	switch (info->DatabaseType)
	{
		
	case MetraTech::DataAccess::DBType::SQLServer:
		bulkInsert = gcnew BCPBulkInsert();
		break;

	case MetraTech::DataAccess::DBType::Oracle:
		bulkInsert = gcnew ArrayBulkInsert();
		break;

	default:
		throw gcnew System::ApplicationException("Unsupported database type!");
	}

	bulkInsert->Connect(info);
	return bulkInsert;
}



BCPBulkInsert::BCPBulkInsert()
	: mpConnection(nullptr),
		mpBcpInsert(nullptr)
{ }

BCPBulkInsert::~BCPBulkInsert()
{
	//Dispose();
}

// IBulkInsert interface
void BCPBulkInsert::Connect(ConnectionInfo ^ connInfo)
{
	Connect(connInfo, nullptr);
}

void BCPBulkInsert::Connect(ConnectionInfo ^ connInfo,
							System::Object ^ txn)
{
	if (txn)
		throw gcnew DataAccessException("BCP bulk inserts cannot join transactions");

	try
	{

		//
		// convert the ConnectionInfo structure to a COdbcConnectionInfo
		// object.
		//
		pin_ptr<const wchar_t> chars = PtrToStringChars(connInfo->Server);
		wstring wideStr = chars;
		string server = ascii(wideStr);

		chars = PtrToStringChars(connInfo->Catalog);
		wideStr = chars;
		string catalog = ascii(wideStr);

		chars = PtrToStringChars(connInfo->UserName);
		wideStr = chars;
		string username = ascii(wideStr);


		chars = PtrToStringChars(connInfo->Password);
		wideStr = chars;
		string password = ascii(wideStr);

		chars = PtrToStringChars(connInfo->DataSource);
		wideStr = chars;
		string dataSource = ascii(wideStr);

		chars = PtrToStringChars(connInfo->DatabaseDriver);
		wideStr = chars;
		string databaseDriver = ascii(wideStr);

		COdbcConnectionInfo::DBType type;
		COdbcConnectionInfo odbcConnInfo(server, catalog, username, password);
		if (connInfo->DatabaseType == DBType::SQLServer)
			type = COdbcConnectionInfo::DBTYPE_SQL_SERVER;
		else
			type = COdbcConnectionInfo::DBTYPE_ORACLE;

		odbcConnInfo.SetDatabaseType(type);

		odbcConnInfo.SetTimeout(connInfo->Timeout);

		odbcConnInfo.SetDataSource(dataSource.c_str());
		odbcConnInfo.SetDatabaseDriver(databaseDriver.c_str());

		mpConnection = new COdbcConnection(odbcConnInfo);

	}
	catch (COdbcException & e)
	{
		std::string s = e.toString().c_str();
		throw gcnew DataAccessException(gcnew String(s.c_str()));
	}
}

void BCPBulkInsert::PrepareForInsert(System::String ^ tableName,
									 int rowsPerInsert)
{
	try
	{
		COdbcBcpHints hints = COdbcBcpHints();

		// use minimally logged inserts.
		// TODO: this may only matter if database recovery model settings are correct.
		//       however, it won't hurt if they're not
		hints.SetMinimallyLogged(true);

		if (!mpConnection)
			throw gcnew DataAccessException("no connection established");

		pin_ptr<const wchar_t> chars = PtrToStringChars(tableName);
		wstring wideStr = chars;
		string tableNameStr = ascii(wideStr);

		mpBcpInsert = mpConnection->PrepareBcpInsertStatement(tableNameStr.c_str(), hints);
	}
	catch (COdbcException & e)
	{
		std::string s = e.toString().c_str();
		throw gcnew DataAccessException(gcnew String(s.c_str()));
	}
}

void BCPBulkInsert::PrepareForInsertWithStatement(System::String ^ insertStatement,
												  int rowsPerInsert)
{
	ASSERT(0);
}


void BCPBulkInsert::SetValue(int column, MTParameterType type, System::Object ^ value)
{
	try
	{
		switch (type)
		{
		case MetraTech::DataAccess::MTParameterType::Integer:
		{
			int intVal = *safe_cast<System::Int32 ^>(value);
			mpBcpInsert->SetInteger(column, intVal);
			break;
		}
		case MetraTech::DataAccess::MTParameterType::BigInteger:
		{
			__int64  intVal = *safe_cast<System::Int64 ^>(value);
			mpBcpInsert->SetBigInteger(column, intVal);
			break;
		}
		case MetraTech::DataAccess::MTParameterType::String:
		{

			using namespace System::Runtime::InteropServices; 
			System::String ^ strVal = safe_cast<System::String ^>(value);
			const char* chars =
				(const char*)(Marshal::StringToHGlobalAnsi(strVal)).ToPointer();
			mpBcpInsert->SetString(column, chars);
			Marshal::FreeHGlobal(System::IntPtr((void*)chars));
			break;
		}
		case MetraTech::DataAccess::MTParameterType::WideString:
		{

			System::String ^ strVal = safe_cast<System::String ^>(value);
			pin_ptr<const wchar_t> chars;
			chars = PtrToStringChars(strVal);


			// TODO: avoid creating the intermediate wstring
			//wstring wideStr(chars);

			mpBcpInsert->SetWideString(column, chars, strVal->Length);

			break;
		}
		case MetraTech::DataAccess::MTParameterType::Decimal:
		{
			System::Decimal ^ decVal = safe_cast<System::Decimal ^>(value);

		    cli::array<int>^ bits = System::Decimal::GetBits(*decVal);

			// TODO: avoid intermediate conversion to DECIMAL
			// convert directly to SQL_NUMERIC_STRUCT
			DECIMAL convert;
			convert.wReserved = 0;
			convert.signscale = (bits[3]) >> 16;
			convert.Hi32 = bits[2];
			convert.Mid32 = bits[1];
			convert.Lo32 = bits[0];


			SQL_NUMERIC_STRUCT numericVal;
			DecimalToOdbcNumeric(&convert, &numericVal);

			mpBcpInsert->SetDecimal(column, numericVal);

			break;
		}
		case MetraTech::DataAccess::MTParameterType::DateTime:
		{
			System::DateTime ^ dateTimeVal = safe_cast<System::DateTime ^>(value);

			DATE oleDateVal = dateTimeVal->ToOADate();
			TIMESTAMP_STRUCT timestampVal;
			OLEDateToOdbcTimestamp(&oleDateVal, &timestampVal);
			mpBcpInsert->SetDatetime(column, timestampVal);
			break;
		}
#if 0
		// TODO: double isn't supported from DataAccess.cs
		case MetraTech::DataAccess::MTParameterType::Double:
		{
			double doubleVal = *safe_cast<System::Double *>(value);
			mpBcpInsert->SetDouble(column, doubleVal);
			break;
		}
#endif

			case MetraTech::DataAccess::MTParameterType::Binary:
			{
				cli::array<System::Byte>^ binaryData = safe_cast<array<System::Byte>^>(value); 
				pin_ptr<System::Byte> pinnedByteArray = &binaryData[0];
				mpBcpInsert->SetBinary(column, pinnedByteArray, binaryData->Length);
				break;
			}
		} // end switch
	} // end try 
	catch (COdbcException & e)
	{
		char buffer[1024];
		sprintf(buffer, "SetValue failed for column %d: %s", column, e.toString().c_str());
		throw gcnew DataAccessException(gcnew String(buffer));
	}
}

void BCPBulkInsert::SetWideString(int column, System::String ^ value)
{
	try
	{
		System::String ^ strVal = value;
		pin_ptr<const wchar_t> chars;
		chars = PtrToStringChars(strVal);

		mpBcpInsert->SetWideString(column, chars, strVal->Length);
	}
	catch (COdbcException & e)
	{
		std::string s = e.toString().c_str();
		throw gcnew DataAccessException(gcnew String(s.c_str()));
	}
}

void BCPBulkInsert::SetDecimal(int column, System::Decimal value)
{
	try
	{
		cli::array<int>^ bits = System::Decimal::GetBits(value);

		// TODO: avoid intermediate conversion to DECIMAL
		// convert directly to SQL_NUMERIC_STRUCT
		DECIMAL convert;
		convert.wReserved = 0;
		convert.signscale = (bits[3]) >> 16;
		convert.Hi32 = bits[2];
		convert.Mid32 = bits[1];
		convert.Lo32 = bits[0];


		SQL_NUMERIC_STRUCT numericVal;
		DecimalToOdbcNumeric(&convert, &numericVal);

		mpBcpInsert->SetDecimal(column, numericVal);
	}
	catch (COdbcException & e)
	{
		std::string s = e.toString().c_str();
		throw gcnew DataAccessException(gcnew String(s.c_str()));
	}

}

void BCPBulkInsert::SetDateTime(int column, System::DateTime value)
{
	try
	{
		DATE oleDateVal = value.ToOADate();
		TIMESTAMP_STRUCT timestampVal;
		OLEDateToOdbcTimestamp(&oleDateVal, &timestampVal);
		mpBcpInsert->SetDatetime(column, timestampVal);
	}
	catch (COdbcException & e)
	{
		std::string s = e.toString().c_str();
		throw gcnew DataAccessException(gcnew String(s.c_str()));
	}
}


void BCPBulkInsert::AddBatch()
{
	try
	{
		mpBcpInsert->AddBatch();
	}
	catch (COdbcException & e)
	{
		std::string s = e.toString().c_str();
		throw gcnew DataAccessException(gcnew String(s.c_str()));
	}
}

void BCPBulkInsert::ExecuteBatch()
{
	try
	{
		mpBcpInsert->ExecuteBatch();
	}
	catch (COdbcException & e)
	{
		std::string s = e.toString().c_str();
		throw gcnew DataAccessException(gcnew String(s.c_str()));
	}
}

int BCPBulkInsert::BatchCount()
{
	return mpBcpInsert->BatchCount();
}


ArrayBulkInsert::ArrayBulkInsert()
	: mpConnection(NULL),
		mpArrayInsert(NULL)
{ }

ArrayBulkInsert::~ArrayBulkInsert()
{
	
}

// IBulkInsert interface
void ArrayBulkInsert::Connect(ConnectionInfo ^ connInfo)
{
	Connect(connInfo, nullptr);
}


void ArrayBulkInsert::Connect(ConnectionInfo ^ connInfo,
							  System::Object ^ txn)
{
	try
	{
		ITransactionPtr rawtxn;

		if (txn)
		{
			// get the IUnknown pointer from the object.  This does an AddRef
			System::IntPtr pointer =
				System::Runtime::InteropServices::Marshal::GetIUnknownForObject(txn);
			IUnknown * iunk = (IUnknown *) pointer.ToPointer();

			// get the ITransaction interface from the IUnknown
			HRESULT hr = iunk->QueryInterface(__uuidof(ITransaction), (void **) &rawtxn);
			iunk->Release();

			if (FAILED(hr))
				throw gcnew System::Runtime::InteropServices::COMException(
					"Bad transaction object", hr);
		}
		else
			rawtxn = 0;

		//
		// convert the ConnectionInfo structure to a COdbcConnectionInfo
		// object.
		//
		pin_ptr<const wchar_t> chars = PtrToStringChars(connInfo->Server);
		wstring wideStr = chars;
		string server = ascii(wideStr);

		chars = PtrToStringChars(connInfo->Catalog);
		wideStr = chars;
		string catalog = ascii(wideStr);

		chars = PtrToStringChars(connInfo->UserName);
		wideStr = chars;
		string username = ascii(wideStr);


		chars = PtrToStringChars(connInfo->Password);
		wideStr = chars;
		string password = ascii(wideStr);

		chars = PtrToStringChars(connInfo->DataSource);
		wideStr = chars;
		string dataSource = ascii(wideStr);

		chars = PtrToStringChars(connInfo->DatabaseDriver);
		wideStr = chars;
		string databaseDriver = ascii(wideStr);

		COdbcConnectionInfo::DBType type;
		COdbcConnectionInfo odbcConnInfo(server, catalog, username, password);
		if (connInfo->DatabaseType == DBType::SQLServer)
			type = COdbcConnectionInfo::DBTYPE_SQL_SERVER;
		else
			type = COdbcConnectionInfo::DBTYPE_ORACLE;

		odbcConnInfo.SetDatabaseType(type);

		odbcConnInfo.SetTimeout(connInfo->Timeout);

		odbcConnInfo.SetDataSource(dataSource.c_str());
		odbcConnInfo.SetDatabaseDriver(databaseDriver.c_str());

		mpConnection = new COdbcConnection(odbcConnInfo);

		if (rawtxn)
		{
			bool retval = mpConnection->JoinTransaction(rawtxn);
			ASSERT(retval);						// should throw on error
		}
	}
	catch (COdbcException & e)
	{
		std::string s = e.toString().c_str();
		throw gcnew DataAccessException(gcnew String(s.c_str()));
	}


}

void ArrayBulkInsert::PrepareForInsert(System::String ^ tableName,
									   int rowsPerInsert)
{
	try
	{
		if (!mpConnection)
			throw gcnew DataAccessException("no connection established");

		pin_ptr<const wchar_t> chars = PtrToStringChars(tableName);
		wstring wideStr = chars;
		string tableNameStr = ascii(wideStr);

		mpArrayInsert = mpConnection->PrepareInsertStatement(tableNameStr, rowsPerInsert);
	}
	catch (COdbcException & e)
	{
		std::string s = e.toString().c_str();
		throw gcnew DataAccessException(gcnew String(s.c_str()));
	}
}


void ArrayBulkInsert::PrepareForInsertWithStatement(System::String ^ insertStatement, int rowsPerInsert)
{
	ASSERT(0);
}


void ArrayBulkInsert::SetValue(int column, MTParameterType type, System::Object ^ value)
{
	try
	{
		switch (type)
		{
		case MetraTech::DataAccess::MTParameterType::Integer:
		{
			int intVal = safe_cast<System::Int32>(value);
			mpArrayInsert->SetInteger(column, intVal);
			break;
		}
		case MetraTech::DataAccess::MTParameterType::BigInteger:
		{
			__int64  bigIntValue = safe_cast<System::Int64>(value);
			mpArrayInsert->SetBigInteger(column, bigIntValue);
			break;
		}
		case MetraTech::DataAccess::MTParameterType::String:
		{
			System::String ^ strVal = safe_cast<System::String ^>(value);

			using namespace System::Runtime::InteropServices;
			const char* chars = 
				(const char*)(Marshal::StringToHGlobalAnsi(strVal)).ToPointer();
			string asciiStr = chars;
			Marshal::FreeHGlobal(System::IntPtr((void*)chars));

			mpArrayInsert->SetString(column, asciiStr);
			break;
		}
		case MetraTech::DataAccess::MTParameterType::WideString:
		{
			System::String ^ strVal = safe_cast<System::String ^>(value);
			pin_ptr<const wchar_t> chars;
			chars = PtrToStringChars(strVal);

			wstring wideStr(chars);
			mpArrayInsert->SetWideString(column, wideStr);
			break;
		}
		case MetraTech::DataAccess::MTParameterType::Decimal:
		{
			// TODO: this conversion is not very efficient
			System::Decimal ^ decVal = safe_cast<System::Decimal ^>(value);
			System::String ^ decStr = decVal->ToString();

			pin_ptr<const wchar_t> chars;
			chars = PtrToStringChars(decStr);

			std::string asciiDec = ascii(wstring(chars));
			MTDecimal mtdec(asciiDec);

			SQL_NUMERIC_STRUCT numericVal;
			DecimalToOdbcNumeric(&mtdec, &numericVal);

			mpArrayInsert->SetDecimal(column, numericVal);
			break;
		}
		case MetraTech::DataAccess::MTParameterType::DateTime:
		{
			System::DateTime ^ dateTimeVal = safe_cast<System::DateTime ^>(value);

			DATE oleDateVal = dateTimeVal->ToOADate();
			TIMESTAMP_STRUCT timestampVal;
			OLEDateToOdbcTimestamp(&oleDateVal, &timestampVal);
			mpArrayInsert->SetDatetime(column, timestampVal);
			break;
		}
#if 0
		// TODO: double isn't supported from DataAccess.cs
		case MetraTech::DataAccess::MTParameterType::Double:
		{
			double doubleVal = *safe_cast<System::Double *>(value);
			mpArrayInsert->SetDouble(column, doubleVal);
			break;
		}
#endif

  case MetraTech::DataAccess::MTParameterType::Binary:
    {
	  cli::array<System::Byte>^ binaryData = safe_cast<array<System::Byte>^>(value); 
      pin_ptr<System::Byte> pinnedByteArray = &binaryData[0];
      mpArrayInsert->SetBinary(column, pinnedByteArray, binaryData->Length);
      break;
    }
    }
  }
	catch (COdbcException & e)
	{
		std::string s = e.toString().c_str();
		throw gcnew DataAccessException(gcnew String(s.c_str()));
	}

}

void ArrayBulkInsert::SetWideString(int column, System::String ^ value)
{
	throw gcnew DataAccessException("needs to be implemented");
}

void ArrayBulkInsert::SetDecimal(int column, System::Decimal value)
{
	throw gcnew DataAccessException("needs to be implemented");
}

void ArrayBulkInsert::SetDateTime(int column, System::DateTime value)
{
	throw gcnew DataAccessException("needs to be implemented");
}


void ArrayBulkInsert::AddBatch()
{
	try
	{
		mpArrayInsert->AddBatch();
	}
	catch (COdbcException & e)
	{
		std::string s = e.toString().c_str();
		throw gcnew DataAccessException(gcnew String(s.c_str()));
	}
}

void ArrayBulkInsert::ExecuteBatch()
{
	try
	{
		mpArrayInsert->ExecuteBatch();
	}
	catch (COdbcException & e)
	{
		std::string s = e.toString().c_str();
		throw gcnew DataAccessException(gcnew String(s.c_str()));
	}
}

int ArrayBulkInsert::BatchCount()
{
	return mpArrayInsert->BatchCount();
}

}
}
