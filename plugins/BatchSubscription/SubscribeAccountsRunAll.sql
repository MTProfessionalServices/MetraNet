
select * from marc_subscribe_individual_batch


-- replace netmeter..tmp_subscribe_individual_batch with tempdb..#tmp_subscribe_individual_batch
-- replace tmp_subscribe_individual_batch with #tmp_subscribe_individual_batch
-- replace tmp_account_state_rules with #tmp_account_state_rules


BEGIN TRAN
--COMMIT
--ROLLBACK

if object_id( 'netmeter..tmp_account_state_rules' ) is not null
  DROP TABLE tmp_account_state_rules

CREATE TABLE tmp_account_state_rules(state char(2), can_subscribe int)

CREATE CLUSTERED INDEX idx_state ON tmp_account_state_rules(state)

insert into tmp_account_state_rules (state, can_subscribe) values ('AC', 1)
insert into tmp_account_state_rules (state, can_subscribe) values ('PA', 1)
insert into tmp_account_state_rules (state, can_subscribe) values ('SU', 1)
insert into tmp_account_state_rules (state, can_subscribe) values ('PF', 1)
insert into tmp_account_state_rules (state, can_subscribe) values ('CL', 0)
insert into tmp_account_state_rules (state, can_subscribe) values ('AR', 0)


-- select * from tmp_account_state_rules


              if object_id( 'netmeter..tmp_subscribe_individual_batch' ) is not null
                DROP TABLE tmp_subscribe_individual_batch

              CREATE TABLE tmp_subscribe_individual_batch
              ( -- Input
                id_acc int NOT NULL,
                id_sub int NOT NULL,
                id_po int NOT NULL,
                dt_start datetime NOT NULL, 
                dt_end datetime NULL,
                next_cycle_after_startdate varchar(1) NOT NULL, -- 'Y' or 'N'
                next_cycle_after_enddate varchar(1) NOT NULL, -- 'Y' or 'N'
                sub_guid varbinary(16) NULL,

                -- Temporary Variables
                dt_adj_start datetime NULL,
                dt_adj_end datetime NULL,
                count int NULL,
                tauc_id_cycle_type int NULL,
                po_id_cycle_type int NULL,

                -- Output
                status int NULL,
                date_modified varchar(1) NULL, -- 'Y' or 'N'
              )
-- DROP INDEX tmp_subscribe_individual_batch.idx_id_sub
-- DROP INDEX tmp_subscribe_individual_batch.idx_id_po
-- DROP INDEX tmp_subscribe_individual_batch.idx_id_acc

CREATE UNIQUE INDEX idx_id_sub ON tmp_subscribe_individual_batch(id_sub)
-- CREATE CLUSTERED INDEX idx_id_po ON tmp_subscribe_individual_batch(id_po)
-- CREATE NONCLUSTERED INDEX idx_id_acc ON tmp_subscribe_individual_batch(id_acc)

insert into tmp_subscribe_individual_batch (id_acc, id_sub, id_po, dt_start, dt_end,
                                             next_cycle_after_startdate, next_cycle_after_enddate, sub_guid)
          SELECT id_acc, id_sub, id_po, dt_start, dt_end,
                 next_cycle_after_startdate, next_cycle_after_enddate, sub_guid
          FROM   marc_subscribe_individual_batch

-- select * from tmp_subscribe_individual_batch
-- select * from marc_subscribe_individual_batch



-- SQL FOR __EXECUTE_SUBSCRIBE_INDIVIDUAL_ACCOUNTS__ STARTS HERE!

DECLARE @system_datetime DATETIME
DECLARE @max_datetime    DATETIME

SELECT @system_datetime = %%%SYSTEMDATE%%% -- GetUTCDate()
SELECT @max_datetime = dbo.MTMaxDate()

-- Check to see if the account is in a state in which we can subscribe it.
--
-- TODO: This is the business rule as implemented in 3.5 and 3.0 (check only
-- the account state in effect at the wall clock time that the subscription is made).
-- What would be better is to ensure that there is no overlap between the valid time
-- interval of any "invalid" account state and the subscription interval.
--
-- This check was taken from the SQL for __SUBSCRIBE_BATCH__.
UPDATE tmp 
SET    tmp.status = -486604774 -- MT_ADD_TO_GROUP_SUB_BAD_STATE
FROM tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
INNER JOIN t_account_state ast ON tmp.id_acc = ast.id_acc
                              AND ast.vt_start <= GetUTCDate()
                              AND ast.vt_end >= GetUTCDate()
INNER JOIN tmp_account_state_rules asr ON ast.status = asr.state
WHERE asr.can_subscribe = 0
  AND tmp.status IS NULL

-- Start AddNewSub

-- compute usage cycle dates if necessary

UPDATE tmp
SET    tmp.dt_end   = CASE WHEN tmp.dt_end IS NULL
                           THEN dbo.MTMaxDate()
                           ELSE tmp.dt_end
                           END,
       tmp.sub_guid = CASE WHEN tmp.sub_guid IS NULL
                           THEN newid()
                           ELSE tmp.sub_guid
                           END
FROM   tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
WHERE  tmp.status IS NULL

-- This SQL used to call dbo.NextDateAfterBillingCycle
UPDATE tmp
SET    tmp.dt_start = DATEADD(s, 1, tpc.dt_end)
FROM t_pc_interval tpc
INNER JOIN t_acc_usage_cycle tauc ON tpc.id_cycle = tauc.id_usage_cycle
INNER JOIN tmp_subscribe_individual_batch tmp WITH(READCOMMITTED) ON tauc.id_acc = tmp.id_acc
WHERE tmp.next_cycle_after_startdate = 'Y'
  AND tpc.dt_start <= tmp.dt_start
  AND tmp.dt_start <= tpc.dt_end
  AND tmp.status IS NULL

-- This SQL used to call dbo.NextDateAfterBillingCycle
UPDATE tmp
SET    tmp.dt_end = DATEADD(s, 1, tpc.dt_end)
FROM t_pc_interval tpc
INNER JOIN t_acc_usage_cycle tauc ON tpc.id_cycle = tauc.id_usage_cycle
INNER JOIN tmp_subscribe_individual_batch tmp WITH(READCOMMITTED) ON tauc.id_acc = tmp.id_acc
WHERE tmp.next_cycle_after_enddate = 'Y'
  AND tpc.dt_start <= tmp.dt_end
  AND tmp.dt_end   <= tpc.dt_end
  AND tmp.dt_end <> dbo.MTMaxDate()
  AND tmp.status IS NULL

-- End AddNewSub

-- Start AddSubscriptionBase

-- Start AdjustSubDate

UPDATE tmp
SET    tmp.dt_adj_start = te.dt_start,
       tmp.dt_adj_end   = CASE WHEN te.dt_end IS NULL
                               THEN dbo.MTMaxDate()
                               ELSE te.dt_end
                               END
FROM  tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
INNER JOIN t_po po ON po.id_po = tmp.id_po
INNER JOIN t_effectivedate te on te.id_eff_date = po.id_eff_date
WHERE tmp.status IS NULL

-- This SQL used to call dbo.MTMaxOfTwoDates and dbo.MTMinOfTwoDates
UPDATE tmp
SET    tmp.dt_adj_start = CASE WHEN tmp.dt_adj_start > tmp.dt_start
                               THEN tmp.dt_adj_start
                               ELSE tmp.dt_start
                               END,
       tmp.dt_adj_end   = CASE WHEN tmp.dt_adj_end < tmp.dt_end
                               THEN tmp.dt_adj_end
                               ELSE tmp.dt_end
                               END
FROM tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
WHERE  tmp.status IS NULL

UPDATE tmp
SET    tmp.status = -289472472 -- MTPCUSER_PRODUCTOFFERING_NOT_EFFECTIVE (0xEEBF0028)
FROM tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
WHERE tmp.dt_adj_end < tmp.dt_adj_start
  AND tmp.status IS NULL

UPDATE tmp
SET    tmp.date_modified = CASE WHEN (tmp.dt_start <> tmp.dt_adj_start) OR (tmp.dt_end <> tmp.dt_adj_end)
                                THEN 'Y'
                                ELSE 'N'
                                END
FROM tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
WHERE tmp.status IS NULL

-- End AdjustSubDate

-- Check availability of the product offering.

UPDATE tmp
SET    tmp.status = CASE WHEN (ta.n_begintype = 0) OR (ta.n_endtype = 0)
                         THEN -289472451 -- MTPCUSER_AVAILABILITY_DATE_NOT_SET (0xEEBF003D)
                         WHEN (ta.n_begintype <> 0) AND (ta.dt_start > GetUTCDate())
                         THEN -289472449 -- MTPCUSER_AVAILABILITY_DATE_IN_FUTURE (0xEEBF003F)
                         WHEN (ta.n_endtype <> 0) AND (ta.dt_end < GetUTCDate())
                         THEN -289472450 -- MTPCUSER_AVAILABILITY_DATE_IN_PAST (0xEEBF003E)
                         ELSE NULL
                         END
FROM tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
INNER JOIN t_po po ON po.id_po = tmp.id_po
INNER JOIN t_effectivedate ta ON po.id_avail = ta.id_eff_date
WHERE tmp.status IS NULL

-- Start CheckSubscriptionConflicts

UPDATE tmp1
SET tmp1.status = -289472485 -- MTPCUSER_CONFLICTING_PO_SUBSCRIPTION (0xEEBF001B)
FROM tmp_subscribe_individual_batch tmp1 WITH(READCOMMITTED)
WHERE EXISTS(
             SELECT *
             FROM tmp_subscribe_individual_batch tmp2 WITH(READCOMMITTED)
             INNER JOIN tmp_subscribe_individual_batch tmp3 WITH(READCOMMITTED)
                                                            ON tmp3.id_acc = tmp2.id_acc
                                                           AND tmp3.id_po = tmp2.id_po
                                                           AND tmp3.id_sub <> tmp2.id_sub
             -- This SQL used to call dbo.OverlappingDateRange().
             WHERE NOT ((tmp3.dt_adj_start > tmp2.dt_adj_end)
                     OR (tmp2.dt_adj_start > tmp3.dt_adj_end))
               AND tmp2.status IS NULL
               AND tmp3.status IS NULL
               AND tmp1.id_sub = tmp2.id_sub
            )
  AND tmp1.status IS NULL

UPDATE tmp
                         -- This SQL used to call dbo.OverlappingDateRange().
SET    tmp.status = CASE WHEN ((tmp.dt_adj_start > te.dt_end)
                            OR (te.dt_start IS NOT NULL AND te.dt_start > tmp.dt_adj_end))
                         THEN -289472472 -- MTPCUSER_PRODUCTOFFERING_NOT_EFFECTIVE (0xEEBF0028)
                         ELSE NULL
                         END
FROM tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
INNER JOIN t_po ON tmp.id_po = t_po.id_po
INNER JOIN t_effectivedate te ON te.id_eff_date = t_po.id_eff_date
WHERE tmp.status IS NULL

DECLARE @bad_subscriptions TABLE
(
  id_sub INT NOT NULL
)

INSERT INTO @bad_subscriptions
SELECT tmp1.id_sub
FROM tmp_subscribe_individual_batch tmp1 WITH(READCOMMITTED)
  INNER JOIN t_pl_map map1 WITH(READCOMMITTED) ON map1.id_po = tmp1.id_po
                                              AND tmp1.status IS NULL
  INNER JOIN t_pl_map map2 WITH(READCOMMITTED) ON map1.id_pi_template = map2.id_pi_template
  INNER JOIN tmp_subscribe_individual_batch tmp2  WITH(READCOMMITTED) ON map2.id_po = tmp2.id_po
                                                                     AND tmp2.status IS NULL
  INNER JOIN tmp_subscribe_individual_batch tmp3 WITH(READCOMMITTED) ON tmp3.id_acc = tmp2.id_acc
                                                                    AND tmp3.id_sub <> tmp2.id_sub
                                                                    AND tmp3.status IS NULL
                 -- This SQL used to call dbo.OverlappingDateRange().
WHERE ((tmp3.dt_adj_start <= tmp2.dt_adj_end)
   AND (tmp2.dt_adj_start <= tmp3.dt_adj_end))

UPDATE tmp
SET tmp.status = -289472484 -- MTPCUSER_CONFLICTING_PO_SUB_PRICEABLEITEM (0xEEBF001C)
FROM tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
  -- WITH(READCOMMITTED) generates an error after @bad_subscriptions.
  INNER JOIN @bad_subscriptions bad_subs ON tmp.id_sub = bad_subs.id_sub
                                        AND tmp.status IS NULL

-- Start IsAccountAndPOSameCurrency

-- This SQL used to call (dbo.IsAccountAndPOSameCurrency() = '0')
UPDATE tmp
SET tmp.status = -486604729 -- MT_ACCOUNT_PO_CURRENCY_MISMATCH (0xE2FF0047)
FROM tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
INNER JOIN t_po po ON po.id_po = tmp.id_po
INNER JOIN t_av_internal av ON av.id_acc = tmp.id_acc
INNER JOIN t_pricelist pl ON po.id_nonshared_pl = pl.id_pricelist
WHERE av.c_currency <> pl.nm_currency_code
  and tmp.status IS NULL

-- End IsAccountAndPOSameCurrency

-- End CheckSubscriptionConflicts

-- fetches the cycle type of the subscriber (payee)
UPDATE tmp
SET    tmp.tauc_id_cycle_type = tuc.id_cycle_type
FROM tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
INNER JOIN t_acc_usage_cycle tauc ON tauc.id_acc = tmp.id_acc
INNER JOIN t_usage_cycle tuc on tuc.id_usage_cycle = tauc.id_usage_cycle 
WHERE tmp.status IS NULL

-- fetch the cycle of the PI's on the PO
--
-- I am using the stored procedure (dbo.poConstrainedCycleType()
-- here because there should not be that many POs so it should not
-- be called that many times and so should not be a performance
-- issue.  If it is we can look at "batchifying" it then.
--

DECLARE @po_cycle_type_mapping TABLE
(
  id_po INT NOT NULL,
  id_cycle_type INT NOT NULL
)

INSERT INTO @po_cycle_type_mapping
SELECT 
  results.id_po,
  results.cycle_type
FROM (
      SELECT po.id_po, dbo.poConstrainedCycleType(po.id_po) AS cycle_type
      FROM (
            SELECT DISTINCT tmp.id_po
            FROM tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
            WHERE tmp.status IS NULL
           ) po
     ) results

UPDATE tmp
SET tmp.po_id_cycle_type = mapping.id_cycle_type
FROM tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
INNER JOIN @po_cycle_type_mapping mapping ON mapping.id_po = tmp.id_po
WHERE tmp.status IS NULL

UPDATE tmp
SET    tmp.status = -289472464 -- MTPCUSER_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE (0xEEBF0030)
FROM tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
WHERE tmp.po_id_cycle_type <> 0
  AND tmp.po_id_cycle_type <> tmp.tauc_id_cycle_type
  AND tmp.status IS NULL

-- checks the subscriber's billing cycle for EBCR cycle conflicts
UPDATE tmp
SET    tmp.status = -289472444 -- MTPCUSER_EBCR_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE (0xEEBF0044)
FROM tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
INNER JOIN t_pl_map map ON map.id_po = tmp.id_po
INNER JOIN t_recur rc ON rc.id_prop = map.id_pi_template
                      OR rc.id_prop = map.id_pi_instance
WHERE rc.tx_cycle_mode = 'EBCR'
  AND tmp.status IS NULL
  -- These next two "NOT AND" statments replaced dbo.CheckEBCRCycleTypeCompatibility().
  AND NOT (((rc.id_cycle_type = 4) OR (rc.id_cycle_type = 5))
       AND ((tmp.tauc_id_cycle_type = 4) OR (tmp.tauc_id_cycle_type = 5)))
  AND NOT (((rc.id_cycle_type = 1) OR (rc.id_cycle_type = 7) OR (rc.id_cycle_type = 8))
       AND ((tmp.tauc_id_cycle_type = 1) OR (tmp.tauc_id_cycle_type = 7) OR (tmp.tauc_id_cycle_type = 8)))

-- This commented out SQL should be equivalent to the SQL above.
--
-- checks the subscriber's billing cycle for EBCR cycle conflicts
-- UPDATE tmp
-- SET    tmp.status = -289472444 -- MTPCUSER_EBCR_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE (0xEEBF0044)
-- FROM tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
-- where EXISTS 
-- (
--   SELECT NULL
--   FROM t_pl_map plmap
--   INNER JOIN t_recur rc ON rc.id_prop = plmap.id_pi_template OR
--                            rc.id_prop = plmap.id_pi_instance
--   WHERE rc.tx_cycle_mode = 'EBCR'
--     AND tmp.status IS NULL
--     AND plmap.id_po = tmp.id_po
--     -- These next two "NOT AND" statments replaced dbo.CheckEBCRCycleTypeCompatibility().
--     AND NOT (((rc.id_cycle_type = 4) OR (rc.id_cycle_type = 5))
--          AND ((tmp.tauc_id_cycle_type = 4) OR (tmp.tauc_id_cycle_type = 5)))
--     AND NOT (((rc.id_cycle_type = 1) OR (rc.id_cycle_type = 7) OR (rc.id_cycle_type = 8))
--          AND ((tmp.tauc_id_cycle_type = 1) OR (tmp.tauc_id_cycle_type = 7) OR (tmp.tauc_id_cycle_type = 8)))
-- )

-- End AddSubscriptionBase

-- Start CreateSubscriptionRecord

-- Create the new subscription history record.
INSERT INTO t_sub_history (id_sub, id_sub_ext, id_acc, id_group,
                           id_po, dt_crt, vt_start, vt_end,
                           tt_start, tt_end)
SELECT tmp.id_sub, tmp.sub_guid, tmp.id_acc, NULL,
       tmp.id_po, GetUTCDate(), tmp.dt_adj_start, tmp.dt_adj_end,
       GetUTCDate(), dbo.MTMaxDate()
FROM tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
WHERE tmp.status IS NULL

-- Create the new subscription record.
INSERT INTO t_sub (id_sub, id_sub_ext, id_acc, id_group,
                   id_po, dt_crt, vt_start, vt_end)
SELECT tmp.id_sub, tmp.sub_guid, tmp.id_acc, NULL,
       tmp.id_po, GetUTCDate(), tmp.dt_adj_start, tmp.dt_adj_end
FROM tmp_subscribe_individual_batch tmp WITH(READCOMMITTED)
WHERE tmp.status IS NULL

-- End CreateSubscriptionRecord

--COMMIT
--ROLLBACK
