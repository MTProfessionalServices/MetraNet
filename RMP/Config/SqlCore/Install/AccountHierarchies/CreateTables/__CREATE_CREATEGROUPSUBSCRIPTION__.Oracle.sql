
CREATE OR REPLACE 
PROCEDURE creategroupsubscription (
   p_sub_guid                   IN       RAW,
   p_group_guid                 IN       RAW,
   p_name                       IN       NVARCHAR2,
   p_desc                       IN       NVARCHAR2,
   p_usage_cycle                IN       INTEGER,
   p_startdate                  IN       DATE,
   p_enddate                    IN       DATE,
   p_id_po                      IN       INTEGER,
   p_proportional               IN       VARCHAR2,
   p_supportgroupops            IN       VARCHAR2,
   p_discountaccount            IN       INTEGER,
   p_corporateaccount           IN       INTEGER,
   p_systemdate                 IN       DATE,
   p_enforce_same_corporation            VARCHAR2,
   p_allow_acc_po_curr_mismatch IN       INTEGER DEFAULT 0,
   p_id_sub													     INTEGER,
   p_quoting_batch_id                    VARCHAR2,
   p_id_group                   OUT      INTEGER,
   p_status                     OUT      INTEGER,
   p_datemodified               OUT      VARCHAR2
)
AS
   existingpo             INTEGER;
   realenddate            DATE;
   varmaxdatetime         DATE;
   varsystemgmtdatetime   DATE;
   desctouse NVARCHAR2(255);
BEGIN /* business rule checks*/
   p_datemodified := 'N';
   varmaxdatetime := dbo.mtmaxdate;
   p_status := 0;
   checkgroupsubbusinessrules (p_name,
                               p_desc,
                               p_startdate,
                               p_enddate,
                               p_id_po,
                               p_proportional,
                               p_discountaccount,
                               p_corporateaccount,
                               NULL,
                               p_usage_cycle,
                               p_systemdate,
                               p_enforce_same_corporation,
                               p_allow_acc_po_curr_mismatch,
                               p_status
                              );

   IF p_status <> 1
   THEN
      RETURN;
   END IF; /* set the end date to max date if it is not specified*/

   IF p_enddate IS NULL
   THEN
      realenddate := varmaxdatetime;
   ELSE
      realenddate := p_enddate;
   END IF; /* add group entry*/

  if (p_desc is null) then
    desctouse := ' ';
  else
    desctouse := p_desc;
  end if;
   INSERT INTO t_group_sub
               (id_group, id_group_ext, tx_name, tx_desc, b_visable,
                b_supportgroupops, id_usage_cycle, b_proportional,
                id_discountaccount, id_corporate_account)
      SELECT seq_t_group_sub.NEXTVAL, p_group_guid, p_name,
      desctouse, 'N',
             p_supportgroupops, p_usage_cycle, p_proportional,
             p_discountaccount, p_corporateaccount
        FROM DUAL; /* group subscription ID*/

   SELECT seq_t_group_sub.CURRVAL
     INTO p_id_group
     FROM DUAL; /* add subscription entry*/

   addsubscriptionbase (NULL,
                        p_id_group,
                        p_id_po,
                        p_startdate,
                        p_enddate,
                        p_group_guid,
                        p_systemdate,
                        p_id_sub,                        
                        p_quoting_batch_id,
                        p_status,
                        p_datemodified,
                        0,
                        0
                       ); /* done*/
END;
		