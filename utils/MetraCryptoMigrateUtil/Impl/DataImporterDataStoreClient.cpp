
#include "DataImporterDataStoreClient.h"

//todo: need to refactor the cut and paste code from DataExporterDataStoreClient!!!

///////////////////////////////////////////////////////////////////////////////

struct SPaymentInstrument
{
	string tx_hash; //that's all we care really
	string nm_truncd_acct_num;
	int id_creditcard_type;
	string nm_exp_date;
	int nm_exp_date_format;

	string nm_first_name;
	string nm_middle_name;
	string nm_last_name;

	string nm_address1;
	string nm_address2;
	string nm_city;
	string nm_state;
	string nm_zip;
	int id_country;
};

struct SPsPaymentInstrument
{
	string nm_account_number; //that's all we care

	string nm_first_name;
	string nm_middle_name;
	string nm_last_name;

	string nm_address1;
	string nm_address2;
	string nm_city;
	string nm_state;
	string nm_zip;
	int id_country;
};

///////////////////////////////////////////////////////////////////////////////


CDataImporterDataStoreClient::CDataImporterDataStoreClient(CDataImporterDataStoreSubscriber* pSubscriber,
									const string& serverLocation,
									const string& dbName,
									const string& uid,
									const string& password,
									const string& port)
:CDataStoreClient(serverLocation,dbName,uid,password,port),
 m_pSubscriber(pSubscriber),
 m_useNmpDsClient(false)
{
}

CDataImporterDataStoreClient::CDataImporterDataStoreClient(CDataImporterDataStoreSubscriber* pSubscriber,
		             const string& nmServerLocation,
		             const string& nmDbName,
					 const string& nmUid,
					 const string& nmPassword,
					 const string& nmpServerLocation,
		             const string& nmpDbName,
					 const string& nmpUid,
					 const string& nmpPassword,
					 const string& nmPort,
					 const string& nmpPort)
:CDataStoreClient(nmServerLocation,nmDbName,nmUid,nmPassword,nmPort),
 m_pSubscriber(pSubscriber)
{
	m_spNmpDataStoreClient = new CDataStoreClient(nmpServerLocation,nmpDbName,nmpUid,nmpPassword,nmpPort);
	if(m_spNmpDataStoreClient->DataSession().isNull())
		throw Exception(__FUNCTION__ ": Could not initialize NMP data store client");

	m_useNmpDsClient = true;
}

CDataImporterDataStoreClient::~CDataImporterDataStoreClient()
{
}

bool
CDataImporterDataStoreClient::UpdatePaymentInstrument(const string& recordKey,
													  const string& aNumber,
													  const string& aNumberHash)
{
	bool isOk = false;
	if(recordKey.empty() || aNumber.empty() || aNumberHash.empty())
	{
		m_logger.trace() << __FUNCTION__ << ": Invalid parameters." << endl;
		return isOk;
	}

	try
	{
		if(m_useNmpDsClient)
		{
			if(m_spNmpDataStoreClient.isNull() || m_spNmpDataStoreClient->DataSession().isNull())
				throw Exception("No NMP data store client");

			m_logger.trace() << "PIU[1]: UPDATE t_ps_payment_instrument SET nm_account_number="
							 << aNumber 
							 << " WHERE id_payment_instrument="
							 << recordKey
							 << endl;

			Statement update1(*(m_spNmpDataStoreClient->DataSession()));
			update1 << "UPDATE t_ps_payment_instrument SET nm_account_number=? WHERE id_payment_instrument=CAST(? AS nvarchar(72))",
				use(aNumber),
				use(recordKey);

			update1.execute();
		}
		else
		{
			m_logger.trace() << "PIU[2]: UPDATE t_ps_payment_instrument SET nm_account_number="
							 << aNumber 
							 << " WHERE id_payment_instrument="
							 << recordKey
							 << endl;

			Statement update1(*m_spStoreSession);
			update1 << "UPDATE t_ps_payment_instrument SET nm_account_number=? WHERE id_payment_instrument=CAST(? AS nvarchar(72))",
				use(aNumber),
				use(recordKey);

			update1.execute();
		}

		m_logger.trace() << "PIUH[2]: UPDATE t_payment_instrument SET tx_hash="
							 << aNumberHash 
							 << " WHERE id_payment_instrument="
							 << recordKey
							 << endl;

		Statement update2(*m_spStoreSession);
		update2 << "UPDATE t_payment_instrument SET tx_hash=? WHERE id_payment_instrument=CAST(? AS nvarchar(72))",
			use(aNumberHash),
			use(recordKey);
		
		update2.execute();

		isOk = true;
	}
	catch(StatementException& x)
	{ 
		m_logger.error() << __FUNCTION__ << " : " << x.toString() << endl; 

		const StatementDiagnostics::FieldVec& fields = x.diagnostics().fields();
		StatementDiagnostics::Iterator it = fields.begin();
		for (; it != fields.end(); ++it)
		{
			if (3701 == it->_nativeError)
			{
				m_logger.error() << __FUNCTION__ << " : " << "Table doesnt exist" << endl;
			}
			else
			{
				m_logger.error() << __FUNCTION__ << " : " << " : Native DB Error: " << it->_nativeError << endl;
			}
		}

		throw;
	}
	catch(Exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " <<  x.displayText() << endl;
		throw;
	}
	return isOk;
}

bool 
CDataImporterDataStoreClient::VisitData()
{
	bool isOk = false;
	try
	{
		if(NULL != m_pSubscriber)
		{
			string aNumber;
			string recordKey;

			if(m_useNmpDsClient)
			{
				if(m_spNmpDataStoreClient.isNull() || m_spNmpDataStoreClient->DataSession().isNull())
					throw Exception("No NMP data store client");

				Statement select(*(m_spNmpDataStoreClient->DataSession()));
				select << "SELECT id_payment_instrument, nm_account_number FROM t_ps_payment_instrument",
					into(recordKey),
					into(aNumber),
					range(0, 1); 

				while (!select.done())
				{
					select.execute();

					string aNewNumber;
					string aNewNumberHash;
					if(m_pSubscriber->OnPaymentInstrumentReport(aNumber,recordKey,aNewNumber,aNewNumberHash))
					{
						if(!aNewNumber.empty() && !aNewNumberHash.empty())
						{
							UpdatePaymentInstrument(recordKey,aNewNumber,aNewNumberHash);
						}
					}
				}
			}
			else
			{
				Statement select(*m_spStoreSession);
				select << "SELECT id_payment_instrument, nm_account_number FROM t_ps_payment_instrument",
					into(recordKey),
					into(aNumber),
					range(0, 1); 

				while (!select.done())
				{
					select.execute();

					string aNewNumber;
					string aNewNumberHash;
					if(m_pSubscriber->OnPaymentInstrumentReport(aNumber,recordKey,aNewNumber,aNewNumberHash))
					{
						if(!aNewNumber.empty() && !aNewNumberHash.empty())
						{
							UpdatePaymentInstrument(recordKey,aNewNumber,aNewNumberHash);
						}
					}
				}
			}
		}
		isOk = true;
	}
	catch(StatementException& x)
	{ 
		m_logger.error() << __FUNCTION__ << " : " << x.toString() << endl; 

		const StatementDiagnostics::FieldVec& fields = x.diagnostics().fields();
		StatementDiagnostics::Iterator it = fields.begin();
		for (; it != fields.end(); ++it)
		{
			if (3701 == it->_nativeError)
			{
				m_logger.error() << __FUNCTION__ << " : " << "Table doesnt exist" << endl;
			}
			else
			{
				m_logger.error() << __FUNCTION__ << " : " << " : Native DB Error: " << it->_nativeError << endl;
			}
		}

		throw;
	}
	catch(Exception& x)
	{
		m_logger.error() << __FUNCTION__ << " : " <<  x.displayText() << endl;
		throw;
	}

	return isOk;
}


