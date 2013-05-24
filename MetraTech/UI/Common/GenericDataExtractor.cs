using System;
using System.Data;
using System.Configuration;
using System.Collections;

using System.Net;
using System.Text;
using System.IO;
using MetraTech.ActivityServices.Common;
using System.Reflection;
using System.Collections.Generic;
using System.Web.Script.Serialization;
using System.ComponentModel;

using MetraTech.UI.Tools;
using System.Web;
using System.Text.RegularExpressions;
using MetraTech.Core.Services.ClientProxies;

namespace MetraTech.UI.Common
{
  /// <summary>
  /// Representation of a Column that is getting returned
  /// </summary>
  public class MTColumnElement
  {
    private string columnID;

    public string ColumnID
    {
      get { return columnID; }
      set { columnID = value; }
    }

    private string dataIndex;

    public string DataIndex
    {
      get { return dataIndex; }
      set { dataIndex = value; }
    }

    private string headerText;

    public string HeaderText
    {
      get { return headerText; }
      set { headerText = value; }
    }

  }

  public class GenericDataExtractor
  {
    #region properties and private and protected vars

    private UserData mUserData = null;
    protected Type dynamicObjectType;

    private string outPropertyName;
    public string OutPropertyName
    {
      get { return outPropertyName; }
      set { outPropertyName = value; }
    }

    private List<MTColumnElement> columns;

    public List<MTColumnElement> Columns
    {
      get
      {
        if (columns == null)
        {
          columns = new List<MTColumnElement>();
        }

        return columns;
      }
      set { columns = value; }
    }


    private List<MTBaseFilterElement> filters;

    //Filters will only be relevant for MTList objects only
    public List<MTBaseFilterElement> Filters
    {
      get
      {
        if (filters == null)
        {
          filters = new List<MTBaseFilterElement>();
        }

        return filters;
      }
    }

    private int pageSize;
    public int PageSize
    {
      get { return pageSize; }
      set { pageSize = value; }
    }

    private int currentPage;
    public int CurrentPage
    {
      get { return currentPage; }
      set { currentPage = value; }
    }

    private string sortProperty;
    public string SortProperty
    {
      get { return sortProperty; }
      set { sortProperty = value; }
    }

    private SortType sortDirection;
    public SortType SortDirection
    {
      get { return sortDirection; }
      set { sortDirection = value; }
    }

    public string JSon
    {
      get { return GetJSonString(); }
    }

    protected object dynamicObject;
    public object DynamicObject
    {
      get { return dynamicObject; }
    }

    public Type DynamicObjectType
    {
      get { return dynamicObjectType; }
    }

    private string processorInstanceId;
    public string ProcessorInstanceId
    {
      get { return processorInstanceId; }
      set { processorInstanceId = value; }
    }

    private string state;
    public string State
    {
      get { return state; }
      set { state = value; }
    }

    private string accountId;
    public string AccountId
    {
      get { return accountId; }
      set { accountId = value; }
    }

    private string operation;
    public string Operation
    {
      get { return operation; }
      set { operation = value; }
    }

    private Dictionary<string, string> arguments;
    public Dictionary<string, string> Arguments
    {
      get
      {
        if (arguments == null)
        {
          arguments = new Dictionary<string, string>();
        }
        return arguments;

      }
      set { arguments = value; }
    }

    private string serviceMethodName;

    public string ServiceMethodName
    {
      get { return serviceMethodName; }
      set { serviceMethodName = value; }
    }

    private List<MTServiceParameter> serviceMethodParameters;

    public List<MTServiceParameter> ServiceMethodParameters
    {
      get
      {
        if (serviceMethodParameters == null)
        {
          serviceMethodParameters = new List<MTServiceParameter>();
        }
        return serviceMethodParameters;
      }
      set { serviceMethodParameters = value; }
    }



    #endregion

    #region Public Constructors

    public GenericDataExtractor(UserData userData) { mUserData = userData; }

    public GenericDataExtractor(UserData userData, string ProcessorInstanceId, string AccountId,
                                string Operation)
    {
      mUserData = userData;
      processorInstanceId = ProcessorInstanceId;
      accountId = AccountId;
      operation = Operation;
    }

    public GenericDataExtractor(UserData userData, string ProcessorInstanceId, string AccountId,
                                string Operation, string Arguments)
    {
      mUserData = userData;
      processorInstanceId = ProcessorInstanceId;
      accountId = AccountId;
      operation = Operation;
      ParseAdditionalArguments(Arguments);
    }

    #endregion

    #region Public Methods

    public object GetOutProperty(object parentObject, string propName)
    {
      object objResult = null;
      string propertyName = propName;
      PropertyInfo pi = GetProperty(parentObject.GetType(), propertyName, true);

      //exit if invalid property
      if (pi == null)
      {
        return null;
      }

      try
      {
        objResult = pi.GetValue(parentObject, null);
      }
      catch (Exception e)
      {
        Utils.CommonLogger.LogException("Unable to retrieve property " + propName, e);
        return null;
      }

      return objResult;
    }

    /// <summary>
    /// Converts the value of a property of the dynamicObject to CSV
    /// </summary>
    /// <param name="propName">property of the dynamic object to convert to csv</param>
    /// <param name="bIncludeHeaders"></param>
    /// <returns>CSV string</returns>
    public string ConvertObjectToCSV(string propName, bool bIncludeHeaders)
    {
      object objPropValue = GetOutProperty(dynamicObject, propName);
      if (objPropValue == null)
      {
        return String.Empty;
      }

      bool bIsArrayList = (objPropValue.GetType().Name == "ArrayList");

      //exit if not of type MTList or Array List
      if ((objPropValue.GetType().Name != "MTList`1") && (objPropValue.GetType().BaseType.Name != "MTList`1") 
        && (!bIsArrayList))
      {
        return String.Empty;
      }

      //get the items property
      object listItems;


      if (bIsArrayList)
      {
        listItems = objPropValue;
      }
      else
      {
        listItems = GetOutProperty(objPropValue, "Items");
      }

      if ((listItems == null) || (!listItems.GetType().IsGenericType))
      {
        if (!bIsArrayList)
        {
          return String.Empty;
        }
      }

      StringBuilder sb = new StringBuilder();

      //add headers if necessary
      if (bIncludeHeaders)
      {
        sb.Append(GenerateCSVHeader());
        if (sb.ToString().Length > 0)
        {
          sb.Append("\n");
        }
      }

      //iterate through the list of items
      foreach (object curItem in (IList)listItems)
      {
        string curRowCSV = ConvertRowToCSV(curItem);
        sb.Append(curRowCSV);
        sb.Append("\n");
      }

      return sb.ToString();
    }

    /// <summary>
    /// Generate a CSV representation of the column headers based on the columns collection
    /// </summary>
    /// <returns>CSV representation of column headers</returns>
    protected string GenerateCSVHeader()
    {
      StringBuilder sb = new StringBuilder();

      //iterate through the columns
      for (int i = 0; i < this.Columns.Count; i++)
      {
        if (i > 0)
        {
          sb.Append(",");
        }

        //append the column's header text and replace all quotes will double quotes
        sb.Append("\"");
        sb.Append(Columns[i].HeaderText.Replace("\"", "\"\""));
        sb.Append("\"");
      }

      return sb.ToString();
    }

    /// <summary>
    /// Export a single row of data to csv
    /// </summary>
    /// <param name="curRow"></param>
    /// <returns></returns>
    protected string ConvertRowToCSV(object curRow)
    {
      if (curRow == null)
      {
        return String.Empty;
      }

      StringBuilder sb = new StringBuilder();

      int columnIndex = 0;

      //iterate through the fields that we want to extract
      foreach (MTColumnElement ce in this.Columns)
      {
        object cellValue = GetObjectPropertyValue(ce.DataIndex, curRow);

        if (columnIndex > 0)
        {
          sb.Append(",");
        }

        sb.Append("\"");
        if (cellValue != null)
        {
          sb.Append(cellValue.ToString().Replace("\"", "\"\""));
        }
        sb.Append("\"");

        columnIndex++;
      }

      return sb.ToString();
    }

    /// <summary>
    /// Find an element corresponding to propertyPath in the targetObject
    /// </summary>
    /// <param name="propertyPath">case insensitive object path</param>
    /// <param name="targetObject">object to traverse</param>
    /// <returns></returns>
    protected object GetObjectPropertyValue(string propertyPath, object targetObject)
    {
      //exit on bad input
      if ((String.IsNullOrEmpty(propertyPath)) || (targetObject == null))
      {
        return String.Empty;
      }

      //terminate if a single level path is passed in
      int indexOfDot = propertyPath.IndexOf('.');
      if (indexOfDot < 0)
      {
        return ScanObjectForProperty(propertyPath, targetObject);
      }

      //this is multi-level path, so strip out the top level node
      string topLevelPath = propertyPath.Substring(0, indexOfDot);

      //find the object that corresponds to the top level path
      object subObject = ScanObjectForProperty(topLevelPath, targetObject);
      if ((subObject == null) || (!(subObject is object)))
      {
        return String.Empty;
      }

      //grab the remainder of the path by stripping out the top level
      string subPath = propertyPath.Substring(indexOfDot + 1, propertyPath.Length - indexOfDot - 1);
      if (String.IsNullOrEmpty(subPath))
      {
        return string.Empty;
      }

      //recursively call itself for subpath and subObject
      return GetObjectPropertyValue(subPath, subObject);
    }

    /// <summary>
    /// Iterate through the target object's property list and return the value of the property
    /// with the name in propertyName
    /// </summary>
    /// <param name="propertyName">property name whose value is to be retrieved</param>
    /// <param name="target">Target object to evaluate</param>
    /// <returns>Value of the property, or null if property is not found</returns>
    protected object ScanObjectForProperty(string propertyName, object target)
    {
      //exit on bad input
      if ((String.IsNullOrEmpty(propertyName)) || (target == null))
      {
        return null;
      }

      //get the list of properties
      PropertyInfo[] properties = target.GetType().GetProperties();

      //iterate through the object's properties
      foreach (PropertyInfo curProperty in properties)
      {
        //find a case-insensitive match to the propertyName that was sent in
        if (curProperty.Name.ToLower() == propertyName.ToLower())
        {
          //retrieve and return the value
          return curProperty.GetValue(target, null);
        }
      }

      return null;
    }

    public string GetPropertyAsJSon(string propName)
    {
      object objPropValue = GetOutProperty(dynamicObject, propName);
      string strJSon = string.Empty;

      //exit if property is null
      if (objPropValue == null)
      {
        return string.Empty;
      }

      JavaScriptSerializer jss = new JavaScriptSerializer();
      strJSon = jss.Serialize(objPropValue);

      //Replace the \/Date(xxx)\/   with Date(xxx)
      MatchEvaluator me = new MatchEvaluator(MTListServicePage.MatchDate);
      strJSon = Regex.Replace(strJSon, "\\\\/\\Date[(](\\d+)[)]\\\\/", me, RegexOptions.None);

      if (objPropValue is IList)
      {
        int itemCount = ((IList)objPropValue).Count;
        strJSon = String.Format("\"TotalRows\":\"{0}\",\"Items\":{1}", itemCount.ToString(), strJSon);
        strJSon = "{" + strJSon + "}";
      }
      return strJSon;
    }

    public void AddArgument(string key, string value)
    {
      this.arguments.Add(key, value);
    }

    protected string GetDynamicObjectTypeName()
    {
      if (!String.IsNullOrEmpty(serviceMethodName))
      {
        return "MetraTech.Core.Services.ClientProxies." + Operation;
      }

      return "MetraTech.PageNav.ClientProxies." + Operation;
    }

    public void GetData()
    {
      Assembly assembly = GetAssembly();

      //Generate the type of the object to create
      dynamicObjectType = assembly.GetType(GetDynamicObjectTypeName());
      if (dynamicObjectType == null)
      {
        return;
      }

      //Generate the object
      dynamicObject = Activator.CreateInstance(dynamicObjectType);
      if (dynamicObject == null)
      {
        return;
      }

      //set the properties
      PopulateProperties();

      // If we have an InOut_ property that has a base of generic MTList, 
      //       Then new it up with the real generic type.
      //       And set it as a ref parameter.
      object mtList = GetMTListPlaceholderObject();
      if (mtList != null)
      {
        PopulateProperty(dynamicObject, outPropertyName, mtList, true, true);
      }

      //execute the event on the dynamic object
      try
      {
          if (!String.IsNullOrEmpty(this.serviceMethodName))
          {
              ExecuteMethodOnDynamicObject_MethodCall(mtList);
          }
          else
          {
              ExecuteMethodOnDynamicObject_Workflow();
          }
      }
      catch (TargetInvocationException targetEx)
      {
          Utils.CommonLogger.LogException("Target invocation exception caught in GetData()", targetEx);
          throw targetEx.InnerException;
      }
      catch (Exception exp)
      {
          Utils.CommonLogger.LogException("Failed to invoke service.", exp);
          throw;
      }
    }
    #endregion

    #region Protected Methods
    protected void ExecuteMethodOnDynamicObject_MethodCall(object mtList)
    {
      MethodInfo mi = DynamicObjectType.GetMethod(this.serviceMethodName);
      if (mi == null)
      {
        Utils.CommonLogger.LogError("Object does not have " + serviceMethodName);
        throw new MissingMethodException("Object does not have " + serviceMethodName + " method");
      }

      //populate parameters
      ArrayList alParams = new ArrayList();
      ParameterInfo[] methodParams = mi.GetParameters();

      for (int i = 0; i < methodParams.Length; i++)
      {
        ParameterInfo pi = methodParams[i];

        if (i < ServiceMethodParameters.Count)//WRONG CHECK!!!  need to see if it is byRef mtList
        {
          //copy parameter value to param list
          string rawValue = ServiceMethodParameters[i].ParamValue;
          object actualValue = TypeDescriptor.GetConverter(pi.ParameterType).ConvertFrom(rawValue);

          alParams.Add(actualValue);
        }
        else
        {
          //if it is MTList, then pass in by ref
          if (pi.ParameterType.IsByRef)
          {
            alParams.Add(mtList);
          }

          //else - some un-initialized param, pass in null
          else
          {
            alParams.Add(null);
          }
        }
      }

      //copy params to object array
      object[] objParams = alParams.ToArray();

      //invoke the method
      mi.Invoke(dynamicObject, objParams);

      ////HACK!!!
      dynamicObject = objParams[1];
      dynamicObjectType = dynamicObject.GetType();
    }

    protected void ExecuteMethodOnDynamicObject_Workflow()
    {
      //find Invoke method on the object
      MethodInfo mi = dynamicObjectType.GetMethod("Invoke");
      if (mi == null)
      {
        Utils.CommonLogger.LogError("Object does not have Invoke method");
        throw new MissingMethodException("Object does not have Invoke method");
      }

      mi.Invoke(dynamicObject, null);
    }

    /// <summary>
    /// Determine the type of MTList by evaluating the parameters to the service method
    /// </summary>
    /// <returns></returns>
    protected Type GetMTListType_MethodCall()
    {
      if (DynamicObjectType == null)
      {
        return null;
      }

      if (String.IsNullOrEmpty(serviceMethodName))
      {
        return null;
      }

      //attempt to find the method with the name matching ServiceMethodName
      MethodInfo mi = null;
      try
      {
        mi = DynamicObjectType.GetMethod(serviceMethodName);
      }
      //exit if more than one found
      catch (AmbiguousMatchException ame)
      {
        Utils.CommonLogger.LogError("Multiple instances of method " + serviceMethodName + " found", ame);
        return null;
      }

      //exit if none found
      if (mi == null)
      {
        Utils.CommonLogger.LogError("Unable to find method " + serviceMethodName);
        return null;
      }

      //get the list of parameters
      ParameterInfo[] piList = mi.GetParameters();

      Type innerType = null;

      //find the MTList parameter
      foreach (ParameterInfo pi in piList)
      {
        if ((pi.ParameterType.Name == "MTList`1") || (pi.ParameterType.Name == "MTList`1&"))
        {
          try
          {
            Type[] genericArguments = pi.ParameterType.GetGenericArguments();
            if (genericArguments.Length > 0)
            {
              innerType = genericArguments[0];

              //return the list type
              if (pi.ParameterType.IsByRef)
              {
                return pi.ParameterType.GetElementType();
              }
            }
          }
          catch (Exception e)
          {
            Utils.CommonLogger.LogWarning("Unable to load MTList from parameter list", e);
            return null;
          }
        }
      }

      return null;
    }

    /// <summary>
    /// Determines the type of the items in MTList based on the outPropertyName
    /// and matching it to the properties of the dynami object.  This only applies
    /// to the cases where the data is extracted from the workflows.
    /// </summary>
    /// <returns></returns>
    protected Type GetMTListType_Workflow()
    {
      //return if empty
      if (String.IsNullOrEmpty(outPropertyName))
      {
        return null;
      }

      //attempt to find the property on the dynamic object
      PropertyInfo pi = GetProperty(dynamicObjectType, outPropertyName, true);

      //return if property does not exist
      if (pi == null)
      {
        return null;
      }

      //if this property is of type MTList...
      if ((pi.PropertyType.Name != "MTList`1") && (pi.PropertyType.BaseType.Name != "MTList`1"))
      {
        return null;
      }

      return pi.PropertyType;
    }

    protected Type GetMTListType()
    {
      if (!String.IsNullOrEmpty(serviceMethodName))
      {
        return GetMTListType_MethodCall();
      }

      return GetMTListType_Workflow();
    }

    protected object GetMTListPlaceholderObject()
    {
      Type mtListType = GetMTListType();
      if (mtListType == null)
      {
        return null;
      }

      //...create an instance of that type
      object mtList = null;
      try
      {
        mtList = Activator.CreateInstance(mtListType);
      }
      catch (Exception e)
      {
        Utils.CommonLogger.LogError("Unable to create instance of type " + mtListType.Name, e);
        return null;
      }
      if (mtList == null)
      {
        return null;
      }

      //dynamically set the following properties: CurrentPage, Filters, PageSize, SortDirection, SortProperty
      PopulateProperty(mtList, "CurrentPage", this.currentPage);
      PopulateProperty(mtList, "PageSize", this.pageSize);
      if (!string.IsNullOrEmpty(sortProperty))
      {
          SortCriteria sc = new SortCriteria(ResolveFilterColumnName(this.sortProperty), this.SortDirection);
          List<SortCriteria> scList = new List<SortCriteria>() { sc };
          PopulateProperty(mtList, "SortCriteria", scList);
      }
      //PopulateProperty(mtList, "SortDirection", this.sortDirection);
      //PopulateProperty(mtList, "SortProperty", ResolveFilterColumnName(this.sortProperty));
      PopulateProperty(mtList, "Filters", this.Filters, false, true);

      return mtList;
    }

    protected string ResolveFilterColumnName(string propName)
    {
        return propName.Replace("#", ".");
      //if (String.IsNullOrEmpty(propName))
      //{
      //  return propName;
      //}

      ////if no '.' found, return without any modifications
      //if (propName.IndexOf('.') < 0)
      //{
      //  //attempt to find double underscore
      //  if (propName.LastIndexOf("#") <= 0)
      //  {
      //    return propName;
      //  }

      //  //return everything after __
      //  //return propName.Substring(propName.LastIndexOf("#") + 1);
      //  return propName.Replace("#", ".");
      //}

      ////split around the '.'
      //string[] arrParts = propName.Split('.');

      //if (arrParts.Length < 2)
      //{
      //  return null;
      //}

      ////return the property name, which is the last item in the split array
      //return arrParts[arrParts.Length - 1];
    }


    protected string GetJSonString()
    {
      JavaScriptSerializer jss = new JavaScriptSerializer();
      return jss.Serialize(dynamicObject);
    }

    protected void PopulateProperties()
    {
      PopulateProperty(dynamicObject, "UserName", mUserData.UserName, false, true);
      PopulateProperty(dynamicObject, "Password", mUserData.SessionPassword, false, true);

      if(!String.IsNullOrEmpty(this.serviceMethodName))
      {
        ((AccountServiceClient)dynamicObject).ClientCredentials.UserName.UserName = mUserData.UserName;
        ((AccountServiceClient) dynamicObject).ClientCredentials.UserName.Password = mUserData.SessionPassword;
      }

      if (!String.IsNullOrEmpty(this.AccountId))
      {
        PopulateProperty(dynamicObject, "AccountId", new AccountIdentifier(int.Parse(this.AccountId)), true, false);
      }

      if (!String.IsNullOrEmpty(this.ProcessorInstanceId))
      {
        PopulateProperty(dynamicObject, "ProcessorInstanceId", this.ProcessorInstanceId, true, false);
      }

      foreach (string key in Arguments.Keys)
      {
        PopulateProperty(dynamicObject, key, Arguments[key], true, false);
      }
    }

    protected static PropertyInfo GetProperty(Type objectType, String propertyName)
    {
      return GetProperty(objectType, propertyName, false);
    }

    protected static PropertyInfo GetProperty(Type objectType, String propertyName, bool usePrefix)
    {
      if (objectType == null)
      {
        return null;
      }

      if (String.IsNullOrEmpty(propertyName))
      {
        return null;
      }

      PropertyInfo pi = objectType.GetProperty(propertyName);

      if (usePrefix)
      {
        //attempt to prefix In_ to prop name
        if (pi == null)
        {
          pi = objectType.GetProperty("In_" + propertyName);
        }

        //attempt to prefix InOut_ if it is still not found
        if (pi == null)
        {
          pi = objectType.GetProperty("InOut_" + propertyName);
        }
      }

      //return whatever we get
      return pi;
    }

    protected void PopulateProperty(object targetObject, string key, object value)
    {
      PopulateProperty(targetObject, key, value, false, false);
    }

    protected void PopulateProperty(object targetObject, string key, object value, bool usePrefix, bool skipCohersion)
    {
      //attempt to find the property by retrieving it or appending In_ or InOut_ to the property name
      string propertyName = key;
      PropertyInfo pi = GetProperty(targetObject.GetType(), propertyName, true);

      //if it is still null, exit
      if (pi == null)
      {
        return;
      }

      try
      {
        //attempt to set the property
        object cohercedValue = (skipCohersion) ? value : CoherceStringToPropertyType(targetObject, /*propertyName*/pi, value);
        pi.SetValue(targetObject, cohercedValue, null);
      }
      catch (Exception e)
      {
        Utils.CommonLogger.LogException("Unable to set property value for " + key, e);
        return;
      }
    }

    protected object CoherceStringToPropertyType(object targetObject,
      /*string propertyName*/PropertyInfo pi,
                                              object value)
    {
      object result = null;

      //Type type = targetObject.GetType();//dynamicObjectType;
      //PropertyInfo p = type.GetProperty(propertyName);
      if (pi != null && value != null)
      {
        Type propertyType = pi.PropertyType;

        if (propertyType == value.GetType())
        {
          return value;
        }

        TypeConverter converter = TypeDescriptor.GetConverter(propertyType);

        if (converter != null)
        {

          if (converter.CanConvertFrom(value.GetType()))
          {
            result = converter.ConvertFrom(value);
          }
        }
      }
      return result;
    }

    protected Assembly GetAssembly()
    {
      String assemblyPath = string.Empty;

      //use services
      if (!String.IsNullOrEmpty(serviceMethodName))
      {
        assemblyPath = "MetraTech.Core.Services.ClientProxies.dll";
      }
      else //use workflows
      {
        assemblyPath = "MetraTech.PageNav.ClientProxies.dll";
      }
      Assembly a = Assembly.LoadFile(Path.Combine(HttpRuntime.BinDirectory, assemblyPath));

      return a;
    }


    protected void ProcessKeyValuePairElement(string element)
    {
      string[] keyValuePair = element.Split(new char[] { '=' });

      //make sure we have two items: key and value
      if (keyValuePair.Length != 2)
      {
        return;
      }

      //read out key and value
      string key = keyValuePair[0];
      string value = keyValuePair[1];

      //populate the arguments dictionary
      if (!this.arguments.ContainsKey(key))
      {
        this.arguments.Add(key, value);
      }
      else
      {
        this.arguments[key] = value;
      }
    }

    protected void ParseAdditionalArguments(string args)
    {
      string[] elementSeparator = new string[] { "**" }; //instead of regular &    
      string[] keyValuePair = new string[] { };

      if (args.Length == 0)
      {
        return;
      }

      //break each element into array of key value pairs
      string[] elements = args.Split(elementSeparator, 0, StringSplitOptions.None);

      //check the case when there is only one element
      if (args.Length > 0 && elements.Length == 0)
      {
        ProcessKeyValuePairElement(args);
      }

      //iterate through each key value pairs
      foreach (string elt in elements)
      {
        ProcessKeyValuePairElement(elt);
      }
    }


    #endregion
  }
}
