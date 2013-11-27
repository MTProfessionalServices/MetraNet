
BEGIN
  /* creates or truncates tmp_discount_1 */
  IF OBJECT_ID('tempdb..#tmp_discount_1') IS NOT NULL
    TRUNCATE TABLE #tmp_discount_1

  /* creates or truncates tmp_discount_2 */
  IF OBJECT_ID('tempdb..#tmp_discount_2') IS NOT NULL
    TRUNCATE TABLE #tmp_discount_2

  /* creates or truncates tmp_discount_3 */
  IF OBJECT_ID('tempdb..#tmp_discount_3') IS NULL
	BEGIN
	  /* table must be created explicitly since high-precision is required */
		/* on the proportion column */
		CREATE TABLE %%%TEMP_TABLE_PREFIX%%%tmp_discount_3
		( 
		  id_interval     INT NOT NULL,             /* discount interval */
		  id_group        INT NOT NULL,             /* group subscription */
			id_acc          INT NOT NULL,             /* member account */
			id_pi_instance          INT NOT NULL,             /* discount instance */
			proportion      NUMERIC(38, 20) NOT NULL  /* share of discount */
		)
  END
	ELSE
    TRUNCATE TABLE #tmp_discount_3

  /* creates or truncates tmp_discount_4 */
  IF OBJECT_ID('tempdb..#tmp_discount_4') IS NULL
	BEGIN
	  /* we need to create this table explicitly since we wouldn't know */
		/* which SELECT...INTO would execute first */
		CREATE TABLE %%%TEMP_TABLE_PREFIX%%%tmp_discount_4
		( 
		  id_interval     INT NOT NULL,              /* discount interval */
			id_group        INT NOT NULL,              /* group subscription */
			id_acc          INT NOT NULL,              /* member account */
			id_pi_instance          INT NOT NULL,              /* discount instance */
			amount          NUMERIC(22,10) NOT NULL    
		)
	END
	ELSE
    TRUNCATE TABLE #tmp_discount_4

  /* creates or truncates tmp_discount_5 */
  IF OBJECT_ID('tempdb..#tmp_discount_5') IS NOT NULL
    TRUNCATE TABLE #tmp_discount_5

  delete from t_pv_groupdiscount_temp
END
   