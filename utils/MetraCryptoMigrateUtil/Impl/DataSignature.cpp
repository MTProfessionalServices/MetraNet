
#include "DataSignature.h"


CDataSignature::CDataSignature(bool isGenerator)
:m_isGenerator(isGenerator)
{
	if(m_isGenerator)
	{
		m_name = "GenerateDataSig";
		m_description = "Generates a data signature from the selected data source";
	}
	else
	{
		m_name = "VerifyDataSig";
		m_description = "Compares the data signature for the target against a previously generated data signature";
	}

	m_rsaPiNumberKeyClass = "CreditCardNumber";
	m_rsaPiHashKeyClass = "PaymentInstHash";
	m_rsaPassKeyClass = "PasswordHash";
}

CDataSignature::~CDataSignature()
{
}

void 
CDataSignature::ClearParams()
{
	m_tid.clear();
	m_dataSource = CDataSignature::E_DS_NONE;

	m_exportDataTid.clear();
	m_dttPassPhrase.clear();

	exportedServerData = false;
	m_serverLocation.clear();
	m_dbName.clear();
	m_uid.clear();
	m_password.clear();
	m_port.clear();

	m_rsaKmcConfigFileName.clear();
	m_rsaKmcCertPass.clear();
	m_rsaPiNumberKeyClass = "CreditCardNumber";
	m_rsaPiHashKeyClass = "PaymentInstHash";
	m_rsaPassKeyClass = "PasswordHash";

	m_piReportCount = 0;
}


CDataSignature::TDataSource
CDataSignature::GetDataSource(const string& dataSourceStr)
{
	if(dataSourceStr == "server")
		return CDataSignature::E_DS_SERVER;

	if(dataSourceStr == "exportDataMirror")
		return CDataSignature::E_DS_EXPORT_DATA_MIRROR;

	if(dataSourceStr == "importDataMirror")
		return CDataSignature::E_DS_IMPORT_DATA_MIRROR;

	return CDataSignature::E_DS_NONE; 
}


void 
CDataSignature::GetServerDataSourceParams(AutoPtr<AbstractConfiguration> spParams)
{
	//need to refactor...
	exportedServerData = spParams->getBool("params.exportedData",false);

	if(!exportedServerData)
	{
		if(!spParams->hasProperty("params.rsaKmcConfigFileName"))
			throw Exception("Missing parameter");

		m_rsaKmcConfigFileName = spParams->getString("params.rsaKmcConfigFileName");

		if(!spParams->hasProperty("params.rsaKmcCertPass"))
			throw Exception("Missing parameter");

		m_rsaKmcCertPass = spParams->getString("params.rsaKmcCertPass");

		m_rsaPiNumberKeyClass = spParams->getString("params.rsaPiNumberKeyClass","CreditCardNumber");
		m_rsaPiHashKeyClass = spParams->getString("params.rsaPiHashKeyClass","PaymentInstHash");
		m_rsaPassKeyClass = spParams->getString("params.rsaPassKeyClass","PasswordHash");
	}
	else
	{
		if(!spParams->hasProperty("params.exportDataTid"))
			throw Exception("Missing parameter");

		m_exportDataTid = spParams->getString("params.exportDataTid");

		if(!spParams->hasProperty("params.dttPassPhrase"))
			throw Exception("Missing parameter");

		m_dttPassPhrase = spParams->getString("params.dttPassPhrase");
		if(m_dttPassPhrase.length() < 12)
			throw Exception("DTT passphrase must be at least 12 characters");
	}

	if(!spParams->hasProperty("params.serverLocation"))
		throw Exception("Missing parameter");

	m_serverLocation = spParams->getString("params.serverLocation");

	if(!spParams->hasProperty("params.dbName"))
		throw Exception("Missing parameter");

	m_dbName = spParams->getString("params.dbName");

	if(!spParams->hasProperty("params.uid"))
		throw Exception("Missing parameter");

	m_uid = spParams->getString("params.uid");

	if(!spParams->hasProperty("params.password"))
		throw Exception("Missing parameter");

	m_password = spParams->getString("params.password");

	m_port = spParams->getString("params.port","1433");
}

void 
CDataSignature::GetExportDataMirrorDataSourceParams(AutoPtr<AbstractConfiguration> spParams)
{
	if(!spParams->hasProperty("params.exportDataTid"))
		throw Exception("Missing parameter");

	m_exportDataTid = spParams->getString("params.exportDataTid");

	if(!spParams->hasProperty("params.dttPassPhrase"))
		throw Exception("Missing parameter");

	m_dttPassPhrase = spParams->getString("params.dttPassPhrase");
	if(m_dttPassPhrase.length() < 12)
		throw Exception("DTT passphrase must be at least 12 characters");
}

void 
CDataSignature::GetImportDataMirrorDataSourceParams(AutoPtr<AbstractConfiguration> spParams)
{
	if(!spParams->hasProperty("params.exportDataTid"))
		throw Exception("Missing parameter");

	m_exportDataTid = spParams->getString("params.exportDataTid");

	if(!spParams->hasProperty("params.rsaKmcConfigFileName"))
		throw Exception("Missing parameter");

	m_rsaKmcConfigFileName = spParams->getString("params.rsaKmcConfigFileName");

	if(!spParams->hasProperty("params.rsaKmcCertPass"))
		throw Exception("Missing parameter");

	m_rsaKmcCertPass = spParams->getString("params.rsaKmcCertPass");

	m_rsaPiNumberKeyClass = spParams->getString("params.rsaPiNumberKeyClass","CreditCardNumber");
	m_rsaPiHashKeyClass = spParams->getString("params.rsaPiHashKeyClass","PaymentInstHash");
	m_rsaPassKeyClass = spParams->getString("params.rsaPassKeyClass","PasswordHash");
}

bool 
CDataSignature::GetParams(AutoPtr<AbstractConfiguration> spParams)
{
	bool isOk = false;
	try
	{
		if(!spParams->hasProperty("params.tid"))
			throw Exception("Missing parameter");

		m_tid = spParams->getString("params.tid");

		if(!spParams->hasProperty("params.dataSource"))
			throw Exception("Missing parameter");

		string dataSource = spParams->getString("params.dataSource");
		m_dataSource = GetDataSource(dataSource);

		if(CDataSignature::E_DS_NONE == m_dataSource)
			throw Exception("Bad data source");

		switch(m_dataSource)
		{
		case CDataSignature::E_DS_SERVER:
			GetServerDataSourceParams(spParams);
			break;
		case CDataSignature::E_DS_EXPORT_DATA_MIRROR:
			GetExportDataMirrorDataSourceParams(spParams);
			break;
		case CDataSignature::E_DS_IMPORT_DATA_MIRROR:
			GetImportDataMirrorDataSourceParams(spParams);
			break;
		default:
			throw Exception("Bad data source type");
		}

		isOk = true;
	}
	catch(Exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " <<  x.displayText() << endl;
	}
	return isOk;
}

///////////////////////////////////////////////////////////////////////////////


bool
CDataSignature::Execute(AutoPtr<AbstractConfiguration> spParams)
{
	bool isOk = false;

	if(spParams.isNull())
		return isOk;

	try
	{
		ClearParams();
		if(!GetParams(spParams))
			throw Exception("Bad parameters");

		if(CDataSignature::E_DS_EXPORT_DATA_MIRROR == m_dataSource)
		{
			m_spDttRecord = new CDataTransformTransaction(m_exportDataTid);

			if(!m_spDttRecord->SetPassPhrase(m_dttPassPhrase))
				throw Exception("Could not restore DTT");

			if(!m_spDttRecord->Restore())
				throw Exception("Could not restore DTT");

			bool hasExportDataMirror = false;
			if(!m_spDttRecord->GetDataMirror(hasExportDataMirror))
				throw Exception("Could not restore DTT data");

			if(hasExportDataMirror)
			{
				m_spSourceDmManager = new CDataMirrorManager(m_exportDataTid + ".export",false,this);

				string dmmName;
				if(m_spDttRecord->GetDataMirrorFileName(dmmName))
				{
					if(m_spSourceDmManager->Name() != dmmName)
						m_logger.warning() << __FUNCTION__ << " : Bad DTT data";
				}
				else
					throw Exception("Could not restore DTT data");
			}
			else
			{
				throw Exception("Missing export data mirror");
			}

			m_spSourceDataMirrorDasManager = new CDataActionStateManager(m_exportDataTid + ".export",true);

			string kid;
			string kv;
			string kiv;
			if(!m_spDttRecord->GetDataKey(kid,kv,kiv))
				throw Exception("DTT data error");

			if((kid != m_exportDataTid) || kid.empty() || kv.empty() || kiv.empty())
				throw Exception("DTT data error");
		
			m_spCryptoEngine = new CCryptoEngine();

			if(!m_spCryptoEngine->SetKeyAsHexString(kv,kiv))
				throw Exception("CE error");

			kid.clear();
			kv.clear();
			kiv.clear();
		}

		if((CDataSignature::E_DS_SERVER == m_dataSource) ||
			(CDataSignature::E_DS_IMPORT_DATA_MIRROR == m_dataSource))
		{
			m_spRsaKmClient = new CRsaKeyManagerClient(m_rsaKmcConfigFileName,m_rsaKmcCertPass,
											m_rsaPiNumberKeyClass,m_rsaPiHashKeyClass,m_rsaPassKeyClass);
		}
		
		if(CDataSignature::E_DS_SERVER == m_dataSource)
		{
			if(exportedServerData)
			{
				m_spDttRecord = new CDataTransformTransaction(m_exportDataTid);

				if(!m_spDttRecord->SetPassPhrase(m_dttPassPhrase))
					throw Exception("Could not restore DTT");

				if(!m_spDttRecord->Restore())
					throw Exception("Could not restore DTT");

				string kid;
				string kv;
				string kiv;
				if(!m_spDttRecord->GetDataKey(kid,kv,kiv) || ((kid != m_tid) || kid.empty() || kv.empty() || kiv.empty()))
					throw Exception("DTT data error");

				m_spCryptoEngine = new CCryptoEngine();

				if(!m_spCryptoEngine->SetKeyAsHexString(kv,kiv))
					throw Exception("CE error");

				kid.clear();
				kv.clear();
				kiv.clear();
			}

			m_spDsClient = new CDataExporterDataStoreClient(this,m_serverLocation,m_dbName,m_uid,m_password,m_port);
		}

		if(CDataSignature::E_DS_IMPORT_DATA_MIRROR == m_dataSource)
		{
			m_spSourceDataMirrorDasManager = new CDataActionStateManager(m_exportDataTid + ".import",true);
			m_spSourceDmManager = new CDataMirrorManager(m_exportDataTid + ".import",false,this);
		}

		string typeSuffix;
		if(m_isGenerator)
			typeSuffix = ".generator";
		else
		{
			typeSuffix = ".validator";
			m_spCompareDasManager = new CDataActionStateManager(m_tid + ".generator",true);
		}

		m_spDasManager = new CDataActionStateManager(m_tid + typeSuffix);

		if(CDataSignature::E_DS_SERVER == m_dataSource)
		{
			isOk = m_spDsClient->VisitPaymentInstruments();
		}
		else
		{
			isOk = m_spSourceDmManager->VisitData();
		}

		m_logger.information() << "Total payment instrument reports: " << m_piReportCount << endl
								<< "Total data records: " << m_spDasManager->DataCount() << endl
								<< "Data hash: " << m_spDasManager->DataHash() << endl;

		if((CDataSignature::E_DS_IMPORT_DATA_MIRROR == m_dataSource) ||
			(CDataSignature::E_DS_IMPORT_DATA_MIRROR == m_dataSource))
		{
			if((m_spDasManager->DataCount() != m_spSourceDataMirrorDasManager->DataCount()) ||
				(m_spDasManager->DataHash() != m_spSourceDataMirrorDasManager->DataHash()))
			{
				m_logger.information() << "IMPORTANT: DATA DOES NOT MATCH ORIGINAL DATA" << endl;
			}
		}

		if(!m_isGenerator)
		{
			if((m_spDasManager->DataCount() != m_spCompareDasManager->DataCount()) ||
				(m_spDasManager->DataHash() != m_spCompareDasManager->DataHash()))
			{
				m_logger.information() << "DATA SIGNATURE VERIFICATION FAILED" << endl;
			}
			else
			{
				m_logger.information() << "DATA SIGNATURE VERIFICATION SUCCESSFUL" << endl;
			}
		}
	}
	catch(Exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " <<  x.displayText() << endl;
	}

	m_spSourceDmManager = NULL;
	m_spDsClient = NULL;
	m_spRsaKmClient = NULL;
	m_spCryptoEngine = NULL;
	m_spDttRecord = NULL;
	m_spDasManager = NULL;
	m_spSourceDataMirrorDasManager = NULL;
	m_spCompareDasManager = NULL;

	ClearParams();

	return isOk;
}


///////////////////////////////////////////////////////////////////////////////

bool 
CDataSignature::OnPaymentInstrumentReport(const string& inAccount,
												   const string& inKey,
												   string& outAccount)
{
	bool isOk = true;
	m_piReportCount++;

	if(inAccount.empty() || inKey.empty())
		return isOk;

	//todo: convert to exceptions... 

	string decAccount;
	if(exportedServerData)
	{
		if(m_spCryptoEngine->Decrypt(inAccount,decAccount,true))
		{
			if(!decAccount.empty())
			{	
				m_spDasManager->UpdateState(inKey,decAccount);

				const char* pInfo = decAccount.data();
				size_t infoSize = decAccount.size();
				if((NULL != pInfo) && (0 != infoSize))
					SecureZeroMemory((void*)pInfo,infoSize);

				isOk = true;
			}
			else
			{
				m_logger.warning() << __FUNCTION__ << " : Report processing error 1" << endl;
			}
		}
		else
		{
			m_logger.warning() << __FUNCTION__ << " : Report processing error 2" << endl;
		}
	}
	else
	{
		if(m_spRsaKmClient->DecryptCcNumber(inAccount,decAccount))
		{
			if(!decAccount.empty())
			{
				m_spDasManager->UpdateState(inKey,decAccount);

				const char* pInfo = decAccount.data();
				size_t infoSize = decAccount.size();
				if((NULL != pInfo) && (0 != infoSize))
					SecureZeroMemory((void*)pInfo,infoSize);

				isOk = true;
			}
			else
			{
				m_logger.warning() << __FUNCTION__ << " : Report processing error 3" << endl;
			}
		}
		else
		{
			m_logger.warning() << __FUNCTION__ << " : Report processing error 4" << endl;
		}
	}

	return isOk;
}

bool 
CDataSignature::OnPaymentInstrumentError(const string& inErrorInfo,bool& outIgnore)
{
	m_logger.warning() << __FUNCTION__ << " : PaymentInstrument error: " << inErrorInfo << endl;
	outIgnore = true;
	return true;
}

///////////////////////////////////////////////////////////////////////////////

bool 
CDataSignature::OnDataReport(const string& inNewData,
							const string& inNewDataHash,
							const string& inOrigData,
							const string& inOrigDataKey)
{
	bool isOk = true;
	m_piReportCount++;

	if(inNewData.empty() || inOrigData.empty() || inOrigDataKey.empty())
		return isOk;

	//todo: convert to exceptions... 

	if(CDataSignature::E_DS_EXPORT_DATA_MIRROR == m_dataSource)
	{
		string decAccount;
		if(m_spCryptoEngine->Decrypt(inNewData,decAccount,true))
		{
			if(!decAccount.empty())
			{
				m_spDasManager->UpdateState(inOrigDataKey,decAccount);

				const char* pInfo = decAccount.data();
				size_t infoSize = decAccount.size();
				if((NULL != pInfo) && (0 != infoSize))
					SecureZeroMemory((void*)pInfo,infoSize);

				isOk = true;
			}
			else
			{
				m_logger.warning() << __FUNCTION__ << " : Report processing error 1" << endl;
			}
		}
		else
		{
			m_logger.warning() << __FUNCTION__ << " : Report processing error 2" << endl;
		}
	}
	else //CDataSignature::E_DS_IMPORT_DATA_MIRROR
	{
		string decAccount;
		if(m_spRsaKmClient->DecryptCcNumber(inNewData,decAccount))
		{
			if(!decAccount.empty())
			{
				m_spDasManager->UpdateState(inOrigDataKey,decAccount);

				const char* pInfo = decAccount.data();
				size_t infoSize = decAccount.size();
				if((NULL != pInfo) && (0 != infoSize))
					SecureZeroMemory((void*)pInfo,infoSize);

				isOk = true;
			}
			else
			{
				m_logger.warning() << __FUNCTION__ << " : Report processing error 3" << endl;
			}
		}
	}

	return isOk;
}

bool 
CDataSignature::OnDataError(const string& inErrorInfo,bool& outIgnore)
{
	m_logger.warning() << __FUNCTION__ << " : Mirror data record error: " << inErrorInfo << endl;
	outIgnore = true;
	return true;
}
