
CREATE PROCEDURE ApplyAccountTemplate(
	@accountTemplateId          int,
	@sessionId                  int,
	@systemDate                 datetime,
	@sub_start                  datetime,
	@sub_end                    datetime,
	@next_cycle_after_startdate char, /* Y or N */
	@next_cycle_after_enddate   char, /* Y or N */
	@id_event_success           int,
	@id_event_failure           int,
	@account_id					int = NULL,
	@doCommit                   char = 'Y' /* Y or N */
)
AS
	SET NOCOUNT ON


	DECLARE @nRetryCount int
	SET @nRetryCount = 0

	DECLARE @DetailTypeGeneral int
	DECLARE @DetailResultInformation int
	DECLARE @DetailTypeSubscription int
	DECLARE @id_acc_type int
	DECLARE @id_acc int
	DECLARE @user_id int

	SELECT @id_acc_type = id_acc_type, @id_acc = id_folder FROM t_acc_template WHERE id_acc_template = @accountTemplateId
	SELECT @user_id = ts.id_submitter FROM t_acc_template_session ts WHERE ts.id_session = @sessionId


	SELECT @DetailTypeGeneral = id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Success'
	SELECT @DetailResultInformation = id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailResult/Information'
	SELECT @DetailTypeSubscription = id_enum_data FROM t_enum_data WHERE nm_enum_data = 'metratech.com/accounttemplate/DetailType/Subscription'
	--!!!Starting application of template
	INSERT INTO t_acc_template_session_detail
		(
			id_session,
			n_detail_type,
			n_result,
			dt_detail,
			nm_text,
			n_retry_count
		)
		VALUES
		(
			@sessionId,
			@DetailTypeGeneral,
			@DetailResultInformation,
			getdate(),
			'Starting application of template',
			@nRetryCount
		)

	-- Updating session details with a number of themplates to be applied in the session
	UPDATE t_acc_template_session
	SET    n_templates = (SELECT COUNT(1) FROM t_account_ancestor aa JOIN t_acc_template at ON aa.id_ancestor = @id_acc AND aa.id_descendent = at.id_folder)
	WHERE  id_session = @sessionId

	DECLARE @incIdTemplate INT
	--Select account hierarchy for current template and for each child template.
	DECLARE accTemplateCursor CURSOR FOR

	SELECT tat.id_acc_template

	FROM t_account_ancestor taa
	INNER JOIN t_acc_template tat ON taa.id_descendent = tat.id_folder AND tat.id_acc_type = @id_acc_type
	WHERE taa.id_ancestor = @id_acc

	OPEN accTemplateCursor
	FETCH NEXT FROM accTemplateCursor INTO @incIdTemplate

	WHILE @@FETCH_STATUS = 0
	BEGIN

		--Apply account template to appropriate account list.
		EXEC ApplyTemplateToAccounts
			@idAccountTemplate          = @incIdTemplate,
			@sub_start                  = @sub_start,
			@sub_end                    = @sub_end,
			@next_cycle_after_startdate = @next_cycle_after_startdate,
			@next_cycle_after_enddate   = @next_cycle_after_enddate,
			@user_id                    = @user_id,
			@id_event_success           = @id_event_success,
			@id_event_failure           = @id_event_failure,
			@systemDate                 = @systemDate,
			@sessionId                  = @sessionId,
			@retrycount                 = @nRetryCount,
			@account_id				    = @account_id,
			@doCommit					= @doCommit
		
		UPDATE t_acc_template_session
		SET    n_templates_applied = n_templates_applied + 1
		WHERE  id_session = @sessionId

		FETCH NEXT FROM accTemplateCursor INTO @incIdTemplate
	END

	CLOSE accTemplateCursor
	DEALLOCATE accTemplateCursor

    /* Apply default security */
    INSERT INTO t_policy_role
    SELECT pd.id_policy, pr.id_role
    FROM   t_account_ancestor aa
           JOIN t_account_ancestor ap ON ap.id_descendent = aa.id_descendent AND ap.num_generations = 1
           JOIN t_principal_policy pp ON pp.id_acc = ap.id_ancestor AND pp.policy_type = 'D'
           JOIN t_principal_policy pd ON pd.id_acc = aa.id_descendent AND pd.policy_type = 'A'
           JOIN t_policy_role pr ON pr.id_policy = pp.id_policy
           JOIN t_acc_template t ON aa.id_ancestor = t.id_folder AND t.b_applydefaultpolicy = 'Y'
    WHERE  t.id_acc_template = @accountTemplateId
       AND aa.num_generations > 0
       AND NOT EXISTS (SELECT 1 FROM t_policy_role pr2 WHERE pr2.id_policy = pd.id_policy AND pr2.id_role = pr.id_role)
   
	-- Finalize session state
	UPDATE t_acc_template_session
	SET    n_templates = n_templates_applied
	WHERE  id_session = @sessionId

	--!!!Template application complete
	INSERT INTO t_acc_template_session_detail
	(
		id_session,
		n_detail_type,
		n_result,
		dt_detail,
		nm_text,
		n_retry_count
	)
	VALUES
	(
		@sessionId,
		@DetailTypeGeneral,
		@DetailResultInformation,
		getdate(),
		'Template application complete',
		@nRetryCount
	)