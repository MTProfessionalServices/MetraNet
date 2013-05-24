#include "metralite.h"
#include "UsageLoader.h"
#include "OdbcConnMan.h"
#include "OdbcConnection.h"
#include "OdbcStatement.h"
#include "OdbcResultSet.h"
#include "ProductViewCollection.h"
#include "MTUtil.h"

#include <boost/format.hpp>

bool IsPartitioningEnabled()
{
  boost::shared_ptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
  boost::shared_ptr<COdbcStatement> stmt(conn->CreateStatement());

  boost::shared_ptr<COdbcResultSet> rs= boost::shared_ptr<COdbcResultSet> (stmt->ExecuteQueryW(L"select b_partitioning_enabled from t_usage_server"));
  if (!rs->Next()) throw std::runtime_error("Check installation: failed to read partitioning configuration from database");
  std::wstring partitioning = rs->GetWideString(1);
  return partitioning == L"Y";
}

std::string GenerateWPVNonPartitioned(const std::string& inputFilename,
                                      const std::string& productViewTableName,
                                      const std::vector<std::string> & productViewColumns,
                                      boost::int32_t commitSize,
                                      boost::int32_t batchSize,
                                      const std::string& compositeOperatorName)
{
  // We either are generating a composite operator or a feed directly from file.
  boost::format inputFromFileFmt(
    "input:sequential_file_scan[filename=\"%2%\"];\n"
    "%1%\n"
    "input -> switchInterval;\n"
    );

  boost::format compositeOperatorFmt(
    "operator %2% [in \"input\" is switchInterval(\"input\")]\n"
    "(\n"
    "%1%\n"
    ")\n"
    );

  std::string switchOp(
    "switchInterval:copy[];\n"
    );

  boost::format mfsFmt(
    "g%1%:generate[program=\"\n"
    "CREATE PROCEDURE p @id_commit_unit INTEGER\n"
    "AS\n"
    "SET @id_commit_unit = CAST(@@RECORDCOUNT / %5%LL AS INTEGER)\"];\n"
    "c%1%:copy[];\n"
    "switchInterval(%1%) -> g%1% -> c%1%;\n"
    "au%1%:insert[table=\"t_acc_usage\", schema=\"NetMeter\", batchSize=%6%, transactionKey=\"id_commit_unit\", sortOrder=\"id_sess ASC, id_usage_interval\"];\n"
    "c%1%(0) -> au%1%;\n"
    "pv%1%:insert[table=\"%4%\", schema=\"NetMeter\", batchSize=%6%, transactionKey=\"id_commit_unit\", sortOrder=\"id_sess ASC, id_usage_interval\"];\n"
    "c%1%(1) -> pv%1%;\n"
    "sgb%1%:sort_group_by[key=\"id_commit_unit\",\n"
    "initialize=\"\n"
    "CREATE PROCEDURE i @size_0 INTEGER @size_1 INTEGER\n"
    "AS\n"
    "SET @size_0 = 0\n"
    "SET @size_1 = 0\",\n"
    "update=\"\n"
    "CREATE PROCEDURE u @size_0 INTEGER @size_1 INTEGER\n"
    "AS\n"
    "SET @size_0 = @size_0 + 1\n"
    "SET @size_1 = @size_1 + 1\"];\n"
    "c%1%(2) -> sgb%1%;\n"
    "install%1%:sql_exec_direct[\n"
    "statementList=[\n"
    "	query=\"INSERT INTO %2%..t_acc_usage SELECT * FROM %%%%%%NETMETERSTAGE_PREFIX%%%%%%%3% option(maxdop 1)\",\n"
    "        postprocess=\"DROP TABLE %%%%%%NETMETERSTAGE_PREFIX%%%%%%%3%\"],\n"
    "statementList=[\n"
    "	query=\"INSERT INTO %2%..%4% SELECT * FROM %%%%%%NETMETERSTAGE_PREFIX%%%%%%%3% option(maxdop 1)\",\n"
    "        postprocess=\"DROP TABLE %%%%%%NETMETERSTAGE_PREFIX%%%%%%%3%\"]\n"
    "];\n"
    "au%1% ->[buffered=false] install%1%(\"input(0)\");\n"
    "pv%1% ->[buffered=false] install%1%(\"input(1)\");\n"
    "sgb%1% ->[buffered=false] install%1%(\"control\");\n"
    );

  std::string program;
  program += (mfsFmt % 0 % COdbcConnectionManager::GetConnectionInfo("NetMeter").GetCatalog() % "%1%" % productViewTableName % commitSize % batchSize).str();
  program = switchOp + program;

  if(compositeOperatorName.size() > 0)
    program = (compositeOperatorFmt % program % compositeOperatorName).str();
  else
    program = (inputFromFileFmt % program % inputFilename).str();
  
  return program;
}

std::string GenerateWPV(const std::string& inputFilename,
                        const std::string& productViewTableName,
                        const std::vector<std::string> & productViewColumns,
                        boost::int32_t commitSize,
                        boost::int32_t batchSize,
                        const std::string& compositeOperatorName)
{
  if (!IsPartitioningEnabled()) return GenerateWPVNonPartitioned(inputFilename,
                                                                 productViewTableName,
                                                                 productViewColumns,
                                                                 commitSize,
                                                                 batchSize,
                                                                 compositeOperatorName);

  boost::shared_ptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
  boost::shared_ptr<COdbcStatement> stmt(conn->CreateStatement());

  boost::shared_ptr<COdbcResultSet> rs= boost::shared_ptr<COdbcResultSet> (stmt->ExecuteQueryW(L"select partition_name, id_interval_start, id_interval_end from t_partition where b_default='N' and not exists (select 1 from t_archive_partition where t_partition.partition_name=t_archive_partition.partition_name and status='A' and tt_end='2038-01-01')"));

  // We either are generating a composite operator or a feed directly from file.
  boost::format inputFromFileFmt(
    "input:sequential_file_scan[filename=\"%2%\"];\n"
    "%1%\n"
    "input -> switchInterval;\n"
    );

  boost::format compositeOperatorFmt(
    "operator %2% [in \"input\" is switchInterval(\"input\")]\n"
    "(\n"
    "%1%\n"
    ")\n"
    );

  int i = 0;
  std::string switchClause;
  boost::format switchOpFmt(
    "switchInterval:switch[program=\"\n"
    "CREATE FUNCTION switchInterval (@id_usage_interval INTEGER) RETURNS INTEGER\n"
    "AS\n"
    "RETURN CASE\n%1%END\"];\n"
    );
  boost::format switchClauseFmt("WHEN @id_usage_interval >= %1% AND @id_usage_interval <= %2% THEN %3%\n");

  boost::format mfsFmt(
    "g%1%:generate[program=\"\n"
    "CREATE PROCEDURE p @id_commit_unit INTEGER\n"
    "AS\n"
    "SET @id_commit_unit = CAST(@@RECORDCOUNT / %5%LL AS INTEGER)\"];\n"
    "c%1%:copy[];\n"
    "switchInterval(%1%) -> g%1% -> c%1%;\n"
    "au%1%:insert[table=\"t_acc_usage\", schema=\"NetMeter\", batchSize=%6%, transactionKey=\"id_commit_unit\", sortOrder=\"id_sess ASC, id_usage_interval\"];\n"
    "c%1%(0) -> au%1%;\n"
    "pv%1%:insert[table=\"%4%\", schema=\"NetMeter\", batchSize=%6%, transactionKey=\"id_commit_unit\", sortOrder=\"id_sess ASC, id_usage_interval\"];\n"
    "c%1%(1) -> pv%1%;\n"
    "sgb%1%:sort_group_by[key=\"id_commit_unit\",\n"
    "initialize=\"\n"
    "CREATE PROCEDURE i @size_0 INTEGER @size_1 INTEGER\n"
    "AS\n"
    "SET @size_0 = 0\n"
    "SET @size_1 = 0\",\n"
    "update=\"\n"
    "CREATE PROCEDURE u @size_0 INTEGER @size_1 INTEGER\n"
    "AS\n"
    "SET @size_0 = @size_0 + 1\n"
    "SET @size_1 = @size_1 + 1\"];\n"
    "c%1%(2) -> sgb%1%;\n"
    "install%1%:sql_exec_direct[\n"
    "statementList=[\n"
    "	query=\"INSERT INTO %2%..t_acc_usage SELECT * FROM %%%%%%NETMETERSTAGE_PREFIX%%%%%%%3% option(maxdop 1)\",\n"
    "        postprocess=\"DROP TABLE %%%%%%NETMETERSTAGE_PREFIX%%%%%%%3%\"],\n"
    "statementList=[\n"
    "	query=\"INSERT INTO %2%..%4% SELECT * FROM %%%%%%NETMETERSTAGE_PREFIX%%%%%%%3% option(maxdop 1)\",\n"
    "        postprocess=\"DROP TABLE %%%%%%NETMETERSTAGE_PREFIX%%%%%%%3%\"]\n"
    "];\n"
    "au%1% ->[buffered=false] install%1%(\"input(0)\");\n"
    "pv%1% ->[buffered=false] install%1%(\"input(1)\");\n"
    "sgb%1% ->[buffered=false] install%1%(\"control\");\n"
    );
  std::string program;
  while(rs->Next())
  {
    std::wstring partitionName = rs->GetWideString(1);
    int intervalStart = rs->GetInteger(2);
    int intervalEnd = rs->GetInteger(3);
    switchClause += (switchClauseFmt %  intervalStart % intervalEnd % i).str();
    std::string utf8PartitionName;
    ::WideStringToUTF8(partitionName, utf8PartitionName);
    program += (mfsFmt % i % utf8PartitionName % "%1%" % productViewTableName % commitSize % batchSize).str();
    i += 1;
  }
  program = (switchOpFmt % switchClause).str() + program;

  if(compositeOperatorName.size() > 0)
    program = (compositeOperatorFmt % program % compositeOperatorName).str();
  else
    program = (inputFromFileFmt % program % inputFilename).str();
  
  return program;
}

std::string GenerateWPV2(const std::string& inputFilename,
                        const std::string& productViewTableName,
                        const std::vector<std::string> & productViewColumns,
                        boost::int32_t commitSize,
                        boost::int32_t batchSize)
{
  if (!IsPartitioningEnabled()) return GenerateWPVNonPartitioned(inputFilename,
                                                                 productViewTableName,
                                                                 productViewColumns,
                                                                 commitSize,
                                                                 batchSize,
                                                                 "");

  boost::shared_ptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
  boost::shared_ptr<COdbcStatement> stmt(conn->CreateStatement());

  boost::shared_ptr<COdbcResultSet> rs= boost::shared_ptr<COdbcResultSet> (
    stmt->ExecuteQueryW(
      L"select partition_name, id_interval_start, id_interval_end \n"
      L"from t_partition  \n"
      L"inner join t_usage_interval ui on ui.id_interval between t_partition.id_interval_start and t_partition.id_interval_end \n"
      L"inner join t_usage_cycle uc on uc.id_usage_cycle=ui.id_usage_cycle \n"
      L"where \n"
      L"b_default='N'  \n"
      L"and  \n"
      L"tx_interval_status <> 'H' \n"
      L"and \n"
      L"not exists (select 1 from t_archive_partition where t_partition.partition_name=t_archive_partition.partition_name and status='A' and tt_end='2038-01-01') \n"
      L"and \n"
      L"uc.id_cycle_type=1 \n"
      L"order by ui.id_usage_cycle asc \n"));

//   boost::shared_ptr<COdbcResultSet> rs= boost::shared_ptr<COdbcResultSet> (stmt->ExecuteQueryW(L"select partition_name, id_interval_start, id_interval_end from t_partition where b_default='N' and not exists (select 1 from t_archive_partition where t_partition.partition_name=t_archive_partition.partition_name and status='A' and tt_end='2038-01-01')"));

  int i = 0;
  std::string switchClause;
  boost::format switchOpFmt(
    "input:sequential_file_scan[filename=\"%2%\"];\n"
    "switchInterval:switch[program=\"\n"
    "CREATE FUNCTION switchInterval (@id_usage_interval INTEGER) RETURNS INTEGER\n"
    "AS\n"
    "RETURN CASE\n%1%END\"];\n"
    "input -> switchInterval;\n"
    "all_tables:union_all[];\n"
    );
  boost::format switchClauseFmt("WHEN @id_usage_interval >= %1% AND @id_usage_interval <= %2% THEN %3%\n");

  boost::format mfsFmt(
    "g%1%:generate[program=\"\n"
    "CREATE PROCEDURE p @id_commit_unit INTEGER\n"
    "AS\n"
    "SET @id_commit_unit = CAST(@@RECORDCOUNT / %4%LL AS INTEGER)\"];\n"
    "c%1%:copy[];\n"
    "switchInterval(%1%) -> g%1% -> c%1%;\n"
    "au%1%:insert[table=\"t_acc_usage\", schema=\"NetMeter\", batchSize=%5%, transactionKey=\"id_commit_unit\", sortOrder=\"id_sess ASC, id_usage_interval\"];\n"
    "c%1%(0) -> au%1%;\n"
    "pv%1%:insert[table=\"%3%\", schema=\"NetMeter\", batchSize=%5%, transactionKey=\"id_commit_unit\", sortOrder=\"id_sess ASC, id_usage_interval\"];\n"
    "c%1%(1) -> pv%1%;\n"
    "c1_rename%1%:rename[\n"
    "from=\"id_commit_unit\", to=\"id_commit_unit1\",\n"
    "from=\"table\", to=\"table1\",\n"
    "from=\"schema\", to=\"schema1\"];\n"
    "c0_c1_join%1%:inner_merge_join[leftKey=\"id_commit_unit\", rightKey=\"id_commit_unit1\"];\n"
    "au%1% ->[buffered=false] c0_c1_join%1%(\"left\");\n"
    "pv%1% ->[buffered=false] c1_rename%1% ->[buffered=false] c0_c1_join%1%(\"right\");\n"
    "set_target_schema%1%:generate[program=\"CREATE PROCEDURE p @id_commit_unit INTEGER @targetSchema NVARCHAR OUTPUT @targetSchema1 NVARCHAR OUTPUT\n"
    "AS\n"
    "SET @targetSchema = N'%2%'\n"
    "SET @targetSchema1 = N'%2%'\"];\n"
    "c0_c1_join%1% ->[buffered=false] set_target_schema%1%;\n"
    "set_target_schema%1% ->[buffered=false] all_tables(%1%);\n"
    );
  // Feed all of the database insert outputs into a single
  // sequential exec direct
  boost::format installerFmt (
    "install_all_coll:coll[mode=\"sequential\"];\n"
    "all_tables ->[buffered=false] install_all_coll;\n"
    "install_all_tables:sql_exec_direct2[\n"
    "statementList=[\n"
    "	query=\"INSERT INTO %%%%%%PARTITION_PREFIX%%%%%%t_acc_usage SELECT * FROM %%%%%%NETMETERSTAGE_PREFIX%%%%%%%1% option(maxdop 1)\",\n"
    "        postprocess=\"DROP TABLE %%%%%%NETMETERSTAGE_PREFIX%%%%%%%1%\"],\n"
    "statementList=[\n"
    "	query=\"INSERT INTO %%%%%%PARTITION_PREFIX%%%%%%%2% SELECT * FROM %%%%%%NETMETERSTAGE_PREFIX%%%%%%%1% option(maxdop 1)\",\n"
    "        postprocess=\"DROP TABLE %%%%%%NETMETERSTAGE_PREFIX%%%%%%%1%\"],\n"
    "mode=\"sequential\"];\n"
    "install_all_coll ->[buffered=false] install_all_tables;\n");
  std::string program;
  while(rs->Next())
  {
    std::wstring partitionName = rs->GetWideString(1);
    int intervalStart = rs->GetInteger(2);
    int intervalEnd = rs->GetInteger(3);
    switchClause += (switchClauseFmt %  intervalStart % intervalEnd % i).str();
    std::string utf8PartitionName;
    ::WideStringToUTF8(partitionName, utf8PartitionName);
    program += (mfsFmt % i % utf8PartitionName % productViewTableName % commitSize % batchSize).str();
    i += 1;
  }
  program = (switchOpFmt % switchClause % inputFilename).str() + program + (installerFmt % "%1%" % productViewTableName).str();

  return program;
}

std::string GenerateWPVWithMergeNonPartitioned(const std::string& inputFilename,
                                 const std::string& productViewTableName,
                                 const std::vector<std::string> & productViewColumns,
                                 boost::int32_t commitSize,
                                 boost::int32_t batchSize)
{
  std::string pvColumnList;
  std::string pvSourceColumnList;

  for(std::vector<std::string>::const_iterator it = productViewColumns.begin();
      it != productViewColumns.end();
      ++it)
  {
    pvColumnList += (boost::format(", %1%") % (*it)).str();
    pvSourceColumnList += (boost::format(", Source.%1%") % (*it)).str();
  }

  int i = 0;
  std::string switchClause;
  boost::format switchOpFmt(
    "input:sequential_file_scan[filename=\"%1%\"];\n"
    "switchInterval:copy[];\n"
    "input->switchInterval;\n");

  boost::format mfsFmt(
    "g%1%:generate[program=\"\n"
    "CREATE PROCEDURE p @id_commit_unit INTEGER\n"
    "AS\n"
    "SET @id_commit_unit = CAST(@@RECORDCOUNT / %5%LL AS INTEGER)\"];\n"
    "c%1%:copy[];\n"
    "switchInterval(%1%) -> g%1% -> c%1%;\n"
    "au%1%:insert[table=\"t_acc_usage\", schema=\"NetMeter\", batchSize=%6%, transactionKey=\"id_commit_unit\", sortOrder=\"id_sess ASC, id_usage_interval\"];\n"
    "c%1%(0) -> au%1%;\n"
    "pv%1%:insert[table=\"%4%\", schema=\"NetMeter\", batchSize=%6%, transactionKey=\"id_commit_unit\", sortOrder=\"id_sess ASC, id_usage_interval\"];\n"
    "c%1%(1) -> pv%1%;\n"
    "sgb%1%:sort_group_by[key=\"id_commit_unit\",\n"
    "initialize=\"\n"
    "CREATE PROCEDURE i @size_0 INTEGER @size_1 INTEGER\n"
    "AS\n"
    "SET @size_0 = 0\n"
    "SET @size_1 = 0\",\n"
    "update=\"\n"
    "CREATE PROCEDURE u @size_0 INTEGER @size_1 INTEGER\n"
    "AS\n"
    "SET @size_0 = @size_0 + 1\n"
    "SET @size_1 = @size_1 + 1\"];\n"
    "c%1%(2) -> sgb%1%;\n"
    "install%1%:sql_exec_direct[\n"
    "statementList=[\n"
    "	query=\"MERGE %2%..t_acc_usage AS Target\n"
    "USING (SELECT id_sess, tx_UID, id_acc, id_payee, id_view, id_usage_interval, id_parent_sess, id_prod, id_svc, dt_session, amount, am_currency, dt_crt, tx_batch, tax_federal, tax_state, tax_county, tax_local, tax_other, id_pi_instance, id_pi_template, id_se FROM %%%%%%NETMETERSTAGE_PREFIX%%%%%%%3%) AS Source\n"
    "ON (Target.id_sess = Source.id_sess AND Target.id_usage_interval = Source.id_usage_interval)\n"
    "WHEN NOT MATCHED BY TARGET THEN\n"
    "    INSERT (id_sess, tx_UID, id_acc, id_payee, id_view, id_usage_interval, id_parent_sess, id_prod, id_svc, dt_session, amount, am_currency, dt_crt, tx_batch, tax_federal, tax_state, tax_county, tax_local, tax_other, id_pi_instance, id_pi_template, id_se)\n"
    "    VALUES (Source.id_sess, Source.tx_UID, Source.id_acc, Source.id_payee, Source.id_view, Source.id_usage_interval, Source.id_parent_sess, Source.id_prod, Source.id_svc, Source.dt_session, Source.amount, Source.am_currency, Source.dt_crt, Source.tx_batch, Source.tax_federal, Source.tax_state, Source.tax_county, Source.tax_local, Source.tax_other, Source.id_pi_instance, Source.id_pi_template, Source.id_se) option(maxdop 1);\",\n"
    "        postprocess=\"DROP TABLE %%%%%%NETMETERSTAGE_PREFIX%%%%%%%3%\"],\n"
    "statementList=[\n"
    "	query=\"MERGE %2%..%4% AS Target\n"
"USING (SELECT id_sess, id_usage_interval%7% FROM %%%%%%NETMETERSTAGE_PREFIX%%%%%%%3%) AS Source\n"
"ON (Target.id_sess = Source.id_sess AND Target.id_usage_interval = Source.id_usage_interval)\n"
"WHEN NOT MATCHED BY TARGET THEN\n"
"INSERT (id_sess, id_usage_interval%7%)\n"
"VALUES (Source.id_sess, Source.id_usage_interval%8%) option(maxdop 1);\",\n"
    "        postprocess=\"DROP TABLE %%%%%%NETMETERSTAGE_PREFIX%%%%%%%3%\"]\n"
    "];\n"
    "au%1% ->[buffered=false] install%1%(\"input(0)\");\n"
    "pv%1% ->[buffered=false] install%1%(\"input(1)\");\n"
    "sgb%1% ->[buffered=false] install%1%(\"control\");\n"
    );
  std::string program;
  program += (mfsFmt % 0 % COdbcConnectionManager::GetConnectionInfo("NetMeter").GetCatalog() % "%1%" % productViewTableName % commitSize % batchSize % pvColumnList % pvSourceColumnList).str();
  program = (switchOpFmt % inputFilename).str() + program;
  return program;
}

std::string GenerateWPVWithMerge(const std::string& inputFilename,
                                 const std::string& productViewTableName,
                                 const std::vector<std::string> & productViewColumns,
                                 boost::int32_t commitSize,
                                 boost::int32_t batchSize)
{
  if (!IsPartitioningEnabled()) return GenerateWPVWithMergeNonPartitioned(inputFilename,
                                                                          productViewTableName,
                                                                          productViewColumns,
                                                                          commitSize,
                                                                          batchSize);

  boost::shared_ptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
  boost::shared_ptr<COdbcStatement> stmt(conn->CreateStatement());

  boost::shared_ptr<COdbcResultSet> rs= boost::shared_ptr<COdbcResultSet> (stmt->ExecuteQueryW(L"select partition_name, id_interval_start, id_interval_end from t_partition where b_default='N' and not exists (select 1 from t_archive_partition where t_partition.partition_name=t_archive_partition.partition_name and status='A' and tt_end='2038-01-01')"));

  std::string pvColumnList;
  std::string pvSourceColumnList;

  for(std::vector<std::string>::const_iterator it = productViewColumns.begin();
      it != productViewColumns.end();
      ++it)
  {
    pvColumnList += (boost::format(", %1%") % (*it)).str();
    pvSourceColumnList += (boost::format(", Source.%1%") % (*it)).str();
  }

  int i = 0;
  std::string switchClause;
  boost::format switchOpFmt(
    "input:sequential_file_scan[filename=\"%2%\"];\n"
    "switchInterval:switch[program=\"\n"
    "CREATE FUNCTION switchInterval (@id_usage_interval INTEGER) RETURNS INTEGER\n"
    "AS\n"
    "RETURN CASE\n%1%END\"];\n"
    "input->switchInterval;\n");

  boost::format switchClauseFmt("WHEN @id_usage_interval >= %1% AND @id_usage_interval <= %2% THEN %3%\n");
  boost::format mfsFmt(
    "g%1%:generate[program=\"\n"
    "CREATE PROCEDURE p @id_commit_unit INTEGER\n"
    "AS\n"
    "SET @id_commit_unit = CAST(@@RECORDCOUNT / %5%LL AS INTEGER)\"];\n"
    "c%1%:copy[];\n"
    "switchInterval(%1%) -> g%1% -> c%1%;\n"
    "au%1%:insert[table=\"t_acc_usage\", schema=\"NetMeter\", batchSize=%6%, transactionKey=\"id_commit_unit\", sortOrder=\"id_sess ASC, id_usage_interval\"];\n"
    "c%1%(0) -> au%1%;\n"
    "pv%1%:insert[table=\"%4%\", schema=\"NetMeter\", batchSize=%6%, transactionKey=\"id_commit_unit\", sortOrder=\"id_sess ASC, id_usage_interval\"];\n"
    "c%1%(1) -> pv%1%;\n"
    "sgb%1%:sort_group_by[key=\"id_commit_unit\",\n"
    "initialize=\"\n"
    "CREATE PROCEDURE i @size_0 INTEGER @size_1 INTEGER\n"
    "AS\n"
    "SET @size_0 = 0\n"
    "SET @size_1 = 0\",\n"
    "update=\"\n"
    "CREATE PROCEDURE u @size_0 INTEGER @size_1 INTEGER\n"
    "AS\n"
    "SET @size_0 = @size_0 + 1\n"
    "SET @size_1 = @size_1 + 1\"];\n"
    "c%1%(2) -> sgb%1%;\n"
    "install%1%:sql_exec_direct[\n"
    "statementList=[\n"
    "	query=\"MERGE %2%..t_acc_usage AS Target\n"
    "USING (SELECT id_sess, tx_UID, id_acc, id_payee, id_view, id_usage_interval, id_parent_sess, id_prod, id_svc, dt_session, amount, am_currency, dt_crt, tx_batch, tax_federal, tax_state, tax_county, tax_local, tax_other, id_pi_instance, id_pi_template, id_se FROM %%%%%%NETMETERSTAGE_PREFIX%%%%%%%3%) AS Source\n"
    "ON (Target.id_sess = Source.id_sess AND Target.id_usage_interval = Source.id_usage_interval)\n"
    "WHEN NOT MATCHED BY TARGET THEN\n"
    "    INSERT (id_sess, tx_UID, id_acc, id_payee, id_view, id_usage_interval, id_parent_sess, id_prod, id_svc, dt_session, amount, am_currency, dt_crt, tx_batch, tax_federal, tax_state, tax_county, tax_local, tax_other, id_pi_instance, id_pi_template, id_se)\n"
    "    VALUES (Source.id_sess, Source.tx_UID, Source.id_acc, Source.id_payee, Source.id_view, Source.id_usage_interval, Source.id_parent_sess, Source.id_prod, Source.id_svc, Source.dt_session, Source.amount, Source.am_currency, Source.dt_crt, Source.tx_batch, Source.tax_federal, Source.tax_state, Source.tax_county, Source.tax_local, Source.tax_other, Source.id_pi_instance, Source.id_pi_template, Source.id_se) option(maxdop 1);\",\n"
    "        postprocess=\"DROP TABLE %%%%%%NETMETERSTAGE_PREFIX%%%%%%%3%\"],\n"
    "statementList=[\n"
    "	query=\"MERGE %2%..%4% AS Target\n"
"USING (SELECT id_sess, id_usage_interval%7% FROM %%%%%%NETMETERSTAGE_PREFIX%%%%%%%3%) AS Source\n"
"ON (Target.id_sess = Source.id_sess AND Target.id_usage_interval = Source.id_usage_interval)\n"
"WHEN NOT MATCHED BY TARGET THEN\n"
"INSERT (id_sess, id_usage_interval%7%)\n"
"VALUES (Source.id_sess, Source.id_usage_interval%8%) option(maxdop 1);\",\n"
    "        postprocess=\"DROP TABLE %%%%%%NETMETERSTAGE_PREFIX%%%%%%%3%\"]\n"
    "];\n"
    "au%1% ->[buffered=false] install%1%(\"input(0)\");\n"
    "pv%1% ->[buffered=false] install%1%(\"input(1)\");\n"
    "sgb%1% ->[buffered=false] install%1%(\"control\");\n"
    );
  std::string program;
  while(rs->Next())
  {
    std::wstring partitionName = rs->GetWideString(1);
    int intervalStart = rs->GetInteger(2);
    int intervalEnd = rs->GetInteger(3);
    switchClause += (switchClauseFmt %  intervalStart % intervalEnd % i).str();
    std::string utf8PartitionName;
    ::WideStringToUTF8(partitionName, utf8PartitionName);
    program += (mfsFmt % i % utf8PartitionName % "%1%" % productViewTableName % commitSize % batchSize % pvColumnList % pvSourceColumnList).str();
    i += 1;
  }
  program = (switchOpFmt % switchClause % inputFilename).str() + program;
  return program;
}

std::string GenerateWPVWithMerge2(const std::string& inputFilename,
                                 const std::string& productViewTableName,
                                 const std::vector<std::string> & productViewColumns,
                                 boost::int32_t commitSize,
                                 boost::int32_t batchSize)
{
  if (!IsPartitioningEnabled()) return GenerateWPVWithMergeNonPartitioned(inputFilename,
                                                                          productViewTableName,
                                                                          productViewColumns,
                                                                          commitSize,
                                                                          batchSize);

  boost::shared_ptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
  boost::shared_ptr<COdbcStatement> stmt(conn->CreateStatement());

  boost::shared_ptr<COdbcResultSet> rs= boost::shared_ptr<COdbcResultSet> (stmt->ExecuteQueryW(L"select partition_name, id_interval_start, id_interval_end from t_partition where b_default='N' and not exists (select 1 from t_archive_partition where t_partition.partition_name=t_archive_partition.partition_name and status='A' and tt_end='2038-01-01')"));

  std::string pvColumnList;
  std::string pvSourceColumnList;

  for(std::vector<std::string>::const_iterator it = productViewColumns.begin();
      it != productViewColumns.end();
      ++it)
  {
    pvColumnList += (boost::format(", %1%") % (*it)).str();
    pvSourceColumnList += (boost::format(", Source.%1%") % (*it)).str();
  }

  int i = 0;
  std::string switchClause;
  boost::format switchOpFmt(
    "input:sequential_file_scan[filename=\"%2%\"];\n"
    "switchInterval:switch[program=\"\n"
    "CREATE FUNCTION switchInterval (@id_usage_interval INTEGER) RETURNS INTEGER\n"
    "AS\n"
    "RETURN CASE\n%1%END\"];\n"
    "input->switchInterval;\n"
    "all_tables:union_all[];\n");

  boost::format switchClauseFmt("WHEN @id_usage_interval >= %1% AND @id_usage_interval <= %2% THEN %3%\n");
  boost::format mfsFmt(
    "g%1%:generate[program=\"\n"
    "CREATE PROCEDURE p @id_commit_unit INTEGER\n"
    "AS\n"
    "SET @id_commit_unit = CAST(@@RECORDCOUNT / %4%LL AS INTEGER)\"];\n"
    "c%1%:copy[];\n"
    "switchInterval(%1%) -> g%1% -> c%1%;\n"
    "au%1%:insert[table=\"t_acc_usage\", schema=\"NetMeter\", batchSize=%5%, transactionKey=\"id_commit_unit\", sortOrder=\"id_sess ASC, id_usage_interval\"];\n"
    "c%1%(0) -> au%1%;\n"
    "pv%1%:insert[table=\"%3%\", schema=\"NetMeter\", batchSize=%5%, transactionKey=\"id_commit_unit\", sortOrder=\"id_sess ASC, id_usage_interval\"];\n"
    "c%1%(1) -> pv%1%;\n"
    "c1_rename%1%:rename[\n"
    "from=\"id_commit_unit\", to=\"id_commit_unit1\",\n"
    "from=\"table\", to=\"table1\",\n"
    "from=\"schema\", to=\"schema1\"];\n"
    "c0_c1_join%1%:inner_merge_join[leftKey=\"id_commit_unit\", rightKey=\"id_commit_unit1\"];\n"
    "au%1% ->[buffered=false] c0_c1_join%1%(\"left\");\n"
    "pv%1% ->[buffered=false] c1_rename%1% ->[buffered=false] c0_c1_join%1%(\"right\");\n"
    "set_target_schema%1%:expr[program=\"CREATE PROCEDURE p @targetSchema NVARCHAR OUTPUT @targetSchema1 NVARCHAR OUTPUT\n"
    "AS\n"
    "SET @targetSchema = N'%2%'\n"
    "SET @targetSchema1 = N'%2%'\"];\n"
    "c0_c1_join%1% ->[buffered=false] set_target_schema%1%;\n"
    "set_target_schema%1% ->[buffered=false] all_tables(%1%);\n"
    );
  boost::format installerFmt(
    "install_all_coll:coll[mode=\"sequential\"];\n"
    "all_tables ->[buffered=false] install_all_coll;\n"
    "install_all_tables:sql_exec_direct2[\n"
    "statementList=[\n"
    "	query=\"MERGE %%%%%%PARTITION_PREFIX%%%%%%t_acc_usage AS Target\n"
    "USING (SELECT id_sess, tx_UID, id_acc, id_payee, id_view, id_usage_interval, id_parent_sess, id_prod, id_svc, dt_session, amount, am_currency, dt_crt, tx_batch, tax_federal, tax_state, tax_county, tax_local, tax_other, id_pi_instance, id_pi_template, id_se FROM %%%%%%NETMETERSTAGE_PREFIX%%%%%%%1%) AS Source\n"
    "ON (Target.id_sess = Source.id_sess AND Target.id_usage_interval = Source.id_usage_interval)\n"
    "WHEN NOT MATCHED BY TARGET THEN\n"
    "    INSERT (id_sess, tx_UID, id_acc, id_payee, id_view, id_usage_interval, id_parent_sess, id_prod, id_svc, dt_session, amount, am_currency, dt_crt, tx_batch, tax_federal, tax_state, tax_county, tax_local, tax_other, id_pi_instance, id_pi_template, id_se)\n"
    "    VALUES (Source.id_sess, Source.tx_UID, Source.id_acc, Source.id_payee, Source.id_view, Source.id_usage_interval, Source.id_parent_sess, Source.id_prod, Source.id_svc, Source.dt_session, Source.amount, Source.am_currency, Source.dt_crt, Source.tx_batch, Source.tax_federal, Source.tax_state, Source.tax_county, Source.tax_local, Source.tax_other, Source.id_pi_instance, Source.id_pi_template, Source.id_se) option(maxdop 1);\",\n"
    "        postprocess=\"DROP TABLE %%%%%%NETMETERSTAGE_PREFIX%%%%%%%1%\"],\n"
    "statementList=[\n"
    "	query=\"MERGE %%%%%%PARTITION_PREFIX%%%%%%%2% AS Target\n"
"USING (SELECT id_sess, id_usage_interval%3% FROM %%%%%%NETMETERSTAGE_PREFIX%%%%%%%1%) AS Source\n"
"ON (Target.id_sess = Source.id_sess AND Target.id_usage_interval = Source.id_usage_interval)\n"
"WHEN NOT MATCHED BY TARGET THEN\n"
"INSERT (id_sess, id_usage_interval%3%)\n"
"VALUES (Source.id_sess, Source.id_usage_interval%4%) option(maxdop 1);\",\n"
    "        postprocess=\"DROP TABLE %%%%%%NETMETERSTAGE_PREFIX%%%%%%%1%\"],\n"
    "mode=\"sequential\"];\n"
    "install_all_coll ->[buffered=false] install_all_tables;\n");

  std::string program;
  while(rs->Next())
  {
    std::wstring partitionName = rs->GetWideString(1);
    int intervalStart = rs->GetInteger(2);
    int intervalEnd = rs->GetInteger(3);
    switchClause += (switchClauseFmt %  intervalStart % intervalEnd % i).str();
    std::string utf8PartitionName;
    ::WideStringToUTF8(partitionName, utf8PartitionName);
    program += (mfsFmt % i % utf8PartitionName % productViewTableName % commitSize % batchSize).str();
    i += 1;
  }
  program = (switchOpFmt % switchClause % inputFilename).str() + program + (installerFmt % "%1%" % productViewTableName % pvColumnList % pvSourceColumnList).str();
  return program;
}

std::string GenerateUpdateProductView(const std::string& inputFilename,
                                      const std::string& productViewTableName,
                                      const std::vector<std::string> & productViewColumns,
                                      boost::int32_t commitSize,
                                      boost::int32_t batchSize)
{
  boost::shared_ptr<COdbcConnection> conn(new COdbcConnection(COdbcConnectionManager::GetConnectionInfo("NetMeter")));
  boost::shared_ptr<COdbcStatement> stmt(conn->CreateStatement());

  boost::shared_ptr<COdbcResultSet> rs= boost::shared_ptr<COdbcResultSet> (stmt->ExecuteQueryW(L"select partition_name, id_interval_start, id_interval_end from t_partition where b_default='N' and not exists (select 1 from t_archive_partition where t_partition.partition_name=t_archive_partition.partition_name and status='A' and tt_end='2038-01-01')"));

  std::string pvColumnList;
  std::string pvSourceColumnList;

  for(std::vector<std::string>::const_iterator it = productViewColumns.begin();
      it != productViewColumns.end();
      ++it)
  {
    pvColumnList += (boost::format(", %1%") % (*it)).str();
    pvSourceColumnList += (boost::format(", Source.%1%") % (*it)).str();
  }

  int i = 0;
  std::string switchClause;
  boost::format switchOpFmt(
    "input:sequential_file_scan[filename=\"%2%\"];\n"
    "switchInterval:switch[program=\"\n"
    "CREATE FUNCTION switchInterval (@id_usage_interval INTEGER) RETURNS INTEGER\n"
    "AS\n"
    "RETURN CASE\n%1%END\"];\n"
    "input->switchInterval;\n");

  boost::format switchClauseFmt("WHEN @id_usage_interval >= %1% AND @id_usage_interval <= %2% THEN %3%\n");
  boost::format mfsFmt(
    "g%1%:generate[program=\"\n"
    "CREATE PROCEDURE p @id_commit_unit INTEGER OUTPUT\n"
    "AS\n"
    "SET @id_commit_unit = CAST(@@RECORDCOUNT / %5%LL AS INTEGER)\"];\n"
    "c%1%:copy[];\n"
    "switchInterval(%1%) -> g%1% -> c%1%;\n"
    "pv%1%:insert[table=\"%4%\", schema=\"NetMeter\", batchSize=%6%, transactionKey=\"id_commit_unit\", sortOrder=\"id_sess ASC, id_usage_interval\"];\n"
    "c%1%(0) -> pv%1%;\n"
    "sgb%1%:sort_group_by[key=\"id_commit_unit\",\n"
    "initialize=\"\n"
    "CREATE PROCEDURE i @size_0 INTEGER\n"
    "AS\n"
    "SET @size_0 = 0\",\n"
    "update=\"\n"
    "CREATE PROCEDURE u @size_0 INTEGER \n"
    "AS\n"
    "SET @size_0 = @size_0 + 1\"];\n"
    "c%1%(1) -> sgb%1%;\n"
    "install%1%:sql_exec_direct[\n"
    "statementList=[\n"
    "	query=\"UPDATE p\n"
    "SET p.c_ResourceQuantity = p.c_ResourceQuantity + t.c_ResourceQuantity\n"
    "FROM %2%..%4% p INNER JOIN %%%%%%NETMETERSTAGE_PREFIX%%%%%%%3% t ON p.id_sess=t.id_sess AND p.id_usage_interval=t.id_usage_interval\n"
    "option(maxdop 1)\",\n"
    "        postprocess=\"DROP TABLE %%%%%%NETMETERSTAGE_PREFIX%%%%%%%3%\"]\n"
    "];\n"
    "pv%1% ->[buffered=false] install%1%(\"input(0)\");\n"
    "sgb%1% ->[buffered=false] install%1%(\"control\");\n"
    );
  std::string program;
  while(rs->Next())
  {
    std::wstring partitionName = rs->GetWideString(1);
    int intervalStart = rs->GetInteger(2);
    int intervalEnd = rs->GetInteger(3);
    switchClause += (switchClauseFmt %  intervalStart % intervalEnd % i).str();
    std::string utf8PartitionName;
    ::WideStringToUTF8(partitionName, utf8PartitionName);
    program += (mfsFmt % i % utf8PartitionName % "%1%" % productViewTableName % commitSize % batchSize).str();
    i += 1;
  }
  program = (switchOpFmt % switchClause % inputFilename).str() + program;
  return program;
}

std::string GenerateLoader(const std::string& inputFilename,
                           const std::string& productViewName,
                           boost::int32_t commitSize,
                           boost::int32_t batchSize,
                           bool useMerge)
{
  return GenerateLoaderEx(inputFilename, productViewName, commitSize, batchSize, useMerge, "");
}

std::string GenerateLoaderEx(const std::string& inputFilename,
                             const std::string& productViewName,
                             boost::int32_t commitSize,
                             boost::int32_t batchSize,
                             bool useMerge,
                             const std::string& createCompositeOperator)
{
  CProductViewCollection pvColl;
  if(FALSE == pvColl.Initialize())
  {
    throw std::runtime_error("Failed loading product view definitions; check MetraNet installation");
  }
  
  CMSIXDefinition * pv;
  std::wstring wProductViewName;
  ::ASCIIToWide(wProductViewName, productViewName);
  if(FALSE == pvColl.FindProductView(wProductViewName, pv) || NULL == pv)
  {
    throw std::runtime_error((boost::format("Failed to find product view definition for '%1%'") % productViewName).str());
  }

  std::string utf8TableName;
  ::WideStringToUTF8(pv->GetTableName(), utf8TableName);
  std::vector<std::string> utf8ColumnNames;
  for(MSIXPropertiesList::iterator it = pv->GetMSIXPropertiesList().begin();
      it != pv->GetMSIXPropertiesList().end();
      ++it)
  {
    std::string utf8ColumnName;
    ::WideStringToUTF8((*it)->GetColumnName(), utf8ColumnName);
    utf8ColumnNames.push_back(utf8ColumnName);
  }

  if (useMerge)
  {
    return GenerateWPVWithMerge2(inputFilename,
                                utf8TableName,
                                utf8ColumnNames,
                                commitSize,
                                batchSize);
  }
  else
  {
    return GenerateWPV(inputFilename,
                       utf8TableName,
                       utf8ColumnNames,
                       commitSize,
                       batchSize,
                       createCompositeOperator);
  }
}

