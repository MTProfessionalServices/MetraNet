using System.Windows.Forms;
using MetraTech.ExpressionEngine.Flows;

namespace PropertyGui.Flow
{
    public partial class ctlFlowSteps : UserControl
    {
        #region Constructor
        public ctlFlowSteps()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public void LoadSteps(FlowCollection flowCollection)
        {
            treSteps.BeginUpdate();
            treSteps.Nodes.Clear();
            foreach (var step in flowCollection)
            {
                AddStep(step);
            }
            treSteps.EndUpdate();
        }

        private TreeNode AddStep(FlowStepBase step)
        {
            return InsertStep(treSteps.Nodes.Count, step);
        }
        private TreeNode InsertStep(int index, FlowStepBase step)
        {
            var node = new TreeNode();
            node.ImageKey = step.FlowItemType.ToString();
            node.Name = step.Name;
            node.Tag = step;
            return node;
        }
        #endregion
    }
}
