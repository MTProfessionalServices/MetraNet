
CREATE OR REPLACE PROCEDURE Updategroupsubscription(
p_id_group INT,
p_name NVARCHAR2,
p_desc NVARCHAR2,
p_startdate DATE,
p_enddate DATE,
p_proportional VARCHAR2,
p_supportgroupops VARCHAR2,
p_discountaccount INT,
p_CorporateAccount INT,
p_systemdate DATE,
p_enforce_same_corporation VARCHAR2,
p_allow_acc_po_curr_mismatch IN       INTEGER DEFAULT 0,
p_status OUT INT,
p_datemodified OUT VARCHAR2
)
AS
	idPO INTEGER;
  idSUB INTEGER;
	realenddate DATE;
	oldstartdate DATE;
	oldenddate DATE;
	varMaxDateTime DATE;
	idusagecycle INTEGER;
BEGIN
	varMaxDateTime := Dbo.Mtmaxdate(); 

    /* find the product offering ID*/
    BEGIN
        SELECT id_po, tg.id_usage_cycle, T_SUB.id_sub
        INTO idPO,idusagecycle,idSUB
        FROM T_SUB 
        INNER JOIN T_GROUP_SUB tg ON tg.id_group = p_id_group
        WHERE T_SUB.id_group = p_id_group;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        NULL;
    END;

	/* business rule checks*/
	IF (p_enddate IS NULL) THEN
		realenddate := varMaxDateTime;
	ELSE
		realenddate := p_enddate;
    END IF;

	Checkgroupsubbusinessrules(p_name,p_desc,p_startdate,p_enddate,idPO,
	p_proportional,p_discountaccount,p_CorporateAccount,p_id_group,idusagecycle,p_systemdate,p_enforce_same_corporation,p_allow_acc_po_curr_mismatch,p_status);
	IF p_status <> 1 THEN
    RETURN;
	END IF;

	Updatesub(idSUB,p_startdate,realenddate,'N','N',idPO,NULL,p_systemdate,
		p_status,p_datemodified);
	IF p_status <> 1 THEN
		RETURN;
	END IF;

	UPDATE T_GROUP_SUB SET tx_name = p_name,tx_desc = p_desc,b_proportional = p_proportional,
	id_corporate_account = p_CorporateAccount,id_discountaccount = p_discountaccount,
	b_supportgroupops = p_supportgroupops
	WHERE id_group = p_id_group;

	/* update t_groupsub_historical and friends*

	 Existing RECORD          |--------------|
	 NEW GROUP eff DATE    |--------------|
	 NEW GROUP eff DATE    					|--------------|
	 bring IN THE END DATE TO match THE NEW END DATE OF THE GROUP sub*/
	
	UPDATE T_GSUBMEMBER_HISTORICAL
	SET tt_end = p_systemdate
	WHERE
	id_group = p_id_group  
    AND tt_end = varMaxDateTime
    AND ((p_startdate > vt_start) OR (realenddate < vt_end));

	INSERT INTO T_GSUBMEMBER_HISTORICAL (id_group,id_acc,vt_start,vt_end,tt_start,tt_end)
	SELECT id_group,id_acc,
	Dbo.mtmaxoftwodates(tgs.vt_start,p_startdate),
	Dbo.mtminoftwodates(tgs.vt_end,realenddate),
	p_systemdate,
	varMaxDateTime
	FROM T_GSUBMEMBER tgs
	WHERE tgs.id_group = p_id_group
    AND ((p_startdate > vt_start AND vt_end >= p_startdate) OR (realenddate < vt_end AND vt_start <= realenddate));

	/*remove the old records*/
	DELETE FROM T_GSUBMEMBER WHERE id_group = p_id_group;

	/* reccreate the new subscription records*/
	INSERT INTO T_GSUBMEMBER (id_group,id_acc,vt_start,vt_end)
	SELECT id_group,id_acc,vt_start,vt_end
	FROM T_GSUBMEMBER_HISTORICAL
	WHERE id_group = p_id_group AND tt_end = varMaxDateTime;
	/* done*/

  /* post-operation business rule checks (relies on rollback of work done up until this point)
   CR9906: check to make sure the newly added member does not violate a BCR constraint*/
                  
  p_status := Dbo.CheckGroupMembershipCycleConst(p_systemdate, p_id_group);
  IF p_status <> 1 THEN
    RETURN;
  END IF;
  
  /* checks to make sure the member's payer's do not violate EBCR cycle constraints*/
  p_status := Dbo.CheckGroupMembershipEBCRConstr(p_systemdate, p_id_group);
  IF p_status <> 1 THEN
    RETURN;
  END IF;

  /* checks to make sure the receiver's payer's do not violate EBCR cycle constraints*/
  p_status := Dbo.checkgroupreceiverebcrcons(p_systemdate, p_id_group);

END;
		