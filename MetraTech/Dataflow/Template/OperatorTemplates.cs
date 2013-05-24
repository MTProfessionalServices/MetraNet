using System;
[assembly: System.Runtime.InteropServices.GuidAttribute("f9d92c8f-59ee-489d-b9e4-f59c0a644874")]

namespace MetraTech.Dataflow.Template
{
  using System.Linq;

	[System.Runtime.InteropServices.Guid("f459254e-7b0e-4518-8611-9ac052868fdf")]
  public interface IAccountResolutionBinding
  {
    string View { get; set; }
    string Name { get; set; }
    string Alias { get; set; }
  }

	[System.Runtime.InteropServices.ClassInterface(System.Runtime.InteropServices.ClassInterfaceType.None)]
	[System.Runtime.InteropServices.Guid("6e328317-a140-485b-8afa-32e2c6fae287")]
	public class AccountResolutionBinding : IAccountResolutionBinding
  {
    private string mView;
    public string View
    {
      get { return mView; }
      set { mView = value; }
    }
    private string mName;
    public string Name
    {
      get { return mName; }
      set { mName = value; }
    }
    private string mAlias;
    public string Alias
    {
      get { return mAlias; }
      set { mAlias = value; }
    }
  }

  class MSIXTemplateProperty
  {
    private string mName;
    public string Name
    {
      get { return mName; }
    }
    private string mColumnName;
    public string ColumnName
    {
      get { return mColumnName; }
    }
    private string mType;
    public string Type
    {
      get { return mType; }
    }
    private bool mIsRequired;
    public bool IsRequired
    {
      get { return mIsRequired; }
    }
    private int? mLength;
    public int? Length
    {
      get { return mLength; }
    }
    private String mDefaultValue;
    public String DefaultValue
    {
      get { return mDefaultValue; }
    }
    private String mAlias;
    public String Alias
    {
      get { return mAlias; }
    }
    private bool mPayerProperty;
    public bool PayerProperty
    {
      get { return mPayerProperty; }
    }

    public MSIXTemplateProperty(string name,
                                string columnName,
                                string type,
                                bool isRequired,
                                int length,
                                string defaultValue,
                                string alias,
                                bool payerProperty)
    {
      mName = name;
      mColumnName = columnName;
      mType = type;
      mIsRequired = isRequired;
      mLength = length;
      mDefaultValue = defaultValue;
      mAlias = alias;
      mPayerProperty = payerProperty;
    }
                                
    public MSIXTemplateProperty(string name,
                                string columnName,
                                string type,
                                bool isRequired,
                                int length,
                                string alias,
                                bool payerProperty)
    {
      mName = name;
      mColumnName = columnName;
      mType = type;
      mIsRequired = isRequired;
      mLength = length;
      mAlias = alias;
      mPayerProperty = payerProperty;
    }
  }

	[System.Runtime.InteropServices.Guid("7cedf7c1-a06c-4609-bb23-3bbfcc0820c1")]
  public interface IOperatorTemplateFactory
  {
    string GetAccountResolutionTemplate(string operatorName,
                                        string compositeInstanceName,
                                        string payeeField,
                                        string namespaceField,
                                        string namespaceLiteralField,
                                        string timestampField,
                                        MetraTech.Interop.GenericCollection.IMTCollection accountViewBindings);

    string GetRateScheduleResolutionTemplate(string operatorName,
                                             string compositeInstanceName,
                                             string subscriptionField,
                                             MetraTech.Interop.GenericCollection.IMTCollection paramTableDefinition);
    string GetRateApplicationTemplate(string operatorName, string compositeInstanceName, string paramTableDefinition,
		                      bool isScheduleUnderParent);
    string GetSubscriptionResolutionTemplate(string operatorName,
                                             string priceableItemNameField,
                                             string priceableItemNameLiteral,
                                             string accountIDField,
                                             string timestampField,
                                             string priceableItemTypeIDField,
                                             string priceableItemTemplateIDField,
                                             string subscriptionField);
    string GetWriteProductViewTemplate(string operatorName, string compositeInstanceName, string productViewName,
		                       bool isMultipointParent, bool isMultipointChild);
    string GetWriteErrorTemplate(string operatorName, string serviceDefinitionName, int numInputs);
    string GetLoadErrorTemplate(string operatorName, string serviceDefinitionName);
  }

	[System.Runtime.InteropServices.ClassInterface(System.Runtime.InteropServices.ClassInterfaceType.None)]
	[System.Runtime.InteropServices.Guid("bdf0ced7-1b28-4a32-9f36-f166cba64672")]
	public class OperatorTemplateFactory : IOperatorTemplateFactory
	{
    private string RenderDataType(MetraTech.Interop.MTProductCatalog.PropValType dt)
    {
      switch(dt)
      {
      case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_INTEGER:
        return "INTEGER";
      case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_STRING:
      case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_UNICODE_STRING:
        return "NVARCHAR";
      case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_DATETIME:
        return "DATETIME";
      case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_BOOLEAN:
        return "BOOLEAN";
      case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_ENUM:
        return "ENUM";
      case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_DECIMAL:
        return "DECIMAL";
      case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_ASCII_STRING:
        return "VARCHAR";
      case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_BIGINTEGER:
        return "BIGINT";
      default:
        throw new ApplicationException("Unsupported data type in parameter table");
      }
    }

    private string RenderOperatorType(MetraTech.Interop.MTProductCatalog.MTOperatorType ot)
    {
      switch(ot)
      {
      case MetraTech.Interop.MTProductCatalog.MTOperatorType.OPERATOR_TYPE_EQUAL:
        return "=";
      case MetraTech.Interop.MTProductCatalog.MTOperatorType.OPERATOR_TYPE_GREATER:
        return ">";
      case MetraTech.Interop.MTProductCatalog.MTOperatorType.OPERATOR_TYPE_GREATER_EQUAL:
        return ">=";
      case MetraTech.Interop.MTProductCatalog.MTOperatorType.OPERATOR_TYPE_LESS:
        return "<";
      case MetraTech.Interop.MTProductCatalog.MTOperatorType.OPERATOR_TYPE_LESS_EQUAL:
        return "<=";
      default:
        throw new ApplicationException("Unsupported operator type in parameter table");
      }
    }

    private string RenderDefaultValue(MetraTech.Interop.MTProductCatalog.IMTPropertyMetaData prop)
    {
      object dv = prop.DefaultValue;
      System.String str = dv as System.String;
      if (prop.DefaultValue == null || (str != null && str.Length == 0)) return System.String.Empty;

      switch(prop.DataType)
      {
      case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_INTEGER:
        return str;
      case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_STRING:
      case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_UNICODE_STRING:
        return str;
      case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_DATETIME:
      {
        return MetraTech.Xml.MTXmlDocument.ToDateTime(str).ToString();
      }
      case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_BOOLEAN:
        return MetraTech.Xml.MTXmlDocument.ToBool(str) ? "TRUE" : "FALSE";
      case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_ENUM:
      {
        MetraTech.Interop.MTEnumConfig.IEnumConfig enumConfig = new MetraTech.Interop.MTEnumConfig.EnumConfigClass();

        // enum ID must be calculated
        int enumId = enumConfig.GetID(prop.EnumSpace, 
                                      prop.EnumType, 
                                      (System.String) prop.DefaultValue);
        
        return enumId.ToString();
      }
      case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_DECIMAL:
        return str;
      case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_ASCII_STRING:
        return str;
      case MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_BIGINTEGER:
        return str;
      default:
        throw new ApplicationException("Unsupported data type in parameter table");
      }
    }

    private void AddAccountResolutionProperty(IAccountResolutionBinding avb,
                                              System.Collections.Generic.Dictionary<string, System.Collections.Generic.List<MSIXTemplateProperty> > tables,
                                              System.Collections.Generic.Dictionary<string,MetraTech.Pipeline.IServiceDefinition> pvColl,
                                              bool forPayer)
    {
        if (!pvColl.ContainsKey(avb.Name))
            throw new ApplicationException(string.Format("Unknown account property: {0}", avb.Name));

        if (null == pvColl[avb.Name])
            throw new ApplicationException(string.Format("Account property: {0} exists in multiple account views", avb.Name));

        MetraTech.Pipeline.IServiceDefinition pv = pvColl[avb.Name];

        if (!tables.ContainsKey(pv.TableName))
        {
          tables.Add(pv.TableName, new System.Collections.Generic.List<MSIXTemplateProperty>());
        }
        MetraTech.Interop.MTProductCatalog.IMTPropertyMetaData pvProp = pv.GetProperty(avb.Name);
        string dv = RenderDefaultValue(pvProp);
        if (dv.Length > 0)
          tables[pv.TableName].Add(new MSIXTemplateProperty(
                                     pvProp.Name,
                                     pvProp.DBColumnName,
                                     RenderDataType(pvProp.DataType),
                                     pvProp.Required,
                                     pvProp.Length,
                                     dv,
                                     avb.Alias,
                                     forPayer));
        else
          tables[pv.TableName].Add(new MSIXTemplateProperty(
                                     pvProp.Name,
                                     pvProp.DBColumnName,
                                     RenderDataType(pvProp.DataType),
                                     pvProp.Required,
                                     pvProp.Length,
                                     avb.Alias,
                                     forPayer));
    }                                         

    public string GetAccountResolutionTemplate(string operatorName,
                                               string compositeInstanceName,
                                               string payeeField,
                                               string namespaceField,
                                               string namespaceLiteralField,
                                               string timestampField,
                                               MetraTech.Interop.GenericCollection.IMTCollection accountViewBindings)
    {
      MetraTech.Interop.RCD.IMTRcd rcd = (MetraTech.Interop.RCD.IMTRcd) new MetraTech.Interop.RCD.MTRcd();
      Antlr.StringTemplate.IStringTemplateGroupLoader l = new Antlr.StringTemplate.CommonGroupLoader(
        new Antlr.StringTemplate.ConsoleErrorListener(),
        new string[] {rcd.ConfigDir + "MetraFlow\\ProductCatalog\\Templates"});
      Antlr.StringTemplate.StringTemplateGroup.RegisterGroupLoader(l);
      Antlr.StringTemplate.StringTemplateGroup group = Antlr.StringTemplate.StringTemplateGroup.LoadGroup("AccountResolution");
      Antlr.StringTemplate.StringTemplate t = group.GetInstanceOf("accountResolutionComposite");

      t.SetAttribute("operatorName", operatorName);
      t.SetAttribute("compositeInstanceName", compositeInstanceName);
      t.SetAttribute("payeeField", payeeField);
      if (namespaceField.Length > 0)
        t.SetAttribute("namespaceField", namespaceField);
      if (namespaceLiteralField.Length > 0)
        t.SetAttribute("namespaceLiteral", namespaceLiteralField);
      t.SetAttribute("timestampField", timestampField);

      System.Collections.Generic.Dictionary<string, System.Collections.Generic.List<MSIXTemplateProperty> > tables = 
        new System.Collections.Generic.Dictionary<string, System.Collections.Generic.List<MSIXTemplateProperty> >();

      MetraTech.Pipeline.IServiceDefinitionCollection pvColl = new MetraTech.Pipeline.ServiceDefinitionCollection("accountview");

      // We are not requiring the user to specify an account view, hence we are relying
      // on global uniqueness of account view property names.  This means that we have to
      // figure out the view from the property name alone.
      var propertyToView = new System.Collections.Generic.Dictionary<string,MetraTech.Pipeline.IServiceDefinition>();
      foreach(string sds in pvColl.Names)
      {
          MetraTech.Pipeline.IServiceDefinition sd = pvColl.GetServiceDefinition(sds);
          foreach(MetraTech.Interop.MTProductCatalog.IMTPropertyMetaData p in sd)
          {
              if (propertyToView.ContainsKey(p.Name))
              {
                  // This means there is non-uniqueness in the property.
                  // In this case leave a null for the non-prefixed key so
                  // that everyone knows there is ambiguity.
                  // TODO: Support prefixed references
                  propertyToView[p.Name] = null;
              }
              else
              {
                  propertyToView[p.Name] = sd;
              }
          }
      }
      
      foreach(IAccountResolutionBinding avb in accountViewBindings)
      {
          // Handle the "virtual" properties
          if(0 == String.Compare(avb.Name, "PayerCurrency"))
          {
              IAccountResolutionBinding avbTemp = new AccountResolutionBinding();
              avbTemp.Name = "Currency";
              avbTemp.Alias = avb.Alias;
              AddAccountResolutionProperty(avbTemp, 
                                           tables, 
                                           propertyToView, true);
          }
          else if(0 == String.Compare(avb.Name, "AccountID", true))
          {
              t.SetAttribute("accountIdField", avb.Alias);
          }
          else if(0 == String.Compare(avb.Name, "PayingAccountID", true))
          {
              t.SetAttribute("payingAccountIdField", avb.Alias);
          }
          else if(0 == String.Compare(avb.Name, "UsageCycleID", true))
          {
              t.SetAttribute("usageCycleIdField", avb.Alias);
          }
          else
          {
              AddAccountResolutionProperty(avb, tables, propertyToView, false);
          }
      }        

      // Seems to be a bug in ST that for a single Tables entry the 0-based index i0 isn't 
      // begin set properly.  Thus we have to set array index (0-based and 1-based) in the model
      // to enable gluing operators together.
      int idx=0;
      foreach(System.Collections.Generic.KeyValuePair<string, System.Collections.Generic.List<MSIXTemplateProperty> > entry 
              in tables)
      {
        t.SetAttribute("Tables.{Name, TableName, Properties, HasPayerProperties, HasOriginatorProperties, prevIdx, Idx}", 
                       entry.Key, 
                       "t_av_" + entry.Key, 
                       entry.Value,
                       entry.Value.Count(p => p.PayerProperty) > 0,
                       entry.Value.Count(p => !p.PayerProperty) > 0,
                       idx,
                       idx+1);
        idx += 1;
      }

      return t.ToString();
    }

    public string GetRateScheduleResolutionTemplate(string operatorName,
                                                    string compositeInstanceName,
                                                    string subscriptionField,
                                                    MetraTech.Interop.GenericCollection.IMTCollection paramTableDefinitions)
    {
      MetraTech.Interop.RCD.IMTRcd rcd = (MetraTech.Interop.RCD.IMTRcd) new MetraTech.Interop.RCD.MTRcd();
      Antlr.StringTemplate.IStringTemplateGroupLoader l = new Antlr.StringTemplate.CommonGroupLoader(
        new Antlr.StringTemplate.ConsoleErrorListener(),
        new string[] {rcd.ConfigDir + "MetraFlow\\ProductCatalog\\Templates"});
      Antlr.StringTemplate.StringTemplateGroup.RegisterGroupLoader(l);
      Antlr.StringTemplate.StringTemplateGroup group = Antlr.StringTemplate.StringTemplateGroup.LoadGroup("RateScheduleResolution");
      Antlr.StringTemplate.StringTemplate t = group.GetInstanceOf("rateScheduleResolutionComposite");

      MetraTech.Interop.MTProductCatalog.IMTProductCatalog pc = new MetraTech.Interop.MTProductCatalog.MTProductCatalogClass();
			// sets the SU session context on the client
			MetraTech.Interop.MTAuth.IMTLoginContext loginContext = new MetraTech.Interop.MTAuth.MTLoginContextClass();
			MetraTech.Interop.MTAuth.IMTSessionContext ctx = loginContext.Login("su", "system_user", "su123");
			pc.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)ctx);  

      t.SetAttribute("operatorName", operatorName);
      t.SetAttribute("compositeInstanceName", compositeInstanceName);
      t.SetAttribute("subscriptionField", subscriptionField);
      foreach (string paramTableDefinition in paramTableDefinitions)
      {
        MetraTech.Interop.MTProductCatalog.IMTParamTableDefinition pcPT = pc.GetParamTableDefinitionByName(paramTableDefinition);
        t.SetAttribute("paramtabledef.{Name,FQN}", pcPT.Name.Substring(pcPT.Name.LastIndexOf("/")+1), pcPT.Name);
      }
      return t.ToString();
    }

    public string GetRateApplicationTemplate(string operatorName, string compositeInstanceName, string paramTableDefinition,
		                             bool isScheduleUnderParent)
    {
      MetraTech.Interop.RCD.IMTRcd rcd = (MetraTech.Interop.RCD.IMTRcd) new MetraTech.Interop.RCD.MTRcd();
      Antlr.StringTemplate.IStringTemplateGroupLoader l = new Antlr.StringTemplate.CommonGroupLoader(
        new Antlr.StringTemplate.ConsoleErrorListener(),
        new string[] {rcd.ConfigDir + "MetraFlow\\ProductCatalog\\Templates"});
      Antlr.StringTemplate.StringTemplateGroup.RegisterGroupLoader(l);
      Antlr.StringTemplate.StringTemplateGroup group = Antlr.StringTemplate.StringTemplateGroup.LoadGroup("PCRateGroup");
      Antlr.StringTemplate.StringTemplate t = group.GetInstanceOf("pcRateComposite");

      MetraTech.Interop.MTProductCatalog.IMTProductCatalog pc = new MetraTech.Interop.MTProductCatalog.MTProductCatalogClass();
			// sets the SU session context on the client
			MetraTech.Interop.MTAuth.IMTLoginContext loginContext = new MetraTech.Interop.MTAuth.MTLoginContextClass();
			MetraTech.Interop.MTAuth.IMTSessionContext ctx = loginContext.Login("su", "system_user", "su123");
			pc.SetSessionContext((MetraTech.Interop.MTProductCatalog.IMTSessionContext)ctx);      
      MetraTech.Interop.MTProductCatalog.IMTParamTableDefinition pcPT = pc.GetParamTableDefinitionByName(paramTableDefinition);

      t.SetAttribute("operatorName", operatorName);
      t.SetAttribute("compositeInstanceName", compositeInstanceName);
      t.SetAttribute("paramtabledef.{Name,TableName}", pcPT.Name.Substring(pcPT.Name.LastIndexOf("/")+1), pcPT.DBTableName);

      if (isScheduleUnderParent)
      {
        t.SetAttribute("parentPrefix", "parent.");
      }
      else
      {
        t.SetAttribute("parentPrefix", "");
      }


      foreach(MetraTech.Interop.MTProductCatalog.IMTConditionMetaData c in pcPT.ConditionMetaData)
      {
        t.SetAttribute("AllConditions.{Name,ColumnName,Type,IsBoolean,Operator,IsRequired,OperatorPerRule}", 
                       c.PropertyName, 
                       c.ColumnName, 
                       RenderDataType(c.DataType), 
                       c.DataType==MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_BOOLEAN,
                       c.OperatorPerRule ? "" : RenderOperatorType(c.Operator),
                       c.Required,
                       c.OperatorPerRule);

        // Required equality predicates can be handled as part of the table lookup, otherwise not (default value semantics)
        if (!c.OperatorPerRule && c.Required && MetraTech.Interop.MTProductCatalog.MTOperatorType.OPERATOR_TYPE_EQUAL == c.Operator)
        {
          t.SetAttribute("EquiJoinConditions.{Name,ColumnName,Type,IsBoolean}", 
                         c.PropertyName, 
                         c.ColumnName, 
                         RenderDataType(c.DataType), 
                         c.DataType==MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_BOOLEAN);
        }
        else
        { 
          t.SetAttribute("NonEquiJoinConditions.{Name,ColumnName,Type,IsBoolean,Operator,IsRequired,OperatorPerRule}", 
                         c.PropertyName, 
                         c.ColumnName, 
                         RenderDataType(c.DataType), 
                         c.DataType==MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_BOOLEAN,
                         c.OperatorPerRule ? "" : RenderOperatorType(c.Operator),
                         c.Required,
                         c.OperatorPerRule);
       }
        if (MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_BOOLEAN == c.DataType ||
            MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_ENUM == c.DataType)
        {
          t.SetAttribute("BooleanActions.{Name,ColumnName,Type,IsBoolean}", 
                         c.PropertyName, 
                         c.ColumnName, 
                         RenderDataType(c.DataType), 
                         c.DataType==MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_BOOLEAN);
        }
        if (c.OperatorPerRule)
        {
          t.SetAttribute("BooleanActions.{Name,ColumnName,Type,IsBoolean}", 
                         c.PropertyName, 
                         c.ColumnName, 
                         "OP", 
                         false);
        }
      }
      foreach(MetraTech.Interop.MTProductCatalog.IMTActionMetaData c in pcPT.ActionMetaData)
      {
        t.SetAttribute("AllActions.{Name,ColumnName,Type,IsBoolean}", 
                       c.PropertyName, 
                       c.ColumnName, 
                       RenderDataType(c.DataType), 
                       c.DataType==MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_BOOLEAN);
        if (MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_BOOLEAN == c.DataType ||
            MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_ENUM == c.DataType)
        {
          t.SetAttribute("BooleanActions.{Name,ColumnName,Type,IsBoolean}", 
                         c.PropertyName, 
                         c.ColumnName, 
                         RenderDataType(c.DataType), 
                         c.DataType==MetraTech.Interop.MTProductCatalog.PropValType.PROP_TYPE_BOOLEAN);
        }
      }

      return t.ToString();
    }
    public string GetSubscriptionResolutionTemplate(string operatorName,
                                                    string priceableItemNameField,
                                                    string priceableItemNameLiteral,
                                                    string accountIDField,
                                                    string timestampField,
                                                    string priceableItemTypeIDField,
                                                    string priceableItemTemplateIDField,
                                                    string subscriptionField
      )
    {
      MetraTech.Interop.RCD.IMTRcd rcd = (MetraTech.Interop.RCD.IMTRcd) new MetraTech.Interop.RCD.MTRcd();
      Antlr.StringTemplate.IStringTemplateGroupLoader l = new Antlr.StringTemplate.CommonGroupLoader(
        new Antlr.StringTemplate.ConsoleErrorListener(),
        new string[] {rcd.ConfigDir + "MetraFlow\\ProductCatalog\\Templates"});
      Antlr.StringTemplate.StringTemplateGroup.RegisterGroupLoader(l);
      Antlr.StringTemplate.StringTemplateGroup group = Antlr.StringTemplate.StringTemplateGroup.LoadGroup("SubscriptionResolution");
      Antlr.StringTemplate.StringTemplate t = group.GetInstanceOf("subscriptionResolutionComposite");
      t.SetAttribute("operatorName", operatorName);
      if (priceableItemNameField.Length > 0)
        t.SetAttribute("priceableItemNameField", priceableItemNameField);
      if (priceableItemNameLiteral.Length > 0)
        t.SetAttribute("priceableItemNameLiteral", priceableItemNameLiteral);
      t.SetAttribute("accountIDField", accountIDField);
      t.SetAttribute("timestampField", timestampField);
      t.SetAttribute("priceableItemTypeIDField", priceableItemTypeIDField);
      t.SetAttribute("priceableItemTemplateIDField", priceableItemTemplateIDField);
      t.SetAttribute("subscriptionField", subscriptionField);
      return t.ToString();
    }

    public string GetWriteProductViewTemplate(string operatorName, 
                                              string compositeInstanceName,
                                              string productViewName,
					      bool isMultipointParent,
					      bool isMultipointChild)
    {
      MetraTech.Interop.RCD.IMTRcd rcd = (MetraTech.Interop.RCD.IMTRcd) new MetraTech.Interop.RCD.MTRcd();
      Antlr.StringTemplate.IStringTemplateGroupLoader l = new Antlr.StringTemplate.CommonGroupLoader(
        new Antlr.StringTemplate.ConsoleErrorListener(),
        new string[] {rcd.ConfigDir + "MetraFlow\\ProductCatalog\\Templates"});
      Antlr.StringTemplate.StringTemplateGroup.RegisterGroupLoader(l);
      Antlr.StringTemplate.StringTemplateGroup group = Antlr.StringTemplate.StringTemplateGroup.LoadGroup("WriteProductView");
      Antlr.StringTemplate.StringTemplate t = group.GetInstanceOf("writeProductViewComposite");
      t.SetAttribute("operatorName", operatorName);
      t.SetAttribute("compositeInstanceName", compositeInstanceName);
      t.SetAttribute("productViewName", productViewName);

      // Determine the product view table name
      int slashPos = productViewName.IndexOf("/");
      string productViewTable = "t_pv_" + productViewName.Remove(0, slashPos+1);

      t.SetAttribute("productViewTable", productViewTable);

      MetraTech.Pipeline.IProductViewDefinitionCollection pvColl = new MetraTech.Pipeline.ProductViewDefinitionCollection();
      MetraTech.Pipeline.IProductViewDefinition pv = pvColl.GetProductViewDefinition(productViewName);
      foreach(MetraTech.Interop.MTProductCatalog.IMTPropertyMetaData pvProp in pv)
      {
        string dv = RenderDefaultValue(pvProp);
        if (dv.Length > 0)
        t.SetAttribute("Properties.{Name,ColumnName,Type,IsRequired,Length,DefaultValue}", 
                       pvProp.Name,
                       pvProp.DBColumnName,
                       RenderDataType(pvProp.DataType),
                       pvProp.Required,
                       pvProp.Length,
                       dv);
        else
        t.SetAttribute("Properties.{Name,ColumnName,Type,IsRequired,Length}", 
                       pvProp.Name,
                       pvProp.DBColumnName,
                       RenderDataType(pvProp.DataType),
                       pvProp.Required,
                       pvProp.Length);
      }

      t.SetAttribute("isMultipointParent", isMultipointParent);
      t.SetAttribute("isMultipointChild",  isMultipointChild);

      return t.ToString();
    }
    public string GetWriteErrorTemplate(string operatorName, string serviceDefinitionName, int numInputs)
    {
      MetraTech.Interop.RCD.IMTRcd rcd = (MetraTech.Interop.RCD.IMTRcd) new MetraTech.Interop.RCD.MTRcd();
      Antlr.StringTemplate.IStringTemplateGroupLoader l = new Antlr.StringTemplate.CommonGroupLoader(
        new Antlr.StringTemplate.ConsoleErrorListener(),
        new string[] {rcd.ConfigDir + "MetraFlow\\ProductCatalog\\Templates"});
      Antlr.StringTemplate.StringTemplateGroup.RegisterGroupLoader(l);
      Antlr.StringTemplate.StringTemplateGroup group = Antlr.StringTemplate.StringTemplateGroup.LoadGroup("WriteError");
      Antlr.StringTemplate.StringTemplate t = group.GetInstanceOf("writeErrorComposite");
      t.SetAttribute("operatorName", operatorName);
      t.SetAttribute("serviceDefinitionName", serviceDefinitionName);
      for(int i=0; i<numInputs; i++)
      {
        t.SetAttribute("inputPort", i);
      }

      MetraTech.Pipeline.IServiceDefinitionCollection pvColl = new MetraTech.Pipeline.ServiceDefinitionCollection();
      MetraTech.Pipeline.IServiceDefinition pv = pvColl.GetServiceDefinition(serviceDefinitionName);
      foreach(MetraTech.Interop.MTProductCatalog.IMTPropertyMetaData pvProp in pv)
      {
        string dv = RenderDefaultValue(pvProp);
        if (dv.Length > 0)
        t.SetAttribute("Properties.{Name,ColumnName,Type,IsRequired,Length,DefaultValue}", 
                       pvProp.Name,
                       pvProp.DBColumnName,
                       RenderDataType(pvProp.DataType),
                       pvProp.Required,
                       pvProp.Length,
                       dv);
        else
        t.SetAttribute("Properties.{Name,ColumnName,Type,IsRequired,Length}", 
                       pvProp.Name,
                       pvProp.DBColumnName,
                       RenderDataType(pvProp.DataType),
                       pvProp.Required,
                       pvProp.Length);
      }

      return t.ToString();
    }
    public string GetLoadErrorTemplate(string operatorName, string serviceDefinitionName)
    {
      MetraTech.Interop.RCD.IMTRcd rcd = (MetraTech.Interop.RCD.IMTRcd) new MetraTech.Interop.RCD.MTRcd();
      Antlr.StringTemplate.IStringTemplateGroupLoader l = new Antlr.StringTemplate.CommonGroupLoader(
        new Antlr.StringTemplate.ConsoleErrorListener(),
        new string[] {rcd.ConfigDir + "MetraFlow\\ProductCatalog\\Templates"});
      Antlr.StringTemplate.StringTemplateGroup.RegisterGroupLoader(l);
      Antlr.StringTemplate.StringTemplateGroup group = Antlr.StringTemplate.StringTemplateGroup.LoadGroup("LoadError");
      Antlr.StringTemplate.StringTemplate t = group.GetInstanceOf("loadErrorComposite");
      t.SetAttribute("operatorName", operatorName);
      t.SetAttribute("serviceDefinitionName", serviceDefinitionName);

      MetraTech.Pipeline.IServiceDefinitionCollection pvColl = new MetraTech.Pipeline.ServiceDefinitionCollection();
      MetraTech.Pipeline.IServiceDefinition pv = pvColl.GetServiceDefinition(serviceDefinitionName);
      t.SetAttribute("serviceDefinitionTable", "t_svc_" + pv.TableName);

      return t.ToString();
    }
  }
}
