using System;
using System.Collections.Generic;
using System.Globalization;
using MetraNet.Models;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.Debug.Diagnostics;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.UI.Common;
using Resources;
using PropertyType = MetraTech.DomainModel.Enums.Core.Global.PropertyType;
using MetraTech;

/// <summary>
/// SpecCharacteristicRepository - used for loading and saving SpecCharacteristics
/// </summary>
public class SpecCharacteristicRepository
{
  readonly UIManager UI;
  readonly Logger logger = new Logger("[SpecCharacteristicRepository]");

  public SpecCharacteristicRepository(UIManager ui)
  {
    if (ui == null)
      throw new UIException(ErrorMessages.SpecCharacteristicRepository_SpecCharacteristicRepository_Access_denied_);

    UI = ui;
  }

  /// <summary>
  /// Return a list of SpecCharacteristicModels
  /// </summary>
  /// <param name="id"></param>
  /// <param name="justUserVisible"> </param>
  /// <returns></returns>
  public List<SpecCharacteristicModel> LoadSpecCharacteristics(int? id, bool justUserVisible = false)
  {
    using (new HighResolutionTimer("SpecCharacteristicRepository::LoadSpecCharacteristics method"))
    {
      var modelSpecs = new List<SpecCharacteristicModel>();

      SpecificationsServiceClient client = null;

      try
      {
        client = new SpecificationsServiceClient();
        if (client.ClientCredentials != null)
        {
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }

        var specs = new MTList<SpecificationCharacteristic>();

        if (justUserVisible)
        {
          var fe = new MTFilterElement("UserVisible", MTFilterElement.OperationType.Equal, "Y");
          specs.Filters.Add(fe);
        }

        if (id.HasValue)
        {
          client.GetSpecificationCharacteristicsForEntity((int)id, ref specs);
        }
        else
        {
          client.GetSpecificationCharacteristics(ref specs);
        }
        client.Close();
        client = null;

        foreach (var spec in specs.Items)
        {
          var modelSpec = new SpecCharacteristicModel
          {
            Description = spec.Description,
            IsUserVisible = spec.UserVisible,
            IsUserEditable = spec.UserEditable,
            IsRequired = spec.IsRequired,
            Category = spec.Category,
            DisplayOrder = spec.DisplayOrder,
            EntityId = id,
            Name = spec.Name,
            SpecType = spec.SpecType
          };

          if (spec.ID != null)
            modelSpec.SpecId = spec.ID;

          SetDefaultValue(modelSpec, spec);

          modelSpecs.Add(modelSpec);
        }

      }
      catch (Exception ex)
      {
        logger.LogException(ErrorMessages.SpecCharacteristicRepository_LoadSpecCharacteristics_Failed_getting_specs_, ex);
        throw;
      }
      finally
      {
        if (client != null)
        {
          client.Abort();
        }
      }

      return modelSpecs;
    }
  }

  /// <summary>
  /// Sets the default value on the SpecCharacteristicModel, based on SpecCharacteristicValues populated on the SpecificationCharacteristic
  /// </summary>
  /// <param name="modelSpec"></param>
  /// <param name="spec"></param>
  private static void SetDefaultValue(SpecCharacteristicModel modelSpec, SpecificationCharacteristic spec)
  {
    if (spec.SpecCharacteristicValues == null) return;

    // fill in DefaultValue
    if (spec.SpecCharacteristicValues.Count == 1)
    {
      modelSpec.DefaultValue = spec.SpecCharacteristicValues[0].Value;
    }
    else
    {
      foreach (var val in spec.SpecCharacteristicValues)
      {
        if (val.IsDefault)
        {
          modelSpec.DefaultValue = val.Value;
          break;
        }
      }
    }
  }

  /// <summary>
  /// Return a SpecCharacteristicModel for specId
  /// </summary>
  /// <param name="specId"></param>
  /// <returns></returns>
  public SpecCharacteristicModel LoadSpecCharacteristic(int specId)
  {
    using (new HighResolutionTimer("SpecCharacteristicRepository::LoadSpecCharacteristic method"))
    {
      var modelSpec = new SpecCharacteristicModel();

      SpecificationsServiceClient client = null;

      try
      {
        client = new SpecificationsServiceClient();
        if (client.ClientCredentials != null)
        {
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }

        SpecificationCharacteristic spec;
        client.GetSpecificationCharacteristic(specId, out spec);
        client.Close();
        client = null;

        modelSpec.Name = spec.Name;
        modelSpec.Category = spec.Category;
        modelSpec.DisplayOrder = spec.DisplayOrder;
        modelSpec.SpecId = spec.ID;
        modelSpec.SpecType = spec.SpecType;
        modelSpec.DisplayOrder = spec.DisplayOrder;
        modelSpec.IsUserVisible = spec.UserVisible;
        modelSpec.IsUserEditable = spec.UserEditable;
        modelSpec.IsRequired = spec.IsRequired;
        modelSpec.Description = spec.Description;

        SetDefaultValue(modelSpec, spec);

      }
      catch (Exception ex)
      {
        logger.LogException(ErrorMessages.SpecCharacteristicRepository_LoadSpecCharacteristics_Failed_getting_specs_, ex);
        throw;
      }
      finally
      {
        if (client != null)
        {
          client.Abort();
        }
      }

      return modelSpec;
    }
  }

  /// <summary>
  /// Return a MTList of CharacteristicValues for an entity id.
  /// </summary>
  /// <param name="entityId"></param>
  /// <returns></returns>
  public MTList<CharacteristicValue> LoadCharacteristicValuesForEntity(int entityId)
  {
    using (new HighResolutionTimer("SpecCharacteristicRepository::LoadCharacteristicValuesForEntity method"))
    {
      var values = new MTList<CharacteristicValue>();

      SubscriptionServiceClient client = null;

      try
      {
        client = new SubscriptionServiceClient();
        if (client.ClientCredentials != null)
        {
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }

        var fe = new MTFilterElement("EntityId", MTFilterElement.OperationType.Equal, entityId);
        values.Filters.Add(fe);

        client.GetCharacteristicValues(ref values);
        client.Close();
        client = null;
      }
      catch (Exception ex)
      {
        logger.LogException(ErrorMessages.SpecCharacteristicRepository_LoadSubCharacteristicValues_Failed_getting_entity_properties_, ex);
        throw;
      }
      finally
      {
        if (client != null)
        {
          client.Abort();
        }
      }

      return values;
    }
  }

  /// <summary>
  /// Return a SpecCharacteristicValueModel for a specId
  /// </summary>
  /// <param name="specId"></param>
  /// <returns></returns>
  public SpecCharacteristicValueModel LoadSpecCharacteristicValue(int specId)
  {
    using (new HighResolutionTimer("SpecCharacteristicRepository::LoadSpecCharacteristicValue method"))
    {
      var specCharValue = new SpecCharacteristicValueModel();
      SpecificationsServiceClient client = null;

      try
      {
        client = new SpecificationsServiceClient();
        if (client.ClientCredentials != null)
        {
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }

        SpecificationCharacteristic spec;

        client.GetSpecificationCharacteristic(specId, out spec);
        client.Close();
        client = null;

        specCharValue.Category = spec.Category;
        specCharValue.Name = spec.Name;
        specCharValue.SpecId = spec.ID;
        specCharValue.SpecType = spec.SpecType;
        specCharValue.IsUserVisible = spec.UserVisible;
        specCharValue.IsUserEditable = spec.UserEditable;
        specCharValue.IsRequired = spec.IsRequired;
        specCharValue.Description = spec.Description;

        // min and max restrictions
        switch (spec.SpecType)
        {
          case PropertyType.String:
            if (!String.IsNullOrEmpty(spec.MinValue))
              if (spec.MinValue != "NULL")
                specCharValue.Length = int.Parse(spec.MinValue);
            break;
          case PropertyType.Int:
            if (!String.IsNullOrEmpty(spec.MinValue))
              if (spec.MinValue != "NULL")
                specCharValue.Min = int.Parse(spec.MinValue);
            if (!String.IsNullOrEmpty(spec.MaxValue))
              if (spec.MaxValue != "NULL")
                specCharValue.Max = int.Parse(spec.MaxValue);
            break;
          case PropertyType.Decimal:
            if (!String.IsNullOrEmpty(spec.MinValue))
              if (spec.MinValue != "NULL")
                specCharValue.MinDecimal = decimal.Parse(spec.MinValue);
            if (!String.IsNullOrEmpty(spec.MaxValue))
              if (spec.MaxValue != "NULL")
                specCharValue.MaxDecimal = decimal.Parse(spec.MaxValue);
            break;
          case PropertyType.Boolean:
            if (!String.IsNullOrEmpty(spec.MinValue))
              if (spec.MinValue != "NULL")
                specCharValue.BooleanValue = bool.Parse(spec.MinValue);
            break;
          case PropertyType.Datetime:
            if (!String.IsNullOrEmpty(spec.MinValue))
              if (spec.MinValue != "NULL")
                specCharValue.BetweenStartDate = DateTime.Parse(spec.MinValue);
            if (!String.IsNullOrEmpty(spec.MaxValue))
              if (spec.MaxValue != "NULL")
                specCharValue.BetweenEndDate = DateTime.Parse(spec.MaxValue);
            break;
          case PropertyType.List:
            break;
          default:
            throw new ArgumentOutOfRangeException();
        }

        var choicesDisplayNames = new Dictionary<LanguageCode, string>();
        string val = "";
        if (spec.SpecCharacteristicValues != null &&
            spec.SpecCharacteristicValues.Count > 0 &&
            spec.SpecCharacteristicValues[0] != null)
        {
          // value
          val = spec.SpecCharacteristicValues[0].Value;
          specCharValue.ValueId = spec.SpecCharacteristicValues[0].ID;

          // value localization
          foreach (var v in spec.SpecCharacteristicValues)
          {
            if (v.LocalizedDisplayValues != null)
            {
              foreach (var displayValue in v.LocalizedDisplayValues)
              {
                choicesDisplayNames[displayValue.Key] += displayValue.Value + Environment.NewLine;
              }
            }
          }
          specCharValue.ChoicesDisplayNames = choicesDisplayNames;
        }

        switch (spec.SpecType)
        {
          case PropertyType.String:
            specCharValue.StringValue = val;
            break;
          case PropertyType.Int:
            specCharValue.IntValue = int.Parse(val);
            break;
          case PropertyType.Decimal:
            specCharValue.DecimalValue = Decimal.Parse(val);
            break;
          case PropertyType.List:
            if (spec.SpecCharacteristicValues != null &&
                spec.SpecCharacteristicValues.Count > 0 &&
                spec.SpecCharacteristicValues[0] != null)
            {
              specCharValue.ValueIds = new List<string>();
              foreach (var v in spec.SpecCharacteristicValues)
              {
                specCharValue.Choices += v.Value + Environment.NewLine;
                if (v.ID != null)
                  specCharValue.ValueIds.Add(v.ID.Value.ToString(CultureInfo.InvariantCulture));
                if (v.IsDefault)
                  specCharValue.DefaultChoice = v.Value;
              }
            }
            break;
          case PropertyType.Boolean:
            specCharValue.BooleanValue = bool.Parse(val);
            break;
          case PropertyType.Datetime:
            if (!string.IsNullOrEmpty(val))
            {
              specCharValue.DatetimeValue = DateTime.Parse(val);
            }
            break;
          default:
            throw new ArgumentOutOfRangeException();
        }

        specCharValue.NameDisplayNames = spec.LocalizedDisplayNames;
        specCharValue.DescriptionDisplayNames = spec.LocalizedDescriptions;
        specCharValue.CategoryDisplayNames = spec.CategoryDisplayNames;
      }
      catch (Exception ex)
      {
        logger.LogException(ErrorMessages.SpecCharacteristicRepository_LoadSpecCharacteristics_Failed_getting_specs_, ex);
        throw;
      }
      finally
      {
        if (client != null)
        {
          client.Abort();
        }
      }

      return specCharValue;
    }
  }

  /// <summary>
  /// SaveSpecCharacteristic - calls SaveSpecificationCharacteristicForEntity service
  /// </summary>
  /// <param name="spec"></param>
  /// <param name="entityType"> </param>
  /// <param name="entityId"> </param>
  /// <param name="saveDetails"> </param>
  public void SaveSpecCharacteristic(SpecCharacteristicModel spec, EntityType entityType, int? entityId, bool saveDetails = true)
  {
    using (new HighResolutionTimer("SpecCharacteristicRepository::SpecCharacteristicModel method"))
    {
      SpecificationsServiceClient client = null;
      try
      {
        client = new SpecificationsServiceClient();
        if (client.ClientCredentials != null)
        {
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }

        var saveSpec = GetSpecForModel(spec);
        if (!saveDetails)
          saveSpec.SpecCharacteristicValues = null;

        // if we have an entity id, then we need to connect the spec to the entity
        if (entityId.HasValue)
        {
          client.SaveSpecificationCharacteristicForEntity((int)entityId, entityType, saveSpec);
        }
        else
        {
          client.SaveSpecificationCharacteristic(ref saveSpec);
        }
        client.Close();
        client = null;
      }
      catch (Exception ex)
      {
        logger.LogException(ErrorMessages.SpecCharacteristicRepository_SaveSpecCharacteristic_Failed_saving_spec_, ex);
        throw;
      }
      finally
      {
        if (client != null)
        {
          client.Abort();
        }
      }
    }
  }

  /// <summary>
  /// SaveSpecCharacteristicValue - calls SaveSpecificationCharacteristicForEntity with the values populated
  /// </summary>
  /// <param name="specCharValue"></param>
  /// <param name="entityType"> </param>
  /// <param name="entityId"> </param>
  public void SaveSpecCharacteristicValue(SpecCharacteristicValueModel specCharValue, EntityType entityType, int? entityId)
  {
    using (new HighResolutionTimer("SpecCharacteristicRepository::SaveSpecCharacteristicValue method"))
    {
      SpecificationsServiceClient client = null;
      try
      {
        client = new SpecificationsServiceClient();
        if (client.ClientCredentials != null)
        {
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }

        var newSpecCharValue = GetSpecCharWithValuesForModel(specCharValue);

        if (entityId.HasValue)
        {
          client.SaveSpecificationCharacteristicForEntity((int)entityId, entityType, newSpecCharValue);
        }
        else
        {
          client.SaveSpecificationCharacteristic(ref newSpecCharValue);
        }
        client.Close();
        client = null;
      }
      catch (Exception ex)
      {
        logger.LogException(ErrorMessages.SpecCharacteristicRepository_SaveSpecCharacteristic_Failed_saving_spec_, ex);
        throw;
      }
      finally
      {
        if (client != null)
        {
          client.Abort();
        }
      }

    }
  }

  /// <summary>
  /// DeleteSpecCharacteristic - delete a spec by id
  /// </summary>
  /// <param name="specId"> </param>
  /// <param name="entityId"> </param>
  public void DeleteSpecCharacteristic(int specId, int? entityId)
  {
    using (new HighResolutionTimer("SpecCharacteristicRepository::DeleteSpecCharacteristic method"))
    {
      SpecificationsServiceClient client = null;
      try
      {
        client = new SpecificationsServiceClient();
        if (client.ClientCredentials != null)
        {
          client.ClientCredentials.UserName.UserName = UI.User.UserName;
          client.ClientCredentials.UserName.Password = UI.User.SessionPassword;
        }

        if (entityId.HasValue)
        {
          client.RemoveSpecificationCharacteristicFromEntity(specId, (int)entityId);
        }
        else
        {
          client.DeleteSpecificationCharacteristic(specId);
        }
        client.Close();
        client = null;
      }
      catch (Exception ex)
      {
        logger.LogException(ErrorMessages.SpecCharacteristicRepository_DeleteSpecCharacteristic_Failed_deleting_spec_,
                            ex);
        throw;
      }
      finally
      {
        if (client != null)
        {
          client.Abort();
        }
      }

    }
  }

  /// <summary>
  /// GetSpecForModel - copies the UI view model into a SpecificationCharacteristic
  /// </summary>
  /// <param name="spec"></param>
  /// <returns></returns>
  public SpecificationCharacteristic GetSpecForModel(SpecCharacteristicModel spec)
  {
    using (new HighResolutionTimer("SpecCharacteristicRepository::GetSpecForModel method"))
    {
      var newSpec = new SpecificationCharacteristic
      {
        Category = spec.Category,
        Name = spec.Name,
        SpecType = spec.SpecType,
        DisplayOrder = spec.DisplayOrder,
        ID = spec.SpecId,
        SpecCharacteristicValues = null,
        IsRequired = spec.IsRequired,
        UserEditable = spec.IsUserEditable,
        UserVisible = spec.IsUserVisible,
        Description = spec.Description
      };

      return newSpec;
    }
  }

  /// <summary>
  /// GetSpecCharWithValuesForModel - copies the UI view model into a SpecCharacteristic with Values
  /// </summary>
  /// <param name="specCharValue"></param>
  /// <returns></returns>
  public SpecificationCharacteristic GetSpecCharWithValuesForModel(SpecCharacteristicValueModel specCharValue)
  {
    using (new HighResolutionTimer("SpecCharacteristicRepository::GetSpecCharWithValuesForModel method"))
    {
      // get spec
      var tempModel = specCharValue.SpecId.HasValue
                        ? LoadSpecCharacteristic((int)specCharValue.SpecId)
                        : new SpecCharacteristicModel();
      var newSpec = GetSpecForModel(tempModel);

      // add values
      newSpec.IsRequired = specCharValue.IsRequired;
      newSpec.UserVisible = specCharValue.IsUserVisible;
      newSpec.UserEditable = specCharValue.IsUserEditable;
      newSpec.LocalizedDisplayNames = specCharValue.NameDisplayNames;
      newSpec.LocalizedDescriptions = specCharValue.DescriptionDisplayNames;
      newSpec.CategoryDisplayNames = specCharValue.CategoryDisplayNames;
      newSpec.Description = specCharValue.Description;
      newSpec.Name = specCharValue.Name;
      newSpec.SpecType = specCharValue.SpecType;
      newSpec.ID = specCharValue.SpecId;
      newSpec.Category = specCharValue.Category;
      newSpec.SpecCharacteristicValues = new List<SpecCharacteristicValue>();

      // min and max restrictions
      // ReSharper disable SpecifyACultureInStringConversionExplicitly
      switch (specCharValue.SpecType)
      {
        case PropertyType.String:
          if (specCharValue.Length != null)
            newSpec.MinValue = specCharValue.Length.ToString();
          break;
        case PropertyType.Int:
          if (specCharValue.Min != null)
            newSpec.MinValue = specCharValue.Min.ToString();
          if (specCharValue.Max != null)
            newSpec.MaxValue = specCharValue.Max.ToString();
          break;
        case PropertyType.Decimal:
          if (specCharValue.MinDecimal != null)
            newSpec.MinValue = specCharValue.MinDecimal.ToString();
          if (specCharValue.MaxDecimal != null)
            newSpec.MaxValue = specCharValue.MaxDecimal.ToString();
          break;
        case PropertyType.Boolean:
          newSpec.MinValue = specCharValue.BooleanValue.ToString();
          break;
        case PropertyType.Datetime:
          newSpec.MinValue = specCharValue.BetweenStartDate.ToString();
          newSpec.MaxValue = specCharValue.BetweenEndDate.ToString();
          break;
        case PropertyType.List:
          break;
        default:
          throw new ArgumentOutOfRangeException();
      }
      // ReSharper restore SpecifyACultureInStringConversionExplicitly

      if (specCharValue.SpecType == PropertyType.List)
      {
        // Add all the values in a list
        if (!String.IsNullOrEmpty(specCharValue.Choices))
        {
          var values = specCharValue.Choices.Split(new[] { Environment.NewLine }, StringSplitOptions.RemoveEmptyEntries);
          int i = 0;
          foreach (var tempVal in values)
          {
            var v = tempVal ?? String.Empty;
            int? valueId = null;
            if (specCharValue.ValueIds != null && specCharValue.ValueIds.Count > i)
            {
              if (!String.IsNullOrEmpty(specCharValue.ValueIds[i]))
                valueId = int.Parse(specCharValue.ValueIds[i]);
            }

            var newValue = new SpecCharacteristicValue
            {
              ID = valueId,
              Value = v,
              IsDefault = specCharValue.DefaultChoice == v,
              LocalizedDisplayValues = specCharValue.ChoicesDisplayNames
            };
            newSpec.SpecCharacteristicValues.Add(newValue);
            i++;
          }
        }
      }
      else
      {
        var newValue = new SpecCharacteristicValue { ID = specCharValue.ValueId ?? 0 };

        string val;
        switch (specCharValue.SpecType)
        {
          case PropertyType.String:
            val = specCharValue.StringValue;
            break;
          case PropertyType.Int:
            val = specCharValue.IntValue.ToString(CultureInfo.InvariantCulture);
            break;
          case PropertyType.Decimal:
            val = specCharValue.DecimalValue.ToString(CultureInfo.InvariantCulture);
            break;
          case PropertyType.Boolean:
            val = specCharValue.BooleanValue.ToString(CultureInfo.InvariantCulture);
            break;
          case PropertyType.Datetime:
            val = specCharValue.DatetimeValue.ToString(CultureInfo.InvariantCulture);
            break;
          default:
            throw new ArgumentOutOfRangeException();
        }
        if (val == null) val = String.Empty;
        newValue.Value = val;
        newValue.IsDefault = specCharValue.DefaultChoice == val;
        newSpec.SpecCharacteristicValues.Add(newValue);
      }

      return newSpec;
    }
  }

}