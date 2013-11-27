-- Custom Procedures written to support interfaces not supported by eConnect.
--
-- This script was built for eConnect 7.5.1.17 (7.5.1.0 with SP 17).
--
-- This script contains modifications specifically for eConnect.  This script
-- should be re-run any time that a new eConnect SP is applied.
--
Use MTGP
go

delete RM00201 where CLASSID = '(DEFAULT)'
go

insert into RM00201 (CLASSID,CLASDSCR,CRLMTTYP,CRLMTAMT,CRLMTPER,CRLMTPAM,DEFLTCLS,BALNCTYP,CHEKBKID,BANKNAME,TAXSCHID,SHIPMTHD,PYMTRMID,CUSTDISC,CSTPRLVL,MINPYTYP,MINPYDLR,MINPYPCT,MXWOFTYP,MXWROFAM,FINCHARG,FNCHATYP,FINCHDLR,FNCHPCNT,PRCLEVEL,CURNCYID,RATETPID,DEFCACTY,RMCSHACC,RMARACC,RMCOSACC,RMIVACC,RMSLSACC,RMAVACC,RMTAKACC,RMFCGACC,RMWRACC,SALSTERR,SLPRSNID,STMTCYCL,SNDSTMNT,INACTIVE,KPCALHST,KPDSTHST,KPERHIST,KPTRXHST,NOTEINDX,MODIFDT,CREATDDT,Revalue_Customer,Post_Results_To,DISGRPER,DUEGRPER)
values ('(DEFAULT)','Default Class',1,0,0,0,1,0,'','','','','',0,'',0,0,0,1,0,0,0,0,0,'','USD','',0,0,0,0,0,0,0,0,0,0,'','',5,0,0,1,1,1,1,0,'1/1/1900','1/1/1900',1,0,0,0)
go

delete RM00303 where SALSTERR = '(NOTERRITORY)'
go

insert into RM00303(SALSTERR,SLTERDSC,INACTIVE,SLPRSNID,STMGRFNM,STMGRMNM,STMGRLNM,COUNTRY,COSTTODT,TTLCOMTD,TTLCOMLY,NCOMSLYR,COMSLLYR,CSTLSTYR,COMSLTDT,NCOMSLTD,KPCALHST,KPERHIST,NOTEINDX,MODIFDT,CREATDDT)
values ('(NOTERRITORY)','No Territory Assigned',0,'','','','','',0,0,0,0,0,0,0,0,1,1,0,'1/1/1900','1/1/1900')
go

delete Dynamics..taErrorCode where ErrorCode > 30000
go

set IDENTITY_INSERT Dynamics..taErrorCode OFF
go

insert into Dynamics..taErrorCode (ErrorCode, SourceProc, ErrorDesc, ErrorKeyFields, ErrorParms) values(30001,'AccountStatusUpdate', 'Account does not exist', '', '')
go

insert into Dynamics..taErrorCode (ErrorCode, SourceProc, ErrorDesc, ErrorKeyFields, ErrorParms) values(30002,'UpdateTerritoryManagers', 'Territory does not exist', '', '')
go

insert into Dynamics..taErrorCode (ErrorCode, SourceProc, ErrorDesc, ErrorKeyFields, ErrorParms) values(30003,'UpdateTerritoryManagers', 'Sales Manager does not exist', '', '')
go

insert into Dynamics..taErrorCode (ErrorCode, SourceProc, ErrorDesc, ErrorKeyFields, ErrorParms) values(30004,'DeletePayments', 'Payment ID does not exist', '', '')
go

insert into Dynamics..taErrorCode (ErrorCode, SourceProc, ErrorDesc, ErrorKeyFields, ErrorParms) values(30005,'CreateUpdateCustomer', 'Sales Person does not exist', '', '')
go

insert into Dynamics..taErrorCode (ErrorCode, SourceProc, ErrorDesc, ErrorKeyFields, ErrorParms) values(30006,'DeleteBatches', 'BatchID does not exist', '', '')
go

insert into Dynamics..taErrorCode (ErrorCode, SourceProc, ErrorDesc, ErrorKeyFields, ErrorParms) values(30007,'DeleteInvoice', 'InvoiceID does not exist', '', '')
go

insert into Dynamics..taErrorCode (ErrorCode, SourceProc, ErrorDesc, ErrorKeyFields, ErrorParms) values(30008,'DeleteDebit', 'Debit Adjustment does not exist', '', '')
go

insert into Dynamics..taErrorCode (ErrorCode, SourceProc, ErrorDesc, ErrorKeyFields, ErrorParms) values(30009,'DeleteCredit', 'Credit Adjustment does not exist', '', '')
go

insert into Dynamics..taErrorCode (ErrorCode, SourceProc, ErrorDesc, ErrorKeyFields, ErrorParms) values(30010,'DeleteCashReceipt', 'Payment does not exist', '', '')
go

insert into Dynamics..taErrorCode (ErrorCode, SourceProc, ErrorDesc, ErrorKeyFields, ErrorParms) values(30011,'DeleteBatches', 'Batch has been posted. Unable to delete the batch.', '', '')
go

insert into Dynamics..taErrorCode (ErrorCode, SourceProc, ErrorDesc, ErrorKeyFields, ErrorParms) values(30012,'GreatPlainsExec', 'An Unknown Error has occurred', '', '')
go

insert into Dynamics..taErrorCode (ErrorCode, SourceProc, ErrorDesc, ErrorKeyFields, ErrorParms) values(30013,'MoveBalance', 'No records to Move', '', '')
go

insert into Dynamics..taErrorCode (ErrorCode, SourceProc, ErrorDesc, ErrorKeyFields, ErrorParms) values(30014,'CanDeleteDocument', 'Document does not exist', '', '')
go

insert into Dynamics..taErrorCode (ErrorCode, SourceProc, ErrorDesc, ErrorKeyFields, ErrorParms) values(30015,'DeleteAccountStatusChange', 'ChangeID does not exist', '', '')
go

IF EXISTS (SELECT name FROM   sysobjects WHERE  name = 'MT_Outstanding_Transactions' AND type = 'V')
   DROP View MT_Outstanding_Transactions
go

Create View MT_Outstanding_Transactions
as

-- Max value of TRXDSCRN (DOCDESCR) is 31 characters.

-- posted, outstanding (not fully applied) txns
select DOCNUMBR,RMDTYPAL,CURTRXAM,CUSTNMBR,DOCDATE,TRXDSCRN,CSHRCTYP,CHEKNMBR,FRTSCHID as CRCARDID, 
case when RMDTYPAL in (1,3,4,5,6) then CURTRXAM else CURTRXAM * -1 end CURTRXAM1 
from RM20101 where CURTRXAM > 0 
union
-- unposted, outstanding (not fully applied) sales txns
select DOCNUMBR,RMDTYPAL,DOCAMNT as CURTRXAM,CUSTNMBR,DOCDATE,DOCDESCR as TRXDSCRN,0 as CSHRCTYP,CHEKNMBR,FRTSCHID as CQCARDID, 
case when RMDTYPAL in (1,3,4,5,6) then DOCAMNT else DOCAMNT * -1 end CURTRXAM1
from RM10301 where DOCAMNT - APPLDAMT > 0
union
-- unposted, outstanding (not fully applied) payments
select DOCNUMBR,RMDTYPAL,CURTRXAM,CUSTNMBR,DOCDATE,TRXDSCRN,CSHRCTYP,CHEKNMBR,CRCARDID, 
case when RMDTYPAL in (1,3,4,5,6) then CURTRXAM else CURTRXAM * -1 end CURTRXAM1
from RM10201 where CURTRXAM > 0

go

IF EXISTS (SELECT name FROM   sysobjects WHERE  name = 'MT_Update_CustomerStatus' AND type = 'P')
   DROP PROCEDURE MT_Update_CustomerStatus
go

Create Procedure MT_Update_CustomerStatus
@I_vCUSTNMBR char(15),
@I_vHOLD tinyint,
@I_vINACTIVE tinyint,
@O_iErrorState int output,            /* Return value:  0=No Errors, 1=Error Occurred */
@oErrString varchar(255) output       /* Return Error Code List                       */

as

declare @O_oErrorState int
declare @iErrString varchar(255)
declare @iStatus int

if @O_iErrorState is NULL
begin
  select @O_iErrorState = 0
end

if (select count(*) from RM00101 where CUSTNMBR = @I_vCUSTNMBR) > 0 
begin
        update RM00101 set HOLD = @I_vHOLD, INACTIVE = @I_vINACTIVE
        where CUSTNMBR = @I_vCUSTNMBR
end
else
begin
        select @O_iErrorState = 30001
        exec @iStatus = taUpdateString @O_iErrorState,@oErrString,@oErrString output,@O_oErrorState output 
end

return(@O_iErrorState)

go

IF EXISTS (SELECT name FROM   sysobjects WHERE  name = 'MT_CreateUpdate_Territory' AND type = 'P')
   DROP PROCEDURE MT_CreateUpdate_Territory
go

Create Procedure MT_CreateUpdate_Territory
@I_vSALSTERR char(15),
@I_vSLTERDSC char(30) = ' ',
@I_vCOUNTRY char(20)= ' ',
@I_vKPCALHST tinyint=1,
@I_vKPERHIST tinyint=1,
@O_iErrorState int output,            /* Return value:  0=No Errors, 1=Error Occurred */
@oErrString varchar(255) output       /* Return Error Code List                       */

as
select @O_iErrorState = 0

if (select count(*) from RM00303 where SALSTERR = @I_vSALSTERR) > 0 
begin
        update RM00303 set SLTERDSC = @I_vSLTERDSC, COUNTRY = @I_vCOUNTRY ,
                           KPCALHST = @I_vKPCALHST, KPERHIST = @I_vKPERHIST
        where SALSTERR = @I_vSALSTERR
end
else
begin
        insert into RM00303(SALSTERR, SLTERDSC, COUNTRY, KPCALHST, KPERHIST)
        values (@I_vSALSTERR, @I_vSLTERDSC, @I_vCOUNTRY, @I_vKPCALHST, @I_vKPERHIST)
end

return(@O_iErrorState)

go

IF EXISTS (SELECT name FROM   sysobjects WHERE  name = 'MT_Update_TerritoryManagers' AND type = 'P')
   DROP PROCEDURE MT_Update_TerritoryManagers
go

Create Procedure MT_Update_TerritoryManagers
@I_vSALSTERR char(15),
@I_vSLPRSNID char(15) = NULL,
@O_iErrorState int output,            /* Return value:  0=No Errors, 1=Error Occurred */
@oErrString varchar(255) output       /* Return Error Code List                       */

as
declare @O_oErrorState int
declare @iErrString varchar(255)
declare @iStatus int

if (select count(*) from RM00303 where SALSTERR = @I_vSALSTERR) > 0 
begin
      if (select count(*) from RM00301 where SLPRSNID = @I_vSLPRSNID) > 0         
      begin
        update RM00303 set SLPRSNID = @I_vSLPRSNID,STMGRFNM = SLPRSNFN,STMGRMNM = SPRSNSMN, STMGRLNM = SPRSNSLN 
        from RM00303,RM00301  where RM00303.SALSTERR = @I_vSALSTERR and RM00301.SLPRSNID = @I_vSLPRSNID 

        update RM00101 set SLPRSNID = @I_vSLPRSNID where SALSTERR = @I_vSALSTERR   

        update RM00301 set SALSTERR = @I_vSALSTERR where SLPRSNID = @I_vSLPRSNID
      end
      else
      begin
        select @O_iErrorState = 30003
        exec @iStatus = taUpdateString @O_iErrorState,@oErrString,@oErrString output,@O_oErrorState output 
      end    
end
else
begin
        select @O_iErrorState = 30002
        exec @iStatus = taUpdateString @O_iErrorState,@oErrString,@oErrString output,@O_oErrorState output 
end

return(@O_iErrorState)

go


IF EXISTS (SELECT name FROM   sysobjects WHERE  name = 'taUpdateCreateCustomerRcdPre' AND type = 'P')
   DROP PROCEDURE taUpdateCreateCustomerRcdPre
go

create procedure taUpdateCreateCustomerRcdPre
@I_vCUSTNMBR char(15) output,   
@I_vHOLD tinyint output,   
@I_vINACTIVE tinyint output,   
@I_vCUSTNAME char(64) output,   
@I_vSHRTNAME char(15) output,   
@I_vSTMTNAME char(64) output,   
@I_vCUSTCLAS char(15) output,   
@I_vCUSTPRIORITY smallint output,  
@I_vADRSCODE char(15) output,   
@I_vCNTCPRSN char(30) output,   
@I_vADDRESS1 char(30) output,   
@I_vADDRESS2 char(30) output,     
@I_vADDRESS3 char(30) output,     
@I_vCITY char(30) output,   
@I_vSTATE char(29) output,   
@I_vZIPCODE char(10) output,    
@I_vCCode char(6) output,   
@I_vCOUNTRY char(20) output,   
@I_vPHNUMBR1 char(14) output,   
@I_vPHNUMBR2 char(14) output,   
@I_vPHNUMBR3 char(14) output,   
@I_vFAX char(14) output,   
@I_vUPSZONE char(3) output,
@I_vSHIPMTHD char(15) output,   
@I_vTAXSCHID char(15) output,   
@I_vSHIPCOMPLETE tinyint output,  
@I_vPRSTADCD char(15) output,   
@I_vPRBTADCD char(15) output,   
@I_vSTADDRCD char(15) output,   
@I_vSLPRSNID char(15) output,   
@I_vSALSTERR char(15) output,   
@I_vUSERDEF1 char(20) output,   
@I_vUSERDEF2 char(20) output,    
@I_vCOMMENT1 char(30) output,    
@I_vCOMMENT2 char(30) output,    
@I_vCUSTDISC numeric(19,2) output,  
@I_vPYMTRMID char(20) output,   
@I_vDISGRPER smallint output,    
@I_vDUEGRPER smallint output,   
@I_vPRCLEVEL char(10) output,   
@I_vNOTETEXT varchar(8000) output,  
@I_vBALNCTYP tinyint output,   
@I_vFNCHATYP smallint output,   
@I_vFNCHPCNT numeric(19,2) output,  
@I_vFINCHDLR numeric(19,5) output,  
@I_vMINPYTYP smallint output,   
@I_vMINPYPCT numeric(19,2) output,  
@I_vMINPYDLR numeric(19,5) output,  
@I_vCRLMTTYP smallint output,   
@I_vCRLMTAMT numeric(19,5) output,  
@I_vCRLMTPER smallint output,   
@I_vCRLMTPAM numeric(19,5) output,  
@I_vMXWOFTYP smallint output,   
@I_vMXWROFAM numeric(19,5) output,  
@I_vRevalue_Customer tinyint output,  
@I_vPost_Results_To smallint output,  
@I_vORDERFULFILLDEFAULT tinyint output,  
@I_vINCLUDEINDP tinyint output,   
@I_vCRCARDID char(15) output,   
@I_vCRCRDNUM char(20) output,   
@I_vCCRDXPDT datetime output,   
@I_vBANKNAME char(30) output,   
@I_vBNKBRNCH char(20) output,   
@I_vUSERLANG smallint output,   
@I_vTAXEXMT1 char(25) output,   
@I_vTAXEXMT2 char(25) output,   
@I_vTXRGNNUM char(25) output,   
@I_vCURNCYID char(15) output,   
@I_vRATETPID char(15) output,   
@I_vSTMTCYCL smallint output,   
@I_vKPCALHST tinyint output,   
@I_vKPERHIST tinyint output,   
@I_vKPTRXHST tinyint output,   
@I_vKPDSTHST tinyint output,   
@I_vSend_Email_Statements tinyint output, 
@I_vToEmail_Recipient char(80) output,   
@I_vCcEmail_Recipient char(80) output,   
@I_vBccEmail_Recipient char(80) output,   
@I_vCHEKBKID char(15) output,   
@I_vDEFCACTY smallint output,   
@I_vRMCSHACTNUMST varchar(75) output,  
@I_vRMARACTNUMST varchar(75) output,  
@I_vRMSLSACTNUMST varchar(75) output, 
@I_vRMCOSACTNUMST varchar(75) output,  
@I_vRMIVACTNUMST varchar(75) output,  
@I_vRMTAKACTNUMST varchar(75) output,  
@I_vRMAVACTNUMST varchar(75) output,  
@I_vRMFCGACTNUMST varchar(75) output,  
@I_vRMWRACTNUMST varchar(75) output,  
@I_vRMSORACTNUMST varchar(75) output,  
@I_vRMOvrpymtWrtoffACTNUMST varchar(75) output, 
@I_vGPSFOINTEGRATIONID char(30) output,  
@I_vINTEGRATIONSOURCE smallint output,  
@I_vINTEGRATIONID char(30) output,  
@I_vUseCustomerClass tinyint output,  
@I_vCreateAddress tinyint output,  
@I_vUpdateIfExists tinyint output,  
@I_vRequesterTrx smallint output,  
@I_vUSRDEFND1 char(50) output,       
@I_vUSRDEFND2 char(50) output,       
@I_vUSRDEFND3 char(50) output,       
@I_vUSRDEFND4 varchar(8000) output,  
@I_vUSRDEFND5 varchar(8000) output,  
@O_iErrorState int output, 
@oErrString varchar(255) 
output as set nocount on select @O_iErrorState = 0 

declare @O_oErrorState int
declare @iErrString varchar(255)
declare @iStatus int

/* Create Custom Business Logic */

      if (select count(*) from RM00301 where SLPRSNID = @I_vSLPRSNID) = 0 and @I_vSLPRSNID not like ' ' and @I_vSLPRSNID is not null        
      begin
        select @O_iErrorState = 30005
        exec @iStatus = taUpdateString @O_iErrorState,@oErrString,@oErrString output,@O_oErrorState output 
      end   
      if (select count(*) from RM00303 where SALSTERR = @I_vSALSTERR) = 0 and @I_vSALSTERR not like ' ' and @I_vSALSTERR is not null
      begin
        select @O_iErrorState = 30002
        exec @iStatus = taUpdateString @O_iErrorState,@oErrString,@oErrString output,@O_oErrorState output 
      end

/* End Create Custom Business Logic */ 

return (@O_iErrorState)

go

IF EXISTS (SELECT name FROM   sysobjects WHERE  name = 'MT_Age_Customer' AND type = 'P')
   DROP PROCEDURE MT_Age_Customer
go

Create Procedure MT_Age_Customer
@I_vBalanceType int = 0,
@I_vBeginCustNumber char(15) = '00000',
@I_vEndCustNumber char(15) = 'zzzzz',
@I_vAgingDate datetime = GetDate,
@I_vStatementCycle int = 127,
@I_vAgeFinanceCharges tinyint = 1,
@O_iErrorState int output,              /* Return value:  0=No Errors, 1=Error Occurred */
@oErrString varchar(255) output         /* Return Error Code List                       */
as
DECLARE @O_oErrorState int
DECLARE @iStatus int

-- The following are parameters added to eConnect 10. Using false and null currently.
DECLARE @UsingCustomRange tinyint
DECLARE @MarkedTable varchar(15)
set @UsingCustomRange = 0

exec @iStatus = rmAgeCustomer @I_vBalanceType,@I_vBeginCustNumber,@I_vEndCustNumber,@I_vAgingDate,@I_vStatementCycle,@I_vAgeFinanceCharges,@UsingCustomRange,@MarkedTable,@O_oErrorState output

return @iStatus
go

IF EXISTS (SELECT name FROM   sysobjects WHERE  name = 'MT_GetAll_OpenCredits' AND type = 'P')
   DROP PROCEDURE MT_GetAll_OpenCredits
go


Create Procedure MT_GetAll_OpenCredits
as

SELECT DOCNUMBR,RMDTYPAL,DOCDATE,CUSTNMBR,CURTRXAM FROM RM20101 WHERE CURTRXAM > 0 and RMDTYPAL in (7,9)
ORDER BY CUSTNMBR,DUEDATE,DOCNUMBR
go

IF EXISTS (SELECT name FROM   sysobjects WHERE  name = 'MT_GetAll_OpenDebits' AND type = 'P')
   DROP PROCEDURE MT_GetAll_OpenDebits
go

Create Procedure MT_GetAll_OpenDebits
@CUSTNMBR varchar(17)
as

SELECT DOCNUMBR,RMDTYPAL,DOCDATE,CUSTNMBR,CURTRXAM FROM RM20101 WHERE CURTRXAM > 0 and RMDTYPAL in (1,3) and CUSTNMBR = @CUSTNMBR
ORDER BY CUSTNMBR,DUEDATE,DOCNUMBR
go

IF EXISTS (SELECT name FROM   sysobjects WHERE  name = 'MT_Get_Balances' AND type = 'P')
   DROP PROCEDURE MT_Get_Balances 
go

CREATE PROC MT_Get_Balances @CustomerData text 
AS 
DECLARE @xmlDoc int 
DECLARE @ErrCustomer varchar(15)
EXEC sp_xml_preparedocument @xmlDoc OUTPUT, @CustomerData
if (SELECT count(*) from OPENXML (@xmlDoc, '/ARDocuments/ARDocument/GetBalance',1) WITH (ExtAccountID  varchar(15))
    WHERE ExtAccountID not in (SELECT CUSTNMBR from RM00101)) > 0 
begin
    SELECT @ErrCustomer = (SELECT Min(ExtAccountID) from OPENXML (@xmlDoc, '/ARDocuments/ARDocument/GetBalance',1) WITH (ExtAccountID  varchar(15))
    WHERE ExtAccountID not in (SELECT CUSTNMBR from RM00101))
    EXEC sp_xml_removedocument @xmlDoc 
    RAISERROR ('<ARDocuments><ARDocument><Errors><Error><Code>30001</Code><Message>Account %s does not exist in the system</Message></Error></Errors></ARDocument></ARDocuments>',16,1,@ErrCustomer)
end
else
begin
    SELECT ExtAccountID,CUSTBLNC + UNPSTDSA - UNPSTDCA as CurrentUnpostedBalance
    FROM OPENXML (@xmlDoc, '/ARDocuments/ARDocument/GetBalance',1) WITH (ExtAccountID  varchar(15)),RM00103 
    WHERE RM00103.CUSTNMBR = ExtAccountID
    EXEC sp_xml_removedocument @xmlDoc 
end
go

IF EXISTS (SELECT name FROM   sysobjects WHERE  name = 'MT_Get_BalanceDetails' AND type = 'P')
   DROP PROCEDURE MT_Get_BalanceDetails 
go


CREATE PROC MT_Get_BalanceDetails @CustomerData text 
AS 
DECLARE @xmlDoc int 
DECLARE @ErrCustomer varchar(15)
EXEC sp_xml_preparedocument @xmlDoc OUTPUT, @CustomerData
if (SELECT count(*) FROM OPENXML (@xmlDoc, '/ARDocuments/ARDocument/GetBalanceDetails',1) WITH (ExtAccountID  varchar(15))
    WHERE ExtAccountID not in (SELECT CUSTNMBR FROM RM00101)) > 0 
begin
    SELECT @ErrCustomer = (SELECT Min(ExtAccountID) FROM OPENXML (@xmlDoc, '/ARDocuments/ARDocument/GetBalanceDetails',1) WITH (ExtAccountID  varchar(15))
    WHERE ExtAccountID not in (SELECT CUSTNMBR FROM RM00101))
    EXEC sp_xml_removedocument @xmlDoc 
    RAISERROR ('<ARDocuments><ARDocument><Errors><Error><Code>30001</Code><Message>Account %s does not exist in the system</Message></Error></Errors></ARDocument></ARDocuments>',16,1,@ErrCustomer)
end
else
begin
    SELECT ExtAccountID,CUSTBLNC as CurrentPostedBalance,CUSTBLNC + UNPSTDSA - UNPSTDCA as CurrentUnpostedBalance,
    UNPSTDCA CurrentUnpostedCredits,UNPSTDSA CurrentUnpostedDebits,AGPERAMT_1,AGPERAMT_2,AGPERAMT_3,AGPERAMT_4,
    AGPERAMT_5,AGPERAMT_6,AGPERAMT_7         
    FROM OPENXML (@xmlDoc, '/ARDocuments/ARDocument/GetBalanceDetails',1) WITH (ExtAccountID  varchar(15)),RM00103 
    WHERE RM00103.CUSTNMBR = ExtAccountID
    EXEC sp_xml_removedocument @xmlDoc 
end

go

IF EXISTS (SELECT name FROM   sysobjects WHERE  name = 'MT_Get_AgingConfiguration' AND type = 'P')
   DROP PROCEDURE MT_Get_AgingConfiguration 
go


Create Procedure MT_Get_AgingConfiguration
as
select Index1 as AgingBucketIdx,RMPERDSC as Description,
case when INDEX1 = 1 then 0 else (select RMPEREND+1 from RM40201 RM40201a where RM40201a.INDEX1 = RM40201.INDEX1-1) End StartDay,
RMPEREND EndDay
from RM40201 where INDEX1 <= 7

go

IF EXISTS (SELECT name FROM   sysobjects WHERE  name = 'MT_GetNextNumber' AND type = 'FN')
   DROP Function MT_GetNextNumber 
go

CREATE function MT_GetNextNumber(@Prefix varchar(5))
returns varchar(17)
as
begin

-- This method is used in: MT_MoveBalance_Details

declare @NextDocNumStr varchar(17), @NextNumStr varchar(17)
declare @PrefixLen int, @MvBalDocNumLen int, @PrevDocNum bigint, @NextDocNum bigint
declare @NextNumStrLen int, @NumZeros int

set @PrefixLen      = len(@Prefix)
set @MvBalDocNumLen = 14     -- The longest document number we support is 14 characters.
                             -- This is done so that we have room to append a version number
                             -- ("_00") if necessary.
set @PrevDocNum =
 (select isnull(max(convert(int,substring(DOCNUMBR,@PrefixLen+1,@MvBalDocNumLen))), '0')
  from RM00401
  where (DOCNUMBR like @Prefix + '%')
    and ((isnumeric(substring(DOCNUMBR,@PrefixLen+1,@MvBalDocNumLen))) = 1)
 )

set @NextDocNum = @PrevDocNum + 1

if  (@PrefixLen = 0 and @NextDocNum > 99999999999999)
 or (@PrefixLen = 1 and @NextDocNum > 9999999999999)
 or (@PrefixLen = 2 and @NextDocNum > 999999999999)
 or (@PrefixLen = 3 and @NextDocNum > 99999999999)
 or (@PrefixLen = 4 and @NextDocNum > 9999999999)
 or (@PrefixLen = 5 and @NextDocNum > 999999999)
  set @NextDocNumStr = null   -- This is an error.
else
begin
  set @NextNumStr    = convert(varchar(14), @NextDocNum)
  set @NextNumStrLen = len(@NextNumStr)

  set @NumZeros = 14 - (@PrefixLen + @NextNumStrLen)

  if (@NumZeros > 0)
    set @NextDocNumStr = @Prefix + replicate('0', @NumZeros) + @NextNumStr
  else
    set @NextDocNumStr = @Prefix + @NextNumStr
end

return @NextDocNumStr
end

go

IF EXISTS (SELECT name FROM   sysobjects WHERE  name = 'MT_GetOriginDocument' AND type = 'FN')
   DROP Function MT_GetOriginDocument 
go


CREATE function MT_GetOriginDocument(@DOCNUMBR  varchar(17),
                                     @Seperator varchar(1))
returns varchar(17)
as
begin

-- This method is used in: MT_MoveBalance_Details

declare @ActualDocument varchar(17)
declare @SeperatorIndex int

-- @SeperatorIndex is -1 if the separator is not found.
-- @SeperatorIndex is  0 if the separator is the first character.
-- @SeperatorIndex points to the character before the separator character otherwise.
set @SeperatorIndex = charindex(@Seperator,@DOCNUMBR) - 1

if (@SeperatorIndex < 0)
  set @ActualDocument = rtrim(@DOCNUMBR)
else if (@SeperatorIndex > 0)
  set @ActualDocument = substring(@DOCNUMBR, 1, @SeperatorIndex)
else
  set @ActualDocument = ''

return @ActualDocument
end

go


IF EXISTS (SELECT name FROM   sysobjects WHERE  name = 'MT_GetDocumentRevision' AND type = 'FN')
   DROP Function MT_GetDocumentRevision 
go


CREATE function MT_GetDocumentRevision(@DOCNUMBR  varchar(17),
                                       @Seperator varchar(1))
returns int
as
begin

-- This method is used in: MT_MoveBalance_Details

declare @DocumentRevision int, @SeperatorIndex int, @DocNumberLength int

set @DocNumberLength = len(@DOCNUMBR)
set @SeperatorIndex = charindex(@Seperator,@DOCNUMBR)

if (@SeperatorIndex > 0)
  set @DocumentRevision = convert(int,substring(@DOCNUMBR, @SeperatorIndex + 1, @DocNumberLength - @SeperatorIndex))
else
  set @DocumentRevision = 0

return @DocumentRevision
end

go

IF EXISTS (SELECT name FROM sysobjects WHERE  name = 'MT_NewDocumentRevision' AND type = 'FN')
   DROP Function MT_NewDocumentRevision 
go

CREATE function MT_NewDocumentRevision(@DOCNUMBR  varchar(17),
                                       @Seperator varchar(1),
                                       @VERSION   int)
returns varchar(17)
as
begin

-- This method is used in: MT_MoveBalance_Details

declare @NewDocument varchar(17)
declare @NewVersion int

set @NewVersion = @VERSION + 1

if (len(@DOCNUMBR) > 14)   -- This is an error.
  set @NewDocument = null
else if (@NewVersion > 99) -- This is an error.
  set @NewDocument = null
else if (@NewVersion < 10)
  set @NewDocument = @DOCNUMBR + @Seperator + '0' + convert(varchar(1), @NewVersion)
else
  set @NewDocument = @DOCNUMBR + @Seperator + convert(varchar(2), @NewVersion)

return @NewDocument
end

go

IF EXISTS (SELECT name FROM   sysobjects WHERE  name = 'MT_MoveBalance_Details' AND type = 'TF')
   DROP function MT_MoveBalance_Details 
go

CREATE function MT_MoveBalance_Details(@FromCustNo varchar(15),
                                       @ToCustNo varchar(15),
                                       @ReversalDate datetime,
                                       @Prefix varchar(5),
                                       @Seperator varchar(1))
returns @MoveBalanceDetails table (DOCNUMBR varchar(17),
                                   RMDTYPAL smallint,
                                   CURTRXAM numeric(19,5),
                                   CUSTNMBR varchar(15),
                                   DOCDATE datetime,
                                   TXNDESC varchar(32),  -- Maximum of 32 for TRXDSCRN or
                                                         -- 15 for @ToCustNo plus 17 for @DescString
                                   CSHRCTYP smallint,
                                   CRCARDID varchar(15),
                                   CHEKNMBR varchar(15))
as
begin

  -- This method is used in: MT_Get_MoveBalanceDetails

  -- get the amount to reverse (outstanding balance)

  declare @ReversalTrxAmount numeric (19,5)

  select @ReversalTrxAmount =
   (select sum(CURTRXAM1)
    from MT_Outstanding_Transactions
    where CUSTNMBR = @FromCustNo
   )

  declare @DescString varchar(17)  -- Must also increase TXNDESC if @DescString is increased.
  set @DescString = 'Balance moved to '

  declare @DOCNUMBR varchar(17), @RMDTYPAL int, @CURTRXAM numeric(19,5)
  declare @CUSTNMBR varchar(15), @DOCDATE datetime, @TRXDSCRN varchar(31)
  declare @CSHRCTYP int, @CRCARDID varchar(20), @CHEKNMBR varchar(15)

  declare @NextDocNumber varchar(17)

  -- documents generated in current sproc

  declare @GeneratedDocs table(DOCBASE varchar(14), DOCOFFSET int)

  if @ReversalTrxAmount <> 0 
  begin
    -- get cursor over all outstanding transactions for FromCustNo
    declare Outstanding_Trans cursor for 
            select DOCNUMBR,RMDTYPAL,CURTRXAM,CUSTNMBR,
                   DOCDATE,TRXDSCRN,CSHRCTYP,CRCARDID,CHEKNMBR  -- TRXDSCRN can be up to 31 characters long.
            from MT_Outstanding_Transactions
            where CUSTNMBR = @FromCustNo

    open Outstanding_Trans
  
    fetch next from Outstanding_Trans
               into @DOCNUMBR,@RMDTYPAL,@CURTRXAM,@CUSTNMBR,
                    @DOCDATE,@TRXDSCRN,@CSHRCTYP,@CRCARDID,@CHEKNMBR 

    declare @DocBase varchar(14), @LastRevision int

    -- loop to create copied doc for ToCust for each outstaning txn of FromCust
    while @@FETCH_STATUS = 0
    begin

      set @DocBase = dbo.MT_GetOriginDocument(@DOCNUMBR, @Seperator)

      -- do we already know about this document...
      set @LastRevision = null
      select @LastRevision = DOCOFFSET from @GeneratedDocs where DOCBASE = @DocBase

      if (@LastRevision is null)
      begin

        -- get max revision of current doc (in RM master)
        select @LastRevision =
         (select max(dbo.MT_GetDocumentRevision(DOCNUMBR,@Seperator))
          from RM00401 
          where DOCNUMBR like @DocBase + '%'
         )

      end -- if (@LastRevision is null)

      set @LastRevision = @LastRevision + 1

      -- remember this number
      insert into @GeneratedDocs values(@DocBase, @LastRevision)

      -- get new revision based on last revision
      -- note: MT_GetOriginDocument must be equal to or less than
      --                      17 - 3 (separator + 2 digit revision)
      -- note: MT_NewDocumentRevision increments @LastRevision before
      --       using it.
      set @NextDocNumber = dbo.MT_NewDocumentRevision(@DocBase,
                                                      @Seperator,
                                                      @LastRevision - 1)

      -- add document to returned temp table
      insert into @MoveBalanceDetails(DOCNUMBR,RMDTYPAL,CURTRXAM,CUSTNMBR,
                                      DOCDATE,TXNDESC,CSHRCTYP,CRCARDID,CHEKNMBR)
      values(@NextDocNumber,@RMDTYPAL,@CURTRXAM,@ToCustNo,
             @DOCDATE,@TRXDSCRN,@CSHRCTYP,@CRCARDID,@CHEKNMBR)

      fetch next from Outstanding_Trans
                 into @DOCNUMBR,@RMDTYPAL,@CURTRXAM,@CUSTNMBR,
                      @DOCDATE,@TRXDSCRN,@CSHRCTYP,@CRCARDID,@CHEKNMBR 
    end

    close Outstanding_Trans
    deallocate Outstanding_Trans

    -- create reversal doc to nullify FromCust balance
    if @ReversalTrxAmount > 0
    begin
      -- create credit memo
      insert into @MoveBalanceDetails(DOCNUMBR,RMDTYPAL,CURTRXAM,CUSTNMBR,
                                      DOCDATE,TXNDESC,CSHRCTYP,CRCARDID,CHEKNMBR)
      select dbo.MT_GetNextNumber(@Prefix),7,@ReversalTrxAmount,@FromCustNo,
                                  @ReversalDate, @DescString + @ToCustNo,
                                  0,'',''
    end
    else if @ReversalTrxAmount < 0 
    begin
      -- create debit memo
      insert into @MoveBalanceDetails(DOCNUMBR,RMDTYPAL,CURTRXAM,CUSTNMBR,
                                      DOCDATE,TXNDESC,CSHRCTYP,CRCARDID,CHEKNMBR)
      select dbo.MT_GetNextNumber(@Prefix),3,@ReversalTrxAmount * (-1),
                                  @FromCustNo,@ReversalDate, @DescString + @ToCustNo,
                                  0,'',''
    end
  end

  return
end

go

IF EXISTS (SELECT name FROM   sysobjects WHERE  name = 'MT_Get_MoveBalanceDetails' AND type = 'P')
   DROP PROCEDURE MT_Get_MoveBalanceDetails 
go

Create Proc MT_Get_MoveBalanceDetails
@FromCustNo varchar(15),@ToCustNo varchar(15),@BatchID varchar(15),@Prefix varchar(5),@Seperator varchar(1),@MoveDate datetime
as

if (Select count(*) from RM00101 where CUSTNMBR = @FromCustNo) = 0 
begin
    Raiserror('<ARDocuments><ARDocument><Errors><Error><Code>30001</Code><Message>Account %s does not exist in the system</Message></Error></Errors></ARDocument></ARDocuments>' , 16,1,@FromCustNo)
end
else
begin
    if (Select count(*) from RM00101 where CUSTNMBR = @ToCustNo) = 0 
    begin    
      Raiserror('<ARDocuments><ARDocument><Errors><Error><Code>30001</Code><Message>Account %s does not exist in the system</Message></Error></Errors></ARDocument></ARDocuments>' , 16,1,@ToCustNo)
    end
    else
    begin
      select *,@BatchID BACHNUMB from MT_MoveBalance_Details(@FromCustNo,@ToCustNo,@MoveDate,@Prefix,@Seperator)   
    end  
end

go

IF EXISTS (SELECT name FROM   sysobjects WHERE  name = 'MT_Sales_Invoice_Delete' AND type = 'P')
   DROP PROCEDURE MT_Sales_Invoice_Delete 
go

CREATE PROCEDURE MT_Sales_Invoice_Delete
@I_vDOCNUMBR varchar(17),
@O_iErrorState int output,            /* Return value:  0=No Errors, 1=Error Occurred */
@oErrString varchar(255) output       /* Return Error Code List                       */
AS
declare @O_oErrorState int,@iErrString varchar(255),@iStatus int
if (SELECT COUNT(*) FROM RM10301 WHERE DOCNUMBR = @I_vDOCNUMBR and RMDTYPAL = '1') > 0
begin
        UPDATE SY00500 
        SET BCHTOTAL = BCHTOTAL - DOCAMNT, NUMOFTRX = NUMOFTRX - 1
        FROM RM10301,SY00500
        WHERE RM10301.BACHNUMB = SY00500.BACHNUMB AND RM10301.BCHSOURC = SY00500.BCHSOURC AND RM10301.DOCNUMBR = @I_vDOCNUMBR
        AND RM10301.RMDTYPAL = '1'
        
        UPDATE RM00103 
        SET UNPSTDSA = UNPSTDSA - DOCAMNT 
        FROM RM00103,RM10301 
        WHERE RM10301.DOCNUMBR = @I_vDOCNUMBR AND RM10301.RMDTYPAL = '1' AND RM00103.CUSTNMBR = RM10301.CUSTNMBR 
        
        DELETE RM10101 WHERE DOCNUMBR = @I_vDOCNUMBR AND RMDTYPAL = '1'

        DELETE RM10301 WHERE DOCNUMBR = @I_vDOCNUMBR AND RMDTYPAL = '1'
        
        DELETE RM00401 WHERE DOCNUMBR = @I_vDOCNUMBR AND RMDTYPAL = '1'

        DELETE RM10601 WHERE DOCNUMBR = @I_vDOCNUMBR AND RMDTYPAL = '1'    /* Remove any entries from tax detail table */

end
else
begin
        select @O_iErrorState = 30007
        exec @iStatus = taUpdateString @O_iErrorState,@oErrString,@oErrString output,@O_oErrorState output 
end
return (@O_iErrorState)

go

IF EXISTS (SELECT name FROM   sysobjects WHERE  name = 'MT_Sales_Debit_Delete' AND type = 'P')
   DROP PROCEDURE MT_Sales_Debit_Delete 
go

CREATE PROCEDURE MT_Sales_Debit_Delete
@I_vDOCNUMBR varchar(17),
@O_iErrorState int output,            /* Return value:  0=No Errors, 1=Error Occurred */
@oErrString varchar(255) output       /* Return Error Code List                       */
AS
declare @O_oErrorState int,@iErrString varchar(255),@iStatus int

if (SELECT COUNT(*) FROM RM10301 WHERE DOCNUMBR = @I_vDOCNUMBR and RMDTYPAL = '3') > 0
begin
        UPDATE SY00500 
        SET BCHTOTAL = BCHTOTAL - DOCAMNT, NUMOFTRX = NUMOFTRX - 1
        FROM RM10301,SY00500
        WHERE RM10301.BACHNUMB = SY00500.BACHNUMB AND RM10301.BCHSOURC = SY00500.BCHSOURC AND RM10301.DOCNUMBR = @I_vDOCNUMBR
        AND RM10301.RMDTYPAL = '3'
        
        UPDATE RM00103 
        SET UNPSTDSA = UNPSTDSA - DOCAMNT 
        FROM RM00103,RM10301 
        WHERE RM10301.DOCNUMBR = @I_vDOCNUMBR AND RM10301.RMDTYPAL = '3' AND RM00103.CUSTNMBR = RM10301.CUSTNMBR 
        
        DELETE RM10101 WHERE DOCNUMBR = @I_vDOCNUMBR AND RMDTYPAL = '3'

        DELETE RM10301 WHERE DOCNUMBR = @I_vDOCNUMBR AND RMDTYPAL = '3'
        
        DELETE RM00401 WHERE DOCNUMBR = @I_vDOCNUMBR AND RMDTYPAL = '3'
end
else
begin
        select @O_iErrorState = 30008
        exec @iStatus = taUpdateString @O_iErrorState,@oErrString,@oErrString output,@O_oErrorState output 
end
return(@O_iErrorState)

go

IF EXISTS (SELECT name FROM   sysobjects WHERE  name = 'MT_Sales_Credit_Delete' AND type = 'P')
   DROP PROCEDURE MT_Sales_Credit_Delete 
go

CREATE PROCEDURE MT_Sales_Credit_Delete
@I_vDOCNUMBR varchar(17),
@O_iErrorState int output,            /* Return value:  0=No Errors, 1=Error Occurred */
@oErrString varchar(255) output       /* Return Error Code List                       */
AS
declare @O_oErrorState int,@iErrString varchar(255),@iStatus int

if (SELECT COUNT(*) FROM RM10301 WHERE DOCNUMBR = @I_vDOCNUMBR and RMDTYPAL = '7') > 0
begin
        UPDATE RM20101 
        SET CURTRXAM = CURTRXAM + APPTOAMT 
        FROM RM20101,RM20201 
        WHERE DOCNUMBR = APTODCNM AND APTODCTY = RMDTYPAL AND APFRDCNM = @I_vDOCNUMBR AND APFRDCTY = '7'
        
        DELETE RM20201 WHERE APFRDCNM = @I_vDOCNUMBR AND APFRDCTY = '7'

        UPDATE SY00500 
        SET BCHTOTAL = BCHTOTAL - DOCAMNT, NUMOFTRX = NUMOFTRX - 1
        FROM RM10301,SY00500
        WHERE RM10301.BACHNUMB = SY00500.BACHNUMB AND RM10301.BCHSOURC = SY00500.BCHSOURC AND RM10301.DOCNUMBR = @I_vDOCNUMBR
        AND RM10301.RMDTYPAL = '7'
        
        UPDATE RM00103 
        SET UNPSTDCA = UNPSTDCA - DOCAMNT 
        FROM RM00103,RM10301 
        WHERE RM10301.DOCNUMBR = @I_vDOCNUMBR AND RM10301.RMDTYPAL = '7' AND RM00103.CUSTNMBR = RM10301.CUSTNMBR 
        
        DELETE RM10101 WHERE DOCNUMBR = @I_vDOCNUMBR AND RMDTYPAL = '7'

        DELETE RM10301 WHERE DOCNUMBR = @I_vDOCNUMBR AND RMDTYPAL = '7'
        
        DELETE RM00401 WHERE DOCNUMBR = @I_vDOCNUMBR AND RMDTYPAL = '7'
end
else
begin
        select @O_iErrorState = 30009
        exec @iStatus = taUpdateString @O_iErrorState,@oErrString,@oErrString output,@O_oErrorState output 
end
return(@O_iErrorState)

go

IF EXISTS (SELECT name FROM   sysobjects WHERE  name = 'MT_Cash_Receipt_Delete' AND type = 'P')
   DROP PROCEDURE MT_Cash_Receipt_Delete 
go

CREATE PROCEDURE MT_Cash_Receipt_Delete
@I_vDOCNUMBR varchar(17),
@O_iErrorState int output,            /* Return value:  0=No Errors, 1=Error Occurred */
@oErrString varchar(255) output       /* Return Error Code List                       */
AS
declare @O_oErrorState int,@iErrString varchar(255),@iStatus int

if (SELECT COUNT(*) FROM RM10201 WHERE DOCNUMBR = @I_vDOCNUMBR and RMDTYPAL = '9') > 0
begin
        UPDATE RM20101 
        SET CURTRXAM = CURTRXAM + APPTOAMT 
        FROM RM20101,RM20201 
        WHERE DOCNUMBR = APTODCNM AND APTODCTY = RMDTYPAL AND APFRDCNM = @I_vDOCNUMBR AND APFRDCTY = '9'
        
        DELETE RM20201 WHERE APFRDCNM = @I_vDOCNUMBR AND APFRDCTY = '9'

        UPDATE SY00500 
        SET BCHTOTAL = BCHTOTAL - ORTRXAMT, NUMOFTRX = NUMOFTRX - 1
        FROM RM10201,SY00500
        WHERE RM10201.BACHNUMB = SY00500.BACHNUMB AND RM10201.BCHSOURC = SY00500.BCHSOURC AND RM10201.DOCNUMBR = @I_vDOCNUMBR
        AND RM10201.RMDTYPAL = '9'
        
        UPDATE RM00103 
        SET UNPSTDCA = UNPSTDCA - ORTRXAMT 
        FROM RM00103,RM10201 
        WHERE RM10201.DOCNUMBR = @I_vDOCNUMBR AND RM10201.RMDTYPAL = '9' AND RM00103.CUSTNMBR = RM10201.CUSTNMBR 
        
        DELETE RM10101 WHERE DOCNUMBR = @I_vDOCNUMBR AND RMDTYPAL = '9'

        DELETE RM10201 WHERE DOCNUMBR = @I_vDOCNUMBR AND RMDTYPAL = '9'
        
        DELETE RM00401 WHERE DOCNUMBR = @I_vDOCNUMBR AND RMDTYPAL = '9'
end
else
begin
        select @O_iErrorState = 30010
        exec @iStatus = taUpdateString @O_iErrorState,@oErrString,@oErrString output,@O_oErrorState output 
end
return(@O_iErrorState)

go

IF EXISTS (SELECT name FROM   sysobjects WHERE  name = 'MT_Delete_Batch' AND type = 'P')
   DROP PROCEDURE MT_Delete_Batch 
go

Create Procedure MT_Delete_Batch
@I_vBACHNUMB varchar(15),
@O_iErrorState int output,            /* Return value:  0=No Errors, 1=Error Occurred */
@oErrString varchar(255) output       /* Return Error Code List                       */
as

declare @O_oErrorState int,@iErrString varchar(255),@iStatus int
declare @DOCNUMBR varchar(17),@DOCAMNT Numeric(19,5),@CUSTNMBR varchar(15),@RMDTYPAL int

if @O_iErrorState is NULL
begin
select @O_iErrorState = 0
end

If (Select count(*) from SY00500 where BACHNUMB = @I_vBACHNUMB) > 0
begin
  if ((Select count(*) from RM20101 where BACHNUMB = @I_vBACHNUMB) > 0 or (Select count(*) from RM30101 where BACHNUMB = @I_vBACHNUMB) > 0 )
  begin
        select @O_iErrorState = 30011
        exec @iStatus = taUpdateString @O_iErrorState,@oErrString,@oErrString output,@O_oErrorState output 
  end  
  else
  begin
        DECLARE Sales_Batch CURSOR FOR 
        SELECT DOCNUMBR, RMDTYPAL, CUSTNMBR, DOCAMNT
        FROM RM10301
        WHERE BACHNUMB = @I_vBACHNUMB
        UNION
        SELECT DOCNUMBR, RMDTYPAL, CUSTNMBR, ORTRXAMT DOCAMNT
        FROM RM10201
        WHERE BACHNUMB = @I_vBACHNUMB
        
        OPEN Sales_Batch
        
        FETCH NEXT FROM Sales_Batch 
        INTO @DOCNUMBR, @RMDTYPAL, @CUSTNMBR, @DOCAMNT
        
        WHILE @@FETCH_STATUS = 0
        BEGIN
           if @RMDTYPAL = 1
              exec MT_Sales_Invoice_Delete @DOCNUMBR,@O_iErrorState,@oErrString
           else if @RMDTYPAL = 3
              exec MT_Sales_Debit_Delete @DOCNUMBR,@O_iErrorState,@oErrString
           else if @RMDTYPAL = 7
              exec MT_Sales_Credit_Delete @DOCNUMBR,@O_iErrorState,@oErrString
           else if @RMDTYPAL = 9
              exec MT_Cash_Receipt_Delete @DOCNUMBR,@O_iErrorState,@oErrString
      
           FETCH NEXT FROM Sales_Batch 
           INTO @DOCNUMBR, @RMDTYPAL, @CUSTNMBR, @DOCAMNT
        END

        CLOSE Sales_Batch
        DEALLOCATE Sales_Batch

        Delete SY00500 where BACHNUMB = @I_vBACHNUMB
   end
end
else
begin
  if ((Select count(*) from RM20101 where BACHNUMB = @I_vBACHNUMB) > 0 or (Select count(*) from RM30101 where BACHNUMB = @I_vBACHNUMB) > 0 )
  begin
        select @O_iErrorState = 30011
        exec @iStatus = taUpdateString @O_iErrorState,@oErrString,@oErrString output,@O_oErrorState output 
  end  
  else
  begin

        select @O_iErrorState = 30006
        exec @iStatus = taUpdateString @O_iErrorState,@oErrString,@oErrString output,@O_oErrorState output 
  end
end  
return(@O_iErrorState)

go

IF EXISTS (SELECT name FROM   sysobjects WHERE  name = 'MT_Account_Status' AND type = 'U')
   DROP Table MT_Account_Status 
go


CREATE TABLE [MT_Account_Status] (
        [ChangeID] [int] IDENTITY (1, 1) NOT NULL ,
        [CustCode] [varchar] (15) NOT NULL ,
        [Hold] [bit] NOT NULL ,
        [Inactive] [bit] NOT NULL ,
        [ChangeTime] [datetime] NOT NULL ,
        [UserID] [varchar] (15) NOT NULL 
) ON [PRIMARY]

go

IF EXISTS (SELECT name FROM   sysobjects WHERE  name = 'MT_Status_Trigger' AND type = 'TR')
   DROP Trigger MT_Status_Trigger 
go

Create Trigger MT_Status_Trigger
on RM00101
for update 
as
  insert into MT_Account_Status(CustCode,Hold,Inactive,ChangeTime,UserID)
  select inserted.CUSTNMBR,inserted.HOLD,inserted.INACTIVE,getdate(),User FROM inserted,deleted WHERE deleted.CUSTNMBR = inserted.CUSTNMBR and deleted.HOLD <> inserted.HOLD

go

IF EXISTS (SELECT name FROM   sysobjects WHERE  name = 'MT_Get_AccountStatusChanges' AND type = 'P')
   DROP PROCEDURE MT_Get_AccountStatusChanges 
go

CREATE PROCEDURE MT_Get_AccountStatusChanges
AS
Select ChangeID,RTRIM(CustCode) ExtAccountID,Case when Hold = 0 then 'US' else 'SU' end Status,datediff(ss,ChangeTime,GetDate()) SecondsAgo,UserID from MT_Account_Status

go

IF EXISTS (SELECT name FROM   sysobjects WHERE  name = 'MT_AccountStatusChange_Delete' AND type = 'P')
   DROP PROCEDURE MT_AccountStatusChange_Delete 
go

CREATE PROCEDURE MT_AccountStatusChange_Delete
@I_vChangeID int,
@O_iErrorState int output,            /* Return value:  0=No Errors, 1=Error Occurred */
@oErrString varchar(255) output       /* Return Error Code List                       */
AS
declare @O_oErrorState int,@iErrString varchar(255),@iStatus int
if (SELECT COUNT(*) FROM MT_Account_Status WHERE ChangeID = @I_vChangeID) > 0
begin
        DELETE MT_Account_Status WHERE ChangeID = @I_vChangeID 
end
else
begin
        select @O_iErrorState = 30015
        exec @iStatus = taUpdateString @O_iErrorState,@oErrString,@oErrString output,@O_oErrorState output 
end
return (@O_iErrorState)

go

IF EXISTS (SELECT name FROM   sysobjects WHERE  name = 'MT_Can_DeleteDocument' AND type = 'P')
   DROP PROC MT_Can_DeleteDocument 
go

CREATE PROC MT_Can_DeleteDocument @DocumentData text 
AS 
DECLARE @xmlDoc int 
DECLARE @ErrDocument varchar(15)
EXEC sp_xml_preparedocument @xmlDoc OUTPUT, @DocumentData

SELECT DOCNO, DOCTYPE,case when DCSTATUS is null then 'false' else 'true' end as "Exists",
case when DCSTATUS = 1 then 'true' else 'false' end as CanDelete
FROM OPENXML (@xmlDoc, '/ARDocuments/ARDocument/CanDeleteDocument',1) WITH (DOCNO  varchar(17),DOCTYPE smallint) request
LEFT OUTER JOIN RM00401 on request.DOCNO = RM00401.DOCNUMBR AND request.DOCTYPE=RM00401.RMDTYPAL

EXEC sp_xml_removedocument @xmlDoc 

go


IF EXISTS (SELECT name FROM   sysobjects WHERE  name = 'MT_GetAll_Batches' AND type = 'V')
   DROP View MT_GetAll_Batches 
go

Create View MT_GetAll_Batches
as
SELECT BACHNUMB, 0 as POSTED, sum(NUMOFTRX) as NUMOFTRX from SY00500 group by BACHNUMB
UNION ALL
SELECT BACHNUMB,1 as POSTED, count(*) as NUMOFTRX from RM20101 group by BACHNUMB
UNION ALL
SELECT BACHNUMB,1 as POSTED, count(*) as NUMOFTRX from RM30101 group by BACHNUMB

go

IF EXISTS (SELECT name FROM   sysobjects WHERE  name = 'MT_Can_DeleteBatch' AND type = 'P')
   DROP PROC MT_Can_DeleteBatch 
go

CREATE PROC MT_Can_DeleteBatch @BatchData text 
AS 
DECLARE @xmlDoc int 
DECLARE @ErrBatch varchar(15)
EXEC sp_xml_preparedocument @xmlDoc OUTPUT, @BatchData

SELECT BatchID,case when (b.BACHNUMB is null) then 'false' else 'true' end as "Exists",
case when (b.BACHNUMB is null or b.POSTED = 1) then 'false' else 'true' end as CanDelete,
isnull(b.NUMOFTRX ,0) as NumTransactions
FROM OPENXML (@xmlDoc, '/ARDocuments/ARDocument/CanDeleteBatch',1) WITH (BatchID  varchar(17))
LEFT OUTER JOIN MT_GetAll_Batches b ON b.BACHNUMB = BatchID

EXEC sp_xml_removedocument @xmlDoc 

go
