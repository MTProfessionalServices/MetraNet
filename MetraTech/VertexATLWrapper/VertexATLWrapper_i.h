

/* this ALWAYS GENERATED file contains the definitions for the interfaces */


 /* File created by MIDL compiler version 7.00.0555 */
/* at Thu Jul 25 14:02:47 2013
 */
/* Compiler settings for VertexATLWrapper.idl:
    Oicf, W1, Zp8, env=Win32 (32b run), target_arch=X86 7.00.0555 
    protocol : dce , ms_ext, c_ext, robust
    error checks: allocation ref bounds_check enum stub_data 
    VC __declspec() decoration level: 
         __declspec(uuid()), __declspec(selectany), __declspec(novtable)
         DECLSPEC_UUID(), MIDL_INTERFACE()
*/
/* @@MIDL_FILE_HEADING(  ) */

#pragma warning( disable: 4049 )  /* more than 64k source lines */


/* verify that the <rpcndr.h> version is high enough to compile this file*/
#ifndef __REQUIRED_RPCNDR_H_VERSION__
#define __REQUIRED_RPCNDR_H_VERSION__ 475
#endif

#include "rpc.h"
#include "rpcndr.h"

#ifndef __RPCNDR_H_VERSION__
#error this stub requires an updated version of <rpcndr.h>
#endif // __RPCNDR_H_VERSION__

#ifndef COM_NO_WINDOWS_H
#include "windows.h"
#include "ole2.h"
#endif /*COM_NO_WINDOWS_H*/

#ifndef __VertexATLWrapper_i_h__
#define __VertexATLWrapper_i_h__

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

/* Forward Declarations */ 

#ifndef __IVertexCtrl_FWD_DEFINED__
#define __IVertexCtrl_FWD_DEFINED__
typedef interface IVertexCtrl IVertexCtrl;
#endif 	/* __IVertexCtrl_FWD_DEFINED__ */


#ifndef __VertexCtrl_FWD_DEFINED__
#define __VertexCtrl_FWD_DEFINED__

#ifdef __cplusplus
typedef class VertexCtrl VertexCtrl;
#else
typedef struct VertexCtrl VertexCtrl;
#endif /* __cplusplus */

#endif 	/* __VertexCtrl_FWD_DEFINED__ */


/* header files for imported files */
#include "oaidl.h"
#include "ocidl.h"

#ifdef __cplusplus
extern "C"{
#endif 


#ifndef __IVertexCtrl_INTERFACE_DEFINED__
#define __IVertexCtrl_INTERFACE_DEFINED__

/* interface IVertexCtrl */
/* [unique][helpstring][nonextensible][dual][version][uuid][object] */ 


EXTERN_C const IID IID_IVertexCtrl;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("DA8BA531-8D97-4BA0-BA30-186806865E92")
    IVertexCtrl : public IDispatch
    {
    public:
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_bstrVertexConfigPath( 
            /* [retval][out] */ BSTR *pVal) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_bstrVertexConfigPath( 
            /* [in] */ BSTR newVal) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_bstrVertexConfigName( 
            /* [retval][out] */ BSTR *pVal) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_bstrVertexConfigName( 
            /* [in] */ BSTR newVal) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE Initialize( 
            /* [retval][out] */ BSTR *bstrResults) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE Reset( 
            /* [retval][out] */ BSTR *bstrResults) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE Terminate( 
            /* [retval][out] */ BSTR *bstrResults) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE CalculateTaxes( 
            /* [in] */ BSTR bstrXMLParams,
            /* [retval][out] */ BSTR *bstrResults) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_sReturnTimings( 
            /* [retval][out] */ SHORT *pVal) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_sReturnTimings( 
            /* [in] */ SHORT newVal) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE LookupGeoCode( 
            /* [in] */ BSTR bstrXMLParams,
            /* [retval][out] */ BSTR *bstrResults) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_iWriteToJournal( 
            /* [retval][out] */ LONG *pVal) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_iWriteToJournal( 
            /* [in] */ LONG newVal) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE Reconnect( 
            /* [retval][out] */ BSTR *bstrResults) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE Refresh( 
            /* [retval][out] */ BSTR *bstrResults) = 0;
        
    };
    
#else 	/* C style interface */

    typedef struct IVertexCtrlVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            IVertexCtrl * This,
            /* [in] */ REFIID riid,
            /* [annotation][iid_is][out] */ 
            __RPC__deref_out  void **ppvObject);
        
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            IVertexCtrl * This);
        
        ULONG ( STDMETHODCALLTYPE *Release )( 
            IVertexCtrl * This);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfoCount )( 
            IVertexCtrl * This,
            /* [out] */ UINT *pctinfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfo )( 
            IVertexCtrl * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetIDsOfNames )( 
            IVertexCtrl * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [range][in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        /* [local] */ HRESULT ( STDMETHODCALLTYPE *Invoke )( 
            IVertexCtrl * This,
            /* [in] */ DISPID dispIdMember,
            /* [in] */ REFIID riid,
            /* [in] */ LCID lcid,
            /* [in] */ WORD wFlags,
            /* [out][in] */ DISPPARAMS *pDispParams,
            /* [out] */ VARIANT *pVarResult,
            /* [out] */ EXCEPINFO *pExcepInfo,
            /* [out] */ UINT *puArgErr);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_bstrVertexConfigPath )( 
            IVertexCtrl * This,
            /* [retval][out] */ BSTR *pVal);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE *put_bstrVertexConfigPath )( 
            IVertexCtrl * This,
            /* [in] */ BSTR newVal);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_bstrVertexConfigName )( 
            IVertexCtrl * This,
            /* [retval][out] */ BSTR *pVal);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE *put_bstrVertexConfigName )( 
            IVertexCtrl * This,
            /* [in] */ BSTR newVal);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Initialize )( 
            IVertexCtrl * This,
            /* [retval][out] */ BSTR *bstrResults);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Reset )( 
            IVertexCtrl * This,
            /* [retval][out] */ BSTR *bstrResults);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Terminate )( 
            IVertexCtrl * This,
            /* [retval][out] */ BSTR *bstrResults);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *CalculateTaxes )( 
            IVertexCtrl * This,
            /* [in] */ BSTR bstrXMLParams,
            /* [retval][out] */ BSTR *bstrResults);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_sReturnTimings )( 
            IVertexCtrl * This,
            /* [retval][out] */ SHORT *pVal);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE *put_sReturnTimings )( 
            IVertexCtrl * This,
            /* [in] */ SHORT newVal);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *LookupGeoCode )( 
            IVertexCtrl * This,
            /* [in] */ BSTR bstrXMLParams,
            /* [retval][out] */ BSTR *bstrResults);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE *get_iWriteToJournal )( 
            IVertexCtrl * This,
            /* [retval][out] */ LONG *pVal);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE *put_iWriteToJournal )( 
            IVertexCtrl * This,
            /* [in] */ LONG newVal);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Reconnect )( 
            IVertexCtrl * This,
            /* [retval][out] */ BSTR *bstrResults);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Refresh )( 
            IVertexCtrl * This,
            /* [retval][out] */ BSTR *bstrResults);
        
        END_INTERFACE
    } IVertexCtrlVtbl;

    interface IVertexCtrl
    {
        CONST_VTBL struct IVertexCtrlVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IVertexCtrl_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IVertexCtrl_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IVertexCtrl_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IVertexCtrl_GetTypeInfoCount(This,pctinfo)	\
    ( (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo) ) 

#define IVertexCtrl_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    ( (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo) ) 

#define IVertexCtrl_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    ( (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId) ) 

#define IVertexCtrl_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    ( (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr) ) 


#define IVertexCtrl_get_bstrVertexConfigPath(This,pVal)	\
    ( (This)->lpVtbl -> get_bstrVertexConfigPath(This,pVal) ) 

#define IVertexCtrl_put_bstrVertexConfigPath(This,newVal)	\
    ( (This)->lpVtbl -> put_bstrVertexConfigPath(This,newVal) ) 

#define IVertexCtrl_get_bstrVertexConfigName(This,pVal)	\
    ( (This)->lpVtbl -> get_bstrVertexConfigName(This,pVal) ) 

#define IVertexCtrl_put_bstrVertexConfigName(This,newVal)	\
    ( (This)->lpVtbl -> put_bstrVertexConfigName(This,newVal) ) 

#define IVertexCtrl_Initialize(This,bstrResults)	\
    ( (This)->lpVtbl -> Initialize(This,bstrResults) ) 

#define IVertexCtrl_Reset(This,bstrResults)	\
    ( (This)->lpVtbl -> Reset(This,bstrResults) ) 

#define IVertexCtrl_Terminate(This,bstrResults)	\
    ( (This)->lpVtbl -> Terminate(This,bstrResults) ) 

#define IVertexCtrl_CalculateTaxes(This,bstrXMLParams,bstrResults)	\
    ( (This)->lpVtbl -> CalculateTaxes(This,bstrXMLParams,bstrResults) ) 

#define IVertexCtrl_get_sReturnTimings(This,pVal)	\
    ( (This)->lpVtbl -> get_sReturnTimings(This,pVal) ) 

#define IVertexCtrl_put_sReturnTimings(This,newVal)	\
    ( (This)->lpVtbl -> put_sReturnTimings(This,newVal) ) 

#define IVertexCtrl_LookupGeoCode(This,bstrXMLParams,bstrResults)	\
    ( (This)->lpVtbl -> LookupGeoCode(This,bstrXMLParams,bstrResults) ) 

#define IVertexCtrl_get_iWriteToJournal(This,pVal)	\
    ( (This)->lpVtbl -> get_iWriteToJournal(This,pVal) ) 

#define IVertexCtrl_put_iWriteToJournal(This,newVal)	\
    ( (This)->lpVtbl -> put_iWriteToJournal(This,newVal) ) 

#define IVertexCtrl_Reconnect(This,bstrResults)	\
    ( (This)->lpVtbl -> Reconnect(This,bstrResults) ) 

#define IVertexCtrl_Refresh(This,bstrResults)	\
    ( (This)->lpVtbl -> Refresh(This,bstrResults) ) 

#endif /* COBJMACROS */


#endif 	/* C style interface */




#endif 	/* __IVertexCtrl_INTERFACE_DEFINED__ */



#ifndef __VertexATLWrapperLib_LIBRARY_DEFINED__
#define __VertexATLWrapperLib_LIBRARY_DEFINED__

/* library VertexATLWrapperLib */
/* [helpstring][version][uuid] */ 


EXTERN_C const IID LIBID_VertexATLWrapperLib;

EXTERN_C const CLSID CLSID_VertexCtrl;

#ifdef __cplusplus

class DECLSPEC_UUID("0E6FCBAD-34CB-438B-A2C1-EFA071A3B7EA")
VertexCtrl;
#endif
#endif /* __VertexATLWrapperLib_LIBRARY_DEFINED__ */

/* Additional Prototypes for ALL interfaces */

unsigned long             __RPC_USER  BSTR_UserSize(     unsigned long *, unsigned long            , BSTR * ); 
unsigned char * __RPC_USER  BSTR_UserMarshal(  unsigned long *, unsigned char *, BSTR * ); 
unsigned char * __RPC_USER  BSTR_UserUnmarshal(unsigned long *, unsigned char *, BSTR * ); 
void                      __RPC_USER  BSTR_UserFree(     unsigned long *, BSTR * ); 

/* end of Additional Prototypes */

#ifdef __cplusplus
}
#endif

#endif


