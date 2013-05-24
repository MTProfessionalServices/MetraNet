
#include "DataImporter.h"


CDataImporter::CDataImporter()
{
	m_name = "ImportData";
	m_description = "Converts the encrypted database data from the export format";
	m_rsaPiNumberKeyClass = "CreditCardNumber";
	m_rsaPiHashKeyClass = "PaymentInstHash";
	m_rsaPassKeyClass = "PasswordHash";
}

CDataImporter::~CDataImporter()
{
}

bool
CDataImporter::Execute(AutoPtr<AbstractConfiguration> spParams)
{
	bool isOk = false;

	if(spParams.isNull())
		return isOk;

	try
	{
		m_spDasManager = new CDataActionStateManager(m_tid + ".import");
		if(m_spDasManager.isNull())
			throw Exception(__FUNCTION__ ": Could not create an import state manager");

		ClearParams();
		if(!GetParams(spParams))
			throw Exception("Bad parameters");

		m_spDttRecord = new CDataTransformTransaction(m_tid);

		if(!m_spDttRecord->SetPassPhrase(m_dttPassPhrase))
			throw Exception("Could not restore DTT");

		if(!m_spDttRecord->Restore())
			throw Exception("Could not restore DTT");

		bool hasExportDataMirror = false;
		if(!m_spDttRecord->GetDataMirror(hasExportDataMirror))
			throw Exception("Could not restore DTT data");

		if(hasExportDataMirror)
		{
			m_spExportDmManager = new CDataMirrorManager(m_tid + ".export",false,this);

			string dmmName;
			if(m_spDttRecord->GetDataMirrorFileName(dmmName))
			{
				if(m_spExportDmManager->Name() != dmmName)
					m_logger.warning() << __FUNCTION__ << " : " << "Bad DTT data (" << m_spExportDmManager->Name() << "/" << dmmName << ")" << endl;
			}
			else
				throw Exception("Could not restore DTT data");
		}

		m_spExportDasManager = new CDataActionStateManager(m_tid + ".export",true);
		if(m_spExportDasManager.isNull())
			throw Exception(__FUNCTION__ ": Could not create an export state manager");

		string kid;
		string kv;
		string kiv;
		if(!m_spDttRecord->GetDataKey(kid,kv,kiv))
			throw Exception("DTT data error");

		if((kid != m_tid) || kid.empty() || kv.empty() || kiv.empty())
			throw Exception("DTT data error");
		
		m_spCryptoEngine = new CCryptoEngine();

		if(!m_spCryptoEngine->SetKeyAsHexString(kv,kiv))
			throw Exception("CE error");

		kid.clear();
		kv.clear();
		kiv.clear();

		m_spRsaKmClient = new CRsaKeyManagerClient(m_rsaKmcConfigFileName,m_rsaKmcCertPass,
											m_rsaPiNumberKeyClass,m_rsaPiHashKeyClass,m_rsaPassKeyClass);
		
		if(!m_importFromMirror)
		{
			m_logger.information() << "DATA IMPORTER: Start initializing product data store client for data conversion and import." << endl;

			m_spDsClient = new CDataImporterDataStoreClient(this,
				m_nmServerLocation,m_nmDbName,m_nmUid,m_nmPassword,
				m_nmpServerLocation,m_nmpDbName,m_nmpUid,m_nmpPassword,
				m_nmPort,m_nmpPort
				);

			m_logger.information() << "DATA IMPORTER: Done initializing product data store client for data conversion and import." << endl;
		}
		else
		{
			if(!hasExportDataMirror || !m_spExportDmManager)
				throw Exception(__FUNCTION__ ": No input source");

			if(m_doUpdateSource)
			{
				m_logger.information() << "DATA IMPORTER: Start initializing product data store client for data import only." << endl;

				m_spDsClient = new CDataImporterDataStoreClient(this,
					m_nmServerLocation,m_nmDbName,m_nmUid,m_nmPassword,
					m_nmpServerLocation,m_nmpDbName,m_nmpUid,m_nmpPassword,
					m_nmPort,m_nmpPort);

				m_logger.information() << "DATA IMPORTER: Done initializing product data store client for data import only." << endl;
			}
		}

		if(m_doMirrorData)
		{
			m_spDmManager = new CDataMirrorManager(m_tid + ".import");
		}

		if(!m_importFromMirror)
		{
			m_logger.information() << "DATA IMPORTER: Start iterating product data store" << endl;
			isOk = m_spDsClient->VisitData();
			m_logger.information() << "DATA IMPORTER: Done iterating product data store" << endl;
		}
		else
		{
			m_logger.information() << "DATA IMPORTER: Start iterating export data mirror" << endl;
			isOk = m_spExportDmManager->VisitData();
			m_logger.information() << "DATA IMPORTER: Done iterating export data mirror" << endl;
		}

		m_logger.information() << "Total payment instrument reports: " << m_piReportCount << endl
							   << "Total transformed records: " << m_spDasManager->DataCount() << endl;

		if((m_spDasManager->DataCount() != m_spExportDasManager->DataCount()) ||
			(m_spDasManager->DataHash() != m_spExportDasManager->DataHash()))
		{
			m_logger.information() << "IMPORTANT: IMPORTED DATA DOES NOT MATCH ORIGINAL DATA" << endl;
		}
	}
	catch(Exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " <<  x.displayText() << endl;
	}

	m_spRsaKmClient = NULL;
	m_spDsClient = NULL;
	m_spDmManager = NULL;
	m_spCryptoEngine = NULL;
	m_spDttRecord = NULL;
	m_spDasManager = NULL;

	m_spExportDmManager = NULL;
	m_spExportDasManager = NULL;

	ClearParams();

	return isOk;
}

//////////////////////////////////////////////////////////////

void 
CDataImporter::ClearParams()
{
	m_tid.clear();
	m_dttPassPhrase.clear();
	m_piReportCount = 0;

	m_nmpServerLocation.clear();
	m_nmpDbName.clear();
	m_nmpUid.clear();
	m_nmpPassword.clear();
	m_nmpPort.clear();

	m_nmServerLocation.clear();
	m_nmDbName.clear();
	m_nmUid.clear();
	m_nmPassword.clear();
	m_nmPort.clear();

	m_rsaKmcConfigFileName.clear();
	m_rsaKmcCertPass.clear();
	m_rsaPiNumberKeyClass = "CreditCardNumber";
	m_rsaPiHashKeyClass = "PaymentInstHash";
	m_rsaPassKeyClass = "PasswordHash";

	m_doMirrorData = false;
	m_doUpdateSource = true;
	m_importFromMirror = false;
}

bool 
CDataImporter::GetParams(AutoPtr<AbstractConfiguration> spParams)
{
	bool isOk = false;
	try
	{
		if(!spParams->hasProperty("params.tid"))
			throw Exception("Missing 'tid' parameter");

		m_tid = spParams->getString("params.tid");
		if(!m_spDasManager.isNull())
			m_spDasManager->AddActionParam("tid",m_tid);
		
		m_logger.information() << "DATA IMPORTER: tid = " << m_tid << endl;

		if(!spParams->hasProperty("params.dttPassPhrase"))
			throw Exception("Missing 'dttPassPhrase' parameter");

		m_dttPassPhrase = spParams->getString("params.dttPassPhrase");
		if(m_dttPassPhrase.length() < 12)
			throw Exception("DTT passphrase must be at least 12 characters");

		if(!m_spDasManager.isNull())
			m_spDasManager->AddActionParam("dttPassPhrase","****");

		if(!spParams->hasProperty("params.rsaKmcConfigFileName"))
			throw Exception("Missing 'rsaKmcConfigFileName' parameter");

		m_rsaKmcConfigFileName = spParams->getString("params.rsaKmcConfigFileName");
		
		if(!m_spDasManager.isNull())
			m_spDasManager->AddActionParam("rsaKmcConfigFileName",m_rsaKmcConfigFileName);
		
		m_logger.information() << "DATA IMPORTER: rsaKmcConfigFileName = " << m_rsaKmcConfigFileName << endl;

		if(!spParams->hasProperty("params.rsaKmcCertPass"))
			throw Exception("Missing 'rsaKmcCertPass' parameter");

		m_rsaKmcCertPass = spParams->getString("params.rsaKmcCertPass");
		
		m_rsaPiNumberKeyClass = spParams->getString("params.rsaPiNumberKeyClass","CreditCardNumber");
		m_rsaPiHashKeyClass = spParams->getString("params.rsaPiHashKeyClass","PaymentInstHash");
		m_rsaPassKeyClass = spParams->getString("params.rsaPassKeyClass","PasswordHash");

		if(!m_spDasManager.isNull())
			m_spDasManager->AddActionParam("rsaKmcCertPass","****");

		if(!spParams->hasProperty("params.NetmeterPay.serverLocation"))
			throw Exception("Missing 'NetmeterPay.serverLocation' parameter");

		m_nmpServerLocation = spParams->getString("params.NetmeterPay.serverLocation");
		
		if(!m_spDasManager.isNull())
			m_spDasManager->AddActionParam("NetmeterPay.serverLocation",m_nmpServerLocation);
		
		m_logger.information() << "DATA IMPORTER: NetmeterPay.serverLocation = " << m_nmpServerLocation << endl;

		if(!spParams->hasProperty("params.NetmeterPay.dbName"))
			throw Exception("Missing 'NetmeterPay.dbName' parameter");

		m_nmpDbName = spParams->getString("params.NetmeterPay.dbName");
		
		if(!m_spDasManager.isNull())
			m_spDasManager->AddActionParam("NetmeterPay.dbName",m_nmpDbName);
		
		m_logger.information() << "DATA IMPORTER: NetmeterPay.dbName = " << m_nmpDbName << endl;

		if(!spParams->hasProperty("params.NetmeterPay.uid"))
			throw Exception("Missing 'NetmeterPay.uid' parameter");

		m_nmpUid = spParams->getString("params.NetmeterPay.uid");
		
		if(!m_spDasManager.isNull())
			m_spDasManager->AddActionParam("NetmeterPay.uid",m_nmpUid);
		
		m_logger.information() << "DATA IMPORTER: NetmeterPay.uid = " << m_nmpUid << endl;

		if(!spParams->hasProperty("params.NetmeterPay.password"))
			throw Exception("Missing 'NetmeterPay.password' parameter");

		m_nmpPassword = spParams->getString("params.NetmeterPay.password");
		
		if(!m_spDasManager.isNull())
			m_spDasManager->AddActionParam("NetmeterPay.password","****");

		m_nmpPort = spParams->getString("params.NetmeterPay.port","1433");
		
		if(!m_spDasManager.isNull())
			m_spDasManager->AddActionParam("NetmeterPay.port",m_nmpPort);
		
		m_logger.information() << "DATA IMPORTER: NetmeterPay.port = " << m_nmpPort << endl;

		if(!spParams->hasProperty("params.Netmeter.serverLocation"))
			throw Exception("Missing 'Netmeter.serverLocation' parameter");

		m_nmServerLocation = spParams->getString("params.Netmeter.serverLocation");
		
		if(!m_spDasManager.isNull())
			m_spDasManager->AddActionParam("Netmeter.serverLocation",m_nmServerLocation);
		
		m_logger.information() << "DATA IMPORTER: Netmeter.serverLocation = " << m_nmServerLocation << endl;

		if(!spParams->hasProperty("params.Netmeter.dbName"))
			throw Exception("Missing 'Netmeter.dbName' parameter");

		m_nmDbName = spParams->getString("params.Netmeter.dbName");
		
		if(!m_spDasManager.isNull())
			m_spDasManager->AddActionParam("Netmeter.dbName",m_nmDbName);
		
		m_logger.information() << "DATA IMPORTER: Netmeter.dbName = " << m_nmDbName << endl;

		if(!spParams->hasProperty("params.Netmeter.uid"))
			throw Exception("Missing 'Netmeter.uid' parameter");

		m_nmUid = spParams->getString("params.Netmeter.uid");
		
		if(!m_spDasManager.isNull())
			m_spDasManager->AddActionParam("Netmeter.uid",m_nmUid);
		
		m_logger.information() << "DATA IMPORTER: Netmeter.uid = " << m_nmUid << endl;

		if(!spParams->hasProperty("params.Netmeter.password"))
			throw Exception("Missing 'Netmeter.password' parameter");

		m_nmPassword = spParams->getString("params.Netmeter.password");
		
		if(!m_spDasManager.isNull())
			m_spDasManager->AddActionParam("Netmeter.password","****");

		m_nmPort = spParams->getString("params.Netmeter.port","1433");
		
		if(!m_spDasManager.isNull())
			m_spDasManager->AddActionParam("Netmeter.port",m_nmPort);
		
		m_logger.information() << "DATA IMPORTER: Netmeter.port = " << m_nmPort << endl;

		m_doMirrorData = spParams->getBool("params.mirror",false);
		
		if(!m_spDasManager.isNull())
			m_spDasManager->AddActionParam("mirror",m_doMirrorData);
		
		m_logger.information() << "DATA IMPORTER: mirror = " << (m_doMirrorData ? "true" : "false") << endl;

		m_doUpdateSource = spParams->getBool("params.updateSource",true);
		
		if(!m_spDasManager.isNull())
			m_spDasManager->AddActionParam("updateSource",m_doUpdateSource);
		
		m_logger.information() << "DATA IMPORTER: updateSource = " << (m_doUpdateSource ? "true" : "false") << endl;
		if(!m_doUpdateSource)
		{
			m_logger.information() << "DATA IMPORTER: THE PRODUCT DATABASE WILL NOT BE UPDATED." << endl;
		}

		m_importFromMirror = spParams->getBool("params.fromMirror",false);
		
		if(!m_spDasManager.isNull())
			m_spDasManager->AddActionParam("fromMirror",m_importFromMirror);
		
		m_logger.information() << "DATA IMPORTER: fromMirror = " << (m_importFromMirror ? "true" : "false") << endl;
		if(m_importFromMirror)
		{
			m_logger.information() << "DATA IMPORTER: The import action will be performed from an export mirror (make sure you have the corresponding <x>.export.Dmm.Store file)" << endl;
		}
		else
		{
			m_logger.information() << "DATA IMPORTER: The import action will be performed from the product database (make sure you have the export action stored data in the product database)" << endl;
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
CDataImporter::OnPaymentInstrumentReport(const string& inAccount,
										  const string& inKey,
										  string& outAccount,
										  string& outAccountHash)
{
	bool isOk = true;
	m_piReportCount++;

	if(inAccount.empty() || inKey.empty())
	{
		m_logger.error() << __FUNCTION__ << " : Invalid parameters." << endl;
		return isOk;
	}

	m_logger.trace() << "DATA IMPORTER (PIR): Processing = [" << inKey << "] => " << inAccount << endl;
	
	try
	{
		string decAccount;
		if(m_spCryptoEngine->Decrypt(inAccount,decAccount,true))
		{
		if(!decAccount.empty())
		{
			string nativeAccount;
			if(m_spRsaKmClient->EncryptCcNumber(decAccount,nativeAccount))
			{
				string hash;
				if(!m_spRsaKmClient->HashCcNumber(decAccount,hash) || hash.empty())
					throw Exception(string(__FUNCTION__ " : Could not calculate hash"));

				if(m_doMirrorData && m_spDmManager)
				{
					m_spDmManager->AddData(nativeAccount,hash,inAccount,inKey);
				}

				if(m_doUpdateSource)
				{
					if(!m_importFromMirror)
					{
						outAccount = nativeAccount;
						outAccountHash = hash;
					}
					else
					{
						m_spDsClient->UpdatePaymentInstrument(inKey,outAccount,outAccountHash);
					}
				}

				m_spDasManager->UpdateState(inKey,decAccount);
				isOk = true;
			}
			else
			{
				m_logger.warning() << __FUNCTION__ << " : Report processing error 1" << endl;
			}

			const char* pInfo = decAccount.data();
			size_t infoSize = decAccount.size();
			if((NULL != pInfo) && (0 != infoSize))
				SecureZeroMemory((void*)pInfo,infoSize);
		}
		else
		{
			m_logger.warning() << __FUNCTION__ << " : Report processing error 2" << endl;
		}
		}
		else
		{
			m_logger.warning() << __FUNCTION__ << " : Report processing error 3" << endl;
		}
	}
	catch(Exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " <<  x.displayText() << endl;
	}

	return isOk;
}

bool 
CDataImporter::OnPaymentInstrumentError(const string& inErrorInfo,bool& outIgnore)
{
	m_logger.warning() << __FUNCTION__ << " : " << "PaymentInstrument error: " << inErrorInfo << endl;
	outIgnore = true;
	return true;
}

///////////////////////////////////////////////////////////////////////////////

bool 
CDataImporter::OnDataReport(const string& inNewData,
							const string& inNewDataHash,
							const string& inOrigData,
							const string& inOrigDataKey)
{
	bool isOk = true;
	m_piReportCount++;

	if(inNewData.empty() || inOrigData.empty() || inOrigDataKey.empty())
	{
		m_logger.error() << __FUNCTION__ << " : Invalid parameters." << endl;
		return isOk;
	}

	m_logger.trace() << "DATA IMPORTER (DR): Processing = [" << inOrigDataKey << "] => " << inNewData << endl;

	try
	{
		string decAccount;
		if(m_spCryptoEngine->Decrypt(inNewData,decAccount,true))
		{
			if(!decAccount.empty())
			{
				string nativeAccount;
				if(m_spRsaKmClient->EncryptCcNumber(decAccount,nativeAccount))
				{
					string hash;
					if(!m_spRsaKmClient->HashCcNumber(decAccount,hash) || hash.empty())
						throw Exception(__FUNCTION__ ": Could not calculate hash");

					if(m_doMirrorData && m_spDmManager)
					{
						m_spDmManager->AddData(nativeAccount,hash,inNewData,inOrigDataKey);
					}

					if(m_doUpdateSource && m_importFromMirror && !m_spDsClient.isNull())
					{
						m_spDsClient->UpdatePaymentInstrument(inOrigDataKey,nativeAccount,hash);
					}

					m_spDasManager->UpdateState(inOrigDataKey,decAccount);
					isOk = true;
				}
				else
				{
					m_logger.warning() << __FUNCTION__ << " : Report processing error 1" << endl;
				}

				const char* pInfo = decAccount.data();
				size_t infoSize = decAccount.size();
				if((NULL != pInfo) && (0 != infoSize))
					SecureZeroMemory((void*)pInfo,infoSize);
			}
			else
			{
				m_logger.warning() << __FUNCTION__ << " : Report processing error 2" << endl;
			}
		}
		else
		{
			m_logger.warning() << __FUNCTION__ << " : Report processing error 3" << endl;
		}
	}
	catch(Exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " <<  x.displayText() << endl;
	}

	return isOk;
}

bool 
CDataImporter::OnDataError(const string& inErrorInfo,bool& outIgnore)
{
	m_logger.warning() << __FUNCTION__ << " : " << "Mirror data record error: " << inErrorInfo << endl;
	outIgnore = true;
	return true;
}
