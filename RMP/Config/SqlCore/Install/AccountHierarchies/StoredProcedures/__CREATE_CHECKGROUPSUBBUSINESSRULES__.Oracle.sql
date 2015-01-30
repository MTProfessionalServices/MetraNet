
CREATE OR REPLACE 
PROCEDURE checkgroupsubbusinessrules (
   p_name                       IN       NVARCHAR2,
   p_desc                       IN       NVARCHAR2,
   p_startdate                  IN       DATE,
   p_enddate                    IN       DATE,
   p_id_po                      IN       INTEGER,
   p_proportional               IN       VARCHAR2,
   p_discountaccount            IN       INTEGER,
   p_corporateaccount           IN       INTEGER,
   p_existingid                 IN       INTEGER,
   p_id_usage_cycle             IN       INTEGER,
   p_systemdate                 IN       DATE,
   p_enforce_same_corporation            VARCHAR2,
   p_allow_acc_po_curr_mismatch IN       INTEGER DEFAULT 0,
   p_status                     OUT      INTEGER
)
AS
   existingpo             INTEGER;
   constrainedcycletype   INTEGER;
   groupsubcycletype      INTEGER;
   corporatestartdate     DATE;
   var_condn              NUMBER  := 0;
   var_p_enddate          DATE    := p_enddate;
BEGIN
   p_status := 0; /* verify that the corporate account and the product offering have the same currency.*/

   IF (p_enforce_same_corporation = '1')
   THEN
      IF (dbo.isaccountandposamecurrency (p_corporateaccount, p_id_po) = '0'
         )
      THEN /* MT_ACCOUNT_PO_CURRENCY_MISMATCH*/
         if (p_allow_acc_po_curr_mismatch <> 0) THEN
        		p_status := 1;
	       else
            p_status := -486604729;
            RETURN;
         END IF;
      END IF;
   END IF; /* verify that the discount account, if not null has the same currency as the po.*/

   IF (p_enforce_same_corporation = '0' AND p_discountaccount IS NOT NULL)
   THEN
      IF (dbo.isaccountandposamecurrency (p_discountaccount, p_id_po) = '0')
      THEN /* MT_ACCOUNT_PO_CURRENCY_MISMATCH*/
         p_status := -486604729;
         RETURN;
      END IF;
   END IF;

   IF var_p_enddate IS NULL
   THEN
      var_p_enddate := dbo.mtmaxdate;
   END IF; /* verify that the product offering exists and the effective date is kosher*/

   IF p_proportional = 'N'
   THEN
      IF p_discountaccount IS NULL AND dbo.pocontainsdiscount (p_id_po) = 1
      THEN /* MT_GROUP_SUB_DISCOUNT_ACCOUNT_REQUIRED*/
         p_status := -486604787;
         RETURN;
      END IF;
   END IF; /* verify that the account is actually a corporate account*/

   IF p_enforce_same_corporation = '1'
   THEN
      SELECT COUNT (1)
        INTO var_condn
        FROM DUAL
       WHERE NOT EXISTS (
                SELECT 1
                  FROM t_account_ancestor aa INNER JOIN t_account a ON a.id_acc =
                                                                         aa.id_descendent
                       INNER JOIN t_account_type AT ON AT.id_type = a.id_type
                 WHERE AT.b_iscorporate = '1'
                   AND aa.id_descendent = p_corporateaccount
                   AND aa.vt_start <= p_startdate
                   AND aa.vt_end >= p_startdate)
          OR NOT EXISTS (
                SELECT 1
                  FROM t_account_ancestor aa INNER JOIN t_account a ON a.id_acc =
                                                                         aa.id_descendent
                       INNER JOIN t_account_type AT ON AT.id_type = a.id_type
                 WHERE AT.b_iscorporate = '1'
                   AND aa.id_descendent = p_corporateaccount
                   AND aa.vt_start <= var_p_enddate
                   /* AND aa.vt_end >= var_p_enddate */
                   )
          OR EXISTS (
                SELECT 1 /* This finds a record that ends during the                interval...*/
                  FROM t_account_ancestor aa INNER JOIN t_account a ON a.id_acc =
                                                                         aa.id_descendent
                       INNER JOIN t_account_type AT ON AT.id_type = a.id_type
                 WHERE AT.b_iscorporate = '1'
                   AND aa.id_descendent = p_corporateaccount
                   AND p_startdate <= aa.vt_end
                   AND aa.vt_end <
                          var_p_enddate /* ... and there is not corp. account record that extends                its validity.*/
                   AND NOT EXISTS (
                          SELECT 1
                            FROM t_account_ancestor aa2 INNER JOIN t_account a ON a.id_acc =
                                                                                    aa2.id_descendent
                                 INNER JOIN t_account_type AT ON AT.id_type =
                                                                     a.id_type
                           WHERE AT.b_iscorporate = '1'
                             AND aa2.vt_start <=
                                              aa.vt_end
                                              + (1 / (24 * 60 * 60))
                             /* AND aa2.vt_end > aa.vt_end */
                             ));

      IF var_condn <> 0
      THEN
      
        DECLARE
          v_accStart  DATE;
          v_accEnd    DATE;
        BEGIN
          SELECT vt_start, vt_end
          INTO v_accStart, v_accEnd
          FROM t_account_ancestor
          WHERE id_descendent = p_corporateaccount AND num_generations = 0
                AND ROWNUM <= 1;
          
          IF p_startdate < v_accStart THEN
            /* MT_GROUP_SUB_STARTS_BEFORE_ACCOUNT*/
            p_status := -486604710;
            RETURN;
          END IF;
          
          IF var_p_enddate > v_accEnd THEN
            /* MT_GROUP_SUB_ENDS_AFTER_ACCOUNT*/
            p_status := -486604709;
            RETURN;
          END IF;          
        END;
      
        /* MT_GROUP_SUB_CORPORATE_ACCOUNT_INVALID*/
        p_status := -486604786;
        RETURN;
      END IF;
   END IF; /* make sure start date is before end date   MT_GROUPSUB_STARTDATE_AFTER_ENDDATE*/

   IF var_p_enddate IS NOT NULL
   THEN
      IF p_startdate > var_p_enddate
      THEN
         p_status := -486604782;
         RETURN;
      END IF;
   END IF; /* verify that the group subscription name does not conflict with an existing    group subscription, based on group sub name and corporate account     MT_GROUP_SUB_NAME_EXISTS -486604784*/

   p_status := 0;

   FOR i IN (SELECT id_group
               FROM t_group_sub
              WHERE p_name = tx_name
                AND (p_existingid <> id_group OR p_existingid IS NULL))
   LOOP
      p_status := i.id_group;
   END LOOP;

   IF p_status <> 0
   THEN
      p_status := -486604784;
      RETURN;
   END IF; /* verify that the usage cycle type matched that of the      product offering*/

   FOR i IN (SELECT dbo.poconstrainedcycletype (p_id_po) p_id_po, id_cycle_type
               INTO constrainedcycletype, groupsubcycletype
               FROM t_usage_cycle
              WHERE id_usage_cycle = p_id_usage_cycle)
   LOOP
      constrainedcycletype := i.p_id_po;
      groupsubcycletype := i.id_cycle_type;
   END LOOP;

   IF constrainedcycletype > 0 AND constrainedcycletype <> groupsubcycletype
   THEN /* MT_GROUP_SUB_CYCLE_TYPE_MISMATCH*/
      p_status := -486604762;
      RETURN;
   END IF; /* check that the discount account has in its ancestory tree      the corporate account*/

   IF p_enforce_same_corporation = '1' AND p_discountaccount IS NOT NULL
   THEN
      SELECT MAX (id_ancestor)
        INTO p_status
        FROM t_account_ancestor
       WHERE id_descendent = p_discountaccount
         AND id_ancestor = p_corporateaccount;

      IF p_status IS NULL
      THEN /* MT_DISCOUNT_ACCOUNT_MUST_BE_IN_CORPORATE_HIERARCHY*/
         p_status := -486604760;
         RETURN;
      END IF;
   END IF; /* make sure the start date is after the start date of the corporate account*/

   IF (p_enforce_same_corporation = '1')
   THEN
      FOR i IN (SELECT dbo.mtstartofday (dt_crt) dt_crt
                  FROM t_account
                 WHERE id_acc = p_corporateaccount)
      LOOP
         corporatestartdate := i.dt_crt;
      END LOOP;

      IF corporatestartdate > p_startdate
      THEN /* MT_CANNOT_CREATE_GROUPSUB_BEFORE_CORPORATE_START_DATE*/
         p_status := -486604747;
         RETURN;
      END IF;
   END IF;

   p_status := 1;
END;
				