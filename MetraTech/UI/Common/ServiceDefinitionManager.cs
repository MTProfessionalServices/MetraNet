using System;
using System.Diagnostics;
using System.Collections.Generic;
using System.Text;
using System.Data;

using MetraTech.Pipeline;
using MetraTech.Interop.MTProductCatalog;
using MetraTech.Xml;
using MetraTech.Interop.MTEnumConfig;
using MetraTech.Interop.COMMeter;
using MetraTech.UI.Tools;

namespace MetraTech.UI.Common
{
  /// <summary>
  ///   Provide facilities related to service definitions.
  /// </summary>
  public class ServiceDefinitionManager
  {
    #region Public Methods
    /// <summary>
    ///    Convert from PropertyType to MetraTech.Interop.COMMeter.DataType
    /// </summary>
    /// <param name="propertyType"></param>
    /// <returns></returns>
    public static DataType GetComMeterDataType(PropertyType propertyType)
    {
      DataType comMeterDataType = DataType.MTC_DT_UNKNOWN;

      switch (propertyType)
      {
        case PropertyType.Boolean:
          {
            comMeterDataType = DataType.MTC_DT_BOOL;
            break;
          }
        case PropertyType.Decimal:
          {
            comMeterDataType = DataType.MTC_DT_DECIMAL;
            break;
          }
        case PropertyType.Double:
          {
            comMeterDataType = DataType.MTC_DT_DOUBLE;
            break;
          }
        case PropertyType.Enum:
          {
            comMeterDataType = DataType.MTC_DT_ENUM;
            break;
          }
        case PropertyType.Float:
          {
            comMeterDataType = DataType.MTC_DT_FLOAT;
            break;
          }
        case PropertyType.Int32:
          {
            comMeterDataType = DataType.MTC_DT_INT;
            break;
          }
        case PropertyType.Int64:
          {
            comMeterDataType = DataType.MTC_DT_BIGINT;
            break;
          }
        case PropertyType.String:
          {
            comMeterDataType = DataType.MTC_DT_WCHAR;
            break;
          }
        case PropertyType.DateTime:
          {
            comMeterDataType = DataType.MTC_DT_TIMESTAMP;
            break;
          }
        case PropertyType.Unknown:
          {
            comMeterDataType = DataType.MTC_DT_UNKNOWN;
            break;
          }
        default:
          {
            Debug.Assert(false, "Incorrect Property Type");
            break;
          }
      }

      return comMeterDataType;
    }

    /// <summary>
    ///    Convert from MetraTech.Interop.MTProductCatalog.PropValType to PropertyType.
    ///    
    ///    Does not handle PropValType.PROP_TYPE_DEFAULT
    ///    Does not handle PropValType.PROP_TYPE_ENUM
    ///    Does not handle PropValType.PROP_TYPE_OPAQUE
    ///    Does not handle PropValType.PROP_TYPE_SET
    /// 
    /// </summary>
    /// <param name="propValType"></param>
    /// <returns></returns>
    public static PropertyType GetPropertyType(MetraTech.Interop.MTProductCatalog.PropValType propValType)
    {
      PropertyType propertyType = PropertyType.Unknown;

      switch (propValType)
      {
        case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_ASCII_STRING:
        case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_STRING:
        case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_UNICODE_STRING:
          {
            propertyType = PropertyType.String;
            break;
          }
        case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_BIGINTEGER:
          {
            propertyType = PropertyType.Int64;
            break;
          }
        case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_INTEGER:
          {
            propertyType = PropertyType.Int32;
            break;
          }
        case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_BOOLEAN:
          {
            propertyType = PropertyType.Boolean;
            break;
          }
        case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_DATETIME:
        case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_TIME:
          {
            propertyType = PropertyType.DateTime;
            break;
          }
        case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_DECIMAL:
          {
            propertyType = PropertyType.Decimal;
            break;
          }
        case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_DOUBLE:
          {
            propertyType = PropertyType.Double;
            break;
          }
        default:
          {
            Debug.Assert(false, "Incorrect Property Type");
            break;
          }
      }
      return propertyType;
    }

    /// <summary>
    ///   Convert the given propertyTypeName to the PropertyType enum.
    ///   Return PropertyType.Unknown and log an error if the conversion cannot be performed.
    /// </summary>
    /// <param name="propertyTypeName"></param>
    /// <returns></returns>
    public static PropertyType GetPropertyType(string propertyTypeName)
    {
      PropertyType propertyType = PropertyType.Unknown;
      try
      {
        propertyType = (PropertyType)Enum.Parse(typeof(PropertyType), propertyTypeName);
      }
      catch (Exception e)
      {
        Utils.CommonLogger.LogException("Unknown property type format " + propertyTypeName, e);
      }

      return propertyType;
    }

    /// <summary>
    ///     Get the service definition properties for the given service definition name.
    /// </summary>
    /// <param name="serviceDefinitionName">e.g. "metratech.com\accountcreation"</param>
    /// <returns></returns>
    public static PropertyDS GetServiceProperties(string serviceDefinitionName)
    {
      PropertyDS PropertyDS = new PropertyDS();

      // Retrieve the ServiceDefinition
      ServiceDefinitionCollection serviceDefinitionCollection = new ServiceDefinitionCollection();
      IServiceDefinition serviceDefinition = 
        serviceDefinitionCollection.GetServiceDefinition(serviceDefinitionName);

      Debug.Assert(serviceDefinition != null);

      foreach (IMTPropertyMetaData propertyMetaData in serviceDefinition.Properties)
      {
        CreatePropertyRow(PropertyDS, propertyMetaData, serviceDefinitionName);
      }

      // TODO Each Property needs to be localized.
      return PropertyDS;
    }

    /// <summary>
    ///    Meter the data based on data in the given meterData.
    ///    // TODO Handle output properties in a generic way
    /// </summary>
    /// <param name="meterData"></param>
    public static void Meter(MeterData meterData)
    {
      IMeter meterSdk = null;
      IBatch batch = null;
      ISessionSet sessionSet = null;
      ISession session = null;

      try
      {
        // Get the meter sdk for the given listener
        meterSdk = GetMeterSdk(meterData.ListenerMachineName);
        Debug.Assert(meterSdk != null);

        /*
        // Create and save the batch
        batch = meterSdk.CreateBatch();
        Debug.Assert(batch != null);

        batch.NameSpace = "MT        ";
        batch.Name = "1";
        batch.ExpectedCount = 1;
        batch.SourceCreationDate = DateTime.Now;
        batch.SequenceNumber = DateTime.Now.ToFileTime().ToString();

        //batch.NameSpace = "metratech.com";
        //batch.Name = "_Batch_1"; // +"_Batch_"; +DateTime.Now.ToLongTimeString();
        //batch.ExpectedCount = 1;
        //batch.SourceCreationDate = DateTime.Now;
        //batch.SequenceNumber = DateTime.Now.ToFileTime().ToString();

        batch.Save();
        */

        // Create and initialize the session set
        sessionSet = meterSdk.CreateSessionSet();
        Debug.Assert(sessionSet != null);

        // Set sessionSet properties
        sessionSet.SetProperties(null,
                                 null,
                                 meterData.SessionContext.ToXML(),
                                 null,
                                 null,
                                 null);

        // Create the session
        session = sessionSet.CreateSession(meterData.ServiceDefinitionName);
        Debug.Assert(session != null);

        // Synchronous
        if (meterData.Synchronous)
        {
          session.RequestResponse = true;
        }
        else
        {
          session.RequestResponse = false;
        }

        // Filter the propertyDS for the given serviceDefinition
        DataView view = new DataView();
        view.Table = meterData.PropertyDS.Property;
        view.RowFilter = "ServiceDefinition = '" + meterData.ServiceDefinitionName + "'";

        PropertyDS.PropertyDataTable propertyDataTable = view.Table as PropertyDS.PropertyDataTable;

        // Initialize session properties
        foreach (PropertyDS.PropertyRow propertyRow in propertyDataTable.Rows)
        {
          object value = null;

          // If the value exists, use it. Otherwise use the default value.
          if (!propertyRow.IsValueNull())
          {
            value = propertyRow.Value;
          }
          else if (!propertyRow.IsDefaultValueNull())
          {
            value = propertyRow.DefaultValue;
          }
         
          // If it's a required property, we must have a value
          if (propertyRow.Required && value == null)
          {
            throw new ApplicationException("missing required property" + propertyRow.Name);
            //throw new CommonException
            //  (CommonRes.ServiceDefinitionManager_MissingRequiredPropertyFormat(propertyRow.Name));
          }
  
          // Set the property only if we have a value
          if (value != null)
          {
            // Fixup timestamps and booleans
            if (propertyRow.Type == PropertyType.DateTime.ToString())
            {
              DateTime dateTime = DateTime.Parse(value.ToString());
              value = dateTime.ToString(dateFormat);
            }
            else if (propertyRow.Type == PropertyType.Boolean.ToString())
            {
              value = Convert.ToBoolean(value);
            }

            if (value.ToString().Length != 0)
            {
              session.InitProperty(propertyRow.Name, value);
            }
          }
        }

        // Set the transaction id
        if (!String.IsNullOrEmpty(meterData.TransactionId))
        {
          sessionSet.TransactionID = meterData.TransactionId.ToString();
        }

        // Close session set
        sessionSet.Close();

        // Set the output properties
        // If the output property row does not exist in meterData.PropertyDS, then
        // no action is performed.
        if (meterData.HasOutputProperties)
        {
          foreach (string outputPropertyName in meterData.OutputPropertyNames)
          {
            PropertyDS.PropertyRow outputPropertyRow = meterData.PropertyDS.GetPropertyRow(outputPropertyName);

            if (outputPropertyRow != null)
            {
              PropertyType propertyType = GetPropertyType(outputPropertyRow.Type);
              Debug.Assert(propertyType != PropertyType.Unknown);

              DataType dataType = GetComMeterDataType(propertyType);
              Debug.Assert(dataType != DataType.MTC_DT_UNKNOWN);

              outputPropertyRow.Value =
                session.ResultSession.GetProperty(outputPropertyName, dataType).ToString();
            }
          }
        }
      }
      finally
      {
        if (sessionSet != null)
        {
          System.Runtime.InteropServices.Marshal.ReleaseComObject(sessionSet);
        }
        if (batch != null)
        {
          System.Runtime.InteropServices.Marshal.ReleaseComObject(batch);
        }
        if (meterSdk != null)
        {
          System.Runtime.InteropServices.Marshal.ReleaseComObject(meterSdk);
        }
      }
    }

    #endregion

    #region Private Methods

    private static IMeter GetMeterSdk(string meteringServer)
    {
      IMeter sdk = new Meter();
      sdk.Startup();
      sdk.AddServer(0, meteringServer, PortNumber.DEFAULT_HTTP_PORT, 0, "", "");
      return sdk;
    }

    private static void CreatePropertyRow(PropertyDS propertyDS, 
                                          IMTPropertyMetaData propertyMetaData,
                                          string serviceDefinitionName)
    {
      PropertyDS.PropertyRow propertyRow = null;

      // Handle enums
      if (propertyMetaData.DataType == MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_ENUM)
      {
        // Create the enum Property Row
        propertyRow = propertyDS.Property.NewPropertyRow();

        propertyRow.Name = propertyMetaData.Name;
        propertyRow.Type = PropertyType.Enum.ToString();
        propertyRow.Required = propertyMetaData.Required;
        propertyRow.Description = propertyMetaData.DisplayName;
        propertyRow.EnumSpace = propertyMetaData.EnumSpace;
        propertyRow.EnumType = propertyMetaData.EnumType;

        propertyDS.Property.AddPropertyRow(propertyRow);

        // Create the enum rows
        PropertyDS.EnumRow enumRow = null;
        foreach (MetraTech.Interop.MTEnumConfig.IMTEnumerator mtEnumerator in propertyMetaData.Enumerators)
        {
          Debug.Assert(String.Equals(mtEnumerator.EnumType, propertyMetaData.EnumType,
                                     StringComparison.InvariantCultureIgnoreCase));
          Debug.Assert(String.Equals(mtEnumerator.Enumspace, propertyMetaData.EnumSpace,
                                     StringComparison.InvariantCultureIgnoreCase));
         

          // Create the Enum row
          enumRow = propertyDS.Enum.NewEnumRow();
          enumRow.EnumType = mtEnumerator.EnumType;
          enumRow.Name = mtEnumerator.name;
          enumRow.Id = mtEnumerator.ElementAt(0);
          enumRow.LocalizedName = mtEnumerator.DisplayName;
          propertyDS.Enum.AddEnumRow(enumRow);
        }

        return;
      }

      // The rest
      propertyRow = propertyDS.Property.NewPropertyRow();

      propertyRow.Name = propertyMetaData.Name;
      propertyRow.Type = GetPropertyType(propertyMetaData.DataType).ToString();
      propertyRow.Required = propertyMetaData.Required;
      propertyRow.Description = propertyMetaData.DisplayName;
      propertyRow.EnumSpace = propertyMetaData.EnumSpace;
      propertyRow.EnumType = propertyMetaData.EnumType;
      propertyRow.ServiceDefinition = serviceDefinitionName;

      propertyDS.Property.AddPropertyRow(propertyRow);
    }

    

    #endregion

    #region Data
    public const string dateFormat = "yyyy-MM-ddTHH:mm:ssZ";
    #endregion
  }
}
