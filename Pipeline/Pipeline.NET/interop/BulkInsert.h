/**************************************************************************
 * @doc BULKINSERT
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
 * Created by: 
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | BULKINSERT
 ***************************************************************************/

#ifndef _BULKINSERT_H
#define _BULKINSERT_H

#ifdef WIN32
// only include this header one time
#pragma once
#endif

#using <System.dll>

#using <MetraTech.DataAccess.dll>

using System::String;
using System::Object;

#pragma unmanaged
#include <metralite.h>
#include <OdbcException.h>
#include <OdbcConnection.h>
#include <OdbcPreparedArrayStatement.h>
#include <OdbcPreparedBcpStatement.h>
#include <OdbcConnMan.h>
#include <OdbcSessionTypeConversion.h>
#include <autoptr.h>

typedef MTautoptr<COdbcPreparedArrayStatement> COdbcPreparedArrayStatementPtr;
typedef MTautoptr<COdbcPreparedBcpStatement> COdbcPreparedBcpStatementPtr;
typedef MTautoptr<COdbcConnection> COdbcConnectionPtr;
typedef MTautoptr<COdbcStatement> COdbcStatementPtr;

#pragma managed

namespace MetraTech
{
namespace DataAccess
{

	//
	// TODO: this code should really live under S:\MetraTech\DataAccess\BulkInsert
	//


	// ideally this class would live in MetraTech.DataAccess.ConnectionManager
	// but because of circularity issues it lives with the implementation of 
	// bulk insert
	[System::Runtime::InteropServices::ComVisible(false)]
  public ref class BulkInsertManager
	{
  private:
		BulkInsertManager() {;}
	public:

		/// <summary>
		/// Returns a vendor specific bulk insert object based on the logical server.
		/// For SQL Server, BCP bulk inserts are returned. For Oracle, array inserts are returned.
		/// </summary>
		static IBulkInsert^ CreateBulkInsert(System::String ^ logicalServerName);
	};


	[System::Runtime::InteropServices::ComVisible(false)]
  public ref class BCPBulkInsert : public MetraTech::DataAccess::IBulkInsert
	{
	public:
		BCPBulkInsert();
		virtual ~BCPBulkInsert();

		// ----------------------------------------
		// IBulkInsert interface
		virtual void Connect(ConnectionInfo ^ connInfo);

		virtual void Connect(ConnectionInfo ^ connInfo,
							 System::Object ^ txn);

		virtual void PrepareForInsert(String ^ tableName, int rowsPerInsert);

		virtual void PrepareForInsertWithStatement(String ^ insertStatement,
										   int rowsPerInsert);

		virtual void SetValue(int column, MTParameterType type, Object ^ value);

		virtual void SetWideString(int column, String ^ value);
		virtual void SetDecimal(int column, System::Decimal value);
		virtual void SetDateTime(int column, System::DateTime value);

		virtual void AddBatch();

		virtual void ExecuteBatch();

		virtual int BatchCount();

		//void Dispose();

	private:
		COdbcConnection * mpConnection;
//		COdbcPreparedArrayStatementPtr mArrayInsert;
		COdbcPreparedBcpStatement * mpBcpInsert;
	};


	[System::Runtime::InteropServices::ComVisible(false)]
  public ref class ArrayBulkInsert : public MetraTech::DataAccess::IBulkInsert
	{
	public:
		ArrayBulkInsert();
		virtual ~ArrayBulkInsert();

		// ----------------------------------------
		// IBulkInsert interface
		virtual void Connect(ConnectionInfo ^ connInfo);

		virtual void Connect(ConnectionInfo ^ connInfo,
					         System::Object ^ txn);

		virtual void PrepareForInsert(System::String ^ tableName, int rowsPerInsert);

		virtual void PrepareForInsertWithStatement(System::String ^ insertStatement,
												   int rowsPerInsert);

		virtual void SetValue(int column, MTParameterType type, Object ^ value);

		virtual void SetWideString(int column, System::String ^ value);
		virtual void SetDecimal(int column, System::Decimal value);
		virtual void SetDateTime(int column, System::DateTime value);


		virtual void AddBatch();

		virtual void ExecuteBatch();

		virtual int BatchCount();

		//void Dispose();

	private:
		COdbcConnection * mpConnection;
		COdbcPreparedArrayStatement * mpArrayInsert;

//		COdbcConnectionPtr mConnection; 
	};


}
}

#endif /* _BULKINSERT_H */
