using System;
using System.Drawing;
using System.IO;
using System.Windows.Forms;
using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Flows;
using MetraTech.ExpressionEngine.Flows.Enumerations;
using PropertyGui.Flows.Steps;
using StepFactory = PropertyGui.Flows.Steps.StepControlFactory;

namespace PropertyGui.Flows
{
    public partial class ctlFlowSteps : UserControl
    {
        #region Properties
        private bool IgnoreChanges = true;
        private Context Context;
        private BaseFlow Flow;
        public BaseStep CurrentStep { get; private set; }
        public ctlBaseStep CurrentStepControl { get; private set; }
        private Control TargetStepControlParent;
        private ctlContextExplorer Toolbox;
        private TreeNode PreviouslySelectedNode;
        private ctlFlowEditor FlowEditor;
        #endregion

        #region Constructor
        public ctlFlowSteps()
        {
            InitializeComponent();
        }
        #endregion

        #region Methods
        public void Init(Context context, BaseFlow flow, ctlFlowEditor flowEditor, Control targetStepControlParent=null, ctlContextExplorer toolbox=null)
        {
            if (context == null)
                throw new ArgumentException("context is null");
            if (flow == null)
                throw new ArgumentException("flow is null");
            Context = context;
            Flow = flow;
            FlowEditor = flowEditor;
            TargetStepControlParent = targetStepControlParent;
            Toolbox = toolbox;

            treSteps.Font = GuiHelper.ExpressionFont;

            AddMenuItem(StepType.Expression);
            AddMenuItem(StepType.Aggregate);
            AddMenuItem(StepType.NewProperty);
            AddMenuItem(StepType.CalculateEventCharge);
            AddMenuItem(StepType.Enforce);
            AddMenuItem(StepType.Function);

            IgnoreChanges = true;
            GuiHelper.LoadEnum<LabelMode>(cboLabelMode);
            cboLabelMode.SelectedItem = LabelMode.Business;
            IgnoreChanges = false;
        }

        public void AddMenuItem(StepType flowItemType)
        {
            var image = imageList.Images[string.Format("{0}.png", flowItemType)];
            var text = flowItemType.ToString();
            var item = new ToolStripMenuItem(text, image, insertStepMenu_Click);
            item.Tag = flowItemType;
            mnuInsert.DropDownItems.Add(item);
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

            SyncCurrentStepControlToForm();

            //Attempt to reselect previosly selected node
            if (CurrentStep != null)
            {
                foreach (var node in treSteps.GetAllNodes())
                {
                    if (node.Tag.Equals(CurrentStep))
                        treSteps.SelectedNode = node;
                }
            }
            else
                AttemptToSelectNode(0);

          
        }

        private TreeNode AddStep(BaseStep step)
        {
            return InsertStep(treSteps.Nodes.Count, step);
        }
        private TreeNode InsertStep(int index, BaseStep step)
        {
            var node = new TreeNode();
            node.ImageKey = step.StepType.ToString();
            node.Tag = step;
            return node;
        }

        public void SyncToObject()
        {
            //Insure that the current step control is updated
            SyncCurrentStepControlToObject();
            
            //Get the order of the steps
            Flow.Steps.Clear();
            foreach (var node in treSteps.GetAllNodes())
            {
                Flow.Steps.Add((BaseStep)node.Tag);
            }
            Flow.UpdateFlow(Context);
        }

        private void UpdateNode(TreeNode node)
        {
            var step = (BaseStep) node.Tag;
            node.Text = string.Format("{0}. {1}", step.Index, step.GetLabel((LabelMode)cboLabelMode.SelectedItem));
            node.ToolTipText = step.GetDescription();

            var baseImageName = step.StepType.ToString() + ".png";
            if (step.HasConditionalExpression)
            {
                var overlayImageName = step.StepType.ToString() + "_Overlay.png";
                if (!imageList.Images.ContainsKey(overlayImageName))
                {
                    var image = MvcAbstraction.GetOverlayImage(imageList.Images[baseImageName],
                                                               imageList.Images["ConditionalExecutionOverlay.png"]);
                    imageList.Images.Add(overlayImageName, image);
                }
                node.ImageKey = overlayImageName;
            }
            else
                node.ImageKey = baseImageName; 

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
            //Need to deslected the node because the tree will autorelceted whatever node fills its slot
            treSteps.SelectedNode = null;
            treSteps.Nodes.RemoveAt(node.Index);
            treSteps.Nodes.Insert(index, node);
            RefreshTree();
        }

        public void RefreshTree()
        {
            SyncToObject();
            SyncToForm();
        }
        #endregion

        #region Button Events

        private void btnRefresh_Click(object sender, EventArgs e)
        {
            if (!IgnoreChanges)
                RefreshTree();
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

        private void SyncCurrentStepControlToForm()
        {
            if (CurrentStepControl != null)
            {
                CurrentStepControl.SyncToForm();
                FlowEditor.SyncCommonFieldsToForm(CurrentStep);
            }
        }

        private void SyncCurrentStepControlToObject()
        {
            if (CurrentStepControl != null)
            {
                CurrentStepControl.SyncToObject();
                FlowEditor.SyncCommonFieldsToObject(CurrentStep);
            }
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

            if (CurrentStepControl != null)
            {
                SyncCurrentStepControlToObject();
                UpdateNode(PreviouslySelectedNode);
                CurrentStepControl.Parent = null;
                CurrentStepControl.Visible = false;
                CurrentStepControl.Dispose();
            }

            CurrentStep = (BaseStep)treSteps.SelectedNode.Tag;

            Flow.UpdateFlow(Context);
            CurrentStepControl = StepFactory.Create(Context, CurrentStep);
            if (TargetStepControlParent != null)
            {
                CurrentStepControl.Parent = TargetStepControlParent;
                CurrentStepControl.Dock = DockStyle.Fill;
                SyncCurrentStepControlToForm();
            }
            if (Toolbox != null)
            {
                Context.AvailableProperties = CurrentStep.AvailableProperties;
                Context.InputsAndOutputs = CurrentStep.InputsAndOutputs;
                Toolbox.RefreshTree();
            }
            PreviouslySelectedNode = treSteps.SelectedNode;
        }
        #endregion

        #region Menu Events

        private void insertStepMenu_Click(object sender, EventArgs e)
        {
            var menuItem = (ToolStripMenuItem) sender;
            var step  = MetraTech.ExpressionEngine.Flows.StepFactory.Create((StepType) menuItem.Tag, Flow);

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

        private void btnCsv_Click(object sender, EventArgs e)
        {
            try
            {
                SyncToObject();
                var csv = Flow.GetEventChargeMappingsCsvString();
                Clipboard.SetText(csv);
                File.WriteAllText(@"C:\Temp\CdeEventChargeMappings.csv", csv);
            }
            catch (Exception ex)
            {  
                GuiHelper.ShowErrorMessage(ex.Message);
            }
        }
    }
}
