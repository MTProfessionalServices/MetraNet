/*
 **************************************************************
 * MTDataBinder
 **************************************************************
 *  Source derrived from the works of Rick Strahl 
 *          http://www.west-wind.com/
 *          http://msdn.microsoft.com/msdnmag/issues/06/12/ExtendASPNET/default.aspx?loc=en
 **************************************************************   
 */

using System;
using System.Collections.Generic;
using System.Text;

using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.Design.WebControls;

using System.Drawing;
using System.Drawing.Design;
using System.Reflection;
using System.IO;
using System.ComponentModel;

using System.Data;
using System.Globalization;
using System.Threading;
using System.ComponentModel.Design;
using System.Web.UI.Design;
using System.Diagnostics;
using System.Text.RegularExpressions;
using MetraTech.Debug.Diagnostics;
using MetraTech.UI.Tools;
using Microsoft.Win32;
using Calendar = System.Globalization.Calendar;

namespace MetraTech.UI.Controls
{

	/// <summary>
	/// The MTDataBinder class provides two-way, simple databinding a single 
	/// datasource value and single control property. It can bind object properties
	///  and fields and database values (DataRow fields) to a control property such
	///  as the Text, Checked or SelectedValue properties. In a nutshell the 
	/// controls acts as a connector between a datasource and the control and 
	/// provides explicit databinding for the control.
	/// 
	/// The control supports two-way binding. Control can be bound to the 
	/// datasource values and can be unbound by taking control values and storing 
	/// them back into the datasource. The process is performed explicitly by 
	/// calling the DataBind() and Unbind() methods of the control. Controls 
	/// attached to the databinder can also be bound individually.
	/// 
	/// The control also provides a BindErrors collection which captures any 
	/// binding errors and allows friendly display of these binding errors using 
	/// the ToHtml() method. BindingErrors can be manually added and so application
	///  level errors can be handled the same way as binding errors. It's also 
	/// possible to pull in ASP.NET Validator control errors.
	/// 
	/// Simple validation is available with IsRequired for each DataBinding item. 
	/// Additional validation can be performed server side by implementing the 
	/// ValidateControl event which allows you to write application level 
	/// validation code.
	/// 
	/// This control is implemented as an Extender control that extends any Control
	///  based class. This means you can databind to ANY control class and its 
	/// properties with this component.
	/// <seealso>Class MTDataBindingItem</seealso>
	/// </summary>
	[NonVisualControl, Designer(typeof(MTDataBinderDesigner))]
	[ProvideProperty("DataBindingItem", typeof(Control))]
	[ParseChildren(true, "DataBindingItems")]
	[PersistChildren(false)]
	[DefaultProperty("DataBindingItems")]
	[DefaultEvent("ValidateControl")]
	public class MTDataBinder : Control, IExtenderProvider  //System.Web.UI.WebControls.WebControl
	{
		private static Logger logger = new Logger("[DataBinder]");

		public MTDataBinder()
		{
			this._DataBindingItems = new MTDataBindingItemCollection(this);
		}

		public new bool DesignMode = (HttpContext.Current == null);

		/// <summary>
		/// Only unbinds properties that have been changed on the UI, null and emptystring are considered equal.
		/// </summary>
		[Description("Only unbinds properties that have been changed on the UI, null and emptystring are considered equal.")]
		[DefaultValue(false)]
		public bool UseMinimalBinding
		{
			get
			{
				if (ViewState["UseMinimalBinding"] == null)
					ViewState["UseMinimalBinding"] = false;

				return (bool)ViewState["UseMinimalBinding"];
			}
			set { ViewState["UseMinimalBinding"] = value; }
		}

		/// <summary>
		/// Dictionary of properties and values that have been bound.  
		/// This is used to know if we need to unbind properties when UseMinimalBinding is on.
		/// </summary>
		public Dictionary<string, string> BoundValues
		{
			get
			{
				Dictionary<string, string> dict = ViewState["BoundValues"] as Dictionary<string, string>;
				if (dict == null)
				{
					ViewState["BoundValues"] = new Dictionary<string, string>();
				}
				return ViewState["BoundValues"] as Dictionary<string, string>;
			}
			set { ViewState["BoundValues"] = value; }
		}

		/// <summary>
		/// MetaDataMappings used to give clues to the type converters so dropdowns can be 
		/// provided in the designer's property sheets.
		/// </summary>
		[DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
		[PersistenceMode(PersistenceMode.InnerProperty)]
		[Category("MetaData")]
		public List<MetaDataItem> MetaDataMappings
		{
			get { return _MetaDataMappings; }
		}
		List<MetaDataItem> _MetaDataMappings = new List<MetaDataItem>();

		/// <summary>
		/// A collection of all the DataBindingItems that are to be bound. Each 
		/// &lt;&lt;%= TopicLink([MTDataBindingItem],[_1UL03RIKQ]) %&gt;&gt; contains 
		/// the information needed to bind and unbind a DataSource to a Control 
		/// property.
		/// <seealso>Class MTDataBinder</seealso>
		/// </summary>
		[DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
		[PersistenceMode(PersistenceMode.InnerProperty)]
		public MTDataBindingItemCollection DataBindingItems
		{
			get { return _DataBindingItems; }
		}
		MTDataBindingItemCollection _DataBindingItems = null;

		/////// <summary>
		/////// Collection of all the preserved properties that are to
		/////// be preserved/restored. Collection hold, ControlId, Property
		/////// </summary>
		//[DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
		//[PersistenceMode(PersistenceMode.InnerProperty)]
		//public List<MTDataBindingItem> DataBindingItems
		//{
		//    get
		//    {
		//        return _DataBindingItems;
		//    }
		//}
		//List<MTDataBindingItem> _DataBindingItems = new List<MTDataBindingItem>();

		/// <summary>
		/// A collection of binding errors that is filled after binding or unbinding
		/// if errors occur during binding and unbinding.
		/// </summary>
		[Browsable(false)]
		public BindingErrors BindingErrors
		{
			get { return _BindingErrors; }
			set { _BindingErrors = value; }
		}
		private BindingErrors _BindingErrors = new BindingErrors();

		/// <summary>
		/// Determines whether binding errors are display on controls.
		/// </summary>
		[Description("Determines whether binding errors are displayed on controls. The display mode is determined for each binding individually.")]
		[DefaultValue(true)]
		public bool ShowBindingErrorsOnControls
		{
			get { return _ShowBindingErrorsOnControls; }
			set { _ShowBindingErrorsOnControls = value; }
		}
		private bool _ShowBindingErrorsOnControls = true;


		/// <summary>
		/// Determines the number of controls to render before creating a new thread to run in parallel
		/// </summary>
		[Description("Determines the number of controls to render before creating a new thread to run in parallel")]
		[DefaultValue(true)]
		public int NumberOfControlsBeforeMultiThreaded
		{
			get { return _NumberOfControlsBeforeMultiThreaded; }
			set { _NumberOfControlsBeforeMultiThreaded = value; }
		}
		private int _NumberOfControlsBeforeMultiThreaded = 10;

		/// <summary>
		/// Optional Url to the Warning and Info Icons.
		/// Note: Used only if the control uses images.
		/// </summary>
		[Description("Optional Image Url for the Error Icon. Used only if the control uses image icons."),
		Editor("System.Web.UI.Design.ImageUrlEditor", typeof(UITypeEditor)),
		DefaultValue("WebResource")]
		public string ErrorIconUrl
		{
			get { return _ErrorIconUrl; }
			set { _ErrorIconUrl = value; }
		}
		private string _ErrorIconUrl = "WebResource";


		/// <summary>
		/// Determines whether the control uses client script to inject error 
		/// notification icons/messages into the page. Setting this flag to true causes
		///  JavaScript to be added to the page to create the messages. If false, the 
		/// DataBinder uses Controls.Add to add controls to the Page or other 
		/// Containers.
		/// 
		/// JavaScript injection is preferrable as it works reliable under all 
		/// environments except when JavaScript is off. Controls.Add() can have 
		/// problems if &lt;% %&gt; &lt;%= %&gt; script is used in a container that has
		///  an error and needs to add a control.
		/// <seealso>Class MTDataBinder</seealso>
		/// </summary>
		[Description("Uses Client Script code to inject Validation Error messages into the document. More reliable than Controls.Add() due to markup restrictions"),
		DefaultValue(true)]
		public bool UseClientScriptHtmlInjection
		{
			get { return _UseClientScriptHtmlInjection; }
			set { _UseClientScriptHtmlInjection = value; }
		}
		private bool _UseClientScriptHtmlInjection = true;

		bool _ClientScriptInjectionScriptAdded = false;

		/// <summary>
		/// Automatically imports all controls on the form that implement the IMTDataBinder interface and adds them to the DataBinder
		/// </summary>
		[Description("Automatically imports all controls on the form that implement the IMTDataBinder interface and adds them to the DataBinder"),
		 Browsable(true), DefaultValue(false)]
		public bool AutoLoadDataBoundControls
		{
			get { return _AutoLoadDataBoundControls; }
			set { _AutoLoadDataBoundControls = value; }
		}
		private bool _AutoLoadDataBoundControls = false;

		/// <summary>
		/// Flag that determines whether controls where auto-loaded from the page.
		/// </summary>
		private bool _AutoLoadedDataBoundControls = false;

		/// <summary>
		/// Determines whether this control works as an Extender object to other controls on the form.
		/// In some situations it might be useful to disable the extender functionality such
		/// as when all databinding is driven through code or when using the IMTDataBinder
		/// interface with custom designed controls that have their own DataBinder objects.
		/// </summary>
		[Browsable(true), Description("Determines whether this control works as an Extender object to other controls on the form"), DefaultValue(true)]
		public bool IsExtender
		{
			get { return _IsExtender; }
			set { _IsExtender = value; }
		}
		private bool _IsExtender = true;


		/// <summary>
		/// Event that can be hooked to validate each control after it's been unbound. 
		/// Allows for doing application level validation of the data once it's been 
		/// returned.
		/// 
		/// This method receives a MTDataBindingItem parameter which includes a 
		/// reference to both the control and the DataSource object where you can check
		///  values. Return false from the event method to indicate that validation 
		/// failed which causes a new BindingError to be created and added to the 
		/// BindingErrors collection.
		/// <seealso>Class MTDataBinder</seealso>
		/// </summary>
		/// <example>
		/// &lt;&lt;code lang=&quot;C#&quot;&gt;&gt;protected bool 
		/// DataBinder_ValidateControl(MsdnMag.Web.Controls.MTDataBindingItem Item)
		/// {
		///     if (Item.ControlInstance == this.txtCategoryId)
		///     {
		///         DropDownList List = Item.ControlInstance as DropDownList;
		///         if (List.SelectedItem.Text == &quot;Dairy Products&quot;)
		///         {
		///             Item.BindingErrorMessage = &quot;Dairy Properties not allowed 
		/// (ValidateControl)&quot;;
		///             return false;
		///         }
		///     }
		/// 
		///     return true;
		/// }&lt;&lt;/code&gt;&gt;
		/// </example>
		[Description("Fired after a control has been unbound. Gets passed an instance of the DataBinding item. Event must check for the control to check.")]
		public event delItemResultNotification ValidateControl;

		/// <summary>
		/// Fired just before the control is bound. You can return false from the 
		/// handler to cause the control to not be bound
		/// <seealso>Class MTDataBinder</seealso>
		/// </summary>
		[Description("Fires immediately before a control is bound. Fires for all controls and is passed a DataBindingItem.")]
		public event delItemResultNotification BeforeBindControl;

		/// <summary>
		/// Fires immediately after the control has been bound. You can check for
		/// errors or perform additional validation.
		/// </summary>
		[Description("Fires immediately after a control has been bound. Gets passed a DataBinding Item instance. Fires for all bound controls.")]
		public event delItemNotification AfterBindControl;

		/// <summary>
		/// Fires immediately before unbinding of a control takes place.
		/// You can return false to abort DataUnbinding.wl
		/// </summary>
		[Description("Fires immediately before a control is unbound. Gets passed a DataBinding Item instance. Fires for all bound controls.")]
		public event delItemResultNotification BeforeUnbindControl;

		/// <summary>
		/// Fires immediately after binding is complete. You can check for errors 
		/// and take additional action. 
		/// </summary>
		[Description("Fires immediately after a control has been unbound. Gets passed a DataBinding Item instance. Fires for all bound controls.")]
		public event delItemNotification AfterUnbindControl;


		/// <summary>
		/// Binds the controls that are attached to this DataBinder.
		/// </summary>
		/// <returns>true if there no errors. False otherwise.</returns>
		public new bool DataBind()
		{
			using (new HighResolutionTimer("DataBind", 10000))
			{
				return this.DataBind(this.Page);
			}
		}

		/// <summary>
		/// Binds data of the specified controls into the specified bindingsource
		/// </summary>
		/// <param name="Container">The top level container that is bound</param>
		public bool DataBind(Control Container)
		{
			if (AutoLoadDataBoundControls)
				LoadFromControls(Container);

			if (UseMinimalBinding)
				BoundValues.Clear();

			// Run through each item and bind it
			int end = DataBindingItems.Count;
			if (end > NumberOfControlsBeforeMultiThreaded)
			{
				// THREADED VERSION
				int mid = end / 2;

				DataBindParameters parameters1 = new DataBindParameters();
				parameters1.Container = Container;
				parameters1.start = 0;
				parameters1.end = mid;
				Thread t1 = new Thread(DataBindWithParameters);
				t1.CurrentCulture = Thread.CurrentThread.CurrentCulture;
				t1.CurrentUICulture = Thread.CurrentThread.CurrentUICulture;
				t1.Start(parameters1);

				DataBindParameters parameters2 = new DataBindParameters();
				parameters2.Container = Container;
				parameters2.start = mid;
				parameters2.end = end;
				Thread t2 = new Thread(DataBindWithParameters);
				t2.CurrentCulture = Thread.CurrentThread.CurrentCulture;
				t2.CurrentUICulture = Thread.CurrentThread.CurrentUICulture;
				t2.Start(parameters2);

				t1.Join();
				t2.Join();
			}
			else
			{
				// NON-THREADED VERSION
				DataBindParameters parameters = new DataBindParameters();
				parameters.Container = Container;
				parameters.start = 0;
				parameters.end = end;
				DataBindWithParameters(parameters);
			}

			return true;
		}

		internal class DataBindParameters
		{
			public Control Container;
			public int start;
			public int end;
		}

		public void DataBindWithParameters(object parameters)
		{
			DataBindParameters param = (DataBindParameters)parameters;

			for (int i = param.start; i < param.end; i++)
			{
				MTDataBindingItem Item = DataBindingItems[i];
				try
				{
					if (this.BeforeBindControl != null)
					{
						if (!this.BeforeBindControl(Item))
							continue;
					}

					// *** Here's where all the work happens
					Item.DataBind(param.Container);

					// If we are using minimal binding then we get the value in the control and add it to our list of bound values.
					// We use this list to know if we should set the value in the object on unbind.  If the values are the same, we
					// will not unbind, so the object will not be dirty.
					if (UseMinimalBinding)
					{

						Control ActiveControl = null;
						if (Item.ControlInstance != null)
							ActiveControl = Item.ControlInstance;
						else
						{
							//single-level ControlID
							if (Item.ControlId.IndexOf(".") < 0)
							{
								ActiveControl = WebUtils.FindControlRecursive(param.Container, Item.ControlId);
							}
						}

						var val = Utils.GetProperty(ActiveControl, Item.BindingProperty);
						BoundValues.Add(Item.BindingSource + Item.BindingSourceMember, val.ToString());
					}

				}
				// *** Binding errors fire into here
				catch (Exception ex)
				{
					logger.LogException("You should fix the invalid binding for " + Item.BindingProperty, ex);
					this.HandleUnbindingError(Item, ex);
				}

				if (this.AfterBindControl != null)
					this.AfterBindControl(Item);
			}
		}

		/// <summary>
		/// Unbind the controls back into their underlying binding sources. Returns true on success
		/// false on failure. On failure the BindingErrors collection will be set
		/// </summary>
		/// <returns>True if there are no errors. False if unbinding failed. Check the BindingErrors for errors.</returns>
		public bool Unbind()
		{
			return this.Unbind(this.Page);
		}

		/// <summary>
		/// Unbind the controls back into their binding source. Returns true on success
		/// false on failure. On failure the BindingErrors collection will be set
		/// </summary>
		/// <param name="Container">The top level container Control that is bound.</param>
		/// <returns>True if there are no errors. False if unbinding failed. Check the BindingErrors for errors.</returns>
		public bool Unbind(Control Container)
		{
			if (this.AutoLoadDataBoundControls)
				this.LoadFromControls(Container);

			bool ResultFlag = true;

			// *** Loop through all bound items and unbind them
			foreach (MTDataBindingItem Item in this.DataBindingItems)
			{
				try
				{
					if (this.BeforeUnbindControl != null)
					{
						if (!this.BeforeUnbindControl(Item))
							continue;
					}

					// *** here's where all the work happens!
					Item.Unbind(Container);

					// *** Run any validation logic - DataBinder Global first
					if (!OnValidateControl(Item))
						this.HandleUnbindingError(Item, new ValidationErrorException(Item.BindingErrorMessage));

					// *** Run control specific validation
					if (!Item.OnValidate())
						this.HandleUnbindingError(Item, new ValidationErrorException(Item.BindingErrorMessage));
				}
				// *** Handles any unbinding errors
				catch (Exception ex)
				{
					this.HandleUnbindingError(Item, ex);
					ResultFlag = false;
				}

				// *** Notify that we're done unbinding
				if (this.AfterUnbindControl != null)
					this.AfterUnbindControl(Item);
			}

			// *** Add existing validators to the BindingErrors
			foreach (IValidator Validator in this.Page.Validators)
			{
				if (Validator.IsValid)
					continue;

				string ClientId = null;

				BaseValidator BValidator = Validator as BaseValidator;
				if (BValidator != null)
				{
					Control Ctl = WebUtils.FindControlRecursive(this.Page, BValidator.ControlToValidate);
					if (Ctl != null)
						ClientId = Ctl.ClientID;
				}
				this.BindingErrors.Add(new BindingError(Validator.ErrorMessage, ClientId));
			}

			return ResultFlag;
		}

		/// <summary>
		/// Manages errors that occur during unbinding. Sets BindingErrors collection and
		/// and writes out validation error display to the page if specified
		/// </summary>
		/// <param name="Item"></param>
		/// <param name="ex"></param>
		private void HandleUnbindingError(MTDataBindingItem Item, Exception ex)
		{
			Item.IsBindingError = true;

			// *** Display Error info by setting BindingErrorMessage property
			try
			{
				string ErrorMessage = null;

				// *** Must check that the control exists - if invalid ID was
				// *** passed there may not be an instance!
				if (Item.ControlInstance == null)
					ErrorMessage = "Invalid Control: " + Item.ControlId;
				else
				{
					string DerivedUserFieldName = this.DeriveUserFieldName(Item);
					if (ex is RequiredFieldException)
					{
						ErrorMessage = DerivedUserFieldName + " can't be left empty";
					}
					else if (ex is ValidationErrorException)
					{
						// *** Binding Error Message will be set
						ErrorMessage = ex.Message;
					}
					// *** Explicit error message returned
					else if (ex is BindingErrorException)
					{
						//SECENG: CORE-4828 CLONE - BSS 29003 Security - CAT .NET - Information Disclosure through Exception Information (SecEx)
						// hidding sensitive info from end user and putting it into the log for admins
						//ErrorMessage = ex.Message + " for " + DerivedUserFieldName;
						ErrorMessage = "Binding error for " + DerivedUserFieldName;
						logger.LogException(ErrorMessage, ex);
					}
					else
					{
						if (string.IsNullOrEmpty(Item.BindingErrorMessage))
							ErrorMessage = "Invalid format for " + DerivedUserFieldName;
						else
							// *** Control has a pre-assigned error message
							ErrorMessage = Item.BindingErrorMessage;
					}
				}
				this.AddBindingError(ErrorMessage, Item);
			}
			catch (Exception)
			{
				this.AddBindingError("Binding Error", Item);
			}
		}

		/// <summary>
		/// Adds a binding to the control. This method is a simple
		/// way to establish a binding.
		/// 
		/// Returns the Item so you can customize properties further
		/// </summary>
		/// <param name="ControlToBind"></param>
		/// <param name="ControlPropertyToBind"></param>
		/// <param name="SourceObjectToBindTo"></param>
		/// <param name="SourceMemberToBindTo"></param>
		public MTDataBindingItem AddBinding(Control ControlToBind, string ControlPropertyToBind,
						  object SourceObjectToBindTo, string SourceMemberToBindTo)
		{
			MTDataBindingItem Item = new MTDataBindingItem(this);

			Item.ControlInstance = ControlToBind;
			Item.ControlId = ControlToBind.ID;
			Item.BindingSourceObject = SourceObjectToBindTo;
			Item.BindingSourceMember = SourceMemberToBindTo;

			this.DataBindingItems.Add(Item);

			return Item;
		}

		/// <summary>
		/// Adds a binding to the control. This method is a simple
		/// way to establish a binding.
		/// 
		/// Returns the Item so you can customize properties further
		/// </summary>
		/// <param name="ControlToBind"></param>
		/// <param name="ControlPropertyToBind"></param>
		/// <param name="SourceObjectNameToBindTo"></param>
		/// <param name="SourceMemberToBindTo"></param>
		/// <returns></returns>
		public MTDataBindingItem AddBinding(Control ControlToBind, string ControlPropertyToBind,
						  string SourceObjectNameToBindTo, string SourceMemberToBindTo)
		{
			MTDataBindingItem Item = new MTDataBindingItem(this);

			Item.ControlInstance = ControlToBind;
			Item.ControlId = ControlToBind.ID;
			Item.Page = this.Page;
			Item.BindingSource = SourceObjectNameToBindTo;
			Item.BindingSourceMember = SourceMemberToBindTo;

			this.DataBindingItems.Add(Item);

			return Item;
		}

		/// <summary>
		/// This method only adds a data binding item, but doesn't bind it
		/// to anything. This can be useful for only displaying errors
		/// </summary>
		/// <param name="ControlToBind"></param>
		/// <returns></returns>
		public MTDataBindingItem AddBinding(Control ControlToBind)
		{
			MTDataBindingItem Item = new MTDataBindingItem(this);

			Item.ControlInstance = ControlToBind;
			Item.ControlId = ControlToBind.ID;
			Item.Page = this.Page;

			this.DataBindingItems.Add(Item);

			return Item;
		}

		/// <summary>
		/// Adds a binding error message to a specific control attached to this binder
		/// BindingErrors collection.
		/// </summary>
		/// <param name="ControlName">Form relative Name (ID) of the control to set the error on</param>
		/// <param name="ErrorMessage">The Error Message to set it to.</param>
		/// <returns>true if the control was found. False if not found, but message is still assigned</returns>
		public bool AddBindingError(string ErrorMessage, string ControlName)
		{
			MTDataBindingItem DataBindingItem = null;

			foreach (MTDataBindingItem Ctl in this.DataBindingItems)
			{
				if (Ctl.ControlId == ControlName)
				{
					DataBindingItem = Ctl;
					break;
				}
			}

			if (DataBindingItem == null)
			{
				this.BindingErrors.Add(new BindingError(ErrorMessage));
				return false;
			}

			return this.AddBindingError(ErrorMessage, DataBindingItem);
		}

		/// <summary>
		/// Adds a binding error to the collection of binding errors.
		/// </summary>
		/// <param name="ErrorMessage"></param>
		/// <param name="Control"></param>
		/// <returns>false if the control was not able to get a control reference to attach hotlinks and an icon. Error message always gets added</returns>
		public bool AddBindingError(string ErrorMessage, Control Control)
		{
			MTDataBindingItem DataBindingItem = null;

			if (Control == null)
			{
				this.BindingErrors.Add(new BindingError(ErrorMessage));
				return false;
			}


			foreach (MTDataBindingItem Ctl in this.DataBindingItems)
			{
				if (Ctl.ControlId == Control.ID)
				{
					Ctl.ControlInstance = Control;
					DataBindingItem = Ctl;
					break;
				}
			}

			// *** No associated control found - just add the error message
			if (DataBindingItem == null)
			{
				this.BindingErrors.Add(new BindingError(ErrorMessage, Control.ClientID));
				return false;
			}

			return this.AddBindingError(ErrorMessage, DataBindingItem);
		}

		/// <summary>
		/// Adds a binding error for DataBindingItem control. This is the most efficient
		/// way to add a BindingError. The other overloads call into this method after
		/// looking up the Control in the DataBinder.
		/// </summary>
		/// <param name="ErrorMessage"></param>
		/// <param name="BindingItem"></param>
		/// <returns></returns>
		public bool AddBindingError(string ErrorMessage, MTDataBindingItem BindingItem)
		{

			// *** Associated control found - add icon and link id
			if (BindingItem.ControlInstance != null)
				this.BindingErrors.Add(new BindingError(ErrorMessage, BindingItem.ControlInstance.ClientID));
			else
			{
				// *** Just set the error message
				this.BindingErrors.Add(new BindingError(ErrorMessage));
				return false;
			}

			BindingItem.BindingErrorMessage = ErrorMessage;

			// *** Insert the error text/icon as a literal
			if (this.ShowBindingErrorsOnControls && BindingItem.ControlInstance != null)
			{
				// *** Retrieve the Html Markup for the error
				// *** NOTE: If script code injection is enabled this is done with client
				// ***       script code to avoid Controls.Add() functionality which may not
				// ***       always work reliably if <%= %> tags are in document. Script HTML injection
				// ***       is the preferred behavior as it should work on any page. If script is used
				// ***       the message returned is blank and the startup script is embedded instead
				string HtmlMarkup = this.GetBindingErrorMessageHtml(BindingItem);

				if (!string.IsNullOrEmpty(HtmlMarkup))
				{
					LiteralControl Literal = new LiteralControl();
					Control Parent = BindingItem.ControlInstance.Parent;

					int CtlIdx = Parent.Controls.IndexOf(BindingItem.ControlInstance);
					try
					{
						// *** Can't add controls to the Control collection if <%= %> tags are on the page
						Parent.Controls.AddAt(CtlIdx + 1, Literal);
					}
					catch { ; }
				}
			}

			return true;
		}

#if USE_WWBUSINESS
		/// <summary>
		/// Takes a collection of ValidationErrors and assigns it to the
		/// matching controls. These controls must match in signature as follows:
		/// Must have the same name as the field and a 3 letter prefix. For example,
		/// 
		/// txtCompany - matches company field
		/// cmbCountry - matches the Country field
		/// </summary>
		/// <returns></returns>
		public void AddValidationErrorsToBindingErrors(Westwind.BusinessObjects.ValidationErrorCollection Errors) 
		{
			foreach (Westwind.BusinessObjects.ValidationError Error in Errors) 
			{
                Control ctl = WebUtils.FindControlRecursive(this.Page.Form,Error.ControlID);
                this.AddBindingError(Error.Message,ctl);        
			}
		}
#endif


		/// <summary>
		/// Picks up all controls on the form that implement the IMTDataBinder interface
		/// and adds them to the DataBindingItems Collection
		/// </summary>
		/// <param name="Container"></param>
		/// <returns></returns>
		public void LoadFromControls(Control Container)
		{
			// *** Only allow loading of controls implicitly once
			if (this._AutoLoadedDataBoundControls)
				return;
			this._AutoLoadedDataBoundControls = true;

			LoadDataBoundControls(Container);
		}

		/// <summary>
		/// Loop through all of the contained controls of the form and
		/// check for all that implement IMTDataBinder. If found
		/// add the BindingItem to this Databinder
		/// </summary>
		/// <param name="Container"></param>
		private void LoadDataBoundControls(Control Container)
		{
			foreach (Control Ctl in Container.Controls)
			{
				// ** Recursively call down into any containers
				if (Ctl.Controls.Count > 0)
					this.LoadDataBoundControls(Ctl);

				//KAB  if (Ctl is IMTDataBinder)
				//     this.DataBindingItems.Add(((IMTDataBinder)Ctl).BindingItem);
			}
		}

		/// <summary>
		/// Returns a UserField name. Returns UserFieldname if set, or if not
		/// attempts to derive the name based on the field.
		/// </summary>
		/// <param name="Item"></param>
		/// <returns></returns>
		protected string DeriveUserFieldName(MTDataBindingItem Item)
		{
			if (!string.IsNullOrEmpty(Item.UserFieldName))
				return Item.UserFieldName;

			string ControlID = Item.ControlInstance.ID;

			// *** Try to get a name by stripping of control prefixes
			string ControlName = Regex.Replace(Item.ControlInstance.ID, "^txt|^chk|^lst|^rad|", "", RegexOptions.IgnoreCase);
			if (ControlName != ControlID)
				return ControlName;

			// *** Nope - use the default ID
			return ControlID;
		}


		/// <summary>
		/// Creates the text for binding error messages based on the 
		/// BindingErrorMessage property of a data bound control.
		/// 
		/// If set the control calls this method render the error message. Called by 
		/// the various controls to generate the error HTML based on the <see>Enum 
		/// ErrorMessageLocations</see>.
		/// 
		/// If UseClientScriptHtmlInjection is set the error message is injected
		/// purely through a client script JavaScript function which avoids problems
		/// with Controls.Add() when script tags are present in the container.
		/// <seealso>Class wwWebDataHelper</seealso>
		/// </summary>
		/// <param name="Item">Instance of the control that has an error.</param>
		/// <returns>String</returns>
		internal string GetBindingErrorMessageHtml(MTDataBindingItem Item)
		{
			string Image = null;
			if (string.IsNullOrEmpty(this.ErrorIconUrl) || this.ErrorIconUrl == "WebResource")
				Image = @"/Res/images/icons/error.png";
			else
				Image = this.ResolveUrl(this.ErrorIconUrl);

			string Message = "";

			if (Item.ErrorMessageLocation == BindingErrorMessageLocations.WarningIconRight)
				Message = string.Format("&nbsp;<img src=\"{0}\" alt=\"{1}\" />", Image, Item.BindingErrorMessage);
			else if (Item.ErrorMessageLocation == BindingErrorMessageLocations.RedTextBelow)
				Message = "<br /><span style=\"color:red;\"><smaller>" + Item.BindingErrorMessage + "</smaller></span>";
			else if (Item.ErrorMessageLocation == BindingErrorMessageLocations.RedTextAndIconBelow)
				Message = string.Format("<br /><img src=\"{0}\"> <span style=\"color:red;\" /><smaller>{1}</smaller></span>", Image, Item.BindingErrorMessage);
			else if (Item.ErrorMessageLocation == BindingErrorMessageLocations.None)
				Message = "";
			else
				Message = "<span style='color:red;font-weight:bold;'> * </span>";

			// *** Fix up message so ' are allowed
			Message = Message.Replace("'", @"\'");


			// *** Use Client Side JavaScript to inject the message rather than adding a control
			if (this.UseClientScriptHtmlInjection && Item.ControlInstance != null)
			{
				if (!this._ClientScriptInjectionScriptAdded)
					this.AddScriptForAddHtmlAfterControl();

				this.Page.ClientScript.RegisterStartupScript(this.GetType(), Item.ControlId,
					string.Format("AddHtmlAfterControl('{0}','{1}');\r\n", Item.ControlInstance.ClientID, Message), true);

				// *** Message is handled in script so nothing else to write
				Message = "";
			}


			// *** Message will be embedded with a Literal Control
			return Message;
		}

		/// <summary>
		/// This method adds the static script to handle injecting the warning icon/messages 
		/// into the page as literal strings.
		/// </summary>
		private void AddScriptForAddHtmlAfterControl()
		{
			this.Page.ClientScript.RegisterClientScriptBlock(this.GetType(), "AddHtmlAfterControl",
		 @"function AddHtmlAfterControl(ControlId,HtmlMarkup)
{
var Ctl = document.getElementById(ControlId);
if (Ctl == null)
 return;
 
var Insert = document.createElement('span');
Insert.innerHTML = HtmlMarkup;

var Sibling = Ctl.nextSibling;
if (Sibling != null)
 Ctl.parentNode.insertBefore(Insert,Sibling);
else
 Ctl.parentNode.appendChild(Insert);
}", true);

		}

		/// <summary>
		/// Fires the ValidateControlEvent
		/// </summary>
		/// <param name="Item"></param>
		/// <returns>false - Validation for control failed and a BindingError is added, true - Validation succeeded</returns>
		public bool OnValidateControl(MTDataBindingItem Item)
		{
			if (this.ValidateControl != null && !this.ValidateControl(Item))
				return false;

			return true;
		}

		#region IExtenderProvider Members

		/// <summary>
		/// Determines whether a control can be extended. Basically
		/// we allow ANYTHING to be extended so all controls except
		/// the databinder itself are extendable.
		/// 
		/// Optionally the control can be set up to not act as 
		/// an extender in which case the IsExtender property 
		/// can be set to false
		/// </summary>
		/// <param name="extendee"></param>
		/// <returns></returns>
		public bool CanExtend(object extendee)
		{
			if (!this.IsExtender)
				return false;

			// *** Don't extend ourself <g>
			if (extendee is MTDataBinder)
				return false;

			if (extendee is Control)
				return true;

			return false;
		}

		/// <summary>
		/// Returns a specific DataBinding Item for a given control.
		/// Always returns an item even if the Control is not found.
		/// If you need to check whether this is a valid item check
		/// the BindingSource property for being blank.
		/// 
		/// Extender Property Get method
		/// </summary>
		/// <param name="control"></param>
		/// <returns></returns>
		public MTDataBindingItem GetDataBindingItem(Control control)
		{

			foreach (MTDataBindingItem Item in this.DataBindingItems)
			{
				if (Item.ControlId == control.ID)
				{
					// *** Ensure the binder is set on the item
					Item.Binder = this;
					return Item;
				}
			}

			MTDataBindingItem NewItem = new MTDataBindingItem(this);
			NewItem.ControlId = control.ID;
			NewItem.ControlInstance = control;

			this.DataBindingItems.Add(NewItem);

			return NewItem;
		}

		/// <summary>
		/// Return a specific databinding item for a give control id.
		/// Note unlike the ControlInstance version return null if the
		/// ControlId isn't found. 
		/// </summary>
		/// <param name="ControlId"></param>
		/// <returns></returns>
		public MTDataBindingItem GetDataBindingItem(string ControlId)
		{
			for (int i = 0; i < this.DataBindingItems.Count; i++)
			{
				if (this.DataBindingItems[i].ControlId == ControlId)
					return this.DataBindingItems[i];
			}

			return null;
		}

		// <summary>
		// This is never fired in ASP.NET runtime code
		// </summary>
		// <param name="extendee"></param>
		// <param name="Item"></param>
		//public void SetDataBindingItem(object extendee, object Item)
		//{
		//   MTDataBindingItem BindingItem = Item as MTDataBindingItem;
		//    Control Ctl = extendee as Control;
		//    HttpContext.Current.Response.Write("SetDataBindingItem fired " + BindingItem.ControlId);
		//}

		/// <summary>
		/// this method is used to ensure that designer is notified
		/// every time there is a change in the sub-ordinate validators
		/// </summary>
		internal void NotifyDesigner()
		{
			if (this.DesignMode)
			{
				IDesignerHost Host = this.Site.Container as IDesignerHost;
				ControlDesigner Designer = Host.GetDesigner(this) as ControlDesigner;
				PropertyDescriptor Descriptor = null;
				try
				{
					Descriptor = TypeDescriptor.GetProperties(this)["DataBindingItems"];
				}
				catch
				{
					return;
				}

				ComponentChangedEventArgs ccea = new ComponentChangedEventArgs(
							this,
							Descriptor,
							null,
							this.DataBindingItems);
				Designer.OnComponentChanged(this, ccea);
			}
		}


		#endregion
	}

	public delegate bool delItemResultNotification(MTDataBindingItem Item);

	public delegate void delItemNotification(MTDataBindingItem Item);

	public delegate void delDataBindingItemValidate(object sender, DataBindingValidationEventArgs e);


	/// <summary>
	/// Control designer used so we get a grey button display instead of the 
	/// default label display for the control.
	/// </summary>
	internal class MTDataBinderDesigner : ControlDesigner
	{
		private DesignerActionListCollection mLists;
		public override DesignerActionListCollection ActionLists
		{
			get
			{
				if (mLists == null)
				{
					mLists = new DesignerActionListCollection();
					mLists.Add(new MTDataBinderActionList(this.Component));
				}
				return mLists;
			}
		}

		public override string GetDesignTimeHtml()
		{
			return base.CreatePlaceHolderDesignTimeHtml("MetraTech Control Extender");
		}
	}

	/// <summary>
	/// DataBinderActionList ovverides the GetSortedActionItems to 
	/// setup the smart tag in the designer.
	/// </summary>
	internal class MTDataBinderActionList : System.ComponentModel.Design.DesignerActionList
	{
		private DesignerActionUIService mDesignerActionSvc = null;
		private MTDataBinder mDataBinder = null;

		public List<MetaDataItem> MetaDataMappings
		{
			get { return mDataBinder.MetaDataMappings; }
			//set { SetProperty("MetaDataMappings", value); }
		}

		public MTDataBinderActionList(IComponent component)
			: base(component)
		{
			mDataBinder = component as MTDataBinder;
			mDesignerActionSvc = ((DesignerActionUIService)(GetService(typeof(DesignerActionUIService))));

			// Automatically display smart tag panel when
			// design-time component is dropped onto the designer
			this.AutoShow = true;
		}

		// Helper method to safely set a component’s property
		private void SetProperty(string propertyName, object value)
		{
			// Get property
			PropertyDescriptor property = TypeDescriptor.GetProperties(mDataBinder)[propertyName];

			// Set property value
			property.SetValue(mDataBinder, value);
		}

		// Helper method to return the Category string from a
		// CategoryAttribute assigned to a property exposed by 
		// the specified object
		private string GetCategory(object source, string propertyName)
		{
			PropertyInfo property = source.GetType().GetProperty(propertyName);
			CategoryAttribute attribute = (CategoryAttribute)property.GetCustomAttributes(typeof(CategoryAttribute), false)[0];
			if (attribute == null) return null;
			return attribute.Category;
		}

		// Helper method to return the Description string from a
		// DescriptionAttribute assigned to a property exposed by 
		// the specified object
		private string GetDescription(object source, string propertyName)
		{
			PropertyInfo property = source.GetType().GetProperty(propertyName);
			DescriptionAttribute attribute = (DescriptionAttribute)property.GetCustomAttributes(typeof(DescriptionAttribute), false)[0];
			if (attribute == null) return null;
			return attribute.Description;
		}

		// LaunchICE designer action method implementation
		public void LaunchICE()
		{
			try
			{
				// Check if ICE is installed
				string iceDir = null;
				RegistryKey hive = Registry.LocalMachine;
				RegistryKey mtkey = hive.OpenSubKey(@"SOFTWARE\MetraTech\ICE");
				if (mtkey != null)
				{
					iceDir = (string)mtkey.GetValue("InstallDir");
				}
				else
				{
					System.Windows.Forms.MessageBox.Show("ICE doesn't seem to be installed.");
					return;
				}

				Process p = new Process();
				string filename = iceDir + "bin\\" + "MetraTech.ICE.exe";
				string args = "";
				if (MetaDataMappings != null)
				{
					if (MetaDataMappings.Count > 0)
					{
						if (MetaDataMappings.Count == 1)
						{
							// Only one alias, so just open it
							if (MetaDataMappings[0] != null)
							{
								args = "/action:open /type:" + MetaDataMappings[0].MetaType.ToString() + " /name:" + MetaDataMappings[0].Value + " /config:LocalMetranetInstallation";
							}
						}
						else
						{
							// More than one alias, so ask the user which configuration to open
							frmSelectMetaData form = new frmSelectMetaData();
							foreach (MetaDataItem itm in MetaDataMappings)
							{
								form.ddAlias.Items.Add(itm.Alias);
							}

							// if OK button is pressed
							if (form.ShowDialog() == System.Windows.Forms.DialogResult.OK)
							{
								foreach (MetaDataItem itm2 in MetaDataMappings)
								{
									if (form.ddAlias.SelectedItem.ToString().Equals(itm2.Alias))
									{
										args = "/action:open /type:" + itm2.MetaType.ToString() + " /name:" + itm2.Value + " /config:LocalMetranetInstallation";
									}
								}
							}
							else
							{
								return;
							}
						}
					}
				}

				p.StartInfo.FileName = filename;
				p.StartInfo.Arguments = args;
				p.Start();
			}
			catch (Exception exp)
			{
				System.Windows.Forms.MessageBox.Show("Error launching ICE: " + exp.ToString());
			}

			/*
			// Create form
			Xceed.Grid.Licenser.LicenseKey = "GRD32-Y57KX-BWX4N-XNAA";
			frmDataBindings form = new frmDataBindings();
			form.ServiceDefinition = mDataBinder.ServiceDefinition;
			form.Mappings = mDataBinder.mMappings;

			// Update values if OK button is pressed
			if (form.ShowDialog() == System.Windows.Forms.DialogResult.OK)
			{
			  string bindings = "";
			  foreach (ControlMapping cm in form.Mappings.Values)
			  {
				bindings += cm.ID + "|" + cm.ControlType + "=" + cm.ServiceDefProperty + ";";
			  }
			  ControlBindings = bindings;
			}
			 * */
		}

		/// <summary>
		/// Adds the list of items
		/// </summary>
		/// <returns></returns>
		public override DesignerActionItemCollection GetSortedActionItems()
		{
			DesignerActionItemCollection items = new DesignerActionItemCollection();

			// Service def designer action method item
			items.Add(new DesignerActionMethodItem(this, "LaunchICE",
					  "Launch ICE", "MetaData", "Launch the Integrated Configuration Environment.", true));

			return items;
		}
	}

}
