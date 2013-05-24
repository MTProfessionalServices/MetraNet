
#include "DataExporterDataStoreClient.h"


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


CDataExporterDataStoreClient::CDataExporterDataStoreClient(CDataExporterDataStoreSubscriber* pSubscriber,
									const string& serverLocation,
									const string& dbName,
									const string& uid,
									const string& password,
									const string& port)
:CDataStoreClient(serverLocation,dbName,uid,password,port),
 m_pSubscriber(pSubscriber)
{
}

CDataExporterDataStoreClient::~CDataExporterDataStoreClient()
{
}

bool
CDataExporterDataStoreClient::UpdatePaymentInstrument(const string& recordKey,const string& aNumber)
{
	bool isOk = false;
	try
	{
		Statement update1(*m_spStoreSession);
		update1 << "UPDATE t_ps_payment_instrument SET nm_account_number=? WHERE id_payment_instrument=CAST(? AS nvarchar(72))",
			use(aNumber),
			use(recordKey);
		
		update1.execute();

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
				m_logger.warning() << __FUNCTION__ << " : " << " : Native DB Error: " << it->_nativeError << endl;
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
CDataExporterDataStoreClient::VisitPaymentInstruments()
{
	bool isOk = false;
	try
	{
		if(NULL != m_pSubscriber)
		{
			string aNumber;
			string recordKey;
			Statement select(*m_spStoreSession);
			select << "SELECT id_payment_instrument, nm_account_number FROM t_ps_payment_instrument",
				into(recordKey),
				into(aNumber),
				range(0, 1); 

			while (!select.done())
			{
				select.execute();

				string aNewNumber;
				if(m_pSubscriber->OnPaymentInstrumentReport(aNumber,recordKey,aNewNumber))
				{
					if(!aNewNumber.empty())
					{
						UpdatePaymentInstrument(recordKey,aNewNumber);
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


