#ifndef __LOGGERREADERWRITER_H__
#define __LOGGERREADERWRITER_H__
#pragma once

#include <LoggerEnums.h>
#include <mtprogids.h>

#import <MTConfigLib.tlb>
using namespace MTConfigLib;

class MTLoggerReaderWriter 
{
public:
	
	MTLoggerReaderWriter() :
		mFileName(""),
		mLogLevel(LOG_INFO),
		mError(NO_ERROR),
		mlogsocket(0),
		mlogrolloverage(0),
		mlogfilterlevel(LOG_OFF),
		mlogfiltertag(""),
		mVersion(1) {}

	void Read(_bstr_t&);
	void Write(_bstr_t&);

public: // data

	_bstr_t mFileName;
	MTLogLevel mLogLevel;
	long mError;
	long mlogsocket ;
	long mlogrolloverage;
	MTLogLevel mlogfilterlevel;
	_bstr_t mlogfiltertag ;
	long mVersion;

};

const _bstr_t versionBstr("version");
const _bstr_t loggingConfigBstr("logging_config");
const _bstr_t logFileNameBstr("logfilename");
const _bstr_t loglevelBstr("loglevel");
const _bstr_t logsocketBstr("logsocket"); // port number for remote monitoring of messages.
const _bstr_t logrolloverageBstr("logrolloverage"); // days that will trigger a log file rollover.
const _bstr_t logfilterlevelBstr("logfilterlevel"); // trigger log file contents.
const _bstr_t logfiltertagBstr("logfiltertag");  // trigger log file contents.

//////////////////////////////////////////////////////////////////
// Function name	: MTLoggerReaderWriter::Read
// Description	    : 
// Return type		: void 
//////////////////////////////////////////////////////////////////

void MTLoggerReaderWriter::Read(_bstr_t& aFileName)
{

	MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);

	VARIANT_BOOL flag;
	_bstr_t bstrConfigFile = aFileName;

	MTConfigLib::IMTConfigPropSetPtr propset = config->ReadConfiguration(aFileName, &flag);

	mVersion = propset->NextLongWithName(versionBstr);

	MTConfigLib::IMTConfigPropSetPtr subset = propset->NextSetWithName(loggingConfigBstr);
	mFileName = subset->NextStringWithName(logFileNameBstr);
	mLogLevel = (MTLogLevel) subset->NextLongWithName(loglevelBstr);

	if(mVersion > 1) {
		mlogsocket =  subset->NextLongWithName(logsocketBstr);
		mlogrolloverage =  subset->NextLongWithName(logrolloverageBstr);
		mlogfilterlevel =  (MTLogLevel) subset->NextLongWithName(logfilterlevelBstr);
		mlogfiltertag =  subset->NextStringWithName(logfiltertagBstr);
	}

}


//////////////////////////////////////////////////////////////////
// Function name	: MTLoggerReaderWriter::Write
// Description	    : 
// Return type		: void 
//////////////////////////////////////////////////////////////////

void MTLoggerReaderWriter::Write(_bstr_t& aFileName)
{
	MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
	
	// write out the new logging file

	MTConfigLib::IMTConfigPropSetPtr aNewLogFile = config->NewConfiguration("xmlconfig");
	aNewLogFile->InsertProp(versionBstr,PROP_TYPE_INTEGER,mVersion);
	MTConfigLib::IMTConfigPropSetPtr aNewSet = aNewLogFile->InsertSet(loggingConfigBstr);

		aNewSet->InsertProp(logFileNameBstr,PROP_TYPE_STRING,mFileName);
		aNewSet->InsertProp(loglevelBstr,PROP_TYPE_INTEGER,(long)mLogLevel);
	if(mVersion > 1) {
		aNewSet->InsertProp(logsocketBstr,PROP_TYPE_INTEGER,mlogsocket);
		aNewSet->InsertProp(logrolloverageBstr,PROP_TYPE_INTEGER,mlogrolloverage);
		aNewSet->InsertProp(logfilterlevelBstr,PROP_TYPE_INTEGER,(long)mlogfilterlevel);
		aNewSet->InsertProp(logfiltertagBstr,PROP_TYPE_STRING,mlogfiltertag);
	}

	aNewLogFile->Write(aFileName);

}



#endif //__LOGGERREADERWRITER_H__