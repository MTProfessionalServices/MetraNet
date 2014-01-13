
				CREATE PROCEDURE UpdateAccountState (
				  @id_acc int,
					@new_status varchar(2),
					@start_date datetime,
					@system_date datetime,
					@status int OUTPUT
					)
				AS
				BEGIN
					select @status = 0

					-- Set the maxdatetime into a variable
					declare @varMaxDateTime datetime
					declare @realstartdate datetime
					declare @realenddate datetime

					select @varMaxDateTime = dbo.MTMaxDate()

					select @realstartdate = dbo.mtstartofday(@start_date)
					select @realenddate = dbo.mtstartofday(@varMaxDateTime)

					exec CreateAccountStateRecord
					  @id_acc,
					  @new_status,
						@realstartdate,
						@realenddate,
						@system_date,
						@status output
				END
				