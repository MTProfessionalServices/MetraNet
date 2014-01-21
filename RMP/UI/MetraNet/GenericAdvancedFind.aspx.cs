using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using MetraTech.UI.Common;
using MetraTech.Accounts.Type;
using System.Collections.Generic;
using MetraTech.DomainModel.Common;
using MetraTech.DomainModel.Enums;
using System.Reflection;
using MetraTech.UI.Controls;
using System.ComponentModel;
using MetraTech.DomainModel.BaseTypes;

public partial class GenericAdvancedFind : MTPage
{/*
  protected void Page_Load(object sender, EventArgs e)
  {
    List<Type> accountTypes = GetAccountTypeList();
    List<PropertyInfo> fullPropList = new List<PropertyInfo>();
    List<string> propListNames = new List<string>();

    //for each of the types
    foreach (Type curAccountType in accountTypes)
    {
      ProcessAccountType(curAccountType, String.Empty, fullPropList, propListNames);
    }

    //foreach (PropertyInfo pi in fullPropList)
    for(int i = 0; i < fullPropList.Count; i++)
    {
      PropertyInfo pi = fullPropList[i];

      if ((pi.Name.ToLower() != "_accountid") && (pi.Name.ToLower() != "username"))
      {
        MTGridDataElement de = new MTGridDataElement();
        de.DataIndex = propListNames[i]; //pi.Name.ToLower();
        de.DataType = GetDataTypeByPropertyInfo(pi);
        if (de.DataType == MTDataType.List)
        {
          de.FilterEnum.EnumClassName = GetEnumType(pi).FullName;
        }

        de.Filterable = true;
        de.IsColumn = true;
        de.Sortable = true;
        de.HeaderText = pi.Name;
        de.ShowInExpander = true;
        de.RecordElement = true;
        de.FilterHideable = true;
        de.ID = pi.Name.ToLower().Replace('.', '_');

        MyGrid1.Elements.Add(de);
      }
    }
  }

  protected Type GetEnumType(PropertyInfo propertyInfo)
  {
    Type type = null;

    if (propertyInfo == null)
    {
      return type;
    }

    if (propertyInfo.PropertyType.IsGenericType &&
        propertyInfo.PropertyType.GetGenericTypeDefinition().Equals(typeof(Nullable<>)))
    {
      NullableConverter nullableConverter = new NullableConverter(propertyInfo.PropertyType);
      if (nullableConverter.UnderlyingType.BaseType == typeof(Enum))
      {
        type = nullableConverter.UnderlyingType;
      }
    }

    return type;
  }

  protected MTDataType GetDataTypeByPropertyInfo(PropertyInfo pi)
  {
    if ((pi.PropertyType == typeof(bool)) || (pi.PropertyType == typeof(bool?)))
    {
      return MTDataType.Boolean;
    }

    if ((pi.PropertyType == typeof(Int32)) || (pi.PropertyType == typeof(Int32?)))
    {
      return MTDataType.Numeric;
    }

    if ((pi.PropertyType == typeof(DateTime)) || (pi.PropertyType == typeof(DateTime?)))
    {
      return MTDataType.Date;
    }

    if (pi.PropertyType.IsGenericType &&
        pi.PropertyType.GetGenericTypeDefinition().Equals(typeof(Nullable<>)))
    {
      NullableConverter nullableConverter = new NullableConverter(pi.PropertyType);
      if (nullableConverter.UnderlyingType.BaseType == typeof(Enum))
      {
        return MTDataType.List;
      }
    }
    return MTDataType.String;
  }

  protected void ProcessAccountType(Type accountType, string propPath,  List<PropertyInfo> fullPropList, List<string> propListNames)
  {
    object[] attributes = null;

    if (!String.IsNullOrEmpty(propPath))
    {
      propPath += ".";
    }

    //get the property list by executing GetProperties() method on current account type
    foreach (PropertyInfo pi in accountType.GetProperties())
    {
      if (pi.PropertyType.BaseType.Name.ToLower() == "view")
      {
        ProcessAccountType(pi.PropertyType, propPath + pi.Name, fullPropList, propListNames);
      }

        //for generic types, get the actual type and feed it in
      else if ((pi.PropertyType.IsGenericType) && (pi.PropertyType.Name == "List`1"))
      {
        Type[] internalTypes = pi.PropertyType.GetGenericArguments();
        for (int i = 0; i < internalTypes.Length; i++)
        {
          ProcessAccountType(internalTypes[i],propPath + pi.Name + "[" + i.ToString() + "]", fullPropList, propListNames);
        }
      }

      else
      {
        //skip the dirty flags by extracting only the properties with MTDataMember attributes
        attributes = pi.GetCustomAttributes(typeof(MTDataMemberAttribute), false);

        if ((attributes != null) && (attributes.Length == 1))
        {
          if (!propListNames.Contains(propPath + pi.Name))
          {
            propListNames.Add(propPath + pi.Name);
            fullPropList.Add(pi);
          }
        }
      }
    }

  }

  protected List<Type> GetAccountTypeList()
  {
    List<Type> listTypes = new List<Type>();
    Type[] arrTypes = Account.GetKnownTypes(typeof(MTAccountAttribute));
    for (int i = 0; i < arrTypes.Length; i++)
    {
      if ((arrTypes[i].Name.ToLower() != "root")
          && (arrTypes[i].Name.ToLower() != "systemaccount"))
      {
        listTypes.Add(arrTypes[i]);
      }
    }

    return listTypes;
  }
  */

}
