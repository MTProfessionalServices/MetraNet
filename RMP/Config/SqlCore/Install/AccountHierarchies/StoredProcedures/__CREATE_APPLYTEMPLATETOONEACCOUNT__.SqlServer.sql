CREATE PROCEDURE ApplyTemplateToOneAccount
	@accountID INTEGER
	,@p_systemdate DATETIME
	,@p_acc_type NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @templateId INT
	DECLARE @templateOwner INT

	select top 1 @templateId = id_acc_template
			, @templateOwner = template.id_folder
	from
				t_acc_template template
	INNER JOIN t_account_ancestor ancestor on template.id_folder = ancestor.id_ancestor
	INNER JOIN t_account_mapper mapper on mapper.id_acc = ancestor.id_ancestor
	inner join t_account_type atype on template.id_acc_type = atype.id_type
	left join t_acc_tmpl_types tatt on tatt.id = 1
			WHERE id_descendent = @accountID AND
				@p_systemdate between vt_start AND vt_end AND
				(atype.name = @p_acc_type or tatt.all_types = 1)
	ORDER BY num_generations asc

	IF @templateId IS NOT NULL
	BEGIN
        DECLARE @sessionId INTEGER
		EXECUTE GetCurrentID 'id_template_session', @sessionId OUT
		insert into t_acc_template_session(id_session, id_template_owner, nm_acc_type, dt_submission, id_submitter, nm_host, n_status, n_accts, n_subs)
        values (@sessionId, @templateOwner, @p_acc_type, @p_systemdate, 0, '', 0, 0, 0)
		execute ApplyAccountTemplate @templateId, @sessionId, @p_systemdate, NULL, NULL, 'N', 'N', NULL, NULL, @accountID, 'N'
	END
END
