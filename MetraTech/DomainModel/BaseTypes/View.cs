using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.Serialization;
using System.Reflection;
using System.IO;

using MetraTech.DomainModel.Common;
using System.Web.Script.Serialization;

namespace MetraTech.DomainModel.BaseTypes
{
  [KnownType("KnownTypes")]
  [DataContract]
  [Serializable] 
  public abstract class View : AccountBase, ICloneable, IEquatable<View>
  {
    [ScriptIgnore]
    public string ViewName
    {
      get 
      {
        string viewName = "";

        object[] attributes = GetType().GetCustomAttributes(typeof(MTViewAttribute), false);
        if (attributes != null && attributes.Length > 0)
        {
          MTViewAttribute attribute = attributes[0] as MTViewAttribute;

          viewName = attribute.ViewType;
        }

        return viewName; 
      }
    }

    public static Type[] KnownTypes()
    {
      return GetKnownTypes(typeof(MTViewAttribute));
    }
    

    public static View CreateView(string typeName)
    {
      View view = null;

      Assembly assembly = GetAccountTypesAssembly();

      Type viewType = null;

      foreach (Type type in assembly.GetTypes())
      {
        object[] attributes = type.GetCustomAttributes(typeof(MTViewAttribute), false);
        if (attributes != null && attributes.Length > 0)
        {
          MTViewAttribute attribute = attributes[0] as MTViewAttribute;

          if (type.Name.ToLower() == typeName.ToLower() ||
              type.FullName.ToLower() == typeName.ToLower() ||
              attribute.ViewType.ToLower() == typeName.ToLower())
          {
            viewType = type;
            break;
          }
        }
      }

      if (viewType == null)
      {
        //logger.LogError(String.Format("Unable to create view of type '{0}' from assembly 'MetraTech.DomainModel.BaseTypes.dll'", typeName));
        throw new ApplicationException(String.Format("Unable to create view of type '{0}' from assembly 'MetraTech.DomainModel.BaseTypes.dll'", typeName));
      }

      // Create an instance of viewType
      view = Activator.CreateInstance(viewType, false) as View;

      return view;
    }

    public MTViewAttribute GetCustomAttributes()
    {
      object[] attributes = GetType().GetCustomAttributes(typeof(MTViewAttribute), false);
      if (attributes != null)
        return (MTViewAttribute)attributes[0];
      else
        return null;
    }

    public void ApplyDirtyProperties(View modifiedView)
    {
      if (this.Equals(modifiedView))
      {
        List<PropertyInfo> viewProps = GetMTProperties();

        foreach (PropertyInfo prop in viewProps)
        {
          if (modifiedView.IsDirty(prop))
          {
            prop.SetValue(this, prop.GetValue(modifiedView, null), null);
          }
        }
      }
      else
      {
        throw new ArgumentException("The modified view does not match this view");
      }
    }

    public static List<PropertyInfo> GetKeyProperties(string viewName)
    {
      List<PropertyInfo> keyProps = new List<PropertyInfo>();
      View view = View.CreateView(viewName);

      List<PropertyInfo> viewProps = view.GetMTProperties();

      foreach (PropertyInfo viewProp in viewProps)
      {
        MTDataMemberAttribute attrib = view.GetMTDataMemberAttribute(viewProp);

        if (attrib.IsPartOfKey)
        {
          keyProps.Add(viewProp);
        }
      }

      return keyProps;
    }

    //public object GetDbValue(PropertyInfo pi)
    //{
    //  return EnumHelper.GetDbValue(this, pi);
    //}

    #region ICloneable Members

    public object Clone()
    {
      View newView = null;

      newView = View.CreateView(this.ViewName);

      List<PropertyInfo> keyProps = View.GetKeyProperties(this.ViewName);

      foreach (PropertyInfo keyProp in keyProps)
      {
        newView.SetValue(keyProp, this.GetValue(keyProp.Name));
      }

      newView.ApplyDirtyProperties(this);

      return newView;
    }

    #endregion

    #region IEquatable<View> Members

    public bool Equals(View other)
    {
      bool retval = true;

      if (this.GetType() == other.GetType())
      {
        List<PropertyInfo> keyProps = View.GetKeyProperties(this.ViewName);

        foreach (PropertyInfo keyProp in keyProps)
        {
          object thisVal = this.GetValue(keyProp.Name);
          object otherVal = other.GetValue(keyProp.Name);

          if ( (thisVal == null && otherVal != null) || 
                (thisVal != null && otherVal == null) ||
                (thisVal != null && !thisVal.Equals(otherVal)))
          {
            retval = false;
            break;
          }
        }
      }
      else
      {
        retval = false;
      }

      return retval;
    }

    #endregion
  }
}
