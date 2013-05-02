IF EXISTS (select * from sys.indexes where name = 'IX_t_be_cor_fil_invocationreco_c__ControlNumber')
DROP INDEX IX_t_be_cor_fil_invocationreco_c__ControlNumber ON t_be_cor_fil_invocationreco
GO
IF EXISTS (select * from sys.stats where name = 'STAT_t_enum_data_1_2')
DROP STATISTICS t_enum_data.STAT_t_enum_data_1_2
GO
IF EXISTS (select * from sys.stats where name = 'STAT_t_mf_tracking_env_5')
DROP STATISTICS t_mf_tracking_env.stat_t_mf_tracking_env_5
GO
IF EXISTS (select * from sys.stats where name = 'STAT_t_be_cor_fil_filebe_1_2')
DROP STATISTICS t_be_cor_fil_filebe.STAT_t_be_cor_fil_filebe_1_2
GO
IF EXISTS (select * from sys.stats where name = 'STAT_t_be_cor_fil_invocationreco_1_9')
DROP STATISTICS t_be_cor_fil_invocationreco.STAT_t_be_cor_fil_invocationreco_1_9
GO
IF EXISTS (select * from sys.stats where name = 'STAT_t_be_cor_fil_invocationreco_1_2')
DROP STATISTICS t_be_cor_fil_invocationreco.STAT_t_be_cor_fil_invocationreco_1_2
GO
IF EXISTS (select * from sys.stats where name = 'STAT_t_be_cor_fil_r_invoca_filebe_6_7')
DROP STATISTICS t_be_cor_fil_r_invoca_filebe.STAT_t_be_cor_fil_r_invoca_filebe_6_7
GO

CREATE NONCLUSTERED INDEX [IX_t_be_cor_fil_invocationreco_c__ControlNumber] ON [dbo].[t_be_cor_fil_invocationreco]
(
[c__ControlNumber] ASC
)
INCLUDE ( [c_InvocationRecordBE_Id],
[c__version],
[c_internal_key],
[c_CreationDate],
[c_UpdateDate],
[c__Command],
[c__ErrorCode],
[c__State],
[c__DateTime],
[c__BatchId],
[c__TrackingId])
GO

CREATE STATISTICS [STAT_t_be_cor_fil_invocationreco_1_9] ON [dbo].[t_be_cor_fil_invocationreco]([c_InvocationRecordBE_Id], [c__ControlNumber])
GO
CREATE STATISTICS [STAT_t_be_cor_fil_invocationreco_1_2] ON [dbo].[t_be_cor_fil_invocationreco]([c_InvocationRecordBE_Id], [c__version])
GO
CREATE STATISTICS [STAT_t_be_cor_fil_filebe_1_2] ON [dbo].[t_be_cor_fil_filebe]([c_FileBE_Id], [c__version])
GO
CREATE STATISTICS [STAT_t_be_cor_fil_r_invoca_filebe_6_7] ON [dbo].[t_be_cor_fil_r_invoca_filebe]([c_InvocationRecordBE_Id], [c_FileBE_Id])
GO
CREATE STATISTICS [STAT_t_enum_data_1_2] ON [dbo].[t_enum_data]([nm_enum_data], [id_enum_data])
GO
CREATE STATISTICS [STAT_t_mf_tracking_env_5] ON [dbo].[t_mf_tracking_env]([arg_type])
GO
