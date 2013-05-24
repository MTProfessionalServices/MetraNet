/**************************************************************************
* Copyright 1997-2000 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Created by: Boris Partensky
* $$
* 
***************************************************************************/
using System;
using MetraTech.Interop.MTProductCatalog;





namespace MetraTech
{
  /// <summary>
	/// Implements BaseProperties C++ class behavior.
	/// </summary>
	/// <example>
  /// 
  /// Object:      PropertiesBase
  /// Description: base class for com objects implementing get_Properties()
  ///
  ///              Here's "How to implement MTProperties in 23 easy steps":
  ////
  ///              (1) make sure the system knows the meta data for the new class "MyObj":
  ///
  ///              (1a) in MtProductCatalog.idl:
  ///                   add MyObj as a new enum value to MTPCEntityType enum
  ///
  ///              (1b) in MTProductCatalogMetaData.h:
  ///                   add MyObj as a new enum value to MetaDataSetIndexType
  ///
  ///              (1c) in MTProductCatalogMetaData.cpp:
  ///                   modify CMTProductCatalogMetaData::EntityTypeToIndex()
  ///                   to add a new enum mapping for MyObj
  ///
  ///              (1d) in MTProductCatalogMetaData.cpp:
  ///                   modify CMTProductCatalogMetaData::LoadPropertyMetaData()
  ///                   to set up the meta data of MyObj
  ///
  ///              (2) derive from PropertiesBase
  ///
  ///              (3) call LoadPropertiesMetaData() in your C# object constructor, passing in
  ///                  the correct entity type:
  ///
  ///                  HRESULT CMyObj()
  ///                  { ...
  ///                     LoadPropertiesMetaData( PCENTITY_TYPE_MY_OBJ );
  ///                  }
  ///
  ///              (4) in each accessor / mutator call GetPropertyValue/PutPropertyValue
  ///                  passing in the name of the property:
  ///
  ///                  STDMETHODIMP CMyObj::get_Name(BSTR *pVal)
  ///                  { return GetPropertyValue("Name", pVal); }
  ///
  ///                  STDMETHODIMP CMyObj::put_Name(BSTR newVal)
  ///                  { return PutPropertyValue("Name", newVal); }
  ///
  /// </example>
	public class PropertiesBase
	{
    const long PROPERTIES_BASE_NO_ID = -1;


		public PropertiesBase()
		{
			mProdCat = (IMTProductCatalog)Activator.CreateInstance(Types.MTProductCatalog);
		}
    public virtual MetraTech.Interop.MTProductCatalog.IMTProperties Properties
    {
      get 
      {
        if (mPropertiesPtr == null)
          throw new System.NullReferenceException("PropertiesPtr is NULL, call LoadPropertiesMetaData first");
        return mPropertiesPtr;
      }
    }
    protected virtual void LoadPropertiesMetaData (MetraTech.Interop.MTProductCatalog.MTPCEntityType aEntityType)
    {
      mPropertiesPtr = (IMTProperties)Activator.CreateInstance(Types.MTProperties);
      MetraTech.Interop.MTProductCatalog.IMTPropertyMetaDataSet metaDataSetPtr;
      metaDataSetPtr = mProdCat.GetMetaData(aEntityType);
      int Count = metaDataSetPtr.Count;
      foreach(MTPropertyMetaData metaDataPtr in metaDataSetPtr)
      {
        mPropertiesPtr.Add(metaDataPtr);
      }
    }
    protected virtual MetraTech.Interop.MTProductCatalog.IMTProperty GetPropertyPtr(string aPropertyName)
    {
      object oProp = aPropertyName;
      if(!mPropertiesPtr.Exist(oProp))
        throw new ApplicationException(
          String.Format("Property {0} does not exist", aPropertyName));
      return (MetraTech.Interop.MTProductCatalog.IMTProperty)mPropertiesPtr[oProp];
    }
    //set/get prop value as object
    protected virtual object GetPropertyValue(string aPropertyName)
    {
      return GetPropertyPtr(aPropertyName).Value;
    }
    protected virtual void PutPropertyValue(string aPropertyName, object aPropertyValue)
    {
      GetPropertyPtr(aPropertyName).Value = aPropertyValue;
    }

    /// <summary>
    /// This method is obsolete (C++/COM implementation legacy)
    /// GetPropertyValue/PutPropertyValue which deal with object class should be used instead.
    /// Object returned from GetPropertyValue should be casted to the correct type by the caller
    /// (or not casted at all in case of object property)
    /// </summary>
    /// <example>
    /// public string Name
    /// {
    ///   get 
    ///   { 
    ///     return (string)GetPropertyValue("Name");
    ///   }
    ///   set { PutPropertyValue("Name", value); }
    /// }
    /// </example>
    /// <param name="aPropertyName"></param>
    /// <param name="apPropertyValue"></param>
    protected virtual void GetPropertyValue(string aPropertyName, ref string apPropertyValue)
    {
      apPropertyValue = (string)GetPropertyPtr(aPropertyName).Value;
    }
    /// <summary>
    /// This method is obsolete (C++/COM implementation legacy)
    /// GetPropertyValue/PutPropertyValue which deal with object class should be used instead.
    /// Object returned from GetPropertyValue should be casted to the correct type by the caller
    /// (or not casted at all in case of object property)
    /// </summary>
    /// <example>
    /// public string Name
    /// {
    ///   get 
    ///   { 
    ///     return (string)GetPropertyValue("Name");
    ///   }
    ///   set { PutPropertyValue("Name", value); }
    /// }
    /// </example>
    /// <param name="aPropertyName"></param>
    /// <param name="apPropertyValue"></param>

    protected virtual void PutPropertyValue(string aPropertyName, string aPropertyValue)
    {
      GetPropertyPtr(aPropertyName).Value = aPropertyValue;
    }
    /// <summary>
    /// This method is obsolete (C++/COM implementation legacy)
    /// GetPropertyValue/PutPropertyValue which deal with object class should be used instead.
    /// Object returned from GetPropertyValue should be casted to the correct type by the caller
    /// (or not casted at all in case of object property)
    /// </summary>
    /// <example>
    /// public string Name
    /// {
    ///   get 
    ///   { 
    ///     return (string)GetPropertyValue("Name");
    ///   }
    ///   set { PutPropertyValue("Name", value); }
    /// }
    /// </example>
    /// <param name="aPropertyName"></param>
    /// <param name="apPropertyValue"></param>
    protected virtual void GetPropertyValue(string aPropertyName, ref int apPropertyValue)
    {
      apPropertyValue = (int)GetPropertyPtr(aPropertyName).Value;
    }
    /// <summary>
    /// This method is obsolete (C++/COM implementation legacy)
    /// GetPropertyValue/PutPropertyValue which deal with object class should be used instead.
    /// Object returned from GetPropertyValue should be casted to the correct type by the caller
    /// (or not casted at all in case of object property)
    /// </summary>
    /// <example>
    /// public string Name
    /// {
    ///   get 
    ///   { 
    ///     return (string)GetPropertyValue("Name");
    ///   }
    ///   set { PutPropertyValue("Name", value); }
    /// }
    /// </example>
    /// <param name="aPropertyName"></param>
    /// <param name="apPropertyValue"></param>
    protected virtual void PutPropertyValue(string aPropertyName, int aPropertyValue)
    {
      GetPropertyPtr(aPropertyName).Value = aPropertyValue;
    }
    /// <summary>
    /// This method is obsolete (C++/COM implementation legacy)
    /// GetPropertyValue/PutPropertyValue which deal with object class should be used instead.
    /// Object returned from GetPropertyValue should be casted to the correct type by the caller
    /// (or not casted at all in case of object property)
    /// </summary>
    /// <example>
    /// public string Name
    /// {
    ///   get 
    ///   { 
    ///     return (string)GetPropertyValue("Name");
    ///   }
    ///   set { PutPropertyValue("Name", value); }
    /// }
    /// </example>
    /// <param name="aPropertyName"></param>
    /// <param name="apPropertyValue"></param>
    protected virtual void GetPropertyValue(string aPropertyName, ref bool apPropertyValue)
    {
      apPropertyValue = (bool)GetPropertyPtr(aPropertyName).Value;
    }
    /// <summary>
    /// This method is obsolete (C++/COM implementation legacy)
    /// GetPropertyValue/PutPropertyValue which deal with object class should be used instead.
    /// Object returned from GetPropertyValue should be casted to the correct type by the caller
    /// (or not casted at all in case of object property)
    /// </summary>
    /// <example>
    /// public string Name
    /// {
    ///   get 
    ///   { 
    ///     return (string)GetPropertyValue("Name");
    ///   }
    ///   set { PutPropertyValue("Name", value); }
    /// }
    /// </example>
    /// <param name="aPropertyName"></param>
    /// <param name="apPropertyValue"></param>
    protected virtual void PutPropertyValue(string aPropertyName, bool aPropertyValue)
    {
      GetPropertyPtr(aPropertyName).Value = aPropertyValue;
    }
    /// <summary>
    /// This method is obsolete (C++/COM implementation legacy)
    /// GetPropertyValue/PutPropertyValue which deal with object class should be used instead.
    /// Object returned from GetPropertyValue should be casted to the correct type by the caller
    /// (or not casted at all in case of object property)
    /// </summary>
    /// <example>
    /// public string Name
    /// {
    ///   get 
    ///   { 
    ///     return (string)GetPropertyValue("Name");
    ///   }
    ///   set { PutPropertyValue("Name", value); }
    /// }
    /// </example>
    /// <param name="aPropertyName"></param>
    /// <param name="apPropertyValue"></param>
    protected virtual void GetPropertyValue(string aPropertyName, ref System.DateTime apPropertyValue)
    {
      apPropertyValue = (System.DateTime)GetPropertyPtr(aPropertyName).Value;
    }
    /// <summary>
    /// This method is obsolete (C++/COM implementation legacy)
    /// GetPropertyValue/PutPropertyValue which deal with object class should be used instead.
    /// Object returned from GetPropertyValue should be casted to the correct type by the caller
    /// (or not casted at all in case of object property)
    /// </summary>
    /// <example>
    /// public string Name
    /// {
    ///   get 
    ///   { 
    ///     return (string)GetPropertyValue("Name");
    ///   }
    ///   set { PutPropertyValue("Name", value); }
    /// }
    /// </example>
    /// <param name="aPropertyName"></param>
    /// <param name="apPropertyValue"></param>
    protected virtual void PutPropertyValue(string aPropertyName, System.DateTime aPropertyValue)
    {
      GetPropertyPtr(aPropertyName).Value = aPropertyValue;
    }
    /// <summary>
    /// This method is obsolete (C++/COM implementation legacy)
    /// GetPropertyValue/PutPropertyValue which deal with object class should be used instead.
    /// Object returned from GetPropertyValue should be casted to the correct type by the caller
    /// (or not casted at all in case of object property)
    /// </summary>
    /// <example>
    /// public string CalculationFormula
    /// {
    ///   get 
    ///   { 
    ///     return GetPropertyValue("CalculationFormula");
    ///   }
    ///   set { PutPropertyValue("CalculationFormula", value); }
    /// }
    /// </example>
    /// <param name="aPropertyName"></param>
    /// <param name="apPropertyValue"></param>
    protected virtual void GetObjectProperty(string aPropertyName, ref object apPropertyValue)
    {
      apPropertyValue = GetPropertyPtr(aPropertyName).Value;
    }
    /// <summary>
    /// This method is obsolete (C++/COM implementation legacy)
    /// GetPropertyValue/PutPropertyValue which deal with object class should be used instead.
    /// Object returned from GetPropertyValue should be casted to the correct type by the caller
    /// (or not casted at all in case of object property)
    /// </summary>
    /// <example>
    /// public string CalculationFormula
    /// {
    ///   get 
    ///   { 
    ///     return GetPropertyValue("CalculationFormula");
    ///   }
    ///   set { PutPropertyValue("CalculationFormula", value); }
    /// }
    /// </example>
    /// <param name="aPropertyName"></param>
    /// <param name="apPropertyValue"></param>
    protected virtual void PutObjectProperty(string aPropertyName, object aPropertyValue)
    {
      GetPropertyPtr(aPropertyName).Value = aPropertyValue;
    }
    /// <summary>
    /// Convenience method
    /// </summary>
    public virtual int GetID()
    { 
      int ID = 0;
      GetPropertyValue("ID", ref ID);
      return ID;
    }
    public virtual bool HasID()
    {
      int ID = 0;
      GetPropertyValue("ID", ref ID);
      return (ID == PROPERTIES_BASE_NO_ID);
    }
    /// <summary>
    /// validate properties,
    /// checks that all required properties have been entered
    /// throws user error if invalid
    /// </summary>
    
    protected virtual void ValidateProperties()
    {
      foreach(IMTProperty prop in mPropertiesPtr)
      {
        MetraTech.Interop.MTProductCatalog.PropValType dataType = prop.DataType;
        string propName = prop.Name;
        //do not check 'ID'. since item might not have been created yet
        if(propName.ToUpper().CompareTo("ID") == 0)
          continue;
        object propValue = prop.Value;
        if(mProdCat.IsBusinessRuleEnabled(MetraTech.Interop.MTProductCatalog.MTPC_BUSINESS_RULE.MTPC_BUSINESS_RULE_All_NoEmptyRequiredProperty))
        {
          if(prop.Required && (propValue==null) )//how about VT_EMPTY?
            throw new ApplicationException(String.Format("Property <!s> is required, but missing on <!s>", propName, this.ToString()));
        }
        switch(dataType)
        {
          case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_STRING:
          {
            string strVal = (string)prop.Value;
            if(mProdCat.IsBusinessRuleEnabled(MetraTech.Interop.MTProductCatalog.MTPC_BUSINESS_RULE.MTPC_BUSINESS_RULE_All_NoEmptyRequiredProperty) && (strVal.Length == 0))
            {
              throw new ApplicationException(String.Format("Property <!s> is required, but is empty on <!s>", propName, this.ToString()));
            }
            if(mProdCat.IsBusinessRuleEnabled(MetraTech.Interop.MTProductCatalog.MTPC_BUSINESS_RULE.MTPC_BUSINESS_RULE_All_CheckStringLength ))
            {
              if (strVal.Length > prop.Length)
                throw new ApplicationException(String.Format("Property <!s> has exceeded the length limit", propName));
            }
            break;
          }
          case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_DATETIME:
          {
            if(prop.Required)
            {
              //System.DateTime prop = (DateTime)prop.Value;
              //what happens next?
              break;
            }
            break;
              
          }
          default: break;
        }
      }
    }
    protected virtual void OnGetProperties()
    {
      return;
    }

    protected MetraTech.Interop.MTProductCatalog.IMTProperties mPropertiesPtr;
    protected MetraTech.Interop.MTProductCatalog.IMTProductCatalog mProdCat;
	}
}
