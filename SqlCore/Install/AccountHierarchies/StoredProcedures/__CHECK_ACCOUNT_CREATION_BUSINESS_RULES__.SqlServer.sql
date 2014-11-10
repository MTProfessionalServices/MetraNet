
				CREATE PROCEDURE CheckAccountCreationBusinessRules(
				  @p_nm_space nvarchar(40),
				  @p_acc_type varchar(40),
				  @p_id_ancestor int,
					@status int OUTPUT)
				AS
				BEGIN
				  -- 1. check account and its ancestor business rules. 
					-- Only an account of type systemaccount can exist in
					-- these namespaces
					DECLARE @tx_typ_space AS varchar(40)
					SELECT 
				  	@tx_typ_space = tx_typ_space 
					FROM
				  	t_namespace 
					WHERE
				  	nm_space = @p_nm_space		
	
					IF (@tx_typ_space in ('system_user', 
					                      'system_auth', 
					                      'system_mcm', 
					                      'system_ops', 
					                      'system_rate', 
																'system_csr'))
					BEGIN
						-- An account with this account type and namespace cannot be
						-- created
					  IF (@p_acc_type NOT in ('SYSTEMACCOUNT'))
						BEGIN
							-- MT_ACCOUNT_TYPE_AND_NAMESPACE_MISMATCH ((DWORD)0xE2FF0046L)
			  			SELECT @status = -486604732
							RETURN
						END
					END	

					-- If an account is not a subscriber or an independent account 
					-- and its namespace is system_mps, that shouldnt be allowed
					-- either
					IF (@tx_typ_space = 'system_mps')
					BEGIN
					  IF (@p_acc_type IN ('SYSTEMACCOUNT'))
						BEGIN
							-- MT_ACCOUNT_TYPE_AND_NAMESPACE_MISMATCH ((DWORD)0xE2FF0046L)
			  			SELECT @status = -486604732
							RETURN
						END
					END
				
					SELECT @status = 1
				END	
			 
			 