using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Flows;
using MetraTech.ExpressionEngine.Flows.Steps;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.Mvm.Enumerations;
using MetraTech.ExpressionEngine.PropertyBags;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Constants;

namespace PropertyGui.Flows.Steps
{
    public partial class ctlAggregateStep : ctlBaseStep
    {
        #region Properties
        private AggregationStep Step { get { return (AggregationStep)_step; } }
        #endregion

        #region Constructor
        public ctlAggregateStep()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public override void Init(BaseStep step, Context context)
        {
            base.Init(step, context);

            //Init the targets
            var targets = new PropertyCollection(null);
            var parent = Step.AvailableProperties.Get(PropertyBagConstants.ParentPropertyBag);
            if (parent is PropertyBag)
            {
                targets.Add(parent);
            }
            ctlTargetProperty.Init(targets, TypeFactory.CreateNumeric());
           

            GuiHelper.LoadEnum<AggregateAction>(cboAction);

            ctlSourceProperty.Init(step.AvailableProperties, TypeFactory.CreateNumeric());
        }

        public override void SyncToForm()
        {
            base.SyncToForm();
            ctlTargetProperty.Text = Step.TargetProperty;
            cboAction.SelectedItem = Step.Action;
            ctlSourceProperty.Text = Step.SourceProperty;
        }

        public override void SyncToObject()
        {
            base.SyncToObject();
            Step.TargetProperty = ctlTargetProperty.Text;
            Step.Action = (AggregateAction)cboAction.SelectedItem;
            Step.SourceProperty = ctlSourceProperty.Text;
        }
        #endregion
    }
}
