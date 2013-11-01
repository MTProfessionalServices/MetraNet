// VertexCtrl.cpp : Implementation of CVertexCtrl

#include "stdafx.h"
#include "VertexCtrl.h"
#include "stda.h"
#include "ctqa.h"

const CComBSTR BEGIN_SUCCESS_XML = _T("<Success>");
const CComBSTR END_SUCCESS_XML = _T("</Success>");
const CComBSTR BEGIN_ERROR_XML = _T("<Error>");
const CComBSTR END_ERROR_XML = _T("</Error>");

#ifdef DEBUG_PRINT
#define BEGIN_PROC(x) \
  printf("==>%s %d\n",(x),__LINE__)

#define END_PROC(x) \
  printf("<==%s %d\n",(x),__LINE__)

#define TRACER(x) \
  printf("\t%d %s\n",__LINE__,(x))
#else
#define BEGIN_PROC(x)
#define END_PROC(x)
#define TRACER(x)
#endif

#define ADD_TIMING(x) \
  if( m_bReturnTimings) \
{ \
  LARGE_INTEGER leTest; \
  QueryPerformanceCounter(&leTest); \
  CTimingObj* cto = new CTimingObj(leTest,CString((x))); \
  m_vTiming.push_back(cto); \
}

#define DELETE_TIMINGS \
  int size = m_vTiming.size(); \
  for( int i = 0; i < size; i++ ) \
{ \
  delete m_vTiming[i]; \
} \
  m_vTiming.clear();

/////////////////////////////////////////////////////////////////////////////
// CICVWException

class CICVWException : public CUserException
{
public:
  CString m_strErr;
  CICVWException(CString strErr){m_strErr = strErr;}
};

/////////////////////////////////////////////////////////////////////////////
// CSimpleFilter

class  CSimpleFilter : public DOMNodeFilter {
public:

  CSimpleFilter(short nodeType, bool reject=false) : DOMNodeFilter(), fNodeType(nodeType), fReject(reject) {};
  virtual FilterAction acceptNode(const DOMNode* node) const;
private:
  short fNodeType;
  bool fReject;
};

/*
Node Types can be of the following:
ELEMENT_NODE         = 1,
ATTRIBUTE_NODE       = 2,
TEXT_NODE            = 3,
CDATA_SECTION_NODE   = 4,
ENTITY_REFERENCE_NODE = 5,
ENTITY_NODE          = 6,
PROCESSING_INSTRUCTION_NODE = 7,
COMMENT_NODE         = 8,
DOCUMENT_NODE        = 9,
DOCUMENT_TYPE_NODE   = 10,
DOCUMENT_FRAGMENT_NODE = 11,
NOTATION_NODE        = 12
*/

DOMNodeFilter::FilterAction  CSimpleFilter::acceptNode(const DOMNode* node) const {
  if (fNodeType == 0)
    return  DOMNodeFilter::FILTER_ACCEPT;
  if (node->getNodeType() ==  fNodeType) {
    return  DOMNodeFilter::FILTER_ACCEPT;
  } else {
    return  fReject ? DOMNodeFilter::FILTER_REJECT : DOMNodeFilter::FILTER_SKIP;
  }
}

/////////////////////////////////////////////////////////////////////////////
// CVertexAttribObj

IMPLEMENT_SERIAL(CVertexAttribObj, CObject, 0)

void CVertexAttribObj::Serialize(CArchive& ar)
{
  DWORD dw;
  if (ar.IsStoring())
  {
    dw = (DWORD)m_Attrib;
    ar << dw;
  }
  else
  {
    ar >> dw;
    m_Attrib = (tCtqAttrib)dw;
  }
}

/////////////////////////////////////////////////////////////////////////////
// CVertexCtrl
int CVertexCtrl::m_iVertexSysInitialized = 0;

void CVertexCtrl::CleanUpMaps()
{
  BEGIN_PROC("CleanUpMaps");
  CVertexAttribObj* obj;
  obj = m_mapVertexAttrib[CString("ConfigHome")];
  delete obj;
  obj = m_mapVertexAttrib[CString("ConfigName")];
  delete obj;
  obj = m_mapVertexAttrib[CString("LogFilePath")];
  delete obj;
  obj = m_mapVertexAttrib[CString("LogData")];
  delete obj;
  obj = m_mapVertexAttrib[CString("LogEvents")];
  delete obj;

  // Calculate Taxes
  obj = m_mapVertexAttrib[CString("BilledLines")];
  delete obj;
  obj = m_mapVertexAttrib[CString("CallMinutes")];
  delete obj;
  obj = m_mapVertexAttrib[CString("CategoryCode")];
  delete obj;
  obj = m_mapVertexAttrib[CString("ChargeToGeoCode")];
  delete obj;
  obj = m_mapVertexAttrib[CString("ChargeToNpaNxx")];
  delete obj;
  obj = m_mapVertexAttrib[CString("ChargeToPostalCode")];
  delete obj;
  obj = m_mapVertexAttrib[CString("InvoiceDate")];
  delete obj;
  obj = m_mapVertexAttrib[CString("InvoiceNumber")];
  delete obj;
  obj = m_mapVertexAttrib[CString("OriginGeoCode")];
  delete obj;
  obj = m_mapVertexAttrib[CString("OriginNpaNxx")];
  delete obj;
  obj = m_mapVertexAttrib[CString("OriginPostalCode")];
  delete obj;
  obj = m_mapVertexAttrib[CString("ServiceCode")];
  delete obj;
  obj = m_mapVertexAttrib[CString("TaxableAmount")];
  delete obj;
  obj = m_mapVertexAttrib[CString("TerminationGeoCode")];
  delete obj;
  obj = m_mapVertexAttrib[CString("TerminationNpaNxx")];
  delete obj;
  obj = m_mapVertexAttrib[CString("TerminationPostalCode")];
  delete obj;
  obj = m_mapVertexAttrib[CString("UserArea")];
  delete obj;

  // Additional Calculate Taxes
  obj = m_mapVertexAttrib[CString("ChargeToIncorporatedCode")];
  delete obj;
  obj = m_mapVertexAttrib[CString("ChargeToLocationMode")];
  delete obj;
  obj = m_mapVertexAttrib[CString("CityExemptFlag")];
  delete obj;
  obj = m_mapVertexAttrib[CString("CountyExemptFlag")];
  delete obj;
  obj = m_mapVertexAttrib[CString("CreditCode")];
  delete obj;
  obj = m_mapVertexAttrib[CString("CustomerCode")];
  delete obj;
  obj = m_mapVertexAttrib[CString("CustomerReference")];
  delete obj;
  obj = m_mapVertexAttrib[CString("DescriptionFlag")];
  delete obj;
  obj = m_mapVertexAttrib[CString("FederalExemptFlag")];
  delete obj;
  obj = m_mapVertexAttrib[CString("OriginIncorporatedCode")];
  delete obj;
  obj = m_mapVertexAttrib[CString("OriginLocationMode")];
  delete obj;
  obj = m_mapVertexAttrib[CString("SaleResaleCode")];
  delete obj;
  obj = m_mapVertexAttrib[CString("StateExemptFlag")];
  delete obj;
  obj = m_mapVertexAttrib[CString("TaxedGeoCodeOverrideCode")];
  delete obj;
  obj = m_mapVertexAttrib[CString("TerminationIncorporatedCode")];
  delete obj;
  obj = m_mapVertexAttrib[CString("TerminationLocationMode")];
  delete obj;
  obj = m_mapVertexAttrib[CString("TransactionCode")];
  delete obj;
  obj = m_mapVertexAttrib[CString("TrunkLines")];
  delete obj;
  obj = m_mapVertexAttrib[CString("UtilityCode")];
  delete obj;
  obj = m_mapVertexAttrib[CString("WriteJournal")];
  delete obj;

  // Output Only
  obj = m_mapVertexAttrib[CString("BundleCategoryCode")];
  delete obj;
  obj = m_mapVertexAttrib[CString("BundleFlag")];
  delete obj;
  obj = m_mapVertexAttrib[CString("BundleServiceCode")];
  delete obj;
  obj = m_mapVertexAttrib[CString("CustomerOverride")];
  delete obj;
  obj = m_mapVertexAttrib[CString("LinesTaxed")];
  delete obj;
  obj = m_mapVertexAttrib[CString("LinkTaxAmount")];
  delete obj;
  obj = m_mapVertexAttrib[CString("TaxAmount")];
  delete obj;
  obj = m_mapVertexAttrib[CString("TaxAuthority")];
  delete obj;
  obj = m_mapVertexAttrib[CString("TaxCode")];
  delete obj;
  obj = m_mapVertexAttrib[CString("TaxedCityName")];
  delete obj;
  obj = m_mapVertexAttrib[CString("TaxedCountyName")];
  delete obj;
  obj = m_mapVertexAttrib[CString("TaxedGeoCode")];
  delete obj;
  obj = m_mapVertexAttrib[CString("TaxedGeoCodeIncorporatedCode")];
  delete obj;
  obj = m_mapVertexAttrib[CString("TaxRate")];
  delete obj;
  obj = m_mapVertexAttrib[CString("TaxedStateCode")];
  delete obj;
  obj = m_mapVertexAttrib[CString("TaxType")];
  delete obj;
  obj = m_mapVertexAttrib[CString("TrunksTaxed")];
  delete obj;

  // Location Lookup
  obj = m_mapVertexAttrib[CString("CriteriaNpaNxx")];
  delete obj;
  obj = m_mapVertexAttrib[CString("CriteriaPostal")];
  delete obj;
  obj = m_mapVertexAttrib[CString("AttribGeoCode")];
  delete obj;

  m_mapVertexAttrib.RemoveAll();
  END_PROC("CleanUpMaps");
}

void CVertexCtrl::SetupMaps()
{
  BEGIN_PROC("SetupMaps");
  // The Attribute map

  // General Set Up
  m_mapVertexAttrib[CString("ConfigHome")]					= new CVertexAttribObj(eCtqAttribCtqCfgHome,eCtqString,CTQ_PATH_SIZE);
  m_mapVertexAttrib[CString("ConfigName")]					= new CVertexAttribObj(eCtqCriteriaConfigurationName,eCtqString,CTQ_CONFIGURATION_NAME_SIZE);
  m_mapVertexAttrib[CString("LogFilePath")]					= new CVertexAttribObj(eCtqAttribLogFilePath,eCtqString,CTQ_PATH_SIZE);
  m_mapVertexAttrib[CString("LogData")]						= new CVertexAttribObj(eCtqAttribLogData,eCtqEnum,sizeof(tCtqLogData));
  m_mapVertexAttrib[CString("LogEvents")]						= new CVertexAttribObj(eCtqAttribLogEvents,eCtqEnum,sizeof(tCtqLogEvents));

  // Calculate Taxes
  m_mapVertexAttrib[CString("BilledLines")]					= new CVertexAttribObj(eCtqAttribBilledLines,eCtqInt,sizeof(int));
  m_mapVertexAttrib[CString("CallMinutes")]					= new CVertexAttribObj(eCtqAttribCallMinutes,eCtqDouble,sizeof(double));
  m_mapVertexAttrib[CString("CategoryCode")]					= new CVertexAttribObj(eCtqAttribCategoryCode,eCtqString,CTQ_CATEGORY_CODE_SIZE);
  m_mapVertexAttrib[CString("ChargeToGeoCode")]				= new CVertexAttribObj(eCtqAttribChargeToGeoCode,eCtqString,CTQ_GEOCODE_SIZE);
  m_mapVertexAttrib[CString("ChargeToNpaNxx")]				= new CVertexAttribObj(eCtqAttribChargeToNpaNxx,eCtqString,CTQ_NPA_NXX_SIZE);
  m_mapVertexAttrib[CString("ChargeToPostalCode")]			= new CVertexAttribObj(eCtqAttribChargeToPostalCode,eCtqString,CTQ_ZIPPLUS4_SIZE);
  m_mapVertexAttrib[CString("InvoiceDate")]					= new CVertexAttribObj(eCtqAttribInvoiceDate,eCtqString,CTQ_DATE_SIZE);
  m_mapVertexAttrib[CString("InvoiceNumber")]					= new CVertexAttribObj(eCtqAttribInvoiceNumber,eCtqString,CTQ_INVOICE_NUMBER_SIZE);
  m_mapVertexAttrib[CString("OriginGeoCode")]					= new CVertexAttribObj(eCtqAttribOriginGeoCode,eCtqString,CTQ_GEOCODE_SIZE);
  m_mapVertexAttrib[CString("OriginNpaNxx")]					= new CVertexAttribObj(eCtqAttribOriginNpaNxx,eCtqString,CTQ_NPA_NXX_SIZE);
  m_mapVertexAttrib[CString("OriginPostalCode")]				= new CVertexAttribObj(eCtqAttribOriginPostalCode,eCtqString,CTQ_ZIPPLUS4_SIZE);
  m_mapVertexAttrib[CString("ServiceCode")]					= new CVertexAttribObj(eCtqAttribServiceCode,eCtqString,CTQ_SERVICE_CODE_SIZE);
  m_mapVertexAttrib[CString("TaxableAmount")]					= new CVertexAttribObj(eCtqAttribTaxableAmount,eCtqDouble,sizeof(double));
  m_mapVertexAttrib[CString("TerminationGeoCode")]			= new CVertexAttribObj(eCtqAttribTerminationGeoCode,eCtqString,CTQ_GEOCODE_SIZE);
  m_mapVertexAttrib[CString("TerminationNpaNxx")]				= new CVertexAttribObj(eCtqAttribTerminationNpaNxx,eCtqString,CTQ_NPA_NXX_SIZE);
  m_mapVertexAttrib[CString("TerminationPostalCode")]			= new CVertexAttribObj(eCtqAttribTerminationPostalCode,eCtqString,CTQ_ZIPPLUS4_SIZE);
  m_mapVertexAttrib[CString("UserArea")]						= new CVertexAttribObj(eCtqAttribUserArea,eCtqString,CTQ_USER_AREA_SIZE);

  // Additional Calculate Taxes
  m_mapVertexAttrib[CString("ChargeToIncorporatedCode")]		= new CVertexAttribObj(eCtqAttribChargeToIncorporatedCode,eCtqString,CTQ_FLAG_SIZE);
  m_mapVertexAttrib[CString("ChargeToLocationMode")]			= new CVertexAttribObj(eCtqAttribChargeToLocationMode,eCtqString,CTQ_FLAG_SIZE);
  m_mapVertexAttrib[CString("CityExemptFlag")]				= new CVertexAttribObj(eCtqAttribCityExemptFlag,eCtqString,CTQ_FLAG_SIZE);
  m_mapVertexAttrib[CString("CountyExemptFlag")]				= new CVertexAttribObj(eCtqAttribCountyExemptFlag,eCtqString,CTQ_FLAG_SIZE);
  m_mapVertexAttrib[CString("CreditCode")]					= new CVertexAttribObj(eCtqAttribCreditCode,eCtqString,CTQ_FLAG_SIZE);
  m_mapVertexAttrib[CString("CustomerCode")]					= new CVertexAttribObj(eCtqAttribCustomerCode,eCtqString,CTQ_FLAG_SIZE);
  m_mapVertexAttrib[CString("CustomerReference")]				= new CVertexAttribObj(eCtqAttribCustomerReference,eCtqString,CTQ_CUSTOMER_REFERENCE_SIZE);
  m_mapVertexAttrib[CString("DescriptionFlag")]				= new CVertexAttribObj(eCtqAttribDescriptionFlag,eCtqString,CTQ_FLAG_SIZE);
  m_mapVertexAttrib[CString("FederalExemptFlag")]				= new CVertexAttribObj(eCtqAttribFederalExemptFlag,eCtqString,CTQ_FLAG_SIZE);
  m_mapVertexAttrib[CString("OriginIncorporatedCode")]		= new CVertexAttribObj(eCtqAttribOriginIncorporatedCode,eCtqString,CTQ_FLAG_SIZE);
  m_mapVertexAttrib[CString("OriginLocationMode")]			= new CVertexAttribObj(eCtqAttribOriginLocationMode,eCtqString,CTQ_FLAG_SIZE);
  m_mapVertexAttrib[CString("SaleResaleCode")]				= new CVertexAttribObj(eCtqAttribSaleResaleCode,eCtqString,CTQ_SALE_RESALE_CODE_SIZE);
  m_mapVertexAttrib[CString("StateExemptFlag")]				= new CVertexAttribObj(eCtqAttribStateExemptFlag,eCtqString,CTQ_FLAG_SIZE);
  m_mapVertexAttrib[CString("TaxedGeoCodeOverrideCode")]		= new CVertexAttribObj(eCtqAttribTaxedGeoCodeOverrideCode,eCtqString,CTQ_FLAG_SIZE);
  m_mapVertexAttrib[CString("TerminationIncorporatedCode")]	= new CVertexAttribObj(eCtqAttribTerminationIncorporatedCode,eCtqString,CTQ_FLAG_SIZE);
  m_mapVertexAttrib[CString("TerminationLocationMode")]		= new CVertexAttribObj(eCtqAttribTerminationLocationMode,eCtqString,CTQ_FLAG_SIZE);
  m_mapVertexAttrib[CString("TransactionCode")]				= new CVertexAttribObj(eCtqAttribTransactionCode,eCtqString,CTQ_TRANSACTION_CODE_SIZE);
  m_mapVertexAttrib[CString("TrunkLines")]					= new CVertexAttribObj(eCtqAttribTrunkLines,eCtqInt,sizeof(int));
  m_mapVertexAttrib[CString("UtilityCode")]					= new CVertexAttribObj(eCtqAttribUtilityCode,eCtqString,CTQ_UTILITY_CODE_SIZE);
  m_mapVertexAttrib[CString("WriteJournal")]					= new CVertexAttribObj(eCtqAttribWriteJournal,eCtqBool,CTQ_FLAG_SIZE);

  // Output Only
  m_mapVertexAttrib[CString("BundleCategoryCode")]			= new CVertexAttribObj(eCtqAttribBundleCategoryCode,eCtqString,CTQ_CATEGORY_CODE_SIZE);
  m_mapVertexAttrib[CString("BundleFlag")]					= new CVertexAttribObj(eCtqAttribBundleFlag,eCtqString,CTQ_FLAG_SIZE);
  m_mapVertexAttrib[CString("BundleServiceCode")]				= new CVertexAttribObj(eCtqAttribBundleServiceCode,eCtqString,CTQ_SERVICE_CODE_SIZE);
  m_mapVertexAttrib[CString("CustomerOverride")]				= new CVertexAttribObj(eCtqAttribCustomerOverride,eCtqString,20);
  m_mapVertexAttrib[CString("LinesTaxed")]					= new CVertexAttribObj(eCtqAttribLinesTaxed,eCtqInt,sizeof(int));
  m_mapVertexAttrib[CString("LinkTaxAmount")]					= new CVertexAttribObj(eCtqAttribLinkTaxAmount,eCtqDouble,sizeof(double));
  m_mapVertexAttrib[CString("TaxAmount")]						= new CVertexAttribObj(eCtqAttribTaxAmount,eCtqDouble,sizeof(double));
  m_mapVertexAttrib[CString("TaxAuthority")]					= new CVertexAttribObj(eCtqAttribTaxAuthority,eCtqString,CTQ_TAX_AUTHORITY_SIZE);
  m_mapVertexAttrib[CString("TaxCode")]						= new CVertexAttribObj(eCtqAttribTaxCode,eCtqString,CTQ_TAX_CODE_SIZE);
  m_mapVertexAttrib[CString("TaxedCityName")]					= new CVertexAttribObj(eCtqAttribTaxedCityName,eCtqString,CTQ_CITY_NAME_SIZE);
  m_mapVertexAttrib[CString("TaxedCountyName")]				= new CVertexAttribObj(eCtqAttribTaxedCountyName,eCtqString,CTQ_COUNTY_NAME_SIZE);
  m_mapVertexAttrib[CString("TaxedGeoCode")]					= new CVertexAttribObj(eCtqAttribTaxedGeoCode,eCtqString,CTQ_GEOCODE_SIZE);
  m_mapVertexAttrib[CString("TaxedGeoCodeIncorporatedCode")]	= new CVertexAttribObj(eCtqAttribTaxedGeoCodeIncorporatedCode,eCtqString,CTQ_FLAG_SIZE);
  m_mapVertexAttrib[CString("TaxRate")]						= new CVertexAttribObj(eCtqAttribRate,eCtqDouble,sizeof(double));
  m_mapVertexAttrib[CString("TaxedStateCode")]				= new CVertexAttribObj(eCtqAttribTaxedStateCode,eCtqString,CTQ_STATE_ABBREVIATION_SIZE);
  m_mapVertexAttrib[CString("TaxType")]						= new CVertexAttribObj(eCtqAttribTaxType,eCtqString,CTQ_TAX_TYPE_SIZE);
  m_mapVertexAttrib[CString("TrunksTaxed")]					= new CVertexAttribObj(eCtqAttribTrunksTaxed,eCtqInt,sizeof(int));

  // Location Lookup
  m_mapVertexAttrib[CString("CriteriaNpaNxx")]				= new CVertexAttribObj(eCtqCriteriaNpaNxx,eCtqString,CTQ_NPA_NXX_SIZE);
  m_mapVertexAttrib[CString("CriteriaPostal")]				= new CVertexAttribObj(eCtqCriteriaPostal,eCtqString,CTQ_POSTAL_CODE_SIZE);
  m_mapVertexAttrib[CString("AttribGeoCode")]					= new CVertexAttribObj(eCtqAttribGeoCode,eCtqString,CTQ_GEOCODE_SIZE);
  END_PROC("SetupMaps");
}

tCtqResultCode CVertexCtrl::SetVertexAttrib(tCtqHandle handle, CString& strAttrib, void *pData)
{
  BEGIN_PROC("SetVertexAttrib");
  // The Vertex lib assumes char* for strings.
  //   We are using BSTR because of COM so we need
  //   to do some conversions;
  USES_CONVERSION;
  char *strA = NULL;

  // Get the Attrib descriptor
  CVertexAttribObj *pObj = m_mapVertexAttrib[strAttrib];

  if( NULL == pObj )
  {
    CString strErr;
    strErr = _T("Attribute (");
    strErr += strAttrib;
    strErr += _T(") is not supported.");
    throw new CICVWException(strErr);
  }

  // If we are dealing with a string we will need
  //   to convert
  if( pObj->m_Type == eCtqString )
  {
    LPWSTR strW = (LPWSTR)pData;
    strA = W2A(strW);
    pData = strA;
  }

  // Call the Vertex API
  TRACER("Call CtqSetAttrib");
 
  tCtqResultCode ret = CtqSetAttrib(	handle,
    pObj->m_Attrib,
    pData,
    pObj->m_Type);  
  TRACER("Ret CtqSetAttrib");

  // Return the Vertex result code.
  END_PROC("SetVertexAttrib");
  return ret;
}

CString CVertexCtrl::GetVertexAttrib(tCtqHandle handle, CString& strAttrib )
{
  BEGIN_PROC("GetVertexAttrib");
  CString strRet = _T("");

  // The Vertex lib assumes char* for strings.
  //   We are using BSTR because of COM so we need
  //   to do some conversions;
  USES_CONVERSION;

  // Get the Attrib descriptor
  CVertexAttribObj *pObj = m_mapVertexAttrib[strAttrib];

  if( NULL == pObj )
  {
    CString strErr;
    strErr = _T("Attribute (");
    strErr += strAttrib;
    strErr += _T(") is not supported.");
    END_PROC("GetVertexAttrib");
    throw new CICVWException(strErr);
  }

  // Check our results
  tCtqResultCode lRC = eCtqResultSuccess;

  // Process depending on type
  switch( pObj->m_Type )
  {
  case eCtqString:
    {
      char *pBuff = (char*)alloca(pObj->m_Size * sizeof(char));
      TRACER("Call CtqGetAttrib");
      lRC = CtqGetAttrib(
        handle,
        pObj->m_Attrib,
        pBuff,
        pObj->m_Type,
        pObj->m_Size);
      strRet = pBuff;
      TRACER("Ret CtqGetAttrib");
    }
    break;

  case eCtqInt:
  case eCtqEnum:
    {
      int iAttrib = 0;
      TRACER("Call CtqGetAttrib");
      lRC = CtqGetAttrib(
        handle,
        pObj->m_Attrib,
        &iAttrib,
        pObj->m_Type,
        pObj->m_Size);
      TRACER("Ret CtqGetAttrib");
      strRet.Format(_T("%d"),iAttrib);
    }
    break;

  case eCtqDouble:
    {
      double dAttrib = 0.0;
      TRACER("Call CtqGetAttrib");
      lRC = CtqGetAttrib(
        handle,
        pObj->m_Attrib,
        &dAttrib,
        pObj->m_Type,
        pObj->m_Size);
      TRACER("Ret CtqGetAttrib");
      strRet.Format(_T("%f"),dAttrib);
    }
    break;

  default:
    {
      CString strErr;
      strErr = _T("Unknown attribute type for (");
      strErr += strAttrib;
      strErr += _T(")");
      lRC = eCtqResultFailure;
      END_PROC("GetVertexAttrib");
      throw new CICVWException(strErr);
    }
  }

  if( eCtqResultSuccess != lRC )
  {
    CString strErr;
    strErr = _T("Error retrieving attribute ");
    strErr += strAttrib;
    strErr += _T(": ");
    strErr += VertexErrorString(lRC);
    END_PROC("GetVertexAttrib");
    throw new CICVWException(strErr);
  }

  END_PROC("GetVertexAttrib");
  return strRet;
}

CString CVertexCtrl::VertexErrorString(tCtqResultCode pResultCode)
{
  BEGIN_PROC("VertexErrorString");
  CString strRet;
  char lResultId[CTQ_MESSAGE_SIZE];
  char lDescription[CTQ_MESSAGE_SIZE];

  /* Obtain a description of the error returned by CTQ. */
  TRACER("Call CtqInquireResultCode");
  CtqInquireResultCode(pResultCode,
    lResultId,
    sizeof(lResultId),
    lDescription,
    sizeof(lDescription));
  TRACER("Ret CtqInquireResultCode");

  // NOTE: Vertex assumes char*, but we are using UNICODE
  //       so we use the convert values in the format string.
  strRet.Format(_T("%S(%d) - %S"), lResultId, pResultCode, lDescription);

  END_PROC("VertexErrorString");
  return strRet;
}

void CVertexCtrl::VertexSysInit(void)
{
  BEGIN_PROC("VertexSysInit");
  if( 0 != m_iVertexSysInitialized )
  {
    END_PROC("VertexSysInit");
    return;
  }

  // Vertex return code
  tCtqResultCode lRC = eCtqResultSuccess;

  // Initialize the system.
  TRACER("Call CtqSetUpCtq");
  lRC = CtqSetUpCtq();
  TRACER("Ret CtqSetUpCtq");
  if (eCtqResultSuccess != lRC)
  {
    CString strErr = _T("Unable to initialize the CTQ system: ");
    strErr += VertexErrorString(lRC);
    END_PROC("VertexSysInit");
    throw new CICVWException(strErr);
  }
  m_iVertexSysInitialized++;
  END_PROC("VertexSysInit");
}

void CVertexCtrl::VertexSysTerm(void)
{
  BEGIN_PROC("VertexSysTerm");
  // Deinitialize the system.
  if( 0 == m_iVertexSysInitialized--)
  {
    TRACER("Call CtqCleanUpCtq");
    CtqCleanUpCtq();
    TRACER("Ret CtqCleanUpCtq");
  }
  END_PROC("VertexSysTerm");
}

void CVertexCtrl::VertexInit(void)
{
  BEGIN_PROC("VertexInit");
  // Vertex assumes char* and we are using UNICODE,
  //   so we need to do conversions
  USES_CONVERSION;

  // Vertex return code
  tCtqResultCode lRC = eCtqResultSuccess;

  // Allocate a root object.
  TRACER("Call CtqAllocCtq");
  lRC = CtqAllocCtq(&m_lCtqRootHandle);
  TRACER("Ret CtqAllocCtq");
  if (eCtqResultSuccess != lRC)
  {
    CString strErr = _T("Unable to allocate the CTQ root object: ");
    strErr += VertexErrorString(lRC);
    END_PROC("VertexInit");
    throw new CICVWException(strErr);
  }

  // Make sure the Config Dir propery is set before going on.
  if( m_bstrVertexConfigPath.Length() <= 0 )
  {
    CString strErr = _T("Configuation directory property not set.");
    END_PROC("VertexInit");
    throw new CICVWException(strErr);
  }

  // Set the CTQ configuration directory location.
  lRC = SetVertexAttrib(m_lCtqRootHandle,CString("ConfigHome"),m_bstrVertexConfigPath);
  if (eCtqResultSuccess != lRC)
  {
    CString strErr = _T("Unable to set configuation directory(");
    strErr += m_bstrVertexConfigPath;
    strErr += _T(": ");
    strErr += VertexErrorString(lRC);
    END_PROC("VertexInit");
    throw new CICVWException(strErr);
  }

  // Handle for the configuration object
  tCtqHandle lCfgHandle = NULL;

  // Get the configuration handle.
  TRACER("Call CtqGetAttrib");
  lRC = CtqGetAttrib(m_lCtqRootHandle,
    eCtqHandleCfg,
    &lCfgHandle,
    eCtqHandle,
    sizeof(lCfgHandle));
  TRACER("Ret CtqGetAttrib");
  if (eCtqResultSuccess != lRC)
  {
    CString strErr = _T("Unable to retrieve configuration object handle (init): ");
    strErr += VertexErrorString(lRC);
    END_PROC("VertexInit");
    throw new CICVWException(strErr);
  }

  // Make sure the Config Name propery is set before going on.
  if( m_bstrVertexConfigName.Length() <= 0 )
  {
    CString strErr = _T("Configuation name property not set.");
    END_PROC("VertexInit");
    throw new CICVWException(strErr);
  }

  // Set the configuration to load.
  lRC = SetVertexAttrib(lCfgHandle,CString("ConfigName"),m_bstrVertexConfigName);
  if (eCtqResultSuccess != lRC)
  {
    CString strErr = _T("Unable to set configuration name(");
    strErr += m_bstrVertexConfigName;
    strErr += _T("): ");
    strErr += VertexErrorString(lRC);
    END_PROC("VertexInit");
    throw new CICVWException(strErr);
  }

  // Retrieve target configuration from the configuration file.
  TRACER("Call CtqInquireConfig");
  lRC = CtqInquireConfig(m_lCtqRootHandle);
  TRACER("Ret CtqInquireConfig");
  if (eCtqResultSuccess != lRC)
  {
    CString strErr = _T("Unable to retrieve target configuration(");
    strErr += m_bstrVertexConfigName;
    strErr += _T(") from the configuration file (");
    strErr += m_bstrVertexConfigPath;
    strErr += _T("): ");
    strErr += VertexErrorString(lRC);
    END_PROC("VertexInit");
    throw new CICVWException(strErr);
  }

  // Logging settings
  //
  // NOTE: Vertex APIs assume char*
  char* lLogFilePath[CTQ_PATH_SIZE];
  tCtqLogData lLogData = eCtqLogNoData;
  tCtqLogEvents lLogEvents = eCtqLogNoEvents;

  // Get the logging settings from the configurate we retrieved
  TRACER("Call CtqGetAttrib");
  lRC = CtqGetAttrib(lCfgHandle,
    eCtqAttribLogFilePath,
    lLogFilePath,
    eCtqString,
    sizeof(lLogFilePath));
  TRACER("Ret CtqGetAttrib");
  if (eCtqResultSuccess != lRC)
  {
    CString strErr = _T("Unable to retrieve log file path from the configuration object: ");
    strErr += VertexErrorString(lRC);
    END_PROC("VertexInit");
    throw new CICVWException(strErr);
  }

  TRACER("Call CtqGetAttrib"); 
  lRC = CtqGetAttrib(lCfgHandle,
    eCtqAttribLogData,
    &lLogData,
    eCtqEnum,
    sizeof(lLogData));
  TRACER("Ret CtqGetAttrib");
  if (eCtqResultSuccess != lRC)
  {
    CString strErr = _T("Unable to retrieve log data attribue from the configuration object: ");
    strErr += VertexErrorString(lRC);
    END_PROC("VertexInit");
    throw new CICVWException(strErr);
  }

  TRACER("Call CtqGetAttrib");
  lRC = CtqGetAttrib(lCfgHandle,
    eCtqAttribLogEvents,
    &lLogEvents,
    eCtqEnum,
    sizeof(lLogEvents));
  TRACER("Ret CtqGetAttrib");
  if (eCtqResultSuccess != lRC)
  {
    CString strErr = _T("Unable to retrieve log event attribue from the configuration object: ");
    strErr += VertexErrorString(lRC);
    END_PROC("VertexInit");
    throw new CICVWException(strErr);
  }

  // Set the logging settings in our instance
  lRC = SetVertexAttrib(m_lCtqRootHandle,CString("LogFilePath"),A2W((LPCSTR)lLogFilePath));
  if (eCtqResultSuccess != lRC)
  {
    CString strErr = _T("Unable to set log file path in our instance: ");
    strErr += VertexErrorString(lRC);
    END_PROC("VertexInit");
    throw new CICVWException(strErr);
  }

  lRC = SetVertexAttrib(m_lCtqRootHandle,CString("LogData"),&lLogData);
  if (eCtqResultSuccess != lRC)
  {
    CString strErr = _T("Unable to set log data attribute in our instance: ");
    strErr += VertexErrorString(lRC);
    END_PROC("VertexInit");
    throw new CICVWException(strErr);
  }

  lRC = SetVertexAttrib(m_lCtqRootHandle,CString("LogEvents"),&lLogEvents);
  if (eCtqResultSuccess != lRC)
  {
    CString strErr = _T("Unable to set log event attribute in our instance: ");
    strErr += VertexErrorString(lRC);
    END_PROC("VertexInit");
    throw new CICVWException(strErr);
  }

  m_bVertexInitialized = true;
  END_PROC("VertexInit");
}

void CVertexCtrl::VertexTerm(void)
{
  BEGIN_PROC("VertexTerm");
  if(NULL != m_lCtqRootHandle)
  {
    TRACER("Call CtqFreeCtq");
    CtqFreeCtq(&m_lCtqRootHandle);
    TRACER("Ret CtqFreeCtq");
    m_lCtqRootHandle = NULL;
  }
  m_bVertexInitialized = false;
  END_PROC("VertexTerm");
}

void CVertexCtrl::VertexConnect(void)
{
  BEGIN_PROC("VertexConnect");
  // Vertex return code
  tCtqResultCode lRC = eCtqResultSuccess;

  // Handle for the configuration object
  tCtqHandle lCfgHandle = NULL;

  // Get the configuration handle.
  TRACER("Call CtqGetAttrib");
  lRC = CtqGetAttrib(m_lCtqRootHandle,
    eCtqHandleCfg,
    &lCfgHandle,
    eCtqHandle,
    sizeof(lCfgHandle));
  TRACER("Ret CtqGetAttrib");
  if (eCtqResultSuccess != lRC)
  {
    CString strErr = _T("VertexConnect: Unable to retrieve configuration object handle (connect): ");
    strErr += VertexErrorString(lRC);
    END_PROC("VertexConnect");
    throw new CICVWException(strErr);
  }

  // The Customization object hanlde
  tCtqHandle lCtzHandle = NULL;

  // Retrieve Customization object handle.
  TRACER("Call CtqGetAttrib");
  lRC = CtqGetAttrib(m_lCtqRootHandle,
    eCtqHandleCtz,
    &lCtzHandle,
    eCtqHandle,
    sizeof(lCtzHandle));
  TRACER("Ret CtqGetAttrib");
  if (eCtqResultSuccess != lRC)
  {
    CString strErr = _T("VertexConnect: Unable to retrieve Customization object handle: ");
    strErr += VertexErrorString(lRC);
    END_PROC("VertexConnect");
    throw new CICVWException(strErr);
  }

  // Establish Customization database connection.
  TRACER("Call CtqConnect");
  lRC = CtqConnect(lCtzHandle,
    lCfgHandle);
  TRACER("Ret CtqConnect");
  if (eCtqResultSuccess != lRC)
  {
    CString strErr = _T("VertexConnect: Unable to establish Customization database connection: ");
    strErr += VertexErrorString(lRC);
    END_PROC("VertexConnect");
    throw new CICVWException(strErr);
  }

  m_bVertexCtzConnected = true;

  // The Location object hanlde
  tCtqHandle lLocHandle = NULL;

  // Retrieve Location object handle.
  TRACER("Call CtqGetAttrib");
  lRC = CtqGetAttrib(m_lCtqRootHandle,
    eCtqHandleLoc,
    &lLocHandle,
    eCtqHandle,
    sizeof(lLocHandle));
  TRACER("Ret CtqGetAttrib");
  if (eCtqResultSuccess != lRC)
  {
    CString strErr = _T("VertexConnect: Unable to retrieve Location object handle: ");
    strErr += VertexErrorString(lRC);
    END_PROC("VertexConnect");
    throw new CICVWException(strErr);
  }

  // Establish Location database connection.
  TRACER("Call CtqConnect");
  lRC = CtqConnect(lLocHandle,
    lCfgHandle);
  TRACER("Ret CtqConnect");
  if (eCtqResultSuccess != lRC)
  {
    CString strErr = _T("VertexConnect: Unable to establish Location database connection: ");
    strErr += VertexErrorString(lRC);
    END_PROC("VertexConnect");
    throw new CICVWException(strErr);
  }

  m_bVertexLocConnected = true;

  // The Rate object hanlde
  tCtqHandle lRteHandle = NULL;

  // Retrieve Rate object handle.
  TRACER("Call CtqGetAttrib");
  lRC = CtqGetAttrib(m_lCtqRootHandle,
    eCtqHandleRte,
    &lRteHandle,
    eCtqHandle,
    sizeof(lRteHandle));
  TRACER("Ret CtqGetAttrib");
  if (eCtqResultSuccess != lRC)
  {
    CString strErr = _T("VertexConnect: Unable to retrieve Rate object handle: ");
    strErr += VertexErrorString(lRC);
    END_PROC("VertexConnect");
    throw new CICVWException(strErr);
  }

  // Establish Rate database connection.
  TRACER("Call CtqConnect");
  lRC = CtqConnect(lRteHandle,
    lCfgHandle);
  TRACER("Ret CtqConnect");
  if (eCtqResultSuccess != lRC)
  {
    CString strErr = _T("VertexConnect: Unable to establish Rate database connection: ");
    strErr += VertexErrorString(lRC);
    END_PROC("VertexConnect");
    throw new CICVWException(strErr);
  }

  m_bVertexRteConnected = true;

  // The Register object hanlde
  tCtqHandle lRegHandle = NULL;

  // Retrieve Register object handle.
  TRACER("Call CtqGetAttrib");
  lRC = CtqGetAttrib(m_lCtqRootHandle,
    eCtqHandleReg,
    &lRegHandle,
    eCtqHandle,
    sizeof(lRegHandle));
  TRACER("Ret CtqGetAttrib");
  if (eCtqResultSuccess != lRC)
  {
    CString strErr = _T("VertexConnect: Unable to retrieve Register object handle: ");
    strErr += VertexErrorString(lRC);
    END_PROC("VertexConnect");
    throw new CICVWException(strErr);
  }

  // Establish Register database connection.
  TRACER("Call CtqConnect");
  lRC = CtqConnect(lRegHandle,
    lCfgHandle);
  TRACER("Ret CtqConnect");
  if (eCtqResultSuccess != lRC)
  {
    CString strErr = _T("VertexConnect: Unable to establish Register database connection: ");
    strErr += VertexErrorString(lRC);
    END_PROC("VertexConnect");
    throw new CICVWException(strErr);
  }

  m_bVertexRegConnected = true;
  END_PROC("VertexConnect");
}

void CVertexCtrl::VertexDisconnect(void)
{
  BEGIN_PROC("VertexDisconnect");
  // If this fails we don't really have a connection
  //   so lets set the flag
  m_bVertexConnected = false;

  // Vertex return code
  tCtqResultCode lRC = eCtqResultSuccess;

  // Handle for the configuration object
  tCtqHandle lCfgHandle = NULL;

  if( m_bVertexRegConnected )
  {
    // If this fails we don't really have a connection
    //   so lets set the flag
    m_bVertexRegConnected = false;

    // Register object.
    tCtqHandle lRegHandle = NULL;

    // Retrieve Register object handle.
    TRACER("Call CtqGetAttrib");
    lRC = CtqGetAttrib(m_lCtqRootHandle,
      eCtqHandleReg,
      &lRegHandle,
      eCtqHandle,
      sizeof(lRegHandle));
    TRACER("Ret CtqGetAttrib");
    if (eCtqResultSuccess != lRC)
    {
      CString strErr = _T("Unable to get Register object: ");
      strErr += VertexErrorString(lRC);
      END_PROC("VertexDisconnect");
      throw new CICVWException(strErr);
    }

    // Close Register database connection.
    TRACER("Call CtqDisconnect");
    lRC = CtqDisconnect(lRegHandle);
    TRACER("Ret CtqDisconnect");
    if (eCtqResultSuccess != lRC)
    {
      CString strErr = _T("Unable to disconnect Register DB: ");
      strErr += VertexErrorString(lRC);
      END_PROC("VertexDisconnect");
      throw new CICVWException(strErr);
    }
  }

  if( m_bVertexRteConnected )
  {
    // If this fails we don't really have a connection
    //   so lets set the flag
    m_bVertexRteConnected = false;

    // Rate object.
    tCtqHandle lRteHandle = NULL;

    // Retrieve Rate object handle.
    TRACER("Call CtqGetAttrib");
    lRC = CtqGetAttrib(m_lCtqRootHandle,
      eCtqHandleReg,
      &lRteHandle,
      eCtqHandle,
      sizeof(lRteHandle));
    TRACER("Ret CtqGetAttrib");
    if (eCtqResultSuccess != lRC)
    {
      CString strErr = _T("Unable to get Rate object: ");
      strErr += VertexErrorString(lRC);
      END_PROC("VertexDisconnect");
      throw new CICVWException(strErr);
    }

    // Close Rate database connection.
    TRACER("Call CtqDisconnect");
    lRC = CtqDisconnect(lRteHandle);
    TRACER("Ret CtqDisconnect");
    if (eCtqResultSuccess != lRC)
    {
      CString strErr = _T("Unable to disconnect Rate DB: ");
      strErr += VertexErrorString(lRC);
      END_PROC("VertexDisconnect");
      throw new CICVWException(strErr);
    }
  }

  if( m_bVertexLocConnected )
  {
    // If this fails we don't really have a connection
    //   so lets set the flag
    m_bVertexLocConnected = false;

    // Location object.
    tCtqHandle lLocHandle = NULL;

    // Retrieve Location object handle.
    TRACER("Call CtqGetAttrib");
    lRC = CtqGetAttrib(m_lCtqRootHandle,
      eCtqHandleLoc,
      &lLocHandle,
      eCtqHandle,
      sizeof(lLocHandle));
    TRACER("Ret CtqGetAttrib");
    if (eCtqResultSuccess != lRC)
    {
      CString strErr = _T("Unable to get Location object: ");
      strErr += VertexErrorString(lRC);
      END_PROC("VertexDisconnect");
      throw new CICVWException(strErr);
    }

    // Close Location database connection.
    TRACER("Call CtqDisconnect");
    lRC = CtqDisconnect(lLocHandle);
    TRACER("Ret CtqDisconnect");
    if (eCtqResultSuccess != lRC)
    {
      CString strErr = _T("Unable to disconnect Location DB: ");
      strErr += VertexErrorString(lRC);
      END_PROC("VertexDisconnect");
      throw new CICVWException(strErr);
    }
  }

  if( m_bVertexCtzConnected )
  {
    // If this fails we don't really have a connection
    //   so lets set the flag
    m_bVertexCtzConnected = false;

    // Customization object.
    tCtqHandle lCtzHandle = NULL;

    // Retrieve Customization object handle.
    TRACER("Call CtqGetAttrib");
    lRC = CtqGetAttrib(m_lCtqRootHandle,
      eCtqHandleCtz,
      &lCtzHandle,
      eCtqHandle,
      sizeof(lCtzHandle));
    TRACER("Ret CtqGetAttrib");
    if (eCtqResultSuccess != lRC)
    {
      CString strErr = _T("Unable to get Customization object: ");
      strErr += VertexErrorString(lRC);
      END_PROC("VertexDisconnect");
      throw new CICVWException(strErr);
    }

    // Close Customization database connection.
    TRACER("Call CtqDisconnect");
    lRC = CtqDisconnect(lCtzHandle);
    TRACER("Ret CtqDisconnect");
    if (eCtqResultSuccess != lRC)
    {
      CString strErr = _T("Unable to disconnect Customization DB: ");
      strErr += VertexErrorString(lRC);
      END_PROC("VertexDisconnect");
      throw new CICVWException(strErr);
    }
  }
  END_PROC("VertexDisconnect");
}

void CVertexCtrl::SetVertexParams(CComBSTR &strParams)
{
  BEGIN_PROC("SetVertexParams");
  using namespace std;
  using namespace XERCES_CPP_NAMESPACE;
  USES_CONVERSION;

  tCtqResultCode lRC = eCtqResultSuccess;

  tCtqHandle lRegHandle = NULL;
  tCtqHandle lRegTrnHandle = NULL;

  // Retrieve Register object handle. */
  TRACER("Call CtqGetAttrib");
  lRC = CtqGetAttrib(m_lCtqRootHandle,
    eCtqHandleReg,
    &lRegHandle,
    eCtqHandle,
    sizeof(lRegHandle));
  TRACER("Ret CtqGetAttrib");
  if (eCtqResultSuccess != lRC)
  {
    CString strErr = _T("SetVertexParams(";
    strErr += strParams;
    strErr += "): Unable to retrieve Register object handle: ");
    strErr += VertexErrorString(lRC);
    END_PROC("SetVertexParams");
    throw new CICVWException(strErr);
  }

  // Set whether we are writing to the registry
  lRC = SetVertexAttrib(lRegHandle,CString("WriteJournal"),&m_bWriteToJournal);
  if(eCtqResultSuccess != lRC)
  {
    CString strErr = _T("Unable to set Register object write attibute: ");
    strErr += VertexErrorString(lRC);
    END_PROC("SetVertexParams");
    throw new CICVWException(strErr);
  }

  /* Retrieve Register Transaction object handle. */
  TRACER("Call CtqGetAttrib");
  lRC = CtqGetAttrib(lRegHandle,
    eCtqHandleRegTrn,
    &lRegTrnHandle,
    eCtqHandle,
    sizeof(lRegTrnHandle));
  TRACER("Ret CtqGetAttrib");
  if (eCtqResultSuccess != lRC)
  {
    CString strErr = _T("Unable to retrieve Register Transaction object handle: ");
    strErr += VertexErrorString(lRC);
    END_PROC("SetVertexParams");
    throw new CICVWException(strErr);
  }

  /* Reset transaction information. */
  TRACER("Call CtqResetAttribs");
  lRC = CtqResetAttribs(lRegTrnHandle);
  TRACER("Ret CtqResetAttribs");
  if (eCtqResultSuccess != lRC)
  {
    CString strErr = _T("Unable to reset Register Transaction object attributes: ");
    strErr += VertexErrorString(lRC);
    END_PROC("SetVertexParams");
    throw new CICVWException(strErr);
  }

  // Now go through our XMLParams and apply the values.
  XercesDOMParser *parser = new XercesDOMParser;

  // Set up the parser
  DOMTreeErrorReporter *errReporter = new DOMTreeErrorReporter();
  parser->setErrorHandler(errReporter);

  try
  {
    // Run the parser from our XML string
    MemBufInputSource is((XMLByte*)W2A(strParams.m_str),strParams.Length(),"BogusID");
    parser->parse(is);
  }
  catch (const OutOfMemoryException&)
  {
    delete parser;
    delete errReporter;
    CString strErr = _T("Caught OutOfMemoryException while parsing.");
    END_PROC("SetVertexParams");
    throw new CICVWException(strErr);
  }
  catch (const XMLException& e)
  {
    delete parser;
    delete errReporter;
    CString strErr = _T("Caught exception during parsing\n   Message: ");
    strErr += (TCHAR*)e.getMessage();
    END_PROC("SetVertexParams");
    throw new CICVWException(strErr);
  }
  catch (const DOMException& e)
  {
    delete parser;
    delete errReporter;
    const unsigned int maxChars = 2047;
    XMLCh errText[maxChars + 1];

    CString strErr = _T("Caught DOM Error during parsing: 'personal.xml'\nDOMException code is: ");
    CString strNum;
    strNum.Format(_T("%d"),e.code);
    strErr += strNum;

    if (DOMImplementation::loadDOMExceptionMsg(e.code, errText, maxChars))
    {
      strErr += _T("\n\nMessage is: ");
      strErr += (TCHAR*)errText;
    }

    END_PROC("SetVertexParams");
    throw new CICVWException(strErr);
  }
  catch (...)
  {
    delete parser;
    delete errReporter;
    CString strErr = BEGIN_ERROR_XML;
    strErr += _T("Unhandled exception was caught while parsing.");
    END_PROC("SetVertexParams");
    throw new CICVWException(strErr);
  }

  // get the DOM representation
  XERCES_CPP_NAMESPACE::DOMDocument *doc = parser->getDocument();

  // Set up a filter to iterate through the elements
  DOMNode * nodeRoot = doc->getFirstChild();
  unsigned long whatToShow = DOMNodeFilter::SHOW_ELEMENT;
  CSimpleFilter* filter = new CSimpleFilter(DOMNode::ELEMENT_NODE);
  DOMNodeIterator*  iter = ((DOMDocumentTraversal*)doc)->createNodeIterator(nodeRoot, whatToShow, filter, true);

  // Make sure we are starting in the right place
  DOMNode* nd = iter->nextNode();
  if( CString(nd->getNodeName()) == CString("VertexTaxParams") )
  {
    // Process all of the elements
    while( NULL != (nd = iter->nextNode()) )
    {
      CString strName = nd->getNodeName();
      DOMNode* ndChild = nd->getFirstChild();

      // Ensure that we are getting data
      if( NULL == ndChild || DOMNode::TEXT_NODE != ndChild->getNodeType() )
      {
        delete parser;
        delete errReporter;
        delete filter;
        CString strErr;
        strErr = _T("Incorrect format for Tax Parameters:");
        strErr += _T("node (");
        strErr += strName;
        strErr += _T(") does not have a text child.");
        END_PROC("SetVertexParams");
        throw new CICVWException(strErr);
      }

      // Get the Attrib descriptor
      CVertexAttribObj *pObj = m_mapVertexAttrib[strName];
      if( NULL == pObj )
      {
        delete parser;
        delete errReporter;
        delete filter;
        CString strErr;
        strErr = _T("Attribute (");
        strErr += strName;
        strErr += _T(") is not supported.");
        END_PROC("SetVertexParams");
        throw new CICVWException(strErr);
      }

      // To check for the return code.
      tCtqResultCode lRC = eCtqResultSuccess;

      // Translate from XML to the type of data we need
      switch(pObj->m_Type)
      {
      case eCtqString:
        {
          CString sValue = ndChild->getNodeValue();
          _TCHAR* pBuff = sValue.GetBuffer();
          lRC = SetVertexAttrib(lRegTrnHandle,strName,pBuff);
          sValue.ReleaseBuffer();
        }
        break;
      case eCtqInt:
      case eCtqEnum:
        {
          int iValue = _tstoi(ndChild->getNodeValue());
          lRC = SetVertexAttrib(lRegTrnHandle,strName,&iValue);
        }
        break;
      case eCtqDouble:
        {
          double dValue = _tstof(ndChild->getNodeValue());
          lRC = SetVertexAttrib(lRegTrnHandle,strName,&dValue);
        }
        break;
      default:
        {
          delete parser;
          delete errReporter;
          delete filter;
          CString strErr;
          strErr = _T("Unknown attribute type for (");
          strErr += strName;
          strErr += _T(")");
          lRC = eCtqResultFailure;
          END_PROC("SetVertexParams");
          throw new CICVWException(strErr);
        }
      }

      // We weren't able to set it
      if( eCtqResultSuccess != lRC )
      {
        delete parser;
        delete errReporter;
        delete filter;
        CString strErr = _T("Unable to set an attribute in (");
        strErr += strParams;
        strErr += _T("): ");
        strErr += VertexErrorString(lRC);
        END_PROC("SetVertexParams");
        throw new CICVWException(strErr);
      }
    }
  }
  else
  {
    delete parser;
    delete errReporter;
    delete filter;
    CString strErr;
    strErr = _T("Incorrect format for Tax Parameters: Invalid Root Node.");
    END_PROC("SetVertexParams");
    throw new CICVWException(strErr);
  }
  delete parser;
  delete errReporter;
  delete filter;
  END_PROC("SetVertexParams");
}

void CVertexCtrl::SetLookupVertexParams(tCtqHandle& lLocHandle, CComBSTR &strParams)
{
  BEGIN_PROC("SetLookupVertexParams");
  using namespace std;
  using namespace XERCES_CPP_NAMESPACE;
  USES_CONVERSION;

  tCtqResultCode lRC = eCtqResultSuccess;

  // Go through our XMLParams and apply the values.
  XercesDOMParser *parser = new XercesDOMParser;

  // Set up the parser
  DOMTreeErrorReporter *errReporter = new DOMTreeErrorReporter();
  parser->setErrorHandler(errReporter);

  try
  {
    // Run the parser from our XML string
    MemBufInputSource is((XMLByte*)W2A(strParams.m_str),strParams.Length(),"BogusID");
    parser->parse(is);
  }
  catch (const OutOfMemoryException&)
  {
    delete parser;
    delete errReporter;
    CString strErr = _T("Caught OutOfMemoryException while parsing.");
    END_PROC("SetLookupVertexParams");
    throw new CICVWException(strErr);
  }
  catch (const XMLException& e)
  {
    delete parser;
    delete errReporter;
    CString strErr = _T("Caught exception during parsing\n   Message: ");
    strErr += (TCHAR*)e.getMessage();
    END_PROC("SetLookupVertexParams");
    throw new CICVWException(strErr);
  }
  catch (const DOMException& e)
  {
    delete parser;
    delete errReporter;
    const unsigned int maxChars = 2047;
    XMLCh errText[maxChars + 1];

    CString strErr = _T("Caught DOM Error during parsing: 'personal.xml'\nDOMException code is: ");
    CString strNum;
    strNum.Format(_T("%d"),e.code);
    strErr += strNum;

    if (DOMImplementation::loadDOMExceptionMsg(e.code, errText, maxChars))
    {
      strErr += _T("\n\nMessage is: ");
      strErr += (TCHAR*)errText;
    }

    END_PROC("SetLookupVertexParams");
    throw new CICVWException(strErr);
  }
  catch (...)
  {
    delete parser;
    delete errReporter;
    CString strErr = BEGIN_ERROR_XML;
    strErr += _T("Unhandled exception was caught while parsing.");
    END_PROC("SetLookupVertexParams");
    throw new CICVWException(strErr);
  }

  // get the DOM representation
  XERCES_CPP_NAMESPACE::DOMDocument *doc = parser->getDocument();

  // Set up a filter to iterate through the elements
  DOMNode * nodeRoot = doc->getFirstChild();
  unsigned long whatToShow = DOMNodeFilter::SHOW_ELEMENT;
  CSimpleFilter* filter = new CSimpleFilter(DOMNode::ELEMENT_NODE);
  DOMNodeIterator*  iter = ((DOMDocumentTraversal*)doc)->createNodeIterator(nodeRoot, whatToShow, filter, true);

  // Make sure we are starting in the right place
  DOMNode* nd = iter->nextNode();
  if( CString(nd->getNodeName()) == CString("VertexLookupLocationParams") )
  {
    // Process all of the elements
    while( NULL != (nd = iter->nextNode()) )
    {
      CString strName = nd->getNodeName();
      DOMNode* ndChild = nd->getFirstChild();

      // Ensure that we are getting data
      if( NULL == ndChild || DOMNode::TEXT_NODE != ndChild->getNodeType() )
      {
        delete parser;
        delete errReporter;
        delete filter;
        CString strErr;
        strErr = _T("Incorrect format for Tax Parameters:");
        strErr += _T("node (");
        strErr += strName;
        strErr += _T(") does not have a text child.");
        END_PROC("SetLookupVertexParams");
        throw new CICVWException(strErr);
      }

      // Get the Attrib descriptor
      CVertexAttribObj *pObj = m_mapVertexAttrib[strName];
      if( NULL == pObj )
      {
        delete parser;
        delete errReporter;
        delete filter;
        CString strErr;
        strErr = _T("Attribute (");
        strErr += strName;
        strErr += _T(") is not supported.");
        END_PROC("SetLookupVertexParams");
        throw new CICVWException(strErr);
      }

      // To check for the return code.
      tCtqResultCode lRC = eCtqResultSuccess;

      // Translate from XML to the type of data we need
      switch(pObj->m_Type)
      {
      case eCtqString:
        {
          CString sValue = ndChild->getNodeValue();
          _TCHAR* pBuff = sValue.GetBuffer();
          lRC = SetVertexAttrib(lLocHandle,strName,pBuff);
          sValue.ReleaseBuffer();
        }
        break;

        // This function only deals with string criteria.
        //   Anything else is unexpected and thus an error.
      case eCtqInt:
      case eCtqEnum:
      case eCtqDouble:
      default:
        {
          delete parser;
          delete errReporter;
          delete filter;
          CString strErr;
          strErr = _T("Invalid attribute type for (");
          strErr += strName;
          strErr += _T(")");
          lRC = eCtqResultFailure;
          END_PROC("SetLookupVertexParams");
          throw new CICVWException(strErr);
        }
      }

      // We weren't able to set it
      if( eCtqResultSuccess != lRC )
      {
        delete parser;
        delete errReporter;
        delete filter;
        CString strErr = _T("Unable to set attribute in (");
        strErr += strParams;
        strErr += _T("): ");
        strErr += VertexErrorString(lRC);
        END_PROC("SetLookupVertexParams");
        throw new CICVWException(strErr);
      }
    }
  }
  else
  {
    delete parser;
    delete errReporter;
    delete filter;
    CString strErr;
    strErr = _T("Incorrect format for Tax Parameters: Invalid Root Node.");
    END_PROC("SetLookupVertexParams");
    throw new CICVWException(strErr);
  }
  delete parser;
  delete errReporter;
  delete filter;
  END_PROC("SetLookupVertexParams");
}

CComBSTR CVertexCtrl::GetVertexResults()
{
  BEGIN_PROC("GetVertexResults");
  CComBSTR strRet = _T("<TaxResults>");

  tCtqResultCode lRC = eCtqResultSuccess;

  // Retrieve the Register object handle.
  tCtqHandle lRegHandle = NULL;
  TRACER("Call CtqGetAttrib");
  lRC = CtqGetAttrib(m_lCtqRootHandle,
    eCtqHandleReg,
    &lRegHandle,
    eCtqHandle,
    sizeof(lRegHandle));
  TRACER("Ret CtqGetAttrib");
  if (eCtqResultSuccess != lRC)
  {
    CString strErr = _T("Unable to retrieve Register object handle for results: ");
    strErr += VertexErrorString(lRC);
    END_PROC("GetVertexResults");
    throw new CICVWException(strErr);
  }

  // Retrieve Register Transaction object handle.
  tCtqHandle lRegTrnHandle = NULL;
  TRACER("Call CtqGetAttrib");
  lRC = CtqGetAttrib(lRegHandle,
    eCtqHandleRegTrn,
    &lRegTrnHandle,
    eCtqHandle,
    sizeof(lRegTrnHandle));
  TRACER("Ret CtqGetAttrib");
  if (eCtqResultSuccess != lRC)
  {
    CString strErr = _T("Unable to retrieve Register Transaction object handle for results: ");
    strErr += VertexErrorString(lRC);
    END_PROC("GetVertexResults");
    throw new CICVWException(strErr);
  }

  // Retrieve invoice number
  strRet += _T("<InvoiceNumber>");
  strRet += GetVertexAttrib(lRegTrnHandle,CString(_T("InvoiceNumber")));
  strRet += _T("</InvoiceNumber>");

  // Retrieve invoice date
  strRet += _T("<InvoiceDate>");
  strRet += GetVertexAttrib(lRegTrnHandle,CString(_T("InvoiceDate")));
  strRet += _T("</InvoiceDate>");

  /* We don't really need the input location info
  *   since it changes depending on the input mode.
  // Retrieve Origin Location
  strRet += _T("<OriginGeoCode>");
  strRet += GetVertexAttrib(lRegTrnHandle,CString(_T("OriginGeoCode")));
  strRet += _T("</OriginGeoCode>");

  // Retrieve Termination Location
  strRet += _T("<TerminationGeoCode>");
  strRet += GetVertexAttrib(lRegTrnHandle,CString(_T("TerminationGeoCode")));
  strRet += _T("</TerminationGeoCode>");

  // Retrieve Charge To Location
  strRet += _T("<ChargeToGeoCode>");
  strRet += GetVertexAttrib(lRegTrnHandle,CString(_T("ChargeToGeoCode")));
  strRet += _T("</ChargeToGeoCode>");
  */

  // Retrieve Taxed Location
  strRet += _T("<TaxedGeoCode>");
  strRet += GetVertexAttrib(lRegTrnHandle,CString(_T("TaxedGeoCode")));
  strRet += _T("</TaxedGeoCode>");

  // Retrieve Taxed City Name
  strRet += _T("<TaxedCityName>");
  strRet += GetVertexAttrib(lRegTrnHandle,CString(_T("TaxedCityName")));
  strRet += _T("</TaxedCityName>");

  // Retrieve Taxed County Name
  strRet += _T("<TaxedCountyName>");
  strRet += GetVertexAttrib(lRegTrnHandle,CString(_T("TaxedCountyName")));
  strRet += _T("</TaxedCountyName>");

  // Retrieve Taxed GeoCode Incorporated Code
  strRet += _T("<TaxedGeoCodeIncorporatedCode>");
  strRet += GetVertexAttrib(lRegTrnHandle,CString(_T("TaxedGeoCodeIncorporatedCode")));
  strRet += _T("</TaxedGeoCodeIncorporatedCode>");

  // Retrieve Taxed State Code
  strRet += _T("<TaxedStateCode>");
  strRet += GetVertexAttrib(lRegTrnHandle,CString(_T("TaxedStateCode")));
  strRet += _T("</TaxedStateCode>");

  // Get the Bundle Category Code
  strRet += _T("<BundleCategoryCode>");
  strRet += GetVertexAttrib(lRegTrnHandle,CString(_T("BundleCategoryCode")));
  strRet += _T("</BundleCategoryCode>");

  // Get the Bundle Flag
  strRet += _T("<BundleFlag>");
  strRet += GetVertexAttrib(lRegTrnHandle,CString(_T("BundleFlag")));
  strRet += _T("</BundleFlag>");

  // Get the Bundle Service Code
  strRet += _T("<BundleServiceCode>");
  strRet += GetVertexAttrib(lRegTrnHandle,CString(_T("BundleServiceCode")));
  strRet += _T("</BundleServiceCode>");

  // Retrieve the handle to each tax object under the transaction object.
  tCtqHandle lRegTaxHandle = NULL;
  TRACER("Call CtqGetAttrib");
  lRC = CtqGetAttrib(lRegTrnHandle,
    eCtqHandleRegTax,
    &lRegTaxHandle,
    eCtqHandle,
    sizeof(lRegTaxHandle));
  TRACER("Ret CtqGetAttrib");
  if (eCtqResultSuccess != lRC)
  {
    CString strErr = _T("Unable to retrieve tax detail handle: ");
    strErr += VertexErrorString(lRC);
    END_PROC("GetVertexResults");
    throw new CICVWException(strErr);
  }

  // Retrieve the count of tax objects for this transaction.
  int lTaxCount = 0;
  TRACER("Call CtqGetAttrib");
  lRC = CtqGetAttrib(lRegTaxHandle,
    eCtqAttribRowCount,
    &lTaxCount,
    eCtqInt,
    sizeof(lTaxCount));
  TRACER("Ret CtqGetAttrib");
  if (eCtqResultSuccess != lRC)
  {
    CString strErr = _T("Unable to retrieve row count tax detail object: ");
    strErr += VertexErrorString(lRC);
    END_PROC("GetVertexResults");
    throw new CICVWException(strErr);
  }
  strRet += _T("<TaxRecords>");

  // process each instance of the tax detail object.
  for (int iTaxIndex = 0; iTaxIndex < lTaxCount; iTaxIndex++)
  {
    strRet += _T("<TaxRecord>");

    // Set the index on the tax detail object to reference the current instance.
    TRACER("Call CtqSetAttrib");
    lRC = ::CtqSetAttrib(lRegTaxHandle,
      eCtqAttribRowIndex,
      &iTaxIndex,
      eCtqInt);
    TRACER("Ret CtqSetAttrib");
    if (eCtqResultSuccess != lRC)
    {
      CString strErr = _T("Unable to set tax detail index: ");
      strErr += VertexErrorString(lRC);
      END_PROC("GetVertexResults");
      throw new CICVWException(strErr);
    }

    // Obtain the taxing authority.
    strRet += _T("<TaxAuthority>");
    strRet += GetVertexAttrib(lRegTaxHandle,CString(_T("TaxAuthority")));
    strRet += _T("</TaxAuthority>");

    // Get the tax type.
    strRet += _T("<TaxType>");
    strRet += GetVertexAttrib(lRegTaxHandle,CString(_T("TaxType")));
    strRet += _T("</TaxType>");

    // Get the tax code. (This attribute is retrieved but not displayed.)
    strRet += _T("<TaxCode>");
    strRet += GetVertexAttrib(lRegTaxHandle,CString(_T("TaxCode")));
    strRet += _T("</TaxCode>");

    // Get the tax rate.
    strRet += _T("<TaxRate>");
    strRet += GetVertexAttrib(lRegTaxHandle,CString(_T("TaxRate")));
    strRet += _T("</TaxRate>");

    // Get the lines taxed.
    strRet += _T("<LinesTaxed>");
    strRet += GetVertexAttrib(lRegTaxHandle,CString(_T("LinesTaxed")));
    strRet += _T("</LinesTaxed>");

    // Get the trunk lines taxed.
    strRet += _T("<TrunksTaxed>");
    strRet += GetVertexAttrib(lRegTaxHandle,CString(_T("TrunksTaxed")));
    strRet += _T("</TrunksTaxed>");

    // Get the tax amount.
    strRet += _T("<TaxAmount>");
    strRet += GetVertexAttrib(lRegTaxHandle,CString(_T("TaxAmount")));
    strRet += _T("</TaxAmount>");

    // Get the linked tax amount.
    strRet += _T("<LinkTaxAmount>");
    strRet += GetVertexAttrib(lRegTaxHandle,CString(_T("LinkTaxAmount")));
    strRet += _T("</LinkTaxAmount>");

    // Get the Customer Override flag.
    strRet += _T("<CustomerOverride>");
    strRet += GetVertexAttrib(lRegTaxHandle,CString(_T("CustomerOverride")));
    strRet += _T("</CustomerOverride>");

    strRet += _T("</TaxRecord>");
  }
  strRet += _T("</TaxRecords>");

  strRet += _T("</TaxResults>");
  END_PROC("GetVertexResults");
  return strRet;
}

CComBSTR CVertexCtrl::GetLookupVertexResults(tCtqHandle& lLocHandle)
{
  BEGIN_PROC("GetLookupVertexResults");
  CComBSTR strRet = _T("<LookupResults>");

  tCtqResultCode lRC = eCtqResultSuccess;

  // Set the index on the Location object handle to 0.
  //   We are only dealing with the first returned row in any case.
  int lRowIndex = 0;
  TRACER("Call CtqSetAttrib");
  lRC = ::CtqSetAttrib(lLocHandle,
    eCtqAttribRowIndex,
    &lRowIndex,
    eCtqInt);
  TRACER("Ret CtqSetAttrib");
  if (eCtqResultSuccess != lRC)
  {
    CString strErr = _T("Unable to set Lookup row index: ");
    strErr += VertexErrorString(lRC);
    END_PROC("GetLookupVertexResults");
    throw new CICVWException(strErr);
  }

  // Obtain GeoCode.
  strRet += _T("<AttribGeoCode>");
  strRet += GetVertexAttrib(lLocHandle,CString(_T("AttribGeoCode")));
  strRet += _T("</AttribGeoCode>");

  strRet += _T("</LookupResults>");

  END_PROC("GetLookupVertexResults");
  return strRet;
}

CString CVertexCtrl::ReportTimings()
{
  BEGIN_PROC("ReportTimings");
  CString strRet = _T("");
  if( m_bReturnTimings )
  {
    strRet = _T("<Timings>");
    LARGE_INTEGER leStart = m_vTiming[0]->m_leTiming;
    LARGE_INTEGER leBegin = leStart;
    LARGE_INTEGER leStop;
	int size = m_vTiming.size();
    for(int i = 0; i < size; i++ )
    {
      strRet += _T("<Interval><Desc>");
      strRet += m_vTiming[i]->strDesc;
      strRet += _T("</Desc><Milliseconds>");
      CString strMilli;
      leStop = m_vTiming[i]->m_leTiming;
      strMilli.Format(_T("%d"), (1000 * ( leStop.QuadPart - leStart.QuadPart )) / m_leTimingFreq.QuadPart);
      strRet += strMilli;
      strRet += _T("</Milliseconds></Interval>");
      leStart = leStop;
    }
    strRet += _T("<TotalTime>");
    CString strTotMilli;
    strTotMilli.Format(_T("%d"), (1000 * ( leStop.QuadPart - leBegin.QuadPart )) / m_leTimingFreq.QuadPart);
    strRet += strTotMilli;
    strRet += _T("</TotalTime>");
    strRet += _T("</Timings>");
  }

  END_PROC("ReportTimings");
  return strRet;
}

STDAPI CVertexCtrl::get_bstrVertexConfigPath(BSTR* pVal)
{
  AFX_MANAGE_STATE(AfxGetStaticModuleState());

  *pVal = m_bstrVertexConfigPath.Copy();

  return S_OK;
}

STDAPI CVertexCtrl::put_bstrVertexConfigPath(BSTR newVal)
{
  AFX_MANAGE_STATE(AfxGetStaticModuleState());

  m_bstrVertexConfigPath = newVal;

  return S_OK;
}

STDAPI CVertexCtrl::get_bstrVertexConfigName(BSTR* pVal)
{
  AFX_MANAGE_STATE(AfxGetStaticModuleState());

  *pVal = m_bstrVertexConfigName.Copy();

  return S_OK;
}

STDAPI CVertexCtrl::put_bstrVertexConfigName(BSTR newVal)
{
  AFX_MANAGE_STATE(AfxGetStaticModuleState());

  m_bstrVertexConfigName = newVal;

  return S_OK;
}

STDAPI CVertexCtrl::Initialize(BSTR* bstrResults)
{
  BEGIN_PROC("Initialize");
  AFX_MANAGE_STATE(AfxGetStaticModuleState());

  ADD_TIMING(_T("Begin Initialize"));
  bool bHasErrors = false;

  CComBSTR bstrRet;
  bstrRet = BEGIN_SUCCESS_XML;

  using namespace XERCES_CPP_NAMESPACE;
  try
  {
    ADD_TIMING(_T("Begin Processing"));
    // XML support initialization
    XMLPlatformUtils::Initialize();
    m_bXercesInitialized = true;
    ADD_TIMING(_T("XMLPlatformUtils::Initialize Done"));

    // Vertex support initialization
    VertexSysInit();
    ADD_TIMING(_T("VertexSysInit Done"));
    VertexInit();
    ADD_TIMING(_T("VertexInit Done"));
    VertexConnect();
    ADD_TIMING(_T("VertexConnect Done"));
    m_bVertexConnected = true;
    ADD_TIMING(_T("End Processing"));
  }
  catch(const XMLException &toCatch)
  {
    bstrRet = BEGIN_ERROR_XML;
    bstrRet += _T("Error during Xerces-c Initialization.\n  Exception message: ");
    bstrRet += (TCHAR*)toCatch.getMessage();
    bHasErrors = true;
  }
  catch(CICVWException* e)
  {
    bstrRet = BEGIN_ERROR_XML;
    bstrRet += e->m_strErr;
    //Reset(NULL);
    bHasErrors = true;
    e->Delete();
  }
  catch(...)
  {
    bstrRet = BEGIN_ERROR_XML;
    bstrRet += _T("Unhandled exception");
    bHasErrors = true;
  }

  m_bInitialized = true;
  if( m_bReturnTimings )
  {
    ADD_TIMING(_T("End Initialize"));
    bstrRet += ReportTimings();
    DELETE_TIMINGS;
  }

  if( !bHasErrors )
    bstrRet += END_SUCCESS_XML;
  else 
    bstrRet += END_ERROR_XML;

  if( bstrResults )
    *bstrResults = bstrRet.Copy();

  END_PROC("Initialize");
  return S_OK;
}

STDAPI CVertexCtrl::Reconnect(BSTR* bstrResults)
{
  BEGIN_PROC("Reconnect");
  AFX_MANAGE_STATE(AfxGetStaticModuleState());

  CComBSTR bstrRet;
  bstrRet = BEGIN_SUCCESS_XML;
  bool bHasErrors = false;

  try
  {
    VertexDisconnect();
    VertexConnect();
  }
  catch(CICVWException* e)
  {
    bstrRet = BEGIN_ERROR_XML;
    bstrRet += e->m_strErr;
    //Reset(NULL);
    bHasErrors = true;
    e->Delete();
  }
  catch(...)
  {
    bstrRet = BEGIN_ERROR_XML;
    bstrRet += _T("Unhandled exception");
    bHasErrors = true;
  }

  if( !bHasErrors )
  {
    bstrRet += END_SUCCESS_XML;
  }
  else
  {
    m_bInitialized = false;
    bstrRet += END_ERROR_XML;
  }

  if( bstrResults )
    *bstrResults = bstrRet.Copy();

  END_PROC("Reconnect");
  return S_OK;
}

STDAPI CVertexCtrl::Refresh(BSTR* bstrResults)
{
  BEGIN_PROC("Refresh");
  AFX_MANAGE_STATE(AfxGetStaticModuleState());

  CComBSTR bstrRet;
  bstrRet = BEGIN_SUCCESS_XML;
  bool bHasErrors = false;

  try
  {
    VertexTerm();
  }
  catch(CICVWException* e)
  {
    bstrRet = BEGIN_ERROR_XML;
    bstrRet += e->m_strErr;
    //Reset(NULL);
    bHasErrors = true;
    e->Delete();
  }
  catch(...)
  {
    bstrRet = BEGIN_ERROR_XML;
    bstrRet += _T("Unhandled exception");
    bHasErrors = true;
  }

  if( !bHasErrors )
  {
    bstrRet += END_SUCCESS_XML;
  }
  else
  {
    m_bInitialized = false;
    bstrRet += END_ERROR_XML;
  }

  if( bstrResults )
    *bstrResults = bstrRet.Copy();

  END_PROC("Refresh");
  return S_OK;
}

STDAPI CVertexCtrl::Reset(BSTR* bstrResults)
{
  BEGIN_PROC("Reset");
  AFX_MANAGE_STATE(AfxGetStaticModuleState());

  CComBSTR bstrRet;
  bstrRet = BEGIN_SUCCESS_XML;
  bool bHasErrors = false;

  try
  {
    VertexDisconnect();
    VertexTerm();
    Initialize(NULL);
  }
  catch(CICVWException* e)
  {
    bstrRet = BEGIN_ERROR_XML;
    bstrRet += e->m_strErr;
    //Reset(NULL);
    bHasErrors = true;
    e->Delete();
  }
  catch(...)
  {
    bstrRet = BEGIN_ERROR_XML;
    bstrRet += _T("Unhandled exception");
    bHasErrors = true;
  }

  if( !bHasErrors )
  {
    bstrRet += END_SUCCESS_XML;
  }
  else
  {
    m_bInitialized = false;
    bstrRet += END_ERROR_XML;
  }

  if( bstrResults )
    *bstrResults = bstrRet.Copy();

  END_PROC("Reset");
  return S_OK;
}

STDAPI CVertexCtrl::Terminate(BSTR* bstrResults)
{
  BEGIN_PROC("Terminate");
  AFX_MANAGE_STATE(AfxGetStaticModuleState());

  ADD_TIMING(_T("Begin Terminate"));

  CComBSTR bstrRet;
  bstrRet = BEGIN_SUCCESS_XML;
  bool bHasErrors = false;

  try
  {
    ADD_TIMING(_T("Begin Processing"));
    if( m_bXercesInitialized)
      XMLPlatformUtils::Terminate();
    ADD_TIMING(_T("XMLPlatformUtils::Terminate Done"));
    VertexDisconnect();
    ADD_TIMING(_T("VertexDisconnect Done"));
    VertexTerm();
    ADD_TIMING(_T("VertexTerm Done"));
    VertexSysTerm();
    ADD_TIMING(_T("VertexSysTerm Done"));

    m_bstrVertexConfigName.Empty();
    m_bstrVertexConfigPath.Empty();
    ADD_TIMING(_T("End Processing"));
  }
  catch(CICVWException* e)
  {
    bstrRet = BEGIN_ERROR_XML;
    bstrRet += e->m_strErr;
    //Reset(NULL);
    bHasErrors = true;
    e->Delete();
  }
  catch(...)
  {
    bstrRet = BEGIN_ERROR_XML;
    bstrRet += _T("Unhandled exception");
    bHasErrors = true;
  }

  m_bInitialized = false;
  if( m_bReturnTimings )
  {
    ADD_TIMING(_T("End Terminate"));
    bstrRet += ReportTimings();
    DELETE_TIMINGS;
  }

  if( !bHasErrors )
    bstrRet += END_SUCCESS_XML;
  else
    bstrRet += END_ERROR_XML;

  if( bstrResults )
    *bstrResults = bstrRet.Copy();

  END_PROC("Terminate");
  return S_OK;
}

STDAPI CVertexCtrl::CalculateTaxes(BSTR bstrXMLParams, BSTR* bstrResults)
{
  BEGIN_PROC("CalculateTaxes");
  AFX_MANAGE_STATE(AfxGetStaticModuleState());

  ADD_TIMING(_T("Begin CalculateTaxes"));

  CComBSTR bstrRet;
  bstrRet = BEGIN_SUCCESS_XML;
  bool bHasErrors = false;

  try
  {
    if(!m_bInitialized)
    {
      CString strErr = _T("The object is not initialized correctly.");
      END_PROC("CalculateTaxes");
      throw new CICVWException(strErr);
    }

    CComBSTR bstrXML(bstrXMLParams);
    ADD_TIMING(_T("Begin Processing"));

    SetVertexParams(bstrXML);
    ADD_TIMING(_T("SetVertexParams Done"));

    TRACER("Call CtqCalculateTax");
    tCtqResultCode lRC = CtqCalculateTax(m_lCtqRootHandle);
    TRACER("Ret CtqCalculateTax");
    if (eCtqResultSuccess != lRC)
    {
      CString strErr = _T("Unable to calculate the tax: ");
      strErr += VertexErrorString(lRC);
      END_PROC("CalculateTaxes");
      throw new CICVWException(strErr);
    }
    ADD_TIMING(_T("CtqCalculateTax Done"));

    bstrRet += GetVertexResults();
    ADD_TIMING(_T("GetVertexResults Done"));

    ADD_TIMING(_T("End Processing"));
  }
  catch(CICVWException* e)
  {
    bstrRet = BEGIN_ERROR_XML;
    bstrRet += e->m_strErr;
    //Reset(NULL);
    bHasErrors = true;
    e->Delete();
  }
  catch(...)
  {
    bstrRet = BEGIN_ERROR_XML;
    bstrRet += _T("Unhandled exception");
    bHasErrors = true;
  }

  if( m_bReturnTimings )
  {
    ADD_TIMING(_T("End CalculateTaxes"));
    bstrRet += ReportTimings();
    DELETE_TIMINGS;
  }

  if( !bHasErrors )
    bstrRet += END_SUCCESS_XML;
  else
    bstrRet += END_ERROR_XML;

  *bstrResults = bstrRet.Copy();

  END_PROC("CalculateTaxes");
  return S_OK;
}

 STDAPI CVertexCtrl::get_sReturnTimings(SHORT* pVal)
{
  AFX_MANAGE_STATE(AfxGetStaticModuleState());

  *pVal = m_bReturnTimings;

  return S_OK;
}

STDAPI CVertexCtrl::put_sReturnTimings(SHORT newVal)
{
  AFX_MANAGE_STATE(AfxGetStaticModuleState());

  m_bReturnTimings = newVal == 0 ? false : true;

  return S_OK;
}

STDAPI CVertexCtrl::LookupGeoCode(BSTR bstrXMLParams, BSTR* bstrResults)
{
  BEGIN_PROC("LookupGeoCode");
  AFX_MANAGE_STATE(AfxGetStaticModuleState());

  ADD_TIMING(_T("Begin LookupGeoCode"));

  CComBSTR bstrRet;
  bstrRet = BEGIN_SUCCESS_XML;
  bool bHasErrors = false;

  try
  {
    if(!m_bInitialized)
    {
      CString strErr = _T("The object is not initialized correctly.");
      END_PROC("LookupGeoCode");
      throw new CICVWException(strErr);
    }

    CComBSTR bstrXML(bstrXMLParams);
    ADD_TIMING(_T("Begin Processing"));

    tCtqHandle lLocHandle = NULL;

    /* Obtain the Location object handle. */
    tCtqResultCode lRC = eCtqResultSuccess;
    TRACER("Call CtqGetAttrib");
    lRC = CtqGetAttrib(m_lCtqRootHandle,
      eCtqHandleLoc,
      &lLocHandle,
      eCtqHandle,
      sizeof(lLocHandle));
    TRACER("Ret CtqGetAttrib");
    if (eCtqResultSuccess != lRC)
    {
      CString strErr = _T("Unable to retrieve Location object handle: ");
      strErr += VertexErrorString(lRC);
      END_PROC("LookupGeoCode");
      throw new CICVWException(strErr);
    }

    /* Reset location information. */
    TRACER("Call CtqResetAttribs");
    lRC = CtqResetAttribs(lLocHandle);
    TRACER("Ret CtqResetAttribs");
    if (eCtqResultSuccess != lRC)
    {
      CString strErr = _T("Unable to reset Location object attributes: ");
      strErr += VertexErrorString(lRC);
      END_PROC("LookupGeoCode");
      throw new CICVWException(strErr);
    }

    SetLookupVertexParams(lLocHandle, bstrXML);
    ADD_TIMING(_T("SetVertexParams Done"));

    TRACER("Call CtqInquireLocations");
    lRC = CtqInquireLocations(lLocHandle);
    TRACER("Ret CtqInquireLocations");
    if (eCtqResultSuccess != lRC)
    {
      CString strErr = _T("Unable to perform the lookup: ");
      strErr += VertexErrorString(lRC);
      END_PROC("LookupGeoCode");
      throw new CICVWException(strErr);
    }
    ADD_TIMING(_T("CtqCalculateTax Done"));

    bstrRet += GetLookupVertexResults(lLocHandle);
    ADD_TIMING(_T("GetVertexResults Done"));

    ADD_TIMING(_T("End Processing"));
  }
  catch(CICVWException* e)
  {
    bstrRet = BEGIN_ERROR_XML;
    bstrRet += e->m_strErr;
    //Reset(NULL);
    bHasErrors = true;
    e->Delete();
  }
  catch(...)
  {
    bstrRet = BEGIN_ERROR_XML;
    bstrRet += _T("Unhandled exception");
    bHasErrors = true;
  }

  if( m_bReturnTimings )
  {
    ADD_TIMING(_T("End LookupGeoCode"));
    bstrRet += ReportTimings();
    DELETE_TIMINGS;
  }

  if( !bHasErrors )
    bstrRet += END_SUCCESS_XML;
  else
    bstrRet += END_ERROR_XML;

  *bstrResults = bstrRet.Copy();

  END_PROC("LookupGeoCode");
  return S_OK;
}

STDAPI CVertexCtrl::get_iWriteToJournal(LONG* pVal)
{
  AFX_MANAGE_STATE(AfxGetStaticModuleState());

  *pVal = m_bWriteToJournal;

  return S_OK;
}

STDAPI CVertexCtrl::put_iWriteToJournal(LONG newVal)
{
  AFX_MANAGE_STATE(AfxGetStaticModuleState());

  m_bWriteToJournal = newVal;

  return S_OK;
}