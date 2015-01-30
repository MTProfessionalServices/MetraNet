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
    if (!UI.CoarseCheckCapability("Manage Usage Processing"))
    {
      Response.End();
      return;
    }

    
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

          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\ProductCatalog", "__GET_INTERVALS__"))
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
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\ProductCatalog", "__GET_PV_NAMES__"))
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
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\ProductCatalog", "__GET_PV_TABLES__"))
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
          using (IMTAdapterStatement stmt = conn.CreateAdapterStatement("queries\\ProductCatalog", "__GET_PI_TEMPLATE_NAMES__"))
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
