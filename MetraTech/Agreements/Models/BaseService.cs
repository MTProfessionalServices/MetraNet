using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Web;
using MetraTech.DataAccess;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.Enums.Core.Global;

namespace MetraTech.Agreements.Models
{
  public abstract class BaseService
  {
    /// <summary>
    /// Aplies Filter and Sorting Criteria to the query statement.
    /// </summary>
    /// <param name="filterpropertiesList">List of Filter Properties</param>
    /// <param name="sortCriteria">Sort Criteria</param>
    /// <param name="querystatement">Query Statement on which this filter and sorting will be applied</param>
    /// <returns>Nothing</returns>
    public void ApplySortingFiltering(List<FilterElement> filterpropertiesList, List<SortCriteria> sortCriteria,
                                      IMTFilterSortStatement querystatement)
    {
      //Add Filtering
      if (filterpropertiesList != null)
      {
        //foreach (AgreementTemplateModel.GenericFilterPropertiesModel filterprop in filterProperties)
        foreach (FilterElement filterprop in filterpropertiesList)
        {
          FilterElement fe = new FilterElement(filterprop.PropertyName, filterprop.Operation, filterprop.Value);
          querystatement.AddFilter(fe);
        }
      }

      //Add Sorting
      //iterate through the Sorting Criteria Object's properties
      if (sortCriteria != null)
      {
        foreach (SortCriteria sortprop in sortCriteria)
        {
          querystatement.SortCriteria.Add(new SortCriteria(sortprop.Property, sortprop.Direction));
        }
      }
    }

    protected void GetLocalizedDispAndDesc(int idPo, out int nameId, out int descId)
    {
      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {
        using (IMTAdapterStatement getLocalValStmt = conn.CreateAdapterStatement("queries\\PCWS", "__GET_NAME_DISP_ID__"))
        {
          getLocalValStmt.AddParam("%%ID_PO%%", idPo);
          nameId = -1;
          descId = -1;
          using (IMTDataReader getLocalValReader = getLocalValStmt.ExecuteReader())
          {
            while (getLocalValReader.Read())
            {
              nameId = getLocalValReader.GetInt32("n_display_name");
              descId = getLocalValReader.GetInt32("n_desc");
            }
          }
        }
      }
    }

    protected void ProcessLocalizationData(int id_prop,
                                        Dictionary<LanguageCode, string> localizedDisplayNames,
                                        Dictionary<LanguageCode, string> localizedDescriptions)
    {
      int nameId = -1;
      int descId = -1;
      GetLocalizedDispAndDesc(id_prop, out nameId, out descId);

      if (nameId == -1 || descId == -1)
      {
        throw new DataException("Cannot add localized values if base properties are not created first");
      }

      ProcessLocalizationData(nameId,
                              localizedDisplayNames,
                              descId,
                              localizedDescriptions);
    }

    protected void ProcessLocalizationData(int? displayNameId,
                                            Dictionary<LanguageCode, string> localizedDisplayNames,
                                            int? descId,
                                            Dictionary<LanguageCode, string> localizedDescriptions)
    {
      bool runUpdate = false;
      bool hasLocalizedDisplayNameValues = false;
      bool hasLocalizedDescriptionValues = false;
      StringBuilder updateDisplayNames = new StringBuilder();
      StringBuilder updateDescriptions = new StringBuilder();
      StringBuilder updateLocalization = new StringBuilder();

      using (IMTConnection conn = ConnectionManager.CreateConnection())
      {

        bool isOracle = conn.ConnectionInfo.DatabaseType == DBType.Oracle ? true : false;
        if (isOracle)
          updateLocalization.Append("DECLARE\n A_ID_DESC NUMBER;\n BEGIN\n A_ID_DESC := NULL; \n");
        else
          updateLocalization.Append("BEGIN\n declare @a_id_desc int \n");

        if (displayNameId.HasValue)
        {
          if (isOracle)
          {
            updateDisplayNames.Append(string.Format("delete from t_description where id_desc = {0};\n", displayNameId.Value));
          }
          else
          {
            updateDisplayNames.Append(string.Format("delete from t_description where id_desc = {0};\n", displayNameId.Value));
          }

          if (localizedDisplayNames != null && localizedDisplayNames.Count > 0)
          {
            foreach (KeyValuePair<LanguageCode, string> dispName in localizedDisplayNames)
            {
              int lcId = System.Convert.ToInt32(EnumHelper.GetValueByEnum(dispName.Key, 1));

              if (dispName.Value != null && dispName.Value.Length > 0)
                hasLocalizedDisplayNameValues = true;

              if (isOracle)
                updateDisplayNames.Append(String.Format("UPSERTDESCRIPTIONV2({0},N'{1}',{2},{3});\n", lcId, dispName.Value, displayNameId.Value, "A_ID_DESC"));
              else
                updateDisplayNames.Append(String.Format("exec UpsertDescriptionV2 {0},N'{1}',{2},{3}", lcId, dispName.Value, displayNameId.Value, "@a_id_desc OUTPUT;\n"));
            }
          }

          if (displayNameId.Value <= 0)
          {
            if (hasLocalizedDisplayNameValues)
              throw new DataException("Cannot add localized values if default display names are not defined.");

          }
          else
          {
            updateLocalization.Append(updateDisplayNames.ToString());
            runUpdate = true;
          }


        }

        if (descId.HasValue)
        {
          if (isOracle)
          {
            updateDescriptions.Append(string.Format("delete from t_description where id_desc = {0};\n", descId.Value));
          }
          else
          {
            updateDescriptions.Append(string.Format("delete from t_description where id_desc =  {0};\n", descId.Value));
          }

          if (localizedDescriptions != null && localizedDescriptions.Count > 0)
          {
            foreach (KeyValuePair<LanguageCode, string> dispDesc in localizedDescriptions)
            {
              int lcId = System.Convert.ToInt32(EnumHelper.GetValueByEnum(dispDesc.Key, 1));

              if (dispDesc.Value != null && dispDesc.Value.Length > 0)
                hasLocalizedDescriptionValues = true;

              if (isOracle)
                updateDescriptions.Append(String.Format("UPSERTDESCRIPTIONV2({0},N'{1}',{2},{3});\n", lcId, dispDesc.Value, descId.Value, "A_ID_DESC"));
              else
                updateDescriptions.Append(String.Format("exec UpsertDescriptionV2 {0},N'{1}',{2},{3}", lcId, dispDesc.Value, descId.Value, "@a_id_desc OUTPUT;\n"));
            }
          }

          if (descId.Value <= 0)
          {
            if (hasLocalizedDescriptionValues)
              throw new DataException("Cannot add localized values if default Descriptions are not defined.");

          }
          else
          {
            updateLocalization.Append(updateDescriptions.ToString());
            runUpdate = true;
          }

        }

        updateLocalization.Append("END;");

        if (runUpdate)
        {
          using (IMTStatement localizationStmt = conn.CreateStatement(updateLocalization.ToString()))
          {
            localizationStmt.ExecuteNonQuery();
          }
        }
      }
    }
  }
}