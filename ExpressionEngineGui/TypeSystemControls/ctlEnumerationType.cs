using System;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.TypeSystem;

namespace PropertyGui.TypeSystemControls
{
    public partial class ctlEnumerationType : ctlBaseType
    {
        #region Properties
        private EnumerationType EnumerationType;
        #endregion

        #region Constructor
        public ctlEnumerationType()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public override void Init(Property property, Context context)
        {
 	        base.Init(property, context);
            EnumerationType = (EnumerationType) property.Type;
        }

        public override void SyncToForm()
        {
            cboEnumeration.Text = EnumerationType.Category;
        }
        public override void SyncToObject()
        {
            EnumerationType.Category = cboEnumeration.Text;
        }
        #endregion

        #region Events

        private void cboEnumeration_DropDown(object sender, EventArgs e)
        {
            cboEnumeration.BeginUpdate();
            cboEnumeration.Items.Clear();
            foreach (var category in Context.EnumCategories)
            {
                cboEnumeration.Items.Add(category);
            }
            cboEnumeration.EndUpdate();
        }

        #endregion
    }
}
