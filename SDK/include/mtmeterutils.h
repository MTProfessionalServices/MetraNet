/**************************************************************************
 * @doc FileParsing 
 *
 * @module MTMeterUtils
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
#ifndef _MTMETERUTILS_H
#define _MTMETERUTILS_H


#include "mtsdk.h"

// classes defined in this file
// these are interface classes
class MTImportObject;
class MTField;
class MTFixedField;
class MTDelimitedField;
class MTRecord;
class MTImportConfig;
class MTImportSource;
class MTImporter;

// Classes referenced here but used elsewhere
// to provide interface via containment
class MTImportObjectImp;
class MTFieldImp;
class MTFixedFieldImp;
class MTDelimitedFieldImp;
class MTRecordImp;
class MTImportConfigImp;
class MTImportSourceImp;
class MTImporterImp;

#ifdef WIN32
#ifndef MTSDKUTILS_DLL_EXPORT
#define MTSDKUTILS_DLL_EXPORT __declspec( dllimport )
#endif // MTSDK_DLL_EXPORT
#endif

#ifdef UNIX 
#undef MTSDKUTILS_DLL_EXPORT
#define MTSDKUTILS_DLL_EXPORT /* nothing */
#endif

//================================================================================================
// MTImportObject  
//================================================================================================

class MTSDKUTILS_DLL_EXPORT MTImportObject

{
public:
			MTImportObject();
			MTImportObject(const MTImportObject & theOther);
	virtual MTMeterError *  GetLastErrorObject () const;

protected:
	MTImportObjectImp * pImportObject;
};

//================================================================================================
// MTImporter 
//================================================================================================
/*
 * @class:
 * The MTImporter object is the parsing engine which can meter
 * one or more <c MTImportSource> objects.
 * .
 */

class MTSDKUTILS_DLL_EXPORT MTImporter : public MTImportObject
{
// @access Public:
public:
	// @cmember,mfunc
	//   Constructor.  Construct a <c MTImporter> object. 
	// @@parm
	//   A <c MTImportSource> object to be processed. For compounds, the <c MTImportSource> 
	//   must refer to the parent file.
	// @@parm
	//   A <c MTMeter> object to be used for metering. It must be constructed and properly  
	//   initialized.
					MTImporter (MTImportSource & theParent , MTMeter	* Meter);
	// @cmember,mfunc
	//   Destructor.  Destruct a <c MTImporter> object. 
	virtual			~MTImporter();
	// @cmember,mfunc
	//   Adds a child <c MTImporter> object as a child of the parent which was
	//   specified during construction.
	// @@parm
	//   A <c MTImportSource> object to be processed as a child. 
	virtual	BOOL	AddChild (MTImportSource & theChild);
	// @cmember,mfunc
	//   Meters the <c MTImporter> objects which were previously specified. 
	virtual	BOOL	Meter();
	// @cmember,mfunc
	//   Obtains the number of parent records processed during the last <mf MTImporter.Meter>
	//   call.
	// @@rdesc The number of parent records processed.
	virtual	long	ParentRecordCount() const;
	// @cmember,mfunc
	//   Obtains the number of child records processed during the last <mf MTImporter.Meter>
	//   call.
	// @@rdesc The number of child records processed for all parents.
	virtual	long	ChildRecordCount() const ;
	// @cmember,mfunc
	//   Specifies the complete path and file name for a file to be used to maintain the
	//   status of records as they are metered.
	// @@parm
	//   The full path and file name for the status file.
	// @@rdesc Returns TRUE if successful, FALSE otherwise.
	virtual	BOOL	MeterJournal(const char * FileName);
	// @cmember,mfunc
	//   This method is called when a parent session has been closed. The default implementation
	//   does nothing. Derived class may provide alternate implementations such as its own status
	//   tracking scheme.
	// @@parm
	//   A pointer to <c MTMeterSession> object which represents the session as it was
	//   passed into the MetraTech Metering SDK.
	// @@parm
	//   A status flag that indicates the outcome from closing the session.
	// @@rdesc Informs the parsing engine as to whether to continue processing.
	virtual	BOOL	ParentComplete (MTMeterSession * pParent, BOOL bStatus) const;
	// @cmember,mfunc
	//   This method is called when a child session has been closed. The default implementation
	//   does nothing. Derived class may provide alternate implementations such as its own status
	//   tracking scheme.
	// @@parm
	//   A pointer to <c MTMeterSession> object which represents the parent session as it was
	//   passed into the MetraTech Metering SDK.
	// @@parm
	//   A pointer to <c MTMeterSession> object which represents the child session as it was
	//   passed into the MetraTech Metering SDK.
	// @@parm
	//   A status flag that indicates the outcome from closing the session.
	// @@rdesc Informs the parsing engine as to whether to continue processing.
	virtual BOOL	ChildComplete (MTMeterSession * pParent, MTMeterSession * pChild, BOOL bStatus) const;

protected:
	MTImporter(const MTImporter & theOther);

private:
	MTImporterImp * pImporter;
};

//================================================================================================
// MTImportSource  
//================================================================================================
/*
 * @class
 * The <c MTImportSource> object represents an actual physical file to be processed.
 *
 * 
 */

class MTSDKUTILS_DLL_EXPORT MTImportSource : public  MTImportObject
{
// @access Public:
public:
	// @cmember,mfunc
	//   Constructor.  Construct a <c MTImportSource> object. <mf MTImportSource.InitializeInput> or  
	//	 <mf MTImportSource.InitializeOutput> must be called before any of the other 
	//   methods can be invoked.
						MTImportSource();
	// @cmember,mfunc
	//   Destructor.  Destruct a <c MTImportSource> object. Its <c MTImportConfig> object
	//   is destructed.
	virtual				~MTImportSource();
	// @cmember,mfunc
	//   Prepares a  <c MTImportSource> object for use as an input source.
	// @@parm
	//   An XML file which describes the file to be processed.
	// @@parm
	//   The input file to be processed.
	virtual	BOOL		InitializeInput (const char * configfile, const char * FileName);	
	// @cmember,mfunc
	//   Prepares a  <c MTImportSource> object for use as an input source where the 
	//   configuration is created programatically.
	// @@parm
	//   A <c MTImportConfig> object which was created programatically.
	// @@parm
	//   The input file to be processed.
	virtual	BOOL		InitializeInput (MTImportConfig &, const char * FileName);		
	// @cmember,mfunc
	//   Prepares a  <c MTImportSource> object for use as an output source.
	// @@parm
	//   The output file name to be written.
	virtual	BOOL		InitializeOutput (const char * FileName);						
	// @cmember,mfunc
	//   Reads the next record from the <c MTImportSource> input source.
	// @@parm
	//   The <c MTRecord> object that represents the physical record from the record source.
	// @@rdesc Indicates the success or failure of the operation.
	virtual	BOOL		Read (MTRecord * & Record);										
	// @cmember,mfunc
	//   Reads the next record from the <c MTImportSource> input source within the specified 
	//   key range. This method is incompatible with unsorted files. Records with keys less 
	//   than the fromKey parameter are skipped.
	// @@parm
	//   The <c MTRecord> object that represents the physical record from the record source.
	// @@parm 
	//   The starting key in the range of keys to be read. 
	// @@parm 
	//   The ending key in the range of keys to be read
	// @@rdesc Indicates the success or failure of the operation.
	virtual	BOOL		Read (MTRecord * & Record, const char * fromKey, const char * toKey);																		
	// @cmember,mfunc
	//   Writes the specified record from the <c MTImportSource> output source as described 
	//   by the <c MTRecord> object parameter. 
	// @@parm
	//   The <c MTRecord> object that contains the data and output format to be written
	// @@rdesc Indicates the success or failure of the operation.
	virtual	BOOL		Write (MTRecord & Record);										
	// @cmember,mfunc
	//   Maps fields from an <c MTRecord> object to a <c MTMeterSession> object.  
	// @@parm
	//   The <c MTMeterSession> object to receive the <c MTRecord> fields.
	// @@parm
	//   The <c MTRecord> object to be mapped.
	// @@rdesc Indicates the success or failure of the operation.
	virtual	BOOL		Meter (MTMeterSession * apParent, MTRecord & Record);			
  // @cmember,mfunc
	//   The <mf MTRecord.PreRead> method is called before a physical read occurs. This allows
	//   a derived class to programatically alter the record before it is read.
	// @@parm
	//   The <c MTRecord> object which is about to be read.
	// @@rdesc Indicates whether the implementation should continue with the read operation
	virtual BOOL		PreRead (MTRecord &);
	// @cmember,mfunc
	//   The <mf MTRecord.PostRead> method is called after the physical read occurs. This allows
	//   a derived class to programatically alter the record after it is read.
	// @@parm
	//   The <c MTRecord> object which has just been read.
	// @@parm
	//   A boolean value which indicates the outcome of the read operation.
	// @@rdesc Indicates whether the implementation should continue processing.
	virtual BOOL		PostRead (MTRecord &, BOOL);
	// @cmember,mfunc
	//   The <mf MTRecord.PreWrite> method is called before a physical write occurs. This allows
	//   a derived class to programatically alter the record before it is written.
	// @@parm
	//   The <c MTRecord> object which is about to be written.
	// @@rdesc Indicates whether the implementation should continue with the write operation
	virtual BOOL		PreWrite (MTRecord &);
	// @cmember,mfunc
	//   The <mf MTRecord.PostWrite> method is called after the physical write occurs. This allows
	//   a derived class be informed as to the outcome of write operations.
	// @@parm
	//   The <c MTRecord> object which has just been written.
	// @@parm
	//   A boolean value which indicates the outcome of the write operation.
	// @@rdesc Indicates whether the implementation should continue processing.
	virtual BOOL		PostWrite (MTRecord &, BOOL);

							operator MTImportSourceImp *();
protected:
	MTImportSource(const MTImportSource & theOther);

private:	
	MTImportSourceImp * pSource;
};


//================================================================================================
// MTImportConfig  
//================================================================================================
/*
 * @class
 * The <c MTImportConfig> object contains the configuration objects necessary
 * to perform the parsing operation. This is the in memory representation of the XML
 * configuration files.
 */

class MTSDKUTILS_DLL_EXPORT MTImportConfig : public MTImportObject
{
// @access Public:
public:
	// @cmember,mfunc
	//   Constructor.  Construct a <c MTImportConfig> object.   
					MTImportConfig();
	// @cmember,mfunc
	//   Destructor.  Destruct a <c MTImportConfig> object. All of it's contained objects are 
	//   destroyed as well.
	virtual			~MTImportConfig();
	// @cmember,mfunc
	//   Adds a <c MTRecord> object to the configuration. 
	// @@parm
	//	 The <c MTRecord> object to be added.
	// @@parm
	//	 A flag to indicate if this is the default format to be applied. When a record is
	//   intially read, the default format is applied. This is used to identify the logical 
	//   record type when multiple types exist in the same input source.
	virtual	BOOL	AddRecordFormat (MTRecord &, BOOL bDefault=FALSE);
	// @cmember,mfunc
	//   Reads the configuration from a file. Derived classes may override this method in order
	//   to extend functionality or read the configuration from an alternate source.
	// @@parm
	//	 The file name containing the configuration.
	// @@rdesc Returns a boolean to indicate the outcome of the operation.
	virtual BOOL	ReadConfiguration(const char * aFilename);
	// @cmember,mfunc
	//	 Verifies that the configuration is valid by calling the <mf object.validate> method
	//   on all of its sub objects.
	// @@rdesc Returns a boolean to indicate whether the configuration is valid.	
	virtual BOOL	Validate();
					operator MTImportConfigImp *();

protected:
	MTImportConfig(const MTImportConfig & theOther);

private:
	MTImportConfigImp *	pConfig;
};

//================================================================================================
// MTRecord  
//================================================================================================
/*
 * @class
 * The <c MTRecord> object contains a both the map of fields within a record and
 * the data values for each field.
 * 
 */

class MTSDKUTILS_DLL_EXPORT MTRecord  : public MTImportObject
{
// @access public:
public:
	// @cmember,mfunc
	//   Constructor.  Construct the minimum <c MTRecord> object. The record name should 
	//   unique when added to a <c MTImportConfig> object.
	// @parm 
	//   The name of record.
						MTRecord(const char * arName);
						MTRecord(MTRecordImp * pRecord, BOOL bOwns = TRUE);
	// @cmember,mfunc
	//   Destructor.  Destruct <c MTRecord> object. Its subojects are destroyed. 
	virtual				~MTRecord();

	// @cmember,mfunc
	//   Copy Constructor.  Construct a copy of the <c MTRecord> object. A deep copy
	//   of the object is made.
	// @parm 
	//   The MTRecord to be copied
						MTRecord(const MTRecord & theOther);
						operator MTRecordImp *();
	// @cmember,mfunc
	//	 Add a fixed length field to the end of the record 
	// @@parm
	//   The <c MTFixedField> object to be added.
	// @@parm
	//   The flag which indicates if this field is the record's key.
	// @@rdesc
	//	 A boolean value which indicates the outcome of the operation. 
			BOOL		AppendField(MTFixedField &, BOOL bIsKey = FALSE);		
	// @cmember,mfunc
	//	 Add a Delimited length field to the end of the record. Delimited fields are
	//   read in the order in which they are added to the record.
	// @@parm
	//   The <c MTDelMTedField> object to be added.
	// @@parm
	//   The flag which indicates if this field is the record's key.
	// @@rdesc
	//	 A boolean value which indicates the outcome of the operation. 
			BOOL		AppendField(MTDelimitedField &, BOOL bIsKey = FALSE);	
	// @cmember,mfunc
	//	 Add a field to the record as the logical field number specified. This method
	//   has not yet been implemented.
	// @@parm
	//   The logical or ordinal field number in the record.
	// @@parm
	//   The flag which indicates if this field is the record's key.
	// @@rdesc
	//	 A boolean value which indicates the outcome of the operation. 
			BOOL		InsertField (int, MTField &);						
	// @cmember,mfunc
	//	 Deletes a field from the record with a given name. This method
	//   has not yet been implemented.
	// @@parm
	//   The name of the field.
	// @@rdesc
	//	 A boolean value which indicates the outcome of the operation. 
			BOOL		DeleteField (const char *);							
	// @cmember,mfunc
	//	 Locates a field with a given name within a record. This is especially useful
	//   for performing custom processing during file event processing as it provides
	//   a location independent way of locating a field.
	// @@parm
	//   The name of the field.
	// @@rdesc
	//	 A pointer to a <c MTField> object repsenting the field or NULL if the
	//   field was not found.  
			MTField * 	FindField (const char *) const;							
	// @cmember,mfunc
	//	 Locates a field with a given ordinal position within a record. 
	// @@parm
	//   Ordinal position within the record.
	// @@rdesc
	//	 A pointer to a <c MTField> object repsenting the field or NULL if the
	//   parameter was out of range.
			MTField *	Field (unsigned int Ordinal) const;					
	// @cmember,mfunc
	//	 Returns the number of fields within a record. 
	// @@rdesc
	//	 The number of fields in the record.
			int			FieldCount () const;										
	// @cmember,mfunc
	//   Obtains the service name to be used when metering this record.
	// @@parm
	//	 Buffer in which to copy the service name.
	// @@parm
	//	 The length of the buffer. If zero, the length of the name is returned
	//   without being copied to the buffer.
	// @@rdesc
	//   If the Length parameter is zero, the length of the name is returned. Otherwise
	//   the number of bytes copied into the buffer is returned.
			int			Service(char *, int) const;						
	// @cmember,mfunc
	//   Sets the service name to be used when metering this record.
	// @@parm
	//	 Buffer containing the service name.
			void		Service(const char *);								
	// @cmember,mfunc
	//   Obtains the record key value..
	// @@parm
	//	 Buffer in which to copy the value.
	// @@parm
	//	 The length of the buffer. If zero, the length of the name is returned
	//   without being copied to the buffer.
	// @@rdesc
	//   If the Length parameter is zero, the length of the name is returned. Otherwise
	//   the number of bytes copied into the buffer is returned.
			int			Key(char *, int) const;								
	// @cmember,mfunc
	//   Specifies the key field within the record.
	// @@parm
	//	 Pointer to the field which should be used as the key.
			void		Key(MTField * pField);
	// @cmember,mfunc
	//	  Specifies a list of characters to remove from the front of a field value
	// @@parm
	//    The list of characters to remove.
			void		StripLeading(const char *);							
	// @cmember,mfunc
	//	  Specifies a list of characters to remove from the end of a field value
	// @@parm
	//    The list of characters to remove.
			void		StripTrailing(const char *);					
	// @cmember,mfunc
	//   Obtains the list of leading characters to strip.
	// @@parm
	//	 Buffer in which to copy the value.
	// @@parm
	//	 The length of the buffer. If zero, the length of the name is returned
	//   without being copied to the buffer.
	// @@rdesc
	//   If the Length parameter is zero, the length of the name is returned. Otherwise
	//   the number of bytes copied into the buffer is returned.
			int			StripLeading(char *, int) const;
	// @cmember,mfunc
	//   Obtains the list of trailing characters to strip.
	// @@parm
	//	 Buffer in which to copy the value.
	// @@parm
	//	 The length of the buffer. If zero, the length of the name is returned
	//   without being copied to the buffer.
	// @@rdesc
	//   If the Length parameter is zero, the length of the name is returned. Otherwise
	//   the number of bytes copied into the buffer is returned.
			int			StripTrailing(char *, int) const;
	// @cmember,mfunc
	//   Obtains the record start key value..
	// @@parm
	//	 Buffer in which to copy the value.
	// @@parm
	//	 The length of the buffer. If zero, the length of the name is returned
	//   without being copied to the buffer.
	// @@rdesc
	//   If the Length parameter is zero, the length of the name is returned. Otherwise
	//   the number of bytes copied into the buffer is returned.			
			int			FromKey(char *, int) const;											
	// @cmember,mfunc
	//   Obtains the record end key value..
	// @@parm
	//	 Buffer in which to copy the value.
	// @@parm
	//	 The length of the buffer. If zero, the length of the name is returned
	//   without being copied to the buffer.
	// @@rdesc
	//   If the Length parameter is zero, the length of the name is returned. Otherwise
	//   the number of bytes copied into the buffer is returned.			
			int			ToKey(char *, int) const;
	// @cmember,mfunc
	//   Specifies the starting key field within the record.
	// @@parm
	//	 Pointer to the field which should be used as the starting key.
			void		FromKey(MTField &);
	// @cmember,mfunc
	//   Specifies the endkey field within the record.
	// @@parm
	//	 Pointer to the field which should be used as the end key.
			void		ToKey(MTField &);
	// @cmember,mfunc
	//   Compute the values for all fields in the record which are computed from
	//   other fields. This method is normally called internally.
			BOOL		ComputeFields ();
	// @cmember,mfunc
	//   Validate that the records configuration values are legal.
	// @@rdesc 
	//   Returns a value to indicate the success of the operation.
	virtual BOOL		Validate();


private:
	MTRecordImp * pRecord;
	BOOL mbOwns;
};	


//================================================================================================
// MTField  
//================================================================================================

/*
 * @class
 * The MTField object serves as a base class for fields contained in
 * a <c MTRecord> object.
 * .
 */

class MTSDKUTILS_DLL_EXPORT MTField : public MTImportObject
{
// @access Public:
public:
	// @cmember,menum
	//   Field formats supported. 
	enum FieldFormat
	{
		FieldFormatUnknown = 0,
		FieldFormatFixed = 1,
		FieldFormatDelimited = 2
	};
	// @cmember,mfunc
	//   Constructor.  Construct the minimum <c MTField> object.
	// @@parm
	//   The name of the field which must be unique within a <c MTRecord> object.
	// @@parm
	//   The format of the field within a record. The default value is FieldFormatUnknown
	//   which will not be read or written.
						MTField(const char * aName, FieldFormat aFormat);
	// @cmember,mfunc
	//   Constructor.  Construct <c MTField> object including a MeterProperty name.
	// @@parm
	//   The name of the field which must be unique within a <c MTRecord> object.
	// @@parm
	//   The format of the field within a record. The default value is FieldFormatUnknown
	//   which will not be read or written.
	// @@parm
	//   The SDK property name to be used when metering this field. A blank value will
	//   cause this field to not be metered.
						MTField(const char * aName, FieldFormat aFormat, const char * aMeterProperty);
	// @cmember,mfunc
	//   Destructor.  
	virtual				~MTField();
	// @cmember,mfunc
	//   Specifies the field's ordinal position within the record.
	// @@rdesc
	//   none.
	virtual	void		Ordinal(int Val);	
	// @cmember,mfunc
	//   Obtains the field's ordinal position within the record.
	// @@rdesc
	//   The field's ordinal position (1 based)
	virtual	int 		Ordinal() const;
	// @cmember,mfunc
	//   Obtains the field's name.
	// @@parm
	//	 Buffer in which to copy the field's name.
	// @@parm
	//	 The length of the buffer. If zero, the length of the name is returned
	//   without being copied to the buffer.
	// @@rdesc
	//   If the Length parameter is zero, the length of the name is returned. Otherwise
	//   the number of bytes copied into the buffer is returned.
	virtual	int			Name (char * szName, int Length) const;
	// @cmember,mfunc
	//   Set the field's name.
	// @@parm
	//	 Buffer containing the name.
	virtual	void		Name(const char *);	
	// @cmember,mfunc
	//   Obtains the field's value.
	// @@parm
	//	 Buffer in which to copy the field's value.
	// @@parm
	//	 The length of the buffer. If zero, the length of the name is returned
	//   without being copied to the buffer.
	// @@rdesc
	//   If the Length parameter is zero, the length of the name is returned. Otherwise
	//   the number of bytes copied into the buffer is returned.
	virtual	int			Value(char * szValue, int Length) const;
	// @cmember,mfunc
	//   Set the field's value.
	// @@parm
	//	 Buffer containing the value.
	virtual	void		Value(const char * szValue);	
	// @cmember,mfunc
	//   Obtains the field's meterproperty name.
	// @@parm
	//	 Buffer in which to copy the field's meterproperty name.
	// @@parm
	//	 The length of the buffer. If zero, the length of the name is returned
	//   without being copied to the buffer.
	// @@rdesc
	//   If the Length parameter is zero, the length of the name is returned. Otherwise
	//   the number of bytes copied into the buffer is returned.
	virtual	int			MeterProperty (char * szName, int Length) const;
	// @cmember,mfunc
	//   Set the field's meterproperty name.
	// @@parm
	//	 Buffer containing the value.
	virtual	void		MeterProperty(const char * szName);	
	// @cmember,mfunc
	//   Set the field's Input flag. If FALSE, the field is not extracted from the
	//   input record. The default value is TRUE.
	// @@parm
	//	 Flag containing the value.
	virtual	void		Input(BOOL bRead);
	// @cmember,mfunc
	//   Gets the field's Input flag. 
	// @@rdesc 
	//   Boolean value indicating whether the field's input flag is set.
	virtual	BOOL		Input() const;
	// @cmember,mfunc
	//   Set the field's output flag. If FALSE, the field is not included in the
	//   output record. The default value is TRUE.
	// @@parm
	//	 Flag containing the value.
	virtual	void		Output(BOOL bRead);
	// @cmember,mfunc
	//   Gets the field's Output flag. 
	// @@rdesc 
	//   Boolean value indicating whether the field's output flag is set.
	virtual	BOOL		Output() const;
	// @cmember,mfunc
	//   Gets the field's Format as defined by the fieldformat enumerated type. 
	// @@rdesc 
	//   The fields format enumerated type.
	virtual	FieldFormat	Format() const;
	// @cmember,mfunc
	//   Validates that the field contains legal properties. 
	// @@rdesc 
	//   Boolean which indicates whether the field contains valid parameter values.
	virtual BOOL		Validate();
	// @cmember,mfunc
	//   Gets the field's Meter Type as defined by the MTMeterSession::SDKPropertyTypes 
	//   enumerated type. 
	// @@rdesc 
	//   The fields Meter Property enumerated type.
	virtual	MTMeterSession::SDKPropertyTypes 
						Type() const;
	// @cmember,mfunc
	//   Sets the field's Meter Type as defined by the MTMeterSession::SDKPropertyTypes 
	//   enumerated type. 
	// @@parm 
	//   The fields Meter Property enumerated type.
	virtual	void		Type(MTMeterSession::SDKPropertyTypes);
	// @cmember,mfunc
	//   Sets the field's Meter Type as defined by the MTMeterSession::SDKPropertyTypes 
	//   enumerated type using a string representation of the type
	// @@parm 
	//   The fields Meter Property as a string (ie "int32").
	virtual	BOOL		Type(const char * szType);
	// @cmember,mfunc
	//   Computes the field's value it obtained via one of the builtin functions 
	//   enumerated type. 
	// @@rdesc 
	//   Boolean which indicates if the computation succeeded.
	virtual BOOL		ComputeValue (MTRecord & );

						operator MTFieldImp *();
						MTField(MTFieldImp * pField);
protected:
						MTField(const MTField & theOther);

protected:
	MTFieldImp * pField;
};


//================================================================================================
// MTFixedField  
//================================================================================================
/*
 * @class
 * The <c MTFixedField> object controls how an individual field within a record is  .
 * processed. It also contains the field's value. Fixed fields start at a given byte offset
 * within the record and our of a fixed length.
 */

class MTSDKUTILS_DLL_EXPORT MTFixedField : public MTField
{
// @access Public:
public:
	// @cmember,mfunc
	//   Constructor.  Construct a <c MTFixedField> object.
	// @@parm
	//   Name of the field. This should be unique within its contained record.
	// @@parm
	//   The position (byte offset) within the record. This is zero based.
	// @@parm
	//   The fixed Length of the field. This is the number of bytes to extract at the
	//   given position.
	// @@parm
	//   The property name to meter this field as. A null value indicates that this field
	//   will not be metered.
					MTFixedField(const char * arName, int Position, int Length, 
																	const char * arPropName);
	// @cmember,mfunc
	//   Destructor.  Destructs a <c MTFixedField> object.
	virtual			~MTFixedField();
	// @cmember,mfunc
	//   Sets the field's fixed position within the data record.
	// @@parm
	//   The fixed position.
			void	Position(int);		
	// @cmember,mfunc
	//   Gets the field's fixed position within the data record.
	// @@rdesc
	//   Returns the fixed position.
			int 	Position() const;
	// @cmember,mfunc
	//   Sets the field's fixed length within the data record.
	// @@parm
	//   The fixed field length.
			void	Length(int);		
	// @cmember,mfunc
	//   Gets the field's fixed length within the data record.
	// @@rdesc
	//   Returns the fixed length.
			int		Length() const;
	// @cmember,mfunc
	//   Validates the field's parameter values.
	// @@rdesc
	//   Boolean which indicates the validity of the field's configuration.
	virtual BOOL	Validate();

					operator MTFixedFieldImp *();
protected:
					MTFixedField(const MTFixedField & theOther);

private:
	MTFixedFieldImp * pField;
};


//================================================================================================
// MTDelimitedField  
//================================================================================================
/*
 * @class
 * The <c MTDelMTedField> object controls how an individual field within a record is  .
 * processed. It also contains the field's value. Delimited fields a seperated
 * by a single character value.
 */

class MTSDKUTILS_DLL_EXPORT MTDelimitedField : public MTField
{
// @access Public:
public:
	// @cmember,mfunc
	//   Constructor.  Construct a <c MTDelimitedField> object.
	// @@parm
	//   Name of the field. This should be unique within its contained record.
	// @@parm
	//   The character indicates the end of this field.
					MTDelimitedField(const char * arName, char Delimiter);
	// @cmember,mfunc
	//   Destructor.  Destructs a <c MTDelimitedField> object.
	virtual			~MTDelimitedField();
	// @cmember,mfunc
	//   Sets the field's delMTer.
	// @@parm
	//   The the Delimiter.
			void	Delimiter(char);	
	// @cmember,mfunc
	//   Gets the field's Delimiter within the data record.
	// @@rdesc
	//   Returns the Delimiter.
			char	Delimiter() const;
	// @cmember,mfunc
	//   Validates the field's parameter values.
	// @@rdesc
	//   Boolean which indicates the validity of the field's configuration.
	virtual BOOL	Validate();

					operator MTDelimitedFieldImp *();
protected:
					MTDelimitedField(const MTDelimitedField & theOther);

private:
	MTDelimitedFieldImp * pField;
};



#endif /* _MTMETERUTILS_H */
