SELECT 
  CN.c_CreationDate AS CREATE_DATE,
  SUBSCRIBER.c_FirstName AS FIRST_NAME,
  SUBSCRIBER.c_LastName AS LAST_NAME,
  CN.c_Description AS "COMMENT",
  ( -1 * (AMOUNTS.TotalAmount + AMOUNTS.TotalTaxAmount)) AS CREDIT_AMOUNTASCURRENCY,
  AMOUNTS.am_Currency AS CREDIT_AMOUNTCURRENCY,
  REPLACE(EDATA.nm_enum_data, 'Global/LanguageCode/', '') AS "LANGUAGE",
  SUBSCRIBER.c_Email AS ADDRESSEDTO,
  CN.c_AccountID AS ACCOUNTID,
  'http://localhost/MetraView/login.aspx' AS METRAVIEW_PDF_LINK,
  RAWTOHEX(CN.c_CreditNote_Id) %%ENTITY_ID_COLUMNNAME%%
FROM t_be_cor_cre_creditnote CN
INNER JOIN 
(
  /* Credit Notes for which email has not been sent yet (first run of the adapter or created after the adapter last ran) */
  SELECT 
    c_CreditNote_Id AS ID_ENTITY_GUID
  FROM t_be_cor_cre_creditnote CN
  WHERE CN.c_CreditNote_Id NOT IN
               (
                SELECT 
                  id_entity_guid
                FROM t_sch_email_adapter_status ESTATUS
                WHERE ESTATUS.id_event = (SELECT 
                                            I.id_event
                                           FROM t_recevent_run R
                                           INNER JOIN t_recevent_inst I on I.id_instance = R.id_instance
                                           WHERE R.id_run = %%ID_RUN%% AND ROWNUM =1 )
                 )
  UNION ALL
  /* Credit Notes for which emails were not sent successfully and have retry_counter less than the threshold */
  SELECT 
    id_entity_guid AS ID_ENTITY_GUID
  FROM t_sch_email_adapter_status ESTATUS
  INNER JOIN t_be_cor_cre_creditnote CN ON CN.c_CreditNote_Id = ESTATUS.id_entity_guid AND ESTATUS.email_status = 'Failed' AND ESTATUS.retry_counter < %%NUM_RETRIES%%
  WHERE ESTATUS.id_event =  (SELECT 
                              I.id_event
                             FROM t_recevent_run R
                             INNER JOIN t_recevent_inst I on I.id_instance = R.id_instance
                             WHERE R.id_run = %%ID_RUN%% AND ROWNUM =1 )
) CREDITNOTESTOEMAIL ON CREDITNOTESTOEMAIL.ID_ENTITY_GUID = CN.c_CreditNote_Id
INNER JOIN (SELECT
              CN.c_CreditNote_Id,
              USAGE.am_Currency,
              SUM(NVL(USAGE.amount,0)) + SUM(NVL(ADJUSTMENTS.AdjustmentAmount,0)) AS TotalAmount,
              SUM(NVL(USAGE.tax_federal, 0)) + SUM(NVL(USAGE.tax_state, 0)) + SUM(NVL(USAGE.tax_county, 0)) + SUM(NVL(USAGE.tax_local, 0)) + SUM(NVL(USAGE.tax_other, 0)) +
              SUM(NVL(ADJUSTMENTS.aj_tax_federal, 0)) + SUM(NVL(ADJUSTMENTS.aj_tax_state, 0)) + SUM(NVL(ADJUSTMENTS.aj_tax_county, 0)) + SUM(NVL(ADJUSTMENTS.aj_tax_local, 0)) + SUM(NVL(ADJUSTMENTS.aj_tax_other, 0)) AS TotalTaxAmount
            FROM t_be_cor_cre_creditnote CN 
            INNER JOIN t_be_cor_cre_creditnoteitem CNI ON CNI.c_CreditNote_Id = CN.c_CreditNote_Id
            LEFT JOIN t_acc_usage USAGE ON USAGE.id_sess = CNI.c_SessionID
            LEFT JOIN t_adjustment_transaction ADJUSTMENTS ON ADJUSTMENTS.id_adj_trx = CNI.c_AdjustmentTransactionID
            GROUP BY CN.c_CreditNote_Id, USAGE.am_Currency) AMOUNTS ON CN.c_CreditNote_Id = AMOUNTS.c_CreditNote_Id
LEFT JOIN t_av_Internal INTERNAL ON INTERNAL.id_acc = CN.c_AccountID
LEFT JOIN t_enum_data EDATA ON EDATA.id_enum_data = INTERNAL.c_Language
LEFT JOIN t_av_Contact SUBSCRIBER ON SUBSCRIBER.id_acc = CN.c_AccountID 
LEFT JOIN t_enum_data CONTACTTYPE ON CONTACTTYPE.id_enum_data = SUBSCRIBER.c_contactType AND LTRIM(RTRIM((LOWER(CONTACTTYPE.nm_enum_data)))) = 'metratech.com/accountcreation/contacttype/bill-to'
WHERE SUBSCRIBER.c_Email IS NOT NULL
