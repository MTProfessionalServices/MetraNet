using System;
using System.Collections.Generic;
using System.Windows.Forms;
using MetraTech.ExpressionEngine.Components;

namespace PropertyGui.Compoenents
{
    public partial class ctlEnumCategory : UserControl
    {
        #region Properties
        public bool ShowItems { get; set; }
        public bool ShowUnitsOfMeasure { get; set; }
        public bool ShowCurrency { get; set; }
        public string Text { get { return txtValue.Text; } set { txtValue.Text = value; } }
        private EnumManager EnumManager;
        #endregion

        #region Contructor
        public ctlEnumCategory()
        {
            InitializeComponent();
            Height = cboCatogories.Height;
            txtValue.Height = Height;
            ShowItems = true;
            ShowUnitsOfMeasure = true;
            ShowCurrency = true;
        }
        #endregion

        #region Methods
        public void Init(EnumManager enumManager)
        {
            if (enumManager == null)
                throw new ArgumentException("enumManager is null");
            EnumManager = enumManager;
        }

        public EnumCategory GetEnumCategory()
        {
            return EnumManager.GetCategory(Text);
        }
        #endregion

        #region Events
        private void cboCatogories_DropDown(object sender, EventArgs e)
        {
            cboCatogories.BeginUpdate();
            cboCatogories.DropDownWidth = Width;
            cboCatogories.Items.Clear();
            var kvps = EnumManager.GetCategoryDropDownList(ShowItems, ShowUnitsOfMeasure, ShowCurrency);
            cboCatogories.DisplayMember = "key";
            foreach (var kvp in kvps)
            {
                cboCatogories.Items.Add(kvp);
            }
            cboCatogories.Sorted = true;
            cboCatogories.EndUpdate();
        }

        private void cboCatogories_SelectedIndexChanged(object sender, EventArgs e)
        {
            var kvp = (KeyValuePair<string, EnumCategory>)cboCatogories.SelectedItem;
            txtValue.Text = kvp.Value.FullName;
        }

        #endregion
    }
}
