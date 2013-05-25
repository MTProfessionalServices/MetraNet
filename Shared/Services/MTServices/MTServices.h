/* this ALWAYS GENERATED file contains the definitions for the interfaces */


/* File created by MIDL compiler version 3.01.75 */
/* at Thu Jan 07 14:50:46 1999
 */
/* Compiler settings for MTServices.idl:
    Oicf (OptLev=i2), W1, Zp8, env=Win32, ms_ext, c_ext
    error checks: none
*/
//@@MIDL_FILE_HEADING(  )
#include "rpc.h"
#include "rpcndr.h"
#ifndef COM_NO_WINDOWS_H
#include "windows.h"
#include "ole2.h"
#endif /*COM_NO_WINDOWS_H*/

#ifndef __MTServices_h__
#define __MTServices_h__

#ifdef __cplusplus
extern "C"{
#endif 

/* Forward Declarations */ 

#ifndef __IMTServicesDef_FWD_DEFINED__
#define __IMTServicesDef_FWD_DEFINED__
typedef interface IMTServicesDef IMTServicesDef;
#endif 	/* __IMTServicesDef_FWD_DEFINED__ */


#ifndef __MTServicesDef_FWD_DEFINED__
#define __MTServicesDef_FWD_DEFINED__

#ifdef __cplusplus
typedef class MTServicesDef MTServicesDef;
#else
typedef struct MTServicesDef MTServicesDef;
#endif /* __cplusplus */

#endif 	/* __MTServicesDef_FWD_DEFINED__ */


/* header files for imported files */
#include "oaidl.h"
#include "ocidl.h"

void __RPC_FAR * __RPC_USER MIDL_user_allocate(size_t);
void __RPC_USER MIDL_user_free( void __RPC_FAR * ); 

#ifndef __IMTServicesDef_INTERFACE_DEFINED__
#define __IMTServicesDef_INTERFACE_DEFINED__

/****************************************
 * Generated header for interface: IMTServicesDef
 * at Thu Jan 07 14:50:46 1999
 * using MIDL 3.01.75
 ****************************************/
/* [unique][helpstring][dual][uuid][object] */ 



EXTERN_C const IID IID_IMTServicesDef;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    interface DECLSPEC_UUID("2A54584F-A4CB-11D2-B297-006008925549")
    IMTServicesDef : public IDispatch
    {
    public:
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE Save( void) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_dn( 
            /* [retval][out] */ BSTR __RPC_FAR *pVal) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_dn( 
            /* [in] */ BSTR newVal) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_type( 
            /* [retval][out] */ BSTR __RPC_FAR *pVal) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_type( 
            /* [in] */ BSTR newVal) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_length( 
            /* [retval][out] */ long __RPC_FAR *pVal) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_length( 
            /* [in] */ long newVal) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_required( 
            /* [retval][out] */ BSTR __RPC_FAR *pVal) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_required( 
            /* [in] */ BSTR newVal) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_defaultVal( 
            /* [retval][out] */ BSTR __RPC_FAR *pVal) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_defaultVal( 
            /* [in] */ BSTR newVal) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_name( 
            /* [retval][out] */ BSTR __RPC_FAR *pVal) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_name( 
            /* [in] */ BSTR newVal) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_majorversion( 
            /* [retval][out] */ BSTR __RPC_FAR *pVal) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_majorversion( 
            /* [in] */ BSTR newVal) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_minorversion( 
            /* [retval][out] */ BSTR __RPC_FAR *pVal) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_minorversion( 
            /* [in] */ BSTR newVal) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_tablename( 
            /* [retval][out] */ BSTR __RPC_FAR *pVal) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_tablename( 
            /* [in] */ BSTR newVal) = 0;
        
        virtual /* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE get_exttablename( 
            /* [retval][out] */ BSTR __RPC_FAR *pVal) = 0;
        
        virtual /* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE put_exttablename( 
            /* [in] */ BSTR newVal) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE Initialize( void) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE AddProperty( 
            BSTR dn,
            BSTR type,
            BSTR length,
            BSTR required,
            BSTR defaultVal) = 0;
        
    };
    
#else 	/* C style interface */

    typedef struct IMTServicesDefVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *QueryInterface )( 
            IMTServicesDef __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppvObject);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *AddRef )( 
            IMTServicesDef __RPC_FAR * This);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *Release )( 
            IMTServicesDef __RPC_FAR * This);
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetTypeInfoCount )( 
            IMTServicesDef __RPC_FAR * This,
            /* [out] */ UINT __RPC_FAR *pctinfo);
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetTypeInfo )( 
            IMTServicesDef __RPC_FAR * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo __RPC_FAR *__RPC_FAR *ppTInfo);
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetIDsOfNames )( 
            IMTServicesDef __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR __RPC_FAR *rgszNames,
            /* [in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID __RPC_FAR *rgDispId);
        
        /* [local] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *Invoke )( 
            IMTServicesDef __RPC_FAR * This,
            /* [in] */ DISPID dispIdMember,
            /* [in] */ REFIID riid,
            /* [in] */ LCID lcid,
            /* [in] */ WORD wFlags,
            /* [out][in] */ DISPPARAMS __RPC_FAR *pDispParams,
            /* [out] */ VARIANT __RPC_FAR *pVarResult,
            /* [out] */ EXCEPINFO __RPC_FAR *pExcepInfo,
            /* [out] */ UINT __RPC_FAR *puArgErr);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *Save )( 
            IMTServicesDef __RPC_FAR * This);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_dn )( 
            IMTServicesDef __RPC_FAR * This,
            /* [retval][out] */ BSTR __RPC_FAR *pVal);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_dn )( 
            IMTServicesDef __RPC_FAR * This,
            /* [in] */ BSTR newVal);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_type )( 
            IMTServicesDef __RPC_FAR * This,
            /* [retval][out] */ BSTR __RPC_FAR *pVal);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_type )( 
            IMTServicesDef __RPC_FAR * This,
            /* [in] */ BSTR newVal);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_length )( 
            IMTServicesDef __RPC_FAR * This,
            /* [retval][out] */ long __RPC_FAR *pVal);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_length )( 
            IMTServicesDef __RPC_FAR * This,
            /* [in] */ long newVal);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_required )( 
            IMTServicesDef __RPC_FAR * This,
            /* [retval][out] */ BSTR __RPC_FAR *pVal);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_required )( 
            IMTServicesDef __RPC_FAR * This,
            /* [in] */ BSTR newVal);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_defaultVal )( 
            IMTServicesDef __RPC_FAR * This,
            /* [retval][out] */ BSTR __RPC_FAR *pVal);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_defaultVal )( 
            IMTServicesDef __RPC_FAR * This,
            /* [in] */ BSTR newVal);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_name )( 
            IMTServicesDef __RPC_FAR * This,
            /* [retval][out] */ BSTR __RPC_FAR *pVal);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_name )( 
            IMTServicesDef __RPC_FAR * This,
            /* [in] */ BSTR newVal);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_majorversion )( 
            IMTServicesDef __RPC_FAR * This,
            /* [retval][out] */ BSTR __RPC_FAR *pVal);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_majorversion )( 
            IMTServicesDef __RPC_FAR * This,
            /* [in] */ BSTR newVal);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_minorversion )( 
            IMTServicesDef __RPC_FAR * This,
            /* [retval][out] */ BSTR __RPC_FAR *pVal);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_minorversion )( 
            IMTServicesDef __RPC_FAR * This,
            /* [in] */ BSTR newVal);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_tablename )( 
            IMTServicesDef __RPC_FAR * This,
            /* [retval][out] */ BSTR __RPC_FAR *pVal);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_tablename )( 
            IMTServicesDef __RPC_FAR * This,
            /* [in] */ BSTR newVal);
        
        /* [helpstring][id][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_exttablename )( 
            IMTServicesDef __RPC_FAR * This,
            /* [retval][out] */ BSTR __RPC_FAR *pVal);
        
        /* [helpstring][id][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_exttablename )( 
            IMTServicesDef __RPC_FAR * This,
            /* [in] */ BSTR newVal);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *Initialize )( 
            IMTServicesDef __RPC_FAR * This);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *AddProperty )( 
            IMTServicesDef __RPC_FAR * This,
            BSTR dn,
            BSTR type,
            BSTR length,
            BSTR required,
            BSTR defaultVal);
        
        END_INTERFACE
    } IMTServicesDefVtbl;

    interface IMTServicesDef
    {
        CONST_VTBL struct IMTServicesDefVtbl __RPC_FAR *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IMTServicesDef_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define IMTServicesDef_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define IMTServicesDef_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define IMTServicesDef_GetTypeInfoCount(This,pctinfo)	\
    (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo)

#define IMTServicesDef_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo)

#define IMTServicesDef_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)

#define IMTServicesDef_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)


#define IMTServicesDef_Save(This)	\
    (This)->lpVtbl -> Save(This)

#define IMTServicesDef_get_dn(This,pVal)	\
    (This)->lpVtbl -> get_dn(This,pVal)

#define IMTServicesDef_put_dn(This,newVal)	\
    (This)->lpVtbl -> put_dn(This,newVal)

#define IMTServicesDef_get_type(This,pVal)	\
    (This)->lpVtbl -> get_type(This,pVal)

#define IMTServicesDef_put_type(This,newVal)	\
    (This)->lpVtbl -> put_type(This,newVal)

#define IMTServicesDef_get_length(This,pVal)	\
    (This)->lpVtbl -> get_length(This,pVal)

#define IMTServicesDef_put_length(This,newVal)	\
    (This)->lpVtbl -> put_length(This,newVal)

#define IMTServicesDef_get_required(This,pVal)	\
    (This)->lpVtbl -> get_required(This,pVal)

#define IMTServicesDef_put_required(This,newVal)	\
    (This)->lpVtbl -> put_required(This,newVal)

#define IMTServicesDef_get_defaultVal(This,pVal)	\
    (This)->lpVtbl -> get_defaultVal(This,pVal)

#define IMTServicesDef_put_defaultVal(This,newVal)	\
    (This)->lpVtbl -> put_defaultVal(This,newVal)

#define IMTServicesDef_get_name(This,pVal)	\
    (This)->lpVtbl -> get_name(This,pVal)

#define IMTServicesDef_put_name(This,newVal)	\
    (This)->lpVtbl -> put_name(This,newVal)

#define IMTServicesDef_get_majorversion(This,pVal)	\
    (This)->lpVtbl -> get_majorversion(This,pVal)

#define IMTServicesDef_put_majorversion(This,newVal)	\
    (This)->lpVtbl -> put_majorversion(This,newVal)

#define IMTServicesDef_get_minorversion(This,pVal)	\
    (This)->lpVtbl -> get_minorversion(This,pVal)

#define IMTServicesDef_put_minorversion(This,newVal)	\
    (This)->lpVtbl -> put_minorversion(This,newVal)

#define IMTServicesDef_get_tablename(This,pVal)	\
    (This)->lpVtbl -> get_tablename(This,pVal)

#define IMTServicesDef_put_tablename(This,newVal)	\
    (This)->lpVtbl -> put_tablename(This,newVal)

#define IMTServicesDef_get_exttablename(This,pVal)	\
    (This)->lpVtbl -> get_exttablename(This,pVal)

#define IMTServicesDef_put_exttablename(This,newVal)	\
    (This)->lpVtbl -> put_exttablename(This,newVal)

#define IMTServicesDef_Initialize(This)	\
    (This)->lpVtbl -> Initialize(This)

#define IMTServicesDef_AddProperty(This,dn,type,length,required,defaultVal)	\
    (This)->lpVtbl -> AddProperty(This,dn,type,length,required,defaultVal)

#endif /* COBJMACROS */


#endif 	/* C style interface */



/* [helpstring][id] */ HRESULT STDMETHODCALLTYPE IMTServicesDef_Save_Proxy( 
    IMTServicesDef __RPC_FAR * This);


void __RPC_STUB IMTServicesDef_Save_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE IMTServicesDef_get_dn_Proxy( 
    IMTServicesDef __RPC_FAR * This,
    /* [retval][out] */ BSTR __RPC_FAR *pVal);


void __RPC_STUB IMTServicesDef_get_dn_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE IMTServicesDef_put_dn_Proxy( 
    IMTServicesDef __RPC_FAR * This,
    /* [in] */ BSTR newVal);


void __RPC_STUB IMTServicesDef_put_dn_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE IMTServicesDef_get_type_Proxy( 
    IMTServicesDef __RPC_FAR * This,
    /* [retval][out] */ BSTR __RPC_FAR *pVal);


void __RPC_STUB IMTServicesDef_get_type_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE IMTServicesDef_put_type_Proxy( 
    IMTServicesDef __RPC_FAR * This,
    /* [in] */ BSTR newVal);


void __RPC_STUB IMTServicesDef_put_type_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE IMTServicesDef_get_length_Proxy( 
    IMTServicesDef __RPC_FAR * This,
    /* [retval][out] */ long __RPC_FAR *pVal);


void __RPC_STUB IMTServicesDef_get_length_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE IMTServicesDef_put_length_Proxy( 
    IMTServicesDef __RPC_FAR * This,
    /* [in] */ long newVal);


void __RPC_STUB IMTServicesDef_put_length_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE IMTServicesDef_get_required_Proxy( 
    IMTServicesDef __RPC_FAR * This,
    /* [retval][out] */ BSTR __RPC_FAR *pVal);


void __RPC_STUB IMTServicesDef_get_required_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE IMTServicesDef_put_required_Proxy( 
    IMTServicesDef __RPC_FAR * This,
    /* [in] */ BSTR newVal);


void __RPC_STUB IMTServicesDef_put_required_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE IMTServicesDef_get_defaultVal_Proxy( 
    IMTServicesDef __RPC_FAR * This,
    /* [retval][out] */ BSTR __RPC_FAR *pVal);


void __RPC_STUB IMTServicesDef_get_defaultVal_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE IMTServicesDef_put_defaultVal_Proxy( 
    IMTServicesDef __RPC_FAR * This,
    /* [in] */ BSTR newVal);


void __RPC_STUB IMTServicesDef_put_defaultVal_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE IMTServicesDef_get_name_Proxy( 
    IMTServicesDef __RPC_FAR * This,
    /* [retval][out] */ BSTR __RPC_FAR *pVal);


void __RPC_STUB IMTServicesDef_get_name_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE IMTServicesDef_put_name_Proxy( 
    IMTServicesDef __RPC_FAR * This,
    /* [in] */ BSTR newVal);


void __RPC_STUB IMTServicesDef_put_name_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE IMTServicesDef_get_majorversion_Proxy( 
    IMTServicesDef __RPC_FAR * This,
    /* [retval][out] */ BSTR __RPC_FAR *pVal);


void __RPC_STUB IMTServicesDef_get_majorversion_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE IMTServicesDef_put_majorversion_Proxy( 
    IMTServicesDef __RPC_FAR * This,
    /* [in] */ BSTR newVal);


void __RPC_STUB IMTServicesDef_put_majorversion_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE IMTServicesDef_get_minorversion_Proxy( 
    IMTServicesDef __RPC_FAR * This,
    /* [retval][out] */ BSTR __RPC_FAR *pVal);


void __RPC_STUB IMTServicesDef_get_minorversion_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE IMTServicesDef_put_minorversion_Proxy( 
    IMTServicesDef __RPC_FAR * This,
    /* [in] */ BSTR newVal);


void __RPC_STUB IMTServicesDef_put_minorversion_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE IMTServicesDef_get_tablename_Proxy( 
    IMTServicesDef __RPC_FAR * This,
    /* [retval][out] */ BSTR __RPC_FAR *pVal);


void __RPC_STUB IMTServicesDef_get_tablename_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE IMTServicesDef_put_tablename_Proxy( 
    IMTServicesDef __RPC_FAR * This,
    /* [in] */ BSTR newVal);


void __RPC_STUB IMTServicesDef_put_tablename_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propget] */ HRESULT STDMETHODCALLTYPE IMTServicesDef_get_exttablename_Proxy( 
    IMTServicesDef __RPC_FAR * This,
    /* [retval][out] */ BSTR __RPC_FAR *pVal);


void __RPC_STUB IMTServicesDef_get_exttablename_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id][propput] */ HRESULT STDMETHODCALLTYPE IMTServicesDef_put_exttablename_Proxy( 
    IMTServicesDef __RPC_FAR * This,
    /* [in] */ BSTR newVal);


void __RPC_STUB IMTServicesDef_put_exttablename_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id] */ HRESULT STDMETHODCALLTYPE IMTServicesDef_Initialize_Proxy( 
    IMTServicesDef __RPC_FAR * This);


void __RPC_STUB IMTServicesDef_Initialize_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id] */ HRESULT STDMETHODCALLTYPE IMTServicesDef_AddProperty_Proxy( 
    IMTServicesDef __RPC_FAR * This,
    BSTR dn,
    BSTR type,
    BSTR length,
    BSTR required,
    BSTR defaultVal);


void __RPC_STUB IMTServicesDef_AddProperty_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);



#endif 	/* __IMTServicesDef_INTERFACE_DEFINED__ */



#ifndef __MTSERVICESLib_LIBRARY_DEFINED__
#define __MTSERVICESLib_LIBRARY_DEFINED__

/****************************************
 * Generated header for library: MTSERVICESLib
 * at Thu Jan 07 14:50:46 1999
 * using MIDL 3.01.75
 ****************************************/
/* [helpstring][version][uuid] */ 



EXTERN_C const IID LIBID_MTSERVICESLib;

#ifdef __cplusplus
EXTERN_C const CLSID CLSID_MTServicesDef;

class DECLSPEC_UUID("2A545850-A4CB-11D2-B297-006008925549")
MTServicesDef;
#endif
#endif /* __MTSERVICESLib_LIBRARY_DEFINED__ */

/* Additional Prototypes for ALL interfaces */

unsigned long             __RPC_USER  BSTR_UserSize(     unsigned long __RPC_FAR *, unsigned long            , BSTR __RPC_FAR * ); 
unsigned char __RPC_FAR * __RPC_USER  BSTR_UserMarshal(  unsigned long __RPC_FAR *, unsigned char __RPC_FAR *, BSTR __RPC_FAR * ); 
unsigned char __RPC_FAR * __RPC_USER  BSTR_UserUnmarshal(unsigned long __RPC_FAR *, unsigned char __RPC_FAR *, BSTR __RPC_FAR * ); 
void                      __RPC_USER  BSTR_UserFree(     unsigned long __RPC_FAR *, BSTR __RPC_FAR * ); 

/* end of Additional Prototypes */

#ifdef __cplusplus
}
#endif

#endif
