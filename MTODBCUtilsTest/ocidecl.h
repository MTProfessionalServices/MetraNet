#ifndef _OCIDECL_H_
#define _OCIDECL_H_

#include <iostream>
using namespace std;

#pragma once


/*
EXTERNAL DATATYPE   TYPE OF PROGRAM
VARIABLE   OCI DEFINED CONSTANT   
NAME  CODE  
VARCHAR2  
 1  
 char[n]  
 SQLT_CHR  
 
NUMBER  
 2  
 unsigned char[21]  
 SQLT_NUM  
 
8-bit signed INTEGER  
 3  
 signed char  
 SQLT_INT  
 
16-bit signed INTEGER  
 3  
 signed short, signed int  
 SQLT_INT  
 
32-bit signed INTEGER  
 3  
 signed int, signed long  
 SQLT_INT  
 
FLOAT  
 4  
 float, double  
 SQLT_FLT  
 
Null-terminated STRING  
 5  
 char[n+1]  
 SQLT_STR  
 
VARNUM  
 6  
 char[22]  
 SQLT_VNU  
 
LONG  
 8  
 char[n]  
 SQLT_LNG  
 
VARCHAR  
 9  
 char[n+sizeof(short integer)]  
 SQLT_VCS  
 
ROWID  
 11  
 char[n]  
 SQLT_RID (see note 1)  
 
DATE  
 12  
 char[7]  
 SQLT_DAT  
 
VARRAW  
 15  
 unsigned char[n+sizeof(short integer)]  
 SQLT_VBI  
 
RAW  
 23  
 unsigned char[n]  
 SQLT_BIN  
 
LONG RAW  
 24  
 unsigned char[n]  
 SQLT_LBI  
 
UNSIGNED INT  
 68  
 unsigned  
 SQLT_UIN  
 
LONG VARCHAR  
 94  
 char[n+sizeof(integer)]  
 SQLT_LVC  
 
LONG VARRAW  
 95  
 unsigned char[n+sizeof(integer)]  
 SQLT_LVB  
 
CHAR  
 96  
 char[n]  
 SQLT_AFC  
 
CHARZ  
 97  
 char[n+1]  
 SQLT_AVC  
 
ROWID descriptor  
 104  
 OCIRowid  
 SQLT_RDD  
 
NAMED DATA TYPE  
 108  
 struct  
 SQLT_NTY  
 
REF  
 110  
 OCIRef  
 SQLT_REF  
 
Character LOB  
 112  
 OCILobLocator (see note 3)  
 SQLT_CLOB  
 
Binary LOB  
 113  
 OCILobLocator (see note 3)  
 SQLT_BLOB  
 
Binary FILE  
 114  
 OCILobLocator  
 SQLT_FILE  
 
OCI string type  
 155  
 OCIString  
 SQLT_VST (see note 2)  
 
OCI date type  
 156  
 OCIDate  
 SQLT_ODT (see note 2)  
 


*/

/* Copyright (c) Oracle Corporation 1997, 1998. All Rights Reserved. */ 
 
/* 
   NAME 
     cdemodr.h - DML RETURNING demo program.
 
   DESCRIPTION
     Demonstrate INSERT/UPDATE/DELETE statements with RETURNING clause

*/

/*------------------------------------------------------------------------
 * Include Files
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <oci.h>
/*
#include <orastd.h>
*/

/*------------------------------------------------------------------------
 * Define Constants
 */

#define MAXBINDS       25 
#define MAXROWS         5           /* max no of rows returned per iter */ 
#define MAXCOLS        25
#define MAXITER        50000
#define MAXCOLLEN      40           /* if changed, update cdemodr1.sql */
#define DATBUFLEN       7

static sword init_handles(OCIEnv **envhp, OCISvcCtx **svchp, 
                               OCIError **errhp, OCIServer **svrhp, 
                               OCISession **authp, OCIDescribe **deschp, ub4 mode);

static sword attach_server(text* name, ub4 mode, OCIServer *srvhp,
                        OCIError *errhp, OCISvcCtx *svchp);
static sword log_on(OCISession *authp, OCIError *errhp, OCISvcCtx *svchp,
                 text *uid, text *pwd, ub4 credt, ub4 mode);
static sword init_bind_handle(/*_ OCIStmt *stmthp, OCIBind *bndhp[],
                                                             int nbinds _*/);
static void print_raw(ub1 *raw, ub4 rawlen);

static void free_handles(OCIEnv *envhp, OCISvcCtx *svchp, OCIServer *srvhp,
                      OCIError *errhp, OCISession *authp, OCIStmt *stmthp);
void report_error(OCIError *errhp);
void logout_detach_server(OCISvcCtx *svchp, OCIServer *srvhp,
                              OCIError *errhp, OCISession *authp,
                              text *userid);
sword finish_demo(boolean loggedon, OCIEnv *envhp, OCISvcCtx *svchp,
                      OCIServer *srvhp, OCIError *errhp, OCISession *authp,
                      OCIStmt *stmthp, text *userid);
//static sword insert_with_returning(OCISvcCtx *svchp, OCIStmt *stmthp, 
//                              OCIBind *bndhp[], OCIError *errhp);
static sword insertnarrow(int numrows, int arraysize, OCISvcCtx *svchp, OCIStmt *stmthp, 
                              OCIBind *bndhp[], OCIError *errhp);
static sword insertwider(int numrows, int arraysize, OCISvcCtx *svchp, OCIStmt *stmthp, 
                              OCIBind *bndhp[], OCIError *errhp);

static sword insertwide(int numrows, int arraysize, OCISvcCtx *svchp, OCIStmt *stmthp, 
                              OCIBind *bndhp[], OCIError *errhp);

static sword cleanup(OCISvcCtx *svchp, OCIStmt *stmthp, 
                              OCIBind *bndhp[], OCIError *errhp);

static sword truncatetable(string aName, OCISvcCtx *svchp, OCIStmt *stmthp, 
                              OCIBind *bndhp[], OCIError *errhp);

static sword oldinsert(OCISvcCtx *svchp, OCIStmt *stmthp, 
                              OCIBind *bndhp[], OCIError *errhp);


static sword dummy(OCISvcCtx *svchp, OCIStmt *stmthp, 
                              OCIBind *bndhp[], OCIError *errhp);

static sword demo_update(/*_ OCISvcCtx *svchp, OCIStmt *stmthp, 
                              OCIBind *bndhp[], OCIError *errhp _*/);
static sword demo_delete(/*_ OCISvcCtx *svchp, OCIStmt *stmthp, 
                              OCIBind *bndhp[], OCIError *errhp _*/);
static sword bind_name(OCIStmt *stmthp, OCIBind *bndhp[], 
                            OCIError *errhp);
static sword bind_pos(OCIStmt *stmthp, OCIBind *bndhp[], 
                           OCIError *errhp);
static sword bind_input(OCIStmt *stmthp, OCIBind *bndhp[], 
                             OCIError *errhp);
static sword bind_output(OCIStmt *stmthp, OCIBind *bndhp[], 
                              OCIError *errhp);
static sword bind_array(OCIBind *bndhp[], OCIError *errhp);
static sword bind_dynamic(OCIBind *bndhp[], OCIError *errhp);
static sb4 cbf_get_data(dvoid *ctxp, OCIBind *bindp, ub4 iter, ub4 index,
                             dvoid **bufpp, ub4 **alenpp, ub1 *piecep,
                             dvoid **indpp, ub2 **rcodepp);
static sword alloc_buffer(ub4 pos, ub4 iter, ub4 rows);
static sword print_return_data(int iter);


	static boolean logged_on = FALSE;
	/* t_dummy columns */
	static int   in1[MAXITER];                    /* for INTEGER      */
	static text  in2[MAXITER][40];                /* for CHAR(40)     */
	static text  in3[MAXITER][40];                /* for VARCHAR2(40) */
	static float in4[MAXITER];                    /* for FLOAT        */
	static int   in5[MAXITER];                    /* for DECIMAL      */
	static float in6[MAXITER];                    /* for DECIMAL(8,3) */
	static int   in7[MAXITER];                    /* for NUMERIC      */
	static float in8[MAXITER];                    /* for NUMERIC(7,2) */
	static ub1   in9[MAXITER][7];                 /* for DATE         */
	static ub1   in10[MAXITER][40];               /* for RAW(40)      */

	/* output buffers */
	static int   *p1[MAXITER];                     /* for INTEGER      */
	static text  *p2[MAXITER];                     /* for CHAR(40)     */
	static text  *p3[MAXITER];                     /* for VARCHAR2(40) */
	static float *p4[MAXITER];                     /* for FLOAT        */
	static int   *p5[MAXITER];                     /* for DECIMAL      */
	static float *p6[MAXITER];                     /* for DECIMAL(8,3) */
	static int   *p7[MAXITER];                     /* for NUMERIC      */
	static float *p8[MAXITER];                     /* for NUMERIC(7,2) */
	static ub1   *p9[MAXITER];                     /* for DATE         */
	static ub1   *p10[MAXITER];                    /* for RAW(40)      */

	/* skip values for binding t_dummy */ 
static ub4   s1 = (ub4) sizeof(in1[0]);
static ub4   s2 = (ub4) sizeof(in2[0]);
static ub4   s3 = (ub4) sizeof(in3[0]);
static ub4   s4 = (ub4) sizeof(in4[0]);
static ub4   s5 = (ub4) sizeof(in5[0]);
static ub4   s6 = (ub4) sizeof(in6[0]);
static ub4   s7 = (ub4) sizeof(in7[0]);
static ub4   s8 = (ub4) sizeof(in8[0]);
static ub4   s9 = (ub4) sizeof(in9[0]);
static ub4   s10= (ub4) sizeof(in10[0]);

/* Rows returned in each iteration */
static ub2 rowsret[MAXITER];

/*  indicator skips */
static ub4   indsk[MAXCOLS] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
/*  return length skips */
static ub4   rlsk[MAXCOLS] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
/*  return code skips */
static ub4   rcsk[MAXCOLS] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

static int   lowc1[MAXITER], highc1[MAXITER];

static ub4   pos[MAXCOLS];
static short *ind[MAXCOLS][MAXITER];           /* indicators */
static ub2   *rc[MAXCOLS][MAXITER];            /* return codes */
static ub4   *rl[MAXCOLS][MAXITER];            /* return lengths */

static OCIError *errhp;
	text *username = (text *)"nmdbobp";
  text *password = (text *)"nmdbobp";
	text* server = (text*)"poison.metratech.com";
	
  OCIEnv *envhp;
  OCIServer *srvhp;
  OCISvcCtx *svchp;
  OCISession *authp;
  OCIStmt *stmthp;
	OCIDescribe *deschp;

  OCIBind *bndhp[MAXBINDS];
	


static sb4 cbf_no_data(dvoid *ctxp, OCIBind *bindp, ub4 iter, ub4 index,
                      dvoid **bufpp, ub4 *alenpp, ub1 *piecep, dvoid **indpp);

static sword allochandlesandlogon();

static sword DescribeTable(OCISvcCtx *deschp, OCIError *errhp, string& tablename);



#endif





