using System.Data;
using System.Diagnostics;
using System;
using System.Collections.Generic;

namespace MetraTech.UI.Common {

  public enum PropertyType
  {
    Unknown,
    String,
    DateTime,
    Float,
    Decimal,
    Double,
    Int32,
    Int64,
    Boolean,
    Enum
  }

  partial class PropertyDS
  {
    /// <summary>
    ///    Indexer for setting and getting property values based on name.
    /// </summary>
    /// <param name="propertyName"></param>
    /// <returns></returns>
    public object this[string propertyName]
    {
      get
      {
        return GetPropertyValue(propertyName);
      }
      set
      {
        string dbValue = Convert.ToString(value);
        SetPropertyValue(propertyName, dbValue);
      }
    }

    public string GetPropertyType(string propertyName)
    {
      DataRow[] dataRows = Property.Select("Name = '" + propertyName + "'");
      PropertyRow propertyRow = dataRows[0] as PropertyRow;
      return propertyRow.Type;
    }


    public void SetPropertyValue(string propertyName, string value)
    {
      // TODO Handle errors
      DataView dataView = new DataView();
      dataView.Table = Property;
      dataView.AllowEdit = true;
      dataView.RowFilter = "Name = '" + propertyName + "'";

      Debug.Assert(dataView.Count == 1);
      dataView[0]["value"] = value;
    }

    /// <summary>
    /// Check if the property exists
    /// </summary>
    /// <param name="propertyName"></param>
    /// <returns>true / false</returns>
    public bool Exists(string propertyName)
    {
      DataView dataView = new DataView();
      dataView.Table = Property;
      dataView.AllowEdit = true;
      dataView.RowFilter = "Name = '" + propertyName + "'";

      if (dataView.Count == 0)
      {
        return false;
      }
      else
      {
        return true;
      }
    }

    /// <summary>
    /// Return true if enum... else false
    /// </summary>
    /// <param name="propertyName"></param>
    /// <returns></returns>
    public bool IsEnum(string propertyName)
    {
      bool isEnum = false;

      DataRow[] dataRows = Property.Select("Name = '" + propertyName + "'");
      // ensure only one property with the given name exists
      Debug.Assert(dataRows.Length == 1);

      // Cast to PropertyRow so we can use strong typing 
      PropertyRow propertyRow = dataRows[0] as PropertyRow;

      // Parse the type
      PropertyType propertyType =
        (PropertyType)System.Enum.Parse(typeof(PropertyType), propertyRow.Type);

      if (propertyType == PropertyType.Enum)
      {
        isEnum = true;
      }

      return isEnum;

    }

    /// <summary>
    ///   Return the value of the given propertyName. Null, if the value is null.
    ///   If the property is an Enum property, an EnumData object will be returned.
    /// </summary>
    /// <param name="propertyName"></param>
    /// <returns></returns>
    public object GetPropertyValue(string propertyName)
    {
      object propertyValue = null;

      PropertyRow propertyRow = GetPropertyRow(propertyName);

      // Determine the type of the property
      PropertyType propertyType =
        (PropertyType)System.Enum.Parse(typeof(PropertyType), propertyRow.Type);
      
      if (!propertyRow.IsValueNull())
      {
        propertyValue = ConvertDataValue(propertyRow.Value, propertyType);
      }

      // Handle enums
      if (propertyType == PropertyType.Enum)
      {
        // Get the EnumRows
        // Get property row
        DataRow[] dataRows = Enum.Select("EnumType = '" + propertyRow.EnumType + "'");

        EnumData enumData = new EnumData();
        enumData.SelectedValue = propertyValue as string;
        enumData.EnumType = propertyRow.EnumType;

        // Create EnumItem's for each row
        List<EnumItem> enumItems = new List<EnumItem>();
        EnumItem enumItem = null;

        foreach (EnumRow enumRow in dataRows)
        {
          enumItem = new EnumItem();
          enumItem.Id = enumRow.Id;
          enumItem.Name = enumRow.Name;
          enumItem.LocalizedName = enumRow.LocalizedName;
          enumItems.Add(enumItem);
        }

        enumData.EnumItems = enumItems;

        // Return the EnumData 
        propertyValue = enumData;
      }
     
      return propertyValue;
    }

    /// <summary>
    ///    
    /// </summary>
    /// <param name="propertyName"></param>
    /// <param name="propertyType"></param>
    /// <param name="length"></param>
    /// <param name="isRequired"></param>
    /// <param name="description"></param>
    /// <param name="defaultValue"></param>
    /// <param name="value"></param>
    public void AddProperty(string propertyName, 
                            PropertyType propertyType, 
                            int length,
                            bool isRequired, 
                            string description,
                            string defaultValue,
                            string value)
    {
      this.Property.AddPropertyRow
        (propertyName, propertyType.ToString(), length, isRequired, defaultValue, description, value, null, null, null);
    }

    public PropertyRow GetPropertyRow(string propertyName)
    {
      PropertyRow propertyRow = null;

      // Get property row
      DataRow[] dataRows = Property.Select("Name = '" + propertyName + "'");

      // ensure only one property with the given name exists
      Debug.Assert(dataRows.Length == 1);

      // Cast to PropertyRow  
      propertyRow = dataRows[0] as PropertyRow;

      return propertyRow;
    }

    private object ConvertDataValue(string value, PropertyType propertyType)
    {
      object dataValue = null;

      switch (propertyType)
      {
        case PropertyType.Boolean:
          {
            dataValue = Convert.ToBoolean(value);
            break;
          }
        case PropertyType.Decimal:
          {
            dataValue = Convert.ToDecimal(value);
            break;
          }
        case PropertyType.Double:
          {
            dataValue = Convert.ToDouble(value);
            break;
          }
        case PropertyType.Float:
          {
            dataValue = Convert.ToDecimal(value);
            break;
          }
        case PropertyType.Int64:
          {
            dataValue = Convert.ToInt64(value);
            break;
          }
        case PropertyType.String:
        case PropertyType.Enum:
          {
            dataValue = value;
            break;
          }
        case PropertyType.Int32:
          {
            dataValue = Convert.ToInt32(value);
            break;
          }
        case PropertyType.DateTime:
          {
            dataValue = Convert.ToDateTime(value);
            break;
          }
        default:
          {
            throw new ApplicationException("Invalid data type");
          }
      }

      return dataValue;
    }
  }

  public class EnumData
  {
    // Selected Value
    private string selectedValue;
    public string SelectedValue
    {
      get { return selectedValue; }
      set { selectedValue = value; }
    }

    // EnumType 
    private string enumType;
    public string EnumType
    {
      get { return enumType; }
      set { enumType = value; }
    }

    // EnumItems 
    private List<EnumItem> enumItems;
    public List<EnumItem> EnumItems
    {
      get { return enumItems; }
      set { enumItems = value; }
    }

    public string GetLocalizedName(string id)
    {
      string localizedName = string.Empty;
      foreach (EnumItem itm in EnumItems)
      {
        if (itm.Id.Equals(id))
        {
          localizedName = itm.LocalizedName;
          break;
        }
      }
      return localizedName;
    }
  }

  public class EnumItem
  {
    // Id
    private string id;
    public string Id
    {
      get { return id; }
      set { id = value; }
    }

    // Name
    private string name;
    public string Name
    {
      get { return name; }
      set { name = value; }
    }

    // Localized Name
    private string localizedName;
    public string LocalizedName
    {
      get { return localizedName; }
      set { localizedName = value; }
    }
	
  }
}
