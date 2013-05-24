/* this ALWAYS GENERATED file contains the definitions for the interfaces */


/* File created by MIDL compiler version 3.01.75 */
/* at Thu Aug 27 21:56:08 1998
 */
/* Compiler settings for D:\SBN\Samples\components\spruuids\spruuids.odl:
    Os (OptLev=s), W1, Zp8, env=Win32, ms_ext, c_ext
    error checks: none
*/
//@@MIDL_FILE_HEADING(  )
#include "rpc.h"
#include "rpcndr.h"

#ifndef __Spruuids_h__
#define __Spruuids_h__

#ifdef __cplusplus
extern "C"{
#endif 

/* Forward Declarations */ 

#ifndef __ISpruuidsApp_FWD_DEFINED__
#define __ISpruuidsApp_FWD_DEFINED__
typedef interface ISpruuidsApp ISpruuidsApp;
#endif 	/* __ISpruuidsApp_FWD_DEFINED__ */


#ifndef __IGame_FWD_DEFINED__
#define __IGame_FWD_DEFINED__
typedef interface IGame IGame;
#endif 	/* __IGame_FWD_DEFINED__ */


#ifndef __IGameEvents_FWD_DEFINED__
#define __IGameEvents_FWD_DEFINED__
typedef interface IGameEvents IGameEvents;
#endif 	/* __IGameEvents_FWD_DEFINED__ */


#ifndef __ISpriteClass_FWD_DEFINED__
#define __ISpriteClass_FWD_DEFINED__
typedef interface ISpriteClass ISpriteClass;
#endif 	/* __ISpriteClass_FWD_DEFINED__ */


#ifndef __ISpriteClassEvents_FWD_DEFINED__
#define __ISpriteClassEvents_FWD_DEFINED__
typedef interface ISpriteClassEvents ISpriteClassEvents;
#endif 	/* __ISpriteClassEvents_FWD_DEFINED__ */


#ifndef __ISprite_FWD_DEFINED__
#define __ISprite_FWD_DEFINED__
typedef interface ISprite ISprite;
#endif 	/* __ISprite_FWD_DEFINED__ */


#ifndef __SpruuidsApp_FWD_DEFINED__
#define __SpruuidsApp_FWD_DEFINED__

#ifdef __cplusplus
typedef class SpruuidsApp SpruuidsApp;
#else
typedef struct SpruuidsApp SpruuidsApp;
#endif /* __cplusplus */

#endif 	/* __SpruuidsApp_FWD_DEFINED__ */


#ifndef __Game_FWD_DEFINED__
#define __Game_FWD_DEFINED__

#ifdef __cplusplus
typedef class Game Game;
#else
typedef struct Game Game;
#endif /* __cplusplus */

#endif 	/* __Game_FWD_DEFINED__ */


#ifndef __SpriteClass_FWD_DEFINED__
#define __SpriteClass_FWD_DEFINED__

#ifdef __cplusplus
typedef class SpriteClass SpriteClass;
#else
typedef struct SpriteClass SpriteClass;
#endif /* __cplusplus */

#endif 	/* __SpriteClass_FWD_DEFINED__ */


#ifndef __Sprite_FWD_DEFINED__
#define __Sprite_FWD_DEFINED__

#ifdef __cplusplus
typedef class Sprite Sprite;
#else
typedef struct Sprite Sprite;
#endif /* __cplusplus */

#endif 	/* __Sprite_FWD_DEFINED__ */


void __RPC_FAR * __RPC_USER MIDL_user_allocate(size_t);
void __RPC_USER MIDL_user_free( void __RPC_FAR * ); 


#ifndef __SPRUUIDS_LIBRARY_DEFINED__
#define __SPRUUIDS_LIBRARY_DEFINED__

/****************************************
 * Generated header for library: SPRUUIDS
 * at Thu Aug 27 21:56:08 1998
 * using MIDL 3.01.75
 ****************************************/
/* [version][uuid] */ 













DEFINE_GUID(LIBID_SPRUUIDS,0x8703FF61,0x669C,0x11cf,0xA9,0x2B,0x00,0xAA,0x00,0x68,0x8A,0x2F);

#ifndef __ISpruuidsApp_INTERFACE_DEFINED__
#define __ISpruuidsApp_INTERFACE_DEFINED__

/****************************************
 * Generated header for interface: ISpruuidsApp
 * at Thu Aug 27 21:56:08 1998
 * using MIDL 3.01.75
 ****************************************/
/* [object][dual][uuid] */ 



DEFINE_GUID(IID_ISpruuidsApp,0x8703FF62,0x669C,0x11cf,0xA9,0x2B,0x00,0xAA,0x00,0x68,0x8A,0x2F);

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    interface DECLSPEC_UUID("8703FF62-669C-11cf-A92B-00AA00688A2F")
    ISpruuidsApp : public IDispatch
    {
    public:
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Application( 
            /* [retval][out] */ ISpruuidsApp __RPC_FAR *__RPC_FAR *ppRet) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Parent( 
            /* [retval][out] */ ISpruuidsApp __RPC_FAR *__RPC_FAR *ppRet) = 0;
        
        virtual /* [id] */ HRESULT STDMETHODCALLTYPE Quit( void) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Game( 
            /* [retval][out] */ IGame __RPC_FAR *__RPC_FAR *ppRet) = 0;
        
    };
    
#else 	/* C style interface */

    typedef struct ISpruuidsAppVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *QueryInterface )( 
            ISpruuidsApp __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppvObject);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *AddRef )( 
            ISpruuidsApp __RPC_FAR * This);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *Release )( 
            ISpruuidsApp __RPC_FAR * This);
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetTypeInfoCount )( 
            ISpruuidsApp __RPC_FAR * This,
            /* [out] */ UINT __RPC_FAR *pctinfo);
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetTypeInfo )( 
            ISpruuidsApp __RPC_FAR * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo __RPC_FAR *__RPC_FAR *ppTInfo);
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetIDsOfNames )( 
            ISpruuidsApp __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR __RPC_FAR *rgszNames,
            /* [in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID __RPC_FAR *rgDispId);
        
        /* [local] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *Invoke )( 
            ISpruuidsApp __RPC_FAR * This,
            /* [in] */ DISPID dispIdMember,
            /* [in] */ REFIID riid,
            /* [in] */ LCID lcid,
            /* [in] */ WORD wFlags,
            /* [out][in] */ DISPPARAMS __RPC_FAR *pDispParams,
            /* [out] */ VARIANT __RPC_FAR *pVarResult,
            /* [out] */ EXCEPINFO __RPC_FAR *pExcepInfo,
            /* [out] */ UINT __RPC_FAR *puArgErr);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Application )( 
            ISpruuidsApp __RPC_FAR * This,
            /* [retval][out] */ ISpruuidsApp __RPC_FAR *__RPC_FAR *ppRet);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Parent )( 
            ISpruuidsApp __RPC_FAR * This,
            /* [retval][out] */ ISpruuidsApp __RPC_FAR *__RPC_FAR *ppRet);
        
        /* [id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *Quit )( 
            ISpruuidsApp __RPC_FAR * This);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Game )( 
            ISpruuidsApp __RPC_FAR * This,
            /* [retval][out] */ IGame __RPC_FAR *__RPC_FAR *ppRet);
        
        END_INTERFACE
    } ISpruuidsAppVtbl;

    interface ISpruuidsApp
    {
        CONST_VTBL struct ISpruuidsAppVtbl __RPC_FAR *lpVtbl;
    };

    

#ifdef COBJMACROS


#define ISpruuidsApp_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define ISpruuidsApp_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define ISpruuidsApp_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define ISpruuidsApp_GetTypeInfoCount(This,pctinfo)	\
    (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo)

#define ISpruuidsApp_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo)

#define ISpruuidsApp_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)

#define ISpruuidsApp_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)


#define ISpruuidsApp_get_Application(This,ppRet)	\
    (This)->lpVtbl -> get_Application(This,ppRet)

#define ISpruuidsApp_get_Parent(This,ppRet)	\
    (This)->lpVtbl -> get_Parent(This,ppRet)

#define ISpruuidsApp_Quit(This)	\
    (This)->lpVtbl -> Quit(This)

#define ISpruuidsApp_get_Game(This,ppRet)	\
    (This)->lpVtbl -> get_Game(This,ppRet)

#endif /* COBJMACROS */


#endif 	/* C style interface */



/* [propget][id] */ HRESULT STDMETHODCALLTYPE ISpruuidsApp_get_Application_Proxy( 
    ISpruuidsApp __RPC_FAR * This,
    /* [retval][out] */ ISpruuidsApp __RPC_FAR *__RPC_FAR *ppRet);


void __RPC_STUB ISpruuidsApp_get_Application_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE ISpruuidsApp_get_Parent_Proxy( 
    ISpruuidsApp __RPC_FAR * This,
    /* [retval][out] */ ISpruuidsApp __RPC_FAR *__RPC_FAR *ppRet);


void __RPC_STUB ISpruuidsApp_get_Parent_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [id] */ HRESULT STDMETHODCALLTYPE ISpruuidsApp_Quit_Proxy( 
    ISpruuidsApp __RPC_FAR * This);


void __RPC_STUB ISpruuidsApp_Quit_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE ISpruuidsApp_get_Game_Proxy( 
    ISpruuidsApp __RPC_FAR * This,
    /* [retval][out] */ IGame __RPC_FAR *__RPC_FAR *ppRet);


void __RPC_STUB ISpruuidsApp_get_Game_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);



#endif 	/* __ISpruuidsApp_INTERFACE_DEFINED__ */


#ifndef __IGame_INTERFACE_DEFINED__
#define __IGame_INTERFACE_DEFINED__

/****************************************
 * Generated header for interface: IGame
 * at Thu Aug 27 21:56:08 1998
 * using MIDL 3.01.75
 ****************************************/
/* [object][dual][uuid] */ 



DEFINE_GUID(IID_IGame,0x8703FF64,0x669C,0x11cf,0xA9,0x2B,0x00,0xAA,0x00,0x68,0x8A,0x2F);

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    interface DECLSPEC_UUID("8703FF64-669C-11cf-A92B-00AA00688A2F")
    IGame : public IDispatch
    {
    public:
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Caption( 
            /* [retval][out] */ BSTR __RPC_FAR *pbstrReturn) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Caption( 
            /* [in] */ BSTR bstr) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Application( 
            /* [retval][out] */ ISpruuidsApp __RPC_FAR *__RPC_FAR *ppRet) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Parent( 
            /* [retval][out] */ ISpruuidsApp __RPC_FAR *__RPC_FAR *ppRet) = 0;
        
        virtual /* [id] */ HRESULT STDMETHODCALLTYPE StartGame( void) = 0;
        
        virtual /* [id] */ HRESULT STDMETHODCALLTYPE EndGame( void) = 0;
        
        virtual /* [id] */ HRESULT STDMETHODCALLTYPE RemoveAllSprites( void) = 0;
        
        virtual /* [id] */ HRESULT STDMETHODCALLTYPE NextLevel( void) = 0;
        
        virtual /* [id] */ HRESULT STDMETHODCALLTYPE Refresh( void) = 0;
        
        virtual /* [id] */ HRESULT STDMETHODCALLTYPE AddScore( 
            /* [in] */ int val) = 0;
        
        virtual /* [id] */ HRESULT STDMETHODCALLTYPE StdBorderBounce( 
            /* [in] */ ISprite __RPC_FAR *pspr,
            /* [in] */ int brd) = 0;
        
        virtual /* [id] */ HRESULT STDMETHODCALLTYPE StdBorderWrap( 
            /* [in] */ ISprite __RPC_FAR *pspr,
            /* [in] */ int brd) = 0;
        
        virtual /* [id] */ HRESULT STDMETHODCALLTYPE StdInitRand( 
            /* [in] */ ISprite __RPC_FAR *pspr,
            /* [in] */ VARIANT user) = 0;
        
        virtual /* [id] */ HRESULT STDMETHODCALLTYPE StdInitEdge( 
            /* [in] */ ISprite __RPC_FAR *pspr,
            /* [in] */ VARIANT user) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Paused( 
            /* [retval][out] */ VARIANT_BOOL __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Paused( 
            /* [in] */ VARIANT_BOOL val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Width( 
            /* [retval][out] */ int __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Width( 
            /* [in] */ int val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Height( 
            /* [retval][out] */ int __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Height( 
            /* [in] */ int val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_BackColor( 
            /* [retval][out] */ long __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_BackColor( 
            /* [in] */ long val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Score( 
            /* [retval][out] */ int __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Score( 
            /* [in] */ int val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Level( 
            /* [retval][out] */ int __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Level( 
            /* [in] */ int val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_ShipCount( 
            /* [retval][out] */ int __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_ShipCount( 
            /* [in] */ int val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_ScoreFirst1Up( 
            /* [retval][out] */ int __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_ScoreFirst1Up( 
            /* [in] */ int val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_ScoreSecond1Up( 
            /* [retval][out] */ int __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_ScoreSecond1Up( 
            /* [in] */ int val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_DScoreNext1Up( 
            /* [retval][out] */ int __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_DScoreNext1Up( 
            /* [in] */ int val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_ShipsStart( 
            /* [retval][out] */ int __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_ShipsStart( 
            /* [in] */ int val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Tag( 
            /* [retval][out] */ VARIANT __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Tag( 
            /* [in] */ VARIANT val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_StatusText( 
            /* [retval][out] */ BSTR __RPC_FAR *pbstrReturn) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_StatusText( 
            /* [in] */ BSTR bstr) = 0;
        
    };
    
#else 	/* C style interface */

    typedef struct IGameVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *QueryInterface )( 
            IGame __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppvObject);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *AddRef )( 
            IGame __RPC_FAR * This);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *Release )( 
            IGame __RPC_FAR * This);
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetTypeInfoCount )( 
            IGame __RPC_FAR * This,
            /* [out] */ UINT __RPC_FAR *pctinfo);
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetTypeInfo )( 
            IGame __RPC_FAR * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo __RPC_FAR *__RPC_FAR *ppTInfo);
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetIDsOfNames )( 
            IGame __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR __RPC_FAR *rgszNames,
            /* [in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID __RPC_FAR *rgDispId);
        
        /* [local] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *Invoke )( 
            IGame __RPC_FAR * This,
            /* [in] */ DISPID dispIdMember,
            /* [in] */ REFIID riid,
            /* [in] */ LCID lcid,
            /* [in] */ WORD wFlags,
            /* [out][in] */ DISPPARAMS __RPC_FAR *pDispParams,
            /* [out] */ VARIANT __RPC_FAR *pVarResult,
            /* [out] */ EXCEPINFO __RPC_FAR *pExcepInfo,
            /* [out] */ UINT __RPC_FAR *puArgErr);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Caption )( 
            IGame __RPC_FAR * This,
            /* [retval][out] */ BSTR __RPC_FAR *pbstrReturn);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_Caption )( 
            IGame __RPC_FAR * This,
            /* [in] */ BSTR bstr);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Application )( 
            IGame __RPC_FAR * This,
            /* [retval][out] */ ISpruuidsApp __RPC_FAR *__RPC_FAR *ppRet);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Parent )( 
            IGame __RPC_FAR * This,
            /* [retval][out] */ ISpruuidsApp __RPC_FAR *__RPC_FAR *ppRet);
        
        /* [id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *StartGame )( 
            IGame __RPC_FAR * This);
        
        /* [id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *EndGame )( 
            IGame __RPC_FAR * This);
        
        /* [id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *RemoveAllSprites )( 
            IGame __RPC_FAR * This);
        
        /* [id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *NextLevel )( 
            IGame __RPC_FAR * This);
        
        /* [id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *Refresh )( 
            IGame __RPC_FAR * This);
        
        /* [id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *AddScore )( 
            IGame __RPC_FAR * This,
            /* [in] */ int val);
        
        /* [id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *StdBorderBounce )( 
            IGame __RPC_FAR * This,
            /* [in] */ ISprite __RPC_FAR *pspr,
            /* [in] */ int brd);
        
        /* [id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *StdBorderWrap )( 
            IGame __RPC_FAR * This,
            /* [in] */ ISprite __RPC_FAR *pspr,
            /* [in] */ int brd);
        
        /* [id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *StdInitRand )( 
            IGame __RPC_FAR * This,
            /* [in] */ ISprite __RPC_FAR *pspr,
            /* [in] */ VARIANT user);
        
        /* [id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *StdInitEdge )( 
            IGame __RPC_FAR * This,
            /* [in] */ ISprite __RPC_FAR *pspr,
            /* [in] */ VARIANT user);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Paused )( 
            IGame __RPC_FAR * This,
            /* [retval][out] */ VARIANT_BOOL __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_Paused )( 
            IGame __RPC_FAR * This,
            /* [in] */ VARIANT_BOOL val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Width )( 
            IGame __RPC_FAR * This,
            /* [retval][out] */ int __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_Width )( 
            IGame __RPC_FAR * This,
            /* [in] */ int val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Height )( 
            IGame __RPC_FAR * This,
            /* [retval][out] */ int __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_Height )( 
            IGame __RPC_FAR * This,
            /* [in] */ int val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_BackColor )( 
            IGame __RPC_FAR * This,
            /* [retval][out] */ long __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_BackColor )( 
            IGame __RPC_FAR * This,
            /* [in] */ long val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Score )( 
            IGame __RPC_FAR * This,
            /* [retval][out] */ int __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_Score )( 
            IGame __RPC_FAR * This,
            /* [in] */ int val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Level )( 
            IGame __RPC_FAR * This,
            /* [retval][out] */ int __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_Level )( 
            IGame __RPC_FAR * This,
            /* [in] */ int val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_ShipCount )( 
            IGame __RPC_FAR * This,
            /* [retval][out] */ int __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_ShipCount )( 
            IGame __RPC_FAR * This,
            /* [in] */ int val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_ScoreFirst1Up )( 
            IGame __RPC_FAR * This,
            /* [retval][out] */ int __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_ScoreFirst1Up )( 
            IGame __RPC_FAR * This,
            /* [in] */ int val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_ScoreSecond1Up )( 
            IGame __RPC_FAR * This,
            /* [retval][out] */ int __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_ScoreSecond1Up )( 
            IGame __RPC_FAR * This,
            /* [in] */ int val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_DScoreNext1Up )( 
            IGame __RPC_FAR * This,
            /* [retval][out] */ int __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_DScoreNext1Up )( 
            IGame __RPC_FAR * This,
            /* [in] */ int val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_ShipsStart )( 
            IGame __RPC_FAR * This,
            /* [retval][out] */ int __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_ShipsStart )( 
            IGame __RPC_FAR * This,
            /* [in] */ int val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Tag )( 
            IGame __RPC_FAR * This,
            /* [retval][out] */ VARIANT __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_Tag )( 
            IGame __RPC_FAR * This,
            /* [in] */ VARIANT val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_StatusText )( 
            IGame __RPC_FAR * This,
            /* [retval][out] */ BSTR __RPC_FAR *pbstrReturn);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_StatusText )( 
            IGame __RPC_FAR * This,
            /* [in] */ BSTR bstr);
        
        END_INTERFACE
    } IGameVtbl;

    interface IGame
    {
        CONST_VTBL struct IGameVtbl __RPC_FAR *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IGame_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define IGame_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define IGame_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define IGame_GetTypeInfoCount(This,pctinfo)	\
    (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo)

#define IGame_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo)

#define IGame_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)

#define IGame_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)


#define IGame_get_Caption(This,pbstrReturn)	\
    (This)->lpVtbl -> get_Caption(This,pbstrReturn)

#define IGame_put_Caption(This,bstr)	\
    (This)->lpVtbl -> put_Caption(This,bstr)

#define IGame_get_Application(This,ppRet)	\
    (This)->lpVtbl -> get_Application(This,ppRet)

#define IGame_get_Parent(This,ppRet)	\
    (This)->lpVtbl -> get_Parent(This,ppRet)

#define IGame_StartGame(This)	\
    (This)->lpVtbl -> StartGame(This)

#define IGame_EndGame(This)	\
    (This)->lpVtbl -> EndGame(This)

#define IGame_RemoveAllSprites(This)	\
    (This)->lpVtbl -> RemoveAllSprites(This)

#define IGame_NextLevel(This)	\
    (This)->lpVtbl -> NextLevel(This)

#define IGame_Refresh(This)	\
    (This)->lpVtbl -> Refresh(This)

#define IGame_AddScore(This,val)	\
    (This)->lpVtbl -> AddScore(This,val)

#define IGame_StdBorderBounce(This,pspr,brd)	\
    (This)->lpVtbl -> StdBorderBounce(This,pspr,brd)

#define IGame_StdBorderWrap(This,pspr,brd)	\
    (This)->lpVtbl -> StdBorderWrap(This,pspr,brd)

#define IGame_StdInitRand(This,pspr,user)	\
    (This)->lpVtbl -> StdInitRand(This,pspr,user)

#define IGame_StdInitEdge(This,pspr,user)	\
    (This)->lpVtbl -> StdInitEdge(This,pspr,user)

#define IGame_get_Paused(This,pRet)	\
    (This)->lpVtbl -> get_Paused(This,pRet)

#define IGame_put_Paused(This,val)	\
    (This)->lpVtbl -> put_Paused(This,val)

#define IGame_get_Width(This,pRet)	\
    (This)->lpVtbl -> get_Width(This,pRet)

#define IGame_put_Width(This,val)	\
    (This)->lpVtbl -> put_Width(This,val)

#define IGame_get_Height(This,pRet)	\
    (This)->lpVtbl -> get_Height(This,pRet)

#define IGame_put_Height(This,val)	\
    (This)->lpVtbl -> put_Height(This,val)

#define IGame_get_BackColor(This,pRet)	\
    (This)->lpVtbl -> get_BackColor(This,pRet)

#define IGame_put_BackColor(This,val)	\
    (This)->lpVtbl -> put_BackColor(This,val)

#define IGame_get_Score(This,pRet)	\
    (This)->lpVtbl -> get_Score(This,pRet)

#define IGame_put_Score(This,val)	\
    (This)->lpVtbl -> put_Score(This,val)

#define IGame_get_Level(This,pRet)	\
    (This)->lpVtbl -> get_Level(This,pRet)

#define IGame_put_Level(This,val)	\
    (This)->lpVtbl -> put_Level(This,val)

#define IGame_get_ShipCount(This,pRet)	\
    (This)->lpVtbl -> get_ShipCount(This,pRet)

#define IGame_put_ShipCount(This,val)	\
    (This)->lpVtbl -> put_ShipCount(This,val)

#define IGame_get_ScoreFirst1Up(This,pRet)	\
    (This)->lpVtbl -> get_ScoreFirst1Up(This,pRet)

#define IGame_put_ScoreFirst1Up(This,val)	\
    (This)->lpVtbl -> put_ScoreFirst1Up(This,val)

#define IGame_get_ScoreSecond1Up(This,pRet)	\
    (This)->lpVtbl -> get_ScoreSecond1Up(This,pRet)

#define IGame_put_ScoreSecond1Up(This,val)	\
    (This)->lpVtbl -> put_ScoreSecond1Up(This,val)

#define IGame_get_DScoreNext1Up(This,pRet)	\
    (This)->lpVtbl -> get_DScoreNext1Up(This,pRet)

#define IGame_put_DScoreNext1Up(This,val)	\
    (This)->lpVtbl -> put_DScoreNext1Up(This,val)

#define IGame_get_ShipsStart(This,pRet)	\
    (This)->lpVtbl -> get_ShipsStart(This,pRet)

#define IGame_put_ShipsStart(This,val)	\
    (This)->lpVtbl -> put_ShipsStart(This,val)

#define IGame_get_Tag(This,pRet)	\
    (This)->lpVtbl -> get_Tag(This,pRet)

#define IGame_put_Tag(This,val)	\
    (This)->lpVtbl -> put_Tag(This,val)

#define IGame_get_StatusText(This,pbstrReturn)	\
    (This)->lpVtbl -> get_StatusText(This,pbstrReturn)

#define IGame_put_StatusText(This,bstr)	\
    (This)->lpVtbl -> put_StatusText(This,bstr)

#endif /* COBJMACROS */


#endif 	/* C style interface */



/* [propget][id] */ HRESULT STDMETHODCALLTYPE IGame_get_Caption_Proxy( 
    IGame __RPC_FAR * This,
    /* [retval][out] */ BSTR __RPC_FAR *pbstrReturn);


void __RPC_STUB IGame_get_Caption_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE IGame_put_Caption_Proxy( 
    IGame __RPC_FAR * This,
    /* [in] */ BSTR bstr);


void __RPC_STUB IGame_put_Caption_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE IGame_get_Application_Proxy( 
    IGame __RPC_FAR * This,
    /* [retval][out] */ ISpruuidsApp __RPC_FAR *__RPC_FAR *ppRet);


void __RPC_STUB IGame_get_Application_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE IGame_get_Parent_Proxy( 
    IGame __RPC_FAR * This,
    /* [retval][out] */ ISpruuidsApp __RPC_FAR *__RPC_FAR *ppRet);


void __RPC_STUB IGame_get_Parent_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [id] */ HRESULT STDMETHODCALLTYPE IGame_StartGame_Proxy( 
    IGame __RPC_FAR * This);


void __RPC_STUB IGame_StartGame_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [id] */ HRESULT STDMETHODCALLTYPE IGame_EndGame_Proxy( 
    IGame __RPC_FAR * This);


void __RPC_STUB IGame_EndGame_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [id] */ HRESULT STDMETHODCALLTYPE IGame_RemoveAllSprites_Proxy( 
    IGame __RPC_FAR * This);


void __RPC_STUB IGame_RemoveAllSprites_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [id] */ HRESULT STDMETHODCALLTYPE IGame_NextLevel_Proxy( 
    IGame __RPC_FAR * This);


void __RPC_STUB IGame_NextLevel_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [id] */ HRESULT STDMETHODCALLTYPE IGame_Refresh_Proxy( 
    IGame __RPC_FAR * This);


void __RPC_STUB IGame_Refresh_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [id] */ HRESULT STDMETHODCALLTYPE IGame_AddScore_Proxy( 
    IGame __RPC_FAR * This,
    /* [in] */ int val);


void __RPC_STUB IGame_AddScore_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [id] */ HRESULT STDMETHODCALLTYPE IGame_StdBorderBounce_Proxy( 
    IGame __RPC_FAR * This,
    /* [in] */ ISprite __RPC_FAR *pspr,
    /* [in] */ int brd);


void __RPC_STUB IGame_StdBorderBounce_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [id] */ HRESULT STDMETHODCALLTYPE IGame_StdBorderWrap_Proxy( 
    IGame __RPC_FAR * This,
    /* [in] */ ISprite __RPC_FAR *pspr,
    /* [in] */ int brd);


void __RPC_STUB IGame_StdBorderWrap_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [id] */ HRESULT STDMETHODCALLTYPE IGame_StdInitRand_Proxy( 
    IGame __RPC_FAR * This,
    /* [in] */ ISprite __RPC_FAR *pspr,
    /* [in] */ VARIANT user);


void __RPC_STUB IGame_StdInitRand_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [id] */ HRESULT STDMETHODCALLTYPE IGame_StdInitEdge_Proxy( 
    IGame __RPC_FAR * This,
    /* [in] */ ISprite __RPC_FAR *pspr,
    /* [in] */ VARIANT user);


void __RPC_STUB IGame_StdInitEdge_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE IGame_get_Paused_Proxy( 
    IGame __RPC_FAR * This,
    /* [retval][out] */ VARIANT_BOOL __RPC_FAR *pRet);


void __RPC_STUB IGame_get_Paused_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE IGame_put_Paused_Proxy( 
    IGame __RPC_FAR * This,
    /* [in] */ VARIANT_BOOL val);


void __RPC_STUB IGame_put_Paused_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE IGame_get_Width_Proxy( 
    IGame __RPC_FAR * This,
    /* [retval][out] */ int __RPC_FAR *pRet);


void __RPC_STUB IGame_get_Width_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE IGame_put_Width_Proxy( 
    IGame __RPC_FAR * This,
    /* [in] */ int val);


void __RPC_STUB IGame_put_Width_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE IGame_get_Height_Proxy( 
    IGame __RPC_FAR * This,
    /* [retval][out] */ int __RPC_FAR *pRet);


void __RPC_STUB IGame_get_Height_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE IGame_put_Height_Proxy( 
    IGame __RPC_FAR * This,
    /* [in] */ int val);


void __RPC_STUB IGame_put_Height_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE IGame_get_BackColor_Proxy( 
    IGame __RPC_FAR * This,
    /* [retval][out] */ long __RPC_FAR *pRet);


void __RPC_STUB IGame_get_BackColor_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE IGame_put_BackColor_Proxy( 
    IGame __RPC_FAR * This,
    /* [in] */ long val);


void __RPC_STUB IGame_put_BackColor_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE IGame_get_Score_Proxy( 
    IGame __RPC_FAR * This,
    /* [retval][out] */ int __RPC_FAR *pRet);


void __RPC_STUB IGame_get_Score_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE IGame_put_Score_Proxy( 
    IGame __RPC_FAR * This,
    /* [in] */ int val);


void __RPC_STUB IGame_put_Score_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE IGame_get_Level_Proxy( 
    IGame __RPC_FAR * This,
    /* [retval][out] */ int __RPC_FAR *pRet);


void __RPC_STUB IGame_get_Level_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE IGame_put_Level_Proxy( 
    IGame __RPC_FAR * This,
    /* [in] */ int val);


void __RPC_STUB IGame_put_Level_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE IGame_get_ShipCount_Proxy( 
    IGame __RPC_FAR * This,
    /* [retval][out] */ int __RPC_FAR *pRet);


void __RPC_STUB IGame_get_ShipCount_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE IGame_put_ShipCount_Proxy( 
    IGame __RPC_FAR * This,
    /* [in] */ int val);


void __RPC_STUB IGame_put_ShipCount_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE IGame_get_ScoreFirst1Up_Proxy( 
    IGame __RPC_FAR * This,
    /* [retval][out] */ int __RPC_FAR *pRet);


void __RPC_STUB IGame_get_ScoreFirst1Up_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE IGame_put_ScoreFirst1Up_Proxy( 
    IGame __RPC_FAR * This,
    /* [in] */ int val);


void __RPC_STUB IGame_put_ScoreFirst1Up_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE IGame_get_ScoreSecond1Up_Proxy( 
    IGame __RPC_FAR * This,
    /* [retval][out] */ int __RPC_FAR *pRet);


void __RPC_STUB IGame_get_ScoreSecond1Up_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE IGame_put_ScoreSecond1Up_Proxy( 
    IGame __RPC_FAR * This,
    /* [in] */ int val);


void __RPC_STUB IGame_put_ScoreSecond1Up_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE IGame_get_DScoreNext1Up_Proxy( 
    IGame __RPC_FAR * This,
    /* [retval][out] */ int __RPC_FAR *pRet);


void __RPC_STUB IGame_get_DScoreNext1Up_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE IGame_put_DScoreNext1Up_Proxy( 
    IGame __RPC_FAR * This,
    /* [in] */ int val);


void __RPC_STUB IGame_put_DScoreNext1Up_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE IGame_get_ShipsStart_Proxy( 
    IGame __RPC_FAR * This,
    /* [retval][out] */ int __RPC_FAR *pRet);


void __RPC_STUB IGame_get_ShipsStart_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE IGame_put_ShipsStart_Proxy( 
    IGame __RPC_FAR * This,
    /* [in] */ int val);


void __RPC_STUB IGame_put_ShipsStart_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE IGame_get_Tag_Proxy( 
    IGame __RPC_FAR * This,
    /* [retval][out] */ VARIANT __RPC_FAR *pRet);


void __RPC_STUB IGame_get_Tag_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE IGame_put_Tag_Proxy( 
    IGame __RPC_FAR * This,
    /* [in] */ VARIANT val);


void __RPC_STUB IGame_put_Tag_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE IGame_get_StatusText_Proxy( 
    IGame __RPC_FAR * This,
    /* [retval][out] */ BSTR __RPC_FAR *pbstrReturn);


void __RPC_STUB IGame_get_StatusText_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE IGame_put_StatusText_Proxy( 
    IGame __RPC_FAR * This,
    /* [in] */ BSTR bstr);


void __RPC_STUB IGame_put_StatusText_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);



#endif 	/* __IGame_INTERFACE_DEFINED__ */


#ifndef __IGameEvents_DISPINTERFACE_DEFINED__
#define __IGameEvents_DISPINTERFACE_DEFINED__

/****************************************
 * Generated header for dispinterface: IGameEvents
 * at Thu Aug 27 21:56:08 1998
 * using MIDL 3.01.75
 ****************************************/
/* [uuid] */ 



DEFINE_GUID(DIID_IGameEvents,0x8703FF65,0x669C,0x11cf,0xA9,0x2B,0x00,0xAA,0x00,0x68,0x8A,0x2F);

#if defined(__cplusplus) && !defined(CINTERFACE)

    interface DECLSPEC_UUID("8703FF65-669C-11cf-A92B-00AA00688A2F")
    IGameEvents : public IDispatch
    {
    };
    
#else 	/* C style interface */

    typedef struct IGameEventsVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *QueryInterface )( 
            IGameEvents __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppvObject);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *AddRef )( 
            IGameEvents __RPC_FAR * This);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *Release )( 
            IGameEvents __RPC_FAR * This);
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetTypeInfoCount )( 
            IGameEvents __RPC_FAR * This,
            /* [out] */ UINT __RPC_FAR *pctinfo);
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetTypeInfo )( 
            IGameEvents __RPC_FAR * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo __RPC_FAR *__RPC_FAR *ppTInfo);
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetIDsOfNames )( 
            IGameEvents __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR __RPC_FAR *rgszNames,
            /* [in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID __RPC_FAR *rgDispId);
        
        /* [local] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *Invoke )( 
            IGameEvents __RPC_FAR * This,
            /* [in] */ DISPID dispIdMember,
            /* [in] */ REFIID riid,
            /* [in] */ LCID lcid,
            /* [in] */ WORD wFlags,
            /* [out][in] */ DISPPARAMS __RPC_FAR *pDispParams,
            /* [out] */ VARIANT __RPC_FAR *pVarResult,
            /* [out] */ EXCEPINFO __RPC_FAR *pExcepInfo,
            /* [out] */ UINT __RPC_FAR *puArgErr);
        
        END_INTERFACE
    } IGameEventsVtbl;

    interface IGameEvents
    {
        CONST_VTBL struct IGameEventsVtbl __RPC_FAR *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IGameEvents_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define IGameEvents_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define IGameEvents_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define IGameEvents_GetTypeInfoCount(This,pctinfo)	\
    (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo)

#define IGameEvents_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo)

#define IGameEvents_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)

#define IGameEvents_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)

#endif /* COBJMACROS */


#endif 	/* C style interface */


#endif 	/* __IGameEvents_DISPINTERFACE_DEFINED__ */


#ifndef __ISpriteClass_INTERFACE_DEFINED__
#define __ISpriteClass_INTERFACE_DEFINED__

/****************************************
 * Generated header for interface: ISpriteClass
 * at Thu Aug 27 21:56:08 1998
 * using MIDL 3.01.75
 ****************************************/
/* [object][dual][uuid] */ 



DEFINE_GUID(IID_ISpriteClass,0x8703FF67,0x669C,0x11cf,0xA9,0x2B,0x00,0xAA,0x00,0x68,0x8A,0x2F);

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    interface DECLSPEC_UUID("8703FF67-669C-11cf-A92B-00AA00688A2F")
    ISpriteClass : public IDispatch
    {
    public:
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Application( 
            /* [retval][out] */ ISpruuidsApp __RPC_FAR *__RPC_FAR *ppRet) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Parent( 
            /* [retval][out] */ IGame __RPC_FAR *__RPC_FAR *ppRet) = 0;
        
        virtual /* [id] */ HRESULT STDMETHODCALLTYPE CreateSprite( 
            /* [in] */ int x,
            /* [in] */ int y,
            /* [in] */ VARIANT arg,
            /* [retval][out] */ ISprite __RPC_FAR *__RPC_FAR *ppRet) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Tag( 
            /* [retval][out] */ VARIANT __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Tag( 
            /* [in] */ VARIANT val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Image( 
            /* [retval][out] */ int __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Image( 
            /* [in] */ int val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Border( 
            /* [retval][out] */ int __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Border( 
            /* [in] */ int val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Collide( 
            /* [retval][out] */ int __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Collide( 
            /* [in] */ int val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_MaximumVelocity( 
            /* [retval][out] */ float __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_MaximumVelocity( 
            /* [in] */ float val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Friction( 
            /* [retval][out] */ float __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Friction( 
            /* [in] */ float val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_MaximumAcceleration( 
            /* [retval][out] */ float __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_MaximumAcceleration( 
            /* [in] */ float val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_AccelerationFriction( 
            /* [retval][out] */ float __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_AccelerationFriction( 
            /* [in] */ float val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_SpriteCount( 
            /* [retval][out] */ int __RPC_FAR *pRet) = 0;
        
    };
    
#else 	/* C style interface */

    typedef struct ISpriteClassVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *QueryInterface )( 
            ISpriteClass __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppvObject);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *AddRef )( 
            ISpriteClass __RPC_FAR * This);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *Release )( 
            ISpriteClass __RPC_FAR * This);
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetTypeInfoCount )( 
            ISpriteClass __RPC_FAR * This,
            /* [out] */ UINT __RPC_FAR *pctinfo);
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetTypeInfo )( 
            ISpriteClass __RPC_FAR * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo __RPC_FAR *__RPC_FAR *ppTInfo);
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetIDsOfNames )( 
            ISpriteClass __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR __RPC_FAR *rgszNames,
            /* [in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID __RPC_FAR *rgDispId);
        
        /* [local] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *Invoke )( 
            ISpriteClass __RPC_FAR * This,
            /* [in] */ DISPID dispIdMember,
            /* [in] */ REFIID riid,
            /* [in] */ LCID lcid,
            /* [in] */ WORD wFlags,
            /* [out][in] */ DISPPARAMS __RPC_FAR *pDispParams,
            /* [out] */ VARIANT __RPC_FAR *pVarResult,
            /* [out] */ EXCEPINFO __RPC_FAR *pExcepInfo,
            /* [out] */ UINT __RPC_FAR *puArgErr);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Application )( 
            ISpriteClass __RPC_FAR * This,
            /* [retval][out] */ ISpruuidsApp __RPC_FAR *__RPC_FAR *ppRet);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Parent )( 
            ISpriteClass __RPC_FAR * This,
            /* [retval][out] */ IGame __RPC_FAR *__RPC_FAR *ppRet);
        
        /* [id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *CreateSprite )( 
            ISpriteClass __RPC_FAR * This,
            /* [in] */ int x,
            /* [in] */ int y,
            /* [in] */ VARIANT arg,
            /* [retval][out] */ ISprite __RPC_FAR *__RPC_FAR *ppRet);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Tag )( 
            ISpriteClass __RPC_FAR * This,
            /* [retval][out] */ VARIANT __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_Tag )( 
            ISpriteClass __RPC_FAR * This,
            /* [in] */ VARIANT val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Image )( 
            ISpriteClass __RPC_FAR * This,
            /* [retval][out] */ int __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_Image )( 
            ISpriteClass __RPC_FAR * This,
            /* [in] */ int val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Border )( 
            ISpriteClass __RPC_FAR * This,
            /* [retval][out] */ int __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_Border )( 
            ISpriteClass __RPC_FAR * This,
            /* [in] */ int val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Collide )( 
            ISpriteClass __RPC_FAR * This,
            /* [retval][out] */ int __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_Collide )( 
            ISpriteClass __RPC_FAR * This,
            /* [in] */ int val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_MaximumVelocity )( 
            ISpriteClass __RPC_FAR * This,
            /* [retval][out] */ float __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_MaximumVelocity )( 
            ISpriteClass __RPC_FAR * This,
            /* [in] */ float val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Friction )( 
            ISpriteClass __RPC_FAR * This,
            /* [retval][out] */ float __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_Friction )( 
            ISpriteClass __RPC_FAR * This,
            /* [in] */ float val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_MaximumAcceleration )( 
            ISpriteClass __RPC_FAR * This,
            /* [retval][out] */ float __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_MaximumAcceleration )( 
            ISpriteClass __RPC_FAR * This,
            /* [in] */ float val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_AccelerationFriction )( 
            ISpriteClass __RPC_FAR * This,
            /* [retval][out] */ float __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_AccelerationFriction )( 
            ISpriteClass __RPC_FAR * This,
            /* [in] */ float val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_SpriteCount )( 
            ISpriteClass __RPC_FAR * This,
            /* [retval][out] */ int __RPC_FAR *pRet);
        
        END_INTERFACE
    } ISpriteClassVtbl;

    interface ISpriteClass
    {
        CONST_VTBL struct ISpriteClassVtbl __RPC_FAR *lpVtbl;
    };

    

#ifdef COBJMACROS


#define ISpriteClass_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define ISpriteClass_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define ISpriteClass_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define ISpriteClass_GetTypeInfoCount(This,pctinfo)	\
    (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo)

#define ISpriteClass_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo)

#define ISpriteClass_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)

#define ISpriteClass_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)


#define ISpriteClass_get_Application(This,ppRet)	\
    (This)->lpVtbl -> get_Application(This,ppRet)

#define ISpriteClass_get_Parent(This,ppRet)	\
    (This)->lpVtbl -> get_Parent(This,ppRet)

#define ISpriteClass_CreateSprite(This,x,y,arg,ppRet)	\
    (This)->lpVtbl -> CreateSprite(This,x,y,arg,ppRet)

#define ISpriteClass_get_Tag(This,pRet)	\
    (This)->lpVtbl -> get_Tag(This,pRet)

#define ISpriteClass_put_Tag(This,val)	\
    (This)->lpVtbl -> put_Tag(This,val)

#define ISpriteClass_get_Image(This,pRet)	\
    (This)->lpVtbl -> get_Image(This,pRet)

#define ISpriteClass_put_Image(This,val)	\
    (This)->lpVtbl -> put_Image(This,val)

#define ISpriteClass_get_Border(This,pRet)	\
    (This)->lpVtbl -> get_Border(This,pRet)

#define ISpriteClass_put_Border(This,val)	\
    (This)->lpVtbl -> put_Border(This,val)

#define ISpriteClass_get_Collide(This,pRet)	\
    (This)->lpVtbl -> get_Collide(This,pRet)

#define ISpriteClass_put_Collide(This,val)	\
    (This)->lpVtbl -> put_Collide(This,val)

#define ISpriteClass_get_MaximumVelocity(This,pRet)	\
    (This)->lpVtbl -> get_MaximumVelocity(This,pRet)

#define ISpriteClass_put_MaximumVelocity(This,val)	\
    (This)->lpVtbl -> put_MaximumVelocity(This,val)

#define ISpriteClass_get_Friction(This,pRet)	\
    (This)->lpVtbl -> get_Friction(This,pRet)

#define ISpriteClass_put_Friction(This,val)	\
    (This)->lpVtbl -> put_Friction(This,val)

#define ISpriteClass_get_MaximumAcceleration(This,pRet)	\
    (This)->lpVtbl -> get_MaximumAcceleration(This,pRet)

#define ISpriteClass_put_MaximumAcceleration(This,val)	\
    (This)->lpVtbl -> put_MaximumAcceleration(This,val)

#define ISpriteClass_get_AccelerationFriction(This,pRet)	\
    (This)->lpVtbl -> get_AccelerationFriction(This,pRet)

#define ISpriteClass_put_AccelerationFriction(This,val)	\
    (This)->lpVtbl -> put_AccelerationFriction(This,val)

#define ISpriteClass_get_SpriteCount(This,pRet)	\
    (This)->lpVtbl -> get_SpriteCount(This,pRet)

#endif /* COBJMACROS */


#endif 	/* C style interface */



/* [propget][id] */ HRESULT STDMETHODCALLTYPE ISpriteClass_get_Application_Proxy( 
    ISpriteClass __RPC_FAR * This,
    /* [retval][out] */ ISpruuidsApp __RPC_FAR *__RPC_FAR *ppRet);


void __RPC_STUB ISpriteClass_get_Application_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE ISpriteClass_get_Parent_Proxy( 
    ISpriteClass __RPC_FAR * This,
    /* [retval][out] */ IGame __RPC_FAR *__RPC_FAR *ppRet);


void __RPC_STUB ISpriteClass_get_Parent_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [id] */ HRESULT STDMETHODCALLTYPE ISpriteClass_CreateSprite_Proxy( 
    ISpriteClass __RPC_FAR * This,
    /* [in] */ int x,
    /* [in] */ int y,
    /* [in] */ VARIANT arg,
    /* [retval][out] */ ISprite __RPC_FAR *__RPC_FAR *ppRet);


void __RPC_STUB ISpriteClass_CreateSprite_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE ISpriteClass_get_Tag_Proxy( 
    ISpriteClass __RPC_FAR * This,
    /* [retval][out] */ VARIANT __RPC_FAR *pRet);


void __RPC_STUB ISpriteClass_get_Tag_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE ISpriteClass_put_Tag_Proxy( 
    ISpriteClass __RPC_FAR * This,
    /* [in] */ VARIANT val);


void __RPC_STUB ISpriteClass_put_Tag_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE ISpriteClass_get_Image_Proxy( 
    ISpriteClass __RPC_FAR * This,
    /* [retval][out] */ int __RPC_FAR *pRet);


void __RPC_STUB ISpriteClass_get_Image_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE ISpriteClass_put_Image_Proxy( 
    ISpriteClass __RPC_FAR * This,
    /* [in] */ int val);


void __RPC_STUB ISpriteClass_put_Image_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE ISpriteClass_get_Border_Proxy( 
    ISpriteClass __RPC_FAR * This,
    /* [retval][out] */ int __RPC_FAR *pRet);


void __RPC_STUB ISpriteClass_get_Border_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE ISpriteClass_put_Border_Proxy( 
    ISpriteClass __RPC_FAR * This,
    /* [in] */ int val);


void __RPC_STUB ISpriteClass_put_Border_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE ISpriteClass_get_Collide_Proxy( 
    ISpriteClass __RPC_FAR * This,
    /* [retval][out] */ int __RPC_FAR *pRet);


void __RPC_STUB ISpriteClass_get_Collide_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE ISpriteClass_put_Collide_Proxy( 
    ISpriteClass __RPC_FAR * This,
    /* [in] */ int val);


void __RPC_STUB ISpriteClass_put_Collide_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE ISpriteClass_get_MaximumVelocity_Proxy( 
    ISpriteClass __RPC_FAR * This,
    /* [retval][out] */ float __RPC_FAR *pRet);


void __RPC_STUB ISpriteClass_get_MaximumVelocity_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE ISpriteClass_put_MaximumVelocity_Proxy( 
    ISpriteClass __RPC_FAR * This,
    /* [in] */ float val);


void __RPC_STUB ISpriteClass_put_MaximumVelocity_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE ISpriteClass_get_Friction_Proxy( 
    ISpriteClass __RPC_FAR * This,
    /* [retval][out] */ float __RPC_FAR *pRet);


void __RPC_STUB ISpriteClass_get_Friction_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE ISpriteClass_put_Friction_Proxy( 
    ISpriteClass __RPC_FAR * This,
    /* [in] */ float val);


void __RPC_STUB ISpriteClass_put_Friction_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE ISpriteClass_get_MaximumAcceleration_Proxy( 
    ISpriteClass __RPC_FAR * This,
    /* [retval][out] */ float __RPC_FAR *pRet);


void __RPC_STUB ISpriteClass_get_MaximumAcceleration_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE ISpriteClass_put_MaximumAcceleration_Proxy( 
    ISpriteClass __RPC_FAR * This,
    /* [in] */ float val);


void __RPC_STUB ISpriteClass_put_MaximumAcceleration_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE ISpriteClass_get_AccelerationFriction_Proxy( 
    ISpriteClass __RPC_FAR * This,
    /* [retval][out] */ float __RPC_FAR *pRet);


void __RPC_STUB ISpriteClass_get_AccelerationFriction_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE ISpriteClass_put_AccelerationFriction_Proxy( 
    ISpriteClass __RPC_FAR * This,
    /* [in] */ float val);


void __RPC_STUB ISpriteClass_put_AccelerationFriction_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE ISpriteClass_get_SpriteCount_Proxy( 
    ISpriteClass __RPC_FAR * This,
    /* [retval][out] */ int __RPC_FAR *pRet);


void __RPC_STUB ISpriteClass_get_SpriteCount_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);



#endif 	/* __ISpriteClass_INTERFACE_DEFINED__ */


#ifndef __ISpriteClassEvents_DISPINTERFACE_DEFINED__
#define __ISpriteClassEvents_DISPINTERFACE_DEFINED__

/****************************************
 * Generated header for dispinterface: ISpriteClassEvents
 * at Thu Aug 27 21:56:08 1998
 * using MIDL 3.01.75
 ****************************************/
/* [uuid] */ 



DEFINE_GUID(DIID_ISpriteClassEvents,0x8703FF68,0x669C,0x11cf,0xA9,0x2B,0x00,0xAA,0x00,0x68,0x8A,0x2F);

#if defined(__cplusplus) && !defined(CINTERFACE)

    interface DECLSPEC_UUID("8703FF68-669C-11cf-A92B-00AA00688A2F")
    ISpriteClassEvents : public IDispatch
    {
    };
    
#else 	/* C style interface */

    typedef struct ISpriteClassEventsVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *QueryInterface )( 
            ISpriteClassEvents __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppvObject);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *AddRef )( 
            ISpriteClassEvents __RPC_FAR * This);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *Release )( 
            ISpriteClassEvents __RPC_FAR * This);
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetTypeInfoCount )( 
            ISpriteClassEvents __RPC_FAR * This,
            /* [out] */ UINT __RPC_FAR *pctinfo);
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetTypeInfo )( 
            ISpriteClassEvents __RPC_FAR * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo __RPC_FAR *__RPC_FAR *ppTInfo);
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetIDsOfNames )( 
            ISpriteClassEvents __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR __RPC_FAR *rgszNames,
            /* [in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID __RPC_FAR *rgDispId);
        
        /* [local] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *Invoke )( 
            ISpriteClassEvents __RPC_FAR * This,
            /* [in] */ DISPID dispIdMember,
            /* [in] */ REFIID riid,
            /* [in] */ LCID lcid,
            /* [in] */ WORD wFlags,
            /* [out][in] */ DISPPARAMS __RPC_FAR *pDispParams,
            /* [out] */ VARIANT __RPC_FAR *pVarResult,
            /* [out] */ EXCEPINFO __RPC_FAR *pExcepInfo,
            /* [out] */ UINT __RPC_FAR *puArgErr);
        
        END_INTERFACE
    } ISpriteClassEventsVtbl;

    interface ISpriteClassEvents
    {
        CONST_VTBL struct ISpriteClassEventsVtbl __RPC_FAR *lpVtbl;
    };

    

#ifdef COBJMACROS


#define ISpriteClassEvents_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define ISpriteClassEvents_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define ISpriteClassEvents_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define ISpriteClassEvents_GetTypeInfoCount(This,pctinfo)	\
    (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo)

#define ISpriteClassEvents_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo)

#define ISpriteClassEvents_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)

#define ISpriteClassEvents_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)

#endif /* COBJMACROS */


#endif 	/* C style interface */


#endif 	/* __ISpriteClassEvents_DISPINTERFACE_DEFINED__ */


#ifndef __ISprite_INTERFACE_DEFINED__
#define __ISprite_INTERFACE_DEFINED__

/****************************************
 * Generated header for interface: ISprite
 * at Thu Aug 27 21:56:08 1998
 * using MIDL 3.01.75
 ****************************************/
/* [object][dual][uuid] */ 



DEFINE_GUID(IID_ISprite,0x8703FF6a,0x669C,0x11cf,0xA9,0x2B,0x00,0xAA,0x00,0x68,0x8A,0x2F);

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    interface DECLSPEC_UUID("8703FF6a-669C-11cf-A92B-00AA00688A2F")
    ISprite : public IDispatch
    {
    public:
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Application( 
            /* [retval][out] */ ISpruuidsApp __RPC_FAR *__RPC_FAR *ppRet) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Parent( 
            /* [retval][out] */ ISpriteClass __RPC_FAR *__RPC_FAR *ppRet) = 0;
        
        virtual /* [id] */ HRESULT STDMETHODCALLTYPE MoveTo( 
            /* [in] */ float x,
            /* [in] */ float y) = 0;
        
        virtual /* [id] */ HRESULT STDMETHODCALLTYPE MoveBy( 
            /* [in] */ float dx,
            /* [in] */ float dy) = 0;
        
        virtual /* [id] */ HRESULT STDMETHODCALLTYPE MoveAtSprite( 
            /* [in] */ ISprite __RPC_FAR *sprite,
            /* [in] */ float scale,
            /* [in] */ float dMax,
            /* [in] */ long flags) = 0;
        
        virtual /* [id] */ HRESULT STDMETHODCALLTYPE Remove( void) = 0;
        
        virtual /* [id] */ HRESULT STDMETHODCALLTYPE Refresh( void) = 0;
        
        virtual /* [id] */ HRESULT STDMETHODCALLTYPE IgnoreMove( void) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Left( 
            /* [retval][out] */ float __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Left( 
            /* [in] */ float val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Top( 
            /* [retval][out] */ float __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Top( 
            /* [in] */ float val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Vx( 
            /* [retval][out] */ float __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Vx( 
            /* [in] */ float val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Vy( 
            /* [retval][out] */ float __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Vy( 
            /* [in] */ float val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Ax( 
            /* [retval][out] */ float __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Ax( 
            /* [in] */ float val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Ay( 
            /* [retval][out] */ float __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Ay( 
            /* [in] */ float val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_FrictionX( 
            /* [retval][out] */ float __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_FrictionX( 
            /* [in] */ float val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_FrictionY( 
            /* [retval][out] */ float __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_FrictionY( 
            /* [in] */ float val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Image( 
            /* [retval][out] */ int __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Image( 
            /* [in] */ int val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_TickMove( 
            /* [retval][out] */ int __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_TickMove( 
            /* [in] */ int val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_TickEvent( 
            /* [retval][out] */ int __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_TickEvent( 
            /* [in] */ int val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Visible( 
            /* [retval][out] */ VARIANT_BOOL __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Visible( 
            /* [in] */ VARIANT_BOOL val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Tag( 
            /* [retval][out] */ VARIANT __RPC_FAR *pRet) = 0;
        
        virtual /* [propput][id] */ HRESULT STDMETHODCALLTYPE put_Tag( 
            /* [in] */ VARIANT val) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Width( 
            /* [retval][out] */ int __RPC_FAR *pRet) = 0;
        
        virtual /* [propget][id] */ HRESULT STDMETHODCALLTYPE get_Height( 
            /* [retval][out] */ int __RPC_FAR *pRet) = 0;
        
    };
    
#else 	/* C style interface */

    typedef struct ISpriteVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *QueryInterface )( 
            ISprite __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppvObject);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *AddRef )( 
            ISprite __RPC_FAR * This);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *Release )( 
            ISprite __RPC_FAR * This);
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetTypeInfoCount )( 
            ISprite __RPC_FAR * This,
            /* [out] */ UINT __RPC_FAR *pctinfo);
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetTypeInfo )( 
            ISprite __RPC_FAR * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo __RPC_FAR *__RPC_FAR *ppTInfo);
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetIDsOfNames )( 
            ISprite __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR __RPC_FAR *rgszNames,
            /* [in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID __RPC_FAR *rgDispId);
        
        /* [local] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *Invoke )( 
            ISprite __RPC_FAR * This,
            /* [in] */ DISPID dispIdMember,
            /* [in] */ REFIID riid,
            /* [in] */ LCID lcid,
            /* [in] */ WORD wFlags,
            /* [out][in] */ DISPPARAMS __RPC_FAR *pDispParams,
            /* [out] */ VARIANT __RPC_FAR *pVarResult,
            /* [out] */ EXCEPINFO __RPC_FAR *pExcepInfo,
            /* [out] */ UINT __RPC_FAR *puArgErr);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Application )( 
            ISprite __RPC_FAR * This,
            /* [retval][out] */ ISpruuidsApp __RPC_FAR *__RPC_FAR *ppRet);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Parent )( 
            ISprite __RPC_FAR * This,
            /* [retval][out] */ ISpriteClass __RPC_FAR *__RPC_FAR *ppRet);
        
        /* [id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *MoveTo )( 
            ISprite __RPC_FAR * This,
            /* [in] */ float x,
            /* [in] */ float y);
        
        /* [id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *MoveBy )( 
            ISprite __RPC_FAR * This,
            /* [in] */ float dx,
            /* [in] */ float dy);
        
        /* [id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *MoveAtSprite )( 
            ISprite __RPC_FAR * This,
            /* [in] */ ISprite __RPC_FAR *sprite,
            /* [in] */ float scale,
            /* [in] */ float dMax,
            /* [in] */ long flags);
        
        /* [id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *Remove )( 
            ISprite __RPC_FAR * This);
        
        /* [id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *Refresh )( 
            ISprite __RPC_FAR * This);
        
        /* [id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *IgnoreMove )( 
            ISprite __RPC_FAR * This);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Left )( 
            ISprite __RPC_FAR * This,
            /* [retval][out] */ float __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_Left )( 
            ISprite __RPC_FAR * This,
            /* [in] */ float val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Top )( 
            ISprite __RPC_FAR * This,
            /* [retval][out] */ float __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_Top )( 
            ISprite __RPC_FAR * This,
            /* [in] */ float val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Vx )( 
            ISprite __RPC_FAR * This,
            /* [retval][out] */ float __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_Vx )( 
            ISprite __RPC_FAR * This,
            /* [in] */ float val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Vy )( 
            ISprite __RPC_FAR * This,
            /* [retval][out] */ float __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_Vy )( 
            ISprite __RPC_FAR * This,
            /* [in] */ float val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Ax )( 
            ISprite __RPC_FAR * This,
            /* [retval][out] */ float __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_Ax )( 
            ISprite __RPC_FAR * This,
            /* [in] */ float val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Ay )( 
            ISprite __RPC_FAR * This,
            /* [retval][out] */ float __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_Ay )( 
            ISprite __RPC_FAR * This,
            /* [in] */ float val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_FrictionX )( 
            ISprite __RPC_FAR * This,
            /* [retval][out] */ float __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_FrictionX )( 
            ISprite __RPC_FAR * This,
            /* [in] */ float val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_FrictionY )( 
            ISprite __RPC_FAR * This,
            /* [retval][out] */ float __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_FrictionY )( 
            ISprite __RPC_FAR * This,
            /* [in] */ float val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Image )( 
            ISprite __RPC_FAR * This,
            /* [retval][out] */ int __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_Image )( 
            ISprite __RPC_FAR * This,
            /* [in] */ int val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_TickMove )( 
            ISprite __RPC_FAR * This,
            /* [retval][out] */ int __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_TickMove )( 
            ISprite __RPC_FAR * This,
            /* [in] */ int val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_TickEvent )( 
            ISprite __RPC_FAR * This,
            /* [retval][out] */ int __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_TickEvent )( 
            ISprite __RPC_FAR * This,
            /* [in] */ int val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Visible )( 
            ISprite __RPC_FAR * This,
            /* [retval][out] */ VARIANT_BOOL __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_Visible )( 
            ISprite __RPC_FAR * This,
            /* [in] */ VARIANT_BOOL val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Tag )( 
            ISprite __RPC_FAR * This,
            /* [retval][out] */ VARIANT __RPC_FAR *pRet);
        
        /* [propput][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_Tag )( 
            ISprite __RPC_FAR * This,
            /* [in] */ VARIANT val);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Width )( 
            ISprite __RPC_FAR * This,
            /* [retval][out] */ int __RPC_FAR *pRet);
        
        /* [propget][id] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Height )( 
            ISprite __RPC_FAR * This,
            /* [retval][out] */ int __RPC_FAR *pRet);
        
        END_INTERFACE
    } ISpriteVtbl;

    interface ISprite
    {
        CONST_VTBL struct ISpriteVtbl __RPC_FAR *lpVtbl;
    };

    

#ifdef COBJMACROS


#define ISprite_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define ISprite_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define ISprite_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define ISprite_GetTypeInfoCount(This,pctinfo)	\
    (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo)

#define ISprite_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo)

#define ISprite_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)

#define ISprite_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)


#define ISprite_get_Application(This,ppRet)	\
    (This)->lpVtbl -> get_Application(This,ppRet)

#define ISprite_get_Parent(This,ppRet)	\
    (This)->lpVtbl -> get_Parent(This,ppRet)

#define ISprite_MoveTo(This,x,y)	\
    (This)->lpVtbl -> MoveTo(This,x,y)

#define ISprite_MoveBy(This,dx,dy)	\
    (This)->lpVtbl -> MoveBy(This,dx,dy)

#define ISprite_MoveAtSprite(This,sprite,scale,dMax,flags)	\
    (This)->lpVtbl -> MoveAtSprite(This,sprite,scale,dMax,flags)

#define ISprite_Remove(This)	\
    (This)->lpVtbl -> Remove(This)

#define ISprite_Refresh(This)	\
    (This)->lpVtbl -> Refresh(This)

#define ISprite_IgnoreMove(This)	\
    (This)->lpVtbl -> IgnoreMove(This)

#define ISprite_get_Left(This,pRet)	\
    (This)->lpVtbl -> get_Left(This,pRet)

#define ISprite_put_Left(This,val)	\
    (This)->lpVtbl -> put_Left(This,val)

#define ISprite_get_Top(This,pRet)	\
    (This)->lpVtbl -> get_Top(This,pRet)

#define ISprite_put_Top(This,val)	\
    (This)->lpVtbl -> put_Top(This,val)

#define ISprite_get_Vx(This,pRet)	\
    (This)->lpVtbl -> get_Vx(This,pRet)

#define ISprite_put_Vx(This,val)	\
    (This)->lpVtbl -> put_Vx(This,val)

#define ISprite_get_Vy(This,pRet)	\
    (This)->lpVtbl -> get_Vy(This,pRet)

#define ISprite_put_Vy(This,val)	\
    (This)->lpVtbl -> put_Vy(This,val)

#define ISprite_get_Ax(This,pRet)	\
    (This)->lpVtbl -> get_Ax(This,pRet)

#define ISprite_put_Ax(This,val)	\
    (This)->lpVtbl -> put_Ax(This,val)

#define ISprite_get_Ay(This,pRet)	\
    (This)->lpVtbl -> get_Ay(This,pRet)

#define ISprite_put_Ay(This,val)	\
    (This)->lpVtbl -> put_Ay(This,val)

#define ISprite_get_FrictionX(This,pRet)	\
    (This)->lpVtbl -> get_FrictionX(This,pRet)

#define ISprite_put_FrictionX(This,val)	\
    (This)->lpVtbl -> put_FrictionX(This,val)

#define ISprite_get_FrictionY(This,pRet)	\
    (This)->lpVtbl -> get_FrictionY(This,pRet)

#define ISprite_put_FrictionY(This,val)	\
    (This)->lpVtbl -> put_FrictionY(This,val)

#define ISprite_get_Image(This,pRet)	\
    (This)->lpVtbl -> get_Image(This,pRet)

#define ISprite_put_Image(This,val)	\
    (This)->lpVtbl -> put_Image(This,val)

#define ISprite_get_TickMove(This,pRet)	\
    (This)->lpVtbl -> get_TickMove(This,pRet)

#define ISprite_put_TickMove(This,val)	\
    (This)->lpVtbl -> put_TickMove(This,val)

#define ISprite_get_TickEvent(This,pRet)	\
    (This)->lpVtbl -> get_TickEvent(This,pRet)

#define ISprite_put_TickEvent(This,val)	\
    (This)->lpVtbl -> put_TickEvent(This,val)

#define ISprite_get_Visible(This,pRet)	\
    (This)->lpVtbl -> get_Visible(This,pRet)

#define ISprite_put_Visible(This,val)	\
    (This)->lpVtbl -> put_Visible(This,val)

#define ISprite_get_Tag(This,pRet)	\
    (This)->lpVtbl -> get_Tag(This,pRet)

#define ISprite_put_Tag(This,val)	\
    (This)->lpVtbl -> put_Tag(This,val)

#define ISprite_get_Width(This,pRet)	\
    (This)->lpVtbl -> get_Width(This,pRet)

#define ISprite_get_Height(This,pRet)	\
    (This)->lpVtbl -> get_Height(This,pRet)

#endif /* COBJMACROS */


#endif 	/* C style interface */



/* [propget][id] */ HRESULT STDMETHODCALLTYPE ISprite_get_Application_Proxy( 
    ISprite __RPC_FAR * This,
    /* [retval][out] */ ISpruuidsApp __RPC_FAR *__RPC_FAR *ppRet);


void __RPC_STUB ISprite_get_Application_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE ISprite_get_Parent_Proxy( 
    ISprite __RPC_FAR * This,
    /* [retval][out] */ ISpriteClass __RPC_FAR *__RPC_FAR *ppRet);


void __RPC_STUB ISprite_get_Parent_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [id] */ HRESULT STDMETHODCALLTYPE ISprite_MoveTo_Proxy( 
    ISprite __RPC_FAR * This,
    /* [in] */ float x,
    /* [in] */ float y);


void __RPC_STUB ISprite_MoveTo_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [id] */ HRESULT STDMETHODCALLTYPE ISprite_MoveBy_Proxy( 
    ISprite __RPC_FAR * This,
    /* [in] */ float dx,
    /* [in] */ float dy);


void __RPC_STUB ISprite_MoveBy_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [id] */ HRESULT STDMETHODCALLTYPE ISprite_MoveAtSprite_Proxy( 
    ISprite __RPC_FAR * This,
    /* [in] */ ISprite __RPC_FAR *sprite,
    /* [in] */ float scale,
    /* [in] */ float dMax,
    /* [in] */ long flags);


void __RPC_STUB ISprite_MoveAtSprite_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [id] */ HRESULT STDMETHODCALLTYPE ISprite_Remove_Proxy( 
    ISprite __RPC_FAR * This);


void __RPC_STUB ISprite_Remove_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [id] */ HRESULT STDMETHODCALLTYPE ISprite_Refresh_Proxy( 
    ISprite __RPC_FAR * This);


void __RPC_STUB ISprite_Refresh_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [id] */ HRESULT STDMETHODCALLTYPE ISprite_IgnoreMove_Proxy( 
    ISprite __RPC_FAR * This);


void __RPC_STUB ISprite_IgnoreMove_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE ISprite_get_Left_Proxy( 
    ISprite __RPC_FAR * This,
    /* [retval][out] */ float __RPC_FAR *pRet);


void __RPC_STUB ISprite_get_Left_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE ISprite_put_Left_Proxy( 
    ISprite __RPC_FAR * This,
    /* [in] */ float val);


void __RPC_STUB ISprite_put_Left_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE ISprite_get_Top_Proxy( 
    ISprite __RPC_FAR * This,
    /* [retval][out] */ float __RPC_FAR *pRet);


void __RPC_STUB ISprite_get_Top_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE ISprite_put_Top_Proxy( 
    ISprite __RPC_FAR * This,
    /* [in] */ float val);


void __RPC_STUB ISprite_put_Top_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE ISprite_get_Vx_Proxy( 
    ISprite __RPC_FAR * This,
    /* [retval][out] */ float __RPC_FAR *pRet);


void __RPC_STUB ISprite_get_Vx_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE ISprite_put_Vx_Proxy( 
    ISprite __RPC_FAR * This,
    /* [in] */ float val);


void __RPC_STUB ISprite_put_Vx_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE ISprite_get_Vy_Proxy( 
    ISprite __RPC_FAR * This,
    /* [retval][out] */ float __RPC_FAR *pRet);


void __RPC_STUB ISprite_get_Vy_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE ISprite_put_Vy_Proxy( 
    ISprite __RPC_FAR * This,
    /* [in] */ float val);


void __RPC_STUB ISprite_put_Vy_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE ISprite_get_Ax_Proxy( 
    ISprite __RPC_FAR * This,
    /* [retval][out] */ float __RPC_FAR *pRet);


void __RPC_STUB ISprite_get_Ax_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE ISprite_put_Ax_Proxy( 
    ISprite __RPC_FAR * This,
    /* [in] */ float val);


void __RPC_STUB ISprite_put_Ax_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE ISprite_get_Ay_Proxy( 
    ISprite __RPC_FAR * This,
    /* [retval][out] */ float __RPC_FAR *pRet);


void __RPC_STUB ISprite_get_Ay_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE ISprite_put_Ay_Proxy( 
    ISprite __RPC_FAR * This,
    /* [in] */ float val);


void __RPC_STUB ISprite_put_Ay_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE ISprite_get_FrictionX_Proxy( 
    ISprite __RPC_FAR * This,
    /* [retval][out] */ float __RPC_FAR *pRet);


void __RPC_STUB ISprite_get_FrictionX_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE ISprite_put_FrictionX_Proxy( 
    ISprite __RPC_FAR * This,
    /* [in] */ float val);


void __RPC_STUB ISprite_put_FrictionX_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE ISprite_get_FrictionY_Proxy( 
    ISprite __RPC_FAR * This,
    /* [retval][out] */ float __RPC_FAR *pRet);


void __RPC_STUB ISprite_get_FrictionY_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE ISprite_put_FrictionY_Proxy( 
    ISprite __RPC_FAR * This,
    /* [in] */ float val);


void __RPC_STUB ISprite_put_FrictionY_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE ISprite_get_Image_Proxy( 
    ISprite __RPC_FAR * This,
    /* [retval][out] */ int __RPC_FAR *pRet);


void __RPC_STUB ISprite_get_Image_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE ISprite_put_Image_Proxy( 
    ISprite __RPC_FAR * This,
    /* [in] */ int val);


void __RPC_STUB ISprite_put_Image_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE ISprite_get_TickMove_Proxy( 
    ISprite __RPC_FAR * This,
    /* [retval][out] */ int __RPC_FAR *pRet);


void __RPC_STUB ISprite_get_TickMove_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE ISprite_put_TickMove_Proxy( 
    ISprite __RPC_FAR * This,
    /* [in] */ int val);


void __RPC_STUB ISprite_put_TickMove_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE ISprite_get_TickEvent_Proxy( 
    ISprite __RPC_FAR * This,
    /* [retval][out] */ int __RPC_FAR *pRet);


void __RPC_STUB ISprite_get_TickEvent_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE ISprite_put_TickEvent_Proxy( 
    ISprite __RPC_FAR * This,
    /* [in] */ int val);


void __RPC_STUB ISprite_put_TickEvent_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE ISprite_get_Visible_Proxy( 
    ISprite __RPC_FAR * This,
    /* [retval][out] */ VARIANT_BOOL __RPC_FAR *pRet);


void __RPC_STUB ISprite_get_Visible_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE ISprite_put_Visible_Proxy( 
    ISprite __RPC_FAR * This,
    /* [in] */ VARIANT_BOOL val);


void __RPC_STUB ISprite_put_Visible_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE ISprite_get_Tag_Proxy( 
    ISprite __RPC_FAR * This,
    /* [retval][out] */ VARIANT __RPC_FAR *pRet);


void __RPC_STUB ISprite_get_Tag_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propput][id] */ HRESULT STDMETHODCALLTYPE ISprite_put_Tag_Proxy( 
    ISprite __RPC_FAR * This,
    /* [in] */ VARIANT val);


void __RPC_STUB ISprite_put_Tag_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE ISprite_get_Width_Proxy( 
    ISprite __RPC_FAR * This,
    /* [retval][out] */ int __RPC_FAR *pRet);


void __RPC_STUB ISprite_get_Width_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [propget][id] */ HRESULT STDMETHODCALLTYPE ISprite_get_Height_Proxy( 
    ISprite __RPC_FAR * This,
    /* [retval][out] */ int __RPC_FAR *pRet);


void __RPC_STUB ISprite_get_Height_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);



#endif 	/* __ISprite_INTERFACE_DEFINED__ */


#ifdef __cplusplus
DEFINE_GUID(CLSID_SpruuidsApp,0x8703FF63,0x669C,0x11cf,0xA9,0x2B,0x00,0xAA,0x00,0x68,0x8A,0x2F);

class DECLSPEC_UUID("8703FF63-669C-11cf-A92B-00AA00688A2F")
SpruuidsApp;
#endif

#ifdef __cplusplus
DEFINE_GUID(CLSID_Game,0x8703FF66,0x669C,0x11cf,0xA9,0x2B,0x00,0xAA,0x00,0x68,0x8A,0x2F);

class DECLSPEC_UUID("8703FF66-669C-11cf-A92B-00AA00688A2F")
Game;
#endif

#ifdef __cplusplus
DEFINE_GUID(CLSID_SpriteClass,0x8703FF69,0x669C,0x11cf,0xA9,0x2B,0x00,0xAA,0x00,0x68,0x8A,0x2F);

class DECLSPEC_UUID("8703FF69-669C-11cf-A92B-00AA00688A2F")
SpriteClass;
#endif

#ifdef __cplusplus
DEFINE_GUID(CLSID_Sprite,0x8703FF6b,0x669C,0x11cf,0xA9,0x2B,0x00,0xAA,0x00,0x68,0x8A,0x2F);

class DECLSPEC_UUID("8703FF6b-669C-11cf-A92B-00AA00688A2F")
Sprite;
#endif
#endif /* __SPRUUIDS_LIBRARY_DEFINED__ */

/* Additional Prototypes for ALL interfaces */

/* end of Additional Prototypes */

#ifdef __cplusplus
}
#endif

#endif
