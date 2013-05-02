USE NetMeter
/* Drop the relationship tables first */
EXEC sp_MSForEachTable 'IF ''?'' LIKE ''%t[_]be[_]%[_]r[_]%'' EXEC('' DROP TABLE ? '') ' 
/* Drop the remaining tables */
EXEC sp_MSForEachTable 'IF ''?'' LIKE ''%t[_]be[_]%'' EXEC('' DROP TABLE ? '') ' 

create table [t_be_entity_sync_data] 
(
  id [uniqueidentifier] NOT NULL,
  [tx_entity_name] [nvarchar](255) not null,
  [tx_hbm_checksum] [nvarchar](255) not null,
  [dt_sync_date] [datetime] not null,
  primary key (id)
)


select * from t_be_cor_ui_BillSetting