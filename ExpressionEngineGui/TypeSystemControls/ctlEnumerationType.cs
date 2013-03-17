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
            ctlEnumCategory.Init(context.EnumManager);
        }

        public override void SyncToForm()
        {
            ctlEnumCategory.Text = EnumerationType.Category;
        }
        public override void SyncToObject()
        {
            EnumerationType.Category = ctlEnumCategory.Text;
        }
        #endregion

    }
}
