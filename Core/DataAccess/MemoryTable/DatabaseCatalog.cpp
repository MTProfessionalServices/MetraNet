#include "DatabaseCatalog.h"
#include "RecordModel.h"
#include "OdbcConnMan.h"
#include "OdbcConnection.h"

#ifdef WIN32
#include <Rpc.h>
#endif

DatabaseCommands::DatabaseCommands()
  :
  mDropTableFormat(COdbcConnectionManager::GetConnectionInfo("NetMeter").IsOracle() 
                   ?
                   L"begin\n"
                   L"if table_exists('%1%%2%') then\n"
                   L"  exec_ddl ('drop table %1%%2%');\n"
                   L"end if;\n"
                   L"end;\n" 
                   :
                   L"if object_id('%1%%2%') is not null\n"
                   L"  drop table %1%%2%\n"),
  mCreateTableAsSelectFormat(COdbcConnectionManager::GetConnectionInfo("NetMeter").IsOracle()
                             ?
                             L"begin\n"
                             L"  if not table_exists('%1%%2%') then\n"
                             L"      execute immediate 'create table %1%%2%\n"
                             L"        as SELECT * FROM %3%%4% WHERE 0=1';\n"
                             L"  end if;\n"
                             L"end;"
                             :
                             L"if object_id('%1%%2%') is null\n"
                             L"select *\n"
                             L"into %1%%2%\n"
                             L"from\n"
                             L"%3%%4% where 0=1"),
  mTruncateTableFormat(L"TRUNCATE TABLE %1%%2%")
{
}

DatabaseCommands::~DatabaseCommands()
{
}

std::wstring DatabaseCommands::GetTempTableName(const std::wstring& prefix)
{
  UUID uuid;
  ::UuidCreate(&uuid);
  static const wchar_t xlat[] = L"0123456789abcdefghijklmnopqrstuvwxyz";

  wchar_t buf[27];
  // To get around silly/archaic 30 character name limit in Oracle we base32-encode the
  // UUID (26 characters).  So we process 5 bits at a time.  I suppose it would
  // be better to base64-encode (UUENCODE) but I am not sure that Oracle supports
  // all those characters.

  // We ignore the UUID struct and just case into two 8 byte integers
  // to make the code more readable.
  // 32 Bits
  buf[0] = xlat[(((boost::uint64_t *) &uuid)[0] & 0xf800000000000000) >> 59];
  buf[1] = xlat[(((boost::uint64_t *) &uuid)[0] & 0x07c0000000000000) >> 54];
  buf[2] = xlat[(((boost::uint64_t *) &uuid)[0] & 0x003e000000000000) >> 49];
  buf[3] = xlat[(((boost::uint64_t *) &uuid)[0] & 0x0001f00000000000) >> 44];
  buf[4] = xlat[(((boost::uint64_t *) &uuid)[0] & 0x00000f8000000000) >> 39];
  buf[5] = xlat[(((boost::uint64_t *) &uuid)[0] & 0x0000007c00000000) >> 34];
  buf[6] = xlat[(((boost::uint64_t *) &uuid)[0] & 0x00000003e0000000) >> 29];
  buf[7] = xlat[(((boost::uint64_t *) &uuid)[0] & 0x000000001f000000) >> 24];
  buf[8] = xlat[(((boost::uint64_t *) &uuid)[0] & 0x0000000000f80000) >> 19];
  buf[9] = xlat[(((boost::uint64_t *) &uuid)[0] & 0x000000000007c000) >> 14];
  buf[10] = xlat[(((boost::uint64_t *) &uuid)[0] & 0x0000000000003e00) >> 9];
  buf[11] = xlat[(((boost::uint64_t *) &uuid)[0] & 0x00000000000001f0) >> 4];

  buf[12] = xlat[((((boost::uint64_t *) &uuid)[0] & 0x000000000000000f) << 1) + 
                 ((((boost::uint64_t *) &uuid)[1] & 0x8000000000000000) >> 63)];

  buf[13] = xlat[(((boost::uint64_t *) &uuid)[1] & 0x7c00000000000000) >> 58];
  buf[14] = xlat[(((boost::uint64_t *) &uuid)[1] & 0x03e0000000000000) >> 53];
  buf[15] = xlat[(((boost::uint64_t *) &uuid)[1] & 0x001f000000000000) >> 48];
  buf[16] = xlat[(((boost::uint64_t *) &uuid)[1] & 0x0000f80000000000) >> 43];
  buf[17] = xlat[(((boost::uint64_t *) &uuid)[1] & 0x000007c000000000) >> 38];
  buf[18] = xlat[(((boost::uint64_t *) &uuid)[1] & 0x0000003e00000000) >> 33];
  buf[19] = xlat[(((boost::uint64_t *) &uuid)[1] & 0x00000001f0000000) >> 28];
  buf[20] = xlat[(((boost::uint64_t *) &uuid)[1] & 0x000000000f800000) >> 23];
  buf[21] = xlat[(((boost::uint64_t *) &uuid)[1] & 0x00000000007c0000) >> 18];
  buf[22] = xlat[(((boost::uint64_t *) &uuid)[1] & 0x000000000003e000) >> 13];
  buf[23] = xlat[(((boost::uint64_t *) &uuid)[1] & 0x0000000000001f00) >> 8];
  buf[24] = xlat[(((boost::uint64_t *) &uuid)[1] & 0x00000000000000f8) >> 3];
  buf[25] = xlat[(((boost::uint64_t *) &uuid)[1] & 0x0000000000000007)];
  buf[26] = 0;

  return prefix + buf;
}

std::wstring DatabaseCommands::GetSchemaPrefix(const std::wstring& schema)
{
  std::string utf8Schema;
  ::WideStringToUTF8(schema, utf8Schema);
  std::wstring schemaPrefix;
  ::ASCIIToWide(schemaPrefix, COdbcConnectionManager::GetConnectionInfo(utf8Schema.c_str()).GetCatalogPrefix());
  return schemaPrefix;
}

std::wstring DatabaseCommands::CreateTableAsSelect(const std::wstring& targetSchema, const std::wstring& target,
                                                   const std::wstring& sourceSchema, const std::wstring& source
                                                   )
{
  std::string utf8SourceSchema;
  ::WideStringToUTF8(sourceSchema, utf8SourceSchema);
  std::wstring sourceSchemaPrefix;
  ::ASCIIToWide(sourceSchemaPrefix, COdbcConnectionManager::GetConnectionInfo(utf8SourceSchema.c_str()).GetCatalogPrefix());
  std::string utf8TargetSchema;
  ::WideStringToUTF8(targetSchema, utf8TargetSchema);
  std::wstring targetSchemaPrefix;
  ::ASCIIToWide(targetSchemaPrefix, COdbcConnectionManager::GetConnectionInfo(utf8TargetSchema.c_str()).GetCatalogPrefix());

  return (mCreateTableAsSelectFormat % targetSchemaPrefix % target % sourceSchemaPrefix % source).str();
}
std::wstring DatabaseCommands::DropTable(const std::wstring& sourceSchema, const std::wstring& source)
{
  std::string utf8SourceSchema;
  ::WideStringToUTF8(sourceSchema, utf8SourceSchema);
  std::wstring sourceSchemaPrefix;
  ::ASCIIToWide(sourceSchemaPrefix, COdbcConnectionManager::GetConnectionInfo(utf8SourceSchema.c_str()).GetCatalogPrefix());

  return (mDropTableFormat % sourceSchemaPrefix % source).str();
}

std::wstring DatabaseCommands::DropStagingTable(const std::wstring& source)
{
  return (mDropTableFormat % L"%%%NETMETERSTAGE_PREFIX%%%" % source).str();
}

std::wstring DatabaseCommands::TruncateTable(const std::wstring& sourceSchema, const std::wstring& source)
{
  std::string utf8SourceSchema;
  ::WideStringToUTF8(sourceSchema, utf8SourceSchema);
  std::wstring sourceSchemaPrefix;
  ::ASCIIToWide(sourceSchemaPrefix, COdbcConnectionManager::GetConnectionInfo(utf8SourceSchema.c_str()).GetCatalogPrefix());

  return (mTruncateTableFormat % sourceSchemaPrefix % source).str();
}

std::wstring DatabaseCommands::CreateTable(const LogicalRecord& metadata, 
                                           const std::wstring& tableSchema,
                                           const std::wstring& tableName)
{
  return CreateTable(metadata, tableSchema, tableName, std::map<std::wstring,std::wstring>());
}

std::wstring DatabaseCommands::CreateTable(const LogicalRecord& metadata, 
                                           const std::wstring& tableSchema,
                                           const std::wstring& tableName,
                                           const std::map<std::wstring,std::wstring>& sourceTargetMap)
{
  COdbcConnectionInfo netMeter = COdbcConnectionManager::GetConnectionInfo("NetMeter"); 
  bool isOracle = netMeter.IsOracle();

  // Handle the case in which we are asked to create the target table
  // Do this in the NetMeter database because on Oracle we need to
  // use exec_ddl & table_exists and these only live in NetMeter.
  std::string utf8Schema;
  ::WideStringToUTF8(tableSchema, utf8Schema);
  std::string utf8prefix = COdbcConnectionManager::GetConnectionInfo(utf8Schema.c_str()).GetCatalogPrefix();
  std::wstring prefix;
  ::ASCIIToWide(prefix, utf8prefix);
  std::wstring prefixedTable = prefix + tableName;
  std::wstring ddl;
  if (isOracle)
  {
    ddl += L"begin\n";
    ddl += L"if table_exists('";
    ddl += prefixedTable;
    ddl += L"') then\n"
      L"exec_ddl ('drop table ";
    ddl += prefixedTable;
    ddl += L"');\n"
      L"end if;\n"
      L"exec_ddl ('";
  }
  else
  {
    ddl += L"if object_id( '";
    ddl += prefixedTable;
    ddl += L"' ) is not null\n"
      L"DROP TABLE ";
    ddl += prefixedTable;
  }
  ddl += L"\nCREATE TABLE ";
  ddl += prefixedTable;
  ddl += L"(";
  for(LogicalRecord::const_iterator it = metadata.begin();
      it != metadata.end();
      ++it)
  {
    std::wstring colName;
    if (sourceTargetMap.size() == 0)
    {
      colName = it->GetName();
    }
    else
    {
      std::map<std::wstring,std::wstring>::const_iterator sit = sourceTargetMap.find(boost::to_upper_copy(it->GetName()));
      if (sit == sourceTargetMap.end()) continue;
      colName = sit->second;
    } 
    if (it != metadata.begin()) ddl += L", ";
    ddl += colName;
    ddl += L" ";
    ddl += isOracle ? it->GetType().GetOracleDatatype() : it->GetType().GetSQLServerDatatype();
  }    
  ddl += L")";

  if (isOracle)
  {
    ddl += L"');";
    ddl += L"end;";
  }
  return ddl;
}

