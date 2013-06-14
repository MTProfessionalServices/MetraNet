using System;
using System.Windows.Forms;
using MetraTech.ExpressionEngine.Flows;
using PropertyGui.Flows.Steps;

namespace PropertyGui.Flows
{
    public partial class ctlFlowSteps : UserControl
    {
        #region Properties
        private Flow Flow;
        private FlowStepBase CurrentStep;
        private ctlFlowStepBase CurrentStepControl;
        private Control TargetStepControlParent;
        #endregion

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
            node.ImageKey = step.FlowStepType.ToString();
            node.Name = step.Name;
            node.Tag = step;
            return node;
        }
        #endregion

        #region Methods
        public void Init(Flow flow, Control targetStepControlParent=null)
        {
            if (flow == null)
                throw new ArgumentException("flow is null");
            Flow = flow;
            TargetStepControlParent = targetStepControlParent;
        }

        public void SyncToForm()
        {
            treSteps.BeginUpdate();
            treSteps.Nodes.Clear();
            foreach (var step in Flow.FlowCollection)
            {
                AddNode(step);
            }
            treSteps.EndUpdate();
        }

        public void SyncToObject()
        {
            Flow.FlowCollection.Clear();
            if (CurrentStepControl != null)
                CurrentStepControl.SyncToObject();
            foreach (var node in treSteps.GetAllNodes())
            {
                Flow.FlowCollection.Add((FlowStepBase)node.Tag);
            }
            Flow.UpdateFlow();
        }

        public TreeNode AddNode(FlowStepBase step)
        {
            var node = new TreeNode();
            node.Text = step.GetAutoLabel();
            node.ToolTipText = "";
            node.ImageKey = step.FlowStepType.ToString() + ".png";
            node.SelectedImageKey = node.ImageKey;
            node.Tag = step;
            treSteps.Nodes.Add(node);
            return node;
        }
        #endregion

        #region Events
        private void btnMoveUp_Click(object sender, EventArgs e)
        {
            if (treSteps.SelectedNode == null)
                return;

            int index;
            if (treSteps.SelectedNode.Index == 0)
                index = treSteps.Nodes.Count - 1;
            else
                index = treSteps.SelectedNode.Index - 1;

            MoveNode(treSteps.SelectedNode, index);
        }

        private void MoveNode(TreeNode node, int index)
        {
            treSteps.Nodes.RemoveAt(node.Index);
            treSteps.Nodes.Insert(index, node);
            treSteps.SelectedNode = node;
        }

        private void btnMoveDown_Click(object sender, EventArgs e)
        {
            if (treSteps.SelectedNode == null)
                return;

            int index;
            if (treSteps.SelectedNode.Index == treSteps.Nodes.Count - 1)
                index = 0;
            else
                index = treSteps.SelectedNode.Index + 1;

            MoveNode(treSteps.SelectedNode, index);
        }


        #endregion

        private void treSteps_AfterSelect(object sender, TreeViewEventArgs e)
        {
            if (treSteps.SelectedNode == null)
            {
                CurrentStep = null;
                return;
            }

            CurrentStep = (FlowStepBase)treSteps.SelectedNode.Tag;

            if (CurrentStepControl != null)
            {
                CurrentStepControl.SyncToObject();
                CurrentStepControl.Parent = null;
                CurrentStepControl.Visible = false;
                CurrentStepControl.Dispose();
            }

            CurrentStepControl = StepFactory.Create(CurrentStep);
            if (TargetStepControlParent != null)
            {
                CurrentStepControl.Parent = TargetStepControlParent;
                CurrentStepControl.Dock = DockStyle.Fill;
                CurrentStepControl.Init(CurrentStep);
                CurrentStepControl.SyncToForm();
            }
        }


        private void menu_Click(object sender, EventArgs e)
        {
            FlowStepBase step;
            if (sender.Equals(mnuExpression))
                step = new ExpressionStep(Flow);
            else //if (sender.Equals(mnuNewProperty))
                step = new NewPropertyStep(Flow);
            var node = AddNode(step);
            treSteps.SelectedNode = node;
        }

        private void btnRefresh_Click(object sender, EventArgs e)
        {
            SyncToObject();
            SyncToForm();
        }
    }
}
