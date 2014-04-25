using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using MetraTech.DataAccess;
using MetraTech.UI.Common;
using MetraTech.UI.Controls;

public partial class SummaryGridView : MTPage
{
  protected void Page_Load(object sender, EventArgs e)
  {
    
  }

  protected override void OnLoadComplete(EventArgs e)
  {

    // populate dropdownlist
    foreach (MTGridDataElement mtGridDataElement in SummaryGrid.Elements)
    {
      if ("id_usage_interval".Equals(mtGridDataElement.ID))
      {
        mtGridDataElement.FilterDropdownItems.Clear();

        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {

          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"select
ui.id_interval, ui.tx_interval_status, ui.dt_start, ui.dt_end, ct.tx_desc, cast(DENSE_RANK() over (order by case when ui.tx_interval_status='O' then 0 else 1 end, ui.dt_start) as int) n_order
from t_usage_interval ui
inner join t_usage_cycle c on c.id_usage_cycle = ui.id_usage_cycle
inner join t_usage_cycle_type ct on ct.id_cycle_type = c.id_cycle_type
where 1=1
and ui.tx_interval_status in ('H', 'O', 'B')
order by ui.id_interval asc
"))//"queries\\ProductCatalog", "__GET_USAGE_INTERVALS__"))
          {
            using (IMTDataReader reader = stmt.ExecuteReader())
            {
              while (reader.Read())
              {
                MTFilterDropdownItem filterItem = new MTFilterDropdownItem();

                if (!reader.IsDBNull("id_interval"))
                {
                  filterItem.Key = reader.GetInt32("id_interval").ToString();
                }

                var displayName = string.Empty;
                if (!reader.IsDBNull("dt_start"))
                {
                  // TODO: configure date formatting
                  displayName += reader.GetDateTime("dt_start").ToShortDateString() + " - ";
                }

                if (!reader.IsDBNull("dt_end"))
                {
                  // TODO: configure date formatting
                  displayName += reader.GetDateTime("dt_end").ToShortDateString();
                }

                if (!reader.IsDBNull("tx_desc"))
                {
                  displayName += " (" + reader.GetString("tx_desc") + ")";
                }

                filterItem.Value = displayName;

                mtGridDataElement.FilterDropdownItems.Add(filterItem);

                if (!reader.IsDBNull("n_order") && reader.GetInt32("n_order") == 1)
                {
                  mtGridDataElement.ElementValue = reader.GetInt32("id_interval").ToString();
                }
              }
            }
          }
        }
      }
      else if ("nm_view".Equals(mtGridDataElement.ID))
      {
        mtGridDataElement.FilterDropdownItems.Clear();

        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"select
pv.id_view, pv.nm_name, pv.nm_table_name, d.tx_desc
from t_prod_view pv
inner join t_description d on d.id_desc = pv.id_view
where 1=1
and d.id_lang_code = %%ID_LANG_CODE%%
order by d.tx_desc
"))//"queries\\ProductCatalog", "__GET_USAGE_INTERVALS__"))
          {
            stmt.AddParam("%%ID_LANG_CODE%%", UI.User.SessionContext.LanguageID);
            using (IMTDataReader reader = stmt.ExecuteReader())
            {
              while (reader.Read())
              {
                MTFilterDropdownItem filterItem = new MTFilterDropdownItem();

                if (!reader.IsDBNull("nm_name"))
                {
                  filterItem.Key = reader.GetString("nm_name").ToString();
                }

                if (!reader.IsDBNull("tx_desc"))
                {
                  filterItem.Value = reader.GetString("tx_desc");
                }

                mtGridDataElement.FilterDropdownItems.Add(filterItem);
              }
            }
          }
        }
      }
      else if ("nm_pv_table".Equals(mtGridDataElement.ID))
      {
        mtGridDataElement.FilterDropdownItems.Clear();

        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"select
pv.id_view, pv.nm_name, pv.nm_table_name
from t_prod_view pv
where 1=1
order by pv.nm_table_name
"))//"queries\\ProductCatalog", "__GET_USAGE_INTERVALS__"))
          {
            using (IMTDataReader reader = stmt.ExecuteReader())
            {
              while (reader.Read())
              {
                MTFilterDropdownItem filterItem = new MTFilterDropdownItem();

                if (!reader.IsDBNull("nm_table_name"))
                {
                  filterItem.Key = reader.GetString("nm_table_name");
                  filterItem.Value = reader.GetString("nm_table_name");
                }

                mtGridDataElement.FilterDropdownItems.Add(filterItem);
              }
            }
          }
        }
      }
      else if ("nm_pi_template".Equals(mtGridDataElement.ID))
      {
        mtGridDataElement.FilterDropdownItems.Clear();

        using (IMTConnection conn = ConnectionManager.CreateConnection())
        {
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(@"select
pit.id_template, tbp.nm_display_name
from t_pi_template pit
inner join t_base_props tbp on pit.id_template = tbp.id_prop
where 1=1
order by tbp.nm_display_name
"))//"queries\\ProductCatalog", "__GET_USAGE_INTERVALS__"))
          {
            using (IMTDataReader reader = stmt.ExecuteReader())
            {
              while (reader.Read())
              {
                MTFilterDropdownItem filterItem = new MTFilterDropdownItem();

                if (!reader.IsDBNull("nm_display_name"))
                {
                  filterItem.Key = reader.GetString("nm_display_name").ToString();
                  filterItem.Value = reader.GetString("nm_display_name").ToString();
                }

                mtGridDataElement.FilterDropdownItems.Add(filterItem);
              }
            }
          }
        }
      }
      else
      {
        Logger.LogDebug("Not a match: " + mtGridDataElement.ID);
      }
    }
    base.OnLoadComplete(e);
  }

}
