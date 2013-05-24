/**************************************************************************
 * @doc DBPARSER
 *
 * @module |
 *
 *
 * Copyright 2004 by MetraTech Corporation
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
 *
 * @index | DBPARSER
 ***************************************************************************/

#ifndef _DBPARSER_H
#define _DBPARSER_H

#ifdef WIN32
// only include this header one time
#pragma once
#endif

#include <Metra.h>
#include <OdbcResultSet.h>
#include <OdbcConnection.h>
#include <errobj.h>
#include <map>
#include <mtcryptoapi.h>

#import <MTEnumConfigLib.tlb>
#import <MTPipelineLib.tlb> rename ("EOF", "EOFX")
#import <QueryAdapter.tlb> rename("GetUserName", "QAGetUserName")

typedef MTautoptr<COdbcResultSet> COdbcResultSetPtr;
typedef MTautoptr<COdbcConnection> COdbcConnectionPtr;

class CMSIXDefinition;
class CMSIXProperties;
class PipelineInfo;
class SharedSessionFactoryWrapper;
class SharedSessionWrapper;
class SDKSessionWrapper;
struct ValidationData;


/********************************************** PipelineDateTime ***/
// small wrapper around the 64 bit file time used by the Session object.

class PipelineDateTime
{
public:
	// time will be undefined
	PipelineDateTime();
	// time will be the given value
	PipelineDateTime(__int64 ftime);
	// copy constructor is also available

	// set to current time
	void SetToNow();

	// set from filetime
	void SetToFiletime(__int64 ftime);
	// set from 32 bit unix time
	void SetToTimet(time_t unixtime);
	// set from VB/OLE datetime
	void SetToOleDate(DATE oletime);

	static PipelineDateTime GetMax();
	static PipelineDateTime GetMin();

	__int64 GetAsFileTime() const;
	time_t GetAsTimet() const;
	DATE GetAsOleDate() const;

	string GetAsString() const;

private:
	__int64 mTimeValue;
};

/********************************************** PipelineDateTime ***/

inline PipelineDateTime::PipelineDateTime()
	: mTimeValue(-1)
{ }

inline PipelineDateTime::PipelineDateTime(__int64 ftime)
	: mTimeValue(ftime)
{ }

inline void PipelineDateTime::SetToFiletime(__int64 ftime)
{ mTimeValue = ftime; }

inline __int64 PipelineDateTime::GetAsFileTime() const
{ return mTimeValue; }


/*************************************** property base class ***/
// reads one column from the database

template <class _Session, class _Index> class DBParserProperty
{
public:
  DBParserProperty()
  { mHasDefault = false; }

	virtual ~DBParserProperty()
	{ }

	virtual void Read(COdbcResultSetPtr resultSet, int ordinal, _Session * session) = 0;
	virtual bool InitDefault(const wchar_t * strDefault) = 0;

	void SetPropertyIndex(_Index index)
	{ mPropertyIndex = index; }

	void SetPropertyName(const string & propName)
	{ mPropertyName = propName; }

protected:
  bool mHasDefault;
	_Index mPropertyIndex;
	string mPropertyName;
};

/******************************************* DBParserService ***/
// uses a collection of properties to read one row from the database

template <class _Session, class _Index> class DBParserService : public ObjectWithError
{
public:
	virtual ~DBParserService();

	virtual bool Init(CMSIXDefinition * def,
                    MTENUMCONFIGLib::IEnumConfigPtr enumConfig,
										CMTCryptoAPI& crypto,
										bool applyDefaults);

	bool Read(COdbcResultSetPtr resultSet, _Session * session, int ordinal);

	int GetServiceID() const
	{ return mServiceID; }

	// return the list of service def column names to be used in a select query
	const string & GetColumnNames() const
	{ return mColumnNames; }

	const string & GetTableName() const
	{ return mTableName; }

private:
	vector<DBParserProperty<_Session, _Index> *> mProperties;

	int mServiceID;
	string mColumnNames;
	string mTableName;
};

class DBParserServiceSharedSession : public DBParserService<SharedSessionWrapper, int>
{
public:
  DBParserServiceSharedSession();
  ~DBParserServiceSharedSession();
};


/************************************************** DBParser ***/
// read a group of sessions of any service def from the database

class DBParserSharedSession : public ObjectWithError
{
private:
	enum { UID_LENGTH = 16 };

  SharedSessionFactoryWrapper * mSessionServer;
  MTPipelineLib::IMTSessionServerPtr mCOMSessionServer;
	// map service ID to object that can read that service out of the
	// database
	std::map<int, DBParserServiceSharedSession > mServiceDefMap;
	CMTCryptoAPI mCrypto;
	QUERYADAPTERLib::IMTQueryAdapterPtr mQueryAdapter;

public:
  bool Init(const PipelineInfo & pipelineInfo, MTPipelineLib::IMTSessionServerPtr comSessionServer);
  bool Parse(COdbcConnectionPtr conn,
             int messageID,
             int serviceID,
             map<vector<unsigned char>, SharedSessionWrapper*> & sharedSessions,
             map<vector<unsigned char>, vector<unsigned char> > & parentChildRelationships,
						 ValidationData& parsedData);
  bool Parse(int messageID,
             std::vector<int> & serviceIDs,
             unsigned char * batchUID,
             vector<MTPipelineLib::IMTSessionPtr> & sessions,
             ValidationData& parsedData);
};

#include <dbparser_template.h>

#endif /* _DBPARSER_H */
