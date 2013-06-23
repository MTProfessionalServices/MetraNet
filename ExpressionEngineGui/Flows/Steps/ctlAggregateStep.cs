using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Flows;
using MetraTech.ExpressionEngine.Flows.Steps;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.Mvm.Enumerations;
using MetraTech.ExpressionEngine.PropertyBags;
using MetraTech.ExpressionEngine.TypeSystem;

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
            var parent = Step.AvailableProperties.Get("PARENT");
            if (parent is PropertyBag)
            {
                targets.Add(parent);
            }
            ctlTargetProperty.Init(targets, TypeFactory.CreateNumeric());
           

            GuiHelper.LoadEnum<AggregateAction>(cboAction);

            ctlSourceProperty.Init(step.AvailableProperties, TypeFactory.CreateNumeric());

            ctlExpression.Init(Context, null);
        }

        public override void SyncToForm()
        {
            ctlTargetProperty.Text = Step.TargetProperty;
            cboAction.SelectedItem = Step.Action;
            ctlSourceProperty.Text = Step.SourceProperty;
            ctlExpression.Text = Step.Filter;
        }

        public override void SyncToObject()
        {
            Step.TargetProperty = ctlTargetProperty.Text;
            Step.Action = (AggregateAction)cboAction.SelectedItem;
            Step.SourceProperty = ctlSourceProperty.Text;
            Step.Filter = ctlExpression.Text;
        }
        #endregion
    }
}
