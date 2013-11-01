CREATE FUNCTION AllowInitialArrersCharge(@b_advance char, @id_acc int, @id_sub int, @sub_end datetime) RETURNS bit 
AS
BEGIN
	IF @b_advance = 'Y'
	BEGIN
	   /* allows to create initial for ADVANCE */
		RETURN 1
	END	

	 /* forbidden to create initial for ARREARS 
	  * [TODO] Need implement that if end date of Sub is fit in billing acc interval it should be allowed to create Initila charge 
	  */
	RETURN 0	
END