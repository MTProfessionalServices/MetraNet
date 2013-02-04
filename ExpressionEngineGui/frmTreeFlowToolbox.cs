//At this point all three panels are updated. Doesn't appear to be a performance issue.
//In the future we might just updated the one that's open and then update the others only
//when then user opens them.

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Linq;
using System.Windows.Forms;
using Syncfusion.Windows.Forms.Tools;

namespace MetraTech.ICE.TreeFlows.Expressions
{
  public partial class frmTreeFlowToolbox : Form
  {
    #region Constants
    private const string INPUTS_AND_OUTPUTS = "Inputs/Outputs";
    private const string AVAILABLE = "Available";
    private const string AVAILABLE_NUMBERS = "Available Numbers";
    private const string AVAILABLE_STRINGS = "Available Strings";
    private const string AVAILABLE_DATE_TIMES = "Available DateTimes";
    private const string AVAILABLE_ENUMS = "Available Enums";
    private const string AVAILABLE_BOOLEANS = "Available Booleans";
    private const string ENUM_VALUES = "Enum Values";
    #endregion Constants

    #region Properties

    /// <summary>
    /// A reference to the form. Used to ensure that there is only one toolbox.
    /// </summary>
    private static frmTreeFlowToolbox FormRef = null;

    /// <summary>
    /// The TreeFlow editor that the toolbox is interacting with.
    /// </summary>
    private static ctlTreeFlowEditor TreeFlowEditor;

    /// <summary>
    /// The TreeFlow class that the toolbox is interacting with.
    /// </summary>
    private static TreeFlow TreeFlow { get { return TreeFlowEditor.TreeFlow; } }

    /// <summary>
    /// The selected TreeFlowNode that the toolbox is interacting with.
    /// </summary>
    private static TreeFlowNode TreeFlowNode;

    #endregion Properties

    #region Constructor

    public frmTreeFlowToolbox()
    {
      InitializeComponent();

      groupView.SmallImageList = GuiHelper.TreeFlowImages;
      treAvailableFields.ImageList = GuiHelper.TreeFlowImages;

      frmSelectFunction.LoadComboWithFunctionCategories(cboFunctionFilter);

      if (string.IsNullOrEmpty(cboFunctionFilter.Text))
        cboFunctionFilter.Text = Helper.ALL_STR;

      //Field and property filter
      cboFieldPropertyFilter.BeginUpdate();
      cboFieldPropertyFilter.Items.Add(INPUTS_AND_OUTPUTS);
      cboFieldPropertyFilter.Items.Add(AVAILABLE);
      cboFieldPropertyFilter.Items.Add(AVAILABLE_NUMBERS);
      cboFieldPropertyFilter.Items.Add(AVAILABLE_STRINGS);
      cboFieldPropertyFilter.Items.Add(AVAILABLE_DATE_TIMES);
      cboFieldPropertyFilter.Items.Add(AVAILABLE_ENUMS);
      cboFieldPropertyFilter.Items.Add(AVAILABLE_BOOLEANS);
      cboFieldPropertyFilter.Items.Add(ENUM_VALUES);
      cboFieldPropertyFilter.Text = AVAILABLE;

      cboFieldPropertyFilter.EndUpdate();

      InitFlowNodes();
    }

    #endregion Constructor

    #region General Methods

    public static void UpdateStuff(ctlTreeFlowEditor ctlTreeFlowEditor)
    {
      TreeFlowEditor = ctlTreeFlowEditor;
      TreeFlowNode = TreeFlowEditor.CurrentViewer.CurrentFlowNode;

      if (FormRef == null)
      {
        FormRef = new frmTreeFlowToolbox();
        FormManager.Instance.MDI.ConvertToFloatingPanel(FormRef, "TreeFlow Toolbox");
        DockingManager dockingManager = FormManager.Instance.MDI.GetDockingManager();
        dockingManager.DockControl(FormRef, FormManager.Instance.MDI, DockingStyle.Left, 225);
      }
      else
        FormRef.BringToFront();

      FormRef.UpdateAllStuff();
    }

    //If flicker becomes an issue we could just update the groupbar that's open and
    //also trap when the groupbar changes... not an issue at this point
    public void UpdateAllStuff()
    {
      UpdateFlowNodes();

      UpdateFields();

      UpdateFunctionList();
    }

    #endregion General Methods

    # region Flow Nodes

    //Load all of the nodes. They will be shown/hidden based on context
    private void InitFlowNodes()
    {
      groupView.GroupViewItems.Clear();
      foreach (TfnInfo info in TfnInfo.Info.Values)
      {
        if (info.Type == TreeFlowNode.NodeTypeEnum.Start)
          continue;

        AppendFlowNode(info);
      }

      cboNodeFilter.BeginUpdate();
      cboNodeFilter.Items.Add(Helper.ALL_STR);
      foreach (var category in TfnInfo.AllCategories)
      {
        cboNodeFilter.Items.Add(category);
      }
      cboNodeFilter.EndUpdate();
      cboNodeFilter.SelectedItem = Helper.ALL_STR;
    }

    //Show/Hide nodes
    private void UpdateFlowNodes()
    {
      foreach (GroupViewItem item in groupView.GroupViewItems)
      {
        if (TreeFlowNode == null)
          item.Visible = false;
        else
        {
          var info = TfnInfo.Info[((TreeFlowNode.NodeTypeEnum)item.Tag)];

          //If there is a filter, apply it\
          var filter = (string)cboNodeFilter.SelectedItem;
          if (filter != Helper.ALL_STR && !info.Categories.Contains(filter))
          {
            item.Visible = false;
            continue;
          }

          //Check if it's compatible
          if (TreeFlow.FunctionalMode == TreeFlows.TreeFlow.FunctionalModeType.PriceableItemFlow && TreeFlowNode.NodeType == TreeFlows.TreeFlowNode.NodeTypeEnum.Start)
            item.Visible = info.SupportsMetraFlow;
          else
            item.Visible = TreeFlow.IsContextCompatible(TreeFlowNode.Info, info);
        }
      }
    }

    private GroupViewItem AppendFlowNode(TfnInfo info)
    {
      //Uaed to have GetMenuItemName() -- not sure why
      GroupViewItem item = new GroupViewItem(info.UserName, GuiHelper.TreeFlowImages.Images.IndexOfKey(info.ImageName), info.Type);
      item.ToolTipText = info.Description;
      groupView.GroupViewItems.Add(item);
      return item;
    }

    private void groupView_MouseDown(object sender, MouseEventArgs e)
    {
      GroupViewItem item = groupView.GetItemAt(new Point(e.X, e.Y));
      if (item != null)
        groupView.DoDragDrop((TreeFlowNode.NodeTypeEnum)item.Tag, DragDropEffects.Move);
    }

    private void cboNodeFilter_SelectedIndexChanged(object sender, EventArgs e)
    {
      UpdateFlowNodes();
    }

    #endregion FlowNodes

    #region Functions

    private void UpdateFunctionList()
    {
      //Load the functions list
      lstFunctions.BeginUpdate();
      lstFunctions.Items.Clear();
      foreach (Function func in Function.Functions.Values)
      {
        if (TreeFlow != null &&
            func.IsSupported(TreeFlow.CodeGen.LanguageType) &&
            (cboFunctionFilter.Text == Helper.ALL_STR || cboFunctionFilter.Text == func.Category.ToString()))
          lstFunctions.Items.Add(func);
      }
      lstFunctions.EndUpdate();
    }

    private void cboFunctionFilter_SelectedIndexChanged(object sender, EventArgs e)
    {
      UpdateFunctionList();
    }

    private void lstFunctions_MouseDown(object sender, MouseEventArgs e)
    {
      int indexOfItem = lstFunctions.IndexFromPoint(e.X, e.Y);
      if (indexOfItem >= 0 && indexOfItem < lstFunctions.Items.Count)  // check we clicked down on a string
      {
        lstFunctions.DoDragDrop(lstFunctions.Items[indexOfItem], DragDropEffects.Move);
      }
    }

    #endregion Functions

    #region FieldsAndProperties

    private static void SetIcon(TreeNode visualNode, string iconName)
    {
      visualNode.ImageKey = iconName;
      visualNode.SelectedImageKey = iconName;
    }

    private void LoadWithEnums()
    {
      treAvailableFields.BeginUpdate();
      treAvailableFields.Nodes.Clear();
      foreach (EnumerationNamespace enumNamespace in Config.Instance.EnumerationConfig.EnumNamespaces.Values)
      {
        int imageIndex = GuiHelper.TreeFlowImages.Images.IndexOfKey("EnumType.png");
        TreeNode namespaceNode = new TreeNode(enumNamespace.Name, imageIndex, imageIndex);
        namespaceNode.ToolTipText = enumNamespace.Description;
        namespaceNode.Tag = enumNamespace;
        treAvailableFields.Nodes.Add(namespaceNode);

        foreach (EnumerationType enumType in enumNamespace.EnumTypes.Values)
        {
          TreeNode typeNode = new TreeNode(enumType.Name, imageIndex, imageIndex);
          typeNode.Tag = enumType;
          typeNode.ToolTipText = enumType.Description;
          namespaceNode.Nodes.Add(typeNode);

          foreach (EnumerationValue enumValue in enumType.EnumValues.Values)
          {
            TreeNode valueNode = new TreeNode(enumValue.Name, imageIndex, imageIndex);
            valueNode.Tag = enumValue;
            typeNode.Nodes.Add(valueNode);
          }
        }
      }

      treAvailableFields.EndUpdate();
    }

    private void UpdateTreeForFields(List<Property_TreeFlow> propCollection)
    {
      treAvailableFields.BeginUpdate();
      treAvailableFields.Nodes.Clear();

      var containerNodes = new Dictionary<string, TreeNode>(StringComparer.CurrentCultureIgnoreCase);

      var allProps = new List<Property_TreeFlow>();

      //combine all the property collections into one
      foreach (var prop in propCollection)
        allProps.Add(prop);

      //sort and filter
      var props = from p in allProps
                  where !string.IsNullOrEmpty(p.Name) && !FilterOut(p)
                  orderby p.Name.SafeCount('.') descending, p.Name ascending
                  select p;

      var recordList = new List<string>();

      foreach (Property_TreeFlow prop in props)
      {
          string name = prop.Name;

          bool addProperty = true;
          if (prop.Name.Contains(".") && prop.DataTypeInfo.Type != DataType._record )
          {
              var record = props.ToList().Find(ptf => ptf.DataTypeInfo.Type == DataType._record && prop.Name.StartsWith(ptf.Name + ".")) as Property_TreeFlow;
              if (record != null)
              {
                  addProperty = false;
              }
          }
          if (addProperty)
          {
              TreeNode visualNode = new TreeNode(prop.Name);
              visualNode.Tag = prop;
              visualNode.ToolTipText = prop.ToolTipText;

              treAvailableFields.Nodes.Add(visualNode);

              if (prop.DataTypeInfo.Type == DataType._record)
              {
                  if (prop.Direction == DirectionType.Output)
                  {
                      SetIcon(visualNode, "input-output_o-low_record.png");
                  }
                  else if (prop.Direction == DirectionType.Input)
                  {
                      SetIcon(visualNode, "input-output_i-low_record.png");
                  }
                  else if (prop.Direction == DirectionType.InOut)
                  {
                      SetIcon(visualNode, "input-output_i-o-low_record.png");
                  }
              }
              else
              {
                  if (prop.Direction == DirectionType.Output)
                  {
                      SetIcon(visualNode, "input-output_o-low.png");
                  }
                  else if (prop.Direction == DirectionType.Input)
                  {
                      SetIcon(visualNode, "input-output_i-low.png");
                  }
                  else if (prop.Direction == DirectionType.InOut)
                  {
                      SetIcon(visualNode, "input-output_i-o-low.png");
                  }
              } 
          }
      }
      
      treAvailableFields.EndUpdate();

    }

    private void UpdateTreeForAvailableFields(Dictionary<string, Property_TreeFlow> propCollection)
    {
        treAvailableFields.BeginUpdate();
        treAvailableFields.Nodes.Clear();

        var containerNodes = new Dictionary<string, TreeNode>(StringComparer.CurrentCultureIgnoreCase);

        var allProps = new List<Property_TreeFlow>();

        //combine all the property collections into one
        foreach (var prop in propCollection)
            allProps.Add(prop.Value);

        //sort and filter
        var props = from p in allProps
                    where !string.IsNullOrEmpty(p.Name) && !FilterOut(p)
                    orderby p.Name.SafeCount('.') descending, p.Name ascending
                    select p;

        //Load the records... not sure that this needs to be separate loop... need to think this through better
        foreach (var prop in props)
        {
            if (prop.DataTypeInfo.Type != DataType._record)
                continue;

            if(prop.Name.StartsWith(TreeFlow.PARENT_PREFIX))
                continue;

            TreeNode visualNode = new TreeNode(prop.Name);
            visualNode.Tag = prop;
            visualNode.ToolTipText = prop.ToolTipText;
            SetIcon(visualNode, "Record.png");

            //Not sure if this is going to work for multipoint!
            treAvailableFields.Nodes.Add(visualNode);
            containerNodes.Add(prop.Name, visualNode);
        }

        //Load the non-records
        foreach (Property_TreeFlow prop in props)
        {
            if (prop.DataTypeInfo.Type != DataType._record)
                AppendTreeFieldNode(prop, containerNodes);
        }

        treAvailableFields.EndUpdate();
    }

    private bool FilterOut(Property_TreeFlow prop)
    {
      switch (cboFieldPropertyFilter.Text)
      {
        case AVAILABLE:
        case "":
        case null:
        case INPUTS_AND_OUTPUTS:
          return false;
        case AVAILABLE_STRINGS:
          return (prop.DataTypeInfo.Type != DataType._string && prop.DataTypeInfo.Type != DataType._unistring);
        case AVAILABLE_NUMBERS:
          return !prop.DataTypeInfo.IsNumeric();
        case AVAILABLE_DATE_TIMES:
          return prop.DataTypeInfo.Type != DataType._timestamp;
        case AVAILABLE_BOOLEANS:
          return prop.DataTypeInfo.Type != DataType._boolean;
        case AVAILABLE_ENUMS:
          return prop.DataTypeInfo.Type != DataType._enum;
        default:
          Helper.ShowErrorMsg("Unhandled filter option: " + cboFieldPropertyFilter.Text);
          return false;
      }
    }

    private static char[] dotChar = new char[] { '.' };

    private TreeNode AppendTreeFieldNode(Property_TreeFlow prop, Dictionary<string, TreeNode> containerNodes)
    {
      TreeNode parentVisualNode = null;
      string name = prop.Name;

      if (prop.Name.Contains("."))
      {
        string[] parts = prop.Name.Split(dotChar);
        string path = null;
        for (int index = 0; index < parts.Length; index++)
        {
          //If we're at the last one, bail out
          if (index == parts.Length - 1)
          {
            name = parts[index];
            break;
          }

          string part = parts[index];
          if (path == null)
            path = part;
          else
            path = path + "." + part;

          if (!containerNodes.ContainsKey(path))
          {
            TreeNode newNode = new TreeNode(part);
            if (part + "." == TreeFlow.PARENT_PREFIX)// && prop.Name.StartsWith(TreeFlow.PARENT_PREFIX + "."))
            {
              SetIcon(newNode, "Parent.png");
              newNode.ToolTipText = "Contains all of the field's in the parent transaction. They are read only.";
            }
            else
            {
              SetIcon(newNode, "Record.png");
              if (TreeFlowNode.AvailableFields.Contains(part))
              {
                var record = TreeFlowNode.AvailableFields[part];
                newNode.ToolTipText = "Auto Record: " + record.Description;
              }
            }

            if (parentVisualNode == null)
              treAvailableFields.Nodes.Add(newNode);
            else
              parentVisualNode.Nodes.Add(newNode);

            containerNodes.Add(path, newNode);
            parentVisualNode = newNode;
          }
          else
          {
            parentVisualNode = containerNodes[path];
          }
        }
      }

      TreeNode visualNode = new TreeNode(name);
      visualNode.Tag = prop;
      visualNode.ToolTipText = prop.ToolTipText;

      string imageName;
      if (cboFieldPropertyFilter.Text == INPUTS_AND_OUTPUTS)
        imageName = Property_TreeFlow.GetImageName(prop);
      else
        imageName = "TF_Assigned";

      SetIcon(visualNode, imageName);

      if (parentVisualNode == null)
        treAvailableFields.Nodes.Add(visualNode);
      else
        parentVisualNode.Nodes.Add(visualNode);

      if (prop.IsAssigned)
      {
        SetIcon(visualNode, "TF_Assigned");
      }
      else if (prop.Required)
      {
          visualNode.NodeFont = new Font("Tahoma",8,FontStyle.Bold);
          SetIcon(visualNode, "TF_OptionalAndUnassigned");
      }
      else
      {
          SetIcon(visualNode, "TF_OptionalAndUnassigned");
      }

      return visualNode;
    }

    private void treAvailableFields_AfterSelect(object sender, TreeViewEventArgs e)
    {
    }

    private void treAvailableFields_MouseDown(object sender, MouseEventArgs e)
    {
      TreeNode visualNode = treAvailableFields.GetNodeAt(e.X, e.Y);
      if (visualNode == null)
        return;

      treAvailableFields.SelectedNode = visualNode;
      if (visualNode.Tag is EnumerationNamespace ||
          visualNode.Tag is EnumerationType
          )
        return;

      //Handle Fields
      if (visualNode.Tag is Property_TreeFlow)
      {
        treAvailableFields.DoDragDrop(visualNode.Tag, DragDropEffects.Move);
      }
      else if (visualNode.Tag is EnumerationValue)
      {
        treAvailableFields.DoDragDrop(visualNode.Tag, DragDropEffects.Move);
      }
      //else
      //    throw new Exception("Unhandled tag in MouseDown.");
    }

    private void cboFieldPropertyFilter_SelectedIndexChanged(object sender, EventArgs e)
    {
      UpdateFields();
    }

    private void UpdateFields()
    {
      switch (cboFieldPropertyFilter.Text)
      {
        case INPUTS_AND_OUTPUTS:
          if (TreeFlowNode != null)
            UpdateTreeForFields(TreeFlowNode.Fields);
          break;
        case ENUM_VALUES:
          LoadWithEnums();
          break;
        default:
          if (TreeFlowNode != null)
          {
              UpdateTreeForAvailableFields(TreeFlowNode.AvailableFields);
          }
          break;
      }
    }

    private void mnuExpandAll_Click(object sender, EventArgs e)
    {
      treAvailableFields.ExpandAll();
    }

    private void mnuCollapseAll_Click(object sender, EventArgs e)
    {
      treAvailableFields.CollapseAll();
    }

    private void mnuFindAllReferences_Click(object sender, EventArgs e)
    {
      string fieldName = ((Property_TreeFlow)treAvailableFields.SelectedNode.Tag).Name;
      frmFindAllReferences form = new frmFindAllReferences(TreeFlowEditor.CurrentViewer, fieldName);
      form.Show();
    }

    private void mnuRefactorFieldName_Click(object sender, EventArgs e)
    {
      var field = (Property_TreeFlow)treAvailableFields.SelectedNode.Tag;
      var dialog = new frmRefactorFieldName(field.Name, (field.DataTypeInfo.Type==DataType._record), TreeFlow, TreeFlowEditor);
      dialog.ShowDialog();
    }

    #endregion FieldsAndProperties

    private void superToolTip_PopupToolTip(Component component, ref Rectangle rc)
    {
      //indexOfItem = lstFunctions.IndexFromPoint(rc.X, rc.Y);
    }

    private void superToolTip_UpdateToolTip(Component component, ref ToolTipInfo info)
    {
      //info.Header.Text ="Cool Function";
      //info.Body.Text = "Good desc...";
      //info.Footer.Text = "Return Type: " + "string";
      //return;

      //if (indexOfItem <= 0)
      //    return;
      //Function func = (Function)lstFunctions.Items[indexOfItem];
      //info.Header.Text = func.ToProtoypeString();
      //info.Body.Text = func.Description;
      //info.Footer.Text = "Return Type: " + func.ReturnType.ToString();
    }

    private void lstFunctions_MouseMove(object sender, MouseEventArgs e)
    {
      //int indexOfItem = lstFunctions.IndexFromPoint(e.X, e.Y);
      //if (indexOfItem <= 0 || indexOfItem == lastIndex)
      //    return;

      //lastIndex = indexOfItem;
      //Function func = (Function)lstFunctions.Items[indexOfItem];

      //ToolTipInfo ttInfo = new ToolTipInfo();
      //ttInfo.Header.Text = func.ToProtoypeString();
      //ttInfo.Body.Text = func.Description;
      //ttInfo.Footer.Text = "Return Type: " + func.ReturnType.ToString();
      //Point pt = this.PointToClient(new Point(e.X, e.Y + 20));
      //superToolTip.Show(ttInfo, pt);
    }

    private void lstFunctions_MouseLeave(object sender, EventArgs e)
    {
      //superToolTip.Hide();
    }





  }
}
