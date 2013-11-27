
CREATE PROCEDURE mtsp_dm_pop_sum_ancestor
AS
BEGIN
DECLARE @id_enum_data INT

SELECT @id_enum_data = id_enum_data
FROM t_enum_data
WHERE nm_enum_data = 'METRATECH.COM/ACCOUNTCREATION/CONTACTTYPE/BILL-TO'

TRUNCATE TABLE dm_t_sum_gen1

INSERT INTO dm_t_sum_gen1
(id_ancestor, a_folderind, a_firstname, a_lastname, id_descendent, 
 d_folderind, d_firstname, d_lastname, vt_start, vt_end)
SELECT id_ancestor,
	avi.c_folder a_folderind,
	avc.c_firstname c_firstname_a,
	avc.c_lastname c_lastname_a, 
	id_descendent,
	avi2.c_folder d_folderind,
	avc2.c_firstname c_firstname_d,
	avc2.c_lastname c_lastname_d,
	aa.vt_start,
	aa.vt_end
FROM t_account_ancestor aa
	LEFT OUTER JOIN t_av_contact avc
		ON avc.id_acc = aa.id_ancestor
		AND avc.c_contacttype = @id_enum_data 
	INNER JOIN t_av_internal avi
		ON avi.id_acc = aa.id_ancestor
	LEFT OUTER JOIN t_av_contact avc2
		ON avc2.id_acc = aa.id_descendent
		AND avc.c_contacttype = @id_enum_data 
	INNER JOIN t_av_internal avi2
		ON avi2.id_acc = aa.id_descendent
WHERE num_generations = 1
/*
CREATE INDEX idx_dm_t_sum_gen1_descendent ON dm_t_sum_gen1(id_descendent)
UPDATE STATISTICS dm_t_sum_gen1 WITH SAMPLE 100 PERCENT
*/
--IF v_maxgen = 5 THEN
TRUNCATE TABLE dm_t_sum_acc_gen_flat
DROP INDEX dm_t_sum_acc_gen_flat.idx_dm_sum_accgenflat_1
DROP INDEX dm_t_sum_acc_gen_flat.idx_dm_sum_accgenflat_2
DROP INDEX dm_t_sum_acc_gen_flat.idx_dm_sum_accgenflat_3
DROP INDEX dm_t_sum_acc_gen_flat.idx_dm_sum_accgenflat_4
DROP INDEX dm_t_sum_acc_gen_flat.idx_dm_sum_accgenflat_5
DROP INDEX dm_t_sum_acc_gen_flat.idx_dm_sum_accgenflat_6
DROP INDEX dm_t_sum_acc_gen_flat.idx_dm_sum_accgenflat_7
DROP INDEX dm_t_sum_acc_gen_flat.idx_dm_sum_accgenflat_8
DROP INDEX dm_t_sum_acc_gen_flat.idx_dm_sum_accgenflat_9
DROP INDEX dm_t_sum_acc_gen_flat.idx_dm_sum_accgenflat_10

-- intermediate step 1
TRUNCATE TABLE dm_t_sum_acc_gen_flat_s1
INSERT INTO dm_t_sum_acc_gen_flat_s1
(
gen_5,stitle_5,firstname_5,lastname_5,
gen_4,stitle_4,firstname_4,lastname_4,
gen_3,stitle_3,firstname_3,lastname_3,
gen_2,stitle_2,firstname_2,lastname_2,
gen_1,stitle_1,firstname_1,lastname_1,
gen_0,stitle_0,firstname_0,lastname_0,
vt_start, vt_end
)
SELECT
	aa5.id_ancestor gen_5,
	aa5.a_folderind stitle_5,
	aa5.a_firstname firstname_5,
	aa5.a_lastname lastname_5,
	tmpgen4.gen_4,
	tmpgen4.stitle_4,
	tmpgen4.firstname_4,
	tmpgen4.lastname_4,
	tmpgen4.gen_3,
	tmpgen4.stitle_3,
	tmpgen4.firstname_3,
	tmpgen4.lastname_3,
	tmpgen4.gen_2,
	tmpgen4.stitle_2,
	tmpgen4.firstname_2,
	tmpgen4.lastname_2,
	tmpgen4.gen_1,
	tmpgen4.stitle_1,
	tmpgen4.firstname_1,
	tmpgen4.lastname_1,
	tmpgen4.gen_0,
	tmpgen4.stitle_0,
	tmpgen4.firstname_0,
	tmpgen4.lastname_0,
	CASE
	WHEN aa5.vt_start IS NOT NULL AND aa5.vt_start > tmpgen4.vt_start THEN aa5.vt_start
	ELSE tmpgen4.vt_start
	END vt_start,
	CASE 
	WHEN aa5.vt_end IS NOT NULL AND aa5.vt_end < tmpgen4.vt_end THEN aa5.vt_end
	ELSE tmpgen4.vt_end
	END vt_end
FROM
	(SELECT
		aa4.id_ancestor gen_4,
		aa4.a_folderind stitle_4,
		aa4.a_firstname firstname_4,
		aa4.a_lastname lastname_4,
		tmpgen3.gen_3,
		tmpgen3.stitle_3,
		tmpgen3.firstname_3,
		tmpgen3.lastname_3,
		tmpgen3.gen_2,
		tmpgen3.stitle_2,
		tmpgen3.firstname_2,
		tmpgen3.lastname_2,
		tmpgen3.gen_1,
		tmpgen3.stitle_1,
		tmpgen3.firstname_1,
		tmpgen3.lastname_1,
		tmpgen3.gen_0,
		tmpgen3.stitle_0,
		tmpgen3.firstname_0,
		tmpgen3.lastname_0,
		CASE
		WHEN aa4.vt_start IS NOT NULL AND aa4.vt_start > tmpgen3.vt_start THEN aa4.vt_start
		ELSE tmpgen3.vt_start
		END vt_start,
		CASE 
		WHEN aa4.vt_end IS NOT NULL AND aa4.vt_end < tmpgen3.vt_end THEN aa4.vt_end
		ELSE tmpgen3.vt_end
		END vt_end
	FROM
		(SELECT
			aa3.id_ancestor gen_3,
			aa3.a_folderind stitle_3,
			aa3.a_firstname firstname_3,
			aa3.a_lastname lastname_3,
			tmpgen2.gen_2,
			tmpgen2.stitle_2,
			tmpgen2.firstname_2,
			tmpgen2.lastname_2,
			tmpgen2.gen_1,
			tmpgen2.stitle_1,
			tmpgen2.firstname_1,
			tmpgen2.lastname_1,
			tmpgen2.gen_0,
			tmpgen2.stitle_0,
			tmpgen2.firstname_0,
			tmpgen2.lastname_0,
			CASE
			WHEN aa3.vt_start IS NOT NULL AND aa3.vt_start > tmpgen2.vt_start THEN aa3.vt_start
			ELSE tmpgen2.vt_start
			END vt_start,
			CASE 
			WHEN aa3.vt_end IS NOT NULL AND aa3.vt_end < tmpgen2.vt_end THEN aa3.vt_end
			ELSE tmpgen2.vt_end
			END vt_end
		FROM
			(SELECT
				aa2.id_ancestor gen_2,
				aa2.a_folderind stitle_2,
				aa2.a_firstname firstname_2,
				aa2.a_lastname lastname_2,
				tmpgen1.gen_1,
				tmpgen1.stitle_1,
				tmpgen1.firstname_1,
				tmpgen1.lastname_1,
				tmpgen1.gen_0,
				tmpgen1.stitle_0,
				tmpgen1.firstname_0,
				tmpgen1.lastname_0,
				CASE
				WHEN aa2.vt_start IS NOT NULL AND aa2.vt_start > tmpgen1.vt_start THEN aa2.vt_start
				ELSE tmpgen1.vt_start
				END vt_start,
				CASE 
				WHEN aa2.vt_end IS NOT NULL AND aa2.vt_end < tmpgen1.vt_end THEN aa2.vt_end
				ELSE tmpgen1.vt_end
				END vt_end
			FROM
				(SELECT
					aa1.id_ancestor gen_1,
					aa1.a_folderind stitle_1,
					aa1.a_firstname firstname_1,
					aa1.a_lastname lastname_1,
					tmpd.id_acc gen_0,
					avi.c_folder stitle_0,
					avc.c_firstname firstname_0,
					avc.c_lastname lastname_0,
					CASE
					WHEN aa1.vt_start IS NOT NULL AND tmpd.dt_crt IS NOT NULL AND aa1.vt_start > tmpd.dt_crt THEN aa1.vt_start
					WHEN aa1.vt_start IS NOT NULL AND tmpd.dt_crt IS NOT NULL AND aa1.vt_start <= tmpd.dt_crt THEN tmpd.dt_crt
					WHEN aa1.vt_start IS NOT NULL AND tmpd.dt_crt IS NULL THEN aa1.vt_start
					WHEN aa1.vt_start IS NULL AND tmpd.dt_crt IS NOT NULL THEN tmpd.dt_crt
					WHEN aa1.vt_start IS NULL AND tmpd.dt_crt IS NULL THEN CAST('1/1/1970' AS DATETIME)
					END vt_start,
					CASE
					WHEN aa1.vt_end IS NOT NULL THEN aa1.vt_end
					ELSE CAST('1/1/2038' AS DATETIME)
					END vt_end
				FROM t_account tmpd
					INNER JOIN t_av_internal avi
						ON avi.id_acc = tmpd.id_acc	
					LEFT OUTER JOIN t_av_contact avc
						ON avc.id_acc = tmpd.id_acc
						AND avc.c_contacttype = @id_enum_data 
					LEFT OUTER JOIN dm_t_sum_gen1 aa1
						ON aa1.id_descendent = tmpd.id_acc
				) tmpgen1
				LEFT OUTER JOIN dm_t_sum_gen1 aa2
				ON aa2.id_descendent = tmpgen1.gen_1  
			) tmpgen2 
			LEFT OUTER JOIN dm_t_sum_gen1 aa3
			ON aa3.id_descendent = tmpgen2.gen_2  
		) tmpgen3 
		LEFT OUTER JOIN dm_t_sum_gen1 aa4
		ON aa4.id_descendent = tmpgen3.gen_3
	) tmpgen4 
	LEFT OUTER JOIN dm_t_sum_gen1 aa5
	ON aa5.id_descendent = tmpgen4.gen_4

INSERT INTO dm_t_sum_acc_gen_flat
(
gen_9, gen_9_folder_flag, gen_9_firstname, gen_9_lastname,
gen_8, gen_8_folder_flag, gen_8_firstname, gen_8_lastname,
gen_7, gen_7_folder_flag, gen_7_firstname, gen_7_lastname,
gen_6, gen_6_folder_flag, gen_6_firstname, gen_6_lastname,
gen_5, gen_5_folder_flag, gen_5_firstname, gen_5_lastname,
gen_4, gen_4_folder_flag, gen_4_firstname, gen_4_lastname, 
gen_3, gen_3_folder_flag, gen_3_firstname, gen_3_lastname, 
gen_2, gen_2_folder_flag, gen_2_firstname, gen_2_lastname, 
gen_1, gen_1_folder_flag, gen_1_firstname, gen_1_lastname, 
gen_0, gen_0_folder_flag, gen_0_firstname, gen_0_lastname, 
vt_start, vt_end
)
SELECT
	aa9.id_ancestor gen_9,
	aa9.a_folderind stitle_9,
	aa9.a_firstname firstname_9,
	aa9.a_lastname lastname_9,
	tmpgen8.gen_8,
	tmpgen8.stitle_8,
	tmpgen8.firstname_8,
	tmpgen8.lastname_8,
	tmpgen8.gen_7,
	tmpgen8.stitle_7,
	tmpgen8.firstname_7,
	tmpgen8.lastname_7,
	tmpgen8.gen_6,
	tmpgen8.stitle_6,
	tmpgen8.firstname_6,
	tmpgen8.lastname_6,
	tmpgen8.gen_5,
	tmpgen8.stitle_5,
	tmpgen8.firstname_5,
	tmpgen8.lastname_5,
	tmpgen8.gen_4,
	tmpgen8.stitle_4,
	tmpgen8.firstname_4,
	tmpgen8.lastname_4,
	tmpgen8.gen_3,
	tmpgen8.stitle_3,
	tmpgen8.firstname_3,
	tmpgen8.lastname_3,
	tmpgen8.gen_2,
	tmpgen8.stitle_2,
	tmpgen8.firstname_2,
	tmpgen8.lastname_2,
	tmpgen8.gen_1,
	tmpgen8.stitle_1,
	tmpgen8.firstname_1,
	tmpgen8.lastname_1,
	tmpgen8.gen_0,
	tmpgen8.stitle_0,
	tmpgen8.firstname_0,
	tmpgen8.lastname_0,
	CASE
	WHEN aa9.vt_start IS NOT NULL AND aa9.vt_start > tmpgen8.vt_start THEN aa9.vt_start
	ELSE tmpgen8.vt_start
	END vt_start,
	CASE 
	WHEN aa9.vt_end IS NOT NULL AND aa9.vt_end < tmpgen8.vt_end THEN aa9.vt_end
	ELSE tmpgen8.vt_end
	END vt_end
FROM
	(SELECT
		aa8.id_ancestor gen_8,
		aa8.a_folderind stitle_8,
		aa8.a_firstname firstname_8,
		aa8.a_lastname lastname_8,
		tmpgen7.gen_7,
		tmpgen7.stitle_7,
		tmpgen7.firstname_7,
		tmpgen7.lastname_7,
		tmpgen7.gen_6,
		tmpgen7.stitle_6,
		tmpgen7.firstname_6,
		tmpgen7.lastname_6,
		tmpgen7.gen_5,
		tmpgen7.stitle_5,
		tmpgen7.firstname_5,
		tmpgen7.lastname_5,
		tmpgen7.gen_4,
		tmpgen7.stitle_4,
		tmpgen7.firstname_4,
		tmpgen7.lastname_4,
		tmpgen7.gen_3,
		tmpgen7.stitle_3,
		tmpgen7.firstname_3,
		tmpgen7.lastname_3,
		tmpgen7.gen_2,
		tmpgen7.stitle_2,
		tmpgen7.firstname_2,
		tmpgen7.lastname_2,
		tmpgen7.gen_1,
		tmpgen7.stitle_1,
		tmpgen7.firstname_1,
		tmpgen7.lastname_1,
		tmpgen7.gen_0,
		tmpgen7.stitle_0,
		tmpgen7.firstname_0,
		tmpgen7.lastname_0,
		CASE
		WHEN aa8.vt_start IS NOT NULL AND aa8.vt_start > tmpgen7.vt_start THEN aa8.vt_start
		ELSE tmpgen7.vt_start
		END vt_start,
		CASE 
		WHEN aa8.vt_end IS NOT NULL AND aa8.vt_end < tmpgen7.vt_end THEN aa8.vt_end
		ELSE tmpgen7.vt_end
		END vt_end
	FROM
		(SELECT
			aa7.id_ancestor gen_7,
			aa7.a_folderind stitle_7,
			aa7.a_firstname firstname_7,
			aa7.a_lastname lastname_7,
			tmpgen6.gen_6,
			tmpgen6.stitle_6,
			tmpgen6.firstname_6,
			tmpgen6.lastname_6,
			tmpgen6.gen_5,
			tmpgen6.stitle_5,
			tmpgen6.firstname_5,
			tmpgen6.lastname_5,
			tmpgen6.gen_4,
			tmpgen6.stitle_4,
			tmpgen6.firstname_4,
			tmpgen6.lastname_4,
			tmpgen6.gen_3,
			tmpgen6.stitle_3,
			tmpgen6.firstname_3,
			tmpgen6.lastname_3,
			tmpgen6.gen_2,
			tmpgen6.stitle_2,
			tmpgen6.firstname_2,
			tmpgen6.lastname_2,
			tmpgen6.gen_1,
			tmpgen6.stitle_1,
			tmpgen6.firstname_1,
			tmpgen6.lastname_1,
			tmpgen6.gen_0,
			tmpgen6.stitle_0,
			tmpgen6.firstname_0,
			tmpgen6.lastname_0,
			CASE
			WHEN aa7.vt_start IS NOT NULL AND aa7.vt_start > tmpgen6.vt_start THEN aa7.vt_start
			ELSE tmpgen6.vt_start
			END vt_start,
			CASE 
			WHEN aa7.vt_end IS NOT NULL AND aa7.vt_end < tmpgen6.vt_end THEN aa7.vt_end
			ELSE tmpgen6.vt_end
			END vt_end
		FROM
			(SELECT
				aa6.id_ancestor gen_6,
				aa6.a_folderind stitle_6,
				aa6.a_firstname firstname_6,
				aa6.a_lastname lastname_6,
				tmpgen05.gen_5,
				tmpgen05.stitle_5,
				tmpgen05.firstname_5,
				tmpgen05.lastname_5,
				tmpgen05.gen_4,
				tmpgen05.stitle_4,
				tmpgen05.firstname_4,
				tmpgen05.lastname_4,
				tmpgen05.gen_3,
				tmpgen05.stitle_3,
				tmpgen05.firstname_3,
				tmpgen05.lastname_3,
				tmpgen05.gen_2,
				tmpgen05.stitle_2,
				tmpgen05.firstname_2,
				tmpgen05.lastname_2,
				tmpgen05.gen_1,
				tmpgen05.stitle_1,
				tmpgen05.firstname_1,
				tmpgen05.lastname_1,
				tmpgen05.gen_0,
				tmpgen05.stitle_0,
				tmpgen05.firstname_0,
				tmpgen05.lastname_0,
				CASE
				WHEN aa6.vt_start IS NOT NULL AND aa6.vt_start > tmpgen05.vt_start THEN aa6.vt_start
				ELSE tmpgen05.vt_start
				END vt_start,
				CASE 
				WHEN aa6.vt_end IS NOT NULL AND aa6.vt_end < tmpgen05.vt_end THEN aa6.vt_end
				ELSE tmpgen05.vt_end
				END vt_end
			FROM
				dm_t_sum_acc_gen_flat_s1 tmpgen05
				LEFT OUTER JOIN dm_t_sum_gen1 aa6
				ON aa6.id_descendent = tmpgen05.gen_5  
			) tmpgen6 
			LEFT OUTER JOIN dm_t_sum_gen1 aa7
			ON aa7.id_descendent = tmpgen6.gen_6  
		) tmpgen7
		LEFT OUTER JOIN dm_t_sum_gen1 aa8
		ON aa8.id_descendent = tmpgen7.gen_7
	) tmpgen8 
	LEFT OUTER JOIN dm_t_sum_gen1 aa9
	ON aa9.id_descendent = tmpgen8.gen_8

CREATE INDEX idx_dm_sum_accgenflat_1 ON DM_T_SUM_ACC_GEN_FLAT(GEN_0)
CREATE INDEX idx_dm_sum_accgenflat_2 ON DM_T_SUM_ACC_GEN_FLAT(GEN_1)
CREATE INDEX idx_dm_sum_accgenflat_3 ON DM_T_SUM_ACC_GEN_FLAT(GEN_2)
CREATE INDEX idx_dm_sum_accgenflat_4 ON DM_T_SUM_ACC_GEN_FLAT(GEN_3)
CREATE INDEX idx_dm_sum_accgenflat_5 ON DM_T_SUM_ACC_GEN_FLAT(GEN_4)
CREATE INDEX idx_dm_sum_accgenflat_6 ON DM_T_SUM_ACC_GEN_FLAT(GEN_5)
CREATE INDEX idx_dm_sum_accgenflat_7 ON DM_T_SUM_ACC_GEN_FLAT(GEN_6)
CREATE INDEX idx_dm_sum_accgenflat_8 ON DM_T_SUM_ACC_GEN_FLAT(GEN_7)
CREATE INDEX idx_dm_sum_accgenflat_9 ON DM_T_SUM_ACC_GEN_FLAT(GEN_8)
CREATE INDEX idx_dm_sum_accgenflat_10 ON DM_T_SUM_ACC_GEN_FLAT(GEN_9)

--DROP INDEX dm_t_sum_gen1.idx_dm_t_sum_gen1_descendent

-- Generation level table
TRUNCATE TABLE dm_t_sum_acc_lvl_flat
IF EXISTS (SELECT NULL FROM sysindexes WHERE id = object_id('dm_t_sum_acc_lvl_flat') 
	AND LOWER(name) = 'idx_dm_t_sum_acc_lvl_flat')
		DROP INDEX dm_t_sum_acc_lvl_flat.idx_dm_t_sum_acc_lvl_flat

INSERT INTO dm_t_sum_acc_lvl_flat
(gen_0, top_lvl_1, top_lvl_1_desc, top_lvl_2, top_lvl_2_desc, top_lvl_3, top_lvl_3_desc,
 top_lvl_4, top_lvl_4_desc, top_lvl_5, top_lvl_5_desc, top_lvl_6, top_lvl_6_desc,
 top_lvl_7, top_lvl_7_desc, top_lvl_8, top_lvl_8_desc, top_lvl_9, top_lvl_9_desc, top_lvl_10, top_lvl_10_desc,
 vt_start, vt_end)
SELECT -- gen 0
	gen_0, gen_0 TOP_LVL_1, 
	CASE WHEN GEN_0_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_0_firstname) + ' ' + RTRIM(gen_0_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_0_firstname) + ' ' + RTRIM(gen_0_lastname)
	END TOP_LVL_1_DESC, -- level 1
	-1 TOP_LVL_2, NULL TOP_LVL_2_DESC, -- no level 2
	-1 TOP_LVL_3, NULL TOP_LVL_3_DESC, -- no level 3
	-1 TOP_LVL_4, NULL TOP_LVL_4_DESC, -- no level 4
	-1 TOP_LVL_5, NULL TOP_LVL_5_DESC, -- no level 5
	-1 TOP_LVL_6, NULL TOP_LVL_6_DESC, -- no level 6
	-1 TOP_LVL_7, NULL TOP_LVL_7_DESC, -- no level 7
	-1 TOP_LVL_8, NULL TOP_LVL_8_DESC, -- no level 8
	-1 TOP_LVL_9, NULL TOP_LVL_9_DESC, -- no level 9
	-1 TOP_LVL_10, NULL TOP_LVL_10_DESC, -- no level 10
	vt_start,	vt_end
FROM DM_T_SUM_ACC_GEN_FLAT saf
WHERE saf.gen_0 IS NOT NULL
UNION ALL
-- gen 1
SELECT 
	gen_0, gen_1 TOP_LVL_1, CASE WHEN GEN_1_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_1_firstname) + ' ' + RTRIM(gen_1_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_1_firstname) + ' ' + RTRIM(gen_1_lastname)
	END TOP_LVL_1_DESC, -- level 1
	gen_0 TOP_LVL_2,
	CASE WHEN GEN_0_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_0_firstname) + ' ' + RTRIM(gen_0_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_0_firstname) + ' ' + RTRIM(gen_0_lastname)
	END TOP_LVL_2_DESC, -- level 2
	-1,NULL, -- no level 3
	-1,NULL, -- no level 4
	-1,NULL, -- no level 5
	-1,NULL, -- no level 6
	-1,NULL, -- no level 7
	-1,NULL, -- no level 8
	-1,NULL, -- no level 9
	-1,NULL, -- no level 10
	vt_start,vt_end
FROM DM_T_SUM_ACC_GEN_FLAT saf
WHERE saf.gen_0 IS NOT NULL AND saf.gen_1 IS NOT NULL
UNION ALL
-- gen 2
SELECT 
	gen_0, gen_2 TOP_LVL_1, CASE WHEN GEN_2_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_2_firstname) + ' ' + RTRIM(gen_2_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_2_firstname) + ' ' + RTRIM(gen_2_lastname)
	END TOP_LVL_1_DESC, -- level 1
	gen_1 TOP_LVL_2, CASE WHEN GEN_1_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_1_firstname) + ' ' + RTRIM(gen_1_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_1_firstname) + ' ' + RTRIM(gen_1_lastname)
	END TOP_LVL_2_DESC, -- level 2
	gen_0 TOP_LVL_3, CASE WHEN GEN_0_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_0_firstname) + ' ' + RTRIM(gen_0_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_0_firstname) + ' ' + RTRIM(gen_0_lastname)
	END TOP_LVL_3_DESC, -- level 3
	-1,NULL, -- no level 4
	-1,NULL, -- no level 5
	-1,NULL, -- no level 6
	-1,NULL, -- no level 7
	-1,NULL, -- no level 8
	-1,NULL, -- no level 9
	-1,NULL, -- no level 10
	vt_start,vt_end
FROM DM_T_SUM_ACC_GEN_FLAT saf
WHERE saf.gen_0 IS NOT NULL AND saf.gen_1 IS NOT NULL AND saf.gen_2 IS NOT NULL
UNION ALL
-- gen 3
SELECT 
	gen_0, gen_3 TOP_LVL_1, CASE WHEN GEN_3_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_3_firstname) + ' ' + RTRIM(gen_3_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_3_firstname) + ' ' + RTRIM(gen_3_lastname)
	END TOP_LVL_1_DESC, -- level 1
	gen_2 TOP_LVL_2, CASE WHEN GEN_2_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_2_firstname) + ' ' + RTRIM(gen_2_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_2_firstname) + ' ' + RTRIM(gen_2_lastname)
	END TOP_LVL_2_DESC, -- level 2
	gen_1 TOP_LVL_3, CASE WHEN GEN_1_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_1_firstname) + ' ' + RTRIM(gen_1_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_1_firstname) + ' ' + RTRIM(gen_1_lastname)
	END TOP_LVL_3_DESC, -- level 3
	gen_0 TOP_LVL_4, CASE WHEN GEN_0_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_0_firstname) + ' ' + RTRIM(gen_0_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_0_firstname) + ' ' + RTRIM(gen_0_lastname)
	END TOP_LVL_4_DESC, -- level 4
	-1,NULL, -- no level 5
	-1,NULL, -- no level 6
	-1,NULL, -- no level 7
	-1,NULL, -- no level 8
	-1,NULL, -- no level 9
	-1,NULL, -- no level 10
	vt_start,vt_end
FROM DM_T_SUM_ACC_GEN_FLAT saf
WHERE saf.gen_0 IS NOT NULL AND saf.gen_1 IS NOT NULL AND saf.gen_2 IS NOT NULL AND saf.gen_3 IS NOT NULL
UNION ALL
-- gen 4
SELECT 
	gen_0, gen_4 TOP_LVL_1, CASE WHEN GEN_4_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_4_firstname) + ' ' + RTRIM(gen_4_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_4_firstname) + ' ' + RTRIM(gen_4_lastname)
	END TOP_LVL_1_DESC, -- level 1
	gen_3 TOP_LVL_2, CASE WHEN GEN_3_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_3_firstname) + ' ' + RTRIM(gen_3_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_3_firstname) + ' ' + RTRIM(gen_3_lastname)
	END TOP_LVL_2_DESC, -- level 2
	gen_2 TOP_LVL_3, CASE WHEN GEN_2_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_2_firstname) + ' ' + RTRIM(gen_2_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_2_firstname) + ' ' + RTRIM(gen_2_lastname)
	END TOP_LVL_3_DESC, -- level 3
	gen_1 TOP_LVL_4, CASE WHEN GEN_1_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_1_firstname) + ' ' + RTRIM(gen_1_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_1_firstname) + ' ' + RTRIM(gen_1_lastname)
	END TOP_LVL_4_DESC, -- level 4
	gen_0 TOP_LVL_5, CASE WHEN GEN_0_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_0_firstname) + ' ' + RTRIM(gen_0_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_0_firstname) + ' ' + RTRIM(gen_0_lastname)
	END TOP_LVL_5_DESC, -- level 5
	-1,NULL, -- no level 6
	-1,NULL, -- no level 7
	-1,NULL, -- no level 8
	-1,NULL, -- no level 9
	-1,NULL, -- no level 10
	vt_start,vt_end
FROM DM_T_SUM_ACC_GEN_FLAT saf
WHERE saf.gen_0 IS NOT NULL AND saf.gen_1 IS NOT NULL AND saf.gen_2 IS NOT NULL AND saf.gen_3 IS NOT NULL 
AND saf.gen_4 IS NOT NULL
UNION ALL
-- gen 5
SELECT 
	gen_0, gen_5 TOP_LVL_1, CASE WHEN GEN_5_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_5_firstname) + ' ' + RTRIM(gen_5_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_5_firstname) + ' ' + RTRIM(gen_5_lastname)
	END TOP_LVL_1_DESC, -- level 1
	gen_4 TOP_LVL_2, CASE WHEN GEN_4_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_4_firstname) + ' ' + RTRIM(gen_4_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_4_firstname) + ' ' + RTRIM(gen_4_lastname)
	END TOP_LVL_2_DESC, -- level 2
	gen_3 TOP_LVL_3, CASE WHEN GEN_3_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_3_firstname) + ' ' + RTRIM(gen_3_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_3_firstname) + ' ' + RTRIM(gen_3_lastname)
	END TOP_LVL_3_DESC, -- level 3
	gen_2 TOP_LVL_4, CASE WHEN GEN_2_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_2_firstname) + ' ' + RTRIM(gen_2_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_2_firstname) + ' ' + RTRIM(gen_2_lastname)
	END TOP_LVL_4_DESC, -- level 4
	gen_1 TOP_LVL_5, CASE WHEN GEN_1_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_1_firstname) + ' ' + RTRIM(gen_1_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_1_firstname) + ' ' + RTRIM(gen_1_lastname)
	END TOP_LVL_5_DESC, -- level 5
	gen_0 TOP_LVL_6, CASE WHEN GEN_0_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_0_firstname) + ' ' + RTRIM(gen_0_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_0_firstname) + ' ' + RTRIM(gen_0_lastname)
	END TOP_LVL_6_DESC, -- level 6
	-1,NULL, -- no level 7
	-1,NULL, -- no level 8
	-1,NULL, -- no level 9
	-1,NULL, -- no level 10
	vt_start,vt_end
FROM DM_T_SUM_ACC_GEN_FLAT saf
WHERE saf.gen_0 IS NOT NULL AND saf.gen_1 IS NOT NULL AND saf.gen_2 IS NOT NULL AND saf.gen_3 IS NOT NULL 
AND saf.gen_4 IS NOT NULL AND saf.gen_5 IS NOT NULL
UNION ALL
-- gen 6
SELECT 
	gen_0, gen_6 TOP_LVL_1, CASE WHEN GEN_6_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_6_firstname) + ' ' + RTRIM(gen_6_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_6_firstname) + ' ' + RTRIM(gen_6_lastname)
	END TOP_LVL_1_DESC, -- level 1
	gen_5 TOP_LVL_2, CASE WHEN GEN_5_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_5_firstname) + ' ' + RTRIM(gen_5_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_5_firstname) + ' ' + RTRIM(gen_5_lastname)
	END TOP_LVL_2_DESC, -- level 2
	gen_4 TOP_LVL_3, CASE WHEN GEN_4_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_4_firstname) + ' ' + RTRIM(gen_4_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_4_firstname) + ' ' + RTRIM(gen_4_lastname)
	END TOP_LVL_3_DESC, -- level 3
	gen_3 TOP_LVL_4, CASE WHEN GEN_3_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_3_firstname) + ' ' + RTRIM(gen_3_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_3_firstname) + ' ' + RTRIM(gen_3_lastname)
	END TOP_LVL_4_DESC, -- level 4
	gen_2 TOP_LVL_5, CASE WHEN GEN_2_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_2_firstname) + ' ' + RTRIM(gen_2_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_2_firstname) + ' ' + RTRIM(gen_2_lastname)
	END TOP_LVL_5_DESC, -- level 5
	gen_1 TOP_LVL_6, CASE WHEN GEN_1_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_1_firstname) + ' ' + RTRIM(gen_1_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_1_firstname) + ' ' + RTRIM(gen_1_lastname)
	END TOP_LVL_6_DESC, -- level 6
	gen_0 TOP_LVL_7, CASE WHEN GEN_0_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_0_firstname) + ' ' + RTRIM(gen_0_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_0_firstname) + ' ' + RTRIM(gen_0_lastname)
	END TOP_LVL_7_DESC, -- level 7
	-1,NULL, -- no level 8
	-1,NULL, -- no level 9
	-1,NULL, -- no level 10
	vt_start,vt_end
FROM DM_T_SUM_ACC_GEN_FLAT saf
WHERE saf.gen_0 IS NOT NULL AND saf.gen_1 IS NOT NULL AND saf.gen_2 IS NOT NULL AND saf.gen_3 IS NOT NULL 
AND saf.gen_4 IS NOT NULL AND saf.gen_5 IS NOT NULL AND saf.gen_6 IS NOT NULL 
UNION ALL
-- gen 7
SELECT 
	gen_0, gen_7 TOP_LVL_1, CASE WHEN GEN_7_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_7_firstname) + ' ' + RTRIM(gen_7_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_7_firstname) + ' ' + RTRIM(gen_7_lastname)
	END TOP_LVL_1_DESC, -- level 1
	gen_6 TOP_LVL_2, CASE WHEN GEN_6_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_6_firstname) + ' ' + RTRIM(gen_6_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_6_firstname) + ' ' + RTRIM(gen_6_lastname)
	END TOP_LVL_2_DESC, -- level 2
	gen_5 TOP_LVL_3, CASE WHEN GEN_5_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_5_firstname) + ' ' + RTRIM(gen_5_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_5_firstname) + ' ' + RTRIM(gen_5_lastname)
	END TOP_LVL_3_DESC, -- level 3
	gen_4 TOP_LVL_4, CASE WHEN GEN_4_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_4_firstname) + ' ' + RTRIM(gen_4_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_4_firstname) + ' ' + RTRIM(gen_4_lastname)
	END TOP_LVL_4_DESC, -- level 4
	gen_3 TOP_LVL_5, CASE WHEN GEN_3_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_3_firstname) + ' ' + RTRIM(gen_3_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_3_firstname) + ' ' + RTRIM(gen_3_lastname)
	END TOP_LVL_5_DESC, -- level 5
	gen_2 TOP_LVL_6, CASE WHEN GEN_2_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_2_firstname) + ' ' + RTRIM(gen_2_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_2_firstname) + ' ' + RTRIM(gen_2_lastname)
	END TOP_LVL_6_DESC, -- level 6
	gen_1 TOP_LVL_7, CASE WHEN GEN_1_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_1_firstname) + ' ' + RTRIM(gen_1_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_1_firstname) + ' ' + RTRIM(gen_1_lastname)
	END TOP_LVL_7_DESC, -- level 7
	gen_0 TOP_LVL_8, CASE WHEN GEN_0_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_0_firstname) + ' ' + RTRIM(gen_0_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_0_firstname) + ' ' + RTRIM(gen_0_lastname)
	END TOP_LVL_8_DESC, -- level 8
	-1,NULL, -- no level 9
	-1,NULL, -- no level 10
	vt_start,vt_end
FROM DM_T_SUM_ACC_GEN_FLAT saf
WHERE saf.gen_0 IS NOT NULL AND saf.gen_1 IS NOT NULL AND saf.gen_2 IS NOT NULL AND saf.gen_3 IS NOT NULL 
AND saf.gen_4 IS NOT NULL AND saf.gen_5 IS NOT NULL AND saf.gen_6 IS NOT NULL AND saf.gen_7 IS NOT NULL
UNION ALL
-- gen 8
SELECT 
	gen_0, gen_8 TOP_LVL_1, CASE WHEN GEN_8_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_8_firstname) + ' ' + RTRIM(gen_8_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_8_firstname) + ' ' + RTRIM(gen_8_lastname)
	END TOP_LVL_1_DESC, -- level 1
	gen_7 TOP_LVL_2, CASE WHEN GEN_7_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_7_firstname) + ' ' + RTRIM(gen_7_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_7_firstname) + ' ' + RTRIM(gen_7_lastname)
	END TOP_LVL_2_DESC, -- level 2
	gen_6 TOP_LVL_3, CASE WHEN GEN_6_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_6_firstname) + ' ' + RTRIM(gen_6_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_6_firstname) + ' ' + RTRIM(gen_6_lastname)
	END TOP_LVL_3_DESC, -- level 3
	gen_5 TOP_LVL_4, CASE WHEN GEN_5_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_5_firstname) + ' ' + RTRIM(gen_5_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_5_firstname) + ' ' + RTRIM(gen_5_lastname)
	END TOP_LVL_4_DESC, -- level 4
	gen_4 TOP_LVL_5, CASE WHEN GEN_4_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_4_firstname) + ' ' + RTRIM(gen_4_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_4_firstname) + ' ' + RTRIM(gen_4_lastname)
	END TOP_LVL_5_DESC, -- level 5
	gen_3 TOP_LVL_6, CASE WHEN GEN_3_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_3_firstname) + ' ' + RTRIM(gen_3_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_3_firstname) + ' ' + RTRIM(gen_3_lastname)
	END TOP_LVL_6_DESC, -- level 6
	gen_2 TOP_LVL_7, CASE WHEN GEN_2_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_2_firstname) + ' ' + RTRIM(gen_2_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_2_firstname) + ' ' + RTRIM(gen_2_lastname)
	END TOP_LVL_7_DESC, -- level 7
	gen_1 TOP_LVL_8, CASE WHEN GEN_1_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_1_firstname) + ' ' + RTRIM(gen_1_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_1_firstname) + ' ' + RTRIM(gen_1_lastname)
	END TOP_LVL_8_DESC, -- level 8
	gen_0 TOP_LVL_9, CASE WHEN GEN_0_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_0_firstname) + ' ' + RTRIM(gen_0_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_0_firstname) + ' ' + RTRIM(gen_0_lastname)
	END TOP_LVL_9_DESC, -- level 9
	-1,NULL, -- no level 10
	vt_start,vt_end
FROM DM_T_SUM_ACC_GEN_FLAT saf
WHERE saf.gen_0 IS NOT NULL AND saf.gen_1 IS NOT NULL AND saf.gen_2 IS NOT NULL AND saf.gen_3 IS NOT NULL 
AND saf.gen_4 IS NOT NULL AND saf.gen_5 IS NOT NULL AND saf.gen_6 IS NOT NULL AND saf.gen_7 IS NOT NULL
AND saf.gen_8 IS NOT NULL
UNION ALL
-- gen 9
SELECT 
	gen_0, gen_9 TOP_LVL_1, CASE WHEN GEN_9_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_9_firstname) + ' ' + RTRIM(gen_9_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_9_firstname) + ' ' + RTRIM(gen_9_lastname)
	END TOP_LVL_1_DESC, -- level 1
	gen_8 TOP_LVL_2, CASE WHEN GEN_8_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_8_firstname) + ' ' + RTRIM(gen_8_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_8_firstname) + ' ' + RTRIM(gen_8_lastname)
	END TOP_LVL_2_DESC, -- level 2
	gen_7 TOP_LVL_3, CASE WHEN GEN_7_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_7_firstname) + ' ' + RTRIM(gen_7_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_7_firstname) + ' ' + RTRIM(gen_7_lastname)
	END TOP_LVL_3_DESC, -- level 3
	gen_6 TOP_LVL_4, CASE WHEN GEN_6_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_6_firstname) + ' ' + RTRIM(gen_6_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_6_firstname) + ' ' + RTRIM(gen_6_lastname)
	END TOP_LVL_4_DESC, -- level 4
	gen_5 TOP_LVL_5, CASE WHEN GEN_5_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_5_firstname) + ' ' + RTRIM(gen_5_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_5_firstname) + ' ' + RTRIM(gen_5_lastname)
	END TOP_LVL_5_DESC, -- level 5
	gen_4 TOP_LVL_6, CASE WHEN GEN_4_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_4_firstname) + ' ' + RTRIM(gen_4_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_4_firstname) + ' ' + RTRIM(gen_4_lastname)
	END TOP_LVL_6_DESC, -- level 6
	gen_3 TOP_LVL_7, CASE WHEN GEN_3_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_3_firstname) + ' ' + RTRIM(gen_3_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_3_firstname) + ' ' + RTRIM(gen_3_lastname)
	END TOP_LVL_7_DESC, -- level 7
	gen_2 TOP_LVL_8, CASE WHEN GEN_2_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_2_firstname) + ' ' + RTRIM(gen_2_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_2_firstname) + ' ' + RTRIM(gen_2_lastname)
	END TOP_LVL_8_DESC, -- level 8
	gen_1 TOP_LVL_9, CASE WHEN GEN_1_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_1_firstname) + ' ' + RTRIM(gen_1_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_1_firstname) + ' ' + RTRIM(gen_1_lastname)
	END TOP_LVL_9_DESC, -- level 9
	gen_0 TOP_LVL_10, CASE WHEN GEN_0_FOLDER_FLAG = '1' THEN 'FOLDER:   ' + RTRIM(gen_0_firstname) + ' ' + RTRIM(gen_0_lastname)
	ELSE 'MEMBER:   ' + RTRIM(gen_0_firstname) + ' ' + RTRIM(gen_0_lastname)
	END TOP_LVL_10_DESC, -- level 10
	vt_start,vt_end
FROM dm_t_sum_acc_gen_flat saf
WHERE saf.gen_0 IS NOT NULL AND saf.gen_1 IS NOT NULL AND saf.gen_2 IS NOT NULL AND saf.gen_3 IS NOT NULL 
AND saf.gen_4 IS NOT NULL AND saf.gen_5 IS NOT NULL AND saf.gen_6 IS NOT NULL AND saf.gen_7 IS NOT NULL
AND saf.gen_8 IS NOT NULL AND saf.gen_9 IS NOT NULL

CREATE INDEX idx_dm_t_sum_acc_lvl_flat ON dm_t_sum_acc_lvl_flat (top_lvl_1, gen_0)

END 
	   