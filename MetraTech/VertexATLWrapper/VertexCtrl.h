// VertexCtrl.h : Declaration of the CVertexCtrl

/*
In the C and C++ programming languages, #pragma once is a non-standard
but widely supported preprocessor directive designed to cause the current source file 
to be included only once in a single compilation.
Thus, #pragma once serves the same purpose as #include guards, but with several advantages, 
including: less code, avoiding name clashes, and sometimes improved compile speed.
*/
#pragma once

  #ifdef __cplusplus
extern "C" {
#endif

#include "stda.h"
#include "ctqa.h"

#include "resource.h"       // main symbols
#include <atlctl.h>
#include "VertexATLWrapper_i.h"

#if defined(_WIN32_WCE) && !defined(_CE_DCOM) && !defined(_CE_ALLOW_SINGLE_THREADED_OBJECTS_IN_MTA)
#error "Single-threaded COM objects are not properly supported on Windows CE platform, such as the Windows Mobile platforms that do not include full DCOM support. Define _CE_ALLOW_SINGLE_THREADED_OBJECTS_IN_MTA to force ATL to support creating single-thread COM object's and allow use of it's single-threaded COM object implementations. The threading model in your rgs file was set to 'Free' as that is the only threading model supported in non DCOM Windows CE platforms."
#endif

  using namespace std;



  class CTimingObj
  {
  public:
    CTimingObj(LARGE_INTEGER le, CString str){m_leTiming = le; strDesc = str;}
    LARGE_INTEGER m_leTiming;
    CString strDesc;
  };

  class CVertexAttribObj : public CObject
  {
  public:
    DECLARE_SERIAL(CVertexAttribObj)
    tCtqAttrib m_Attrib;
    tCtqAttribType m_Type;
    int m_Size;
    CVertexAttribObj() {m_Attrib = (tCtqAttrib)0;}
    CVertexAttribObj(tCtqAttrib attrib,tCtqAttribType type, int size = 0) {m_Attrib = attrib; m_Type = type; m_Size = size;}
    virtual ~CVertexAttribObj() {}
    virtual void Serialize(CArchive& ar);
  };

  typedef CTypedPtrMap<CMapStringToOb,CString,CVertexAttribObj*> CMapStringToVertexAttrib;

  // CVertexCtrl
  class ATL_NO_VTABLE CVertexCtrl :
    public CComObjectRootEx<CComGlobalsThreadModel>,
    public IDispatchImpl<IVertexCtrl, &IID_IVertexCtrl, &LIBID_VertexATLWrapperLib, /*wMajor =*/ 1, /*wMinor =*/ 0>,
    public IPersistStreamInitImpl<CVertexCtrl>,
    public IOleControlImpl<CVertexCtrl>,
    public IOleObjectImpl<CVertexCtrl>,
    public IOleInPlaceActiveObjectImpl<CVertexCtrl>,
    public IViewObjectExImpl<CVertexCtrl>,
    public IOleInPlaceObjectWindowlessImpl<CVertexCtrl>,
    public ISupportErrorInfo,
    public IPersistStorageImpl<CVertexCtrl>,
    public ISpecifyPropertyPagesImpl<CVertexCtrl>,
    public IQuickActivateImpl<CVertexCtrl>,
#ifndef _WIN32_WCE
    public IDataObjectImpl<CVertexCtrl>,
#endif
    public IProvideClassInfo2Impl<&CLSID_VertexCtrl, NULL, &LIBID_VertexATLWrapperLib>,
#ifdef _WIN32_WCE // IObjectSafety is required on Windows CE for the control to be loaded correctly
    public IObjectSafetyImpl<CVertexCtrl, INTERFACESAFE_FOR_UNTRUSTED_CALLER>,
#endif
    public CComCoClass<CVertexCtrl, &CLSID_VertexCtrl>,
    public CComControl<CVertexCtrl>
  {
  public:
    CVertexCtrl() :
      m_bstrVertexConfigPath(_T("")),
      m_bstrVertexConfigName(_T("")),
      m_bInitialized(false),
      m_bXercesInitialized(false),
      //		m_bVertexSysInitialized(false),
      m_bVertexInitialized(false),
      m_bVertexConnected(false),
      m_bVertexCtzConnected(false),
      m_bVertexLocConnected(false),
      m_bVertexRteConnected(false),
      m_bVertexRegConnected(false),
      m_lCtqRootHandle(NULL),
      m_bReturnTimings(false),
      m_bWriteToJournal(0)
    {
      SetupMaps();
      QueryPerformanceFrequency(&m_leTimingFreq);
    }

    virtual ~CVertexCtrl()
    {
      CleanUpMaps();
    }

    DECLARE_OLEMISC_STATUS(OLEMISC_RECOMPOSEONRESIZE |
    OLEMISC_INVISIBLEATRUNTIME |
      OLEMISC_CANTLINKINSIDE |
      OLEMISC_INSIDEOUT |
      OLEMISC_ACTIVATEWHENVISIBLE |
      OLEMISC_SETCLIENTSITEFIRST
      )

      DECLARE_REGISTRY_RESOURCEID(IDR_VERTEXCTRL)


    BEGIN_COM_MAP(CVertexCtrl)
      COM_INTERFACE_ENTRY(IVertexCtrl)
      COM_INTERFACE_ENTRY(IDispatch)
      COM_INTERFACE_ENTRY(IViewObjectEx)
      COM_INTERFACE_ENTRY(IViewObject2)
      COM_INTERFACE_ENTRY(IViewObject)
      COM_INTERFACE_ENTRY(IOleInPlaceObjectWindowless)
      COM_INTERFACE_ENTRY(IOleInPlaceObject)
      COM_INTERFACE_ENTRY2(IOleWindow, IOleInPlaceObjectWindowless)
      COM_INTERFACE_ENTRY(IOleInPlaceActiveObject)
      COM_INTERFACE_ENTRY(IOleControl)
      COM_INTERFACE_ENTRY(IOleObject)
      COM_INTERFACE_ENTRY(IPersistStreamInit)
      COM_INTERFACE_ENTRY2(IPersist, IPersistStreamInit)
      COM_INTERFACE_ENTRY(ISupportErrorInfo)
      COM_INTERFACE_ENTRY(ISpecifyPropertyPages)
      COM_INTERFACE_ENTRY(IQuickActivate)
      COM_INTERFACE_ENTRY(IPersistStorage)
#ifndef _WIN32_WCE
      COM_INTERFACE_ENTRY(IDataObject)
#endif
      COM_INTERFACE_ENTRY(IProvideClassInfo)
      COM_INTERFACE_ENTRY(IProvideClassInfo2)
#ifdef _WIN32_WCE // IObjectSafety is required on Windows CE for the control to be loaded correctly
      COM_INTERFACE_ENTRY_IID(IID_IObjectSafety, IObjectSafety)
#endif
    END_COM_MAP()

    BEGIN_PROP_MAP(CVertexCtrl)
      PROP_DATA_ENTRY("_cx", m_sizeExtent.cx, VT_UI4)
      PROP_DATA_ENTRY("_cy", m_sizeExtent.cy, VT_UI4)
      // Example entries
      // PROP_ENTRY_TYPE("Property Name", dispid, clsid, vtType)
      // PROP_PAGE(CLSID_StockColorPage)
    END_PROP_MAP()


    BEGIN_MSG_MAP(CVertexCtrl)
      CHAIN_MSG_MAP(CComControl<CVertexCtrl>)
      DEFAULT_REFLECTION_HANDLER()
    END_MSG_MAP()
    // Handler prototypes:
    //  LRESULT MessageHandler(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
    //  LRESULT CommandHandler(WORD wNotifyCode, WORD wID, HWND hWndCtl, BOOL& bHandled);
    //  LRESULT NotifyHandler(int idCtrl, LPNMHDR pnmh, BOOL& bHandled);

    // ISupportsErrorInfo
    STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid)
    {
      static const IID* arr[] =
      {
        &IID_IVertexCtrl,
      };

      for (int i=0; i<sizeof(arr)/sizeof(arr[0]); i++)
      {
        if (InlineIsEqualGUID(*arr[i], riid))
          return S_OK;
      }
      return S_FALSE;
    }

    // IViewObjectEx
    DECLARE_VIEW_STATUS(0)

    // IVertexCtrl
  public:
    HRESULT OnDrawAdvanced(ATL_DRAWINFO& di)
    {
      RECT& rc = *(RECT*)di.prcBounds;
      // Set Clip region to the rectangle specified by di.prcBounds
      HRGN hRgnOld = NULL;
      if (GetClipRgn(di.hdcDraw, hRgnOld) != 1)
        hRgnOld = NULL;
      bool bSelectOldRgn = false;

      HRGN hRgnNew = CreateRectRgn(rc.left, rc.top, rc.right, rc.bottom);

      if (hRgnNew != NULL)
      {
        bSelectOldRgn = (SelectClipRgn(di.hdcDraw, hRgnNew) != ERROR);
      }

      Rectangle(di.hdcDraw, rc.left, rc.top, rc.right, rc.bottom);
      SetTextAlign(di.hdcDraw, TA_CENTER|TA_BASELINE);
      LPCTSTR pszText = _T("ATL 8.0 : VertexCtrl");
#ifndef _WIN32_WCE
      TextOut(di.hdcDraw,
        (rc.left + rc.right) / 2,
        (rc.top + rc.bottom) / 2,
        pszText,
        lstrlen(pszText));
#else
      ExtTextOut(di.hdcDraw,
        (rc.left + rc.right) / 2,
        (rc.top + rc.bottom) / 2,
        ETO_OPAQUE,
        NULL,
        pszText,
        ATL::lstrlen(pszText),
        NULL);
#endif

      if (bSelectOldRgn)
        SelectClipRgn(di.hdcDraw, hRgnOld);

      return S_OK;
    }


    DECLARE_PROTECT_FINAL_CONSTRUCT()

    HRESULT FinalConstruct()
    {
      return S_OK;
    }

    void FinalRelease()
    {
    }

    STDMETHOD(get_bstrVertexConfigPath)(BSTR* pVal);
    STDMETHOD(put_bstrVertexConfigPath)(BSTR newVal);
    STDMETHOD(get_bstrVertexConfigName)(BSTR* pVal);
    STDMETHOD(put_bstrVertexConfigName)(BSTR newVal);
    STDMETHOD(Initialize)(BSTR* bstrResults);
    STDMETHOD(Reconnect)(BSTR* bstrResults);
    STDMETHOD(Refresh)(BSTR* bstrResults);
    STDMETHOD(Reset)(BSTR* bstrResults);
    STDMETHOD(Terminate)(BSTR* bstrResults);
    STDMETHOD(CalculateTaxes)(BSTR bstrXMLParams, BSTR* bstrResults);
    STDMETHOD(get_sReturnTimings)(SHORT* pVal);
    STDMETHOD(put_sReturnTimings)(SHORT newVal);

  protected:
    CComBSTR m_bstrVertexConfigPath;
    CComBSTR m_bstrVertexConfigName;
    bool m_bInitialized;
    bool m_bXercesInitialized;
    static int m_iVertexSysInitialized;
    bool m_bVertexInitialized;
    bool m_bVertexConnected;
    bool m_bVertexCtzConnected;
    bool m_bVertexLocConnected;
    bool m_bVertexRteConnected;
    bool m_bVertexRegConnected;
    tCtqHandle m_lCtqRootHandle;
    CMapStringToVertexAttrib m_mapVertexAttrib;
    bool m_bReturnTimings;
    LARGE_INTEGER m_leTimingFreq;
    vector <CTimingObj*> m_vTiming;
    int m_bWriteToJournal;

     void SetupMaps(void);
     void CleanUpMaps(void);
     CString  VertexErrorString(tCtqResultCode pResultCode);
     void  VertexSysInit(void);
     void  VertexSysTerm(void);
     void  VertexInit(void);
     void  VertexTerm(void);
     void  VertexConnect(void);
     void  VertexDisconnect(void);
     tCtqResultCode  SetVertexAttrib(tCtqHandle handle, CString& strAttrib, void *pData);
     CString  GetVertexAttrib(tCtqHandle, CString& strAttrib);
     void  SetVertexParams(CComBSTR &strParams);
     CComBSTR  GetVertexResults();
     CString  ReportTimings();
     void  SetLookupVertexParams(tCtqHandle& lCtqLocHandle, CComBSTR &strParams);
     CComBSTR  GetLookupVertexResults(tCtqHandle& lLocHandle);
  public:
     STDMETHOD(LookupGeoCode)(BSTR bstrXMLParams, BSTR* bstrResults);
     STDMETHOD(get_iWriteToJournal)(LONG* pVal);
     STDMETHOD(put_iWriteToJournal)(LONG newVal);
  };

OBJECT_ENTRY_AUTO(__uuidof(VertexCtrl), CVertexCtrl)

#ifdef __cplusplus
}
#endif
