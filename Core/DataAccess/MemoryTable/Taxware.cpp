#include "metra.h"
#include "Taxware.h"
#include "LogAdapter.h"
#include "SEHException.h"
#include "OperatorArg.h"
#include <iostream>

//#include <tax010.h>
// typedef struct tagTaxParm {
// } TaxParm;

// typedef struct tagJurParm {
// } JurParm;

// typedef struct tagAuditRecData {
// } AuditRecData;

#include <taxset.h>
#include <taxio.h>
#include <taxioseq.h>
#include <taxiodb.h>
#include <tax010.h>
#include <wtcons.h>
#include <comapi.h>
#include <zipset.h>
#include <zip020.h>

#include <boost/thread/mutex.hpp>
#include <boost/format.hpp>


/**
 * A Taxware integer field.  These must be stored using ASCII characters
 * and are right justfied and padded with zeros on the left.
 */
class TaxwareIntegerBinding 
{
private:
  boost::int32_t mOffset;
  boost::int32_t mLength;
public:
  TaxwareIntegerBinding(boost::int32_t offset, boost::int32_t length)
    :
    mOffset(offset),
    mLength(length)
  {
  }

  void Set(char * outputBuffer, boost::int32_t value)
  {
    static char conversion [] = "0123456789";
    char * outputBufferIt = outputBuffer + mOffset;
    char * outputBufferEnd = outputBufferIt + mLength;
    while (value != 0 && outputBufferIt != outputBufferEnd)
    {
      *((char*)outputBufferIt) = conversion[value % 10];
      outputBufferIt += 1;
      value /= 10;
    }

    // We have an overflow.
    if (value != 0) 
      throw std::runtime_error("Taxware export overflow");

    // Pad with 0's if necessary
    while (outputBufferIt != outputBufferEnd)
    {
      *((char*)outputBufferIt) = '0';
      outputBufferIt += 1;
    }

    // Reverse the digits.
    std::reverse(outputBuffer + mOffset, outputBufferEnd);    
  }
};

/**
 * A Taxware String field.  These must be stored using ASCII characters
 * and are left justfied and padded with spaces on the right.
 */
class TaxwareStringBinding 
{
private:
  boost::int32_t mOffset;
  boost::int32_t mLength;
public:
  TaxwareStringBinding(boost::int32_t offset, boost::int32_t length)
    :
    mOffset(offset),
    mLength(length)
  {
  }

  void Set(char * outputBuffer, const char * value)
  {
    boost::int32_t l = strlen(value);
    if (l > mLength)
      throw std::runtime_error("Taxware export overflow");

    memcpy(outputBuffer + mOffset, value, l);
    if (l < mLength)
      memset(outputBuffer + mOffset + l, ' ', mLength - l);
  }
};

static boost::mutex sLoadLock;
TaxwareUniversalTaxLink * TaxwareUniversalTaxLink::sInstance=NULL;
boost::int32_t TaxwareUniversalTaxLink::sRefCount=0;

TaxwareUniversalTaxLink* TaxwareUniversalTaxLink::GetInstance()
{
  boost::mutex::scoped_lock sl(sLoadLock);
  if (sRefCount == 0)
  {
    sInstance = new TaxwareUniversalTaxLink();
  }

  sRefCount += 1;
  return sInstance;
}

void TaxwareUniversalTaxLink::ReleaseInstance(TaxwareUniversalTaxLink*  utl)
{
  boost::mutex::scoped_lock sl(sLoadLock);
  if (--sRefCount == 0)
  {
    delete utl;
    sInstance = NULL;
  }
}

TaxwareUniversalTaxLink::TaxwareUniversalTaxLink()
  :
  mModule(NULL),
  mVeraZipModule(NULL),
  mCapiTaxRoutine(NULL),
  mZIP020(NULL)
{
  mLogger = MetraFlowLoggerManager::GetLogger("[Taxware]");

  mModule = ::LoadLibrary(L"taxcommono.dll");
  if(mModule == NULL)
  {
    DWORD dwErr = ::GetLastError();

    throw std::runtime_error("Failure loading Taxware UTL library.  Please check PATH and verify that Taxware installation is on it");
  }

  mVeraZipModule = ::LoadLibrary(L"avpzip.dll");
  if(mModule == NULL)
  {
    DWORD dwErr = ::GetLastError();

    throw std::runtime_error("Failure loading Taxware VeraZip library.  Please check PATH and verify that Taxware installation is on it");
  }

  mCapiTaxRoutine = (CAPITAXROUTINEPROC) ::GetProcAddress(mModule, "CapiTaxRoutine");
  if (mCapiTaxRoutine == NULL)
  {
    DWORD dwErr = ::GetLastError();

    throw std::runtime_error("Failure locating Taxware CapiTaxRoutine function in Taxware UTL library.  Please check PATH and verify that Taxware installation is on it");
  }

  mZIP020 = (ZIP020PROC) ::GetProcAddress(mVeraZipModule, "ZIP020");
  if (mZIP020 == NULL)
  {
    DWORD dwErr = ::GetLastError();

    throw std::runtime_error("Failure locating Taxware ZIP020 function in Taxware VeraZip library.  Please check PATH and verify that Taxware installation is on it");
  }
  mZipOpen = (ZIPOPENPROC) ::GetProcAddress(mVeraZipModule, "ZIPOPEN");
  if (mZipOpen == NULL)
  {
    DWORD dwErr = ::GetLastError();

    throw std::runtime_error("Failure locating Taxware ZipOpen function in Taxware VeraZip library.  Please check PATH and verify that Taxware installation is on it");
  }
  mZipClose = (ZIPCLOSEPROC) ::GetProcAddress(mVeraZipModule, "ZIPCLOSE");
  if (mZipClose == NULL)
  {
    DWORD dwErr = ::GetLastError();

    throw std::runtime_error("Failure locating Taxware ZipClose function in Taxware VeraZip library.  Please check PATH and verify that Taxware installation is on it");
  }
  mVerifyZip = (VERIFYZIPPROC) ::GetProcAddress(mVeraZipModule, "VERIFY_ZIP");
  if (mVerifyZip == NULL)
  {
    DWORD dwErr = ::GetLastError();

    throw std::runtime_error("Failure locating Taxware Verify_Zip function in Taxware VeraZip library.  Please check PATH and verify that Taxware installation is on it");
  }

  // Call Taxware to load the tax rules file.
  std::string taxinheader(CAPIINBUFFERSIZE, ' ');
  TaxwareIntegerBinding numRecordsIn(NUMBERINRECORDSPOS, 6);
  numRecordsIn.Set(&taxinheader[0], 0);
  TaxwareIntegerBinding processingIndicator(OPENCLOSEPROCESSINDPOS, 1);  
  processingIndicator.Set(&taxinheader[0], OPEN_ALL_FILES-'0');
  std::string taxoutheader(CAPIOUTBUFFERSIZE, ' ');
  int ret = TaxRoutine(&taxinheader[0], &taxoutheader[0], CAPICOMMONINDATASIZE);
  boost::shared_ptr<ZIP020_Parm> parm(new ZIP020_Parm);
  memset(parm.get(), ' ', sizeof(ZIP020_Parm));
  parm->Action = OPENALL;
  mZIP020(parm.get());
  int completionCode = parm->Output.ComplCode;
  if (completionCode > SUCCESSCC && completionCode <= STZIPCITYNF)
  {
    throw std::runtime_error("Failed opening VeraZip Zip Master and County Master files."); 
  }
}

TaxwareUniversalTaxLink::~TaxwareUniversalTaxLink()
{
  if (mModule != NULL)
  {
    if (mCapiTaxRoutine)
    {
      // Call Taxware to unload the tax rules file.
      std::string taxinheader(CAPIINBUFFERSIZE, ' ');
      TaxwareIntegerBinding numRecordsIn(NUMBERINRECORDSPOS, 6);
      numRecordsIn.Set(&taxinheader[0], 0);
      TaxwareIntegerBinding processingIndicator(OPENCLOSEPROCESSINDPOS, 1);  
      processingIndicator.Set(&taxinheader[0], CLOSE_ALL_FILES-'0');
      std::string taxoutheader(CAPIOUTBUFFERSIZE, ' ');
      int ret = TaxRoutine(&taxinheader[0], &taxoutheader[0], CAPICOMMONINDATASIZE); 
    }
    ::FreeLibrary(mModule);
  }

  if (mVeraZipModule != NULL)
  {
    if (mZipClose!= NULL)
    {
      mZipClose();
    }
    ::FreeLibrary(mVeraZipModule);
  }
}

int TaxwareUniversalTaxLink::TaxRoutine(char * taxinbuffer, char * taxoutbuffer, int length)
{
  return mCapiTaxRoutine(taxinbuffer, taxoutbuffer, length);
}
/**
 * Simply calls ZIP020
 */
int TaxwareUniversalTaxLink::VerifyZip(char * stateCode, char * zipCode, char * cityCode)
{
  try
  {
    ZIP020_Parm parm;
    memset(&parm, ' ', sizeof(parm));
    parm.Action = PROCESS;
    if (2 != strlen(stateCode))
      return 16;
    parm.Input.StateCode[0] = stateCode[0];
    parm.Input.StateCode[1] = stateCode[1];


    // Strip out any formatting characters from zip.

    int zipLength = strlen(zipCode);

    if (zipLength == 5)
    {
      parm.Input.ZipCode[0] = zipCode[0];
      parm.Input.ZipCode[1] = zipCode[1];
      parm.Input.ZipCode[2] = zipCode[2];
      parm.Input.ZipCode[3] = zipCode[3];
      parm.Input.ZipCode[4] = zipCode[4];
    } else if (zipLength == 6)
    {
      parm.Input.ZipCode[0] = zipCode[0];
      parm.Input.ZipCode[1] = zipCode[1];
      parm.Input.ZipCode[2] = zipCode[2];
      parm.Input.ZipCode[3] = zipCode[3];
      parm.Input.ZipCode[4] = zipCode[4];
      parm.Input.ZipExt[0] = zipCode[5];
    }
    else if (zipLength==9)
    {
      parm.Input.ZipCode[0] = zipCode[0];
      parm.Input.ZipCode[1] = zipCode[1];
      parm.Input.ZipCode[2] = zipCode[2];
      parm.Input.ZipCode[3] = zipCode[3];
      parm.Input.ZipCode[4] = zipCode[4];
      parm.Input.ZipExt[0] = zipCode[5];
      parm.Input.ZipExt[1] = zipCode[6];
      parm.Input.ZipExt[2] = zipCode[7];
      parm.Input.ZipExt[3] = zipCode[8];
    }
    else
    {
      return 16;
    }
    // City length no more than 26 characters.
    int cityLen = strlen(cityCode);
    memcpy(parm.Input.CityName, cityCode, cityLen < 26 ? cityLen : 26);

    int ret = mZIP020(&parm);
    int complCode = parm.Output.ComplCode;

    if (complCode != 0 && mLogger->isOkToLogDebug())
    {
      for (int i=0; i<10; i++)
      {
        LinkTable & l(parm.Output.Link_Table[i]);

        // Empty state code means we have hit the end of the link table.
        if(l.StateCode[0] == ' ' && l.StateCode[1] == ' ')
          break;

        mLogger->logDebug((boost::format("State:%1%; Zip1:%2%; Zip2:%3%; Geo:%4%; ZipExt1:%5%; ZipExt2:%6%; CityName:%7%; CntyCode:%8%; CntyName:%9%")
                           % std::string(l.StateCode,STATECODESIZE) % std::string(l.Zip1,ZIPCODESIZE) % std::string(l.Zip2,ZIPCODESIZE) % std::string(l.Geo, GEOCODESIZE) % std::string(l.ZipExt1, ZIPEXTSIZE) % std::string(l.ZipExt2, ZIPEXTSIZE) % std::string(l.CityName, LOCNAMESIZE) % std::string(l.CntyCode, CNTYCODESIZE) % std::string(l.CntyName, LOCNAMESIZE)).str());
      }
    }
    return complCode;
  }
  catch(FatalSystemErrorException& fsee)
  {
    mLogger->logError((boost::format("Unhandled exception in VerifyZip: %1%; stateCode=%2%; zipCode=%3%; cityCode=%4%\nCall Stack: %5%") % 
                       fsee.what() %
                       stateCode %
                       zipCode %
                       cityCode %
                       fsee.callStack()).str());
    // Use an invalid Taxware error code to let the user know that we are in deep trouble.
    return std::numeric_limits<int>::max();
  }
  catch(std::exception& e)
  {
    mLogger->logError((boost::format("Unhandled exception in VerifyZip: %1%; stateCode=%2%; zipCode=%3%; cityCode=%4%") % 
                       e.what() %
                       stateCode %
                       zipCode %
                       cityCode).str());
    return 16;
  }
  catch(...)
  {
    mLogger->logError((boost::format("Unhandled unknown exception in VerifyZip; stateCode=%1%; zipCode=%2%; cityCode=%3%") %
                       stateCode %
                       zipCode %
                       cityCode).str());
    return 16;
  }
}

DesignTimeTaxware::DesignTimeTaxware()
  :
  mOutputMetadata(NULL),
  mOutputMerger(NULL),
  mErrorMetadata(NULL),
  mErrorMerger(NULL)
{
  mInputPorts.insert(this, 0, L"input", false);
  mOutputPorts.insert(this, 0, L"output", false);
  mOutputPorts.insert(this, 1, L"error", false);

  //
  // Put all of the Taxware binding info into a hash table to support
  // metaprogramming on the property list.
  //
  mBindings.insert(std::make_pair(L"systemIndicator", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::INTEGER, SYSTEMINDPOS, 1)));
  mBindings.insert(std::make_pair(L"companyID", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, COMPANYIDPOS, 20)));
  //ShipFrom
  mBindings.insert(std::make_pair(L"shipFromCountryCode", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, SHIPFROMCOUNTRYPOS, 3)));
  mBindings.insert(std::make_pair(L"shipFromTerritory", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, SHIPFROMTERRITORYPOS, 3)));
  mBindings.insert(std::make_pair(L"shipFromProvinceCode", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, SHIPFROMPROVINCEPOS, 26)));
  mBindings.insert(std::make_pair(L"shipFromCounty", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, SHIPFROMCOUNTYNAMEPOS, 26)));
  mBindings.insert(std::make_pair(L"shipFromCountyCode", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, SHIPFROMCOUNTYCODEPOS, 3)));
  mBindings.insert(std::make_pair(L"shipFromCity", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, SHIPFROMCITYPOS, 26)));
  mBindings.insert(std::make_pair(L"shipFromPostalCode", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, SHIPFROMPOSTALCODEPOS, 9)));
  mBindings.insert(std::make_pair(L"shipFromZipExtension", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, SHIPFROMZIPEXTPOS, 4)));
  //Destination/ShipTo
  mBindings.insert(std::make_pair(L"destinationCountryCode", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, DSTCOUNTRYPOS, 3)));
  mBindings.insert(std::make_pair(L"destinationTerritory", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, DSTTERRITORYPOS, 3)));
  mBindings.insert(std::make_pair(L"destinationProvinceCode", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, DSTPROVINCEPOS, 26)));
  mBindings.insert(std::make_pair(L"destinationCounty", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, DSTCOUNTYNAMEPOS, 26)));
  mBindings.insert(std::make_pair(L"destinationCountyCode", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, DSTCOUNTYCODEPOS, 3)));
  mBindings.insert(std::make_pair(L"destinationCity", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, DSTCITYPOS, 26)));
  mBindings.insert(std::make_pair(L"destinationPostalCode", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, DSTPOSTALCODEPOS, 9)));
  mBindings.insert(std::make_pair(L"destinationZipExtension", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, DSTZIPEXTPOS, 4)));
  //Origin/POO
  mBindings.insert(std::make_pair(L"pooCountryCode", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, ORGNCOUNTRYPOS, 3)));
  mBindings.insert(std::make_pair(L"pooTerritory", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, ORGNTERRITORYPOS, 3)));
  mBindings.insert(std::make_pair(L"pooProvinceCode", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, ORGNPROVINCEPOS, 26)));
  mBindings.insert(std::make_pair(L"pooCounty", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, ORGNCOUNTYNAMEPOS, 26)));
  mBindings.insert(std::make_pair(L"pooCountyCode", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, ORGNCOUNTYCODEPOS, 3)));
  mBindings.insert(std::make_pair(L"pooCity", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, ORGNCITYPOS, 26)));
  mBindings.insert(std::make_pair(L"pooPostalCode", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, ORGNPOSTALCODEPOS, 9)));
  mBindings.insert(std::make_pair(L"pooZipExtension", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, ORGNZIPEXTPOS, 4)));
  //Point of acceptance
  mBindings.insert(std::make_pair(L"poaCountryCode", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, POACOUNTRYPOS, 3)));
  mBindings.insert(std::make_pair(L"poaTerritory", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, POATERRITORYPOS, 3)));
  mBindings.insert(std::make_pair(L"poaProvinceCode", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, POAPROVINCEPOS, 26)));
  mBindings.insert(std::make_pair(L"poaCounty", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, POACOUNTYNAMEPOS, 26)));
  mBindings.insert(std::make_pair(L"poaCountyCode", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, POACOUNTYCODEPOS, 3)));
  mBindings.insert(std::make_pair(L"poaCity", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, POACITYPOS, 26)));
  mBindings.insert(std::make_pair(L"poaPostalCode", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, POAPOSTALCODEPOS, 9)));
  mBindings.insert(std::make_pair(L"poaZipExtension", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, POAZIPEXTPOS, 4)));  

  mBindings.insert(std::make_pair(L"pointOfTitlePassage", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, POTPOS, 1)));
  mBindings.insert(std::make_pair(L"taxingLocation", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, TAXINGLOCPOS, 1)));
  mBindings.insert(std::make_pair(L"calculationMode", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, CALCULATIONMODEPOS, 1)));
  mBindings.insert(std::make_pair(L"transactionType", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, TRANSACTIONTYPEPOS, 1)));
  mBindings.insert(std::make_pair(L"worldTaxCode", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, WTAXCODEPOS, 2)));
  mBindings.insert(std::make_pair(L"taxType", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, TAXTYPEPOS, 1)));
  mBindings.insert(std::make_pair(L"taxPoint", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::DATE, TAXPNTPOS, 8)));
  mBindings.insert(std::make_pair(L"deliveryDate", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::DATE, DELIVERYDATEPOS, 8)));
  mBindings.insert(std::make_pair(L"modeOfTransport", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, MODEOFTRANSPORTPOS, 2)));
  mBindings.insert(std::make_pair(L"commodityCode", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, COMMODCODEPOS, 25)));
  mBindings.insert(std::make_pair(L"creditIndicator", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, CREDITINDICATORPOS, 1)));
  mBindings.insert(std::make_pair(L"countryExemptionReasonCode", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, COUNTRYREASONCODEPOS, 2)));
  mBindings.insert(std::make_pair(L"provinceExemptionReasonCode", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, PROVINCEREASONCODEPOS, 2)));
  mBindings.insert(std::make_pair(L"countyExemptionReasonCode", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, COUNTYREASONCODEPOS, 2)));
  mBindings.insert(std::make_pair(L"cityExemptionReasonCode", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, CITYREASONCODEPOS, 2)));
  mBindings.insert(std::make_pair(L"countryTaxCertificateNumber", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, COUNTRYTAXCERTNOPOS, 25)));
  mBindings.insert(std::make_pair(L"provinceTaxCertificateNumber", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, PROVINCETAXCERTNOPOS, 25)));
  mBindings.insert(std::make_pair(L"countyTaxCertificateNumber", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, COUNTYTAXCERTNOPOS, 25)));
  mBindings.insert(std::make_pair(L"cityTaxCertificateNumber", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, CITYTAXCERTNOPOS, 25)));
  mBindings.insert(std::make_pair(L"exemptAll", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, EXMPTALLPOS, 1)));
  mBindings.insert(std::make_pair(L"exemptCountry", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, EXMPTCOUNTRYPOS, 1)));
  mBindings.insert(std::make_pair(L"exemptTerritory", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, EXMPTTERRITORYPOS, 1)));
  mBindings.insert(std::make_pair(L"exemptProvince", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, EXMPTPROVINCEPOS, 1)));
  mBindings.insert(std::make_pair(L"exemptCounty", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, EXMPTCOUNTYPOS, 1)));
  mBindings.insert(std::make_pair(L"exemptCity", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, EXMPTCITYPOS, 1)));
  mBindings.insert(std::make_pair(L"documentNumber", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, DOCUMENTNUMBERPOS, 20)));
  mBindings.insert(std::make_pair(L"currencyCode", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, CURRENCYCODE1POS, 3)));
  mBindings.insert(std::make_pair(L"secondaryCurrencyCode", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, CURRENCYCODE2POS, 3)));
  mBindings.insert(std::make_pair(L"accountingReference", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, ACCTREFPOS, 15)));
  mBindings.insert(std::make_pair(L"originalDocumentNumber", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, ORIGINDOCNUMPOS, 20)));
  mBindings.insert(std::make_pair(L"documentType", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, DOCTYPEPOS, 2)));
  mBindings.insert(std::make_pair(L"sellerRegistrationNumber", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, SELLERREGNUMPOS, 25)));
  mBindings.insert(std::make_pair(L"buyerRegistrationNumber", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, BUYERREGNUMPOS, 25)));
  mBindings.insert(std::make_pair(L"agentRegistrationNumber", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, AGENTREGNUMPOS, 25)));

  mBindings.insert(std::make_pair(L"lineItemAmount", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::BIGINTEGER, LINEITEMAMTPOS, 14)));
  mBindings.insert(std::make_pair(L"taxAmount", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::BIGINTEGER, TAXAMTPOS, 14)));
  mBindings.insert(std::make_pair(L"discountAmount", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::BIGINTEGER, DISCOUNTAMTPOS, 14)));
  mBindings.insert(std::make_pair(L"freightAmount", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::BIGINTEGER, FRGHTAMTPOS, 14)));
  mBindings.insert(std::make_pair(L"insuranceAmountLocal", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::BIGINTEGER, INSURANCEAMTLOCALPOS, 14)));
  mBindings.insert(std::make_pair(L"countryExemptionAmount", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::BIGINTEGER, COUNTRYEXEMPTAMTPOS, 14)));
  mBindings.insert(std::make_pair(L"territoryExemptionAmount", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::BIGINTEGER, TERRITORYEXEMPTAMTPOS, 14)));
  mBindings.insert(std::make_pair(L"provinceExemptionAmount", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::BIGINTEGER, PROVINCEEXEMPTAMTPOS, 14)));
  mBindings.insert(std::make_pair(L"countyExemptionAmount", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::BIGINTEGER, COUNTYEXEMPTAMTPOS, 14)));
  mBindings.insert(std::make_pair(L"cityExemptionAmount", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::BIGINTEGER, CITYEXEMPTAMTPOS, 14)));
  mBindings.insert(std::make_pair(L"districtExemptionAmount", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::BIGINTEGER, DISTEXEMPTAMTPOS, 14)));
  mBindings.insert(std::make_pair(L"secondaryProvinceExemptionAmount", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::BIGINTEGER, SECPROVINEXEMPTAMTPOS, 14)));
  mBindings.insert(std::make_pair(L"secondaryCountyExemptionAmount", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::BIGINTEGER, SECCOUNTYEXEMPTAMTPOS, 14)));
  mBindings.insert(std::make_pair(L"secondaryCityExemptionAmount", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::BIGINTEGER, SECCITYEXEMPTAMTPOS, 14)));
  mBindings.insert(std::make_pair(L"insuranceAmountForeign", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::BIGINTEGER, INSAMTFOREIGNPOS, 14)));
  mBindings.insert(std::make_pair(L"shippingAmountForeign", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::BIGINTEGER, SHIPAMTFOREIGNPOS, 14)));
  mBindings.insert(std::make_pair(L"contractAmount", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::BIGINTEGER, CONTRACTAMTPOS, 14)));
  mBindings.insert(std::make_pair(L"installAmount", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::BIGINTEGER, INSTALLAMTPOS, 14)));
  // Tax Sel Parm 
  // 1 = Jurisdiction determination only
  // 2 (or space) = Calculation only
  // 3 = Jurisdiction determination + calculation
  mBindings.insert(std::make_pair(L"taxSelParm", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::INTEGER, TAXSELPARMPOS, 1)));


  // Outputs
  mOutputBindings.insert(std::make_pair(L"calculatedAmountCountry", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::BIGINTEGER, CALCAMTCOUNTRYPOS, 14)));
  mOutputBindings.insert(std::make_pair(L"calculatedAmountTerritory", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::BIGINTEGER, CALCAMTTERRITORYPOS, 14)));
  mOutputBindings.insert(std::make_pair(L"calculatedAmountProvince", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::BIGINTEGER, CALCAMTPROVINCEPOS, 14)));
  mOutputBindings.insert(std::make_pair(L"calculatedAmountCounty", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::BIGINTEGER, CALCAMTCOUNTYPOS, 14)));
  mOutputBindings.insert(std::make_pair(L"calculatedAmountCity", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::BIGINTEGER, CALCAMTCITYPOS, 14)));
  mOutputBindings.insert(std::make_pair(L"secondaryAmountProvince", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::BIGINTEGER, SECPROVINCETXAMTPOS, 14)));
  mOutputBindings.insert(std::make_pair(L"secondaryAmountCounty", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::BIGINTEGER, SECCOUNTYTXAMTPOS, 14)));
  mOutputBindings.insert(std::make_pair(L"secondaryAmountCity", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::BIGINTEGER, SECCITYTXAMTPOS, 14)));
  mOutputBindings.insert(std::make_pair(L"calculatedAmountDistrict", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::BIGINTEGER, DISTTXAMTPOS, 14)));
  // Errors
  mErrorBindings.insert(std::make_pair(L"generalCompletionCode", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, GENCMPLCDPOS, 4)));
  mErrorBindings.insert(std::make_pair(L"generalCompletionCodeDescription", DesignTimeTaxwareBinding(DesignTimeTaxwareBinding::STRING, GENCMPLCDDSCPOS, 200)));
}

DesignTimeTaxware::~DesignTimeTaxware()
{
  delete mOutputMetadata;
  delete mOutputMerger;
  delete mErrorMetadata;
  delete mErrorMerger;
}

void DesignTimeTaxware::handleArg(const OperatorArg& arg)
{
  if (IsTaxwareBinding(arg.getName()))
  {
    if (arg.getType() != OPERATOR_ARG_TYPE_STRING)
    {
      throw DataflowInvalidArgumentValueException(
                arg.getValueLine(),
                arg.getValueColumn(),
                arg.getFilename(),
                GetName(),
                arg.getName(),
                L"",
                L"Expected a string.");
    }
    SetTaxwareBinding(arg.getName(), arg.getNormalizedString());
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeTaxware* DesignTimeTaxware::clone(
                                        const std::wstring& name,
                                        std::vector<OperatorArg *>& args, 
                                        int nInputs, int nOutputs) const
{
  DesignTimeTaxware* result = new DesignTimeTaxware();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeTaxware::type_check()
{
  // Make sure every input exists and is of the appropriate type.
  for(std::map<std::wstring, DesignTimeTaxwareBinding>::const_iterator it = mBindings.begin();
      it != mBindings.end();
      ++it)
  {
    if (it->second.GetName().size() == 0) continue;

    if (!mInputPorts[0]->GetMetadata()->HasColumn(it->second.GetName()))
    {
      throw MissingFieldException(*this, *mInputPorts[0], it->second.GetName());
    }

    DatabaseColumn * col = mInputPorts[0]->GetMetadata()->GetColumn(it->second.GetName());

    switch(it->second.GetType())
    {
    case DesignTimeTaxwareBinding::STRING:
      if (col->GetColumnType() != MTPipelineLib::PROP_TYPE_ASCII_STRING)
        throw FieldTypeException(*this, *mInputPorts[0], *col, PhysicalFieldType::UTF8StringDomain());
      break;
    case DesignTimeTaxwareBinding::INTEGER:
      if (col->GetColumnType() != MTPipelineLib::PROP_TYPE_INTEGER)
        throw FieldTypeException(*this, *mInputPorts[0], *col, PhysicalFieldType::Integer());
      break;
    case DesignTimeTaxwareBinding::BIGINTEGER:
      if (col->GetColumnType() != MTPipelineLib::PROP_TYPE_BIGINTEGER)
        throw FieldTypeException(*this, *mInputPorts[0], *col, PhysicalFieldType::BigInteger());
      break;
    case DesignTimeTaxwareBinding::DATE:
      if (col->GetColumnType() != MTPipelineLib::PROP_TYPE_DATETIME)
        throw FieldTypeException(*this, *mInputPorts[0], *col, PhysicalFieldType::Datetime());
      break;
    }
  }

  // Take a look at all of the output bindings and create the merged output.  Do the same for the error bindings.
  // Send all of the bindings that were set by the user.
  LogicalRecord outputMembers;
  for(std::map<std::wstring, DesignTimeTaxwareBinding>::const_iterator it = mOutputBindings.begin();
      it != mOutputBindings.end();
      ++it)
  {
    if(it->second.GetName().size() > 0)
    {
      outputMembers.push_back(RecordMember(it->second.GetName(), 
                                           LogicalFieldType::BigInteger(true)));
    }
  }
  mOutputMetadata = new RecordMetadata(outputMembers);
  mOutputMerger = new RecordMerge(mInputPorts[0]->GetMetadata(), mOutputMetadata); 

  LogicalRecord errorMembers;
  for(std::map<std::wstring, DesignTimeTaxwareBinding>::const_iterator it = mErrorBindings.begin();
      it != mErrorBindings.end();
      ++it)
  {
    if(it->second.GetName().size() > 0)
    {
      errorMembers.push_back(RecordMember(it->second.GetName(), 
                                          LogicalFieldType::UTF8String(true)));
    }
  }
  mErrorMetadata = new RecordMetadata(errorMembers);
  mErrorMerger = new RecordMerge(mInputPorts[0]->GetMetadata(), mErrorMetadata); 

  mOutputPorts[0]->SetMetadata(new RecordMetadata(*mOutputMerger->GetRecordMetadata()));
  mOutputPorts[1]->SetMetadata(new RecordMetadata(*mErrorMerger->GetRecordMetadata()));
}

RunTimeOperator * DesignTimeTaxware::code_generate(partition_t maxPartition)
{
  std::vector<DesignTimeTaxwareBinding> bindings;

  // Send all of the bindings that were set by the user.
  for(std::map<std::wstring, DesignTimeTaxwareBinding>::const_iterator it = mBindings.begin();
      it != mBindings.end();
      ++it)
  {
    if(it->second.GetName().size() > 0)
    {
      bindings.push_back(it->second);
    }
  }

  // Desired outputs
  std::vector<DesignTimeTaxwareBinding> outputBindings;

  // Send all of the bindings that were set by the user.
  for(std::map<std::wstring, DesignTimeTaxwareBinding>::const_iterator it = mOutputBindings.begin();
      it != mOutputBindings.end();
      ++it)
  {
    if(it->second.GetName().size() > 0)
    {
      outputBindings.push_back(it->second);
    }
  }

  // Desired errors
  std::vector<DesignTimeTaxwareBinding> errorBindings;

  // Send all of the bindings that were set by the user.
  for(std::map<std::wstring, DesignTimeTaxwareBinding>::const_iterator it = mErrorBindings.begin();
      it != mErrorBindings.end();
      ++it)
  {
    if(it->second.GetName().size() > 0)
    {
      errorBindings.push_back(it->second);
    }
  }

  return new RunTimeTaxware(GetName(), 
                            *mInputPorts[0]->GetMetadata(), 
                            *mOutputPorts[0]->GetMetadata(), 
                            *mOutputMerger,
                            *mOutputPorts[1]->GetMetadata(), 
                            *mErrorMerger,
                            bindings,
                            outputBindings,
                            errorBindings);
}

bool DesignTimeTaxware::IsTaxwareBinding(const std::wstring& taxwareName) const
{
  std::map<std::wstring, DesignTimeTaxwareBinding>::const_iterator it = mBindings.find(taxwareName);
  if (it != mBindings.end())
  {
    return true;
  }
  it = mOutputBindings.find(taxwareName);
  if (it != mOutputBindings.end())
  {
    return true;
  }
  it = mErrorBindings.find(taxwareName);
  if (it != mErrorBindings.end())
  {
    return true;
  }
  return false;
}

void DesignTimeTaxware::SetTaxwareBinding(const std::wstring& taxwareName, const std::wstring& metraFlowName)
{
  std::map<std::wstring, DesignTimeTaxwareBinding>::iterator it = mBindings.find(taxwareName);
  if (it != mBindings.end())
  {
    it->second.SetName(metraFlowName);
    return;
  }
  it = mOutputBindings.find(taxwareName);
  if (it != mOutputBindings.end())
  {
    it->second.SetName(metraFlowName);
    return;
  }
  it = mErrorBindings.find(taxwareName);
  if (it != mErrorBindings.end())
  {
    it->second.SetName(metraFlowName);
    return;
  }

  throw SingleOperatorException(*this,
                                (boost::wformat(L"Unsupported Taxware parameter %1%") % taxwareName).str());
}

void DesignTimeTaxware::SetProductCode(const std::wstring& productCode)
{
  mProductCode = productCode;
}

RunTimeTaxware::RunTimeTaxware (const std::wstring& name, 
                                const RecordMetadata& metadata,
                                const RecordMetadata& outputMetadata,
                                const RecordMerge& outputMerger,
                                const RecordMetadata& errorMetadata,
                                const RecordMerge& errorMerger,
                                const std::vector<DesignTimeTaxwareBinding>& designTimeBindings,
                                const std::vector<DesignTimeTaxwareBinding>& designTimeOutputBindings,
                                const std::vector<DesignTimeTaxwareBinding>& designTimeErrorBindings)
  :
  RunTimeOperator(name),
  mMetadata(metadata),
  mOutputMetadata(outputMetadata),
  mOutputMerger(outputMerger),
  mErrorMetadata(errorMetadata),
  mErrorMerger(errorMerger),
  mDesignTimeBindings(designTimeBindings),
  mDesignTimeOutputBindings(designTimeOutputBindings),
  mDesignTimeErrorBindings(designTimeErrorBindings)
{
}

RunTimeTaxware::~RunTimeTaxware()
{
}
  
RunTimeOperatorActivation * RunTimeTaxware::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeTaxwareActivation(reactor, partition, this);
}

RunTimeTaxwareActivation::RunTimeTaxwareActivation (Reactor * reactor, 
                                                    partition_t partition,
                                                    const RunTimeTaxware * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeTaxware>(reactor, partition, runTimeOperator),
  mUTL(NULL),
  mInBuffer(NULL),
  mOutBuffer(NULL),
  mInputMessage(NULL),
  mOutputMessage(NULL),
  mErrorMessage(NULL),
  mOutputBuffer(NULL),
  mErrorBuffer(NULL),
  mState(START),
  mReturn(0)
{
}

RunTimeTaxwareActivation::~RunTimeTaxwareActivation()
{
  if (mOutputBuffer) mOperator->mOutputMetadata.Free(mOutputBuffer);
  if (mErrorBuffer) mOperator->mErrorMetadata.Free(mErrorBuffer);

  delete [] mInBuffer;
  delete [] mOutBuffer;
  TaxwareUniversalTaxLink::ReleaseInstance(mUTL);
}
  
void RunTimeTaxwareActivation::Start()
{
  mLogger = MetraFlowLoggerManager::GetLogger("[Taxware]");
  mUTL = TaxwareUniversalTaxLink::GetInstance();

  mInBuffer = new char [CAPIINBUFFERSIZE+1];
  memset(mInBuffer, ' ', CAPIINBUFFERSIZE);
  mInBuffer[CAPIINBUFFERSIZE] = 0;
  mOutBuffer = new char [CAPIOUTBUFFERSIZE+1];
  memset(mOutBuffer, ' ', CAPIOUTBUFFERSIZE);
  mOutBuffer[CAPIOUTBUFFERSIZE] = 0;

  // Create NULL buffers for output and error to feed to the merger.
  mOutputBuffer = mOperator->mOutputMetadata.Allocate();
  mErrorBuffer = mOperator->mErrorMetadata.Allocate();
  // Create runtime bindings.
  for(std::vector<DesignTimeTaxwareBinding>::const_iterator it = mOperator->mDesignTimeBindings.begin();
      it != mOperator->mDesignTimeBindings.end();
      ++it)
  {
    mRunTimeBindings.push_back(RunTimeTaxwareBinding(*it, mOperator->mMetadata));
  }

  for(std::vector<DesignTimeTaxwareBinding>::const_iterator it = mOperator->mDesignTimeOutputBindings.begin();
      it != mOperator->mDesignTimeOutputBindings.end();
      ++it)
  {
    mRunTimeOutputBindings.push_back(RunTimeTaxwareBinding(*it, *mOperator->mOutputMerger.GetRecordMetadata()));
  }

  for(std::vector<DesignTimeTaxwareBinding>::const_iterator it = mOperator->mDesignTimeErrorBindings.begin();
      it != mOperator->mDesignTimeErrorBindings.end();
      ++it)
  {
    mRunTimeErrorBindings.push_back(RunTimeTaxwareBinding(*it, *mOperator->mErrorMerger.GetRecordMetadata()));
  }

  mState = START;
  HandleEvent(NULL);
}

void RunTimeTaxwareActivation::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case START:
    while(true)
    {
      RequestRead(0);
      mState = READ_0;
      return;
    case READ_0:
      Read(mInputMessage, ep);
      if (mOperator->mMetadata.IsEOF(mInputMessage))
      {
        mOperator->mMetadata.Free(mInputMessage);
        mInputMessage = NULL;

        RequestWrite(0);
        mState = WRITE_EOF_0;
        return;
      case WRITE_EOF_0:
        Write(mOperator->mOutputMetadata.AllocateEOF(), ep, true);

        RequestWrite(1);
        mState = WRITE_EOF_1;
        return;
      case WRITE_EOF_1:
        Write(mOperator->mErrorMetadata.AllocateEOF(), ep, true);

        return;
      }
      //////////////////////
      // Set header
      //////////////////////
      {
        TaxwareIntegerBinding numRecordsIn(NUMBERINRECORDSPOS, 6);
        numRecordsIn.Set(mInBuffer, 1);
      }
      // Default processing indicator is to process only.


      //////////////////////
      // Set input records
      //////////////////////
      {
        char * taxRecord = mInBuffer + CAPICOMMONINDATASIZE;
        for(std::vector<RunTimeTaxwareBinding>::const_iterator it = mRunTimeBindings.begin();
            it != mRunTimeBindings.end();
            ++it)
        {
          it->Set(taxRecord, mInputMessage);
        }

        if (mLogger->isOkToLogDebug())
        {
          mInBuffer[CAPICOMMONINDATASIZE + CAPIINPUTRECLENGTH] = 0;
          mLogger->logDebug(mInBuffer);
        }

        //TODO: If batching, send in the right length.
        try
        {
          mReturn = mUTL->TaxRoutine(mInBuffer, mOutBuffer, CAPICOMMONINDATASIZE + CAPIINPUTRECLENGTH);
        }
        catch(FatalSystemErrorException & fsee)
        {
          mLogger->logError("Fatal system error from Taxware.  Input Buffer: ");
          mInBuffer[CAPICOMMONINDATASIZE + CAPIINPUTRECLENGTH] = 0;
          mLogger->logError(mInBuffer);
          mLogger->logError(fsee.callStack());
          mLogger->logError(fsee.what());
          // Internal error from Taxware.  Log the input buffer and make sure it is noted that this
          // was an access violation or what-have-you but report back a valid user error using a valid 
          // Taxware completion code and description.  Since an access violation seems to imply that Taxware
          // is unrecoverable we make sure that we use a Taxware error that connotes unrecoverability.
          mReturn = 0;          
          memcpy(mOutBuffer + CAPICOMMONOUTDATASIZE + GENCMPLCDPOS, "0025", 4);
          std::string desc(200, ' ');
          static const char * const fatalSystemErrorString="Error accessing Audit File. No further processing occurs.";
          memcpy(&desc[0], fatalSystemErrorString, strlen(fatalSystemErrorString));
          memcpy(mOutBuffer + CAPICOMMONOUTDATASIZE + GENCMPLCDDSCPOS, &desc[0], 200);
        }
        catch(...)
        {
          mLogger->logError("Unexpected exception from Taxware.  Input Buffer: ");
          mInBuffer[CAPICOMMONINDATASIZE + CAPIINPUTRECLENGTH] = 0;
          mLogger->logError(mInBuffer);
          // Internal error from Taxware.  Log the input buffer and make sure it is noted that this
          // was an access violation or what-have-you but report back a user error using a valid 
          // Taxware completion code and description.
          mReturn = 0;          
          memcpy(mOutBuffer + CAPICOMMONOUTDATASIZE + GENCMPLCDPOS, "0008", 4);
          std::string desc(200, ' ');
          memcpy(&desc[0], 
                 "Error during attempt to access Tax Master File. No further processing occurs.", 
                 strlen("Error during attempt to access Tax Master File. No further processing occurs."));
          memcpy(mOutBuffer + CAPICOMMONOUTDATASIZE + GENCMPLCDDSCPOS, &desc[0], 200);
        }

        if (mLogger->isOkToLogDebug())
        {
          mOutBuffer[CAPICOMMONOUTDATASIZE + CAPIOUTPUTRECLENGTH] = 0;
          mLogger->logDebug(mOutBuffer);
        }
      }

      // Check completion code to see if we had errors.
      if (mReturn==1)
      {
        mOutputMessage = mOperator->mOutputMerger.GetRecordMetadata()->Allocate();
        mOperator->mOutputMerger.Merge(mInputMessage, mOutputBuffer, mOutputMessage);
        mOperator->mMetadata.Free(mInputMessage);
        mInputMessage = NULL;
        for(std::vector<RunTimeTaxwareBinding>::const_iterator it = mRunTimeOutputBindings.begin();
            it != mRunTimeOutputBindings.end();
            ++it)
        {
          it->Get(mOutBuffer + CAPICOMMONOUTDATASIZE, mOutputMessage);
        }
        RequestWrite(0);
        mState = WRITE_0;
        return;
      case WRITE_0:
        Write(mOutputMessage, ep);
      }
      else
      {
        mErrorMessage = mOperator->mErrorMerger.GetRecordMetadata()->Allocate();
        mOperator->mErrorMerger.Merge(mInputMessage, mErrorBuffer, mErrorMessage);
        mOperator->mMetadata.Free(mInputMessage);
        mInputMessage = NULL;
        for(std::vector<RunTimeTaxwareBinding>::const_iterator it = mRunTimeErrorBindings.begin();
            it != mRunTimeErrorBindings.end();
            ++it)
        {
          it->Get(mOutBuffer + CAPICOMMONOUTDATASIZE, mErrorMessage);
        }
        RequestWrite(1);
        mState = WRITE_1;
        return;
      case WRITE_1:
        Write(mErrorMessage, ep);
      }
    }
  }
}
  
