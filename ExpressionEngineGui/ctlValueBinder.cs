using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Data;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.MTProperties.Enumerations;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace PropertyGui
{
    public partial class ctlValueBinder : UserControl
    {
        #region Enums
        public enum BindingTypeEnum { Property, Constant, Expression }
        #endregion

        #region Properties
        public bool AllowProperty { get; set; }
        public bool AllowConstant { get; set; }
        public bool AllowExpression { get; set; }
        public bool ShowBinderIcon { get; set; }
        public BindingTypeEnum DefaultBindingType { get; set; }
        public MatchType MinimumMatchType { get; set; }
        public override string Text { get { return GetText(); } set { SetText(value); } }
        
        /// <summary>
        /// Returns the selected item. Only works for combobox editors
        /// </summary>
        public object SelectedItem { get 
        {
            if (Control is ComboBox)
                return ((ComboBox)Control).SelectedItem;
            else
                return null;
        }
        }

        private Context Context;
        private Property Property;
        private BindingTypeEnum BindingType;
        private Control Control;
        #endregion

        #region Constructor
        public ctlValueBinder()
        {
            InitializeComponent();
            Height = 50;
            Width = 200;

            AllowProperty = true;
            AllowConstant = true;
            AllowExpression = true;
            ShowBinderIcon = true;
            DefaultBindingType = BindingTypeEnum.Property;
            MinimumMatchType = MatchType.Convertible;

            mnuBindingType.ImageList = ctlExpressionTree.Images;
            InitMenu(mnuPropertyBinding, "PropertyBinding.png", BindingTypeEnum.Property);
            InitMenu(mnuConstant, "ConstantBinding.png", BindingTypeEnum.Constant);
            InitMenu(mnuExpression, "ExpressionBinding.png", BindingTypeEnum.Expression);
        }

        private void InitMenu(ToolStripMenuItem menu, string imageName, BindingTypeEnum bindingType)
        {
            menu.ImageKey = imageName;
            menu.Tag = bindingType;
        }

        #endregion

        #region Delegates
        public delegate void GotMyFocus(Property property);
        public GotMyFocus OnGotMyFocus;
        public delegate void MyChange();
        public MyChange OnMyChange;
        #endregion

        #region Methods

        public void Init(Context context, Property property)
        {
            Context = context;
            Property = property;

            //Need to figure this out from parsing in future, for now hardcode!
            BindingType = DefaultBindingType;
            SetBinder();
        }

        private void SetBinder()
        {
            if (Control != null)
                Control.Dispose();

            if (BindingType == BindingTypeEnum.Expression)
                Control = new TextBox();
            else if (BindingType == BindingTypeEnum.Property)
                Control = CreatePropertyComboBox();
            else
            {
                switch (Property.Type.BaseType)
                {
                    case BaseType.DateTime:
                        Control = new DateTimePicker();
                        break;
                    case BaseType.Boolean:
                        Control = CreateBooleanComboBox();
                        break;
                    case BaseType.Enumeration:
                        Control = CreateEnumComboBox((EnumerationType)Property.Type);
                        break;
                    default:
                        Control = new TextBox();
                        break;
                }
            }

            Control.Parent = this;
            Control.Top = 0;
            if (ShowBinderIcon)
            {
                Control.Left = pctArrow.Right + 3;
                Control.Width = Width - Control.Left;
            }
            else
            {
                Control.Left = 0;
                Control.Width = Width;
                Control.BringToFront();
            }
            Control.Anchor = AnchorStyles.Left | AnchorStyles.Right | AnchorStyles.Top;
            Control.GotFocus += new EventHandler(Control_GotFocus);
            Control.TextChanged += new EventHandler(Control_TextChanged);
            if (Control is ComboBox)
                ((ComboBox)Control).SelectedValueChanged += new EventHandler(Control_TextChanged);

            if (Property.Direction == Direction.Output)
                Control.BackColor = Color.LightGreen;

            SetBindingTypeImage();
        }

        private void SetBindingTypeImage()
        {
            string imageName;
            switch (BindingType)
            {
                case BindingTypeEnum.Constant:
                    imageName = "ConstantBinding.png";
                    break;
                case BindingTypeEnum.Expression:
                    imageName = "ExpressionBinding.png";
                    break;
                case BindingTypeEnum.Property:
                    imageName = "PropertyBinding.png";
                    break;
                default:
                    throw new NotImplementedException();
            }
            pctBindingType.Image = ctlExpressionTree.Images.Images[imageName];
        }

        private ComboBox CreatePropertyComboBox()
        {
            var cbo = new ComboBox();
            cbo.BeginUpdate();
            cbo.Items.Clear();
            cbo.DisplayMember = "ToExpressionSnippet";
            var properties = Context.GetProperties(Property.Type, MinimumMatchType, true);
            foreach (var property in properties)
            {
                cbo.Items.Add(property);
            }
            cbo.EndUpdate();
            return cbo;
        }

        private ComboBox CreateEnumComboBox(EnumerationType type)
        {
            var cbo = new ComboBox();
            cbo.BeginUpdate();
            cbo.DropDownStyle = ComboBoxStyle.DropDownList;
            cbo.DisplayMember = "Name";
            EnumCategory enumType;
            if (Context.TryGetEnumType(type, out enumType))
            {
                cbo.Items.AddRange(enumType.Values.ToArray());
            }

            cbo.EndUpdate();
            return cbo;
        }


        private ComboBox CreateBooleanComboBox()
        {
            var cbo = new ComboBox();
            cbo.BeginUpdate();
            cbo.DropDownStyle = ComboBoxStyle.DropDownList;
            cbo.Items.Add("False");
            cbo.Items.Add("True");
            cbo.EndUpdate();
            return cbo;
        }

        private string GetText()
        {
            if (Control is TextBox)
                return ((TextBox)Control).Text;
            else if (Control is ComboBox)
                return ((ComboBox)Control).Text;
            else if (Control is DateTimePicker)
                return ((DateTimePicker)Control).Text;

            throw new NotImplementedException();
        }

        private void SetText(string text)
        {
            if (Control is TextBox)
                ((TextBox)Control).Text = text;
            else if (Control is ComboBox)
                ((ComboBox)Control).Text = text;
            else if (Control is DateTimePicker)
                ((DateTimePicker)Control).Text = text;
            else
                throw new NotImplementedException();
        }
        public void SetFocus()
        {
            Control.Focus();
        }

        public void SyncToForm()
        {
            if (Property is Property)
                Text = ((Property)Property).Value;
        }

        public void SyncToObject()
        {
            if (Property is Property)
                ((Property)Property).Value = Text;
        }

        public void SetDefaultValue()
        {
            if (Property is Property)
                ((Property)Property).Value = ((Property)Property).DefaultValue;
        }
        #endregion

        #region Value Events

        void Control_GotFocus(object sender, EventArgs e)
        {
            if (OnGotMyFocus != null)
                OnGotMyFocus(Property);
        }

        void Control_TextChanged(object sender, EventArgs e)
        {
            if (OnMyChange != null)
                OnMyChange();
        }

        #endregion

        #region Type Events
        private void pctArrow_Click(object sender, EventArgs e)
        {
            mnuBindingType.Show(pctBindingType, 0, pctBindingType.Height);
        }

        private void mnuPropertyBinding_Click(object sender, EventArgs e)
        {
            BindingType = (BindingTypeEnum)((ToolStripMenuItem)sender).Tag;
            SetBinder();
        }

        private void mnuBindingType_Opening(object sender, CancelEventArgs e)
        {
            mnuPropertyBinding.Enabled = (BindingType != BindingTypeEnum.Property) && AllowProperty;
            mnuConstant.Enabled = (BindingType != BindingTypeEnum.Constant) && AllowConstant;
            mnuExpression.Enabled = (BindingType != BindingTypeEnum.Expression) && AllowExpression;
        }
        #endregion
    }
}
