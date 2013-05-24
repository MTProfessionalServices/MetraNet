/**************************************************************************
 * DBPARSER
 *
 * Copyright 1997-2004 by MetraTech Corp.
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: 
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/


#include <dbparser.h>


#import <MTConfigLib.tlb>

#include <pipelineconfig.h>
#include "MTSessionServerBaseDef.h"

#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.Security.Crypto.tlb> inject_statement("using namespace mscorlib;")

typedef MTautoptr<COdbcStatement> COdbcStatementPtr;
/********************************************** PipelineDateTime ***/

void PipelineDateTime::SetToNow()
{
	SetToTimet(GetMTTime());
}

// this come from
// http://support.microsoft.com/default.aspx?scid=kb;en-us;167296

inline __int64 UnixTimeToFileTime(time_t t)
{
	__int64 ll;

	ll = t*10000000LL + 116444736000000000LL;
	return ll;
}

inline time_t FileTimeToUnixTime(__int64 t)
{
	return ((t - 116444736000000000LL) / 10000000LL);
}

void PipelineDateTime::SetToTimet(time_t unixtime)
{
	mTimeValue = UnixTimeToFileTime(unixtime);
}

void PipelineDateTime::SetToOleDate(DATE oletime)
{
	// triple conversion.. oh well
	time_t unixTime;
	TimetFromOleDate(&unixTime, oletime);
	SetToTimet(unixTime);
}

PipelineDateTime PipelineDateTime::GetMax()
{
	return PipelineDateTime(UnixTimeToFileTime(getMaxDate()));
}

PipelineDateTime PipelineDateTime::GetMin()
{
	return PipelineDateTime(UnixTimeToFileTime(getMinDate()));
}

time_t PipelineDateTime::GetAsTimet() const
{
	return FileTimeToUnixTime(mTimeValue);
}

DATE PipelineDateTime::GetAsOleDate() const
{
	DATE oleDate;
	OleDateFromTimet(&oleDate, GetAsTimet());
	return oleDate;
}

string PipelineDateTime::GetAsString() const
{
	string buffer;
	MTFormatISOTime(GetAsTimet(), buffer);
	return buffer;
}




class SharedSessionFactoryWrapper : public ObjectWithError
{
private:
  SharedSessionHeader * mpHeader;
  CMTSessionServerBase * mpSessServer;
public:
  SharedSessionFactoryWrapper(const PipelineInfo & arInfo);
  ~SharedSessionFactoryWrapper();
  SharedSessionWrapper * CreateSession(const unsigned char * uid, const unsigned char * parentUid, int serviceID);
};

SharedSessionFactoryWrapper::SharedSessionFactoryWrapper(const PipelineInfo & arInfo)
  :
  mpHeader(NULL),
  mpSessServer(NULL)
{
	std::string filename;
	std::string sharename;
	
	filename = arInfo.GetSharedSessionFile();
	sharename = arInfo.GetShareName();

	_bstr_t filenameBstr(filename.c_str());
	_bstr_t sharenameBstr(sharename.c_str());

	int totalSize = arInfo.GetSharedFileSize();

  // Get the singleton instance of the session server by creating a base
  // object and then snarfing its underlying shared memory header.
  mpSessServer = CMTSessionServerBase::CreateInstance();
  mpSessServer->Init(filenameBstr, sharenameBstr, totalSize);
  mpHeader = mpSessServer->GetSharedHeader();
}

SharedSessionFactoryWrapper::~SharedSessionFactoryWrapper()
{
  if(mpSessServer != NULL)
  {
    mpSessServer->Release();
    mpSessServer = NULL;
  }
}

SharedSessionWrapper * SharedSessionFactoryWrapper::CreateSession(const unsigned char * uid, 
                                                                  const unsigned char * parentUid, 
                                                                  int serviceId)
{
	const char * functionName = "SharedSessionFactoryWrapper::CreateSession";

	ASSERT(mpHeader);

 	// session is created with a reference count of 1

	long id;											// not used
	SharedSession * sess = SharedSession::Create(mpHeader, 
                                               id, 
                                               (const unsigned char *) uid, 
                                               parentUid ? (const unsigned char *) parentUid : NULL);
	if (!sess)
	{		
		// this call can fail for only two reasons - out of shared memory or
		// duplicate session.  look for a dup if it fails.n

		long dupID;
		SharedSession * duplicate = SharedSession::FindWithUID(mpHeader, dupID, (const unsigned char *) uid);
		if (duplicate && dupID != -1)
		{
      // TODO: Do we need to decrease reference count on duplicate?
			// object already exists
			SetError(PIPE_ERR_DUPLICATE_SESSION, ERROR_MODULE, ERROR_LINE,
							 functionName, "Duplicate session");
			return NULL;
		}

		SetError(PIPE_ERR_SHARED_OBJECT_FAILURE, ERROR_MODULE, ERROR_LINE,
             functionName, "Unknown shared object failure");
		return NULL;
	}


	ASSERT(sess->UIDEquals((const unsigned char *) uid));

	// Create() above set the parent ID
	sess->SetServiceID(serviceId);

	// the shared object was created with a reference count of 1.
	return new SharedSessionWrapper(sess, mpHeader, id);
}







// forces any template compiler issues with SDKSessionWrapper
class TestSDKSessionWrapper
{
	TestSDKSessionWrapper()
	{
		DBParserService<SDKSessionWrapper, std::string> serviceDef;
	}
};





/********************************* SharedSession parser session wrapper ****/
DBParserServiceSharedSession::DBParserServiceSharedSession()
{
}

DBParserServiceSharedSession::~DBParserServiceSharedSession()
{
 // DBParserService<SharedSessionWrapper, int>::~DBParserService();
}


/******************************************** sharedsession parser methods ***/
bool DBParserSharedSession::Init(const PipelineInfo & pipelineInfo, 
                                 MTPipelineLib::IMTSessionServerPtr comSessionServer)
{
	const char * functionName = "DBParserSharedSession::Init";

	MTENUMCONFIGLib::IEnumConfigPtr enumConfig(MTPROGID_ENUM_CONFIG);

  mCOMSessionServer = comSessionServer;
  mSessionServer = new SharedSessionFactoryWrapper(pipelineInfo);

	// collection of service defs
	CServicesCollection services;
	if (!services.Initialize())
	{
		// TODO: make sure mServices returns a good error in all cases
		const ErrorObject * err = services.GetLastError();
		ASSERT(err);
		if (err)
			SetError(err);
		else
			SetError(MT_ERR_SERVER_ERROR, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	// initializes crypto
	int result = mCrypto.Initialize(MetraTech_Security_Crypto::CryptKeyClass_ServiceDefProp, "metratechpipeline", TRUE, "pipeline");
	if (result != 0)
	{
		SetError(CORE_ERR_CRYPTO_FAILURE, ERROR_MODULE, ERROR_LINE, functionName);
		return FALSE;
	}

	MSIXDefCollection::MSIXDefinitionList::iterator it;
	for (it = services.GetDefList().begin(); it != services.GetDefList().end();
			 ++it)
	{
		CMSIXDefinition* pDef = *it;

		int serviceID = pDef->GetID(); //SessionServer::GetNameID(ascii(pDef->GetName()));

#ifdef DEBUG
		map<int, DBParserServiceSharedSession>::iterator it = mServiceDefMap.find(serviceID);
		if (it != mServiceDefMap.end())
			ASSERT(0);
#endif // DEBUG

		DBParserServiceSharedSession & parserdef = mServiceDefMap[serviceID];
		parserdef.Init(pDef, enumConfig, mCrypto, true);
	}

	mQueryAdapter.CreateInstance(MTPROGID_QUERYADAPTER);
	mQueryAdapter->Init("\\Queries\\Pipeline");

	return true;
}

bool DBParserSharedSession::Parse(COdbcConnectionPtr conn,
                                  int messageID,
                                  int serviceID,
                                  map<vector<unsigned char>, SharedSessionWrapper *> & sharedSessions,
                                  map<vector<unsigned char>, vector<unsigned char> > & parentChildRelationships,
																	ValidationData& parsedData)
{
	const char * functionName = "DBParserSharedSesion::Parse";

  // Get the service object
	map<int, DBParserServiceSharedSession>::const_iterator it;
	it = mServiceDefMap.find(serviceID);
	if (it == mServiceDefMap.end())
	{
		char buffer[256];
		sprintf(buffer, "Service definition for service %d not found", serviceID);
									
		SetError(MT_ERR_SERVER_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 buffer);
		return false;
	}
	DBParserServiceSharedSession * service = &mServiceDefMap[serviceID];

	const string & serviceColumns = service->GetColumnNames();
	string serviceTable = service->GetTableName();

	char buffer[20];
	sprintf(buffer, "%d", messageID);
	string strMessageID = buffer;

	mQueryAdapter->SetQueryTag("__RETRIEVE_MESSAGE_DATA__");
	mQueryAdapter->AddParam("%%SVC_COLUMNS%%", serviceColumns.c_str());
	mQueryAdapter->AddParam("%%SVC_TABLE%%",   serviceTable.c_str());
	mQueryAdapter->AddParam("%%ID_MESSAGE%%",  strMessageID.c_str());

	COdbcStatementPtr stmt = conn->CreateStatement();
	COdbcResultSetPtr resultSet;
	resultSet = stmt->ExecuteQueryW((const wchar_t *) mQueryAdapter->GetQuery());

  int sessionSetIDIndex = PipelinePropIDs::SessionSetIDCode();
	int meteredTimestampIndex = PipelinePropIDs::MeteredTimestampCode();
	int timestampIndex = PipelinePropIDs::TimestampCode();
	int serviceIDIndex = PipelinePropIDs::ServiceIDCode();
	int productViewIDIndex = PipelinePropIDs::ProductViewIDCode();
	int ipAddressIndex = PipelinePropIDs::IPAddressCode();
	int batchIDIndex = PipelinePropIDs::CollectionIDCode();
  int externalIDIndex = PipelinePropIDs::ExternalSessionIDCode();

	bool firstTime = true;
	while (resultSet->Next())
	{
		// first columns are special:
		// s.id_ss, s.id_sess, svc.id_parent_sess, svc.id_external, ...
		// 1         2           3                        4          
		// m.dt_metered, m.tx_transaction_id,  m.tx_sc ... , s.id_batch, m.ip_address
		// 5                  6                7-10             11         12
		//
		// the rest of the columns at the service def columns

    int id_ss = resultSet->GetInteger(1);

    std::vector<unsigned char> sessionUID = resultSet->GetBinary(2);
    ASSERT(sessionUID.size() == UID_LENGTH);

    std::vector<unsigned char> parentUID = resultSet->GetBinary(3);
    ASSERT(parentUID.size() == (resultSet->WasNull() ? 0 : UID_LENGTH));
		if (!resultSet->WasNull())
      parentChildRelationships[sessionUID] = parentUID;

    std::vector<unsigned char> externalUID = resultSet->GetBinary(4);
    ASSERT(externalUID.size() == (resultSet->WasNull() ? 0 : UID_LENGTH));

		PipelineDateTime dt_metered;
		COdbcTimestamp dt_metered_odbc = resultSet->GetTimestamp(5);
		time_t dt_metered_timet;
		OdbcTimestampToTimet(dt_metered_odbc.GetBuffer(), &dt_metered_timet);
		dt_metered.SetToTimet(dt_metered_timet);

		// only set message level properties once
		// TODO: above query doesn't need to return t_message data for every session, probably not a big deal though
		if (firstTime)
		{
			std::string transactionID = resultSet->GetString(6);
			if (!resultSet->WasNull())
				strncpy(parsedData.mTransactionID, transactionID.c_str(), transactionID.length()+1);

			std::string contextUsername = resultSet->GetString(7);
			if (!resultSet->WasNull())
				strncpy(parsedData.mContextUsername, contextUsername.c_str(), contextUsername.length()+1);

			std::string contextPassword = resultSet->GetString(8);
			if (!resultSet->WasNull())
			{
				if (mCrypto.Decrypt(contextPassword) != 0)
				{
					SetError(CORE_ERR_CRYPTO_FAILURE, ERROR_MODULE, ERROR_LINE, functionName, "Failed decrypting context password!");
					return false;
				}
				strncpy(parsedData.mContextPassword, contextPassword.c_str(), contextPassword.length()+1);
			}

			std::string contextNamespace = resultSet->GetString(9);
			if (!resultSet->WasNull())
				strncpy(parsedData.mContextNamespace, contextNamespace.c_str(), contextNamespace.length()+1);

			std::string serializedContext = resultSet->GetString(10);
			if (!resultSet->WasNull())
			{
				if (mCrypto.Decrypt(serializedContext) != 0)
				{
					SetError(CORE_ERR_CRYPTO_FAILURE, ERROR_MODULE, ERROR_LINE, functionName, "Failed decrypting serialized context!");
					return false;
				}

				parsedData.mpSessionContext = new char[serializedContext.length() + 1];
				strncpy(parsedData.mpSessionContext, serializedContext.c_str(), serializedContext.length()+1);
			}

			firstTime = false;
		}

    std::vector<unsigned char> batchUID = resultSet->GetBinary(11);
    ASSERT(batchUID.size() == (resultSet->WasNull() ? 0 : 16));

		SharedSessionWrapper * session = mSessionServer->CreateSession(&sessionUID[0], NULL, service->GetServiceID());
    if (session == NULL)
    {
      SetError(*mSessionServer);
      return false;
    }
		session->SetInt32Value(sessionSetIDIndex, id_ss);
		session->SetDateTimeValue(meteredTimestampIndex, dt_metered);
		session->SetDateTimeValue(timestampIndex, dt_metered);
		session->SetInt32Value(serviceIDIndex, serviceID);
		session->SetInt32Value(productViewIDIndex, serviceID);

		std::string ipAddress = resultSet->GetString(12);
		session->SetStringValue(ipAddressIndex, (const wchar_t *) _bstr_t(ipAddress.c_str()));


    if(batchUID.size() > 0)
    {
      std::string batchUIDEncoded;
      MSIXUidGenerator::Encode(batchUIDEncoded, &batchUID[0]);

      std::wstring batchUIDEncodedWide;
      ASCIIToWide(batchUIDEncodedWide, batchUIDEncoded);

      session->SetStringValue(batchIDIndex, batchUIDEncodedWide);
    }

		if (externalUID.size() > 0)
		{
			// sets the client-based session UID in session
			// NOTE: this is needed for feedback generation later
			string base64ExternalUID;
			MSIXUidGenerator::Encode(base64ExternalUID, &externalUID[0]);
			session->SetStringValue(externalIDIndex, (const wchar_t *) _bstr_t(base64ExternalUID.c_str()));
		}

		// read service def properties
		service->Read(resultSet, session, 13);

    // Save in map
		sharedSessions[sessionUID] = session;
	}

	return true;
}

class SharedSessionMap : public  map<vector<unsigned char>, SharedSessionWrapper *>
{
public:
  ~SharedSessionMap();
};

SharedSessionMap::~SharedSessionMap()
{
  for (map<vector<unsigned char>, SharedSessionWrapper*>::iterator mapIt = this->begin(); 
       mapIt != this->end(); 
       mapIt++)
  {
    delete mapIt->second;
  }
}

bool DBParserSharedSession::Parse(int messageID,
                                  vector<int>& serviceIdsForMessage,
                                  unsigned char * batchUID,
                                  vector<MTPipelineLib::IMTSessionPtr> & sessions,
                                  ValidationData& parsedData)
{
	const char * functionName = "SessionRouter::ParseDBSessions";

	try
	{
		//string uid;
		//MSIXUidGenerator::Generate(uid);
		//MSIXUidGenerator::Decode(batchUID, uid);

		// clears optional message-level properties
		parsedData.mTransactionID[0] = '\0';
		parsedData.mContextUsername[0] = '\0';
		parsedData.mContextPassword[0] = '\0';
		parsedData.mContextNamespace[0] = '\0';
		parsedData.mpSessionContext = 0;


		COdbcConnectionInfo info = COdbcConnectionManager::GetConnectionInfo("NetMeter");
		COdbcConnectionPtr conn = new COdbcConnection(info);


		// TODO: reduce amount of copies with map key and values
    // Map binary session UID to session object
    SharedSessionMap sharedSessions;
    // Associate a child's binary session UID with its parent's binary UID
    map<vector<unsigned char>, vector<unsigned char> > parentChildRelationships;

		vector<int>::iterator it;
		//TODO: should we iterate here or should we push the vector down to
		//DBParser::Parse method? Probably doesn't make much difference
		for(it = serviceIdsForMessage.begin(); it != serviceIdsForMessage.end(); ++it)
		{
			int serviceID = (int)(*it);

			if (!Parse(conn, messageID, serviceID, sharedSessions, parentChildRelationships, parsedData))
			{
				return false;
			}
		}

    // Post process to set parent/child relationships
    for(map<vector<unsigned char>, vector<unsigned char> >::iterator parentIt = parentChildRelationships.begin();
        parentChildRelationships.end() != parentIt;
        parentIt++)
    {
      SharedSessionWrapper * child = sharedSessions[parentIt->first];
      if(child == NULL)
      {
        // This should really NEVER happen.
        char buf[1024];
        std::string childUIDEncoded;
        MSIXUidGenerator::Encode(childUIDEncoded, &(parentIt->first[0]));
        sprintf(buf, "Failure routing child session with id = %s",
                childUIDEncoded.c_str()); 
        SetError(MT_ERR_SERVER_ERROR, ERROR_MODULE, ERROR_LINE, functionName, buf);
        return FALSE;
      }
      SharedSessionWrapper * parent = sharedSessions[parentIt->second];
      if(parent == NULL)
      {
        // This can happen if there is a bug in a metering client.  I also think that this can happen in some
        // wacky scenarios involving shared memory leaks and auto-resubmit in the pipeline.  In these cases
        // a child session with a parent pointer is leaked.  Later a new parent is metered and gets the same
        // pointer as the previous parent.  Then this parent is auto-resubmitted as part of partial failure
        // processing.  At this point the previously leaked child sessions will be erroneously seen as children of 
        // the new parent and improperly resubmitted with the new parent.  Believe or not, I think this has
        // actually happened...
        char buf[1024];
        std::string childUIDEncoded;
        MSIXUidGenerator::Encode(childUIDEncoded, &(parentIt->first[0]));
        std::string parentUIDEncoded;
        MSIXUidGenerator::Encode(parentUIDEncoded, &(parentIt->second[0]));
        sprintf(buf, "Metered message contains child session with id = %s that refers to parent with id = %s not contained in the message",
                childUIDEncoded.c_str(), parentUIDEncoded.c_str()); 
        SetError(MT_ERR_SERVER_ERROR, ERROR_MODULE, ERROR_LINE, functionName, buf);
        return FALSE;
      }
      child->SetParent(parent);
    }

    // All done, convert from SharedSession to COM
    for (map<vector<unsigned char>, SharedSessionWrapper*>::iterator mapIt = sharedSessions.begin(); 
         mapIt != sharedSessions.end(); 
         mapIt++)
    {
      SharedSessionWrapper * session = mapIt->second;

      MTPipelineLib::IMTSessionPtr sessionObj =
        mCOMSessionServer->GetSession(session->GetSessionID());

      // the COM object now holds onto it (deletion will happen in the SharedSessionMap d'tor
      session->Detach();
      
      sessions.push_back(sessionObj);
    }

		return true;
	}
	catch (COdbcException & err)
	{
		SetError(MT_ERR_SERVER_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 err.what());

		return FALSE;
	}
	catch (std::exception & err)
	{
		SetError(MT_ERR_SERVER_ERROR, ERROR_MODULE, ERROR_LINE, functionName,
						 err.what());

		return FALSE;
	}
}
