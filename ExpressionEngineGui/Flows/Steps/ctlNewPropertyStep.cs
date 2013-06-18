using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Flows;
using MetraTech.ExpressionEngine.PropertyBags;

namespace PropertyGui.Flows.Steps
{
    public partial class ctlNewPropertyStep : ctlBaseStep
    {
        #region Properties
        private NewPropertyStep Step { get { return (NewPropertyStep) _step; } }
        #endregion

        #region Constructor
        public ctlNewPropertyStep()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public override void Init(BaseStep step, Context context)
        {
            base.Init(step, context);
            ctlProperty.Init(Context, new ProductViewEntity(null, null, null));
            ctlProperty.ShowIsRequired = false;
        }

        public override void SyncToForm()
        {
            ctlProperty.SyncToForm(Step.Property);
        }
        #endregion
    }
}
