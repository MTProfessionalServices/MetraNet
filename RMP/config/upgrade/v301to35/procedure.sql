if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[VW_ADJUSTMENT_DETAILS]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[VW_ADJUSTMENT_DETAILS]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[VW_NOTDELETED_ADJUSTMENT_DETAILS]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[VW_NOTDELETED_ADJUSTMENT_DETAILS]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[VW_ADJUSTMENT_SUMMARY]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[VW_ADJUSTMENT_SUMMARY]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[VW_AJ_INFO]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[VW_AJ_INFO]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_vw_allrateschedules]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[t_vw_allrateschedules]
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[t_vw_allrateschedules_po]') and OBJECTPROPERTY(id, N'IsView') = 1)
drop view [dbo].[t_vw_allrateschedules_po]
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
go
CREATE UNIQUE CLUSTERED INDEX IDX_T_VW_I_ACC_MAPPER_1 ON T_VW_I_ACC_MAPPER (NM_LOGIN, NM_SPACE)
CREATE INDEX IDX_T_VW_I_ACC_MAPPER_2 ON T_VW_I_ACC_MAPPER (id_acc, id_enum_data)
        
  		 
GO
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
go
CREATE UNIQUE CLUSTERED INDEX IDX_T_VW_I_ACCTRES_1 ON T_VW_I_ACCTRES (nm_login, nm_space, status, state_end)
CREATE INDEX IDX_T_VW_I_ACCTRES_2 ON T_VW_I_ACCTRES (id_acc)
  
  
GO
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
go
CREATE UNIQUE CLUSTERED INDEX IDX_T_VW_I_ACCTRES_BYID_1 ON T_VW_I_ACCTRES_BYID (id_acc, status, state_end)
  
  
GO
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
go
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

DT_CRT, B_GROUP ) AS  

select 

sub.id_sub, 

tgs.id_acc,

sub.id_po,

tgs.vt_start,

tgs.vt_end,

tgs.tt_start as dt_crt,

'Y' b_group

from t_sub sub

INNER JOIN t_gsubmember_historical tgs on sub.id_group = tgs.id_group 

where tgs.tt_end = dbo.MTMaxDate()

UNION ALL

select 

sub.id_sub, 

sub.id_acc,

sub.id_po,

sub.vt_start,

sub.vt_end,

sub.dt_crt,

'N' b_group

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
CREATE UNIQUE CLUSTERED INDEX IDX_T_VW_I_GSUBMEMBER_1 ON T_VW_I_GSUBMEMBER (id_group, id_acc,vt_start)
CREATE INDEX IDX_T_VW_I_GSUBMEMBER_2 ON T_VW_I_GSUBMEMBER (id_acc)

  
  
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
go
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


        

				CREATE view VW_ADJUSTMENT_SUMMARY as

        select

          ajtrx.id_acc_payer id_acc,

          ajtrx.id_usage_interval,

          ajtrx.am_currency,

          ajui.dt_start,

          ajui.dt_end,

        --add info about adjustments

        SUM (CASE WHEN ajtrx.n_adjustmenttype=0  THEN ajtrx.AdjustmentAmount ELSE 0 END)  AS PrebillAdjustmentAmount

        ,SUM (CASE WHEN ajtrx.n_adjustmenttype=1  THEN ajtrx.AdjustmentAmount ELSE 0 END)  AS PostbillAdjustmentAmount

        ,SUM (CASE WHEN ajtrx.n_adjustmenttype=1  THEN 1 ELSE 0 END)  AS NumPostbillAdjustments

        ,SUM (CASE WHEN ajtrx.n_adjustmenttype=0  THEN 1 ELSE 0 END)  AS NumPrebillAdjustments

        FROM t_acc_usage au

        INNER JOIN t_adjustment_transaction ajtrx ON au.id_sess = ajtrx.id_sess

        INNER JOIN t_usage_interval ajui on ajui.id_interval = ajtrx.id_usage_interval



        WHERE  ajtrx.c_status = 'A'

        GROUP BY

          ajtrx.id_acc_payer,

          ajtrx.id_usage_interval,

          ajtrx.am_currency,

          ajtrx.c_status,

          ajui.dt_start,

          ajui.dt_end

				 
        
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


        

        create view VW_AJ_INFO

        -- Returns exactly 1 record	per	usage	record

        -- For adjusment related numeric fields	that come	back as	NULLs

        -- because adjustment	does not exist (eg id_aj_template, id_aj_instance)

        -- return	-1;	For	string fields	(AdjustmentDescription,	AdjustmentTemplateDescription) return	empty	strings

        as

        select 



        au.*,



        -- 1. Return Different Amounts: 



        -- PREBILL ADJUSTMENTS:



        -- CompoundPrebillAdjustmentAmount -- parent and children prebill adjustments for a compound transaction

        -- AtomicPrebillAdjustmentAmount -- parent prebill adjustments for a compound transaction. For an atomic transaction

        --                                 CompoundPrebillAdjustmentAmount always equals AtomicPrebillAdjustmentAmount

        -- CompoundPrebillAdjustedAmount -- Charge Amount + CompoundPrebillAdjustmentAmount

        -- AtomicPrebillAdjustedAmount -- Charge amount + parent prebill adjustments for a compound transaction. For an atomic transaction

        --                                 CompoundPrebillAdjustedAmount always equals AtomicPrebillAdjustedAmount





        -- POSTBILL ADJUSTMENTS:



        -- CompoundPostbillAdjustmentAmount -- parent and children postbill adjustments for a compound transaction

        -- AtomicPostbillAdjustmentAmount -- parent postbill adjustments for a compound transaction. For an atomic transaction

        --                                 CompoundPostbillAdjustmentAmount always equals AtomicPostbillAdjustmentAmount

        -- CompoundPostbillAdjustedAmount -- Charge Amount + CompoundPrebillAdjustmentAmount + CompoundPostbillAdjustmentAmount

        -- AtomicPostbillAdjustedAmount - Charge amount + parent prebill adjustments for a compound transaction +

        --                                parent postbill adjustments for a compound transaction. For an atomic transaction

        --                                AtomicPostbillAdjustedAmount always equals CompoundPostbillAdjustedAmount





        -- PREBILL ADJUSTMENTS:



        CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	

            THEN prebillajs.AdjustmentAmount

            ELSE 0 END

            + 

            {fn IFNULL((tmp.PrebillCompoundAdjustmentAmount), 0.0)} AS CompoundPrebillAdjustmentAmount,



        (au.amount + CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	

            THEN prebillajs.AdjustmentAmount

            ELSE 0 END + {fn IFNULL((tmp.PrebillCompoundAdjustmentAmount), 0.0)}) AS CompoundPrebillAdjustedAmount,

             

        (CASE WHEN (prebillajs.id_adj_trx IS NOT NULL AND prebillajs.c_status = 'A')	

	            THEN prebillajs.AdjustmentAmount

	            ELSE 0 END) AS AtomicPrebillAdjustmentAmount,

        	    

        (au.amount + (CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	

	            THEN prebillajs.AdjustmentAmount

	            ELSE 0 END) ) AS AtomicPrebillAdjustedAmount,

	            

        (CASE WHEN (prebillajs.id_adj_trx IS NOT NULL AND prebillajs.c_status = 'P')	

	            THEN prebillajs.AdjustmentAmount

	            ELSE 0 END) AS PendingPrebillAdjustmentAmount,





        -- POSTBILL ADJUSTMENTS:



        CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')	

            THEN postbillajs.AdjustmentAmount

            ELSE 0 END + {fn IFNULL((tmp.PostbillCompoundAdjustmentAmount), 0.0)} AS CompoundPostbillAdjustmentAmount,





        -- when calculating postbill adjusted amounts, always consider prebill adjusted amounts

        (au.amount + CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')	

            THEN postbillajs.AdjustmentAmount

            ELSE 0 END  + {fn IFNULL((tmp.PostbillCompoundAdjustmentAmount), 0.0)} 

        + 

        --bring in prebill adjustments

        CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	

            THEN prebillajs.AdjustmentAmount

            ELSE 0 END

            + 

            {fn IFNULL((tmp.PrebillCompoundAdjustmentAmount), 0.0)}

        ) 

            AS CompoundPostbillAdjustedAmount,

             

        (CASE WHEN (postbillajs.id_adj_trx IS NOT NULL AND postbillajs.c_status = 'A')	

	            THEN postbillajs.AdjustmentAmount

	            ELSE 0 END) AS AtomicPostbillAdjustmentAmount, 



        -- when calculating postbill adjusted amounts, always consider prebill adjusted amounts

        (au.amount + (CASE WHEN (postbillajs.AdjustmentAmount IS NOT NULL AND postbillajs.c_status = 'A')	

	            THEN postbillajs.AdjustmentAmount

	            ELSE 0 END) 

        --bring in prebill adjustments

        +

        (CASE WHEN (prebillajs.AdjustmentAmount IS NOT NULL AND prebillajs.c_status = 'A')	

	            THEN prebillajs.AdjustmentAmount

	            ELSE 0 END)

        	    

	            ) AS AtomicPostbillAdjustedAmount,

	       

       (CASE WHEN (postbillajs.id_adj_trx IS NOT NULL AND postbillajs.c_status = 'P')	

	            THEN postbillajs.AdjustmentAmount

	            ELSE 0 END) AS PendingPostbillAdjustmentAmount,





        -- 2. Return Adjustment Transaction IDs for both prebill and postbill adjustments (or -1 if none): 



        (CASE WHEN prebillajs.id_adj_trx IS NULL THEN -1 ELSE prebillajs.id_adj_trx END) AS PrebillAdjustmentID,

        (CASE WHEN postbillajs.id_adj_trx IS NULL THEN -1 ELSE postbillajs.id_adj_trx END) AS PostbillAdjustmentID,



        -- 3. Return Adjustment Template IDs for both prebill and postbill adjustments (or -1 if none): 



        (CASE WHEN prebillajs.id_aj_template IS NULL THEN -1 ELSE prebillajs.id_aj_template END) AS PrebillAdjustmentTemplateID,

        (CASE WHEN postbillajs.id_aj_template IS NULL THEN -1 ELSE postbillajs.id_aj_template END) AS PostbillAdjustmentTemplateID,



        -- 4. Return Adjustment Instance IDs for both prebill and postbill adjustments (or -1 if none): 



        (CASE WHEN prebillajs.id_aj_instance IS NULL THEN -1 ELSE prebillajs.id_aj_instance END) AS PrebillAdjustmentInstanceID,

        (CASE WHEN postbillajs.id_aj_instance IS NULL THEN -1 ELSE postbillajs.id_aj_instance END) AS PostbillAdjustmentInstanceID,



        -- 5. Return Adjustment ReasonCode IDs for both prebill and postbill adjustments (or -1 if none): 



        (CASE WHEN prebillajs.id_reason_code IS NULL THEN -1 ELSE prebillajs.id_reason_code END) AS PrebillAdjustmentReasonCodeID,

        (CASE WHEN postbillajs.id_reason_code IS NULL THEN -1 ELSE postbillajs.id_reason_code END) AS PostbillAdjustmentReasonCodeID,





        -- 6. Return Adjustment Descriptions and default descriptions for both prebill and postbill adjustments (or empty string if none): 



        (CASE WHEN prebillajs.tx_desc IS NULL THEN '' ELSE prebillajs.tx_desc END) AS PrebillAdjustmentDescription,

        (CASE WHEN postbillajs.tx_desc IS NULL THEN '' ELSE postbillajs.tx_desc END) AS PostbillAdjustmentDescription,

        (CASE WHEN prebillajs.tx_default_desc IS NULL THEN '' ELSE prebillajs.tx_default_desc END) AS PrebillAdjustmentDefaultDescription,

        (CASE WHEN postbillajs.tx_default_desc IS NULL THEN '' ELSE postbillajs.tx_default_desc END) AS PostbillAdjustmentDefaultDescription,

        

        -- 7. Return Adjustment Status as following: If transaction interval is either open or soft closed, return prebill adjustment status or 'NA' if none;

        --    If transaction interval is hard closed, return post bill adjustment status or 'NA' if none

        (CASE WHEN (tui.tx_interval_status in ('O', 'C') AND  prebillajs.id_adj_trx IS NOT NULL) THEN prebillajs.c_status

         ELSE

        (CASE WHEN (tui.tx_interval_status = 'H' AND postbillajs.id_adj_trx IS NOT NULL) THEN postbillajs.c_status ELSE 'NA' END)

        END) AS AdjustmentStatus,





        -- 8. Return Adjustment Template and Instance Display Names for both prebill and postbill adjustments (or empty string if none): 

        --    if needed,  we can return name and descriptions from t_base_props



        -- CASE WHEN (prebillajtemplatedesc.tx_desc IS NULL) THEN '' ELSE prebillajtemplatedesc.tx_desc END  AS PrebillAdjustmentTemplateDisplayName,

        -- CASE WHEN (postbillajtemplatedesc.tx_desc IS NULL) THEN '' ELSE postbillajtemplatedesc.tx_desc END  AS PostbillAdjustmentTemplateDisplayName,



        -- CASE WHEN (prebillajinstancedesc.tx_desc IS NULL) THEN '' ELSE prebillajinstancedesc.tx_desc END  AS PrebillAdjustmentInstanceDisplayName,

        -- CASE WHEN (postbillajinstancedesc.tx_desc IS NULL) THEN '' ELSE postbillajinstancedesc.tx_desc END  AS PostbillAdjustmentInstanceDisplayName,



        -- 9. Return Reason Code Name, Description, Display Name for both prebill and post bill adjustments (or empty string if none)



        -- CASE WHEN (prebillrcdesc.tx_desc IS NULL) THEN '' ELSE prebillrcdesc.tx_desc END  AS PrebillAdjustmentReasonCodeDisplayName,

        -- CASE WHEN (postbillrcdesc.tx_desc IS NULL) THEN '' ELSE postbillrcdesc.tx_desc END  AS PostbillAdjustmentReasonCodeDisplayName,







        -- 10. Return different flags indicating status of a transaction in regard to adjustments





        -- Transactions are not considered to be adjusted if status is not 'A'

        (CASE WHEN (prebillajs.id_adj_trx IS NOT NULL AND prebillajs.c_status = 'A')

        OR (postbillajs.id_adj_trx IS NOT NULL AND postbillajs.c_status = 'A')

	            THEN 'Y' ELSE 'N' END) AS IsAdjusted,

        	    	    

        (CASE WHEN (prebillajs.id_adj_trx IS NOT NULL AND prebillajs.c_status = 'A')	

	            THEN 'Y' ELSE 'N' END) AS IsPrebillAdjusted,

        	    

        (CASE WHEN (postbillajs.id_adj_trx IS NOT NULL AND postbillajs.c_status = 'A')	

	            THEN 'Y' ELSE 'N' END) AS IsPostbillAdjusted,



        (CASE WHEN tui.tx_interval_status in ('N','O')	

		        THEN 'Y' 

		        ELSE 'N' END) AS IsPreBill,



        --can not adjust transactions:

        --1. in soft closed interval

        --2. If transaction is Prebill and it was already prebill adjusted

        --3. If transaction is Post bill and it was already postbill adjusted

        (CASE WHEN	

          (tui.tx_interval_status in	('C')) OR

          (tui.tx_interval_status =	'O' AND prebillajs.id_adj_trx IS NOT NULL) OR

          (tui.tx_interval_status =	'H' AND postbillajs.id_adj_trx IS NOT NULL)

	        then 'N'  else 'Y' end)	AS CanAdjust,



        -- Can not Rebill transactions:

        -- 1. If they are child transactions

        -- 2. in soft closed interval

        -- 3. If transaction is Prebill and it (or it's children) have already been adjusted (need to delete adjustments first)

        -- 4. If transaction is Postbill and it (or it's children) have already been adjusted (need to delete adjustments first)

        --    Above case will take care of possibility of someone trying to do PostBill rebill over and over again.

          (CASE WHEN	

          (au.id_parent_sess IS NOT NULL) 

	        OR

          (tui.tx_interval_status =	('C')) 

          OR

          (tui.tx_interval_status =	'O' AND (prebillajs.id_adj_trx IS NOT NULL 

          OR (tmp.NumChildrenPrebillAdjusted IS NOT NULL AND tmp.NumChildrenPrebillAdjusted > 0)) )

          OR

          (tui.tx_interval_status =	'H' AND (postbillajs.id_adj_trx IS NOT NULL 

          OR (tmp.NumChildrenPostbillAdjusted IS NOT NULL AND tmp.NumChildrenPostbillAdjusted > 0)))

          then 'N' else 'Y' end)	AS CanRebill,

        	

        -- Return 'N' if

        -- 1. Transaction hasn't been prebill adjusted yet

        -- 2. Transaction has been prebill adjusted but transaction interval is already closed

        -- Otherwise return 'Y'

        (CASE WHEN (prebillajs.id_adj_trx IS NOT NULL) THEN

        (CASE WHEN tui.tx_interval_status in ('C', 'H') then 'N'  else 'Y' end)

        ELSE 'N' END)

        AS CanManagePrebillAdjustment,

        

        -- Return 'N' if

        -- 1. If adjustment is postbill rebill

        -- 2. Transaction hasn't been postbill adjusted

        -- 3. Transaction has been postbill adjusted but payer's interval is already closed

        -- Otherwise return 'Y'

        

        (CASE WHEN (postbillajs.id_adj_trx IS NOT NULL)

        THEN

        (CASE WHEN (ajui.tx_interval_status in ('C', 'H') OR

        postbillajtype.n_adjustmenttype = 4) then 'N'  else 'Y' end)

        ELSE 'N' END)

        AS CanManagePostbillAdjustment,

        

        -- This calculates the logical AND of the above two flags.

        -- CR 9547 fix: Start with postbillajs. If transaction was both

        -- pre and post bill adjusted, we should be able to manage it

        -- CR 9548 fix: should not be able to manage REBILL adjustment

          

        (CASE WHEN (postbillajs.id_adj_trx IS NOT NULL) THEN

        (CASE WHEN (ajui.tx_interval_status in ('C', 'H') OR

        postbillajtype.n_adjustmenttype = 4) then 'N'  else 'Y' end)

        ELSE 

        (CASE WHEN (prebillajs.id_adj_trx IS NOT NULL) THEN

        (CASE WHEN tui.tx_interval_status in ('C', 'H') then 'N'  else 'Y' end)

        ELSE 'N' END)

        END)

        AS CanManageAdjustments,

        

        

        (CASE WHEN (tui.tx_interval_status =	'C' ) THEN 'Y' ELSE 'N' END) As IsIntervalSoftClosed,

        

        -- return the number of adjusted children

        -- or 0 for child transactions of a compound

        CASE WHEN tmp.NumApprovedChildrenPrebillAdjusted IS NULL 

        THEN 0 

          ELSE tmp.NumApprovedChildrenPrebillAdjusted

        END

        AS NumPrebillAdjustedChildren,

        

        CASE WHEN tmp.NumApprovedChildrenPostbillAdjusted IS NULL 

        THEN 0 

          ELSE tmp.NumApprovedChildrenPostbillAdjusted

        END

        AS NumPostbillAdjustedChildren





        from



        t_acc_usage au 

        left outer join t_adjustment_transaction prebillajs on prebillajs.id_sess=au.id_sess AND prebillajs.c_status IN ('A', 'P') AND prebillajs.n_adjustmenttype=0

        left outer join t_adjustment_transaction postbillajs on postbillajs.id_sess=au.id_sess AND postbillajs.c_status IN ('A', 'P') AND postbillajs.n_adjustmenttype=1

        -- Damn, this is going to kill us unless we index on id_parent_sess!!!!!!!!!!!!!!!!

        left outer join

        (

        select childau.id_parent_sess, 

        SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status = 'A')	

	          THEN childprebillajs.AdjustmentAmount

	          ELSE 0 END) PrebillCompoundAdjustmentAmount, 

        SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status = 'A')	

	        THEN childpostbillajs.AdjustmentAmount

	        ELSE 0 END) PostbillCompoundAdjustmentAmount,



        -- Approved or Pending adjusted kids

        SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NULL) THEN 0 ELSE 1 END) NumChildrenPrebillAdjusted,

        SUM(CASE WHEN (childpostbillajs.AdjustmentAmount IS NULL) THEN 0 ELSE 1 END) NumChildrenPostbillAdjusted,

        -- Approved adjusted kids (I didn't want to change the above flag because it's used for CanRebill flag calculation)

        SUM(CASE WHEN (childprebillajs.AdjustmentAmount IS NOT NULL AND childprebillajs.c_status ='A') THEN 1 ELSE 0 END) NumApprovedChildrenPrebillAdjusted,

        SUM(CASE WHEN  (childpostbillajs.AdjustmentAmount IS NOT NULL AND childpostbillajs.c_status ='A')  THEN 1 ELSE 0 END)AS NumApprovedChildrenPostbillAdjusted





        from

        t_acc_usage childau 

        left outer join t_adjustment_transaction childprebillajs on childprebillajs.id_sess=childau.id_sess AND childprebillajs.c_status IN ('A', 'P') AND childprebillajs.n_adjustmenttype=0

        left outer join t_adjustment_transaction childpostbillajs on childpostbillajs.id_sess=childau.id_sess AND childpostbillajs.c_status IN ('A', 'P') AND childpostbillajs.n_adjustmenttype=1

        group by childau.id_parent_sess

        ) 

        tmp on tmp.id_parent_sess=au.id_sess

        INNER JOIN t_usage_interval tui on au.id_usage_interval = tui.id_interval

        LEFT OUTER JOIN t_usage_interval ajui on postbillajs.id_usage_interval = ajui.id_interval

        

        --need to bring in adjustment type in order to set ManageAdjustments flag to false in case

        -- of REBILL adjustment type

        LEFT OUTER JOIN t_adjustment_type prebillajtype on prebillajtype.id_prop = prebillajs.id_aj_type 

        LEFT OUTER JOIN t_adjustment_type postbillajtype on postbillajtype.id_prop = postbillajs.id_aj_type 







        --resolve adjustment template or instance name

        -- This view is used in MPS. So if having those baseprops/desc joins becomes too expensive then

        -- they should be removed from this view



        -- AJ INSTANCE JOINs

        --LEFT OUTER JOIN t_base_props prebillajinstancebp ON prebillajs.id_aj_instance = prebillajinstancebp.id_prop

        --LEFT OUTER JOIN t_description  prebillajinstancedesc ON prebillajinstancebp.n_display_name = prebillajinstancedesc.id_desc



        --LEFT OUTER JOIN t_base_props postbillajinstancebp ON postbillajs.id_aj_instance = postbillajinstancebp.id_prop

        --LEFT OUTER JOIN t_description  postbillajinstancedesc ON postbillajinstancebp.n_display_name = prebillajinstancedesc.id_desc



        -- AJ TEMPLATE JOINs

        -- LEFT OUTER JOIN t_base_props prebillajtemplatebp ON prebillajs.id_aj_template = prebillajtemplatebp.id_prop

        -- LEFT OUTER JOIN t_description  prebillajtemplatedesc ON prebillajtemplatebp.n_display_name = prebillajtemplatedesc.id_desc



        -- LEFT OUTER JOIN t_base_props postbillajtemplatebp ON postbillajs.id_aj_template = postbillajtemplatebp.id_prop

        -- LEFT OUTER JOIN t_description  postbillajtemplatedesc ON postbillajtemplatebp.n_display_name = postbillajtemplatedesc.id_desc



        -- Reason Code JOINs

        -- LEFT OUTER JOIN t_base_props prebillrcbp ON prebillajs.id_reason_code = prebillrcbp.id_prop

        -- LEFT OUTER JOIN t_description  prebillrcdesc ON prebillrcbp.n_display_name = prebillrcdesc.id_desc



        -- LEFT OUTER JOIN t_base_props postbillrcbp ON postbillajs.id_aj_template = postbillrcbp.id_prop

        -- LEFT OUTER JOIN t_description  postbillrcdesc ON postbillrcbp.n_display_name = postbillrcdesc.id_desc



				 
        
GO
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

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


        

          CREATE view VW_ADJUSTMENT_DETAILS as

          select

          ajt.id_adj_trx,

          ajt.id_reason_code,

          ajt.id_acc_creator,

          ajt.id_acc_payer,

          ajt.c_status,

          ajt.dt_crt AS AdjustmentCreationDate,

          ajt.dt_modified,

          ajt.id_aj_type,

          ajt.id_aj_template,

          ajt.id_aj_instance,

          ajt.id_usage_interval AS AdjustmentUsageInterval,

          ajt.tx_desc,

          ajt.tx_default_desc,

          ajt.n_adjustmenttype,

          CASE WHEN (ajtemplatedesc.tx_desc IS NULL) THEN '' ELSE ajtemplatedesc.tx_desc END  AS AdjustmentTemplateDisplayName,

          CASE WHEN (ajinstancedesc.tx_desc IS NULL) THEN '' ELSE ajinstancedesc.tx_desc END  AS AdjustmentInstanceDisplayName,

          CASE WHEN (rcbp.nm_name IS NULL) THEN '' ELSE rcbp.nm_name END  AS ReasonCodeName,

          CASE WHEN (rcbp.nm_desc IS NULL) THEN '' ELSE rcbp.nm_desc END  AS ReasonCodeDescription,

          CASE WHEN (rcdesc.tx_desc IS NULL) THEN '' ELSE rcdesc.tx_desc END  AS ReasonCodeDisplayName,

          ajtemplatedesc.id_lang_code AS LanguageCode,

          ajinfo.AtomicPrebillAdjustmentAmount AS PrebillAdjustmentAmount,

          ajinfo.AtomicPostbillAdjustmentAmount AS PostbillAdjustmentAmount,

          ajinfo.*

          FROM t_adjustment_transaction ajt

          INNER JOIN VW_AJ_INFO ajinfo ON ajt.id_sess = ajinfo.id_sess

          --resolve adjustment template or instance name

          INNER JOIN t_base_props ajtemplatebp ON ajt.id_aj_template = ajtemplatebp.id_prop

          INNER JOIN t_description  ajtemplatedesc ON ajtemplatebp.n_display_name = ajtemplatedesc.id_desc

          LEFT OUTER JOIN t_base_props ajinstancebp ON ajt.id_aj_instance = ajinstancebp.id_prop

          LEFT OUTER JOIN t_description  ajinstancedesc ON ajinstancebp.n_display_name = ajinstancedesc.id_desc

          --resolve adjustment reason code name

          INNER JOIN t_base_props rcbp ON ajt.id_reason_code = rcbp.id_prop

          INNER JOIN t_description  rcdesc ON rcbp.n_display_name = rcdesc.id_desc

          WHERE ajt.c_status = 'A'

          AND 

          (

          ajinstancedesc.id_lang_code IS NULL OR  ((ajinstancedesc.id_lang_code = ajtemplatedesc.id_lang_code)

          AND (ajinstancedesc.id_lang_code = rcdesc.id_lang_code))

          )

				 
        
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


        

          CREATE view VW_NOTDELETED_ADJUSTMENT_DETAILS as

           select

          ajt.id_adj_trx,

          ajt.id_reason_code,

          ajt.id_acc_creator,

          ajt.id_acc_payer,

          ajt.c_status,

          ajt.dt_crt AS AdjustmentCreationDate,

          ajt.dt_modified,

          ajt.id_aj_type,

          ajt.id_aj_template,

          ajt.id_aj_instance,

          ajt.id_usage_interval AS AdjustmentUsageInterval,

          ajt.tx_desc,

          ajt.tx_default_desc,

          ajt.n_adjustmenttype,

          CASE WHEN (ajtemplatedesc.tx_desc IS NULL) THEN '' ELSE ajtemplatedesc.tx_desc END  AS AdjustmentTemplateDisplayName,

          CASE WHEN (ajinstancedesc.tx_desc IS NULL) THEN '' ELSE ajinstancedesc.tx_desc END  AS AdjustmentInstanceDisplayName,

          CASE WHEN (rcbp.nm_name IS NULL) THEN '' ELSE rcbp.nm_name END  AS ReasonCodeName,

          CASE WHEN (rcbp.nm_desc IS NULL) THEN '' ELSE rcbp.nm_desc END  AS ReasonCodeDescription,

          CASE WHEN (rcdesc.tx_desc IS NULL) THEN '' ELSE rcdesc.tx_desc END  AS ReasonCodeDisplayName,

          ajtemplatedesc.id_lang_code AS LanguageCode,

          ajinfo.AtomicPrebillAdjustmentAmount AS PrebillAdjustmentAmount,

          ajinfo.AtomicPostbillAdjustmentAmount AS PostbillAdjustmentAmount,

          ajinfo.*

          FROM t_adjustment_transaction ajt

          INNER JOIN VW_AJ_INFO ajinfo ON ajt.id_sess = ajinfo.id_sess

          --resolve adjustment template or instance name

          INNER JOIN t_base_props ajtemplatebp ON ajt.id_aj_template = ajtemplatebp.id_prop

          INNER JOIN t_description  ajtemplatedesc ON ajtemplatebp.n_display_name = ajtemplatedesc.id_desc

          LEFT OUTER JOIN t_base_props ajinstancebp ON ajt.id_aj_instance = ajinstancebp.id_prop

          LEFT OUTER JOIN t_description  ajinstancedesc ON ajinstancebp.n_display_name = ajinstancedesc.id_desc

          --resolve adjustment reason code name

          INNER JOIN t_base_props rcbp ON ajt.id_reason_code = rcbp.id_prop

          INNER JOIN t_description  rcdesc ON rcbp.n_display_name = rcdesc.id_desc

          

          WHERE ajt.c_status IN ('A', 'P')

          AND 

          (

          ajinstancedesc.id_lang_code IS NULL OR  ((ajinstancedesc.id_lang_code = ajtemplatedesc.id_lang_code)

          AND(ajinstancedesc.id_lang_code = rcdesc.id_lang_code))

          )

				 
        
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AddSecond]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[AddSecond]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CSVToInt]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[CSVToInt]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CheckGroupMembershipCycleConstraint]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[CheckGroupMembershipCycleConstraint]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DoesAccountHavePayees]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[DoesAccountHavePayees]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[EnclosedDateRange]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[EnclosedDateRange]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetCurrentIntervalID]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[GetCurrentIntervalID]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetEventExecutionDeps]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[GetEventExecutionDeps]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetEventReversalDeps]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[GetEventReversalDeps]
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IsIntervalOpen]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[IsIntervalOpen]
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MTHexFormat]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[MTHexFormat]
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[POContainsBillingCycleRelative]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[POContainsBillingCycleRelative]
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

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO


  

CREATE FUNCTION CSVToInt (@array VARCHAR(4000)) 

RETURNS @IntTable TABLE (value INT)

AS

BEGIN

  DECLARE @separator CHAR(1)

  SET @separator = ','



	DECLARE @separator_position INT 

	DECLARE @array_value VARCHAR(100) 

	

	SET @array = @array + ','

	

	WHILE PATINDEX('%,%' , @array) <> 0 

	BEGIN

	  SELECT @separator_position = PATINDEX('%,%' , @array)

	  SELECT @array_value = LEFT(@array, @separator_position - 1)

	

		INSERT @IntTable

		VALUES (CAST(@array_value AS INT))



	  SELECT @array = STUFF(@array, 1, @separator_position, '')

	END



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


  

CREATE FUNCTION CheckGroupMembershipCycleConstraint

(

  @dt_now DATETIME, -- system date

  @id_group INT     -- group ID to check

)

RETURNS INT  -- 1 for success, otherwise negative decimal error code 

AS

BEGIN



  -- this function enforces the business rule given in CR9906

  -- a group subscription to a PO containing a BCR priceable item

  -- should only have member's with payers that have a usage cycle

  -- that matches the one specified by the group subscription.

  -- at any point in time, this cycle consistency should hold true. 



  -- looks up the PO the group is subscribed to

  DECLARE @id_po INT

  SELECT @id_po = sub.id_po

  FROM t_group_sub gs

  INNER JOIN t_sub sub ON sub.id_group = gs.id_group

  WHERE gs.id_group = @id_group



  -- this check only applies to PO's that contain a BCR priceable item

  IF dbo.POContainsBillingCycleRelative(@id_po) = 1 -- true

  BEGIN

    

    -- attempts to find a usage cycle mismatch for the member's payers of the group sub

    -- ideally there should be none

    DECLARE @violator INT

    SELECT TOP 1 @violator = gsm.id_acc

    FROM t_gsubmember gsm

    INNER JOIN t_group_sub gs ON gs.id_group = gsm.id_group

    INNER JOIN t_sub sub ON sub.id_group = gs.id_group

    INNER JOIN t_payment_redirection payer ON 

      payer.id_payee = gsm.id_acc AND

      -- checks all payer's who overlap with the group sub

      payer.vt_end >= sub.vt_start AND

      payer.vt_start <= sub.vt_end

    INNER JOIN t_acc_usage_cycle auc ON

      auc.id_acc = payer.id_payer AND

      -- cycle mismatch

      auc.id_usage_cycle <> gs.id_usage_cycle

    WHERE 

      -- checks only the requested group

      gs.id_group = @id_group AND

      -- only consider current or future group subs

      -- don't worry about group subs in the past

      ((@dt_now BETWEEN sub.vt_start AND sub.vt_end) OR

       (sub.vt_start > @dt_now))



    IF @@rowcount > 0

      -- MT_GROUP_SUB_MEMBER_CYCLE_MISMATCH

      RETURN -486604730

  END

  

  -- success

  RETURN 1

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


		

		create function GetCurrentIntervalID (@aDTNow datetime, @aDTSession datetime, @aAccountID int) returns int

		as

		begin

      declare @retVal as int

      SELECT  @retVal =  id_usage_interval FROM  t_acc_usage_interval aui  

         INNER JOIN t_usage_interval ui ON ui.id_interval = aui.id_usage_interval

         WHERE ui.tx_interval_status IN ('N', 'O') AND

 		     @aDTSession BETWEEN ui.dt_start AND ui.dt_end AND

	      ((aui.dt_effective IS NULL) OR (aui.dt_effective <= @aDTNow))

        AND aui.id_acc = @aAccountID

      return @retVal

    end

		
		
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO


  

CREATE FUNCTION GetEventExecutionDeps(@dt_now DATETIME, @id_instances VARCHAR(4000))

RETURNS @deps TABLE

(

  id_orig_event INT NOT NULL,

  id_orig_instance INT NOT NULL,

  tx_orig_name VARCHAR(255) NOT NULL, -- useful for debugging

  tx_name VARCHAR(255) NOT NULL,      -- useful for debugging

  id_event INT NOT NULL,

  id_instance INT,

  id_arg_interval INT,

  dt_arg_start DATETIME,

  dt_arg_end DATETIME,

  tx_status VARCHAR(14)

)

AS

BEGIN



  DECLARE @args TABLE

  ( 

    id_instance INT NOT NULL

  )

  

  -- builds up a table from the comma separated list of instance IDs

  -- if the list is null, then add all ReadyToRun instances

  IF (@id_instances IS NOT NULL)

  BEGIN

    INSERT INTO @args

    SELECT value FROM CSVToInt(@id_instances)

  END

  ELSE

  BEGIN

    INSERT INTO @args

    SELECT id_instance 

    FROM t_recevent_inst

    WHERE tx_status = 'ReadyToRun'

  END





  DECLARE @instances TABLE

  (

    id_event INT NOT NULL,

    tx_type VARCHAR(11) NOT NULL,

    tx_name VARCHAR(255) NOT NULL,

    id_instance INT NOT NULL,

    id_arg_interval INT,

    dt_arg_start DATETIME,

    dt_arg_end DATETIME

  )



  --

  -- inserts all active 'ReadyToRun' instances or the instanceID passed in

  --

  INSERT INTO @instances

  SELECT

    evt.id_event,

    evt.tx_type,

    evt.tx_name,

    inst.id_instance,

    inst.id_arg_interval,

    -- in the case of EOP then, use the interval's start date

    CASE WHEN evt.tx_type = 'Scheduled' THEN inst.dt_arg_start ELSE intervals.dt_start END,

    -- in the case of EOP then, use the interval's end date

    CASE WHEN evt.tx_type = 'Scheduled' THEN inst.dt_arg_end ELSE intervals.dt_end END

  FROM t_recevent_inst inst

  INNER JOIN @args args ON args.id_instance = inst.id_instance

  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event

  LEFT OUTER JOIN t_pc_interval intervals ON intervals.id_interval = inst.id_arg_interval

  WHERE

    -- event is active

    evt.dt_activated <= @dt_now AND

    (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated)



  --

  -- inserts EOP to EOP dependencies

  --

  INSERT INTO @deps

  SELECT

    inst.id_event,

    inst.id_instance,

    inst.tx_name,

    depevt.tx_name,

    depevt.id_event,

    depinst.id_instance,

    depinst.id_arg_interval,

    NULL,

    NULL,

    CASE WHEN inst.id_instance = depinst.id_instance THEN

      -- treats the identity dependency as successful

      'Succeeded'

    ELSE

      depinst.tx_status

    END

  FROM @instances inst

  INNER JOIN t_recevent_dep dep ON dep.id_event = inst.id_event

  INNER JOIN t_recevent depevt ON depevt.id_event = dep.id_dependent_on_event

  INNER JOIN t_recevent_inst depinst ON depinst.id_event = depevt.id_event AND

                                        depinst.id_arg_interval = inst.id_arg_interval

  WHERE

    -- dep event is active

    depevt.dt_activated <= @dt_now AND

    (depevt.dt_deactivated IS NULL OR @dt_now < depevt.dt_deactivated) AND

    -- the original instance's event is root, EOP or a checkpoint event

    inst.tx_type IN ('Root', 'EndOfPeriod', 'Checkpoint') AND

    -- the dependency instance's event is an EOP or Checkpoint event

    depevt.tx_type IN ('EndOfPeriod', 'Checkpoint') 



--SELECT * FROM @deps  



  --

  -- inserts scheduled dependencies (including complete missing instances)

  --
  INSERT INTO @deps

  SELECT

    inst.id_event,

    inst.id_instance,

    inst.tx_name,

    depevt.tx_name,

    depevt.id_event,

    depinst.id_instance,

    NULL, -- id_arg_interval

    ISNULL(depinst.dt_arg_start, inst.dt_arg_start),

    ISNULL(depinst.dt_arg_end, inst.dt_arg_end),

    CASE WHEN inst.id_instance = depinst.id_instance THEN

      -- treats the identity dependency as successful

      'Succeeded'

    ELSE

      ISNULL(depinst.tx_status, 'Missing')

    END

  FROM @instances inst

  INNER JOIN t_recevent_dep dep ON dep.id_event = inst.id_event

  INNER JOIN t_recevent depevt ON depevt.id_event = dep.id_dependent_on_event

  LEFT OUTER JOIN t_recevent_inst depinst ON depinst.id_event = depevt.id_event AND

    -- enforce that the instance's dependency's start arg and end arg

    -- at least partially overlap with the original instance's start and end arguments

    depinst.dt_arg_start <= inst.dt_arg_end AND

    depinst.dt_arg_end >= inst.dt_arg_start

  WHERE

    -- dep event is active

    depevt.dt_activated <= @dt_now AND

    (depevt.dt_deactivated IS NULL OR @dt_now < depevt.dt_deactivated) AND

    depevt.tx_type = 'Scheduled'



--SELECT * FROM @deps ORDER BY tx_orig_name ASC



  -- inserts partially missing scheduled dependency instances (start to min)

  -- covers the original instance's start date to the minimum start date

  -- of all scheduled instances of an event

  INSERT INTO @deps

  SELECT

    inst.id_event,

    inst.id_instance,

    inst.tx_name,

    missingdeps.tx_name,

    missingdeps.id_event,

    NULL, -- id_instance,

    NULL, -- id_arg_interval

    inst.dt_arg_start,

    dbo.SubtractSecond(missingdeps.dt_min_arg_start),

    'Missing' -- tx_status

  FROM @instances inst

  INNER JOIN

  (

    -- gets the minimum arg start date per scheduled event

    SELECT

      deps.id_orig_instance,

      deps.id_event,

      deps.tx_name,

      MIN(deps.dt_arg_start) dt_min_arg_start

    FROM @deps deps

    INNER JOIN t_recevent evt ON evt.id_event = deps.id_event

    WHERE

      evt.tx_type = 'Scheduled' AND

      deps.tx_status <> 'Missing'

    GROUP BY

      deps.id_orig_instance,

      deps.id_event,

      deps.tx_name

  ) missingdeps ON missingdeps.id_orig_instance = inst.id_instance

  WHERE

    -- only adds a missing instance if the minimum start date is too late

    missingdeps.dt_min_arg_start > inst.dt_arg_start 





--SELECT * FROM @deps ORDER BY tx_orig_name ASC



  -- inserts partially missing scheduled dependency instances (max to end)

  -- covers the maximum end date of all scheduled instances of an event to the

  -- original instance's end date

  INSERT INTO @deps

  SELECT

    inst.id_event,

    inst.id_instance,

    inst.tx_name,

    missingdeps.tx_name,

    missingdeps.id_event,

    NULL, -- id_instance,

    NULL, -- id_arg_interval

    dbo.AddSecond(missingdeps.dt_max_arg_end),

    inst.dt_arg_end,

    'Missing' -- tx_status

  FROM @instances inst

  INNER JOIN

  (

    -- gets the maximum arg end date per scheduled event

    SELECT

      deps.id_orig_instance,

      deps.id_event,

      deps.tx_name,

      MAX(deps.dt_arg_end) dt_max_arg_end

    FROM @deps deps

    INNER JOIN t_recevent evt ON evt.id_event = deps.id_event

    WHERE

      evt.tx_type = 'Scheduled' AND

      deps.tx_status <> 'Missing'

    GROUP BY

      deps.id_orig_instance,

      deps.id_event,

      deps.tx_name

  ) missingdeps ON missingdeps.id_orig_instance = inst.id_instance

  WHERE

    -- only adds a missing instance if the maximum end date is too early

    missingdeps.dt_max_arg_end < inst.dt_arg_end 



--SELECT * FROM @deps ORDER BY tx_orig_name ASC

  RETURN

END

  
  
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO


  

CREATE FUNCTION GetEventReversalDeps(@dt_now DATETIME, @id_instances VARCHAR(4000))

RETURNS @deps TABLE

(

  id_orig_event INT NOT NULL,

  id_orig_instance INT NOT NULL,

  tx_orig_name VARCHAR(255) NOT NULL, -- useful for debugging

  tx_name VARCHAR(255) NOT NULL,      -- useful for debugging

  id_event INT NOT NULL,

  id_instance INT,

  id_arg_interval INT,

  dt_arg_start DATETIME,

  dt_arg_end DATETIME,

  tx_status VARCHAR(14)

)

AS

BEGIN



  DECLARE @args TABLE

  ( 

    id_instance INT NOT NULL

  )

  

  -- builds up a table from the comma separated list of instance IDs

  -- if the list is null, then add all ReadyToReverse instances

  IF (@id_instances IS NOT NULL)

  BEGIN

    INSERT INTO @args

    SELECT value FROM CSVToInt(@id_instances)

  END

  ELSE

  BEGIN

    INSERT INTO @args

    SELECT id_instance 

    FROM t_recevent_inst

    WHERE tx_status = 'ReadyToReverse'

  END





  DECLARE @instances TABLE

  (

    id_event INT NOT NULL,

    tx_type VARCHAR(11) NOT NULL,

    tx_name VARCHAR(255) NOT NULL,

    id_instance INT NOT NULL,

    id_arg_interval INT,

    dt_arg_start DATETIME,

    dt_arg_end DATETIME

  )



  --

  -- inserts all active instances found in @args

  --

  INSERT INTO @instances

  SELECT

    evt.id_event,

    evt.tx_type,

    evt.tx_name,

    inst.id_instance,

    inst.id_arg_interval,

    -- in the case of EOP then, use the interval's start date

    CASE WHEN evt.tx_type = 'Scheduled' THEN inst.dt_arg_start ELSE intervals.dt_start END,

    -- in the case of EOP then, use the interval's end date

    CASE WHEN evt.tx_type = 'Scheduled' THEN inst.dt_arg_end ELSE intervals.dt_end END

  FROM t_recevent_inst inst

  INNER JOIN @args args ON args.id_instance = inst.id_instance

  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event

  LEFT OUTER JOIN t_pc_interval intervals ON intervals.id_interval = inst.id_arg_interval

  WHERE

    -- event is active

    evt.dt_activated <= @dt_now AND

    (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated)



  --

  -- inserts EOP to EOP dependencies

  --

  INSERT INTO @deps

  SELECT

    inst.id_event,

    inst.id_instance,

    inst.tx_name,

    depevt.tx_name,

    depevt.id_event,

    depinst.id_instance,

    depinst.id_arg_interval,

    NULL,

    NULL,

    CASE WHEN inst.id_instance = depinst.id_instance THEN

      -- treats the identity dependency as NotYetRun

      'NotYetRun'

    ELSE

      depinst.tx_status

    END

  FROM @instances inst

  INNER JOIN t_recevent_dep dep ON dep.id_dependent_on_event = inst.id_event

  INNER JOIN t_recevent depevt ON depevt.id_event = dep.id_event

  INNER JOIN t_recevent_inst depinst ON depinst.id_event = depevt.id_event AND

                                        depinst.id_arg_interval = inst.id_arg_interval

  WHERE

    -- dep event is active

    depevt.dt_activated <= @dt_now AND

    (depevt.dt_deactivated IS NULL OR @dt_now < depevt.dt_deactivated) AND

    -- the original instance's event is root, EOP or a checkpoint event

    inst.tx_type IN ('Root', 'EndOfPeriod', 'Checkpoint') AND

    -- the dependency instance's event is an EOP or Checkpoint event

    depevt.tx_type IN ('EndOfPeriod', 'Checkpoint') 



--SELECT * FROM @deps ORDER BY tx_orig_name ASC



  --

  -- inserts scheduled dependencies

  --

  INSERT INTO @deps

  SELECT

    inst.id_event,

    inst.id_instance,

    inst.tx_name,

    depevt.tx_name,

    depevt.id_event,

    depinst.id_instance,

    NULL, -- id_arg_interval

    ISNULL(depinst.dt_arg_start, inst.dt_arg_start),

    ISNULL(depinst.dt_arg_end, inst.dt_arg_end),

    CASE WHEN inst.id_instance = depinst.id_instance THEN

      -- treats the identity dependency as NotYetRun
      'NotYetRun'

    ELSE

      depinst.tx_status

    END

  FROM @instances inst

  INNER JOIN t_recevent_dep dep ON dep.id_dependent_on_event = inst.id_event

  INNER JOIN t_recevent depevt ON depevt.id_event = dep.id_event

  INNER JOIN t_recevent_inst depinst ON depinst.id_event = depevt.id_event AND

    -- enforce that the instance's dependency's start arg and end arg

    -- at least partially overlap with the original instance's start and end arguments

    depinst.dt_arg_start <= inst.dt_arg_end AND

    depinst.dt_arg_end >= inst.dt_arg_start

  WHERE

    -- dep event is active

    depevt.dt_activated <= @dt_now AND

    (depevt.dt_deactivated IS NULL OR @dt_now < depevt.dt_deactivated) AND

    depevt.tx_type = 'Scheduled'



--SELECT * FROM @deps ORDER BY tx_orig_name ASC

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


		    

				create function IsAccountBillable(@id_acc int) 

        returns varchar

		    as

        begin

	      declare @billableFlag as char(1)

		    select @billableFlag = c_billable  from t_av_internal where 

		    id_acc = @id_acc

		    if (@billableFlag is NULL) 

					begin

		      select @billableFlag = '0'

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

					select @folderFlag = '0'

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


		    create FUNCTION IsCorporateAccount(
				@id_acc int,@RefDate Datetime) returns INT
				as
				begin
				declare @retval int
				 select @retval = id_descendent from t_account_ancestor 
				 where
         @RefDate between vt_start and vt_end AND
				 id_ancestor = 1 AND id_descendent = @id_acc AND num_generations = 1
				 if (@retval = @id_acc)
				  begin
					select @retval = 1
					end 
         if (@retval is null)
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


		

		

		CREATE  function IsIntervalOpen (@aDTNow datetime, @aIntervalID int) returns int

		as

		begin

      declare @retVal as int

      SET @retval = 0

      SELECT  @retVal = 

      CASE WHEN  

      ( 

        SELECT  tx_interval_status 

        FROM  t_usage_interval ui 

        WHERE @aDTNow BETWEEN ui.dt_start AND ui.dt_end AND id_interval = @aIntervalID

       )

        IN ('N', 'O') THEN 1 ELSE 0 END

        return @retVal

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


	

create function MTHexFormat(@value integer) returns varchar(255)

as

begin

 declare @binvalue varbinary(255)

	      ,@charvalue varchar(255)

        ,@i int

        ,@length int

        ,@hexstring char(16)

 select @charvalue = ''

       ,@i=1

       ,@binvalue = cast(@value as varbinary(4))

       ,@length=datalength(@binvalue)

       ,@hexstring = '0123456789abcdef'

 WHILE (@i<=@length)

   begin

     declare @tempint int

            ,@firstint int

            ,@secondint int

     select @tempint=CONVERT(int, SUBSTRING(@binvalue,@i,1))

     select @firstint=FLOOR(@tempint/16)

     select @secondint=@tempint - (@firstint*16)

     select @charvalue=@charvalue

           +SUBSTRING(@hexstring,@firstint+1,1)

           +SUBSTRING(@hexstring, @secondint+1, 1)

    select @i=@i+1

   end

 return @charvalue

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


				create function MTMaxDate() returns datetime
				as
				begin
					return '2038'
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


			create function MTMinDate() returns datetime
			as
			begin
				return '1753'
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


  

CREATE FUNCTION POContainsBillingCycleRelative

(

  @id_po INT  -- product offering ID

)

RETURNS INT  -- 1 if the PO contains BCR PIs, otherwise 0

AS

BEGIN

  DECLARE @found INT



  -- checks for billing cycle relative discounts

	SELECT @found = CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END 

	FROM t_pl_map plm 

	INNER JOIN t_base_props bp ON bp.id_prop = plm.id_pi_template

  INNER JOIN t_discount disc ON disc.id_prop = bp.id_prop

	WHERE 

    plm.id_po = @id_po AND

    disc.id_usage_cycle IS NULL



  IF @found = 1

	  RETURN @found



  -- checks for billing cycle relative recurring charges

	SELECT @found = CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END 

	FROM t_pl_map plm 

	INNER JOIN t_base_props bp ON bp.id_prop = plm.id_pi_template

  INNER JOIN t_recur rc ON rc.id_prop = bp.id_prop

	WHERE 

    plm.id_po = @id_po AND

    rc.id_usage_cycle IS NULL



  IF @found = 1

	  RETURN @found



  -- checks for billing cycle relative aggregate charges

	SELECT @found = CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END 

	FROM t_pl_map plm 

	INNER JOIN t_base_props bp ON bp.id_prop = plm.id_pi_template

  INNER JOIN t_aggregate agg ON agg.id_prop = bp.id_prop

	WHERE 

    plm.id_po = @id_po AND

    agg.id_usage_cycle IS NULL



  RETURN @found

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


				create function POContainsDiscount
				(@id_po int) returns int
				as
				begin
				declare @retval int
					select @retval = case when count(id_pi_template) > 0 then 1 else 0 end 
					from t_pl_map 
					INNER JOIN t_base_props tb on tb.id_prop = t_pl_map.id_pi_template
					where t_pl_map.id_po = @id_po AND tb.n_kind = 40
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

  LEFT OUTER JOIN t_recur on t_recur.id_prop = t_pl_map.id_pi_template OR t_recur.id_prop = t_pl_map.id_pi_instance

  LEFT OUTER JOIN t_discount on t_discount.id_prop = t_pl_map.id_pi_template  OR t_discount.id_prop = t_pl_map.id_pi_instance

  LEFT OUTER JOIN t_aggregate on t_aggregate.id_prop = t_pl_map.id_pi_template  OR t_aggregate.id_prop = t_pl_map.id_pi_instance

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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AcknowledgeCheckpoint]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AcknowledgeCheckpoint]
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AddCounterParamPredicate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AddCounterParamPredicate]
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AddNewAccount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AddNewAccount]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AddNewSub]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AddNewSub]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AddOwnedFolder]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AddOwnedFolder]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AddServiceEndpoint]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AddServiceEndpoint]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AddServiceEndpointIDMapping]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AddServiceEndpointIDMapping]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdjustGsubMemberDates]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdjustGsubMemberDates]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[AdjustSubDates]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[AdjustSubDates]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ApprovePayments]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ApprovePayments]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BulkSubscriptionChange]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[BulkSubscriptionChange]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CanBulkSubscribe]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CanBulkSubscribe]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CanExecuteEvents]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CanExecuteEvents]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CanReverseEvents]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CanReverseEvents]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CancelSubmittedEvent]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CancelSubmittedEvent]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CheckAccountCreationBusinessRules]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CheckAccountCreationBusinessRules]
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CloneSecurityPolicy]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CloneSecurityPolicy]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ConnectServiceEndpoint]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ConnectServiceEndpoint]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CreateAccountStateRecord]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CreateAccountStateRecord]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CreateAdjustmentType]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CreateAdjustmentType]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CreateCalculationFormula]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CreateCalculationFormula]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CreateCounterPropDef]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CreateCounterPropDef]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CreateGSubMemberRecord]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CreateGSubMemberRecord]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CreateGroupSubscription]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CreateGroupSubscription]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CreatePaymentRecord]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CreatePaymentRecord]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CreatePaymentRecordBitemporal]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CreatePaymentRecordBitemporal]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CreateSubscriptionRecord]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CreateSubscriptionRecord]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CreateTestRecurringEventInstance]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CreateTestRecurringEventInstance]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CreateUsageIntervals]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CreateUsageIntervals]
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DetermineExecutableEvents]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DetermineExecutableEvents]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DetermineReversibleEvents]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DetermineReversibleEvents]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DropAdjustmentTables]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[DropAdjustmentTables]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ExecSpProcOnKind]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ExecSpProcOnKind]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ExtendedUpsert]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ExtendedUpsert]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[FailZombieRecurringEvents]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[FailZombieRecurringEvents]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GenerateAdjustmentTables]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GenerateAdjustmentTables]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetAggregateChargeProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetAggregateChargeProps]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetBalances]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetBalances]
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetLastBalance]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetLastBalance]
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetServiceEndpointPropDefs]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[GetServiceEndpointPropDefs]
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[InsertChargeProperty]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[InsertChargeProperty]
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[InsertMeteredBatch]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[InsertMeteredBatch]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[InsertProductView]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[InsertProductView]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[InsertProductViewProperty]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[InsertProductViewProperty]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[InsertUsageCycleInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[InsertUsageCycleInfo]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[InsertUsageIntervalInfo]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[InsertUsageIntervalInfo]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[InstantiateScheduledEvent]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[InstantiateScheduledEvent]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IsAccBillableNPayingForOthers]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[IsAccBillableNPayingForOthers]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MTSP_INSERTINVOICE]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[MTSP_INSERTINVOICE]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MTSP_INSERTINVOICE_BALANCES]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[MTSP_INSERTINVOICE_BALANCES]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MTSP_INSERTINVOICE_DEFLTINVNUM]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[MTSP_INSERTINVOICE_DEFLTINVNUM]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MTSP_RATE_AGGREGATE_CHARGE]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[MTSP_RATE_AGGREGATE_CHARGE]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MT_SYS_ANALYZE_ALL_TABLES]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[MT_SYS_ANALYZE_ALL_TABLES]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MarkEventAsFailed]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[MarkEventAsFailed]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MarkEventAsSucceeded]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[MarkEventAsSucceeded]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ModifyBatchStatus]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ModifyBatchStatus]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[MoveAccount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[MoveAccount]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[OpenUsageInterval]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[OpenUsageInterval]
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ReRunAbandon]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ReRunAbandon]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ReRunAnalyze]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ReRunAnalyze]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ReRunCreate]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ReRunCreate]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ReRunIdentifyCompounds]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ReRunIdentifyCompounds]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ReRunRollback]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ReRunRollback]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RemoveAdjustmentTypeProps]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RemoveAdjustmentTypeProps]
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RemoveGroupSubscription]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RemoveGroupSubscription]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RemoveMemberFromRole]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RemoveMemberFromRole]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RemoveServiceEndpointIDMapping]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RemoveServiceEndpointIDMapping]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[RemoveSubscription]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[RemoveSubscription]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ReversePayments]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[ReversePayments]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reverse_UpdStateFromClosedToArchived]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reverse_UpdStateFromClosedToArchived]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reverse_UpdateStateFromClosedToPFB]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reverse_UpdateStateFromClosedToPFB]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reverse_UpdateStateFromPFBToClosed]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reverse_UpdateStateFromPFBToClosed]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Reverse_UpdateStateRecordSet]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[Reverse_UpdateStateRecordSet]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SequencedDeleteGsubRecur]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SequencedDeleteGsubRecur]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SequencedInsertGsubRecur]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SequencedInsertGsubRecur]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SequencedInsertGsubRecurInitialize]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SequencedInsertGsubRecurInitialize]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SequencedUpsertGsubRecur]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SequencedUpsertGsubRecur]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SetTariffs]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SetTariffs]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SoftCloseUsageIntervals]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SoftCloseUsageIntervals]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SubmitEventForExecution]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SubmitEventForExecution]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SubmitEventForReversal]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[SubmitEventForReversal]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UnacknowledgeCheckpoint]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UnacknowledgeCheckpoint]
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateCounterPropDef]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateCounterPropDef]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateGroupSubMembership]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateGroupSubMembership]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateGroupSubscription]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateGroupSubscription]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateMeteredCount]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateMeteredCount]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdatePaymentRecord]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdatePaymentRecord]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateProductViewProperty]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateProductViewProperty]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateServiceEndpointConnection]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateServiceEndpointConnection]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateServiceEndpointDates]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateServiceEndpointDates]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[UpdateServiceEndpointIDMapping]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[UpdateServiceEndpointIDMapping]
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

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[mtsp_BackoutInvoices]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[mtsp_BackoutInvoices]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_CreateEpSQL]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_CreateEpSQL]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_DeletePricelist]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_DeletePricelist]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_DeleteRateSchedule]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_DeleteRateSchedule]
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


  

CREATE PROCEDURE AcknowledgeCheckpoint

(

  @dt_now DATETIME,

  @id_instance INT,

  @b_ignore_deps VARCHAR(1),
  @id_acc INT,

  @tx_detail VARCHAR(2048),

  @status INT OUTPUT

)

AS

BEGIN



  -- NOTE: for now, just use the calling procedure's transaction



  SELECT @status = -99



  -- enforces that the checkpoints dependencies are satisfied

  IF (@b_ignore_deps = 'N')
  BEGIN

    DECLARE @unsatisfiedDeps INT

    SELECT @unsatisfiedDeps = COUNT(*) 

    FROM GetEventExecutionDeps (@dt_now, @id_instance)

    WHERE tx_status <> 'Succeeded'



    IF (@unsatisfiedDeps > 0)

    BEGIN

      SELECT @status = -4  -- deps aren't satisfied

      RETURN

    END

  END



  -- updates the checkpoint instance's state to 'Succeeded'

  UPDATE t_recevent_inst

  SET tx_status = 'Succeeded', b_ignore_deps = @b_ignore_deps, dt_effective = NULL

  FROM t_recevent_inst inst

  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event

  INNER JOIN t_usage_interval ui ON ui.id_interval = inst.id_arg_interval

  WHERE 

    -- event is active

    evt.dt_activated <= @dt_now AND

    (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) AND

    inst.id_instance = @id_instance AND

    -- checkpoint must presently be in the NotYetRun state

    inst.tx_status IN ('NotYetRun') AND

    -- interval, if any, must be in the closed state

    ui.tx_interval_status = 'C'



  -- if the update was made, return successfully

  IF (@@ROWCOUNT = 1)

  BEGIN



    -- records the action

    INSERT INTO t_recevent_inst_audit(id_instance,id_acc,tx_action,b_ignore_deps,dt_effective,tx_detail,dt_crt)

    VALUES(@id_instance, @id_acc, 'Acknowledge', @b_ignore_deps, NULL, @tx_detail, @dt_now) 

    SELECT @status = 0

    RETURN

  END



  --

  -- otherwise, attempts to figure out what went wrong

  --

  DECLARE @count INT

  SELECT @count = COUNT(*) FROM t_recevent_inst WHERE id_instance = @id_instance



  IF (@count = 0)

  BEGIN

    -- the instance does not exist

    SELECT @status = -1

    RETURN

  END



  SELECT @count = COUNT(*)

  FROM t_recevent_inst inst

  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event

  WHERE 

    -- event is active

    evt.dt_activated <= @dt_now AND

    (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) AND

    inst.tx_status = 'NotYetRun' AND

    inst.id_instance = @id_instance



  IF (@count = 0)

  BEGIN

    -- instance is not in the proper state

    SELECT @status = -2

    RETURN

  END



  SELECT @count = COUNT(*)  

  FROM t_recevent_inst inst

  INNER JOIN t_usage_interval ui ON ui.id_interval = inst.id_arg_interval

  WHERE 

    inst.id_instance = @id_instance AND

    ui.tx_interval_status = 'C'



  IF (@count = 0)

  BEGIN

    -- end-of-period instance's usage interval is not in the proper state

    SELECT @status = -5 

    RETURN

  END



  -- couldn't submit for some other unknown reason 

  SELECT @status = -99 

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

	if (@bfolder = '0')

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

-- TODO: we need error handling code to detect when the ancestor does 

-- not exist at the time interval!!

-- populate t_account_ancestor (no bitemporal data)

insert into t_account_ancestor (id_ancestor,id_descendent,

num_generations,vt_start,vt_end,tx_path)

select id_ancestor,@id_descendent,num_generations + 1,dbo.MTMaxOfTwoDates(vt_start,@realstartdate),dbo.MTMinOfTwoDates(vt_end,@realenddate),

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

	@p_id_sub int,             -- subscription ID of the group

	@p_id_group int,           -- group ID

	@p_id_po int,              -- product offering ID to which the group is subscribed

	@p_id_acc int,             -- account ID of the candidate member

	@p_startdate datetime,     -- date at which membership should begin

	@p_enddate datetime,       -- date at which membership should end

	@p_systemdate datetime,    -- current system time

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



  -- post-creation business rule check (relies on rollback of work done up until this point)

  -- CR9906: check to make sure the newly added member does not violate a BCR constraint

  SELECT @p_status = dbo.CheckGroupMembershipCycleConstraint(@p_systemdate, @p_id_group)

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


        

					create proc AddCounterInstance

					            @id_lang_code int,

											@n_kind int,

											@nm_name varchar(255),

											@nm_desc varchar(255),

											@counter_type_id int, 

											@id_prop int OUTPUT 

					as

					begin

						DECLARE @identity_value int

						exec InsertBaseProps @id_lang_code, @n_kind, 'N', 'N', @nm_name, @nm_desc, null, @identity_value output

					INSERT INTO t_counter (id_prop, id_counter_type) values (@identity_value, @counter_type_id)

					SELECT 

						@id_prop = @identity_value

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


    

			create proc AddCounterParam

                  @id_lang_code int,

									@id_counter int,

									@id_counter_param_type int,

									@nm_counter_value varchar(255),

                  @nm_name varchar(255),

                  @nm_desc varchar(255),

                  @nm_display_name varchar(255),

									@identity int OUTPUT

			AS

      DECLARE @identity_value int

			BEGIN TRAN

        exec InsertBaseProps @id_lang_code, 190, 'N', 'N', @nm_name, @nm_desc, @nm_display_name, @identity_value output

			INSERT INTO t_counter_params 

				(id_counter_param, id_counter, id_counter_param_meta, Value) 

			VALUES 

				(@identity_value, @id_counter, @id_counter_param_type, @nm_counter_value)

			SELECT 

				@identity = @identity_value

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


    

			create proc AddCounterParamPredicate

									@id_counter_param int,

									@id_pv_prop int,

                  @nm_op varchar(2),

									@nm_value varchar(255),

									@ap_id_prop int OUTPUT

			AS

			BEGIN TRAN

			INSERT INTO t_counter_param_predicate

				(id_counter_param, id_pv_prop, nm_op, nm_value) 

			VALUES 

				(@id_counter_param, @id_pv_prop, @nm_op, @nm_value)

			SELECT 

				@ap_id_prop = @@identity

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


     

						CREATE PROC AddCounterParamType			

									@id_lang_code int,

									@n_kind int,

									@nm_name varchar(255),

									@id_counter_type int,

									@nm_param_type varchar(255),

									@nm_param_dbtype varchar(255),

									@id_prop int OUTPUT 

			      AS

			      DECLARE @identity_value int

			      BEGIN TRAN

			      exec InsertBaseProps @id_lang_code, @n_kind, 'N', 'N', @nm_name, NULL, NULL, @identity_value output

			      INSERT INTO t_counter_params_metadata

					              (id_prop, id_counter_meta, ParamType, DBType) 

				    VALUES 

					              (@identity_value, @id_counter_type, @nm_param_type, @nm_param_dbtype)

            select @id_prop = @identity_value

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


			create proc AddICBMapping(@id_paramtable as int,
					@id_pi_instance as int,
					@id_sub as int,
					@id_acc as int,
					@id_po as int,
          @p_systemdate as datetime)
				as	
					declare @id_pi_type as int
					declare @id_pricelist as int
					declare @id_pi_template as int
					declare @id_pi_instance_parent as int
					declare @currency as varchar(10)
					select @id_pi_type = id_pi_type,@id_pi_template = id_pi_template,
					@id_pi_instance_parent = id_pi_instance_parent
					from
					t_pl_map where id_pi_instance = @id_pi_instance AND id_paramtable is NULL

					set @currency = (select c_currency from t_av_internal where id_acc = @id_acc)
					
					insert into t_base_props (n_kind,n_name,n_display_name,n_desc) values (150,0,0,0)
					set @id_pricelist = @@identity
					insert into t_pricelist(id_pricelist,n_type,nm_currency_code) values (@id_pricelist, 0, @currency)
					insert into t_pl_map(
              id_paramtable,
              id_pi_type,
              id_pi_instance,
              id_pi_template,
              id_pi_instance_parent,
              id_sub,
              id_po,
              id_pricelist,
              b_canICB,
              dt_modified
              )
					values(
              @id_paramtable,
              @id_pi_type,              
              @id_pi_instance,
              @id_pi_template,
              @id_pi_instance_parent,
              @id_sub,
              @id_po,
              @id_pricelist,
              'N',
              @p_systemdate
              )
		
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


				

CREATE PROCEDURE AddNewAccount(

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



	-- check account creation business rules

	IF (@p_nm_login not in ('rm', 'mps_folder'))

	BEGIN

	  exec CheckAccountCreationBusinessRules 

			 @p_nm_space, 

			 @p_acc_type, 

			 @p_id_ancestor, 

			 @status output

	  IF (@status <> 1)

		BEGIN

	  	RETURN

		END		

	END	



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





  --

  -- associates the account with the Usage Server

  --



	-- determines the usage cycle ID from the passed in date properties

	SELECT @usagecycleID = id_usage_cycle 

	FROM t_usage_cycle cycle 

  WHERE

	 cycle.id_cycle_type = @p_ID_CYCLE_TYPE AND

   (@p_DAY_OF_MONTH = cycle.day_of_month OR @p_DAY_OF_MONTH IS NULL) AND

   (@p_DAY_OF_WEEK = cycle.day_of_week OR @p_DAY_OF_WEEK IS NULL) AND

   (@p_FIRST_DAY_OF_MONTH = cycle.FIRST_DAY_OF_MONTH OR @p_FIRST_DAY_OF_MONTH IS NULL) AND

   (@p_SECOND_DAY_OF_MONTH = cycle.SECOND_DAY_OF_MONTH OR @p_SECOND_DAY_OF_MONTH IS NULL) AND

   (@p_START_DAY = cycle.START_DAY OR @p_START_DAY IS NULL) AND

   (@p_START_MONTH = cycle.START_MONTH OR @p_START_MONTH IS NULL) AND

   (@p_START_YEAR = cycle.START_YEAR OR @p_START_YEAR IS NULL)



  -- adds the account to usage cycle mapping

	INSERT INTO t_acc_usage_cycle VALUES (@accountID, @usagecycleID)



  -- creates any needed intervals and mappings

  EXEC CreateUsageIntervals @p_systemdate, NULL, NULL







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

 @p_status int output,

 @p_datemodified varchar(1) output)

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

select @p_datemodified = @datemodified

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

		select @status = -486604761

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


      



        CREATE PROCEDURE AddServiceEndpoint

          @a_id_prop int,

          @a_date_start DATETIME,

          @a_date_end DATETIME,

          @a_se_space varchar(40),

          @a_se_extid varchar(255),

          @a_corp_space varchar(40),

          @a_corp_extid varchar(255),

          @a_corp_id int,

          @a_se_id int OUTPUT,

          @a_se_corp_id int OUTPUT,

          @a_se_date_end DATETIME OUTPUT,

          @a_status int OUTPUT

        AS

          BEGIN

            DECLARE @a_resolved_corp_id as int

	          DECLARE @a_error as int

      	    DECLARE @a_temp as int

            DECLARE @a_transaction_started as int



      	    IF @@trancount = 0 BEGIN

              BEGIN TRAN

	            SET @a_transaction_started = 1

            END            

	          

            SET @a_status = 0

            --Check for NULL end date

            IF @a_date_end IS NULL BEGIN

              SET @a_date_end = dbo.MTMaxDate()

              SET @a_status = @@error

              IF @a_status <> 0 BEGIN

                 GOTO errHandler

              END

            END

            

            SET @a_se_date_end = @a_date_end

            

            --Check dates

            IF @a_date_start > @a_date_end BEGIN

              SET @a_status = -483458970

              GOTO errHandler

            END

            --Get an MT Value

            INSERT INTO t_mt_id default values

            SET @a_status = @@error

            SET @a_se_id = @@identity

            IF @a_status <> 0 BEGIN

              GOTO errHandler

            END

     

            --Create an entry in t_service_endpoint

            INSERT INTO t_service_endpoint (id_se, id_prop, dt_start, dt_end) VALUES (@a_se_id, @a_id_prop, @a_date_start, @a_date_end)

            SET @a_status = @@error

            IF @a_status <> 0 BEGIN

              GOTO errHandler

            END

            --If creating with namespace / name

            IF @a_corp_id IS NULL BEGIN

              --If creating globally unique

              IF @a_corp_extid IS NULL AND @a_corp_space IS NULL BEGIN

            		--Check for duplicate

              		SELECT 

            		  @a_temp = COUNT(*) 

            		FROM 

            		  t_se_mapper tsem

            		  INNER JOIN t_service_endpoint tse on tsem.id_se = tse.id_se

            		WHERE

            		  id_corp IS NULL AND 

            		  LOWER(nm_space) = LOWER(@a_se_space) AND 

            		  LOWER(nm_login) = LOWER(@a_se_extid) AND

            		  ((@a_date_start BETWEEN tse.dt_start AND tse.dt_end) OR

            		  (tse.dt_start BETWEEN @a_date_start AND @a_date_end))



                IF @a_temp > 0 BEGIN

                  SET @a_status = -483458954

                  GOTO errHandler

                END

  

                --Global SE

                SET @a_se_corp_id = NULL



                INSERT INTO t_se_mapper (id_se, id_corp, nm_space, nm_login, b_primary) VALUES (@a_se_id, NULL, @a_se_space, @a_se_extid, '1')

                SET @a_status = @@error

                IF @a_status <> 0 BEGIN

                 GOTO errHandler

                END

       	      END

       	      --Creating locally unique

              ELSE BEGIN

             		SET @a_resolved_corp_id = dbo.LookupAccount(@a_corp_extid, @a_corp_space)

                SET @a_status = @@error

                IF @a_status <> 0 BEGIN

                  GOTO errHandler

                END



          		--Check for duplicate

            		SELECT 

          		  @a_temp = COUNT(*) 

          		FROM 

          		  t_se_mapper tsem

          		  INNER JOIN t_service_endpoint tse on tsem.id_se = tse.id_se

          		WHERE

          		  id_corp = @a_resolved_corp_id AND 

          		  LOWER(nm_space) = LOWER(@a_se_space) AND 

          		  LOWER(nm_login) = LOWER(@a_se_extid) AND

          		  ((@a_date_start BETWEEN tse.dt_start AND tse.dt_end) OR

           		  (tse.dt_start BETWEEN @a_date_start AND @a_date_end))





                IF @a_temp > 0 BEGIN

                  SET @a_status = -483458954

                  GOTO errHandler

                END

                

                SET @a_se_corp_id = @a_resolved_corp_id



                INSERT INTO t_se_mapper (id_se, id_corp, nm_space, nm_login, b_primary) VALUES (@a_se_id, @a_resolved_corp_id, @a_se_space, @a_se_extid, '1')

                SET @a_status = @@error

                IF @a_status <> 0 BEGIN

                  GOTO errHandler

                END       	      

              END

            END

            --Create corporate

            ELSE BEGIN

        		--Check for duplicate

          		SELECT 

        		  @a_temp = COUNT(*) 

        		FROM 

        		  t_se_mapper tsem

        		  INNER JOIN t_service_endpoint tse on tsem.id_se = tse.id_se

        		WHERE

        		  id_corp = @a_corp_id AND 

        		  LOWER(nm_space) = LOWER(@a_se_space) AND 

        		  LOWER(nm_login) = LOWER(@a_se_extid) AND

        		  ((@a_date_start BETWEEN tse.dt_start AND tse.dt_end) OR

         		  (tse.dt_start BETWEEN @a_date_start AND @a_date_end))



              IF @a_temp > 0 BEGIN

                SET @a_status = -483458954

                GOTO errHandler

              END



              SET @a_se_corp_id = @a_corp_id

              

              INSERT INTO t_se_mapper (id_se, id_corp, nm_space, nm_login, b_primary) VALUES (@a_se_id, @a_corp_id, @a_se_space, @a_se_extid, '1')

              SET @a_status = @@error

              IF @a_status <> 0 BEGIN

                 GOTO errHandler

              END

            END

            --No errors, commit and return

            IF @a_transaction_started = 1 BEGIN

              COMMIT TRAN

              RETURN

           END

    

            --oops, an error occurred

            errHandler:

            IF @a_transaction_started = 1 BEGIN

              ROLLBACK TRAN

            END

           

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


        

         CREATE PROCEDURE AddServiceEndpointIDMapping

    @a_id_se int,

	          @a_id_corp int,

            @a_new_id VARCHAR(255),

            @a_new_space VARCHAR(40),

            @b_primary VARCHAR(1),

            @a_status int OUTPUT

          AS BEGIN

            DECLARE @a_temp AS INT

            DECLARE @a_transaction_started as int



      	    IF @@trancount = 0 BEGIN

              BEGIN TRAN

             SET @a_transaction_started = 1

            END               

          

            SET @a_status = 0

          

            --Make sure this mapping does not already exist

            IF @a_id_corp IS NULL BEGIN

          		SELECT

		            @a_temp = COUNT(*)

		          FROM

		            t_se_mapper tsem

	   	          INNER JOIN t_service_endpoint tse ON tsem.id_se = tse.id_se

		          WHERE

 	  	          tsem.id_corp IS NULL	

		            AND LOWER(tsem.nm_login) = LOWER(@a_new_id)

	  	          AND LOWER(tsem.nm_space) = LOWER(@a_new_space)

		            AND (tse.dt_start BETWEEN (select dt_start from t_service_endpoint where id_se = @a_id_se) AND (select dt_end from t_service_endpoint where id_se = @a_id_se) OR 

                    (select dt_start from t_service_endpoint where id_se = @a_id_se) BETWEEN tse.dt_start AND tse.dt_end)

            

            --  SELECT @a_temp = COUNT(*) FROM t_se_mapper WHERE id_corp IS NULL AND LOWER(nm_login) = LOWER(@a_new_id) AND LOWER(nm_space) = LOWER(@a_new_space)

            END

            ELSE BEGIN

		          SELECT

		            @a_temp = COUNT(*)

          		FROM

          		  t_se_mapper tsem

        	   	  INNER JOIN t_service_endpoint tse ON tsem.id_se = tse.id_se

          		WHERE

         	  	  tsem.id_corp = @a_id_corp

          		  AND LOWER(tsem.nm_login) = LOWER(@a_new_id)

         	  	  AND LOWER(tsem.nm_space) = LOWER(@a_new_space)

          		  AND (tse.dt_start BETWEEN (select dt_start from t_service_endpoint where id_se = @a_id_se) AND (select dt_end from t_service_endpoint where id_se = @a_id_se) OR 

                    (select dt_start from t_service_endpoint where id_se = @a_id_se) BETWEEN tse.dt_start AND tse.dt_end)



  --            SELECT @a_temp = COUNT(*) FROM t_se_mapper WHERE id_corp = @a_id_corp AND LOWER(nm_login) = LOWER(@a_new_id) AND LOWER(nm_space) = LOWER(@a_new_space)

            END

            

            IF @a_temp > 0 BEGIN

              SET @a_status = -483458957

              GOTO errHandler

            END

          

            --See if any mappings exist

            SELECT @a_temp = COUNT(*) FROM t_se_mapper WHERE id_se = @a_id_se



           --If no other mappings exist, no need to worry about the primary (this will be it)

           IF @a_temp = 0 BEGIN

              INSERT INTO 

                t_se_mapper (id_se, id_corp, nm_login, nm_space, b_primary) 

              VALUES

                (@a_id_se, @a_id_corp, @a_new_id, @a_new_space, '1')



              SET @a_status = @@error

              IF @a_status <> 0 BEGIN

                GOTO errHandler

              END

            END

            --If this is to be a new primary, remove the old one

           ELSE BEGIN

              IF @b_primary = '1' BEGIN

                UPDATE t_se_mapper SET b_primary = '0' WHERE id_se = @a_id_se AND b_primary = '1'

                SET @a_status = @@error

                IF @a_status <> 0 BEGIN

                  GOTO errHandler

                END

              END



              --Add the new mapping

           	  INSERT INTO 

                t_se_mapper (id_se, id_corp, nm_login, nm_space, b_primary) 

              VALUES

                (@a_id_se, @a_id_corp, @a_new_id, @a_new_space, UPPER(@b_primary))



              SET @a_status = @@error

              IF @a_status <> 0 BEGIN

                GOTO errHandler

              END

            END

            

            --Commit and return

            IF @a_transaction_started = 1 BEGIN

              COMMIT TRAN

              SET @a_status = 0

              RETURN

            END

            

            errHandler:

            IF @a_transaction_started = 1 BEGIN

              ROLLBACK TRAN

            END

            

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


      

      CREATE PROCEDURE ApprovePayments

			  @id_interval int,

				@status int output

			AS

			BEGIN

			  SET @status = -1



				-- It is not necessary to use the temp table here.

				-- However, since there is currently no index on the 

				-- t_acc_uage.id_usage_interval column, to improve the 

				-- performance, the temp table is used so that the 

				-- id_sess be looked up only once for the two deletions.

				DECLARE @id_enum int

				SELECT

				  @id_enum = id_enum_data

				FROM

				  t_enum_data

				WHERE

				  nm_enum_data = 'metratech.com/paymentserver/PaymentStatus/Pending'

				IF ((@@ERROR != 0) OR (@@ROWCOUNT = 0)) 

				BEGIN

					GOTO FatalError

				END



				UPDATE 

				  t_pv_ps_paymentscheduler 

				SET 

				  c_currentstatus = @id_enum

				WHERE

				  c_originalintervalid = @id_interval

				IF (@@ERROR != 0)

				BEGIN

					GOTO FatalError

				END



				SET @status = 0

				RETURN 0



			FatalError:

			SET @status = -1



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

declare @datemodified as varchar(1)

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

		@new_status OUTPUT,

		@datemodified OUTPUT



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


  

CREATE PROC CanExecuteEvents(@dt_now DATETIME, @id_instances VARCHAR(4000))

AS

BEGIN

  BEGIN TRAN



  DECLARE @results TABLE

  (  

    id_instance INT NOT NULL,

    tx_display_name VARCHAR(255),

    tx_reason VARCHAR(80)

  )



  --

  -- initially all instances are considered okay

  -- a succession of queries attempt to find a problem with executing them

  --



  -- builds up a table from the comma separated list of instance IDs

  INSERT INTO @results

  SELECT

    args.value,

    evt.tx_display_name,

    'OK'

  FROM CSVToInt(@id_instances) args

  INNER JOIN t_recevent_inst inst ON inst.id_instance = args.value

  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event



  -- is the event not active?

  UPDATE @results SET tx_reason = 'EventNotActive'

  FROM @results results

  INNER JOIN t_recevent_inst inst ON inst.id_instance = results.id_instance

  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event

  WHERE 

    -- event is NOT active

    evt.dt_activated > @dt_now AND

    (evt.dt_deactivated IS NOT NULL OR @dt_now >= evt.dt_deactivated) 



  -- is the instance in an invalid state?

  UPDATE @results SET tx_reason = inst.tx_status

  FROM @results results

  INNER JOIN t_recevent_inst inst ON inst.id_instance = results.id_instance

  WHERE 

    inst.tx_status NOT IN ('NotYetRun', 'ReadyToRun')



  -- is the interval hard closed?

  UPDATE @results SET tx_reason = 'HardClosed'

  FROM @results results

  INNER JOIN t_recevent_inst inst ON inst.id_instance = results.id_instance

  INNER JOIN t_usage_interval ui ON ui.id_interval = inst.id_arg_interval

  WHERE 

    ui.tx_interval_status = 'H'



  SELECT 

    id_instance InstanceID,

    tx_display_name EventDisplayName,

    tx_reason Reason  

  FROM @results



  COMMIT

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


  

CREATE PROC CanReverseEvents(@dt_now DATETIME, @id_instances VARCHAR(4000))

AS

BEGIN

  BEGIN TRAN



  DECLARE @results TABLE

  (  

    id_instance INT NOT NULL,

    tx_display_name VARCHAR(255),

    tx_reason VARCHAR(80)

  )



  --

  -- initially all instances are considered okay

  -- a succession of queries attempt to find a reason

  -- why an instance can not be reversed



  -- builds up a table from the comma separated list of instance IDs

  INSERT INTO @results

  SELECT

    args.value,

    evt.tx_display_name,

    'OK'

  FROM CSVToInt(@id_instances) args

  INNER JOIN t_recevent_inst inst ON inst.id_instance = args.value

  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event



  -- is the event not active?

  UPDATE @results SET tx_reason = 'EventNotActive'

  FROM @results results

  INNER JOIN t_recevent_inst inst ON inst.id_instance = results.id_instance

  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event

  WHERE 

    -- event is NOT active

    evt.dt_activated > @dt_now AND

    (evt.dt_deactivated IS NOT NULL OR @dt_now >= evt.dt_deactivated) 



  -- is the event not reversible?

  UPDATE @results SET tx_reason = evt.tx_reverse_mode

  FROM @results results

  INNER JOIN t_recevent_inst inst ON inst.id_instance = results.id_instance

  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event

  WHERE 

    -- event is NOT reversible

    evt.tx_reverse_mode = 'NotImplemented'



  -- is the instance in an invalid state?

  UPDATE @results SET tx_reason = inst.tx_status

  FROM @results results

  INNER JOIN t_recevent_inst inst ON inst.id_instance = results.id_instance

  WHERE 

    inst.tx_status NOT IN ('ReadyToReverse', 'Succeeded', 'Failed')



  -- is the interval hard closed?

  UPDATE @results SET tx_reason = 'HardClosed'

  FROM @results results

  INNER JOIN t_recevent_inst inst ON inst.id_instance = results.id_instance

  INNER JOIN t_usage_interval ui ON ui.id_interval = inst.id_arg_interval

  WHERE 

    ui.tx_interval_status = 'H'



  SELECT 

    id_instance InstanceID,

    tx_display_name EventDisplayName,

    tx_reason Reason  

  FROM @results



  COMMIT

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


  

CREATE PROCEDURE CancelSubmittedEvent

(

  @dt_now DATETIME,

  @id_instance INT,

  @id_acc INT,

  @tx_detail VARCHAR(2048),

  @status INT OUTPUT

)

AS

BEGIN

  DECLARE @current_status VARCHAR(14)

  DECLARE @previous_status VARCHAR(14)



  SELECT @status = -99



  BEGIN TRAN

  -- gets the instances current status

  SELECT 

    @current_status = inst.tx_status

  FROM t_recevent_inst inst

  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event

  WHERE 

    -- event is active

    evt.dt_activated <= @dt_now AND

    (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) AND

    inst.id_instance = @id_instance

  

  IF @@ROWCOUNT = 0

  BEGIN

    SELECT @status = -1  -- instance was not found

    ROLLBACK

    RETURN

  END



  IF @current_status = 'ReadyToRun'

  BEGIN

    -- the only way to get to ReadyToRun is from NotYetRun

    SELECT @previous_status = 'NotYetRun'

  END

  ELSE IF @current_status = 'ReadyToReverse'

  BEGIN

    -- the only way to get to ReadyToReverse is from Succeeded or Failed

    -- determines which of these two statuses by looking at the last run's status

    SELECT @previous_status = run.tx_status

    FROM t_recevent_run run

    WHERE run.id_instance = @id_instance

    ORDER BY run.dt_end desc

  END

  ELSE

  BEGIN

    SELECT @status = -2  -- instance cannot be cancelled because it is not in a legal state

    ROLLBACK

    RETURN

  END

  -- reverts the instance's state to what it was previously

  UPDATE t_recevent_inst

  SET tx_status = @previous_status, b_ignore_deps = 'N', dt_effective = NULL

  WHERE id_instance = @id_instance



  -- records the action

    INSERT INTO t_recevent_inst_audit(id_instance,id_acc,tx_action,b_ignore_deps,dt_effective,tx_detail,dt_crt)

  VALUES(@id_instance, @id_acc, 'Cancel', NULL, NULL, @tx_detail, @dt_now) 



  SELECT @status = 0  -- success



  COMMIT

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


				

				CREATE PROCEDURE CheckAccountCreationBusinessRules(

				  @p_nm_space varchar(40),

				  @p_acc_type varchar(3),

				  @p_id_ancestor int,

					@status int OUTPUT)

				AS

				BEGIN

				  -- 1. check account and its ancestor business rules. 

					-- if the account being created belongs to a hierarchy, then it should not

					-- have system_user or system_auth namespace

					-- 

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

						-- An account in the hierarchy cannot be of system namespace

						-- type

					  IF (@p_id_ancestor IS NOT NULL)

						BEGIN

							-- MT_ACCOUNT_NAMESPACE_AND_HIERARCHY_MISMATCH ((DWORD)0xE2FF0045L)

			  			SELECT @status = -486604731

							RETURN

						END



						-- An account with this account type and namespace cannot be

						-- created

					  IF (@p_acc_type in ('IND', 'SUB'))

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

					  IF (@p_acc_type NOT IN ('SUB','IND'))

						BEGIN

							-- MT_ACCOUNT_TYPE_AND_NAMESPACE_MISMATCH ((DWORD)0xE2FF0046L)

			  			SELECT @status = -486604732

							RETURN

						END

					END

				

					SELECT @status = 1

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

				 		IF (dbo.IsAccountFolder(@id_acc) = 'N')

						BEGIN

							SELECT @status = -486604799

							RETURN

				 		END 



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

   					IF (@status = 0)

						BEGIN

						  SELECT @status = 1

         			RETURN

            END

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


        

          CREATE PROCEDURE ConnectServiceEndpoint

            @a_id_se int,

            @a_login varchar(255),

            @a_namespace varchar(40),

            @a_date_start DATETIME,

            @a_date_end DATETIME,

            @a_account_id int,

            @a_conn_account_id int OUTPUT,

            @a_status int OUTPUT

          AS BEGIN

            DECLARE @a_resolved_acct_id as int

            DECLARE @a_temp as int

            DECLARE @a_acc_corp_id as int

            DECLARE @a_se_corp_id as int

          

            SET @a_status = 0

          

            --Check for NULL end date

            IF @a_date_end IS NULL BEGIN

              SET @a_date_end = dbo.MTMaxDate()

            END

          

            --Check dates

            IF @a_date_start > @a_date_end BEGIN

              SET @a_status = -483458969

              RETURN

            END

          

            --Check if SE exists

            SELECT @a_temp = COUNT(*) FROM t_service_endpoint WHERE @a_date_start >= dt_start AND @a_date_start <= dt_end AND @a_date_end >= dt_start AND @a_date_end <= dt_end AND id_se = @a_id_se

            IF @a_temp = 0 BEGIN

              SET @a_status = -483458968

              RETURN

            END

          

            --Check if connection exists for the SE

            SELECT @a_temp = COUNT(*) FROM t_se_parent WHERE (@a_date_start between dt_start and dt_end OR @a_date_end between dt_start and dt_end) AND id_se = @a_id_se

            IF @a_temp > 0 BEGIN

              SET @a_status = -483458967

              RETURN

            END

            

            --Get the corporate ID of the endpoint

            SELECT

              @a_se_corp_id = CASE WHEN id_corp IS NULL then -1 ELSE id_corp END

            FROM  t_se_mapper tse

            WHERE id_se = @a_id_se

          

            -- Resolve the account ID if necessary

            IF @a_account_id IS NULL BEGIN

              --Resolve the account ID

              SET @a_resolved_acct_id = dbo.LookupAccount(@a_login, @a_namespace)

              IF @@error > 0 BEGIN

                SELECT @a_status = -483458966

                RETURN

              END

          

              SET @a_conn_account_id = @a_resolved_acct_id

            END

            ELSE BEGIN

              SET @a_conn_account_id = @a_account_id

            END

            

            -- Get the corporate ID of the account -- NULL is returned if the account doesn't exist at the connection

            -- start date.  Don't worry about the end because accounts don't end.

            -- At some point, account state should probably be included.  ?



            SELECT

              @a_acc_corp_id = corp_parent.id_ancestor

            FROM

            	t_account_ancestor descendent

              INNER JOIN t_account_ancestor parent on parent.id_descendent = @a_conn_account_id AND

                                                      parent.id_ancestor   = 1   AND

                                                      @a_date_start between parent.vt_start and parent.vt_end

              INNER JOIN t_account_ancestor corp_parent on corp_parent.id_descendent = @a_conn_account_id AND

                                                           corp_parent.num_generations = parent.num_generations - 1 AND

  	                                                       @a_date_start between corp_parent.vt_start and corp_parent.vt_end

            WHERE

              descendent.id_descendent = @a_conn_account_id AND

            	descendent.id_ancestor = 1 AND

              @a_date_start between descendent.vt_start and descendent.vt_end

              

              

            --Check if account exists

            IF @a_acc_corp_id IS NULL BEGIN

              SELECT @a_status = -483458953

              RETURN

            END

            

            

            --If @a_se_corp_id = -1, then it is a global SE, and corp doesn't matter

            IF @a_se_corp_id <> -1 BEGIN

              --Check if corp accounts are the same

              IF @a_acc_corp_id <> @a_se_corp_id BEGIN

                SELECT @a_status = -483458952

                RETURN

              END

            END

            

            --Now insert the data

            INSERT INTO t_se_parent (id_se, id_acc, dt_start, dt_end) VALUES (@a_id_se, @a_conn_account_id, @a_date_start, @a_date_end)

            SET @a_status = @@error
            IF @a_status <> 0 BEGIN

              RETURN

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


		

create Procedure CreateAccountStateRecord (

@p_id_acc int,
@p_status varchar(2),

@startdate  datetime,

@enddate datetime,

@p_systemdate datetime,

@status int OUTPUT

)

as

declare @realstartdate datetime

declare @realenddate datetime

declare @varMaxDateTime datetime

declare @tempStartDate datetime

declare @tempEndDate datetime

declare @onesecond_systemdate datetime

declare @temp_id_acc int
declare @temp_status varchar(2)


begin



-- detect directly adjacent records with a adjacent start and end date.  If the

-- key comparison matches successfully, use the start and/or end date of the original record 

-- instead.



select @realstartdate = @startdate,@realenddate = @enddate,@varMaxDateTime = dbo.mtmaxdate(),
  @onesecond_systemdate = dbo.subtractsecond(@p_systemdate)



 -- Someone changes the start date of an existing record so that it creates gaps in time

 -- Existing Record      |---------------------|

 -- modified record       	|-----------|

 -- modified record      |-----------------|

 -- modified record         |------------------|

	begin

		

		-- find the start and end dates of the original interval

		select 

		@tempstartdate = vt_start,

		@tempenddate = vt_end

    from

    t_account_state_history

    where dbo.encloseddaterange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND

    id_acc = @p_id_acc AND status = @p_status and tt_end = @varMaxDateTime 



		-- the original date range is no longer true

		update t_account_state_history

    set tt_end = @onesecond_systemdate

		where id_acc = @p_id_acc AND status = @p_status AND vt_start = @tempstartdate AND

		@tempenddate = vt_end AND tt_end = @varMaxDateTime



		insert into t_account_state_history 

		(id_acc,status,vt_start,vt_end,tt_start,tt_end)

		select 

			id_acc,status,vt_start,dbo.subtractsecond(@realstartdate),@p_systemdate,@varMaxDateTime

			from t_account_state_history 

			where

			id_acc = @p_id_acc AND vt_end = dbo.subtractSecond(@tempstartdate)

		UNION ALL

		select

			id_acc,status,@realenddate,vt_end,@p_systemdate,@varMaxDateTime

			from t_account_state_history

			where

			id_acc = @p_id_acc  AND vt_start = dbo.addsecond(@tempenddate)



		-- adjust the two records end dates that are adjacent on the start and

		-- end dates; these records are no longer true

		update t_account_state_history 

		set tt_end = @onesecond_systemdate where

		id_acc = @p_id_acc AND tt_end = @varMaxDateTime AND

		(vt_end = dbo.subtractSecond(@tempstartdate) OR vt_start = dbo.addsecond(@tempenddate))

    if (@@error <> 0 )

		begin

    select @status = 0

		end

	end



	-- detect directly adjacent records with a adjacent start and end date.  If the

	-- key comparison matches successfully, use the start and/or end date of the original record 

	-- instead.

	

	select @realstartdate = vt_start

	from 

	t_account_state_history  where id_acc = @p_id_acc AND status = @p_status AND

		@startdate between vt_start AND dbo.addsecond(vt_end) and tt_end = @varMaxDateTime

	if @realstartdate is NULL begin

		select @realstartdate = @startdate

	end

	select @realenddate = dbo.addsecond(vt_end)

	from

	t_account_state_history  where id_acc = @p_id_acc AND status = @p_status AND

	@enddate between vt_start AND dbo.addsecond(vt_end) and tt_end = @varMaxDateTime

	if @realenddate is NULL begin

		select @realenddate = @enddate

	end



 -- step : delete a range that is entirely in the new date range

 -- existing record:      |----|

 -- new record:      |----------------|

 update  t_account_state_history 

 set tt_end = @onesecond_systemdate

 where dbo.EnclosedDateRange(@realstartdate,@realenddate,vt_start,vt_end) =1 AND

 id_acc = @p_id_acc  AND tt_end = @varMaxDateTime 



 -- create two new records that are on around the new interval        

 -- existing record:          |-----------------------------------|

 -- new record                        |-------|

 --

 -- adjusted old records      |-------|       |--------------------|

  begin

    select

		@temp_id_acc = id_acc,
@temp_status = status


		,@tempstartdate = vt_start,

		@tempenddate = vt_end

    from

    t_account_state_history

    where dbo.encloseddaterange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND

    id_acc = @p_id_acc and tt_end = @varMaxDateTime AND  status <> @p_status

    update     t_account_state_history 

    set tt_end = @onesecond_systemdate where

    dbo.encloseddaterange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND

    id_acc = @p_id_acc AND tt_end = @varMaxDateTime AND  status <> @p_status

   insert into t_account_state_history 

   (id_acc,status,vt_start,vt_end,tt_start,tt_end)

   select 

    @temp_id_acc,@temp_status,@tempStartDate,dbo.subtractsecond(@realstartdate),

    @p_systemdate,@varMaxDateTime

    where @tempstartdate is not NULL AND @tempStartDate <> @realstartdate

    -- the previous statement may fail

		if @realenddate <> @tempendDate AND @realenddate <> @varMaxDateTime begin

			insert into t_account_state_history 

			(id_acc,status,vt_start,vt_end,tt_start,tt_end)

	    select

	    @temp_id_acc,@temp_status,@realenddate,@tempEndDate,

	    @p_systemdate,@varMaxDateTime

		end

    -- the previous statement may fail

  end

 -- step 5: update existing payment records that are overlapping on the start

 -- range

 -- Existing Record |--------------|

 -- New Record: |---------|

 insert into t_account_state_history

 (id_acc,status,vt_start,vt_end,tt_start,tt_end)

 select 

 id_acc,status,@realenddate,vt_end,@p_systemdate,@varMaxDateTime

 from 

 t_account_state_history  where

 id_acc = @p_id_acc AND 

 vt_start > @realstartdate and vt_start < @realenddate 

 and tt_end = @varMaxDateTime

 

 update t_account_state_history

 set tt_end = @onesecond_systemdate

 where

 id_acc = @p_id_acc AND 

 vt_start > @realstartdate and vt_start < @realenddate 

 and tt_end = @varMaxDateTime

 -- step 4: update existing payment records that are overlapping on the end

 -- range

 -- Existing Record |--------------|

 -- New Record:             |-----------|

 insert into t_account_state_history

 (id_acc,status,vt_start,vt_end,tt_start,tt_end)

 select

 id_acc,status,vt_start,dbo.subtractsecond(@realstartdate),@p_systemdate,@varMaxDateTime

 from t_account_state_history

 where

 id_acc = @p_id_acc AND 

 vt_end > @realstartdate AND vt_end < @realenddate

 AND tt_end = @varMaxDateTime

 update t_account_state_history

 set tt_end = @onesecond_systemdate

 where id_acc = @p_id_acc AND 

  vt_end > @realstartdate AND vt_end < @realenddate

 AND tt_end = @varMaxDateTime

 -- used to be realenddate

 -- step 7: create the new payment redirection record.  If the end date 

 -- is not max date, make sure the enddate is subtracted by one second

 insert into t_account_state_history 

 (id_acc,status,vt_start,vt_end,tt_start,tt_end)

 select 

 @p_id_acc,@p_status,@realstartdate,

  case when @realenddate = dbo.mtmaxdate() then @realenddate else 

  dbo.subtractsecond(@realenddate) end,

  @p_systemdate,@varMaxDateTime

  

delete from t_account_state where id_acc = @p_id_acc

insert into t_account_state (id_acc,status,vt_start,vt_end)

select id_acc,status,vt_start,vt_end

from t_account_state_history  where

id_acc = @p_id_acc and tt_end = @varMaxDateTime

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


        

						create procedure CreateAdjustmentType

						(@p_id_prop INT, 

						 @p_tx_guid VARBINARY(16), 

						 @p_id_pi_type INT, 

             @p_n_AdjustmentType INT, 

             @p_b_supportBulk VARCHAR,

             @p_tx_defaultdesc TEXT,

             @p_id_formula INT

             )

						as

						begin

            	INSERT INTO t_adjustment_type

            	(id_prop, tx_guid,id_pi_type,n_AdjustmentType,b_supportBulk,id_formula, tx_default_desc

            	 ) VALUES (

							@p_id_prop, @p_tx_guid, @p_id_pi_type, @p_n_AdjustmentType, @p_b_supportBulk, @p_id_formula,

							@p_tx_defaultdesc)

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


        

						create procedure CreateCalculationFormula

						(@p_tx_formula TEXT,

             @p_id_engine INT,

             @op_id_prop int OUTPUT)

						as

						begin

            	INSERT INTO t_calc_formula

            	(tx_formula,id_engine) VALUES (

							@p_tx_formula, @p_id_engine)

							if (@@error <> 0) 

                  begin

                  select @op_id_prop = -99

                  end

                  else

                  begin

                  select @op_id_prop = @@identity

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


        

					CREATE PROC CreateCounterPropDef

											@id_lang_code int,

											@n_kind int,

											@nm_name nvarchar(255),

											@nm_display_name nvarchar(255),

											@id_pi int,

											@nm_servicedefprop nvarchar(255),

											@nm_preferredcountertype nvarchar(255),

											@n_order int, 

											@id_prop int OUTPUT 

					AS

						DECLARE @identity_value int

						DECLARE @id_locale int

					BEGIN TRAN

						exec InsertBaseProps @id_lang_code, @n_kind, 'N', 'N', @nm_name, NULL, @nm_display_name, @identity_value output

						INSERT INTO t_counterpropdef 

							(id_prop, id_pi, nm_servicedefprop, n_order, nm_preferredcountertype) 

						VALUES 

							(@identity_value, @id_pi, @nm_servicedefprop, @n_order, @nm_preferredcountertype)

						SELECT 

						@id_prop = @identity_value

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


		

create Procedure CreateGSubMemberRecord (

@p_id_group int,
@p_id_acc int,

@startdate  datetime,

@enddate datetime,

@p_systemdate datetime,

@status int OUTPUT

)

as

declare @realstartdate datetime

declare @realenddate datetime

declare @varMaxDateTime datetime

declare @tempStartDate datetime

declare @tempEndDate datetime

declare @onesecond_systemdate datetime

declare @temp_id_group int
declare @temp_id_acc int


begin



-- detect directly adjacent records with a adjacent start and end date.  If the

-- key comparison matches successfully, use the start and/or end date of the original record 

-- instead.



select @realstartdate = @startdate,@realenddate = @enddate,@varMaxDateTime = dbo.mtmaxdate(),
  @onesecond_systemdate = dbo.subtractsecond(@p_systemdate)



 -- Someone changes the start date of an existing record so that it creates gaps in time

 -- Existing Record      |---------------------|

 -- modified record       	|-----------|

 -- modified record      |-----------------|

 -- modified record         |------------------|

	begin

		

		-- find the start and end dates of the original interval

		select 

		@tempstartdate = vt_start,

		@tempenddate = vt_end

    from

    t_gsubmember_historical

    where dbo.encloseddaterange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND

    id_group = @p_id_group AND id_acc = @p_id_acc and tt_end = @varMaxDateTime 



		-- the original date range is no longer true

		update t_gsubmember_historical

    set tt_end = @onesecond_systemdate

		where id_group = @p_id_group AND id_acc = @p_id_acc AND vt_start = @tempstartdate AND

		@tempenddate = vt_end AND tt_end = @varMaxDateTime



		insert into t_gsubmember_historical 

		(id_group,id_acc,vt_start,vt_end,tt_start,tt_end)

		select 

			id_group,id_acc,vt_start,dbo.subtractsecond(@realstartdate),@p_systemdate,@varMaxDateTime

			from t_gsubmember_historical 

			where

			id_group = @p_id_group AND id_acc = @p_id_acc AND vt_end = dbo.subtractSecond(@tempstartdate)

		UNION ALL

		select

			id_group,id_acc,@realenddate,vt_end,@p_systemdate,@varMaxDateTime

			from t_gsubmember_historical

			where

			id_group = @p_id_group AND id_acc = @p_id_acc  AND vt_start = dbo.addsecond(@tempenddate)



		-- adjust the two records end dates that are adjacent on the start and

		-- end dates; these records are no longer true

		update t_gsubmember_historical 

		set tt_end = @onesecond_systemdate where

		id_group = @p_id_group AND id_acc = @p_id_acc AND tt_end = @varMaxDateTime AND

		(vt_end = dbo.subtractSecond(@tempstartdate) OR vt_start = dbo.addsecond(@tempenddate))

    if (@@error <> 0 )

		begin

    select @status = 0

		end

	end



	-- detect directly adjacent records with a adjacent start and end date.  If the

	-- key comparison matches successfully, use the start and/or end date of the original record 

	-- instead.

	

	select @realstartdate = vt_start

	from 

	t_gsubmember_historical  where id_group = @p_id_group AND id_acc = @p_id_acc AND

		@startdate between vt_start AND dbo.addsecond(vt_end) and tt_end = @varMaxDateTime

	if @realstartdate is NULL begin

		select @realstartdate = @startdate

	end

	select @realenddate = dbo.addsecond(vt_end)

	from

	t_gsubmember_historical  where id_group = @p_id_group AND id_acc = @p_id_acc AND

	@enddate between vt_start AND dbo.addsecond(vt_end) and tt_end = @varMaxDateTime

	if @realenddate is NULL begin

		select @realenddate = @enddate

	end



 -- step : delete a range that is entirely in the new date range

 -- existing record:      |----|

 -- new record:      |----------------|

 update  t_gsubmember_historical 

 set tt_end = @onesecond_systemdate

 where dbo.EnclosedDateRange(@realstartdate,@realenddate,vt_start,vt_end) =1 AND

 id_group = @p_id_group AND id_acc = @p_id_acc  AND tt_end = @varMaxDateTime 



 -- create two new records that are on around the new interval        

 -- existing record:          |-----------------------------------|

 -- new record                        |-------|

 --

 -- adjusted old records      |-------|       |--------------------|

  begin

    select

		@temp_id_group = id_group,
@temp_id_acc = id_acc


		,@tempstartdate = vt_start,

		@tempenddate = vt_end

    from

    t_gsubmember_historical

    where dbo.encloseddaterange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND

    id_group = @p_id_group AND id_acc = @p_id_acc and tt_end = @varMaxDateTime

    update     t_gsubmember_historical 

    set tt_end = @onesecond_systemdate where

    dbo.encloseddaterange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND

    id_group = @p_id_group AND id_acc = @p_id_acc AND tt_end = @varMaxDateTime

   insert into t_gsubmember_historical 

   (id_group,id_acc,vt_start,vt_end,tt_start,tt_end)

   select 

    @temp_id_group,@temp_id_acc,@tempStartDate,dbo.subtractsecond(@realstartdate),

    @p_systemdate,@varMaxDateTime

    where @tempstartdate is not NULL AND @tempStartDate <> @realstartdate

    -- the previous statement may fail

		if @realenddate <> @tempendDate AND @realenddate <> @varMaxDateTime begin

			insert into t_gsubmember_historical 

			(id_group,id_acc,vt_start,vt_end,tt_start,tt_end)

	    select

	    @temp_id_group,@temp_id_acc,@realenddate,@tempEndDate,

	    @p_systemdate,@varMaxDateTime

		end

    -- the previous statement may fail

  end

 -- step 5: update existing payment records that are overlapping on the start

 -- range

 -- Existing Record |--------------|

 -- New Record: |---------|

 insert into t_gsubmember_historical

 (id_group,id_acc,vt_start,vt_end,tt_start,tt_end)

 select 

 id_group,id_acc,@realenddate,vt_end,@p_systemdate,@varMaxDateTime

 from 

 t_gsubmember_historical  where

 id_group = @p_id_group AND id_acc = @p_id_acc AND 

 vt_start > @realstartdate and vt_start < @realenddate 

 and tt_end = @varMaxDateTime

 

 update t_gsubmember_historical

 set tt_end = @onesecond_systemdate

 where

 id_group = @p_id_group AND id_acc = @p_id_acc AND 

 vt_start > @realstartdate and vt_start < @realenddate 

 and tt_end = @varMaxDateTime

 -- step 4: update existing payment records that are overlapping on the end

 -- range

 -- Existing Record |--------------|

 -- New Record:             |-----------|

 insert into t_gsubmember_historical

 (id_group,id_acc,vt_start,vt_end,tt_start,tt_end)

 select

 id_group,id_acc,vt_start,dbo.subtractsecond(@realstartdate),@p_systemdate,@varMaxDateTime

 from t_gsubmember_historical

 where

 id_group = @p_id_group AND id_acc = @p_id_acc AND 

 vt_end > @realstartdate AND vt_end < @realenddate

 AND tt_end = @varMaxDateTime

 update t_gsubmember_historical

 set tt_end = @onesecond_systemdate

 where id_group = @p_id_group AND id_acc = @p_id_acc AND 

  vt_end > @realstartdate AND vt_end < @realenddate

 AND tt_end = @varMaxDateTime

 -- used to be realenddate

 -- step 7: create the new payment redirection record.  If the end date 

 -- is not max date, make sure the enddate is subtracted by one second

 insert into t_gsubmember_historical 

 (id_group,id_acc,vt_start,vt_end,tt_start,tt_end)

 select 

 @p_id_group,@p_id_acc,@realstartdate,

  case when @realenddate = dbo.mtmaxdate() then @realenddate else 

  @realenddate end,

  @p_systemdate,@varMaxDateTime

  

delete from t_gsubmember where id_group = @p_id_group AND id_acc = @p_id_acc

insert into t_gsubmember (id_group,id_acc,vt_start,vt_end)

select id_group,id_acc,vt_start,vt_end

from t_gsubmember_historical  where

id_group = @p_id_group AND id_acc = @p_id_acc and tt_end = @varMaxDateTime

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

	if @enddate <> dbo.mtstartofday(dbo.MTMaxDate())

		select @realenddate = DATEADD(d, 1,dbo.mtstartofday(@enddate))

	else

		select @realenddate = @enddate

    end



	select @AccCreateDate = dbo.mtstartofday(dt_crt) from t_account where id_acc = @NPA

	if @realstartdate < @AccCreateDate 

	begin

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

	if @billableFlag = '0' begin

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

	select TOP 1 @payer_state = status from t_account_state

	where dbo.enclosedDateRange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND

	id_acc = @payer

	if @payer_state is NULL OR @payer_state <> 'AC' begin

		-- MT_PAYER_IN_INVALID_STATE

		select @status = -486604736

		return

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

  IF @status <> 1

    RETURN -- failure



  -- post-operation business rule check (relies on rollback of work done up until this point)

  -- CR9906: checks to make sure the new payer's billing cycle matches all of the payee's 

  -- group subscriptions' BCR constraints

  SELECT @status = ISNULL(MIN(dbo.CheckGroupMembershipCycleConstraint(@systemdate, groups.id_group)), 1)

  FROM 

  (

    -- gets all of the payee's group subscriptions

    SELECT DISTINCT gsm.id_group id_group

    FROM t_gsubmember gsm

    WHERE gsm.id_acc = @NPA  -- payee ID

  ) groups

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


		

create Procedure CreatePaymentRecordBitemporal (

@p_id_payer int,
@p_id_payee int,

@startdate  datetime,

@enddate datetime,

@p_systemdate datetime,

@status int OUTPUT

)

as

declare @realstartdate datetime

declare @realenddate datetime

declare @varMaxDateTime datetime

declare @tempStartDate datetime

declare @tempEndDate datetime

declare @onesecond_systemdate datetime

declare @temp_id_payer int
declare @temp_id_payee int


begin



-- detect directly adjacent records with a adjacent start and end date.  If the

-- key comparison matches successfully, use the start and/or end date of the original record 

-- instead.



select @realstartdate = @startdate,@realenddate = @enddate,@varMaxDateTime = dbo.mtmaxdate(),
  @onesecond_systemdate = dbo.subtractsecond(@p_systemdate)



 -- Someone changes the start date of an existing record so that it creates gaps in time

 -- Existing Record      |---------------------|

 -- modified record       	|-----------|

 -- modified record      |-----------------|

 -- modified record         |------------------|

	begin

		

		-- find the start and end dates of the original interval

		select 

		@tempstartdate = vt_start,

		@tempenddate = vt_end

    from

    t_payment_redir_history

    where dbo.encloseddaterange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND

    id_payer = @p_id_payer AND id_payee = @p_id_payee and tt_end = @varMaxDateTime 



		-- the original date range is no longer true

		update t_payment_redir_history

    set tt_end = @onesecond_systemdate

		where id_payer = @p_id_payer AND id_payee = @p_id_payee AND vt_start = @tempstartdate AND

		@tempenddate = vt_end AND tt_end = @varMaxDateTime



		insert into t_payment_redir_history 

		(id_payer,id_payee,vt_start,vt_end,tt_start,tt_end)

		select 

			id_payer,id_payee,vt_start,dbo.subtractsecond(@realstartdate),@p_systemdate,@varMaxDateTime

			from t_payment_redir_history 

			where

			id_payee = @p_id_payee AND vt_end = dbo.subtractSecond(@tempstartdate)

		UNION ALL

		select

			id_payer,id_payee,@realenddate,vt_end,@p_systemdate,@varMaxDateTime

			from t_payment_redir_history

			where

			id_payee = @p_id_payee  AND vt_start = dbo.addsecond(@tempenddate)



		-- adjust the two records end dates that are adjacent on the start and

		-- end dates; these records are no longer true

		update t_payment_redir_history 

		set tt_end = @onesecond_systemdate where

		id_payee = @p_id_payee AND tt_end = @varMaxDateTime AND

		(vt_end = dbo.subtractSecond(@tempstartdate) OR vt_start = dbo.addsecond(@tempenddate))

    if (@@error <> 0 )

		begin

    select @status = 0

		end

	end



	-- detect directly adjacent records with a adjacent start and end date.  If the

	-- key comparison matches successfully, use the start and/or end date of the original record 

	-- instead.

	

	select @realstartdate = vt_start

	from 

	t_payment_redir_history  where id_payer = @p_id_payer AND id_payee = @p_id_payee AND

		@startdate between vt_start AND dbo.addsecond(vt_end) and tt_end = @varMaxDateTime

	if @realstartdate is NULL begin

		select @realstartdate = @startdate

	end

	select @realenddate = dbo.addsecond(vt_end)

	from

	t_payment_redir_history  where id_payer = @p_id_payer AND id_payee = @p_id_payee AND

	@enddate between vt_start AND dbo.addsecond(vt_end) and tt_end = @varMaxDateTime

	if @realenddate is NULL begin

		select @realenddate = @enddate

	end



 -- step : delete a range that is entirely in the new date range

 -- existing record:      |----|

 -- new record:      |----------------|

 update  t_payment_redir_history 

 set tt_end = @onesecond_systemdate

 where dbo.EnclosedDateRange(@realstartdate,@realenddate,vt_start,vt_end) =1 AND

 id_payee = @p_id_payee  AND tt_end = @varMaxDateTime 



 -- create two new records that are on around the new interval        

 -- existing record:          |-----------------------------------|

 -- new record                        |-------|

 --

 -- adjusted old records      |-------|       |--------------------|

  begin

    select

		@temp_id_payer = id_payer,
@temp_id_payee = id_payee


		,@tempstartdate = vt_start,

		@tempenddate = vt_end

    from

    t_payment_redir_history

    where dbo.encloseddaterange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND

    id_payee = @p_id_payee and tt_end = @varMaxDateTime AND  id_payer <> @p_id_payer

    update     t_payment_redir_history 

    set tt_end = @onesecond_systemdate where

    dbo.encloseddaterange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND

    id_payee = @p_id_payee AND tt_end = @varMaxDateTime AND  id_payer <> @p_id_payer

   insert into t_payment_redir_history 

   (id_payer,id_payee,vt_start,vt_end,tt_start,tt_end)

   select 

    @temp_id_payer,@temp_id_payee,@tempStartDate,dbo.subtractsecond(@realstartdate),

    @p_systemdate,@varMaxDateTime

    where @tempstartdate is not NULL AND @tempStartDate <> @realstartdate

    -- the previous statement may fail

		if @realenddate <> @tempendDate AND @realenddate <> @varMaxDateTime begin

			insert into t_payment_redir_history 

			(id_payer,id_payee,vt_start,vt_end,tt_start,tt_end)

	    select

	    @temp_id_payer,@temp_id_payee,@realenddate,@tempEndDate,

	    @p_systemdate,@varMaxDateTime

		end

    -- the previous statement may fail

  end

 -- step 5: update existing payment records that are overlapping on the start

 -- range

 -- Existing Record |--------------|

 -- New Record: |---------|

 insert into t_payment_redir_history

 (id_payer,id_payee,vt_start,vt_end,tt_start,tt_end)

 select 

 id_payer,id_payee,@realenddate,vt_end,@p_systemdate,@varMaxDateTime

 from 

 t_payment_redir_history  where

 id_payee = @p_id_payee AND 

 vt_start > @realstartdate and vt_start < @realenddate 

 and tt_end = @varMaxDateTime

 

 update t_payment_redir_history

 set tt_end = @onesecond_systemdate

 where

 id_payee = @p_id_payee AND 

 vt_start > @realstartdate and vt_start < @realenddate 

 and tt_end = @varMaxDateTime

 -- step 4: update existing payment records that are overlapping on the end

 -- range

 -- Existing Record |--------------|

 -- New Record:             |-----------|

 insert into t_payment_redir_history

 (id_payer,id_payee,vt_start,vt_end,tt_start,tt_end)

 select

 id_payer,id_payee,vt_start,dbo.subtractsecond(@realstartdate),@p_systemdate,@varMaxDateTime

 from t_payment_redir_history

 where

 id_payee = @p_id_payee AND 

 vt_end > @realstartdate AND vt_end < @realenddate

 AND tt_end = @varMaxDateTime

 update t_payment_redir_history

 set tt_end = @onesecond_systemdate

 where id_payee = @p_id_payee AND 

  vt_end > @realstartdate AND vt_end < @realenddate

 AND tt_end = @varMaxDateTime

 -- used to be realenddate

 -- step 7: create the new payment redirection record.  If the end date 

 -- is not max date, make sure the enddate is subtracted by one second

 insert into t_payment_redir_history 

 (id_payer,id_payee,vt_start,vt_end,tt_start,tt_end)

 select 

 @p_id_payer,@p_id_payee,@realstartdate,

  case when @realenddate = dbo.mtmaxdate() then @realenddate else 

  dbo.subtractsecond(@realenddate) end,

  @p_systemdate,@varMaxDateTime

  

delete from t_payment_redirection where id_payee = @p_id_payee

insert into t_payment_redirection (id_payer,id_payee,vt_start,vt_end)

select id_payer,id_payee,vt_start,vt_end

from t_payment_redir_history  where

id_payee = @p_id_payee and tt_end = @varMaxDateTime

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


		

create Procedure CreateSubscriptionRecord (

@p_id_sub int,
@p_id_sub_ext varbinary(16),
@p_id_acc int,
@p_id_group int,
@p_id_po int,
@p_dt_crt datetime,

@startdate  datetime,

@enddate datetime,

@p_systemdate datetime,

@status int OUTPUT

)

as

declare @realstartdate datetime

declare @realenddate datetime

declare @varMaxDateTime datetime

declare @tempStartDate datetime

declare @tempEndDate datetime

declare @onesecond_systemdate datetime

declare @temp_id_sub int
declare @temp_id_sub_ext varbinary(16)
declare @temp_id_acc int
declare @temp_id_group int
declare @temp_id_po int
declare @temp_dt_crt datetime


begin



-- detect directly adjacent records with a adjacent start and end date.  If the

-- key comparison matches successfully, use the start and/or end date of the original record 

-- instead.



select @realstartdate = @startdate,@realenddate = @enddate,@varMaxDateTime = dbo.mtmaxdate(),
  @onesecond_systemdate = dbo.subtractsecond(@p_systemdate)



 -- Someone changes the start date of an existing record so that it creates gaps in time

 -- Existing Record      |---------------------|

 -- modified record       	|-----------|

 -- modified record      |-----------------|

 -- modified record         |------------------|

	begin

		

		-- find the start and end dates of the original interval

		select 

		@tempstartdate = vt_start,

		@tempenddate = vt_end

    from

    t_sub_history

    where dbo.encloseddaterange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND

    id_sub = @p_id_sub and tt_end = @varMaxDateTime 



		-- the original date range is no longer true

		update t_sub_history

    set tt_end = @onesecond_systemdate

		where id_sub = @p_id_sub AND vt_start = @tempstartdate AND

		@tempenddate = vt_end AND tt_end = @varMaxDateTime



		insert into t_sub_history 

		(id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,vt_start,vt_end,tt_start,tt_end)

		select 

			id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,vt_start,dbo.subtractsecond(@realstartdate),@p_systemdate,@varMaxDateTime

			from t_sub_history 

			where

			id_sub = @p_id_sub AND vt_end = dbo.subtractSecond(@tempstartdate)

		UNION ALL

		select

			id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,@realenddate,vt_end,@p_systemdate,@varMaxDateTime

			from t_sub_history

			where

			id_sub = @p_id_sub  AND vt_start = dbo.addsecond(@tempenddate)



		-- adjust the two records end dates that are adjacent on the start and

		-- end dates; these records are no longer true

		update t_sub_history 

		set tt_end = @onesecond_systemdate where

		id_sub = @p_id_sub AND tt_end = @varMaxDateTime AND

		(vt_end = dbo.subtractSecond(@tempstartdate) OR vt_start = dbo.addsecond(@tempenddate))

    if (@@error <> 0 )

		begin

    select @status = 0

		end

	end



	-- detect directly adjacent records with a adjacent start and end date.  If the

	-- key comparison matches successfully, use the start and/or end date of the original record 

	-- instead.

	

	select @realstartdate = vt_start

	from 

	t_sub_history  where id_sub = @p_id_sub AND

		@startdate between vt_start AND dbo.addsecond(vt_end) and tt_end = @varMaxDateTime

	if @realstartdate is NULL begin

		select @realstartdate = @startdate

	end

	select @realenddate = dbo.addsecond(vt_end)

	from

	t_sub_history  where id_sub = @p_id_sub AND

	@enddate between vt_start AND dbo.addsecond(vt_end) and tt_end = @varMaxDateTime

	if @realenddate is NULL begin

		select @realenddate = @enddate

	end



 -- step : delete a range that is entirely in the new date range

 -- existing record:      |----|

 -- new record:      |----------------|

 update  t_sub_history 

 set tt_end = @onesecond_systemdate

 where dbo.EnclosedDateRange(@realstartdate,@realenddate,vt_start,vt_end) =1 AND

 id_sub = @p_id_sub  AND tt_end = @varMaxDateTime 



 -- create two new records that are on around the new interval        

 -- existing record:          |-----------------------------------|

 -- new record                        |-------|

 --

 -- adjusted old records      |-------|       |--------------------|

  begin

    select

		@temp_id_sub = id_sub,
@temp_id_sub_ext = id_sub_ext,
@temp_id_acc = id_acc,
@temp_id_group = id_group,
@temp_id_po = id_po,
@temp_dt_crt = dt_crt


		,@tempstartdate = vt_start,

		@tempenddate = vt_end

    from

    t_sub_history

    where dbo.encloseddaterange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND

    id_sub = @p_id_sub and tt_end = @varMaxDateTime

    update     t_sub_history 

    set tt_end = @onesecond_systemdate where

    dbo.encloseddaterange(vt_start,vt_end,@realstartdate,@realenddate) = 1 AND

    id_sub = @p_id_sub AND tt_end = @varMaxDateTime

   insert into t_sub_history 

   (id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,vt_start,vt_end,tt_start,tt_end)

   select 

    @temp_id_sub,@temp_id_sub_ext,@temp_id_acc,@temp_id_group,@temp_id_po,@temp_dt_crt,@tempStartDate,dbo.subtractsecond(@realstartdate),

    @p_systemdate,@varMaxDateTime

    where @tempstartdate is not NULL AND @tempStartDate <> @realstartdate

    -- the previous statement may fail

		if @realenddate <> @tempendDate AND @realenddate <> @varMaxDateTime begin

			insert into t_sub_history 

			(id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,vt_start,vt_end,tt_start,tt_end)

	    select

	    @temp_id_sub,@temp_id_sub_ext,@temp_id_acc,@temp_id_group,@temp_id_po,@temp_dt_crt,@realenddate,@tempEndDate,

	    @p_systemdate,@varMaxDateTime

		end

    -- the previous statement may fail

  end

 -- step 5: update existing payment records that are overlapping on the start

 -- range

 -- Existing Record |--------------|

 -- New Record: |---------|

 insert into t_sub_history

 (id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,vt_start,vt_end,tt_start,tt_end)

 select 

 id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,@realenddate,vt_end,@p_systemdate,@varMaxDateTime

 from 

 t_sub_history  where

 id_sub = @p_id_sub AND 

 vt_start > @realstartdate and vt_start < @realenddate 

 and tt_end = @varMaxDateTime

 

 update t_sub_history

 set tt_end = @onesecond_systemdate

 where

 id_sub = @p_id_sub AND 

 vt_start > @realstartdate and vt_start < @realenddate 

 and tt_end = @varMaxDateTime

 -- step 4: update existing payment records that are overlapping on the end

 -- range

 -- Existing Record |--------------|

 -- New Record:             |-----------|

 insert into t_sub_history

 (id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,vt_start,vt_end,tt_start,tt_end)

 select

 id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,vt_start,dbo.subtractsecond(@realstartdate),@p_systemdate,@varMaxDateTime

 from t_sub_history

 where

 id_sub = @p_id_sub AND 

 vt_end > @realstartdate AND vt_end < @realenddate

 AND tt_end = @varMaxDateTime

 update t_sub_history

 set tt_end = @onesecond_systemdate

 where id_sub = @p_id_sub AND 

  vt_end > @realstartdate AND vt_end < @realenddate

 AND tt_end = @varMaxDateTime

 -- used to be realenddate

 -- step 7: create the new payment redirection record.  If the end date 

 -- is not max date, make sure the enddate is subtracted by one second

 insert into t_sub_history 

 (id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,vt_start,vt_end,tt_start,tt_end)

 select 

 @p_id_sub,@p_id_sub_ext,@p_id_acc,@p_id_group,@p_id_po,@p_dt_crt,@realstartdate,

  case when @realenddate = dbo.mtmaxdate() then @realenddate else 

  @realenddate end,

  @p_systemdate,@varMaxDateTime

  

delete from t_sub where id_sub = @p_id_sub

insert into t_sub (id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,vt_start,vt_end)

select id_sub,id_sub_ext,id_acc,id_group,id_po,dt_crt,vt_start,vt_end

from t_sub_history  where

id_sub = @p_id_sub and tt_end = @varMaxDateTime

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


  

CREATE PROCEDURE CreateTestRecurringEventInstance 

  (

    @id_event INT,

    @id_arg_interval INT,

    @dt_arg_start DATETIME,

    @dt_arg_end DATETIME,

    @id_instance INT OUTPUT

  )

AS

BEGIN

  BEGIN TRAN


  INSERT INTO t_recevent_inst

    (id_event, id_arg_interval, dt_arg_start, dt_arg_end,

     b_ignore_deps, dt_effective, tx_status)

  VALUES 

    (@id_event, @id_arg_interval, @dt_arg_start,

     @dt_arg_end, 'N', NULL, 'NotYetRun')



  SELECT @id_instance = @@IDENTITY



  COMMIT

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


  

CREATE PROC CreateUsageIntervals

(

  @dt_now   DATETIME,  -- the MetraTech system's date

  @pretend  INT,       -- if true doesn't create new intervals but returns what would have been created

  @n_count  INT OUTPUT -- the count of intervals created (or that would have been created)

)

AS

BEGIN

  BEGIN TRAN



/*  

  -- debug mode --

  declare @dt_now datetime 

  select @dt_now = CAST('2/9/2003' AS DATETIME) --GetUTCDate()

  declare @pretend int

  select @pretend = null

  declare @n_count int

*/  



  --

  -- PRECONDITIONS:

  --   Intervals and mappings will be created and backfilled as long as there

  --   is an entry for the account in t_acc_usage_cycle. Missing mappings will

  --   be detected and added.

  --   

  --   To update a billing cycle: t_acc_usage_cycle must be updated. Also the

  --   new interval the account is updating to must be created and the initial

  --   special update mapping must be made in t_acc_usage_interval - dt_effective

  --   must be set to the end date of the previous (old) interval. 

  --



  -- ensures that there is only one instance of this sproc executing right now

  DECLARE @result INT

  EXEC @result = sp_getapplock @Resource = 'CreateUsageIntervals', @LockMode = 'Exclusive'

  IF @result < 0

  BEGIN

      ROLLBACK

      RETURN

  END



  -- represents the end date that an interval must

  -- fall into to be considered 

  DECLARE @dt_end DATETIME

  SELECT @dt_end = (@dt_now + n_adv_interval_creation) FROM t_usage_server



  DECLARE @new_mappings TABLE

  (

    id_acc INT NOT NULL,

    id_usage_interval INT NOT NULL,

    tx_status VARCHAR(1)  

  )



  -- associate accounts with intervals based on their cycle mapping

  -- this will detect missing mappings and add them

  INSERT INTO @new_mappings

  SELECT 

    auc.id_acc,

    ref.id_interval,

    'O'  -- TODO: this column is no longer used and should eventually be removed

  FROM t_acc_usage_cycle auc

  INNER JOIN 

  (

    -- gets the minimal start date for each account

    SELECT 

      accstate.id_acc,

      -- if the usage cycle was updated, consider the time of update as the start date

      -- this prevents backfilling mappings for the previous cycle

      MIN(ISNULL(maxaui.dt_effective, accstate.vt_start)) dt_start

    FROM t_account_state accstate

    LEFT OUTER JOIN 

    (

      SELECT 

        id_acc,

        MAX(CASE WHEN dt_effective IS NULL THEN NULL ELSE dbo.AddSecond(dt_effective) END) dt_effective

      FROM t_acc_usage_interval

      GROUP BY id_acc

    ) maxaui ON maxaui.id_acc = accstate.id_acc

    WHERE 

      -- excludes archived accounts

      accstate.status <> 'AR' AND 

      -- the account has already started or is about to start

      accstate.vt_start < @dt_end AND

      -- the account has not yet ended

      accstate.vt_end >= @dt_now

    GROUP BY accstate.id_acc

  ) minstart ON minstart.id_acc = auc.id_acc

  INNER JOIN

  (

    -- gets the maximal end date for each account

    SELECT 

      id_acc,

      MAX(CASE WHEN vt_end > @dt_end THEN @dt_end ELSE vt_end END) dt_end

    FROM t_account_state

    WHERE

      -- excludes archived accounts

      status <> 'AR' AND 

      -- the account has already started or is about to start

      vt_start < @dt_end AND

      -- the account has not yet ended

      vt_end >= @dt_now

    GROUP BY id_acc

  ) maxend ON maxend.id_acc = minstart.id_acc

  INNER JOIN t_pc_interval ref ON

    ref.id_cycle = auc.id_usage_cycle AND

    -- reference interval must at least partially overlap the [minstart, maxend] period

    (ref.dt_end >= minstart.dt_start AND ref.dt_start <= maxend.dt_end)

  LEFT OUTER JOIN t_acc_usage_interval aui ON

    aui.id_usage_interval = ref.id_interval AND

    aui.id_acc = auc.id_acc  

  WHERE

    -- only add mappings that don't exist already

    aui.id_usage_interval IS NULL        



--  SELECT * FROM @new_mappings





  DECLARE @new_intervals TABLE

  (

    id_interval INT NOT NULL,

    id_usage_cycle INT NOT NULL,

    dt_start DATETIME NOT NULL,

    dt_end DATETIME NOT NULL,

    tx_interval_status VARCHAR(1) NOT NULL,

    id_cycle_type INT NOT NULL

  )



  -- determines what usage intervals need to be added

  -- based on the new account-to-interval mappings  

  INSERT INTO @new_intervals

  SELECT 

    ref.id_interval,

    ref.id_cycle,

    ref.dt_start,

    ref.dt_end,

    'O',  -- Open

    uct.id_cycle_type

  FROM t_pc_interval ref

  INNER JOIN 

  (

    SELECT DISTINCT id_usage_interval FROM @new_mappings

  ) mappings ON mappings.id_usage_interval = ref.id_interval

  INNER JOIN t_usage_cycle uc ON uc.id_usage_cycle = ref.id_cycle

  INNER JOIN t_usage_cycle_type uct ON uct.id_cycle_type = uc.id_cycle_type

  WHERE 

    -- don't add any intervals already in t_usage_interval

    ref.id_interval NOT IN (SELECT id_interval FROM t_usage_interval)



  -- records how many intervals would be added

  SET @n_count = @@ROWCOUNT



  -- only adds the new intervals and mappings if pretend is false

  IF ISNULL(@pretend, 0) = 0

  BEGIN

    

    -- adds the new intervals

    INSERT INTO t_usage_interval(id_interval,id_usage_cycle,dt_start,dt_end,tx_interval_status)

    SELECT id_interval, id_usage_cycle, dt_start, dt_end, tx_interval_status

    FROM @new_intervals


    -- adds the new mappings

    INSERT INTO t_acc_usage_interval(id_acc,id_usage_interval,tx_status,dt_effective)

    SELECT id_acc, id_usage_interval, tx_status, NULL

    FROM @new_mappings



    -- updates the last interval creation time, useful for debugging

    UPDATE t_usage_server SET dt_last_interval_creation = @dt_now

  END



  -- returns the added intervals

  SELECT * FROM @new_intervals

  COMMIT

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


        

						create proc DeleteCounterParamInstances

											(@id_counter	int)

						AS

						BEGIN

               -- delete mappings for shared parameters

               DELETE FROM t_counter_param_map WHERE id_counter =  @id_counter

               DELETE FROM T_BASE_PROPS WHERE id_prop IN

              (SELECT id_counter_param FROM t_counter_params WHERE id_counter = @id_counter)

              DELETE FROM T_COUNTER_PARAM_PREDICATE WHERE id_counter_param IN

              (SELECT id_counter_param FROM t_counter_params WHERE id_counter = @id_counter)

						  DELETE FROM T_COUNTER_PARAMS WHERE id_counter = @id_counter

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


        

CREATE PROCEDURE DetermineExecutableEvents (@dt_now DATETIME, @id_instances VARCHAR(4000))

AS

BEGIN

  BEGIN TRAN



  DECLARE @deps TABLE

  (

    id_orig_event INT NOT NULL,

    id_orig_instance INT NOT NULL,

    tx_orig_name VARCHAR(255) NOT NULL, -- useful for debugging

    tx_name VARCHAR(255) NOT NULL,      -- useful for debugging

    id_event INT NOT NULL,

    id_instance INT,

    id_arg_interval INT,

    dt_arg_start DATETIME,

    dt_arg_end DATETIME,

    tx_status VARCHAR(14)

  )

  INSERT INTO @deps  

  SELECT * from GetEventExecutionDeps(@dt_now, @id_instances)



  --

  -- returns the final rowset of all events that are 'ReadyToRun' and

  -- have satisfied dependencies. the rows are sorted in the order

  -- that they should be executed. 

  --

  SELECT 

    evt.tx_name EventName,

    evt.tx_class_name ClassName,

    evt.tx_config_file ConfigFile,

    evt.tx_extension_name Extension,

    evt.tx_type EventType,

    inst.id_instance InstanceID,

    inst.id_arg_interval ArgInterval,

    inst.dt_arg_start ArgStartDate,

    inst.dt_arg_end ArgEndDate,

    dependedon.total DependentScore

  FROM t_recevent_inst inst

  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event

  INNER JOIN 

  (

    -- counts the total amount of dependencies per runnable instance

    SELECT 

      deps.id_orig_instance,

      COUNT(*) total

    FROM @deps deps

    GROUP BY

      deps.id_orig_instance 

  ) total_deps ON total_deps.id_orig_instance = inst.id_instance

  INNER JOIN 

  (

    -- counts the amount of satisfied dependencies per runnable instance

    SELECT 

      deps.id_orig_instance,

      COUNT(*) total

    FROM @deps deps

    WHERE deps.tx_status = 'Succeeded'

    GROUP BY

      deps.id_orig_instance 

  ) sat_deps ON sat_deps.id_orig_instance = inst.id_instance

  INNER JOIN 

  (

    -- determines how 'depended on' each runnable instance is

    -- the most 'depended on' instance should be run first in order

    -- to unblock the largest amount of other adapters in the shortest amount of time

    SELECT 

      inst.id_orig_instance,

      COUNT(*) total

    FROM @deps inst

    INNER JOIN t_recevent_dep dep ON dep.id_dependent_on_event = inst.id_orig_event

    GROUP BY

      inst.id_orig_instance

  ) dependedon ON dependedon.id_orig_instance = inst.id_instance

  LEFT OUTER JOIN t_usage_interval ui ON ui.id_interval = inst.id_arg_interval

  WHERE

    (total_deps.total = sat_deps.total OR inst.b_ignore_deps = 'Y') AND

    -- instance's effective date has passed or is NULL ('Execute Later')

    (inst.dt_effective IS NULL OR inst.dt_effective <= @dt_now) AND

    -- interval, if any, must be in the closed state

    (inst.id_arg_interval IS NULL OR ui.tx_interval_status = 'C')

  ORDER BY dependedon.total DESC, inst.id_instance ASC



  COMMIT

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


  

CREATE PROCEDURE DetermineReversibleEvents (@dt_now DATETIME, @id_instances VARCHAR(4000))

AS

BEGIN

  BEGIN TRAN



  DECLARE @deps TABLE

  (

    id_orig_event INT NOT NULL,

    id_orig_instance INT NOT NULL,

    tx_orig_name VARCHAR(255) NOT NULL, -- useful for debugging

    tx_name VARCHAR(255) NOT NULL,      -- useful for debugging

    id_event INT NOT NULL,

    id_instance INT,

    id_arg_interval INT,

    dt_arg_start DATETIME,

    dt_arg_end DATETIME,

    tx_status VARCHAR(14)

  )

  INSERT INTO @deps  

  SELECT * from GetEventReversalDeps(@dt_now, @id_instances)



  --

  -- returns the final rowset of all events that are 'ReadyToRun' and

  -- have satisfied dependencies. the rows are sorted in the order

  -- that they should be executed. 

  --

  SELECT 

    evt.tx_name EventName,

    evt.tx_class_name ClassName,

    evt.tx_config_file ConfigFile,

    evt.tx_extension_name Extension,

    evt.tx_reverse_mode ReverseMode,

    evt.tx_type EventType,

    run.id_run RunIDToReverse,

    inst.id_instance InstanceID,

    inst.id_arg_interval ArgInterval,

    inst.dt_arg_start ArgStartDate,

    inst.dt_arg_end ArgEndDate,

    dependedon.total DependentScore

  FROM t_recevent_inst inst

  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event

  INNER JOIN

  (

    -- finds the the run to reverse (the last execution's run ID)

    SELECT 

      id_instance,

      MAX(dt_start) dt_start

    FROM t_recevent_run run

    WHERE tx_type = 'Execute'

    GROUP BY

      id_instance

  ) maxrun ON maxrun.id_instance = inst.id_instance

  INNER JOIN t_recevent_run run ON run.dt_start = maxrun.dt_start

  INNER JOIN 

  (

    -- counts the total amount of dependencies per reversible instance

    SELECT 

      deps.id_orig_instance,

      COUNT(*) total

    FROM @deps deps

    GROUP BY

      deps.id_orig_instance 

  ) total_deps ON total_deps.id_orig_instance = inst.id_instance

  INNER JOIN 

  (

    -- counts the amount of satisfied dependencies per reversible instance

    SELECT 

      deps.id_orig_instance,

      COUNT(*) total

    FROM @deps deps

    WHERE deps.tx_status = 'NotYetRun'

    GROUP BY

      deps.id_orig_instance 

  ) sat_deps ON sat_deps.id_orig_instance = inst.id_instance

  INNER JOIN 

  (

    -- determines how 'depended on' (from an forward perspective) each instance is

    -- the least 'depended on' instance should be run first in order

    -- to unblock the largest amount of other adapters in the shortest amount of time

    SELECT 

      inst.id_orig_instance,

      COUNT(*) total

    FROM @deps inst

    INNER JOIN t_recevent_dep dep ON dep.id_dependent_on_event = inst.id_orig_event

    GROUP BY

      inst.id_orig_instance

  ) dependedon ON dependedon.id_orig_instance = inst.id_instance

  LEFT OUTER JOIN t_usage_interval ui ON ui.id_interval = inst.id_arg_interval

  WHERE

    (total_deps.total = sat_deps.total OR inst.b_ignore_deps = 'Y') AND

    -- instance's effective date has passed or is NULL ('Execute Later')

    (inst.dt_effective IS NULL OR inst.dt_effective <= @dt_now) AND

    -- interval, if any, must be in the closed state

    (inst.id_arg_interval IS NULL OR ui.tx_interval_status = 'C')

  ORDER BY dependedon.total ASC, inst.id_instance ASC



  COMMIT

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


		

      create proc DropAdjustmentTables

      as

	      DECLARE @CursorVar CURSOR

	      declare @columncursor CURSOR

	      declare @count integer

	      declare @i integer

	      declare @pvname varchar(256)

	      declare @adjname varchar(256)

	      declare @ddlstr as varchar(8000)

	      declare @idpi as int

	      declare @innercount as int

	      declare @j as int

	      declare @columnname as varchar(256)

	      declare @datatype as varchar(256)

	      SET @CursorVar = CURSOR FORWARD_ONLY STATIC

	      FOR

	      select distinct(pv.nm_table_name),

	      't_aj_' + substring(pv.nm_table_name,6,1000),

	      t_pi.id_pi

	      from 

	      t_pi

	      -- all of the product views references by priceable items

	      INNER JOIN t_prod_view pv on pv.nm_name = t_pi.nm_productview

	      INNER JOIN t_charge on t_charge.id_pi = t_pi.id_pi

	      select @i = 0

	      OPEN @CursorVar

	      Set @count = @@cursor_rows

	      while(@i < @count) begin

		      select @i = @i + 1

		      FETCH NEXT FROM @CursorVar into @pvname,@adjname,@idpi

		      -- drop the table if it exists

		      select @ddlstr =  ('if exists (select * from dbo.sysobjects where id = object_id(''' + @adjname + ''') and OBJECTPROPERTY(id, N''IsUserTable'') = 1) drop table ' + @adjname)

		      exec (@ddlstr)

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


			create proc ExecSpProcOnKind @kind as int,@id as int
				as
				declare @sprocname varchar(256)
				select @sprocname = nm_sprocname from t_principals where id_principal = @kind
				exec (@sprocname + ' ' + @id)
	 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


					create proc ExtendedUpsert(@table_name as varchar(100),
												 @update_list as varchar(8000),
												 @insert_list as varchar(8000),
												 @clist as varchar(8000),
												 @id_prop as int)
					as
					exec('update ' + @table_name + ' set ' + 
					@update_list + ' where ' + @table_name + '.id_prop = ' + @id_prop)
					if @@rowcount = 0 begin
						exec('insert into ' + @table_name + ' (id_prop,' + @clist + ') values( ' + @id_prop + ',' + @insert_list + ')')
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


  

CREATE PROCEDURE FailZombieRecurringEvents

(

  @dt_now DATETIME,          -- system's time

  @tx_machine VARCHAR(128),  -- macine to check for zombies on

  @count INT OUTPUT          -- number of zombies found and failed

)

AS

BEGIN



  BEGIN TRAN



  SELECT @count = 0



  DECLARE @zombies TABLE

  (

    id_instance INT NOT NULL,

    id_run INT NOT NULL

  )



  -- finds any zombie recurring events for the given machine

  INSERT INTO @zombies

  SELECT 

    inst.id_instance,

    run.id_run

  FROM t_recevent_inst inst

  LEFT OUTER JOIN

  (

    -- finds the last run's ID

    SELECT 

      id_instance,

    MAX(dt_start) dt_start

    FROM t_recevent_run run

    GROUP BY

      id_instance

  ) lastrun ON lastrun.id_instance = inst.id_instance

  LEFT OUTER JOIN t_recevent_run run ON run.dt_start = lastrun.dt_start

  WHERE 

    (inst.tx_status IN ('Running', 'Reversing') OR run.tx_status = 'InProgress') AND

    -- only look at runs which are being processed by the given machine

    -- in a multi-machine case, we don't want to fail valid runs

    -- being processed on a different machine

    run.tx_machine = @tx_machine



  SELECT @count = @@ROWCOUNT  



  -- fails the zombie instances

  UPDATE t_recevent_inst

  SET tx_status = 'Failed'

  FROM t_recevent_inst inst
  INNER JOIN @zombies zombies ON zombies.id_instance = inst.id_instance



  -- fails the zombie runs 

  UPDATE t_recevent_run

  SET tx_status = 'Failed', dt_end = @dt_now, tx_detail = 'Run was identified as a zombie'

  FROM t_recevent_run run

  INNER JOIN @zombies zombies ON zombies.id_run = run.id_run



  SELECT 

    id_instance InstanceID,

    id_run RunID

  FROM @zombies

  COMMIT

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


		

create procedure GenerateAdjustmentTables

as

	DECLARE @CursorVar CURSOR

	declare @columncursor CURSOR

	declare @count integer

	declare @i integer
	declare @pvname varchar(256)

	declare @adjname varchar(256)

	declare @ddlstr as varchar(8000)

	declare @idpi as int

	declare @innercount as int

	declare @j as int

	declare @columnname as varchar(256)

	declare @datatype as varchar(256)

	SET @CursorVar = CURSOR FORWARD_ONLY STATIC

	FOR

	select distinct(pv.nm_table_name),

	't_aj_' + substring(pv.nm_table_name,6,1000),

	t_pi.id_pi

	from 

	t_pi

	-- all of the product views references by priceable items

	INNER JOIN t_prod_view pv on pv.nm_name = t_pi.nm_productview

	-- BP changed next join to 'left outer' from 'inner'

	-- in order to support Amount adjustments for PIs that don't

	-- have any charges

	

	LEFT OUTER JOIN t_charge on t_charge.id_pi = t_pi.id_pi

	select @i = 0

	OPEN @CursorVar

	Set @count = @@cursor_rows

	while(@i < @count) begin

		select @i = @i + 1

		FETCH NEXT FROM @CursorVar into @pvname,@adjname,@idpi

		-- drop the table if it exists

		select @ddlstr =  ('if exists (select * from dbo.sysobjects where id = object_id(''' + @adjname + ''') and OBJECTPROPERTY(id, N''IsUserTable'') = 1) drop table ' + @adjname)

		exec (@ddlstr)

		-- create the table

		set @columncursor = CURSOR FORWARD_ONLY STATIC

		for

		select prop.nm_column_name,prop.nm_data_type from t_charge 

			INNER JOIN t_prod_view_prop prop on prop.id_prod_view_prop = t_charge.id_amt_prop

			where id_pi = @idpi

		OPEN @columncursor

		set @innercount = @@cursor_rows

		select @j = 0,@ddlstr = 'create table ' + @adjname + ' (id_adjustment int'

		while (@j < @innercount) begin

			FETCH NEXT FROM @columncursor into @columnname,@datatype

			select @ddlstr = (@ddlstr + ', c_aj_' + right(@columnname,len(@columnname)-2) + ' ' + @datatype)

			select @j = @j+1

		end

		select @ddlstr = (@ddlstr + ')')

		exec (@ddlstr)

		CLOSE @columncursor

		DEALLOCATE @columncursor

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


     

---------------------------------------------------------

-- returns all balances for account as of end of interval

-- return codes:

-- O = OK

-- 1 = currency mismatch

---------------------------------------------------------

CREATE PROCEDURE GetBalances( 

@id_acc int,

@id_interval int,

@previous_balance numeric(18, 6) OUTPUT,

@balance_forward numeric(18, 6) OUTPUT,

@current_balance numeric(18, 6) OUTPUT,

@currency varchar(3) OUTPUT,

@estimation_code int OUTPUT, -- 0 = NONE: no estimate, all balances taken from t_invoice

                             -- 1 = CURRENT_BALANCE: balance_forward and current_balance estimated, @previous_balance taken from t_invoice

                             -- 2 = PREVIOUS_BALANCE: all balances estimated 

@return_code int OUTPUT

)

AS

BEGIN

DECLARE

  @balance_date datetime,

  @unbilled_prior_charges numeric(18, 6), -- unbilled charges from interval after invoice and before this one

  @previous_charges numeric(18, 6),       -- payments, adjsutments for this interval

  @current_charges numeric(18, 6),        -- current charges for this interval

  @interval_start datetime,

  @tmp_amount numeric(18, 6),

  @tmp_currency varchar(3)



  SET @return_code = 0



  -- step1: check for existing t_invoice, and use that one if exists

  SELECT @current_balance = current_balance,

    @balance_forward = current_balance - invoice_amount - tax_ttl_amt,

    @previous_balance = @balance_forward - payment_ttl_amt - postbill_adj_ttl_amt - ar_adj_ttl_amt,

    @currency = invoice_currency

  FROM t_invoice

  WHERE id_acc = @id_acc

  AND id_interval = @id_interval

  

  IF NOT @current_balance IS NULL

    BEGIN

    SET @estimation_code = 0 

    RETURN --done

    END



  -- step2: get balance (as of @interval_start) from previous invoice

  --set @interval_start = (select dt_start from t_usage_interval where id_interval = @id_interval)



  -- AR: Bug fix for 10238, when billing cycle is changed.



  select @interval_start =

	CASE WHEN aui.dt_effective IS NULL THEN

		ui.dt_start

	     ELSE dateadd(s, 1, aui.dt_effective)

	END

  from t_acc_usage_interval aui

	inner join t_usage_interval ui on aui.id_usage_interval = ui.id_interval

	where aui.id_acc = @id_acc

	AND ui.id_interval = @id_interval



  exec GetLastBalance @id_acc, @interval_start, @previous_balance output, @balance_date output, @currency output


  -- step3: calc @unbilled_prior_charges

  set @unbilled_prior_charges = 0



  -- add unbilled payments, and ar adjustments

  SELECT @tmp_amount = SUM(au.Amount),

    @tmp_currency = au.am_currency

  FROM t_acc_usage au

   INNER JOIN t_prod_view pv on au.id_view = pv.id_view

   INNER JOIN t_acc_usage_interval aui on au.id_acc = aui.id_acc and au.id_usage_interval = aui.id_usage_interval

   INNER JOIN t_usage_interval ui on aui.id_usage_interval = ui.id_interval

  WHERE pv.nm_table_name in ('t_pv_Payment', 't_pv_ARAdjustment')

    AND au.id_acc = @id_acc

    AND ui.dt_end > @balance_date

    AND ui.dt_start < @interval_start

  GROUP BY au.am_currency



  IF @@ROWCOUNT > 1 OR (@@ROWCOUNT = 1 AND @tmp_currency <> @currency)

  BEGIN

    SET @return_code = 1 -- currency mismatch

    RETURN 1

  END

  

  SET @tmp_amount = isnull(@tmp_amount, 0)

  SET @unbilled_prior_charges = @unbilled_prior_charges + @tmp_amount



  SET @tmp_amount = 0.0

  

  -- add unbilled current charges

  SELECT @tmp_amount = SUM(isnull(au.Amount, 0.0)) + SUM(isnull(au.Tax_Federal,0.0)) + SUM(isnull(au.Tax_State,0.0)) + SUM(isnull(au.Tax_County,0.0)) + SUM(isnull(au.Tax_Local,0.0)) + SUM(isnull(au.Tax_Other,0.0)),

    @tmp_currency = au.am_currency

  FROM t_acc_usage au

    inner join t_view_hierarchy vh on au.id_view = vh.id_view

    left outer join t_pi_template piTemplated2 on piTemplated2.id_template=au.id_pi_template

    left outer join t_base_props pi_type_props on pi_type_props.id_prop=piTemplated2.id_pi

    inner join t_enum_data enumd2 on au.id_view=enumd2.id_enum_data

    INNER JOIN t_acc_usage_interval aui on au.id_acc = aui.id_acc and au.id_usage_interval = aui.id_usage_interval

    INNER JOIN t_usage_interval ui on aui.id_usage_interval = ui.id_interval

  WHERE

    vh.id_view = vh.id_view_parent

    AND au.id_acc = @id_acc

    AND ((au.id_pi_template is null and au.id_parent_sess is null) or (au.id_pi_template is not null and piTemplated2.id_template_parent is null))

    AND (pi_type_props.n_kind IS NULL or pi_type_props.n_kind <> 15 or upper(enumd2.nm_enum_data) NOT LIKE '%_TEMP')

    AND ui.dt_end > @balance_date

    AND ui.dt_start < @interval_start

  GROUP BY au.am_currency



  IF @@ROWCOUNT > 1 OR (@@ROWCOUNT = 1 AND @tmp_currency <> @currency)

  BEGIN

    SET @return_code = 1 -- currency mismatch

    RETURN 1

  END



  SET @tmp_amount = isnull(@tmp_amount, 0)

  SET @unbilled_prior_charges = @unbilled_prior_charges + @tmp_amount



  -- add unbilled pre-bill and post-bill adjustments

  SET @unbilled_prior_charges = @unbilled_prior_charges + isnull(

    (SELECT SUM(PrebillAdjustmentAmount + PostbillAdjustmentAmount)

     FROM vw_adjustment_summary

     WHERE id_acc = @id_acc

     AND dt_end > @balance_date

     AND dt_start < @interval_start), 0)





  -- step4: add @unbilled_prior_charges to @previous_balance if any found

  IF @unbilled_prior_charges <> 0

    BEGIN

    SET @estimation_code = 2

    SET @previous_balance = @previous_balance + @unbilled_prior_charges

    END

  ELSE

    SET @estimation_code = 1



  -- step5: get previous charges

  SELECT

    @previous_charges = SUM(au.Amount),

    @tmp_currency = au.am_currency

  FROM t_acc_usage au

   INNER JOIN t_prod_view pv on au.id_view = pv.id_view

  WHERE pv.nm_table_name in ('t_pv_Payment', 't_pv_ARAdjustment')

  AND au.id_acc = @id_acc

  AND au.id_usage_interval = @id_interval

  GROUP BY au.am_currency



  IF @@ROWCOUNT > 1 OR (@@ROWCOUNT = 1 AND @tmp_currency <> @currency)

  BEGIN

    SET @return_code = 1 -- currency mismatch

    RETURN 1

  END



  IF @previous_charges IS NULL

    SET @previous_charges = 0



  -- add post-bill adjustments

  SET @previous_charges = @previous_charges + isnull(

    (SELECT SUM(PostbillAdjustmentAmount) FROM vw_adjustment_summary

     WHERE id_acc = @id_acc AND id_usage_interval = @id_interval), 0)





  -- step6: get current charges

  SELECT

   @current_charges = SUM(isnull(au.Amount, 0.0)) + SUM(isnull(au.Tax_Federal,0.0)) + SUM(isnull(au.Tax_State,0.0)) + SUM(isnull(au.Tax_County,0.0)) + SUM(isnull(au.Tax_Local,0.0)) + SUM(isnull(au.Tax_Other,0.0)),

   @tmp_currency = au.am_currency

  FROM t_acc_usage au

    inner join t_view_hierarchy vh on au.id_view = vh.id_view

    left outer join t_pi_template piTemplated2 on piTemplated2.id_template=au.id_pi_template

    left outer join t_base_props pi_type_props on pi_type_props.id_prop=piTemplated2.id_pi

    inner join t_enum_data enumd2 on au.id_view=enumd2.id_enum_data

  WHERE

    vh.id_view = vh.id_view_parent

  AND au.id_acc = @id_acc

  AND ((au.id_pi_template is null and au.id_parent_sess is null) or (au.id_pi_template is not null and piTemplated2.id_template_parent is null))

  AND (pi_type_props.n_kind IS NULL or pi_type_props.n_kind <> 15 or upper(enumd2.nm_enum_data) NOT LIKE '%_TEMP')

  AND au.id_usage_interval = @id_interval

  GROUP BY au.am_currency



  IF @@ROWCOUNT > 1 OR (@@ROWCOUNT = 1 AND @tmp_currency <> @currency)

  BEGIN

    SET @return_code = 1 -- currency mismatch

    RETURN 1

  END



  IF @current_charges IS NULL

    SET @current_charges = 0



  -- add pre-bill adjustments

  SET @current_charges = @current_charges + isnull(

    (SELECT SUM(PrebillAdjustmentAmount) FROM vw_adjustment_summary

     WHERE id_acc = @id_acc AND id_usage_interval = @id_interval), 0)



  SET @balance_forward = @previous_balance + @previous_charges

  SET @current_balance = @balance_forward + @current_charges

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


			 	CREATE PROC GetCurrentID @nm_current varchar(20), @id_current int OUTPUT
        as 
        begin tran 
        select @id_current = id_current from t_current_id 
          where nm_current = @nm_current 
        update t_current_id set id_current = id_current + 1 
          where nm_current = @nm_current 
				if ((@@error != 0) OR (@@rowCount != 1)) 
        begin 
          select @id_current = -99
				  rollback transaction 
        end 
        else 
        begin 
				  commit transaction 
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


     

---------------------------------------------------------

-- gets last calculated balance for an account

-- or latest calculated balance based on a cut-off date

---------------------------------------------------------

CREATE PROCEDURE GetLastBalance( 

@id_acc int,                    -- account

@before_date datetime,          -- last balance before this date, can be NULL

@balance numeric(18, 6) OUTPUT, -- the balance

@balance_date datetime OUTPUT,  -- the date the balance was computed

@currency varchar(3) OUTPUT     -- currency for account

)

AS

BEGIN



  SELECT TOP 1 @balance = inv.current_balance,

    @balance_date = ui.dt_end,

    @currency = inv.invoice_currency

  FROM t_invoice inv

  JOIN t_usage_interval ui ON ui.id_interval = inv.id_interval

  WHERE id_acc = @id_acc

    AND (@before_date IS NULL OR ui.dt_end < @before_date)

  ORDER BY ui.dt_end DESC



  IF @balance IS NULL

    BEGIN

    SET @balance = 0

    SET @currency = (select c_currency from t_av_internal where id_acc = @id_acc)

    SET @balance_date = '1900-01-01'

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


          CREATE PROC GetLocalizedSiteInfo @nm_space nvarchar(40), 
            @tx_lang_code varchar(10), @id_site int OUTPUT
          as 
          if not exists (select * from t_localized_site where 
            nm_space = @nm_space and tx_lang_code = @tx_lang_code) 
          begin 
            insert into t_localized_site (nm_space, tx_lang_code) 
              values (@nm_space, @tx_lang_code)
            if ((@@error != 0) OR (@@rowcount != 1)) 
            begin
              select @id_site = -99
            end 
            else 
            begin 
              select @id_site = @@identity 
            end 
          end 
          else 
          begin 
            select @id_site = id_site from t_localized_site 
              where nm_space = @nm_space and tx_lang_code = @tx_lang_code 
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

create proc GetServiceEndpointPropDefs @id as int as select * from t_service_endpoint JOIN t_base_props on t_base_props.id_prop = @id  where t_service_endpoint.id_se = @id AND t_base_props.n_kind = 400
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


				 CREATE PROC InsertAcctToIntervalMapping @id_acc int, @id_interval int
         as 
				 if not exists (select * from t_acc_usage_interval where id_acc = @id_acc 
          and id_usage_interval = @id_interval) 
				 begin 
          insert into t_acc_usage_interval (id_acc, id_usage_interval, tx_status) 
            values (@id_acc, @id_interval, 'O') 
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


		  create proc InsertAcctUsageWithUID @tx_UID varbinary(16), 
			@id_acc int, @id_view int, @id_usage_interval int, @uid_parent_sess varbinary(16), 
			@id_svc int, @dt_session datetime, @amount numeric(18,6), @am_currency varchar(3), 
			@tax_federal numeric(18,6), @tax_state numeric(18,6), @tax_county numeric(18,6), 
			@tax_local numeric(18,6), @tax_other numeric(18,6), @tx_batch varbinary(16), 
		@id_prod int, @id_pi_instance int, @id_pi_template int,
		@id_sess int OUTPUT as
		  declare @id_parent_sess int
  
		  select @id_parent_sess = -1
			select @id_parent_sess = id_sess from t_acc_usage 
			where tx_UID = @uid_parent_sess
		  if (@id_parent_sess = -1)	begin	select @id_sess = -99	end
		  else
		  begin 
		  select @id_sess = id_current from t_current_id where nm_current='id_sess' 
		  update t_current_id set id_current = id_current + 1 where nm_current='id_sess'
		  insert into t_acc_usage (id_sess, tx_UID, id_acc, id_view, id_usage_interval, 
			id_parent_sess, id_svc, dt_session, amount, am_currency, tax_federal, tax_state, 
			tax_county, tax_local, tax_other, tx_batch, id_prod, id_pi_instance, id_pi_template) 
		  values 
			(@id_sess, @tx_UID, @id_acc, @id_view, @id_usage_interval, @id_parent_sess, @id_svc, @dt_session, 
			@amount, @am_currency, @tax_federal, @tax_state, @tax_county, @tax_local, @tax_other, @tx_batch,
		@id_prod, @id_pi_instance, @id_pi_template)
		  if ((@@error != 0) OR (@@rowcount <> 1))
		  begin 
			select @id_sess = -99 
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


		create proc InsertBaseProps 
			@id_lang_code int,
			@a_kind int,
			@a_approved char(1),
			@a_archive char(1),
			@a_nm_name NVARCHAR(255),
			@a_nm_desc NVARCHAR(255),
			@a_nm_display_name NVARCHAR(255),
			@a_id_prop int OUTPUT 
		AS
		begin
		  declare @id_desc_display_name int
      declare @id_desc_name int
      declare @id_desc_desc int
			exec UpsertDescription @id_lang_code, @a_nm_display_name, NULL, @id_desc_display_name output
			exec UpsertDescription @id_lang_code, @a_nm_name, NULL, @id_desc_name output
			exec UpsertDescription @id_lang_code, @a_nm_desc, NULL, @id_desc_desc output
			insert into t_base_props (n_kind, n_name, n_desc,nm_name,nm_desc,b_approved,b_archive,
			n_display_name, nm_display_name) values
			(@a_kind, @id_desc_name, @id_desc_desc, @a_nm_name,@a_nm_desc,@a_approved,@a_archive,
			 @id_desc_display_name,@a_nm_display_name)
			select @a_id_prop =@@identity
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


	

			create proc InsertChargeProperty

			@a_id_charge int,

			@a_id_prod_view_prop int,

			@a_id_charge_prop int OUTPUT

			as

      insert into t_charge_prop

      (

			id_charge,

			id_prod_view_prop

      )

      values

      (

			@a_id_charge,

			@a_id_prod_view_prop

      )

			select @a_id_charge_prop =@@identity

	
	
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


       create proc InsertDefaultTariff
       as 
       declare @id int
       select @id = id_enum_data from t_enum_data where 
          nm_enum_data = 'metratech.com/tariffs/TariffID/Default'
       insert into t_tariff (id_enum_tariff, tx_currency) values (@id, 'USD')
			 select @id = id_enum_data from t_enum_data where
					nm_enum_data = 'metratech.com/tariffs/TariffID/ConferenceExpress'
				insert into t_tariff(id_enum_tariff,tx_currency) values (@id,'USD')
			 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


				CREATE PROC InsertEnumData	@nm_enum_data varchar(255), 
											@id_enum_data int OUTPUT 
				as

				begin tran 

				if not exists (select * from t_enum_data where nm_enum_data = @nm_enum_data ) 
				begin 
					insert into t_mt_id default values
					select @id_enum_data = @@identity

					insert into t_enum_data (nm_enum_data, id_enum_data) values ( @nm_enum_data, @id_enum_data )
					if ((@@error != 0) OR (@@rowCount != 1)) 
					begin
						rollback transaction 
						select @id_enum_data = -99  
					end 
				end 
				else 
				begin 
					select @id_enum_data = id_enum_data from t_enum_data 
					where nm_enum_data = @nm_enum_data
				end 
				commit transaction
			 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


		CREATE PROC InsertInvoice 
			@namespace varchar(200),
			@invoice_string varchar(50),           
			@id_interval int, 
			@id_acc int,
			@invoice_amount numeric(18,6),
			@invoice_date varchar(100),
			@invoice_due_date varchar(100),
      @invoice_num int,
			@id_invoice int OUTPUT         
			as
			insert into t_invoice 
			(namespace, invoice_string, id_interval, id_acc, invoice_amount, invoice_date, 
      invoice_due_date, id_invoice_num)           
			values 
			(@namespace, @invoice_string, @id_interval, @id_acc, @invoice_amount, @invoice_date, 
      @invoice_due_date, @invoice_num)          
			select @id_invoice = @@identity
			 
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


			

			CREATE proc InsertMeteredBatch (

				@tx_batch varbinary(16),

				@tx_batch_encoded varchar(255),

  			@tx_source varchar(255),

  			@tx_sequence varchar(255),

				@tx_name varchar(255),

				@tx_namespace varchar(255),

				@tx_status char(1),

				@dt_crt_source datetime,

				@dt_crt datetime,

				@n_completed int,  

				@n_failed int,

				@n_expected int,

				@n_metered int,

				@id_batch INT OUTPUT )

			AS

			BEGIN

			  select @id_batch = -1

				IF NOT EXISTS (SELECT 

				                 * 

											 FROM 

											   t_batch

					             WHERE 

											   tx_name = @tx_name AND 

												 tx_namespace = @tx_namespace AND

												 tx_sequence = @tx_sequence AND

												 tx_status != 'D')

				BEGIN	

				  INSERT INTO t_batch (

						tx_batch,

						tx_batch_encoded,

  					tx_source,

  					tx_sequence,

						tx_name,

						tx_namespace,

						tx_status,

						dt_crt_source,

						dt_crt,

						n_completed,  

						n_failed,

						n_expected,

						n_metered )

					values (

						@tx_batch,

						@tx_batch_encoded,

  					@tx_source,

  					@tx_sequence,

						@tx_name,

						@tx_namespace,

						UPPER(@tx_status),

						@dt_crt_source,

						@dt_crt,

						@n_completed,  

						@n_failed,

						@n_expected,

						@n_metered )

	

					select @id_batch = @@identity

				END	

				ELSE

				BEGIN

				  -- MTBATCH_BATCH_ALREADY_EXISTS ((DWORD)0xE4020001L)

				  SELECT @id_batch = -469630975

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


	

			create proc InsertProductView

			@a_id_view int,

			@a_nm_name nvarchar(255),

			@a_dt_modified datetime,

			@a_nm_table_name nvarchar(255),

			@a_id_prod_view int OUTPUT

			as

      insert into t_prod_view

      (

			id_view,

			dt_modified,

			nm_name,

			nm_table_name

      )

      values

      (

			@a_id_view,

			@a_dt_modified,

			@a_nm_name,

			@a_nm_table_name

      )

			select @a_id_prod_view =@@identity

	
	
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


	

			create proc InsertProductViewProperty 

			@a_id_prod_view int,

			@a_nm_name nvarchar(255),

			@a_nm_data_type nvarchar(255),

			@a_nm_column_name nvarchar(255),

			@a_b_required char(1),

			@a_b_composite_idx char(1),

			@a_b_single_idx char(1),

      @a_b_part_of_key char(1),

      @a_b_exportable char(1),

      @a_b_filterable char(1),

      @a_b_user_visible char(1),

			@a_nm_default_value nvarchar(255),

			@a_n_prop_type int,

			@a_nm_space varchar(255),

			@a_nm_enum varchar(255),

      @a_b_core char(1),

			@a_id_prod_view_prop int OUTPUT

			as

      insert into t_prod_view_prop 

      (

			id_prod_view,

			nm_name,

			nm_data_type,

			nm_column_name,

			b_required,

			b_composite_idx,

			b_single_idx,

      b_part_of_key,

      b_exportable,

      b_filterable,

      b_user_visible,

			nm_default_value,

			n_prop_type,

			nm_space,

			nm_enum,

      b_core

      )

      values

      (

			@a_id_prod_view,

			@a_nm_name,

			@a_nm_data_type,

			@a_nm_column_name,

			@a_b_required,

			@a_b_composite_idx,

			@a_b_single_idx,

      @a_b_part_of_key,

      @a_b_exportable,

      @a_b_filterable,

      @a_b_user_visible,

			@a_nm_default_value,

			@a_n_prop_type,

			@a_nm_space,

			@a_nm_enum,

      @a_b_core

      )

			select @a_id_prod_view_prop =@@identity

	
	
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


				create proc InsertUsageCycleInfo @id_cycle_type int, @dom int, 
          @period_type char(1), @id_usage_cycle int OUTPUT
				as 
        insert into t_usage_cycle (id_cycle_type, day_of_month, tx_period_type) 
          values (@id_cycle_type, @dom, @period_type) 
        if ((@@error != 0) OR (@@rowcount != 1)) 
        begin
          select @id_usage_cycle = -99 
        end 
        else 
        begin 
          select @id_usage_cycle = @@identity 
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


			 create proc InsertUsageIntervalInfo @dt_start datetime, @dt_end datetime,@id_usage_cycle int, @id_usage_interval int OUTPUT
			 as 
			 select @id_usage_interval = id_interval from t_pc_interval where id_cycle = @id_usage_cycle
			 and dt_start=@dt_start and dt_end=@dt_end

			 insert into t_usage_interval (id_interval, dt_start, dt_end, 
			 id_usage_cycle, tx_interval_status) 
			   values (@id_usage_interval, @dt_start, @dt_end,@id_usage_cycle, 'O') 
			 if ((@@error != 0) OR (@@rowcount != 1)) 
			 begin 
			   select @id_usage_interval = -99 
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


  

CREATE PROCEDURE InstantiateScheduledEvent 

  (

    @dt_now DATETIME,

    @id_event INT,

    @dt_end DATETIME,

    @id_instance INT OUTPUT,

    @status INT OUTPUT

  )

AS

BEGIN



  BEGIN TRAN



  SELECT @status      = -99

  SELECT @id_instance = -99



  --

  -- attempts to update an pre-existing NotYetRun instance of this event

  --

  SELECT @id_instance = inst.id_instance

  FROM t_recevent_inst inst

  INNER JOIN 

  (

    -- finds the last instance

    SELECT MAX(inst.dt_arg_end) dt_arg_end

    FROM t_recevent evt

    INNER JOIN t_recevent_inst inst ON inst.id_event = evt.id_event

    WHERE

      -- event is active

      evt.dt_activated <= @dt_now AND

      (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) AND

      evt.id_event = @id_event AND

      -- event is of type scheduled

      evt.tx_type = 'Scheduled'

  ) maxinst ON maxinst.dt_arg_end = inst.dt_arg_end

  WHERE

    inst.id_event = @id_event AND

    -- run has not yet been run

    inst.tx_status = 'NotYetRun' AND

    -- existing end date of the latest instance must be 

    -- before the newly requested end date

    inst.dt_arg_end < @dt_end



  IF (@@ROWCOUNT = 1)

  BEGIN

    UPDATE t_recevent_inst SET dt_arg_end = @dt_end WHERE id_instance = @id_instance



    COMMIT

    SELECT @status = 0 -- success (update)

    RETURN

  END





  --

  -- otherwise, an existing instance did not exist so create a new one

  --

  INSERT INTO t_recevent_inst(id_event,id_arg_interval,dt_arg_start,dt_arg_end,b_ignore_deps,dt_effective,tx_status)

  SELECT

    evt.id_event,

    NULL,             -- id_arg_interval

    MAX(dbo.AddSecond(ISNULL(inst.dt_arg_end, dbo.SubtractSecond(evt.dt_activated)))),

    @dt_end,          -- dt_arg_end

    'N',              -- b_ignore_deps

    NULL,             -- dt_effective

    'NotYetRun'       -- tx_status

  FROM t_recevent evt

  LEFT OUTER JOIN t_recevent_inst inst ON inst.id_event = evt.id_event

  WHERE

    -- event is active

    evt.dt_activated <= @dt_now AND

    (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) AND

    evt.id_event = @id_event AND

    -- event is of type scheduled

    evt.tx_type = 'Scheduled'

  GROUP BY

    evt.id_event

  HAVING 

    -- start date must come before the requested end date

    MAX(dbo.AddSecond(ISNULL(inst.dt_arg_end, evt.dt_activated))) < @dt_end



  -- success!

  IF (@@ROWCOUNT = 1)

  BEGIN

    SELECT @status = 0    -- success (insert)

    SELECT @id_instance = @@IDENTITY

    COMMIT

    RETURN

  END





  -- 

  -- no instance was updated or created - figure out exactly what went wrong

  --



  -- does the event exist?

  SELECT 

    evt.id_event

  FROM t_recevent evt

  WHERE

    evt.dt_activated <= @dt_now AND

    (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) AND

    evt.id_event = @id_event



  IF (@@ROWCOUNT = 0)

  BEGIN

    SELECT @status = -1 -- event not found

    ROLLBACK

    RETURN

  END



  -- is the event of type scheduled?

  SELECT 

    evt.id_event

  FROM t_recevent evt

  WHERE

    evt.tx_type = 'Scheduled' AND

    evt.id_event = @id_event



  IF (@@ROWCOUNT = 0)

  BEGIN

    SELECT @status = -2 -- event is not active

    ROLLBACK

    RETURN

  END



  -- is the last instances end date greater than the proposed start date?

  SELECT

    evt.id_event,

    MAX(dbo.AddSecond(ISNULL(inst.dt_arg_end, dbo.SubtractSecond(evt.dt_activated))))

  FROM t_recevent evt

  LEFT OUTER JOIN t_recevent_inst inst ON inst.id_event = evt.id_event

  WHERE 

    evt.id_event = @id_event 

  GROUP BY

    evt.id_event

  HAVING 

    -- start date must come before the requested end date

    MAX(dbo.AddSecond(ISNULL(inst.dt_arg_end, evt.dt_activated))) < @dt_end



  IF (@@ROWCOUNT = 0)

  BEGIN

    SELECT @status = -3 -- last end date is greater than the proposed start date

    ROLLBACK

    RETURN

  END



  -- unknown failure

  ROLLBACK

  SELECT @status = -99  

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




CREATE PROCEDURE MTSP_INSERTINVOICE

@id_interval int,

@invoicenumber_storedproc nvarchar(256), --this is the name of the stored procedure used to generate invoice numbers

@is_sample varchar(1),

@dt_now DATETIME,  -- the MetraTech system's date

@id_run int,

@num_invoices int OUTPUT,

@return_code int OUTPUT

AS

BEGIN

DECLARE 

@invoice_date datetime, 

@cnt int,

@curr_max_id int,

@id_interval_exist int,

@debug_flag bit,

@SQLError int,

@ErrMsg varchar(200)

SET NOCOUNT ON

-- Initialization

SET @num_invoices = 0

SET @invoice_date = CAST(SUBSTRING(CAST(@dt_now AS CHAR),1,11) AS DATETIME) --datepart

SET @debug_flag = 1 -- yes

--SET @debug_flag = 0 -- no

-- Validate input parameter values

IF @id_interval IS NULL 

BEGIN

  SET @ErrMsg = 'InsertInvoice: Completed abnormally, id_interval is null'

  GOTO FatalError

END

if @invoicenumber_storedproc IS NULL OR RTRIM(@invoicenumber_storedproc) = ''

BEGIN

  SET @ErrMsg = 'InsertInvoice: Completed abnormally, invoicenumber_storedproc is null'

  GOTO FatalError

END

IF @debug_flag = 1 

  INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)

    VALUES (@id_run, 'Debug', 'InsertInvoice: Started', getutcdate()) 

-- If already exists, do not process again

SELECT TOP 1 @id_interval_exist = id_interval

FROM t_invoice_range

WHERE id_interval = @id_interval and id_run = NULL

SELECT @SQLError = @@ERROR

IF @SQLError <> 0 GOTO FatalError

IF @id_interval_exist IS NOT NULL

BEGIN

  SET @ErrMsg = 'InsertInvoice: Invoice number already exists in the t_invoice_range table, '

    + 'process skipped, process completed successfully at ' 

    + CONVERT(char, getutcdate(), 109)

  GOTO SkipReturn

END

SELECT TOP 1 @id_interval_exist = id_interval

FROM t_invoice

WHERE id_interval = @id_interval and sample_flag = 'N'

SELECT @SQLError = @@ERROR

IF @SQLError <> 0 GOTO FatalError

IF @id_interval_exist IS NOT NULL

BEGIN

  SET @ErrMsg = 'InsertInvoice: Invoice number already exists in the t_invoice table, '

    + 'process skipped, process completed successfully at ' 

    + CONVERT(char, getdate(), 109)

  GOTO SkipReturn

END



-- call MTSP_INSERTINVOICE_BALANCES to populate #tmp_acc_amounts, #tmp_prev_balance, #tmp_adjustments



CREATE TABLE #tmp_acc_amounts

  (tmp_seq int IDENTITY,

  namespace nvarchar(40),

  id_interval int,

  id_acc int,

  invoice_currency varchar(10),

  payment_ttl_amt numeric(18, 6),

  postbill_adj_ttl_amt numeric(18, 6),

  ar_adj_ttl_amt numeric(18, 6),

  previous_balance numeric(18, 6),

  tax_ttl_amt numeric(18, 6),

  current_charges numeric(18, 6),

  id_payer int,

  id_payer_interval int

  )



SELECT @SQLError = @@ERROR

IF @SQLError <> 0 GOTO FatalError



CREATE TABLE #tmp_prev_balance

 ( id_acc int,

   previous_balance numeric(18, 6)

 )



SELECT @SQLError = @@ERROR

IF @SQLError <> 0 GOTO FatalError



CREATE TABLE #tmp_adjustments

 ( id_acc int,

   PrebillAdjustmentAmount numeric(18, 6),

   PostbillAdjustmentAmount numeric(18, 6)

 )



SELECT @SQLError = @@ERROR

IF @SQLError <> 0 GOTO FatalError



EXEC MTSP_INSERTINVOICE_BALANCES @id_interval, 0, @id_run, @return_code OUTPUT



if @return_code <> 0 GOTO FatalError



-- Obtain the configured invoice strings and store them in a temp table

CREATE TABLE #tmp_invoicenumber

(id_acc int NOT NULL,

 namespace nvarchar(40) NOT NULL,

 invoice_string nvarchar(50) NOT NULL,

 invoice_due_date datetime NOT NULL,

 id_invoice_num int NOT NULL)



SELECT @SQLError = @@ERROR

IF @SQLError <> 0 GOTO FatalError



INSERT INTO #tmp_invoicenumber EXEC @invoicenumber_storedproc @invoice_date

SELECT @SQLError = @@ERROR

IF @SQLError <> 0 GOTO FatalError

-- End of 11/20/2002 add



SELECT @SQLError = @@ERROR

IF @SQLError <> 0 GOTO FatalError



IF @debug_flag = 1 

  INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)

  VALUES (@id_run, 'Debug', 'InsertInvoice: Begin Insert into t_invoice', getutcdate()) 



-- Save all the invoice data to the t_invoice table

INSERT INTO t_invoice

  (namespace,

  invoice_string, 

  id_interval,

  id_acc, 

  invoice_amount, 

  invoice_date, 

  invoice_due_date, 

  id_invoice_num,

  invoice_currency,

  payment_ttl_amt,

  postbill_adj_ttl_amt,

  ar_adj_ttl_amt,

  tax_ttl_amt,

  current_balance,

  id_payer,

  id_payer_interval,

  sample_flag,

  balance_forward_date)

 SELECT

  #tmp_acc_amounts.namespace,

  tmpin.invoice_string, -- from the stored proc as below

  @id_interval,

  #tmp_acc_amounts.id_acc,

 current_charges

  + ISNULL(#tmp_adjustments.PrebillAdjustmentAmount,0)

  + tax_ttl_amt,  -- invoice_amount = current_charges + prebill adjustments + taxes, 

  @invoice_date invoice_date, 

  tmpin.invoice_due_date, -- from the stored proc as @invoice_date+@invoice_due_date_offset   invoice_due_date,

  tmpin.id_invoice_num, -- from the stored proc as tmp_seq + @invoice_number - 1,

  invoice_currency,

  payment_ttl_amt, -- payment_ttl_amt

  CASE WHEN #tmp_adjustments.PostbillAdjustmentAmount IS NULL THEN 0.0 ELSE #tmp_adjustments.PostbillAdjustmentAmount END, -- postbill_adj_ttl_amt

  ar_adj_ttl_amt, -- ar_adj_ttl_amt

  tax_ttl_amt, -- tax_ttl_amt  

  current_charges + tax_ttl_amt + ar_adj_ttl_amt 

	+ ISNULL(#tmp_adjustments.PostbillAdjustmentAmount, 0.0)

        + payment_ttl_amt

	+ ISNULL(#tmp_prev_balance.previous_balance, 0.0)

	+ ISNULL (#tmp_adjustments.PrebillAdjustmentAmount, 0.0), -- current_balance 

  id_payer, -- id_payer

  CASE WHEN #tmp_acc_amounts.id_payer_interval IS NULL THEN @id_interval ELSE #tmp_acc_amounts.id_payer_interval END, -- id_payer_interval

  @is_sample sample_flag,

  ui.dt_end -- balance_forward_date

FROM #tmp_acc_amounts

INNER JOIN #tmp_invoicenumber tmpin ON tmpin.id_acc = #tmp_acc_amounts.id_acc

LEFT OUTER JOIN #tmp_prev_balance ON #tmp_prev_balance.id_acc = #tmp_acc_amounts.id_acc

LEFT OUTER JOIN #tmp_adjustments ON #tmp_adjustments.id_acc = #tmp_acc_amounts.id_acc

INNER JOIN t_usage_interval ui ON ui.id_interval = @id_interval

INNER JOIN t_av_internal avi ON avi.id_acc = #tmp_acc_amounts.id_acc



SET @num_invoices = @@ROWCOUNT



SELECT @SQLError = @@ERROR

IF @SQLError <> 0 GOTO FatalError



-- Store the invoice range data to the t_invoice_range table

SELECT @cnt = MAX(tmp_seq)

FROM #tmp_acc_amounts

SELECT @SQLError = @@ERROR

IF @SQLError <> 0 GOTO FatalError



IF @cnt IS NOT NULL

BEGIN

  --insert info about the current run into the t_invoice_range table

  INSERT INTO t_invoice_range (id_interval, namespace, id_invoice_num_first, id_invoice_num_last)

  SELECT id_interval, namespace, ISNULL(min(id_invoice_num),0), ISNULL(max(id_invoice_num),0)

  FROM t_invoice

  WHERE id_interval = @id_interval

  GROUP BY id_interval, namespace

  --update the id_invoice_num_last in the t_invoice_namespace table

  UPDATE t_invoice_namespace

  SET t_invoice_namespace.id_invoice_num_last = 

	(SELECT ISNULL(max(t_invoice.id_invoice_num),0)

	FROM t_invoice

  	WHERE t_invoice_namespace.namespace = t_invoice.namespace AND

	t_invoice.id_interval = @id_interval)

  SELECT @SQLError = @@ERROR

  IF @SQLError <> 0 GOTO FatalError

END

ELSE  SET @cnt = 0



DROP TABLE #tmp_acc_amounts

DROP TABLE #tmp_prev_balance

DROP TABLE #tmp_invoicenumber

DROP TABLE #tmp_adjustments



IF @debug_flag = 1 

  INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)

   VALUES (@id_run, 'Debug', 'InsertInvoice: Completed successfully', getutcdate())

   

SET @return_code = 0

RETURN 0



SkipReturn:

  IF @ErrMsg IS NULL 

    SET @ErrMsg = 'InsertInvoice: Process skipped'

  IF @debug_flag = 1 

    INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)

      VALUES (@id_run, 'Debug', @ErrMsg, getutcdate()) 

  SET @return_code = 0

  RETURN 0



FatalError:

  IF @ErrMsg IS NULL 

    SET @ErrMsg = 'InsertInvoice: Adapter stored procedure failed'

  IF @debug_flag = 1 

    INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)

      VALUES (@id_run, 'Debug', @ErrMsg, getutcdate()) 

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


     

-- populates #tmp_acc_amounts, #tmp_prev_balance, #tmp_adjustments for a given @id_interval

-- used by MTSP_INSERTINVOICE and __GET_NON_BILLABLE_ACCOUNTS_WITH_BALANCE__

CREATE   PROCEDURE MTSP_INSERTINVOICE_BALANCES

@id_interval int,

@exclude_billable char, -- 'Y' to only return non-billable accounts, 'N' to return all accounts

@id_run int,

@return_code int OUTPUT

AS

BEGIN

DECLARE 

@debug_flag bit,

@SQLError int,

@ErrMsg varchar(200)

SET NOCOUNT ON

SET @debug_flag = 1 -- yes

--SET @debug_flag = 0 -- no



-- Create the driver table with all id_accs

CREATE TABLE #tmp_all_accounts

(id_acc int NOT NULL)



SELECT @SQLError = @@ERROR

IF @SQLError <> 0 GOTO FatalError



-- populate the driver table with account ids 

INSERT INTO #tmp_all_accounts

   (id_acc)

SELECT DISTINCT

   id_acc

	FROM t_acc_usage 

	WHERE id_usage_interval = @id_interval



UNION



SELECT DISTINCT

   id_acc

	FROM vw_adjustment_summary

	WHERE vw_adjustment_summary.id_usage_interval = @id_interval



UNION



--The convoluted logic below is to find the latest current balance for the account.  This may

--not be the previous interval, as the invoice adapter may not have been run

--for certain intervals.  Won't happen in production, but I encountered this

--a lot while testing.

SELECT DISTINCT

  id_acc

FROM

	(SELECT inv.id_acc, 

	ISNULL(MAX(CONVERT(CHAR(8),ui.dt_end,112)+

	REPLICATE('0',20-LEN(inv.current_balance)) + 

	CONVERT(CHAR,inv.current_balance)),'00000000000') comp

	FROM t_invoice inv

	INNER JOIN t_usage_interval ui 

	ON ui.id_interval = inv.id_interval

	GROUP BY inv.id_acc) latestinv

WHERE 

CONVERT(DECIMAL(18,6), SUBSTRING(comp,CASE WHEN PATINDEX('%-%',comp) = 0 THEN 10 ELSE PATINDEX('%-%',comp) END,28)) <> 0



SELECT @SQLError = @@ERROR

IF @SQLError <> 0 GOTO FatalError



-- populate #tmp_acc_amounts with accounts and their invoice amounts

IF (@debug_flag = 1 and @id_run IS NOT NULL)

  INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)

    VALUES (@id_run, 'Debug', 'Invoice-Bal: Begin inserting to the #tmp_acc_amounts table', getutcdate()) 





INSERT INTO #tmp_acc_amounts
  (namespace,

  id_interval,

  id_acc,

  invoice_currency,

  payment_ttl_amt,

  postbill_adj_ttl_amt,

  ar_adj_ttl_amt,

  previous_balance,

  tax_ttl_amt,

  current_charges,

  id_payer,

  id_payer_interval

)

SELECT

  RTRIM(ammps.nm_space) namespace,

  au.id_usage_interval id_interval, 

  ammps.id_acc, 

  avi.c_currency invoice_currency, 

  SUM(CASE WHEN pvpay.id_sess IS NULL THEN 0 ELSE ISNULL(au.amount,0) END) payment_ttl_amt,

  0, --postbill_adj_ttl_amt

  SUM(CASE WHEN pvar.id_sess IS NULL THEN 0 ELSE ISNULL(au.amount,0) END) ar_adj_ttl_amt,

  0, --previous_balance

  SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL) THEN 

	(ISNULL(au.Tax_Federal,0.0)) ELSE 0 END) + 

   SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL) THEN

	(ISNULL(au.Tax_State,0.0))ELSE 0 END) +

   SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL) THEN 

	(ISNULL(au.Tax_County,0.0))ELSE 0 END) +

   SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL) THEN 

	(ISNULL(au.Tax_Local,0.0))ELSE 0 END) +

   SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL) THEN

	(ISNULL(au.Tax_Other,0.0))ELSE 0 END) tax_ttl_amt,

  SUM(CASE WHEN (pvpay.id_sess IS NULL AND pvar.id_sess IS NULL AND NOT vh.id_view IS NULL) THEN (ISNULL(au.Amount, 0.0)) ELSE 0 END) current_charges, 

  CASE WHEN avi.c_billable = '0' THEN pr.id_payer ELSE ammps.id_acc END id_payer,

  CASE WHEN avi.c_billable = '0' THEN auipay.id_usage_interval ELSE au.id_usage_interval END id_payer_interval

FROM  #tmp_all_accounts tmpall

INNER JOIN t_av_internal avi ON avi.id_acc = tmpall.id_acc

INNER JOIN t_account_mapper ammps ON ammps.id_acc = tmpall.id_acc

INNER JOIN t_namespace ns ON ns.nm_space = ammps.nm_space

	AND ns.tx_typ_space = 'system_mps'

INNER join t_acc_usage_interval aui ON aui.id_acc = tmpall.id_acc

INNER join t_usage_interval ui ON aui.id_usage_interval = ui.id_interval

	AND ui.id_interval = @id_interval

INNER join t_payment_redirection pr ON tmpall.id_acc = pr.id_payee

	AND ui.dt_end BETWEEN pr.vt_start AND pr.vt_end

INNER join t_acc_usage_interval auipay ON auipay.id_acc = pr.id_payer

INNER join t_usage_interval uipay ON auipay.id_usage_interval = uipay.id_interval

        AND ui.dt_end BETWEEN CASE WHEN auipay.dt_effective IS NULL THEN uipay.dt_start ELSE dateadd(s, 1, auipay.dt_effective) END AND uipay.dt_end



LEFT OUTER JOIN 

(SELECT au1.id_usage_interval, au1.amount, au1.Tax_Federal, au1.Tax_State, au1.Tax_County, au1.Tax_Local, au1.Tax_Other, au1.id_sess, au1.id_acc, au1.id_view

FROM t_acc_usage au1

LEFT OUTER JOIN t_pi_template piTemplated2 

ON piTemplated2.id_template=au1.id_pi_template

LEFT OUTER JOIN t_base_props pi_type_props ON pi_type_props.id_prop=piTemplated2.id_pi

LEFT OUTER JOIN t_enum_data enumd2 ON au1.id_view=enumd2.id_enum_data

AND (pi_type_props.n_kind IS NULL or pi_type_props.n_kind <> 15 or upper(enumd2.nm_enum_data) NOT LIKE '%_TEMP')



WHERE au1.id_parent_sess is NULL

AND au1.id_usage_interval = @id_interval

AND ((au1.id_pi_template is null and au1.id_parent_sess is null) or (au1.id_pi_template is not null and piTemplated2.id_template_parent is null))

) au ON



	au.id_acc = tmpall.id_acc

-- join with the tables used for calculating the sums

LEFT OUTER JOIN t_view_hierarchy vh 

	ON au.id_view = vh.id_view

	AND vh.id_view = vh.id_view_parent

LEFT OUTER JOIN t_pv_aradjustment pvar ON pvar.id_sess = au.id_sess

LEFT OUTER JOIN t_pv_payment pvpay ON pvpay.id_sess = au.id_sess

-- non-join conditions

WHERE 

(@exclude_billable = '0' OR avi.c_billable = '0')

GROUP BY ammps.nm_space, ammps.id_acc, au.id_usage_interval, avi.c_currency, pr.id_payer, auipay.id_usage_interval, avi.c_billable





SELECT @SQLError = @@ERROR

IF @SQLError <> 0 GOTO FatalError

---------------------------------------------------------------





-- populate #tmp_prev_balance with the previous balance

INSERT INTO #tmp_prev_balance

  (id_acc,

  previous_balance)

SELECT id_acc, CONVERT(DECIMAL(18,6), SUBSTRING(comp,CASE WHEN PATINDEX('%-%',comp) = 0 THEN 10 ELSE PATINDEX('%-%',comp) END,28)) previous_balance

FROM 	(SELECT inv.id_acc, 

ISNULL(MAX(CONVERT(CHAR(8),ui.dt_end,112)+

			REPLICATE('0',20-LEN(inv.current_balance)) + 

			CONVERT(CHAR,inv.current_balance)),'00000000000') comp

	FROM t_invoice inv

	INNER JOIN t_usage_interval ui ON ui.id_interval = inv.id_interval

	INNER JOIN #tmp_all_accounts ON inv.id_acc = #tmp_all_accounts.id_acc

	GROUP BY inv.id_acc) maxdtend



SELECT @SQLError = @@ERROR

IF @SQLError <> 0 GOTO FatalError



-- populate #tmp_adjustments with postbill and prebill adjustments

INSERT INTO #tmp_adjustments

 ( id_acc,

   PrebillAdjustmentAmount,

   PostbillAdjustmentAmount

 )

select ISNULL(adjtrx.id_acc, #tmp_all_accounts.id_acc) id_acc, ISNULL(PrebillAdjustmentAmount, 0) PrebillAdjustmentAmount, ISNULL(PostbillAdjustmentAmount, 0) PostbillAdjustmentAmount

  from vw_adjustment_summary adjtrx FULL OUTER JOIN #tmp_all_accounts ON adjtrx.id_acc = #tmp_all_accounts.id_acc

  where adjtrx.id_usage_interval = @id_interval



SELECT @SQLError = @@ERROR

IF @SQLError <> 0 GOTO FatalError



drop table #tmp_all_accounts



IF (@debug_flag = 1  and @id_run IS NOT NULL)

  INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)

    VALUES (@id_run, 'Debug', 'Invoice-Bal: Completed successfully', getutcdate()) 



SET @return_code = 0



RETURN 0



FatalError:

  IF @ErrMsg IS NULL 

    SET @ErrMsg = 'Invoice-Bal: Stored procedure failed'

  IF (@debug_flag = 1  and @id_run IS NOT NULL)

    INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)

      VALUES (@id_run, 'Debug', @ErrMsg, getutcdate()) 



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


			

CREATE PROCEDURE MTSP_INSERTINVOICE_DEFLTINVNUM

@invoice_date DATETIME

AS

BEGIN

SELECT 

	tmp.id_acc,

	tmp.namespace,

	tins.invoice_prefix

	 + ISNULL(REPLICATE('0', tins.invoice_num_digits - LEN(RTRIM(CONVERT(nvarchar,tmp.tmp_seq + tins.id_invoice_num_last + 1 - 1)))),'')

	 + RTRIM(CONVERT(nvarchar,tmp_seq + tins.id_invoice_num_last + 1 - 1))

	 + tins.invoice_suffix,

	@invoice_date+tins.invoice_due_date_offset,

	tmp.tmp_seq + tins.id_invoice_num_last

FROM #tmp_acc_amounts tmp

INNER JOIN t_invoice_namespace tins ON tins.namespace = tmp.namespace

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




CREATE PROCEDURE MTSP_RATE_AGGREGATE_CHARGE

@input_RUN_ID int,

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

** 

** Last Modified On: 02/19/2003

** Last Modified On: 01/21/2003

** Last Modified On: 01/08/2003

** Last Modified On: 01/02/2003

** Last Modified On: 12/10/2002

** Last Modified On: 11/18/2002

** Last Modified On: 11/14/2002

** Last Modified On: 10/31/2002

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

@SQLError int,



-- the following are added on 11/11/2002

-- I tried a number of ways to implement the performance change. Based on the testing 

-- results of 3 versions of the implementations, both feature flexibility and script flexibility 

-- (like using table variables) have processing cost associated with them. Since the purpose of 

-- the coding change is to improve the performance, I thus decide to use the version 

-- SPAggRate_OK_listed20.sql which provides the best performance improvement among the three new 

-- versions. This stored procedure contains this version.

@max_loop_cnt int,

-- used to accumulate the counter values (SUM)

@countable_0 numeric(18,6),

@countable_1 numeric(18,6),

@countable_2 numeric(18,6),

@countable_3 numeric(18,6),

@countable_4 numeric(18,6),

@countable_5 numeric(18,6),

@countable_6 numeric(18,6),

@countable_7 numeric(18,6),

@countable_8 numeric(18,6),

@countable_9 numeric(18,6),

@countable_10 numeric(18,6),

@countable_11 numeric(18,6),

@countable_12 numeric(18,6),

@countable_13 numeric(18,6),

@countable_14 numeric(18,6),

@countable_15 numeric(18,6),

@countable_16 numeric(18,6),

@countable_17 numeric(18,6),

@countable_18 numeric(18,6),

@countable_19 numeric(18,6),

-- use to count the number of records (COUNT)

@rec_count_0 int,

@rec_count_1 int,

@rec_count_2 int,

@rec_count_3 int,

@rec_count_4 int,

@rec_count_5 int,

@rec_count_6 int,

@rec_count_7 int,

@rec_count_8 int,

@rec_count_9 int,

@rec_count_10 int,

@rec_count_11 int,

@rec_count_12 int,

@rec_count_13 int,

@rec_count_14 int,

@rec_count_15 int,

@rec_count_16 int,

@rec_count_17 int,

@rec_count_18 int,

@rec_count_19 int,



@work_counter_formulas varchar(500),

@work_counter varchar(500),

@loop_index int,

@as_index int,

@comma_index int,

-- store the parsed counter formula

@countable_formula_0 varchar(500),

@countable_formula_1 varchar(500),

@countable_formula_2 varchar(500),

@countable_formula_3 varchar(500),

@countable_formula_4 varchar(500),

@countable_formula_5 varchar(500),

@countable_formula_6 varchar(500),

@countable_formula_7 varchar(500),

@countable_formula_8 varchar(500),

@countable_formula_9 varchar(500),

@countable_formula_10 varchar(500),

@countable_formula_11 varchar(500),

@countable_formula_12 varchar(500),

@countable_formula_13 varchar(500),

@countable_formula_14 varchar(500),

@countable_formula_15 varchar(500),

@countable_formula_16 varchar(500),

@countable_formula_17 varchar(500),

@countable_formula_18 varchar(500),

@countable_formula_19 varchar(500),

-- store the actual value of the calculated formula

@countable_formula_value_0 numeric(18,6),

@countable_formula_value_1 numeric(18,6),

@countable_formula_value_2 numeric(18,6),

@countable_formula_value_3 numeric(18,6),

@countable_formula_value_4 numeric(18,6),

@countable_formula_value_5 numeric(18,6),

@countable_formula_value_6 numeric(18,6),

@countable_formula_value_7 numeric(18,6),

@countable_formula_value_8 numeric(18,6),

@countable_formula_value_9 numeric(18,6),

@countable_formula_value_10 numeric(18,6),

@countable_formula_value_11 numeric(18,6),

@countable_formula_value_12 numeric(18,6),

@countable_formula_value_13 numeric(18,6),

@countable_formula_value_14 numeric(18,6),

@countable_formula_value_15 numeric(18,6),

@countable_formula_value_16 numeric(18,6),

@countable_formula_value_17 numeric(18,6),

@countable_formula_value_18 numeric(18,6),

@countable_formula_value_19 numeric(18,6),

-- store the parsed field names which will be used to create the "temp" table

@counter_resultfieldname_0 varchar(500),

@counter_resultfieldname_1 varchar(500),

@counter_resultfieldname_2 varchar(500),

@counter_resultfieldname_3 varchar(500),

@counter_resultfieldname_4 varchar(500),

@counter_resultfieldname_5 varchar(500),

@counter_resultfieldname_6 varchar(500),

@counter_resultfieldname_7 varchar(500),

@counter_resultfieldname_8 varchar(500),

@counter_resultfieldname_9 varchar(500),

@counter_resultfieldname_10 varchar(500),

@counter_resultfieldname_11 varchar(500),

@counter_resultfieldname_12 varchar(500),

@counter_resultfieldname_13 varchar(500),

@counter_resultfieldname_14 varchar(500),

@counter_resultfieldname_15 varchar(500),

@counter_resultfieldname_16 varchar(500),

@counter_resultfieldname_17 varchar(500),

@counter_resultfieldname_18 varchar(500),

@counter_resultfieldname_19 varchar(500),



@countable_count int,

@formula_count int, -- added on 12/10/2002

@insert_count int



-- added on 12/31/2002

DECLARE

@cur_id_pass int,

@cur_id_sess int,

@cur_id_acc int,

@cur_group_acc_flag tinyint,

@cur_group_acc_id int,

@cur_pci_id_interval int,

@cur_dt_session datetime,

@cur_ui_dt_start datetime,

@cur_ui_dt_end datetime,

@cur_pci_dt_start datetime,

@cur_pci_dt_end datetime,

@cur_countable_0 numeric(18,6),

@cur_countable_1 numeric(18,6),

@cur_countable_2 numeric(18,6),

@cur_countable_3 numeric(18,6),

@cur_countable_4 numeric(18,6),

@cur_countable_5 numeric(18,6),

@cur_countable_6 numeric(18,6),

@cur_countable_7 numeric(18,6),

@cur_countable_8 numeric(18,6),

@cur_countable_9 numeric(18,6),

@cur_countable_10 numeric(18,6),

@cur_countable_11 numeric(18,6),

@cur_countable_12 numeric(18,6),

@cur_countable_13 numeric(18,6),

@cur_countable_14 numeric(18,6),

@cur_countable_15 numeric(18,6),

@cur_countable_16 numeric(18,6),

@cur_countable_17 numeric(18,6),

@cur_countable_18 numeric(18,6),

@cur_countable_19 numeric(18,6),

@pre_group_acc_flag tinyint,

@pre_group_acc_id int,

@pre_pci_id_interval int,

@FetchStatusCalc int



SET NOCOUNT ON

SET @debug_flag = 1



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

IF @debug_flag = 1 AND @input_RUN_ID IS NOT NULL

BEGIN

  INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)

  VALUES (@input_RUN_ID, 'Debug', 'Finished selecting from the t_usage_interval table', getutcdate())  

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



SELECT @ag_dt_start = MIN(pci.dt_start)

FROM #tmp1 tmp1

	LEFT OUTER JOIN t_pc_interval pci ON pci.id_cycle = ISNULL(tmp1.id_pc_cycle,tmp1.id_usage_cycle)

		AND tmp1.dt_session BETWEEN pci.dt_start AND pci.dt_end 

SELECT @SQLError = @@ERROR

IF @SQLError <> 0 GOTO FatalError



DROP TABLE #tmp1

SELECT @SQLError = @@ERROR

IF @SQLError <> 0 GOTO FatalError

IF @debug_flag = 1 AND @input_RUN_ID IS NOT NULL

BEGIN

  INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)

  VALUES (@input_RUN_ID, 'Debug', 'Finished selecting the minimum pci.dt_start', getutcdate())  

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

N'@dinput_FIRST_PASS_PV_VIEWID int, @dinput_id_usage_interval int,@dinput_TEMPLATE_ID int, @dau_bc_dt_end datetime, @dag_dt_start datetime',

@input_FIRST_PASS_PV_VIEWID, @input_USAGE_INTERVAL, @input_TEMPLATE_ID, @au_bc_dt_end, @ag_dt_start

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

	pci.dt_start pci_dt_start,

	pci.dt_end pci_dt_end,

	pci.id_interval pci_id_interval,

	tmp.group_acc_flag,

	tmp.group_acc_id

INTO ' + CAST(@tmp_tbl_name1 AS nvarchar(50)) + N' 

FROM ' + CAST(@tmp_tbl_name12 AS nvarchar(50)) + N' tmp 

	LEFT OUTER JOIN t_pc_interval pci ON pci.id_cycle = ISNULL(tmp.pci_id_cycle,tmp.ui_id_cycle)

		AND tmp.dt_session BETWEEN pci.dt_start AND pci.dt_end '

--PRINT @SQLStmt

EXEC sp_executesql @SQLStmt

SELECT @SQLError = @@ERROR

IF @SQLError <> 0 GOTO FatalError



IF @debug_flag = 1 AND @input_RUN_ID IS NOT NULL

BEGIN

  INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)

  VALUES (@input_RUN_ID, 'Debug', 'Finished inserting into the temp1 table', getutcdate())

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

	pci.id_interval pci_id_interval,

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

	(SELECT DISTINCT pci_id_interval FROM ' + CAST(@tmp_tbl_name1 AS nvarchar(50)) 

	+ N' ) agi,

	t_pc_interval pci

WHERE

	au.id_view IS NULL AND

	ui.id_interval = au.id_usage_interval AND

	au.dt_session BETWEEN @dag_dt_start AND @dau_bc_dt_end AND

	pci.id_interval = agi.pci_id_interval AND 

	au.dt_session BETWEEN pci.dt_start AND pci.dt_end '

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

	pci.id_interval pci_id_interval,

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

	(SELECT DISTINCT pci_id_interval FROM ' + CAST(@tmp_tbl_name1 AS nvarchar(50)) 

	+ N' ) agi,

	t_pc_interval pci

WHERE

	(au.id_view IS NULL OR au.id_view in (' + CAST(@input_COUNTABLE_VIEWIDS AS nvarchar(2000)) + N')) AND

	ui.id_interval = au.id_usage_interval AND

	au.dt_session BETWEEN @dag_dt_start AND @dau_bc_dt_end AND

	pci.id_interval = agi.pci_id_interval AND 

	au.dt_session BETWEEN pci.dt_start AND pci.dt_end '

	+ CAST(@input_ACCOUNT_FILTER AS nvarchar(2000)) 

END

--PRINT @SQLStmt

EXEC sp_executesql @SQLStmt,

N'@dau_bc_dt_end datetime, @dag_dt_start datetime',

@au_bc_dt_end, @ag_dt_start



SELECT @SQLError = @@ERROR

IF @SQLError <> 0 GOTO FatalError

IF @debug_flag = 1 AND @input_RUN_ID IS NOT NULL

BEGIN

  INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)

  VALUES (@input_RUN_ID, 'Debug', 'Finished inserting into the temp2 table', getutcdate())

	SELECT @SQLError = @@ERROR

	IF @SQLError <> 0 GOTO FatalError

END

--PRINT 'completed: to obtain the counter records'

--PRINT CONVERT(char, getdate(), 109)



----------------------------------------------------------------

-- Calculate the counters

----------------------------------------------------------------

-- 11/11/2002

-- Check to see which method to use to calculate the counters

SET @max_loop_cnt = 0

SET @SQLStmt =

N'SELECT @max_loop_cnt = MAX(cnt) FROM '

+ N'(SELECT COUNT(*) cnt FROM ' + CAST(@tmp_tbl_name2 AS nvarchar(50))

+ N' GROUP BY group_acc_flag, group_acc_id) tmptbl'

--PRINT @SQLStmt

EXEC sp_executesql @SQLStmt,

	N'@max_loop_cnt int OUTPUT',

	@max_loop_cnt = @max_loop_cnt OUTPUT



SELECT @SQLError = @@ERROR

IF @SQLError <> 0 GOTO FatalError



IF @input_COUNTER_FORMULAS IS NULL 

   OR @input_COUNTER_FORMULAS = ''

   OR @max_loop_cnt IS NULL 

-- 1/2/2003 Always use the linear approach.

-- Uncomment the following line if want to use either the selfjoin or the linear approach 

-- depending on the data volume.

--   OR @max_loop_cnt <= 1000

-- Use the selfjoin approach

BEGIN

SET @SQLStmt = ''

SET @SQLStmt = 

N'SELECT tp1.id_sess ' + @input_COUNTER_FORMULAS + N' 

INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) 

+ N' FROM ' + CAST(@tmp_tbl_name1 AS nvarchar(50)) 

+ N' tp1 LEFT OUTER JOIN ' + CAST(@tmp_tbl_name2 AS nvarchar(50)) 

+ N' tp2 ON tp2.group_acc_flag = tp1.group_acc_flag AND tp2.group_acc_id = tp1.group_acc_id

	AND tp2.dt_session BETWEEN tp1.pci_dt_start AND tp1.pci_dt_end

	AND (tp2.ui_dt_end < tp1.ui_dt_end 

		OR (tp2.ui_dt_end = tp1.ui_dt_end 

		AND tp2.dt_session < tp1.dt_session)

		OR (tp2.ui_dt_end = tp1.ui_dt_end 

		AND tp2.dt_session = tp1.dt_session 

		AND tp2.id_sess < tp1.id_sess))

GROUP BY tp1.id_sess'



EXEC sp_executesql @SQLStmt

SELECT @SQLError = @@ERROR

IF @SQLError <> 0 GOTO FatalError

IF @debug_flag = 1 AND @input_RUN_ID IS NOT NULL

BEGIN

  INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)

  VALUES (@input_RUN_ID, 'Debug', 'Finished inserting into the temp3 table', getutcdate())

	SELECT @SQLError = @@ERROR

	IF @SQLError <> 0 GOTO FatalError

END

END -- End of the selfjoin approach

ELSE

-- Use the linear approach

BEGIN

SET @countable_0 = 0

SET @countable_1 = 0

SET @countable_2 = 0

SET @countable_3 = 0

SET @countable_4 = 0

SET @countable_5 = 0

SET @countable_6 = 0

SET @countable_7 = 0

SET @countable_8 = 0

SET @countable_9 = 0

SET @countable_10 = 0

SET @countable_11 = 0

SET @countable_12 = 0

SET @countable_13 = 0

SET @countable_14 = 0

SET @countable_15 = 0

SET @countable_16 = 0

SET @countable_17 = 0

SET @countable_18 = 0

SET @countable_19 = 0



SET @rec_count_0 = 0

SET @rec_count_1 = 0

SET @rec_count_2 = 0

SET @rec_count_3 = 0

SET @rec_count_4 = 0

SET @rec_count_5 = 0

SET @rec_count_6 = 0

SET @rec_count_7 = 0

SET @rec_count_8 = 0

SET @rec_count_9 = 0

SET @rec_count_10 = 0

SET @rec_count_11 = 0

SET @rec_count_12 = 0

SET @rec_count_13 = 0

SET @rec_count_14 = 0

SET @rec_count_15 = 0

SET @rec_count_16 = 0

SET @rec_count_17 = 0

SET @rec_count_18 = 0

SET @rec_count_19 = 0



SET @countable_count = LEN(RTRIM(@input_COUNTABLE_PROPERTIES)) - LEN(RTRIM(REPLACE(@input_COUNTABLE_PROPERTIES, ',' , '')))

--PRINT @countable_count

SET @formula_count = LEN(RTRIM(@input_COUNTER_FORMULAS_ALIASES)) - LEN(RTRIM(REPLACE(@input_COUNTER_FORMULAS_ALIASES, ',' , '')))

--PRINT @formula_count



-- Parse the @input_COUNTER_FORMULAS string to obtain the "temp" table column names

SET @work_counter_formulas = @input_COUNTER_FORMULAS

-- remove the leading comma and add the trailing comma

SET @work_counter_formulas = SUBSTRING(@work_counter_formulas,3,LEN(@work_counter_formulas)) + ', '

-- remove the ISNULL

SET @work_counter_formulas = REPLACE(REPLACE(@work_counter_formulas, 'ISNULL(', ''), ', 0)', '')



SET @loop_index = -1

WHILE LEN(@work_counter_formulas) > 0

BEGIN

	SET @loop_index = @loop_index + 1

	SET @as_index = PATINDEX('% AS %', @work_counter_formulas)

	SET @comma_index = PATINDEX('%, %', @work_counter_formulas)

	IF @loop_index = 0

	BEGIN

		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)

		SET @counter_resultfieldname_0 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)



		IF PATINDEX('%(SUM(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_0 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')

		END

		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_0 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')

		END

		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_0 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')

			SET @countable_formula_0 = REPLACE(@countable_formula_0, 'countable_', '@countable_')

				+ '/' + REPLACE(@countable_formula_0, 'countable_', '@rec_count_')

		END

	END

	ELSE IF @loop_index = 1

	BEGIN

		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)

		SET @counter_resultfieldname_1 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)



		IF PATINDEX('%(SUM(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_1 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')

		END

		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_1 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')

		END

		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_1 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')

			SET @countable_formula_1 = REPLACE(@countable_formula_1, 'countable_', '@countable_')

				+ '/' + REPLACE(@countable_formula_1, 'countable_', '@rec_count_')

		END

	END

	ELSE IF @loop_index = 2

	BEGIN

		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)

		SET @counter_resultfieldname_2 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)



		IF PATINDEX('%(SUM(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_2 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')

		END

		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_2 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')

		END

		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_2 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')

			SET @countable_formula_2 = REPLACE(@countable_formula_2, 'countable_', '@countable_')

				+ '/' + REPLACE(@countable_formula_2, 'countable_', '@rec_count_')

		END

	END

	ELSE IF @loop_index = 3

	BEGIN

		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)

		SET @counter_resultfieldname_3 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)



		IF PATINDEX('%(SUM(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_3 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')

		END

		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_3 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')

		END

		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_3 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')

			SET @countable_formula_3 = REPLACE(@countable_formula_3, 'countable_', '@countable_')

				+ '/' + REPLACE(@countable_formula_3, 'countable_', '@rec_count_')

		END

	END

	ELSE IF @loop_index = 4

	BEGIN

		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)

		SET @counter_resultfieldname_4 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)



		IF PATINDEX('%(SUM(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_4 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')

		END

		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_4 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')

		END

		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_4 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')

			SET @countable_formula_4 = REPLACE(@countable_formula_4, 'countable_', '@countable_')

				+ '/' + REPLACE(@countable_formula_4, 'countable_', '@rec_count_')

		END

	END

	ELSE IF @loop_index = 5

	BEGIN

		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)

		SET @counter_resultfieldname_5 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)



		IF PATINDEX('%(SUM(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_5 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')

		END

		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_5 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')

		END

		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_5 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')

			SET @countable_formula_5 = REPLACE(@countable_formula_5, 'countable_', '@countable_')

				+ '/' + REPLACE(@countable_formula_5, 'countable_', '@rec_count_')

		END

	END

	ELSE IF @loop_index = 6

	BEGIN

		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)

		SET @counter_resultfieldname_6 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)



		IF PATINDEX('%(SUM(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_6 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')

		END

		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_6 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')

		END

		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_6 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')

			SET @countable_formula_6 = REPLACE(@countable_formula_6, 'countable_', '@countable_')

				+ '/' + REPLACE(@countable_formula_6, 'countable_', '@rec_count_')

		END

	END

	ELSE IF @loop_index = 7

	BEGIN

		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)

		SET @counter_resultfieldname_7 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)



		IF PATINDEX('%(SUM(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_7 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')

		END

		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_7 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')

		END

		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_7 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')

			SET @countable_formula_7 = REPLACE(@countable_formula_7, 'countable_', '@countable_')

				+ '/' + REPLACE(@countable_formula_7, 'countable_', '@rec_count_')

		END

	END

	ELSE IF @loop_index = 8

	BEGIN

		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)

		SET @counter_resultfieldname_8 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)



		IF PATINDEX('%(SUM(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_8 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')

		END

		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_8 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')

		END

		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_8 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')

			SET @countable_formula_8 = REPLACE(@countable_formula_8, 'countable_', '@countable_')

				+ '/' + REPLACE(@countable_formula_8, 'countable_', '@rec_count_')

		END

	END

	ELSE IF @loop_index = 9

	BEGIN

		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)

		SET @counter_resultfieldname_9 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)



		IF PATINDEX('%(SUM(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_9 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')
		END

		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_9 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')

		END

		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_9 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')

			SET @countable_formula_9 = REPLACE(@countable_formula_9, 'countable_', '@countable_')

				+ '/' + REPLACE(@countable_formula_9, 'countable_', '@rec_count_')

		END

	END

	ELSE IF @loop_index = 10

	BEGIN

		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)

		SET @counter_resultfieldname_10 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)



		IF PATINDEX('%(SUM(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_10 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')

		END

		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_10 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')
		END

		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_10 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')

			SET @countable_formula_10 = REPLACE(@countable_formula_10, 'countable_', '@countable_')

				+ '/' + REPLACE(@countable_formula_10, 'countable_', '@rec_count_')

		END

	END

	ELSE IF @loop_index = 11

	BEGIN

		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)

		SET @counter_resultfieldname_11 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)



		IF PATINDEX('%(SUM(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_11 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')

		END

		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_11 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')

		END

		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_11 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')

			SET @countable_formula_11 = REPLACE(@countable_formula_11, 'countable_', '@countable_')

				+ '/' + REPLACE(@countable_formula_11, 'countable_', '@rec_count_')

		END

	END

	ELSE IF @loop_index = 12

	BEGIN

		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)

		SET @counter_resultfieldname_12 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)



		IF PATINDEX('%(SUM(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_12 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')

		END

		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_12 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')

		END

		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_12 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')

			SET @countable_formula_12 = REPLACE(@countable_formula_12, 'countable_', '@countable_')

				+ '/' + REPLACE(@countable_formula_12, 'countable_', '@rec_count_')

		END

	END

	ELSE IF @loop_index = 13

	BEGIN

		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)

		SET @counter_resultfieldname_13 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)



		IF PATINDEX('%(SUM(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_13 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')

		END

		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_13 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')

		END

		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_13 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')

			SET @countable_formula_13 = REPLACE(@countable_formula_13, 'countable_', '@countable_')

				+ '/' + REPLACE(@countable_formula_13, 'countable_', '@rec_count_')

		END

	END

	ELSE IF @loop_index = 14

	BEGIN

		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)

		SET @counter_resultfieldname_14 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)



		IF PATINDEX('%(SUM(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_14 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')

		END

		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_14 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')

		END

		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_14 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')

			SET @countable_formula_14 = REPLACE(@countable_formula_14, 'countable_', '@countable_')

				+ '/' + REPLACE(@countable_formula_14, 'countable_', '@rec_count_')

		END

	END

	ELSE IF @loop_index = 15

	BEGIN

		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)

		SET @counter_resultfieldname_15 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)



		IF PATINDEX('%(SUM(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_15 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')

		END

		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_15 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')

		END

		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_15 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')

			SET @countable_formula_15 = REPLACE(@countable_formula_15, 'countable_', '@countable_')

				+ '/' + REPLACE(@countable_formula_15, 'countable_', '@rec_count_')

		END

	END

	ELSE IF @loop_index = 16
	BEGIN

		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)

		SET @counter_resultfieldname_16 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)



		IF PATINDEX('%(SUM(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_16 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')

		END

		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_16 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')

		END

		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_16 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')

			SET @countable_formula_16 = REPLACE(@countable_formula_16, 'countable_', '@countable_')

				+ '/' + REPLACE(@countable_formula_16, 'countable_', '@rec_count_')

		END

	END

	ELSE IF @loop_index = 17

	BEGIN

		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)

		SET @counter_resultfieldname_17 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)



		IF PATINDEX('%(SUM(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_17 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')

		END

		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_17 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')

		END

		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_17 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')

			SET @countable_formula_17 = REPLACE(@countable_formula_17, 'countable_', '@countable_')

				+ '/' + REPLACE(@countable_formula_17, 'countable_', '@rec_count_')

		END

	END

	ELSE IF @loop_index = 18

	BEGIN

		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)

		SET @counter_resultfieldname_18 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)



		IF PATINDEX('%(SUM(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_18 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')

		END

		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_18 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')

		END

		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_18 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')

			SET @countable_formula_18 = REPLACE(@countable_formula_18, 'countable_', '@countable_')

				+ '/' + REPLACE(@countable_formula_18, 'countable_', '@rec_count_')

		END

	END

	ELSE IF @loop_index = 19

	BEGIN

		SET @work_counter = SUBSTRING(@work_counter_formulas, 1, @as_index-1)

		SET @counter_resultfieldname_19 = SUBSTRING(@work_counter_formulas, @as_index+4, @comma_index-@as_index-4)



		IF PATINDEX('%(SUM(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_19 = REPLACE(REPLACE(@work_counter, 'SUM', ''), 'tp2.', '@')

		END

		ELSE IF PATINDEX('%(COUNT(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_19 = REPLACE(REPLACE(@work_counter, '(COUNT(', '(('), 'tp2.countable_', '@rec_count_')

		END

		ELSE IF PATINDEX('%(AVG(%',@work_counter) > 0

		BEGIN

			SET @countable_formula_19 = REPLACE(REPLACE(@work_counter, 'AVG', ''), 'tp2.', '')

			SET @countable_formula_19 = REPLACE(@countable_formula_19, 'countable_', '@countable_')

				+ '/' + REPLACE(@countable_formula_19, 'countable_', '@rec_count_')

		END

	END



	SET @work_counter_formulas = SUBSTRING(@work_counter_formulas, @comma_index+2, LEN(@work_counter_formulas))

	--PRINT @work_counter_formulas

END

-- end of the string parsing to extract counter formulas



-- Create the @tmp_tbl_name3 table

IF @formula_count = 1

	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess int, '

		+ @counter_resultfieldname_0 + N' NUMERIC (38,6) ) '

ELSE IF @formula_count = 2

	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess int, '

		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_1 + N' NUMERIC (38,6) ) '

ELSE IF @formula_count = 3

	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess int, '

		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_2 + N' NUMERIC (38,6) ) '

ELSE IF @formula_count = 4

	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess int, '

		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_3 + N' NUMERIC (38,6) ) '

ELSE IF @formula_count = 5

	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess int, '

		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_4 + N' NUMERIC (38,6) ) '

ELSE IF @formula_count = 6

	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess int, '

		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_4 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_5 + N' NUMERIC (38,6) ) '

ELSE IF @formula_count = 7

	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess int, '

		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_4 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_5 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_6 + N' NUMERIC (38,6) ) '

ELSE IF @formula_count = 8

	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess int, '

		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_4 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_5 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_6 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_7 + N' NUMERIC (38,6) ) '

ELSE IF @formula_count = 9

	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess int, '

		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_4 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_5 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_6 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_7 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_8 + N' NUMERIC (38,6) ) '

ELSE IF @formula_count = 10

	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess int, '

		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_4 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_5 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_6 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_7 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_8 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_9 + N' NUMERIC (38,6) ) '

ELSE IF @formula_count = 11

	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess int, '

		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_4 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_5 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_6 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_7 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_8 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_9 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_10 + N' NUMERIC (38,6) ) '

ELSE IF @formula_count = 12

	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess int, '

		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_4 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_5 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_6 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_7 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_8 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_9 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_10 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_11 + N' NUMERIC (38,6) ) '

ELSE IF @formula_count = 13

	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess int, '

		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_4 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_5 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_6 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_7 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_8 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_9 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_10 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_11 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_12 + N' NUMERIC (38,6) ) '

ELSE IF @formula_count = 14

	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess int, '

		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_4 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_5 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_6 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_7 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_8 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_9 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_10 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_11 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_12 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_13 + N' NUMERIC (38,6) ) '

ELSE IF @formula_count = 15

	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess int, '

		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_4 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_5 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_6 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_7 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_8 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_9 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_10 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_11 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_12 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_13 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_14 + N' NUMERIC (38,6) ) '

ELSE IF @formula_count = 16

	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess int, '

		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_4 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_5 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_6 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_7 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_8 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_9 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_10 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_11 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_12 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_13 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_14 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_15 + N' NUMERIC (38,6) ) '

ELSE IF @formula_count = 17

	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess int, '

		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_4 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_5 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_6 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_7 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_8 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_9 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_10 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_11 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_12 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_13 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_14 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_15 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_16 + N' NUMERIC (38,6) ) '

ELSE IF @formula_count = 18

	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess int, '

		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_4 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_5 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_6 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_7 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_8 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_9 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_10 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_11 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_12 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_13 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_14 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_15 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_16 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_17 + N' NUMERIC (38,6) ) '

ELSE IF @formula_count = 19

	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess int, '

		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_4 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_5 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_6 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_7 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_8 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_9 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_10 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_11 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_12 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_13 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_14 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_15 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_16 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_17 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_18 + N' NUMERIC (38,6) ) '

ELSE IF @formula_count = 20

	SET @SQLStmt = N'CREATE TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50)) + N' ( id_sess int, '

		+ @counter_resultfieldname_0 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_1 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_2 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_3 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_4 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_5 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_6 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_7 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_8 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_9 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_10 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_11 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_12 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_13 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_14 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_15 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_16 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_17 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_18 + N' NUMERIC (38,6), '

		+ @counter_resultfieldname_19 + N' NUMERIC (38,6) ) '

--PRINT @SQLStmt

EXEC sp_executesql @SQLStmt

-- End of creating the table



-- Linear processing, 12/31/2002

IF @countable_count = 1 

BEGIN

	SET @SQLStmt = 

	N'DECLARE calc_cursor CURSOR GLOBAL FOR '

	+ N' SELECT 1 id_pass, '

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' pci_dt_start,pci_dt_end,0 FROM ' 

	+ CAST(@tmp_tbl_name1 AS nvarchar(50))

	+ N' UNION ALL '

	+ N' SELECT 2 id_pass, '

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' NULL,NULL,'

	+ N' countable_0'

	+ N' FROM '

	+ CAST(@tmp_tbl_name2 AS nvarchar(50))

	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'

END

ELSE IF @countable_count = 2

BEGIN

	SET @SQLStmt = 

	N'DECLARE calc_cursor CURSOR GLOBAL FOR '

	+ N' SELECT 1 id_pass, '

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' pci_dt_start,pci_dt_end,0,0 FROM ' 

	+ CAST(@tmp_tbl_name1 AS nvarchar(50))

	+ N' UNION ALL '

	+ N' SELECT 2 id_pass, '

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' NULL,NULL,'

	+ N' countable_0,'
	+ N' countable_1'

	+ N' FROM '

	+ CAST(@tmp_tbl_name2 AS nvarchar(50))

	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'

END

ELSE IF @countable_count = 3

BEGIN

	SET @SQLStmt = 

	N'DECLARE calc_cursor CURSOR GLOBAL FOR '

	+ N' SELECT 1 id_pass, '

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' pci_dt_start,pci_dt_end,0,0,0 FROM ' 

	+ CAST(@tmp_tbl_name1 AS nvarchar(50))

	+ N' UNION ALL '

	+ N' SELECT 2 id_pass,'

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' NULL,NULL,'

	+ N' countable_0,'

	+ N' countable_1,'

	+ N' countable_2'

	+ N' FROM '

	+ CAST(@tmp_tbl_name2 AS nvarchar(50))

	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'

END

ELSE IF @countable_count = 4

BEGIN

	SET @SQLStmt = 

	N'DECLARE calc_cursor CURSOR GLOBAL FOR '

	+ N' SELECT 1 id_pass, '

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' pci_dt_start,pci_dt_end,0,0,0,0 FROM ' 

	+ CAST(@tmp_tbl_name1 AS nvarchar(50))

	+ N' UNION ALL '

	+ N' SELECT 2 id_pass,'

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' NULL,NULL,'

	+ N' countable_0,'

	+ N' countable_1,'

	+ N' countable_2,'

	+ N' countable_3'

	+ N' FROM '

	+ CAST(@tmp_tbl_name2 AS nvarchar(50))

	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'

END

ELSE IF @countable_count = 5

BEGIN

	SET @SQLStmt = 

	N'DECLARE calc_cursor CURSOR GLOBAL FOR '

	+ N' SELECT 1 id_pass, '

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0 FROM ' 

	+ CAST(@tmp_tbl_name1 AS nvarchar(50))

	+ N' UNION ALL '

	+ N' SELECT 2 id_pass,'

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' NULL,NULL,'

	+ N' countable_0,'

	+ N' countable_1,'

	+ N' countable_2,'

	+ N' countable_3,'

	+ N' countable_4'

	+ N' FROM '

	+ CAST(@tmp_tbl_name2 AS nvarchar(50))

	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'

END

ELSE IF @countable_count = 6

BEGIN

	SET @SQLStmt = 

	N'DECLARE calc_cursor CURSOR GLOBAL FOR '

	+ N' SELECT 1 id_pass, '

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0,0 FROM ' 

	+ CAST(@tmp_tbl_name1 AS nvarchar(50))

	+ N' UNION ALL '

	+ N' SELECT 2 id_pass,'

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' NULL,NULL,'

	+ N' countable_0,'

	+ N' countable_1,'

	+ N' countable_2,'

	+ N' countable_3,'

	+ N' countable_4,'

	+ N' countable_5'

	+ N' FROM '

	+ CAST(@tmp_tbl_name2 AS nvarchar(50))

	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'

END

ELSE IF @countable_count = 7

BEGIN

	SET @SQLStmt = 

	N'DECLARE calc_cursor CURSOR GLOBAL FOR '

	+ N' SELECT 1 id_pass, '

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0,0,0 FROM ' 

	+ CAST(@tmp_tbl_name1 AS nvarchar(50))

	+ N' UNION ALL '

	+ N' SELECT 2 id_pass,'

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' NULL,NULL,'

	+ N' countable_0,'

	+ N' countable_1,'

	+ N' countable_2,'

	+ N' countable_3,'

	+ N' countable_4,'

	+ N' countable_5,'

	+ N' countable_6'

	+ N' FROM '

	+ CAST(@tmp_tbl_name2 AS nvarchar(50))

	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'

END

ELSE IF @countable_count = 8

BEGIN

	SET @SQLStmt = 

	N'DECLARE calc_cursor CURSOR GLOBAL FOR '

	+ N' SELECT 1 id_pass, '

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0,0,0,0 FROM ' 

	+ CAST(@tmp_tbl_name1 AS nvarchar(50))

	+ N' UNION ALL '

	+ N' SELECT 2 id_pass,'

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' NULL,NULL,'

	+ N' countable_0,'

	+ N' countable_1,'

	+ N' countable_2,'

	+ N' countable_3,'

	+ N' countable_4,'

	+ N' countable_5,'

	+ N' countable_6,'

	+ N' countable_7'

	+ N' FROM '

	+ CAST(@tmp_tbl_name2 AS nvarchar(50))

	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'

END

ELSE IF @countable_count = 9

BEGIN

	SET @SQLStmt = 

	N'DECLARE calc_cursor CURSOR GLOBAL FOR '

	+ N' SELECT 1 id_pass, '

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0,0,0,0,0 FROM ' 

	+ CAST(@tmp_tbl_name1 AS nvarchar(50))

	+ N' UNION ALL '

	+ N' SELECT 2 id_pass,'

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' NULL,NULL,'

	+ N' countable_0,'

	+ N' countable_1,'

	+ N' countable_2,'

	+ N' countable_3,'

	+ N' countable_4,'

	+ N' countable_5,'

	+ N' countable_6,'

	+ N' countable_7,'

	+ N' countable_8'

	+ N' FROM '

	+ CAST(@tmp_tbl_name2 AS nvarchar(50))

	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'

END

ELSE IF @countable_count = 10

BEGIN

	SET @SQLStmt = 

	N'DECLARE calc_cursor CURSOR GLOBAL FOR '

	+ N' SELECT 1 id_pass, '

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0,0,0,0,0,0 FROM ' 

	+ CAST(@tmp_tbl_name1 AS nvarchar(50))

	+ N' UNION ALL '

	+ N' SELECT 2 id_pass,'

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' NULL,NULL,'

	+ N' countable_0,'

	+ N' countable_1,'

	+ N' countable_2,'

	+ N' countable_3,'

	+ N' countable_4,'

	+ N' countable_5,'

	+ N' countable_6,'

	+ N' countable_7,'

	+ N' countable_8,'

	+ N' countable_9'

	+ N' FROM '

	+ CAST(@tmp_tbl_name2 AS nvarchar(50))

	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'

END

ELSE IF @countable_count = 11

BEGIN

	SET @SQLStmt = 

	N'DECLARE calc_cursor CURSOR GLOBAL FOR '

	+ N' SELECT 1 id_pass, '

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0,0,0,0,0,0,0 FROM ' 

	+ CAST(@tmp_tbl_name1 AS nvarchar(50))

	+ N' UNION ALL '

	+ N' SELECT 2 id_pass,'

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' NULL,NULL,'

	+ N' countable_0,'

	+ N' countable_1,'

	+ N' countable_2,'

	+ N' countable_3,'

	+ N' countable_4,'

	+ N' countable_5,'

	+ N' countable_6,'

	+ N' countable_7,'

	+ N' countable_8,'

	+ N' countable_9,'

	+ N' countable_10'

	+ N' FROM '

	+ CAST(@tmp_tbl_name2 AS nvarchar(50))

	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'

END

ELSE IF @countable_count = 12

BEGIN

	SET @SQLStmt = 

	N'DECLARE calc_cursor CURSOR GLOBAL FOR '

	+ N' SELECT 1 id_pass, '

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0,0,0,0,0,0,0,0 FROM ' 

	+ CAST(@tmp_tbl_name1 AS nvarchar(50))

	+ N' UNION ALL '

	+ N' SELECT 2 id_pass,'

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' NULL,NULL,'

	+ N' countable_0,'

	+ N' countable_1,'

	+ N' countable_2,'

	+ N' countable_3,'

	+ N' countable_4,'

	+ N' countable_5,'

	+ N' countable_6,'

	+ N' countable_7,'

	+ N' countable_8,'

	+ N' countable_9,'

	+ N' countable_10,'

	+ N' countable_11'

	+ N' FROM '

	+ CAST(@tmp_tbl_name2 AS nvarchar(50))

	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'

END

ELSE IF @countable_count = 13

BEGIN

	SET @SQLStmt = 

	N'DECLARE calc_cursor CURSOR GLOBAL FOR '

	+ N' SELECT 1 id_pass, '

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'
	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0,0,0,0,0,0,0,0,0 FROM ' 

	+ CAST(@tmp_tbl_name1 AS nvarchar(50))

	+ N' UNION ALL '

	+ N' SELECT 2 id_pass,'

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' NULL,NULL,'

	+ N' countable_0,'

	+ N' countable_1,'

	+ N' countable_2,'

	+ N' countable_3,'

	+ N' countable_4,'

	+ N' countable_5,'

	+ N' countable_6,'

	+ N' countable_7,'

	+ N' countable_8,'

	+ N' countable_9,'

	+ N' countable_10,'

	+ N' countable_11,'

	+ N' countable_12'

	+ N' FROM '

	+ CAST(@tmp_tbl_name2 AS nvarchar(50))

	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'

END

ELSE IF @countable_count = 14

BEGIN

	SET @SQLStmt = 

	N'DECLARE calc_cursor CURSOR GLOBAL FOR '

	+ N' SELECT 1 id_pass, '

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0,0,0,0,0,0,0,0,0,0 FROM ' 

	+ CAST(@tmp_tbl_name1 AS nvarchar(50))

	+ N' UNION ALL '

	+ N' SELECT 2 id_pass,'

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' NULL,NULL,'

	+ N' countable_0,'

	+ N' countable_1,'

	+ N' countable_2,'

	+ N' countable_3,'

	+ N' countable_4,'

	+ N' countable_5,'

	+ N' countable_6,'

	+ N' countable_7,'

	+ N' countable_8,'

	+ N' countable_9,'

	+ N' countable_10,'

	+ N' countable_11,'

	+ N' countable_12,'

	+ N' countable_13'

	+ N' FROM '

	+ CAST(@tmp_tbl_name2 AS nvarchar(50))

	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'

END

ELSE IF @countable_count = 15

BEGIN

	SET @SQLStmt = 

	N'DECLARE calc_cursor CURSOR GLOBAL FOR '

	+ N' SELECT 1 id_pass, '

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 FROM ' 

	+ CAST(@tmp_tbl_name1 AS nvarchar(50))

	+ N' UNION ALL '

	+ N' SELECT 2 id_pass,'

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' NULL,NULL,'

	+ N' countable_0,'

	+ N' countable_1,'

	+ N' countable_2,'

	+ N' countable_3,'

	+ N' countable_4,'

	+ N' countable_5,'

	+ N' countable_6,'

	+ N' countable_7,'

	+ N' countable_8,'

	+ N' countable_9,'

	+ N' countable_10,'

	+ N' countable_11,'

	+ N' countable_12,'

	+ N' countable_13,'

	+ N' countable_14'

	+ N' FROM '

	+ CAST(@tmp_tbl_name2 AS nvarchar(50))

	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'

END

ELSE IF @countable_count = 16

BEGIN

	SET @SQLStmt = 

	N'DECLARE calc_cursor CURSOR GLOBAL FOR '

	+ N' SELECT 1 id_pass, '

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 FROM ' 

	+ CAST(@tmp_tbl_name1 AS nvarchar(50))

	+ N' UNION ALL '

	+ N' SELECT 2 id_pass,'

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' NULL,NULL,'

	+ N' countable_0,'
	+ N' countable_1,'

	+ N' countable_2,'

	+ N' countable_3,'

	+ N' countable_4,'

	+ N' countable_5,'

	+ N' countable_6,'

	+ N' countable_7,'

	+ N' countable_8,'

	+ N' countable_9,'

	+ N' countable_10,'

	+ N' countable_11,'

	+ N' countable_12,'

	+ N' countable_13,'

	+ N' countable_14,'

	+ N' countable_15'

	+ N' FROM '

	+ CAST(@tmp_tbl_name2 AS nvarchar(50))

	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'

END

ELSE IF @countable_count = 17

BEGIN

	SET @SQLStmt = 

	N'DECLARE calc_cursor CURSOR GLOBAL FOR '

	+ N' SELECT 1 id_pass, '

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 FROM ' 

	+ CAST(@tmp_tbl_name1 AS nvarchar(50))

	+ N' UNION ALL '

	+ N' SELECT 2 id_pass,'

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' NULL,NULL,'

	+ N' countable_0,'

	+ N' countable_1,'

	+ N' countable_2,'

	+ N' countable_3,'

	+ N' countable_4,'

	+ N' countable_5,'

	+ N' countable_6,'

	+ N' countable_7,'

	+ N' countable_8,'

	+ N' countable_9,'

	+ N' countable_10,'

	+ N' countable_11,'

	+ N' countable_12,'

	+ N' countable_13,'

	+ N' countable_14,'

	+ N' countable_15,'

	+ N' countable_16'

	+ N' FROM '

	+ CAST(@tmp_tbl_name2 AS nvarchar(50))

	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'

END

ELSE IF @countable_count = 18

BEGIN

	SET @SQLStmt = 

	N'DECLARE calc_cursor CURSOR GLOBAL FOR '

	+ N' SELECT 1 id_pass, '

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 FROM ' 

	+ CAST(@tmp_tbl_name1 AS nvarchar(50))
	+ N' UNION ALL '

	+ N' SELECT 2 id_pass,'

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' NULL,NULL,'

	+ N' countable_0,'

	+ N' countable_1,'

	+ N' countable_2,'

	+ N' countable_3,'

	+ N' countable_4,'

	+ N' countable_5,'

	+ N' countable_6,'

	+ N' countable_7,'

	+ N' countable_8,'

	+ N' countable_9,'

	+ N' countable_10,'

	+ N' countable_11,'

	+ N' countable_12,'

	+ N' countable_13,'

	+ N' countable_14,'

	+ N' countable_15,'

	+ N' countable_16,'

	+ N' countable_17'

	+ N' FROM '

	+ CAST(@tmp_tbl_name2 AS nvarchar(50))

	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'

END

ELSE IF @countable_count = 19

BEGIN

	SET @SQLStmt = 

	N'DECLARE calc_cursor CURSOR GLOBAL FOR '

	+ N' SELECT 1 id_pass, '

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 FROM ' 

	+ CAST(@tmp_tbl_name1 AS nvarchar(50))

	+ N' UNION ALL '

	+ N' SELECT 2 id_pass,'

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' NULL,NULL,'

	+ N' countable_0,'

	+ N' countable_1,'

	+ N' countable_2,'

	+ N' countable_3,'

	+ N' countable_4,'

	+ N' countable_5,'

	+ N' countable_6,'

	+ N' countable_7,'

	+ N' countable_8,'

	+ N' countable_9,'

	+ N' countable_10,'

	+ N' countable_11,'

	+ N' countable_12,'

	+ N' countable_13,'

	+ N' countable_14,'

	+ N' countable_15,'

	+ N' countable_16,'

	+ N' countable_17,'

	+ N' countable_18'

	+ N' FROM '

	+ CAST(@tmp_tbl_name2 AS nvarchar(50))

	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'

END

ELSE IF @countable_count = 20

BEGIN

	SET @SQLStmt = 

	N'DECLARE calc_cursor CURSOR GLOBAL FOR '

	+ N' SELECT 1 id_pass, '

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' pci_dt_start,pci_dt_end,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 FROM ' 

	+ CAST(@tmp_tbl_name1 AS nvarchar(50))

	+ N' UNION ALL '

	+ N' SELECT 2 id_pass,'

	+ N' id_sess,id_acc,group_acc_flag,group_acc_id,pci_id_interval,dt_session,ui_dt_start,ui_dt_end,'

	+ N' NULL,NULL,'

	+ N' countable_0,'

	+ N' countable_1,'

	+ N' countable_2,'

	+ N' countable_3,'

	+ N' countable_4,'

	+ N' countable_5,'

	+ N' countable_6,'

	+ N' countable_7,'

	+ N' countable_8,'

	+ N' countable_9,'

	+ N' countable_10,'

	+ N' countable_11,'

	+ N' countable_12,'

	+ N' countable_13,'

	+ N' countable_14,'

	+ N' countable_15,'

	+ N' countable_16,'

	+ N' countable_17,'

	+ N' countable_18,'

	+ N' countable_19'

	+ N' FROM '

	+ CAST(@tmp_tbl_name2 AS nvarchar(50))

	+ N' ORDER BY group_acc_flag,group_acc_id,pci_id_interval,ui_dt_end,dt_session,id_sess, id_pass'

END

-- PRINT @SQLStmt



EXEC sp_executesql @SQLStmt

SELECT @SQLError = @@ERROR

IF @SQLError <> 0 GOTO FatalError



OPEN calc_cursor 

SELECT @SQLError = @@ERROR

IF @SQLError <> 0 GOTO FatalError



IF @countable_count = 1

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0

END

ELSE IF @countable_count = 2

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1

END

ELSE IF @countable_count = 3

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2

END

ELSE IF @countable_count = 4

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3

END

ELSE IF @countable_count = 5

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4

END

ELSE IF @countable_count = 6

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5

END

ELSE IF @countable_count = 7

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,

	@cur_countable_6

END

ELSE IF @countable_count = 8

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,

	@cur_countable_6,@cur_countable_7

END

ELSE IF @countable_count = 9

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,

	@cur_countable_6,@cur_countable_7,@cur_countable_8

END

ELSE IF @countable_count = 10

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,

	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9

END

ELSE IF @countable_count = 11

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,

	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10

END

ELSE IF @countable_count = 12

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,

	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11

END

ELSE IF @countable_count = 13

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,

	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,

	@cur_countable_12

END

ELSE IF @countable_count = 14

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,

	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,

	@cur_countable_12,@cur_countable_13

END

ELSE IF @countable_count = 15

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,

	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,

	@cur_countable_12,@cur_countable_13,@cur_countable_14

END

ELSE IF @countable_count = 16

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,

	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,

	@cur_countable_12,@cur_countable_13,@cur_countable_14,@cur_countable_15

END

ELSE IF @countable_count = 17

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,

	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,

	@cur_countable_12,@cur_countable_13,@cur_countable_14,@cur_countable_15,@cur_countable_16

END

ELSE IF @countable_count = 18

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,

	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,

	@cur_countable_12,@cur_countable_13,@cur_countable_14,@cur_countable_15,@cur_countable_16,@cur_countable_17

END

ELSE IF @countable_count = 19

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,

	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,

	@cur_countable_12,@cur_countable_13,@cur_countable_14,@cur_countable_15,@cur_countable_16,@cur_countable_17,

	@cur_countable_18

END

ELSE IF @countable_count = 20

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,

	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,

	@cur_countable_12,@cur_countable_13,@cur_countable_14,@cur_countable_15,@cur_countable_16,@cur_countable_17,

	@cur_countable_18,@cur_countable_19

END



SET @FetchStatusCalc = @@FETCH_STATUS

SET @pre_group_acc_flag = 0

SET @pre_group_acc_id = 0

SET @pre_pci_id_interval = 0



WHILE @FetchStatusCalc <> -1

BEGIN

	-- Reset the counters when necessary

	IF @FetchStatusCalc = 0

		AND (@cur_group_acc_flag <> @pre_group_acc_flag 

		     OR @cur_group_acc_id <> @pre_group_acc_id

		     OR @cur_pci_id_interval <> @pre_pci_id_interval

		    )

	BEGIN

		SET @pre_pci_id_interval = @cur_pci_id_interval

		SET @pre_group_acc_flag = @cur_group_acc_flag

		SET @pre_group_acc_id = @cur_group_acc_id



		IF @countable_count = 1

		BEGIN

			SET @countable_0 = 0



			SET @rec_count_0 = 0

		END

		ELSE IF @countable_count = 2

		BEGIN

			SET @countable_0 = 0

			SET @countable_1 = 0



			SET @rec_count_0 = 0

			SET @rec_count_1 = 0

		END

		ELSE IF @countable_count = 3

		BEGIN

			SET @countable_0 = 0

			SET @countable_1 = 0

			SET @countable_2 = 0



			SET @rec_count_0 = 0

			SET @rec_count_1 = 0

			SET @rec_count_2 = 0

		END

		ELSE IF @countable_count = 4

		BEGIN

			SET @countable_0 = 0

			SET @countable_1 = 0

			SET @countable_2 = 0

			SET @countable_3 = 0



			SET @rec_count_0 = 0

			SET @rec_count_1 = 0

			SET @rec_count_2 = 0

			SET @rec_count_3 = 0

		END

		ELSE IF @countable_count = 5

		BEGIN

			SET @countable_0 = 0

			SET @countable_1 = 0

			SET @countable_2 = 0

			SET @countable_3 = 0

			SET @countable_4 = 0



			SET @rec_count_0 = 0

			SET @rec_count_1 = 0

			SET @rec_count_2 = 0

			SET @rec_count_3 = 0

			SET @rec_count_4 = 0

		END

		ELSE IF @countable_count = 6

		BEGIN

			SET @countable_0 = 0

			SET @countable_1 = 0

			SET @countable_2 = 0

			SET @countable_3 = 0

			SET @countable_4 = 0

			SET @countable_5 = 0



			SET @rec_count_0 = 0

			SET @rec_count_1 = 0

			SET @rec_count_2 = 0

			SET @rec_count_3 = 0

			SET @rec_count_4 = 0

			SET @rec_count_5 = 0

		END

		ELSE IF @countable_count = 7

		BEGIN

			SET @countable_0 = 0

			SET @countable_1 = 0

			SET @countable_2 = 0

			SET @countable_3 = 0

			SET @countable_4 = 0

			SET @countable_5 = 0

			SET @countable_6 = 0



			SET @rec_count_0 = 0

			SET @rec_count_1 = 0

			SET @rec_count_2 = 0

			SET @rec_count_3 = 0

			SET @rec_count_4 = 0

			SET @rec_count_5 = 0

			SET @rec_count_6 = 0

		END

		ELSE IF @countable_count = 8

		BEGIN

			SET @countable_0 = 0

			SET @countable_1 = 0

			SET @countable_2 = 0

			SET @countable_3 = 0

			SET @countable_4 = 0

			SET @countable_5 = 0

			SET @countable_6 = 0

			SET @countable_7 = 0



			SET @rec_count_0 = 0

			SET @rec_count_1 = 0

			SET @rec_count_2 = 0

			SET @rec_count_3 = 0

			SET @rec_count_4 = 0

			SET @rec_count_5 = 0

			SET @rec_count_6 = 0

			SET @rec_count_7 = 0

		END

		ELSE IF @countable_count = 9

		BEGIN

			SET @countable_0 = 0

			SET @countable_1 = 0

			SET @countable_2 = 0

			SET @countable_3 = 0

			SET @countable_4 = 0

			SET @countable_5 = 0

			SET @countable_6 = 0

			SET @countable_7 = 0

			SET @countable_8 = 0



			SET @rec_count_0 = 0

			SET @rec_count_1 = 0

			SET @rec_count_2 = 0

			SET @rec_count_3 = 0

			SET @rec_count_4 = 0

			SET @rec_count_5 = 0

			SET @rec_count_6 = 0

			SET @rec_count_7 = 0

			SET @rec_count_8 = 0

		END

		ELSE IF @countable_count = 10

		BEGIN

			SET @countable_0 = 0

			SET @countable_1 = 0

			SET @countable_2 = 0

			SET @countable_3 = 0

			SET @countable_4 = 0

			SET @countable_5 = 0

			SET @countable_6 = 0

			SET @countable_7 = 0

			SET @countable_8 = 0

			SET @countable_9 = 0



			SET @rec_count_0 = 0

			SET @rec_count_1 = 0

			SET @rec_count_2 = 0

			SET @rec_count_3 = 0

			SET @rec_count_4 = 0

			SET @rec_count_5 = 0

			SET @rec_count_6 = 0

			SET @rec_count_7 = 0

			SET @rec_count_8 = 0

			SET @rec_count_9 = 0

		END

		ELSE IF @countable_count = 11

		BEGIN

			SET @countable_0 = 0

			SET @countable_1 = 0

			SET @countable_2 = 0

			SET @countable_3 = 0

			SET @countable_4 = 0

			SET @countable_5 = 0

			SET @countable_6 = 0

			SET @countable_7 = 0

			SET @countable_8 = 0

			SET @countable_9 = 0

			SET @countable_10 = 0



			SET @rec_count_0 = 0

			SET @rec_count_1 = 0

			SET @rec_count_2 = 0

			SET @rec_count_3 = 0

			SET @rec_count_4 = 0

			SET @rec_count_5 = 0

			SET @rec_count_6 = 0

			SET @rec_count_7 = 0

			SET @rec_count_8 = 0

			SET @rec_count_9 = 0

			SET @rec_count_10 = 0

		END

		ELSE IF @countable_count = 12

		BEGIN

			SET @countable_0 = 0

			SET @countable_1 = 0

			SET @countable_2 = 0

			SET @countable_3 = 0

			SET @countable_4 = 0

			SET @countable_5 = 0

			SET @countable_6 = 0

			SET @countable_7 = 0

			SET @countable_8 = 0

			SET @countable_9 = 0

			SET @countable_10 = 0

			SET @countable_11 = 0



			SET @rec_count_0 = 0

			SET @rec_count_1 = 0

			SET @rec_count_2 = 0

			SET @rec_count_3 = 0

			SET @rec_count_4 = 0

			SET @rec_count_5 = 0

			SET @rec_count_6 = 0

			SET @rec_count_7 = 0

			SET @rec_count_8 = 0

			SET @rec_count_9 = 0

			SET @rec_count_10 = 0

			SET @rec_count_11 = 0

		END

		ELSE IF @countable_count = 13

		BEGIN

			SET @countable_0 = 0

			SET @countable_1 = 0

			SET @countable_2 = 0

			SET @countable_3 = 0

			SET @countable_4 = 0

			SET @countable_5 = 0

			SET @countable_6 = 0

			SET @countable_7 = 0

			SET @countable_8 = 0

			SET @countable_9 = 0

			SET @countable_10 = 0

			SET @countable_11 = 0

			SET @countable_12 = 0



			SET @rec_count_0 = 0

			SET @rec_count_1 = 0

			SET @rec_count_2 = 0

			SET @rec_count_3 = 0

			SET @rec_count_4 = 0

			SET @rec_count_5 = 0
			SET @rec_count_6 = 0

			SET @rec_count_7 = 0

			SET @rec_count_8 = 0

			SET @rec_count_9 = 0

			SET @rec_count_10 = 0

			SET @rec_count_11 = 0

			SET @rec_count_12 = 0

		END

		ELSE IF @countable_count = 14

		BEGIN

			SET @countable_0 = 0

			SET @countable_1 = 0

			SET @countable_2 = 0

			SET @countable_3 = 0

			SET @countable_4 = 0

			SET @countable_5 = 0

			SET @countable_6 = 0

			SET @countable_7 = 0

			SET @countable_8 = 0

			SET @countable_9 = 0

			SET @countable_10 = 0

			SET @countable_11 = 0

			SET @countable_12 = 0

			SET @countable_13 = 0



			SET @rec_count_0 = 0

			SET @rec_count_1 = 0

			SET @rec_count_2 = 0

			SET @rec_count_3 = 0

			SET @rec_count_4 = 0

			SET @rec_count_5 = 0

			SET @rec_count_6 = 0

			SET @rec_count_7 = 0

			SET @rec_count_8 = 0

			SET @rec_count_9 = 0

			SET @rec_count_10 = 0

			SET @rec_count_11 = 0

			SET @rec_count_12 = 0

			SET @rec_count_13 = 0

		END

		ELSE IF @countable_count = 15

		BEGIN

			SET @countable_0 = 0

			SET @countable_1 = 0

			SET @countable_2 = 0

			SET @countable_3 = 0

			SET @countable_4 = 0

			SET @countable_5 = 0

			SET @countable_6 = 0

			SET @countable_7 = 0

			SET @countable_8 = 0

			SET @countable_9 = 0

			SET @countable_10 = 0

			SET @countable_11 = 0

			SET @countable_12 = 0

			SET @countable_13 = 0

			SET @countable_14 = 0



			SET @rec_count_0 = 0

			SET @rec_count_1 = 0

			SET @rec_count_2 = 0

			SET @rec_count_3 = 0

			SET @rec_count_4 = 0

			SET @rec_count_5 = 0

			SET @rec_count_6 = 0

			SET @rec_count_7 = 0

			SET @rec_count_8 = 0

			SET @rec_count_9 = 0

			SET @rec_count_10 = 0

			SET @rec_count_11 = 0

			SET @rec_count_12 = 0

			SET @rec_count_13 = 0

			SET @rec_count_14 = 0

		END

		ELSE IF @countable_count = 16

		BEGIN

			SET @countable_0 = 0

			SET @countable_1 = 0

			SET @countable_2 = 0

			SET @countable_3 = 0

			SET @countable_4 = 0

			SET @countable_5 = 0

			SET @countable_6 = 0

			SET @countable_7 = 0

			SET @countable_8 = 0

			SET @countable_9 = 0

			SET @countable_10 = 0

			SET @countable_11 = 0

			SET @countable_12 = 0

			SET @countable_13 = 0

			SET @countable_14 = 0

			SET @countable_15 = 0



			SET @rec_count_0 = 0

			SET @rec_count_1 = 0

			SET @rec_count_2 = 0

			SET @rec_count_3 = 0

			SET @rec_count_4 = 0

			SET @rec_count_5 = 0

			SET @rec_count_6 = 0

			SET @rec_count_7 = 0
			SET @rec_count_8 = 0

			SET @rec_count_9 = 0

			SET @rec_count_10 = 0

			SET @rec_count_11 = 0

			SET @rec_count_12 = 0

			SET @rec_count_13 = 0

			SET @rec_count_14 = 0

			SET @rec_count_15 = 0

		END

		ELSE IF @countable_count = 17

		BEGIN

			SET @countable_0 = 0

			SET @countable_1 = 0

			SET @countable_2 = 0

			SET @countable_3 = 0

			SET @countable_4 = 0

			SET @countable_5 = 0

			SET @countable_6 = 0

			SET @countable_7 = 0

			SET @countable_8 = 0

			SET @countable_9 = 0

			SET @countable_10 = 0

			SET @countable_11 = 0

			SET @countable_12 = 0

			SET @countable_13 = 0

			SET @countable_14 = 0

			SET @countable_15 = 0

			SET @countable_16 = 0



			SET @rec_count_0 = 0

			SET @rec_count_1 = 0

			SET @rec_count_2 = 0

			SET @rec_count_3 = 0

			SET @rec_count_4 = 0

			SET @rec_count_5 = 0

			SET @rec_count_6 = 0

			SET @rec_count_7 = 0

			SET @rec_count_8 = 0

			SET @rec_count_9 = 0

			SET @rec_count_10 = 0

			SET @rec_count_11 = 0

			SET @rec_count_12 = 0

			SET @rec_count_13 = 0

			SET @rec_count_14 = 0

			SET @rec_count_15 = 0

			SET @rec_count_16 = 0

		END

		ELSE IF @countable_count = 18

		BEGIN

			SET @countable_0 = 0

			SET @countable_1 = 0

			SET @countable_2 = 0

			SET @countable_3 = 0

			SET @countable_4 = 0

			SET @countable_5 = 0

			SET @countable_6 = 0

			SET @countable_7 = 0

			SET @countable_8 = 0

			SET @countable_9 = 0

			SET @countable_10 = 0

			SET @countable_11 = 0

			SET @countable_12 = 0

			SET @countable_13 = 0

			SET @countable_14 = 0

			SET @countable_15 = 0

			SET @countable_16 = 0
			SET @countable_17 = 0



			SET @rec_count_0 = 0

			SET @rec_count_1 = 0

			SET @rec_count_2 = 0

			SET @rec_count_3 = 0

			SET @rec_count_4 = 0

			SET @rec_count_5 = 0

			SET @rec_count_6 = 0

			SET @rec_count_7 = 0

			SET @rec_count_8 = 0

			SET @rec_count_9 = 0

			SET @rec_count_10 = 0

			SET @rec_count_11 = 0

			SET @rec_count_12 = 0

			SET @rec_count_13 = 0

			SET @rec_count_14 = 0

			SET @rec_count_15 = 0

			SET @rec_count_16 = 0

			SET @rec_count_17 = 0

		END

		ELSE IF @countable_count = 19

		BEGIN
			SET @countable_0 = 0

			SET @countable_1 = 0

			SET @countable_2 = 0

			SET @countable_3 = 0

			SET @countable_4 = 0

			SET @countable_5 = 0

			SET @countable_6 = 0

			SET @countable_7 = 0

			SET @countable_8 = 0

			SET @countable_9 = 0

			SET @countable_10 = 0

			SET @countable_11 = 0

			SET @countable_12 = 0

			SET @countable_13 = 0

			SET @countable_14 = 0

			SET @countable_15 = 0

			SET @countable_16 = 0

			SET @countable_17 = 0

			SET @countable_18 = 0



			SET @rec_count_0 = 0

			SET @rec_count_1 = 0

			SET @rec_count_2 = 0

			SET @rec_count_3 = 0

			SET @rec_count_4 = 0

			SET @rec_count_5 = 0

			SET @rec_count_6 = 0

			SET @rec_count_7 = 0

			SET @rec_count_8 = 0

			SET @rec_count_9 = 0

			SET @rec_count_10 = 0

			SET @rec_count_11 = 0

			SET @rec_count_12 = 0

			SET @rec_count_13 = 0

			SET @rec_count_14 = 0

			SET @rec_count_15 = 0

			SET @rec_count_16 = 0

			SET @rec_count_17 = 0

			SET @rec_count_18 = 0

		END

		ELSE IF @countable_count = 20

		BEGIN

			SET @countable_0 = 0

			SET @countable_1 = 0

			SET @countable_2 = 0

			SET @countable_3 = 0

			SET @countable_4 = 0

			SET @countable_5 = 0

			SET @countable_6 = 0

			SET @countable_7 = 0

			SET @countable_8 = 0

			SET @countable_9 = 0

			SET @countable_10 = 0

			SET @countable_11 = 0

			SET @countable_12 = 0

			SET @countable_13 = 0

			SET @countable_14 = 0

			SET @countable_15 = 0

			SET @countable_16 = 0

			SET @countable_17 = 0

			SET @countable_18 = 0

			SET @countable_19 = 0



			SET @rec_count_0 = 0

			SET @rec_count_1 = 0

			SET @rec_count_2 = 0

			SET @rec_count_3 = 0

			SET @rec_count_4 = 0

			SET @rec_count_5 = 0

			SET @rec_count_6 = 0

			SET @rec_count_7 = 0

			SET @rec_count_8 = 0

			SET @rec_count_9 = 0

			SET @rec_count_10 = 0

			SET @rec_count_11 = 0

			SET @rec_count_12 = 0

			SET @rec_count_13 = 0

			SET @rec_count_14 = 0

			SET @rec_count_15 = 0

			SET @rec_count_16 = 0

			SET @rec_count_17 = 0

			SET @rec_count_18 = 0

			SET @rec_count_19 = 0

		END

	END -- reset the counters



	-- Processing the record

	IF @FetchStatusCalc = 0

	BEGIN

		IF @cur_id_pass = 1

		BEGIN

			-- Insert into the temp table



			-- obtain the actual value before the insertion

			SET @SQLStmt = N'DECLARE get_value_cursor CURSOR GLOBAL FOR SELECT '

			+ ISNULL(@countable_formula_0,0) + N',' + ISNULL(@countable_formula_1 ,0) + N',' + ISNULL(@countable_formula_2 ,0) + N','

			+ ISNULL(@countable_formula_3 ,0) + N',' + ISNULL(@countable_formula_4 ,0) + N',' + ISNULL(@countable_formula_5 ,0) + N','

			+ ISNULL(@countable_formula_6 ,0) + N',' + ISNULL(@countable_formula_7 ,0) + N',' + ISNULL(@countable_formula_8 ,0) + N','

			+ ISNULL(@countable_formula_9 ,0) + N',' + ISNULL(@countable_formula_10 ,0) + N',' + ISNULL(@countable_formula_11 ,0) + N','

			+ ISNULL(@countable_formula_12 ,0) + N',' + ISNULL(@countable_formula_13 ,0) + N',' + ISNULL(@countable_formula_14 ,0) + N','

			+ ISNULL(@countable_formula_15 ,0) + N',' + ISNULL(@countable_formula_16 ,0) + N',' + ISNULL(@countable_formula_17 ,0) + N','

			+ ISNULL(@countable_formula_18 ,0) + N',' + ISNULL(@countable_formula_19 ,0) 

			--PRINT @SQLStmt



			EXEC sp_executesql @SQLStmt,

			N'@countable_0 numeric(18,6), @countable_1 numeric(18,6), @countable_2 numeric(18,6),

			@countable_3 numeric(18,6), @countable_4 numeric(18,6), @countable_5 numeric(18,6),

			@countable_6 numeric(18,6), @countable_7 numeric(18,6), @countable_8 numeric(18,6),

			@countable_9 numeric(18,6), @countable_10 numeric(18,6), @countable_11 numeric(18,6),

			@countable_12 numeric(18,6), @countable_13 numeric(18,6), @countable_14 numeric(18,6),

			@countable_15 numeric(18,6), @countable_16 numeric(18,6), @countable_17 numeric(18,6),

			@countable_18 numeric(18,6), @countable_19 numeric(18,6),

			@rec_count_0 int, @rec_count_1 int, @rec_count_2 int, 

			@rec_count_3 int, @rec_count_4 int, @rec_count_5 int, 

			@rec_count_6 int, @rec_count_7 int, @rec_count_8 int, 

			@rec_count_9 int, @rec_count_10 int, @rec_count_11 int, 

			@rec_count_12 int, @rec_count_13 int, @rec_count_14 int, 

			@rec_count_15 int, @rec_count_16 int, @rec_count_17 int, 

			@rec_count_18 int, @rec_count_19 int',

			@countable_0, @countable_1, @countable_2,

			@countable_3, @countable_4, @countable_5,

			@countable_6, @countable_7, @countable_8,

			@countable_9, @countable_10, @countable_11,

			@countable_12, @countable_13, @countable_14,

			@countable_15, @countable_16, @countable_17,

			@countable_18, @countable_19,

			@rec_count_0, @rec_count_1, @rec_count_2, 

			@rec_count_3, @rec_count_4, @rec_count_5, 

			@rec_count_6, @rec_count_7, @rec_count_8, 

			@rec_count_9, @rec_count_10, @rec_count_11, 

			@rec_count_12, @rec_count_13, @rec_count_14, 

			@rec_count_15, @rec_count_16, @rec_count_17, 

			@rec_count_18, @rec_count_19



			SELECT @SQLError = @@ERROR

			IF @SQLError <> 0 GOTO FatalErrorCursor_Calc



			OPEN get_value_cursor

			SELECT @SQLError = @@ERROR

			IF @SQLError <> 0 GOTO FatalErrorCursor_Calc



			FETCH NEXT FROM get_value_cursor INTO 

			@countable_formula_value_0, @countable_formula_value_1, @countable_formula_value_2,

			@countable_formula_value_3, @countable_formula_value_4, @countable_formula_value_5,

			@countable_formula_value_6, @countable_formula_value_7, @countable_formula_value_8,

			@countable_formula_value_9, @countable_formula_value_10, @countable_formula_value_11,

			@countable_formula_value_12, @countable_formula_value_13, @countable_formula_value_14,

			@countable_formula_value_15, @countable_formula_value_16, @countable_formula_value_17,

			@countable_formula_value_18, @countable_formula_value_19



			CLOSE get_value_cursor

			DEALLOCATE get_value_cursor



			-- start insertions

			IF @formula_count = 1

				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))

				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N',' 

				+ CAST(@countable_formula_value_0 AS nvarchar(50)) + N')'

			ELSE IF @formula_count = 2

				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))

				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N',' 

				+ CAST(@countable_formula_value_0 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50)) 

				+ N')'

			ELSE IF @formula_count = 3

				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))

				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N',' 

				+ CAST(@countable_formula_value_0 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50)) 

				+ N')'

			ELSE IF @formula_count = 4

				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))

				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N',' 

				+ CAST(@countable_formula_value_0 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50)) 

				+ N')'

			ELSE IF @formula_count = 5

				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))

				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N',' 

				+ CAST(@countable_formula_value_0 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50)) 

				+ N')'

			ELSE IF @formula_count = 6

				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))

				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N',' 

				+ CAST(@countable_formula_value_0 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_5 AS nvarchar(50)) 

				+ N')'

			ELSE IF @formula_count = 7

				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))

				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N',' 

				+ CAST(@countable_formula_value_0 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_5 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_6 AS nvarchar(50)) 

				+ N')'

			ELSE IF @formula_count = 8

				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))

				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N',' 

				+ CAST(@countable_formula_value_0 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_5 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_6 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_7 AS nvarchar(50)) 

				+ N')'

			ELSE IF @formula_count = 9

				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))

				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N',' 

				+ CAST(@countable_formula_value_0 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_5 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_6 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_7 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_8 AS nvarchar(50)) 

				+ N')'

			ELSE IF @formula_count = 10

				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))

				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N',' 

				+ CAST(@countable_formula_value_0 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_5 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_6 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_7 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_8 AS nvarchar(50)) 
				+ N',' + CAST(@countable_formula_value_9 AS nvarchar(50)) 

				+ N')'

			ELSE IF @formula_count = 11

				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))

				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N',' 

				+ CAST(@countable_formula_value_0 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_5 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_6 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_7 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_8 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_9 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_10 AS nvarchar(50)) 

				+ N')'

			ELSE IF @formula_count = 12

				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))

				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N',' 

				+ CAST(@countable_formula_value_0 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_5 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_6 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_7 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_8 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_9 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_10 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_11 AS nvarchar(50)) 

				+ N')'

			ELSE IF @formula_count = 13

				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))

				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N',' 

				+ CAST(@countable_formula_value_0 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_5 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_6 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_7 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_8 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_9 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_10 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_11 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_12 AS nvarchar(50)) 

				+ N')'

			ELSE IF @formula_count = 14

				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))

				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N',' 

				+ CAST(@countable_formula_value_0 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_5 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_6 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_7 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_8 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_9 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_10 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_11 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_12 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_13 AS nvarchar(50)) 

				+ N')'

			ELSE IF @formula_count = 15

				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))

				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N',' 

				+ CAST(@countable_formula_value_0 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_5 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_6 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_7 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_8 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_9 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_10 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_11 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_12 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_13 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_14 AS nvarchar(50)) 

				+ N')'

			ELSE IF @formula_count = 16

				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))

				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N',' 

				+ CAST(@countable_formula_value_0 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_5 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_6 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_7 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_8 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_9 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_10 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_11 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_12 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_13 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_14 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_15 AS nvarchar(50)) 

				+ N')'

			ELSE IF @formula_count = 17

				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))

				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N',' 

				+ CAST(@countable_formula_value_0 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_5 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_6 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_7 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_8 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_9 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_10 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_11 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_12 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_13 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_14 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_15 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_16 AS nvarchar(50)) 

				+ N')'

			ELSE IF @formula_count = 18

				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))

				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N',' 

				+ CAST(@countable_formula_value_0 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_5 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_6 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_7 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_8 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_9 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_10 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_11 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_12 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_13 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_14 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_15 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_16 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_17 AS nvarchar(50)) 

				+ N')'

			ELSE IF @formula_count = 19

				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))

				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N',' 

				+ CAST(@countable_formula_value_0 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50)) 
				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_5 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_6 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_7 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_8 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_9 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_10 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_11 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_12 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_13 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_14 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_15 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_16 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_17 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_18 AS nvarchar(50)) 

				+ N')'

			ELSE IF @formula_count = 20

				SET @SQLStmt = N'INSERT INTO ' + CAST(@tmp_tbl_name3 AS nvarchar(50))

				+ N' VALUES (' + CAST(@cur_id_sess AS nvarchar(50)) + N',' 

				+ CAST(@countable_formula_value_0 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_1 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_2 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_3 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_4 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_5 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_6 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_7 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_8 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_9 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_10 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_11 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_12 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_13 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_14 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_15 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_16 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_17 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_18 AS nvarchar(50)) 

				+ N',' + CAST(@countable_formula_value_19 AS nvarchar(50)) 

				+ N')'



			EXEC sp_executesql @SQLStmt

			SELECT @SQLError = @@ERROR

			IF @SQLError <> 0 GOTO FatalErrorCursor_Calc

		END

		ELSE

		BEGIN

			-- Counter records to accumulate the counters

			IF @countable_count = 1

			BEGIN

				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)



				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END

			END

			ELSE IF @countable_count = 2

			BEGIN

				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)

				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)



				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END

			END

			ELSE IF @countable_count = 3

			BEGIN

				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)

				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)

				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)



				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END

			END

			ELSE IF @countable_count = 4

			BEGIN

				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)

				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)

				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)

				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)



				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END

			END

			ELSE IF @countable_count = 5

			BEGIN

				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)

				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)

				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)

				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)

				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)



				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END

			END

			ELSE IF @countable_count = 6

			BEGIN

				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)

				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)

				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)

				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)

				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)

				SET @countable_5 = @countable_5 + ISNULL(@cur_countable_5,0)



				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_5 = @rec_count_5 + CASE WHEN @cur_countable_5 IS NULL THEN 0 ELSE 1 END

			END

			ELSE IF @countable_count = 7

			BEGIN

				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)

				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)

				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)

				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)

				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)

				SET @countable_5 = @countable_5 + ISNULL(@cur_countable_5,0)

				SET @countable_6 = @countable_6 + ISNULL(@cur_countable_6,0)



				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_5 = @rec_count_5 + CASE WHEN @cur_countable_5 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_6 = @rec_count_6 + CASE WHEN @cur_countable_6 IS NULL THEN 0 ELSE 1 END

			END

			ELSE IF @countable_count = 8

			BEGIN

				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)

				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)

				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)

				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)

				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)

				SET @countable_5 = @countable_5 + ISNULL(@cur_countable_5,0)

				SET @countable_6 = @countable_6 + ISNULL(@cur_countable_6,0)

				SET @countable_7 = @countable_7 + ISNULL(@cur_countable_7,0)



				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_5 = @rec_count_5 + CASE WHEN @cur_countable_5 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_6 = @rec_count_6 + CASE WHEN @cur_countable_6 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_7 = @rec_count_7 + CASE WHEN @cur_countable_7 IS NULL THEN 0 ELSE 1 END

			END

			ELSE IF @countable_count = 9

			BEGIN

				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)

				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)

				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)

				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)

				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)

				SET @countable_5 = @countable_5 + ISNULL(@cur_countable_5,0)

				SET @countable_6 = @countable_6 + ISNULL(@cur_countable_6,0)

				SET @countable_7 = @countable_7 + ISNULL(@cur_countable_7,0)

				SET @countable_8 = @countable_8 + ISNULL(@cur_countable_8,0)



				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_5 = @rec_count_5 + CASE WHEN @cur_countable_5 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_6 = @rec_count_6 + CASE WHEN @cur_countable_6 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_7 = @rec_count_7 + CASE WHEN @cur_countable_7 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_8 = @rec_count_8 + CASE WHEN @cur_countable_8 IS NULL THEN 0 ELSE 1 END

			END

			ELSE IF @countable_count = 10

			BEGIN

				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)

				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)

				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)

				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)

				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)

				SET @countable_5 = @countable_5 + ISNULL(@cur_countable_5,0)

				SET @countable_6 = @countable_6 + ISNULL(@cur_countable_6,0)

				SET @countable_7 = @countable_7 + ISNULL(@cur_countable_7,0)

				SET @countable_8 = @countable_8 + ISNULL(@cur_countable_8,0)

				SET @countable_9 = @countable_9 + ISNULL(@cur_countable_9,0)



				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_5 = @rec_count_5 + CASE WHEN @cur_countable_5 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_6 = @rec_count_6 + CASE WHEN @cur_countable_6 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_7 = @rec_count_7 + CASE WHEN @cur_countable_7 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_8 = @rec_count_8 + CASE WHEN @cur_countable_8 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_9 = @rec_count_9 + CASE WHEN @cur_countable_9 IS NULL THEN 0 ELSE 1 END

			END

			ELSE IF @countable_count = 11

			BEGIN

				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)

				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)

				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)

				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)

				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)

				SET @countable_5 = @countable_5 + ISNULL(@cur_countable_5,0)

				SET @countable_6 = @countable_6 + ISNULL(@cur_countable_6,0)

				SET @countable_7 = @countable_7 + ISNULL(@cur_countable_7,0)

				SET @countable_8 = @countable_8 + ISNULL(@cur_countable_8,0)

				SET @countable_9 = @countable_9 + ISNULL(@cur_countable_9,0)

				SET @countable_10 = @countable_10 + ISNULL(@cur_countable_10,0)



				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_5 = @rec_count_5 + CASE WHEN @cur_countable_5 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_6 = @rec_count_6 + CASE WHEN @cur_countable_6 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_7 = @rec_count_7 + CASE WHEN @cur_countable_7 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_8 = @rec_count_8 + CASE WHEN @cur_countable_8 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_9 = @rec_count_9 + CASE WHEN @cur_countable_9 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_10 = @rec_count_10 + CASE WHEN @cur_countable_10 IS NULL THEN 0 ELSE 1 END

			END

			ELSE IF @countable_count = 12

			BEGIN

				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)

				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)

				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)

				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)

				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)

				SET @countable_5 = @countable_5 + ISNULL(@cur_countable_5,0)

				SET @countable_6 = @countable_6 + ISNULL(@cur_countable_6,0)

				SET @countable_7 = @countable_7 + ISNULL(@cur_countable_7,0)

				SET @countable_8 = @countable_8 + ISNULL(@cur_countable_8,0)

				SET @countable_9 = @countable_9 + ISNULL(@cur_countable_9,0)

				SET @countable_10 = @countable_10 + ISNULL(@cur_countable_10,0)

				SET @countable_11 = @countable_11 + ISNULL(@cur_countable_11,0)



				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_5 = @rec_count_5 + CASE WHEN @cur_countable_5 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_6 = @rec_count_6 + CASE WHEN @cur_countable_6 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_7 = @rec_count_7 + CASE WHEN @cur_countable_7 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_8 = @rec_count_8 + CASE WHEN @cur_countable_8 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_9 = @rec_count_9 + CASE WHEN @cur_countable_9 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_10 = @rec_count_10 + CASE WHEN @cur_countable_10 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_11 = @rec_count_11 + CASE WHEN @cur_countable_11 IS NULL THEN 0 ELSE 1 END

			END
			ELSE IF @countable_count = 13

			BEGIN

				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)

				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)

				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)

				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)

				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)

				SET @countable_5 = @countable_5 + ISNULL(@cur_countable_5,0)

				SET @countable_6 = @countable_6 + ISNULL(@cur_countable_6,0)

				SET @countable_7 = @countable_7 + ISNULL(@cur_countable_7,0)

				SET @countable_8 = @countable_8 + ISNULL(@cur_countable_8,0)

				SET @countable_9 = @countable_9 + ISNULL(@cur_countable_9,0)

				SET @countable_10 = @countable_10 + ISNULL(@cur_countable_10,0)

				SET @countable_11 = @countable_11 + ISNULL(@cur_countable_11,0)

				SET @countable_12 = @countable_12 + ISNULL(@cur_countable_12,0)



				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_5 = @rec_count_5 + CASE WHEN @cur_countable_5 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_6 = @rec_count_6 + CASE WHEN @cur_countable_6 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_7 = @rec_count_7 + CASE WHEN @cur_countable_7 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_8 = @rec_count_8 + CASE WHEN @cur_countable_8 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_9 = @rec_count_9 + CASE WHEN @cur_countable_9 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_10 = @rec_count_10 + CASE WHEN @cur_countable_10 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_11 = @rec_count_11 + CASE WHEN @cur_countable_11 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_12 = @rec_count_12 + CASE WHEN @cur_countable_12 IS NULL THEN 0 ELSE 1 END

			END

			ELSE IF @countable_count = 14

			BEGIN

				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)

				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)

				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)

				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)

				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)

				SET @countable_5 = @countable_5 + ISNULL(@cur_countable_5,0)

				SET @countable_6 = @countable_6 + ISNULL(@cur_countable_6,0)

				SET @countable_7 = @countable_7 + ISNULL(@cur_countable_7,0)

				SET @countable_8 = @countable_8 + ISNULL(@cur_countable_8,0)

				SET @countable_9 = @countable_9 + ISNULL(@cur_countable_9,0)

				SET @countable_10 = @countable_10 + ISNULL(@cur_countable_10,0)

				SET @countable_11 = @countable_11 + ISNULL(@cur_countable_11,0)

				SET @countable_12 = @countable_12 + ISNULL(@cur_countable_12,0)

				SET @countable_13 = @countable_13 + ISNULL(@cur_countable_13,0)



				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_5 = @rec_count_5 + CASE WHEN @cur_countable_5 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_6 = @rec_count_6 + CASE WHEN @cur_countable_6 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_7 = @rec_count_7 + CASE WHEN @cur_countable_7 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_8 = @rec_count_8 + CASE WHEN @cur_countable_8 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_9 = @rec_count_9 + CASE WHEN @cur_countable_9 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_10 = @rec_count_10 + CASE WHEN @cur_countable_10 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_11 = @rec_count_11 + CASE WHEN @cur_countable_11 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_12 = @rec_count_12 + CASE WHEN @cur_countable_12 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_13 = @rec_count_13 + CASE WHEN @cur_countable_13 IS NULL THEN 0 ELSE 1 END

			END

			ELSE IF @countable_count = 15

			BEGIN

				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)

				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)

				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)

				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)

				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)

				SET @countable_5 = @countable_5 + ISNULL(@cur_countable_5,0)

				SET @countable_6 = @countable_6 + ISNULL(@cur_countable_6,0)

				SET @countable_7 = @countable_7 + ISNULL(@cur_countable_7,0)

				SET @countable_8 = @countable_8 + ISNULL(@cur_countable_8,0)

				SET @countable_9 = @countable_9 + ISNULL(@cur_countable_9,0)

				SET @countable_10 = @countable_10 + ISNULL(@cur_countable_10,0)

				SET @countable_11 = @countable_11 + ISNULL(@cur_countable_11,0)

				SET @countable_12 = @countable_12 + ISNULL(@cur_countable_12,0)

				SET @countable_13 = @countable_13 + ISNULL(@cur_countable_13,0)

				SET @countable_14 = @countable_14 + ISNULL(@cur_countable_14,0)



				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_5 = @rec_count_5 + CASE WHEN @cur_countable_5 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_6 = @rec_count_6 + CASE WHEN @cur_countable_6 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_7 = @rec_count_7 + CASE WHEN @cur_countable_7 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_8 = @rec_count_8 + CASE WHEN @cur_countable_8 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_9 = @rec_count_9 + CASE WHEN @cur_countable_9 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_10 = @rec_count_10 + CASE WHEN @cur_countable_10 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_11 = @rec_count_11 + CASE WHEN @cur_countable_11 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_12 = @rec_count_12 + CASE WHEN @cur_countable_12 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_13 = @rec_count_13 + CASE WHEN @cur_countable_13 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_14 = @rec_count_14 + CASE WHEN @cur_countable_14 IS NULL THEN 0 ELSE 1 END

			END

			ELSE IF @countable_count = 16

			BEGIN

				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)

				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)

				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)

				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)

				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)

				SET @countable_5 = @countable_5 + ISNULL(@cur_countable_5,0)

				SET @countable_6 = @countable_6 + ISNULL(@cur_countable_6,0)

				SET @countable_7 = @countable_7 + ISNULL(@cur_countable_7,0)

				SET @countable_8 = @countable_8 + ISNULL(@cur_countable_8,0)

				SET @countable_9 = @countable_9 + ISNULL(@cur_countable_9,0)

				SET @countable_10 = @countable_10 + ISNULL(@cur_countable_10,0)

				SET @countable_11 = @countable_11 + ISNULL(@cur_countable_11,0)

				SET @countable_12 = @countable_12 + ISNULL(@cur_countable_12,0)

				SET @countable_13 = @countable_13 + ISNULL(@cur_countable_13,0)

				SET @countable_14 = @countable_14 + ISNULL(@cur_countable_14,0)

				SET @countable_15 = @countable_15 + ISNULL(@cur_countable_15,0)



				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_5 = @rec_count_5 + CASE WHEN @cur_countable_5 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_6 = @rec_count_6 + CASE WHEN @cur_countable_6 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_7 = @rec_count_7 + CASE WHEN @cur_countable_7 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_8 = @rec_count_8 + CASE WHEN @cur_countable_8 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_9 = @rec_count_9 + CASE WHEN @cur_countable_9 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_10 = @rec_count_10 + CASE WHEN @cur_countable_10 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_11 = @rec_count_11 + CASE WHEN @cur_countable_11 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_12 = @rec_count_12 + CASE WHEN @cur_countable_12 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_13 = @rec_count_13 + CASE WHEN @cur_countable_13 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_14 = @rec_count_14 + CASE WHEN @cur_countable_14 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_15 = @rec_count_15 + CASE WHEN @cur_countable_15 IS NULL THEN 0 ELSE 1 END

			END

			ELSE IF @countable_count = 17

			BEGIN

				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)

				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)

				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)

				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)

				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)

				SET @countable_5 = @countable_5 + ISNULL(@cur_countable_5,0)

				SET @countable_6 = @countable_6 + ISNULL(@cur_countable_6,0)

				SET @countable_7 = @countable_7 + ISNULL(@cur_countable_7,0)

				SET @countable_8 = @countable_8 + ISNULL(@cur_countable_8,0)

				SET @countable_9 = @countable_9 + ISNULL(@cur_countable_9,0)

				SET @countable_10 = @countable_10 + ISNULL(@cur_countable_10,0)

				SET @countable_11 = @countable_11 + ISNULL(@cur_countable_11,0)

				SET @countable_12 = @countable_12 + ISNULL(@cur_countable_12,0)

				SET @countable_13 = @countable_13 + ISNULL(@cur_countable_13,0)

				SET @countable_14 = @countable_14 + ISNULL(@cur_countable_14,0)

				SET @countable_15 = @countable_15 + ISNULL(@cur_countable_15,0)

				SET @countable_16 = @countable_16 + ISNULL(@cur_countable_16,0)



				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_5 = @rec_count_5 + CASE WHEN @cur_countable_5 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_6 = @rec_count_6 + CASE WHEN @cur_countable_6 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_7 = @rec_count_7 + CASE WHEN @cur_countable_7 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_8 = @rec_count_8 + CASE WHEN @cur_countable_8 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_9 = @rec_count_9 + CASE WHEN @cur_countable_9 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_10 = @rec_count_10 + CASE WHEN @cur_countable_10 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_11 = @rec_count_11 + CASE WHEN @cur_countable_11 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_12 = @rec_count_12 + CASE WHEN @cur_countable_12 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_13 = @rec_count_13 + CASE WHEN @cur_countable_13 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_14 = @rec_count_14 + CASE WHEN @cur_countable_14 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_15 = @rec_count_15 + CASE WHEN @cur_countable_15 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_16 = @rec_count_16 + CASE WHEN @cur_countable_16 IS NULL THEN 0 ELSE 1 END

			END

			ELSE IF @countable_count = 18

			BEGIN

				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)

				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)

				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)

				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)

				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)

				SET @countable_5 = @countable_5 + ISNULL(@cur_countable_5,0)

				SET @countable_6 = @countable_6 + ISNULL(@cur_countable_6,0)

				SET @countable_7 = @countable_7 + ISNULL(@cur_countable_7,0)

				SET @countable_8 = @countable_8 + ISNULL(@cur_countable_8,0)

				SET @countable_9 = @countable_9 + ISNULL(@cur_countable_9,0)

				SET @countable_10 = @countable_10 + ISNULL(@cur_countable_10,0)

				SET @countable_11 = @countable_11 + ISNULL(@cur_countable_11,0)

				SET @countable_12 = @countable_12 + ISNULL(@cur_countable_12,0)

				SET @countable_13 = @countable_13 + ISNULL(@cur_countable_13,0)

				SET @countable_14 = @countable_14 + ISNULL(@cur_countable_14,0)

				SET @countable_15 = @countable_15 + ISNULL(@cur_countable_15,0)

				SET @countable_16 = @countable_16 + ISNULL(@cur_countable_16,0)

				SET @countable_17 = @countable_17 + ISNULL(@cur_countable_17,0)



				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_5 = @rec_count_5 + CASE WHEN @cur_countable_5 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_6 = @rec_count_6 + CASE WHEN @cur_countable_6 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_7 = @rec_count_7 + CASE WHEN @cur_countable_7 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_8 = @rec_count_8 + CASE WHEN @cur_countable_8 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_9 = @rec_count_9 + CASE WHEN @cur_countable_9 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_10 = @rec_count_10 + CASE WHEN @cur_countable_10 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_11 = @rec_count_11 + CASE WHEN @cur_countable_11 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_12 = @rec_count_12 + CASE WHEN @cur_countable_12 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_13 = @rec_count_13 + CASE WHEN @cur_countable_13 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_14 = @rec_count_14 + CASE WHEN @cur_countable_14 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_15 = @rec_count_15 + CASE WHEN @cur_countable_15 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_16 = @rec_count_16 + CASE WHEN @cur_countable_16 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_17 = @rec_count_17 + CASE WHEN @cur_countable_17 IS NULL THEN 0 ELSE 1 END

			END

			ELSE IF @countable_count = 19

			BEGIN

				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)

				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)

				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)

				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)

				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)

				SET @countable_5 = @countable_5 + ISNULL(@cur_countable_5,0)

				SET @countable_6 = @countable_6 + ISNULL(@cur_countable_6,0)

				SET @countable_7 = @countable_7 + ISNULL(@cur_countable_7,0)

				SET @countable_8 = @countable_8 + ISNULL(@cur_countable_8,0)

				SET @countable_9 = @countable_9 + ISNULL(@cur_countable_9,0)

				SET @countable_10 = @countable_10 + ISNULL(@cur_countable_10,0)

				SET @countable_11 = @countable_11 + ISNULL(@cur_countable_11,0)

				SET @countable_12 = @countable_12 + ISNULL(@cur_countable_12,0)

				SET @countable_13 = @countable_13 + ISNULL(@cur_countable_13,0)

				SET @countable_14 = @countable_14 + ISNULL(@cur_countable_14,0)

				SET @countable_15 = @countable_15 + ISNULL(@cur_countable_15,0)

				SET @countable_16 = @countable_16 + ISNULL(@cur_countable_16,0)

				SET @countable_17 = @countable_17 + ISNULL(@cur_countable_17,0)

				SET @countable_18 = @countable_18 + ISNULL(@cur_countable_18,0)



				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_5 = @rec_count_5 + CASE WHEN @cur_countable_5 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_6 = @rec_count_6 + CASE WHEN @cur_countable_6 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_7 = @rec_count_7 + CASE WHEN @cur_countable_7 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_8 = @rec_count_8 + CASE WHEN @cur_countable_8 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_9 = @rec_count_9 + CASE WHEN @cur_countable_9 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_10 = @rec_count_10 + CASE WHEN @cur_countable_10 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_11 = @rec_count_11 + CASE WHEN @cur_countable_11 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_12 = @rec_count_12 + CASE WHEN @cur_countable_12 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_13 = @rec_count_13 + CASE WHEN @cur_countable_13 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_14 = @rec_count_14 + CASE WHEN @cur_countable_14 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_15 = @rec_count_15 + CASE WHEN @cur_countable_15 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_16 = @rec_count_16 + CASE WHEN @cur_countable_16 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_17 = @rec_count_17 + CASE WHEN @cur_countable_17 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_18 = @rec_count_18 + CASE WHEN @cur_countable_18 IS NULL THEN 0 ELSE 1 END

			END

			ELSE IF @countable_count = 20

			BEGIN

				SET @countable_0 = @countable_0 + ISNULL(@cur_countable_0,0)

				SET @countable_1 = @countable_1 + ISNULL(@cur_countable_1,0)

				SET @countable_2 = @countable_2 + ISNULL(@cur_countable_2,0)

				SET @countable_3 = @countable_3 + ISNULL(@cur_countable_3,0)

				SET @countable_4 = @countable_4 + ISNULL(@cur_countable_4,0)

				SET @countable_5 = @countable_5 + ISNULL(@cur_countable_5,0)

				SET @countable_6 = @countable_6 + ISNULL(@cur_countable_6,0)

				SET @countable_7 = @countable_7 + ISNULL(@cur_countable_7,0)

				SET @countable_8 = @countable_8 + ISNULL(@cur_countable_8,0)

				SET @countable_9 = @countable_9 + ISNULL(@cur_countable_9,0)

				SET @countable_10 = @countable_10 + ISNULL(@cur_countable_10,0)

				SET @countable_11 = @countable_11 + ISNULL(@cur_countable_11,0)

				SET @countable_12 = @countable_12 + ISNULL(@cur_countable_12,0)

				SET @countable_13 = @countable_13 + ISNULL(@cur_countable_13,0)

				SET @countable_14 = @countable_14 + ISNULL(@cur_countable_14,0)

				SET @countable_15 = @countable_15 + ISNULL(@cur_countable_15,0)

				SET @countable_16 = @countable_16 + ISNULL(@cur_countable_16,0)

				SET @countable_17 = @countable_17 + ISNULL(@cur_countable_17,0)

				SET @countable_18 = @countable_18 + ISNULL(@cur_countable_18,0)

				SET @countable_19 = @countable_19 + ISNULL(@cur_countable_19,0)



				SET @rec_count_0 = @rec_count_0 + CASE WHEN @cur_countable_0 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_1 = @rec_count_1 + CASE WHEN @cur_countable_1 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_2 = @rec_count_2 + CASE WHEN @cur_countable_2 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_3 = @rec_count_3 + CASE WHEN @cur_countable_3 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_4 = @rec_count_4 + CASE WHEN @cur_countable_4 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_5 = @rec_count_5 + CASE WHEN @cur_countable_5 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_6 = @rec_count_6 + CASE WHEN @cur_countable_6 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_7 = @rec_count_7 + CASE WHEN @cur_countable_7 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_8 = @rec_count_8 + CASE WHEN @cur_countable_8 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_9 = @rec_count_9 + CASE WHEN @cur_countable_9 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_10 = @rec_count_10 + CASE WHEN @cur_countable_10 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_11 = @rec_count_11 + CASE WHEN @cur_countable_11 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_12 = @rec_count_12 + CASE WHEN @cur_countable_12 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_13 = @rec_count_13 + CASE WHEN @cur_countable_13 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_14 = @rec_count_14 + CASE WHEN @cur_countable_14 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_15 = @rec_count_15 + CASE WHEN @cur_countable_15 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_16 = @rec_count_16 + CASE WHEN @cur_countable_16 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_17 = @rec_count_17 + CASE WHEN @cur_countable_17 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_18 = @rec_count_18 + CASE WHEN @cur_countable_18 IS NULL THEN 0 ELSE 1 END

				SET @rec_count_19 = @rec_count_19 + CASE WHEN @cur_countable_19 IS NULL THEN 0 ELSE 1 END

			END -- up to 20 countables

		END -- pass 1 (count for) or 2 (contributing to the counters)

	END -- @FetchStatusCalc = 0



-- Process the next record

IF @countable_count = 1

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0

END

ELSE IF @countable_count = 2

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1

END

ELSE IF @countable_count = 3

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2

END

ELSE IF @countable_count = 4

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3

END

ELSE IF @countable_count = 5

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4

END

ELSE IF @countable_count = 6

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5

END

ELSE IF @countable_count = 7

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,

	@cur_countable_6

END

ELSE IF @countable_count = 8

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,

	@cur_countable_6,@cur_countable_7

END

ELSE IF @countable_count = 9

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,

	@cur_countable_6,@cur_countable_7,@cur_countable_8

END

ELSE IF @countable_count = 10

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,

	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9

END

ELSE IF @countable_count = 11

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,

	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10

END

ELSE IF @countable_count = 12

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,

	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11

END

ELSE IF @countable_count = 13

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,

	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,

	@cur_countable_12

END

ELSE IF @countable_count = 14

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,
	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,

	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,

	@cur_countable_12,@cur_countable_13

END

ELSE IF @countable_count = 15

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,

	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,

	@cur_countable_12,@cur_countable_13,@cur_countable_14

END

ELSE IF @countable_count = 16

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,

	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,

	@cur_countable_12,@cur_countable_13,@cur_countable_14,@cur_countable_15

END

ELSE IF @countable_count = 17

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,

	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,

	@cur_countable_12,@cur_countable_13,@cur_countable_14,@cur_countable_15,@cur_countable_16

END

ELSE IF @countable_count = 18

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,

	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,

	@cur_countable_12,@cur_countable_13,@cur_countable_14,@cur_countable_15,@cur_countable_16,@cur_countable_17

END

ELSE IF @countable_count = 19

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,

	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,

	@cur_countable_12,@cur_countable_13,@cur_countable_14,@cur_countable_15,@cur_countable_16,@cur_countable_17,

	@cur_countable_18

END

ELSE IF @countable_count = 20

BEGIN

	FETCH NEXT FROM calc_cursor INTO 

	@cur_id_pass,@cur_id_sess,@cur_id_acc,@cur_group_acc_flag,@cur_group_acc_id,@cur_pci_id_interval,@cur_dt_session,

	@cur_ui_dt_start,@cur_ui_dt_end,@cur_pci_dt_start,@cur_pci_dt_end,

	@cur_countable_0,@cur_countable_1,@cur_countable_2,@cur_countable_3,@cur_countable_4,@cur_countable_5,

	@cur_countable_6,@cur_countable_7,@cur_countable_8,@cur_countable_9,@cur_countable_10,@cur_countable_11,

	@cur_countable_12,@cur_countable_13,@cur_countable_14,@cur_countable_15,@cur_countable_16,@cur_countable_17,

	@cur_countable_18,@cur_countable_19

END -- fetch next



SET @FetchStatusCalc = @@FETCH_STATUS

END -- loop



CLOSE calc_cursor

DEALLOCATE calc_cursor



END -- of the linear approach 12/31/2002



----------------------------------------------------------------

-- Retrieve the result set

----------------------------------------------------------------

SET @SQLStmt = ''

SET @SQLStmt = 

N'SELECT tp1.id_sess, au.id_parent_sess, 

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



--PRINT 'completed: all'

--PRINT CONVERT(char, getdate(), 109)



SET @return_code = 0

RETURN 0



FatalErrorCursor_calc:

	CLOSE calc_cursor

	DEALLOCATE calc_cursor



FatalError:

	SET @return_code = -1



	-- Added on 2/19/2003

	SET @SQLStmt = N'IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'''

			+ CAST(@tmp_tbl_name1 AS nvarchar(50)) 

			+ N''') and OBJECTPROPERTY(id, N''IsUserTable'') = 1)'

			+ N' DROP TABLE ' + CAST(@tmp_tbl_name1 AS nvarchar(50))

	-- PRINT @SQLStmt 

	EXEC sp_executesql @SQLStmt



	SET @SQLStmt = N'IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'''

			+ CAST(@tmp_tbl_name12 AS nvarchar(50)) 

			+ N''') and OBJECTPROPERTY(id, N''IsUserTable'') = 1)'

			+ N' DROP TABLE ' + CAST(@tmp_tbl_name12 AS nvarchar(50))
	-- PRINT @SQLStmt 

	EXEC sp_executesql @SQLStmt



	SET @SQLStmt = N'IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'''

			+ CAST(@tmp_tbl_name2 AS nvarchar(50)) 

			+ N''') and OBJECTPROPERTY(id, N''IsUserTable'') = 1)'

			+ N' DROP TABLE ' + CAST(@tmp_tbl_name2 AS nvarchar(50))

	-- PRINT @SQLStmt 

	EXEC sp_executesql @SQLStmt



	SET @SQLStmt = N'IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'''

			+ CAST(@tmp_tbl_name3 AS nvarchar(50)) 

			+ N''') and OBJECTPROPERTY(id, N''IsUserTable'') = 1)'

			+ N' DROP TABLE ' + CAST(@tmp_tbl_name3 AS nvarchar(50))

	-- PRINT @SQLStmt 

	EXEC sp_executesql @SQLStmt



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

DECLARE @varTblName varchar(128), @SQLStmt varchar(1000), @SQLError int,

	@PrintStmt varchar(1000), @varStatPercentChar varchar(255)



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


  

CREATE PROCEDURE MarkEventAsFailed

(

  @dt_now DATETIME,

  @id_instance INT,

  @id_acc INT,

  @tx_detail VARCHAR(2048),

  @tx_machine VARCHAR(128),

  @status INT OUTPUT

)

AS

BEGIN

  BEGIN TRAN

  SELECT @status = -99



  UPDATE t_recevent_inst 

  SET tx_status = 'Failed'

  WHERE 

    id_instance = @id_instance AND

    tx_status = 'Succeeded'

  

  IF @@ROWCOUNT = 1  -- successfully updated

  BEGIN

    -- inserts a run to record the fact that the status was changed

    -- this is important for 'cancel' to work correctly in reverse situations

    DECLARE @id_run INT

    EXEC GetCurrentID 'receventrun', @id_run OUTPUT

    INSERT INTO t_recevent_run

    (

      id_run,

      id_instance,

      tx_type,

      id_reversed_run,

      tx_machine,

      dt_start,

      dt_end,

      tx_status,

      tx_detail

    )

    VALUES 

    (

      @id_run,

      @id_instance,

      'Execute',

      NULL,

      @tx_machine,

      @dt_now,

      @dt_now,

      'Failed',

      'Manually changed status to Failed'

    )



    -- audits the action

    INSERT INTO t_recevent_inst_audit(id_instance,id_acc,tx_action,b_ignore_deps,dt_effective,tx_detail,dt_crt)

    VALUES(@id_instance, @id_acc, 'MarkAsFailed', NULL, NULL, @tx_detail, @dt_now) 



    SELECT @status = 0  -- success

    COMMIT

    RETURN

  END



  --

  -- update did not occur, so lets figure out why

  --



  -- does the instance exist?

  SELECT 1

  FROM t_recevent_inst 

  WHERE 

    id_instance = @id_instance



  IF @@ROWCOUNT = 0

  BEGIN

    SELECT @status = -1  -- instance does not exist

    ROLLBACK

    RETURN -1

  END



  SELECT @status = -2  -- instance was not in a valid state

  ROLLBACK

  RETURN -2



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


  

CREATE PROCEDURE MarkEventAsSucceeded

(

  @dt_now DATETIME,

  @id_instance INT,

  @id_acc INT,

  @tx_detail VARCHAR(2048),

  @tx_machine VARCHAR(128),

  @status INT OUTPUT

)

AS

BEGIN

  BEGIN TRAN



  SELECT @status = -99



  UPDATE t_recevent_inst 

  SET tx_status = 'Succeeded'

  WHERE 

    id_instance = @id_instance AND

    tx_status = 'Failed'

  

  IF @@ROWCOUNT = 1  -- successfully updated

  BEGIN

    -- inserts a run to record the fact that the status was changed

    -- this is important for 'cancel' to work correctly in reverse situations

    DECLARE @id_run INT

    EXEC GetCurrentID 'receventrun', @id_run OUTPUT

    INSERT INTO t_recevent_run

    (

      id_run,

      id_instance,

      tx_type,

      id_reversed_run,

      tx_machine,

      dt_start,

      dt_end,

      tx_status,

      tx_detail

    )

    VALUES 

    (

      @id_run,

      @id_instance,

      'Execute',

      NULL,

      @tx_machine,

      @dt_now,

      @dt_now,

      'Succeeded',

      'Manually changed status to Succeeded'

    )



    -- audits the action

    INSERT INTO t_recevent_inst_audit(id_instance,id_acc,tx_action,b_ignore_deps,dt_effective,tx_detail,dt_crt)

    VALUES(@id_instance, @id_acc, 'MarkAsSucceeded', NULL, NULL, @tx_detail, @dt_now) 



    SELECT @status = 0  -- success

    COMMIT

    RETURN

  END



  --

  -- update did not occur, so lets figure out why

  --



  -- does the instance exist?

  SELECT 1

  FROM t_recevent_inst 

  WHERE 

    id_instance = @id_instance



  IF @@ROWCOUNT = 0

  BEGIN

    SELECT @status = -1  -- instance does not exist

    ROLLBACK

    RETURN -1

  END



  SELECT @status = -2  -- instance was not in a valid state

  ROLLBACK

  RETURN -2



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


			

			CREATE PROC ModifyBatchStatus

			  @tx_batch varchar(255),

				@dt_change datetime,

				@tx_new_status char(1),

				@id_batch int output,

				@tx_current_status char(1) output,

				@status int output

			AS

			BEGIN

				SELECT

				  @id_batch = id_batch,

				  @tx_current_status = tx_status

				FROM

				  t_batch

				WHERE

				  tx_batch_encoded = @tx_batch

				-- Batch does not exist	

				IF (@@rowcount = 0)

				BEGIN

				  -- MTBATCH_BATCH_DOES_NOT_EXIST ((DWORD)0xE4020007L)

				  SELECT @status = -469630969

					RETURN

				END



				-- State transition business rules 

				IF (

				    ((@tx_new_status = 'F') AND 

				     ((@tx_current_status = 'D') OR (@tx_current_status = 'B')))

						OR

						((@tx_new_status = 'D') AND 

						 ((@tx_current_status = 'A') OR (@tx_current_status = 'C') OR 

						  (@tx_current_status = 'F')))

						OR

						((@tx_new_status = 'C') AND 

						 ((@tx_current_status = 'D') OR (@tx_current_status = 'B')))

						OR

						((@tx_new_status = 'A') AND 

						 ((@tx_current_status = 'D') OR (@tx_current_status = 'C') OR 

						  (@tx_current_status = 'F')))

						OR

						((@tx_new_status = 'B') AND 

						 ((@tx_current_status = 'A') OR (@tx_current_status = 'D') OR

						  (@tx_current_status = 'C')))

						)

				BEGIN

				 	-- MTBATCH_STATE_CHANGE_NOT_PERMITTED ((DWORD)0xE4020007L)

				 	SELECT @status = -469630968

					RETURN

				END

	

				UPDATE 

			  	t_batch 

				SET 

			  	tx_status = @tx_new_status

				WHERE

			  	tx_batch_encoded = @tx_batch



	    	SELECT @status = 1 

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


				

Create procedure MoveAccount 

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

	select @status = count(*) 

	from t_account_ancestor 

	where id_ancestor = @p_id_ancestor 

	and id_descendent = @p_id_descendent 

	and num_generations = 1

	and @realstartdate >= vt_start 

	and vt_end = @varMaxDateTime

	if @status > 0 

   begin 

		-- MT_NEW_ANCESTOR_IS_ALREADY_ A_ANCESTOR
	 select @status = 1

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

			select @status=count(*) 

			from t_account_ancestor 

			where id_descendent = @p_id_descendent  

			and id_ancestor = @p_id_ancestor

			and num_generations = 1

			AND	vt_start <= @realstartdate

			and vt_end <> dbo.mtmaxdate()



			-- check if we need to update any existing end_dates for same ancestor.


			if @status > 0 

			begin

				update  t_account_ancestor 

				set vt_end = dbo.mtmaxdate()

				where id_descendent =  @p_id_descendent

				and id_ancestor = @p_id_ancestor

				and num_generations = 1

				and vt_start <= @realstartdate

				and vt_end <> dbo.mtmaxdate()

			end

			else

			begin	

				insert into t_account_ancestor (id_ancestor,id_descendent,num_generations,b_children,vt_start,vt_end,tx_path)

				values (@p_id_ancestor,@p_id_descendent,1,'N',@realstartdate,dbo.mtmaxdate(),

				dbo.mtconcat(CAST(@p_id_ancestor as varchar(100)),dbo.mtconcat('/',cast(@p_id_descendent as varchar(100)))))

			end





			-- check if we need to update any existing end_dates.



			update t_account_ancestor set vt_end = dbo.subtractsecond(@realstartdate)

			where id_descendent = @p_id_descendent AND num_generations = 1 ANd

			@realstartdate between vt_start AND vt_end AND vt_end <> @VarMaxDateTime

			-- this query is redudant from below



			insert into t_account_ancestor (id_ancestor,id_descendent,

			num_generations,b_children,vt_start,vt_end,tx_path) 

			select

			new_parents.id_ancestor new_ancestor,

			level_children.id_descendent existing_descendent,

			new_parents.num_generations + 1,

			level_children.b_children,

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

			and dbo.mtminoftwodates(new_parents.vt_end,level_children.vt_end) > dbo.mtmaxoftwodates(new_parents.vt_start,level_children.vt_start)



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

		delete parent_list

		 from t_account_ancestor existing_children

		INNER JOIN t_account_ancestor parent_list on parent_list.id_descendent = existing_children.id_descendent

		AND parent_list.num_generations not in (0,1) 

		and existing_children.vt_start > @realstartdate

		and parent_list.vt_end = dbo.MTmaxdate()

		where existing_children.id_ancestor = @p_id_descendent

		and parent_list.id_ancestor<>@p_id_descendent

		 insert into t_account_ancestor

		 (id_ancestor,id_descendent,num_generations,b_children,vt_start,vt_end,tx_path)

			select

			 -- the list of of ancestors

			parent.id_ancestor,

			existing_children.id_descendent,

			existing_children.num_generations + parent.num_generations + 1,

			existing_children.b_Children,

			dbo.MTMaxOfTwoDates((dbo.MTMaxOfTwoDates(parent.vt_start,existing_children.vt_start)),@realstartdate) startdate,

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


  

CREATE PROCEDURE OpenUsageInterval

(

  @dt_now DATETIME,     -- MetraTech system date

  @id_interval INT,     -- specific usage interval to reopen, the interval must be soft-closed

  @ignoreDeps INT,      -- whether to ignore the reverse dependencies for re-opening the interval

  @pretend INT,         -- if pretend is true, the interval is not actually reopened

  @status INT OUTPUT    -- return code: 0 is successful

)

AS

BEGIN

  BEGIN TRAN



  SELECT @status = -999



  -- checks that the interval is soft closed

  DECLARE @count INT

  SELECT @count = COUNT(*)

  FROM t_usage_interval

  WHERE 

    id_interval = @id_interval AND

    tx_interval_status = 'C'

 

  IF @count = 0

  BEGIN

    SELECT @count = COUNT(*)

    FROM t_usage_interval

    WHERE id_interval = @id_interval



    IF @count = 0

      -- interval not found

      SELECT @status = -1

    ELSE

      -- interval not soft closed

      SELECT @status = -2

  

    ROLLBACK

    RETURN

  END



  --

  -- retrieves the instance ID of the start root event for the given interval

  --

  DECLARE @id_instance INT

  SELECT @id_instance = inst.id_instance

  FROM t_recevent_inst inst

  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event

  WHERE

    -- event must be active

    evt.dt_activated <= @dt_now and

    (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) AND

    -- instance must match the given interval

    inst.id_arg_interval = @id_interval AND

    evt.tx_name = '_StartRoot' AND

    evt.tx_type = 'Root'



  IF @id_instance IS NULL

  BEGIN

    -- start root instance was not found!

    SELECT @status = -3

    ROLLBACK

    RETURN

  END

  

  

  --

  -- checks start root's reversal dependencies

  --

  IF @ignoreDeps = 0

  BEGIN

    SELECT @count = COUNT(*)

    FROM GetEventReversalDeps(@dt_now, @id_instance) deps

    WHERE deps.tx_status <> 'NotYetRun'



    IF @count > 0

    BEGIN

      -- not all instances in the interval have been reversed successfuly

      SELECT @status = -4

      ROLLBACK

      RETURN

    END   

  END



  -- just pretending, so don't do the update

  IF @pretend != 0

  BEGIN

    SELECT @status = 0 -- success

    COMMIT

    RETURN

  END  



  UPDATE t_usage_interval SET tx_interval_status = 'O'

  WHERE 

    id_interval = @id_interval AND

    tx_interval_status = 'C'



  IF @@ROWCOUNT = 1

  BEGIN

    SELECT @status = 0 -- success

    COMMIT

  END

  ELSE

  BEGIN

    -- couldn't update the interval

    SELECT @status = -5

    ROLLBACK

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


            

create procedure ReRunAbandon(@id_rerun int) as

begin

	BEGIN TRAN



	delete from t_rerun_sessions where id_rerun = @id_rerun

	delete from t_rerun_history where id_rerun = @id_rerun

	delete from t_rerun where id_rerun = @id_rerun



	COMMIT TRAN

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


            

create procedure ReRunAnalyze(@id_rerun int) as

begin

	BEGIN TRAN



	update t_rerun_sessions

	  set   id_sess = au.id_sess,

		id_parent = au.id_parent_sess,

		-- TODO: id_root

		id_interval = au.id_usage_interval,

		id_view = au.id_view,

    tx_state = 'A'

		from t_acc_usage au

		inner join t_usage_interval ui on au.id_usage_interval = ui.id_interval

		where au.tx_UID = t_rerun_sessions.tx_UID

		and tx_state = 'I'

		and id_rerun = @id_rerun



	update t_rerun_sessions

	  set   tx_state = 'E', id_interval = 0

		from t_rerun_sessions

		-- TODO: this doesn't look at the error state

    inner join t_failed_transaction on t_rerun_sessions.tx_UID = t_failed_transaction.tx_FailureCompoundID

    where t_rerun_sessions.id_rerun = @id_rerun



-- TODO: do we need this?

--	update t_rerun_sessions

--	  set   tx_state = 'N'

--		where id_sess is null and tx_state = 'I' and id_rerun = @id_rerun



	exec ReRunIdentifyCompounds @id_rerun



	COMMIT TRAN

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


            

create procedure ReRunCreate(@tx_filter varchar(255),

			@id_acc int,

			@tx_comment varchar(255),

			@dt_system_date datetime,

			@id_rerun int output)

as

begin

  begin tran



  insert into t_rerun (tx_filter, tx_tag) values(@tx_filter, null)

  set @id_rerun = @@identity



  insert into t_rerun_history (id_rerun, dt_action, tx_action,

		id_acc, tx_comment)

	values (@id_rerun, @dt_system_date, 'CREATE', @id_acc,

		@tx_comment)

  commit

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


            

create procedure ReRunIdentifyCompounds(@id_rerun int)

as

begin



	BEGIN TRAN



	declare @rows_changed int



	-- just so the loop will run the first time

	set @rows_changed = 1



	while @rows_changed > 0

	begin

	

		-- find children

		insert into t_rerun_sessions

		  select @id_rerun,		-- id_rerun

			au.tx_UID,

			au.id_sess,		-- id_sess

			au.id_parent_sess,	-- id_parent

			null,			-- TODO: root

			au.id_usage_interval,	-- id_interval

			au.id_view,		-- id_view

			case ui.tx_interval_status when 'H' then 'C' else 'A' end -- c_state

			from t_acc_usage au

			inner join t_rerun_sessions rr on au.id_parent_sess = rr.id_sess

			inner join t_usage_interval ui on au.id_usage_interval = ui.id_interval

			where rr.id_rerun = @id_rerun

      and not exists (select * from t_rerun_sessions where t_rerun_sessions.id_sess = au.id_sess and t_rerun_sessions.id_rerun = @id_rerun)

	

		set @rows_changed = @@ROWCOUNT

	

		-- find parents

		insert into t_rerun_sessions

		  select @id_rerun,			-- id_rerun

			auparents.tx_UID,

			auparents.id_sess,		-- id_sess

			auparents.id_parent_sess,	-- id_parent

			null,				-- TODO: root

			auparents.id_usage_interval,	-- id_interval

			auparents.id_view,		-- id_view

			case ui.tx_interval_status when 'H' then 'C' else 'A' end -- c_state

			from t_acc_usage auchild

			inner join t_rerun_sessions rr on auchild.id_sess = rr.id_sess

			inner join t_acc_usage auparents on auparents.id_sess = auchild.id_parent_sess

			inner join t_usage_interval ui on auparents.id_usage_interval = ui.id_interval

			where rr.id_rerun = @id_rerun

      and not exists (select * from t_rerun_sessions where t_rerun_sessions.id_sess = auparents.id_sess and t_rerun_sessions.id_rerun = @id_rerun)

	

		set @rows_changed = @rows_changed + @@ROWCOUNT

	end



	-- now identify the root sessions.

	-- root sessions have no parents

	update t_rerun_sessions set id_root = id_sess

		where id_parent IS NULL

			and id_root IS NULL

			and id_rerun = @id_rerun



	-- just so the loop will run the first time

	set @rows_changed = 1



	-- find children that have a parent whose root is known.

	-- copy the parent root to the child root

	while @rows_changed > 0

	begin

		update rrchildren

			set id_root = rrparents.id_root

			from t_rerun_sessions rrchildren 

			inner join t_rerun_sessions rrparents on rrchildren.id_parent = rrparents.id_sess

			where rrchildren.id_root is null and rrparents.id_root is not null

			and rrchildren.id_rerun = @id_rerun and rrparents.id_rerun = @id_rerun



		set @rows_changed = @@ROWCOUNT

	end



	commit

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


            

create procedure ReRunRollback(@id_rerun int) as

BEGIN

	BEGIN TRAN



	-- values we get from the cursor

	declare @tablename varchar(255)

	declare @id_view int

	

	DECLARE tablename_cursor CURSOR FOR

	select rr.id_view, pv.nm_table_name from 

		t_prod_view pv

		inner join t_rerun_sessions rr on rr.id_view = pv.id_view

		where rr.id_rerun = @id_rerun and rr.tx_state = 'A'
		group by rr.id_view, pv.nm_table_name

	OPEN tablename_cursor

	FETCH NEXT FROM tablename_cursor into @id_view, @tablename

	WHILE @@FETCH_STATUS = 0

	BEGIN

	   declare @sql varchar(255)

	   set @sql = 'DELETE from ' + @tablename

			+ ' where id_sess in (select id_sess from t_rerun_sessions '

			+ ' where id_rerun = ' + CAST(@id_rerun AS VARCHAR)

				+ ' and id_view = ' + CAST(@id_view AS VARCHAR)

				+ ' and tx_state = ''A'''

			+ ')'

	   exec (@sql)

	   FETCH NEXT FROM tablename_cursor into @id_view, @tablename

	END

	CLOSE tablename_cursor

	DEALLOCATE tablename_cursor

	

	-- now the easier task of deleting the rows from t_acc_usage

	delete from t_acc_usage where id_sess in

	   (select id_sess from t_rerun_sessions

			where id_rerun = @id_rerun

			and tx_state = 'A')



	-- delete the errors

	delete t_failed_transaction_msix from t_failed_transaction_msix

	   inner join t_failed_transaction on 

          t_failed_transaction.id_failed_transaction = t_failed_transaction_msix.id_failed_transaction

     inner join t_rerun_sessions on

          t_rerun_sessions.tx_uid = t_failed_transaction.tx_failurecompoundid

     where t_rerun_sessions.id_rerun = @id_rerun and t_rerun_sessions.tx_state = 'E'



	delete t_failed_transaction from t_failed_transaction

     inner join t_rerun_sessions on t_failed_transaction.tx_failurecompoundid = t_rerun_sessions.tx_uid

     where t_rerun_sessions.id_rerun = @id_rerun and tx_state = 'E'



	-- update the rerun table so we know these have been backed out

	update t_rerun_sessions set tx_state = 'B' where (tx_state = 'A' or tx_state = 'E') and id_rerun = @id_rerun



	COMMIT

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


        

			    create proc RemoveAdjustmentTypeProps

          @p_id_prop int

          AS

          BEGIN

            DECLARE @propid INT

            DECLARE CursorVar CURSOR STATIC

            FOR SELECT id_prop FROM T_ADJUSTMENT_TYPE_PROP WHERE id_adjustment_type =@p_id_prop

            OPEN CursorVar

            DELETE FROM T_ADJUSTMENT_TYPE_PROP WHERE id_adjustment_type =@p_id_prop

            FETCH NEXT FROM CursorVar into  @propid

            WHILE @@FETCH_STATUS = 0

            BEGIN

              exec DeleteBaseProps @propid

              FETCH NEXT FROM CursorVar into  @propid

            END

          CLOSE CursorVar

          DEALLOCATE CursorVar

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


        

					create proc RemoveCounterInstance

											@id_prop int

					AS

					BEGIN TRAN

            DELETE FROM T_COUNTER_PARAM_PREDICATE WHERE id_counter_param IN 

              (SELECT id_counter_param FROM t_counter_params WHERE id_counter = @id_prop)

						DELETE FROM T_COUNTER_PARAMS WHERE id_counter = @id_prop

						DELETE FROM T_COUNTER WHERE id_prop = @id_prop

						DELETE FROM T_BASE_PROPS WHERE id_prop = @id_prop

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


         

					CREATE PROC RemoveCounterPropDef

											@id_prop int

					AS

						DECLARE @id_locale int

					BEGIN TRAN

						exec DeleteBaseProps @id_prop

						DELETE FROM t_counter_map 

							WHERE id_cpd = @id_prop 

						DELETE FROM t_counterpropdef WHERE id_prop = @id_prop

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


		 

				create procedure RemoveGroupSubMember(

				@id_acc int,

				@p_substartdate datetime,

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

						where id_acc = @id_acc 

									AND id_group = @id_group 

									AND vt_start > @p_systemdate



						if (@startdate is null)

							begin

								select @status = -486604776

								return

							end

					end



				-- The logic here is the following:

				-- We have a parameter called p_substartdate. We need it to identify the proper record to delete,

				-- in case we have multiple participations for the same account on a group sub.

				-- But this parameter is optional to the object - so if it is not passed in, we will delete

				-- all participations of this account. Otherwise, we delete just the participation with the provided

				-- start date.

 				if (@p_substartdate = dbo.MTMaxDate())

					begin

					  delete from t_gsubmember where id_acc = @id_acc and id_group = @id_group

						update t_gsubmember_historical set tt_end = dbo.subtractsecond(@p_systemdate)

							where id_acc = @id_acc 

										and id_group = @id_group

										and tt_end = @varMaxDateTime

					end

				else

					begin

					  delete from t_gsubmember where id_acc = @id_acc and id_group = @id_group and @p_substartdate = vt_start

						update t_gsubmember_historical set tt_end = dbo.subtractsecond(@p_systemdate)

						where id_acc = @id_acc 

							and id_group = @id_group

							and tt_end = @varMaxDateTime

							and @p_substartdate = vt_start

					end

					

				-- If-else structure above is not very elegant, both options very similar, but I will not get fancy right now

				-- done



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


		

create procedure RemoveGroupSubscription(
	@p_id_sub int,
	@p_systemdate datetime,
	@p_status int OUTPUT)

	as

	begin
		
	 	declare @groupID int
		declare @maxdate datetime		
		declare @nmembers int

		set @p_status = 0

		select @groupID = id_group,@maxdate = dbo.mtmaxdate()
		from t_sub where id_sub = @p_id_sub

		select @nmembers = count(*) from t_gsubmember_historical where id_group = @groupID
		if @nmembers > 0
			begin
				-- We don't support deleting group subs if this group sub ever had a member
				select @p_status = 1
				return
			end		
		
	  delete from t_gsub_recur_map where id_group = @groupID
	  delete from t_recur_value where id_sub = @p_id_sub

		-- Eventually we would need to make sure that the rules for each icb rate schedule are removed from the proper parameter tables
		delete from t_pl_map where id_sub = @p_id_sub

		update t_recur_value set tt_end = @p_systemdate 
			where id_sub = @p_id_sub and tt_end = @maxdate
		update t_sub_history set tt_end = @p_systemdate
			where tt_end = @maxdate and id_sub = @p_id_sub

		delete from t_sub where id_sub = @p_id_sub
		update t_group_sub set tx_name = CAST('[DELETED ' + CAST(GetDate() as nvarchar) + ']' + tx_name as nvarchar(255)) where id_group = @groupID

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


        

          CREATE PROCEDURE RemoveServiceEndpointIDMapping

            @a_id_se int,

	          @a_id_corp int,

            @a_id VARCHAR(255),

            @a_space VARCHAR(40),

            @a_status int OUTPUT

          AS BEGIN

            DECLARE @a_temp AS INT

            DECLARE @b_primary AS VARCHAR(1)

            DECLARE @a_transaction_started as int



      	    IF @@trancount = 0 BEGIN

              BEGIN TRAN

             SET @a_transaction_started = 1

            END               

            

            SET @a_status = 0

          

            --See if the mapping exists

            IF @a_id_corp IS NULL BEGIN

              SELECT @a_temp = COUNT(*) FROM t_se_mapper WHERE id_se = @a_id_se AND id_corp IS NULL AND LOWER(nm_login) = LOWER(@a_id) AND LOWER(nm_space) = LOWER(@a_space)

            END

            ELSE BEGIN

              SELECT @a_temp = COUNT(*) FROM t_se_mapper WHERE id_se = @a_id_se AND id_corp = @a_id_corp AND LOWER(nm_login) = LOWER(@a_id) AND LOWER(nm_space) = LOWER(@a_space)

            END



           IF @a_temp = 0 BEGIN

             SET @a_status = -483458955

              GOTO errHandler

            END



            --See if this is the primary mapping, if so, the new primary must be set

            IF @a_id_corp IS NULL BEGIN

              SELECT @b_primary = b_primary FROM t_se_mapper WHERE id_se = @a_id_se AND id_corp IS NULL AND LOWER(nm_login) = LOWER(@a_id) AND LOWER(nm_space) = LOWER(@a_space)

            END

            ELSE BEGIN

              SELECT @b_primary = b_primary FROM t_se_mapper WHERE id_se = @a_id_se AND id_corp = @a_id_corp AND LOWER(nm_login) = LOWER(@a_id) AND LOWER(nm_space) = LOWER(@a_space)

            END

            

            --Don't allow the primary mapping to be removed

            IF @b_primary = '1' BEGIN

              SET @a_status = -483458949

              GOTO errHandler

            END



            --Remove the entry

            IF @a_id_corp IS NULL BEGIN

              DELETE FROM t_se_mapper WHERE id_se = @a_id_se AND id_corp IS NULL AND LOWER(nm_login) = LOWER(@a_id) AND LOWER(nm_space) = LOWER(@a_space)

              SET @a_status = @@error

              IF @a_status <> 0 BEGIN

                GOTO errHandler

              END              

            END

            ELSE BEGIN

              DELETE FROM t_se_mapper WHERE id_se = @a_id_se AND id_corp = @a_id_corp AND LOWER(nm_login) = LOWER(@a_id) AND LOWER(nm_space) = LOWER(@a_space)

              SET @a_status = @@error

              IF @a_status <> 0 BEGIN

                GOTO errHandler

              END

            END

            

            --If primary, select a new primary

           --IF @b_primary = '1' BEGIN

            --See if this is the only entry for this se

            --  SELECT @a_temp = COUNT(*) FROM t_se_mapper WHERE id_se = @a_id_se



            --If there are other mappings, make the first the 

      	     -- IF @a_temp <> 0 BEGIN

             --   UPDATE

             --     t_se_mapper

             --   SET

             --     b_primary = '1'

             --   WHERE

             --     id_se IN (SELECT TOP 1 id_se FROM t_se_mapper WHERE id_se = @a_id_se)



             --   SET @a_status = @@error

             --   IF @a_status <> 0 BEGIN

             --     GOTO errHandler

             --   END   

             -- END

            -- END



            --Commit and return

            IF @a_transaction_started = 1 BEGIN

              COMMIT TRAN

              SET @a_status = 0

              RETURN

            END

            

            errHandler:

            IF @a_transaction_started = 1 BEGIN

              ROLLBACK TRAN

            END

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


		

create procedure RemoveSubscription(

	@p_id_sub int,

	@p_systemdate datetime)

	as

	begin

 	declare @groupID int

	declare @maxdate datetime

  declare @icbID int

	declare @status int

	select @groupID = id_group,@maxdate = dbo.mtmaxdate()

	from t_sub where id_sub = @p_id_sub



  -- Look for an ICB pricelist and delete it if it exists

	select distinct @icbID = id_pricelist from t_pl_map where id_sub=@p_id_sub



  if (@groupID is not NULL)

		begin

		update t_gsubmember_historical set tt_end = @p_systemdate 

		where tt_end = @maxdate AND id_group = @groupID

		delete from t_gsubmember where id_group = @groupID

    delete from t_gsub_recur_map where id_group = @groupID

		-- note that we do not delete from t_group_sub

		end   

	delete from t_pl_map where id_sub = @p_id_sub

	delete from t_sub where id_sub = @p_id_sub

	update t_recur_value set tt_end = @p_systemdate 

	where id_sub = @p_id_sub and tt_end = @maxdate

	update t_sub_history set tt_end = @p_systemdate

	where tt_end = @maxdate AND id_sub = @p_id_sub



	if (@icbID is not NULL)

  begin

    exec sp_DeletePricelist @icbID, @status

    if @status <> 0 return

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


      

			CREATE PROCEDURE ReversePayments

			  @id_interval int,

			  @id_enum int,

				@status int OUTPUT

			AS

			BEGIN

			  /*************************************************

				** Procedure Name: MTSP_REVERSE_PAYMENT_BILLING

				** 

				** Procedure Description: 

				**

				** Parameters: 

				**

				** Returns: 0 if successful

				**          -1 if fatal error occurred

				**

				** Created By: Ning Zhuang

				** Created On: 12/10/2002

				** Last Modified On: 

				**************************************************/

				SET @status = -1

	

				-- It is not necessary to use the temp table here.

				-- However, since there is currently no index on the 

				-- t_acc_uage.id_usage_interval column, to improve the 

				-- performance, the temp table is used so that the 

				-- id_sess be looked up only once for the two deletions.



				-- Delete only those records that are still in pending approval

				-- status

				SELECT pv.id_sess

				INTO #tmp

				FROM t_pv_ps_paymentscheduler pv

				INNER JOIN t_acc_usage au

				ON au.id_sess = pv.id_sess

				AND pv.c_originalintervalid = @id_interval

				AND pv.c_currentstatus = @id_enum

				IF @@ERROR <> 0 GOTO FatalError

					
				DELETE FROM t_acc_usage

				WHERE id_sess IN (SELECT id_sess FROM #tmp)

				IF @@ERROR <> 0 GOTO FatalError

				

				DELETE FROM t_pv_ps_paymentscheduler

				WHERE id_sess IN (SELECT id_sess FROM #tmp)

				IF @@ERROR <> 0 GOTO FatalError

				

				DROP TABLE #tmp

				IF @@ERROR <> 0 GOTO FatalError

				

				SET @status = 0

				RETURN 0

				

				FatalError:

			  	SET @status = -1

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


			  

				CREATE PROCEDURE Reverse_UpdStateFromClosedToArchived (

					@system_date datetime, -- no longer used, 2-21-2003

					@dt_start datetime,

					@dt_end datetime,

					@age int,
					@status INT output)

				AS

				Begin

					declare @varMaxDateTime datetime

					-- declare @varSystemGMTDateTimeSOD datetime



					SELECT @status = -1



					-- Use the true current GMT time for the tt_ dates

					-- SELECT @varSystemGMTDateTimeSOD = dbo.mtstartofday(@system_date)



					-- Set the maxdatetime into a variable

					SELECT @varMaxDateTime = dbo.MTMaxDate()



					-- ======================================================================

					-- Identify the id_accs whose state need to be reversed to 'CL' from 'AR'



					-- Save the id_acc

					CREATE TABLE #updatestate_00 (id_acc int)

					INSERT INTO  #updatestate_00 (id_acc)

					SELECT DISTINCT ast.id_acc 

					FROM t_account_state ast

					WHERE ast.status = 'CL' 

					AND ast.vt_start BETWEEN (dbo.mtstartofday(@dt_start) - @age) AND 

					                         (DATEADD(s, -1, dbo.mtstartofday(@dt_end) + 1) - @age)

 					if (@@error <>0)

					begin

	  					RETURN

					end



					-- Currently have 'AR' state

					CREATE TABLE #updatestate_0 (id_acc int, vt_start datetime, tt_start datetime)

					INSERT INTO  #updatestate_0 (id_acc, vt_start, tt_start)

					SELECT tmp.id_acc, ash.vt_start, ash.tt_start

					FROM #updatestate_00 tmp

					INNER JOIN t_account_state_history ash

						ON ash.id_acc = tmp.id_acc

						AND ash.status = 'AR'

						AND ash.tt_end = @varMaxDateTime 

						AND ash.vt_end = @varMaxDateTime 

						--AND ash.tt_start >= @system_date

 					if (@@error <>0)

					begin

	  					RETURN

					end



					-- Make sure these 'AR' id_accs were immediately from the 'CL' status

					-- And save these id_accs whose state WILL be updated to a temp 

					CREATE TABLE #updatestate_1(id_acc int, tt_end datetime)

					INSERT INTO #updatestate_1 (id_acc, tt_end)

					SELECT tmp.id_acc, ash.tt_end

					FROM #updatestate_0 tmp

					INNER JOIN t_account_state_history ash

						ON ash.id_acc = tmp.id_acc

						AND ash.status = 'CL'

						AND ash.vt_start < tmp.vt_start

						AND ash.vt_end = @varMaxDateTime 

						AND ash.tt_end = DATEADD(ms, -10, tmp.tt_start)

 					if (@@error <>0)

					begin

	  					RETURN

					end



					-- Reverse actions for the identified id_accs

					EXEC Reverse_UpdateStateRecordSet @status OUTPUT



					DROP TABLE #updatestate_0

					DROP TABLE #updatestate_00

					DROP TABLE #updatestate_1

					

					--select @status=1

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


			  

				CREATE PROCEDURE Reverse_UpdateStateFromClosedToPFB (

					@system_date datetime,

					@dt_start datetime,

					@dt_end datetime,

					@status INT output)

				AS

				Begin

					declare @varMaxDateTime datetime

					declare @varSystemGMTDateTime datetime 

					declare @varSystemGMTBDateTime datetime  

					declare @varSystemGMTEDateTime datetime 



					select @status = -1



					-- Use the true current GMT time for the tt_ dates

					SELECT @varSystemGMTDateTime = @system_date



					-- Set the maxdatetime into a variable

					select @varMaxDateTime = dbo.MTMaxDate()



					select @varSystemGMTBDateTime = dbo.mtstartofday(@dt_start - 1)

					select @varSystemGMTEDateTime = DATEADD(s, -1, dbo.mtstartofday(@dt_end) + 1)



					-- ======================================================================

					-- Identify the id_accs whose state need to be reversed to 'CL' from 'PF'



					-- Save those id_acc whose state MAY be updated to a temp table

					-- (had usage between @dt_start and @dt_end)

					CREATE TABLE #updatestate_00 (id_acc int)

					INSERT INTO  #updatestate_00 (id_acc)

					SELECT DISTINCT id_acc 

					FROM (SELECT id_acc FROM t_acc_usage au

					      WHERE au.dt_crt between @varSystemGMTBDateTime and @varSystemGMTEDateTime) ttt

					-- consider adjustments as well as usage

					UNION 

					  SELECT DISTINCT id_acc_payer AS id_acc

  					FROM (SELECT id_acc_payer FROM t_adjustment_transaction ajt

					WHERE  ajt.c_status = 'A' AND 

						ajt.dt_modified between @varSystemGMTBDateTime and @varSystemGMTEDateTime) ttt

 					if (@@error <>0)

					begin

	  					RETURN

					end



					-- Currently have 'PF' state

					CREATE TABLE #updatestate_0 (id_acc int, vt_start datetime, tt_start datetime)

					INSERT INTO  #updatestate_0 (id_acc, vt_start, tt_start)

					SELECT tmp.id_acc, ash.vt_start, ash.tt_start

					FROM #updatestate_00 tmp

					INNER JOIN t_account_state_history ash

						ON ash.id_acc = tmp.id_acc

						AND ash.status = 'PF'

						AND ash.tt_end = @varMaxDateTime 

						AND ash.tt_start >= @system_date

 					if (@@error <>0)

					begin

	  					RETURN

					end



					-- Make sure these 'PF' id_accs were immediately from the 'CL' status

					-- And save these id_accs whose state WILL be updated to a temp 

					CREATE TABLE #updatestate_1(id_acc int, tt_end datetime)

					INSERT INTO #updatestate_1 (id_acc, tt_end)

					SELECT tmp.id_acc, ash.tt_end

					FROM #updatestate_0 tmp

					INNER JOIN t_account_state_history ash

						ON ash.id_acc = tmp.id_acc

						AND ash.status = 'CL'

						AND ash.vt_start < tmp.vt_start

						AND ash.vt_end = @varMaxDateTime 

						AND ash.tt_end = DATEADD(ms, -10, tmp.tt_start)

 					if (@@error <>0)

					begin

	  					RETURN

					end



					-- Reverse actions for the identified id_accs

					EXEC Reverse_UpdateStateRecordSet @status OUTPUT



					DROP TABLE #updatestate_0

					DROP TABLE #updatestate_00

					DROP TABLE #updatestate_1

					

					--select @status=1

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


			  

				CREATE PROCEDURE Reverse_UpdateStateFromPFBToClosed (

					@id_interval INT,

					@ref_date DATETIME,

					@system_date datetime,

					@status INT OUTPUT)

				AS

 				BEGIN

					DECLARE @ref_date_mod DATETIME, 

						@varMaxDateTime DATETIME,

						@CurrentSystemGMTDateTime DATETIME,

						@ref_date_modSOD DATETIME



					SELECT @status = -1

					-- Set the maxdatetime into a variable

					SELECT @varMaxDateTime = dbo.MTMaxDate()

					SELECT @CurrentSystemGMTDateTime = getutcdate()



					IF (@ref_date IS NULL)

					BEGIN

						SELECT @ref_date_mod = @system_date

					END
					ELSE

					BEGIN

						SELECT @ref_date_mod = @ref_date

					END



					SELECT @ref_date_modSOD = dbo.mtstartofday(@ref_date_mod)



					-- Save those id_acc whose state MAY be reversed to a temp table 

					CREATE TABLE #updatestate_0 (id_acc int, vt_start datetime, tt_start datetime)



					INSERT INTO #updatestate_0 (id_acc, vt_start, tt_start)

					SELECT aui.id_acc, ash.vt_start, ash.tt_start

					FROM t_acc_usage_interval aui

					INNER JOIN t_usage_interval ui 

						ON ui.id_interval = aui.id_usage_interval

					INNER JOIN t_account_state_history ash

						ON ash.id_acc = aui.id_acc

						AND ash.status = 'CL'

						AND ash.tt_end = @varMaxDateTime 

						AND ash.tt_start > ui.dt_end

					WHERE aui.id_usage_interval = @id_interval

 					if (@@error <>0)

					begin

	  					RETURN

					end



					-- Make sure these 'CL' id_accs were immediately from the 'PF' status

					-- And save those id_acc whose state WILL be updated to a temp 

					CREATE TABLE #updatestate_1(id_acc int, tt_end datetime)



					INSERT INTO #updatestate_1 (id_acc, tt_end)

					SELECT tmp.id_acc, ash.tt_end

					FROM #updatestate_0 tmp

					INNER JOIN t_account_state_history ash

						ON ash.id_acc = tmp.id_acc

						AND ash.status = 'PF'

						AND ash.vt_start < tmp.vt_start

						AND ash.vt_end = @varMaxDateTime 

						AND ash.tt_end = DATEADD(ms, -10, tmp.tt_start)

 					if (@@error <>0)

					begin

	  					RETURN

					end



					-- follow same pattern for t_gsubmember_historical and t_gsubmember.

					declare @varSystemGMTDateTime datetime

					SELECT @varSystemGMTDateTime = @system_date

					declare @rowcnt int

					SELECT @rowcnt = count(*)

					FROM #updatestate_1

 					if (@@error <>0)

					begin

	  					RETURN

					end



					IF @rowcnt > 0

					BEGIN

					-- ------------------------------------------------------------

					-- ------------------- reverse t_sub & t_sub_history ------------------

					-- ------------------------------------------------------------



						-- Find those records that were updated by the PFBToCL 

						-- and have not yet been updated again

						-- and thus can be reversed

						SELECT sh2.id_sub, sh2.vt_end, sh2.tt_end

						INTO #updatesub_1

						FROM (SELECT sh.id_sub, sh.tt_start

							FROM t_sub_history sh

							INNER JOIN #updatestate_1 tmp

								ON tmp.id_acc = sh.id_acc

								AND sh.vt_end = DATEADD(s, -1, @ref_date_modSOD)

								AND sh.tt_end = @varMaxDateTime

							) rev

						INNER JOIN t_sub_history sh2

							ON sh2.id_sub = rev.id_sub

							AND sh2.tt_end = DATEADD(ms, -10, rev.tt_start)

 						if (@@error <>0)

						begin

	  						RETURN

						end



						UPDATE t_sub_history

						SET tt_end = DATEADD(ms, -10, @CurrentSystemGMTDateTime)

						FROM t_sub_history sh

						INNER JOIN #updatesub_1 tmp

							ON tmp.id_sub = sh.id_sub
							AND sh.tt_end = @varMaxDateTime

 						if (@@error <>0)

						begin

	  						RETURN

						end



						INSERT INTO t_sub_history

						(id_sub,id_sub_ext,id_acc,id_po,dt_crt,id_group,vt_start,vt_end,tt_start,tt_end )

						SELECT sh.id_sub,sh.id_sub_ext,sh.id_acc,sh.id_po,

							sh.dt_crt,sh.id_group,sh.vt_start,sh.vt_end,

							@CurrentSystemGMTDateTime,@varMaxDateTime

						FROM t_sub_history sh

						INNER JOIN #updatesub_1 tmp

							ON tmp.id_sub = sh.id_sub

							AND tmp.tt_end = sh.tt_end

 						if (@@error <>0)

						begin

	  						RETURN

						end



						UPDATE t_sub

						SET vt_end = tmp.vt_end

						FROM t_sub sh

						INNER JOIN #updatesub_1 tmp

							ON tmp.id_sub = sh.id_sub

 						if (@@error <>0)

						begin

	  						RETURN

						end

					-- ------------------------------------------------------------

					-- ------------------- t_sub & t_sub_history ------------------

					-- ------------------------------------------------------------



					-- ------------------------------------------------------------

					-- ------------ reverse t_gsubmember & t_gsubmember_historical --------

					-- ------------------------------------------------------------



						-- Find those records that were updated by the PFBToCL 

						-- and have not yet been updated again

						-- and thus can be reversed

						SELECT gh2.id_group, gh2.id_acc, gh2.vt_start, gh2.vt_end, gh2.tt_end

						INTO #updategsub_1

						FROM (SELECT gh.id_group, gh.id_acc, gh.vt_start, gh.vt_end, gh.tt_start

							FROM t_gsubmember_historical gh

							INNER JOIN #updatestate_1 tmp

								ON tmp.id_acc = gh.id_acc

								AND gh.vt_end = DATEADD(s, -1, @ref_date_modSOD)

								AND gh.tt_end = @varMaxDateTime

							) rev

						INNER JOIN t_gsubmember_historical gh2

							ON gh2.id_group = rev.id_group

							AND gh2.id_acc = rev.id_acc

							AND gh2.vt_start = rev.vt_start

							AND gh2.tt_end = DATEADD(ms, -10, rev.tt_start)

 						if (@@error <>0)

						begin

	  						RETURN

						end



						UPDATE t_gsubmember_historical

						SET tt_end = DATEADD(ms, -10, @CurrentSystemGMTDateTime)

						FROM t_gsubmember_historical gh

						INNER JOIN #updategsub_1 tmp

							ON tmp.id_group = gh.id_group

							AND tmp.id_acc = gh.id_acc

							AND tmp.vt_start = gh.vt_start

							AND gh.tt_end = @varMaxDateTime

 						if (@@error <>0)

						begin

	  						RETURN

						end



						INSERT INTO t_gsubmember_historical

						(id_group, id_acc, vt_start, vt_end, tt_start, tt_end)

						SELECT gh.id_group, gh.id_acc, gh.vt_start, gh.vt_end,

							@CurrentSystemGMTDateTime,@varMaxDateTime

						FROM t_gsubmember_historical gh

						INNER JOIN #updategsub_1 tmp

							ON tmp.id_group = gh.id_group

							AND tmp.id_acc = gh.id_acc

							AND tmp.vt_start = gh.vt_start

							AND tmp.tt_end = gh.tt_end

 						if (@@error <>0)

						begin

	  						RETURN

						end



						UPDATE t_gsubmember

						SET vt_end = tmp.vt_end

						FROM t_gsubmember gh

						INNER JOIN #updategsub_1 tmp

							ON tmp.id_group = gh.id_group

							AND tmp.id_acc = gh.id_acc

							AND tmp.vt_start = gh.vt_start

 						if (@@error <>0)

						begin

	  						RETURN

						end



					-- ------------------------------------------------------------

					-- ------------ t_gsubmember & t_gsubmember_historical --------

					-- ------------------------------------------------------------

					END

					-- Reverse actions for the identified id_accs

					EXEC Reverse_UpdateStateRecordSet @status OUTPUT



					--select @status = 1

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


			  

				CREATE PROCEDURE Reverse_UpdateStateRecordSet (

					@status INT output)

				AS

				Begin

					declare @varMaxDateTime datetime

					declare @CurrentSystemGMTDateTime DATETIME



					select @status = -1



					-- Set the maxdatetime into a variable

					select @varMaxDateTime = dbo.MTMaxDate()



					select @CurrentSystemGMTDateTime = getutcdate()



					-- Reverse actions for the identified id_accs



					-- Remove the existing set of states for these id_accs

					DELETE FROM t_account_state

					WHERE id_acc IN (SELECT id_acc from #updatestate_1)

 					if (@@error <>0)

					begin

	  					RETURN

					end



					-- Add the reversed set of states back for these id_accs

					INSERT INTO t_account_state (id_acc,status,vt_start,vt_end)

					SELECT tmp.id_acc, ash.status, ash.vt_start, ash.vt_end 

					FROM t_account_state_history ash

					INNER JOIN #updatestate_1 tmp

						ON ash.id_acc = tmp.id_acc

						AND tmp.tt_end BETWEEN ash.tt_start AND ash.tt_end

 					if (@@error <>0)

					begin

	  					RETURN

					end

					

					-- Update the tt_end in history

					UPDATE t_account_state_history

					SET tt_end = DATEADD(ms, -10, @CurrentSystemGMTDateTime)

					FROM t_account_state_history ash

					INNER JOIN #updatestate_1 tmp

						ON tmp.id_acc = ash.id_acc

						AND ash.tt_end = @varMaxDateTime 

 					if (@@error <>0)

					begin

	  					RETURN

					end



					-- Record these changes to the history table

					INSERT INTO t_account_state_history

					(id_acc,status,vt_start,vt_end,tt_start,tt_end)

					SELECT tmp.id_acc, ash.status, ash.vt_start, ash.vt_end, 

						@CurrentSystemGMTDateTime, @varMaxDateTime 

					FROM t_account_state_history ash

					INNER JOIN #updatestate_1 tmp

						ON tmp.id_acc = ash.id_acc

						AND tmp.tt_end BETWEEN ash.tt_start AND ash.tt_end

 					if (@@error <>0)

					begin

	  					RETURN

					end



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


		

create procedure SequencedDeleteGsubRecur 
			@p_id_group_sub int,
			@p_id_prop int,
			@p_vt_start datetime,
			@p_vt_end datetime,
			@p_tt_current datetime,
			@p_tt_max datetime,
			@p_status int OUTPUT
		as
		begin
		  SET @p_status = 0
      INSERT INTO t_gsub_recur_map(id_prop, id_group, id_acc, vt_start, vt_end, tt_start, tt_end) 
        SELECT id_prop, id_group, id_acc, dateadd(s,1,@p_vt_end) AS vt_start, vt_end, @p_tt_current as tt_start, @p_tt_max as tt_end
        FROM t_gsub_recur_map 
        WHERE id_prop = @p_id_prop AND id_group = @p_id_group_sub AND vt_start < @p_vt_start AND vt_end > @p_vt_end and tt_end = @p_tt_max;
      IF @@error <> 0
      BEGIN
        SET @p_status = @@error
        return
      END
			-- Valid time update becomes bi-temporal insert and update
      INSERT INTO t_gsub_recur_map(id_prop, id_group, id_acc, vt_start, vt_end, tt_start, tt_end) 
      SELECT id_prop, id_group, id_acc, vt_start, dateadd(s,-1,@p_vt_start) AS vt_end, @p_tt_current AS tt_start, @p_tt_max AS tt_end 
      FROM t_gsub_recur_map WHERE id_prop = @p_id_prop AND id_group = @p_id_group_sub AND vt_start < @p_vt_start AND vt_end >= @p_vt_start AND tt_end = @p_tt_max;
        UPDATE t_gsub_recur_map SET tt_end = dateadd(s, -1, @p_tt_current) WHERE id_prop = @p_id_prop AND id_group = @p_id_group_sub AND vt_start < @p_vt_start AND vt_end >= @p_vt_start AND tt_end = @p_tt_max;
      IF @@error <> 0
      BEGIN
        SET @p_status = @@error
        return
      END
			-- Valid time update becomes bi-temporal insert (of the modified existing history into the past history) and update (of the modified existing history)
      INSERT INTO t_gsub_recur_map(id_prop, id_group, id_acc, vt_start, vt_end, tt_start, tt_end) 
      SELECT id_prop, id_group, id_acc, dateadd(s,1,@p_vt_end) AS vt_start, vt_end, @p_tt_current AS tt_start, @p_tt_max AS tt_end 
      FROM t_gsub_recur_map WHERE id_prop = @p_id_prop AND id_group = @p_id_group_sub AND vt_start < @p_vt_end AND vt_end >= @p_vt_end AND tt_end = @p_tt_max;
      UPDATE t_gsub_recur_map SET tt_end = dateadd(s, -1, @p_tt_current) WHERE id_prop = @p_id_prop AND id_group = @p_id_group_sub AND vt_start < @p_vt_end AND vt_end >= @p_vt_end AND tt_end = @p_tt_max;
      IF @@error <> 0
      BEGIN
        SET @p_status = @@error
        return
      END
      -- Now we delete any interval contained entirely in the interval we are deleting.
      -- Transaction table delete is really an update of the tt_end
      --   [----------------]                 (interval that is being modified)
      -- [------------------------]           (interval we are deleting)
      UPDATE t_gsub_recur_map SET tt_end = dateadd(s, -1, @p_tt_current)
      WHERE id_prop = @p_id_prop AND id_group = @p_id_group_sub AND vt_start >= @p_vt_start AND vt_end <= @p_vt_end AND tt_end = @p_tt_max;
      IF @@error <> 0
      BEGIN
        SET @p_status = @@error
        return
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


		

		create procedure SequencedInsertGsubRecur 
			@p_id_group_sub int,
			@p_id_prop int,
			@p_id_acc int,
			@p_vt_start datetime,
			@p_vt_end datetime,
			@p_tt_current datetime,
			@p_tt_max datetime,
			@p_status int OUTPUT
		as
		begin
		  DECLARE @cnt INTEGER
      SET @p_status = 0
			-- I admit this is a bit wierd, but what I am doing is detecting
			-- a referential integrity failure without generating an error.
			-- This is needed because SQL Server won't let one suppress the
			-- RI failure (and this causes an exception up in ADO land).
			-- This is a little more concise (and perhaps more performant)
			-- than multiple queries up front.
		  INSERT INTO t_gsub_recur_map(id_group, id_prop, id_acc, vt_start, vt_end, tt_start, tt_end) 
			SELECT s.id_group, r.id_prop, a.id_acc, @p_vt_start, @p_vt_end, @p_tt_current, @p_tt_max
      FROM t_sub s
      CROSS JOIN t_account a
      CROSS JOIN t_recur r
      WHERE 
      s.id_group=@p_id_group_sub
      AND
			a.id_acc=@p_id_acc
      AND
      r.id_prop=@p_id_prop

			IF @@rowcount = 1 RETURN

			-- No row, look for specific RI failure to give better message
		  SELECT @cnt = COUNT(*) FROM t_recur where id_prop = @p_id_prop
			IF @cnt = 0 
        BEGIN
          -- MTPC_CHARGE_ACCOUNT_ONLY_ON_RC
				  SET @p_status = -490799065
				  RETURN
        END
		  SELECT @cnt = COUNT(*) FROM t_account where id_acc = @p_id_acc
			IF @cnt = 0 
        BEGIN
          -- KIOSK_ERR_ACCOUNT_NOT_FOUND
				  SET @p_status = -515899365
				  RETURN
        END
		  SELECT @cnt = COUNT(*) FROM t_sub where id_group = @p_id_group_sub
			IF @cnt = 0 
        BEGIN
          -- Return E_FAIL absent better info
				  SET @p_status = -2147483607
				  RETURN
        END
			-- Return E_FAIL absent better info
      SET @p_status = -2147483607
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


		

		create procedure SequencedInsertGsubRecurInitialize
			@p_id_group_sub int,
			@p_id_prop int,
			@p_id_acc int,
			@p_tt_current datetime,
			@p_tt_max datetime,
			@p_status int OUTPUT
		as
		begin
		  DECLARE @cnt INTEGER
      SET @p_status = 0
			-- I admit this is a bit wierd, but what I am doing is detecting
			-- a referential integrity failure without generating an error.
			-- This is needed because SQL Server won't let one suppress the
			-- RI failure (and this causes an exception up in ADO land).
			-- This is a little more concise (and perhaps more performant)
			-- than multiple queries up front.
		  INSERT INTO t_gsub_recur_map(id_group, id_prop, id_acc, vt_start, vt_end, tt_start, tt_end) 
			SELECT s.id_group, r.id_prop, a.id_acc, vt_start, vt_end, @p_tt_current, @p_tt_max
      FROM t_sub s
      CROSS JOIN t_account a
      CROSS JOIN t_recur r
      WHERE 
      s.id_group=@p_id_group_sub
      AND
			a.id_acc=@p_id_acc
      AND
      r.id_prop=@p_id_prop

			IF @@rowcount = 1 RETURN

			-- No row, look for specific RI failure to give better message
		  SELECT @cnt = COUNT(*) FROM t_recur where id_prop = @p_id_prop
			IF @cnt = 0 
        BEGIN
          -- MTPC_CHARGE_ACCOUNT_ONLY_ON_RC
				  SET @p_status = -490799065
				  RETURN
        END
		  SELECT @cnt = COUNT(*) FROM t_account where id_acc = @p_id_acc
			IF @cnt = 0 
        BEGIN
          -- KIOSK_ERR_ACCOUNT_NOT_FOUND
				  SET @p_status = -515899365
				  RETURN
        END
		  SELECT @cnt = COUNT(*) FROM t_sub where id_group = @p_id_group_sub
			IF @cnt = 0 
        BEGIN
          -- Return E_FAIL absent better info
				  SET @p_status = -2147483607
				  RETURN
        END
			-- Return E_FAIL absent better info
      SET @p_status = -2147483607
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


		

		create procedure SequencedUpsertGsubRecur 
			@p_id_group_sub int,
			@p_id_prop int,
			@p_id_acc int,
			@p_vt_start datetime,
			@p_vt_end datetime,
			@p_tt_current datetime,
			@p_tt_max datetime,
			@p_status int OUTPUT
		as
		begin
		  set @p_status = 0
		  exec SequencedDeleteGsubRecur @p_id_group_sub, @p_id_prop, @p_vt_start, @p_vt_end, @p_tt_current, @p_tt_max, @p_status output
      if @p_status <> 0 return
		  exec SequencedInsertGsubRecur @p_id_group_sub, @p_id_prop, @p_id_acc, @p_vt_start, @p_vt_end, @p_tt_current, @p_tt_max, @p_status output
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


			 create procedure SetTariffs (@id_enum_tariff varchar(255),
			 @tx_currency varchar (255))	 
			 as 
			 if not exists (select * from t_tariff where id_enum_tariff = 
			 @id_enum_tariff and tx_currency = @tx_currency) 
			 begin 
				 insert into t_tariff (id_enum_tariff, tx_currency) values (
				 @id_enum_tariff, @tx_currency)
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


  

CREATE PROCEDURE SoftCloseUsageIntervals

(

  @dt_now DATETIME,     -- MetraTech system date

  @id_interval INT,     -- specific usage interval to close or null for automatic detection based on grace periods

  @pretend INT,         -- if pretend is true no intervals are closed but instead are just returned

  @n_count INT OUTPUT   -- the number of usage intervals closed (or that would have been closed)

)

AS

BEGIN

  BEGIN TRAN



  DECLARE @closing_intervals TABLE

  (

    id_interval INT NOT NULL,

    id_usage_cycle INT NOT NULL,

    id_cycle_type INT NOT NULL,

    dt_start DATETIME NOT NULL,

    dt_end DATETIME NOT NULL,

    tx_interval_status VARCHAR(1) NOT NULL

  )



  -- determines which intervals to close

  IF (@id_interval IS NULL)

  BEGIN

    -- looks at all the intervals in the system

    INSERT INTO @closing_intervals

    SELECT ui.id_interval, ui.id_usage_cycle, uct.id_cycle_type, ui.dt_start, ui.dt_end, 'C'

    FROM t_usage_interval ui

    INNER JOIN t_usage_cycle uc ON uc.id_usage_cycle = ui.id_usage_cycle

    INNER JOIN t_usage_cycle_type uct ON uct.id_cycle_type = uc.id_cycle_type

    WHERE

      CASE WHEN uct.n_grace_period IS NOT NULL THEN

        -- take into account the cycle type's grace period

        ui.dt_end + uct.n_grace_period 

      ELSE

        -- the grace period has been disabled, so don't close this interval

        @dt_now

      END < @dt_now AND

      ui.tx_interval_status = 'O'



    SET @n_count = @@ROWCOUNT

  END

  ELSE

  BEGIN

    -- only close the given interval (regardless of grace period/end date)

    INSERT INTO @closing_intervals

    SELECT ui.id_interval, ui.id_usage_cycle, uct.id_cycle_type, ui.dt_start, ui.dt_end, ui.tx_interval_status

    FROM t_usage_interval ui

    INNER JOIN t_usage_cycle uc ON uc.id_usage_cycle = ui.id_usage_cycle

    INNER JOIN t_usage_cycle_type uct ON uct.id_cycle_type = uc.id_cycle_type

    WHERE ui.tx_interval_status = 'O'

          AND ui.id_interval = @id_interval



    SET @n_count = @@ROWCOUNT

  END



  -- only closes the intervals if pretend is false

  IF @pretend = 0

  BEGIN

    UPDATE t_usage_interval

    SET tx_interval_status = 'C'

    FROM t_usage_interval ui

    INNER JOIN @closing_intervals cui ON cui.id_interval = ui.id_interval



    -- adds instance entries for each interval that closed

    INSERT INTO t_recevent_inst(id_event,id_arg_interval,dt_arg_start,dt_arg_end,b_ignore_deps,dt_effective,tx_status)

    SELECT 

      evt.id_event id_event,

      cui.id_interval id_arg_interval,

      NULL dt_arg_start,

      NULL dt_arg_end,

      'N' b_ignore_deps,

      NULL dt_effective,

      -- the start root event is created as Succeeded

      -- the end root event is created as ReadyToRun (for auto hard close)

      -- all others are created as  NotYetRun

      CASE WHEN evt.tx_name = '_StartRoot' AND evt.tx_type = 'Root' THEN 'Succeeded' 

           WHEN evt.tx_name = '_EndRoot'   AND evt.tx_type = 'Root' THEN 'ReadyToRun' ELSE

           'NotYetRun' 

      END tx_status

    FROM @closing_intervals cui

    INNER JOIN t_usage_cycle uc ON uc.id_usage_cycle = cui.id_usage_cycle

    INNER JOIN t_recevent_schedule sch ON 

               -- the schedule is not constrained in any way

               ((sch.id_cycle_type IS NULL AND sch.id_cycle IS NULL) OR

               -- the schedule's cycle type is constrained

               (sch.id_cycle_type = uc.id_cycle_type) OR

               -- the schedule's cycle is constrained

               (sch.id_cycle = uc.id_usage_cycle))

    INNER JOIN t_recevent evt ON evt.id_event = sch.id_event

    WHERE 

      -- event must be active

      evt.dt_activated <= @dt_now and

      (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) AND

      -- event must be of type: root, end-of-period or checkpoint

      (evt.tx_type in ('Root', 'EndOfPeriod', 'Checkpoint')) AND

      evt.id_event NOT IN 

      (

        -- only adds instances if they are missing

        -- this guards against extra instances after closing -> reopening -> closing

        SELECT evt.id_event

        FROM @closing_intervals cui 

        INNER JOIN t_recevent_inst inst ON inst.id_arg_interval = cui.id_interval

        INNER JOIN t_recevent evt ON evt.id_event = inst.id_event

        WHERE  

          -- event must be active

          evt.dt_activated <= @dt_now and

          (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated)

      )

  END



  SELECT * FROM @closing_intervals

  COMMIT

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


  

CREATE PROCEDURE SubmitEventForExecution

(

  @dt_now DATETIME,

  @id_instance INT,

  @b_ignore_deps VARCHAR(1),

  @dt_effective DATETIME,

  @id_acc INT,

  @tx_detail VARCHAR(2048),

  @status INT OUTPUT

)

AS

BEGIN



  BEGIN TRAN



  SELECT @status = -99



  -- if the event is a checkpoint, synchronously acknowledges it

  DECLARE @isCheckpoint INT

  SELECT @isCheckpoint = 1 

  FROM t_recevent_inst inst

  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event
  WHERE 

    inst.id_instance = @id_instance AND

    evt.tx_type = 'Checkpoint'



  IF (@isCheckpoint = 1)

  BEGIN

    EXEC AcknowledgeCheckpoint @dt_now, @id_instance, @b_ignore_deps, @id_acc, @tx_detail, @status OUTPUT

    IF (@status = 0)

      COMMIT

    ELSE

      ROLLBACK

    RETURN 

  END



  -- updates the run state to 'ReadyToRun' only after the run is valid

  UPDATE t_recevent_inst

  SET tx_status = 'ReadyToRun', b_ignore_deps = @b_ignore_deps, dt_effective = @dt_effective

  FROM t_recevent_inst inst INNER JOIN t_recevent evt ON evt.id_event = inst.id_event

  LEFT OUTER JOIN t_usage_interval ui ON ui.id_interval = inst.id_arg_interval

  WHERE 

    -- event is active

    evt.dt_activated <= @dt_now AND

    (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) AND

    inst.id_instance = @id_instance AND

    -- instance must presently be in the NotYetRun state

    -- or the ReadyToRun state (this allows updates to an already

    -- submitted instance)

    inst.tx_status IN ('NotYetRun', 'ReadyToRun') AND

    -- interval, if any, must be in the closed state

    (inst.id_arg_interval IS NULL OR ui.tx_interval_status = 'C')



  -- if the update was made, return successfully

  IF (@@ROWCOUNT = 1)

  BEGIN



    -- records the action

    INSERT INTO t_recevent_inst_audit(id_instance,id_acc,tx_action,b_ignore_deps,dt_effective,tx_detail,dt_crt)

    VALUES(@id_instance, @id_acc, 'SubmitForExecution', @b_ignore_deps, @dt_effective, @tx_detail, @dt_now) 



    COMMIT

    SELECT @status = 0

    RETURN

  END



  --

  -- otherwise, attempts to figure out what went wrong

  --

  DECLARE @count INT

  SELECT @count = COUNT(*) FROM t_recevent_inst WHERE id_instance = @id_instance



  IF (@count = 0)

  BEGIN

    -- the instance does not exist

    ROLLBACK

    SELECT @status = -1

    RETURN

  END





  SELECT @count = COUNT(*)  

  FROM t_recevent_inst inst

  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event

  WHERE 

    -- event is active

    evt.dt_activated <= @dt_now AND

    (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) AND

    inst.tx_status = 'NotYetRun' AND

    inst.id_instance = @id_instance



  IF (@count = 0)

  BEGIN

    -- instance is not in the proper state

    ROLLBACK

    SELECT @status = -2

    RETURN

  END



  SELECT @count = COUNT(*)  

  FROM t_recevent_inst inst

  LEFT OUTER JOIN t_usage_interval ui ON ui.id_interval = inst.id_arg_interval

  WHERE 

    inst.id_instance = @id_instance AND

    (inst.id_arg_interval IS NULL OR ui.tx_interval_status = 'C')



  IF (@count = 0)

  BEGIN

    -- end-of-period instance's usage interval is not in the proper state

    ROLLBACK

    SELECT @status = -5 

    RETURN

  END



	  -- couldn't submit for some other unknown reason 

  ROLLBACK

  SELECT @status = -99 

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


  

CREATE PROCEDURE SubmitEventForReversal

(

  @dt_now DATETIME,

  @id_instance INT,

  @b_ignore_deps VARCHAR(1),

  @dt_effective DATETIME,

  @id_acc INT,

  @tx_detail VARCHAR(2048),

  @status INT OUTPUT

)

AS

BEGIN



  BEGIN TRAN



  SELECT @status = -99



  -- if the instance is a checkpoint, synchronously unacknowledges it

  DECLARE @isCheckpoint INT

  SELECT @isCheckpoint = 1 

  FROM t_recevent_inst inst

  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event

  WHERE 

    inst.id_instance = @id_instance AND

    evt.tx_type = 'Checkpoint'

  IF (@isCheckpoint = 1)

  BEGIN

    EXEC UnacknowledgeCheckpoint @dt_now, @id_instance, @b_ignore_deps, @id_acc, @tx_detail, @status OUTPUT

    IF (@status = 0)

      COMMIT

    ELSE

      ROLLBACK

    RETURN 

  END



  -- updates the instance's state to 'ReadyToReverse'

  UPDATE t_recevent_inst

  SET tx_status = 'ReadyToReverse', b_ignore_deps = @b_ignore_deps, dt_effective = @dt_effective

  FROM t_recevent_inst inst

  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event

  LEFT OUTER JOIN t_usage_interval ui ON ui.id_interval = inst.id_arg_interval

  WHERE 

    -- event is active

    evt.dt_activated <= @dt_now AND

    (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) AND

    evt.tx_reverse_mode IN ('Auto', 'Custom', 'NotNeeded') AND

    inst.id_instance = @id_instance AND

    -- instance must have previously succeeded or failed

    inst.tx_status IN ('Succeeded', 'Failed', 'ReadyToReverse') AND

    -- interval, if any, must be in the closed state

    (inst.id_arg_interval IS NULL OR ui.tx_interval_status = 'C')



  -- if the update was made, return successfully

  IF (@@ROWCOUNT = 1)

  BEGIN



    -- records the action

    INSERT INTO t_recevent_inst_audit(id_instance,id_acc,tx_action,b_ignore_deps,dt_effective,tx_detail,dt_crt)

    VALUES(@id_instance, @id_acc, 'SubmitForReversal', @b_ignore_deps, @dt_effective, @tx_detail, @dt_now) 



    COMMIT

    SELECT @status = 0

    RETURN

  END



  --

  -- otherwise, attempts to figure out what went wrong

  --

  DECLARE @count INT

  SELECT @count = COUNT(*) FROM t_recevent_inst WHERE id_instance = @id_instance



  IF (@count = 0)

  BEGIN

    -- instance doesn't exist at all

    ROLLBACK

    SELECT @status = -1 

    RETURN

  END



  SELECT @count = COUNT(*)

  FROM t_recevent_inst inst

  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event

  WHERE 

    -- event is active

    evt.dt_activated <= @dt_now AND

    (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) AND

    inst.tx_status IN ('Succeeded', 'Failed') AND

    inst.id_instance = @id_instance



  IF (@count = 0)

  BEGIN

    -- instance is not in the proper state

    ROLLBACK

    SELECT @status = -2
    RETURN

  END



  SELECT @count = COUNT(*)

  FROM t_recevent_inst inst

  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event

  WHERE 

    -- event is active

    evt.dt_activated <= @dt_now AND

    (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) AND

    evt.tx_reverse_mode IN ('Auto', 'Custom', 'NotNeeded') AND

    inst.id_instance = @id_instance



  IF (@count = 0)

  BEGIN

    -- event is not reversible 

    ROLLBACK

    SELECT @status = -3

    RETURN

  END



  SELECT @count = COUNT(*)  
  FROM t_recevent_inst inst

  LEFT OUTER JOIN t_usage_interval ui ON ui.id_interval = inst.id_arg_interval

  WHERE 

    inst.id_instance = @id_instance AND

    (inst.id_arg_interval IS NULL OR ui.tx_interval_status = 'C')



  IF (@count = 0)

  BEGIN

    -- end-of-period instance's usage interval is not in the proper state

    ROLLBACK

    SELECT @status = -5 

    RETURN

  END



  -- couldn't submit for some other unknown reason 

  ROLLBACK

  SELECT @status = -99

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


  

CREATE PROCEDURE UnacknowledgeCheckpoint

(

  @dt_now DATETIME,

  @id_instance INT,

  @b_ignore_deps VARCHAR(1),

  @id_acc INT,

  @tx_detail VARCHAR(2048),

  @status INT OUTPUT

)

AS

BEGIN



  -- NOTE: for now, just use the calling procedure's transaction



  SELECT @status = -99



  -- enforces that the checkpoints dependencies are satisfied

  IF (@b_ignore_deps = 'N')

  BEGIN

    DECLARE @unsatisfiedDeps INT

    SELECT @unsatisfiedDeps = COUNT(*) 

    FROM GetEventReversalDeps (@dt_now, @id_instance)

    WHERE tx_status <> 'NotYetRun'



    IF (@unsatisfiedDeps > 0)

    BEGIN

      SELECT @status = -4  -- deps aren't satisfied

      RETURN

    END

  END



  -- updates the checkpoint instance's state to 'NotYetRun'

  UPDATE t_recevent_inst

  SET tx_status = 'NotYetRun', b_ignore_deps = @b_ignore_deps, dt_effective = NULL

  FROM t_recevent_inst inst

  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event

  INNER JOIN t_usage_interval ui ON ui.id_interval = inst.id_arg_interval

  WHERE 

    -- event is active

    evt.dt_activated <= @dt_now AND

    (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) AND

    inst.id_instance = @id_instance AND

    -- checkpoint must presently be in the Succeeded or Failed state

    inst.tx_status IN ('Succeeded', 'Failed') AND

    -- interval, if any, must be in the closed state

    ui.tx_interval_status = 'C'



  -- if the update was made, return successfully

  IF (@@ROWCOUNT = 1)

  BEGIN



    -- records the action

    INSERT INTO t_recevent_inst_audit(id_instance,id_acc,tx_action,b_ignore_deps,dt_effective,tx_detail,dt_crt)

    VALUES(@id_instance, @id_acc, 'Unacknowledge', @b_ignore_deps, NULL, @tx_detail, @dt_now) 



    SELECT @status = 0

    RETURN

  END



  --

  -- otherwise, attempts to figure out what went wrong

  --

  DECLARE @count INT

  SELECT @count = COUNT(*) FROM t_recevent_inst WHERE id_instance = @id_instance



  IF (@count = 0)

  BEGIN

    -- the instance does not exist

    SELECT @status = -1

    RETURN

  END



  SELECT @count = COUNT(*)

  FROM t_recevent_inst inst

  INNER JOIN t_recevent evt ON evt.id_event = inst.id_event

  WHERE 

    -- event is active

    evt.dt_activated <= @dt_now AND

    (evt.dt_deactivated IS NULL OR @dt_now < evt.dt_deactivated) AND

    inst.tx_status IN ('Succeeded', 'Failed') AND

    inst.id_instance = @id_instance



  IF (@count = 0)

  BEGIN

    -- instance is not in the proper state

    SELECT @status = -2

    RETURN

  END



  SELECT @count = COUNT(*)  

  FROM t_recevent_inst inst

  INNER JOIN t_usage_interval ui ON ui.id_interval = inst.id_arg_interval

  WHERE 

    inst.id_instance = @id_instance AND

    ui.tx_interval_status = 'C'



  IF (@count = 0)

  BEGIN

    -- end-of-period instance's usage interval is not in the proper state

    SELECT @status = -5 

    RETURN

  END



  -- couldn't submit for some other unknown reason 

  SELECT @status = -99 

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


	create proc UndoAccounts @id_acc int, @nm_login nvarchar(255), @nm_space nvarchar(40) as 
         begin tran 
           if exists (select * from t_account_mapper where id_acc = @id_acc) 
             begin delete from t_account_mapper where id_acc = @id_acc end 

           if exists (select * from t_account where id_acc = @id_acc) 
             begin delete from t_account where id_acc = @id_acc end 

           if exists (select * from t_acc_usage_cycle where id_acc = @id_acc) 
             begin delete from t_acc_usage_cycle where id_acc = @id_acc end 

           if exists (select * from t_user_credentials where nm_login = @nm_login and nm_space = @nm_space)
             begin delete from t_user_credentials where nm_login = @nm_login and nm_space = @nm_space end 

           if exists (select * from t_acc_usage_interval where id_acc = @id_acc) 
             begin delete from t_acc_usage_interval where id_acc = @id_acc end 

           if exists (select * from t_site_user where nm_login = @nm_login)
			       begin delete from t_site_user where nm_login = @nm_login end 

           if exists (select * from t_av_internal where id_acc = @id_acc) 
             begin delete from t_av_internal where id_acc = @id_acc end 
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


			  

				CREATE PROCEDURE UpdStateFromClosedToArchived (

					@system_date datetime,

					@dt_start datetime,

					@dt_end datetime,

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

					AND ast.vt_start BETWEEN (dbo.mtstartofday(@dt_start) - @age) AND 

					                         (DATEADD(s, -1, dbo.mtstartofday(@dt_end) + 1) - @age)



					EXECUTE UpdateStateRecordSet

					@system_date,

					@varSystemGMTDateTimeSOD,

					'CL', 'AR',

					@status OUTPUT



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


				

CREATE PROCEDURE UpdateAccount (

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



      -- updates the account's billing cycle mapping

      UPDATE t_acc_usage_cycle SET id_usage_cycle = @usagecycleID

      WHERE id_acc = @accountID



      -- post-operation business rule check (relies on rollback of work done up until this point)

      -- CR9906: checks to make sure the account's new billing cycle matches all of it's and/or payee's 

      -- group subscription BCR constraints

      SELECT @p_status = ISNULL(MIN(dbo.CheckGroupMembershipCycleConstraint(@p_systemdate, groups.id_group)), 1)

      FROM 

      (

        -- gets all of the payer's payee's and/or the payee's group subscriptions

        SELECT DISTINCT gsm.id_group id_group

        FROM t_gsubmember gsm

        INNER JOIN t_payment_redirection pay ON pay.id_payee = gsm.id_acc

        WHERE 

          pay.id_payer = @accountID OR

          pay.id_payee = @accountID

      ) groups

      IF @p_status <> 1

        RETURN

    

			-- deletes any mappings to intervals in the future from the old cycle

			DELETE FROM t_acc_usage_interval 

			WHERE 

        t_acc_usage_interval.id_acc = @accountID AND

        id_usage_interval IN 

        ( 

          SELECT id_interval 

          FROM t_usage_interval ui

          INNER JOIN t_acc_usage_interval aui ON 

            t_acc_usage_interval.id_acc = @accountID AND

            aui.id_usage_interval = ui.id_interval

          WHERE dt_start > @p_systemdate

			  )



      -- only one pending update is allowed at a time

			-- deletes any previous update mappings which have not yet

      -- transitioned (dt_effective is still in the future)

			DELETE FROM t_acc_usage_interval 

      WHERE 

        dt_effective IS NOT NULL AND

        id_acc = @accountID AND

        dt_effective >= @p_systemdate



      -- gets the current interval's end date

			SELECT @intervalenddate = ui.dt_end 

      FROM t_acc_usage_interval aui

			INNER JOIN t_usage_interval ui ON 

        ui.id_interval = aui.id_usage_interval AND

        @p_systemdate BETWEEN ui.dt_start AND ui.dt_end

		  WHERE aui.id_acc = @AccountID



      -- figures out the new interval ID based on the end date of the current interval  

			SELECT 

        @intervalID = id_interval,

        @pc_start = dt_start,

        @pc_end = dt_end 

			FROM t_pc_interval

      WHERE

        id_cycle = @usagecycleID AND

			  dbo.addsecond(@intervalenddate) BETWEEN dt_start AND dt_end



      -- inserts the new usage interval if it doesn't already exist

			INSERT INTO t_usage_interval

      SELECT 

        @intervalID,

        @usagecycleID,

        @pc_start,

        @pc_end,

        'O'

			WHERE @intervalID NOT IN (SELECT id_interval FROM t_usage_interval)



			-- creates the special t_acc_usage_interval mapping to the interval of

      -- new cycle. dt_effective is set to the end of the old interval.

			INSERT INTO t_acc_usage_interval VALUES(@accountID, @intervalID, 'O', @intervalenddate)



      -- creates any needed intervals and mappings

      EXEC CreateUsageIntervals @p_systemdate, NULL, NULL



			-- indicate that the cycle changed

			select @p_newcycle = @UsageCycleID

			select @p_cyclechanged = 1



    END

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

	if dbo.IsAccountBillable(@AccountID) = '1' AND @p_billable = 'N' begin

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


			

create procedure UpdateBatchStatus

	@tx_batch VARBINARY(16),

	@tx_batch_encoded varchar(24),

	@n_completed int,

	@sysdate datetime

as



declare @initialStatus char(1)

declare @finalStatus char(1)



if not exists (select * from t_batch where tx_batch_encoded = @tx_batch_encoded)

begin

  insert into t_batch (tx_namespace, tx_name, tx_batch, tx_batch_encoded, tx_status, n_completed, n_failed, dt_first, dt_crt)

    values ('pipeline', @tx_batch_encoded, @tx_batch, @tx_batch_encoded, 'A', 0, 0, @sysdate, @sysdate)

end



select @initialStatus = tx_status from t_batch where tx_batch_encoded = @tx_batch_encoded



update t_batch

  set t_batch.n_completed = t_batch.n_completed + @n_completed,

    t_batch.tx_status =

       case when ((t_batch.n_completed + t_batch.n_failed + @n_completed) = t_batch.n_expected

                   or (((t_batch.n_completed + t_batch.n_failed + @n_completed) = t_batch.n_metered) and t_batch.n_expected = 0)) then 'C'

				 when ((t_batch.n_completed + t_batch.n_failed + @n_completed) < t_batch.n_expected

                   or (((t_batch.n_completed + t_batch.n_failed + @n_completed) < t_batch.n_metered) and t_batch.n_expected = 0)) then 'A'

         when ((t_batch.n_completed + t_batch.n_failed + @n_completed) > t_batch.n_expected) and t_batch.n_expected > 0 then 'F'

         else t_batch.tx_status end,

     t_batch.dt_last = @sysdate,

     t_batch.dt_first =

       case when t_batch.n_completed = 0 then @sysdate else t_batch.dt_first end

  where tx_batch = @tx_batch



select @finalStatus = tx_status from t_batch where tx_batch_encoded = @tx_batch_encoded

			
		
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


        

					CREATE PROC UpdateCounterPropDef

											@id_lang_code int,

											@id_prop int,

											@nm_name nvarchar(255),

											@nm_display_name nvarchar(255),

											@id_pi int,

											@nm_servicedefprop nvarchar(255),

											@nm_preferredcountertype nvarchar(255),

											@n_order int

					AS

						DECLARE @identity_value int

						DECLARE @id_locale int

					BEGIN TRAN

						exec UpdateBaseProps @id_prop, @id_lang_code, @nm_name, NULL, @nm_display_name

						UPDATE t_counterpropdef 

						SET

							nm_servicedefprop = @nm_servicedefprop,

							n_order = @n_order,

							nm_preferredcountertype = @nm_preferredcountertype

						WHERE id_prop = @id_prop

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

	



-- Section 1

	-- find the product offering ID

	select @idPO = id_po, @idusagecycle = tg.id_usage_cycle,@idSUB = t_sub.id_sub

	from t_sub 

	INNER JOIN t_group_sub tg on tg.id_group = @p_id_group

	where t_sub.id_group = @p_id_group

	



-- Section 2

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

	



-- Section 3

	-- Ok, here is how I propose to do this.

	-- First of all, we will end the current history of all memberships whose duration

	-- falls, partially or completely, out of the group subscription duration.

	-- This is accomplished with the following statement.

	update t_gsubmember_historical

	set tt_end = @p_systemdate

	where id_group = @p_id_group 

		AND tt_end = @varMaxDateTime

		AND ((@p_startdate > vt_start) OR (@realenddate < vt_end))

		

-- TODO: When converting this procedure to oracle, sections 4, 5, and 6 have changed since 3.0.1

-- Section 4

	-- The next step involves inserting the new history of the memberships that were changed somehow.

	-- Except that we do not need to insert new history for the memberships that were *completely* left out

	-- of the group sub duration. Those are effectively deleted, and the last entry on t_gsubmember_history

	-- for them will have tt_end = systemdate.

	insert into t_gsubmember_historical (id_group,id_acc,vt_start,vt_end,tt_start,tt_end)

	select id_group,id_acc,

	dbo.mtmaxoftwodates(tgs.vt_start,@p_startdate),

	dbo.mtminoftwodates(tgs.vt_end,@realenddate),

	@p_systemdate,

	@varMaxDateTime

	from t_gsubmember tgs

	where tgs.id_group = @p_id_group

		and ((@p_startdate > vt_start and vt_end >= @p_startdate) OR (@realenddate < vt_end and vt_start <= @realenddate))



-- Section 5

	-- Finally, we will select the records that are still relevant to the current format of the group subscription

	-- and insert them from t_gsubmember_historical into t_gsubmember.

	

	-- First remove the old records

	delete from t_gsubmember where id_group = @p_id_group

	-- Then import the records that are relevant to this group subscription

	insert into t_gsubmember (id_group,id_acc,vt_start,vt_end)

		select id_group,id_acc,vt_start,vt_end

		from t_gsubmember_historical

		where id_group = @p_id_group and tt_end = @varMaxDateTime



  -- post-operation business rule check (relies on rollback of work done up until this point)

  -- CR9906: checks to make sure the newly adjusted group subscription doesn't now include any

  -- additional member payer's that violate BCR cycle constraints

  SELECT @p_status = dbo.CheckGroupMembershipCycleConstraint(@p_systemdate, @p_id_group)

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


			

			CREATE PROC UpdateMeteredCount

			  @tx_batch varchar(255),

				@n_metered int,

				@dt_change datetime,

				@status int output

			AS

			BEGIN

			  declare @id_batch int

				declare @batch_status char(1) 

				SELECT

				  @id_batch = id_batch,

					@batch_status = tx_status

				FROM

				  t_batch

				WHERE

				  tx_batch_encoded = @tx_batch



				UPDATE 

				  t_batch 

				SET 

				  n_metered = @n_metered 

				WHERE

				  tx_batch_encoded = @tx_batch



		    SELECT @status = 1 

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

@realoldenddate <> @realenddate AND @billable = '0')

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


	

			create proc UpdateProductViewProperty 

			@a_id_prod_view_prop int,

			@a_id_prod_view int,

			@a_nm_name nvarchar(255),

			@a_nm_data_type nvarchar(255),

			@a_nm_column_name nvarchar(255),

			@a_b_required char(1),

			@a_b_composite_idx char(1),

			@a_b_single_idx char(1),

      @a_b_part_of_key char(1),

      @a_b_exportable char(1),

      @a_b_filterable char(1),

      @a_b_user_visible char(1),

			@a_nm_default_value nvarchar(255),

			@a_n_prop_type int,

			@a_nm_space varchar(255),

			@a_nm_enum varchar(255),

      @a_b_core char(1)

			as

      update t_prod_view_prop 

			set

			id_prod_view=@a_id_prod_view,

			nm_name=@a_nm_name,

			nm_data_type=@a_nm_data_type,

			nm_column_name=@a_nm_column_name,

			b_required=@a_b_required,

			b_composite_idx=@a_b_composite_idx,

			b_single_idx=@a_b_single_idx,

      b_part_of_key=@a_b_part_of_key,

      b_exportable=@a_b_exportable,

      b_filterable=@a_b_filterable,

      b_user_visible=@a_b_user_visible,

			nm_default_value=@a_nm_default_value,

			n_prop_type=@a_n_prop_type,

			nm_space=@a_nm_space,

			nm_enum=@a_nm_enum,

      b_core=@a_b_core

			where

			id_prod_view_prop=@a_id_prod_view_prop

	
	
GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


        

          CREATE PROCEDURE UpdateServiceEndpointConnection

            @a_id_se int,

            @a_date_start DATETIME,

            @a_new_start DATETIME,

            @a_new_end DATETIME,

            @a_status int OUTPUT

          AS BEGIN

            DECLARE @a_temp AS int

            DECLARE @a_se_end as DATETIME

            DECLARE @a_se_start as DATETIME



            SET @a_status = 0



            --Check for the connection

            SELECT @a_temp = COUNT(*) FROM t_se_parent WHERE id_se = @a_id_se AND dt_start = @a_date_start

            IF @a_temp = 0 BEGIN

              SET @a_status = -483458963

              RETURN

            END



            --Check the end date

            IF @a_new_end IS NULL BEGIN

              SET @a_new_end = dbo.MTMaxDate()

            END

            

            --Make sure the endpoint exists for the new end date

            SELECT @a_se_end = dt_end FROM t_service_endpoint where id_se = @a_id_se

            

            IF @a_new_end > @a_se_end BEGIN

              SET @a_status = -483458951

              RETURN

            END

          

            --Check if the start date was specified, if not, get the existing start

            IF @a_new_start IS NULL BEGIN

              SELECT @a_new_start = dt_start FROM t_se_parent WHERE id_se = @a_id_se AND dt_start = @a_date_start

            END

            

            --Make sure the endpoint exists for the new start date

            SELECT @a_se_start = dt_start FROM t_service_endpoint where id_se = @a_id_se

            

            IF @a_new_start < @a_se_start BEGIN

              SET @a_status = -483458950

              RETURN

            END

          

            --Check the date

            IF @a_new_start > @a_new_end BEGIN

              SET @a_status = -483458962

              RETURN

            END

          

            --Make sure new dates won't cause any overlap

            SELECT 

              @a_temp = COUNT(*) 

            FROM 

              t_se_parent 

            WHERE 

              id_se = @a_id_se AND 

              ((dt_start BETWEEN @a_new_start AND @a_new_end) OR

              (dt_end BETWEEN @a_new_start AND @a_new_end)) AND 

              dt_Start <> @a_date_start

              

            IF @a_temp > 0 BEGIN

              SET @a_status = -483458961

              RETURN

            END 

          

            --UPDATE the date

            UPDATE t_se_parent SET dt_start = @a_new_start, dt_end = @a_new_end WHERE id_se = @a_id_se AND dt_start = @a_date_start

            SET @a_status = @@error

            IF @a_status <> 0 BEGIN

              RETURN

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


        

          CREATE PROCEDURE UpdateServiceEndpointDates

              @a_id_se int,

            @a_date_start DATETIME,

            @a_date_end DATETIME,

            @a_status int OUTPUT

          AS BEGIN

            DECLARE @a_temp AS int

            

            SET @a_status = 0            

            

            --Verify the SE exists

            SELECT @a_temp = COUNT(*) FROM t_service_endpoint WHERE id_se = @a_id_se

            IF @a_temp = 0 BEGIN

              SET @a_status = -483458960

              RETURN

            END

            

            --Check NULL start date

            IF @a_date_start IS NULL BEGIN

              SET @a_status = -483458959

              RETURN

            END

                    

            --Check for NULL date

            IF @a_date_end IS NULL BEGIN

              SET @a_date_end = dbo.MTMaxDate()

            END          

        

            --Check dates

            IF @a_date_start > @a_date_end BEGIN

              SET @a_status = -483458958

              RETURN

            END



   	    --Verify that changing the dates wouldn't hose a connection

            --Check new endpoint start date

	    SELECT @a_temp = COUNT(*) FROM t_se_parent WHERE @a_date_start > dt_start AND @a_id_se = id_se
	    IF @a_temp > 0 BEGIN

	      SET @a_status = -483458947

              RETURN

            END



            --Check new endpoint end date

            SELECT @a_temp = COUNT(*) FROM t_se_parent WHERE @a_date_end < dt_end AND @a_id_se = id_se

            IF @a_temp > 0 BEGIN

              SET @a_status = -483458946

              RETURN

            END

        

            --Ensure that the new date range won't cause an ID conflict

            SELECT

              @a_temp = COUNT(*)

            FROM

              t_se_mapper tsem

            INNER JOIN t_service_endpoint tse ON tse.id_se = tsem.id_se AND

                                                 ((tse.dt_start BETWEEN @a_date_start AND @a_date_end) OR

                                                  (@a_date_start BETWEEN tse.dt_start AND tse.dt_end))

            WHERE

              LOWER(tsem.nm_login) IN (select LOWER(nm_login) from t_se_mapper where id_se = @a_id_se)

	      AND LOWER(tsem.nm_space) IN (select LOWER(nm_space) from t_se_mapper where id_se = @a_id_se)

              AND ((tsem.id_corp IN (select id_corp from t_se_mapper where id_se = @a_id_se)) OR

                  (tsem.id_corp IS NULL AND (select id_corp from t_se_mapper where id_se = @a_id_se) IS NULL))

              AND tsem.id_se <> @a_id_se



	          IF @a_temp > 0 BEGIN

              SET @a_status = -483458944

              RETURN

            END



            --Update the end date

            UPDATE t_service_endpoint SET dt_start = @a_date_start, dt_end = @a_date_end WHERE id_se = @a_id_se

         

            SET @a_status = @@error

            IF @a_status <> 0 BEGIN

              RETURN

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


        

          CREATE PROCEDURE UpdateServiceEndpointIDMapping

            @a_id_se int,

            @a_id_corp int,

            @a_id VARCHAR(255),

            @a_space VARCHAR(40),

            @a_new_id VARCHAR(255),

            @a_new_space VARCHAR(40),

            @b_primary VARCHAR(1),

            @a_status int OUTPUT

          AS BEGIN

            DECLARE @a_temp AS INT

	          DECLARE @a_temp_primary AS VARCHAR(1)

            DECLARE @a_transaction_started as int

  

      	    IF @@trancount = 0 BEGIN

              BEGIN TRAN

              SET @a_transaction_started = 1

            END               

            

            SET @a_status = 0

            

            --Make sure the mapping exists

            IF @a_id_corp IS NULL BEGIN

              SELECT @a_temp = COUNT(*) FROM t_se_mapper WHERE id_se = @a_id_se AND id_corp IS NULL AND LOWER(nm_login) = LOWER(@a_id) AND LOWER(nm_space) = LOWER(@a_space)

              SELECT @a_temp_primary = b_primary FROM t_se_mapper WHERE id_se = @a_id_se AND id_corp IS NULL AND LOWER(nm_login) = LOWER(@a_id) AND LOWER(nm_space) = LOWER(@a_space)

            END

            ELSE BEGIN

              SELECT @a_temp = COUNT(*) FROM t_se_mapper WHERE id_se = @a_id_se AND id_corp = @a_id_corp AND LOWER(nm_login) = LOWER(@a_id) AND LOWER(nm_space) = LOWER(@a_space)

              SELECT @a_temp_primary = b_primary FROM t_se_mapper WHERE id_se = @a_id_se AND id_corp = @a_id_corp AND LOWER(nm_login) = LOWER(@a_id) AND LOWER(nm_space) = LOWER(@a_space)

            END

            

            IF @a_temp = 0 BEGIN

              SET @a_status = -483458956

              GOTO errHandler

            END



            --If the ID mapping has not changed, do nothing, prevents following check from raising error

            IF LOWER(@a_id) = LOWER(@a_new_id) BEGIN

              IF LOWER(@a_space) = LOWER(@a_new_space) BEGIN

                IF @a_temp_primary = @b_primary BEGIN

                  SET @a_status = 0

                  GOTO errHandler

                END

              END

            END



            --Make sure the new mapping does not duplicate another

 	          --Two cases to look out for

            -- 1) Just setting the primary flag for an existing mapping

            -- 2) Changing a mapping name/namespace and or primary flag

	   

            -- Only check duplicate names if changing name or namespace

            IF LOWER(@a_id) <> LOWER(@a_new_id) OR LOWER(@a_space) <> LOWER(@a_new_space) BEGIN

              IF @a_id_corp IS NULL BEGIN

            		SELECT

  		            @a_temp = COUNT(*)

  		          FROM

  		            t_se_mapper tsem

  	   	          INNER JOIN t_service_endpoint tse ON tsem.id_se = tse.id_se

  		          WHERE

   	  	          tsem.id_corp IS NULL	

  		            AND LOWER(tsem.nm_login) = LOWER(@a_new_id)

  	  	          AND LOWER(tsem.nm_space) = LOWER(@a_new_space)

  		            AND (tse.dt_start BETWEEN (select dt_start from t_service_endpoint where id_se = @a_id_se) AND (select dt_end from t_service_endpoint where id_se = @a_id_se) OR 

                      (select dt_start from t_service_endpoint where id_se = @a_id_se) BETWEEN tse.dt_start AND tse.dt_end)



--	              SELECT @a_temp = COUNT(*) FROM t_se_mapper WHERE id_corp IS NULL AND LOWER(nm_login) = LOWER(@a_new_id) AND LOWER(nm_space) = LOWER(@a_new_space)

              END

              ELSE BEGIN

  		          SELECT

  		            @a_temp = COUNT(*)

            		FROM

            		  t_se_mapper tsem

          	   	  INNER JOIN t_service_endpoint tse ON tsem.id_se = tse.id_se

            		WHERE

           	  	  tsem.id_corp = @a_id_corp

            		  AND LOWER(tsem.nm_login) = LOWER(@a_new_id)

           	  	  AND LOWER(tsem.nm_space) = LOWER(@a_new_space)

            		  AND (tse.dt_start BETWEEN (select dt_start from t_service_endpoint where id_se = @a_id_se) AND (select dt_end from t_service_endpoint where id_se = @a_id_se) OR 

                      (select dt_start from t_service_endpoint where id_se = @a_id_se) BETWEEN tse.dt_start AND tse.dt_end)



--                SELECT @a_temp = COUNT(*) FROM t_se_mapper WHERE id_corp = @a_id_corp AND LOWER(nm_login) = LOWER(@a_new_id) AND LOWER(nm_space) = LOWER(@a_new_space)

              END

            END

            

            --Not changing mapping, just primary, so no problem

            ELSE BEGIN

              SET @a_temp = 0

            END



            IF @a_temp > 0 BEGIN

              SET @a_status = -483458945

              GOTO errHandler

            END

          

            --Get the number of mappings for the SE

            IF @a_id_corp IS NULL BEGIN

              SELECT @a_temp = COUNT(*) FROM t_se_mapper WHERE id_se = @a_id_se AND id_corp IS NULL

            END

            ELSE BEGIN

              SELECT @a_temp = COUNT(*) FROM t_se_mapper WHERE id_se = @a_id_se AND id_corp = @a_id_corp

            END

           

            --If primary set, remove the old primary

            --If primary not set, make sure not unsetting the existing primary

            IF @a_temp > 1 BEGIN

              IF @a_temp_primary = '1' BEGIN

                --Do not allow removal of primary flag

                IF @b_primary <> '1' BEGIN

                  SET @a_status = -483458948

                  GOTO errHandler

                END

              END



              SET @a_temp_primary = @b_primary

              IF @b_primary = '1' BEGIN

                UPDATE t_se_mapper SET b_primary = '0' WHERE id_se = @a_id_se AND b_primary = '1'

                SET @a_status = @@error

                IF @a_status <> 0 BEGIN

                  GOTO errHandler

                END

              END

            END

            ELSE BEGIN

              --If only one item, this must be the primary

              IF @b_primary <> '1' BEGIN

                 SET @a_status = -483458948

                 GOTO errHandler

              END

            END

            

            --Now update the mapping

            UPDATE 

              t_se_mapper 

            SET 

              nm_login = @a_new_id, 

              nm_space = @a_new_space, 

              b_primary = @a_temp_primary 

            WHERE 

              id_se = @a_id_se AND

              LOWER(nm_login) = LOWER(@a_id) AND

              LOWER(nm_space) = LOWER(@a_space)

            

            SET @a_status = @@error

            IF @a_status <> 0 BEGIN

               GOTO errHandler

            END

                          

            IF @a_transaction_started = 1 BEGIN

              COMMIT TRAN

              SET @a_status = 0

              RETURN

            END

            

            errHandler:

            IF @a_transaction_started = 1 BEGIN

              ROLLBACK TRAN

            END

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


			  

				CREATE PROCEDURE UpdateStateFromClosedToPFB (

					@system_date datetime,

					@dt_start datetime,

					@dt_end datetime,

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



					select @varSystemGMTBDateTime = dbo.mtstartofday(@dt_start - 1)

					select @varSystemGMTEDateTime = DATEADD(s, -1, dbo.mtstartofday(@dt_end) + 1)



					-- Save those id_acc whose state MAY be updated to a temp table (had usage the previous day)

					create table #updatestate_0 (id_acc int)

					INSERT INTO #updatestate_0 (id_acc)

					SELECT DISTINCT id_acc 

					FROM (SELECT id_acc FROM t_acc_usage au

					      WHERE au.dt_crt between @varSystemGMTBDateTime and @varSystemGMTEDateTime) ttt

					-- Also save id_acc that had adjustments in the approved state

					UNION

					SELECT DISTINCT id_acc_payer AS id_acc 

  					FROM (SELECT id_acc_payer FROM t_adjustment_transaction ajt

					      WHERE  ajt.c_status = 'A' AND 

					      ajt.dt_modified between @varSystemGMTBDateTime and @varSystemGMTEDateTime) ttt

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

					@varSystemGMTDateTime,

					'CL', 'PF',

					@status OUTPUT



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


				

				CREATE proc UpdateStateFromPFBToClosed (

					@id_interval INT,

					@ref_date DATETIME,

					@system_date datetime,

					@status INT OUTPUT)

				AS

 				BEGIN

					DECLARE @ref_date_mod DATETIME, @varMaxDateTime DATETIME, @ref_date_modSOD DATETIME



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



					SELECT @ref_date_modSOD = dbo.mtstartofday(@ref_date_mod)



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

					SET tt_end = DATEADD(ms, -10, @varSystemGMTDateTime)

					WHERE ((@ref_date_mod between vt_start and vt_end) OR 

					       (@ref_date_mod <= vt_start))

					AND tt_end = @varMaxDateTime

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

						--@ref_date_mod,

						dbo.subtractsecond(@ref_date_modSOD),

						@varSystemGMTDateTime,

						@varMaxDateTime

					FROM t_sub sub, #updatestate_1 tmp

					WHERE sub.id_acc = tmp.id_acc

					AND ((@ref_date_mod between sub.vt_start and sub.vt_end) OR 

					     (@ref_date_mod <= vt_start))



					-- Update the vt_end field of the Current records for the accounts

					UPDATE t_sub 

					SET vt_end = dbo.subtractsecond(@ref_date_modSOD)

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

					SET tt_end = DATEADD(ms, -10, @varSystemGMTDateTime)

					WHERE ((@ref_date_mod between vt_start and vt_end) OR 

					       (@ref_date_mod <= vt_start))

					AND tt_end = @varMaxDateTime

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

						dbo.subtractsecond(@ref_date_modSOD),

						@varSystemGMTDateTime,

						@varMaxDateTime

					FROM t_gsubmember gsub, #updatestate_1 tmp

					WHERE gsub.id_acc = tmp.id_acc

					AND ((@ref_date_mod between vt_start and vt_end) OR 

				       (@ref_date_mod <= vt_start))



					-- Update the vt_end field of the Current records for the accounts

					UPDATE t_gsubmember 

					SET vt_end = dbo.subtractsecond(@ref_date_modSOD)

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

					SET tt_end = DATEADD(ms, -10, @varSystemGMTDateTime)

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



	-- Check availability of the product offering

	select @p_status = case 

		when ta.n_begintype = 0 or ta.n_endtype = 0 then -289472451

		when ta.n_begintype <> 0 and ta.dt_start > @p_systemdate then -289472449

		when ta.n_endtype <> 0 and ta.dt_end < @p_systemdate then -289472450

		else 1

		end 

	from t_po po 

	inner join t_effectivedate ta on po.id_avail=ta.id_eff_date

	where

	po.id_po=@p_id_po



	if (@p_status <> 1) begin

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


			

			create procedure mtsp_BackoutInvoices (



			@id_interval int,



			@id_run int,



			@num_invoices int OUTPUT,



			@info_string nvarchar(500) OUTPUT,



			@return_code int OUTPUT



			)



			as



			begin



				DECLARE @debug_flag bit



				DECLARE @msg nvarchar(256)



				DECLARE @usage_cycle_type int



				SET @msg = 'Invoice-Backout: Invoice adapter reversed'



				SET @debug_flag = 1



				--SET @debug_flag = 0



				SET @info_string = '' 



				set @usage_cycle_type = (select id_usage_cycle from t_usage_interval 

							 where id_interval = @id_interval)



				select * from t_invoice left outer join t_usage_interval

 					on t_invoice.id_interval = t_usage_interval.id_interval

 					where id_usage_cycle = @usage_cycle_type

 					and t_invoice.id_interval > @id_interval

				if (@@rowcount > 0) 

 					SET @info_string = 'Reversing the invoice adapter for this interval has caused the invoices for subsequent intervals to be invalid'



				--truncate the table so that all rows corresponding to this interval are removed



				DELETE FROM t_invoice



				WHERE



					id_interval = @id_interval



				SET @num_invoices = @@ROWCOUNT



				--update the t_invoice_range table's id_run field



					UPDATE t_invoice_range



						SET id_run = @id_run WHERE id_interval = @id_interval



					IF @debug_flag = 1 



					INSERT INTO t_recevent_run_details (id_run, tx_type, tx_detail, dt_crt)

					  VALUES (@id_run, 'Debug', @msg, getutcdate()) 



    					SET @return_code = 0



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


  	

		create procedure sp_DeletePricelist 

		(

			@a_plID int,

			@status INT OUTPUT

		)

		as

		begin

			declare @n_pl_maps as int

			declare @n_def_acc as int



			declare @CursorVar CURSOR 

			declare @count as int

			declare @i as int

			declare @id_rs as int

			

			set @n_pl_maps = (select count(*) from t_pl_map where id_pricelist = @a_plID)

			if (@n_pl_maps > 0)

			begin

				select @status = 1

				return

			end



			set @n_def_acc = (select count(*) from t_av_internal where c_pricelist = @a_plID)

			if (@n_def_acc > 0)

			begin

				select @status = 2

				return

			end

			

			set @i = 0

			set @CursorVar = CURSOR STATIC



			for select id_sched from t_rsched

					where id_pricelist = @a_plID

			open @CursorVar

			select @count = @@cursor_rows

			while @i < @count 

				begin

					fetch next from @CursorVar into @id_rs

					set @i = (select @i + 1)

					exec sp_DeleteRateSchedule @id_rs

				end

			close @CursorVar

			deallocate @CursorVar



			delete from t_pricelist where id_pricelist = @a_plID

			execute DeleteBaseProps @a_plID

			

			select @status = 0

			return (0)

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


		

		create procedure sp_DeleteRateSchedule 

			@a_rsID int

		as

		begin

			declare @id_effdate int

			declare @id_paramtbl int

			declare @nm_paramtbl NVARCHAR(255)

			declare @SQLString NVARCHAR(255)



			-- Find the information we need to delete rates

			set @id_effdate = (select id_eff_date from t_rsched where id_sched = @a_rsID)

			set @id_paramtbl = (select id_pt from t_rsched where id_sched = @a_rsID)			

			set @nm_paramtbl = (select nm_instance_tablename from t_rulesetdefinition where id_paramtable = @id_paramtbl)



			-- Create the delete statement for the particular rule table and execute it

			set @SQLString = N'delete from ' + @nm_paramtbl + ' where id_sched = ' + CAST(@a_rsID AS NVARCHAR(10))

			execute sp_executesql @SQLString



			-- Delete the remaining rate schedule info

			delete from t_rsched where id_sched = @a_rsID

			delete from t_effectivedate where id_eff_date = @id_effdate

			execute DeleteBaseProps @a_rsID

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


			create proc sp_InsertBaseProps @a_kind int,
						@a_nameID int,
						@a_descID int,
						@a_approved char(1),
						@a_archive char(1),
						@a_nm_name NVARCHAR(255),
						@a_nm_desc NVARCHAR(255),
						@a_id_prop int OUTPUT
			as
			insert into t_base_props (n_kind,n_name,n_desc,nm_name,nm_desc,b_approved,b_archive) values
				(@a_kind,@a_nameID,@a_descID,@a_nm_name,@a_nm_desc,@a_approved,@a_archive)
			select @a_id_prop =@@identity
	 
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

