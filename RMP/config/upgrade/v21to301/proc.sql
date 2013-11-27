if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AddSecond]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[AddSecond]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DoesAccountHavePayees]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[DoesAccountHavePayees]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[EnclosedDateRange]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[EnclosedDateRange]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IsAccountBillable]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[IsAccountBillable]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IsAccountFolder]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[IsAccountFolder]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IsAccountPayingForOthers]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[IsAccountPayingForOthers]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IsActive]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[IsActive]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IsArchived]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[IsArchived]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IsClosed]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[IsClosed]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IsCorporateAccount]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[IsCorporateAccount]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IsInSameCorporateAccount]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[IsInSameCorporateAccount]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IsInVisableState]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[IsInVisableState]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IsPendingFinalBill]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[IsPendingFinalBill]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IsSuspended]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[IsSuspended]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[LookupAccount]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[LookupAccount]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MTComputeEffectiveBeginDate]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[MTComputeEffectiveBeginDate]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MTComputeEffectiveEndDate]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[MTComputeEffectiveEndDate]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MTDateInRange]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[MTDateInRange]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MTEndOfDay]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[MTEndOfDay]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MTMaxDate]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[MTMaxDate]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MTMaxOfTwoDates]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[MTMaxOfTwoDates]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MTMinDate]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[MTMinDate]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MTMinOfTwoDates]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[MTMinOfTwoDates]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MTRateScheduleScore]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[MTRateScheduleScore]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[NextDateAfterBillingCycle]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[NextDateAfterBillingCycle]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OverlappingDateRange]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[OverlappingDateRange]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[POContainsDiscount]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[POContainsDiscount]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[POContainsOnlyAbsoluteRates]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[POContainsOnlyAbsoluteRates]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SubtractSecond]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[SubtractSecond]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[checksubscriptionconflicts]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[checksubscriptionconflicts]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[mtconcat]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[mtconcat]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[mtstartofday]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[mtstartofday]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[poConstrainedCycleType]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[poConstrainedCycleType]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

				create function AddSecond(@RefDate datetime) returns datetime 
				as
				begin
				 return (dateadd(s,1,@RefDate))
				end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

				create function DoesAccountHavePayees(@id_acc int,@dt_ref datetime) 
				returns varchar
				as
        begin
				declare @returnValue char(1)
				SELECT @returnValue = CASE WHEN count(*) > 0 THEN 'Y' ELSE 'N' END
				FROM t_payment_redirection
				WHERE id_payer = @id_acc and
				((@dt_ref between vt_start and vt_end) OR @dt_ref < vt_start)
				if (@returnValue is null)
					begin
					select @returnValue = 'N'
					end
				return @returnValue
				end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

				create function EnclosedDateRange(@dt_start datetime,
	      @dt_end datetime,
  			@dt_checkstart datetime,
				@dt_checkend datetime) returns int
				as
				begin
        declare @test as int
				 -- check if the range specified by temp_dt_checkstart and
				 -- temp_dt_checkend is completely inside the range specified
				 -- by temp_dt_start, temp_dt_end
				if (@dt_checkstart >= @dt_start AND @dt_checkend <= @dt_end ) 
					begin
			    select @test=1
			    end
        else
					begin
          select @test=0
				  end
        return(@test)
        end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

				create function IsAccountBillable(@id_acc int) 
        returns varchar
		    as
        begin
	      declare @billableFlag as char(1)
		    select @billableFlag = c_billable  from t_av_internal where 
		    id_acc = @id_acc
		    if (@billableFlag is NULL) 
					begin
		      select @billableFlag = 'N'
          end  
		    return (@billableFlag)
		    end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

				create function IsAccountFolder(@id_acc int) 
				returns varchar
				as
				begin 
				declare @folderFlag char(1)
				select @folderFlag = c_folder  from t_av_internal where 
				id_acc = @id_acc
				if (@folderFlag is NULL)
					begin
					select @folderFlag = 'N'
					end  
				return @folderFlag
				end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

				create function IsAccountPayingForOthers(@id_acc int,@dt_ref datetime) 
				returns varchar
				as
        begin
				declare @returnValue char(1)
				SELECT @returnValue = CASE WHEN count(*) > 0 THEN 'Y' ELSE 'N' END
				FROM t_payment_redirection
				WHERE id_payer = @id_acc and
				-- this is the key difference between this and DoesAccountHavePayees
				id_payer <> id_payee and
				((@dt_ref between vt_start and vt_end) OR @dt_ref < vt_start)
				if (@returnValue is null)
					begin
					select @returnValue = 'N'
					end
				return @returnValue
				end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

                  create FUNCTION IsActive(@state varchar(2)) returns int
                  as
                  begin
                  declare @retval as int
	          if (@state = 'AC')
                        begin
		        select @retval = 1
                        end
	          else
                        begin
		        select @retval = 0
                        end 
	          return @retval
                  end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

             CREATE FUNCTION IsArchived(@state varchar(2)) returns integer
             as
             begin
             declare @retval int
	     if (@state = 'AR')
                 begin
		 select @retval = 1
                 end
	     else
                 begin
		 select @retval = 0
	     end 
             return @retval
             end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

             CREATE FUNCTION IsClosed(@state varchar(2)) returns int
             as
             begin
             declare @retval int
	     if (@state = 'CL')
                begin
	        select @retval = 1
                end
	     else
		begin
                select @retval = 0
	        end
             return @retval
             end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

		    create FUNCTION IsCorporateAccount(				@id_acc int,@RefDate Datetime) returns INT				as				begin				declare @retval int				 select @retval = id_descendent from t_account_ancestor 				 where         @RefDate between vt_start and vt_end AND				 id_ancestor = 1 AND id_descendent = @id_acc AND num_generations = 1				 if (@retval = @id_acc)				  begin					select @retval = 1					end          if (@retval is null)				  begin					select @retval = 0					end				return @retval				end
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create function IsInSameCorporateAccount(@acc1 int,@acc2 int,@refdate datetime) returns int
as
begin
declare @retval int
  select @retval =  
  case when parentcorporate.id_ancestor = desccorporate.id_ancestor then
    1 else 0 end
  from
  t_account_ancestor descendent
  INNER JOIN t_account_ancestor parent on parent.id_descendent = @acc2 AND
  parent.id_ancestor = 1 AND @refdate between parent.vt_start AND parent.vt_end
  INNER JOIN t_account_ancestor parentcorporate on parentcorporate.id_descendent = @acc2 AND
  @refdate between parentcorporate.vt_start AND parentcorporate.vt_end AND
  parentcorporate.num_generations = parent.num_generations - 1
  INNER JOIN t_account_ancestor desccorporate on desccorporate.id_descendent = @acc1 AND
  @refdate between desccorporate.vt_start AND desccorporate.vt_end AND
  desccorporate.num_generations = descendent.num_generations - 1
  where
  descendent.id_descendent = @acc1 AND
  @refdate between descendent.vt_start AND descendent.vt_end
  and descendent.id_ancestor = 1
	if @@error <> 0 OR @retval is NULL begin
		select @retval = 0
	end
	return @retval
end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

              CREATE FUNCTION IsInVisableState(@state varchar(2)) returns int
              as
              begin
              declare @retval int
           -- if the account is closed or archived
	      if (@state <> 'CL' AND @state <> 'AR')
                begin
		select @retval = 1
	        end
              else
		begin
                select @retval = 0
	        end 
	      return @retval        
              end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

            CREATE FUNCTION IsPendingFinalBill(@state varchar(2)) returns int
              as
              begin
              declare @retval int
	      if (@state = 'PF')
                  begin
		  select @retval = 1
	          end
              else
                  begin
                  select @retval = 0
        	  end
	      return @retval
              end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

                 CREATE FUNCTION IsSuspended(@state varchar(2)) returns int
                 as
                 begin
	         declare @retval int
                 if (@state = 'SU')
                     begin
	             select @retval = 1
                     end
	         else
		     begin
                     select @retval = 0
	             end 
	        return @retval
                end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

					create function LookupAccount(@login varchar(255),@namespace varchar(40)) 
					returns int
					as
					begin
					declare @retval as int
					select @retval = id_acc  from t_account_mapper 
					where nm_login = @login AND
					lower(@namespace) = nm_space
					if @retval is null
					  begin
						set @retval = -1
					  end
					return @retval
					end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

	create function MTComputeEffectiveBeginDate(@type as int, @offset as int, @base as datetime,  
	@sub_begin datetime, @id_usage_cycle int) returns datetime  
	as  
	begin  
	if (@type = 1)  
	begin  
	return @base  
	end  
	else if (@type = 2)  
	begin   
	return @sub_begin + @offset  
	end  
	else if (@type = 3)  
	begin  
	declare @next_interval_begin datetime  
	select @next_interval_begin = DATEADD(second, 1, dt_end) from t_pc_interval where @base between dt_start and dt_end and id_cycle = @id_usage_cycle  
	return @next_interval_begin  
	end  
	return null  
	end  

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

	create function MTComputeEffectiveEndDate(@type as int, @offset as int, @base as datetime,  
	@sub_begin datetime, @id_usage_cycle int) returns datetime  
	as  
	begin  
	if (@type = 1)  
	begin  
	return @base
	end  
	else if (@type = 2)  
	begin   
	return dbo.MTEndOfDay(@sub_begin + @offset)
	end  
	else if (@type = 3)  
	begin  
	declare @current_interval_end datetime  
	select @current_interval_end = dt_end from t_pc_interval where @base between dt_start and dt_end and id_cycle = @id_usage_cycle  
	return @current_interval_end
	end  
	return null
	end  

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

			create function MTDateInRange (
                                    @startdate datetime,
                                    @enddate datetime,
                                    @CompareDate datetime)
				returns int
			as
			begin
                                  declare @abc as int
                                  if @startdate <= @CompareDate AND @CompareDate < @enddate 
                                   begin
                                   select @abc = 1
                                   end 
                                else
                                   begin
                                   select @abc = 0
                                   end 
			   return @abc
                           end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

				create function MTEndOfDay(@indate as datetime) returns datetime
				as
				begin
					declare @retval as datetime
					set @retval =
						DATEADD(s,-1,
							DATEADD(d,1,	
								DATEADD(hh,-DATEPART(hh,@indate),
									DATEADD(mi,-DATEPART(mi,@indate),
										DATEADD(s,-DATEPART (s,@indate),@indate)
									)
								)
							)
						)
					return @retval
				end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

				create function MTMaxDate() returns datetime				as				begin					return '2038'				end
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

	-- Function returns the maximum of two dates.  A null date is considered
	-- to be infinitely small.
	create function MTMaxOfTwoDates(@chargeIntervalLeft datetime, @subIntervalLeft datetime) returns datetime
	as
	begin
	return case when @subIntervalLeft is null or @chargeIntervalLeft > @subIntervalLeft then @chargeIntervalLeft else @subIntervalLeft end
	end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

			create function MTMinDate() returns datetime			as			begin				return '1753'			end
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

	-- Function returns the minimum of two dates.  A null date is considered
	-- to be infinitely large.
	create function MTMinOfTwoDates(@chargeIntervalLeft datetime, @subIntervalLeft datetime) returns datetime
	begin
	return case when @subIntervalLeft is null or @chargeIntervalLeft < @subIntervalLeft then @chargeIntervalLeft else @subIntervalLeft end
	end		

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

	create function MTRateScheduleScore(@type as int, @begindate datetime) returns int  
	as  
	begin  
	declare @datescore int  
	set @datescore = case @type when 4 then 0 else datediff(s, '1970-01-01', isnull(@begindate, '1970-01-01')) end  
	declare @typescore int  
	set @typescore = case @type   
	when 2 then 2   
	when 4 then 0   
	else 1   
	end  
	return cast(@typescore as int) * 0x20000000 + (cast(@datescore as int) / 8)
	end 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

		create function NextDateAfterBillingCycle(@id_acc as int,@datecheck as datetime) returns datetime
		as
		begin
			return(
			select DATEADD(s,1,tpc.dt_end) from t_pc_interval tpc,t_acc_usage_cycle
			where t_acc_usage_cycle.id_acc = @id_acc AND
			tpc.id_cycle = t_acc_usage_cycle.id_usage_cycle AND
			tpc.dt_start <= @datecheck AND @datecheck <= tpc.dt_end
		)
		end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

		create function OverlappingDateRange(@dt_start as datetime,
		  @dt_end as datetime,
			@dt_checkstart as datetime,
			@dt_checkend as datetime) returns integer
			as begin
               if (@dt_start is not null and @dt_start > @dt_checkend) OR
               (@dt_checkstart is not null and @dt_checkstart > @dt_end)
               begin			   
               return (0)
               end
               return (1)
               end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

				create function POContainsDiscount				(@id_po int) returns int				as				begin				declare @retval int					select @retval = case when count(id_pi_template) > 0 then 1 else 0 end 					from t_pl_map 					INNER JOIN t_base_props tb on tb.id_prop = t_pl_map.id_pi_template					where t_pl_map.id_po = @id_po AND tb.n_kind = 40					return @retval				end
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

    create function POContainsOnlyAbsoluteRates(@id_po int) returns int
    as
    begin
    declare @retval as integer
	    select @retval = count(te.id_eff_date)
	    from
	    t_effectivedate te
	    INNER JOIN t_po on t_po.id_po = @id_po
	    INNER JOIN t_pl_map map on map.id_po = t_po.id_po AND id_paramtable is not NULL AND id_sub is NULL
	    LEFT OUTER JOIN t_rsched sched on sched.id_pt = map.id_paramtable AND sched.id_pricelist = map.id_pricelist
	    AND sched.id_pi_template = map.id_pi_template
	    where
	    te.id_eff_date = sched.id_eff_date AND
	    -- only absolute or NULL dates
	    (te.n_begintype in (2,3) OR te.n_endtype in (2,3))
	    if @retval > 0  begin
		    return 0
	    end
	    else begin
		    return 1
	    end
	    return 0
    end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

				create function SubtractSecond(@RefDate datetime) returns datetime 
				as
				begin
				 return (dateadd(s,-1,@RefDate))
				end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create function checksubscriptionconflicts (
@id_acc            INT,
@id_po             INT,
@real_begin_date   DATETIME,
@real_end_date     DATETIME,
@id_sub            INT
)
RETURNS INT
AS
begin
declare @status int
declare @cycle_type int
declare @po_cycle int
SELECT @status = COUNT (t_sub.id_sub)
FROM t_sub
WHERE t_sub.id_acc = @id_acc
 AND t_sub.id_po = @id_po
 AND t_sub.id_sub <> @id_sub
 AND dbo.overlappingdaterange (t_sub.vt_start,t_sub.vt_end,@real_begin_date,@real_end_date)= 1
IF (@status > 0)
	begin
 -- MTPCUSER_CONFLICTING_PO_SUBSCRIPTION
  RETURN (-289472485)
	END
select @status = dbo.overlappingdaterange(@real_begin_date,@real_end_date,te.dt_start,te.dt_end)
from t_po
INNER JOIN t_effectivedate te on te.id_eff_date = t_po.id_eff_date
where id_po = @id_po
if (@status <> 1)
	begin
	-- MTPCUSER_PRODUCTOFFERING_NOT_EFFECTIVE
	return (-289472472)
	end
SELECT @status = COUNT (id_pi_template)
	FROM t_pl_map
	WHERE t_pl_map.id_po = @id_po
	AND t_pl_map.id_pi_template IN
           (SELECT id_pi_template
              FROM t_pl_map
            WHERE id_po IN
                         (SELECT id_po
                            FROM t_vw_effective_subs subs
                            WHERE subs.id_sub <> @id_sub
                            AND subs.id_acc = @id_acc
                             AND dbo.overlappingdaterange (
                                    subs.dt_start,
                                    subs.dt_end,
                                    @real_begin_date,
                                    @real_end_date
                                 ) = 1))
IF (@status > 0)
	begin
	return (-289472484)
	END
RETURN (1)
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create function mtconcat(@str1 varchar(4000),@str2 varchar(4000)) returns varchar(4000)
as
begin
return @str1 + @str2
end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

  create FUNCTION mtstartofday (@indate datetime) 
  returns datetime
  as
    begin
    declare @retval as datetime
    select @retval =  DATEADD(hh,-DATEPART(hh,@indate),
    DATEADD(mi,-DATEPART(mi,@indate),
    DATEADD(s,-DATEPART (s,@indate),
		DATEADD(ms,-DATEPART(ms,@indate),@indate))))
    return @retval
  end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create function poConstrainedCycleType(@offeringID integer) returns integer
as
begin
	declare @retval as integer
  select @retval = (select max(result.id_cycle_type)
  from (
  select
  case when t_recur.id_cycle_type is NULL then
    case when t_discount.id_cycle_type IS NULL then
      t_aggregate.id_cycle_type else
      t_discount.id_cycle_type
    end
    else
    t_recur.id_cycle_type
    end
    as id_cycle_type
	FROM 
  t_pl_map
  LEFT OUTER JOIN t_recur on t_recur.id_prop = t_pl_map.id_pi_template
  LEFT OUTER JOIN t_discount on t_discount.id_prop = t_pl_map.id_pi_template
  LEFT OUTER JOIN t_aggregate on t_aggregate.id_prop = t_pl_map.id_pi_template
	WHERE
  t_pl_map.id_po = @offeringID
  ) result
	)
  if (@retval is NULL) begin
   	set @retval = 0
  end
return @retval
end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_vw_pilookup]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[t_vw_pilookup]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[T_VW_ACCTRES]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[T_VW_ACCTRES]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[T_VW_ACCTRES_BYID]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[T_VW_ACCTRES_BYID]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[T_VW_EFFECTIVE_SUBS]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[T_VW_EFFECTIVE_SUBS]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[T_VW_I_GSUBMEMBER]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[T_VW_I_GSUBMEMBER]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_vw_allrateschedules]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[t_vw_allrateschedules]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_vw_expanded_sub]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[t_vw_expanded_sub]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_vw_rc_arrears_fixed]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[t_vw_rc_arrears_fixed]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_vw_rc_arrears_relative]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[t_vw_rc_arrears_relative]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[T_VW_I_ACCTRES]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[T_VW_I_ACCTRES]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[T_VW_I_ACCTRES_BYID]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[T_VW_I_ACCTRES_BYID]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[VW_HIERARCHYNAME]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[VW_HIERARCHYNAME]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[VW_MPS_ACC_MAPPER]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[VW_MPS_ACC_MAPPER]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_vw_allrateschedules_pl]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[t_vw_allrateschedules_pl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_vw_allrateschedules_po]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[t_vw_allrateschedules_po]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[vw_mps_or_system_acc_mapper]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[vw_mps_or_system_acc_mapper]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[T_VW_I_ACC_MAPPER]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[T_VW_I_ACC_MAPPER]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_vw_base_props]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[t_vw_base_props]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW T_VW_I_ACC_MAPPER
(NM_LOGIN, NM_SPACE, ID_ACC, TX_DESC, NM_METHOD, TX_TYP_SPACE, NM_ENUM_DATA, ID_ENUM_DATA)
WITH SCHEMABINDING
AS SELECT
	amap.NM_LOGIN, amap.NM_SPACE, amap.ID_ACC,
	ns.TX_DESC, ns.NM_METHOD, ns.TX_TYP_SPACE,
	ed.NM_ENUM_DATA, ed.ID_ENUM_DATA
FROM dbo.t_account_mapper amap
INNER JOIN dbo.t_namespace ns on ns.nm_space = amap.nm_space 
	AND ns.tx_typ_space IN ('system_mps', 'system_user', 'system_auth')
INNER JOIN dbo.t_enum_data ed on ed.nm_enum_data = 'metratech.com/accountcreation/contacttype/bill-to'
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET ANSI_NULLS ON
GO
SET ANSI_PADDING ON
GO
SET ANSI_WARNINGS ON
GO
SET ARITHABORT ON
GO
SET CONCAT_NULL_YIELDS_NULL ON
GO
SET QUOTED_IDENTIFIER ON
GO 
SET NUMERIC_ROUNDABORT OFF 
GO
CREATE UNIQUE CLUSTERED INDEX IDX_T_VW_I_ACC_MAPPER_1 ON T_VW_I_ACC_MAPPER (TX_TYP_SPACE, NM_SPACE, NM_LOGIN)
CREATE INDEX IDX_T_VW_I_ACC_MAPPER_2 ON T_VW_I_ACC_MAPPER (id_acc, id_enum_data)
go
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view t_vw_base_props
as
select
td_name.id_lang_code, bp.id_prop, bp.n_kind, bp.n_name, bp.n_desc,
td_name.tx_desc as nm_name, td_desc.tx_desc as nm_desc, bp.b_approved, bp.b_archive,
bp.n_display_name, td_dispname.tx_desc as nm_display_name
	from t_base_props bp
	inner join t_description td_name on td_name.id_desc = bp.n_name
	inner join t_description td_desc on td_desc.id_desc = bp.n_desc and td_desc.id_lang_code = td_name.id_lang_code
	inner join t_description td_dispname on td_dispname.id_desc = bp.n_display_name and td_dispname.id_lang_code = td_name.id_lang_code

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW T_VW_I_ACCTRES
(ID_ACC, NM_LOGIN, NM_SPACE, ID_USAGE_CYCLE, C_PRICELIST, STATUS, STATE_START, STATE_END ) 
WITH SCHEMABINDING
AS SELECT 
	amap.id_acc, amap.nm_login, amap.nm_space, 
	auc.id_usage_cycle, avi.c_pricelist,
	ast.status, ast.vt_start, ast.vt_end
FROM dbo.t_account_mapper amap
INNER JOIN dbo.t_av_internal avi ON avi.id_acc = amap.id_acc
INNER JOIN dbo.t_acc_usage_cycle auc ON auc.id_acc = amap.id_acc
INNER JOIN dbo.t_account_state ast ON ast.id_acc = amap.id_acc
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET ANSI_NULLS ON
GO
SET ANSI_PADDING ON
GO
SET ANSI_WARNINGS ON
GO
SET ARITHABORT ON
GO
SET CONCAT_NULL_YIELDS_NULL ON
GO
SET QUOTED_IDENTIFIER ON
GO 
SET NUMERIC_ROUNDABORT OFF 
GO
CREATE UNIQUE CLUSTERED INDEX IDX_T_VW_I_ACCTRES_1 ON T_VW_I_ACCTRES (nm_login, nm_space, status, state_end)
CREATE INDEX IDX_T_VW_I_ACCTRES_2 ON T_VW_I_ACCTRES (id_acc)
go
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW T_VW_I_ACCTRES_BYID
(ID_ACC, ID_USAGE_CYCLE, C_PRICELIST, STATUS, STATE_START, STATE_END)
WITH SCHEMABINDING
AS SELECT 
	auc.id_acc, auc.id_usage_cycle, avi.c_pricelist,
	ast.status, ast.vt_start, ast.vt_end
FROM dbo.t_acc_usage_cycle auc
INNER JOIN dbo.t_av_internal avi ON avi.id_acc = auc.id_acc
INNER JOIN dbo.t_account_state ast ON ast.id_acc = auc.id_acc

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET ANSI_NULLS ON
GO
SET ANSI_PADDING ON
GO
SET ANSI_WARNINGS ON
GO
SET ARITHABORT ON
GO
SET CONCAT_NULL_YIELDS_NULL ON
GO
SET QUOTED_IDENTIFIER ON
GO 
SET NUMERIC_ROUNDABORT OFF 
GO
CREATE UNIQUE CLUSTERED INDEX IDX_T_VW_I_ACCTRES_BYID_1 ON T_VW_I_ACCTRES_BYID (id_acc, status, state_end)
go
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

					CREATE VIEW VW_HIERARCHYNAME (
						hierarchyname, id_acc )
						AS SELECT
						case when 
						tac.c_firstname is NULL or tac.c_lastname is NULL then 
						vwamap.nm_login
						else
						case when tac.c_firstname is null then
						tac.c_lastname
						else
						case when tac.c_lastname is null then
						tac.c_firstname
						else
						(tac.c_firstname + (' ' + tac.c_lastname))
						end
						end
						end as hierarchyname,
						vwamap.id_acc id_acc
						FROM T_VW_I_ACC_MAPPER vwamap with (noexpand)
						LEFT OUTER JOIN t_av_contact tac on tac.id_acc = vwamap.id_acc AND tac.c_contacttype = vwamap.id_enum_data
						WHERE vwamap.tx_typ_space = 'system_mps' 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

				create view VW_MPS_ACC_MAPPER as
        select
				mapper.nm_login,
				mapper.nm_space,
				mapper.id_acc,
				case when tac.id_acc is NULL then '' else
				  (c_firstname + (' ' + c_lastname)) end as fullname,
        case when tac.c_firstname is NULL and tac.c_lastname is NULL then 
          (mapper.nm_login + (' (' + (cast(mapper.id_acc as varchar(255)) + ')')))
        else
            case when tac.c_firstname is null then
              (tac.c_lastname + (' (' + (cast(mapper.id_acc as varchar(255)) + ')')))
            else
              case when tac.c_lastname is null then
                (tac.c_firstname + (' (' + (cast(mapper.id_acc as varchar(255)) + ')')))
              else
                ((tac.c_firstname + (' ' + tac.c_lastname)) + (' (' + (cast(mapper.id_acc as varchar(255)) + ')')))
              end
            end
        end as displayname,
        case when tac.c_firstname is NULL and tac.c_lastname is NULL then 
          mapper.nm_login
        else
          case when tac.c_firstname is null then
            tac.c_lastname
          else
            case when tac.c_lastname is null then
              tac.c_firstname
            else
              (tac.c_firstname + (' ' + tac.c_lastname))
            end
          end
        end as hierarchydisplayname
				FROM T_VW_I_ACC_MAPPER mapper with (noexpand)
				LEFT OUTER JOIN t_av_contact tac on tac.id_acc = mapper.id_acc AND
        tac.c_contacttype = mapper.id_enum_data
				WHERE mapper.tx_typ_space = 'system_mps'

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view t_vw_allrateschedules_pl
(
id_po, 
id_paramtable, 
id_pi_instance,
id_pi_template,
id_sub, 
id_sched,
dt_mod,
rs_begintype, 
rs_beginoffset, 
rs_beginbase,
rs_endtype, 
rs_endoffset, 
rs_endbase, 
id_pricelist)
with SCHEMABINDING
as
select 
null as id_po,
mapInner.id_pt as id_paramtable,
null as id_pi_instance,
templateInner.id_template as id_pi_template,
null as id_sub,
trInner.id_sched as id_sched,
trInner.dt_mod as dt_mod,
teInner.n_begintype as rs_begintype, 
teInner.n_beginoffset as rs_beginoffset,
teInner.dt_start as rs_beginbase, 
teInner.n_endtype as rs_endtype,
teInner.n_endoffset as rs_endoffset,
teInner.dt_end as rs_endbase,
trInner.id_pricelist as id_pricelist
from dbo.t_rsched trInner
INNER JOIN dbo.t_effectivedate teInner ON teInner.id_eff_date = trInner.id_eff_date
-- XXX fix this by passing in the instance ID
INNER JOIN dbo.t_pi_template templateInner on templateInner.id_template=trInner.id_pi_template
INNER JOIN dbo.t_pi_rulesetdef_map mapInner ON mapInner.id_pi = templateInner.id_pi and trInner.id_pt = mapInner.id_pt

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET ANSI_NULLS ON
GO
SET ANSI_PADDING ON
GO
SET ANSI_WARNINGS ON
GO
SET ARITHABORT ON
GO
SET CONCAT_NULL_YIELDS_NULL ON
GO
SET QUOTED_IDENTIFIER ON
GO 
SET NUMERIC_ROUNDABORT OFF 
GO
CREATE UNIQUE CLUSTERED INDEX idx_t_vw_allrateschedules_pl ON t_vw_allrateschedules_pl (id_sched)
create index idx_t_vw_allrateschedules_pl_param on t_vw_allrateschedules_pl (id_pi_template, id_paramtable, id_po)
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view t_vw_allrateschedules_po
(
id_po, 
id_paramtable, 
id_pi_instance,
id_pi_template,
id_sub, 
id_sched,
dt_mod,
rs_begintype, 
rs_beginoffset, 
rs_beginbase,
rs_endtype, 
rs_endoffset, 
rs_endbase, 
id_pricelist)
with SCHEMABINDING
as
select
tmInner.id_po as id_po,
tmInner.id_paramtable as id_paramtable,
tmInner.id_pi_instance as id_pi_instance,
tmInner.id_pi_template as id_pi_template,
tmInner.id_sub as id_sub,
rschedInner.id_sched as id_sched,
rschedInner.dt_mod as dt_mod,
teInner.n_begintype as rs_begintype, 
teInner.n_beginoffset as rs_beginoffset,
teInner.dt_start as rs_beginbase, 
teInner.n_endtype as rs_endtype,
teInner.n_endoffset as rs_endoffset,
teInner.dt_end as rs_endbase,
rschedInner.id_pricelist as id_pricelist
from
dbo.t_pl_map tmInner
INNER JOIN dbo.t_rsched rschedInner on 
	rschedInner.id_pricelist = tmInner.id_pricelist 
	AND rschedInner.id_pt =tmInner.id_paramtable 
	AND rschedInner.id_pi_template = tmInner.id_pi_template
INNER JOIN dbo.t_effectivedate teInner on teInner.id_eff_date = rschedInner.id_eff_date

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET ANSI_NULLS ON
GO
SET ANSI_PADDING ON
GO
SET ANSI_WARNINGS ON
GO
SET ARITHABORT ON
GO
SET CONCAT_NULL_YIELDS_NULL ON
GO
SET QUOTED_IDENTIFIER ON
GO 
SET NUMERIC_ROUNDABORT OFF 
GO
CREATE UNIQUE CLUSTERED INDEX idx_t_vw_allrateschedules_po ON t_vw_allrateschedules_po (id_sched, id_pi_instance)
create index idx_t_vw_allrateschedules_po_param on t_vw_allrateschedules_po (id_pi_template, id_paramtable, id_po)
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

				create view vw_mps_or_system_acc_mapper as
        select 
				mapper.nm_login,
				mapper.nm_space,
				mapper.id_acc,
				case when tac.id_acc is NULL then '' else
				  (c_firstname + (' ' + c_lastname)) end as fullname,
        case when tac.c_firstname is NULL and tac.c_lastname is NULL then 
           (mapper.nm_login + (' (' + (cast(mapper.id_acc as varchar(255)) + ')')))
        else
            case when tac.c_firstname is null then
              (tac.c_lastname + (' (' + (cast(mapper.id_acc as varchar(255)) + ')')))
            else
              case when tac.c_lastname is null then
                (tac.c_firstname + (' (' + (cast(mapper.id_acc as varchar(255)) + ')')))
              else
                ((tac.c_firstname + (' ' + tac.c_lastname)) + (' (' + (cast(mapper.id_acc as varchar(255)) + ')')))
              end
            end
        end as displayname,
        case when tac.c_firstname is NULL and tac.c_lastname is NULL then 
          mapper.nm_login
        else
          case when tac.c_firstname is null then
            tac.c_lastname
          else
            case when tac.c_lastname is null then
              tac.c_firstname
            else
             (tac.c_firstname + (' ' + tac.c_lastname))
            end
          end
        end as hierarchydisplayname
				from T_VW_I_ACC_MAPPER mapper with (noexpand)
				LEFT OUTER JOIN t_av_contact tac on tac.id_acc = mapper.id_acc AND
        tac.c_contacttype = mapper.id_enum_data

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW T_VW_ACCTRES
(ID_ACC, NM_LOGIN, NM_SPACE, ID_USAGE_CYCLE, C_PRICELIST, 
ID_PAYER, PAYER_START, PAYER_END, STATUS, STATE_START, STATE_END ) 
AS SELECT
	vwia.id_acc, vwia.nm_login, vwia.nm_space, vwia.id_usage_cycle, vwia.c_pricelist,
	redir.id_payer, 
	case when redir.vt_start is NULL then dbo.MTMinDate() else redir.vt_start end,
	case when redir.vt_end is NULL then dbo.MTMaxDate() else redir.vt_end end,
	vwia.status, vwia.state_start, vwia.state_end
FROM T_VW_I_ACCTRES vwia with (noexpand)
LEFT OUTER JOIN t_payment_redirection redir on redir.id_payee = vwia.id_acc

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW T_VW_ACCTRES_BYID ( ID_ACC, 
ID_USAGE_CYCLE, C_PRICELIST, ID_PAYER, PAYER_START, 
PAYER_END, STATUS, STATE_START, STATE_END ) 
AS SELECT
	vwiab.id_acc, vwiab.id_usage_cycle, vwiab.c_pricelist,
	case when redir.id_payer is NULL then vwiab.id_acc else redir.id_payer end,
	case when redir.vt_start is NULL then dbo.MTMinDate() else redir.vt_start end,
	case when redir.vt_end is NULL then dbo.MTMaxDate() else redir.vt_end end,
	vwiab.status, vwiab.state_start, vwiab.state_end
FROM T_VW_I_ACCTRES_BYID vwiab with (noexpand)
LEFT OUTER JOIN t_payment_redirection redir on redir.id_payee = vwiab.id_acc

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW T_VW_EFFECTIVE_SUBS ( ID_SUB, 
ID_ACC, ID_PO, DT_START, DT_END, 
DT_CRT ) AS  
select 
sub.id_sub, 
tgs.id_acc,
sub.id_po,
tgs.vt_start,
tgs.vt_end,
sub.dt_crt
from t_sub sub 
INNER JOIN t_gsubmember tgs on tgs.id_group = sub.id_group
UNION ALL
select 
sub.id_sub, 
sub.id_acc,
sub.id_po,
sub.vt_start,
sub.vt_end,
sub.dt_crt
from t_sub sub 
WHERE sub.id_group IS NULL

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW T_VW_I_GSUBMEMBER
(ID_GROUP, ID_ACC, VT_START, VT_END,
TX_NAME, TX_DESC, B_VISABLE, B_SUPPORTGROUPOPS, ID_USAGE_CYCLE, 
B_PROPORTIONAL, ID_CORPORATE_ACCOUNT, ID_DISCOUNTACCOUNT)
WITH SCHEMABINDING
AS SELECT
	gsm.ID_GROUP, gsm.ID_ACC, gsm.VT_START, gsm.VT_END,
	gs.TX_NAME, gs.TX_DESC, gs.B_VISABLE, gs.B_SUPPORTGROUPOPS, gs.ID_USAGE_CYCLE, 
	gs.B_PROPORTIONAL, gs.ID_CORPORATE_ACCOUNT, gs.ID_DISCOUNTACCOUNT
FROM dbo.t_group_sub gs
INNER JOIN dbo.t_gsubmember gsm on gsm.id_group = gs.id_group

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET ANSI_NULLS ON
GO
SET ANSI_PADDING ON
GO
SET ANSI_WARNINGS ON
GO
SET ARITHABORT ON
GO
SET CONCAT_NULL_YIELDS_NULL ON
GO
SET QUOTED_IDENTIFIER ON
GO 
SET NUMERIC_ROUNDABORT OFF 
GO
CREATE UNIQUE CLUSTERED INDEX IDX_T_VW_I_GSUBMEMBER_1 ON T_VW_I_GSUBMEMBER (id_group, id_acc,vt_start)
CREATE INDEX IDX_T_VW_I_GSUBMEMBER_2 ON T_VW_I_GSUBMEMBER (id_acc)
go
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view t_vw_allrateschedules
  as
  select * from t_vw_allrateschedules_po with (noexpand)
  UNION ALL
  select * from t_vw_allrateschedules_pl with (noexpand)

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW t_vw_expanded_sub
(
id_sub,
id_acc,
id_po,
vt_start,
vt_end,
dt_crt,
id_group,
id_group_cycle,
b_supportgroupops
)
AS 
SELECT
   sub.id_sub,
   CASE WHEN sub.id_group IS NULL THEN sub.id_acc ELSE mem.id_acc END id_acc,
   sub.id_po,
   CASE WHEN sub.id_group IS NULL THEN sub.vt_start ELSE mem.vt_start END vt_start,
   CASE WHEN sub.id_group IS NULL THEN sub.vt_end ELSE mem.vt_end END vt_end,
   sub.dt_crt,
   sub.id_group,
   gsub.id_usage_cycle,
   CASE WHEN sub.id_group IS NULL THEN 'N' ELSE gsub.b_supportgroupops END b_supportgroupops
FROM  
   t_sub sub
   LEFT OUTER JOIN t_group_sub gsub ON gsub.id_group = sub.id_group
   LEFT OUTER JOIN t_gsubmember mem ON mem.id_group = gsub.id_group

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW t_vw_rc_arrears_fixed
AS
-- Obtain the associated subscription period and recurring cycle
-- for each of the subscription recurring items 
SELECT 
	t_sub.id_po,
	t_pl_map.id_pi_instance,
	t_pl_map.id_pi_template,
	t_pl_map.id_paramtable,
	t_pl_map.id_pi_type,
	t_sub.id_acc,
	t_sub.vt_start sub_dt_start,
	t_sub.vt_end sub_dt_end,
	t_recur.id_usage_cycle recur_usage_cycle_id,
	t_recur.b_advance,
	t_recur.b_prorate_on_activate,
	t_recur.b_prorate_on_deactivate,
	t_recur.b_fixed_proration_length
FROM 
	t_pl_map,
	t_recur,
	t_sub
WHERE 
	t_pl_map.id_pi_instance = t_recur.id_prop and
	t_pl_map.id_po = t_sub.id_po

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE VIEW t_vw_rc_arrears_relative
AS
-- Obtain the associated subscription period, recurring cycle
-- and account usage cycle for each of the subscription recurring items
SELECT 
	t_sub.id_po,
	t_pl_map.id_pi_instance,
	t_pl_map.id_pi_template,
	t_pl_map.id_paramtable,
	t_pl_map.id_pi_type,
	t_sub.id_acc,
	t_sub.vt_start sub_dt_start,
	t_sub.vt_end sub_dt_end,
	t_recur.id_usage_cycle recur_usage_cycle_id,
	t_recur.b_advance,
	t_recur.b_prorate_on_activate,
	t_recur.b_prorate_on_deactivate,
	t_recur.b_fixed_proration_length,
	t_acc_usage_cycle.id_usage_cycle acc_usage_cycle_id
FROM 
	t_pl_map,
	t_recur,
	t_sub, 
	t_acc_usage_cycle
WHERE 
	t_pl_map.id_pi_instance = t_recur.id_prop AND
	t_pl_map.id_po = t_sub.id_po AND
	t_acc_usage_cycle.id_acc = t_sub.id_acc

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create view dbo.t_vw_pilookup
(
dt_start,
dt_end,
nm_name,
id_acc,
id_pi_template,
id_po,
id_pi_instance,
id_sub
)
as
select
sub.dt_start dt_start,
sub.dt_end dt_end,
base.nm_name,
sub.id_acc id_acc,
typemap.id_pi_template,
typemap.id_po,
typemap.id_pi_instance,
sub.id_sub
from
dbo.t_vw_effective_subs sub
 INNER JOIN dbo.t_pl_map typemap on typemap.id_po = sub.id_po AND
  typemap.id_po = sub.id_po and typemap.id_paramtable is null
 INNER JOIN dbo.t_base_props base on base.id_prop=typemap.id_pi_template

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AddAccToHierarchy]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AddAccToHierarchy]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AddAccountToGroupSub]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AddAccountToGroupSub]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AddCalendarHoliday]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AddCalendarHoliday]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AddCalendarPeriod]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AddCalendarPeriod]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AddCalendarWeekday]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AddCalendarWeekday]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AddCounterInstance]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AddCounterInstance]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AddCounterParam]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AddCounterParam]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AddCounterParamType]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AddCounterParamType]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AddCounterType]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AddCounterType]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AddICBMapping]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AddICBMapping]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AddMemberToRole]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AddMemberToRole]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AddNewSub]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AddNewSub]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AddOwnedFolder]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AddOwnedFolder]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AddnewAccount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AddnewAccount]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdjustGsubMemberDates]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdjustGsubMemberDates]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdjustSubDates]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdjustSubDates]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BulkSubscriptionChange]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[BulkSubscriptionChange]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CanBulkSubscribe]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CanBulkSubscribe]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CheckAccountStateDateRules]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CheckAccountStateDateRules]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CheckForNotArchivedDescendents]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CheckForNotArchivedDescendents]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CheckForNotClosedDescendents]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CheckForNotClosedDescendents]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CheckGroupSubBusinessRules]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CheckGroupSubBusinessRules]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CheckIfIntervalIsHardClosed]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CheckIfIntervalIsHardClosed]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CloneSecurityPolicy]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CloneSecurityPolicy]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CreateCounterPropDef]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CreateCounterPropDef]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CreateGroupSubscription]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CreateGroupSubscription]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CreatePaymentRecord]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CreatePaymentRecord]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DelPVRecordsForAcct]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DelPVRecordsForAcct]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DeleteBaseProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DeleteBaseProps]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DeleteCounterParamInstances]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DeleteCounterParamInstances]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DeleteCounterParamTypes]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DeleteCounterParamTypes]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DeleteDescription]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DeleteDescription]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DeleteProductViewRecords]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DeleteProductViewRecords]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ExecSpProcOnKind]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ExecSpProcOnKind]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ExtendedUpsert]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ExtendedUpsert]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetAggregateChargeProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetAggregateChargeProps]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetCalendarPropDefs]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetCalendarPropDefs]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetCounterParamTypeProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetCounterParamTypeProps]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetCounterPropDefs]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetCounterPropDefs]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetCounterProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetCounterProps]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetCounterTypeProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetCounterTypeProps]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetCurrentID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetCurrentID]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetDiscountProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetDiscountProps]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetEffProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetEffProps]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetLocalizedSiteInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetLocalizedSiteInfo]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetNonRecurProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetNonRecurProps]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetPCViewHierarchy]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetPCViewHierarchy]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetPLProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetPLProps]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetPOProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetPOProps]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetRateSchedules]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetRateSchedules]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetRecurProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetRecurProps]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetRuleSetDefProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetRuleSetDefProps]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetSchedProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetSchedProps]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetSubProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetSubProps]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetUsageProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetUsageProps]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GrantAllCapabilityToAccount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GrantAllCapabilityToAccount]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[InsertAcctToIntervalMapping]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[InsertAcctToIntervalMapping]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[InsertAcctUsageWithUID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[InsertAcctUsageWithUID]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[InsertAuditEvent]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[InsertAuditEvent]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[InsertBaseProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[InsertBaseProps]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[InsertDefaultTariff]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[InsertDefaultTariff]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[InsertEnumData]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[InsertEnumData]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[InsertInvoice]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[InsertInvoice]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[InsertRecurringEventRun]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[InsertRecurringEventRun]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[InsertUsageCycleInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[InsertUsageCycleInfo]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[InsertUsageIntervalInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[InsertUsageIntervalInfo]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IsAccBillableNPayingForOthers]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[IsAccBillableNPayingForOthers]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MTSP_RATE_AGGREGATE_CHARGE]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[MTSP_RATE_AGGREGATE_CHARGE]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MT_SYS_ANALYZE_ALL_TABLES]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[MT_SYS_ANALYZE_ALL_TABLES]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MoveAccount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[MoveAccount]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PIResolutionByID]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PIResolutionByID]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PIResolutionByName]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PIResolutionByName]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PropagateProperties]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PropagateProperties]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PurgeAuditTable]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PurgeAuditTable]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RemoveCounterInstance]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RemoveCounterInstance]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RemoveCounterPropDef]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RemoveCounterPropDef]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RemoveGroupSubMember]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RemoveGroupSubMember]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RemoveMemberFromRole]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RemoveMemberFromRole]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RemoveSubscription]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RemoveSubscription]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SetTariffs]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SetTariffs]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UndoAccounts]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UndoAccounts]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdStateFromClosedToArchived]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdStateFromClosedToArchived]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateAccount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateAccount]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateAccountState]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateAccountState]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateBaseProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateBaseProps]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateBatchStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateBatchStatus]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateCounterInstance]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateCounterInstance]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateCounterParamInstance]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateCounterParamInstance]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateCounterPropDef]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateCounterPropDef]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateGroupSubMembership]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateGroupSubMembership]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateGroupSubscription]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateGroupSubscription]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdatePaymentRecord]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdatePaymentRecord]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateStateFromClosedToPFB]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateStateFromClosedToPFB]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateStateFromPFBToClosed]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateStateFromPFBToClosed]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateStateRecordSet]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateStateRecordSet]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpsertDescription]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpsertDescription]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[addsubscriptionbase]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[addsubscriptionbase]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[copytemplate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[copytemplate]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[createboundaryintervals]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[createboundaryintervals]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[mtsp_insertinvoice]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[mtsp_insertinvoice]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_CreateEpSQL]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_CreateEpSQL]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_GenEpProcs]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_GenEpProcs]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_InsertAtomicCapType]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_InsertAtomicCapType]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_InsertBaseProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_InsertBaseProps]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_InsertCapabilityInstance]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_InsertCapabilityInstance]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_InsertCompositeCapType]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_InsertCompositeCapType]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_InsertPolicy]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_InsertPolicy]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_InsertRole]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_InsertRole]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[updatesub]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[updatesub]
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create  procedure
AddAccToHierarchy (@id_ancestor int,
@id_descendent int,
@dt_start  datetime,
@dt_end  datetime,
@p_acc_startdate datetime,
@status int OUTPUT)
as
begin
declare @realstartdate datetime
declare @realenddate datetime
declare @varMaxDateTime datetime
declare @bfolder varchar(1)
declare @descendentIDAsString varchar(50)
declare @ancestorStartDate as datetime
declare @realaccstartdate as datetime
select  @status = 0
-- begin business rules
-- check that the account is not already in the hierarchy
select @varMaxDateTime = dbo.MTMaxDate()
select @descendentIDAsString = CAST(@id_descendent as varchar(50)) 
  -- begin business rules
begin
if (@id_ancestor <> 1)
	begin
	SELECT @bfolder = c_folder 
	from
	t_av_internal where id_acc = @id_ancestor
	if @bfolder is null begin
		-- MT_PARENT_NOT_IN_HIERARCHY
		select @status = -486604771
		return
	end
-- MT_ACCOUNT_NOT_A_FOLDER (0xE2FF0001, -486604799)
-- specified parent account is not marked a folder.
	if (@bfolder = 'N')
		begin 
		select @status = -486604799
		return
		end 
end 
	if @p_acc_startdate is NULL begin
		select @realaccstartdate = dt_crt from t_account where id_acc = @id_descendent
	end
	else begin
		select @realaccstartdate = @p_acc_startdate
	end
	select @ancestorStartDate = dt_crt
	from t_account where id_acc = @id_ancestor
	if  dbo.mtstartofday(@realaccstartdate) < dbo.mtstartofday(@ancestorStartDate) begin
		-- MT_CANNOT_CREATE_ACCOUNT_BEFORE_ANCESTOR_START
		select @status = -486604746
		return
	end 
select top 1 @status = id_descendent  from t_account_ancestor
where id_descendent = @id_descendent and
dbo.overlappingdaterange(vt_start,vt_end,@dt_start,@dt_end) = 1 
-- make sure we only get one row back
if (@status = @id_descendent) 
 begin
 -- MT_ACCOUNT_ALREADY_IN_HIEARCHY
 select @status = -486604785
 return
 end 
if (@status is null) 
 begin
 select @status = 0
 return
 end
end
select @realstartdate = dbo.MTStartOfDay(@dt_start)  
if (@dt_end is NULL) 
begin
 select @realenddate = dbo.MTStartOfDay(dbo.mtmaxdate())  
 end
else
 begin
 select @realenddate = dbo.mtstartofday(@dt_end)  
 end 
-- end business rules
-- error handling cases: 
-- Is the parent account a folder
-- does the ancestor exist in the effective date range
-- is the account already in the hierarchy at a given time
-- XXX we need error handling code to detect when the ancestor does 
-- not exist at the time interval!!
-- populate t_account_ancestor (no bitemporal data)
insert into t_account_ancestor (id_ancestor,id_descendent,
num_generations,vt_start,vt_end,tx_path)
select id_ancestor,@id_descendent,num_generations + 1,vt_start,vt_end,
case when id_descendent = 1 then
tx_path + @descendentIDAsString
else
tx_path + '/' + @descendentIDAsString
end 
from t_account_ancestor
where
id_descendent = @id_ancestor AND id_ancestor <> id_descendent  AND
dbo.OverlappingDateRange(vt_start,vt_end,@realstartdate,@realenddate) = 1
UNION ALL
-- the new record to parent.  Note that the 
select @id_ancestor,@id_descendent,1,@realstartdate,@realenddate,
case when id_descendent = 1 then
tx_path + @descendentIDAsString
else
tx_path + '/' + @descendentIDAsString
end
from
t_account_ancestor where id_descendent = @id_ancestor AND num_generations = 0
AND dbo.OverlappingDateRange(vt_start,vt_end,@realstartdate,@realenddate) = 1
	-- self pointer
UNION ALL 
select @id_descendent,@id_descendent,0,@realstartdate,@realenddate,@descendentIDAsString
 -- update our parent entry to have children
update t_account_ancestor set b_Children = 'Y' where
id_descendent = @id_ancestor AND
dbo.OverlappingDateRange(vt_start,vt_end,@realstartdate,@realenddate) = 1
if (@@error <> 0) 
 begin
 select @status = 0
 end
select @status = 1  
end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create procedure AddAccountToGroupSub(
	@p_id_sub int,
	@p_id_group int,
	@p_id_po int,
	@p_id_acc int,
@p_startdate datetime,
	@p_enddate datetime,
	@p_systemdate datetime,
	@p_status int OUTPUT,
	@p_datemodified varchar output)
as
begin
declare @existingID as int
declare @real_enddate as datetime
declare @real_startdate datetime
	select @p_status = 0
	-- step : if the end date is null get the max date
	-- XXX this is broken if the end date of the group subscription is not max date
	if (@p_enddate is null)
		begin
		select @real_enddate = dbo.MTMaxDate()
		end
	else
		begin
		if @p_startdate > @p_enddate begin
			-- MT_GROUPSUB_STARTDATE_AFTER_ENDDATE
			select @p_status = -486604782
			select @p_datemodified = 'N'
			return
		end
		select @real_enddate = @p_enddate
		end 
	select @real_startdate = dbo.mtmaxoftwodates(@p_startdate,t_sub.vt_start),
	@real_enddate = dbo.mtminoftwodates(@real_enddate,t_sub.vt_end) 
	from 
	t_sub where id_sub = @p_id_sub
	if (@real_startdate <> @p_startdate OR
	(@real_enddate <> @p_enddate AND @real_enddate <> dbo.mtmaxdate()))
		begin
			select @p_datemodified = 'Y'
		end
		else
		begin
			select @p_datemodified = 'N'
		end
	begin
	-- step : check that account is not already part of the group subscription
	-- in the specified date range
		select @existingID = id_acc from t_gsubmember where
	-- check againt the account
		id_acc = @p_id_acc AND id_group = @p_id_group
	-- make sure that the specified date range does not conflict with 
	-- an existing range
		AND dbo.overlappingdaterange(vt_start,vt_end,
		@real_startdate,@real_enddate) = 1
		if (@existingID = @p_id_acc)
			begin
			-- MT_ACCOUNT_ALREADY_IN_GROUP_SUBSCRIPTION 
			select @p_status = -486604790
			return
			end 
		if (@existingID is null)
			begin
			select @p_status = 0 
			end
	end
		-- step : verify that the date range is inside that of the group subscription
		begin
			select @p_status = dbo.encloseddaterange(vt_start,vt_end,@real_startdate,@real_enddate)  
			from t_sub where id_group = @p_id_group
			if (@p_status <> 1 ) 
			begin
			-- MT_GSUB_DATERANGE_NOT_IN_SUB_RANGE
			select @p_status = -486604789
			return
			end 
		if (@p_status is null) 
			begin
			-- MT_GROUP_SUBSCRIPTION_DOES_NOT_EXIST
			select @p_status = -486604788
			return 
		end
		end
		-- step : check that the account does not have any conflicting subscriptions
		-- note: checksubscriptionconflicts return 0 on success while the other
		-- functions return 1.  This should be fixed (CS 2-1-2001)
		select @p_status = dbo.checksubscriptionconflicts(@p_id_acc,@p_id_po,
		@real_startdate, @real_enddate,@p_id_sub) 
		if (@p_status <> 1 ) 
			begin
			 return
			end 
		 -- make sure that the member is in the corporate account specified in 
		 -- the group subscription
		select @p_status = count(num_generations) from 
		t_account_ancestor ancestor
		INNER JOIN t_group_sub tg on tg.id_group = @p_id_group
		where ancestor.id_ancestor = tg.id_corporate_account AND
		ancestor.id_descendent = @p_id_acc AND
		@real_startdate between ancestor.vt_start AND ancestor.vt_end
		if (@p_status = 0 )
			begin
			-- MT_ACCOUNT_NOT_IN_GSUB_CORPORATE_ACCOUNT
			select @p_status = -486604769
			return
			end 
		-- end business rule checks
	exec CreateGSubmemberRecord @p_id_group,@p_id_acc,@real_startdate,@real_enddate,@p_systemdate,@p_status OUTPUT
end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

		 create proc AddCalendarHoliday
			@id_calendar int,
			@n_code int,
			@nm_name NVARCHAR(255),
			@n_day int,
			@n_weekday int,
			@n_weekofmonth int,
			@n_month int,
			@n_year int,
			@id_day int OUTPUT
			as
			begin tran
				insert into t_calendar_day (id_calendar, n_weekday, n_code)
					values (@id_calendar, @n_weekday, @n_code)
				select @id_day = @@IDENTITY
				insert into t_calendar_holiday (id_day, nm_name, n_day, n_weekofmonth, n_month, n_year)
					values (@id_day, @nm_name, @n_day, @n_weekofmonth, @n_month, @n_year)
			commit tran

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

		 create proc AddCalendarPeriod
			@id_day int,
			@n_begin int,
			@n_end int,
			@n_code int,
			@id_period int OUTPUT
			as
			begin tran
				insert into t_calendar_periods (id_day, n_begin, n_end, n_code)
					values (@id_day, @n_begin, @n_end, @n_code)
				select @id_period = @@IDENTITY
			commit tran

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

		 create proc AddCalendarWeekday
			@id_calendar int,
			@n_weekday int,
			@n_code int,
			@id_day int OUTPUT
			as
				begin tran
					insert into t_calendar_day (id_calendar, n_weekday, n_code)
						values (@id_calendar, @n_weekday, @n_code)
					select @id_day = @@IDENTITY
				commit tran

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

					create proc AddCounterInstance					            @id_lang_code int,											@n_kind int,											@nm_name varchar(255),											@nm_desc varchar(255),											@counter_type_id int, 											@id_prop int OUTPUT 					as					begin						DECLARE @identity_value int						exec InsertBaseProps @id_lang_code, @n_kind, 'N', 'N', @nm_name, @nm_desc, null, @identity_value output						SELECT @identity_value = @@identity					INSERT INTO t_counter (id_prop, id_counter_type) values (@@identity, @counter_type_id)					SELECT 						@id_prop = @identity_value					end
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

			create proc AddCounterParam									@id_counter int,									@id_counter_param_type int,									@nm_counter_value varchar(255),									@identity int OUTPUT			AS			BEGIN TRAN			INSERT INTO t_counter_params 				(id_counter, id_counter_param_meta, Value) 			VALUES 				(@id_counter, @id_counter_param_type, @nm_counter_value)			SELECT 				@identity = @@identity			COMMIT TRAN
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

						CREATE PROC AddCounterParamType												@id_lang_code int,									@n_kind int,									@nm_name varchar(255),									@id_counter_type int,									@nm_param_type varchar(255),									@nm_param_dbtype varchar(255),									@id_prop int OUTPUT 			      AS			      DECLARE @identity_value int			      BEGIN TRAN			      exec InsertBaseProps @id_lang_code, @n_kind, 'N', 'N', @nm_name, NULL, NULL, @identity_value output			      INSERT INTO t_counter_params_metadata					              (id_prop, id_counter_meta, ParamType, DBType) 				    VALUES 					              (@identity_value, @id_counter_type, @nm_param_type, @nm_param_dbtype)            select @id_prop = @identity_value      			COMMIT TRAN
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

				create proc AddCounterType
					  		  @id_lang_code int,
									@n_kind int,
									@nm_name varchar(255),
									@nm_desc varchar(255),
									@nm_formula_template varchar(1000),
									@valid_for_dist char(1),
									@id_prop int OUTPUT 
			AS
	    begin
			declare @t_count int	
			declare @temp_nm_name varchar(255)
			declare @temp_id_lang_code int
			declare @identity_value int
			declare @t_base_props_count INT
			select @id_prop = -1
      select @temp_nm_name = @nm_name
			select @temp_id_lang_code = @id_lang_code
      SELECT @t_base_props_count = COUNT(*) FROM T_BASE_PROPS				
      WHERE T_BASE_PROPS.nm_name = @nm_name
			SELECT @t_count = COUNT(*) FROM t_vw_base_props
				WHERE t_vw_base_props.nm_name = @temp_nm_name and t_vw_base_props.id_lang_code = @temp_id_lang_code
      IF (@t_base_props_count <> 0)
				begin	
 				select @id_prop = -1
				end			
			IF (@t_count = 0)
			  begin
				exec InsertBaseProps @id_lang_code, @n_kind, 'N', 'N', @nm_name, @nm_desc, null, @identity_value OUTPUT
		    INSERT INTO t_counter_metadata (id_prop, FormulaTemplate, b_valid_for_dist) values (@identity_value, 
				    @nm_formula_template, @valid_for_dist)
				select @id_prop = @identity_value
			  end
       end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

			create proc AddICBMapping(@id_paramtable as int,					@id_pi_instance as int,					@id_sub as int,					@id_acc as int,					@id_po as int,          @p_systemdate as datetime)				as						declare @id_pi_type as int					declare @id_pricelist as int					declare @id_pi_template as int					declare @id_pi_instance_parent as int					declare @currency as varchar(10)					select @id_pi_type = id_pi_type,@id_pi_template = id_pi_template,					@id_pi_instance_parent = id_pi_instance_parent					from					t_pl_map where id_pi_instance = @id_pi_instance AND id_paramtable is NULL					set @currency = (select c_currency from t_av_internal where id_acc = @id_acc)					insert into t_base_props (n_kind,n_name,n_display_name,n_desc) values (150,0,0,0)					set @id_pricelist = @@identity					insert into t_pricelist values (@id_pricelist,'N',@currency)					insert into t_pl_map(              id_paramtable,              id_pi_type,              id_pi_instance,              id_pi_template,              id_pi_instance_parent,              id_sub,              id_po,              id_pricelist,              b_canICB,              dt_modified              )					values(              @id_paramtable,              @id_pi_type,                            @id_pi_instance,              @id_pi_template,              @id_pi_instance_parent,              @id_sub,              @id_po,              @id_pricelist,              'N',              @p_systemdate              )
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

						CREATE PROCEDURE AddMemberToRole
						(@aRoleID INT,
						 @aAccountID INT,
						 @status INT OUTPUT)		
						AS
						Begin
						declare @accType VARCHAR(3)
						declare @polID INT
						declare @bCSRAssignableFlag VARCHAR(1)
						declare @bSubscriberAssignableFlag VARCHAR(1)
						declare @scratch INT
						select @status = 0
						-- evaluate business rules: role has to
						-- be assignable to the account type
						-- returned errors: MTAUTH_ROLE_CAN_NOT_BE_ASSIGNED_TO_SUBSCRIBER ((DWORD)0xE29F001CL) (-492896228)
						--                  MTAUTH_ROLE_CAN_NOT_BE_ASSIGNED_TO_CSR ((DWORD)0xE29F001DL) (-492896227)
						SELECT @accType = acc_type FROM T_ACCOUNT WHERE id_acc = @aAccountID
						SELECT @bCSRAssignableFlag = csr_assignable, 
						@bSubscriberAssignableFlag = subscriber_assignable  
						FROM T_ROLE WHERE id_role = @aRoleID
						IF (UPPER(@accType) = 'SUB' OR UPPER(@accType) = 'IND') 
						begin
						IF (UPPER(@bSubscriberAssignableFlag) = 'N')
							begin
      				  select @status = -492896228
							  RETURN
							END
            END
						ELSE
						  begin
							IF UPPER(@bCSRAssignableFlag) = 'N' 
								begin
								select @status = -492896227
								RETURN
								END
							END
						--Get policy id for this account. sp_InsertPolicy will either
						--insert a new one or get existing one
						exec Sp_Insertpolicy 'id_acc', @aAccountID,'A', @polID output
						-- make the stored proc idempotent, only insert mapping record if
						-- it's not already there
						begin
							SELECT @scratch = id_policy FROM T_POLICY_ROLE WHERE id_policy = @polID AND id_role = @aRoleID
							if @scratch is null
								begin
								INSERT INTO T_POLICY_ROLE (id_policy, id_role) VALUES (@polID, @aRoleID)
								end
						end
						select @status = 1
						END 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create procedure AddNewSub(
 @p_id_acc int, 
 @p_dt_start datetime,
 @p_dt_end datetime,
 @p_NextCycleAfterStartDate varchar,
 @p_NextCycleAfterEndDate varchar,
 @p_id_po int,
 @p_GUID varbinary(16),
 @p_systemdate datetime,
 @p_id_sub int OUTPUT,
 @p_status int output)
as
begin
declare @real_begin_date as datetime
declare @real_end_date as datetime
declare @po_effstartdate as datetime
declare @varMaxDateTime datetime
declare @datemodified varchar(1)
select @varMaxDateTime = dbo.MTMaxDate()
	select @p_status =0
-- compute usage cycle dates if necessary
if (upper(@p_NextCycleAfterStartDate) = 'Y')
 begin
 select @real_begin_date = dbo.NextDateAfterBillingCycle(@p_id_acc,@p_dt_start)
 end
else
 begin
   select @real_begin_date = @p_dt_start
 end 
if (upper(@p_NextCycleAfterEndDate) = 'Y' AND @p_dt_end is not NULL)
 begin
 select @real_end_date = dbo.NextDateAfterBillingCycle(@p_id_acc,@p_dt_end)
   end
else
 begin
 select @real_end_date = @p_dt_end
 end
if (@p_dt_end is NULL)
 begin
 select @real_end_date = @varMaxDateTime
 end
exec AddSubscriptionBase @p_id_acc,NULL,@p_id_po,@real_begin_date,@real_end_date,@p_GUID,@p_systemdate,@p_id_sub output,
@p_status output,@datemodified output
end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create procedure AddOwnedFolder(
@owner  int,
@folder int,
@p_systemdate datetime,
@existing_owner int OUTPUT,
@status int OUTPUT)
as
begin
	declare @bFolder char
	select @status = 0 
	if (@owner = @folder) 
		begin
		--MT_FOLDER_CANNOT_OWN_ITSELF
		select status = -486604761
		return
		end
	begin
	select @existing_owner = id_owner  from t_impersonate where	id_acc = @folder
	if (@existing_owner is null)
		begin
		select @existing_owner = 0
		end
	end
	if (@existing_owner <> 0 and @existing_owner <> @owner)
		begin
		-- the folder is already owned by another account
		-- MT_EXISTING_FOLDER_OWNER
		select @status = -486604779
		RETURN
		END 
	-- simply exit the stored procedure if the current owner is the owner
	if (@existing_owner = @owner) 
		begin
		select @status = 1
		return
		end
	-- Check first to see if its a folder
	-- return MT_ACCOUNT_NOT_A_FOLDER
	if (dbo.IsAccountFolder(@folder) = 'N')
		begin
		select @status = -486604799
		return
		end 
	if (@bFolder = 'N') 
		begin
		select @status = -486604778
		RETURN
		end 
		-- check that both the payer and Payee are in the same corporate account
		if dbo.IsInSameCorporateAccount(@owner,@folder,@p_systemdate) <> 1 begin
			-- MT_CANNOT_OWN_FOLDER_IN_DIFFERENT_CORPORATE_ACCOUNT
			select @status = -486604751
			return
		end
	if (@existing_owner = 0) 
		begin
		insert into t_impersonate (id_owner,id_acc) values (@owner,@folder)
		select @status = 0
		end
	select @status = 1
end 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create procedure AddnewAccount(
@p_id_acc_ext  varchar(16),
@p_acc_state  varchar(2),
@p_acc_status_ext  int,
@p_acc_vtstart  datetime,
@p_acc_vtend  datetime,
@p_nm_login  varchar(255),
@p_nm_space varchar(40),
@p_tx_password  varchar(64),
@p_langcode  varchar(10),
@p_profile_timezone  int,
@p_ID_CYCLE_TYPE  int,
@p_DAY_OF_MONTH  int,
@p_DAY_OF_WEEK  int,
@p_FIRST_DAY_OF_MONTH  int,
@p_SECOND_DAY_OF_MONTH int,
@p_START_DAY int,
@p_START_MONTH int,
@p_START_YEAR int,
@p_billable varchar,
@p_id_payer int,
@p_payer_startdate datetime,
@p_payer_enddate datetime,
@p_payer_login varchar(255),
@p_payer_namespace varchar(40),
@p_id_ancestor int,
@p_hierarchy_start datetime,
@p_hierarchy_end datetime,
@p_ancestor_name varchar(255),
@p_ancestor_namespace varchar(40),
@p_acc_type varchar(3),
@p_apply_default_policy varchar,
@p_systemdate datetime,
@accountID int OUTPUT,
@status  int OUTPUT,
@p_hierarchy_path varchar(4000) output,
@p_currency varchar(10) OUTPUT
)
as
	declare @existing_account as int
	declare @profileID as int
	declare @intervalID as int
	declare @intervalstart as datetime
	declare @intervalend as datetime
	declare @usagecycleID as int
	declare @acc_startdate as datetime
	declare @acc_enddate as datetime
	declare @payer_startdate as datetime
	declare @payer_enddate as datetime
	declare @ancestor_startdate as datetime
	declare @ancestor_enddate as datetime
	declare @payerID as int
	declare @ancestorID as int
	declare @siteID as int
	declare @folderName varchar(255)
	declare @varMaxDateTime as datetime
	declare @IsNotSubscriber int
	declare @payerbillable as varchar(1)
	declare @authancestor as int
	-- step : validate that the account does not already exist.  Note 
	-- that this check is performed by checking the t_account_mapper table.
	-- However, we don't check the account state so the new account could
	-- conflict with an account that is an archived state.  You would need
	-- to purge the archived account before the new account could be created.
	select @varMaxDateTime = dbo.MTMaxDate()
	select @existing_account = dbo.LookupAccount(@p_nm_login,@p_nm_space) 
	if (@existing_account <> -1) begin
	-- ACCOUNTMAPPER_ERR_ALREADY_EXISTS
	select @status = -501284862
	return
	end 
	-- step : populate the account start dates if the values were
	-- not passed into the sproc
	select 
	@acc_startdate = case when @p_acc_vtstart is NULL then dbo.mtstartofday(@p_systemdate) 
		else dbo.mtstartofday(@p_acc_vtstart) end,
	@acc_enddate = case when @p_acc_vtend is NULL then @varMaxDateTime 
		else dbo.mtstartofday(@p_acc_vtend) end
	-- step : populate t_account
	if (@p_id_acc_ext is null) begin
		insert into t_account(id_acc_ext,dt_crt,acc_type)
		select newid(),@acc_startdate,@p_acc_type 
	end
	else begin
		insert into t_account(id_Acc_ext,dt_crt,acc_type)
		select convert(varbinary(16),@p_id_acc_ext),@acc_startdate,@p_acc_type 
	end 
	-- step : get the account ID
	select @accountID = @@identity
	-- step : initial account state
	insert into t_account_state values (@accountID,
	@p_acc_state /*,p_acc_status_ext*/,
	@acc_startdate,@acc_enddate)
	insert into t_account_state_history values (@accountID,
	@p_acc_state /*,p_acc_status_ext*/,
	@acc_startdate,@acc_enddate,@p_systemdate,@varMaxDateTime)
	-- step : login and namespace information
	insert into t_account_mapper values (@p_nm_login,lower(@p_nm_space),@accountID)
	-- step : user credentials
	insert into t_user_credentials values (@p_nm_login,lower(@p_nm_space),@p_tx_password)
	-- step : get the profile id.  This step seems kind of superfluous on oracle			
	insert into t_mt_id default values
		select  @profileID = @@identity
	-- step : t_profile. This looks like it is only for timezone information
	insert into t_profile values (@profileID,'timeZoneID',@p_profile_timezone,'System')
	-- step : site user information
	exec GetlocalizedSiteInfo @p_nm_space,@p_langcode,@siteID OUTPUT
	insert into t_site_user values (@p_nm_login,@siteID,@profileID)
	-- step : get the cycle ID
	select @usagecycleID = id_usage_cycle 
	 from t_usage_cycle cycle where
	 cycle.id_cycle_type = @p_ID_CYCLE_TYPE 
	 AND (@p_DAY_OF_MONTH = cycle.day_of_month or @p_DAY_OF_MONTH is NULL)
	 AND (@p_DAY_OF_WEEK = cycle.day_of_week or @p_DAY_OF_WEEK is NULL)
	 AND (@p_FIRST_DAY_OF_MONTH= cycle.FIRST_DAY_OF_MONTH  or @p_FIRST_DAY_OF_MONTH is NULL)
	 AND (@p_SECOND_DAY_OF_MONTH = cycle.SECOND_DAY_OF_MONTH or @p_SECOND_DAY_OF_MONTH is NULL)
	 AND (@p_START_DAY= cycle.START_DAY or @p_START_DAY is NULL)
	 AND (@p_START_MONTH= cycle.START_MONTH or @p_START_MONTH is NULL)
	 AND (@p_START_YEAR = cycle.START_YEAR or @p_START_YEAR is NULL)
		-- step : add the account to usage cycle mapping
	insert into t_acc_usage_cycle values (@accountID,@usagecycleID)
	-- step : find the interval ID.
	-- XXX: is this the correct date 
	select 
		@intervalID=id_interval,@intervalstart=dt_start,@intervalend=dt_end
	from t_pc_interval where
	id_cycle = @usagecycleID AND
	@p_systemdate between dt_start AND dt_end
	-- populate the usage interval if necessary
	insert into t_usage_interval(id_interval,id_usage_cycle,
		dt_start,dt_end,tx_interval_status)
	select
		@intervalID,@usagecycleID,@intervalstart,@intervalend,'N'
	where @intervalID not in (select id_interval from t_usage_interval)
	-- populate account to usage interval mapping
	insert into t_acc_usage_interval (id_acc,id_usage_interval,
		tx_status) values (@accountID,@intervalID,'O')  
	exec CreateBoundaryIntervals @usagecycleID,@p_ID_CYCLE_TYPE,
	@intervalstart,@intervalend,@p_systemdate
	-- Non-billable accounts must have a payment redirection record
	if ( @p_billable = 'N' AND 
	(@p_id_payer is NULL and
	(@p_id_payer is null AND @p_payer_login is NULL AND @p_payer_namespace is NULL))) begin
	-- MT_NONBILLABLE_ACCOUNTS_REQUIRE_PAYER
		select @status = -486604768
		return
	end
	-- default the payer start date to the start of the account  
	select @payer_startdate = case when @p_payer_startdate is NULL then @acc_startdate else dbo.mtstartofday(@p_payer_startdate) end,
	 -- default the payer end date to the end of the account if NULL
	@payer_enddate = case when @p_payer_enddate is NULL then @acc_enddate else dbo.mtstartofday(@p_payer_enddate) end,
	-- step : default the hierarchy start date to the account start date 
	@ancestor_startdate = case when @p_hierarchy_start is NULL then @acc_startdate else @p_hierarchy_start end,
	-- step : default the hierarchy end date to the account end date
	@ancestor_enddate = case when @p_hierarchy_end is NULL then @acc_enddate else @p_hierarchy_end end,
	-- step : resolve the ancestor ID if necessary
	@ancestorID = case when @p_ancestor_name is not NULL and @p_ancestor_namespace is not NULL then
		dbo.LookupAccount(@p_ancestor_name,@p_ancestor_namespace)  else 
		-- if the ancestor ID iis NULL then default to the root
		case when @p_id_ancestor is NULL then 1 else @p_id_ancestor end
	end,
	-- step : resolve the payer account if necessary
	@payerID = case when 	@p_payer_login is not null and @p_payer_namespace is not null then
		 dbo.LookupAccount(@p_payer_login,@p_payer_namespace) else 
			case when @p_id_payer is NULL then @accountID else @p_id_payer end end
	if (@payerID = -1) 	begin
		-- MT_CANNOT_RESOLVE_PAYING_ACCOUNT
		select @status = -486604792
		return
	end
	if (@ancestorID = -1) begin
		-- MT_CANNOT_RESOLVE_HIERARCHY_ACCOUNT
		select @status = -486604791
		return
	end 
	if (UPPER(@p_acc_type) <> 'SUB') begin
		select @IsNotSubscriber = 1
	end 
	-- we trust AddAccToHIerarchy to set the status to 1 in case of success
	exec AddAccToHierarchy @ancestorID,@accountID,@ancestor_startdate,
	@ancestor_enddate,@acc_startdate,@status output
	if (@status <> 1)begin 
		return
	end 
	-- pass in the current account's billable flag when creating the payment 
	-- redirection record IF the account is paying for itself
	select @payerbillable = case when @payerID = @accountID then
		@p_billable else NULL end
	exec CreatePaymentRecord @payerID,@accountID,
	@payer_startdate,@payer_enddate,@payerbillable,@p_systemdate,'N',@status OUTPUT
	if (@status <> 1) begin
		return
	end   
	-- if "Apply Default Policy" flag is set, then
	-- figure out "ancestor" id based on account type in case the account is not
	--a subscriber
	if
		(UPPER(@p_apply_default_policy) = 'Y' OR
		UPPER(@p_apply_default_policy) = 'T' OR
		UPPER(@p_apply_default_policy) = '1') begin
    SET @authancestor = @ancestorID
		if (@IsNotSubscriber > 0) begin
		 	select @folderName = 
			 CASE 
				WHEN UPPER(@p_acc_type) = 'CSR' THEN 'csr_folder'
				WHEN UPPER(@p_acc_type) = 'MOM' THEN 'mom_folder'
				WHEN UPPER(@p_acc_type) = 'MCM' THEN 'mcm_folder'
				WHEN UPPER(@p_acc_type) = 'IND' THEN 'mps_folder' END
			SELECT @authancestor = NULL
      SELECT @authancestor = id_acc  FROM t_account_mapper WHERE nm_login = @folderName
			AND nm_space = 'auth'
			if (@authancestor is null) begin
	 			select @status = 1
	 		end
		end 
		--apply default security policy
		if (@authancestor > 1) begin
			exec dbo.CloneSecurityPolicy @authancestor, @accountID , 'D' , 'A'
		end
	End 
	select @p_hierarchy_path = tx_path  from t_account_ancestor
	where id_descendent = @accountID and id_ancestor = 1 AND 
	@ancestor_startdate between vt_start AND vt_end
	if @ancestorID <> 1 begin
		select @p_currency = c_currency from t_av_internal where id_acc = @ancestorID
  end
	-- done
	select @status = 1

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create procedure AdjustGsubMemberDates(
@p_id_sub integer,
@p_startdate datetime,
@p_enddate datetime,
@p_adjustedstart datetime OUTPUT,
@p_adjustedend datetime OUTPUT,
@p_datemodified char(1) OUTPUT,
@p_status INT OUTPUT
)
as
begin
	select @p_datemodified = 'N'	
	select @p_adjustedstart = dbo.mtmaxoftwodates(@p_startdate,vt_start),
	@p_adjustedend = dbo.mtminoftwodates(@p_enddate,vt_end) 
	from 
	t_sub where id_sub = @p_id_sub
	if (@p_adjustedstart <> @p_startdate OR @p_adjustedend <> @p_enddate) begin
		select @p_datemodified = 'Y'
	end
	if @p_adjustedend < @p_adjustedstart begin
		-- hmm.... looks like we are outside the effective date of the group subscription
		-- MT_GSUB_DATERANGE_NOT_IN_SUB_RANGE
		select @p_status = -486604789
		return
	end
	select @p_status = 1
	return
end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create procedure AdjustSubDates(
@p_id_po integer,
@p_startdate datetime,
@p_enddate datetime,
@p_adjustedstart datetime OUTPUT,
@p_adjustedend datetime OUTPUT,
@p_datemodified char(1) OUTPUT,
@p_status INT OUTPUT
)
as
begin
	select @p_datemodified = 'N'	
	select @p_adjustedstart = dbo.mtmaxoftwodates(@p_startdate,po.dt_start),
	@p_adjustedend = dbo.mtminoftwodates(@p_enddate,po.dt_end) 
	from 
	(select te.dt_start,
	case when te.dt_end is NULL then dbo.mtmaxdate() else te.dt_end end as dt_end
	from t_po
	INNER JOIN t_effectivedate te on te.id_eff_date = t_po.id_eff_date
	where t_po.id_po = @p_id_po) po
	if (@p_adjustedstart <> @p_startdate OR @p_adjustedend <> @p_enddate) begin
		select @p_datemodified = 'Y'
	end
	if @p_adjustedend < @p_adjustedstart begin
		-- hmm.... looks like we are outside the effective date of the product offering
		-- MTPCUSER_PRODUCTOFFERING_NOT_EFFECTIVE
		select @p_status = -289472472
		return
	end
	select @p_status = 1
	return
end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create proc BulkSubscriptionChange(
@id_old_po as int,
@id_new_po as int,
@date as datetime,
@nextbillingcycle as varchar(1),
@p_systemdate datetime
)
as
DECLARE @CursorVar CURSOR	
DECLARE @count as int
declare @i as int
declare @id_acc as int
declare @end_date as datetime
declare @id_sub as int
declare @new_sub as int
declare @new_status as int
declare @varmaxdatetime datetime
declare @subext as varbinary(16)
declare @realenddate as datetime
-- lock everything down as tight as possible!
--SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
begin 
select @varmaxdatetime = dbo.mtmaxdate ()
-- should we update the end effective date of the 
-- old product offering here?
-- create a cursor that holds a static list of all old
-- subscriptions that have end dates later than the old date
set @CursorVar = CURSOR STATIC FOR
	select id_acc,vt_end,id_sub
	from t_sub
	where t_sub.id_po = @id_old_po AND
	t_sub.vt_end >= @date
	AND id_group is NULL
OPEN @CursorVar
set @count = @@cursor_rows
set @i = 0
while @i < @count begin
	FETCH NEXT FROM @CursorVar into @id_acc,@end_date,@id_sub
	set @i = (select @i + 1)
	select @subext = CAST(newid() as varbinary(16))
	select @realenddate = case when @nextbillingcycle = 'Y' AND @date is not null then
		dbo.subtractsecond(dbo.NextDateAfterBillingCycle(@id_acc,@date))
	else
		dbo.subtractsecond(@date)
	end		
	-- update the old subscription use the specified date
	update t_sub set vt_end = @realenddate where
	id_sub = @id_sub
	-- update the old subscription tt_end
	UPDATE t_sub_history
  SET tt_end = dbo.subtractsecond (@p_systemdate)
	WHERE id_sub = @id_sub
	and tt_end = @varmaxdatetime
	-- insert the new record
	INSERT INTO t_sub_history
  SELECT id_sub, id_sub_ext, id_acc, id_po, dt_crt, id_group,
         vt_start, @realenddate, @p_systemdate, @varmaxdatetime
  FROM t_sub_history
   WHERE id_sub = @id_sub
     AND tt_end = dbo.subtractsecond (@p_systemdate)
	exec AddNewSub  
		@id_acc,
		@date,
		@end_date,
		@nextbillingcycle, -- next billing cycle after start date
		'N',
		@id_new_po,
		@subext,
		@p_systemdate,
		@new_sub OUTPUT,
		@new_status OUTPUT
	-- if @new_status is not 0 then raise an error
	if @new_status <> 1 begin
		declare @errstatus as varchar(256)
		select @errstatus = CAST(@new_status as varchar(256))
		RAISERROR (@errstatus,16,1)
	end
end 
CLOSE @CursorVar
DEALLOCATE @CursorVar
end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

			create proc CanBulkSubscribe(@id_old_po as int,
										 @id_new_po as int,
										 @subdate as datetime,
										 @status as int output)
			as
			declare @conflictcount as int
			set @conflictcount = 0
			set @status = 0 -- success
			declare @countvar as int
			declare @totalnum as int
			-- step 1: are there any subscriptions that are already subscribed to the new product offering
			set @conflictcount = (select count(t_sub.id_sub) --t_sub.id_acc,t_subnew.id_acc
			from t_sub where t_sub.id_po = @id_new_po AND
			t_sub.vt_start <= @subdate AND t_sub.vt_end >= @subdate
			and t_sub.id_acc in (
				select sub2.id_acc from t_sub sub2 where sub2.id_po = @id_old_po AND
				sub2.vt_start <= @subdate AND sub2.vt_end >= @subdate
				)
			)
			if(@conflictcount > 0) begin
				set @status = 1
				return
			end
			-- step 2: does the destination product offering conflict with  
			select @countvar = count(id_pi_template),@totalnum = (select count(id_pi_template) from t_pl_map where id_po = @id_new_po)
			 from t_pl_map where id_po = @id_new_po AND id_pi_template in 
			(
			select id_pi_template from t_pl_map map where id_pi_template not in 
				-- find all templates from subscribed product offerings
				(select DISTINCT(id_pi_template) from t_pl_map where t_pl_map.id_po in 
					-- match all product offerings
					(select id_po from t_sub where 
					t_sub.vt_start <= @subdate AND t_sub.vt_end >= @subdate 
					-- get all of the accounts where they are currently subscribed to the original
					-- product offering
					AND t_sub.id_acc in (
						select id_acc from t_sub where id_po = @id_old_po AND
						t_sub.vt_start <= @subdate AND t_sub.vt_end >= @subdate
						)
					)
				)
			UNION
				select DISTINCT(id_pi_template) from t_pl_map where id_po = @id_old_po
			)
			if(@countvar <> @totalnum) begin
				set @status = 2
			end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

				CREATE PROCEDURE CheckAccountStateDateRules (
				  @p_id_acc integer,
					@p_old_status varchar(2),
					@p_new_status varchar(2),
					@p_ref_date datetime,
					@status integer output)
				AS
				BEGIN
					declare @dt_crt datetime
					-- Rule 1: There should be no updates with dates earlier than 
					-- inception date
					SELECT 
					  @dt_crt = dbo.mtstartofday(dt_crt)
					FROM 	
					  t_account 
					WHERE
					  id_acc = @p_id_acc
					IF (dbo.mtstartofday(@p_ref_date) < @dt_crt)
					BEGIN
					  -- MT_SETTING_START_DATE_BEFORE_ACCOUNT_INCEPTION_DATE_NOT_ALLOWED
					  -- (DWORD)0xE2FF002EL)
					  SELECT @status = -486604754
					  return
					END
					select @status = 1
				 END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

				CREATE PROCEDURE CheckForNotArchivedDescendents (
					@id_acc INT,
					@ref_date DATETIME,
					@status INT output)
				AS
				BEGIN
				  select @status = 1
					BEGIN
						-- Check first to see if its a folder
						-- return MT_ACCOUNT_NOT_A_FOLDER
				 		if (dbo.IsAccountFolder(@id_acc) = 'N')
						  begin
							select @status = -486604799
							return
				 			end 
						-- select accounts that have status as closed or archived
						SELECT 
							@status = count(*)  
						FROM 
				  		t_account_ancestor aa
							-- join between t_account_state and t_account_ancestor
							INNER JOIN t_account_state astate ON aa.id_ancestor = astate.id_acc 
						WHERE
							aa.id_ancestor = @id_acc AND
				  		astate.status <> 'AR' AND
				  		@ref_date between astate.vt_start and astate.vt_end AND
				  		@ref_date between aa.vt_start and aa.vt_end
				  		-- success is when no rows found
   						if (@status is null)
							   begin
								 select @status = 1
         				 return
                 end
					END
				END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

				CREATE PROCEDURE CheckForNotClosedDescendents (
					@id_acc INT,
					@ref_date DATETIME,
					@status INT output)
				AS
				BEGIN
				  select @status = 1
					BEGIN
						-- Check first to see if its a folder
						-- return MT_ACCOUNT_NOT_A_FOLDER
				 		if (dbo.IsAccountFolder(@id_acc) = 'N')
						  begin
							select @status = -486604799
							return
				 		  end 
						-- select accounts that have status less than closed
						SELECT @status =	count(*) 
						FROM 
				  		t_account_ancestor aa
							-- join between t_account_state and t_account_ancestor
							INNER JOIN t_account_state astate ON aa.id_ancestor = astate.id_acc 
						WHERE
							aa.id_ancestor = @id_acc AND
				  		astate.status <> 'CL' AND
				  		@ref_date between astate.vt_start and astate.vt_end AND
				  		@ref_date between aa.vt_start and aa.vt_end
				  		-- success is when no rows found
   						if (@status is null)
							   begin
         				  select @status = 1
         					return
					        end
					END
				END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create procedure CheckGroupSubBusinessRules(
	@p_name varchar(255),
	@p_desc varchar(255),
	@p_startdate datetime,
	@p_enddate datetime,
	@p_id_po int,
	@p_proportional varchar,
	@p_discountaccount int,
	@p_CorporateAccount int,
	@p_existingID int,
	@p_id_usage_cycle integer,
	@p_systemdate datetime,
	@p_status int OUTPUT
)
as
begin 
declare @existingPO integer
declare @constrainedcycletype integer
declare @groupsubCycleType integer
declare @corporatestartdate datetime
select @p_status = 0
	-- verify that the product offering exists and the effective date is kosher
if (@p_proportional = 'N' )
 begin
 if (@p_discountaccount is NULL AND dbo.POContainsDiscount(@p_id_po) = 1)
	begin
	-- MT_GROUP_SUB_DISCOUNT_ACCOUNT_REQUIRED
	select @p_status = -486604787
	return
	end 
 end
	-- verify that the account is actually a corporate account
if (dbo.iscorporateaccount(@p_CorporateAccount,@p_systemdate) = 0)
	begin
	-- MT_GROUP_SUB_CORPORATE_ACCOUNT_INVALID
	select @p_status = -486604786
	return
	end 
 -- make sure start date is before end date
	-- MT_GROUPSUB_STARTDATE_AFTER_ENDDATE
if (@p_enddate is not null )
	begin
	if (@p_startdate > @p_enddate)
		begin
		select @p_status = -486604782
		return
		end 
	end
	-- verify that the group subscription name does not conflict with an existing
	-- group subscription
	--  MT_GROUP_SUB_NAME_EXISTS -486604784
begin
	select @p_status = 0
	select @p_status = id_group  from t_group_sub where lower(@p_name) = lower(tx_name) AND
	(@p_existingID <> id_group OR @p_existingID is NULL)
	if (@p_status <> 0) begin
		select @p_status = -486604784
		return
	end 
	if (@p_status is null) begin
		select @p_status = 0
		end
end
-- verify that the usage cycle type matched that of the 
-- product offering
select @constrainedcycletype = dbo.poconstrainedcycletype(@p_id_po),
		@groupsubCycleType = id_cycle_type 
from
t_usage_cycle
where id_usage_cycle = @p_id_usage_cycle
if @constrainedcycletype > 0 AND
	@constrainedcycletype <> @groupsubCycleType begin
-- MT_GROUP_SUB_CYCLE_TYPE_MISMATCH
	select @p_status = -486604762
return
end
 -- check that the discount account has in its ancestory tree 
	-- the corporate account
if (@p_discountaccount is not NULL)
	begin
		select @p_status = max(id_ancestor)  
		from t_account_ancestor 
		where id_descendent = @p_discountaccount 
		and id_ancestor = @p_CorporateAccount
	if (@p_status is NULL)
		begin
		-- MT_DISCOUNT_ACCOUNT_MUST_BE_IN_CORPORATE_HIERARCHY
		select @p_status = -486604760
		return
		end 
	end 
	if dbo.POContainsOnlyAbsoluteRates(@p_id_po) = 0 begin
		-- MTPCUSER_CANNOT_RATE_SCHEDULES_CONFLICT_WITH_GROUP_SUB
		select @p_status = -289472469
		return
	end
	-- make sure the start date is after the start date of the corporate account
	select @corporatestartdate = dbo.mtstartofday(dt_crt) from t_account where id_acc = @p_CorporateAccount
	if @corporatestartdate > @p_startdate begin
		-- MT_CANNOT_CREATE_GROUPSUB_BEFORE_CORPORATE_START_DATE
		select @p_status = -486604747
		return
	end 
-- done
select @p_status = 1
end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

				CREATE proc CheckIfIntervalIsHardClosed (
				  @id_interval INT,
					@status INT OUTPUT)
				AS
 				BEGIN
					declare @intervalstatus VARCHAR(255)
					select @status = -1
					SELECT @intervalstatus = tx_interval_status 
					FROM t_usage_interval
					WHERE t_usage_interval.id_interval = @id_interval
					IF (@intervalstatus <> 'H') 
					begin 
					  -- no need to do anything here (INTERVAL_NOT_HARD_CLOSED)
						select @status = -469368826
						RETURN
					end 
					select @status = 1
					RETURN
				END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

					  CREATE procedure CloneSecurityPolicy 
            (@parent_id_acc int,
             @child_id_acc  int ,
             @parent_pol_type varchar(1),
						 @child_pol_type varchar(1))
            as                               
            begin				
            declare @polid INT,			
										@parentPolicy INT,
										@childPolicy INT		
            exec sp_Insertpolicy N'id_acc', @parent_id_acc,@parent_pol_type, @parentPolicy output
  					exec sp_Insertpolicy N'id_acc', @child_id_acc, @child_pol_type,@childPolicy output
						DELETE FROM T_POLICY_ROLE WHERE id_policy = @childPolicy
						INSERT INTO T_POLICY_ROLE
						SELECT @childPolicy, pr.id_role FROM T_POLICY_ROLE pr
						INNER JOIN T_PRINCIPAL_POLICY pp ON pp.id_policy = pr.id_policy
						WHERE pp.id_acc = @parent_id_acc AND
						pp.policy_type = @parent_pol_type
						end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

					CREATE PROC CreateCounterPropDef											@id_lang_code int,											@n_kind int,											@nm_name nvarchar(255),											@nm_display_name nvarchar(255),											@id_pi int,											@nm_servicedefprop nvarchar(255),											@nm_preferredcountertype nvarchar(255),											@n_order int, 											@id_prop int OUTPUT 					AS						DECLARE @identity_value int						DECLARE @id_locale int					BEGIN TRAN						exec InsertBaseProps @id_lang_code, @n_kind, 'N', 'N', @nm_name, NULL, @nm_display_name, @identity_value output						INSERT INTO t_counterpropdef 							(id_prop, id_pi, nm_servicedefprop, n_order, nm_preferredcountertype) 						VALUES 							(@identity_value, @id_pi, @nm_servicedefprop, @n_order, @nm_preferredcountertype)						SELECT 						@id_prop = @identity_value					COMMIT TRAN
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create procedure CreateGroupSubscription(
@p_sub_GUID varbinary(16),
@p_group_GUID varbinary(16),
@p_name  varchar(255),
@p_desc varchar(255),
@p_usage_cycle int,
@p_startdate datetime,
@p_enddate datetime,
@p_id_po int,
@p_proportional varchar,
@p_supportgroupops varchar,
@p_discountaccount int,
@p_CorporateAccount int,
@p_systemdate datetime,
@p_id_sub int OUTPUT,
@p_id_group int OUTPUT,
@p_status int OUTPUT,
@p_datemodified varchar OUTPUT
)
as
begin
declare @existingPO as int
declare @realenddate as datetime
declare @varMaxDateTime as datetime
select @p_datemodified = 'N'
 -- business rule checks
select @varMaxDateTime = dbo.MTMaxDate()
select @p_status = 0
exec CheckGroupSubBusinessRules @p_name,@p_desc,@p_startdate,@p_enddate,@p_id_po,@p_proportional,
@p_discountaccount,@p_CorporateAccount,NULL,@p_usage_cycle,@p_systemdate,@p_status OUTPUT
if (@p_status <> 1) 
	begin
	return
	end 
	-- set the end date to max date if it is not specified
if (@p_enddate is null) 
	begin
	select @realenddate = @varMaxDateTime
	end
else
	begin
	select @realenddate = @p_enddate
	end 
	insert into t_group_sub (id_group_ext,tx_name,tx_desc,b_visable,b_supportgroupops,
	id_usage_cycle,b_proportional,id_discountAccount,id_corporate_account)
	select @p_group_GUID,@p_name,@p_desc,'N',@p_supportgroupops,@p_usage_cycle,
	@p_proportional,@p_discountaccount,@p_CorporateAccount
	-- group subscription ID
	select @p_id_group =@@identity
 -- add group entry
  exec AddSubscriptionBase NULL,@p_id_group,@p_id_po,@p_startdate,@p_enddate,
	@p_group_GUID,@p_systemdate,@p_id_sub output,@p_status output,@p_datemodified output
end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create  Procedure  CreatePaymentRecord (
  @Payer  int,
	@NPA int,
  @startdate  datetime,
  @enddate datetime,
	@payerbillable varchar(1),
  @systemdate datetime,
	@p_fromUpdate char(1),
  @status int OUTPUT)
  as
  begin
  declare @realstartdate datetime
  declare @realenddate datetime
	declare @accCreateDate datetime
	declare @billableFlag varchar(1)
	declare @payer_state varchar(10)
	select @status = 0
  select @realstartdate = dbo.mtstartofday(@startdate)    
  if (@enddate is NULL)
    begin
    select @realenddate = dbo.mtstartofday(dbo.MTMaxDate()) 
    end
  else
    begin
    select @realenddate = dbo.mtstartofday(@enddate) 
    end
	select @AccCreateDate = dbo.mtstartofday(dt_crt) from t_account where id_acc = @NPA
	if @realstartdate < @AccCreateDate begin
    -- MT_PAYMENT_DATE_BEFORE_ACCOUNT_STARDATE
		select @status = -486604753
		return
	end
	if @realstartdate = @realenddate begin
		-- MT_PAYMENT_START_AND_END_ARE_THE_SAME
		select @status = -486604735
		return
	end
	if @realstartdate > @realenddate begin
		-- MT_PAYMENT_START_AFTER_END
		select @status = -486604734
		return
	end
	 /* 
		NPA: Non Paying Account
	  Assumptions: The system has already checked if an existing payment
	  redirection record exists.  The user is asked whether the 
	  system should truncate the existing payment redirection record.
	  business rule checks:
	  MT_ACCOUNT_CAN_NOT_PAY_FOR_ITSELF (0xE2FF0007L, -486604793)
	  ACCOUNT_IS_NOT_BILLABLE (0xE2FF0005L,-486604795)
	  MT_PAYMENT_RELATIONSHIP_EXISTS (0xE2FF0006L, -486604794)
	  step 1: Account can not pay for itself
	if (@Payer = @NPA)
		begin
		select @status = -486604793
		return
		end  
	 */
	select @billableFlag = case when @payerbillable is NULL then
		dbo.IsAccountBillable(@payer)	else @payerbillable end
	 -- step 2: The account is in a state such that new payment records can be created
	if @billableFlag = 'N' begin
		-- MT_ACCOUNT_IS_NOT_BILLABLE
		select @status = -486604795
		return
	end
	-- check payee is not an independent account, return.
	-- MT_CANNOT_PAY_FOR_INDEPENDENT_ACCOUNT
	-- Note that we allow an account to pay for itself if it is billable 
	-- irregardless of the account type
	if @payer <> @NPA begin
		select 
			@status = 
			case when acc_type = 'IND' then -486604757 else 0 end
			from t_account where id_acc = @NPA
		if @status <> 0 begin
			return
		end
	end
	-- make sure that the paying account is active for the entire payment period
	-- PA is considered valid state now for 3.0.1
	if (@payer_state <> 'PA') begin
		select TOP 1 @payer_state = status from t_account_state
		where dbo.enclosedDateRange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND
		id_acc = @payer
		if @payer_state is NULL OR @payer_state <> 'AC' begin
			-- MT_PAYER_IN_INVALID_STATE
			select @status = -486604736
			return
		end
	end
	-- check that both the payer and Payee are in the same corporate account
	if dbo.IsInSameCorporateAccount(@payer,@NPA,@realstartdate) <> 1 begin
		-- MT_CANNOT_PAY_FOR_ACCOUNT_IN_OTHER_CORPORATE_ACCOUNT
		select @status = -486604758
		return
	end
	-- return without doing work in cases where nothing needs to be done
	select @status = count(*) 
	from t_payment_redirection where id_payer = @payer AND id_payee = @NPA
	AND (
		(dbo.encloseddaterange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND @p_fromupdate = 'N') 
		OR
		(vt_start = @realstartdate AND vt_end = @realenddate AND @p_fromupdate = 'Y')
	)
	if @status > 0 begin
		-- account is already paying for the account during the interval.  Simply ignore
		-- the action
		select @status = 1
		return
	end
	exec CreatePaymentRecordBitemporal @payer,@NPA,@realstartdate,@realenddate,@systemdate, @status OUTPUT
end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

				CREATE PROC DelPVRecordsForAcct
										@nm_productview varchar(255),
										@id_pi_template int,
										@id_interval int,
										@id_view int,
										@id_acc int
				AS
 				DECLARE @pv_delete_stmt varchar(1000)
 				DECLARE @usage_delete_stmt varchar(1000)
 				DECLARE @strInterval varchar(255)
 				DECLARE @strPITemplate varchar(255)
 				DECLARE @strView varchar(255)
 				DECLARE @strAccount varchar(255)
 				DECLARE @WhereClause varchar(255)
				--convert int to strings
				SELECT @strInterval = CONVERT(varchar(255), @id_interval)
				SELECT @strPITemplate = CONVERT(varchar(255), @id_pi_template)
				SELECT @strView = CONVERT(varchar(255), @id_view)
				SELECT @strAccount = CONVERT(varchar(255), @id_acc)
				SELECT @WhereClause = ' WHERE id_usage_interval=' + @strInterval + ' AND id_pi_template=' + @strPITemplate + ' AND id_view=' + @strView + ' AND id_acc=' + @strAccount
				SELECT 
					@pv_delete_stmt = 'DELETE FROM ' + @nm_productview + ' WHERE id_sess IN (select id_sess from t_acc_usage ' +
					+ @WhereClause + ')'
				SELECT 
					@usage_delete_stmt = 'DELETE FROM t_acc_usage ' + @WhereClause
				BEGIN TRAN
					EXECUTE(@pv_delete_stmt)
					EXECUTE(@usage_delete_stmt)
				COMMIT TRAN

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

      create procedure DeleteBaseProps(
				@a_id_prop int) 
      as
			begin
        declare @id_desc_display_name int
        declare @id_desc_name int
        declare @id_desc_desc int
     		SELECT @id_desc_name = n_name, @id_desc_desc = n_desc, 
				@id_desc_display_name = n_display_name
		 		from t_base_props where id_prop = @a_id_prop
				exec DeleteDescription @id_desc_display_name
				exec DeleteDescription @id_desc_name
				exec DeleteDescription @id_desc_desc
				DELETE FROM t_base_props WHERE id_prop = @a_id_prop
			end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

						create proc DeleteCounterParamInstances											(@id_counter	int)						AS						BEGIN 						DELETE FROM T_COUNTER_PARAMS WHERE id_counter = @id_counter					  end
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

						CREATE PROC DeleteCounterParamTypes			
									@id_counter_type int
			AS
			BEGIN TRAN
				SELECT id_prop INTO #TempCounterType FROM t_counter_params_metadata WHERE id_counter_meta = @id_counter_type
				DELETE FROM t_counter_params_metadata WHERE id_prop IN (SELECT id_prop FROM #TempCounterType)
				DELETE FROM t_base_props WHERE id_prop IN (SELECT id_prop FROM #TempCounterType)
			COMMIT TRAN

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

      create procedure DeleteDescription(
				@a_id_desc int)
			as
			BEGIN
				IF (@a_id_desc <> 0)
					begin
					delete from t_description where id_desc=@a_id_desc
					delete from t_mt_id where id_mt=@a_id_desc
	     		end 
			END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

				CREATE PROC DeleteProductViewRecords
										@nm_productview varchar(255),
										@id_pi_template int,
										@id_interval int,
										@id_view int
				AS
 				DECLARE @pv_delete_stmt varchar(1000)
 				DECLARE @usage_delete_stmt varchar(1000)
 				DECLARE @strInterval varchar(255)
 				DECLARE @strPITemplate varchar(255)
				DECLARE @strView varchar(255)
 				DECLARE @WhereClause varchar(255)
				--convert int to strings
				SELECT @strInterval = CONVERT(varchar(255), @id_interval)
				SELECT @strPITemplate = CONVERT(varchar(255), @id_pi_template)
				SELECT @strView = CONVERT(varchar(255), @id_view)
				SELECT @WhereClause = ' WHERE id_usage_interval=' + @strInterval + ' AND id_pi_template=' + @strPITemplate + ' AND id_view=' + @strView
				SELECT 
					@pv_delete_stmt = 'DELETE FROM ' + @nm_productview +  ' WHERE id_sess IN (select id_sess from t_acc_usage ' +
					 + @WhereClause + ')'
				SELECT 
					@usage_delete_stmt = 'DELETE FROM t_acc_usage'  + @WhereClause
				BEGIN TRAN
					EXECUTE(@pv_delete_stmt)
					EXECUTE(@usage_delete_stmt)
				COMMIT TRAN

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

			create proc ExecSpProcOnKind @kind as int,@id as int				as				declare @sprocname varchar(256)				select @sprocname = nm_sprocname from t_principals where id_principal = @kind				exec (@sprocname + ' ' + @id)
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

					create proc ExtendedUpsert(@table_name as varchar(100),												 @update_list as varchar(8000),												 @insert_list as varchar(8000),												 @clist as varchar(8000),												 @id_prop as int)					as					exec('update ' + @table_name + ' set ' + 					@update_list + ' where ' + @table_name + '.id_prop = ' + @id_prop)					if @@rowcount = 0 begin						exec('insert into ' + @table_name + ' (id_prop,' + @clist + ') values( ' + @id_prop + ',' + @insert_list + ')')					end
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create proc GetAggregateChargeProps @id as int as select * from t_pi JOIN t_base_props on t_base_props.id_prop = @id  FULL JOIN t_aggregate ON t_aggregate.id_prop = @id where t_pi.id_pi = @id AND t_base_props.n_kind = 15
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create proc GetCalendarPropDefs @id as int as select * from t_calendar JOIN t_base_props on t_base_props.id_prop = @id  where t_calendar.id_prop = @id AND t_base_props.n_kind = 240
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create proc GetCounterParamTypeProps @id as int as select * from t_counter_params_metadata JOIN t_base_props on t_base_props.id_prop = @id  where t_counter_params_metadata.id_prop = @id AND t_base_props.n_kind = 190
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create proc GetCounterPropDefs @id as int as select * from t_counterpropdef JOIN t_base_props on t_base_props.id_prop = @id  where t_counterpropdef.id_prop = @id AND t_base_props.n_kind = 230
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create proc GetCounterProps @id as int as select * from t_counter JOIN t_base_props on t_base_props.id_prop = @id  where t_counter.id_prop = @id AND t_base_props.n_kind = 170
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create proc GetCounterTypeProps @id as int as select * from t_counter_metadata JOIN t_base_props on t_base_props.id_prop = @id  where t_counter_metadata.id_prop = @id AND t_base_props.n_kind = 180
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

			 	CREATE PROC GetCurrentID @nm_current varchar(20), @id_current int OUTPUT        as         begin tran         select @id_current = id_current from t_current_id           where nm_current = @nm_current         update t_current_id set id_current = id_current + 1           where nm_current = @nm_current 				if ((@@error != 0) OR (@@rowCount != 1))         begin           select @id_current = -99				  rollback transaction         end         else         begin 				  commit transaction         end 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create proc GetDiscountProps @id as int as select * from t_pi JOIN t_base_props on t_base_props.id_prop = @id  FULL JOIN t_discount ON t_discount.id_prop = @id where t_pi.id_pi = @id AND t_base_props.n_kind = 40
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create proc GetEffProps @id as int as select * from t_effectivedate JOIN t_base_props on t_base_props.id_prop = @id  where t_effectivedate.id_eff_date = @id AND t_base_props.n_kind = 160
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

          CREATE PROC GetLocalizedSiteInfo @nm_space nvarchar(40),             @tx_lang_code varchar(10), @id_site int OUTPUT          as           if not exists (select * from t_localized_site where             nm_space = @nm_space and tx_lang_code = @tx_lang_code)           begin             insert into t_localized_site (nm_space, tx_lang_code)               values (@nm_space, @tx_lang_code)            if ((@@error != 0) OR (@@rowcount != 1))             begin              select @id_site = -99            end             else             begin               select @id_site = @@identity             end           end           else           begin             select @id_site = id_site from t_localized_site               where nm_space = @nm_space and tx_lang_code = @tx_lang_code           end
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create proc GetNonRecurProps @id as int as select * from t_pi JOIN t_base_props on t_base_props.id_prop = @id  FULL JOIN t_nonrecur ON t_nonrecur.id_prop = @id where t_pi.id_pi = @id AND t_base_props.n_kind = 30
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

				create proc GetPCViewHierarchy(@id_acc as int,
					@id_interval as int,
					@id_lang_code as int)
				as
				select 
				tb_po.n_display_name id_po,-- use the display name as the product offering ID
				--au.id_prod id_po,
				pi_template.id_template_parent id_template_parent,
				--po_nm_name = case when t_description.tx_desc is NULL then template_desc.tx_desc else t_description.tx_desc end,
				po_nm_name = case when t_description.tx_desc is NULL then template_desc.tx_desc else t_description.tx_desc end,
				ed.nm_enum_data pv_child,
				ed.id_enum_data pv_childID,
				pv_parentID = case when parent_kind.nm_productview is NULL then tb_po.n_display_name else tenum_parent.id_enum_data end,
				AggRate = case when pi_props.n_kind = 15 then 'Y' else 'N' end,
				viewID = case when au.id_pi_instance is NULL then id_view else 
					(select viewID = case when pi_props.n_kind = 15 AND child_kind.nm_productview = ed.nm_enum_data then
					-(au.id_pi_instance + 0x40000000)
					else
					-au.id_pi_instance 
					end)
				end,
				id_view realPVID,
				--ViewName = case when tb_instance.nm_display_name is NULL then tb_template.nm_display_name else tb_instance.nm_display_name end,
				ViewName = case when tb_instance.nm_display_name is NULL then tb_template.nm_display_name else tb_instance.nm_display_name end,
				'Product' ViewType,
				--id_view DescriptionID,
				DescriptionID = case when t_description.tx_desc is NULL then template_props.n_display_name else id_view end,
				sum(au.amount) 'Amount',
				count(au.id_sess) 'Count',
				au.am_currency 'Currency', sum((isnull((au.tax_federal), 
				0.0) + isnull((au.tax_state), 0.0) + isnull((au.tax_county), 0.0) + 
				isnull((au.tax_local), 0.0) + isnull((au.tax_other), 0.0))) TaxAmount, 
				sum(au.amount + (isnull((au.tax_federal), 0.0) + isnull((au.tax_state), 0.0) + 
				isnull((au.tax_county), 0.0) + isnull((au.tax_local), 0.0) + 
				isnull((au.tax_other), 0.0))) AmountWithTax
				from t_usage_interval
				JOIN t_acc_usage au on au.id_acc = @id_acc AND au.id_usage_interval = @id_interval AND au.id_pi_template is not NULL
				JOIN t_base_props tb_template on tb_template.id_prop = au.id_pi_template
				JOIN t_pi_template pi_template on pi_template.id_template = au.id_pi_template
				JOIN t_pi child_kind on child_kind.id_pi = pi_template.id_pi
				JOIN t_base_props pi_props on pi_props.id_prop = child_kind.id_pi
				JOIN t_enum_data ed on ed.id_enum_data = au.id_view
				JOIN t_base_props template_props on pi_template.id_template = template_props.id_prop
				JOIN t_description template_desc on template_props.n_display_name = template_desc.id_desc AND template_desc.id_lang_code = @id_lang_code
				LEFT OUTER JOIN t_pi_template parent_template on parent_template.id_template = pi_template.id_template_parent
				LEFT OUTER JOIN t_pi parent_kind on parent_kind.id_pi = parent_template.id_pi
				LEFT OUTER JOIN t_enum_data tenum_parent on tenum_parent.nm_enum_data = parent_kind.nm_productview
				LEFT OUTER JOIN t_base_props tb_po on tb_po.id_prop = au.id_prod
				LEFT OUTER JOIN t_base_props tb_instance on tb_instance.id_prop = au.id_pi_instance 
				LEFT OUTER JOIN t_description on t_description.id_desc = tb_po.n_display_name AND t_description.id_lang_code = @id_lang_code
				where
				t_usage_interval.id_interval = @id_interval
				GROUP BY 
				--t_pl_map.id_po,t_pl_map.id_pi_instance_parent,
				tb_po.n_display_name,tb_instance.n_display_name,
				t_description.tx_desc,template_desc.tx_desc,
				tb_instance.nm_display_name,tb_template.nm_display_name,
				tb_instance.nm_display_name, -- this shouldn't need to be here!!
				child_kind.nm_productview,
				parent_kind.nm_productview,tenum_parent.id_enum_data,
				pi_props.n_kind,
				id_view,ed.nm_enum_data,ed.id_enum_data,
				au.am_currency,
				tb_template.nm_name,
				pi_template.id_template_parent,
				au.id_pi_instance,
				template_props.n_display_name
				ORDER BY tb_po.n_display_name ASC, pi_template.id_template_parent ASC

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create proc GetPLProps @id as int as select * from t_pricelist JOIN t_base_props on t_base_props.id_prop = @id  where t_pricelist.id_pricelist = @id AND t_base_props.n_kind = 150
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create proc GetPOProps @id as int as select * from t_po JOIN t_base_props on t_base_props.id_prop = @id  where t_po.id_po = @id AND t_base_props.n_kind = 100
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

					create proc GetRateSchedules @id_acc as int,
					@acc_cycle_id as int,
					@default_pl as int,
					@RecordDate as datetime,
					@id_pi_template as int
					as
						-- real stored procedure code starts here
						-- only count rows on the final select.
						SET NOCOUNT ON
						declare @winner_type as int
						declare @winner_row as int
						declare @winner_begin as datetime
						-- Don't actually need the @winner end since it is not used
						-- to test overlapping effective dates
						declare @CursorVar CURSOR
						declare @count as int
						declare @i as int
						set @i = 0
						declare @tempID as int
						declare @tempStartType as int
						declare @temp_begin as datetime
						declare @temp_b_offset as int
						declare @tempEndType as int
						declare @temp_end as datetime
						declare @temp_e_offset as int
						declare @sub_begin as datetime
						declare @sub_end as datetime
						-- unused stuff until temporary table insertion
						declare @id_sched as int
						declare @dt_mod as datetime
						declare @id_po as int
						declare @id_paramtable as int
						declare @id_pricelist as int
						declare @id_sub as int
						declare @id_pi_instance as int
						declare @currentptable as int
						declare @currentpo as int
						declare @currentsub as int
						-- winner variables
						declare @win_id_sched as int
						declare @win_dt_mod as datetime
						declare @win_id_paramtable as int
						declare @win_id_pricelist as int
						declare @win_id_sub as int
						declare @win_id_po as int
						declare @win_id_pi_instance as int
						declare @TempEff table (id_sched int not null,
							dt_modified datetime not null,
							id_paramtable int not null,
							id_pricelist int not null,
							id_sub int null,
							id_po int null,
							id_pi_instance int null)
						-- declare our cursor. Is there anything special here for performance around STATIC vs. DYNAMIC?
						set @CursorVar = CURSOR STATIC
							 FOR 
								-- this query is pretty tricky.  It is the union of all of the possible rate schedules
								-- on the resolved product offering AND the intersection of the 
								-- default account pricelist and parameter tables for the priceable item type.
								select
								t_rsched.id_sched,t_rsched.dt_mod,
								tm.id_po,tm.id_pi_instance,tm.id_paramtable, tm.id_pricelist,tm.id_sub
								,te.n_begintype,te.dt_start, te.n_beginoffset,te.n_endtype,te.dt_end,te.n_endoffset
								,t_sub.vt_start dt_start,t_sub.vt_end dt_end
								from t_pl_map tm
								INNER JOIN t_sub on t_sub.id_acc= @id_acc
								INNER JOIN t_rsched on t_rsched.id_pricelist = tm.id_pricelist AND t_rsched.id_pt =tm.id_paramtable AND
								t_rsched.id_pi_template = @id_pi_template
								INNER JOIN t_effectivedate te on te.id_eff_date = t_rsched.id_eff_date
								where tm.id_po = t_sub.id_po and tm.id_pi_template = @id_pi_template 
								and (tm.id_acc = @id_acc or tm.id_sub is null)
								-- make sure that subscription is currently in effect
								AND (t_sub.vt_start <= @RecordDate AND @RecordDate <= t_sub.vt_end)
								UNION ALL
								select tr.id_sched,tr.dt_mod,
								NULL,NULL,map.id_pt,@default_pl,NULL,
								te.n_begintype,te.dt_start,te.n_beginoffset,te.n_endtype,te.dt_end,te.n_endoffset
								,NULL,NULL
								from t_rsched tr
								INNER JOIN t_effectivedate te ON te.id_eff_date = tr.id_eff_date
								-- throw out any default account pricelist rate schedules that use subscription relative effective dates
								AND te.n_begintype <> 2
								-- XXX fix this by passing in the instance ID
								INNER JOIN t_pi_template on id_template = @id_pi_template
								INNER JOIN t_pi_rulesetdef_map map ON map.id_pi = t_pi_template.id_pi
								where tr.id_pt = map.id_pt AND tr.id_pricelist = @default_pl AND tr.id_pi_template = @id_pi_template
								-- the ordering is very important.  The following algorithm depends on the fact
								-- that ICB rates will show up first (rows that don't have a NULL subscription value),
								-- normal product offering rates next, and thirdly the default account pricelist rate schedules
								order by tm.id_paramtable,tm.id_sub desc,tm.id_po desc
						OPEN @CursorVar
						select @count = @@cursor_rows
						while @i < @count begin
							FETCH NEXT FROM @CursorVar into 
								-- rate schedule stuff
								@id_sched,@dt_mod
								-- plmap
								,@id_po,@id_pi_instance,@id_paramtable,@id_pricelist,@id_sub
								-- effectivedate rate schedule
								,@tempStartType,@temp_begin,@temp_b_offset,@tempEndType,@temp_end,@temp_e_offset
								-- effective date from subscription
								,@sub_begin,@sub_end
							set @i = (select @i + 1)
							if(@currentptable IS NULL) begin
								set @currentptable = @id_paramtable
								set @currentpo = @id_po
								set @currentsub = @id_sub
							end
							else if(@currentpTable != @id_paramtable
									 OR -- completely new parameter table
									@currentsub != IsNull(@id_sub,-1) OR -- ICB rates
									@currentpo != IsNull(@id_po,-1) -- default account PL
								) begin
								if @winner_row IS NOT NULL begin
									-- insert winner record into table variable
									insert into @TempEff values (@win_id_sched,@win_dt_mod,@win_id_paramtable,
									@win_id_pricelist,@win_id_sub,@win_id_po,@win_id_pi_instance)
								end
								-- clear out winner values
								set @winner_type = NULL
								set @winner_row = NULL
								set @winner_begin = NULL
							end
							-- set our current parametertable
							set @currentpTable = @id_paramtable
							set @currentpo = @id_po
							set @currentsub = @id_sub
							-- step : convert non absolute dates into absolute dates.  Only have to 
							-- deal with subscription relative and usage cycle relative
							-- subscription relative.  Add the offset of the rate schedule effective date to the
							-- start date of the subscription.  This code assumes that subscription effective dates
							-- are absolute or have already been normalized
							if(@tempStartType = 2) begin
								set @temp_begin = @sub_begin + @temp_b_offset
							end
							if(@tempEndType = 2) begin
								set @temp_end = dbo.MTEndOfDay(@temp_e_offset + @sub_begin)
							end
							-- usage cycle relative
							-- The following query will only return a result if both the beginning 
							-- and the end start dates are somewhere in the past.  We find the date by
							-- finding the interval where our date lies and adding 1 second the end of that 
							-- interval to give us the start of the next.  If the startdate query returns NULL,
							-- we can simply reject the result since the effective date is in the future.  It is 
							-- OK for the enddate to be NULL.  Note: We expect that we will always be able to find
							-- an old interval in t_usage_interval and DO NOT handle purged records
							if(@tempStartType = 3) begin
								set @temp_begin = dbo.NextDateAfterBillingCycle(@id_acc,@temp_begin)
								if(@temp_begin IS NULL) begin
									-- restart to the beginning of the while loop
									continue
								end
							end
							if(@tempEndType = 3) begin
								set @temp_end = dbo.NextDateAfterBillingCycle(@id_acc,@temp_end)
							end
							-- step : perform date range check
							if( @RecordDate >= IsNull(@temp_begin,@RecordDate) AND @RecordDate <= IsNull(@temp_end,@RecordDate)) begin
								-- step : check if there is an existing winner
								-- if no winner always populate
								if( (@winner_row IS NULL) OR
									-- start into the complicated winner logic used when there are multiple
									-- effective dates that apply.  The winner is the effective date with the latest
									-- start date
									-- Anything overrides a NULL start date
									(@tempStartType != 4 AND @winner_type = 4) OR
									-- subscription relative overrides anything else
									(@winner_type != 2 AND @tempStartType = 2) OR
									-- check for duplicate subscription relative, pick one with latest start date
									(@winner_type = 2 AND @tempStartType = 2 AND @winner_begin < @temp_begin) OR
									-- check if usage cycle or absolute, treat as equal
									((@winner_type = 1 OR @winner_type = 3) AND (@tempStartType = 1 OR @tempStartType = 3) 
									AND @winner_begin < @temp_begin)
									) -- end if
								begin
									set @winner_type = @tempStartType
									set @winner_row = @i
									set @winner_begin = @temp_begin
									set @win_id_sched = @id_sched
									set @win_dt_mod = @dt_mod
									set @win_id_paramtable = @id_paramtable
									set @win_id_pricelist =@id_pricelist
									set @win_id_sub =@id_sub
									set @win_id_po = @id_po
									set @win_id_pi_instance = @id_pi_instance
								end
							end
						end
						-- step : Dump the last remaining winner into the temporary table
						if @winner_row IS NOT NULL begin
							insert into @TempEff values (@win_id_sched,@win_dt_mod,@win_id_paramtable,
							@win_id_pricelist,@win_id_sub,@win_id_po,@win_id_pi_instance)
						end
						CLOSE @CursorVar
						DEALLOCATE @CursorVar
						-- step : if we have any results, get the results from the temp table
						SET NOCOUNT OFF
						select * from @TempEff

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create proc GetRecurProps @id as int as select * from t_pi JOIN t_base_props on t_base_props.id_prop = @id  FULL JOIN t_recur ON t_recur.id_prop = @id where t_pi.id_pi = @id AND t_base_props.n_kind = 20
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create proc GetRuleSetDefProps @id as int as select * from t_rulesetdefinition JOIN t_base_props on t_base_props.id_prop = @id  where t_rulesetdefinition.id_paramtable = @id AND t_base_props.n_kind = 140
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create proc GetSchedProps @id as int as select * from t_rsched JOIN t_base_props on t_base_props.id_prop = @id  where t_rsched.id_sched = @id AND t_base_props.n_kind = 130
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create proc GetSubProps @id as int as select * from t_sub JOIN t_base_props on t_base_props.id_prop = @id  where t_sub.id_sub = @id AND t_base_props.n_kind = 120
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create proc GetUsageProps @id as int as select * from t_pi JOIN t_base_props on t_base_props.id_prop = @id  where t_pi.id_pi = @id AND t_base_props.n_kind = 10
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

						CREATE PROCEDURE GrantAllCapabilityToAccount
						(@aLoginName VARCHAR(255), @aNameSpace VARCHAR(255)) 
						as
						Begin
						declare @polID INT
						declare @dummy int
            declare @aAccountID INT
        			begin
              SELECT @aAccountID = id_acc FROM t_account_mapper WHERE nm_login = @aLoginName AND nm_space = @aNameSpace
              IF @aAccountID IS NULL
              BEGIN
                RAISERROR('No Records found in t_account_mapper for Login Name %s and NameSpace %s', 16, 2, @aLoginName,  @aNameSpace)
              END
							SELECT @polID  = id_policy FROM T_PRINCIPAL_POLICY WHERE id_acc = @aAccountID AND policy_type = 'A'
							if (@polID is null)
								begin
								exec sp_Insertpolicy 'id_acc', @aAccountID, 'A', @polID output
								end
							end
							begin
							SELECT @dummy = id_policy FROM T_CAPABILITY_INSTANCE WHERE id_policy = @polID
							if (@dummy is null)
								begin		         
								INSERT INTO T_CAPABILITY_INSTANCE(tx_guid,id_parent_cap_instance,id_policy,id_cap_type) 
								SELECT cast('ABCD' as varbinary(16)), NULL,@polID,id_cap_type FROM T_COMPOSITE_CAPABILITY_TYPE WHERE 
								tx_name = 'Unlimited Capability'
								end
							end
						End

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

				 CREATE PROC InsertAcctToIntervalMapping @id_acc int, @id_interval int         as 				 if not exists (select * from t_acc_usage_interval where id_acc = @id_acc           and id_usage_interval = @id_interval) 				 begin           insert into t_acc_usage_interval (id_acc, id_usage_interval, tx_status)             values (@id_acc, @id_interval, 'O')          end
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

		  create proc InsertAcctUsageWithUID @tx_UID varbinary(16), 			@id_acc int, @id_view int, @id_usage_interval int, @uid_parent_sess varbinary(16), 			@id_svc int, @dt_session datetime, @amount numeric(18,6), @am_currency varchar(3), 			@tax_federal numeric(18,6), @tax_state numeric(18,6), @tax_county numeric(18,6), 			@tax_local numeric(18,6), @tax_other numeric(18,6), @tx_batch varbinary(16), 		@id_prod int, @id_pi_instance int, @id_pi_template int,		@id_sess int OUTPUT as		  declare @id_parent_sess int		  select @id_parent_sess = -1			select @id_parent_sess = id_sess from t_acc_usage 			where tx_UID = @uid_parent_sess		  if (@id_parent_sess = -1)	begin	select @id_sess = -99	end		  else		  begin 		  select @id_sess = id_current from t_current_id where nm_current='id_sess' 		  update t_current_id set id_current = id_current + 1 where nm_current='id_sess'		  insert into t_acc_usage (id_sess, tx_UID, id_acc, id_view, id_usage_interval, 			id_parent_sess, id_svc, dt_session, amount, am_currency, tax_federal, tax_state, 			tax_county, tax_local, tax_other, tx_batch, id_prod, id_pi_instance, id_pi_template) 		  values 			(@id_sess, @tx_UID, @id_acc, @id_view, @id_usage_interval, @id_parent_sess, @id_svc, @dt_session, 			@amount, @am_currency, @tax_federal, @tax_state, @tax_county, @tax_local, @tax_other, @tx_batch,		@id_prod, @id_pi_instance, @id_pi_template)		  if ((@@error != 0) OR (@@rowcount <> 1))		  begin 			select @id_sess = -99 		  end 		  end
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

	  create proc InsertAuditEvent @id_userid int, @id_event int, @id_entity_type int, @id_entity int, @dt_timestamp datetime, @tx_details varchar(255), @id_identity int OUTPUT as
 	 	--if (@id_parent_sess = -1) 
  	begin
  		insert into t_audit values(@id_event, @id_userid, @id_entity_type, @id_entity, @dt_timestamp)
  	end
 		select @id_identity = @@identity
  	if (@tx_details is not null) and (@tx_details != '')
  	begin
  		insert into t_audit_details values(@id_identity,@tx_details)
  	end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

		create proc InsertBaseProps 			@id_lang_code int,			@a_kind int,			@a_approved char(1),			@a_archive char(1),			@a_nm_name NVARCHAR(255),			@a_nm_desc NVARCHAR(255),			@a_nm_display_name NVARCHAR(255),			@a_id_prop int OUTPUT 		AS		begin		  declare @id_desc_display_name int      declare @id_desc_name int      declare @id_desc_desc int			exec UpsertDescription @id_lang_code, @a_nm_display_name, NULL, @id_desc_display_name output			exec UpsertDescription @id_lang_code, @a_nm_name, NULL, @id_desc_name output			exec UpsertDescription @id_lang_code, @a_nm_desc, NULL, @id_desc_desc output			insert into t_base_props (n_kind, n_name, n_desc,nm_name,nm_desc,b_approved,b_archive,			n_display_name, nm_display_name) values			(@a_kind, @id_desc_name, @id_desc_desc, @a_nm_name,@a_nm_desc,@a_approved,@a_archive,			 @id_desc_display_name,@a_nm_display_name)			select @a_id_prop =@@identity	   end
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

       create proc InsertDefaultTariff       as        declare @id int       select @id = id_enum_data from t_enum_data where           nm_enum_data = 'metratech.com/tariffs/TariffID/Default'       insert into t_tariff (id_enum_tariff, tx_currency) values (@id, 'USD')			 select @id = id_enum_data from t_enum_data where					nm_enum_data = 'metratech.com/tariffs/TariffID/ConferenceExpress'				insert into t_tariff(id_enum_tariff,tx_currency) values (@id,'USD')
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

				CREATE PROC InsertEnumData	@nm_enum_data varchar(255), 											@id_enum_data int OUTPUT 				as				begin tran 				if not exists (select * from t_enum_data where nm_enum_data = @nm_enum_data ) 				begin 					insert into t_mt_id default values					select @id_enum_data = @@identity					insert into t_enum_data (nm_enum_data, id_enum_data) values ( @nm_enum_data, @id_enum_data )					if ((@@error != 0) OR (@@rowCount != 1)) 					begin						rollback transaction 						select @id_enum_data = -99  					end 				end 				else 				begin 					select @id_enum_data = id_enum_data from t_enum_data 					where nm_enum_data = @nm_enum_data				end 				commit transaction
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

		CREATE PROC InsertInvoice 			@namespace varchar(200),			@invoice_string varchar(50),           			@id_interval int, 			@id_acc int,			@invoice_amount numeric(18,6),			@invoice_date varchar(100),			@invoice_due_date varchar(100),      @invoice_num int,			@id_invoice int OUTPUT         			as			insert into t_invoice 			(namespace, invoice_string, id_interval, id_acc, invoice_amount, invoice_date,       invoice_due_date, id_invoice_num)           			values 			(@namespace, @invoice_string, @id_interval, @id_acc, @invoice_amount, @invoice_date,       @invoice_due_date, @invoice_num)          			select @id_invoice = @@identity
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

				create proc InsertRecurringEventRun @id_interval int, @tx_adapter_name varchar(80),        @tx_adapter_method varchar(255), @tx_config_file varchar(255), @system_date datetime, @id_run int OUTPUT         as        insert into t_recurring_event_run (id_interval, dt_start, tx_adapter_name,           tx_adapter_method, tx_config_file)           values (@id_interval, @system_date, @tx_adapter_name, @tx_adapter_method, @tx_config_file)         if ((@@error != 0) OR (@@rowcount != 1))         begin           select @id_run = -99         end         else         begin           select @id_run = @@identity        end
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

				create proc InsertUsageCycleInfo @id_cycle_type int, @dom int,           @period_type char(1), @id_usage_cycle int OUTPUT				as         insert into t_usage_cycle (id_cycle_type, day_of_month, tx_period_type)           values (@id_cycle_type, @dom, @period_type)         if ((@@error != 0) OR (@@rowcount != 1))         begin          select @id_usage_cycle = -99         end         else         begin           select @id_usage_cycle = @@identity         end
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

			 create proc InsertUsageIntervalInfo @dt_start datetime, @dt_end datetime,@id_usage_cycle int, @id_usage_interval int OUTPUT			 as 			 select @id_usage_interval = id_interval from t_pc_interval where id_cycle = @id_usage_cycle			 and dt_start=@dt_start and dt_end=@dt_end			 insert into t_usage_interval (id_interval, dt_start, dt_end, 			 id_usage_cycle, tx_interval_status) 			   values (@id_usage_interval, @dt_start, @dt_end,@id_usage_cycle, 'N') 			 if ((@@error != 0) OR (@@rowcount != 1)) 			 begin 			   select @id_usage_interval = -99 			 end 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

					create procedure IsAccBillableNPayingForOthers(
						@id_acc int,
						@ref_date datetime,
						@status int output) 
					as
					begin
				 		-- step 1: Check if this account is billable first
						-- MT_ACCOUNT_IS_NOT_BILLABLE ((DWORD)0xE2FF0005L)
				 		if (dbo.IsAccountBillable(@id_acc) = 'N')
						  begin
							select @status = -486604795
							return
				 		  end 
				 		-- step 2: Now that this account is billable, check if this 
				 		-- account has any non paying subscribers (payees)
						-- MT_ACCOUNT_PAYING_FOR_OTHERS ((DWORD)0xE2FF0030L)
				 		if (dbo.IsAccountPayingForOthers(@id_acc,@ref_date) = 'Y')
						  begin
							select @status = -486604752
							return
				 		  end 
				 		-- success
						select @status = 1
						return
					end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE MTSP_RATE_AGGREGATE_CHARGE
@input_USAGE_INTERVAL int,
@input_TEMPLATE_ID int,
@input_FIRST_PASS_PV_VIEWID int,
@input_FIRST_PASS_PV_TABLE varchar(50),
@input_COUNTABLE_VIEWIDS varchar(2000),
@input_COUNTABLE_OJOINS varchar(2000),
@input_FIRST_PASS_PV_PROPERTIES_ALIASED varchar(2000),  --field names with alias
@input_COUNTABLE_PROPERTIES varchar(2000),                    --field names only
@input_COUNTER_FORMULAS varchar(2000),                  --counters
@input_ACCOUNT_FILTER varchar(2000),
@input_COMPOUND_ORDERING varchar(2000),
@input_COUNTER_FORMULAS_ALIASES varchar(2000),
@output_SQLStmt_SELECT varchar(4000) OUTPUT,
@output_SQLStmt_DROPTMPTBL1 varchar(200) OUTPUT,
@output_SQLStmt_DROPTMPTBL2 varchar(200) OUTPUT,
@return_code int OUTPUT
AS
BEGIN
/********************************************************************
** Procedure Name: MTSP_RATE_AGGREGATE_CHARGE
** 
** Procedure Description: 
**
** Parameters: 
**
** Returns: 0 if successful
**          -1 if fatal error occurred
**
** Created By: Ning Zhuang
** Created On: 1/8/2002
** Last Modified On: 6/12/2002
** Last Modified On: 6/10/2002
**
**********************************************************************/
DECLARE
@au_id_usage_interval int,
@au_id_usage_cycle int,
@au_bc_dt_start datetime,
@au_bc_dt_end datetime,
@ag_dt_start datetime,
@SQLStmt nvarchar(4000),
@tmp_tbl_name_base varchar(50),
@tmp_tbl_name1 varchar(50),
@tmp_tbl_name12 varchar(50),
@tmp_tbl_name2 varchar(50),
@tmp_tbl_name3 varchar(50),
@debug_flag bit,
@SQLError int
SET NOCOUNT ON
SET @debug_flag = 1
IF @debug_flag = 1 
BEGIN
	--PRINT 'Starting...' + CONVERT(char, getdate(), 109)
	INSERT INTO t_sys_track_adapter_run (adapter_type, action_datetime, action_desc) 
	VALUES ('AggRate', getdate(), 'Started at ' + CONVERT(char, getdate(), 109))
	SELECT @SQLError = @@ERROR
	IF @SQLError <> 0 GOTO FatalError
END
------------------------------------------
-- Construct the temp. table names
------------------------------------------
SET @tmp_tbl_name_base = REPLACE(REPLACE(REPLACE(REPLACE
	(RTRIM(CAST(@@SPID AS CHAR) + '_' + CONVERT(CHAR, getdate(), 121)),
	 ' ', ''), ':', ''), '.', ''), '-','')
SET @tmp_tbl_name1 = 't' + @tmp_tbl_name_base + '_1'
SET @tmp_tbl_name12 = 't' + @tmp_tbl_name_base + '_12'
SET @tmp_tbl_name2 = 't' + @tmp_tbl_name_base + '_2'
SET @tmp_tbl_name3 = 't' + @tmp_tbl_name_base + '_3'
------------------------------------------
-- Obtain the billing start and end dates:
-- One billing interval has only one pair of start and end dates
-- Retrieve and then store them in local variables
-----------------------------------------------
SELECT
	@au_id_usage_interval=ui.id_interval,
	@au_id_usage_cycle=ui.id_usage_cycle,
	@au_bc_dt_start=ui.dt_start,
	@au_bc_dt_end=ui.dt_end
FROM 
	t_usage_interval ui
WHERE
	ui.id_interval = @input_USAGE_INTERVAL
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
IF @debug_flag = 1 
BEGIN
	--PRINT 'After selecting from the t_usage_interval table: '+ CONVERT(char, getdate(), 109)
	INSERT INTO t_sys_track_adapter_run (adapter_type, action_datetime, action_desc) 
	VALUES ('AggRate', getdate(), 'After selecting from the t_usage_interval table: ' + CONVERT(char, getdate(), 109))
	SELECT @SQLError = @@ERROR
	IF @SQLError <> 0 GOTO FatalError
END
--PRINT @au_id_usage_interval
--PRINT @au_id_usage_cycle
--PRINT @au_bc_dt_start
--PRINT @au_bc_dt_end
--PRINT ' '
--PRINT 'started: to obtain the earliest aggragate starting date'
--PRINT CONVERT(char, getdate(), 109)
-----------------------------------------------
-- Obtain the earliest aggragate starting date:
-- Modified on 5/31/02 to take the group sub into consideration
-----------------------------------------------
SELECT au.dt_session, 
ag.id_usage_cycle id_pc_cycle,
ISNULL(gs.id_usage_cycle,auc.id_usage_cycle) id_usage_cycle
INTO #tmp1
FROM 
	t_acc_usage au
	INNER JOIN t_acc_usage_cycle auc ON auc.id_acc = au.id_payee
	LEFT OUTER JOIN t_gsubmember gsm ON gsm.id_acc = au.id_payee
		AND au.dt_session BETWEEN gsm.vt_start AND gsm.vt_end
	LEFT OUTER JOIN t_group_sub gs ON gs.id_group = gsm.id_group,
	t_usage_interval ui,
	t_aggregate ag
WHERE
	au.id_view = @input_FIRST_PASS_PV_VIEWID AND
	au.id_usage_interval = @input_USAGE_INTERVAL AND
	au.id_pi_template = @input_TEMPLATE_ID AND
	ui.id_interval = au.id_usage_interval AND
	ui.id_interval = @input_USAGE_INTERVAL AND
	ag.id_prop = ISNULL(au.id_pi_instance, au.id_pi_template)
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
SELECT @ag_dt_start = MIN(CASE WHEN tmp1.id_pc_cycle IS NULL THEN ui.dt_start ELSE pci.dt_start END)
FROM #tmp1 tmp1
	LEFT OUTER JOIN t_pc_interval pci ON pci.id_cycle = tmp1.id_pc_cycle 
		AND tmp1.dt_session BETWEEN pci.dt_start AND pci.dt_end 
	LEFT OUTER JOIN t_usage_interval ui ON ui.id_usage_cycle = tmp1.id_usage_cycle 
		AND tmp1.dt_session BETWEEN ui.dt_start AND ui.dt_end 
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
DROP TABLE #tmp1
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
IF @debug_flag = 1 
BEGIN
	--PRINT 'After selecting the minimum pci.dt_start: ' + CONVERT(char, getdate(), 109)
	INSERT INTO t_sys_track_adapter_run (adapter_type, action_datetime, action_desc) 
	VALUES ('AggRate', getdate(), 'After selecting the minimum pci.dt_start: ' + CONVERT(char, getdate(), 109))
	SELECT @SQLError = @@ERROR
	IF @SQLError <> 0 GOTO FatalError
END
--PRINT @ag_dt_start
--PRINT 'completed: to obtain the earliest aggragate starting date'
--PRINT CONVERT(char, getdate(), 109)
-----------------------------------------------
-- If no aggregate cycle then use billing cycle
IF @ag_dt_start IS NULL SET @ag_dt_start = @au_bc_dt_start
--PRINT @ag_dt_start
----------------------------------------------------------------
-- Firstpass records
----------------------------------------------------------------
SET @SQLStmt = ''
SET @SQLStmt =
N'SELECT
	au.id_sess,
	au.id_acc,
	au.id_payee,
	au.dt_session,
	ui.dt_start ui_dt_start,
	ui.dt_end ui_dt_end,
	-- Changed on 5/3, 5/6/2002 to take the group subscription dates into consideration
	CASE WHEN 
		gsm.id_group IS NOT NULL AND gs.b_supportgroupops = ''Y''
		THEN 1 ELSE 0 
	END group_acc_flag,
	CASE WHEN
		gsm.id_group IS NOT NULL AND gs.b_supportgroupops = ''Y''
		THEN gsm.id_group ELSE au.id_payee 
	END group_acc_id,
	ag.id_usage_cycle pci_id_cycle,
	ISNULL(gs.id_usage_cycle,auc.id_usage_cycle) ui_id_cycle
INTO ' + CAST(@tmp_tbl_name12 AS nvarchar(50)) + N' 
FROM
	t_acc_usage au
	INNER JOIN t_acc_usage_cycle auc ON auc.id_acc = au.id_payee
	-- Changed on 5/3 to take the group subscription dates into consideration
	LEFT OUTER JOIN t_gsubmember gsm ON gsm.id_acc = au.id_payee
		AND au.dt_session BETWEEN gsm.vt_start AND gsm.vt_end
	LEFT OUTER JOIN t_group_sub gs ON gs.id_group = gsm.id_group,
	t_usage_interval ui,
	t_aggregate ag
WHERE
	au.id_view = @dinput_FIRST_PASS_PV_VIEWID AND
	au.id_usage_interval = @dinput_id_usage_interval AND
	au.id_pi_template = @dinput_TEMPLATE_ID AND
	ui.id_interval = au.id_usage_interval AND
	ag.id_prop = ISNULL(au.id_pi_instance, au.id_pi_template) AND
	au.dt_session BETWEEN @dag_dt_start AND @dau_bc_dt_end '
	+ CAST(@input_ACCOUNT_FILTER AS nvarchar(2000)) 
--PRINT @SQLStmt
EXEC sp_executesql @SQLStmt,
N'@dinput_FIRST_PASS_PV_VIEWID int, @dinput_id_usage_interval int,@dinput_TEMPLATE_ID int, @dau_bc_dt_start datetime, @dau_bc_dt_end datetime, @dag_dt_start datetime',
@input_FIRST_PASS_PV_VIEWID, @input_USAGE_INTERVAL, @input_TEMPLATE_ID, @au_bc_dt_start, @au_bc_dt_end, @ag_dt_start
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
SET @SQLStmt = ''
SET @SQLStmt =
N'SELECT
	tmp.id_sess,
	tmp.id_acc,
	tmp.id_payee,
	tmp.dt_session,
	tmp.ui_dt_start,
	tmp.ui_dt_end,
	CASE WHEN pci.id_cycle IS NOT NULL THEN pci.dt_start ELSE ui.dt_start END pci_dt_start,
	CASE WHEN pci.id_cycle IS NOT NULL THEN pci.dt_end ELSE ui.dt_end END pci_dt_end,
	tmp.group_acc_flag,
	tmp.group_acc_id
INTO ' + CAST(@tmp_tbl_name1 AS nvarchar(50)) + N' 
FROM ' + CAST(@tmp_tbl_name12 AS nvarchar(50)) + N' tmp 
	LEFT OUTER JOIN t_pc_interval pci ON pci.id_cycle = tmp.pci_id_cycle 
		AND tmp.dt_session BETWEEN pci.dt_start AND pci.dt_end 
	LEFT OUTER JOIN t_usage_interval ui ON ui.id_usage_cycle = tmp.ui_id_cycle 
		AND tmp.dt_session BETWEEN ui.dt_start AND ui.dt_end '
--PRINT @SQLStmt
EXEC sp_executesql @SQLStmt,
N'@dinput_FIRST_PASS_PV_VIEWID int, @dinput_id_usage_interval int,@dinput_TEMPLATE_ID int, @dau_bc_dt_start datetime, @dau_bc_dt_end datetime, @dag_dt_start datetime',
@input_FIRST_PASS_PV_VIEWID, @input_USAGE_INTERVAL, @input_TEMPLATE_ID, @au_bc_dt_start, @au_bc_dt_end, @ag_dt_start
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
IF @debug_flag = 1 
BEGIN
	--PRINT 'After inserting to the zn_ningtemp table: '+ CONVERT(char, getdate(), 109)
	INSERT INTO t_sys_track_adapter_run (adapter_type, action_datetime, action_desc) 
	VALUES ('AggRate', getdate(), 'After inserting to the zn_ningtemp table: '+ CONVERT(char, getdate(), 109))
	SELECT @SQLError = @@ERROR
	IF @SQLError <> 0 GOTO FatalError
END
--PRINT 'completed: to obtain the firstpass records'
--PRINT CONVERT(char, getdate(), 109)
SET @SQLStmt = 'DROP TABLE ' + @tmp_tbl_name12
EXEC sp_executesql @SQLStmt
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
----------------------------------------------------------------
-- Counter records
----------------------------------------------------------------
SET @SQLStmt = ''
IF RTRIM(@input_COUNTABLE_VIEWIDS) = '' OR @input_COUNTABLE_VIEWIDS IS NULL
BEGIN
SET @SQLStmt =
N'SELECT
	au.id_sess,
	au.id_acc,
	au.id_payee,
	au.dt_session,
	au.id_pi_template,
	ui.dt_start ui_dt_start,
	ui.dt_end ui_dt_end,
	--Changed on 5/3 to take the group subscription dates into consideration
	CASE WHEN 
		gsm.id_group IS NOT NULL AND gs.b_supportgroupops = ''Y''
		THEN 1 ELSE 0 
	END group_acc_flag,
	CASE WHEN
		gsm.id_group IS NOT NULL AND gs.b_supportgroupops = ''Y''
		THEN gsm.id_group ELSE au.id_payee 
	END group_acc_id '
	+ CAST(@input_COUNTABLE_PROPERTIES AS nvarchar(2000)) 
	+ N' 
INTO ' + CAST(@tmp_tbl_name2 AS nvarchar(50)) + N' 
FROM
	t_acc_usage au 
	--Changed on 5/3 to take the group subscription dates into consideration
	LEFT OUTER JOIN t_gsubmember gsm ON gsm.id_acc = au.id_payee
		AND au.dt_session BETWEEN gsm.vt_start AND gsm.vt_end
	LEFT OUTER JOIN t_group_sub gs ON gs.id_group = gsm.id_group ' + CAST(@input_COUNTABLE_OJOINS AS nvarchar(2000)) + N',
	t_usage_interval ui,
	t_aggregate ag
WHERE
	au.id_view IS NULL AND
	--au.id_usage_interval = @dinput_id_usage_interval AND
	ui.id_interval = au.id_usage_interval AND
	ag.id_prop = ISNULL(au.id_pi_instance, au.id_pi_template) AND
	au.dt_session BETWEEN @dag_dt_start AND @dau_bc_dt_end '
	+ CAST(@input_ACCOUNT_FILTER AS nvarchar(2000)) 
END
ELSE
BEGIN
SET @SQLStmt =
N'SELECT
	au.id_sess,
	au.id_acc,
	au.id_payee,
	au.dt_session,
	au.id_pi_template,
	ui.dt_start ui_dt_start,
	ui.dt_end ui_dt_end,
	--Changed on 5/3 to take the group subscription dates into consideration
	CASE WHEN 
		gsm.id_group IS NOT NULL AND gs.b_supportgroupops = ''Y''
		THEN 1 ELSE 0 
	END group_acc_flag,
	CASE WHEN
		gsm.id_group IS NOT NULL AND gs.b_supportgroupops = ''Y''
		THEN gsm.id_group ELSE au.id_payee 
	END group_acc_id '
	+ CAST(@input_COUNTABLE_PROPERTIES AS nvarchar(2000)) 
	+ N' 
INTO ' + CAST(@tmp_tbl_name2 AS nvarchar(50)) + N' 
FROM
	t_acc_usage au 
	--Changed on 5/3 to take the group subscription dates into consideration
	LEFT OUTER JOIN t_gsubmember gsm ON gsm.id_acc = au.id_payee
		AND au.dt_session BETWEEN gsm.vt_start AND gsm.vt_end
	LEFT OUTER JOIN t_group_sub gs ON gs.id_group = gsm.id_group ' + CAST(@input_COUNTABLE_OJOINS AS nvarchar(2000)) + N',
	t_usage_interval ui,
	t_aggregate ag
WHERE
	(au.id_view IS NULL OR au.id_view in (' + CAST(@input_COUNTABLE_VIEWIDS AS nvarchar(2000)) + N')) AND
	--au.id_usage_interval = @dinput_id_usage_interval AND
	ui.id_interval = au.id_usage_interval AND
	ag.id_prop = ISNULL(au.id_pi_instance, au.id_pi_template) AND
	au.dt_session BETWEEN @dag_dt_start AND @dau_bc_dt_end '
	+ CAST(@input_ACCOUNT_FILTER AS nvarchar(2000)) 
END
--PRINT @SQLStmt
EXEC sp_executesql @SQLStmt,
N'@dau_bc_dt_end datetime, @dag_dt_start datetime',
@au_bc_dt_end, @ag_dt_start
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
IF @debug_flag = 1 
BEGIN
	--PRINT 'After inserting to the zn_ningtemp1 table: '+ CONVERT(char, getdate(), 109)
	INSERT INTO t_sys_track_adapter_run (adapter_type, action_datetime, action_desc) 
	VALUES ('AggRate', getdate(), 'After inserting to the zn_ningtemp1 table: '+ CONVERT(char, getdate(), 109))
	SELECT @SQLError = @@ERROR
	IF @SQLError <> 0 GOTO FatalError
END
--PRINT 'completed: to obtain the counter records'
--PRINT CONVERT(char, getdate(), 109)
----------------------------------------------------------------
-- Calculate the counters
----------------------------------------------------------------
SET @SQLStmt = ''
--Changed on 5/3 to take the group subscription dates into consideration
SET @SQLStmt = 
N'SELECT tp1.id_sess ' + @input_COUNTER_FORMULAS + N' 
INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) 
+ N' FROM ' + CAST(@tmp_tbl_name1 AS nvarchar(50)) 
+ N' tp1 LEFT OUTER JOIN ' + CAST(@tmp_tbl_name2 AS nvarchar(50)) 
+ N' tp2 ON tp2.group_acc_flag = tp1.group_acc_flag AND tp2.group_acc_id = tp1.group_acc_id
	AND tp2.id_pi_template = @dinput_TEMPLATE_ID
	AND tp2.dt_session BETWEEN tp1.pci_dt_start AND tp1.pci_dt_end
	AND (tp2.ui_dt_end < tp1.ui_dt_end 
		OR (tp2.ui_dt_end = tp1.ui_dt_end 
		AND tp2.dt_session < tp1.dt_session)
		OR (tp2.ui_dt_end = tp1.ui_dt_end 
		AND tp2.dt_session = tp1.dt_session 
		AND tp2.id_sess < tp1.id_sess))
GROUP BY tp1.id_sess'
--PRINT @SQLStmt
EXEC sp_executesql @SQLStmt,
N'@dinput_TEMPLATE_ID int', @input_TEMPLATE_ID
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
IF @debug_flag = 1 
BEGIN
	--PRINT 'After inserting to the zn_ningtemp2 table: '+ CONVERT(char, getdate(), 109)
	INSERT INTO t_sys_track_adapter_run (adapter_type, action_datetime, action_desc) 
	VALUES ('AggRate', getdate(), 'After inserting to the zn_ningtemp2 table: '+ CONVERT(char, getdate(), 109))
	SELECT @SQLError = @@ERROR
	IF @SQLError <> 0 GOTO FatalError
END
--PRINT 'completed: to obtain the agg counters'
--PRINT CONVERT(char, getdate(), 109)
----------------------------------------------------------------
-- Retrieve the result set
----------------------------------------------------------------
SET @SQLStmt = ''
SET @SQLStmt = 
N'--INSERT INTO zn_ningtemp3 
SELECT tp1.id_sess, au.id_parent_sess, 
   au.id_view AS c_ViewId, 
   tp1.id_acc AS c__PayingAcount,
   tp1.id_payee AS c__AccountID, 
   au.dt_crt AS c_CreationDate, 
   tp1.dt_session AS c_SessionDate '
	+ CAST(@input_FIRST_PASS_PV_PROPERTIES_ALIASED AS nvarchar(2000)) 
	+ CAST(@input_COUNTER_FORMULAS_ALIASES AS nvarchar(2000)) + N',
   au.id_pi_template AS c__PriceableItemTemplateID, 
   au.id_pi_instance AS c__PriceableItemInstanceID, 
   au.id_prod AS c__ProductOfferingID, 
   tp1.ui_dt_start AS c_BillingIntervalStart, 
   tp1.ui_dt_end AS c_BillingIntervalEnd, 
   tp1.pci_dt_start AS c_AggregateIntervalStart, 
   tp1.pci_dt_end AS c_AggregateIntervalEnd
FROM ' + CAST(@tmp_tbl_name1 AS nvarchar(50)) + N' tp1, ' 
	+ CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' tp2, t_acc_usage au INNER JOIN ' 
	+ CAST(@input_FIRST_PASS_PV_TABLE AS nvarchar(2000))
	+ N' firstpasspv on firstpasspv.id_sess = au.id_sess
WHERE tp2.id_sess = tp1.id_sess
AND au.id_sess = tp1.id_sess
ORDER BY ' + CAST(@input_COMPOUND_ORDERING AS nvarchar(2000)) + N' tp1.id_acc, tp1.dt_session'
SET @output_SQLStmt_SELECT = @SQLStmt
SET @SQLStmt = 'DROP TABLE ' + @tmp_tbl_name2
EXEC sp_executesql @SQLStmt
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
SET @output_SQLStmt_DROPTMPTBL1 = 'DROP TABLE ' + @tmp_tbl_name1
SET @output_SQLStmt_DROPTMPTBL2 = 'DROP TABLE ' + @tmp_tbl_name3
IF @debug_flag = 1 
BEGIN
	--PRINT 'Completed at: ' + CONVERT(char, getdate(), 109)
	INSERT INTO t_sys_track_adapter_run (adapter_type, action_datetime, action_desc) 
	VALUES ('AggRate', getdate(), 'Completed at: '+ CONVERT(char, getdate(), 109))
	SELECT @SQLError = @@ERROR
	IF @SQLError <> 0 GOTO FatalError
END
--PRINT 'completed: all'
--PRINT CONVERT(char, getdate(), 109)
SET @return_code = 0
RETURN 0
FatalError:
	IF @debug_flag = 1 
	BEGIN 
		INSERT INTO t_sys_track_adapter_run (adapter_type, action_datetime, action_desc) VALUES
		('AggRate', getdate(), 'Completed abnormally at: '+ CONVERT(char, getdate(), 109))
		SET @return_code = -1
		RETURN -1
	END
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE MT_SYS_ANALYZE_ALL_TABLES (@varStatPercent int)
AS
BEGIN
/********************************************************************
** Procedure Name: MT_SYS_ANALYZE_ALL_TABLES
** 
** Procedure Description: Analyze all the user defined tables in the current schema.
**
** Parameters: varStatPercent int
**
** Returns: 0 if successful
**          1 if fatal error occurred
**
** Created By: Ning Zhuang
** Created On: 9/20/2001
**
**********************************************************************/
DECLARE @varTblName varchar(50), @SQLStmt varchar(1000), @SQLError int,
	@PrintStmt varchar(1000), @varStatPercentChar varchar(200)
SET NOCOUNT ON
IF @varStatPercent < 5
	SET @varStatPercentChar = ' WITH SAMPLE 5 PERCENT '
ELSE IF @varStatPercent >= 100 
	SET @varStatPercentChar = ' WITH FULLSCAN '
ELSE SET @varStatPercentChar = ' WITH SAMPLE ' 
	+ CAST(@varStatPercent AS varchar(20)) 
	+ ' PERCENT '
DECLARE curUserObjs CURSOR FOR
SELECT name
FROM sysobjects
WHERE type = 'U'
ORDER BY name
SELECT @SQLError = @@ERROR
IF @SQLError <> 0
	RETURN 1
OPEN curUserObjs 
SELECT @SQLError = @@ERROR
IF @SQLError <> 0
	RETURN 1
FETCH curUserObjs INTO @varTblName
WHILE @@FETCH_STATUS <> -1
BEGIN
	IF @@FETCH_STATUS <> -2
	BEGIN
		SET @SQLStmt = 'UPDATE STATISTICS ' + @varTblName + @varStatPercentChar
		PRINT @SQLStmt
		EXECUTE (@SQLStmt)
		SELECT @SQLError = @@ERROR
		IF @SQLError <> 0 RETURN 1
	END
	FETCH curUserObjs INTO @varTblName
END
CLOSE curUserObjs 
DEALLOCATE curUserObjs 
PRINT 'Statistics have been updated for all tables.'
RETURN 0
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create procedure MoveAccount 
							(@p_id_ancestor int,
   				     @p_id_descendent int,
               @p_dt_start datetime,
					     @status int output)
	as
  begin
	declare @realstartdate as datetime
	declare @id_old_parent as int
	declare @varMaxDateTime as datetime
	declare @AccCreateDate as datetime
	declare @maxlevel as int
	declare @currentlevel as int
  select @realstartdate = dbo.mtstartofday(@p_dt_start) 
  select @varMaxDateTime = dbo.MTMaxDate()
	select @AccCreateDate = 
	dbo.mtminoftwodates(dbo.mtstartofday(ancestor.dt_crt),dbo.mtstartofday(descendent.dt_crt))
	from t_account ancestor,t_account descendent where ancestor.id_acc = @p_id_ancestor and
	descendent.id_acc = @p_id_descendent
	if dbo.mtstartofday(@p_dt_start) < dbo.mtstartofday(@AccCreateDate)  begin
		-- MT_CANNOT_MOVE_ACCOUNT_BEFORE_START_DATE
		select @status = -486604750
		return
	end 
				-- step : make sure that the new ancestor is not actually a child
	select @status = count(*) 
	from t_account_ancestor 
	where id_ancestor = @p_id_descendent 
	and id_descendent = @p_id_ancestor AND 
  @realstartdate between vt_start AND vt_end
	if @status > 0 
   begin 
		-- MT_NEW_PARENT_IS_A_CHILD
	 select @status = -486604797
	 return
   end 
      -- step : make sure that the account is not archived or closed
  select @status = count(*)  from t_account_state 
  where id_acc = @p_id_Descendent
	and (dbo.IsClosed(@status) = 1 OR dbo.isArchived(@status) = 1) 
	and @realstartdate between vt_start AND vt_end
  if (@status > 0 )
	 begin
   -- OPERATION_NOT_ALLOWED_IN_CLOSED_OR_ARCHIVED
   select @status = -469368827
   end 
	-- step : make sure that the account is not a corporate account
if (dbo.iscorporateaccount(@p_id_descendent,@p_dt_start) = 1)
	-- MT_CANNOT_MOVE_CORPORATE_ACCOUNT
		begin
		select @status = -486604770
		return
		end 
	if dbo.IsInSameCorporateAccount(@p_id_ancestor,@p_id_descendent,@realstartdate) <> 1 begin
		-- MT_CANNOT_MOVE_BETWEEN_CORPORATE_HIERARCHIES
		select @status = -486604759
		return
	end
	-------------------------------------------------------------------------
	 -- end of business rules
	-------------------------------------------------------------------------
	-- step : make sure that the account to be moved does not have a pending move 
	-- in the future.  
	select @status = count(*) 
	from t_account_ancestor 
	where id_descendent = @p_id_descendent  
	AND	vt_start >= @realstartdate
	if @status > 0 
	begin
		-- calculate how many levels of hierarchy we have beneath the current descendent
		select @maxlevel = MAX(num_generations)+1 from t_account_ancestor
		where id_ancestor = @p_id_descendent AND 
		((@realstartdate between vt_start AND vt_end) OR @realstartdate > vt_start)
		-- delete all descendents of the target account EXCEPT for the record that points
		-- to the immediate parent.
		-- create a temporary list for processing the number of descendents we need to deal with.
		-- It is necessary to create temporary storage because we can't necessarily write
		-- a query to no exactly what nodes to process!  We essentially need to rebuild the
		-- tree from the parent child relationship for the nodes in question.
		create table #processlist (id_acc int,num_generations int)
		insert into #processlist (id_acc,num_generations)
		select id_descendent,num_generations from t_account_ancestor 
		where id_ancestor = @p_id_descendent AND num_generations <> 0 
		delete parent_list
		 from t_account_ancestor existing_children
		-- move_list is the list of all descendents of the ancestors where we get only their direct ancestor
		INNER JOIN t_account_ancestor parent_list on parent_list.id_descendent = existing_children.id_descendent
		AND parent_list.num_generations not in (0,1) 
		where existing_children.id_ancestor = @p_id_descendent
		if dbo.mtstartofday(@p_dt_start) = dbo.mtstartofday(@AccCreateDate) begin
			delete from t_account_ancestor where id_descendent = @p_id_descendent
			exec AddAccToHierarchy @p_id_ancestor,@p_id_descendent,@realstartdate,@varMaxDateTime,@AccCreateDate,@status OUTPUT
		end
		else begin
			delete from t_account_ancestor where id_descendent = @p_id_Descendent AND num_generations <> 0 AND
			@realstartdate <= vt_start
			insert into t_account_ancestor (id_ancestor,id_descendent,num_generations,b_children,vt_start,vt_end,tx_path)
			values (@p_id_ancestor,@p_id_descendent,1,'N',@realstartdate,dbo.mtmaxdate(),
			dbo.mtconcat(CAST(@p_id_ancestor as varchar(100)),dbo.mtconcat('/',cast(@p_id_descendent as varchar(100)))))
			-- check if we need to update any existing end_dates.
			update t_account_ancestor set vt_end = dbo.subtractsecond(@realstartdate)
			where id_descendent = @p_id_descendent AND num_generations = 1 ANd
			@realstartdate between vt_start AND vt_end AND vt_end <> @VarMaxDateTime
			-- this query is redudant from below
			insert into t_account_ancestor (id_ancestor,id_descendent,
			num_generations,vt_start,vt_end,tx_path) 
			select
			new_parents.id_ancestor new_ancestor,
			level_children.id_descendent existing_descendent,
			new_parents.num_generations + 1,
			dbo.mtmaxoftwodates(new_parents.vt_start,level_children.vt_start),
			dbo.mtminoftwodates(new_parents.vt_end,level_children.vt_end),
			case when new_parents.id_descendent = 1 then
			new_parents.tx_path + level_children.tx_path
			else
			new_parents.tx_path + '/' + CAST(level_children.id_descendent as varchar(50)) 
			end 
			from (select id_ancestor id_acc from t_account_ancestor where id_descendent = @p_id_descendent 
					AND num_generations <> 1) process_list
			INNER JOIN t_account_ancestor level_children on level_children.id_descendent = process_list.id_acc AND 
			level_children.num_generations = 1 
			INNER JOIN t_account_ancestor new_parents on new_parents.id_descendent = level_children.id_ancestor
			AND new_parents.num_generations > 0 
		end
		-- iterate through each level downwards, adding back the parent records.
		select @currentlevel = 1
		while(@currentlevel <= @maxlevel) begin
			insert into t_account_ancestor (id_ancestor,id_descendent,
			num_generations,vt_start,vt_end,tx_path) 
			select
			new_parents.id_ancestor new_ancestor,
			level_children.id_descendent existing_descendent,
			new_parents.num_generations +1, 
			dbo.mtmaxoftwodates(new_parents.vt_start,level_children.vt_start),
			dbo.mtminoftwodates(new_parents.vt_end,level_children.vt_end),
			case when new_parents.id_descendent = 1 then
			new_parents.tx_path + level_children.tx_path
			else
			new_parents.tx_path + '/' + CAST(level_children.id_descendent as varchar(50)) 
			end 
			from #processlist process_list
			INNER JOIN t_account_ancestor level_children on level_children.id_descendent = process_list.id_acc AND 
			level_children.num_generations = 1
			INNER JOIN t_account_ancestor new_parents on new_parents.id_descendent = level_children.id_ancestor
			AND new_parents.num_generations > 0 
			where 
			process_list.num_generations = @currentlevel AND
			dbo.mtminoftwodates(new_parents.vt_end,level_children.vt_end) > dbo.mtmaxoftwodates(new_parents.vt_start,level_children.vt_start)
			select @currentlevel = @currentlevel + 1
		end
	end 
	else begin
		-- step : get the old parent for the descendent
		select @id_old_parent = id_ancestor
		from t_account_ancestor where
		id_descendent = @p_id_descendent and num_generations = 1 AND
	  @realstartdate between vt_start and vt_end
		 -- step : update the existing entry for the descendent's sub hierarchy AND
		 -- the existing descendent.  This probably can be rewritten as a join
		 -- but I don't have time right now.
		update t_account_ancestor
		 -- very important... we subtract a second so that the dates are not identical
		set vt_end = case when vt_start = @realstartdate then @realstartdate else dbo.SubtractSecond(@realstartdate) end
		where id_descendent in ( -- sub select to find matching accounts
		select id_descendent from t_account_ancestor where
		id_ancestor = @p_id_descendent AND num_generations <> 0 AND
	  @realstartdate between vt_start AND vt_end
		UNION ALL
		select @p_id_descendent 
		)
	  AND id_ancestor in 
	  (select id_ancestor from t_account_ancestor where id_descendent = @p_id_descendent AND
	  num_generations > 0 AND @realstartdate between vt_start AND vt_end) AND
	  @realstartdate between vt_start AND vt_end
			 -- step : insert the entries into t_account_ancestor.  We need to insert 
			 -- the parent and all of its ancestors into the descendent and all of its
			 -- children
		 insert into t_account_ancestor
		 (id_ancestor,id_descendent,num_generations,b_children,vt_start,vt_end,tx_path)
			select
			 -- the list of of ancestors
			parent.id_ancestor,
			existing_children.id_descendent,
			existing_children.num_generations + parent.num_generations + 1,
			existing_children.b_Children,
			dbo.MTMaxOfTwoDates(parent.vt_start,@realstartdate) startdate,
			parent.vt_end,
			case when parent.id_descendent = 1 then
	    parent.tx_path + existing_children.tx_path
	    else
	    parent.tx_path + '/' + existing_children.tx_path
	    end
			from 
			t_account_ancestor parent,t_account_ancestor existing_children
			where parent.id_descendent = @p_id_ancestor AND 
	    ((@realstartdate between parent.vt_start AND parent.vt_end) OR parent.vt_start >= @realstartdate) AND
			-- the existing children of p_id_descendent
			existing_children.id_ancestor = @p_id_descendent AND
	   	((@realstartdate between existing_children.vt_start AND existing_children.vt_end) OR existing_children.vt_start >= @realstartdate)
	end
select @status = 1
end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

		      create proc PIResolutionByID(
		      @dt_session DATETIME, @id_pi_template INTEGER, @id_acc INTEGER)
		      as
		      select 
		      typemap.id_po,
		      typemap.id_pi_instance,
		      sub.id_sub
		      from
		      -- select out the instances from the pl map (either need to follow 
		      -- up with a group by or assume one param table or add a unique entry
		      -- with a null param table/price list; I am assuming the null entry exists)
		      t_pl_map typemap 
		      -- Now that we have the correct list of instances we match them up with the
		      -- accounts on the billing interval being processed.  For each account grab the
		      -- information about the billing interval dates so that we can select the 
		      -- correct intervals to process.
		      -- Go get all subscriptions product offerings containing the proper discount
		      -- instances
		      , t_sub sub 
		      -- Go get the effective date of the subscription to the discount
		      where
		      -- Join criteria for t_sub
		      typemap.id_po = sub.id_po
		      -- join criteria for t_sub to t_effective_date
		      -- Find the subscription which contains the dt_session; there should be
		      -- at most one of these.
		      and (sub.vt_start <= @dt_session)
		      and (sub.vt_end >= @dt_session)
		      -- Select the unique instance record that includes an instance in a template
		      and typemap.id_paramtable is null
		      and typemap.id_pi_template = @id_pi_template
		      and sub.id_acc = @id_acc

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

		      create proc PIResolutionByName(
		      @dt_session DATETIME, @nm_name VARCHAR(255), @id_acc INTEGER)
		      as
		      select 
		      typemap.id_po,
		      typemap.id_pi_instance,
		      sub.id_sub
		      from
		      -- select out the instances from the pl map (either need to follow 
		      -- up with a group by or assume one param table or add a unique entry
		      -- with a null param table/price list; I am assuming the null entry exists)
		      t_pl_map typemap 
		      -- Now that we have the correct list of instances we match them up with the
		      -- accounts on the billing interval being processed.  For each account grab the
		      -- information about the billing interval dates so that we can select the 
		      -- correct intervals to process.
		      -- Go get all subscriptions product offerings containing the proper discount
		      -- instances
		      , t_sub sub 
		      -- Go get the effective date of the subscription to the discount
		      , t_base_props base
		      where
		      -- Join criteria for t_sub
		      typemap.id_po = sub.id_po
		      -- join criteria for t_sub to t_effective_date
		      -- Find the subscription which contains the dt_session; there should be
		      -- at most one of these.
		      and (sub.vt_start <= @dt_session)
		      and (sub.vt_end >= @dt_session)
		      -- Join template to base props
		      and base.id_prop=typemap.id_pi_template
		      -- Select the unique instance record that includes an instance in a template
		      and typemap.id_paramtable is null
		      and base.nm_name = @nm_name
		      and sub.id_acc = @id_acc

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

			create proc PropagateProperties(@table_name as varchar(100),
																			@update_list as varchar(8000),
																			@insert_list as varchar(8000),
																			@clist as varchar(8000),
																			@id_pi_template as int)
			as
			declare @CursorVar CURSOR
			declare @count as int
			declare @i as int
			declare @idInst as int
			set @i = 0
			set @CursorVar = CURSOR STATIC
				FOR select id_pi_instance from t_pl_map
						where id_pi_template = @id_pi_template and id_paramtable is null
			OPEN @CursorVar
			select @count = @@cursor_rows
			while @i < @count begin
				FETCH NEXT FROM @CursorVar into @idInst
				set @i = (select @i + 1)
				exec ExtendedUpsert @table_name, @update_list, @insert_list, @clist, @idInst
			end
			CLOSE @CursorVar
			DEALLOCATE @CursorVar

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

		    CREATE PROCEDURE PurgeAuditTable @dt_start varchar(255), 
		                                     @ret_code int OUTPUT
		    AS
		    BEGIN
			    DELETE FROM t_audit 
			    WHERE dt_crt <= @dt_start 
			    IF (@@error != 0)
			    BEGIN
				    SELECT @ret_code = -99
			    END
			    ELSE
			    BEGIN
				    SELECT @ret_code = 0
			    END
			END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

					create proc RemoveCounterInstance											@id_prop int					AS					BEGIN TRAN						DELETE FROM T_COUNTER_PARAMS WHERE id_counter = @id_prop						DELETE FROM T_COUNTER WHERE id_prop = @id_prop						DELETE FROM T_BASE_PROPS WHERE id_prop = @id_prop 					COMMIT TRAN
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

					CREATE PROC RemoveCounterPropDef											@id_prop int					AS						DECLARE @id_locale int					BEGIN TRAN						exec DeleteBaseProps @id_prop						DELETE FROM t_counter_map 							WHERE id_cpd = @id_prop 						DELETE FROM t_counterpropdef WHERE id_prop = @id_prop					COMMIT TRAN
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

				create procedure RemoveGroupSubMember(
				@id_acc int,
				@id_group int,
				@b_overrideDateCheck varchar,
        @p_systemdate datetime,
				@status int OUTPUT
				)
				as
				begin
				declare @startdate datetime
				declare @varMaxDateTime datetime
				select @varMaxDateTime = dbo.MTMaxDate()
				select @status = 0
				if (@b_overrideDateCheck = 'N')
					begin
					-- find the start date of the group subscription membership
					-- that exists at some point in the future.
					select @startdate  = vt_start from t_gsubmember
					where id_acc = @id_acc AND id_group = @id_group AND
					vt_start > @p_systemdate
					if (@startdate is null)
						begin
						select @status = -486604776
						return
						end
					end
			  delete from t_gsubmember where id_acc = @id_acc and id_group = @id_group
				update t_gsubmember_historical set tt_end = dbo.subtractsecond(@p_systemdate)
				where id_acc = @id_acc and id_group = @id_group  
				and tt_end = @varMaxDateTime
				--done
				select @status = 1
				end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

						CREATE PROCEDURE RemoveMemberFromRole
						(
            @aRoleID INT,
            @aAccountID INT,
            @status  INT OUTPUT
						)
						AS
						Begin
						declare @accType VARCHAR(3)
						declare @polID INT
						declare @bCSRAssignableFlag VARCHAR(1)
						declare @bSubscriberAssignableFlag VARCHAR(1)
						declare @scratch INT
						select @status = 1
						SELECT @polID = id_policy FROM T_PRINCIPAL_POLICY WHERE id_acc = @aAccountID AND policy_type = 'A'
	          -- make the stored proc idempotent, only remove mapping record if
	          -- it's there
							BEGIN
	            SELECT @scratch = id_policy FROM T_POLICY_ROLE WHERE id_policy = @polID 
							AND id_role = @aRoleID 
	            if (@scratch is null)
								begin
								  RETURN
								end
							END
						DELETE FROM T_POLICY_ROLE WHERE id_policy = @polID AND id_role = @aRoleID
						END 

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create procedure RemoveSubscription(
	@p_id_sub int,
	@p_systemdate datetime)
	as
	begin
 	declare @groupID int
	declare @maxdate datetime
	select @groupID = id_group,@maxdate = dbo.mtmaxdate()
	from t_sub where id_sub = @p_id_sub
  if (@groupID is not NULL)
		begin
		update t_gsubmember_historical set tt_end = @p_systemdate 
		where tt_end = @maxdate AND id_group = @groupID
		delete from t_gsubmember where id_group = @groupID
		-- note that we do not delete from t_group_sub
		end   
	delete from t_pl_map where id_sub = @p_id_sub
	delete from t_sub where id_sub = @p_id_sub
	update t_sub_history set tt_end = @p_systemdate
	where tt_end = @maxdate AND id_sub = @p_id_sub
	end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

			 create procedure SetTariffs (@id_enum_tariff varchar(255),			 @tx_currency varchar (255))	 			 as 			 if not exists (select * from t_tariff where id_enum_tariff = 			 @id_enum_tariff and tx_currency = @tx_currency) 			 begin 				 insert into t_tariff (id_enum_tariff, tx_currency) values (				 @id_enum_tariff, @tx_currency)			end
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

	create proc UndoAccounts @id_acc int, @nm_login nvarchar(255), @nm_space nvarchar(40) as          begin tran            if exists (select * from t_account_mapper where id_acc = @id_acc)              begin delete from t_account_mapper where id_acc = @id_acc end            if exists (select * from t_account where id_acc = @id_acc)              begin delete from t_account where id_acc = @id_acc end            if exists (select * from t_acc_usage_cycle where id_acc = @id_acc)              begin delete from t_acc_usage_cycle where id_acc = @id_acc end            if exists (select * from t_user_credentials where nm_login = @nm_login and nm_space = @nm_space)             begin delete from t_user_credentials where nm_login = @nm_login and nm_space = @nm_space end            if exists (select * from t_acc_usage_interval where id_acc = @id_acc)              begin delete from t_acc_usage_interval where id_acc = @id_acc end            if exists (select * from t_site_user where nm_login = @nm_login)			       begin delete from t_site_user where nm_login = @nm_login end            if exists (select * from t_av_internal where id_acc = @id_acc)              begin delete from t_av_internal where id_acc = @id_acc end          commit tran
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

				CREATE PROCEDURE UpdStateFromClosedToArchived (
					@system_date datetime,
					@age int,
					@status INT output)
				AS
				Begin
					declare @varMaxDateTime datetime
					declare @varSystemGMTDateTimeSOD datetime
					SELECT @status = -1
					-- Use the true current GMT time for the tt_ dates
					SELECT @varSystemGMTDateTimeSOD = dbo.mtstartofday(@system_date)
					-- Set the maxdatetime into a variable
					SELECT @varMaxDateTime = dbo.MTMaxDate()
					-- Save the id_acc
					CREATE TABLE #updatestate_1(id_acc int)
					INSERT INTO #updatestate_1 (id_acc)
					SELECT ast.id_acc 
					FROM t_account_state ast
					WHERE ast.vt_end = @varMaxDateTime
					AND ast.status = 'CL' 
					AND ast.vt_start <= @varSystemGMTDateTimeSOD - @age
					EXECUTE UpdateStateRecordSet
					@system_date,
					@varSystemGMTDateTimeSOD,
					'CL', 'AR',
					@status OUTPUT
					DROP TABLE #updatestate_1
					select @status=1
					RETURN
				END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create procedure UpdateAccount (
	@p_loginname varchar(255),
	@p_namespace varchar(40),
	@p_id_acc int,
	@p_acc_state varchar(2),
	@p_acc_state_ext int,
	@p_acc_statestart datetime,
	@p_tx_password varchar(64),
	@p_ID_CYCLE_TYPE int,
	@p_DAY_OF_MONTH  int,
	@p_DAY_OF_WEEK int,
	@p_FIRST_DAY_OF_MONTH int,
	@p_SECOND_DAY_OF_MONTH  int,
	@p_START_DAY int,
	@p_START_MONTH int,
	@p_START_YEAR int,
	@p_id_payer int,
	@p_payer_login varchar(255),	@p_payer_namespace varchar(40),
	@p_payer_startdate datetime,
	@p_payer_enddate datetime,
	@p_id_ancestor int,
	@p_ancestor_name varchar(255),
	@p_ancestor_namespace varchar(40),
	@p_hierarchy_movedate datetime,
	@p_systemdate datetime,
	@p_billable varchar,
	@p_status int output,
	@p_cyclechanged int output,
	@p_newcycle int output,
	@p_accountID int output,
	@p_hierarchy_path varchar(4000) output
	)
as
begin
	declare @accountID int
	declare @oldcycleID int
	declare @usagecycleID int
	declare @intervalenddate datetime
	declare @intervalID int
	declare @pc_start datetime
	declare @pc_end datetime
	declare @oldpayerstart datetime
	declare @oldpayerend datetime
	declare @oldpayer int
	declare @payerenddate datetime
	declare @payerID int
	declare @AncestorID int
	declare @payerbillable varchar(1)
	select @accountID = -1
	select @oldcycleID = 0
	select @p_status = 0
	-- step : resolve the account if necessary
	if (@p_id_acc is NULL) begin
		if (@p_loginname is not NULL and @p_namespace is not NULL) begin
			select @accountID = dbo.LookupAccount(@p_loginname,@p_namespace) 
			if (@accountID < 0) begin
				-- MTACCOUNT_RESOLUTION_FAILED
					select @p_status = -509673460
      end
		end
		else 
			begin
  	-- MTACCOUNT_RESOLUTION_FAILED
      select @p_status = -509673460
		end 
	end
	else
	begin
		select @accountID = @p_id_acc
	end 
	if (@p_status < 0) begin
		return
	end
 -- step : update the account password if necessary.  catch error
 -- if the account does not exist or the login name is not valid.  The system
 -- should check that both the login name, namespace, and password are 
 -- required to change the password.
	if (@p_loginname is not NULL and @p_namespace is not NULL and 
			@p_tx_password is not NULL)
			begin
			 update t_user_credentials set tx_password = @p_tx_password
				where nm_login = @p_loginname and nm_space = @p_namespace
			 if (@@rowcount = 0) 
	       begin
				 -- MTACCOUNT_FAILED_PASSWORD_UPDATE
				 select @p_status =  -509673461
         end
      end
			-- step : figure out if we need to update the account's billing cycle.  this
			-- may fail because the usage cycle information may not be present.
	begin
		select @usagecycleID = id_usage_cycle 
		from t_usage_cycle cycle where
	  cycle.id_cycle_type = @p_ID_CYCLE_TYPE 
		AND (@p_DAY_OF_MONTH = cycle.day_of_month or @p_DAY_OF_MONTH is NULL)
		AND (@p_DAY_OF_WEEK = cycle.day_of_week or @p_DAY_OF_WEEK is NULL)
		AND (@p_FIRST_DAY_OF_MONTH= cycle.FIRST_DAY_OF_MONTH  or @p_FIRST_DAY_OF_MONTH is NULL)
		AND (@p_SECOND_DAY_OF_MONTH = cycle.SECOND_DAY_OF_MONTH or @p_SECOND_DAY_OF_MONTH is NULL)
		AND (@p_START_DAY= cycle.START_DAY or @p_START_DAY is NULL)
		AND (@p_START_MONTH= cycle.START_MONTH or @p_START_MONTH is NULL)
		AND (@p_START_YEAR = cycle.START_YEAR or @p_START_YEAR is NULL)
    if (@usagecycleid is null)
		 begin
			SELECT @usagecycleID = -1
		 end
   end
	 select @oldcycleID = id_usage_cycle from
	 t_acc_usage_cycle where id_acc = @accountID
	 if (@oldcycleID <> @usagecycleID AND @usagecycleID <> -1)
	  begin
		-- step : update the account's billing cycle
			update t_acc_usage_cycle set id_usage_cycle = @usagecycleID
			where id_acc = @accountID
			-- step : delete any records in t_acc_usage_interval that
			-- exist in the future with the old interval
			delete from t_acc_usage_interval 
			where t_acc_usage_interval.id_acc = @accountID AND id_usage_interval IN 
			( 
			select id_interval from t_usage_interval ui
			INNER JOIN t_acc_usage_interval aui on t_acc_usage_interval.id_acc = @accountID AND
			aui.id_usage_interval = ui.id_interval
			where
			dt_start > @p_systemdate
			)
			-- step : delete any previous updates in t_acc_usage_interval 
			-- (only one can have dt-effective set) and the effective date is in 
			-- the future.
			delete from t_acc_usage_interval where dt_effective is not null 
			and id_acc = @accountID AND dt_effective >= @p_systemdate
			select @intervalenddate = ui.dt_end from t_acc_usage_interval aui
			INNER JOIN t_usage_interval ui on ui.id_interval = aui.id_usage_interval
			AND @p_systemdate between ui.dt_start AND ui.dt_end
		  where
			aui.id_acc = @AccountID
		-- step : figure out the new interval ID based on the end date
		-- of the existing interval  
			select @intervalID = id_interval,@pc_start = dt_start,@pc_end = dt_end 
			from 
			t_pc_interval where
			id_cycle = @usagecycleID AND
			dbo.addsecond(@intervalenddate) between dt_start AND dt_end
			  -- step : create new usage interval if it is missing.  Make sure we use
				-- the end date of the existing interval plus one second AND the new 
				-- interval id.
				-- populate the usage interval if necessary
			insert into t_usage_interval(id_interval,id_usage_cycle,dt_start,dt_end,
			                             tx_interval_status)
			select
			@intervalID,@usagecycleID,@pc_start,@pc_end,'N' --from t_usage_interval
			where 
			@intervalID not in (select id_interval from t_usage_interval)
				-- step : delete any records in t_acc_usage_interval that
				-- exist in the future with the old interval
			 -- step : create the t_acc_usage_interval mappings.  the new one is effective
				-- at the end of the interval.  We also must make sure to 
			-- populate t_acc_usage_interval with any other intervals in the future that
			-- may have been created by USM
			insert into t_acc_usage_interval (id_acc,id_usage_interval,tx_status,dt_effective)
			select @accountID,id_interval,'O',@intervalenddate
			from t_usage_interval
			where id_usage_cycle = @usagecycleID 
			-- this check is necessary if we are creating an association with an interval that begins
			-- in the past.  This could happen if you create a daily account on tuesday and then
			-- change to a weekly account (starting on monday) on Thursday.  not that the end date check is 
			-- only greater than because we want to avoid any intervals that have the same end date as
			-- @intervalenddate.  The second part of the condition is to pick up intervals that are in the future.
			and ((@intervalenddate >= dt_start AND @intervalenddate < dt_end) 
			or dt_start > @intervalenddate)
				-- indicate that the cycle changed
			select @p_newcycle = @UsageCycleID
			select @p_cyclechanged = 1
			 -- step : create intervals in the future where the systemdate is close
			 -- to the end of the interval
			exec CreateBoundaryIntervals @usagecycleID,@p_ID_CYCLE_TYPE,@pc_start,@pc_end,@p_systemdate
    end
	else
  -- indicate to the caller that the cycle did not change
  begin
    select @p_cyclechanged = 0
  end
		-- step : update the payment redirection information.  Only update
		-- the payment information if the payer and payer_startdate is specified
	if ((@p_id_payer is NOT NULL OR (@p_payer_login is not NULL AND 
			@p_payer_namespace is not NULL)) AND @p_payer_startdate is NOT NULL) 
		begin
			-- resolve the paying account id if necessary
			if (@p_payer_login is not null and @p_payer_namespace is not null)
			 begin
				select @payerId = dbo.LookupAccount(@p_payer_login,@p_payer_namespace) 
				if (@payerID = -1)
				 begin 
					-- MT_CANNOT_RESOLVE_PAYING_ACCOUNT
				 select @p_status = -486604792
				 return
				 end 
			 end
			else
       begin
        select @payerID = @p_id_payer
			 end 
		-- default the payer end date to the end of the account
		if (@p_payer_enddate is NULL)
		 begin
			select @payerenddate = dbo.mtmaxdate()
		 end 
		else
		 begin 
			select @payerenddate = @p_payer_enddate
    end 
		-- find the old payment information
		select @oldpayerstart = vt_start,@oldpayerend = vt_end ,@oldpayer = id_payer
		from t_payment_redirection
		where id_payee = @AccountID and
		dbo.overlappingdaterange(vt_start,vt_end,@p_payer_startdate,dbo.mtmaxdate())=1
		-- if the new record is in range of the old record and the payer is the same as the older payer,
		-- update the record
		if (@payerID = @oldpayer) begin
	    exec UpdatePaymentRecord @payerID,@accountID,@oldpayerstart,@oldpayerend,
															 @p_payer_startdate,@payerenddate,@p_systemdate,@p_status output
			if (@p_status <> 1)
			 begin
				return
			 end 
	  end
	  else begin
		 select @payerbillable = case when @payerID = @accountID then @p_billable else NULL end
		 exec CreatePaymentRecord @payerID,@accountID,@p_payer_startdate,@payerenddate,@payerbillable,
			@p_systemdate,'N',@p_status output
		 if (@p_status <> 1)
		  begin
      return
			end
  	end
  end
	-- check if the account has any payees before setting the account as Non-billable.  It is important
	-- that this check take place after creating any payment redirection records	
	if dbo.IsAccountBillable(@AccountID) = 'Y' AND @p_billable = 'N' begin
		if dbo.DoesAccountHavePayees(@AccountID,@p_systemdate) = 'Y' begin
			-- MT_ACCOUNT_NON_BILLABLE_AND_HAS_NON_PAYING_SUBSCRIBERS
			select @p_status = -486604767
			return
		end
	end
	if (((@p_ancestor_name is not null AND @p_ancestor_namespace is not NULL)
			 or @p_id_ancestor is not null) AND @p_hierarchy_movedate is not null)
		begin	 
			if (@p_ancestor_name is not NULL and @p_ancestor_namespace is not NULL)
			 begin
				select @ancestorID = dbo.LookupAccount(@p_ancestor_name,@p_ancestor_namespace) 
				if (@ancestorID = -1)
				 begin
					-- MT_CANNOT_RESOLVE_HIERARCHY_ACCOUNT
					select @p_status = -486604791
					return
				 end 
       end
		  else
       begin
				select @ancestorID = @p_id_ancestor
			 end
    exec MoveAccount @ancestorID,@AccountID,@p_hierarchy_movedate,@p_status output
		if (@p_status <> 1)
		 begin
			return
		 end 
	end
	-- step : resolve the hierarchy path based on the current time
 begin
	select @p_hierarchy_path = tx_path  from t_account_ancestor
	where id_ancestor =1  and id_descendent = @AccountID and
	@p_systemdate between vt_start and vt_end
  if (@p_hierarchy_path is null)
	 begin
		select @p_hierarchy_path = '/'  
	 end
 end
 -- done
 select @p_accountID = @AccountID
 select @p_status = 1
 end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

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

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

			create procedure UpdateBaseProps(
			@a_id_prop int,
			@a_id_lang int,
			@a_nm_name NVARCHAR(255),
			@a_nm_desc NVARCHAR(255),
			@a_nm_display_name NVARCHAR(255))
		AS
		begin
      declare @old_id_name int
      declare @id_name int
      declare @old_id_desc int
      declare @id_desc int
      declare @old_id_display_name int
      declare @id_display_name int
			select @old_id_name = n_name, @old_id_desc = n_desc, 
			@old_id_display_name = n_display_name
     	from t_base_props where id_prop = @a_id_prop
			exec UpsertDescription @a_id_lang, @a_nm_name, @old_id_name, @id_name output
			exec UpsertDescription @a_id_lang, @a_nm_desc, @old_id_desc, @id_desc output
			exec UpsertDescription @a_id_lang, @a_nm_display_name, @old_id_display_name, @id_display_name output
			UPDATE t_base_props
				SET n_name = @id_name, n_desc = @id_desc, n_display_name = @id_display_name,
						nm_name = @a_nm_name, nm_desc = @a_nm_desc, nm_display_name = @a_nm_display_name
				WHERE id_prop = @a_id_prop
		END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

			CREATE PROC UpdateBatchStatus
				@a_tx_batch VARBINARY(16),
				@a_n_completed int
			AS
				DECLARE @completed int
				SET @completed = (SELECT n_completed FROM t_batch_status WHERE (tx_batch = @a_tx_batch))
				IF @completed IS NULL
					INSERT INTO t_batch_status
						(tx_batch, n_completed)
						VALUES (@a_tx_batch, @a_n_completed)
				ELSE
					UPDATE t_batch_status
						SET n_completed = @a_n_completed + @completed
						WHERE tx_batch = @a_tx_batch

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

					create proc UpdateCounterInstance
											@id_lang_code int,
                      @id_prop int,
											@counter_type_id int,
											@nm_name varchar(255),
											@nm_desc varchar(255)
					AS
					BEGIN TRAN
            exec UpdateBaseProps @id_prop, @id_lang_code, NULL, @nm_desc, NULL
						UPDATE 
 							t_base_props  
						SET 
 							nm_name = @nm_name, nm_desc = @nm_desc 
						WHERE 
 							id_prop = @id_prop
 						UPDATE 
 							t_counter
						SET 
 							id_counter_type = @counter_type_id
						WHERE 
 							id_prop = @id_prop
					COMMIT TRAN

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

						create proc UpdateCounterParamInstance											@id_counter_param				int,											@id_counter				 			int,											@id_counter_param_type 	int,											@nm_counter_value 			varchar(255)					AS					BEGIN TRAN						DELETE FROM T_COUNTER_PARAMS WHERE id_counter = @id_counter AND id_counter_param = @id_counter_param						INSERT INTO 							t_counter_params (id_counter, Value, id_counter_param_meta)						VALUES  							(@id_counter, @nm_counter_value, @id_counter_param_type)					COMMIT TRAN
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

					CREATE PROC UpdateCounterPropDef											@id_lang_code int,											@id_prop int,											@nm_name nvarchar(255),											@nm_display_name nvarchar(255),											@id_pi int,											@nm_servicedefprop nvarchar(255),											@nm_preferredcountertype nvarchar(255),											@n_order int					AS						DECLARE @identity_value int						DECLARE @id_locale int					BEGIN TRAN						exec UpdateBaseProps @id_prop, @id_lang_code, @nm_name, NULL, @nm_display_name						UPDATE t_counterpropdef 						SET							nm_servicedefprop = @nm_servicedefprop,							n_order = @n_order,							nm_preferredcountertype = @nm_preferredcountertype						WHERE id_prop = @id_prop					COMMIT TRAN
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create procedure UpdateGroupSubMembership(
@p_id_acc int,
@p_id_sub int,
@p_id_po int,
@p_id_group int,	
@p_startdate datetime,
@p_enddate datetime,
@p_systemdate datetime,
@p_status int OUTPUT,
@p_datemodified varchar OUTPUT
)
as
begin
declare @realstartdate datetime
declare @realenddate datetime
	exec AdjustGsubMemberDates @p_id_sub,@p_startdate,@p_enddate,
	@realstartdate OUTPUT,@realenddate OUTPUT,@p_datemodified OUTPUT,@p_status OUTPUT
	if @p_status <> 1 begin
		return
	end
 -- check that the new date does not conflict with another subscription
	-- to the same product offering
select @p_status = dbo.checksubscriptionconflicts(@p_id_acc,@p_id_po,@realstartdate,@realenddate,@p_id_sub) 
if (@p_status <> 1)
	begin
	return
	end 
-- end business rule checks
begin
	exec CreateGSubMemberRecord @p_id_group,@p_id_acc,@realstartdate,@realenddate,
		@p_systemdate,@p_status OUTPUT
	if (@@error <> 0)
		begin
		-- not in group subscription, MT_GROUPSUB_ACCOUNT_NOT_IN_GROUP_SUB
		select @p_status = -486604777 
		end
-- done
end
end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create procedure UpdateGroupSubscription(
@p_id_group int,
@p_name varchar(255),
@p_desc varchar(255),
@p_startdate datetime,
@p_enddate datetime,
@p_proportional varchar,
@p_supportgroupops varchar,
@p_discountaccount int,
@p_CorporateAccount int,
@p_systemdate datetime,
@p_status int OUTPUT,
@p_datemodified varchar OUTPUT
)
as
begin
	declare @idPO as int
	declare @idSUB as int
	declare @realenddate as datetime
	declare @oldstartdate as datetime
	declare @oldenddate as datetime
	declare @varMaxDateTime as datetime
	declare @idusagecycle int
	select @varMaxDateTime = dbo.MTMaxDate()
	-- find the product offering ID
	select @idPO = id_po, @idusagecycle = tg.id_usage_cycle,@idSUB = t_sub.id_sub
	from t_sub 
	INNER JOIN t_group_sub tg on tg.id_group = @p_id_group
	where t_sub.id_group = @p_id_group
	-- business rule checks
	if (@p_enddate is null)
		begin
		select @realenddate = @varMaxDateTime
		end
	else
		begin
		select @realenddate = @p_enddate
		end 
	exec CheckGroupSubBusinessRules @p_name,@p_desc,@p_startdate,@p_enddate,@idPO,
	@p_proportional,@p_discountaccount,@p_CorporateAccount,@p_id_group,@idusagecycle,@p_systemdate,@p_status output
	if (@p_status <> 1) begin
		return
	end
	exec UpdateSub @idSUB,@p_startdate,@realenddate,'N','N',@idPO,NULL,@p_systemdate,
		@p_status OUTPUT,@p_datemodified OUTPUT
	if @p_status <> 1 begin
		return
	end
	update t_group_sub set tx_name = @p_name,tx_desc = @p_desc,b_proportional = @p_proportional,
	id_corporate_account = @p_CorporateAccount,id_discountaccount = @p_discountaccount,
	b_supportgroupops = @p_supportgroupops
	where id_group = @p_id_group
	-- update t_groupsub_historical and friends
	-- Existing Record          |--------------|
	-- new group eff date    |--------------|
	-- new group eff date    					|--------------|
	-- bring in the end date to match the new end date of the group sub
	update t_gsubmember_historical
	set tt_end = @p_systemdate
	where
	id_group = @p_id_group AND 
	((vt_start >= @p_startdate and vt_start <= @realenddate) OR
	 (vt_end >= @p_startdate AND vt_end <= @realenddate))
	and tt_end = @varMaxDateTime
	insert into t_gsubmember_historical (id_group,id_acc,vt_start,vt_end,tt_start,tt_end)
	select id_group,id_acc,
	dbo.mtmaxoftwodates(tgs.vt_start,@p_startdate),
	dbo.mtminoftwodates(tgs.vt_end,@realenddate),
	@p_systemdate,
	@varMaxDateTime
	from t_gsubmember tgs
	where tgs.id_group = @p_id_group
	-- remove the old records
	delete from t_gsubmember where id_group = @p_id_group
	-- reccreate the new subscription records
	insert into t_gsubmember (id_group,id_acc,vt_start,vt_end)
	select id_group,id_acc,vt_start,vt_end
	from t_gsubmember_historical
	where id_group = @p_id_group and tt_end = @varMaxDateTime
	-- done
	select @p_status = 1
end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

create procedure UpdatePaymentRecord(
@p_payer int,
@p_payee int,
@p_oldstartdate datetime,
@p_oldenddate datetime,
@p_startdate datetime,
@p_enddate datetime,
@p_systemdate datetime,
@p_status int OUTPUT
)
as
begin
declare @realoldstartdate datetime
declare @realoldenddate datetime
declare @realstartdate datetime
declare @realenddate datetime
declare @testenddate datetime
declare @billable char
declare @varMaxDateTime datetime
declare @accstartdate datetime
declare @tempvar int
select @varMaxDateTime = dbo.MTMaxDate()
select @p_status = 0
-- normalize dates
select @realstartdate = dbo.mtstartofday(@p_startdate) 
if (@p_enddate is null)
	begin
	select @realenddate = dbo.mtstartofday(@varMaxDateTime)  
	end
else
	begin
	select @realenddate = dbo.mtstartofday(@p_enddate) 
	end
select @realoldstartdate = dbo.mtstartofday(@p_oldstartdate) 
select @realoldenddate = dbo.mtstartofday(@p_oldenddate)  
 -- business rule checks
 -- if the account is not billable, we must make sure that they are 
	-- not changing the most recent payment redirection record's end date from
	-- MTMaxDate(). 
select @testenddate = max(vt_end), @billable = c_billable from t_payment_redirection redir
INNER JOIN t_av_internal tav on tav.id_acc = @p_payee
where
redir.id_payee = @p_payee and redir.id_payer = @p_payer
group by c_billable
 -- if the enddate matches the record we are changing
if (@testenddate = @realoldstartdate AND
-- the user is changing the enddate and the account is not billable
@realoldenddate <> @realenddate AND @billable = 'N')
	begin
	-- MT_PAYMENT_UDDATE_END_DATE_INVALID
	select @p_status = -486604780
	return
	end 
if (@p_oldenddate = @varMaxDateTime AND @p_enddate <> @varMaxDateTime) begin
	-- MT_CANNOT_MOVE_MODIFY_PAYMENT_ENDDATE_IF_INFINITE
	select @p_status = -486604749
	return
end
select @accstartdate = dbo.mtstartofday(dt_crt) from t_account where id_acc = @p_payee
if (@p_oldstartdate = @accstartdate AND @p_startdate <> @accstartdate) begin
	-- MT_CANNOT_MOVE_MODIFY_PAYMENT_STARTDATE_IF_ACC_STARTDATE
	select @p_status = -486604748
	return
end
-- end business rules
exec CreatePaymentRecord @p_payer,@p_payee,@realstartdate,@realenddate,NULL,@p_systemdate,'Y',@p_status output
if (@p_status is null)
	begin
	-- MT_PAYMENTUPDATE_FAILED
	select @p_status = -486604781
	end
end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

				CREATE PROCEDURE UpdateStateFromClosedToPFB (
					@system_date datetime,
					@ref_date datetime,
					@status INT output)
				AS
				Begin
					declare @varMaxDateTime datetime
					declare @varSystemGMTDateTime datetime 
					declare @varSystemGMTBDateTime datetime  
					declare @varSystemGMTEDateTime datetime 
					declare @ref_date_mod DATETIME
					select @status = -1
					-- Use the true current GMT time for the tt_ dates
					SELECT @varSystemGMTDateTime = @system_date
					-- Set the maxdatetime into a variable
					select @varMaxDateTime = dbo.MTMaxDate()
					/*
					-- currently always use the system date
					-- get the code ready to take input ref_date
					IF (@ref_date IS NULL)
					begin
						select @ref_date_mod = @varSystemGMTDateTime
						select @ref_date_modSOD = @varSystemGMTDateTimeSOD
					end
					ELSE
					begin
						select @ref_date_mod = @ref_date
						select @ref_date_modSOD = dbo.mtstartofday(@ref_date)
					end
					*/
					select @ref_date_mod = @varSystemGMTDateTime
					select @varSystemGMTBDateTime = dateadd(day,-1,dbo.mtstartofday(@ref_date_mod))
					select @varSystemGMTEDateTime = DATEADD(s,-1,DATEADD(day,1,@varSystemGMTBDateTime))
					-- Save those id_acc whose state MAY be updated to a temp table (had usage the previous day)
					create table #updatestate_0 (id_acc int)
					INSERT INTO #updatestate_0 (id_acc)
					SELECT DISTINCT id_acc 
					FROM (SELECT id_acc FROM t_acc_usage au
					      WHERE au.dt_crt between @varSystemGMTBDateTime and @varSystemGMTEDateTime) ttt
					-- Save those id_acc whose state WILL be updated to a temp 
					-- table (has CL state)
					create table #updatestate_1(id_acc int)
					INSERT INTO #updatestate_1 (id_acc)
					SELECT tmp0.id_acc 
					FROM t_account_state ast, #updatestate_0 tmp0
					WHERE ast.id_acc = tmp0.id_acc
					AND ast.vt_end = @varMaxDateTime
					AND ast.status = 'CL'
					EXECUTE UpdateStateRecordSet
					@system_date,
					@ref_date_mod,
					'CL', 'PF',
					@status OUTPUT
					DROP TABLE #updatestate_0
					DROP TABLE #updatestate_1
					select @status=1
					RETURN
				END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

				CREATE proc UpdateStateFromPFBToClosed (
					@id_interval INT,
					@ref_date DATETIME,
					@system_date datetime,
					@status INT OUTPUT)
				AS
 				BEGIN
					DECLARE @ref_date_mod DATETIME, @varMaxDateTime DATETIME
					SELECT @status = -1
					-- Set the maxdatetime into a variable
					SELECT @varMaxDateTime = dbo.MTMaxDate()
					IF (@ref_date IS NULL)
					BEGIN
						SELECT @ref_date_mod = @system_date
					END
					ELSE
					BEGIN
						SELECT @ref_date_mod = @ref_date
					END
					-- Save those id_acc whose state MAY be updated to a temp table 
					-- (had usage the previous day)
					CREATE TABLE #updatestate_0 (id_acc int)
					INSERT INTO #updatestate_0 (id_acc)
					SELECT id_acc 
					FROM t_acc_usage_interval aui
					WHERE aui.id_usage_interval = @id_interval
					-- Save those id_acc whose state WILL be updated to a temp 
					-- table (has PF state)
					CREATE TABLE #updatestate_1(id_acc int)
					INSERT INTO #updatestate_1 (id_acc)
					SELECT tmp0.id_acc 
					FROM t_account_state ast, #updatestate_0 tmp0
					WHERE ast.id_acc = tmp0.id_acc
					AND ast.vt_end = @varMaxDateTime
					AND ast.status = 'PF'
					AND @ref_date_mod BETWEEN vt_start and vt_end
					-- ------------------------------------------------------------
					-- ------------------- t_sub & t_sub_history ------------------
					-- ------------------------------------------------------------
					-- update all of the current subscriptions in t_sub_history 
					-- where the account ID matches and tt_end = dbo.mtmaxdate().  
					-- Set tt_end = systemtime.
					-- add a new record to t_sub_history where vt_end is the account 
					-- close date.
					-- Update the end date of the relevant subscriptions in t_sub 
					-- where id_acc = closed accounts
					-- Set vt_end = account close date.
					-- follow same pattern for t_gsubmember_historical and t_gsubmember.
					declare @varSystemGMTDateTime datetime
					SELECT @varSystemGMTDateTime = @system_date
					declare @rowcnt int
					SELECT @rowcnt = count(*)
					FROM #updatestate_1
					IF @rowcnt > 0
					BEGIN
					UPDATE t_sub_history 
					SET tt_end = dbo.subtractsecond(@varSystemGMTDateTime)
					WHERE ((@ref_date_mod between vt_start and vt_end) OR 
					       (@ref_date_mod <= vt_start))
					AND EXISTS (SELECT NULL FROM #updatestate_1 tmp
							WHERE tmp.id_acc = t_sub_history.id_acc)
					INSERT INTO t_sub_history (
						id_sub,
						id_sub_ext,
						id_acc,
						id_po,
						dt_crt,
						id_group,
						vt_start,
						vt_end,
						tt_start,
						tt_end )
					SELECT 
						sub.id_sub,
						sub.id_sub_ext,
						sub.id_acc,
						sub.id_po,
						sub.dt_crt,
						sub.id_group,
						sub.vt_start,
						@ref_date_mod,
						@varSystemGMTDateTime,
						@varMaxDateTime
					FROM t_sub sub, #updatestate_1 tmp
					WHERE sub.id_acc = tmp.id_acc
					AND ((@ref_date_mod between sub.vt_start and sub.vt_end) OR 
					     (@ref_date_mod <= vt_start))
					-- Update the vt_end field of the Current records for the accounts
					UPDATE t_sub 
					SET vt_end = @ref_date_mod
					WHERE ((@ref_date_mod between vt_start and vt_end) OR 
					       (@ref_date_mod <= vt_start))
					AND EXISTS (SELECT NULL FROM #updatestate_1 tmp
							WHERE tmp.id_acc = t_sub.id_acc)
					-- ------------------------------------------------------------
					-- ------------------- t_sub & t_sub_history ------------------
					-- ------------------------------------------------------------
					-- ------------------------------------------------------------
					-- ------------ t_gsubmember & t_gsubmember_historical --------
					-- ------------------------------------------------------------
					UPDATE t_gsubmember_historical 
					SET tt_end = dbo.subtractsecond(@varSystemGMTDateTime)
					WHERE ((@ref_date_mod between vt_start and vt_end) OR 
					       (@ref_date_mod <= vt_start))
					AND EXISTS (SELECT NULL FROM #updatestate_1 tmp
							WHERE tmp.id_acc = t_gsubmember_historical.id_acc)
					INSERT INTO t_gsubmember_historical (
						id_group,
						id_acc,
						vt_start,
						vt_end,
						tt_start,
						tt_end)
					SELECT 
						gsub.id_group,
						gsub.id_acc,
						gsub.vt_start,
						@ref_date_mod,
						@varSystemGMTDateTime,
						@varMaxDateTime
					FROM t_gsubmember gsub, #updatestate_1 tmp
					WHERE gsub.id_acc = tmp.id_acc
					AND ((@ref_date_mod between vt_start and vt_end) OR 
				       (@ref_date_mod <= vt_start))
					-- Update the vt_end field of the Current records for the accounts
					UPDATE t_gsubmember 
					SET vt_end = @ref_date_mod
					WHERE ((@ref_date_mod between vt_start and vt_end) OR 
					       (@ref_date_mod <= vt_start))
					AND EXISTS (SELECT NULL FROM #updatestate_1 tmp
							WHERE tmp.id_acc = t_gsubmember.id_acc)
					END
					-- ------------------------------------------------------------
					-- ------------ t_gsubmember & t_gsubmember_historical --------
					-- ------------------------------------------------------------
					EXECUTE UpdateStateRecordSet
					@system_date,
					@ref_date_mod,
					'PF', 'CL',
					@status OUTPUT
					select @status = 1
					DROP TABLE #updatestate_0
					DROP TABLE #updatestate_1
					RETURN
				END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

				CREATE PROCEDURE UpdateStateRecordSet (
					@system_date DATETIME,
					@start_date_mod DATETIME,
					@from_status CHAR(2),
					@to_status CHAR(2),
					@status INT OUTPUT)
				AS
 				BEGIN
					DECLARE @varMaxDateTime DATETIME,
						@varSystemGMTDateTime DATETIME,
						@varSystemGMTDateTimeSOD DATETIME,
						@start_date_modSOD DATETIME
					DECLARE @table_formerge TABLE (id_acc INT, status CHAR(2), vt_start DATETIME) 
					-- Set the maxdatetime into a variable
					SELECT @varMaxDateTime = dbo.MTMaxDate()
					-- Use the true current GMT time for the tt_ dates
					SELECT @varSystemGMTDateTime = @system_date
					SELECT @varSystemGMTDateTimeSOD = dbo.mtstartofday(@system_date)
					SELECT @start_date_modSOD = dbo.mtstartofday(@start_date_mod)
					SELECT @status = -1
					--CREATE TABLE #updatestate_1 (id_acc INT)
					-- Update the tt_end field of the t_account_state_history record 
					-- for the accounts
					UPDATE t_account_state_history 
					SET tt_end = dbo.subtractsecond(@varSystemGMTDateTime)
					WHERE vt_end = @varMaxDateTime
					AND tt_end = @varMaxDateTime
					AND status = @from_status
					AND EXISTS (SELECT NULL FROM #updatestate_1 tmp 
						    WHERE tmp.id_acc = t_account_state_history.id_acc)
 					if (@@error <>0)
					begin
	  					RETURN
					end
					-- Insert the to-be-updated Current records into the History table 
					-- for the accounts, exclude the one that needs to be override
					INSERT INTO t_account_state_history
					SELECT 
						ast.id_acc,
						ast.status,
						ast.vt_start,
						dbo.subtractsecond(@start_date_modSOD),
						@varSystemGMTDateTime,
						@varMaxDateTime
					FROM t_account_state ast, #updatestate_1 tmp
					WHERE ast.id_acc = tmp.id_acc
					AND ast.vt_end = @varMaxDateTime
					AND ast.status = @from_status
					AND @start_date_mod between ast.vt_start and ast.vt_end
					-- exclude the one that needs to be override
					AND ast.vt_start <> @start_date_modSOD
 					if (@@error <>0)
					begin
	  					RETURN
					end
					-- Update the vt_end field of the Current records for the accounts
					-- when the new status is on a different day
					UPDATE t_account_state 
					SET vt_end = dbo.subtractsecond(@start_date_modSOD)
					FROM t_account_state, #updatestate_1 tmp
					WHERE tmp.id_acc = t_account_state.id_acc
					AND t_account_state.vt_end = @varMaxDateTime
					AND t_account_state.status = @from_status 
					AND @start_date_mod between t_account_state.vt_start and t_account_state.vt_end
					AND t_account_state.vt_start <> @start_date_modSOD
 					if (@@error <>0)
					begin
	  					RETURN
					end
					-- MERGE: Identify if needs to be merged with the previous record 
					INSERT INTO @table_formerge
					SELECT tmp.id_acc, status, vt_start
					FROM t_account_state ast, #updatestate_1 tmp
					WHERE ast.id_acc = tmp.id_acc
					AND ast.status = @to_status
					AND ast.vt_end = dateadd(second,-1,@start_date_modSOD)
 					if (@@error <>0)
					begin
	  					RETURN
					end
					-- MERGE: Remove the to-be-merged records
					DELETE t_account_state
					FROM t_account_state, @table_formerge mrg
					WHERE t_account_state.id_acc = mrg.id_acc
					AND t_account_state.status = mrg.status
					AND t_account_state.vt_start = mrg.vt_start
 					if (@@error <>0)
					begin
	  					RETURN
					end
					-- Remove the Current records for the accounts if the new 
					-- status is from the same day
					DELETE t_account_state
					FROM t_account_state, #updatestate_1 tmp
					WHERE t_account_state.id_acc = tmp.id_acc
					AND t_account_state.vt_end = @varMaxDateTime
					AND t_account_state.status = @from_status
					AND t_account_state.vt_start = @start_date_modSOD
 					if (@@error <>0)
					begin
	  					RETURN
					end
					DELETE t_account_state_history
					FROM t_account_state_history, @table_formerge mrg
					WHERE t_account_state_history.id_acc = mrg.id_acc
					AND t_account_state_history.status = mrg.status
					AND t_account_state_history.vt_start = mrg.vt_start
					AND t_account_state_history.tt_end = @varMaxDateTime
 					if (@@error <>0)
					begin
	  					RETURN
					end
					-- Insert new records to the Current table
					INSERT INTO t_account_state (
						id_acc,
						status,
						vt_start,
						vt_end)
					SELECT tmp.id_acc,
						@to_status,
						CASE WHEN mrg.vt_start IS NULL 
							THEN @start_date_modSOD
							ELSE mrg.vt_start END,
						@varMaxDateTime
					FROM #updatestate_1 tmp LEFT OUTER JOIN @table_formerge mrg
						ON mrg.id_acc = tmp.id_acc
 					if (@@error <>0)
					begin
	  					RETURN
					end
					-- Insert new records to the History table
					INSERT INTO t_account_state_history (
						id_acc,
						status,
						vt_start,
						vt_end,
						tt_start,
						tt_end)
					SELECT tmp.id_acc,
						@to_status,
						CASE WHEN mrg.vt_start IS NULL 
							THEN @start_date_modSOD
							ELSE mrg.vt_start END,
						@varMaxDateTime,
						@varSystemGMTDateTime,
						@varMaxDateTime
					FROM #updatestate_1 tmp LEFT OUTER JOIN @table_formerge mrg
						ON mrg.id_acc = tmp.id_acc
 					if (@@error <>0)
					begin
	  					RETURN
					end
					select @status = 1
					RETURN
				END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

		create proc UpsertDescription
			@id_lang_code int,
			@a_nm_desc NVARCHAR(255),
			@a_id_desc_in int, 
			@a_id_desc int OUTPUT
		AS
    begin
      declare @var int
			IF (@a_id_desc_in IS NOT NULL and @a_id_desc_in <> 0)
				BEGIN
					-- there was a previous entry
				UPDATE t_description
					SET
						tx_desc = @a_nm_desc
					WHERE
						id_desc = @a_id_desc_in AND id_lang_code = @id_lang_code
					-- continue to use old ID
					select @a_id_desc = @a_id_desc_in
				END
			ELSE
			  begin
				-- there was no previous entry
				IF (@a_nm_desc IS NULL)
				 begin
					-- no new entry
					select @a_id_desc = 0
				 end
				 ELSE
					BEGIN
						-- generate a new ID to use
						INSERT INTO t_mt_id default values
						select @a_id_desc = @@identity
						INSERT INTO t_description
							(id_desc, id_lang_code, tx_desc)
						VALUES
							(@a_id_desc, @id_lang_code, @a_nm_desc)
					 END
			END 
			end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE procedure addsubscriptionbase(
@p_id_acc int,
@p_id_group int,
@p_id_po int,
@p_startdate datetime,
@p_enddate datetime,
@p_GUID varbinary(16),
@p_systemdate datetime,
@p_id_sub int output,
@p_status int output,
@p_datemodified varchar output)
as
declare @varSystemGMTDateTime datetime,
				@varMaxDateTime datetime,
				@realstartdate datetime,
				@realenddate datetime,
				@realguid varbinary(16),
        @po_cycle integer,
        @cycle_type integer
begin
	select @varMaxDateTime = dbo.mtmaxdate()  
	select @p_status = 0
	exec AdjustSubDates @p_id_po,@p_startdate,@p_enddate,@realstartdate OUTPUT,
		@realenddate OUTPUT,@p_datemodified OUTPUT,@p_status OUTPUT
	if @p_status <> 1 begin
		return
	end
if (@p_id_acc is not NULL) begin
	select @p_status = dbo.CheckSubscriptionConflicts(@p_id_acc,@p_id_po,@realstartdate,@realenddate,-1)
	if (@p_status <> 1) begin
    return
	end
  -- fetch the cycle of the account
  select 
  @cycle_type = id_cycle_type
  from t_acc_usage_cycle
  INNER JOIN t_usage_cycle on t_usage_cycle.id_usage_cycle = t_acc_usage_cycle.id_usage_cycle 
  where 
  t_acc_usage_cycle.id_acc = @p_id_acc
  -- fetch the cycle of the PI's on the PO
  select @po_cycle = dbo.poConstrainedCycleType(@p_id_po)
  if @po_cycle <> 0 begin
	  if @cycle_type <> @po_cycle begin
		  -- MTPCUSER_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE
		  select @p_status = -289472464
      return
	  end
  end
end 
	-- get the new subscriptionID
	insert into t_mt_id default values
	select @p_id_sub = @@identity
if (@p_GUID is NULL)
	begin
	select @realguid = newid()
	end
else
	begin
	select @realguid = @p_GUID
	end 
	exec CreateSubscriptionRecord @p_id_sub,@realguid,@p_id_acc,
		@p_id_group,@p_id_po,@p_systemdate,@realstartdate,@realenddate,
		@p_systemdate,@status = @p_status OUTPUT
end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

					CREATE procedure copytemplate(
					@id_folder int,
					@id_parent int,
          @p_systemdate datetime,
					@status int output)
					as
				 	begin
					declare @parentID int
					declare @cdate datetime
					declare @nexttemplate int
					declare @parentTemplateID int
					 begin
						if (@id_parent is NULL)
						 begin
							select @parentID = id_ancestor 
							from t_account_ancestor where id_descendent = @id_folder
							AND @p_systemdate between vt_start AND vt_end AND
							num_generations = 1
						  if (@parentID is null)
							 begin
						     select @status = -486604771 -- MT_PARENT_NOT_IN_HIERARCHY
							   return
							 end
						 end
						else
						 begin
							select @parentID = @id_parent  
						 end 
						end	
						begin
							select @parentTemplateID = id_acc_template from t_acc_template
							where id_folder = @parentID
							if (@parentTemplateID is null)
							 begin
								SELECT @status = -486604772
							  return
							 end
						end	
							exec clonesecuritypolicy @id_parent,@id_folder,'D','D'
							insert into t_acc_template 
							 (id_folder,dt_crt,tx_name,tx_desc,b_applydefaultpolicy)
							 select @id_folder,@p_systemdate,
							 tx_name,tx_desc,b_applydefaultpolicy
							 from t_acc_template where id_folder = @parentID
  					  select @nexttemplate =@@identity
							insert into t_acc_template_props (id_acc_template,nm_prop_class,
							nm_prop,nm_value)
							select @nexttemplate,existing.nm_prop_class,existing.nm_prop,
							existing.nm_value from 
							t_acc_template_props existing where 
							existing.id_acc_template = @parentTemplateID
							insert into t_acc_template_subs (id_po,id_acc_template,b_group,
							vt_start,vt_end,nm_groupsubname)
						  select existing.id_po,@nexttemplate,existing.b_group,
							existing.vt_start,existing.vt_end,existing.nm_groupsubname
							from t_acc_template_subs existing
							where
							existing.id_acc_template = @parentTemplateID
							select @status = 1
					 end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

				CREATE procedure createboundaryintervals
				(@id_cycle int,
				@id_cycle_type int,
				@intervalstart datetime,
				@intervalend datetime,
				@systemdate datetime)
				as
				begin
				if (@systemdate + 1 > @intervalend)
					begin
					insert into t_usage_interval(id_interval,id_usage_cycle,dt_start,
																				dt_End,tx_interval_status)
						select id_interval,id_cycle,dt_start,dt_end,'N'
						from t_pc_interval
						INNER JOIN t_usage_cycle_type len on len.id_cycle_type = @id_cycle_type
						where dt_start > @intervalend AND
						((dt_end < @intervalend+8) OR 
						((@intervalend+len.n_proration_length) between
						dt_start AND dt_end))
						AND id_cycle = @id_cycle AND
						id_interval not in (select id_interval from t_usage_interval)
						-- blow away the mappings in t_acc_usage_interval
						delete from t_acc_usage_interval
						where id_usage_interval in (
								select pc.id_interval
								from
								t_pc_interval pc
								INNER JOIN t_usage_cycle_type len on len.id_cycle_type = @id_cycle_type
								where id_cycle = @id_cycle AND dt_start > @intervalend AND
								((dt_end < @intervalend+8) OR 
								((@intervalend+len.n_proration_length) between
								dt_start AND dt_end))
								AND id_cycle = @id_cycle
							)
						insert into t_acc_usage_interval (id_acc,id_usage_interval,tx_status)
						select tac.id_acc,pc.id_interval,'O'
						from 
						t_acc_usage_cycle tac
						INNER JOIN t_pc_interval pc on id_cycle = @id_cycle
						INNER JOIN t_usage_cycle_type len on len.id_cycle_type = @id_cycle_type
						where dt_start > @intervalend AND
						((dt_end < @intervalend+8) OR 
						((@intervalend+len.n_proration_length) between
						dt_start AND dt_end))
						AND id_cycle = @id_cycle AND
						tac.id_usage_cycle = @id_cycle
				end 
				end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/*
The procedure returns a value of
-1: fatal errors occurred
 0: successful
*/
CREATE PROCEDURE mtsp_insertinvoice
@id_interval int,
@update_id int,
@invoice_prefix varchar,
@invoice_sufix varchar,
@invoice_digits int,
@invoice_number int,
@invoice_due_date_offset int,
@new_invoice_number int OUTPUT,
@return_code int OUTPUT
AS
BEGIN
DECLARE 
@invoice_date datetime, 
@cnt int,
@invoice_string varchar(100),
@curr_max_id int,
@id_interval_exist int,
@min_id_invoice int,
@max_id_invoice int,
@debug_flag bit,
@SQLError int,
@ErrMsg varchar(200)
SET NOCOUNT ON
-- Initialization
SET @invoice_date = CAST(SUBSTRING(CAST(getdate() AS CHAR),1,11) AS DATETIME)
SET @debug_flag = 1 -- yes
--SET @debug_flag = 0 -- no
-- Validate input parameter values
IF @id_interval IS NULL 
BEGIN
	SET @ErrMsg = 'Completed abnormally, id_interval is null, at ' + CONVERT(char, getdate(), 109)
	GOTO FatalError
END
IF @invoice_digits IS NULL 
BEGIN
	SET @ErrMsg = 'Completed abnormally, invoice_digits is null, at ' + CONVERT(char, getdate(), 109)
	GOTO FatalError
END
IF @invoice_due_date_offset IS NULL 
BEGIN
	SET @ErrMsg = 'Completed abnormally, invoice_due_date_offset is null, at ' + CONVERT(char, getdate(), 109)
	GOTO FatalError
END
IF @update_id IS NULL SET @update_id = 1
IF @invoice_prefix IS NULL SET @invoice_prefix = ''
IF @invoice_sufix IS NULL SET @invoice_sufix = ''
IF @invoice_number IS NULL SET @invoice_number = 1
IF @debug_flag = 1 
	INSERT INTO t_sys_track_adapter_run (adapter_type, action_datetime, action_desc) VALUES
	('Invoice', getdate(), 'Started at ' + CONVERT(char, getdate(), 109))
-- If already exists, do not process again
SELECT TOP 1 @id_interval_exist = id_interval
FROM t_invoice_range
WHERE id_interval = @id_interval
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
IF @id_interval_exist IS NOT NULL
BEGIN
	SET @new_invoice_number = @invoice_number
	SET @ErrMsg = 'Invoice number already exists in the t_invoice_range table, '
		+ 'process skipped, process completed successfully at ' 
		+ CONVERT(char, getdate(), 109)
	GOTO SkipReturn
END
SELECT TOP 1 @id_interval_exist = id_interval
FROM t_invoice
WHERE id_interval = @id_interval
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
IF @id_interval_exist IS NOT NULL
BEGIN
	SET @new_invoice_number = @invoice_number
	SET @ErrMsg = 'Invoice number already exists in the t_invoice table, '
		+ 'process skipped, process completed successfully at ' 
		+ CONVERT(char, getdate(), 109)
	GOTO SkipReturn
END
/*
-- If decides to delete automatically
DELETE FROM t_invoice WHERE id_interval = @id_interval
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
DELETE FROM t_invoice_range WHERE id_interval = @id_interval
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
IF @debug_flag = 1 
	INSERT INTO t_sys_track_adapter_run (adapter_type, action_datetime, action_desc) VALUES
	('Invoice', getdate(), 'After deleting the t_invoice records: ' + CONVERT(char, getdate(), 109))
*/
-- Make sure the new invoice numbers do not exist already
SELECT @curr_max_id = MAX(id_invoice_num)
FROM t_invoice
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
IF @curr_max_id IS NOT NULL AND @curr_max_id + 1 > @invoice_number
	SET @invoice_number = @curr_max_id + 1 
-- Store the accounts and their invoice amount to a temp table
CREATE TABLE #tmp
	(tmp_seq int IDENTITY,
	namespace varchar (200),
	id_interval int,
	id_acc int,
	invoice_amount numeric(18, 6),
	invoice_date datetime,
	invoice_due_date datetime,
invoice_currency varchar(10))
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
IF @debug_flag = 1 
	INSERT INTO t_sys_track_adapter_run (adapter_type, action_datetime, action_desc) VALUES
	('Invoice', getdate(), 'Inserting to the #tmp table, started at ' + CONVERT(char, getdate(), 109))
INSERT INTO #tmp
	(namespace,
	id_interval,
	id_acc,
	invoice_amount,
invoice_currency)
SELECT
	RTRIM(ammps.nm_space) namespace,
	au.id_usage_interval id_interval, 
	ammps.id_acc, 
	sum(au.amount) invoice_amount,
avi.c_currency invoice_currency
FROM	t_acc_usage au, 
	t_account_mapper ammps,
	t_namespace ns,
  t_av_Internal avi
WHERE	ns.tx_typ_space = 'system_mps'
AND	ammps.nm_space = ns.nm_space 
AND	ammps.id_acc = au.id_acc
AND	au.id_parent_sess is NULL
AND	au.id_usage_interval = @id_interval
AND avi.id_acc = ammps.id_acc
GROUP BY ammps.nm_space, ammps.id_acc, au.id_usage_interval, avi.c_currency
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
IF @debug_flag = 1 
	INSERT INTO t_sys_track_adapter_run (adapter_type, action_datetime, action_desc) VALUES
	('Invoice', getdate(), 'Inserting to the t_invoice table, started at ' + CONVERT(char, getdate(), 109))
-- Save all the invoice data to the t_invoice table
INSERT INTO t_invoice
	(namespace,
	invoice_string, 
	id_interval,
	id_acc, 
	invoice_amount, 
	--invoice_tax, 
	invoice_date, 
	invoice_due_date, 
	id_invoice_num,
  invoice_currency)
SELECT
	namespace,
	@invoice_prefix
		+ ISNULL(REPLICATE('0', @invoice_digits - LEN(RTRIM(CONVERT(varchar,tmp_seq + @invoice_number - 1)))),'')
		+ RTRIM(CONVERT(varchar,tmp_seq + @invoice_number - 1))
		+ @invoice_sufix,
	id_interval,
	id_acc,
	invoice_amount,
	@invoice_date invoice_date, 
	@invoice_date+@invoice_due_date_offset invoice_due_date,
	tmp_seq + @invoice_number - 1,
  invoice_currency
FROM #tmp
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
-- Store the invoice range data to the t_invoice_range table
SELECT @cnt = MAX(tmp_seq)
FROM #tmp
SELECT @SQLError = @@ERROR
IF @SQLError <> 0 GOTO FatalError
IF @cnt IS NOT NULL
BEGIN
	SELECT @min_id_invoice=MIN(id_invoice), @max_id_invoice=MAX(id_invoice)
	FROM t_invoice
	WHERE id_interval = @id_interval
	SELECT @SQLError = @@ERROR
	IF @SQLError <> 0 GOTO FatalError
	INSERT INTO t_invoice_range (id_interval, id_invoice_first, id_invoice_last)
	VALUES (@id_interval, @min_id_invoice, @max_id_invoice)
	SELECT @SQLError = @@ERROR
	IF @SQLError <> 0 GOTO FatalError
END
ELSE	SET @cnt = 0
IF @update_id = 1 SET @new_invoice_number = @invoice_number+@cnt
ELSE SET @new_invoice_number = @invoice_number
DROP TABLE #tmp
IF @debug_flag = 1 
	INSERT INTO t_sys_track_adapter_run (adapter_type, action_datetime, action_desc) VALUES
	('Invoice', getdate(), 'Completed successfully at ' + CONVERT(char, getdate(), 109))
SET @return_code = 0
RETURN 0
SkipReturn:
	IF @ErrMsg IS NULL 
		SET @ErrMsg = 'Process skipped, completed at ' + CONVERT(char, getdate(), 109)
	IF @debug_flag = 1 
		INSERT INTO t_sys_track_adapter_run (adapter_type, action_datetime, action_desc) VALUES
		('Invoice', getdate(), @ErrMsg)
	SET @return_code = 0
	RETURN 0
FatalError:
	IF @ErrMsg IS NULL 
		SET @ErrMsg = 'Completed abnormally at ' + CONVERT(char, getdate(), 109)
	IF @debug_flag = 1 
		INSERT INTO t_sys_track_adapter_run (adapter_type, action_datetime, action_desc) VALUES
		('Invoice', getdate(), @ErrMsg)
	SET @return_code = -1
	RETURN -1
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

			create proc sp_CreateEpSQL @id_str as varchar(100),
								@kind as int,
								@core_table as varchar(50),
								@core_pk as varchar(50),
								@select_str as varchar(1024) OUTPUT
			as
				DECLARE @CursorVar CURSOR
				declare @tablename varchar(50)
				declare @constraintlist varchar(512)
				declare @i as int
				declare @count as int
				SET @CursorVar = CURSOR FORWARD_ONLY STATIC
				FOR
				select nm_ep_tablename from t_ep_map where id_principal = @kind
				set @i = 0
				OPEN @CursorVar
				Set @count = @@cursor_rows
				select @constraintlist = ('')
				while(@i < @count) begin
					select @i = @i + 1
					FETCH NEXT FROM @CursorVar into @tablename
					select @constraintlist = (@constraintlist + ' FULL JOIN ' + @tablename + ' ON ' + 
					@tablename + '.id_prop = ' + @id_str)
				end
				CLOSE @CursorVar
				DEALLOCATE @CursorVar
				select @select_str =  ('select * from ' + @core_table + 
				' JOIN t_base_props on t_base_props.id_prop = ' + @id_str + ' ' + 
				@constraintlist + ' where ' + @core_table + '.' + @core_pk + ' = ' + @id_str + 
				' AND t_base_props.n_kind = ' + CAST(@kind as varchar(20)))

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

			create proc sp_GenEpProcs
			as
			DECLARE @CursorVar CURSOR
			declare @id_principal as int
			declare @nm_table_name as varchar(256)
			declare @nm_pk as varchar(100)
			declare @nm_sprocname as varchar(256)
			declare @i as int
			declare @count as int
			declare @sql_string as varchar(1024)
			declare @existing_count as int
			set @i = 0
			SET @CursorVar = CURSOR FORWARD_ONLY STATIC
			FOR
			select id_principal,nm_table_name,nm_pk,nm_sprocname from t_principals
			OPEN @CursorVar
			select @count = @@cursor_rows
			while @i < @count begin
			FETCH NEXT FROM @CursorVar into @id_principal,@nm_table_name,@nm_pk,@nm_sprocname
			exec sp_CreateEpSQL '@id',@id_principal,@nm_table_name,@nm_pk,@select_str = @sql_string OUTPUT
				set @existing_count = (select COUNT(*) from sysobjects where name =  @nm_sprocname)
				if @existing_count != 0 begin
					exec ('drop proc ' + @nm_sprocname)
				end
				exec ('create proc ' + @nm_sprocname + ' @id as int as ' + @sql_string)
			select @i = @i + 1
			end
			CLOSE @CursorVar
			DEALLOCATE @CursorVar

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

						create procedure sp_InsertAtomicCapType 
						(@aGuid varbinary(16), @aName VARCHAR(255), @aDesc VARCHAR(255), @aProgid VARCHAR(255), @aEditor VARCHAR(255),
						@ap_id_prop int OUTPUT)
						as
						begin
            	INSERT INTO t_atomic_capability_type(tx_guid,tx_name,tx_desc,tx_progid,tx_editor) VALUES (
            	@aGuid, @aName, @aDesc, @aProgid, @aEditor)
            	  if (@@error <> 0) 
                  begin
                  select @ap_id_prop = -99
                  end
                  else
                  begin
                  select @ap_id_prop = @@identity
                  end
            end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

			create proc sp_InsertBaseProps @a_kind int,						@a_nameID int,						@a_descID int,						@a_approved char(1),						@a_archive char(1),						@a_nm_name NVARCHAR(255),						@a_nm_desc NVARCHAR(255),						@a_id_prop int OUTPUT			as			insert into t_base_props (n_kind,n_name,n_desc,nm_name,nm_desc,b_approved,b_archive) values				(@a_kind,@a_nameID,@a_descID,@a_nm_name,@a_nm_desc,@a_approved,@a_archive)			select @a_id_prop =@@identity
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

					  CREATE procedure sp_InsertCapabilityInstance
						(@aGuid VARCHAR(16), @aParentInstance int, @aPolicy int, @aCapType int,
						@ap_id_prop int OUTPUT)
						as
						begin
            	INSERT INTO t_capability_instance (tx_guid, id_parent_cap_instance, id_policy, id_cap_type) 
            	VALUES (cast (@aGuid as varbinary(16)), @aParentInstance, @aPolicy, @aCapType)
              if (@@error <> 0) 
                begin
                select @ap_id_prop = -99
                end
              else
                begin
                select @ap_id_prop = @@identity
                end
           	end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

						create procedure sp_InsertCompositeCapType 
						(@aGuid VARBINARY(16), @aName VARCHAR(255), @aDesc VARCHAR(255), @aProgid VARCHAR(255), 
             @aEditor VARCHAR(255),@aCSRAssignable VARCHAR, @aSubAssignable VARCHAR,
             @aMultipleInstances VARCHAR, @aUmbrellaSensitive VARCHAR , @ap_id_prop int OUTPUT)
						as
						begin
            	INSERT INTO t_composite_capability_type(tx_guid,tx_name,tx_desc,tx_progid,tx_editor,
              csr_assignable,subscriber_assignable,multiple_instances,umbrella_sensitive) VALUES (
							@aGuid, @aName, @aDesc, @aProgid, @aEditor, @aCSRAssignable,
						  @aSubAssignable, @aMultipleinstances,@aUmbrellaSensitive)
							if (@@error <> 0) 
                  begin
                  select @ap_id_prop = -99
                  end
                  else
                  begin
                  select @ap_id_prop = @@identity
                  end
        		END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

						create procedure sp_InsertPolicy
						(@aPrincipalColumn VARCHAR(255),
						 @aPrincipalID int,
						 @aPolicyType VARCHAR(2),
             @ap_id_prop int OUTPUT)
		        as
            declare @args NVARCHAR(255)
		        declare @str nvarchar(2000)
						declare @selectstr nvarchar(2000)
            begin
						 select @selectstr = N'SELECT @ap_id_prop = id_policy  FROM t_principal_policy WHERE ' + 
																CAST(@aPrincipalColumn AS nvarchar(255))
																+  N' = ' + CAST(@aPrincipalID AS nvarchar(38)) + N' AND ' + N'policy_type=''' 
																+ CAST(@aPolicyType AS nvarchar(2)) + ''''
						 select @str = N'INSERT INTO t_principal_policy (' + CAST(@aPrincipalColumn AS nvarchar(255)) + N',
						               policy_type)' + N' VALUES ( ' + CAST(@aPrincipalID AS nvarchar(38)) + N', ''' + 
						               CAST(@aPolicyType AS nvarchar(2))	+ N''')' 
            select @args = '@ap_id_prop INT OUTPUT'
            exec sp_executesql @selectstr, @args, @ap_id_prop OUTPUT
             if (@ap_id_prop is null)
	            begin
              exec sp_executesql @str
  	          select @ap_id_prop = @@identity
              end
            end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

					  create procedure sp_InsertRole
						(@aGuid VARBINARY(16), @aName VARCHAR(255), @aDesc VARCHAR(255),
						 @aCSRAssignable VARCHAR, @aSubAssignable VARCHAR, @ap_id_prop int OUTPUT)
						as
	          begin
             INSERT INTO t_role (tx_guid, tx_name, tx_desc, csr_assignable, subscriber_assignable) VALUES (@aGuid,
             @aName, @aDesc, @aCSRAssignable, @aSubAssignable)
						 if (@@error <> 0) 
							begin
              select @ap_id_prop = -99
              end
             else
              begin
              select @ap_id_prop = @@identity
              end
            end

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

CREATE PROCEDURE updatesub (
@p_id_sub INT,
@p_dt_start datetime,
@p_dt_end datetime,
@p_nextcycleafterstartdate VARCHAR,
@p_nextcycleafterenddate VARCHAR,
@p_id_po INT,
@p_id_acc INT,
@p_systemdate datetime,
@p_status INT OUTPUT,
@p_datemodified varchar OUTPUT
)
AS
BEGIN
	DECLARE @real_begin_date as datetime
	DECLARE @real_end_date as datetime
	declare @varMaxDateTime datetime
	declare @temp_guid varbinary(16)
	declare @id_group as integer
  declare @cycle_type as integer
  declare @po_cycle as integer
	select @varMaxDateTime = dbo.MTMaxDate()
	-- step 1: compute usage cycle dates if necessary
	select @p_status = 0
	SELECT @temp_guid = id_sub_ext
	FROM t_sub
	WHERE id_sub = @p_id_sub
	if @p_id_acc is not NULL begin
		IF (@p_nextcycleafterstartdate = 'Y') begin
			select @real_begin_date =dbo.nextdateafterbillingcycle (@p_id_acc, @p_dt_start) 
		end
		ELSE begin
			select @real_begin_date = @p_dt_start
		END
		IF (@p_nextcycleafterenddate = 'Y') begin
		-- CR 5785: make sure the end date of the subscription if using billing cycle
		-- relative is at the end of the current billing cycle
			select @real_end_date = dbo.subtractsecond (
		                        dbo.nextdateafterbillingcycle (@p_id_acc, @p_dt_end))
		end
		ELSE begin
			select @real_end_date = @p_dt_end
		END
		-- step 2: if the begin date is after the end date, make the begin date match the end date
		IF (@real_begin_date > @real_end_date) begin
			select @real_begin_date = @real_end_date
		END 
		select @p_status = dbo.checksubscriptionconflicts (
		                 @p_id_acc,@p_id_po,@real_begin_date,@real_end_date,
		                 @p_id_sub)
		IF (@p_status <> 1) begin
		  RETURN
		END
    -- fetch the cycle of the account
    select 
    @cycle_type = id_cycle_type
    from t_acc_usage_cycle
    INNER JOIN t_usage_cycle on t_usage_cycle.id_usage_cycle = t_acc_usage_cycle.id_usage_cycle 
    where 
    t_acc_usage_cycle.id_acc = @p_id_acc
    -- fetch the cycle of the PI's on the PO
    select @po_cycle = dbo.poConstrainedCycleType(@p_id_po)
    if @po_cycle <> 0 begin
	    if @cycle_type <> @po_cycle begin
		    -- MTPCUSER_CYCLE_CONFLICTS_WITH_ACCOUNT_CYCLE
		    select @p_status = -289472464
        return
	    end
    end
	end
	else begin
		select @real_begin_date = @p_dt_start
		select @real_end_date = @p_dt_end
		select @id_group = id_group from t_sub where id_sub = @p_id_sub
	end
	-- verify that the start and end dates are inside the product offering effective
	-- date
	exec AdjustSubDates @p_id_po,@real_begin_date,@real_end_date,
		@real_begin_date OUTPUT,@real_end_date OUTPUT,@p_datemodified OUTPUT,
		@p_status OUTPUT
	if @p_status <> 1 begin
		return
	end
	exec CreateSubscriptionRecord @p_id_sub,@temp_guid,@p_id_acc,@id_group,
		@p_id_po,@p_systemdate,@real_begin_date,@real_end_date,
		@p_systemdate,@p_status OUTPUT
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

