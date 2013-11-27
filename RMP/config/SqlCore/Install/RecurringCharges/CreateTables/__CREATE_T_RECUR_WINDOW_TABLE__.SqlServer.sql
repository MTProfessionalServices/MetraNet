
       CREATE TABLE t_recur_window(
	c_CycleEffectiveDate datetime NOT NULL,
	c_CycleEffectiveStart datetime NOT NULL,
	c_CycleEffectiveEnd datetime NOT NULL,
	c_SubscriptionStart datetime NOT NULL,
	c_SubscriptionEnd datetime NOT NULL,
	c_Advance char(1) NOT NULL,
	c__AccountID int NOT NULL,
	c__PayingAccount int NOT NULL,
	c__PriceableItemInstanceID int NULL,
	c__PriceableItemTemplateID int NULL,
	c__ProductOfferingID int NULL,
	c_PayerStart datetime NOT NULL,
	c_PayerEnd datetime NOT NULL,
	c__SubscriptionID int NOT NULL,
	c_UnitValueStart datetime NULL,
	c_UnitValueEnd datetime NULL,
	c_UnitValue numeric(22, 10) NULL,
	c_BilledThroughDate datetime NULL,
	c_LastIdRun int NOT NULL,
	c_MembershipStart datetime NULL,
	c_MembershipEnd datetime NULL
      );
	  
	insert into t_db_values(parameter,value) values('InstantRc','true');
      