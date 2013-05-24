/*!
 * \file stda.h
 *
 * \ingroup fwk
 * \ingroup api
 *
 * Vertex Communications Tax (CTQ) Q Series
 *
 * Copyright &copy; 2003-2008 by Vertex, Incorporated All Rights Reserved.
 *
 * \brief CTQ Standard Data Types and Definitions
 */
/* History:
 * - 20030527 JLH: Initial shell.
 * - 20030609 JLH: Renamed and reorganized as part of the framework adoption.
 * - 20030613 WD:  Added standard documentation. Renamed some attributes to conform
 *                 to naming convention and to correct spelling.
 * - 20030617 WD:  Added transaction object attributes.
 * - 20030619 WD:  Added support for Configuration Object database connection attributes.
 * - 20030619 JLH: Added location value attributes.
 * - 20030625 WD:  Added Customization definitions and attributes.
 * - 20030626 LLH: Added some Rate definitions and attributes.
 * - 20030627 JLH: Added tCtqLogEvent && tCtqLogData for logging.
 * - 20030701 AR:  Added some Decision and MaxTier definitions.
 * - 20030702 WD:  Attribute consolidation. Added attributes.
 * - 20030708 AR:  Added attributes for Decision
 * - 20030708 JLH: Changed eCtqAttribName to eCtqAttribConfigurationName 
 * - 20030711 DTC: Added eCtqResultInvalidDbConnectionName and eCtqResultXMLParseMaxDB
 * - 20030724 AR:  Added constants and attributes for Decision and MaxTier
 * - 20030730 DTC: Fixed Doxygen comment on Solaris
 * - 20030730 DTC: replaced ? with 255 for CTQ_PATH_LEN and CTQ_FILE_NAME_LEN for UNIX
 * - 20030731 LLH: Added 'eCtqAttribTaxableAmount' to 'tCtqAttrib'.
 * - 20030804 DTC: Modified Doxygen comment, removed compiling warnings/errors for Solaris.
 * - 20030806 JLH: Modified for to Doxygen Qt style documentation generation.
 * - 20030807 PLC: Added CTQ_YEAR_LEN, CTQ_KEY_TYPE_LEN, CTQ_ACCUMULATOR_REFERENCE_LEN, CTQ_TAX_CODE_LEN
 * - 20030807 PLC: Added Reference to RegJrn
 * - 20030808 PLC: New handle attribute enumerators for RegJrn
 * - 20030811 PLC: New handle attribute enumerators for RegAcc
 * - 20030811 PLC: New handle enumerators for RegAccPer
 * - 20030818 PLC: Update Attributes for Parent child relation in Reg Journal
 * - 20030818 PLC: Add eCtqAttribLinkTaxAmount
 * - 20030818 DTC: Removed extra "," from tCtqAttribType
 * - 20030818 JLH: Added file name attribute for register reports
 * - 20030819 JLH: Added new file control and page length configuration attributes
 * - 20030820 LLH: Removed 'eCtqHandleTrn'.
 * - 20030822 LLH: Added enumerations for published code values.
 * - 20030827 PLC: New handle attribute enumerators for RegJtx
 * - 20030827 LLH: Added 'eCtqHandleRegTax' to the list of system attributes.
 * - 20030827 PLC: Added enum handles for RteDdl and RteRdd
 * - 20030828 LLH: Removed 'eCtqAttribLinkedTaxAmount' ('eCtqAttribLinkTaxAmount' already in use).
 * - 20030828 LLH: Removed 'eCtqAttribTaxRate' ('eCtqAttribRate' already in use).
 * - 20030828 PLC: Added eCtqHandleRteDdd
 * - 20030904 WD:  Eliminated enumerations: eCtqAttribAuthorityLevel, eCtqAttribResaleFlag
 * - 20030904 WD:  Increased USER_AREA_LEN from 20 to 40
 * - 20030904 JLH: Added error codes and attributes in support of record sequence number generation
 * - 20030908 PLC: Added Enumerations for Efective Date
 * - 20030918 JLH: Changed all references to BOOL to tCtqBool
 * - 20030922 WD:  Added enumerations for Max Tier row identifiers.
 * - 20030922 DTC: Removed "//" style comment for eCtqAttribAuthorityLevel.
 * - 20030926 WD:  Replaced assorted sequence and identification attributes with the standard
 *                 eCtqAttribId and eCtqAttribParentId.
 * - 20030929 LLH: Added attribute comments; removed 'eCtqAttribTaxCount' and 'eCtqAttribTaxIndex'.
 * - 20030930 JLH: Removed eCtqAttribLinesBilled (in favor of eCtqAttribBilledLines)
 *                 Removed eCtqAttribTaxedIncorporatedCode
 *                 Removed eCtqAttribTaxableMinutes
 * - 20030930 LLH: Removed eCtqAttribRegulatedCode.
 * - 20030930 DTC: Added type cast for Forte C++.
 * - 20031002 WCC: Added eCtqCriteriaStartReference
 *                 Added eCtqCriteriaEndReference
 *                 Added eCtqCriteriaStartGeoCode
 *                 Added eCtqCriteriaEndGeoCode
 *                 Added eCtqCriteriaStartYear
 *                 Added eCtqCriteriaEndYear
 * - 20031002 JLH: Added reporting persister handles.
 * - 20031003 WD:  Added tCtqTaxAuthority enumeration.
 * - 20031003 AR:  Updated CTQ_ACCUMULATOR_REFERENCE_LEN and removed some duplicate definitions.
 * - 20031009 JLH: Added eCtqResultRejectedValue
 * - 20031010 LLH: Added 'eCtqTaxAuthorityUnincorpArea' to 'tCtqTaxAuthority'.
 * - 20031010 WD:  Added support for specifying a sort order for retrieved object instances.
 * - 20031014 LLH: Added 'eCtqTaxTypeUtilitySalesTax' to 'tCtqTaxType'.
 * - 20031023 JLH: Added new accumulator attributes to match new accumulator table structure.
 * - 20031028 JLH: Split eCtqAttribAccrualTimeStamp in to eCtqAttribAccrualYear and eCtqAttribAccrualMonth
 * - 20031031 LLH: Added macro definitions for partial GeoCode lengths and changed the way that
 *                 'CTQ_GEOCODE_LEN' is defined.
 * - 20031107 AR:  Added eCtqHandleRegAdd
 * - 20031112 LLH: Removed unused macros.
 * - 20031113 DTC: Removed "//" style comment.
 * - 20031113 LLH: Added enumerated values for 'RecordActive' and 'RecordCreator' attributes.
 * - 20031120 JLH: Added eCtqResultHelpSwitch
 * - 20031121 WD:  Removed eCtqAttribBatchFilePath. Its function is performed by the
 *                 eCtqAttribPath and eCtqAttribFileName combination.
 * - 20031125 WD:  Added support for eCtqAttribOriginIncorporatedCode,
 *                 eCtqAttribTerminationIncorporatedCode and eCtqChargeToIncorportedCode.
 *                 Renamed eCtqAttribIncorporatedCode as eCtqAttribTaxedGeoCodeincorporatedCode.
 * - 20031201 AR:  Added eCtqResultNoParentRecords
 * - 20031202 WD:  Added support for RegJrd object.
 * - 20031202 WD:  Added support for eCtqAttribFileFormat and eCtqAttribFileDelimiter.
 * - 20031209 DTC: Removed the unnecessary ',' which casued error on AIX43.
 * - 20031218 LLH: Bumped up the enumerated values for existing CTQ result codes to make room for
 *                 return values that match those of the L Series calc engine.
 * - 20031231 WD:  Added support for the concept of "Attribute State".
 * - 20040105 LLH: Updated result code interpretaion table for 'eCtqResultNoMaxTierData'.
 * - 20040108 JLH: Added cache and hash table attributes
 * - 20040112 JLH: Added two new attrbute types to tCtqAttribType and 5 attributes for hash tables
 * - 20040116 LLH: Added two more L Series result codes related to description flag processing
 * - 20040119 JLH: Added locking failure result codes
 * - 20040119 JLH: Removed defunct attribute comment
 * - 20040120 JLH: Realigned Cache and Hash Table attributes
 * - 20040120 JLH: Took care of a couple of clean up "To Do" items & other Doxygen related clean ups
 * - 20040122 JLH: Added 4 error descriptions that I neglected to include in previous changes
 * - 20040123 JLH: Added result code eCtqResultRecordReplaced
 * - 20040127 PLC: Added eCtqAttribCustomerOverride so program can determine if a RegTax was input or
 *                 created from the db.
 * - 20040130 JLH: Added eCtqResultAlreadyInitialized
 * - 20040212 LLH: Added 'eCtqHandleRegBsc'.
 * - 20040219 JLH: Added eCtqCriteriaPrimaryDescription and eCtqAttribGeoLevel
 * - 20040222 JLH: Added cache statistic attributes
 * - 20040227 PLC: Fixed typo
 * - 20040229 JLH: Modified logging to conform to the revised logging parameter standards.
 * - 20040303 PLC: Added eCtqHandleRteMaxWorkspace, which is part of a workaround for caching allocation, used in regtrnil.c
 * - 20040305 LLH: Added 'eCtqResultNoBundleDefinition = 90' for compatiblity with a corresponding L Series error condition.
 * - 20040309 LLH: Began updating Doxygen comments for character based attributes to include their defined size.
 * - 20040310 LLH: Finished updating Doxygen comments for character based attributes to include their defined size.
 * - 20040312 WD:  Added eCtqAttribDFCx equivalent attributes for bacward compatibility.
 * - 20040315 WD:  Changed all references of "Service Package" to "Bundled Service".
 * - 20040315 WD:  Removed eCtqAttribChange attribute.
 * - 20040318 AR:  Added 'eCtqResultMaxTaxesExceeded'
 * - 20040319 WD:  Added support for cache bypass.
 * - 20040413 JLH: Removed CTQ_SQL_MAX_STATEMENT_SIZE && CTQ_SQL_MAX_STATEMENT_LEN (see dbcpera.h)
 * - 20040713 JLH: Added eCtqResultFileRead and eCtqResultFileWrite
 * - 20040720 JLH: Changed eCtqAttribRegisterFlag to eCtqAttribWriteBundleDetailFlag
 * - 20040723 JLH: Added eCtqAttribNone
 * - 20040723 JLH: Added eCtqResultUnexpectedCLISwitchValue and eCtqResultMissingCLISwitchValue
 * - 20031120 JLH: Removed eCtqResultHelpSwitch
 * - 20040923 JLH: Fully implemented the ability to activate/deactivate all caches
 * - 20051017 LLH: Added 'eCtqAttribDFCChangeFlag' to resolve OSR #35156.
 * - 20060105 LLH: Added attributes for the GeoCode range record object.
 * - 20060721 LLH: Added 'eCtqAttribReturnZeroRateTaxes' and 'eCtqResultMisplacedReturnZRT' (OSR #220454)
 * - 20061020 LLH: Added 'eCtqTransactionCodeExempt' to 'tCtqTransactionCode' (OSR #249244)
 * - 20061108 LLH: Added CTQ_CANADIAN_POSTAL_CODE_SIZE (OSR #264634)
 * - 20070212 LLH: Increased macro definitions for InvoiceNumber and CustomerReference from 20 to 40 characters (OSR #179030)
 * - 20070302 LLH: Added CTQ_PACKAGE_DESCRIPTION_SIZE and 'eCtqAttribPackageDescription' (OSR #36634)
 * - 20070508 LLH: Added 'eCtqResultInvalidZip' (OSR #356934)
 * - 20070508 JLH: Added 'eCtqResultNotUnique' for situations where multiple threads/processed attempt to simultaneously
 *                 create a record with a duplicate key within an Accumulator table
 * - 20070601 JLH: Support improved accumulator concurrency
 * - 20080716 JLH: Added sequenceBlockSize, retryInterval and maximumRetries configuration elements
 * - 20081028 LLH: Added new 'DistrictName', 'OverrideTaxType', 'OverrideTaxAuthority', 'AccumAsTaxType',
 *                 'AccumAsTaxAuthority', and 'MaxTaxAmount' attributes; removed 'eCtqAttribFipsCode'.
 * - 20081107 LLH: Added 'eCtqTaxAuthorityCountyDistrict' and 'eCtqTaxAuthorityCityDistrict'.
 * - 20081110 LLH: Added 'eCtqTaxAuthorityOtherMunicipality'.
 * - 20081201 RFS: Added 'eCtqAttribCityDistrictExemptFlag', 'eCtqAttribCountyDistrictExemptFlag', 'eCtqAttribOtherExemptFlag'
 *				   'eCtqAttribTaxedDistrictName'
 * - 20090126 LLH: 'C3CTXUPD' to 'C4CTXUPD' conversion.
 * - 20090213 LLH: Added 'eCtqCriteriaParentGeoCode' and 'eCtqCriteriaChildGeoCode'.
 * - 20090215 LLH: Added 'eCtqAttribLocDghCacheMode'.
 * - 20090223 RFS: Added result code for misplaced cfg element zip4Err (OSR #686914).
 * - 20090224 RFS: Updated cfg version to 2.0 (OSR# 686914).
 * - 20090225 LLH: Added 'eCtqAttribZip4Error' and 'eCtqResultZip4Error'.
 * - 20090520 LLH: Added 'eCtqResultMaxOverridesExceeded' to correspond with L Series result code '02'.
 * - 20060902 RFS: Added a Build number to the version.
 * - 20090820 LLH: Added 'eCtqAttribFranchiseAreaId' to 'tCtqAttrib'.
 * - 20091005 LLH: Removed redundant attribute values for 'accumulate as' tax type and authority.
 * - 20100526 LLH: Changed 'eCtqOrderByGeoCode' (unused) to 'eCtqCriteriaRecordCount'.
 * - 20100601 LLH: Added attribute and result codes for database transaction control.
 * - 20110802 BW : Added result code for eCtqResultInvalidMonthlyUpdateFile for invalid monthly update file.
 *                 Also inserted it into result code array and updated the array total count.
 * - 20110912 BW : Added 'eCtqHandleDbcSeqPer' (for Database Sequence Connection object handle) to 'tCtqAttrib'. (CR 37201) 
 */

#ifndef STDA_H
#define STDA_H

#define PORT_WINDOWS_EXE
/*--------------------------------------------------------------------------
                 Make sure a valid compile option has been set
  --------------------------------------------------------------------------*/

#if !(defined(PORT_WINDOWS_EXE) || \
      defined(PORT_WINDOWS_DLL) || \
      defined(PORT_CONSOLE_EXE) || \
      defined(PORT_UNIXANSI) || \
      defined(PORT_AS400))

#error PORT_WINDOWS_EXE, PORT_WINDOWS_DLL, PORT_CONSOLE_EXE, PORT_UNIXANSI or PORT_AS400 compile option must be defined.

#endif

#include <limits.h>

#if (defined(PORT_WINDOWS_DLL) ||  defined(PORT_WINDOWS_EXE) || defined(PORT_CONSOLE_EXE))

#include <windows.h>

/* Place PREFIX before the type of a public function. */

#define PREFIX __declspec(dllexport) /*!< Windows storage-class information - eliminates the need for a module-definition (.DEF) file */

/* Place POSTFIX before the name of a public function. */

#define POSTFIX __stdcall            /*!< Windows calling convention */

/* File and path string lengths */

#define CTQ_FILE_NAME_LEN 255
#define CTQ_FILE_NAME_SIZE (CTQ_FILE_NAME_LEN + 1)

#define CTQ_PATH_LEN 255
#define CTQ_PATH_SIZE (CTQ_PATH_LEN + 1)

#endif /* PORT_WINDOWS_DLL, PORT_WINDOWS_EXE, PORT_CONSOLE_EXE */

/*---------------------------------------------------------------------------
  Place PORT_UNIXANSI on the compile line of applications that are being
  compiled and linked for the UNIX platform using an ANSI C compiler.
  ---------------------------------------------------------------------------*/

#if defined(PORT_UNIXANSI)

/* Place PREFIX before the type of a public function. */

#define PREFIX  /*!< Not used on UNIX */

/* Place POSTFIX before the name of a public function. */

#define POSTFIX /*!< Not used on UNIX */

/* File and path string lengths */

#define CTQ_FILE_NAME_LEN 255
#define CTQ_FILE_NAME_SIZE (CTQ_FILE_NAME_LEN + 1)

#define CTQ_PATH_LEN 255
#define CTQ_PATH_SIZE (CTQ_PATH_LEN + 1)

#endif /* PORT_UNIXANSI */

/*---------------------------------------------------------------------------
  Place PORT_AS400 on the compile line of applications that are being
  compiled and linked for the AS400 platform using an ANSI C compiler.
  ---------------------------------------------------------------------------*/

#if defined(PORT_AS400)

/* Place PREFIX before the type of a public function. */

#define PREFIX  /*!< Not used on AS/400 */

/* Place POSTFIX before the name of a public function. */

#define POSTFIX /*!< Not used on AS/400 */

/* General type definitions */

/* File and path string lengths */

#define CTQ_FILE_NAME_LEN 255
#define CTQ_FILE_NAME_SIZE (CTQ_FILE_NAME_LEN + 1)

#define CTQ_PATH_LEN 255
#define CTQ_PATH_SIZE (CTQ_PATH_LEN + 1)

#endif /* PORT_AS400 */

#define CTQ_MAX_SIGNED_INT    INT_MAX
#define CTQ_MAX_UNSIGNED_INT  UINT_MAX

#define CTQ_MAX_SIGNED_LONG   LONG_MAX
#define CTQ_MAX_UNSIGNED_LONG ULONG_MAX

#define CTQ_NULL_DATA (void *) -1

#define CTQ_REGJRN_LINE_ITEM_ID_MIN_ROW 0
#define CTQ_REGJRN_LINE_ITEM_ID_MAX_ROW 1

#define CTQ_FILE_FIELD_DELIMITER_LEN 1
#define CTQ_FILE_FIELD_DELIMITER_SIZE (CTQ_FILE_FIELD_DELIMITER_LEN + 1)

#define CTQ_LOG_MESSAGE_LEN 2048
#define CTQ_LOG_MESSAGE_SIZE (CTQ_LOG_MESSAGE_LEN + 1)                /*!< The internal log message character buffer size (including the terminating null) */

#define CTQ_NA_LEN 0
#define CTQ_NA_SIZE 0

#define CTQ_CODE_TYPE_LEN 1
#define CTQ_CODE_TYPE_SIZE (CTQ_CODE_TYPE_LEN + 1)                  /*!< The character buffer size (including the terminating null) of Code Types
                                                                         within the Codes objects */
#define CTQ_CODE_CATEGORY_LEN 2
#define CTQ_CODE_CATEGORY_SIZE (CTQ_CODE_CATEGORY_LEN + 1)          /*!< The character buffer size (including the terminating null) of Code Subtypes or
                                                                         category of codes within the Codes objects. */
#define CTQ_CODE_VALUE_LEN 2
#define CTQ_CODE_VALUE_SIZE (CTQ_CODE_VALUE_LEN + 1)                /*!< The character buffer size (including the terminating null) of Code Values
                                                                         within the Codes objects. */
#define CTQ_FLAG_LEN 1
#define CTQ_FLAG_SIZE (CTQ_FLAG_LEN + 1)                              /*!< The character buffer size (including the terminating null) of flag attribute values */

#define CTQ_CATEGORY_CODE_LEN 2
#define CTQ_CATEGORY_CODE_SIZE (CTQ_CATEGORY_CODE_LEN + 1)            /*!< The character buffer size (including the terminating null) of flag attribute values */

#define CTQ_FUNCTION_CODE_LEN 1
#define CTQ_FUNCTION_CODE_SIZE (CTQ_FUNCTION_CODE_LEN + 1)            /*!< The character buffer size (including the terminating null) of function code attribute values */

#define CTQ_TAX_TYPE_LEN 2
#define CTQ_TAX_TYPE_SIZE (CTQ_TAX_TYPE_LEN + 1)                      /*!< The character buffer size (including the terminating null) of tax type attribute values */

#define CTQ_TAX_AUTHORITY_LEN 1
#define CTQ_TAX_AUTHORITY_SIZE (CTQ_TAX_AUTHORITY_LEN + 1)            /*!< The character buffer size (including the terminating null) of tax authority level attribute values */

#define CTQ_SERVICE_CODE_LEN 2
#define CTQ_SERVICE_CODE_SIZE (CTQ_SERVICE_CODE_LEN + 1)              /*!< The character buffer size (including the terminating null) of service code attribute values */

#define CTQ_RATE_DESCRIPTION_CODE_LEN 1
#define CTQ_RATE_DESCRIPTION_CODE_SIZE (CTQ_RATE_DESCRIPTION_CODE_LEN + 1) /*!< The character buffer size (including the terminating null) of code description attribute values */

#define CTQ_TAX_CODE_LEN 1
#define CTQ_TAX_CODE_SIZE (CTQ_TAX_CODE_LEN + 1)                        /*!< The character buffer size (including the terminating null) of taxable code attribute values */

#define CTQ_TAXABLE_CODE_LEN 1
#define CTQ_TAXABLE_CODE_SIZE (CTQ_TAXABLE_CODE_LEN + 1)                /*!< The character buffer size (including the terminating null) of taxable code attribute values */

#define CTQ_PROPAGATION_CODE_LEN 1
#define CTQ_PROPAGATION_CODE_SIZE (CTQ_PROPAGATION_CODE_LEN + 1)        /*!< The character buffer size (including the terminating null) of propagation code attribute values */

#define CTQ_SUB_CODE_LEN 3
#define CTQ_SUB_CODE_SIZE ( CTQ_SUB_CODE_LEN + 1 )                    /*!< The character buffer size (including the terminating null) of subcode attribute values */

#define CTQ_RECORD_SEQUENCE_LEN 2
#define CTQ_RECORD_SEQUENCE_SIZE ( CTQ_RECORD_SEQUENCE_LEN + 1 )      /*!< The character buffer size (including the terminating null) of sequence attribute values */

#define CTQ_BASE_AMOUNT_LEN 5
#define CTQ_BASE_AMOUNT_SIZE ( CTQ_BASE_AMOUNT_LEN + 1 )              /*!< The character buffer size (including the terminating null) of sequence attribute values */

#define CTQ_SALE_RESALE_CODE_LEN 1
#define CTQ_SALE_RESALE_CODE_SIZE (CTQ_SALE_RESALE_CODE_LEN + 1) /*!< The character buffer size (including the terminating null) of Sale/Resale Code attribute values. */

#define CTQ_MAX_TIER_CODE_LEN 1
#define CTQ_MAX_TIER_CODE_SIZE (CTQ_MAX_TIER_CODE_LEN + 1)

#define CTQ_MAX_CODE_LEN 1
#define CTQ_MAX_CODE_SIZE (CTQ_MAX_CODE_LEN + 1)

#define CTQ_CODE_LEN 2
#define CTQ_CODE_SIZE (CTQ_CODE_LEN + 1)

#define CTQ_SYMBOL_LEN 4
#define CTQ_SYMBOL_SIZE (CTQ_SYMBOL_LEN + 1)

#define CTQ_NAME_LEN 32
#define CTQ_NAME_SIZE (CTQ_NAME_LEN + 1)

#define CTQ_LABEL_LEN 32
#define CTQ_LABEL_SIZE (CTQ_LABEL_LEN + 1)

#define CTQ_VERSION_LEN 8
#define CTQ_VERSION_SIZE (CTQ_VERSION_LEN + 1)

#define CTQ_UPDATE_NUMBER_LEN 7
#define CTQ_UPDATE_NUMBER_SIZE (CTQ_UPDATE_NUMBER_LEN + 1)

#define CTQ_TITLE_LEN 64
#define CTQ_TITLE_SIZE (CTQ_TITLE_LEN + 1)

#define CTQ_VARIABLE_NAME_LEN 64
#define CTQ_VARIABLE_NAME_SIZE (CTQ_VARIABLE_NAME_LEN + 1)

#define CTQ_MESSAGE_LEN 256
#define CTQ_MESSAGE_SIZE (CTQ_MESSAGE_LEN + 1)

#define CTQ_DESCRIPTION_LEN 256
#define CTQ_DESCRIPTION_SIZE (CTQ_DESCRIPTION_LEN + 1)

#define CTQ_CODE_DESCRIPTION_LEN 20
#define CTQ_CODE_DESCRIPTION_SIZE (CTQ_CODE_DESCRIPTION_LEN + 1)

#define CTQ_NOTE_LEN 1024
#define CTQ_NOTE_SIZE (CTQ_NOTE_LEN + 1)

#define CTQ_C4CTXUPD_BUFFER_LEN 1538
#define CTQ_C4CTXUPD_BUFFER_SIZE (CTQ_C4CTXUPD_BUFFER_LEN + 1)

#define CTQ_TEXT_LEN 4096
#define CTQ_TEXT_SIZE (CTQ_TEXT_LEN + 1)

#define CTQ_STATE_GEO_LEN 2
#define CTQ_STATE_GEO_SIZE (CTQ_STATE_GEO_LEN + 1)

#define CTQ_COUNTY_GEO_LEN 3
#define CTQ_COUNTY_GEO_SIZE (CTQ_COUNTY_GEO_LEN + 1)

#define CTQ_CITY_GEO_LEN 4
#define CTQ_CITY_GEO_SIZE (CTQ_CITY_GEO_LEN + 1)

#define CTQ_GEOCODE_LEN (CTQ_STATE_GEO_LEN + CTQ_COUNTY_GEO_LEN + CTQ_CITY_GEO_LEN)
#define CTQ_GEOCODE_SIZE (CTQ_GEOCODE_LEN + 1)

#define CTQ_GEOLEVEL_LEN 1
#define CTQ_GEOLEVEL_SIZE (CTQ_GEOLEVEL_LEN + 1)

#define CTQ_CANADIAN_POSTAL_PREFIX_LEN 3
#define CTQ_CANADIAN_POSTAL_PREFIX_SIZE (CTQ_CANADIAN_POSTAL_PREFIX_LEN + 1)

#define CTQ_CANADIAN_POSTAL_CODE_LEN 6
#define CTQ_CANADIAN_POSTAL_CODE_SIZE (CTQ_CANADIAN_POSTAL_CODE_LEN + 1)

#define CTQ_ZIP_LEN 5
#define CTQ_ZIP_SIZE (CTQ_ZIP_LEN + 1)

#define CTQ_ZIP4_LEN 4
#define CTQ_ZIP4_SIZE (CTQ_ZIP4_LEN + 1)

#define CTQ_ZIPID_LEN 11
#define CTQ_ZIPID_SIZE (CTQ_ZIPID_LEN + 1)

#define CTQ_ZIPPLUS4_LEN 9
#define CTQ_ZIPPLUS4_SIZE (CTQ_ZIPPLUS4_LEN + 1)

#define CTQ_POSTAL_CODE_LEN 9
#define CTQ_POSTAL_CODE_SIZE (CTQ_POSTAL_CODE_LEN + 1)

#define CTQ_DISTRICT_NAME_LEN 60
#define CTQ_DISTRICT_NAME_SIZE ( CTQ_DISTRICT_NAME_LEN + 1 )

#define CTQ_CITY_NAME_LEN 32
#define CTQ_CITY_NAME_SIZE (CTQ_CITY_NAME_LEN + 1)

#define CTQ_COUNTY_NAME_LEN 32
#define CTQ_COUNTY_NAME_SIZE (CTQ_COUNTY_NAME_LEN + 1)

#define CTQ_STATE_NAME_LEN 32
#define CTQ_STATE_NAME_SIZE (CTQ_STATE_NAME_LEN + 1)

#define CTQ_STATE_ABBREVIATION_LEN 2
#define CTQ_STATE_ABBREVIATION_SIZE (CTQ_STATE_ABBREVIATION_LEN + 1)

#define CTQ_COUNTRY_NAME_LEN 32
#define CTQ_COUNTRY_NAME_SIZE (CTQ_COUNTRY_NAME_LEN + 1)

#define CTQ_COUNTRY_ABBREVATION_LEN 4
#define CTQ_COUNTRY_ABBREVATION_SIZE (CTQ_COUNTRY_ABBREVATION_LEN + 1)

#define CTQ_NPA_NXX_LEN 6
#define CTQ_NPA_NXX_SIZE (CTQ_NPA_NXX_LEN + 1)

#define CTQ_PLACE_NAME_LEN 18
#define CTQ_PLACE_NAME_SIZE CTQ_PLACE_NAME_LEN + 1

#define CTQ_PLACE_NAME_ABBREV_LEN 10
#define CTQ_PLACE_NAME_ABBREV_SIZE CTQ_PLACE_NAME_ABBREV_LEN + 1

#define CTQ_AREA_CODE_LEN 3
#define CTQ_AREA_CODE_SIZE CTQ_AREA_CODE_LEN + 1

#define CTQ_EXCHANGE_LEN 3
#define CTQ_EXCHANGE_SIZE CTQ_EXCHANGE_LEN + 1

#define CTQ_LATA_NUMBER_LEN 4
#define CTQ_LATA_NUMBER_SIZE CTQ_LATA_NUMBER_LEN + 1

#define CTQ_ACCUMULATOR_REFERENCE_LEN 40
#define CTQ_ACCUMULATOR_REFERENCE_SIZE (CTQ_ACCUMULATOR_REFERENCE_LEN + 1)

#define CTQ_KEY_TYPE_LEN 1
#define CTQ_KEY_TYPE_SIZE (CTQ_KEY_TYPE_LEN + 1)

#define CTQ_TYPE_LEN 1
#define CTQ_TYPE_SIZE ( CTQ_TYPE_LEN + 1 )

#define CTQ_TIER_TYPE_LEN 1
#define CTQ_TIER_TYPE_SIZE ( CTQ_TIER_TYPE_LEN + 1)

#define CTQ_RANGE_TYPE_LEN 1
#define CTQ_RANGE_TYPE_SIZE (CTQ_RANGE_TYPE_LEN + 1)

#define CTQ_VALUE_TYPE_LEN 1
#define CTQ_VALUE_TYPE_SIZE (CTQ_VALUE_TYPE_LEN + 1)

#define CTQ_PERIOD_TYPE_LEN 1
#define CTQ_PERIOD_TYPE_SIZE (CTQ_PERIOD_TYPE_LEN + 1)

#define CTQ_START_MONTH_LEN 2
#define CTQ_START_MONTH_SIZE (CTQ_START_MONTH_LEN + 1)

#define CTQ_START_VALUE_LEN 18
#define CTQ_START_VALUE_SIZE (CTQ_START_VALUE_LEN + 1)

#define CTQ_END_VALUE_LEN 18
#define CTQ_END_VALUE_SIZE (CTQ_END_VALUE_LEN + 1)

#define CTQ_TAX_VALUE_LEN 8
#define CTQ_TAX_VALUE_SIZE (CTQ_TAX_VALUE_LEN + 1)

#define CTQ_ROUNDING_RULE_LEN 1
#define CTQ_ROUNDING_RULE_SIZE (CTQ_ROUNDING_RULE_LEN +1)

#define CTQ_INVOICE_NUMBER_LEN 40
#define CTQ_INVOICE_NUMBER_SIZE (CTQ_INVOICE_NUMBER_LEN +1)

#define CTQ_CUSTOMER_CODE_LEN   1
#define CTQ_CUSTOMER_CODE_SIZE  (CTQ_CUSTOMER_CODE_LEN +1)

#define CTQ_CUSTOMER_REFERENCE_LEN 40
#define CTQ_CUSTOMER_REFERENCE_SIZE (CTQ_CUSTOMER_REFERENCE_LEN +1)

#define CTQ_UTILITY_CODE_LEN 1
#define CTQ_UTILITY_CODE_SIZE (CTQ_UTILITY_CODE_LEN +1)

#define CTQ_TRANSACTION_CODE_LEN 1
#define CTQ_TRANSACTION_CODE_SIZE (CTQ_TRANSACTION_CODE_LEN +1)

#define CTQ_USER_AREA_LEN 40
#define CTQ_USER_AREA_SIZE (CTQ_USER_AREA_LEN +1)

#define CTQ_ORIGIN_INPUT_LEN 20
#define CTQ_ORIGIN_INPUT_SIZE (CTQ_ORIGIN_INPUT_LEN +1)

#define CTQ_TERMINATION_INPUT_LEN 20
#define CTQ_TERMINATION_INPUT_SIZE (CTQ_TERMINATION_INPUT_LEN +1)

#define CTQ_CHARGETO_INPUT_LEN 20
#define CTQ_CHARGETO_INPUT_SIZE (CTQ_CHARGETO_INPUT_LEN +1)

/* Configuration string buffer sizes */

#define CTQ_CONFIGURATION_NAME_LEN 30
#define CTQ_CONFIGURATION_NAME_SIZE (CTQ_CONFIGURATION_NAME_LEN + 1)

/* Cache string buffer sizes */

#define CTQ_CACHE_NAME_LEN 15
#define CTQ_CACHE_NAME_SIZE (CTQ_CACHE_NAME_LEN + 1)

#define CTQ_CACHE_MODE_LEN 15
#define CTQ_CACHE_MODE_SIZE (CTQ_CACHE_MODE_LEN + 1)

/* Database connection string buffer sizes */

#define CTQ_CONNECTION_NAME_LEN 32
#define CTQ_CONNECTION_NAME_SIZE (CTQ_CONNECTION_NAME_LEN + 1)

#define CTQ_DATA_SOURCE_NAME_LEN 32
#define CTQ_DATA_SOURCE_NAME_SIZE (CTQ_DATA_SOURCE_NAME_LEN + 1)

#define CTQ_USERNAME_LEN 32
#define CTQ_USERNAME_SIZE (CTQ_USERNAME_LEN + 1)

#define CTQ_PASSWORD_LEN 32
#define CTQ_PASSWORD_SIZE (CTQ_PASSWORD_LEN + 1)

#define CTQ_SCHEMA_LEN 32
#define CTQ_SCHEMA_SIZE (CTQ_SCHEMA_LEN + 1)

#define CTQ_CATALOG_LEN 32
#define CTQ_CATALOG_SIZE (CTQ_CATALOG_LEN + 1)

#define CTQ_TABLE_NAME_LEN 32
#define CTQ_TABLE_NAME_SIZE (CTQ_TABLE_NAME_LEN + 1)

#define CTQ_QUALIFIED_TABLE_NAME_LEN (CTQ_TABLE_NAME_SIZE + CTQ_SCHEMA_SIZE + CTQ_CATALOG_SIZE - 3)
#define CTQ_QUALIFIED_TABLE_NAME_SIZE (CTQ_QUALIFIED_TABLE_NAME_LEN + 1)

/* Date and Time string buffer sizes */

#define CTQ_DATE_LEN 8
#define CTQ_DATE_SIZE (CTQ_DATE_LEN + 1)

#define CTQ_DAY_LEN 1
#define CTQ_DAY_SIZE (CTQ_DAY_LEN + 1)

#define CTQ_MONTH_LEN 2
#define CTQ_MONTH_SIZE (CTQ_MONTH_LEN + 1)

#define CTQ_YEAR_LEN 4
#define CTQ_YEAR_SIZE (CTQ_YEAR_LEN + 1)

#define CTQ_TIME_LEN 6
#define CTQ_TIME_SIZE (CTQ_TIME_LEN + 1)

#define CTQ_TIMESTAMP_LEN 14
#define CTQ_TIMESTAMP_SIZE (CTQ_TIMESTAMP_LEN + 1)

#define CTQ_PACKAGE_DESCRIPTION_LEN 50
#define CTQ_PACKAGE_DESCRIPTION_SIZE (CTQ_PACKAGE_DESCRIPTION_LEN + 1)

/* Arbitrary numeric value stored as a string */

#define CTQ_NUMBER_LEN 32
#define CTQ_NUMBER_SIZE (CTQ_NUMBER_LEN + 1)

/* Max/Tier Tax interval flags */

#define CTQ_ANNUAL      'A'
#define CTQ_SEMI_ANNUAL 'S'
#define CTQ_QUARTERLY   'Q'
#define CTQ_MONTHLY     'M'
#define CTQ_INVOICE     'I'

/* type definitions */

/*!
 * The LOCATION MODE is used to describe the type of location data that is
 * being passed from a host system.
 */

typedef enum eCtqLocationMode
{
    eCtqLocationGeocode           = 'G',    /*!< Indicates that the location is a Geocode. */
    eCtqLocationNpaNxx            = 'N',    /*!< Indicates that the location is Npa/Nxx encoded. */
    eCtqLocationZip               = 'Z',    /*!< Indicates that the location is a five-digit Zip code. */
    eCtqLocationZip4              = 'P'     /*!< Indicates that the location is a nine-digit Zip+4 code. */
} tCtqLocationMode;

/*!
 * The TAXING AUTHORITY identifies the taxing entity.
 */

typedef enum eCtqTaxAuthority
{
    eCtqTaxAuthorityFederal           = 0,  /*!< Indicates that the Taxing Authority is at the Federal level. */
    eCtqTaxAuthorityState             = 1,  /*!< Indicates that the Taxing Authority is at the State level. */
    eCtqTaxAuthorityCounty            = 2,  /*!< Indicates that the Taxing Authority is at the County level. */
    eCtqTaxAuthorityCity              = 3,  /*!< Indicates that the Taxing Authority is at the City level. */
    eCtqTaxAuthorityUnincorpArea      = 4,  /*!< Indicates that the Taxing Authority is an unincorporated area of a county. */
    eCtqTaxAuthorityOtherMunicipality = 6,  /*!< Indicates that the Taxing Authority is some other municipality. */
    eCtqTaxAuthorityCountyDistrict    = 7,  /*!< Indicates that the Taxing Authority is a district within a county. */
    eCtqTaxAuthorityCityDistrict      = 9   /*!< Indicates that the Taxing Authority is a district within a city. */
} tCtqTaxAuthority;

/*!
 * The CHANGE FLAG is used to indicate that an object instance in the RATE database
 * has been customized by the user.
 */

typedef enum eCtqChangeFlag
{
    eCtqChangeFlagNoChange  = ' ',          /*!< Indicates that the object instance has NOT been customized. */
    eCtqChangeFlagUser      = 'U'           /*!< Indicates that the object instance HAS been customized. */
} tCtqChangeFlag;

/*!
 * The INCORPORATED CODE is used to distinguish locations that are either
 * inside or outside of the incorporated area of a taxing jurisdiction.
 */

typedef enum eCtqIncorporatedCode
{
    eCtqIncorporatedCodeInside    = 'I',    /*!< Indicates a location inside the incorporated area of a taxing jurisdiction. */
    eCtqIncorporatedCodeOutside   = 'O'     /*!< Indicates a location outside the incorporated area of a taxing jurisdiction. */
} tCtqIncorporatedCode;

/*!
 * The CUSTOMER CODE distinguishes business customers from residential
 * customers. Businesses and residences are sometimes subject to different
 * taxation requirements.
 */

typedef enum eCtqCustomerCode
{
    eCtqCustomerCodeBusiness      = 'B',    /*!< Indicates that the customer is a Business. */
    eCtqCustomerCodeResidential   = 'R'     /*!< Indicates that the customer is a Residence. */
} tCtqCustomerCode;

/*!
 * The UTILITY CODE distinguishes regulated and unregulated utilities.
 * These are sometimes subject to different taxation requirements.
 */

typedef enum eCtqUtilityCode
{
    eCtqUtilityCodeRegulated      = 'R',    /*!< Indicates a Regulated Utility. */
    eCtqUtilityCodeUnregulated    = 'U'     /*!< Indicates an Unregulated Utility. */
} tCtqUtilityCode;

/*!
 * The SALE/RESALE CODE is used to distinguish transactions between resellers
 * and consumers of telecommunications services.
 */

typedef enum eCtqResaleFlag
{
    eCtqResaleFlagResale          = 'R',    /*!< Indicates that the customer is a Reseller. */
    eCtqResaleFlagSale            = 'S'     /*!< Indicates that the customer is a Consumer. */
} tCtqResaleFlag;

/*!
 * The TRANSACTION CODE is used to distinguish normal tax calculation
 * requests from special transaction processing.
 */

typedef enum eCtqTransactionCode
{
    eCtqTransactionCodeDefault    = ' ',    /*!< Indicates a normal transaction. */
    eCtqTransactionCodeAdjustment = 'A',    /*!< Indicates that the transaction is an adjustment. */
    eCtqTransactionCodeExempt     = 'X'     /*!< Indicates that the transaction is exempt from all calculated taxes. */
} tCtqTransactionCode;

/*!
 * The 2 OF 3 OVERRIDE CODE is used to alter the default behavior of the
 * '2 of 3' rule.  By default, the '2 of 3' rule determines where taxes are
 * to be collected based on comparisons of the origin, termination, and
 * 'charge to' locations.  This logic can be overridden or altered by
 * speifying one of these override values.
 */

typedef enum eCtq2of3Override
{
    eCtq2of3OverrideDefault                 = ' ',  /*!< Indicates no override and that the normal '2 of 3'
                                                         rule behavior should be used. */
    eCtq2of3OverrideCompleteUseOrigin       = 'A',  /*!< Indicates that the Origin Location should
                                                         be used regardless of whether a match was found. */
    eCtq2of3OverrideCompleteUseTermination  = 'B',  /*!< Indicates that the Termination Location should
                                                         be used regardless of whether a match was found. */
    eCtq2of3OverrideCompleteUseChargeTo     = 'C',  /*!< Indicates that the Charge-To Location should
                                                         be used regardless of whether a match was found. */
    eCtq2of3OverrideNoMatchUseOrigin        = 'F',  /*!< Indicates that the Origin Location should be used
                                                         if no match is found. */
    eCtq2of3OverrideNoMatchUseTermination   = 'G',  /*!< Indicates that the Termination Location should be used
                                                         if no match is found. */
    eCtq2of3OverrideNoMatchUseChargeTo      = 'H',  /*!< Indicates that the Charge-To Location should be used
                                                         if no match is found. */
    eCtq2of3OverrideAdjustIfNoCity          = 'J'   /*!< Indicates that adjustments shall be made if no City
                                                         was identified in the 2-of-3 Rule processing. The
                                                         Charge-To Location shall be used if it matches the
                                                         2-of-3 State or State/County. The Origin Location
                                                         shall be used if the Charge-To Location does not
                                                         match the 2-of-3 State or State/County or if no
                                                         2-of-3 match was identified at all. */
} tCtq2of3Override;

/*!
 * TAX TYPE Codes.
 */

typedef enum eCtqTaxType
{
    eCtqTaxTypeUtilitySalesTax =  5,   /*!< Identifies a tax as being a utility sales tax. */
    eCtqTaxTypeSalesTax        = 99    /*!< Identifies a tax as being a sales tax. */
} tCtqTaxType;

/*!
 * CTQ Import/Export Data File Format Identifiers
 *
 * These identifiers are used to specify the record structures to be used when importing or
 * exporting data.
 *
 * At present, the following operations support the File Format identifier:
 *
 *      - Register Journal Export [See: #CtqExportJournal()]
 */

typedef enum eCtqFileFormat
{
    eCtqFileFormatFixed,        /*!< Fixed-length, fixed-field records. */
    eCtqFileFormatDelimited     /*!< Variable-length, delimited-field records. */
} tCtqFileFormat;

/*!
 * CTQ cache modes
 *
 * These modes control whether the CTQ cache is off or on and how it is populated
 *
 */

typedef enum eCtqCacheMode
{
    eCtqCacheOff,     /*!< Cache is inactive and populated with no records -------------------- (used to remove the cache from memory)               */
    eCtqCacheDynamic, /*!< Cache is active and populated with records on a query by query basis (used for low volume/short duration processing runs) */
    eCtqCachePreload  /*!< Cache is active and (re)populated with all records when activated -- (used for high volume/long duration processing runs) */
} tCtqCacheMode;

/*!
 * Action codes for customization edit functions
 */

typedef enum eCtqAction
{
    eCtqActionInsert,     /*!< Add one or more object instances to the persistent store database.*/
    eCtqActionUpdate,     /*!< Modify an existing stored object. */
    eCtqActionDelete,     /*!< Remove one or more existing stored object instances. */
    eCtqActionCommit      /*!< Perform the underlying database actions associated with previously-
                               requested functions. At present, this feature applies only to
                               inserts on objects supporting multi-row insert capability. */
} tCtqAction;

/*!
 * Sorting Order for Inquiries
 *
 * Only some Inquire() methods within the sysetm implement these modes
 */

typedef enum eCtqSortOrder
{
    eCtqSortOrderUnspecified, /*!< Database natural ordering */
    eCtqSortOrderAscending,   /*!< Sort in ascending order   */
    eCtqSortOrderDescending   /*!< Sort in descending order  */
} tCtqSortOrder;

/*!
 * CTQ Data types for attribute "Get" and "Set" functions. These enumerations
 * represent the data types which may be set or retrieved by the attribute manipulation
 * function(s) associated with an object.
 *
 * NOTE: The actual size and format of the attribute may vary depending upon the
 * underlying compiler and machine architecture.
 */

typedef enum eCtqAttribType
{
    eCtqHandle,    /*!< A generic object handle. */
    eCtqBool,      /*!< Boolean value: eCtqTrue or eCtqFalse. */
    eCtqEnum,      /*!< A generic enumerated value. */
    eCtqInt,       /*!< Default machine integer. */
    eCtqLong,      /*!< Long integer. */
    eCtqFloat,     /*!< Single-precision floating point. */
    eCtqDouble,    /*!< Double-precision floating point. */
    eCtqDate,      /*!< Date in the form CCYYMMDD. */
    eCtqTime,      /*!< Time in the form HHMMSS. */
    eCtqTimestamp, /*!< A complete timestamp containing both the date and time for a given instant. Format:CCYYMMDDHHMMSS */
    eCtqString,    /*!< Null-terminated character string. */
    eCtqChar,      /*!< A single character. */
    eCtqVoid,      /*!< An abstract data pointer. */
    eCtqCallBack   /*!< A call back function pointer. */
} tCtqAttribType;

/*!
 * Attributes which may be retrieved and/or set for objects within the CTQ
 * framework.
 *
 * NOTE: Not all attributes may be both retrieved and set. Some attributes may be
 *       read-only and others may be write-only. Attribute accessibility is designated
 *       as follows:
 *
 *          - R/W: Read and Write
 *          - R/O: Read Only
 *          - W/O: Write Only
 *          - M/A: Mixed access. Actual access is object-dependent.
 */

typedef enum eCtqAttrib
{
    eCtqAttribNone,                     /*!< (W/O) Indicates an unspecified or non-existent attribute */

    /*------------------------------- handles -------------------------------*/

    eCtqHandleCtq,                      /*!< (R/O) Root object handle. */

    eCtqHandleDbcMgr,                   /*!< (R/O) Database Connection Pool Manager object handle. */
    eCtqHandleDbcPer,                   /*!< (R/O) Database Connection object handle. */

	eCtqHandleDbcSeqPer,				/*!< (R/O) Database Sequence Connection object handle. */

    eCtqHandleCchMgr,                   /*!< (R/O) Persister Cache Manager object handle */
    eCtqHandleCch,                      /*!< (R/O) Persister Cache object handle. */

    eCtqHandleHsh,                      /*!< (R/O) Hash Table object handle. */

    eCtqHandlePer,                      /*!< (R/O) Business object's persister object */
    eCtqHandleAdm,                      /*!< (R/O) Administrative Log object handle. */

    eCtqHandleCfg,                      /*!< (R/O) Configuration object handle. */

    eCtqHandleCtz,                      /*!< (R/O) Customization module object handle. */
    eCtqHandleCtzBsc,                   /*!< (R/O) Bundled Services Component object handle. */
    eCtqHandleCtzBsp,                   /*!< (R/O) Bundled Services object handle. */
    eCtqHandleCtzCde,                   /*!< (R/O) Customization Code object handle. */
    eCtqHandleCtzDec,                   /*!< (R/O) Customization Decision object handle.) */
    eCtqHandleCtzDlt,                   /*!< (R/O) Customization Decision Link object handle. */
    eCtqHandleCtzFfd,                   /*!< (R/O) Franchise Fee Decision handle. */
    eCtqHandleCtzFfl,                   /*!< (R/O) Franchise Fee Decision Linked Tax object handle. */
    eCtqHandleCtzFfr,                   /*!< (R/O) Franchise Fee Rate object handle. */
    eCtqHandleCtzMax,                   /*!< (R/O) Customization Max Tier object handle. */
    eCtqHandleCtzMdd,                   /*!< (R/O) Customization Max Tier Detail object handle. */
    eCtqHandleCtzRte,                   /*!< (R/O) Customization Rate object handle. */
    eCtqHandleLoc,                      /*!< (R/O) Location Module object handle. */
    eCtqHandleRte,                      /*!< (R/O) Rate object handle. */
    eCtqHandleRteBsc,                   /*!< (R/O) Bundled Services Component object handle. */
    eCtqHandleRteBsp,                   /*!< (R/O) Bundled Services object handle. */
    eCtqHandleRteCde,                   /*!< (R/O) Rate Code object handle. */
    eCtqHandleRteDec,                   /*!< (R/O) Rate Decision object handle. */
    eCtqHandleRteMax,                   /*!< (R/O) Rate Max Tier object handle. */
    eCtqHandleRteMaxWorkspace,          /*!< (R/O) Rate Max Tier object handle used as a temporary workspace. */
    eCtqHandleRteMdd,                   /*!< (R/O) Rate Max Tier Detail object handle. */
    eCtqHandleRteRte,                   /*!< (R/O) Rate Rate object handle . */
    eCtqHandleRteDdl,                   /*!< (R/O) Rate Decision object handle. */
    eCtqHandleRteRdd,                   /*!< (R/O) Rate Detail object handle. */
    eCtqHandleRteDdd,                   /*!< (R/O) Rate Decision object handle. */
    eCtqHandleReg,                      /*!< (R/O) Register object handle. */
    eCtqHandleRegTrn,                   /*!< (R/O) Register transaction handle. */
    eCtqHandleRegTax,                   /*!< (R/O) Register tax detail handle. */
    eCtqHandleRegJrn,                   /*!< (R/O) Register journal handle. */
    eCtqHandleRegAcc,                   /*!< (R/O) Register Accumulator handle. */
    eCtqHandleRegAdd,                   /*!< (R/O) Register Accumulator Detail object handle. */
    eCtqHandleRegJtx,                   /*!< (R/O) Register journal tax detail handle. */
    eCtqHandleRegJrd,                   /*!< (R/O) Register Journal Denormalized object handle. */
    eCtqHandleRegBsc,                   /*!< (R/O) Register Bundled Service Component object handle. */
    eCtqHandleRpt,                      /*!< (R/O) Reporting object handle. */
    eCtqHandleRptPer,                   /*!< (R/O) Reporting Persister object handle. */

    /*---------------------------- system monitoring -------------------------*/

    /*!
     * \internal
     * \todo implementation pending
     */

    eCtqAttribActivityCallback,         /*!< (R/W) A function callback to monitor processing. */

    /*!
     * \internal
     * \todo implementation pending
     */

    eCtqAttribErrorCallback,            /*!< (R/W) A function callback for error handling.*/
    
    /*---------------- Cache and Hash Table Object Attributes ---------------*/
    
    eCtqAttribIntialized,               /*!< (R/O) Indicates whether a cache or hash table is initialized                   */

    eCtqAttribReferenceCount,           /*!< (R/O) The number of threads currently referencing a cache                      */

    eCtqAttribMemoryLimit,              /*!< (R/W) The maximum cache memory to use (in bytes).                              */
    eCtqAttribAgeLimit,                 /*!< (R/W) The cache node refresh period (in seconds).                              */
 
    eCtqAttribNodeLimit,                /*!< (R/W) The maximum number of nodes to allocate for a cache or hash table.       */

    eCtqAttribKey,                      /*!< (R/W) void pointer to a key value to use to access a cache or hash table       */
    eCtqAttribKeySize,                  /*!< (R/W) The size of the user defined key                                         */
    eCtqAttribKeyType,                  /*!< (R/W) The type of the user defined key (eCtqString or eCtqVoid)                */

    eCtqAttribDatum,                    /*!< (R/W) void pointer to a value (or structure) to store in a cache or hash table */
    eCtqAttribDatumSize,                /*!< (R/W) The size of the user defined data to be stored in a cache or hash table  */

    eCtqAttribCacheInsertAttempts,      /*!< (R/O) The number of insert attempts made against a database cache              */
    eCtqAttribCacheRecordsInserted,     /*!< (R/O) The number of records successfully inserted into a database cache        */
    eCtqAttribCacheUpdateAttempts,      /*!< (R/O) The number or update attempts made against a database cache              */
    eCtqAttribCacheRecordsUpdated,      /*!< (R/O) The number of records updated in a database cache                        */
    eCtqAttribCacheFetchAttempts,       /*!< (R/O) The number or fetch attempts made against a database cache               */
    eCtqAttribCacheRecordsFetched,      /*!< (R/O) The number of records fetched from a database cache                      */
    eCtqAttribCacheDeleteAttempts,      /*!< (R/O) The number or delete attempts made against a database cache              */
    eCtqAttribCacheRecordsDeleted,      /*!< (R/O) The number of records deleted from a database cache                      */

    eCtqAttribKeyCompareFunction,       /*!< (R/W) A key comparison function pointer                                        */

    eCtqAttribHashFunction,             /*!< (R/W) A hash code generation function pointer                                  */

    /*----------------------- Generic Object Attributes ---------------------*/
    
    eCtqAttribRowLimit,                 /*!< (R/O) The maximum number of attribute rows.*/
    eCtqAttribRowCount,                 /*!< (R/O) The number of attribute rows present.*/
    eCtqAttribRowIndex,                 /*!< (R/W) The index, zero-based, of the current row. */
    eCtqAttribRowsAllocated,            /*!< (R/O) The number of attribute rows allocated. */

    /*-------------------- root (CtqRoot) Object Attributes ------------------*/

    eCtqAttribReleaseDate,              /*!< (R/O) CTQ Release Date: CCYYMMDD. Sized by CTQ_DATE_SIZE. */
    eCtqAttribMajorVersion,             /*!< (R/O) CTQ Major Release Number. */
    eCtqAttribMinorVersion,             /*!< (R/O) CTQ Minor Release Number. */
    eCtqAttribRevisionNumber,           /*!< (R/O) CTQ Release Revision Number. */
	eCtqAttribBuildNumber,				/*!< (R/O) CTQ Build Revion Number. */

    eCtqAttribCtqCfgHome,               /*!< (R/W) Home directory for the configuration file. Sized by CTQ_PATH_SIZE. */

    /*--------------------- configuration object attributes ------------------*/

    eCtqCriteriaConfigurationName,      /*!< (R/W) Name of a configuration to be retrieved from the configuration (ctqcfg.xml)
                                                   file. Sized by CTQ_CONFIGURATION_NAME_SIZE. */

    eCtqAttribConfigurationName,        /*!< (R/O) Name of the configuration actually retrieved from the configuration
                                                   (ctqcfg.xml) file. Sized by CTQ_CONFIGURATION_NAME_SIZE. */

    eCtqAttribArchiveFilePath,          /*!< (R/O) Specifies the Path of Import/Export Files. Sized by CTQ_PATH_SIZE. */
    eCtqAttribLogFilePath,              /*!< (R/O) Specifies the Path of System Log Files. Sized by CTQ_PATH_SIZE. */
    eCtqAttribReportFilePath,           /*!< (R/O) Specifies the Path of Report Files. Sized by CTQ_PATH_SIZE. */
    eCtqAttribUpdateFilePath,           /*!< (R/O) Specifies the Path of Monthly Update Files. Sized by CTQ_PATH_SIZE. */
	eCtqAttribCallFilePath,             /*!< (R/O) Specifies the Path of Call Files. Sized by CTQ_PATH_SIZE. */

    eCtqAttribPageLength,               /*!< (R/O) The number of lines to print per page for reports. */

    eCtqAttribWriteAccumulator,         /*!< (R/O) Controls Writing to the Accumulator. */
    eCtqAttribWriteJournal,             /*!< (R/O) Controls Writing to the Journal. */
    eCtqAttribReturnZeroRateTaxes,      /*!< (R/O) Controls whether or not to return tax detail for zero rate taxes. */
    eCtqAttribZip4Error,                /*!< (R/O) Controls whether or not to return an error for Zip+4 queries that return
                                                   more than one row. */

    eCtqAttribCacheMode,                /*!< (R/W) Generic cache mode.                          */
    eCtqAttribLocGeoCacheMode,          /*!< (R/W) Controls the cache mode of the LocGeo cache. */
    eCtqAttribLocNpaCacheMode,          /*!< (R/W) Controls the cache mode of the LocNpa cache. */
    eCtqAttribLocZipCacheMode,          /*!< (R/W) Controls the cache mode of the LocZip cache. */
    eCtqAttribLocDghCacheMode,          /*!< (R/W) Controls the cache mode of the LocDgh cache. */
    eCtqAttribRteBscCacheMode,          /*!< (R/W) Controls the cache mode of the RteBsc cache. */
    eCtqAttribRteBspCacheMode,          /*!< (R/W) Controls the cache mode of the RteBsp cache. */
    eCtqAttribRteCdeCacheMode,          /*!< (R/W) Controls the cache mode of the RteCde cache. */
    eCtqAttribRteDddCacheMode,          /*!< (R/W) Controls the cache mode of the RteDdd cache. */
    eCtqAttribRteDdlCacheMode,          /*!< (R/W) Controls the cache mode of the RteDdl cache. */
    eCtqAttribRteDecCacheMode,          /*!< (R/W) Controls the cache mode of the RteDec cache. */
    eCtqAttribRteMaxCacheMode,          /*!< (R/W) Controls the cache mode of the RteMax cache. */
    eCtqAttribRteMddCacheMode,          /*!< (R/W) Controls the cache mode of the RteMdd cache. */
    eCtqAttribRteRddCacheMode,          /*!< (R/W) Controls the cache mode of the RteRdd cache. */
    eCtqAttribRteRteCacheMode,          /*!< (R/W) Controls the cache mode of the RteRte cache. */

    eCtqAttribLogData,                  /*!< (R/O) Bit mask of debug data to be logged. See #tCtqLogData
                                                   for interpretation of the bit positions. */

    eCtqAttribLogEvents,                /*!< (R/O) Bit mask of events to be logged. See tCtqLogEvents
                                                   for interpretation of the bit positions. */

    eCtqAttribCtzDataSourceName,        /*!< (R/O) Customization database ODBC Data Source Name (DSN) (CTQ_DATA_SOURCE_NAME_SIZE) */
    eCtqAttribCtzCatalog,               /*!< (R/O) Customization database Catalog Identifier (CTQ_CATALOG_SIZE) */
    eCtqAttribCtzSchema,                /*!< (R/O) Customization database Schema Identifier (CTQ_SCHEMA_SIZE) */
    eCtqAttribCtzUsername,              /*!< (R/O) Customization database Username (CTQ_USERNAME_SIZE) */
    eCtqAttribCtzPassword,              /*!< (R/O) Customization database Password (CTQ_PASSWORD_SIZE) */
    eCtqAttribCtzBscSequenceBlockSize,
    eCtqAttribCtzBspSequenceBlockSize,
    eCtqAttribCtzCdeSequenceBlockSize,
    eCtqAttribCtzDecSequenceBlockSize,
    eCtqAttribCtzDltSequenceBlockSize,
    eCtqAttribCtzFfdSequenceBlockSize,
    eCtqAttribCtzFflSequenceBlockSize,
    eCtqAttribCtzFfrSequenceBlockSize,
    eCtqAttribCtzMaxSequenceBlockSize,
    eCtqAttribCtzMddSequenceBlockSize,
    eCtqAttribCtzRteSequenceBlockSize,
    eCtqAttribCtzRetryInterval,
    eCtqAttribCtzMaximumRetries,
    
    eCtqAttribLocDataSourceName,        /*!< (R/O) Location database ODBC Data Source Name (DSN) (CTQ_DATA_SOURCE_NAME_SIZE) */
    eCtqAttribLocCatalog,               /*!< (R/O) Location database Catalog Identifier (CTQ_CATALOG_SIZE) */
    eCtqAttribLocSchema,                /*!< (R/O) Location database Schema Identifier (CTQ_SCHEMA_SIZE) */
    eCtqAttribLocUsername,              /*!< (R/O) Location database Username (CTQ_USERNAME_SIZE) */
    eCtqAttribLocPassword,              /*!< (R/O) Location database Password (CTQ_PASSWORD_SIZE) */
    eCtqAttribLocGeoSequenceBlockSize,
    eCtqAttribLocNpaSequenceBlockSize,
    eCtqAttribLocZipSequenceBlockSize,
    eCtqAttribLocRetryInterval,
    eCtqAttribLocMaximumRetries,

    eCtqAttribRegDataSourceName,        /*!< (R/O) Register database ODBC Data Source Name (DSN)(CTQ_DATA_SOURCE_NAME_SIZE) */
    eCtqAttribRegCatalog,               /*!< (R/O) Register database Catalog Identifier (CTQ_CATALOG_SIZE) */
    eCtqAttribRegSchema,                /*!< (R/O) Register database Schema Identifier (CTQ_SCHEMA_SIZE) */
    eCtqAttribRegUsername,              /*!< (R/O) Register database Username (CTQ_USERNAME_SIZE) */
    eCtqAttribRegPassword,              /*!< (R/O) Register database Password (CTQ_PASSWORD_SIZE) */
    eCtqAttribRegAccSequenceBlockSize,
    eCtqAttribRegAddSequenceBlockSize,
    eCtqAttribRegJrnSequenceBlockSize,
    eCtqAttribRegJtxSequenceBlockSize,
    eCtqAttribRegRetryInterval,
    eCtqAttribRegMaximumRetries,

    eCtqAttribRteDataSourceName,        /*!< (R/O) Contains the Rate database ODBC Data Source Name (DSN) (CTQ_DATA_SOURCE_NAME_SIZE) */
    eCtqAttribRteCatalog,               /*!< (R/O) Contains the Rate database Catalog Identifier (CTQ_CATALOG_SIZE) */
    eCtqAttribRteSchema,                /*!< (R/O) Contains the Rate database Schema Identifier (CTQ_SCHEMA_SIZE) */
    eCtqAttribRteUsername,              /*!< (R/O) Contains the Rate database Username (CTQ_USERNAME_SIZE) */
    eCtqAttribRtePassword,              /*!< (R/O) Contains the Rate database Password (CTQ_PASSWORD_SIZE) */
    eCtqAttribRteBscSequenceBlockSize,
    eCtqAttribRteBspSequenceBlockSize,
    eCtqAttribRteCdeSequenceBlockSize,
    eCtqAttribRteDddSequenceBlockSize,
    eCtqAttribRteDdlSequenceBlockSize,
    eCtqAttribRteDecSequenceBlockSize,
    eCtqAttribRteMaxSequenceBlockSize,
    eCtqAttribRteMddSequenceBlockSize,
    eCtqAttribRteRddSequenceBlockSize,
    eCtqAttribRteRteSequenceBlockSize,
    eCtqAttribRteRetryInterval,
    eCtqAttribRteMaximumRetries,

    /*---------------- database connection object attributes ----------------*/

    eCtqAttribDataSourceName,           /*!< (R/W) Contains a ODBC Data Source Name (DSN). Sized by CTQ_DATA_SOURCE_NAME_SIZE. */
    eCtqAttribCatalog,                  /*!< (R/W) Contains a Database Catalog Identifier. Sized by CTQ_CATALOG_SIZE. */
    eCtqAttribSchema,                   /*!< (R/W) Contains a Database Schema Identifier. Sized by CTQ_SCHEMA_SIZE. */
    eCtqAttribUsername,                 /*!< (R/W) Contains a Database Username. Sized by CTQ_USERNAME_SIZE. */
    eCtqAttribPassword,                 /*!< (W/O) Contains a Database Password. Sized by CTQ_PASSWORD_SIZE. */

    eCtqAttribRetryInterval,            /*!< (R/W) Contains the interval in milliseconds between database access retries */
    eCtqAttribMaximumRetries,           /*!< (R/W) Contains the maximum number of database access retries to attempt before returning an error */

    eCtqAttribBulkInsertRows,           /*!< (R/O) Contains the number of rows to bulk insert. */
    eCtqAttribIsConnected,              /*!< (R/O) Contains the connection state. */

    eCtqCriteriaTable,                  /*!< (R/W) The Object Name for which to allocate a block of unique identifiers. Sized
                                                   by CTQ_TABLE_NAME_SIZE. */
    eCtqCriteriaSequenceSize,           /*!< (R/W) The number of unique identifiers to allocate in a block. */

    eCtqAttribSequenceStart,            /*!< (R/O) The starting unique identifier in the allocated block. Identifiers
                                                   within the block are sequential integers. */
    eCtqAttribSequenceEnd,              /*!< (R/O) The ending unique identifier in the allocated block. Identifiers
                                                   within the block are sequential integers. */
    eCtqAttribSequenceCurrent,          /*!< (R/O) The current sequence number within the most
                                                   recently allocated block of sequence numbers. */

    /*-------------------- administration object attributes -----------------*/

    eCtqAttribEventCode,                /*!< (R/O) Denotes the type of operation that generated an event. Sized by
                                                   CTQ_CODE_SIZE. */
    eCtqAttribEventTimeStamp,           /*!< (R/O) When the event occured. Sized by CTQ_TIMESTAMP_SIZE. */
    eCtqAttribEventDescription,         /*!< (R/O) The description of the event recorded. Sized by CTQ_DESCRIPTION_SIZE. */

    eCtqCriteriaEventCode,              /*!< (R/W) Inquiry criterion for adminstration events by event type. Sized by
                                                   CTQ_CODE_SIZE. */
    eCtqCriteriaEventTimeStampBegin,    /*!< (R/W) Inquiry criterion for adminstration events by event time range.
                                                   Sized by CTQ_TIMESTAMP_SIZE. */
    eCtqCriteriaEventTimeStampEqual,    /*!< (R/W) Inquiry criterion for adminstration events by event time range.
                                                   Sized by CTQ_TIMESTAMP_SIZE. */
    eCtqCriteriaEventTimeStampEnd,      /*!< (R/W) Inquiry criterion for adminstration events by event time range.
                                                   Sized by CTQ_TIMESTAMP_SIZE. */

    /*----------- object attributes commonly used in multiple objects ----------*/

    eCtqCriteriaId,                     /*!< (R/W) Selection criterion for objects by their unique identifier. */
    eCtqCriteriaParentId,               /*!< (R/W) Selection criterion for objects by their parent's unique identifier. */
    eCtqCriteriaCategoryCode,           /*!< (R/W) Selection criterion for objects by category of service. Sized by
                                                   CTQ_CATEGORY_CODE_SIZE. See: #eCtqAttribCategoryCode. */
    eCtqCriteriaServiceCode,            /*!< (R/W) Selection criterion for objects by type of service. Sized by 
                                                   CTQ_SERVICE_CODE_SIZE. See: #eCtqAttribServiceCode. */
    eCtqCriteriaTypeCode,               /*!< (R/W) Selection criterion for objects by type of code. Sized by
                                                   CTQ_CODE_TYPE_SIZE. See: #eCtqAttribTypeCode. */
    eCtqCriteriaTaxType,                /*!< (R/W) Selection criterion for objects by type of tax. Sized by
                                                   CTQ_TAX_TYPE_SIZE. See: eCtqAttribTaxType. */
    eCtqCriteriaTaxAuthority,           /*!< (R/W) Selection criterion for objects by taxing authority. Sized by
                                                   CTQ_TAX_AUTHORITY_SIZE. See: eCtqAttribTaxAuthority. */
    
    eCtqOrderByAttribute1,              /*!< (R/W) The attribute to be used for the first order by specification. */
    eCtqOrderBySortOrder1,              /*!< (R/W) The sort order to be used for the first order by specification. */
    eCtqOrderByAttribute2,              /*!< (R/W) The attribute to be used for the second order by specification. */
    eCtqOrderBySortOrder2,              /*!< (R/W) The sort order to be used for the second order by specification. */
    eCtqOrderByAttribute3,              /*!< (R/W) The attribute to be used for the third order by specification. */
    eCtqOrderBySortOrder3,              /*!< (R/W) The sort order to be used for the third order by specification. */
    eCtqOrderByAttribute4,              /*!< (R/W) The attribute to be used for the fourth order by specification. */
    eCtqOrderBySortOrder4,              /*!< (R/W) The sort order to be used for the fourth order by specification. */
    eCtqOrderByAttribute5,              /*!< (R/W) The attribute to be used for the fifth order by specification. */
    eCtqOrderBySortOrder5,              /*!< (R/W) The sort order to be used for the fifth order by specification. */

    eCtqAttribPath,                     /*!< (R/W) The directory to use for monthly updates/import/export/reporting
                                                   operations. Sized by CTQ_PATH_SIZE. */
    eCtqAttribFileName,                 /*!< (R/W) The name of a file for monthly updates/import/export/reporting
                                                   Sized by CTQ_FILE_NAME_SIZE. operations. */
    eCtqAttribFileFormat,               /*!< (R/W) Specifies the format of an import or export file. See: #tCtqFileFormat. */
    eCtqAttribFileFieldDelimiter,       /*!< (R/W) Specifies the field delimiter to be used when processing #eCtqFileFormatDelimited
                                                   files. Sized by CTQ_FILE_FIELD_DELIMITER_SIZE. */

    eCtqAttribQualifiedTableName,       /*!< (R/O) Used to obtain the fully-qualified database table name associated with an object's persister.
                                                   Sized by the following formula: CTQ_TABLE_NAME_SIZE + CTQ_SCHEMA_SIZE + CTQ_CATALOG_SIZE + 2. */

    eCtqAttribId,                       /*!< (R/O) A unique identifier assigned to an object. */
    eCtqAttribParentId,                 /*!< (R/W) Identifies the object as being a child of the specified parent object. */
    eCtqAttribChildId,                  /*!< (R/O) Identifies the child of the current parent object. This is used primarily for denormalized objects. */
    eCtqAttribCategoryCode,             /*!< (R/W) Identifies the Category of Service being taxed. Sized by CTQ_CATEGORY_CODE_SIZE. */
    eCtqAttribCategoryCodeDescription,  /*!< (R/W) The Description of a Category of Service. Sized by CTQ_DESCRIPTION_SIZE. */
    eCtqAttribComponentCategoryCode,    /*!< (R/W) Identifies the Category of Service that is a component of a Bundled Service.
                                                   Sized by CTQ_CATEGORY_CODE_SIZE. */
    eCtqAttribComponentCategoryCodeDescription, /*!< (R/W) The Description of a Category of Service that is a Component of a Bundled Service.
                                                   Sized by CTQ_DESCRIPTION_SIZE. */
    eCtqAttribServiceCode,              /*!< (R/W) Identifies the Type of Service being taxed. Sized by CTQ_SERVICE_CODE_SIZE. */
    eCtqAttribServiceCodeDescription,   /*!< (R/W) The Description of a Service. Sized by CTQ_DESCRIPTION_SIZE. */
    eCtqAttribComponentServiceCode,     /*!< (R/W) Identifies the Type of Service that is a component of a Bundled Service. Sized by
                                                   CTQ_SERVICE_CODE_SIZE. */
    eCtqAttribComponentServiceCodeDescription, /*!< (R/W) The Description of a Service that is a Component of a Bundled Service. Sized by
                                                   CTQ_DESCRIPTION_SIZE. */
    eCtqAttribTypeCode,                 /*!< (R/W) A classification code used for various objects. Sized by CTQ_CODE_TYPE_SIZE. */
    eCtqAttribMoreRecords,
    eCtqAttribMoreRecordsFlag,
    eCtqAttribChangeFlag,
    eCtqAttribCreationDate,             /*!< (R/W) Specifies the date that an object instance was created. Sized by CTQ_DATE_SIZE. */
    eCtqAttribDescription,              /*!< (R/W) General descriptive text. Sized by CTQ_DESCRIPTION_SIZE. */
    eCtqAttribEffectiveDate,            /*!< (R/W) Specifies the date upon which a particular rate, rule, etc.
                                                   becomes effective. Sized by CTQ_DATE_SIZE. */
    eCtqAttribRate,                     /*!< (R/W) Contains a tax rate or flat amount to be used on or after the
                                                   effective date. */
    eCtqAttribPreviousRate,             /*!< (R/W) Contains a tax rate or flat amount to be used before the
                                                   effective date. */

    /*-------------------------- code object attributes -----------------------*/

    eCtqCriteriaRecordActive,           /*!< (R/W) Selection criterion for active/iactive objects. Sized by CTQ_FLAG_SIZE. */
    eCtqCriteriaRecordCreator,          /*!< (R/W) Selection criterion for object based upon the source of the instance data.
                                                   Sized by CTQ_FLAG_SIZE. */
    eCtqCriteriaCodeType,               /*!< (R/W) Selection criterion for objects type of code represented within a Codes object. */
    eCtqCriteriaCodeCategory,           /*!< (R/W) Selection criterion for objects subtype of category of code represented within a Codes object. */
    eCtqCriteriaCodeValue,              /*!< (R/W) Selection criterion for objects actual value of the code represented within a Codes object. */

    eCtqAttribRecordActive,             /*!< (R/O) Indicates whether or not a code record is currently active. */
    eCtqAttribRecordCreator,            /*!< (R/O) Indicates the creator of a code record. */
    eCtqAttribCodeType,                 /*!< (R/W) The type of code represented within a Codes object. Sized by CTQ_CODE_TYPE_SIZE. */
    eCtqAttribCodeCategory,             /*!< (R/W) The subtype of category of code represented within a Codes object. Sized by
                                                   CTQ_CODE_CATEGORY_SIZE. */
    eCtqAttribCodeValue,                /*!< (R/W) The actual value of the code represented within a Codes object. Sized by
                                                   CTQ_CODE_VALUE_SIZE. */

    /*---------------------- customization object attributes ------------------*/

    eCtqAttribPackageCost,              /*!< (R/W) Contains the total cost of a Bundled Services package. */
    eCtqAttribCost,                     /*!< (R/W) The cost of an individual Bundled Services component. */
    eCtqAttribPropagationCode,          /*!< (R/W) Indicates whether a customization should be propagated to lower-level
                                                   GeoCodes. Sized by CTQ_PROPAGATION_CODE_SIZE. */
    eCtqAttribMaxLines,                 /*!< (R/W) For a customized rate record, the maximum number of lines that may be taxed. */
    eCtqAttribMaxTrunks,                /*!< (R/W) For a customized rate record, the maximum number of trunk lines that may be taxed. */
    eCtqAttribTransitRate,              /*!< (R/W) For a customized rate record, the transit rate imposed on sales transactions. */
    eCtqAttribMaxTaxCode,               /*!< (R/W) For a customized rate record, the code associated with any max tax or tiered tax rule.
                                                   Sized by CTQ_MAX_CODE_SIZE. */
    eCtqAttribTaxBase,                  /*!< (R/W) For a customized rate record, the amount at which the excess rate takes effect. */
    eCtqAttribExcessRate,               /*!< (R/W) For a customized rate record, the (usually lower) rate applied to amounts in excess of the base amount. */
    eCtqAttribPartialStateRate,         /*!< (R/W) For a customized rate record, the partial state sales tax rate. */
    eCtqAttribPartialCountyRate,        /*!< (R/W) For a customized rate record, the partial county sales tax rate. */

    eCtqCriteriaStartReference,         /*!< (R/W) Selection criterion for objects by starting Customer or Invoice number.
                                                   Sized by CTQ_CUSTOMER_REFERENCE_SIZE. */
    eCtqCriteriaEndReference,           /*!< (R/W) Selection criterion for objects by ending Customer or Invoice number.
                                                   Sized by CTQ_CUSTOMER_REFERENCE_SIZE. */
    eCtqCriteriaStartYear,              /*!< (R/W) Selection criterion for objects by startihg Year. Sized by CTQ_YEAR_SIZE. */
    eCtqCriteriaEndYear,                /*!< (R/W) Selection criterion for objects by ending Year. Sized by CTQ_YEAR_SIZE. */

    eCtqAttribWriteBundleDetailFlag,    /*!< (R/W) Indicates whether the detail of a Bundled Service is written to the Tax Journal. Sized by CTQ_FLAG_SIZE. */

    /*------------------------- location object attributes --------------------*/

    eCtqCriteriaGeoCode,                /*!< Vertex GeoCode value that identifies a taxing jurisdiction. Sized by CTQ_GEOCODE_SIZE. */
    eCtqCriteriaGeoCodeBegin,           /*!< Identifies the starting point of a GeoCode-based range inquiry, update or delete operation.
                                             Sized by CTQ_GEOCODE_SIZE. */
    eCtqCriteriaGeoCodeEnd,             /*!< Identifies the ending point of a GeoCode-based range inquiry, update or delete operation.
                                             Sized by CTQ_GEOCODE_SIZE. */
    eCtqCriteriaPrimaryDescription,     /*!< Indicates whether to get the just the primary GeoCode description record or all description
                                             records.  Sized by CTQ_FLAG_SIZE. */
    eCtqCriteriaCountryName,            /*!< The full name of a country USA or CANADA.  Sized by CTQ_COUNTRY_NAME_SIZE. */
    eCtqCriteriaStateName,              /*!< The full name of a state/province. Sized by CTQ_STATE_NAME_SIZE. */
    eCtqCriteriaStateCode,              /*!< The 2 character abbreviation of a state/province. Sized by CTQ_STATE_ABBREVIATION_SIZE. */
    eCtqCriteriaCountyName,             /*!< The full name of a county. Sized by CTQ_COUNTY_NAME_SIZE. */
    eCtqCriteriaCityName,               /*!< The full name of a city. Sized by CTQ_CITY_NAME_SIZE. */
    eCtqCriteriaPostal,                 /*!< A 5 digit Zip or Canadian Postal Code. Sized by CTQ_POSTAL_CODE_SIZE. */
    eCtqCriteriaZipCode,                /*!< A 5 digit Zipcode. Sized by CTQ_ZIP_SIZE. */
    eCtqCriteriaZip4,                   /*!< A +4 portion of a Zip+4. Sized by CTQ_ZIP4_SIZE. */
    eCtqCriteriaFipsCode,               /*!< A 10 digit Federal Information Proceesing Standard Jurisdiction Identifier Code. Sized
                                             by CTQ_FIPS_CODE_SIZE. */
    eCtqCriteriaNpaNxx,                 /*!< Phone number National Plan Area Code / Exchange. Sized by CTQ_NPA_NXX_SIZE. */
    eCtqCriteriaParentGeoCode,          /*!< A GeoCode used to query the district GeoCode hierarchy table ('LocDgh') for its child jurisdictions. */
    eCtqCriteriaChildGeoCode,           /*!< A GeoCode used to query the district GeoCode hierarchy table ('LocDgh') for its parent jurisdiction. */
    eCtqCriteriaRecordCount,            /*!< Criteria attribute of type 'tCtqBool' that enables 'Inquire()' methods to obtain record counts. */

    eCtqAttribGeoCode,                  /*!< Vertex GeoCode value that identifies a taxing jurisdiction. Sized by CTQ_GEOCODE_SIZE. */
    eCtqAttribGeoLevel,                 /*!< Vertex GeoCode level that identifies the type of stored jurisdiction description. Sized
                                             by CTQ_GEOLEVEL_SIZE. */

    eCtqAttribParentGeoCode,            /*!< The GeoCode of a taxing authority to which a district GeoCode is subordinate.  Sized by CTQ_GEOCODE_SIZE. */

    eCtqAttribStateCode,                /*!< The 2 character abbreviation of a state/province. Sized by CTQ_STATE_ABBREVIATION_SIZE. */
    eCtqAttribStateName,                /*!< The name of a state/country. Sized by CTQ_STATE_NAME_SIZE. */
    eCtqAttribCountyName,               /*!< The name of a county/province. Sized by CTQ_COUNTY_NAME_SIZE. */
    eCtqAttribCityName,                 /*!< The name of a city. Sized by CTQ_CITY_NAME_SIZE. */
    eCtqAttribDistrictName,             /*!< The name of a district.  Sized by CTQ_DISTRICT_NAME_SIZE. */

    eCtqAttribPostalCodeStart,          /*!< The start of a 3 character Canadian Postal prefix or 5 digit Zip range. Sized by CTQ_POSTAL_CODE_SIZE. */
    eCtqAttribPostalCodeEnd,            /*!< The end of a 3 character Canadian Postal prefix or 5 digit Zip range. Sized by CTQ_POSTAL_CODE_SIZE. */

    eCtqAttribZipCode,                  /*!< A 5 digit Zipcode. Sized by CTQ_ZIP_SIZE. */

    eCtqAttribZip4Start,                /*!< The +4 portion of the start of a Zip+4 range. Sized by CTQ_ZIP4_SIZE. */
    eCtqAttribZip4End,                  /*!< The +4 portion of the end of a Zip+4 range. Sized by CTQ_ZIP4_SIZE. */

    eCtqAttribNpaNxx,                   /*!< Phone number National Plan Area Code / Exchange. Sized by CTQ_NPA_NXX_SIZE. */
    eCtqAttribLata,                     /*!< Phone system Local Access Transport Area code. Sized by CTQ_LATA_NUMBER_SIZE. */

    /*-------------------------- rate object attributes -----------------------*/

    eCtqAttribStateTaxRate,             /*!< The State-level sales tax rate to be used on and after the effective date. */
    eCtqAttribStateTaxEffDate,          /*!< The date that the State sales tax rate became effective. Sized by CTQ_DATE_SIZE. */
    eCtqAttribStatePreviousTaxRate,     /*!< The State-level sales tax rate to be used prior to the effective date. */
    eCtqAttribCountyTaxRate,            /*!< The County-level sales tax rate to be used on and after the effective date. */
    eCtqAttribCountyTaxEffDate,         /*!< The date that the County sales tax rate became effective. Sized by CTQ_DATE_SIZE. */
    eCtqAttribCountyPreviousTaxRate,    /*!< The County-level sales tax rate to be used prior to the effective date. */
    eCtqAttribCountyTransitRate,        /*!< Contains the County-level transit tax rate. */
    eCtqAttribCountyMaxTaxCode,         /*!< Reserved. Sized by CTQ_MAX_CODE_SIZE. */
    eCtqAttribCountyBaseAmount,         /*!< Specifies the maximum amount on which the County sales tax is calculated. */
    eCtqAttribCountyExcessRate,         /*!< Specifies the rate at which any amount over the base amount is taxed for County sales tax. */
    eCtqAttribCountyPartialStateRate,   /*!< This value overrides the State sales tax rate unless the user overrides the State sales tax. */
    eCtqAttribCityTaxRate,              /*!< The City-level sales tax rate to be used on and after the effective date. */
    eCtqAttribCityTaxEffDate,           /*!< The date that the City sales tax rate became effective. Sized by CTQ_DATE_SIZE. */
    eCtqAttribCityPreviousTaxRate,      /*!< The City-level sales tax rate to be used prior to the effective date. */
    eCtqAttribCityTransitRate,          /*!< Contains the City-level transit tax rate. */
    eCtqAttribCityMaxTaxCode,           /*!< Reserved. Sized by CTQ_MAX_CODE_SIZE. */
    eCtqAttribCityBaseAmount,           /*!< Specifies the maximum amount on which the City sales tax is calculated. */
    eCtqAttribCityExcessRate,           /*!< Specifies the rate at which any amount over the base amount is taxed for City sales tax. */
    eCtqAttribCityPartialStateRate,     /*!< This value overrides the State sales tax rate unless the user overrides the State sales tax. */
    eCtqAttribCityPartialCountyRate,    /*!< This value overrides the State sales tax rate unless the user overrides the State sales tax. */
    eCtqAttribCityCountyOverrideFlag,   /*!< Allows the suppression of certain State and County tax calculations. Sized by CTQ_FLAG_SIZE. */

   /* ------------- decision and maxtier object attributes ---------------- */

    eCtqAttribTierType,                     /*!< The tier type of a maximum tax or tiered tax rule. Sized by CTQ_TIER_TYPE_SIZE. */
    eCtqAttribRangeType,                    /*!< The range type of a maximum tax or tiered tax rule. Sized by CTQ_RANGE_TYPE_SIZE. */
    eCtqAttribValueType,                    /*!< The value subject to a maximum tax or tiered tax rule. Sized by CTQ_VALUE_TYPE_SIZE. */
    eCtqAttribPeriodType,                   /*!< The period over which a maximum tax or tiered tax rule applies. Sized by CTQ_PERIOD_TYPE_SIZE. */
    eCtqAttribStartMonth,                   /*!< The starting month for a maximum tax or tiered tax rule. Sized by CTQ_START_MONTH_SIZE. */
    eCtqAttribRateDescriptionCode,          /*!< The code used to associate a CommTax rate to its description. Sized by
                                                 CTQ_RATE_DESCRIPTION_CODE_SIZE. */
    eCtqAttribTaxableCode,                  /*!< The taxable code associated with a decision record. Sized by CTQ_TAXABLE_CODE_SIZE. */
    eCtqAttribCustomerCode,                 /*!< A code used to designate the customer of a CommTax transaction. Sized by
                                                 CTQ_CUSTOMER_CODE_SIZE. */
    eCtqAttribUtilityCode,                  /*!< A code used to describe the type of utility providing the product or service.
                                                   Sized by CTQ_UTILITY_CODE_SIZE. */
    eCtqAttribSaleResaleCode,               /*!< The code used to indicate whether the product or service was sold for resale. Sized by
                                                 CTQ_SALE_RESALE_CODE_SIZE. */
    eCtqAttribMaxTierCode,                  /*!< The code used used to describe a maximum tax or tiered tax rule. Sized by
                                                 CTQ_MAX_TIER_CODE_SIZE. */
    eCtqAttribRoundingRule,                 /*!< The rounding rule associated with a decision record. Sized by CTQ_FUNCTION_CODE_SIZE. */
    eCtqAttribLinkTaxType,                  /*!< The tax type of a linked tax associated with a decision record. Sized by CTQ_TAX_TYPE_SIZE. */
    eCtqAttribLinkTaxAuthority,             /*!< The taxing authority of a linked tax associated with a decision rtecord. Sized by
                                                 CTQ_TAX_AUTHORITY_SIZE. */
    eCtqAttribOverrideTaxType,              /*!< The tax type of an override of a decision record. Sized by CTQ_TAX_TYPE_SIZE. */
    eCtqAttribOverrideTaxAuthority,         /*!< The taxing authority of an override of a decision rtecord. Sized by CTQ_TAX_AUTHORITY_SIZE. */
    eCtqAttribAccumAsTaxType,               /*!< The tax type under which to accumulate other taxes. Sized by CTQ_TAX_TYPE_SIZE. */
    eCtqAttribAccumAsTaxAuthority,          /*!< The taxing authority under which to accumulate other taxes. Sized by CTQ_TAX_AUTHORITY_SIZE. */
    eCtqAttribMaxTaxAmount,                 /*!< The maximum tax amount associated with a tax that has such a limit. */
    eCtqAttribStartValue,                   /*!< The starting value of a maximum tax or tiered tax rule. */
    eCtqAttribEndValue,                     /*!< The ending value of a maximum tax or tiered tax rule. */
    eCtqAttribTaxValue,                     /*!< The tax rate of a maximum tax or tiered tax rule. */

    eCtqAttribDFC1 = eCtqAttribRateDescriptionCode, /*!< Equivalent to: #eCtqAttribRateDescriptionCode. Supplied for bacward compatibility. */
    eCtqAttribDFC2 = eCtqAttribTaxableCode,         /*!< Equivalent to: #eCtqAttribTaxableCode. Supplied for bacward compatibility. */
    eCtqAttribDFC3 = eCtqAttribCustomerCode,        /*!< Equivalent to: #eCtqAttribCustomerCode. Supplied for bacward compatibility. */
    eCtqAttribDFC4 = eCtqAttribUtilityCode,         /*!< Equivalent to: #eCtqAttribUtilityCode. Supplied for bacward compatibility. */
    eCtqAttribDFC5 = eCtqAttribSaleResaleCode,      /*!< Equivalent to: #eCtqAttribSaleResaleCode. Supplied for bacward compatibility. */
    eCtqAttribDFC6 = eCtqAttribMaxTierCode,         /*!< Equivalent to: #eCtqAttribMaxTierCode. Supplied for bacward compatibility. */
    eCtqAttribDFC7 = eCtqAttribRoundingRule,        /*!< Equivalent to: #eCtqAttribRoundingRule. Supplied for bacward compatibility. */

    /*----------------------- transaction object attributes -------------------*/

    eCtqAttribOriginGeoCode,                  /*!< The GeoCode of the origin location for a CommTax transaction. Sized by CTQ_GEOCODE_SIZE. */
    eCtqAttribOriginPostalCode,               /*!< The postal code of the origin location. Sized by CTQ_ZIPPLUS4_SIZE. */
    eCtqAttribOriginNpaNxx,                   /*!< The NPA/NXX number of the origin location. Sized by CTQ_NPA_NXX_SIZE. */
    eCtqAttribOriginIncorporatedCode,         /*!< The incorporated code of the origin location. Sized by CTQ_FLAG_SIZE. */
    eCtqAttribTerminationGeoCode,             /*!< The GeoCode of the termination location. Sized by CTQ_GEOCODE_SIZE. */
    eCtqAttribTerminationPostalCode,          /*!< The postal code of the termination location. Sized by CTQ_ZIPPLUS4_SIZE. */
    eCtqAttribTerminationNpaNxx,              /*!< The NPA/NXX number of the termination location. Sized by CTQ_NPA_NXX_SIZE. */
    eCtqAttribTerminationIncorporatedCode,    /*!< The incorporated code of the termination location. Sized by CTQ_FLAG_SIZE. */
    eCtqAttribChargeToGeoCode,                /*!< The GeoCode of the charge-to location. Sized by CTQ_GEOCODE_SIZE. */
    eCtqAttribChargeToPostalCode,             /*!< The postal code of the charge-to location. Sized by CTQ_ZIPPLUS4_SIZE. */
    eCtqAttribChargeToNpaNxx,                 /*!< The NPA/NXX number of the charge-to location. Sized by CTQ_NPA_NXX_SIZE. */
    eCtqAttribChargeToIncorporatedCode,       /*!< The incorporated code of the charge-to location. Sized by CTQ_FLAG_SIZE. */
    eCtqAttribCreditCode,                     /*!< The code used to indicate if the transaction is a credit. Sized by CTQ_FLAG_SIZE. */
    eCtqAttribTrunkLines,                     /*!< The number of trunk lines billed. */
    eCtqAttribBilledLines,                    /*!< The number of lines billed. */
    eCtqAttribTaxableAmount,                  /*!< The amount being taxed. */
    eCtqAttribDescriptionFlag,                /*!< A flag used to indicate whether or not to retrieve location information for the taxed GeoCode.
                                                   Sized by CTQ_FLAG_SIZE. */
    eCtqAttribTaxedGeoCode,                   /*!< The GeoCode of the location where taxes are collected. Sized by CTQ_GEOCODE_SIZE. */
    eCtqAttribTaxedStateCode,                 /*!< The state code of the location where taxes are collected. Sized by CTQ_STATE_ABBREVIATION_SIZE. */
    eCtqAttribTaxedCountyName,                /*!< The county name of the location where taxes are collected. Sized by CTQ_COUNTY_NAME_SIZE. */
    eCtqAttribTaxedCityName,                  /*!< The city name of the location where taxes are collected. Sized by CTQ_CITY_NAME_SIZE. */
    eCtqAttribTaxedDistrictName,			  /*!< The district name of the location where taxes are collected. Sized by CTQ_DISTRICT_NAME_SIZE. */
	eCtqAttribTaxAuthority,                   /*!< The authority level of a taxing jurisdiction to which taxes are due. Sized by
                                                   CTQ_TAX_AUTHORITY_SIZE. */
    eCtqAttribTaxType,                        /*!< The tax type of a rate applied to a transaction. Sized by CTQ_TAX_TYPE_SIZE. */
    eCtqAttribTaxCode,                        /*!< The code associated with a tax applied to a transaction. Sized by CTQ_TAX_CODE_SIZE. */
    eCtqAttribTaxAmount,                      /*!< The amount calculated by applying a rate to a taxable amount. */
    eCtqAttribLinesTaxed,                     /*!< The number of lines taxed. */
    eCtqAttribTrunksTaxed,                    /*!< The number of trunk lines taxed. */
	eCtqAttribCustomerOverride,               /*!< Flag set to true if detail object is a customer override. */
    eCtqAttribFranchiseAreaId,                /*!< The area for which franchise fees are added. */

    /*----------------------- register journal object attributes -------------------*/

    eCtqAttribTimeStamp,                      /*!< The time at which a transaction is recorded in the Register. Sized by CTQ_TIMESTAMP_SIZE. */
    eCtqAttribOriginLocation,                 /*!< The origin location of a CommTax transaction. Sized by CTQ_GEOCODE_SIZE. */
    eCtqAttribTerminationLocation,            /*!< The termination location of a CommTax transaction. Sized by CTQ_GEOCODE_SIZE. */
    eCtqAttribChargeToLocation,               /*!< The charge-to location of a CommTax transaction. Sized by CTQ_GEOCODE_SIZE. */
    eCtqAttribOriginLocationMode,             /*!< Specifies whether the origin location is expressed as a GeoCode, postal code, or NPA/NXX.
                                                   Sized by CTQ_FLAG_SIZE. */
    eCtqAttribTerminationLocationMode,        /*!< Specifies whether the termination location is expressed as a GeoCode, postal code, or NPA/NXX.
                                                   Sized by CTQ_FLAG_SIZE. */
    eCtqAttribChargeToLocationMode,           /*!< Specifies whether the charge-to location is expressed as a GeoCode, postal code, or NPA/NXX.
                                                   Sized by CTQ_FLAG_SIZE. */
    eCtqAttribInvoiceDate,                    /*!< The invoice date of a CommTax transaction. Sized by CTQ_DATE_SIZE. */
    eCtqAttribInvoiceNumber,                  /*!< The invoice number of a CommTax transaction. Sized by CTQ_INVOICE_NUMBER_SIZE. */
    eCtqAttribCustomerReference,              /*!< The customer reference number associated with the transaction. Sized by
                                                   CTQ_CUSTOMER_REFERENCE_SIZE. */
    eCtqAttribTransactionCode,                /*!< A code used to describe the type of transaction. Sized by CTQ_TRANSACTION_CODE_SIZE. */
    eCtqAttribTaxedGeoCodeIncorporatedCode,   /*!< A code that describes whether or not the taxing jurisdiction is incorporated. Sized by
                                                   CTQ_FLAG_SIZE. */
    eCtqAttribTaxedGeoCodeOverrideCode,       /*!< A code used to to explicitly specify the taxing jurisdiction. Sized by CTQ_FLAG_SIZE. */
    eCtqAttribCallMinutes,                    /*!< The number of minutes associate with a telecommunications service. */
    eCtqAttribFederalExemptFlag,              /*!< A flag used to exempt the transaction from federal taxes. Sized by CTQ_FLAG_SIZE. */
    eCtqAttribStateExemptFlag,                /*!< A flag used to exempt the transaction from state taxes. Sized by CTQ_FLAG_SIZE. */
    eCtqAttribCountyExemptFlag,               /*!< A flag used to exempt the transaction from county taxes. Sized by CTQ_FLAG_SIZE. */
    eCtqAttribCityExemptFlag,                 /*!< A flag used to exempt the transaction from city taxes. Sized by CTQ_FLAG_SIZE. */
    eCtqAttribCityDistrictExemptFlag,		  /*!< A flag used to exempt the transaction from district taxes (Auth=9). Sized by CTQ_FLAG_SIZE. */
    eCtqAttribCountyDistrictExemptFlag,		  /*!< A flag used to exempt the transaction from district taxes (Auth=7). Sized by CTQ_FLAG_SIZE. */
    eCtqAttribOtherExemptFlag,				  /*!< A flag used to exempt the transaction from district taxes (Auth=6). Sized by CTQ_FLAG_SIZE. */
	eCtqAttribUserArea,                       /*!< The user area field associated with a transaction recorded in the register. Sized by
                                                   CTQ_USER_AREA_SIZE. */
    eCtqAttribOriginInput,                    /*!< The input value used to specify the origin location. Sized by CTQ_ORIGIN_INPUT_SIZE. */
    eCtqAttribTerminationInput,               /*!< The input value used to specify the termination location. Sized by CTQ_TERMINATION_INPUT_SIZE. */
    eCtqAttribChargeToInput,                  /*!< The input value used to specify the charge-to location. Sized by CTQ_CHARGETO_INPUT_SIZE. */
    eCtqAttribBundleFlag,                     /*!< A flag used to indicate whether or not the product or service being taxed is a bundle. Sized
                                                   by CTQ_FLAG_SIZE. */
    eCtqAttribBundleCategoryCode,             /*!< The category code associated with a bundle definition. Sized by CTQ_CATEGORY_CODE_SIZE. */
    eCtqAttribBundleServiceCode,              /*!< The service code associated with a bundle definition. Sized by CTQ_SERVICE_CODE_SIZE*/
    eCtqAttribBundleArchiveSequence,          /*!< The sequence number associated with a bundle definition. */
    eCtqAttribExtractedFlag,                  /*!< Register record extracted flag. Sized by CTQ_FLAG_SIZE. */
    eCtqAttribReportedFlag,                   /*!< Register record reported flag. Sized by CTQ_FLAG_SIZE. */
    eCtqAttribLinkTaxAmount,                  /*!< A tax amount added to the taxable amount in order to calculate a linked tax. */
    
    /*----------- register accumulator object attributes ------------*/

    eCtqCriteriaAccrualYear,                  /*!< The year used for accumulator file queries. Sized by CTQ_YEAR_SIZE. */
    eCtqCriteriaAccrualMonth,                 /*!< The month used for accumulator file queries. Sized by CTQ_MONTH_SIZE. */
    eCtqCriteriaCustomerReferenceType,        /*!< The indicator used to indicate customer or invoice criteria for register or accumulator file queries.
                                                   Sized by CTQ_KEY_TYPE_SIZE. */
    eCtqCriteriaCustomerReference,            /*!< The invoice or customer number used for register or accumulator file queries. Sized by
                                                   CTQ_ACCUMULATOR_REFERENCE_SIZE. */

    eCtqAttribAccrualYear,                    /*!< The year associated with an accumulator file entry. Sized by CTQ_YEAR_SIZE. */
    eCtqAttribAccrualMonth,                   /*!< The month associated with an accumulator file entry. Sized by CTQ_MONTH_SIZE. */

    eCtqAttribCustomerReferenceType,          /*!< Indicates a customer or invoice record from the accumulator. Sized by CTQ_KEY_TYPE_SIZE. */

    eCtqAttribArchiveTimeStamp,               /*!< When an accumulator record was archived. Sized by CTQ_TIMESTAMP_SIZE. */
    eCtqAttribArchiveReasonFlag,              /*!< Why an accumulator record was archived. Sized by CTQ_FLAG_SIZE. */

    /* ---------------- new attributes for CTQ version 1.1 ----------------- */

    eCtqAttribDFCChangeFlag,                  /*!< Change flag for decision function code data on rate decision records. Sized by CTQ_FLAG_SIZE. */
    eCtqAttribGeoCodeRange,                   /*!< The first four digits of a GeoCode. GeoCode ranges are used internally by the publish process while
                                                   propagating customizations.  */
    eCtqAttribRecordCount,                    /*!< The number of rate records within a GeoCode range. */
    eCtqAttribDbType,                         /*!< The database type, as detected by the database connection logic. */
    eCtqAttribPackageDescription,             /*!< The description of a bundled service package.  Sized by CTQ_PACKAGE_DESCRIPTION_SIZE. */

    /* ---------------- new attributes for CTQ version 2.1 ----------------- */

    eCtqAttribIsTransactionPending,           /*!< (R/O) Contains the transaction state. */
    eCtqIncludeInvoiceLineItemId,             /*!< Indicates which Line Item ID records to include in the query result. Sized by enum. */
    eCtqCriteriaInvoiceNumber,                /*!< The invoice number used for tax journal queries. Sized by CTQ_INVOICE_NUMBER_SIZE. */
    eCtqAttribInvoiceLineItemId,              /*!< The invoice line item identifier assigned by the system within the Tax Journal. Sized by CTQ_NUMBER_SIZE. */
    eCtqAttribReversalTimeStamp,              /*!< The time at which a transaction is reversed in the Register. Sized by CTQ_TIMESTAMP_SIZE. */

    /*-------------- attribute comparison bit flags -----------------*/

    eCtqAttribGreater        = 1 << ((sizeof(int) * 8) - 1),         /*!< (First highest order bit) "Greater Than" criteria */
    eCtqAttribEqual          = 1 << ((sizeof(int) * 8) - 2),         /*!< (Second highest order bit) "Equal To" criteria */
    eCtqAttribLesser         = 1 << ((sizeof(int) * 8) - 3),         /*!< (Third highest order bit) "Less Than" criteria */

    eCtqAttribGreaterOrEqual = eCtqAttribEqual  | eCtqAttribGreater, /*!< (Second | First highest order bits) "Greater Than Or Equal To" criteria */
    eCtqAttribNotEqual       = eCtqAttribLesser | eCtqAttribGreater, /*!< (Third | First highest order bits) "Not Equal To" criteria */
    eCtqAttribLesserOrEqual  = eCtqAttribLesser | eCtqAttribEqual,   /*!< (Third | Second highest order bits) "Less Than Or Equal To" criteria */

    eCtqAttribAny            = eCtqAttribLesser | eCtqAttribEqual | eCtqAttribGreater
} tCtqAttrib;

/*!
 * Loggable data (bit flags)
 * Used primarily for internal Vertex debugging of the system.
 *
 * \note These directly correspond to the data logging elements in ctqcfg.xml
 */

typedef enum eCtqLogData
{
    eCtqLogNoData     = 0,   /*!< A special case in that this value is not a bitmask. If the
                                  Loggable Data Indicator is equal to this value, none of the
                                  data below shall be logged. */
    eCtqLogSourceFile = 1,   /*!< The source module's name                                                                 */
    eCtqLogLine       = 2,   /*!< The source module's line number                                                          */
    eCtqLogName       = 4,   /*!< The variable's name                                                               */
    eCtqLogType       = 8,   /*!< The variable's type (as reported by the developer)                                */
    eCtqLogSize       = 16,  /*!< The variable's size (as reported by the developer and sizeof)                     */
    eCtqLogAddress    = 32,  /*!< The variable's address                                                            */
    eCtqLogValue      = 64,  /*!< The variable's value (using the type reported by the developer)                   */
    eCtqLogArray      = 128, /*!< The variable's array elements (using the size and type reported by the developer) */
    eCtqLogAllData    = 255  /*!< All of the above data                                                             */
} tCtqLogData;

/*!
 * Loggable events (bit flags)
 * Used to monitor system activity within a log file.
 *
 * \note These directly correspond to the event logging elements in ctqcfg.xml
 */

typedef enum eCtqLogEvents
{
    eCtqLogNoEvents     = 0,   /*!< A special case in that this value is not a bitmask.
                                    If the Loggable Events Indicator is equal to this
                                    value, none of the events below shall be logged.     */

    eCtqLogDebugDetail  = 1,   /*!< Low level debug information           */
    eCtqLogDebugSummary = 2,   /*!< High level debug information          */
    eCtqLogMinorInfo    = 4,   /*!< Minor informational messages          */
    eCtqLogMinorFailure = 8,   /*!< Minor failure messages (AKA warnings) */
    eCtqLogMinorSuccess = 16,  /*!< Minor success messages                */
    eCtqLogMajorInfo    = 32,  /*!< Major informational messages          */
    eCtqLogMajorFailure = 64,  /*!< Major failure messages                */
    eCtqLogMajorSuccess = 128, /*!< Major success messages                */
    eCtqLogAllEvents    = 255  /*!< All of the above events               */
} tCtqLogEvents;

/*!
 * CTQ Boolean values used to set boolean flags
 * also maps to eCtqResultCode
 */

typedef enum eCtqBool
{
    eCtqFalse = (0 != 0), /*!< corresponds to eCtqResultFalse */
    eCtqTrue  = (0 == 0)  /*!< corresponds to eCtqResultTrue  */
} tCtqBool;

/*!
 * Indicate how far a multi-step operation progressed
 *
 * When a multi-step operation fails the host application may interrogate
 * this state to determine how far processing progressed to determine how
 * to recover from the failure. See function result for cause of function
 * failure.
 */

typedef enum eCtqState
{
    eCtqStateOperationReset,                    /*!< The operation has yet not been invoked since the last handle reset */

    eCtqStateOperationInitialized,              /*!< The operation was invoked, but no real processing has yet occured */

    /* CtqReverseTax() specific states */

    eCtqStateReverseTaxDetailInitialized,       /*!< Ready to reverese tax detail information */
    eCtqStateReverseTaxDetailProcessed,         /*!< The tax detail information (RegJtx) has been reversed */
    eCtqStateReverseTaxDetailFinalized,         /*!< Cleaned up after the tax detail information has been reversed */

    eCtqStateReverseTaxTransactionInitialized,  /*!< Ready to reverse tax transaction summary information */
    eCtqStateReverseTaxTransactionProcessed,    /*!< The tax transaction summary information (RegJrn) has been reversed */
    eCtqStateReverseTaxTransactionFinalized,    /*!< Cleaned up after the tax transaction summary information has been reversed */

    eCtqStateReverseTaxAccumulatorInitialized,  /*!< Ready to reverse tax accumulator information */
    eCtqStateReverseTaxAccumulatorProcessed,    /*!< The tax accumulator information (RegAcc/RegAdd) has been reversed */
    eCtqStateReverseTaxAccumulatorFinalized,    /*!< Cleaned up after the tax accumulator information has been reversed */

    eCtqStateOperationFinalized                 /*!< The operation completed */
} tCtqState;

/*!
 * Result Codes which may be returned by function/method calls.
 *
 * \internal
 *
 * \note Changes to these values must also be reflected in the textual
 *       descriptions within gCtqResultCodeInterpretation
 */

typedef enum eCtqResultCode
{
    /*--------------------------------------- "Normal" Return Codes ----------------------------------------*/
    
    eCtqResultTaxedGeoNotDetermined = -90,/*!< Taxed GeoCode could not be determined                         */

    eCtqResultAlreadyInitialized = -10,   /*!< Indicates that an object was already initialized (possibly by another thread) */

    eCtqResultAttributeUnvalued = -7,     /*!< An attempt has been made to retrieve an attribute's value but the attribute has not been assigned a value */
    eCtqResultAttributeValuedNull = -6,   /*!< An attempt has been made to retrieve an attribute's value but the attribute has been set to a NULL DATA value */

    eCtqResultRecordReplaced = -5,        /*!< An insert operation succeded by updating                       */

    eCtqResultNoParentRecords = -4,       /*!< Indicates no match in the parent table on the inquiry criteria */

    eCtqResultMoreRecords = -3,           /*!< Indicates more data remains to be retrieved                    */

    eCtqResultNoMoreRecords = -2,         /*!< Indicates no data remains to be retrieved                      */
    eCtqResultNoRecords = -1,             /*!< Indicates no match on the inquiry criteria                     */

    eCtqResultSuccess = 0,                /*!< Success                                                        */

    /*--------------------------------- L Series Calc Module Return Codes ----------------------------------*/

    eCtqResultMaxTaxesExceeded = 01,      /*!< Exceeded the maximum number of taxes the array structure can hold */
    eCtqResultMaxOverridesExceeded = 02,  /*!< Exceeded the maximum number of overrides that the array structure can hold */
    eCtqResultInvalidOrigOrTermGeo = 51,  /*!< Invalid Origin or Termination GeoCode specified */
    eCtqResultInvalidCategoryOrServiceCode = 53, /*!< Invalid Category or Service Code specified */
    eCtqResultLocationInquiry = 61,       /*!< An unexpected error occurred querying the location database by GeoCode. */
    eCtqResultGeoCodeNotFound = 62,       /*!< A location query by GeoCode returned no match.                 */
    eCtqResultZip4Error = 63,             /*!< A location query by Zip+4 returned more than one match and the 'zip4Error' flag was enabled. */
    eCtqResultInvalidZipPlus4 = 81,       /*!< Invalid Zip+4 value specified */
	eCtqResultBlankStateCode = 84,        /*!< While processing zip access, State Code was blank.             */
    eCtqResultInvalidZip = 85,            /*!< The zip code was invalid for the state code specified.         */
    eCtqResultNoMaxTierData = 87,         /*!< For the taxing jurisdiction, decision function code 6 is 'M' and no max tier data could be loaded. */
    eCtqResultInvalidNpaNxx = 89,		  /*!< Invalid NpaNxx specified */
	eCtqResultNoBundleDefinition = 90,    /*!< The components of a bundle could not be loaded while trying to calculate tax on a bundled service. */
	eCtqResultInvalidBundle = 95,	      /*!< Invalid bundle specified */

    /*---------------------------------------- Failure Return Codes ----------------------------------------*/

    eCtqResultFailure = 100,              /*!< Unspecified, Generic error                                     */
    eCtqResultAssert,                     /*!< Function parameter assertion failed                            */
    eCtqResultMemoryCorrupt,              /*!< Object attribute corruption                                    */
    eCtqResultFreeMemory,                 /*!< A memory deallocation failed                                   */
    eCtqResultAllocMemory,                /*!< A memory allocation failed                                     */
    eCtqResultLockCreate,                 /*!< A system mutex allocation failed                               */
    eCtqResultLock,                       /*!< A system mutex lock errored                                    */
    eCtqResultUnlock,                     /*!< A system mutex unlock errored                                  */
    eCtqResultLockDestroy,                /*!< A system mutex deallocation failed                             */
    eCtqResultThreadWait,                 /*!< More than one thread is waiting for child threads to terminate */
    eCtqResultNullPointer,                /*!< A NULL pointer was passed unexpectedly                         */
    eCtqResultFileOpen,                   /*!< fopen (for write) failed                                       */
    eCtqResultFileNotFound,               /*!< fopen (for read) failed                                        */
    eCtqResultFileRename,                 /*!< A file rename failed                                           */
    eCtqResultFileRemove,                 /*!< A file remove failed                                           */
    eCtqResultFileInvalid,                /*!< The file content was incorrect                                 */
    eCtqResultFileRead,                   /*!< A read operation on a file failed unexpectedly                 */
    eCtqResultFileWrite,                  /*!< A write operation on a file failed unexpectedly                */
    eCtqResultAllocXMLParser,             /*!< The XML parser failed to allocate                              */
    eCtqResultAllocODBCEnvHandle,         /*!< ODBC environment handle allocation failed                      */
    eCtqResultAllocODBCSQLHandle,         /*!< ODBC SQL handle allocation failed                              */
    eCtqResultSetODBCEnvAttr,             /*!< ODBC environment attribute set failed                          */
    eCtqResultSetODBCConnAttr,            /*!< ODBC connection attribute set failed                           */
    eCtqResultAllocODBCStmt,              /*!< ODBC statment handle allocation failed                         */
    eCtqResultFreeODBCStmt,               /*!< ODBC statment handle deallocation failed                       */
    eCtqResultSetODBCStmtAttr,            /*!< ODBC statement attribute set failed                            */
    eCtqResultConnectODBC,                /*!< ODBC connection failed                                         */
    eCtqResultDisconnectODBC,             /*!< ODBC disconnection failed                                      */
    eCtqResultNotConnected,               /*!< ODBC connection is not established                             */
    eCtqResultTransactionActive,          /*!< Can not begin a transaction while the last transaction is uncommitted */
    eCtqResultTransactionInactive,        /*!< Can not commit or rollback a transaction that has not yet begun */
    eCtqResultSequenceError,              /*!< A database error generating a table sequence number            */
    eCtqResultSequenceLocked,             /*!< A sequence number row is locked (may need manual reset)        */
    eCtqResultBeginTransaction,           /*!< A database begin transaction operation failed                  */
    eCtqResultCommitTransaction,          /*!< A database commit operation failed                             */
    eCtqResultRollbackTransaction,        /*!< A database rollback operation failed                           */
    eCtqResultBind,                       /*!< A parameter or column bind operation failed                    */
    eCtqResultNotUnique,                  /*!< A database operation failed due to a non-unique record         */
    eCtqResultConcurrencyFailure,         /*!< A database operation failed due to another thread or process modifying the record to be updated after the record was read */
    eCtqResultInsert,                     /*!< A database insert operation failed                             */
    eCtqResultUpdate,                     /*!< A database update operation failed                             */
    eCtqResultDelete,                     /*!< A database delete operation failed                             */
    eCtqResultSelect,                     /*!< A database select operation failed                             */
    eCtqResultFetch,                      /*!< A result set fetch operation failed                            */
    eCtqResultDatabaseVersion,            /*!< The CTQ database version is invalid                            */
    eCtqResultSetOnlyAttrib,              /*!< Attribute cannot be read                                       */
    eCtqResultGetOnlyAttrib,              /*!< Attribute cannot be set                                        */
    eCtqResultAttributeNotNullable,       /*!< An attempt has been made to set an attribute to NULL DATA but the attribute may not be set to a null value */    
    eCtqResultInvalidAttrib,              /*!< Invalid tCtqAttrib for reference object                        */
    eCtqResultInvalidHandle,              /*!< Handle is corrupt or invalid                                   */
    eCtqResultTypeMismatch,               /*!< Invalid tAttribType for attribute                              */
    eCtqResultObjectMismatch,             /*!< Invalid object type for method/attribute.                      */
    eCtqResultObjectState,                /*!< The object is not in proper state to process a request         */
    eCtqResultObjectIsEmpty,              /*!< An attempt has been made to retrieve a row-level attribute but
                                             the object has no rows allocated.                              */
    eCtqResultDeferred,                   /*!< Method or attribute is not implemented                         */
    eCtqResultRowLimit,                   /*!< No more attribute rows may be allocated                        */
    eCtqResultInvalidCriteria,            /*!< Incorrect criteria were set for inquiry                        */
    eCtqResultInvalidValue,               /*!< An inappropriate value for an attribute                        */
    eCtqResultInvalidState,               /*!< The system attempted to enter an invalid state                 */
    eCtqResultInvalidAction,              /*!< Object does not support invoked operation                      */
    eCtqResultMissingCriteria,            /*!< Insufficient criteria were set for inquiry                     */
    eCtqResultMissingValues,              /*!< Required attributes were not set                               */
    eCtqResultMissingAttribute,           /*!< An attribute that is required to perform a requested action is missing or has not been set */
    eCtqResultInvalidSize,                /*!< A size-oriented parameter is incorrect.                        */
    eCtqResultInvalidTable,               /*!< Invalid table name for reference object                        */
    eCtqResultRejectedValue,              /*!< A legal but incongruent value was rejected from a data set     */
    eCtqResultBatchFailure,               /*!< One or more errors were detected while processing a transaction batch */

    eCtqResultMissingCLISwitchValue,      /*!< A CLI switch parameter value was not provided                  */
    eCtqResultInvalidCLISwitchValue,      /*!< A CLI switch parameter value was unexpected or not acceptable  */
    eCtqResultMismatchedCLISwitchValues,  /*!< Incompatible CLI switch values occured on the command line     */

    eCtqResultFallThroughError,           /*!< The system has entered an unexpected state                     */

    /*----------------------------------- ctqcfg.xml Data Parsing Errors -----------------------------------*/

    eCtqResultXMLParse,                   /*!< The ctqcfg.xml failed to parse due to a syntax error           */

    eCtqResultInvalidDbCtqcfg,            /*!< version != "1.1"                                               */
    eCtqResultInvalidDbConnection,        /*!< the name or default attribute is invalid value                 */
    eCtqResultInvalidPassword,            /*!< encrypted attribute is invalid value                           */
    eCtqResultInvalidSequenceBlockSize,   /*!< An unsupported or invalid table was referenced                 */
    eCtqResultInvalidRetryInterval,       /*!< The database connection does not support sequence blocks       */
    eCtqResultInvalidMaximumRetries,      /*!< The database connection does not support sequence blocks       */

    eCtqResultMisplacedCtqcfg,            /*!< A ctqcfg element was found out of place in ctqcfg.xml          */
    eCtqResultMisplacedConfiguration,     /*!< A configuration element was found out of place in ctqcfg.xml   */
    eCtqResultMisplacedFileControl,       /*!< A file control element was found out of place in ctqcfg.xml    */
    eCtqResultMisplacedArchivePath,       /*!< An archive path element was found out of place in ctqcfg.xml   */
    eCtqResultMisplacedLogPath,           /*!< A log path element was found out of place in ctqcfg.xml        */
    eCtqResultMisplacedReportPath,        /*!< A report path element was found out of place in ctqcfg.xml     */
    eCtqResultMisplacedUpdatePath,        /*!< An update path element was found out of place in ctqcfg.xml    */
    eCtqResultMisplacedCallFilePath,      /*!< A call file path element was found out of place in ctqcfg.xml    */
    eCtqResultMisplacedReportControl,     /*!< A report control element was found out of place in ctqcfg.xml  */
    eCtqResultMisplacedPageLength,        /*!< A page length element was found out of place in ctqcfg.xml     */
    eCtqResultMisplacedLogControl,        /*!< A log element was found out of place in ctqcfg.xml             */
    eCtqResultMisplacedLogNoData,         /*!< A logNoData element was found out of place in ctqcfg.xml       */
    eCtqResultMisplacedLogSourceFile,     /*!< A logSourceFile element was found out of place in ctqcfg.xml   */
    eCtqResultMisplacedLogLine,           /*!< A logLine element was found out of place in ctqcfg.xml         */
    eCtqResultMisplacedLogName,           /*!< A logName element was found out of place in ctqcfg.xml         */
    eCtqResultMisplacedLogType,           /*!< A logType element was found out of place in ctqcfg.xml         */
    eCtqResultMisplacedLogSize,           /*!< A logSize element was found out of place in ctqcfg.xml         */
    eCtqResultMisplacedLogAddress,        /*!< A logAddress element was found out of place in ctqcfg.xml      */
    eCtqResultMisplacedLogValue,          /*!< A logValue element was found out of place in ctqcfg.xml        */
    eCtqResultMisplacedLogArray,          /*!< A logArray element was found out of place in ctqcfg.xml        */
    eCtqResultMisplacedLogAllData,        /*!< A logAllData element was found out of place in ctqcfg.xml      */
    eCtqResultMisplacedLogNoEvents,       /*!< A logNoEvents element was found out of place in ctqcfg.xml     */
    eCtqResultMisplacedLogMinorDebug,     /*!< A logMinorDebug element was found out of place in ctqcfg.xml   */
    eCtqResultMisplacedLogMajorDebug,     /*!< A logMajorDebug element was found out of place in ctqcfg.xml   */
    eCtqResultMisplacedLogMinorSuccess,   /*!< A logMinorSuccess element was found out of place in ctqcfg.xml */
    eCtqResultMisplacedLogMinorWarning,   /*!< A logMinorWarning element was found out of place in ctqcfg.xml */
    eCtqResultMisplacedLogMinorFailure,   /*!< A logMinorFailure element was found out of place in ctqcfg.xml */
    eCtqResultMisplacedLogMajorSuccess,   /*!< A logMajorSuccess element was found out of place in ctqcfg.xml */
    eCtqResultMisplacedLogMajorWarning,   /*!< A logMajorWarning element was found out of place in ctqcfg.xml */
    eCtqResultMisplacedLogMajorFailure,   /*!< A logMajorFailure element was found out of place in ctqcfg.xml */
    eCtqResultMisplacedLogAllEvents,      /*!< A logAllEvents element was found out of place in ctqcfg.xml    */
    eCtqResultMisplacedRegisterControl,   /*!< A register control element was found out of place in ctqcfg.xml*/
    eCtqResultMisplacedWriteToAcc,        /*!< A logWriteToAcc element was found out of place in ctqcfg.xml   */
    eCtqResultMisplacedWriteToJrn,        /*!< A logWriteToJrn element was found out of place in ctqcfg.xml   */
    eCtqResultMisplacedReturnZRT,         /*!< A returnZeroRateTaxes element was found out of place in ctqcfg.xml */
    eCtqResultMisplacedzip4Err,			  /*!< A zip4Err element was found out of place in ctqcfg.xml */
	eCtqResultMisplacedCacheControl,      /*!< A cacheControl element was found out of place in ctqcfg.xml    */
    eCtqResultMisplacedCache,             /*!< A cache element was found out of place in ctqcfg.xml           */
    eCtqResultMisplacedDbConnection,      /*!< A dbConnection element was found out of place in ctqcfg.xml    */
    eCtqResultMisplacedDsn,               /*!< A dsn element was found out of place in ctqcfg.xml             */
    eCtqResultMisplacedSchema,            /*!< A schema element was found out of place in ctqcfg.xml          */
    eCtqResultMisplacedCatalog,           /*!< A catalog element was found out of place in ctqcfg.xml         */
    eCtqResultMisplacedUsername,          /*!< A username element was found out of place in ctqcfg.xml        */
    eCtqResultMisplacedPassword,          /*!< A password element was found out of place in ctqcfg.xml        */
    eCtqResultMisplacedSequenceBlockSize, /*!< A sequence block size element was found out of place in ctqcfg.xml */
    eCtqResultMisplacedRetryInterval,     /*!< A retry interval element was found out of place in ctqcfg.xml  */
    eCtqResultMisplacedMaximumRetries,    /*!< A maximum retries element was found out of place in ctqcfg.xml */
    eCtqResultMissingParameterValue,      /*!< A required command line parameter value is missing             */ 
	eCtqResultInvalidParameterValue,      /*!< A command line parameter value is invalid                      */
	eCtqResultInvalidMonthlyUpdateFile,   /*!< Attempted to import an invalid update file					  */


    /*--------------------------------------- Boolean Return Codes -----------------------------------------*/

    eCtqResultFalse = eCtqFalse,        /*!< A negative boolean result mapped to a eCtqResult code value    */
    eCtqResultTrue = eCtqTrue           /*!< A positive boolean result mapped to a eCtqResult code value    */
} tCtqResultCode;

/*!
 * The generic data type which is used to reference objects.
 */

typedef void * tCtqHandle;

#endif /* STDA_H */

/*!
 * End user access to the following result code descriptions should be programmatically obtained via the
 * CtqInquireResultCode() function of the Vertex Communications Tax Application Programmer's Interface
 * (see ctqa.h). These result code descriptions are provided within this C header file mearly as a
 * convenience to Vertex Development for purposes of maintaining result code definitions within a single
 * source module. End user reliance upon these values is subject to change (without notice) at the
 * discretion of Vertex Development.
 */

#if (defined(INCLUDE_RESULT_CODE_DESCRIPTIONS) && !defined(RESULT_CODE_DESCRIPTIONS_INCLUDED))

#define RESULT_CODE_DESCRIPTIONS_INCLUDED

/*!
 * CTQ Result Code Interpretation Table.
 */

typedef struct sCtqResultCodeInterpretation
{
    tCtqResultCode  ResultCode;
    char *          Variable;
    char *          Description;
} tCtqResultCodeInterpretation;

/*
#define CTQ_UTL_ERROR_COUNT 147
*/

#define CTQ_UTL_ERROR_COUNT 148

static tCtqResultCodeInterpretation gCtqResultCodeInterpretation[CTQ_UTL_ERROR_COUNT] = {
    {eCtqResultTaxedGeoNotDetermined,        (char *) "eCtqResultTaxedGeoNotDetermined",        (char *) "Taxed GeoCode could not be determined"},
    {eCtqResultAttributeUnvalued,            (char *) "eCtqResultAttributeUnvalued",            (char *) "An attempt has been made to retrieve an attribute value but the attribute has not been assigned a value"},
    {eCtqResultAttributeValuedNull,          (char *) "eCtqResultAttributeValuedNull",          (char *) "An attempt has been made to retrieve an attribute's value but the attribute has been set to a NULL DATA value"},
    {eCtqResultRecordReplaced,               (char *) "eCtqResultRecordReplaced",               (char *) "An insert operation succeded by updating"},
    {eCtqResultNoParentRecords,              (char *) "eCtqResultNoParentRecords",              (char *) "Indicates no match in the parent table on the inquiry criteria"},
    {eCtqResultMoreRecords,                  (char *) "eCtqResultMoreRecords",                  (char *) "Indicates more data remains to be retrieved"},
    {eCtqResultNoMoreRecords,                (char *) "eCtqResultNoMoreRecords",                (char *) "Indicates no data remains to be retrieved"},
    {eCtqResultNoRecords,                    (char *) "eCtqResultNoRecords",                    (char *) "Indicates no match on the inquiry criteria"},
    {eCtqResultAlreadyInitialized,           (char *) "eCtqResultAlreadyInitialized",           (char *) "Indicates that an object was already initialized (possibly by another thread)"},
    {eCtqResultSuccess,                      (char *) "eCtqResultSuccess",                      (char *) "Success"},
    {eCtqResultLocationInquiry,              (char *) "eCtqResultLocationInquiry",              (char *) "An unexpected error occurred querying the location database by GeoCode"},
    {eCtqResultGeoCodeNotFound,              (char *) "eCtqResultGeoCodeNotFound",              (char *) "A location query by GeoCode returned no match"},
    {eCtqResultZip4Error,                    (char *) "eCtqResultZip4Error",                    (char *) "A location query by Zip+4 returned more than one match and the 'zip4Error' flag was enabled"},
    {eCtqResultInvalidZipPlus4,				 (char *) "eCtqResultInvalidZipPlus4",				(char *) "Invalid Zip+4 value specified"},
	{eCtqResultBlankStateCode,               (char *) "eCtqResultBlankStateCode",               (char *) "State Code Blank on zip access"},
    {eCtqResultInvalidZip,                   (char *) "eCtqResultInvalidZip",                   (char *) "Invalid zip code for state code specified"},
    {eCtqResultNoMaxTierData,                (char *) "eCtqResultNoMaxTierData",                (char *) "Max/tier data could not be loaded for taxing jurisdiction"},
    {eCtqResultInvalidNpaNxx,				 (char *) "eCtqResultInvalidNpaNxx",				(char *) "Invalid NpaNxx specified"},
	{eCtqResultNoBundleDefinition,           (char *) "eCtqResultNoBundleDefinition",           (char *) "Components could not be loaded for a bundled service"},
	{eCtqResultInvalidBundle,				 (char *) "eCtqResultInvalidBundle",				(char *) "Invalid bundle specified"},
    {eCtqResultFailure,                      (char *) "eCtqResultFailure",                      (char *) "Unspecified, Generic error"},
    {eCtqResultAssert,                       (char *) "eCtqResultAssert",                       (char *) "Function parameter assertion failed"},
    {eCtqResultMemoryCorrupt,                (char *) "eCtqResultMemoryCorrupt",                (char *) "Object attribute corruption"},
    {eCtqResultFreeMemory,                   (char *) "eCtqResultFreeMemory",                   (char *) "A memory deallocation failed"},
    {eCtqResultAllocMemory,                  (char *) "eCtqResultAllocMemory",                  (char *) "A memory allocation failed"},
    {eCtqResultLockCreate,                   (char *) "eCtqResultLockCreate",                   (char *) "A system mutex allocation failed"},
    {eCtqResultLock,                         (char *) "eCtqResultLock",                         (char *) "A system mutex lock errored"},
    {eCtqResultUnlock,                       (char *) "eCtqResultUnlock",                       (char *) "A system mutex unlock errored"},
    {eCtqResultLockDestroy,                  (char *) "eCtqResultLockDestroy",                  (char *) "A system mutex deallocation failed"},
    {eCtqResultThreadWait,                   (char *) "eCtqResultThreadWait",                   (char *) "More than one thread is waiting for child threads to terminate"},
    {eCtqResultNullPointer,                  (char *) "eCtqResultNullPointer",                  (char *) "A NULL pointer was passed unexpectedly"},
    {eCtqResultFileOpen,                     (char *) "eCtqResultFileOpen",                     (char *) "fopen (for write) operation failed"},
    {eCtqResultFileNotFound,                 (char *) "eCtqResultFileNotFound",                 (char *) "fopen (for read) operation failed"},
    {eCtqResultFileRename,                   (char *) "eCtqResultFileRename",                   (char *) "a file rename operation failed"},
    {eCtqResultFileRemove,                   (char *) "eCtqResultFileRemove",                   (char *) "a file remove operation failed"},
    {eCtqResultFileInvalid,                  (char *) "eCtqResultFileInvalid",                  (char *) "The file content was incorrect"},
    {eCtqResultFileRead,                     (char *) "eCtqResultFileRead",                     (char *) "A read operation on a file failed unexpectedly"},
    {eCtqResultFileWrite,                    (char *) "eCtqResultFileWrite",                    (char *) "A write operation on a file failed unexpectedly"},
    {eCtqResultAllocXMLParser,               (char *) "eCtqResultAllocXMLParser",               (char *) "The system could not allocate an internal XML Parser"},
    {eCtqResultAllocODBCEnvHandle,           (char *) "eCtqResultAllocODBCEnvHandle",           (char *) "ODBC environment handle allocation failed"},
    {eCtqResultAllocODBCSQLHandle,           (char *) "eCtqResultAllocODBCSQLHandle",           (char *) "ODBC SQL handle allocation failed"},
    {eCtqResultAllocODBCStmt,                (char *) "eCtqResultAllocODBCStmt",                (char *) "ODBC statement handle allocation failed"},
    {eCtqResultFreeODBCStmt,                 (char *) "eCtqResultFreeODBCStmt",                 (char *) "ODBC statement handle deallocation failed"},
    {eCtqResultSetODBCEnvAttr,               (char *) "eCtqResultSetODBCEnvAttr",               (char *) "ODBC environment attribute set failed"},
    {eCtqResultSetODBCConnAttr,              (char *) "eCtqResultSetODBCConnAttr",              (char *) "ODBC connection attribute set failed"},
    {eCtqResultConnectODBC,                  (char *) "eCtqResultConnectODBC",                  (char *) "ODBC connection failed"},
    {eCtqResultDisconnectODBC,               (char *) "eCtqResultDisconnectODBC",               (char *) "ODBC disconnection failed"},
    {eCtqResultNotConnected,                 (char *) "eCtqResultNotConnected",                 (char *) "ODBC connection is not established"},
    {eCtqResultTransactionActive,            (char *) "eCtqResultTransactionActive",            (char *) "Cannot begin a transaction while the last transaction is uncommitted"},
    {eCtqResultTransactionInactive,          (char *) "eCtqResultTransactionInactive",          (char *) "Cannot commit or rollback a transaction that has not yet begun"},
    {eCtqResultSequenceError,                (char *) "eCtqResultSequenceError",                (char *) "A database error generating a table sequence number"},
    {eCtqResultSequenceLocked,               (char *) "eCtqResultSequenceLocked",               (char *) "A sequence number row is locked (may need manual reset)"},
    {eCtqResultBeginTransaction,             (char *) "eCtqResultBeginTransaction",             (char *) "A database begin transaction operation failed"},
    {eCtqResultCommitTransaction,            (char *) "eCtqResultCommitTransaction",            (char *) "A database commit operation failed"},
    {eCtqResultRollbackTransaction,          (char *) "eCtqResultRollbackTransaction",          (char *) "A database rollback operation failed"},
    {eCtqResultBind,                         (char *) "eCtqResultBind",                         (char *) "A parameter or column bind operation failed"},
    {eCtqResultNotUnique,                    (char *) "eCtqResultNotUnique",                    (char *) "A database operation failed due to a non-unique record"},
    {eCtqResultConcurrencyFailure,           (char *) "eCtqResultConcurrencyFailure",           (char *) "A database operation failed due to another thread or process modifying the record to be updated after the record was read"},
    {eCtqResultInsert,                       (char *) "eCtqResultInsert",                       (char *) "A database insert operation failed"},
    {eCtqResultUpdate,                       (char *) "eCtqResultUpdate",                       (char *) "A database update operation failed"},
    {eCtqResultDelete,                       (char *) "eCtqResultDelete",                       (char *) "A database delete operation failed"},
    {eCtqResultSelect,                       (char *) "eCtqResultSelect",                       (char *) "A database select operation failed"},
    {eCtqResultFetch,                        (char *) "eCtqResultFetch",                        (char *) "A result set fetch operation failed"},
    {eCtqResultDatabaseVersion,              (char *) "eCtqResultDatabaseVersion",              (char *) "The CTQ database version is invalid"},
    {eCtqResultSetOnlyAttrib,                (char *) "eCtqResultSetOnlyAttrib",                (char *) "Attribute cannot be read"},
    {eCtqResultGetOnlyAttrib,                (char *) "eCtqResultGetOnlyAttrib",                (char *) "Attribute cannot be set"},
    {eCtqResultAttributeNotNullable,         (char *) "eCtqResultAttributeNotNullable",         (char *) "An attempt has been made to set an attribute to NULL DATA but the attribute may not be set to a null value"},
    {eCtqResultInvalidAttrib,                (char *) "eCtqResultInvalidAttrib",                (char *) "Invalid tCtqAttrib for reference object"},
    {eCtqResultInvalidHandle,                (char *) "eCtqResultInvalidHandle",                (char *) "Handle is corrupt or invalid"},
    {eCtqResultTypeMismatch,                 (char *) "eCtqResultTypeMismatch",                 (char *) "Invalid tAttribType for attribute"},
    {eCtqResultObjectMismatch,               (char *) "eCtqResultObjectMismatch",               (char *) "Invalid object type for method/attribute"},
    {eCtqResultObjectState,                  (char *) "eCtqResultObjectState",                  (char *) "The object has not been configured/initialized properly"},
    {eCtqResultObjectIsEmpty,                (char *) "eCtqResultObjectIsEmpty",                (char *) "An attempt has been made to retrieve a row-level attribute but the object has no rows allocated"},
    {eCtqResultDeferred,                     (char *) "eCtqResultDeferred",                     (char *) "Method or attribute is not implemented"},
    {eCtqResultRowLimit,                     (char *) "eCtqResultRowLimit",                     (char *) "No more attribute rows may be allocated"},
    {eCtqResultInvalidCriteria,              (char *) "eCtqResultInvalidCriteria",              (char *) "Insufficient criteria were set for inquiry"},
    {eCtqResultInvalidValue,                 (char *) "eCtqResultInvalidValue",                 (char *) "An inappropriate value for an attribute"},
    {eCtqResultInvalidAction,                (char *) "eCtqResultInvalidAction",                (char *) "Object does not support invoked operation"},
    {eCtqResultMissingCriteria,              (char *) "eCtqResultMissingCriteria",              (char *) "Required selection criteria attributes were not set"},
    {eCtqResultMissingValues,                (char *) "eCtqResultMissingValues",                (char *) "Required attributes were not set"},
    {eCtqResultMissingAttribute,             (char *) "eCtqResultMissingAttribute",             (char *) "An attribute that is required to perform a requested action is missing or has not been set"},
    {eCtqResultInvalidSize,                  (char *) "eCtqResultInvalidSize",                  (char *) "A size-oriented parameter is incorrect"},
    {eCtqResultInvalidTable,                 (char *) "eCtqResultInvalidTable",                 (char *) "Invalid database table name specified"},
    {eCtqResultRejectedValue,                (char *) "eCtqResultRejectedValue",                (char *) "A legal but incongruent value was rejected from a data set"},
    {eCtqResultBatchFailure,                 (char *) "eCtqResultBatchFailure",                 (char *) "One or more errors were detected while processing a transaction batch"},
    {eCtqResultMissingCLISwitchValue,        (char *) "eCtqResultMissingCLISwitchValue",        (char *) "A CLI switch parameter value was not provided"},
    {eCtqResultInvalidCLISwitchValue,        (char *) "eCtqResultUnexpectedCLISwitchValue",     (char *) "A CLI switch parameter value was unexpected or not acceptable"},
    {eCtqResultMismatchedCLISwitchValues,    (char *) "eCtqResultMismatchedCLISwitchValues",    (char *) "Incompatible CLI switch values occured on the command line"},
    {eCtqResultFallThroughError,             (char *) "eCtqResultFallThroughError",             (char *) "The system has entered an unexpected state"},
    {eCtqResultXMLParse,                     (char *) "eCtqResultXMLParse",                     (char *) "The XML Parser failed while parsing the configuration file"},
    {eCtqResultInvalidDbCtqcfg,              (char *) "eCtqResultInvalidDbCtqcfg",              (char *) "Expected the ctqcfg.xml file version to be 2.0"},
    {eCtqResultInvalidDbConnection,          (char *) "eCtqResultInvalidDbConnection",          (char *) "A dbConnection name in ctqcfg.xml is invalid"},
    {eCtqResultInvalidPassword,              (char *) "eCtqResultInvalidPassword",              (char *) "An encrypted attribute value in ctqcfg.xml is invalid"},
    {eCtqResultInvalidSequenceBlockSize,     (char *) "eCtqResultInvalidSequenceBlockSize",     (char *) "An unsupported or invalid table was referenced"},
    {eCtqResultInvalidRetryInterval,         (char *) "eCtqResultInvalidRetryInterval",         (char *) "The database connection does not support sequence blocks"},
    {eCtqResultInvalidMaximumRetries,        (char *) "eCtqResultInvalidMaximumRetries",        (char *) "The database connection does not support sequence blocks"},
    {eCtqResultMisplacedCtqcfg,              (char *) "eCtqResultMisplacedCtqcfg",              (char *) "A ctqcfg element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedConfiguration,       (char *) "eCtqResultMisplacedConfiguration",       (char *) "A configuration element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedFileControl,         (char *) "eCtqResultMisplacedFileControl",         (char *) "A file control element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedArchivePath,         (char *) "eCtqResultMisplacedArchivePath",         (char *) "An archive path element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedLogPath,             (char *) "eCtqResultMisplacedLogPath",             (char *) "A log path element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedReportPath,          (char *) "eCtqResultMisplacedReportPath",          (char *) "A report path element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedUpdatePath,          (char *) "eCtqResultMisplacedUpdatePath",          (char *) "An update path element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedCallFilePath,        (char *) "eCtqResultMisplacedCallFilePath",        (char *) "A call file path element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedReportControl,       (char *) "eCtqResultMisplacedReportControl",       (char *) "A report control element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedPageLength,          (char *) "eCtqResultMisplacedPageLength",          (char *) "A page length element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedLogControl,          (char *) "eCtqResultMisplacedLogControl",          (char *) "A log control element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedLogNoData,           (char *) "eCtqResultMisplacedLogNoData",           (char *) "A logNoData element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedLogSourceFile,       (char *) "eCtqResultMisplacedLogSourceFile",       (char *) "A logSourceFile element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedLogLine,             (char *) "eCtqResultMisplacedLogLine",             (char *) "A logLine element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedLogName,             (char *) "eCtqResultMisplacedLogName",             (char *) "A logName element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedLogType,             (char *) "eCtqResultMisplacedLogType",             (char *) "A logType element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedLogSize,             (char *) "eCtqResultMisplacedLogSize",             (char *) "A logSize element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedLogAddress,          (char *) "eCtqResultMisplacedLogAddress",          (char *) "A logAddress element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedLogValue,            (char *) "eCtqResultMisplacedLogValue",            (char *) "A logValue element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedLogArray,            (char *) "eCtqResultMisplacedLogArray",            (char *) "A logArray element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedLogAllData,          (char *) "eCtqResultMisplacedLogAllData",          (char *) "A logAllData element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedLogNoEvents,         (char *) "eCtqResultMisplacedLogNoEvents",         (char *) "A logNoEvents element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedLogMinorDebug,       (char *) "eCtqResultMisplacedLogMinorDebug",       (char *) "A logMinorDebug element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedLogMajorDebug,       (char *) "eCtqResultMisplacedLogMajorDebug",       (char *) "A logMajorDebug element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedLogMinorSuccess,     (char *) "eCtqResultMisplacedLogMinorSuccess",     (char *) "A logMinorSuccess element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedLogMinorWarning,     (char *) "eCtqResultMisplacedLogMinorWarning",     (char *) "A logMinorWarning element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedLogMinorFailure,     (char *) "eCtqResultMisplacedLogMinorFailure",     (char *) "A logMinorFailure element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedLogMajorSuccess,     (char *) "eCtqResultMisplacedLogMajorSuccess",     (char *) "A logMajorSuccess element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedLogMajorWarning,     (char *) "eCtqResultMisplacedLogMajorWarning",     (char *) "A logMajorWarning element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedLogMajorFailure,     (char *) "eCtqResultMisplacedLogMajorFailure",     (char *) "A logMajorFailure element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedLogAllEvents,        (char *) "eCtqResultMisplacedLogAllEvents",        (char *) "A logAllEvents element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedRegisterControl,     (char *) "eCtqResultMisplacedRegisterControl",     (char *) "A register control element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedWriteToAcc,          (char *) "eCtqResultMisplacedWriteToAcc",          (char *) "A logWriteToAcc element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedWriteToJrn,          (char *) "eCtqResultMisplacedWriteToJrn",          (char *) "A logWriteToJrn element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedReturnZRT,           (char *) "eCtqResultMisplacedReturnZRT",           (char *) "A returnZeroRateTaxes element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedCacheControl,        (char *) "eCtqResultMisplacedCacheControl",        (char *) "A cacheControl element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedCache,               (char *) "eCtqResultMisplacedCache",               (char *) "A cache element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedDbConnection,        (char *) "eCtqResultMisplacedDbConnection",        (char *) "A dbConnection element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedDsn,                 (char *) "eCtqResultMisplacedDsn",                 (char *) "A dsn element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedSchema,              (char *) "eCtqResultMisplacedSchema",              (char *) "A schema element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedCatalog,             (char *) "eCtqResultMisplacedCatalog",             (char *) "A catalog element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedUsername,            (char *) "eCtqResultMisplacedUsername",            (char *) "A username element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedPassword,            (char *) "eCtqResultMisplacedPassword",            (char *) "A password element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedSequenceBlockSize,   (char *) "eCtqResultMisplacedSequenceBlockSize",   (char *) "A sequence block size element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedRetryInterval,       (char *) "eCtqResultMisplacedRetryInterval",       (char *) "A retry interval element was found out of place in ctqcfg.xml"},
    {eCtqResultMisplacedMaximumRetries,      (char *) "eCtqResultMisplacedMaximumRetries",      (char *) "A maximum retries element was found out of place in ctqcfg.xml"},
    {eCtqResultMissingParameterValue,        (char *) "eCtqResultMissingParameterValue",        (char *) "A required command line parameter value has not been specified"},
    {eCtqResultMaxTaxesExceeded,             (char *) "eCtqResultMaxTaxesExceeded",             (char *) "Exceeded the maximum number of taxes the array structure can hold"},
    {eCtqResultInvalidOrigOrTermGeo,         (char *) "eCtqResultInvalidOrigOrTermGeo",         (char *) "An invalid value for Origin or Termination GeoCode"},
    {eCtqResultInvalidCategoryOrServiceCode, (char *) "eCtqResultInvalidCategoryOrServiceCode", (char *) "An invalid value for Category or Service Code"},
	{eCtqResultInvalidParameterValue,        (char *) "eCtqResultInvalidParameterValue",        (char *) "An invalid value for a Command line parameter"},
	{eCtqResultInvalidMonthlyUpdateFile,     (char *) "eCtqResultInvalidMonthlyUpdateFile",     (char *) "Attempted to import an invalid monthly update file"}

};

#endif /* (defined(INCLUDE_RESULT_CODE_DESCRIPTIONS) && !defined(RESULT_CODE_DESCRIPTIONS_INCLUDED)) */
