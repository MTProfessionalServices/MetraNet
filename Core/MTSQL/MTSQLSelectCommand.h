#ifndef _MTSQLSELECTCOMMAND_H_
#define _MTSQLSELECTCOMMAND_H_

#include "MTSQLConfig.h"
#include "RuntimeValue.h"

#ifdef WIN32
// import the query adapter tlb ...
#import <MTPipelineLib.tlb> rename( "EOF", "RowsetEOF" )
#else
namespace MTPipelineLib
{
  typedef long IMTSQLRowsetPtr;
};
#endif

class MTSQLSelectCommand
{
private:
	MTPipelineLib::IMTSQLRowsetPtr mpRowset;
public:
	MTSQL_DECL MTSQLSelectCommand(MTPipelineLib::IMTSQLRowsetPtr rowset);
  MTSQL_DECL void setQueryString(const std::wstring& query);
	MTSQL_DECL void execute();
	/**
	 * Can only call getRecordCount() after execute has been called.
	 */
	MTSQL_DECL long getRecordCount();
	MTSQL_DECL RuntimeValue getLong(long pos);
	MTSQL_DECL RuntimeValue getLongLong(long pos);
	MTSQL_DECL RuntimeValue getDec(long pos);
	MTSQL_DECL RuntimeValue getDouble(long pos);
	MTSQL_DECL RuntimeValue getBool(long pos);
	MTSQL_DECL RuntimeValue getString(long pos);
	MTSQL_DECL RuntimeValue getWString(long pos);
	MTSQL_DECL RuntimeValue getDatetime(long pos);
	MTSQL_DECL RuntimeValue getTime(long pos);
	MTSQL_DECL RuntimeValue getEnum(long pos);
	MTSQL_DECL RuntimeValue getBinary(long pos);
	/**
   * @param pos The position of the parameter whose value to set.  Begins with 1.
   * @param val The value to which to set the parameter.
   */
	MTSQL_DECL void setParam(long pos, RuntimeValue val);
};

#endif
