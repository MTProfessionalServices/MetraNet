using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.TypeSystem;

namespace PropertyGui.TypeSystemControls
{
    public partial class ctlNumberType : ctlBaseType
    {
        #region Properties
        private NumberType NumberType;
        #endregion

        #region Constructor
        public ctlNumberType()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public override void Init(Property property, Context context)
        {
            base.Init(property, context);
            NumberType = (NumberType)property.Type;
        }

        public override void SyncToForm()
        {
        }
        public override void SyncToObject()
        {
        }
        #endregion
    }
}
