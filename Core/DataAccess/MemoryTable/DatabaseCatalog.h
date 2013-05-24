#ifndef __DATABASECATALOG_H__
#define __DATABASECATALOG_H__

#include <string>
#include <map>
#include <boost/format.hpp>

#include "MetraFlowConfig.h"

class LogicalRecord;
class RecordMember;

class DatabaseCommands
{
private:
  boost::wformat mDropTableFormat;
  boost::wformat mCreateTableAsSelectFormat;
  boost::wformat mTruncateTableFormat;
public:
  METRAFLOW_DECL DatabaseCommands();
  METRAFLOW_DECL ~DatabaseCommands();
  METRAFLOW_DECL std::wstring GetTempTableName(const std::wstring& prefix);
  METRAFLOW_DECL std::wstring GetSchemaPrefix(const std::wstring& schema);
  METRAFLOW_DECL std::wstring CreateTableAsSelect(const std::wstring& targetSchema, const std::wstring& target,
                                                  const std::wstring& sourceSchema, const std::wstring& source);
  METRAFLOW_DECL std::wstring DropTable(const std::wstring& sourceSchema, const std::wstring& source);
  METRAFLOW_DECL std::wstring DropStagingTable(const std::wstring& source);
  METRAFLOW_DECL std::wstring TruncateTable(const std::wstring& sourceSchema, const std::wstring& source);
  METRAFLOW_DECL std::wstring CreateTable(const LogicalRecord& metadata, 
                                          const std::wstring& tableSchema,
                                          const std::wstring& tableName,
                                          const std::map<std::wstring,std::wstring>& sourceTargetMap);
  METRAFLOW_DECL std::wstring CreateTable(const LogicalRecord& metadata, 
                                          const std::wstring& tableSchema,
                                          const std::wstring& tableName);
};


#endif
