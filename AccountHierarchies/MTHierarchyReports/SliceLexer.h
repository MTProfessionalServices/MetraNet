	
// SliceLexer.h : Declaration of the CSliceLexer

#ifndef __SLICELEXER_H_
#define __SLICELEXER_H_

#include "resource.h"       // main symbols

#include <string>

/////////////////////////////////////////////////////////////////////////////
// CSliceLexer
class ATL_NO_VTABLE CSliceLexer : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CSliceLexer, &CLSID_SliceLexer>,
	public ISupportErrorInfo,
	public IDispatchImpl<ISliceLexer, &IID_ISliceLexer, &LIBID_MTHIERARCHYREPORTSLib>
{
public:

	CSliceLexer();

DECLARE_REGISTRY_RESOURCEID(IDR_SLICELEXER)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CSliceLexer)
	COM_INTERFACE_ENTRY(ISliceLexer)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
		return CoCreateFreeThreadedMarshaler(
			GetControllingUnknown(), &m_pUnkMarshaler.p);
	}

	void FinalRelease()
	{
		m_pUnkMarshaler.Release();
	}

	CComPtr<IUnknown> m_pUnkMarshaler;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// ISliceLexer
public:
  /**
   * Get the next token and advance the token stream.
   */
	STDMETHOD(GetNextToken)(/*[out, retval]*/ BSTR *apToken);
  /**
   * Look ahead 1 token
   */
	STDMETHOD(LookAhead)(/*[out, retval]*/ BSTR *apToken);
  /**
   * Initialize the lexer with buffer represented by the string
   */
	STDMETHOD(Init)(/*[in]*/ BSTR aStr);
private:
  std::string mBuffer;
	const std::string::size_type NPOS;
	std::string::size_type mLastFound;
	std::string::size_type mNextFound;
  std::string mFoundStr;
	void Advance();
};

#endif //__SLICELEXER_H_
