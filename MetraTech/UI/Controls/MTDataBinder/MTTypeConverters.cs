using System;
using System.ComponentModel;
using System.Collections;
using System.Drawing;
using System.Windows.Forms;

using MetraTech;
using MetraTech.Xml;
using MetraTech.Pipeline;
using System.Data;
using MetraTech.UI.Common;
using System.Reflection;

namespace MetraTech.UI.Controls
{
  //////////////////////////////////////////////////////////////////////////////////////////
  #region MetaDataTypeConverter
  public class MetaDataTypeConverter : System.ComponentModel.TypeConverter
  {
    private ArrayList values = new ArrayList();
    private ServiceDefinitionCollection mSDCol = new ServiceDefinitionCollection();

    public MetaDataTypeConverter()
    {
    }

    // Indicates this converter provides a list of standard values.
    public override bool GetStandardValuesSupported(System.ComponentModel.ITypeDescriptorContext context)
    {
      return true;
    }

    // Returns a StandardValuesCollection of standard value objects.
    public override System.ComponentModel.TypeConverter.StandardValuesCollection GetStandardValues(System.ComponentModel.ITypeDescriptorContext context)
    {
      if (context != null)
      {

        MetaDataItem itm = context.Instance as MetaDataItem;
        values.Clear();

        if (itm != null)
        {
          switch (itm.MetaType)
          {
            // Service Def Type
            case MetaDataType.ServiceDefinition:
              foreach (string s in mSDCol.SortedNames)
              {
                values.Add(s);
              }
              break;

            case MetaDataType.DomainModel:

              AssemblyName nm = AssemblyName.GetAssemblyName(itm.AssemblyName);
              Assembly a = Assembly.Load(nm);
              Type[] types = a.GetTypes();
              foreach (Type t in types)
              {
                values.Add(t.Name);
              }
              break;

            default:
              values.Add("Type not supported");
              break;
          }
        }
      }

      // Passes the local array.
      StandardValuesCollection svc = new StandardValuesCollection(values);
      return svc;
    }

    // Returns true for a sourceType of string to indicate that 
    // conversions from string to integer are supported. (The 
    // GetStandardValues method requires a string to native type 
    // conversion because the items in the drop-down list are 
    // translated to string.)
    public override bool CanConvertFrom(System.ComponentModel.ITypeDescriptorContext context, System.Type sourceType)
    {
      if (sourceType == typeof(string))
        return true;
      else
        return base.CanConvertFrom(context, sourceType);
    }

    public override object ConvertFrom(System.ComponentModel.ITypeDescriptorContext context, System.Globalization.CultureInfo culture, object value)
    {
      if (value.GetType() == typeof(string))
      {
        // Parses the string to get the integer to set to the property.
        string newVal = value.ToString();

        // Tests whether new integer is already in the list.
        if (!values.Contains(newVal))
        {
          // If the integer is not in list, adds it in order.
          values.Add(newVal);
          values.Sort();
        }
        // Returns the integer value to assign to the property.
        return newVal;
      }
      else
        return base.ConvertFrom(context, culture, value);
    }
  }
  #endregion
  
  //////////////////////////////////////////////////////////////////////////////////////////
  #region MTPropertyConverter
  public class MTPropertyConverter : System.ComponentModel.TypeConverter
  {
    private ArrayList values = new ArrayList();

    public MTPropertyConverter()
    {

    }

    // Indicates this converter provides a list of standard values.
    public override bool GetStandardValuesSupported(System.ComponentModel.ITypeDescriptorContext context)
    {
      return true;
    }

    // Returns a StandardValuesCollection of standard value objects.
    public override System.ComponentModel.TypeConverter.StandardValuesCollection GetStandardValues(System.ComponentModel.ITypeDescriptorContext context)
    {
      if (context != null)
      {

        MTDataBindingItem designerProperties = context.Instance as MTDataBindingItem;
        values.Clear();

        if (designerProperties != null)
        {
          MTDataBinder binderCtrl = designerProperties.Binder;
          if(binderCtrl != null)
          {
            foreach (MetaDataItem itm in binderCtrl.MetaDataMappings)
            {
              if (designerProperties.BindingMetaDataAlias == itm.Alias)
              {
                // Service Definition
                if (itm.MetaType == MetaDataType.ServiceDefinition)
                {
                  string serviceDef = itm.Value;
                  if ((!String.IsNullOrEmpty(serviceDef)))
                  {
                    PropertyDS props = null;
                    props = ServiceDefinitionManager.GetServiceProperties(serviceDef);

                    PropertyDS dsTemp = props.Copy() as PropertyDS;
                    DataView dv = new DataView(dsTemp.Property);
                    dv.Sort = "Name ASC";

                    foreach (System.Data.DataRowView r in dv)
                    {
                      values.Add(r["Name"].ToString());
                    }
                  }
                }

                // Donain Model
                if (itm.MetaType == MetaDataType.DomainModel)
                {
                  AssemblyName nm = AssemblyName.GetAssemblyName(itm.AssemblyName);
                  Assembly a = Assembly.Load(nm);
                  Type[] types = a.GetTypes();
                  foreach (Type t in types)
                  {
                    if (t.Name == itm.Value)
                    {
                      RecurseProperties(t, t.Name, itm.AliasBaseType, 0, values);
                    }

                  }
                }

              }
            }
          }

        }
      }

      // Passes the local integer array.
      StandardValuesCollection svc = new StandardValuesCollection(values);
      return svc;
    }

    static public void RecurseProperties(Type t, string curType, string baseType, int i, ArrayList values)
    {
      i++;
      if (i > 3)
        return;

      foreach (PropertyInfo p1 in t.GetProperties())
      {
        if (curType == baseType)
        {
          values.Add(p1.Name);
        }
        else if (baseType == "")
        {
          values.Add(curType + "." + p1.Name);
        }

        RecurseProperties(p1.PropertyType, curType + "." + p1.Name, baseType, i, values);
      }
    }

    // Returns true for a sourceType of string to indicate that 
    // conversions from string to integer are supported. (The 
    // GetStandardValues method requires a string to native type 
    // conversion because the items in the drop-down list are 
    // translated to string.)
    public override bool CanConvertFrom(System.ComponentModel.ITypeDescriptorContext context, System.Type sourceType)
    {
      if (sourceType == typeof(string))
        return true;
      else
        return base.CanConvertFrom(context, sourceType);
    }

    public override object ConvertFrom(System.ComponentModel.ITypeDescriptorContext context, System.Globalization.CultureInfo culture, object value)
    {
      if (value.GetType() == typeof(string))
      {
        // Parses the string to get the integer to set to the property.
        string newVal = value.ToString();

        // Tests whether new integer is already in the list.
        if (!values.Contains(newVal))
        {
          // If the integer is not in list, adds it in order.
          values.Add(newVal);
          values.Sort();
        }
        // Returns the integer value to assign to the property.
        return newVal;
      }
      else
        return base.ConvertFrom(context, culture, value);

    }
  }
  #endregion

  //////////////////////////////////////////////////////////////////////////////////////////
  #region MetaDataAliasConverter
  public class MetaDataAliasConverter : System.ComponentModel.TypeConverter
  {
    private ArrayList values = new ArrayList();

    public MetaDataAliasConverter()
    {

    }

    // Indicates this converter provides a list of standard values.
    public override bool GetStandardValuesSupported(System.ComponentModel.ITypeDescriptorContext context)
    {
      return true;
    }

    // Returns a StandardValuesCollection of standard value objects.
    public override System.ComponentModel.TypeConverter.StandardValuesCollection GetStandardValues(System.ComponentModel.ITypeDescriptorContext context)
    {
      if (context != null)
      {
        MTDataBindingItem designerProperties = context.Instance as MTDataBindingItem;
        values.Clear();

        if (designerProperties != null)
        {
          MTDataBinder binderCtrl = designerProperties.Binder;
          if (binderCtrl != null)
          {
            foreach (MetaDataItem itm in binderCtrl.MetaDataMappings)
            {
              values.Add(itm.Alias);
            }
          }
        }
      }

      // Passes the local integer array.
      StandardValuesCollection svc = new StandardValuesCollection(values);
      return svc;
    }

    // Returns true for a sourceType of string to indicate that 
    // conversions from string to integer are supported. (The 
    // GetStandardValues method requires a string to native type 
    // conversion because the items in the drop-down list are 
    // translated to string.)
    public override bool CanConvertFrom(System.ComponentModel.ITypeDescriptorContext context, System.Type sourceType)
    {
      if (sourceType == typeof(string))
        return true;
      else
        return base.CanConvertFrom(context, sourceType);
    }

    public override object ConvertFrom(System.ComponentModel.ITypeDescriptorContext context, System.Globalization.CultureInfo culture, object value)
    {
      if (value.GetType() == typeof(string))
      {
        // Parses the string to get the integer to set to the property.
        string newVal = value.ToString();

        // Tests whether new integer is already in the list.
        if (!values.Contains(newVal))
        {
          // If the integer is not in list, adds it in order.
          values.Add(newVal);
          values.Sort();
        }
        // Returns the integer value to assign to the property.
        return newVal;
      }
      else
        return base.ConvertFrom(context, culture, value);

    }
  }  
#endregion

}