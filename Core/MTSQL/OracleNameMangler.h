#ifndef __ORACLENAMEMANGLER_H__
#define __ORACLENAMEMANGLER_H__

#ifdef WIN32
#include "OdbcConnection.h"
#include "OdbcConnMan.h"
#import <QueryAdapter.tlb> rename( "GetUserName", "QAGetUserName" )
#import <mscorlib.tlb> rename ("ReportEvent", "ReportEventX") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.DataAccess.tlb> inject_statement("using namespace mscorlib;")
#endif
#include <string>

class OracleNameMangler
{
public:

#ifdef WIN32
  static std::string GetStageDatabase()
  {
    return COdbcConnectionManager::GetConnectionInfo("NetMeterStage").GetCatalog();
  }

  static std::string HashTableName(const std::string& n)
  {
    MetraTech_DataAccess::IDBNameHashPtr nameHash(__uuidof(MetraTech_DataAccess::DBNameHash));
    std::string output = nameHash->GetDBNameHash(n.c_str());
    //sanity check - should never be longer than 30
    if(output.length() > 30)
    {
      char buf[512];
      sprintf(buf, 
              "Identifer '%s' too long (%d bytes vs. maximum of 30 bytes on Oracle). Decrease stage name, "
              "plugin name or temp table prefix in plugin configuration file!", output.c_str(), output.length());
      throw MTSQLInternalErrorException(__FILE__, __LINE__, buf);
    }
    return output;
  }
#else
  static std::string GetStageDatabase()
  {
    return "NetMeterStage";
  }

  static std::string HashTableName(const std::string& n)
  {
    return n;
  }
#endif
};

#endif
