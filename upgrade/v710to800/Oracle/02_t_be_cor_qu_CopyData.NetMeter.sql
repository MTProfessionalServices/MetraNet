/* 
  Script for Quoting upgrade 
*/
SET DEFINE OFF

ALTER TABLE t_be_cor_qu_quoteheader RENAME COLUMN c_customidentifier to c_quoteidentifier;
ALTER TABLE t_be_cor_qu_quoteheader RENAME COLUMN c_customdescription to c_quotedescription;

ALTER TABLE t_be_cor_qu_quoteheader ADD (
  c_groupsubscription CHAR,
  c_corporateaccountid NUMBER(20),
  c_reportlink NVARCHAR2(255),
  c_totaltax NUMBER(22,10),
  c_currency NVARCHAR2(255),
  c_failedmessage NVARCHAR2(2000),
  c_localization NVARCHAR2(255),
  c_effectivedate TIMESTAMP(4),
  c_effectiveenddate TIMESTAMP(4),
  c_idquote NUMBER(10) NOT NULL,
  c_totalamount NUMBER(22,10),
  c_reporturl RAW(2000),
  c_status NUMBER(10),
  c_statuscleanup NUMBER(10),
  c_statusreport NUMBER(10),
  c_accountsinfo NVARCHAR2(2000),
  c_posinfo NVARCHAR2(2000),
  c_quotecreationdate TIMESTAMP(4));

COMMENT ON COLUMN t_be_cor_qu_quoteheader.c_groupsubscription IS 'Indicates then quote is generated for group subscription';
COMMENT ON COLUMN t_be_cor_qu_quoteheader.c_corporateaccountid IS 'Corporate AccountId for group subscription';
COMMENT ON COLUMN t_be_cor_qu_quoteheader.c_reportlink IS 'Link to PDF file with report';
COMMENT ON COLUMN t_be_cor_qu_quoteheader.c_totaltax IS 'Total sum of taxes in quote';
COMMENT ON COLUMN t_be_cor_qu_quoteheader.c_currency IS 'Currency of quote amount';
COMMENT ON COLUMN t_be_cor_qu_quoteheader.c_failedmessage IS 'Error message';
COMMENT ON COLUMN t_be_cor_qu_quoteheader.c_localization IS 'Localization';
COMMENT ON COLUMN t_be_cor_qu_quoteheader.c_effectivedate IS 'Date the quote is started';
COMMENT ON COLUMN t_be_cor_qu_quoteheader.c_effectiveenddate IS 'Date the quote is finished.';
COMMENT ON COLUMN t_be_cor_qu_quoteheader.c_idquote IS 'Quoute number. Should be unique.';
COMMENT ON COLUMN t_be_cor_qu_quoteheader.c_totalamount IS 'Total sum of charges in quote';
COMMENT ON COLUMN t_be_cor_qu_quoteheader.c_reporturl IS 'URL to quote report file';
COMMENT ON COLUMN t_be_cor_qu_quoteheader.c_status IS '0 - None, 1 - In progress, 2 - Failed, 3 - Completed';
COMMENT ON COLUMN t_be_cor_qu_quoteheader.c_statuscleanup IS '0 - None, 1 - In progress, 2 - Failed, 3 - Completed';
COMMENT ON COLUMN t_be_cor_qu_quoteheader.c_statusreport IS '0 - Skipped, 1 - In progress, 2 - Failed, 3 - Completed';
COMMENT ON COLUMN t_be_cor_qu_quoteheader.c_accountsinfo IS 'String for display accounts in quote';
COMMENT ON COLUMN t_be_cor_qu_quoteheader.c_posinfo IS 'String for display POs in quote';

merge into t_be_cor_qu_quoteheader qh
using (select * from t_be_cor_qu_quotecontent) qc
on (qh.c_QuoteHeader_Id = qc.c_QuoteHeader_Id)
when matched then update set 
  qh.c_reportlink = qc.c_reportlink,
  qh.c_reporturl = qc.c_reportcontent,
  qh.c_totalamount = qc.c_total,
  qh.c_totaltax = qc.c_totaltax,  
  qh.c_currency = qc.c_currency,  
  qh.c_status = qc.c_status,
  qh.c_effectivedate = qh.c_startdate,
  qh.c_effectiveenddate = qh.c_enddate,
  qh.c_idquote = qh.c_quoteid;

ALTER TABLE t_be_cor_qu_quoteheader DROP (c_startdate, c_enddate, c_quoteid);
ALTER TABLE t_be_cor_qu_quoteheader MODIFY (c_quotedescription NVARCHAR2(2000));
/*
ALTER TABLE t_be_cor_qu_quoteicb DROP CONSTRAINT fk78cc1dcb4018c0cd;
ALTER TABLE t_be_cor_qu_quoteicb DROP (c_quoteheader_id);
*/
ALTER TABLE t_be_cor_qu_quoteicb DROP COLUMN c_quoteheader_id CASCADE  CONSTRAINTS;

COMMENT ON COLUMN t_be_cor_qu_quoteicb.c_chargesrates IS 'Serializable list of charges rates';
COMMENT ON COLUMN t_be_cor_qu_quoteicb.c_currentchargetype IS 'Type of charge (recuring, non-recuring, etc.)';
COMMENT ON COLUMN t_be_cor_qu_quoteicb.c_priceableitemid IS 'Priceable item id';

DROP TABLE t_be_cor_qu_quotecontent;

DECLARE tmpEnumValNone NUMBER(10);
tmpEnumValInprogress NUMBER(10);
tmpEnumValFailed NUMBER(10);
tmpEnumValCompleted NUMBER(10);

BEGIN

SELECT id_enum_data into tmpEnumValNone  FROM t_enum_data WHERE nm_enum_data = 'metratech.com/QuoteStatus/None';
SELECT id_enum_data into tmpEnumValInprogress FROM t_enum_data WHERE nm_enum_data = 'metratech.com/QuoteStatus/InProgress';
SELECT id_enum_data into tmpEnumValFailed  FROM t_enum_data WHERE nm_enum_data = 'metratech.com/QuoteStatus/Failed';
SELECT id_enum_data into tmpEnumValCompleted FROM t_enum_data WHERE nm_enum_data = 'metratech.com/QuoteStatus/Complete';

UPDATE t_be_cor_qu_quoteheader SET c_status = tmpEnumValNone WHERE c_status = 0;
UPDATE t_be_cor_qu_quoteheader SET c_status = tmpEnumValInprogress WHERE c_status = 1;
UPDATE t_be_cor_qu_quoteheader SET c_status = tmpEnumValFailed WHERE c_status = 2;
UPDATE t_be_cor_qu_quoteheader SET c_status = tmpEnumValCompleted WHERE c_status = 3;

END; 