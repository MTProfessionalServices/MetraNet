using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;

using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using System.Drawing;
using System.Drawing.Design;

using System.Reflection;
using System.IO;
using System.ComponentModel;

using System.Data;
using System.Globalization;
using System.Threading;
using System.ComponentModel.Design.Serialization;
using System.Xml.Serialization;
using MetraTech.BusinessEntity.Core.Model;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.DomainModel.Enums.Core.Global_SystemCurrencies;
using MetraTech.UI.Tools;
using MetraTech.Interop.MTEnumConfig;
using MetraTech.UI.Common;
using MetraTech.DomainModel.Enums;
using MetraTech.DomainModel.AccountTypes;
using BaseObject=MetraTech.DomainModel.BaseTypes.BaseObject;

namespace MetraTech.UI.Controls
{
  /// <summary>
  /// An individual binding item. A BindingItem maps a source object - 
  /// a property/field or database field - to a property of a Control object.
  ///
  /// The object is a child for the MTDataBinder object which acts as a master
  /// object that performs the actual binding of individual BingingItems.
  /// 
  /// Binding Items can be attached to controls and if the control implements the
  /// IMTDataBinder
  /// </summary>
  //[TypeConverter(typeof(MTDataItemTypeConverter))]
  [ToolboxData("<{0}:MTDataBindingItem runat=server />")]
  [Category("Data")]
  [DefaultEvent("Validate")]
  [Description("An individual databinding item that allows you to bind a source binding source - a database field or Object property typically - to a target control property")]
  [Serializable]
  public class MTDataBindingItem : Control
  {
    private IEnumConfig EnumSingletonCache = new EnumConfigClass();

    /// <summary>
    /// Explicitly set designmode flag - stock doesn't work on Collection child items
    /// </summary>
    protected new bool DesignMode = (HttpContext.Current == null);

    /// <summary>
    /// Default Constructor
    /// </summary>
    public MTDataBindingItem()
    {
    }

    /// <summary>
    /// Overridden constructor to allow DataBinder to be passed
    /// as a reference. Unfortunately ASP.NET doesn't fire this when
    /// creating the DataBinder child items.
    /// </summary>
    /// <param name="Parent"></param>
    public MTDataBindingItem(MTDataBinder Parent)
    {
      this._Binder = Parent;
    }

    /// <summary>
    /// Reference to the DataBinder parent object.
    /// </summary>
    [Browsable(false), DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
    public MTDataBinder Binder
    {
      get { return _Binder; }
      set { _Binder = value; }
    }
    private MTDataBinder _Binder = null;

    /// <summary>
    /// MetaData
    /// </summary>
    [NotifyParentProperty(true)]
    [Description("The MetaData to use for better designer support."), DefaultValue("")]
    [TypeConverter(typeof(MetaDataAliasConverter))]
    [Browsable(true)]
    public string BindingMetaDataAlias
    {
      get
      {
        return _BindingMetaDataAlias;
      }
      set
      {
        _BindingMetaDataAlias = value;
      }
    }
    private string _BindingMetaDataAlias = "";

    /// <summary>
    /// The ID of the control to that is bound.
    /// </summary>
    [NotifyParentProperty(true)]
    [Description("The ID of the control to that is bound."), DefaultValue("")]
    [TypeConverter(typeof(ControlIDConverter))]
    [Browsable(true)]
    public string ControlId
    {
      get
      {
        return _ControlId;
      }
      set
      {
        _ControlId = value;
        if (this.DesignMode && this.Binder != null)
          this.Binder.NotifyDesigner();
      }
    }
    private string _ControlId = "";

    /// <summary>
    /// An optional instance of the control that can be assigned. Used internally
    /// by the wwDatBindiner to assign the control whenever possible as the instance
    /// is more efficient and reliable than the string name.
    /// </summary>
    [NotifyParentProperty(false)]
    [Description("An instance value for the controls")]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
    [Browsable(false)]
    public Control ControlInstance
    {
      get
      {
        return _ControlInstance;
      }
      set
      {
        _ControlInstance = value;
      }
    }
    private Control _ControlInstance = null;

    /// <summary>
    /// The binding source object that is the source for databinding.
    /// This is an object of some sort and can be either a real object
    /// or a DataRow/DataTable/DataSet. If a DataTable is used the first row 
    /// is assumed. If a DataSet is used the first table and first row are assumed.
    ///
    /// The object reference is always Page relative, so binding doesn't work
    /// against local variables, only against properties of the form. Form
    /// properties that are bound should be marked public or protected, but
    /// not private as Reflection is used to get the values. 
    /// 
    /// This or me is implicit, but can be specified so
    ///  "Customer" or "this.Customer" is equivalent. 
    /// </summary>
    /// <example>
    /// // *** Bind a DataRow Item
    /// bi.BindingSource = "Customer.DataRow";
    /// bi.BindingSourceMember = "LastName";
    ///
    /// // *** Bind a DataRow within a DataSet  - not recommended though
    /// bi.BindingSource = "this.Customer.Tables["TCustomers"].Rows[0]";
    /// bi.BindingSourceMember = "LastName";
    ///
    /// // *** Bind an Object
    /// bi.BindingSource = "InventoryItem.Entity";
    /// bi.BindingSourceMember = "ItemPrice";
    /// 
    /// // *** Bind a form property
    /// bi.BindingSource = "this";   // also "me" 
    /// bi.BindingSourceMember = "CustomerPk";
    /// </example>
    [NotifyParentProperty(true)]
    [Description("The name of the object or DataSet/Table/Row to bind to. Page relative. Example: Customer.DataRow = this.Customer.DataRow"), DefaultValue("")]
    public string BindingSource
    {
      get { return _BindingSource; }
      set
      {
        _BindingSource = value;
        if (this.DesignMode && this.Binder != null)
          this.Binder.NotifyDesigner();
      }
    }
    private string _BindingSource = "";


    /// <summary>
    /// An instance of the object that the control is bound to
    /// Optional - can be passed instead of a BindingSource string. Using
    /// a reference is more efficient. Declarative use in the designer
    /// always uses strings, code base assignments should use instances
    /// with BindingSourceObject.
    /// </summary>
    [Browsable(false)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
    public object BindingSourceObject
    {
      get { return _BindingSourceObject; }
      set
      {
        _BindingSourceObject = value;
      }
    }
    private object _BindingSourceObject = null;

    /// <summary>
    /// The property or field on the Binding Source that is
    /// bound. Example: BindingSource: Customer.Entity BindingSourceMember: Company
    /// </summary>
    [NotifyParentProperty(true)]
    [Description("The name of the property or field to bind to. Example: So you can bind to a BindingSource of Customer.DataRow and the BindingSourceMember is Company."), DefaultValue("")]
    [TypeConverter(typeof(MTPropertyConverter))]
    public string BindingSourceMember
    {
      get { return _BindingSourceMember; }
      set
      {
        _BindingSourceMember = value;
        if (this.DesignMode && this.Binder != null)
          this.Binder.NotifyDesigner();
      }
    }
    private string _BindingSourceMember = "";

    /// <summary>
    /// Property that is bound on the target controlId
    /// </summary>
    [NotifyParentProperty(true)]
    [Description("Property that is bound on the target control"), DefaultValue("Text")]
    public string BindingProperty
    {
      get { return _BindingProperty; }
      set
      {
        _BindingProperty = value;
        if (this.DesignMode && this.Binder != null)
          this.Binder.NotifyDesigner();
      }
    }
    private string _BindingProperty = "Text";

    /// <summary>
    /// Format Expression ( {0:c) ) applied to the binding source when it's displayed.
    /// Watch out for two way conversion issues when formatting this way. If you create
    /// expressions and you are also saving make sure the format used can be saved back.
    /// </summary>
    [NotifyParentProperty(true)]
    [Description("Format Expression ( {0:c) ) applied to the binding source when it's displayed."), DefaultValue("")]
    public string DisplayFormat
    {
      get { return _DisplayFormat; }
      set
      {
        _DisplayFormat = value;
        if (this.DesignMode && this.Binder != null)
          this.Binder.NotifyDesigner();
      }
    }
    private string _DisplayFormat = "";

    /// <summary>
    /// If set requires that the control contains a value, otherwise a validation error is thrown
    /// Useful mostly on TextBox controls only.
    /// </summary>
    [NotifyParentProperty(true)]
    [Description("If set requires that the control contains a value, otherwise a validation error is thrown - recommended only on TextBox controls."), DefaultValue(false)]
    public bool IsRequired
    {
      get { return _IsRequired; }
      set
      {
        _IsRequired = value;
        if (this.DesignMode && this.Binder != null)
          this.Binder.NotifyDesigner();
      }
    }
    private bool _IsRequired = false;

    /// <summary>
    /// A descriptive name for the field used for error display
    /// </summary>
    [Description("A descriptive name for the field used for error display"), DefaultValue("")]
    [NotifyParentProperty(true)]
    public string UserFieldName
    {
      get { return _UserFieldName; }
      set
      {
        _UserFieldName = value;
        if (this.DesignMode && this.Binder != null)
          this.Binder.NotifyDesigner();
      }
    }
    private string _UserFieldName = "";

    /// <summary>
    /// Determines how binding and validation errors display on the control
    /// </summary>
    [Description("Determines how binding and validation errors display on the control"),
     DefaultValue(BindingErrorMessageLocations.WarningIconRight)]
    [NotifyParentProperty(true)]
    public BindingErrorMessageLocations ErrorMessageLocation
    {
      get { return _ErrorMessageLocation; }
      set
      {
        _ErrorMessageLocation = value;
        if (this.DesignMode && this.Binder != null)
          this.Binder.NotifyDesigner();
      }
    }
    private BindingErrorMessageLocations _ErrorMessageLocation = BindingErrorMessageLocations.RedTextAndIconBelow;

    /// <summary>
    /// Internal property that lets you know if there was binding error
    /// on this control after binding occurred
    /// </summary>
    [NotifyParentProperty(true)]
    [Browsable(false)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
    public bool IsBindingError
    {
      get { return _IsBindingError; }
      set { _IsBindingError = value; }
    }
    private bool _IsBindingError = false;

    /// <summary>
    /// An error message that gets set if there is a binding error
    /// on the control.
    /// </summary>
    [NotifyParentProperty(true)]
    [Browsable(false)]
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
    public string BindingErrorMessage
    {
      get { return _BindingErrorMessage; }
      set { _BindingErrorMessage = value; }
    }
    private string _BindingErrorMessage = "";

    /// <summary>
    /// Determines how databinding and unbinding is done on the target control. 
    /// One way only fires DataBind() and ignores Unbind() calls. 
    /// Two-way does both. None effectively turns off binding.
    /// </summary>
    [Description("Determines how databinding and unbinding is done on the target control. One way only fires DataBind() and ignores Unbind() calls. Two-way does both"),
    Browsable(true), DefaultValue(BindingModes.TwoWay)]
    public BindingModes BindingMode
    {
      get { return _BindingMode; }
      set { _BindingMode = value; }
    }
    private BindingModes _BindingMode = BindingModes.TwoWay;

    /// <summary>
    /// Use this event to hook up special validation logic. Called after binding completes. Return false to indicate validation failed
    /// </summary>
    [Browsable(true), Description("Use this event to hook up special validation logic. Called after binding completes. Return false to indicate validation failed")]
    public event delDataBindingItemValidate Validate;

    /// <summary>
    /// Fires the Validation Event
    /// </summary>
    /// <returns></returns>
    public bool OnValidate()
    {
      if (this.Validate != null)
      {
        DataBindingValidationEventArgs Args = new DataBindingValidationEventArgs();
        Args.DataBindingItem = this;

        this.Validate(this, Args);

        if (!Args.IsValid)
          return false;
      }

      return true;
    }

    /// <summary>
    /// Binds a source object and property to a control's property. For example
    /// you can bind a business object to a the text property of a text box, or 
    /// a DataRow field to a text box field. You specify a binding source object 
    /// (Customer.Entity or Customer.DataRow) and property or field(Company, FirstName)
    /// and bind it to the control and the property specified (Text).
    /// </summary>
    public new void DataBind()
    {
      if (BindingMode == BindingModes.None)
        return;

      if (this.Binder != null)
        this.DataBind(this.Binder.Page);

      this.DataBind(this.Page);
    }

    protected Control GetControlByControlId(Control root, String ControlId)
    {
      Control ctrl = null;

      int firstDot = ControlId.IndexOf(".");
      string topLevelObj = ControlId.Substring(0, firstDot);
      string propertyHierarchy = ControlId.Substring(firstDot + 1, ControlId.Length - firstDot - 1);
      object tempControl = WebUtils.FindControlRecursive(root, topLevelObj);
      if (tempControl != null)
      {

        try
        {
          ctrl = (Control)Utils.GetPropertyEx(tempControl, propertyHierarchy);
        }
        catch {
          ctrl = null; 
        }
      }

      return ctrl;
    }

    /// <summary>
    /// Binds a source object and property to a control's property. For example
    /// you can bind a business object to a the text property of a text box, or 
    /// a DataRow field to a text box field. You specify a binding source object 
    /// (Customer.Entity or Customer.DataRow) and property or field(Company, FirstName)
    /// and bind it to the control and the property specified (Text).
    /// </summary>
    /// <param name="WebPage">the Base control that binding source objects are attached to</param>
    public void DataBind(Control WebPage)
    {
      if (BindingMode == BindingModes.None)
        return;

      // *** Empty BindingSource - simply skip
      if (this.BindingSourceObject == null &&
          string.IsNullOrEmpty(this.BindingSource) ||
          string.IsNullOrEmpty(this.BindingSourceMember))
        return;

      // *** Retrieve the binding source either by object reference or by name
      string BindingSource = this.BindingSource;
      object BindingSourceObject = this.BindingSourceObject;

      string BindingSourceMember = this.BindingSourceMember;
      string BindingProperty = this.BindingProperty;

      Control ActiveControl = null;
      if (this.ControlInstance != null)
        ActiveControl = this.ControlInstance;
      else
      {
        //single-level ControlID
        if (this.ControlId.IndexOf(".") < 0)
        {
          ActiveControl = WebUtils.FindControlRecursive(WebPage, this.ControlId);
        }

        //complex ControlID
        else
        {
          ActiveControl = GetControlByControlId(WebPage, this.ControlId);
        }
      }
      try
      {
        if (ActiveControl == null)
          throw new ApplicationException();

        // *** Assign so error handler can get a clean control reference
        this.ControlInstance = ActiveControl;

        // *** Retrieve the bindingsource by name - otherwise we use the 
        if (BindingSourceObject == null)
        {
          // *** Get a reference to the actual control source object
          // *** Allow this or me to be bound to the page
          if (BindingSource == "this" || BindingSource.ToLower() == "me")
          {
            BindingSourceObject = WebPage;
          }
          else
          {
            BindingSourceObject = Utils.GetPropertyEx(WebPage, BindingSource);
          }
        }

        if (BindingSourceObject == null)
          throw new BindingErrorException("Invalid BindingSource: " +
                                          this.BindingSource + "." + this.BindingSourceMember);

        // *** Retrieve the control source value
        object loValue;
        Type enumType = null;

        if (BindingSourceObject is EntityInstance)
        {
          loValue = ((EntityInstance)BindingSourceObject).GetValue(BindingSourceMember);
        }
        else if (BindingSourceObject is PropertyDS)
        {
          PropertyDS properties = (PropertyDS)BindingSourceObject;
          loValue = properties[BindingSourceMember];
        }
        else if (BindingSourceObject is System.Data.DataSet)
        {
          string lcTable = BindingSourceMember.Substring(0, BindingSourceMember.IndexOf("."));
          string lcColumn = BindingSourceMember.Substring(BindingSourceMember.IndexOf(".") + 1);
          DataSet Ds = (DataSet)BindingSourceObject;
          loValue = Ds.Tables[lcTable].Rows[0][lcColumn];
        }
        else if (BindingSourceObject is System.Data.DataRow)
        {
          DataRow Dr = (DataRow)BindingSourceObject;
          loValue = Dr[BindingSourceMember];
        }
        else if (BindingSourceObject is System.Data.DataTable)
        {
          DataTable Dt = (DataTable)BindingSourceObject;
          loValue = Dt.Rows[0][BindingSourceMember];
        }
        else if (BindingSourceObject is System.Data.DataView)
        {
          DataView Dv = (DataView)BindingSourceObject;
          loValue = Dv.Table.Rows[0][BindingSourceMember];
        }
        else
        {
          loValue = Utils.GetPropertyEx(BindingSourceObject, BindingSourceMember);
        }

        // *** Figure out the type of the control we're binding to
        object loBindValue = Utils.GetProperty(ActiveControl, BindingProperty);
        string lcBindingSourceType = loBindValue.GetType().Name;




        // TODO: Handle DbNull value here...
        if (loValue == null)
        {
          if (BindingSourceObject is EntityInstance)
          {
            PropertyInstance propertyInstance = ((EntityInstance)BindingSourceObject)[BindingSourceMember];
            if (propertyInstance.PropertyType == MetraTech.BusinessEntity.Core.PropertyType.Enum)
            {
              enumType = Type.GetType(propertyInstance.AssemblyQualifiedTypeName);
            }
          }
          else
          {
            // See if this type is an enum
            enumType = Utils.GetNullableEnumType(BindingSourceObject, BindingSourceMember);            
          }

          if (enumType != null)
          {
            SetEnumValues(ActiveControl, enumType);
          }
          else if (lcBindingSourceType == "String")
          {
            Utils.SetProperty(ActiveControl, BindingProperty, "");
          }
          else if (lcBindingSourceType == "Boolean")
          {
            Utils.SetProperty(ActiveControl, BindingProperty, false);
          }
          else
          {
            Utils.SetProperty(ActiveControl, BindingProperty, "");
          }
        }
        else
        {
          // Special case the handling of InternalView.Currency because it's specified as a
          // string on the InternalView and must be used like an enum based on SystemCurrencies
          if (BindingSourceObject is MetraTech.DomainModel.AccountTypes.InternalView &&
              BindingSourceMember.ToLower() == "currency")
          {
            if (ActiveControl is DropDownList)
            {
              InternalView internalView = BindingSourceObject as InternalView;

              object currencyEnum = EnumHelper.GetEnumByValue(typeof(SystemCurrencies), internalView.Currency);

              List<MetraTech.DomainModel.BaseTypes.EnumData> enumDataList = null;
              if (currencyEnum != null)
              {
                enumDataList = BaseObject.GetEnumData((SystemCurrencies)currencyEnum);
              }
              else
              {
                enumDataList = BaseObject.GetEnumData(typeof(SystemCurrencies));
              }
              MTDropDown dd = ActiveControl as MTDropDown;
              dd.AllowBlank = true;
              dd.Items.Clear();
              ListItem itmBlank = new ListItem("", "");
              dd.Items.Add(itmBlank);

              foreach (MetraTech.DomainModel.BaseTypes.EnumData enumData in enumDataList)
              {
                ListItem itm = new ListItem(enumData.DisplayName /*localized*/, enumData.EnumInstance.ToString());
                if (enumData.Selected)
                {
                  itm.Selected = true;
                }
                dd.Items.Add(itm);
              }
            }
            //blindly bind to the control
            else 
            {
              Utils.SetProperty(ActiveControl, BindingProperty, loValue.ToString());
            }
          }
          // Booleans
          else if (lcBindingSourceType == "Boolean")
          {
            Utils.SetProperty(ActiveControl, BindingProperty, loValue);
          }
          // ENUMS
          else if (loValue.GetType().BaseType.Name == "Enum")
          {

            if (BindingSourceObject is EntityInstance)
            {
              PropertyInstance propertyInstance = ((EntityInstance)BindingSourceObject)[BindingSourceMember];
              if (propertyInstance.PropertyType == MetraTech.BusinessEntity.Core.PropertyType.Enum)
              {
                enumType = Type.GetType(propertyInstance.AssemblyQualifiedTypeName);
              }
            }
            else
            {
              enumType = loValue.GetType(); 
            }
            
            SetEnumValues(ActiveControl, enumType);
            if (ActiveControl is DropDownList)
            {
              Utils.SetProperty(ActiveControl, BindingProperty, loValue.ToString());
            }
            else
            {
              Utils.SetProperty(ActiveControl, BindingProperty, BaseObject.GetDisplayName(loValue).ToString()); 
            }
          }
          else if (ActiveControl is Label)
          {
            // get localized value of enum
            Label label = ActiveControl as Label;
            Utils.SetProperty(ActiveControl, BindingProperty, loValue.ToString());
          }
          // ArrayList
          else if (loValue.GetType().Name == "ArrayList")
          {
            ArrayList vals = loValue as ArrayList;
            if (ActiveControl is DropDownList)
            {
              DropDownList dd = ActiveControl as DropDownList;
              if (dd.Items.Count == 0)
              {
                foreach (string val in vals)
                {
                  ListItem itm = new ListItem(val /*localized*/, val /*value*/);
                  dd.Items.Add(itm);
                }
              }

              //TODO:  We could set a selected property here... maybe off a default attribute
              //Utils.SetProperty(ActiveControl, BindingProperty, defaultValue); // try to set a default
            }
          }
          // Enums
          else if (loValue is MetraTech.UI.Common.EnumData)
          {
            MetraTech.UI.Common.EnumData enumData = loValue as MetraTech.UI.Common.EnumData;
            if (ActiveControl is DropDownList)
            {
              DropDownList dd = ActiveControl as DropDownList;
              dd.Items.Clear();
              foreach (EnumItem item in enumData.EnumItems)
              {
                ListItem itm = new ListItem(item.LocalizedName, item.Id);
                dd.Items.Add(itm);
              }
              Utils.SetProperty(ActiveControl, BindingProperty, enumData.SelectedValue);
            }
            else
            {
              //TODO: should be LocalizedValue
              Utils.SetProperty(ActiveControl, BindingProperty, enumData.GetLocalizedName(enumData.SelectedValue));
            }
          }
          else
          {
            if (string.IsNullOrEmpty(this.DisplayFormat))
              Utils.SetProperty(ActiveControl, BindingProperty, loValue.ToString());
            else
              Utils.SetProperty(ActiveControl, BindingProperty, String.Format(this.DisplayFormat, loValue));
          }
        }
      }
      catch (Exception ex)
      {
        string lcException = ex.Message;
        throw (new BindingErrorException("Unable to bind " +
            BindingSource + "." +
            BindingSourceMember));
      }
    }

    /// <summary>
    /// Unbinds control properties back into the control source.
    /// 
    /// This method uses reflection to lift the data out of the control, then 
    /// parses the string value back into the type of the data source. If an error 
    /// occurs the exception is not caught internally, but generally the 
    /// FormUnbindData method captures the error and assigns an error message to 
    /// the BindingErrorMessage property of the control.
    /// </summary>
    public void Unbind()
    {
      if (this.BindingMode != BindingModes.TwoWay)
        return;

      if (this.Binder != null)
        this.Unbind(this.Binder.Page);

      this.Unbind(this.Page);
    }

    /// <summary>
    /// Unbinds control properties back into the control source.
    /// 
    /// This method uses reflection to lift the data out of the control, then 
    /// parses the string value back into the type of the data source. If an error 
    /// occurs the exception is not caught internally, but generally the 
    /// FormUnbindData method captures the error and assigns an error message to 
    /// the BindingErrorMessage property of the control.
    /// <seealso>Class wwWebDataHelper</seealso>
    /// </summary>
    /// <param name="WebPage">
    /// The base control that binding sources are based on.
    /// </param>
    public void Unbind(Control WebPage)
    {

      // *** Get the Control Instance first so we ALWAYS have a ControlId
      // *** instance reference available
      Control ActiveControl = null;
      if (this.ControlInstance != null)
        ActiveControl = this.ControlInstance;
      else
      {
        //single-level ControlID
        if (this.ControlId.IndexOf(".") < 0)
        {
          ActiveControl = WebUtils.FindControlRecursive(WebPage, this.ControlId);
        }

        //complex ControlID
        else
        {
          ActiveControl = GetControlByControlId(WebPage, this.ControlId);
        }
      }

      if (ActiveControl == null)
        throw new ApplicationException("Invalid Control Id");

      this.ControlInstance = ActiveControl;

      // *** Don't unbind this item unless we're in TwoWay mode
      if (this.BindingMode != BindingModes.TwoWay)
        return;

      // *** Empty BindingSource - simply skip
      if (this.BindingSourceObject == null &&
          string.IsNullOrEmpty(this.BindingSource) ||
          string.IsNullOrEmpty(this.BindingSourceMember))
        return;

      // *** Retrieve the binding source either by object reference or by name
      string BindingSource = this.BindingSource;
      object BindingSourceObject = this.BindingSourceObject;

      string BindingSourceMember = this.BindingSourceMember;
      string BindingProperty = this.BindingProperty;

      if (BindingSourceObject == null)
      {
        if (BindingSource == null || BindingSource.Length == 0 ||
            BindingSourceMember == null || BindingSourceMember.Length == 0)
          return;

        if (BindingSource == "this" || BindingSource.ToLower() == "me")
          BindingSourceObject = WebPage;
        else
          BindingSourceObject = Utils.GetPropertyEx(WebPage, BindingSource);
      }

      if (BindingSourceObject == null)
        throw new ApplicationException("Invalid BindingSource");


      // Retrieve the new value from the control
      object ControlValue = Utils.GetPropertyEx(ActiveControl, BindingProperty);


      // If we are using minimal binding then check to see if the value in the control is the same as what is in our BoundValues dictionary.
      // If the values are the same, then we do NOT set the value in the object so it will not be set to dirty.
      if (Binder.UseMinimalBinding)
      {
        if (Binder.BoundValues.ContainsKey(BindingSource + BindingSourceMember))
        {
          var val = Binder.BoundValues[BindingSource + BindingSourceMember];

          if (val.ToString().ToLower() == "false" || val.ToString().ToLower() == "true")
          {
            if (ControlValue.ToString().ToLower() == val.ToString().ToLower())
            {
              return;
            }
          }
          else if(ControlValue.ToString() == val.ToString())
          {
            return;
          }
        }
      }

      // Check for Required values not being blank
      if (this.IsRequired && (string)ControlValue == "")
        throw new RequiredFieldException();

      // Try to retrieve the type of the BindingSourceMember
      Type typBindingSource = null;
      string BindingSourceType;
      string DataColumn = null;
      string DataTable = null;

      if (BindingSourceObject is PropertyDS)
      {
        DataColumn = BindingSourceMember;
        BindingSourceType = "string";
        typBindingSource = typeof(string);
      }
      else if (BindingSourceObject is System.Data.DataSet)
      {
        // *** Split out the datatable and column names
        int At = BindingSourceMember.IndexOf(".");
        DataTable = BindingSourceMember.Substring(0, At);
        DataColumn = BindingSourceMember.Substring(At + 1);
        DataSet Ds = (DataSet)BindingSourceObject;
        BindingSourceType = Ds.Tables[DataTable].Columns[DataColumn].DataType.Name;
        typBindingSource = Ds.Tables[DataTable].Columns[DataColumn].DataType;
      }
      else if (BindingSourceObject is System.Data.DataRow)
      {
        DataRow Dr = (DataRow)BindingSourceObject;
        BindingSourceType = Dr.Table.Columns[BindingSourceMember].DataType.Name;
        typBindingSource = Dr.Table.Columns[BindingSourceMember].DataType;
      }
      else if (BindingSourceObject is System.Data.DataTable)
      {
        DataTable dt = (DataTable)BindingSourceObject;
        BindingSourceType = dt.Columns[BindingSourceMember].DataType.Name;
        typBindingSource = dt.Columns[BindingSourceMember].DataType;
      }
      else
      {
        // *** It's an object property or field - get it
        if (BindingSourceObject is EntityInstance)
        {
          BindingSourceType = ((EntityInstance)BindingSourceObject)[BindingSourceMember].Name;  // name of the type
          PropertyInstance prop = ((EntityInstance) BindingSourceObject)[BindingSourceMember];
          typBindingSource = Type.GetType(prop.AssemblyQualifiedTypeName);   // type
        }
        else
        {
          MemberInfo[] MInfo = BindingSourceObject.GetType().GetMember(BindingSourceMember, Utils.MemberAccess);
          if (MInfo[0].MemberType == MemberTypes.Field)
          {
            FieldInfo Field = (FieldInfo) MInfo[0];
            BindingSourceType = Field.FieldType.Name;
            typBindingSource = Field.FieldType;
          }
          else
          {
            PropertyInfo loField = (PropertyInfo) MInfo[0];
            BindingSourceType = loField.PropertyType.Name;
            typBindingSource = loField.PropertyType;
          }
        }
      }

      // ***  Retrieve the value
      object AssignedValue;
      Type enumType;

      if (typBindingSource == typeof(string))
      {
        if (ActiveControl is DropDownList )
        {
          if(ControlValue.ToString() == "")
          {
            AssignedValue = null;
          }
          else
          {
            AssignedValue = ControlValue;
          }
        }
        else
        {
          AssignedValue = ControlValue;
        }
      }
      else if (typBindingSource == typeof(Int16) || typBindingSource == typeof(Nullable<Int16>))
      {
        Int16 TValue = 0;
        if (String.IsNullOrEmpty((string)ControlValue) && typBindingSource == typeof(Nullable<Int32>))
        {
          AssignedValue = null;
        }
        else
        {
          if (!Int16.TryParse((string)ControlValue, NumberStyles.Integer, Thread.CurrentThread.CurrentCulture.NumberFormat, out TValue))
            throw new BindingErrorException("Invalid numeric input");
          else
            AssignedValue = TValue;
        }
      }
      else if (typBindingSource == typeof(Int32) || typBindingSource == typeof(Nullable<Int32>))
      {
        Int32 TValue = 0;

        if (String.IsNullOrEmpty((string)ControlValue) && typBindingSource == typeof(Nullable<Int32>))
        {
          AssignedValue = null;
        }
        else
        {
          if (!Int32.TryParse((string)ControlValue, NumberStyles.Integer, Thread.CurrentThread.CurrentCulture.NumberFormat, out TValue))
            throw new BindingErrorException("Invalid numeric input");
          else
            AssignedValue = TValue;
        }
      }
      else if (typBindingSource == typeof(Int64) || typBindingSource == typeof(Nullable<Int64>))
      {
        Int64 TValue = 0;
        if (String.IsNullOrEmpty((string)ControlValue) && typBindingSource == typeof(Nullable<Int32>))
        {
          AssignedValue = null;
        }
        else
        {
          if (!Int64.TryParse((string)ControlValue, NumberStyles.Integer, Thread.CurrentThread.CurrentCulture.NumberFormat, out TValue))
            throw new BindingErrorException("Invalid numeric input");
          else
            AssignedValue = TValue;
        }
      }
      else if (typBindingSource == typeof(byte) || typBindingSource == typeof(Nullable<byte>))
        AssignedValue = Convert.ToByte(ControlValue);
      else if (typBindingSource == typeof(decimal) || typBindingSource == typeof(Nullable<decimal>) )
        AssignedValue = Decimal.Parse((string)ControlValue, NumberStyles.Any);
      else if (typBindingSource == typeof(double) || typBindingSource == typeof(Nullable<double>))
        AssignedValue = Double.Parse((string)ControlValue, NumberStyles.Any);
      // Bug: CORE-3015 - Handle Guid
      else if (typBindingSource == typeof(Guid) || typBindingSource == typeof(Nullable<Guid>))
          AssignedValue = new Guid((string)ControlValue);
      else if (typBindingSource == typeof(bool) || typBindingSource == typeof(Nullable<bool>))
      {
        AssignedValue = ControlValue;
      }
      else if (typBindingSource == typeof(DateTime) || typBindingSource == typeof(Nullable<DateTime>))
      {
        if (((string)ControlValue).Length != 0)
        {
          DateTime TValue = DateTime.MinValue;
          if (!DateTime.TryParse((string)ControlValue, Thread.CurrentThread.CurrentCulture.DateTimeFormat, DateTimeStyles.None, out TValue))
            throw new BindingErrorException("Invalid date input");
          else
            AssignedValue = TValue;
          //AssignedValue = Convert.ToDateTime(loValue);
        }
        else
        {
          AssignedValue = null;
        }
      }
      else if (typBindingSource == typeof(ArrayList))
      {
        AssignedValue = ControlValue;
        // *** Clear the error message - no error
        this.BindingErrorMessage = "";
        return; // no way to unbind a simple arraylist
      }
      else if (typBindingSource.IsEnum)
      {
        AssignedValue = Enum.Parse(typBindingSource, (string)ControlValue);
      }
      else if (Utils.IsNullableEnumType(typBindingSource, out enumType))
      {
        AssignedValue = null;
        if (Enum.IsDefined(enumType, (string)ControlValue))
        {
          AssignedValue = Enum.Parse(enumType, (string)ControlValue);
        }
      }
      else  // Not HANDLED!!!
        // *** Use a generic exception - we don't want to display the error
        throw (new Exception("Field Type not Handled by Data unbinding"));

      // Write the value back to the underlying object/data item
      if (BindingSourceObject is PropertyDS)
      {
        PropertyDS propertyDS = (PropertyDS)BindingSourceObject;
        propertyDS.SetPropertyValue(DataColumn, AssignedValue.ToString());
      }
      else if (BindingSourceObject is System.Data.DataSet)
      {
        DataSet Ds = (DataSet)BindingSourceObject;
        Ds.Tables[DataTable].Rows[0][DataColumn] = AssignedValue;
      }
      else if (BindingSourceObject is System.Data.DataRow)
      {
        DataRow Dr = (DataRow)BindingSourceObject;
        Dr[BindingSourceMember] = AssignedValue;
      }
      else if (BindingSourceObject is System.Data.DataTable)
      {
        DataTable dt = (DataTable)BindingSourceObject;
        dt.Rows[0][BindingSourceMember] = AssignedValue;
      }
      else if (BindingSourceObject is System.Data.DataView)
      {
        DataView dv = (DataView)BindingSourceObject;
        dv[0][BindingSourceMember] = AssignedValue;
      }
      else
      {
        if (BindingSourceObject is EntityInstance)
        {
          ((EntityInstance)BindingSourceObject).SetValue(AssignedValue, BindingSourceMember);
        }
        else
        {
          Utils.SetPropertyEx(BindingSourceObject, BindingSourceMember, AssignedValue);
        }
      }

      // *** Clear the error message - no error
      this.BindingErrorMessage = "";
    }

    /// <summary>
    /// Returns a the control bindingsource and binding source member
    /// </summary>
    /// <returns></returns>
    public override string ToString()
    {
      if (string.IsNullOrEmpty(this.BindingSource))
        return base.ToString();

      return this.BindingSource + "." + this.BindingSourceMember;
    }

    private void SetEnumValues(Control control, Type enumType)
    {
      if (control is DropDownList)
      {
        DropDownList dd = control as DropDownList;
        dd.Items.Clear(); 

        List<MetraTech.DomainModel.BaseTypes.EnumData> enumDataList = BaseObject.GetEnumData(enumType);

        if (enumType.Name == "CountryName")
        {
          ListItem itm0 = new ListItem("", "");
          dd.Items.Add(itm0);
          foreach (MetraTech.DomainModel.BaseTypes.EnumData enumData in enumDataList)
          {
            ListItem itm = new ListItem(enumData.DisplayName /*localized*/, enumData.EnumInstance.ToString());
            dd.Items.Add(itm);
          }          
        }
        else
        {
          if(control is MTDropDown)
          {
            if(((MTDropDown)control).AllowBlank)
            {
              ListItem itm0 = new ListItem("", "");
              dd.Items.Add(itm0);              
            }
          }

          foreach (MetraTech.DomainModel.BaseTypes.EnumData enumData in enumDataList)
          {
            ListItem itm = new ListItem(enumData.DisplayName /*localized*/, enumData.EnumInstance.ToString());
            dd.Items.Add(itm);
          }
        }
      }
    }

    private object GetEnumValue(string displayName)
    {
      object enumInstance = null;

      return enumInstance;
    }

    #region Hide Properties for the Designer
    [Browsable(false)]
    public override string ID
    {
      get
      {
        return base.ID;
      }
      set
      {
        base.ID = value;
      }
    }

    [Browsable(false)]
    public override bool Visible
    {
      get
      {
        return base.Visible;
      }
      set
      {
        base.Visible = value;
      }
    }

    [Browsable(false)]
    public override bool EnableViewState
    {
      get
      {
        return base.EnableViewState;
      }
      set
      {
        base.EnableViewState = value;
      }
    }
    #endregion

  }

  /// <summary>
  /// Enumeration for the various binding error message locations possible
  /// that determine where the error messages are rendered in relation to the
  /// control.
  /// </summary>
  public enum BindingErrorMessageLocations
  {
    /// <summary>
    /// Displays an image icon to the right of the control
    /// </summary>
    WarningIconRight,
    /// <summary>
    /// Displays a text ! next to the control 
    /// </summary>
    TextExclamationRight,
    /// <summary>
    /// Displays the error message as text below the control
    /// </summary>
    RedTextBelow,
    /// <summary>
    /// Displays an icon and the text of the message below the control.
    /// </summary>
    RedTextAndIconBelow,
    None
  }

  /// <summary>
  /// Determines how databinding is performed for the target control. Note that 
  /// if a MTDataBindingItem is  marked for None or OneWay, the control will not 
  /// be unbound or in the case of None bound even when an explicit call to 
  /// DataBind() or Unbind() is made.
  /// </summary>
  public enum BindingModes
  {
    /// <summary>
    /// Databinding occurs for DataBind() and Unbind()
    /// </summary>
    TwoWay,
    /// <summary>
    /// DataBinding occurs for DataBind() only
    /// </summary>
    OneWay,
    /// <summary>
    /// No binding occurs
    /// </summary>
    None
  }


  /// <summary>
  /// Event Args passed to a Validate event of a MTDataBindingItem control.
  /// </summary>
  public class DataBindingValidationEventArgs : EventArgs
  {
    /// <summary>
    /// Instance of the DataBinding Control that fired this Validation event.
    /// </summary>
    public MTDataBindingItem DataBindingItem
    {
      get { return _DataBindingItem; }
      set { _DataBindingItem = value; }
    }
    private MTDataBindingItem _DataBindingItem = null;

    /// <summary>
    /// Out flag that determines whether this control value is valid.
    /// </summary>
    public bool IsValid
    {
      get { return _IsValid; }
      set { _IsValid = value; }
    }
    private bool _IsValid = true;
  }

}