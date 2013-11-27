
				create view vw_mps_or_system_acc_mapper as
        select 
				mapper.nm_login,
				mapper.nm_space,
				mapper.id_acc,
				case when tac.id_acc is NULL then '' else
				  (c_firstname + (' ' + c_lastname)) end as fullname,
        case when (tac.c_firstname is NULL or tac.c_firstname = '') and (tac.c_lastname is NULL or tac.c_lastname ='') then 
           (mapper.nm_login + (' (' + (cast(mapper.id_acc as varchar(255)) + ')')))
        else
            case when tac.c_firstname is null or tac.c_firstname = '' then
              (tac.c_lastname + (' (' + (cast(mapper.id_acc as varchar(255)) + ')')))
            else
              case when tac.c_lastname is null or tac.c_lastname ='' then
                (tac.c_firstname + (' (' + (cast(mapper.id_acc as varchar(255)) + ')')))
              else
                ((tac.c_firstname + (' ' + tac.c_lastname)) + (' (' + (cast(mapper.id_acc as varchar(255)) + ')')))
              end
            end
        end as displayname,
        case when tac.c_firstname is NULL and tac.c_lastname is NULL then 
          mapper.nm_login
        else
          case when tac.c_firstname is null or tac.c_firstname = '' then
            tac.c_lastname
          else
            case when tac.c_lastname is null or tac.c_lastname = '' then
              tac.c_firstname
            else
             (tac.c_firstname + (' ' + tac.c_lastname))
            end
          end
        end as hierarchydisplayname,
        ns.tx_typ_space
		FROM dbo.t_account_mapper mapper
		INNER JOIN dbo.t_namespace ns on ns.nm_space = mapper.nm_space 
			AND ns.tx_typ_space IN ('system_mps', 'system_user', 'system_auth')
		INNER JOIN dbo.t_enum_data ed on ed.nm_enum_data = 'metratech.com/accountcreation/contacttype/bill-to'
		LEFT OUTER JOIN t_av_contact tac on tac.id_acc = mapper.id_acc AND
			tac.c_contacttype = ed.id_enum_data
				