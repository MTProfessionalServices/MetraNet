
        create procedure AddBillManager (
        @managee  int,
        @manager int,
        @p_systemdate datetime,
        @p_enforce_same_corporation varchar,
        @status int OUTPUT)
        as
        begin
        declare @existing_manager int
        select @status = 0
        if (@managee = @manager)
        begin
        --MT_FOLDER_CANNOT_MANAGE_ITSELF
        select @status = 2
        return
        end
        begin
        select @existing_manager = id_manager  from t_bill_manager where id_acc = @managee and id_manager = @manager
        -- simply exit the stored procedure if the current manager is the desired
        if (@existing_manager = @manager)
        begin
        select @status = 1
        return
        end

        -- check that both the payer and Payee are in the same corporate account
        if @p_enforce_same_corporation = '1' AND dbo.IsInSameCorporateAccount(@manager,@managee,@p_systemdate) <> 1
        begin
        -- MT_CANNOT_MANAGE_FOLDER_IN_DIFFERENT_CORPORATE_ACCOUNT
        select @status = 3
        return
        end


        if (@status = 0)
        begin
        insert into t_bill_manager (id_manager,id_acc) values (@manager,@managee)
        select @status = 0
        end
        end
        end
      