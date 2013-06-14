
create proc ApplyAccountTemplate @accountTemplateId int, @sessionId int, @systemDate datetime
as
set nocount on


declare @nRetryCount int
set @nRetryCount = 0

declare @DetailTypeGeneral int
declare @DetailResultInformation int
declare @DetailTypeSubscription int
declare @id_acc_type int
declare @id_acc int

select @id_acc_type = id_acc_type, @id_acc = id_folder from t_acc_template where id_acc_template = @accountTemplateId


SELECT @DetailTypeGeneral = id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Success'
SELECT @DetailResultInformation = id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Information'
SELECT @DetailTypeSubscription = id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailType/Subscription'
--!!!Starting application of template
insert into t_acc_template_session_detail
	( 
		id_session,    
		n_detail_type,
		n_result,    
		dt_detail,  
		nm_text,    
		n_retry_count
	)
	values
	(
		@sessionId,
		@DetailTypeGeneral,
		@DetailResultInformation,
		getdate(),
		'Starting application of template',
		@nRetryCount
	)

declare @incIdTemplate int
--Select account hierarchy for current template and for each child template.
declare accTemplateCursor cursor for

select tat.id_acc_template

from t_account_ancestor taa
inner join t_acc_template tat on taa.id_descendent = tat.id_folder and tat.id_acc_type = @id_acc_type
where taa.id_ancestor = @id_acc

OPEN accTemplateCursor   
fetch next from accTemplateCursor into @incIdTemplate

while @@FETCH_STATUS = 0
begin

	--Apply account template to appropriate account list.
	execute ApplyTemplateToAccounts @incIdTemplate, @sessionId, @nRetryCount, @systemDate
	fetch next from accTemplateCursor into @incIdTemplate
end

close accTemplateCursor   
deallocate accTemplateCursor


insert into t_acc_template_session_detail
( 
	id_session,
	n_detail_type,
	n_result,
	dt_detail,
	nm_text,
	n_retry_count
)
values
(
	@sessionId,
	@DetailTypeSubscription,
	@DetailResultInformation,
	getdate(),
	'There are no subscriptions to be applied',
	@nRetryCount
)

--!!!Template application complete
insert into t_acc_template_session_detail
( 
	id_session,
	n_detail_type,
	n_result,
	dt_detail,
	nm_text,
	n_retry_count
)
values
(
	@sessionId,
	@DetailTypeGeneral,
	@DetailResultInformation,
	getdate(),
	'Template application complete',
	@nRetryCount
)