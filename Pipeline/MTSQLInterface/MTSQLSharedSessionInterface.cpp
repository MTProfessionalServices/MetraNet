#include <metra.h>
#include <exception>

#import <MTConfigLib.tlb>

#include <MTSQLSharedSessionInterface.h>
#include <pipelineconfig.h>
#include <MTSessionServerBaseDef.h>
#include <mtglobal_msg.h>
#include <ConfigDir.h>
#include <mtdec.h>
#include <mtprogids.h>

MTSQLSharedSessionFactoryWrapper::MTSQLSharedSessionFactoryWrapper()
  :
  mpHeader(NULL),
  mpSessServer(NULL)
{
	//
	// reads in the pipeline configuration file
	//
	std::string configDir;
	if (!GetMTConfigDir(configDir))
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Could not read configuration directory setting!");

	PipelineInfo pipelineInfo;
	PipelineInfoReader pipelineReader;
	MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
	if (!pipelineReader.ReadConfiguration(config, configDir.c_str(), pipelineInfo))
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Could not read pipeline configuration file!");

	std::string filename;
	std::string sharename;
	
	filename = pipelineInfo.GetSharedSessionFile();
	sharename = pipelineInfo.GetShareName();

	_bstr_t filenameBstr(filename.c_str());
	_bstr_t sharenameBstr(sharename.c_str());

	int totalSize = pipelineInfo.GetSharedFileSize();

  // Get the singleton instance of the session server by creating a base
  // object and then snarfing its underlying shared memory header.
  mpSessServer = CMTSessionServerBase::CreateInstance();
  mpSessServer->Init(filenameBstr, sharenameBstr, totalSize);
  mpHeader = mpSessServer->GetSharedHeader();
}

MTSQLSharedSessionFactoryWrapper::~MTSQLSharedSessionFactoryWrapper()
{
  if(mpSessServer != NULL)
  {
    mpSessServer->Release();
    mpSessServer = NULL;
  }
}

bool MTSQLSharedSessionFactoryWrapper::InitSession(const unsigned char * uid, 
                                                   const unsigned char * parentUid, 
                                                   int serviceId,
                                                   MTSQLSharedSessionWrapper * wrapper)
{
	const char * functionName = "MTSQLSharedSessionFactoryWrapper::InitSession";

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
			return false;
		}

		SetError(PIPE_ERR_SHARED_OBJECT_FAILURE, ERROR_MODULE, ERROR_LINE,
             functionName, "Unknown shared object failure");
		return false;
	}


	ASSERT(sess->UIDEquals((const unsigned char *) uid));

	// Create() above set the parent ID
	sess->SetServiceID(serviceId);

  wrapper->Init(sess, mpHeader, id);

  return true;
}

MTSQLSharedSessionWrapper * MTSQLSharedSessionFactoryWrapper::CreateSession(const unsigned char * uid, 
                                                                  const unsigned char * parentUid, 
                                                                  int serviceId)
{
	// the shared object was created with a reference count of 1.
	MTSQLSharedSessionWrapper * tmp = new MTSQLSharedSessionWrapper();
  if(InitSession(uid, parentUid, serviceId, tmp))
  {
    return tmp;
  }
  else
  {
    delete tmp;
    return NULL;
  }
}

bool MTSQLSharedSessionFactoryWrapper::InitSession(long id, MTSQLSharedSessionWrapper * wrapper)
{
	const char * functionName = "MTSQLSharedSessionFactoryWrapper::GetSession";

	ASSERT(mpHeader);

	SharedSession * sess = mpHeader->GetSession(id);
	if (!sess)
	{		
		SetError(PIPE_ERR_SHARED_OBJECT_FAILURE, ERROR_MODULE, ERROR_LINE,
             functionName, "Unknown shared object failure");
		return false;
	}
	// must add ref since creation start with ref count of 1 so
  // the wrapper doesn't AddRef.
  sess->AddRef();

	wrapper->Init(sess, mpHeader, id);
  return true;
}

MTSQLSharedSessionWrapper * MTSQLSharedSessionFactoryWrapper::GetSession(long id)
{
	// the shared object was created with a reference count of 1.
	MTSQLSharedSessionWrapper * tmp = new MTSQLSharedSessionWrapper();
  if(InitSession(id, tmp))
  {
    return tmp;
  }
  else
  {
    delete tmp;
    return NULL;
  }
}


MTSQLSharedSessionActivationRecord::MTSQLSharedSessionActivationRecord(MTSQLSharedSessionWrapper * aSessionPtr) 
{
  mSessionPtr = aSessionPtr;
}

void MTSQLSharedSessionActivationRecord::getLongValue(const Access * access, RuntimeValue * value)
{
  long id = (static_cast<const MTSessionAccess *>(access))->getID();
  mSessionPtr->GetInt32Value(id, value);
}
void MTSQLSharedSessionActivationRecord::getLongLongValue(const Access * access, RuntimeValue * value)
{
  long id = (static_cast<const MTSessionAccess *>(access))->getID();
  mSessionPtr->GetInt64Value(id, value);
}
void MTSQLSharedSessionActivationRecord::getDoubleValue(const Access * access, RuntimeValue * value)
{
  long id = (static_cast<const MTSessionAccess *>(access))->getID();
  mSessionPtr->GetDoubleValue(id, value);
}
void MTSQLSharedSessionActivationRecord::getDecimalValue(const Access * access, RuntimeValue * value)
{
  long id = (static_cast<const MTSessionAccess *>(access))->getID();
  mSessionPtr->GetDecimalValue(id, value);
}
void MTSQLSharedSessionActivationRecord::getStringValue(const Access * access, RuntimeValue * value)
{
  long id = (static_cast<const MTSessionAccess *>(access))->getID();
  RuntimeValue tmp;
  mSessionPtr->GetStringValue(id, &tmp);
  value->operator=(tmp.castToString());
}
void MTSQLSharedSessionActivationRecord::getWStringValue(const Access * access, RuntimeValue * value)
{
  long id = (static_cast<const MTSessionAccess *>(access))->getID();
  mSessionPtr->GetStringValue(id, value);
}
void MTSQLSharedSessionActivationRecord::getBooleanValue(const Access * access, RuntimeValue * value)
{
  long id = (static_cast<const MTSessionAccess *>(access))->getID();
  mSessionPtr->GetBooleanValue(id, value);
}
void MTSQLSharedSessionActivationRecord::getDatetimeValue(const Access * access, RuntimeValue * value)
{
  long id = (static_cast<const MTSessionAccess *>(access))->getID();
  mSessionPtr->GetDatetimeValue(id, value);
}
void MTSQLSharedSessionActivationRecord::getTimeValue(const Access * access, RuntimeValue * value)
{
  long id = (static_cast<const MTSessionAccess *>(access))->getID();
  mSessionPtr->GetTimeValue(id, value);
}
void MTSQLSharedSessionActivationRecord::getEnumValue(const Access * access, RuntimeValue * value)
{
  long id = (static_cast<const MTSessionAccess *>(access))->getID();
  mSessionPtr->GetEnumValue(id, value);
}
void MTSQLSharedSessionActivationRecord::getBinaryValue(const Access * access, RuntimeValue * value)
{
  throw MTSQLRuntimeErrorException("BINARY properties not supported");
}

void MTSQLSharedSessionActivationRecord::setLongValue(const Access * access, const RuntimeValue * value)
{
  if (false == value->isNullRaw())
  {
  long id = (static_cast<const MTSessionAccess *>(access))->getID();
  mSessionPtr->SetInt32Value(id, value);
}
  else
  {
    throw MTSQLNullException(static_cast<const MTSessionAccess *>(access));
  }    
}
void MTSQLSharedSessionActivationRecord::setLongLongValue(const Access * access, const RuntimeValue * value)
{
  if (false == value->isNullRaw())
  {
  long id = (static_cast<const MTSessionAccess *>(access))->getID();
  mSessionPtr->SetInt64Value(id, value);
}
  else
  {
    throw MTSQLNullException(static_cast<const MTSessionAccess *>(access));
  }    
}
void MTSQLSharedSessionActivationRecord::setDoubleValue(const Access * access, const RuntimeValue * value)
{
  if (false == value->isNullRaw())
  {
  long id = (static_cast<const MTSessionAccess *>(access))->getID();
  mSessionPtr->SetDoubleValue(id, value);
}
  else
  {
    throw MTSQLNullException(static_cast<const MTSessionAccess *>(access));
  }    
}
void MTSQLSharedSessionActivationRecord::setDecimalValue(const Access * access, const RuntimeValue * value)
{
  if (false == value->isNullRaw())
  {
  long id = (static_cast<const MTSessionAccess *>(access))->getID();
  mSessionPtr->SetDecimalValue(id, value);
}
  else
  {
    throw MTSQLNullException(static_cast<const MTSessionAccess *>(access));
  }    
}
void MTSQLSharedSessionActivationRecord::setStringValue(const Access * access, const RuntimeValue * value)
{
  if (false == value->isNullRaw())
  {
  long id = (static_cast<const MTSessionAccess *>(access))->getID();
  mSessionPtr->SetStringValue(id, &(value->castToWString()));
}
  else
  {
    throw MTSQLNullException(static_cast<const MTSessionAccess *>(access));
  }    
}
void MTSQLSharedSessionActivationRecord::setWStringValue(const Access * access, const RuntimeValue * value)
{
  if (false == value->isNullRaw())
  {
  long id = (static_cast<const MTSessionAccess *>(access))->getID();
  mSessionPtr->SetStringValue(id, value);
}
  else
  {
    throw MTSQLNullException(static_cast<const MTSessionAccess *>(access));
  }    
}
void MTSQLSharedSessionActivationRecord::setBooleanValue(const Access * access, const RuntimeValue * value)
{
  if (false == value->isNullRaw())
  {
  long id = (static_cast<const MTSessionAccess *>(access))->getID();
  mSessionPtr->SetBoolValue(id, value);
}
  else
  {
    throw MTSQLNullException(static_cast<const MTSessionAccess *>(access));
  }    
}
void MTSQLSharedSessionActivationRecord::setDatetimeValue(const Access * access, const RuntimeValue * value)
{
  if (false == value->isNullRaw())
  {
  long id = (static_cast<const MTSessionAccess *>(access))->getID();
  mSessionPtr->SetDateTimeValue(id, value);
}
  else
  {
    throw MTSQLNullException(static_cast<const MTSessionAccess *>(access));
  }    
}
void MTSQLSharedSessionActivationRecord::setTimeValue(const Access * access, const RuntimeValue * value)
{
  if (false == value->isNullRaw())
  {
  long id = (static_cast<const MTSessionAccess *>(access))->getID();
  mSessionPtr->SetTimeValue(id, value);
}
  else
  {
    throw MTSQLNullException(static_cast<const MTSessionAccess *>(access));
  }    
}
void MTSQLSharedSessionActivationRecord::setEnumValue(const Access * access, const RuntimeValue * value)
{
  if (false == value->isNullRaw())
  {
  long id = (static_cast<const MTSessionAccess *>(access))->getID();
  mSessionPtr->SetEnumValue(id, value);
}
  else
  {
    throw MTSQLNullException(static_cast<const MTSessionAccess *>(access));
  }    
}

void MTSQLSharedSessionActivationRecord::setBinaryValue(const Access * access, const RuntimeValue * value)
{
  throw MTSQLRuntimeErrorException("BINARY properties not supported");
}

RuntimeValue MTSQLSharedSessionActivationRecord::getLongValue(AccessPtr access)
{
  RuntimeValue tmp;
  getLongValue(access.get(), &tmp);
  return tmp;
}
RuntimeValue MTSQLSharedSessionActivationRecord::getLongLongValue(AccessPtr access)
{
  RuntimeValue tmp;
  getLongLongValue(access.get(), &tmp);
  return tmp;
}
RuntimeValue MTSQLSharedSessionActivationRecord::getDoubleValue(AccessPtr access)
{
  RuntimeValue tmp;
  getDoubleValue(access.get(), &tmp);
  return tmp;
}
RuntimeValue MTSQLSharedSessionActivationRecord::getDecimalValue(AccessPtr access)
{
  RuntimeValue tmp;
  getDecimalValue(access.get(), &tmp);
  return tmp;
}
RuntimeValue MTSQLSharedSessionActivationRecord::getStringValue(AccessPtr access)
{
  RuntimeValue tmp;
  getStringValue(access.get(), &tmp);
  return tmp;
}
RuntimeValue MTSQLSharedSessionActivationRecord::getWStringValue(AccessPtr access)
{
  RuntimeValue tmp;
  getWStringValue(access.get(), &tmp);
  return tmp;
}
RuntimeValue MTSQLSharedSessionActivationRecord::getBooleanValue(AccessPtr access)
{
  RuntimeValue tmp;
  getBooleanValue(access.get(), &tmp);
  return tmp;
}
RuntimeValue MTSQLSharedSessionActivationRecord::getDatetimeValue(AccessPtr access)
{
  RuntimeValue tmp;
  getDatetimeValue(access.get(), &tmp);
  return tmp;
}
RuntimeValue MTSQLSharedSessionActivationRecord::getTimeValue(AccessPtr access)
{
  RuntimeValue tmp;
  getTimeValue(access.get(), &tmp);
  return tmp;
}
RuntimeValue MTSQLSharedSessionActivationRecord::getEnumValue(AccessPtr access)
{
  RuntimeValue tmp;
  getEnumValue(access.get(), &tmp);
  return tmp;
}
void MTSQLSharedSessionActivationRecord::setLongValue(AccessPtr access, RuntimeValue val)
{
  if (false == val.isNullRaw())
  {
    mSessionPtr->SetInt32Value((static_cast<MTSessionAccess *>(access.get()))->getID(), val.getLong());
  }
  else
  {
    throw MTSQLNullException(static_cast<MTSessionAccess *>(access.get()));
  }
}
void MTSQLSharedSessionActivationRecord::setLongLongValue(AccessPtr access, RuntimeValue val)
{
  if (false == val.isNullRaw())
  {
    mSessionPtr->SetInt64Value((static_cast<MTSessionAccess *>(access.get()))->getID(), val.getLongLong());
  }
  else
  {
    throw MTSQLNullException(static_cast<MTSessionAccess *>(access.get()));
  }
}
void MTSQLSharedSessionActivationRecord::setDoubleValue(AccessPtr access, RuntimeValue val)
{
  if (false == val.isNullRaw())
  {
    mSessionPtr->SetDoubleValue((static_cast<MTSessionAccess *>(access.get()))->getID(), val.getDouble());
  }
  else
  {
    throw MTSQLNullException(static_cast<MTSessionAccess *>(access.get()));
  }
}
void MTSQLSharedSessionActivationRecord::setDecimalValue(AccessPtr access, RuntimeValue val)
{
  if (false == val.isNullRaw())
  {
    mSessionPtr->SetDecimalValue((static_cast<MTSessionAccess *>(access.get()))->getID(), val.getDecPtr());
  }
  else
  {
    throw MTSQLNullException(static_cast<MTSessionAccess *>(access.get()));
  }
}
void MTSQLSharedSessionActivationRecord::setStringValue(AccessPtr access, RuntimeValue val)
{
  if (false == val.isNullRaw())
  {
    mSessionPtr->SetStringValue((static_cast<MTSessionAccess *>(access.get()))->getID(), val.castToWString().getWStringPtr());
  }
  else
  {
    throw MTSQLNullException(static_cast<MTSessionAccess *>(access.get()));
  }
}
void MTSQLSharedSessionActivationRecord::setWStringValue(AccessPtr access, RuntimeValue val)
{
  if (false == val.isNullRaw())
  {
    mSessionPtr->SetStringValue((static_cast<MTSessionAccess *>(access.get()))->getID(), val.getWStringPtr());
  }
  else
  {
    throw MTSQLNullException(static_cast<MTSessionAccess *>(access.get()));
  }
}
void MTSQLSharedSessionActivationRecord::setBooleanValue(AccessPtr access, RuntimeValue val)
{
  if (false == val.isNullRaw())
  {
    mSessionPtr->SetBoolValue((static_cast<MTSessionAccess *>(access.get()))->getID(), val.getBool());
  }
  else
  {
    throw MTSQLNullException(static_cast<MTSessionAccess *>(access.get()));
  }
}
void MTSQLSharedSessionActivationRecord::setDatetimeValue(AccessPtr access, RuntimeValue val)
{
  if (false == val.isNullRaw())
  {
    mSessionPtr->SetDateTimeValue((static_cast<MTSessionAccess *>(access.get()))->getID(), val.getDatetime());
  }
  else
  {
    throw MTSQLNullException(static_cast<MTSessionAccess *>(access.get()));
  }
}
void MTSQLSharedSessionActivationRecord::setTimeValue(AccessPtr access, RuntimeValue val)
{
  if (false == val.isNullRaw())
  {
    mSessionPtr->SetTimeValue((static_cast<MTSessionAccess *>(access.get()))->getID(), val.getTime());
  }
  else
  {
    throw MTSQLNullException(static_cast<MTSessionAccess *>(access.get()));
  }
}
void MTSQLSharedSessionActivationRecord::setEnumValue(AccessPtr access, RuntimeValue val)
{	
  if (false == val.isNullRaw())
  {
    mSessionPtr->SetEnumValue((static_cast<MTSessionAccess *>(access.get()))->getID(), val.getEnum());
  }
  else
  {
    throw MTSQLNullException(static_cast<MTSessionAccess *>(access.get()));
  }
}
