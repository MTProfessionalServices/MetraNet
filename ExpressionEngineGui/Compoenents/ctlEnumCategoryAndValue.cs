using System;
using System.Windows.Forms;
using MetraTech.ExpressionEngine.Components;

namespace PropertyGui.Compoenents
{
    public partial class ctlEnumCategoryAndValue : UserControl
    {
        #region Properties
        public string EnumCategory
        {
            get { return ctlEnumCategory.Text; } 
            set { ctlEnumCategory.Text = value; }
        }
        public bool ShowItems
        {
            get { return ctlEnumCategory.ShowItems; } 
            set { ctlEnumCategory.ShowItems = value; }
        }
        public bool ShowUnitsOfMeasure {
            get { return ctlEnumCategory.ShowUnitsOfMeasure; }
            set { ctlEnumCategory.ShowUnitsOfMeasure = value; }
        }
        public bool ShowCurrency {
            get { return ctlEnumCategory.ShowCurrency; }
            set { ctlEnumCategory.ShowCurrency = value; }
        }
        public string EnumItem
        {
            get { return cboEnumItem.Text; }
            set { cboEnumItem.Text = value; }
        }
        public string EnumFullName { get { return EnumCategory + "." + EnumItem; } }

        #endregion

        #region Constructor
        public ctlEnumCategoryAndValue()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public void Init(EnumManager enumManager)
        {
            ctlEnumCategory.Init(enumManager);
        }

        public void SetItemComboBoxVisibility(bool isVisible)
        {
            if (isVisible)
                Height = cboEnumItem.Bottom;
            else
                Height = ctlEnumCategory.Bottom;
        }

        #endregion

        #region Events
        private void cboEnumItem_DropDown(object sender, EventArgs e)
        {
            var enumCategory = ctlEnumCategory.GetEnumCategory();

            cboEnumItem.BeginUpdate();
            cboEnumItem.Items.Clear();
            cboEnumItem.DisplayMember = "Name";
            if (enumCategory != null)
            {
                foreach (var item in enumCategory.Items)
                {
                    cboEnumItem.Items.Add(item.Name);
                }
            }

            cboEnumItem.EndUpdate();
        }
        #endregion
    }
}
