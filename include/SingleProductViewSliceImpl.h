/**************************************************************************
* Copyright 1997-2002 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
***************************************************************************/

#ifndef __SingleProductViewSliceImpl_H__
#define __SingleProductViewSliceImpl_H__
#pragma once

#include <comdef.h>
#include <autoptr.h>
#include <mtcomerr.h>
#include <mtprogids.h>
#include <mtglobal_msg.h>
#include <MTDec.h>
#include <formatdbvalue.h>
#include <map>
#include <list>
#include <boost/shared_ptr.hpp>
#import <rowsetinterfaceslib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping
#import <MTProductCatalog.tlb> rename ("EOF", "PCEOF") no_function_mapping
#import <MTEnumConfigLib.tlb> rename ("EOF", "PCEOF") no_function_mapping

class PropertyWithValue;

typedef boost::shared_ptr<PropertyWithValue> PropertyWithValuePtr;
typedef std::list<PropertyWithValuePtr> PredicateList;

using namespace std;

#define SLICEIMPL template<class T,const IID* piid, const GUID* plibid> \
                STDMETHODIMP SingleProductViewSliceImpl<T,piid,plibid>

//template<class T,const IID* piid, const GUID* plibid> class SingleProductViewSliceImpl<T,piid,plibid>;
template<class T,const IID* piid, const GUID* plibid> class SingleProductViewSliceImpl;

class PropertyWithValue
{
public:
  template <class T,const IID* piid, const GUID* plibid> friend class SingleProductViewSliceImpl;//<T,piid,plibid>;
  PropertyWithValue() : mPVProperty(NULL)
  {
   
  }
  ~PropertyWithValue()
  {
  }
  IProductViewProperty* GetProperty()
  {
    MTPRODUCTVIEWLib::IProductViewPropertyPtr outPtr = mPVProperty;
    return reinterpret_cast<IProductViewProperty*>(outPtr.Detach());
  }
   _variant_t GetValue()
  {
    return mValue;
  }
  /*
typedef enum
	{
		MSIX_TYPE_STRING = 0,
		MSIX_TYPE_WIDESTRING = 1,
		MSIX_TYPE_INT32 = 2,
		MSIX_TYPE_TIMESTAMP = 3,
		MSIX_TYPE_FLOAT = 4,
		MSIX_TYPE_DOUBLE = 5,
		MSIX_TYPE_NUMERIC = 6,
		MSIX_TYPE_DECIMAL = 7,
		MSIX_TYPE_ENUM = 8,
		MSIX_TYPE_BOOLEAN = 9,
		MSIX_TYPE_TIME = 10
	} MSIX_PROPERTY_TYP
  */
  wstring ToString()
  {
    /*****
     * mValue.ChangeType() is called bellow because I removed passing the variant type to 
     * FormatValueForDB() function. To guarantee the same behavior as before I change the type
     * of variant to type that was being passed into the call. This is probably anal and 
     * isn't necessary. - Boris
     *****/

    wstring out(L"");
    wstring sFormatted;
    if ((mPVProperty == NULL) || (V_VT(&mValue) == VT_EMPTY))
      return out;
    wchar_t buf[1024];
    MTPRODUCTVIEWLib::MSIX_PROPERTY_TYPE tp = mPVProperty->PropertyType;
    switch(tp)
    {
      case MSIX_TYPE_STRING:
      case MSIX_TYPE_WIDESTRING:
        {
          mValue.ChangeType(VT_BSTR);
          FormatValueForDB(mValue, false, sFormatted);
          break;
        }
      case MSIX_TYPE_INT32:
      case MSIX_TYPE_NUMERIC:
        {
          mValue.ChangeType(VT_I4);
          FormatValueForDB(mValue, false, sFormatted);
          break;
        }
      case MSIX_TYPE_INT64:
        {
          mValue.ChangeType(VT_I8);
          FormatValueForDB(mValue, false, sFormatted);
          break;
        }
      case MSIX_TYPE_DOUBLE:
      case MSIX_TYPE_DECIMAL:
        {
          mValue.ChangeType(VT_DECIMAL);
          FormatValueForDB(mValue, false, sFormatted);
          break;
        }
      case MSIX_TYPE_BOOLEAN:
        {
          mValue.ChangeType(VT_BOOL);
          FormatValueForDB(mValue, false, sFormatted);
          break;
        }
      case MSIX_TYPE_ENUM:
         {
           long lVal;
           if(V_VT(&mValue) == VT_BSTR)
           {
             if(mEnumConfig == NULL)
             {
               HRESULT hr = mEnumConfig.CreateInstance("Metratech.MTEnumConfig");
               if(FAILED(hr))
                 MT_THROW_COM_ERROR(hr);
             }
             lVal = mEnumConfig->GetID(mPVProperty->EnumNamespace, mPVProperty->EnumEnumeration, (_bstr_t)mValue);
           }
           else
             lVal = (long)mValue;
          wsprintf(buf, L"%d", lVal);
          sFormatted = buf;
          break;
        }
      case MSIX_TYPE_TIMESTAMP:
      case MSIX_TYPE_TIME:
        {
          // {ts '1900-01-01 00:00:00'}
          mValue.ChangeType(VT_DATE);
          FormatValueForDB(mValue, false, sFormatted);
          break;
        }
      default:
        ASSERT(!"Unsupported MSIX type");
    }
  
     out = (wchar_t*)mPVProperty->ColumnName;
     out += L"=";
     out += sFormatted;
     return out;
  }

private:
    MTPRODUCTVIEWLib::IProductViewPropertyPtr mPVProperty;
    MTENUMCONFIGLib::IEnumConfigPtr mEnumConfig;
    _variant_t mValue;
};

template<class T,const IID* piid, const GUID* plibid>
class SingleProductViewSliceImpl : public IDispatchImpl<T,piid,plibid>
{
public:
  virtual ~SingleProductViewSliceImpl() 
  {
    /*
    while(mPredicates.size() > 0)
    {
      delete mPredicates.back();
      mPredicates.pop_back();
    }
    */
  }
  
  STDMETHOD(get_ProductView)(/*[out, retval]*/ IProductView* *pVal);
	STDMETHOD(get_DisplayName)(/*[in]*/ ICOMLocaleTranslator *apLocale, /*[out,retval]*/ BSTR *pVal);
  STDMETHOD(AddProductViewPropertyPredicate)(/*[in]*/ IProductViewProperty* aPVProperty, /*[in]*/VARIANT aPropertyValue);
  _bstr_t GetPredicateString();
  PredicateList& GetPredicates()
  {
    return mPredicates;
  }
  void SetPredicates(PredicateList& aPredicates)
  {
    mPredicates = aPredicates;
  }

protected:
  PredicateList mPredicates;
	long mInstanceID;
	long mViewID;
  MTPRODUCTVIEWLib::IProductViewPtr mProductView;
  std::map<long,_bstr_t> mDisplayName;
  
};

SLICEIMPL::AddProductViewPropertyPredicate(/*[in]*/ IProductViewProperty* aPVProperty, /*[in]*/VARIANT aPropertyValue)
{
  if(aPVProperty == NULL || V_VT(&aPropertyValue) == VT_NULL)
    return E_POINTER;
	PropertyWithValuePtr propPtr(new PropertyWithValue());
  propPtr->mPVProperty = aPVProperty;
  //if passed by ref, make a copy
  //if(V_VT(&aPVProperty) & VT_BYREF)
  //make a copy always to avoid possible byref problems
  _variant_t vCopiedVal;
  ::VariantCopy(&vCopiedVal, &aPropertyValue);

  propPtr->mValue = vCopiedVal;
  mPredicates.push_back(propPtr);
  return S_OK;
}

SLICEIMPL::get_ProductView(IProductView* *pVal)
{
  return S_OK;
}
SLICEIMPL::get_DisplayName(ICOMLocaleTranslator *apLocale, BSTR *pVal)
{
  return S_OK;
}

 template<class T,const IID* piid, const GUID* plibid> _bstr_t  SingleProductViewSliceImpl<T,piid,plibid>::GetPredicateString()
{
  _bstr_t predicates = L"";
  PredicateList::const_iterator it = mPredicates.begin();
  while ( it != mPredicates.end())
  {
    predicates += "\nAND ";
    PropertyWithValuePtr propPtr = *it++;
    predicates += _bstr_t("pv.");
    predicates += _bstr_t(propPtr->ToString().c_str());
  }

  return predicates;
}


#endif //__SingleProductViewSliceImpl_H__
