/**************************************************************************
 * @doc 
 *
 * @module |
 *
 * The MetraTech Metering Software Development Kit.
 *
 * Copyright 1998 by MetraTech Corporation
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
 ***************************************************************************/
#ifndef _MTSDKUTILS_H
#define _MTSDKUTILS_H

//
#include "mtsdk.h"
#include "mtlocalmode.h"
#include <fstream>
#include <string>
#include <vector>

using namespace std;

// objects defined in this file
class MTFieldImp;
class MTRecordImp;
class MTImportConfigImp;
class MTImportSourceImp;
class MTImporterImp;


int CStringToCharString (char * szBuffer, int Length, string cstrData) ;

//================================================================================================
// MTImportObjectImp  
//================================================================================================

class MTImportObjectImp : virtual public ObjectWithError, virtual public MTMeterError

{
public:
	virtual					~MTImportObjectImp();
	virtual unsigned long	GetErrorCode() const;
	virtual BOOL			GetErrorMessage(wchar_t * buffer, int & bufferSize) const;
	virtual BOOL			GetErrorMessage(char * buffer, int & bufferSize) const;
	virtual int				GetErrorMessageEx(char * buffer, int & bufferSize) const;
	virtual int				GetErrorMessageEx(wchar_t * buffer, int & bufferSize) const;
	virtual time_t			GetErrorTime() const;

protected:
	void					SetError (MTMeterError * pError);

private:
	string				mErrorMessage;
};

//================================================================================================
// MTFieldImp  
//================================================================================================

class MTFieldImp : public MTImportObjectImp
{
public:

	enum FieldFormat
	{
		FieldFormatUnknown = 0,
		FieldFormatFixed = 1,
		FieldFormatdelimited = 2
	};
						MTFieldImp(const string & arName, FieldFormat aFormat);
						MTFieldImp(const string & arName, FieldFormat aFormat, 
															const string & arMeterProperty);
	virtual				~MTFieldImp();
			void		Ordinal(int Val);	
			int 		Ordinal();
			string	Name ();
			void		Name(string &);	
			string	Value();
			void		Value(string &);	
			BOOL		operator==(const MTFieldImp &) const;
			string	MeterProperty ();
			void		MeterProperty(string &);	
			void		Input(BOOL bRead);
			BOOL		Input();
			void		Output(BOOL bRead);
			BOOL		Output();
			FieldFormat	Format();
	virtual BOOL		Validate();
			MTMeterSession::SDKPropertyTypes Type();
			void		Type(MTMeterSession::SDKPropertyTypes);
			BOOL		Type(const char * szType);
	virtual BOOL		ComputeValue (MTRecordImp & );

private:
	string							mName;
	string							mValue;
	string							mMeterProperty;
	BOOL								mInput;
	BOOL								mOutput;
	FieldFormat							mFormat;
	MTMeterSession::SDKPropertyTypes	mType;
};


//================================================================================================
// MTFixedFieldImp  
//================================================================================================

class MTFixedFieldImp : public MTFieldImp
{
public:
					MTFixedFieldImp(string & arName, int Position, int Length, 
																	string & arPropName);
	virtual			~MTFixedFieldImp();
			void	Position(int);		
			int 	Position();
			void	Length(int);		
			int		Length();
	virtual BOOL	Validate();

private:
	int			mPosition;
	int			mLength;
};


//================================================================================================
// MTDelimitedFieldImp  
//================================================================================================

class MTDelimitedFieldImp : public MTFieldImp
{
public:
					MTDelimitedFieldImp(string & arName, char Delimiter);
	virtual			~MTDelimitedFieldImp();
			void	Delimiter(char);	
			char	Delimiter();
	virtual BOOL	Validate();

private:
	char	mDelimiter;
};


//================================================================================================
// MTRecordImp  
//================================================================================================

class MTRecordImp  : public MTImportObjectImp
{
public:
						MTRecordImp(string & arName);
	virtual				~MTRecordImp();
						MTRecordImp(const MTRecordImp & theOther);
			MTRecordImp &	operator=(const MTRecordImp &);						// operator = for record
			BOOL		AppendField(MTFixedFieldImp &, BOOL bIsKey = FALSE);		// append a field to the definition
			BOOL		AppendField(MTDelimitedFieldImp &, BOOL bIsKey = FALSE);	// append a field to the definition
			BOOL		InsertField (int, MTFieldImp &);						// insert a field at position N
			BOOL		DeleteField (string &);							// remove the named field
			MTFieldImp * 	FindField (const string &);							// find the named field
			BOOL		operator==(const MTRecordImp &)   const;				// operator == for record
			MTFieldImp *	Field (unsigned int Ordinal);						// field at ordinal
			int			FieldCount ();										// number of fields
			string	Service();											// service name
			void		Service(string &);								// service name
			string	Key();												// Get the single record key
			void		Key(MTFieldImp * pField);
			void		StripLeading(string &);							// Leading chars to strip
			void		StripTrailing(string &);							// trailing chars to strip
			string	StripLeading();
			string	StripTrailing();
			string	FromKey();											
			string	ToKey();
			void		FromKey(MTFieldImp &);
			void		ToKey(MTFieldImp &);
			BOOL		ComputeFields ();
	virtual BOOL		Validate();


private:
	typedef vector<MTFieldImp*> vectorFields;
	string						mName;
	string						mService;
	MTFieldImp *						mKeyField;
	MTFieldImp *						mFromKeyField;
	MTFieldImp *						mToKeyField;
	vectorFields				mFields;
	string						mLeading;
	string						mTrailing;

};	


//================================================================================================
// MTImportConfigImp  
//================================================================================================

class MTImportConfigImp : public MTImportObjectImp
{
public:
				MTImportConfigImp();
	virtual		~MTImportConfigImp();
	BOOL		AddRecordFormat (MTRecordImp &, BOOL bDefault=FALSE);	// the record definition
	MTRecordImp *  DefaultFormat();
	BOOL		ReadConfiguration(const char * aFilename);
	BOOL		Validate();

private:
	typedef vector<MTRecordImp*> vectorFormats;
	MTRecordImp *						mDefaultFormat;
	vectorFormats						mFormats;
};

//================================================================================================
// MTImportSourceImp  
//================================================================================================

class MTImportSourceImp : public MTImportObjectImp
{

public:
						MTImportSourceImp();
	virtual				~MTImportSourceImp();
//	BOOL		Initialize (const char * configfile, istream &  InputStream);	// set the effective input stream
			BOOL		InitializeInput (const char * configfile, const char * FileName);	
																				// from a file name
//	BOOL		Initialize (MTImportConfigImp &, istream &  InputStream);			// set the effective input stream
			BOOL		InitializeInput (MTImportConfigImp &, const char * FileName);		// input from a file name
			BOOL		InitializeOutput (const char * FileName);						// output from a file name
	virtual	BOOL		Read (MTRecordImp * & Record);										// read the next record
			BOOL		Read (MTRecordImp * & Record, const string & fromKey, const string & toKey);
																				// read next with this key range
			BOOL		Write (MTRecordImp & Record);										// write the next record
			BOOL		Meter (MTMeterSession * apParent, MTRecordImp & Record);			// meter the record
			BOOL		operator==(const MTImportSourceImp &)   const;


	virtual BOOL		PreRead (MTRecordImp &);
	virtual BOOL		PostRead (MTRecordImp &, BOOL);
	virtual BOOL		PreWrite (MTRecordImp &);
	virtual BOOL		PostWrite (MTRecordImp &, BOOL);

private:
			BOOL		ReadRecord (string &);
			BOOL		ParseRecord (MTRecordImp &, string &);
			BOOL		WriteRecord (string & arData);
			BOOL		SerializeRecord (MTRecordImp & arFormat, string & arData);


private:	
	ifstream		mInputFile;
	ofstream		mOutputFile;
	MTImportConfigImp * mConfig;

};

//================================================================================================
// MTImporterImp 
//================================================================================================

class MTImporterImp : public MTImportObjectImp
{
public:
					MTImporterImp (MTImportSourceImp & theParent , MTMeter	* Meter);
	virtual			~MTImporterImp();
			BOOL	AddChild (MTImportSourceImp & theChild);
			BOOL	Meter();
			long	ParentRecordCount();
			long	ChildRecordCount();
			BOOL	MeterJournal(const char * FileName);
	virtual	BOOL	ParentComplete (MTMeterSession * pParent, BOOL bStatus);
	virtual BOOL	ChildComplete (MTMeterSession * pParent, MTMeterSession * pChild, BOOL bStatus);

private:
	MTMeter	*								mMeter;
	MTImportSourceImp *						mParent;
	vector<MTImportSourceImp*>				mChildren;
	long									mParentRecordCount;
	long									mChildRecordCount;
	MTMeterStore *							mpMeterJournal;
};

#endif /* _MTSDKUTILS_H */
