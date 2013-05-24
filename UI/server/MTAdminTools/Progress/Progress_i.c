/* this file contains the actual definitions of */
/* the IIDs and CLSIDs */

/* link this file in with the server and any clients */


/* File created by MIDL compiler version 5.01.0164 */
/* at Wed Jun 07 11:03:42 2000
 */
/* Compiler settings for D:\source\development\UI\server\MTAdminTools\Progress\Progress.idl:
    Oicf (OptLev=i2), W1, Zp8, env=Win32, ms_ext, c_ext
    error checks: allocation ref bounds_check enum stub_data 
*/
//@@MIDL_FILE_HEADING(  )
#ifdef __cplusplus
extern "C"{
#endif 


#ifndef __IID_DEFINED__
#define __IID_DEFINED__

typedef struct _IID
{
    unsigned long x;
    unsigned short s1;
    unsigned short s2;
    unsigned char  c[8];
} IID;

#endif // __IID_DEFINED__

#ifndef CLSID_DEFINED
#define CLSID_DEFINED
typedef IID CLSID;
#endif // CLSID_DEFINED

const IID IID_IProgressServer = {0xA055E69D,0x38C7,0x11D4,{0xB9,0xA1,0x00,0xC0,0x4F,0x04,0x3E,0x86}};


const IID IID_IDummy = {0xA055E6A4,0x38C7,0x11D4,{0xB9,0xA1,0x00,0xC0,0x4F,0x04,0x3E,0x86}};


const IID LIBID_PROGRESSLib = {0xA055E691,0x38C7,0x11D4,{0xB9,0xA1,0x00,0xC0,0x4F,0x04,0x3E,0x86}};


const CLSID CLSID_ProgressServer = {0xA055E69E,0x38C7,0x11D4,{0xB9,0xA1,0x00,0xC0,0x4F,0x04,0x3E,0x86}};


const CLSID CLSID_Dummy = {0xA055E6A5,0x38C7,0x11D4,{0xB9,0xA1,0x00,0xC0,0x4F,0x04,0x3E,0x86}};


#ifdef __cplusplus
}
#endif

