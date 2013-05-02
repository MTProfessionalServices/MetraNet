
CREATE PROCEDURE UpsertAccountType @name nvarchar(400), @b_cansubscribe varchar(1), 
              @b_canbepayer varchar(1), @b_canhavesyntheticroot varchar(1), 
              @b_CanParticipateInGSub varchar(1), @bIsVisibleInHierarchy varchar(1),
              @b_CanHaveTemplates varchar(1), @b_IsCorporate varchar(1),
              @nm_desc nvarchar(1024), @id_accounttype int OUTPUT
AS
BEGIN
      update t_account_type 
			set 
			  b_cansubscribe = @b_cansubscribe,
			  b_canbepayer = @b_canbepayer,
			  b_canhavesyntheticroot = @b_canhavesyntheticroot,
			  b_CanParticipateInGSub = @b_CanParticipateInGSub,
			  b_IsVisibleInHierarchy = @bIsVisibleInHierarchy,
			  b_CanHaveTemplates = @b_CanHaveTemplates,
			  b_IsCorporate = @b_IsCorporate,
			  nm_description = @nm_desc
			where
			name = @name

			if (@@ROWCOUNT = 0)
		  insert into t_account_type 
			(name, b_CanSubscribe, b_CanBePayer, b_CanHaveSyntheticRoot, b_CanParticipateInGSub, b_IsVisibleInHierarchy,
			b_CanHaveTemplates, b_IsCorporate, nm_description)
			values 
			(@name, @b_cansubscribe, @b_canbepayer, @b_canhavesyntheticroot, @b_CanParticipateInGSub,
			 @bIsVisibleInHierarchy, @b_CanHaveTemplates, @b_IsCorporate, @nm_desc)

			select @id_accounttype=id_type from t_account_type where name=@name
END
			