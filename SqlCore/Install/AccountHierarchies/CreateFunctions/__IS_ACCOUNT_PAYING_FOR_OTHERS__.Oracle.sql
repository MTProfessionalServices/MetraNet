
CREATE OR REPLACE 
function IsAccountPayingForOthers(
	p_id_acc IN integer,
	p_dt_ref IN DATE) 
return varchar2
as
 returnValue char(1);
BEGIN
 BEGIN
	SELECT CASE WHEN count(*) > 0 THEN 'Y' ELSE 'N' END
	INTO returnValue
	FROM t_payment_redirection
	WHERE id_payer = p_id_acc and
	/* this is the key difference between this and DoesAccountHavePayees*/
	id_payer <> id_payee and
	((p_dt_ref between vt_start and vt_end) OR p_dt_ref < vt_start);
	exception when NO_DATA_FOUND then
	 returnValue := 'N';
 END;
 return returnValue;
END;
				