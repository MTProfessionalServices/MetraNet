
#include "DataExporter.h"


CDataExporter::CDataExporter()
:m_piReportCount(0)
{
	m_name = "ExportData";
	m_description = "Converts the encrypted database data into its export format";
	m_rsaPiNumberKeyClass = "CreditCardNumber";
	m_rsaPiHashKeyClass = "PaymentInstHash";
	m_rsaPassKeyClass = "PasswordHash";
}

CDataExporter::~CDataExporter()
{
}

void 
CDataExporter::ClearParams()
{
	m_tid.clear();
	m_dttPassPhrase.clear();
	m_piReportCount = 0;
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

	m_doMirrorData = false;
	m_doUpdateSource = true;
}

bool 
CDataExporter::GetParams(AutoPtr<AbstractConfiguration> spParams)
{
	bool isOk = false;

	m_logger.trace() << "Processing data export parameters..." << endl;

	try
	{
		if(!spParams->hasProperty("params.tid"))
			throw Exception("Missing parameter");

		m_tid = spParams->getString("params.tid");

		if(!spParams->hasProperty("params.dttPassPhrase"))
			throw Exception("Missing parameter");

		m_dttPassPhrase = spParams->getString("params.dttPassPhrase");

		if(m_dttPassPhrase.length() < 12)
			throw Exception("DTT passphrase must be at least 12 characters");

		if(!spParams->hasProperty("params.rsaKmcConfigFileName"))
			throw Exception("Missing parameter");

		m_rsaKmcConfigFileName = spParams->getString("params.rsaKmcConfigFileName");

		if(!spParams->hasProperty("params.rsaKmcCertPass"))
			throw Exception("Missing parameter");

		m_rsaKmcCertPass = spParams->getString("params.rsaKmcCertPass");

		m_rsaPiNumberKeyClass = spParams->getString("params.rsaPiNumberKeyClass","CreditCardNumber");
		m_rsaPiHashKeyClass = spParams->getString("params.rsaPiHashKeyClass","PaymentInstHash");
		m_rsaPassKeyClass = spParams->getString("params.rsaPassKeyClass","PasswordHash");

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
		m_doMirrorData = spParams->getBool("params.mirror",false);
		m_doUpdateSource = spParams->getBool("params.updateSource",true);

		isOk = true;

		m_logger.trace() << "Done processing data export parameters..." << endl;
	}
	catch(Exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " <<  x.displayText() << endl;
	}
	return isOk;
}

//////////////////////////////////////////////////////////////

bool 
CDataExporter::Execute(AutoPtr<AbstractConfiguration> spParams)
{
	bool isOk = false;

	if(spParams.isNull())
		return isOk;

	m_logger.trace() << "Starting data export..." << endl;

	try
	{
		ClearParams();
		if(!GetParams(spParams))
			throw Exception("Bad parameters");

		m_logger.trace() << "Initializing Data Transform Transaction... " << endl;

		m_spDttRecord = new CDataTransformTransaction(m_tid);

		if(!m_spDttRecord->SetPassPhrase(m_dttPassPhrase))
			throw Exception("Could setup DTT");

		m_logger.trace() << "Initializing Crypto Engine... " << endl;

		m_spCryptoEngine = new CCryptoEngine();
		m_spCryptoEngine->GenerateKey();
		
		string kv;
		string kiv;
		
		if(!m_spCryptoEngine->GetKeyAsHexString(kv,kiv))
			throw Exception("CE error");

		if(!m_spDttRecord->SetDataKey(m_tid,kv,kiv))
			throw Exception("Could not configure DTT");

		kv.clear();
		kiv.clear();

		m_spDttRecord->SetTransformedSource(m_doUpdateSource);

		m_logger.trace() << "Initializing RSA Key Manager Client... " << endl;

		m_spRsaKmClient = new CRsaKeyManagerClient(m_rsaKmcConfigFileName,
			m_rsaKmcCertPass,m_rsaPiNumberKeyClass,m_rsaPiHashKeyClass,m_rsaPassKeyClass);

		m_logger.trace() << "Initializing Data Exporter Data Store Client... " << endl;

		m_spDsClient = new CDataExporterDataStoreClient(this,m_serverLocation,m_dbName,m_uid,m_password,m_port);

		m_logger.trace() << "Configuring Data Transform Transaction... " << endl;

		m_spDttRecord->SetDataMirror(m_doMirrorData);
		if(m_doMirrorData)
		{
			m_spDmManager = new CDataMirrorManager(m_tid + ".export");
			m_spDttRecord->SetDataMirrorFileName(m_spDmManager->Name());
		}

		m_spDasManager = new CDataActionStateManager(m_tid + ".export");

		m_logger.trace() << "Processing Data..." << endl;

		isOk = m_spDsClient->VisitPaymentInstruments();

		m_logger.trace() << "Saving Data Transform Transaction..." << endl;

		m_spDttRecord->SetDataCount(m_spDasManager->DataCount());
		m_spDttRecord->SetDataHash(m_spDasManager->DataHash());

		if(!m_spDttRecord->Save())
		{
			m_logger.warning() << __FUNCTION__ << " : " << "Could not save DTT" << endl;
		}

		m_logger.information() << "Total payment instrument reports: " << m_piReportCount << endl
		                       << "Total transformed records: " << m_spDasManager->DataCount() << endl;
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
	ClearParams();

	return isOk;
}

bool 
CDataExporter::OnPaymentInstrumentReport(const string& inAccount,
										const string& inKey,
										string& outAccount)
{
	bool isOk = true;
	m_piReportCount++;

	if(inAccount.empty() || inKey.empty())
		return isOk;

	string decAccount;
	if(m_spRsaKmClient->DecryptCcNumber(inAccount,decAccount))
	{
		if(!decAccount.empty())
		{
			if(m_spCryptoEngine)
			{
				string safeAccount;
				if(m_spCryptoEngine->Encrypt(decAccount,safeAccount,true))
				{
					if(m_doMirrorData && m_spDmManager)
					{
						m_spDmManager->AddData(safeAccount,"",inAccount,inKey);
					}

					if(m_doUpdateSource)
					{
						outAccount = safeAccount;
					}

					m_spDasManager->UpdateState(inKey,decAccount);
					isOk = true;
				}
				else
				{
					m_logger.warning() << __FUNCTION__ << " : Report processing error 1" << endl;
				}
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

	return isOk;
}

bool 
CDataExporter::OnPaymentInstrumentError(const string& inErrorInfo,bool& outIgnore)
{
	m_logger.warning() << __FUNCTION__ << " : PaymentInstrument error: " << inErrorInfo << endl;
	outIgnore = true;
	return true;
}

