using System;
using System.Collections.Generic;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Components.Enumerations;

namespace PropertyGui.Compoenents
{
    public partial class ctlComponentLink : UserControl
    {
        #region Properties
        private ComponentLink ComponentLink;
        private Context Context;
        #endregion

        #region Constructor
        public ctlComponentLink()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public void Init(ComponentLink componentLink, Context context)
        {
            if (componentLink == null)
                throw new ArgumentException("component is null");
            if (context == null)
                throw new ArgumentException("context is null");

            ComponentLink = componentLink;
            Context = context;
        }
        public void SyncToForm()
        {
            cboComponents.Text = ComponentLink.GetFullName();
        }
        public void SyncToObject()
        {
            ComponentLink.SetFullName(cboComponents.Text);
        }

        private void PopulateItems(IEnumerable<object> items, string displayMember)
        {
            cboComponents.BeginUpdate();
            cboComponents.Items.Clear();
            cboComponents.Sorted = true;
            cboComponents.DisplayMember = displayMember;
            foreach (var item in items)
            {
                cboComponents.Items.Add(item);
            }
            cboComponents.EndUpdate();  
        }
        #endregion

        #region Events
        private void cboComponents_DropDown(object sender, EventArgs e)
        {
            switch (ComponentLink.ExpectedComponentType)
            {
                case ComponentType.Currency:
                    PopulateItems(Context.EnumManager.GetCurrencyCategory().Items, "Name");
                    break;
                case ComponentType.UnitOfMeasure:
                    PopulateItems(Context.EnumManager.GetUnitOfMeasureCategories(), "Name");
                    break;
                case ComponentType.UnitOfMeasureCategory:
                    PopulateItems(Context.EnumManager.GetUnitOfMeasureCategories(), "Name");
                    break;
            }
        }
        #endregion
    }
}
