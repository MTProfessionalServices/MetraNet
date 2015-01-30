
CREATE OR REPLACE PROCEDURE addnewsub (
   p_id_acc                          INT,
   p_dt_start                        DATE,
   p_dt_end                          DATE,
   p_nextcycleafterstartdate         VARCHAR2,
   p_nextcycleafterenddate           VARCHAR2,
   p_id_po                           INTEGER,
   p_guid                            RAW,
   p_systemdate                      DATE,
   p_id_sub                          INTEGER,
   p_status                    OUT   INTEGER,
   p_datemodified              OUT   VARCHAR2,
   p_allow_acc_po_curr_mismatch      INTEGER default 0,
   p_allow_multiple_pi_sub_rcnrc     INTEGER default 0,
   p_quoting_batch_id                VARCHAR2 default null
)
AS
   real_begin_date   DATE;
   real_end_date     DATE;
   po_effstartdate   DATE;
   datemodified      VARCHAR (1);
BEGIN
   p_status := 0; /* compute usage cycle dates if necessary */

   IF p_nextcycleafterstartdate = 'Y'
   THEN
      real_begin_date := dbo.nextdateafterbillingcycle (p_id_acc, p_dt_start);
   ELSE
      real_begin_date := p_dt_start;
   END IF;

   IF p_nextcycleafterenddate = 'Y' AND p_dt_end IS NOT NULL
   THEN
      real_end_date := dbo.nextdateafterbillingcycle (p_id_acc, p_dt_end);
   ELSE
      real_end_date := p_dt_end;
   END IF;

   IF p_dt_end IS NULL
   THEN
      real_end_date := dbo.mtmaxdate ();
   END IF;

   addsubscriptionbase (p_id_acc,
                        NULL,
                        p_id_po,
                        real_begin_date,
                        real_end_date,
                        p_guid,
                        p_systemdate,
                        p_id_sub,
                        p_quoting_batch_id,
                        p_status,
                        p_datemodified,
                        p_allow_acc_po_curr_mismatch,
                        p_allow_multiple_pi_sub_rcnrc
                       );
END;
					