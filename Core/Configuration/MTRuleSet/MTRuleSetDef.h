// MTRuleSetDef.h : Declaration of the CMTRuleSet

#ifndef __MTRULESET_H_
#define __MTRULESET_H_

#include "resource.h"       // main symbols

#include <mttime.h>
#import <MTRuleSet.tlb>

#import <GenericCollection.tlb>
using GENERICCOLLECTIONLib::IMTCollection;

#include <MTObjectCollection.h>

#include <MTUtil.h>
#include <time.h>

#import <MTConfigLib.tlb>

#include <vector>

class ArgumentMap
{
public:
	ArgumentMap() {}
	virtual ~ArgumentMap() {}

	ArgumentMap(_bstr_t aPropName, _bstr_t aPropType, 
							_bstr_t aPropEnumType, _bstr_t aPropEnumSpace) : 
			mPropertyName(aPropName),
			mPropertyType(aPropType),
			mEnumType(aPropEnumType),
			mEnumSpace(aPropEnumSpace)
	{}

	// needs the == to be placed in the vector
	bool operator ==(const ArgumentMap & arMap) const
	{
		return mPropertyName == arMap.mPropertyName && 
						mPropertyType == arMap.mPropertyType &&
						mEnumType == arMap.mEnumType &&
						mEnumSpace == arMap.mEnumSpace;
	}

	ArgumentMap & operator =(const ArgumentMap & arMap)
	{
		mPropertyName = arMap.mPropertyName;
		mPropertyType = arMap.mPropertyType;
		mEnumType = arMap.mEnumType;
		mEnumSpace = arMap.mEnumSpace;
		return *this;
	}

	inline void SetPropertyName(_bstr_t aName)
	{
		mPropertyName = aName;
	}
	
	inline const _bstr_t GetPropertyName()
	{
		return mPropertyName;
	}

	inline void SetPropertyType(_bstr_t aType)
	{
		mPropertyType = aType;
	}

	inline const _bstr_t GetPropertyType()
	{
		return mPropertyType;
	}

	inline void SetEnumType(_bstr_t aEnumType)
	{
		mEnumType = aEnumType;
	}

	inline const _bstr_t GetEnumType()
	{
		return mEnumType;
	}

	inline void SetEnumSpace(_bstr_t aEnumSpace)
	{
		mEnumSpace = aEnumSpace;
	}

	inline const _bstr_t GetEnumSpace()
	{
		return mEnumSpace;
	}

private:
	_bstr_t		mPropertyName;
	_bstr_t		mPropertyType;
	_bstr_t		mEnumType;
	_bstr_t		mEnumSpace;

};

/////////////////////////////////////////////////////////////////////////////
// CMTRuleSet
class ATL_NO_VTABLE CMTRuleSet : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTRuleSet, &CLSID_MTRuleSet>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTRuleSet, &IID_IMTRuleSet, &LIBID_MTRULESETLib>
{
public:
	CMTRuleSet()
      : mPluginName("rate"), // default behavior
			mTimeOut(365) // default to a zear for the timeout
	{
		// set the default effective date to now
		mOleDate = (DATE) GetMTOLETime();
	}

	void FinalRelease();
	HRESULT FinalConstruct();


DECLARE_REGISTRY_RESOURCEID(IDR_MTRULESET)

DECLARE_GET_CONTROLLING_UNKNOWN()
DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTRuleSet)
	COM_INTERFACE_ENTRY(IMTRuleSet)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTRuleSet
public:

	STDMETHOD(get__NewEnum)(/*[out, retval]*/ LPUNKNOWN *pVal);
	STDMETHOD(get_Item)(/*[in]*/ long Index, /*[out,retval]*/ LPVARIANT pItem);
	STDMETHOD(Add)(/*[in]*/ IMTRule * pMyObj );
	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal );

	STDMETHOD(get_DefaultActions)(/*[out, retval]*/ IMTActionSet * * pVal);
	STDMETHOD(put_DefaultActions)(/*[in]*/ IMTActionSet * newVal);

	STDMETHOD(Read)(/*[in]*/ BSTR filename);
	STDMETHOD(Write)(/*[in]*/ BSTR filename);

	STDMETHOD(WriteToHost)(BSTR aHostName, BSTR aRelativePath,
												 BSTR aUsername, BSTR aPassword,
												 VARIANT_BOOL aSecure);

	STDMETHOD(ReadFromHost)(/*[in]*/ BSTR hostname, /*[in]*/ BSTR relativePath,
													VARIANT_BOOL secure);
	STDMETHOD(WriteToSet)(::IMTConfigPropSet** ppSet);
	STDMETHOD(ReadFromSet)(::IMTConfigPropSet* pSet);
	STDMETHOD(Insert)(IMTRule * pMyObj, int aIndex);
	STDMETHOD(Remove)(int aIndex);
	STDMETHOD(get_Timeout)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_Timeout)(/*[in]*/ long newVal);
	STDMETHOD(get_EffectiveDate)(/*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(put_EffectiveDate)(/*[in]*/ VARIANT newVal);
	STDMETHOD(get_PluginName)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_PluginName)(/*[in]*/ BSTR newVal);


private:
	//
	// output methods
	//
	HRESULT OutputRules(MTConfigLib::IMTConfigPropSetPtr arPropSet);
	HRESULT OutputMTSysHeader(MTConfigLib::IMTConfigPropSetPtr aPropSet,
														long aDate, long aTimeoutDates);

	HRESULT OutputMTPlugInHeader(MTConfigLib::IMTConfigPropSetPtr aPropSet, 
															 _bstr_t name, 
															 _bstr_t aProgID,
															 _bstr_t aDescription);

	HRESULT OutputRuleSetData(MTConfigLib::IMTConfigPropSetPtr aPropSet);

	HRESULT OutputActionSet(MTConfigLib::IMTConfigPropSetPtr aPropSet,
													MTRULESETLib::IMTActionSetPtr aActionSet);

	HRESULT OutputAction(MTConfigLib::IMTConfigPropSetPtr aPropSet,
											 MTRULESETLib::IMTAssignmentActionPtr aAction);

	HRESULT OutputConditionSet(MTConfigLib::IMTConfigPropSetPtr aPropSet,
														 MTRULESETLib::IMTConditionSetPtr aConditionSet);

	HRESULT OutputCondition(MTConfigLib::IMTConfigPropSetPtr aPropSet,
													MTRULESETLib::IMTSimpleConditionPtr aCondition);


	HRESULT OutputRule(MTConfigLib::IMTConfigPropSetPtr aPropSet,
										 MTRULESETLib::IMTRulePtr aRule);

	//
	// input methods
	//
	HRESULT InputRuleSet(MTConfigLib::IMTConfigPropSetPtr aPropSet);

	HRESULT InputRulesOnly(MTConfigLib::IMTConfigPropSetPtr aPropSet);

	HRESULT InputMTSysHeader(MTConfigLib::IMTConfigPropSetPtr aPropSet);

	HRESULT InputMTPlugInHeader(MTConfigLib::IMTConfigPropSetPtr aPropSet);

	HRESULT InputRuleSetData(MTConfigLib::IMTConfigPropSetPtr aPropSet);

	HRESULT InputActionSet(MTConfigLib::IMTConfigPropSetPtr aPropSet,
												 MTRULESETLib::IMTActionSetPtr aActionSet);

	HRESULT InputConditionSet(MTConfigLib::IMTConfigPropSetPtr aPropSet,
														MTRULESETLib::IMTConditionSetPtr aConditionSet);

	HRESULT InputRule(MTConfigLib::IMTConfigPropSetPtr aPropSet,
										MTRULESETLib::IMTRulePtr aRule);

	HRESULT InputAction(MTConfigLib::IMTConfigPropSetPtr aPropSet,
											MTRULESETLib::IMTAssignmentActionPtr aAction);

	HRESULT InputCondition(MTConfigLib::IMTConfigPropSetPtr aPropSet,
												 MTRULESETLib::IMTSimpleConditionPtr aCondition);


	//
	// argument map methods
	//
	HRESULT RefreshInputList(MTRULESETLib::IMTConditionSetPtr aConditionSet);
	HRESULT RefreshOutputList(MTRULESETLib::IMTActionSetPtr aActionSet);
	HRESULT RefreshArgumentMap();

private:
	MTObjectCollection<IMTRule> mRules;

	MTRULESETLib::IMTActionSetPtr mDefaultActions;


	std::vector<ArgumentMap> mInputArgList;
	std::vector<ArgumentMap> mOutputArgList;

  _bstr_t mPluginName;
	_bstr_t mProgid;
	_bstr_t mDescription;

	long mTimeOut;
	DATE mOleDate;

	CComPtr<IUnknown> m_pUnkMarshaler;

};

#endif //__MTRULESET_H_
