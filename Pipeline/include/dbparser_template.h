//#include <sessionprops.h>
//#include <sharedsess.h>

#include <metra.h>


#include <stdutils.h>
#include <ServicesCollection.h>
#include <OdbcSessionTypeConversion.h>
#include <OdbcConnMan.h>
#include <OdbcException.h>
#include <mtprogids.h>
#include <mtglobal_msg.h>
#include <OdbcStatement.h>
#include <sessionprops.h>
#include <sharedsess.h>
#include <MSIX.h>
#include <propids.h>
#include <genparser.h>
#include <MTUtil.h>
#include <mttime.h>
//#include <session.h>

#import <NameID.tlb>
#import <COMMeter.tlb>


typedef size_t size_type;

class SessionPropertyAllocationFailure : public std::exception
{
public:
  SessionPropertyAllocationFailure() : std::exception("Failure allocating shared memory") {}
};

class SharedSessionWrapper
{
private:
  SharedSession * mpSession;  
  SharedSessionHeader * mpHeader;
  long mSessionID;
  SharedPropVal * CreateSharedProp(long aPropId)
  {
    // NOTE: we know that we're always creating properties since it's a new
    // session object.  therefore we don't need to see if the property already exists.
    // property reference ID is ignored
    long ref;
    SharedPropVal * prop = mpSession->AddProperty(mpHeader, ref, aPropId);
    if (!prop)
      // If prop is null, the shared area is out of memory
      throw SessionPropertyAllocationFailure();
    // no need to clear the property since it's brand new
    ASSERT(prop->GetType() == SharedPropVal::FREE_PROPERTY);
    return prop;
  }

public:

  SharedSessionWrapper(SharedSession * apSession, SharedSessionHeader * apHeader, long aSessionID)
    :
    mpSession(apSession),
    mpHeader(apHeader),
    mSessionID(aSessionID)
  {
    ASSERT(apSession);
    ASSERT(apHeader);
  }

  ~SharedSessionWrapper()
  {
    // Clean up if not detached
    if (mpSession != NULL)
    {
      mpSession->Release(mpHeader);
    }
  }

	static int CalculatePropertyIndex(const char * propertyName)
	{
		NAMEIDLib::IMTNameIDPtr nameID(MTPROGID_NAMEID);
		return nameID->GetNameID(propertyName);
	}

  SharedSession * Detach()
  {
    mpSession->Release(mpHeader);
    SharedSession * tmp = mpSession;
    mpSession = NULL;
    return tmp;
  }

  int GetSessionID()
  {
    return mpSession->GetSessionID(mpHeader);
  }

	void SetInt32Value(size_type index, int value)
  {
		CreateSharedProp(index)->SetLongValue(value);
  }
	void SetInt64Value(size_type index, __int64 value)
  {
		CreateSharedProp(index)->SetLongLongValue(value);
  }
	void SetStringValue(size_type index, const wstring & value)
  {
    // is the string small enough to go into the SharedPropVal directly
    if (value.size() * sizeof(wchar_t) < SharedSessionHeader::TINY_STRING_MAX)
    {
      CreateSharedProp(index)->SetTinyStringValue(value.c_str());
    }
    else
    {
      long ref;
      const wchar_t * wideStr = mpHeader->AllocateWideString(value.c_str(), ref);
      if (!wideStr)
        // TODO:
        throw SessionPropertyAllocationFailure();

      // set the value
      CreateSharedProp(index)->SetUnicodeIDValue(ref);
    }
  }

	// value is encrypted here, session server decrypts it on-demand when used
  void SetEncryptedStringValue(size_type index, const wstring & value)
  {
    SetStringValue(index, value);
  }
	void SetDecimalValue(size_type index, const MTDecimal & value)
  {
		CreateSharedProp(index)->SetDecimalValue((const unsigned char *) &value);
  }
	void SetDateTimeValue(size_type index, const PipelineDateTime & value)
  {
		CreateSharedProp(index)->SetDateTimeValue(value.GetAsTimet());
  }
	void SetBoolValue(size_type index, bool value)
  {
		CreateSharedProp(index)->SetBooleanValue(value);
  }
	void SetDoubleValue(size_type index, double value)
  {
		CreateSharedProp(index)->SetDoubleValue(value);
  }
	void SetTimeValue(size_type index, int value)
  {
		CreateSharedProp(index)->SetTimeValue(value);
  }
	void SetEnumValue(size_type index, int value)  
  {
		CreateSharedProp(index)->SetEnumValue(value);
  }
  void SetParent(SharedSessionWrapper * parent)
  {
    mpSession->SetParentID(mpHeader, parent->mSessionID);
  }
};

//
// SDK Session Wrapper
//

class SDKSessionWrapper
{
  private:
    COMMeterLib::ISessionPtr mSession;
    MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;
    CMTCryptoAPI& mCrypto;
  public:

	// TODO: pass in a COMMeter.ISession object
  SDKSessionWrapper(COMMeterLib::ISessionPtr session,
										MTENUMCONFIGLib::IEnumConfigPtr enumConfig,
										CMTCryptoAPI& crypto)
		: mSession(session), mCrypto(crypto)
  {
   mEnumConfig = enumConfig;
  }

	static std::string CalculatePropertyIndex(const char * propertyName)
	{
		return propertyName;
	}

	void SetInt32Value(std::string& index, int value)
  {
    _variant_t val(long(value), VT_I4);
    mSession->InitProperty(index.c_str(), val);
  }

	void SetInt64Value(std::string& index, __int64 value)
  {
     _variant_t val(value);
     mSession->InitProperty(index.c_str(), val);
  }

	void SetStringValue(std::string& index, const wstring & value)
  {
     _variant_t val(value.c_str()); 
     mSession->InitProperty(index.c_str(), val);
  }

  void SetEncryptedStringValue(std::string& index, const wstring & value)
  {
    std::string cipherText;
    if(!::WideStringToUTF8(value, cipherText))
    {
      ASSERT(0);
		  throw MTException("Failed to convert wide string to UTF8!");
    }

	  // decrypt the string
	  int result;
	  result = mCrypto.Decrypt(cipherText);
	  if (result != 0)
	  {
		  ASSERT(0);
		  std::string msg = "Failed to decrypt property! propid=" + index;
		  throw MTException(msg.c_str());
	  }

	  _bstr_t wideCipherText(cipherText.c_str());

    SetStringValue(index, (wchar_t*) wideCipherText); 
  }

	void SetDecimalValue(std::string& index, const MTDecimal & value)
  {
     _variant_t val(value);
     mSession->InitProperty(index.c_str(), val);
  }

	void SetDateTimeValue(std::string& index, const PipelineDateTime & value)
  {
    DATE mydate;
    mydate = value.GetAsOleDate();
    _variant_t val(mydate, VT_DATE);
     mSession->InitProperty(index.c_str(), val);
  }

	void SetBoolValue(std::string& index, bool value)
  {
    _variant_t val(value);
     mSession->InitProperty(index.c_str(), val);
  }

	void SetDoubleValue(std::string& index, double value)
  {
    _variant_t val(value, VT_R8);
     mSession->InitProperty(index.c_str(), val);
  }

	void SetTimeValue(std::string& index, int value)
  {
    _variant_t val(value);
     mSession->InitProperty(index.c_str(), val);
  }

	void SetEnumValue(std::string& index, int value)  
  {
    _bstr_t enumerator = mEnumConfig->GetEnumeratorByID(value);
     _variant_t val(enumerator);
     mSession->InitProperty(index.c_str(), val);
  }


};


/****************************************** property classes ***/

template <class _Session, class _Index>
class DBParserInt32Property : public DBParserProperty<_Session, _Index>
{
public:
	virtual void Read(COdbcResultSetPtr resultSet, int ordinal, _Session * session);
	virtual bool InitDefault(const wchar_t * strDefault);

private:
	int mDefault;
};

template <class _Session, class _Index>
class DBParserInt64Property : public DBParserProperty<_Session, _Index>
{
public:
	virtual void Read(COdbcResultSetPtr resultSet, int ordinal, _Session * session);
	virtual bool InitDefault(const wchar_t * strDefault);

private:
	__int64 mDefault;
};

template <class _Session, class _Index>
class DBParserDecimalProperty : public DBParserProperty<_Session, _Index>
{
public:
	virtual void Read(COdbcResultSetPtr resultSet, int ordinal, _Session * session);
	virtual bool InitDefault(const wchar_t * strDefault);

private:
	MTDecimal mDefault;
};

template <class _Session, class _Index>
class DBParserStringProperty : public DBParserProperty<_Session, _Index>
{
public:
	virtual void Read(COdbcResultSetPtr resultSet, int ordinal, _Session * session);
	virtual bool InitDefault(const wchar_t * strDefault);

private:
	wstring mDefault;
};

template <class _Session, class _Index>
class DBParserEncryptedStringProperty : public DBParserProperty<_Session, _Index>
{
public:
	DBParserEncryptedStringProperty(CMTCryptoAPI& crypto) : mCrypto(crypto)
	{ };

	virtual void Read(COdbcResultSetPtr resultSet, int ordinal, _Session * session);
	virtual bool InitDefault(const wchar_t * strDefault);

private:
	// default value stored as ciphertext
	wstring mDefault;

	CMTCryptoAPI& mCrypto;
};

template <class _Session, class _Index>
class DBParserBoolProperty : public DBParserProperty<_Session, _Index>
{
public:
	virtual void Read(COdbcResultSetPtr resultSet, int ordinal, _Session * session);
	virtual bool InitDefault(const wchar_t * strDefault);

private:
	bool mDefault;
};

template <class _Session, class _Index>
class DBParserDateTimeProperty : public DBParserProperty<_Session, _Index>
{
public:
	virtual void Read(COdbcResultSetPtr resultSet, int ordinal, _Session * session);
	virtual bool InitDefault(const wchar_t * strDefault);

private:
	PipelineDateTime mDefault;
};

template <class _Session, class _Index>
class DBParserDoubleProperty : public DBParserProperty<_Session, _Index>
{
public:
	virtual void Read(COdbcResultSetPtr resultSet, int ordinal, _Session * session);
	virtual bool InitDefault(const wchar_t * strDefault);

private:
	double mDefault;
};

template <class _Session, class _Index>
class DBParserTimeProperty : public DBParserProperty<_Session, _Index>
{
public:
	virtual void Read(COdbcResultSetPtr resultSet, int ordinal, _Session * session);
	virtual bool InitDefault(const wchar_t * strDefault);

private:
	int mDefault;
};

/******************************** property class definitions ***/

template <class _Session, class _Index>
class DBParserEnumProperty : public DBParserProperty<_Session, _Index>
{
public:
	virtual void Read(COdbcResultSetPtr resultSet, int ordinal, _Session * session);
	virtual bool InitDefault(const wchar_t * strDefault);

	DBParserEnumProperty(MTENUMCONFIGLib::IEnumConfigPtr enumConfig,
											 const wstring & enumNamespace, const wstring & enumeration)
	{
		mEnumConfig = enumConfig;
		mEnumNamespace = enumNamespace;
		mEnumeration = enumeration;
	}

private:
	int mDefault;
	wstring mEnumNamespace;
	wstring mEnumeration;
	MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;
};


template <class _Session, class _Index> 
void DBParserInt32Property<_Session, _Index>::Read(COdbcResultSetPtr resultSet, int ordinal, _Session * session)
{
	// NOTE: this assumes required properties are not nullable in the database.
	// this is not checked here.
	int value = resultSet->GetInteger(ordinal);
	if (resultSet->WasNull())
  {
    if (mHasDefault)
      value = mDefault;
    else
      return; // If there is no default do not set in the session.  MG
  }

	session->SetInt32Value(mPropertyIndex, value);
}

template <class _Session, class _Index>
bool DBParserInt32Property<_Session, _Index>::InitDefault(const wchar_t * strDefault)
{
	wchar_t * end;
	mDefault = wcstol(strDefault, &end, 10);
  mHasDefault = (end == strDefault + wcslen(strDefault));
	return mHasDefault;
}

template <class _Session, class _Index>
void DBParserInt64Property<_Session, _Index>::Read(COdbcResultSetPtr resultSet, int ordinal, _Session * session)
{
	// NOTE: this assumes required properties are not nullable in the database.
	// this is not checked here.
	__int64 value = resultSet->GetBigInteger(ordinal);
	if (resultSet->WasNull())
  {
    if (mHasDefault)
      value = mDefault;
    else
      return; // If there is no default do not set in the session.  MG
  }

	session->SetInt64Value(mPropertyIndex, value);
}

template <class _Session, class _Index>
bool DBParserInt64Property<_Session, _Index>::InitDefault(const wchar_t * strDefault)
{
	wchar_t * end;
	mDefault = _wcstoi64(strDefault, &end, 10);
  mHasDefault = (end == strDefault + wcslen(strDefault));
	return mHasDefault;
}

template <class _Session, class _Index>
void DBParserDecimalProperty<_Session, _Index>::Read(COdbcResultSetPtr resultSet, int ordinal, _Session * session)
{
  COdbcDecimal value = resultSet->GetDecimal(ordinal);
	if (resultSet->WasNull())
  {
    // If there is no default do not set in the session.  MG
    if (mHasDefault)
  		session->SetDecimalValue(mPropertyIndex, mDefault);
  }
	else
	{
		DECIMAL decVal;
		OdbcDecimalToDecimal(value, &decVal);
		session->SetDecimalValue(mPropertyIndex, decVal);
	}
}

template <class _Session, class _Index>
bool DBParserDecimalProperty<_Session, _Index>::InitDefault(const wchar_t * strDefault)
{
	string ascDefault = ascii(strDefault);
  mHasDefault = (mDefault.SetValue(ascDefault.c_str()) ? true : false);
	return mHasDefault;
}

template <class _Session, class _Index>
void DBParserEncryptedStringProperty<_Session, _Index>::Read(COdbcResultSetPtr resultSet, int ordinal, _Session * session)
{
	wstring value = resultSet->GetWideString(ordinal);
	if (resultSet->WasNull())
  {
    // If there is no default do not set in the session.  MG
    if (mHasDefault)
  		session->SetEncryptedStringValue(mPropertyIndex, mDefault);
  }
	else
		session->SetEncryptedStringValue(mPropertyIndex, value);
}

template <class _Session, class _Index>
bool DBParserEncryptedStringProperty<_Session, _Index>::InitDefault(const wchar_t * strDefault)
{
	// default values are stored in plaintext in the msixdef
	// but the session server expects them to be encrypted

	std::string cipherText;
  if(!::WideStringToUTF8(strDefault, cipherText))
		throw MTException("Failed to convert wide string to UTF8!");

	// encrypts and uuencodes string
	int result = mCrypto.Encrypt(cipherText);
	if (result != 0)
	{
		std::string msg = "Failed to encrypt default value of property! default=";
		msg += (const char *) _bstr_t(strDefault);
		throw MTException(msg.c_str());
	}

	mDefault = (const wchar_t *) _bstr_t(cipherText.c_str());

  mHasDefault = true;
	return mHasDefault;
}


template <class _Session, class _Index>
void DBParserStringProperty<_Session, _Index>::Read(COdbcResultSetPtr resultSet, int ordinal, _Session * session)
{
	wstring value = resultSet->GetWideString(ordinal);
	if (resultSet->WasNull())
  {
    // If there is no default do not set in the session.  MG
    if (mHasDefault)
  		session->SetStringValue(mPropertyIndex, mDefault);
  }
	else
		session->SetStringValue(mPropertyIndex, value);
}

template <class _Session, class _Index>
bool DBParserStringProperty<_Session, _Index>::InitDefault(const wchar_t * strDefault)
{
	mDefault = strDefault;
  mHasDefault = true;
	return mHasDefault;
}

template <class _Session, class _Index>
void DBParserBoolProperty<_Session, _Index>::Read(COdbcResultSetPtr resultSet, int ordinal, _Session * session)
{
	string value = resultSet->GetString(ordinal);
	if (resultSet->WasNull())
  {
    // If there is no default do not set in the session.  MG
    if (mHasDefault)
  		session->SetBoolValue(mPropertyIndex, mDefault);
  }
	else
	{
		if (value == "1")
			session->SetBoolValue(mPropertyIndex, true);
		else
			session->SetBoolValue(mPropertyIndex, false);
	}
}

template <class _Session, class _Index>
bool DBParserBoolProperty<_Session, _Index>::InitDefault(const wchar_t * strDefault)
{
  mHasDefault = false;  // Just in case this is called multiple times.  MG

	// only one chararcter is expected
	if (strDefault[1] != '\0')
  {
		return mHasDefault;
  }

	// conforms strictly to the MSIX specification [tTfF]
	switch(strDefault[0]) {
	case 'T': case 't':
		mDefault = true;
		break;
	case 'F':	case 'f':
		mDefault = false;
		break;
	default:
		return mHasDefault;
	}

  mHasDefault = true;
	return mHasDefault;
}

template <class _Session, class _Index>
void DBParserDateTimeProperty<_Session, _Index>::Read(COdbcResultSetPtr resultSet, int ordinal, _Session * session)
{
	COdbcTimestamp value = resultSet->GetTimestamp(ordinal);
	if (resultSet->WasNull())
  {
    // If there is no default do not set in the session.  MG
    if (mHasDefault)
  		session->SetDateTimeValue(mPropertyIndex, mDefault);
  }
	else
	{
		PipelineDateTime dt;
		time_t dt_timet;
		OdbcTimestampToTimet(value.GetBuffer(), &dt_timet);
		dt.SetToTimet(dt_timet);
		session->SetDateTimeValue(mPropertyIndex, dt);
	}
}

template <class _Session, class _Index>
bool DBParserDateTimeProperty<_Session, _Index>::InitDefault(const wchar_t * strDefault)
{
  mHasDefault = false;  // Just in case this is called multiple times.  MG

	time_t iso;
	string ascDefault = ascii(strDefault);
	if (!MTParseISOTime(ascDefault.c_str(), &iso))
		return mHasDefault;

	mDefault.SetToTimet(iso);
  mHasDefault = true;
	return mHasDefault;
}

template <class _Session, class _Index>
void DBParserDoubleProperty<_Session, _Index>::Read(COdbcResultSetPtr resultSet, int ordinal, _Session * session)
{
	double value = resultSet->GetDouble(ordinal);
	if (resultSet->WasNull())
  {
    // If there is no default do not set in the session.  MG
    if (mHasDefault)
  		session->SetDoubleValue(mPropertyIndex, mDefault);
  }
	else
		session->SetDoubleValue(mPropertyIndex, value);
}

template <class _Session, class _Index>
bool DBParserDoubleProperty<_Session, _Index>::InitDefault(const wchar_t * strDefault)
{
	wchar_t * end;
	mDefault = wcstod(strDefault, &end);
  mHasDefault = (end == strDefault + wcslen(strDefault));
	return (mHasDefault);
}

#if 0
// time not currently supported in service defs
template <class _Session, class _Index>
void DBParserTimeProperty<_Session, _Index>::Read(COdbcResultSetPtr resultSet, int ordinal, _Session * session)
{
	int value = resultSet->GetInteger(ordinal);
	if (resultSet->WasNull())
  {
    if (mHasDefault)
  		value = mDefault;
    else
      return; // If there is no default do not set in the session.  MG
  }

	session->SetTimeValue(mPropertyIndex, value);
}

template <class _Session, class _Index>
bool DBParserTimeProperty<_Session, _Index>::InitDefault(const wchar_t * strDefault)
{
  mHasDefault = false;
}
#endif

template <class _Session, class _Index>
void DBParserEnumProperty<_Session, _Index>::Read(COdbcResultSetPtr resultSet, int ordinal, _Session * session)
{
	int value = resultSet->GetInteger(ordinal);
	if (resultSet->WasNull())
  {
    if (mHasDefault)
  		value = mDefault;
		else
			return;
  }

	session->SetEnumValue(mPropertyIndex, value);
}

template <class _Session, class _Index>
bool DBParserEnumProperty<_Session, _Index>::InitDefault(const wchar_t * strDefault)
{
  mHasDefault = false;  // Just in case this is called multiple times.  MG

	try 
	{
		// enum ID must be calculated
		mDefault = mEnumConfig->GetID(mEnumNamespace.c_str(), mEnumeration.c_str(), _bstr_t(strDefault));
	}
	catch (_com_error&)
	{
		return mHasDefault;
	}

  mHasDefault = true;
	return mHasDefault;
}

/******************************************* service methods ***/

template <class _Session, class _Index>
DBParserService<_Session, _Index>::~DBParserService()
{
	vector<DBParserProperty<_Session, _Index> *>::const_iterator it;
	for (it = mProperties.begin(); it != mProperties.end(); ++it)
		delete *it;
}

template <class _Session, class _Index>
bool DBParserService<_Session, _Index>::Init(CMSIXDefinition * def,
																						 MTENUMCONFIGLib::IEnumConfigPtr enumConfig,
																						 CMTCryptoAPI& crypto,
																						 bool applyDefaults)
{
	const char * functionName = "DBParserService::Init";

	MSIXPropertiesList & props = def->GetMSIXPropertiesList();

  NAMEIDLib::IMTNameIDPtr nameID(MTPROGID_NAMEID);
  mServiceID = nameID->GetNameID(def->GetName().c_str());

	mTableName = ascii(def->GenerateTableName(L"t_svc_"));

	mColumnNames = "";

	MSIXPropertiesList::iterator it;
	for (it = props.begin(); it != props.end(); ++it)
	{
		CMSIXProperties * serviceProp = *it;

		if (mColumnNames.size() > 0)
			mColumnNames += ", ";
		mColumnNames += ascii(serviceProp->GetColumnName());

		CMSIXProperties * aProps = serviceProp;
		CMSIXProperties::PropertyType type = aProps->GetPropertyType();
    bool requiresDecryption = false;
    std::wstring name = aProps->GetDN();
    int len = name.length();

		DBParserProperty<_Session, _Index> * svcDefProp = NULL;
		switch (type)
		{
		case CMSIXProperties::TYPE_INT32:
			svcDefProp = new DBParserInt32Property<_Session, _Index>();
			break;
		
		case CMSIXProperties::TYPE_INT64:
			svcDefProp = new DBParserInt64Property<_Session, _Index>();
			break;
		
		case CMSIXProperties::TYPE_FLOAT:
		case CMSIXProperties::TYPE_DOUBLE:
			svcDefProp = new DBParserDoubleProperty<_Session, _Index>();
			break;

		case CMSIXProperties::TYPE_TIMESTAMP:
			svcDefProp = new DBParserDateTimeProperty<_Session, _Index>();
			break;

		case CMSIXProperties::TYPE_BOOLEAN:
			svcDefProp = new DBParserBoolProperty<_Session, _Index>();
			break;

		case CMSIXProperties::TYPE_ENUM:
			svcDefProp = new DBParserEnumProperty<_Session, _Index>(enumConfig,
																						aProps->GetEnumNamespace().c_str(),
																						aProps->GetEnumEnumeration().c_str());
			break;
		
		case CMSIXProperties::TYPE_STRING:
		case CMSIXProperties::TYPE_WIDESTRING:
			// encrypted string properties are identified by their trailing underscore suffix
      if (len > 1 && name[len - 1] == L'_')
        svcDefProp = new DBParserEncryptedStringProperty<_Session, _Index>(crypto);
			else
			  svcDefProp = new DBParserStringProperty<_Session, _Index>();
			break;

		case CMSIXProperties::TYPE_DECIMAL:
			svcDefProp = new DBParserDecimalProperty<_Session, _Index>();
			break;

		default:
			// TODO:
			//SetError(MT_ERR_BAD_PROPERTY, ERROR_MODULE, ERROR_LINE, functionName);
			svcDefProp = NULL;
			break;
		}

		ASSERT(svcDefProp);

		// store the property ID
		_Index propIndex = _Session::CalculatePropertyIndex(ascii(serviceProp->GetDN()).c_str());
		svcDefProp->SetPropertyIndex(propIndex);
		// .. and name for diagnostics
		svcDefProp->SetPropertyName(ascii(serviceProp->GetDN()));

		// keeps track of required/nonrequired properties for validation later 
		if (!serviceProp->GetIsRequired())
		{
			std::wstring wideDefaultStr = serviceProp->GetDefault();

			if (applyDefaults && wideDefaultStr.length() != 0)
			{
				if (!svcDefProp->InitDefault(wideDefaultStr.c_str()))
				{
					std::string buffer = "Cannot initialize default value of property '";
					buffer += ascii(aProps->GetDN()) + "' from ";
					buffer += ascii(def->GetName());
					SetError(MT_ERR_BAD_PROPERTY, ERROR_MODULE, ERROR_LINE, functionName,
									 buffer.c_str());
					return false;
				}
			}
		}

		mProperties.push_back(svcDefProp);
	}

	//
	// adds special properties to all service defs
	//
	DBParserProperty<_Session, _Index> * svcDefProp = NULL;

	// _IntervalID represents an explicit non-hard-closed interval used to guide usage into
	svcDefProp = new DBParserInt32Property<_Session, _Index>();
	svcDefProp->SetPropertyIndex(_Session::CalculatePropertyIndex(MT_INTERVALID_PROP_A));
	mProperties.push_back(svcDefProp);
	mColumnNames += ", c_" + string(MT_INTERVALID_PROP_A);

	// _TransactionCookie represents an opaque string used to join into distributed transactions
	// NOTE: SetTransactionID at the session set level supercedes this functionality
	svcDefProp = new DBParserStringProperty<_Session, _Index>();
	svcDefProp->SetPropertyIndex(_Session::CalculatePropertyIndex(MT_TRANSACTIONCOOKIE_PROP_A));
	mProperties.push_back(svcDefProp);
	mColumnNames += ", c_" + string(MT_TRANSACTIONCOOKIE_PROP_A);

	// _Resubmit represents whether a failed session has been fixed and resubmitted
	// to the pipeline for processing
	svcDefProp = new DBParserBoolProperty<_Session, _Index>();
	svcDefProp->SetPropertyIndex(_Session::CalculatePropertyIndex(MT_RESUBMIT_PROP_A));
	mProperties.push_back(svcDefProp);
	mColumnNames += ", c_" + string(MT_RESUBMIT_PROP_A);

	// NOTE: _CollectionID is omitted here because it is handled specially in
	// DBParserSharedSession::Parse method. Although it is metered as a base64 encoded
	// UID string it is stored as binary(16) blob in the t_svc tables. The pipeline 
	// expects it as an encoded string so it must be re-encoded by the router.

	return true;
}

template <class _Session, class _Index>
bool DBParserService<_Session, _Index>::Read(COdbcResultSetPtr resultSet, _Session * session, int ordinal)
{
	vector<DBParserProperty<_Session, _Index> *>::const_iterator it;

	// first columns are special:
	// ss.id_ss, ss.id_sess, ss.id_parent_sess,  ss.dt_metered, ss.id_batch
	// 1         2           3                          4             5
	//
	// the rest of the columns at the service def columns

	//int ordinal = 11;	
	for (it = mProperties.begin(); it != mProperties.end(); ++it)
	{
		DBParserProperty<_Session, _Index> * prop = *it;
		prop->Read(resultSet, ordinal, session);

		++ordinal;
	}

	return true;
}
