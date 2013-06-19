using System;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Flows;
using PropertyGui.Flows.Steps;
using StepFactory = PropertyGui.Flows.Steps.StepFactory;

namespace PropertyGui.Flows
{
    public partial class ctlFlowSteps : UserControl
    {
        #region Properties
        private Context Context;
        private BaseFlow Flow;
        private BaseStep CurrentStep;
        private ctlBaseStep CurrentStepControl;
        private Control TargetStepControlParent;
        private TreeNode PreviouslySelectedNode;
        #endregion

        #region Constructor
        public ctlFlowSteps()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public void Init(Context context, BaseFlow flow, Control targetStepControlParent=null)
        {
            if (context == null)
                throw new ArgumentException("context is null");
            if (flow == null)
                throw new ArgumentException("flow is null");
            Context = context;
            Flow = flow;
            TargetStepControlParent = targetStepControlParent;
        }

        public void SyncToForm()
        {
            treSteps.BeginUpdate();
            treSteps.Nodes.Clear();
            foreach (var step in Flow.Steps)
            {
                AddNode(step);
            }
            treSteps.EndUpdate();
            AttemptToSelectNode(0);
        }

        private TreeNode AddStep(BaseStep step)
        {
            return InsertStep(treSteps.Nodes.Count, step);
        }
        private TreeNode InsertStep(int index, BaseStep step)
        {
            var node = new TreeNode();
            node.ImageKey = step.FlowStepType.ToString();
            node.Name = step.Name;
            node.Tag = step;
            return node;
        }

        public void SyncToObject()
        {
            Flow.Steps.Clear();
            if (CurrentStepControl != null)
                CurrentStepControl.SyncToObject();
            foreach (var node in treSteps.GetAllNodes())
            {
                Flow.Steps.Add((BaseStep)node.Tag);
            }
        }

        private void UpdateNode(TreeNode node)
        {
            var step = (BaseStep) node.Tag;
            node.Text = step.GetAutoLabel();
            node.ToolTipText = step.GetAutoDescription();
            node.ImageKey = step.FlowStepType.ToString() + ".png";
            node.SelectedImageKey = node.ImageKey;
        }
        public TreeNode InsertNode(int index, BaseStep step)
        {
            var node = new TreeNode();
            node.Tag = step;
            UpdateNode(node);
            treSteps.Nodes.Insert(index, node);
            return node;
        }
        public TreeNode AddNode(BaseStep step)
        {
            return InsertNode(treSteps.Nodes.Count, step);
        }

        private void AttemptToSelectNode(int targetIndex)
        {
            if (targetIndex < treSteps.Nodes.Count)
                treSteps.SelectedNode = treSteps.Nodes[targetIndex];
            else if (treSteps.Nodes.Count > 0)
                treSteps.SelectedNode = treSteps.Nodes[treSteps.Nodes.Count - 1];
        }

        private void MoveNode(TreeNode node, int index)
        {
            treSteps.Nodes.RemoveAt(node.Index);
            treSteps.Nodes.Insert(index, node);
            treSteps.SelectedNode = node;
        }
        #endregion

        #region Button Events

        private void btnRefresh_Click(object sender, EventArgs e)
        {
            Flow.UpdateFlow(Context);//;, Flow.InitialProperties);
            SyncToObject();
            SyncToForm();

            if (CurrentStep != null)
            {
                foreach (var node in treSteps.GetAllNodes())
                {
                    if (node.Tag.Equals(CurrentStep))
                        treSteps.SelectedNode = node;
                }
            }
        }
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

        #region Tree Events
        private void treSteps_AfterSelect(object sender, TreeViewEventArgs e)
        {
            if (treSteps.SelectedNode == null)
            {
                CurrentStep = null;
                return;
            }

            CurrentStep = (BaseStep)treSteps.SelectedNode.Tag;

            if (CurrentStepControl != null)
            {
                CurrentStepControl.SyncToObject();
                UpdateNode(PreviouslySelectedNode);
                CurrentStepControl.Parent = null;
                CurrentStepControl.Visible = false;
                CurrentStepControl.Dispose();
            }

            Flow.UpdateFlow(Context);
            CurrentStepControl = StepFactory.Create(Context, CurrentStep);
            if (TargetStepControlParent != null)
            {
                CurrentStepControl.Parent = TargetStepControlParent;
                CurrentStepControl.Dock = DockStyle.Fill;
                //CurrentStepControl.Init(CurrentStep, Context);
                CurrentStepControl.SyncToForm();
            }
            PreviouslySelectedNode = treSteps.SelectedNode;
        }
        #endregion

        #region Menu Events
        private void menu_Click(object sender, EventArgs e)
        {
            BaseStep step;
            if (sender.Equals(mnuExpression))
                step = new ExpressionStep(Flow);
            else //if (sender.Equals(mnuNewProperty))
                step = new NewPropertyStep(Flow);

            TreeNode node;
            if (treSteps.SelectedNode != null)
                node = InsertNode(treSteps.SelectedNode.Index, step);
            else
                node = AddNode(step);

            //Need to update the flow so that available properties etc are set properly
            SyncToObject();
            Flow.UpdateFlow(Context);

            treSteps.SelectedNode = node;
        }

        private void mnuDelete_Click(object sender, EventArgs e)
        {
            if (treSteps.SelectedNode == null)
                return;

            var index = treSteps.SelectedNode.Index;
            treSteps.Nodes.RemoveAt(index);
            SyncToObject();
            AttemptToSelectNode(index);
        }
        #endregion
    }
}
