
    /* Following temp tables are created for storing intermediate results during MV code processing, These are created during MV sync operation */
  begin
	if not table_exists('%%%NETMETERSTAGE_PREFIX%%%summ_delta_i_payer_interval') then
	exec_ddl ('CREATE TABLE %%%NETMETERSTAGE_PREFIX%%%summ_delta_i_payer_interval (
	id_acc number(10) NOT NULL ,
	id_dm_acc number(10) NOT NULL ,
	id_usage_interval number(10) NOT NULL ,
	id_prod number(10) NULL ,
	id_view number(10) NOT NULL ,
	id_pi_instance number(10) NULL ,
	id_pi_template number(10) NULL ,
	am_currency nvarchar2 (3) NOT NULL ,
	id_se number(10) NULL ,
	TotalAmount numeric(38, 6) NULL ,
	TotalFederalTax numeric(38, 6) NULL ,
	TotalCountyTax numeric(38, 6)  NULL,
	TotalLocalTax numeric(38, 6)  NULL,
	TotalOtherTax numeric(38, 6)  NULL,	
	TotalStateTax numeric(38, 6) NULL ,
	TotalTax numeric(38, 6) NULL ,
	PrebillAdjAmt numeric(38, 6) NULL ,
	PrebillFedTaxAdjAmt numeric(38, 6) NULL ,
	PrebillStateTaxAdjAmt numeric(38, 6) NULL ,
	PrebillCntyTaxAdjAmt numeric(38, 6) NULL ,
	PrebillLocalTaxAdjAmt numeric(38, 6) NULL ,
	PrebillOtherTaxAdjAmt numeric(38, 6) NULL ,
	PrebillTotalTaxAdjAmt numeric(38, 6) NULL ,
	PostbillAdjAmt numeric(38, 6) NULL ,
	PostbillFedTaxAdjAmt numeric(38, 6) NULL ,
	PostbillStateTaxAdjAmt numeric(38, 6) NULL ,
	PostbillCntyTaxAdjAmt numeric(38, 6) NULL ,
	PostbillLocalTaxAdjAmt numeric(38, 6) NULL ,
	PostbillOtherTaxAdjAmt numeric(38, 6) NULL ,
	PostbillTotalTaxAdjAmt numeric(38, 6) NULL ,
	PrebillAdjustedAmount numeric(38, 6) NULL ,
	PostbillAdjustedAmount numeric(38, 6) NULL ,
	NumPrebillAdjustments number(10) NULL ,
	NumPostbillAdjustments number(10) NULL ,
	NumTransactions number(10) NULL)');
    exec_ddl
       ('CREATE index i_summ_delta_i_payer_interval on  %%%NETMETERSTAGE_PREFIX%%%summ_delta_i_payer_interval(id_acc,id_usage_interval,id_view,id_dm_acc)'
       );
	end if;
	if not table_exists('%%%NETMETERSTAGE_PREFIX%%%summ_delta_d_payer_interval') then
	exec_ddl ('CREATE TABLE %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_payer_interval (
	id_acc number(10) NOT NULL ,
	id_dm_acc number(10) NOT NULL ,
	id_usage_interval number(10) NOT NULL ,
	id_prod number(10) NULL ,
	id_view number(10) NOT NULL ,
	id_pi_instance number(10) NULL ,
	id_pi_template number(10) NULL ,
	am_currency nvarchar2 (3) NOT NULL ,
	id_se number(10) NULL ,
	TotalAmount numeric(38, 6) NULL ,
	TotalFederalTax numeric(38, 6) NULL ,
	TotalCountyTax numeric(38, 6)  NULL,
	TotalLocalTax numeric(38, 6)  NULL,
	TotalOtherTax numeric(38, 6)  NULL,	
	TotalStateTax numeric(38, 6) NULL ,
	TotalTax numeric(38, 6) NULL ,
	PrebillAdjAmt numeric(38, 6) NULL ,
	PrebillFedTaxAdjAmt numeric(38, 6) NULL ,
	PrebillStateTaxAdjAmt numeric(38, 6) NULL ,
	PrebillCntyTaxAdjAmt numeric(38, 6) NULL ,
	PrebillLocalTaxAdjAmt numeric(38, 6) NULL ,
	PrebillOtherTaxAdjAmt numeric(38, 6) NULL ,
	PrebillTotalTaxAdjAmt numeric(38, 6) NULL ,
	PostbillAdjAmt numeric(38, 6) NULL ,
	PostbillFedTaxAdjAmt numeric(38, 6) NULL ,
	PostbillStateTaxAdjAmt numeric(38, 6) NULL ,
	PostbillCntyTaxAdjAmt numeric(38, 6) NULL ,
	PostbillLocalTaxAdjAmt numeric(38, 6) NULL ,
	PostbillOtherTaxAdjAmt numeric(38, 6) NULL ,
	PostbillTotalTaxAdjAmt numeric(38, 6) NULL ,
	PrebillAdjustedAmount numeric(38, 6) NULL ,
	PostbillAdjustedAmount numeric(38, 6) NULL ,
	NumPrebillAdjustments number(10) NULL ,
	NumPostbillAdjustments number(10) NULL ,
	NumTransactions number(10) NULL)');
    exec_ddl
       ('CREATE index i_summ_delta_d_payer_interval on  %%%NETMETERSTAGE_PREFIX%%%summ_delta_d_payer_interval(id_acc,id_usage_interval,id_view,id_dm_acc)'
       );
	end if;
	end;
	