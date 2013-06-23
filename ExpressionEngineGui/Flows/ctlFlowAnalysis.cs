using System.Drawing;
using System.Windows.Forms;

namespace PropertyGui.Flows
{
    public partial class ctlFlowAnalysis : UserControl
    {
        #region Propertis
        public Color ValueNotSet = Color.White;
        public Color ValueSetColor = Color.LightBlue;
        public Color ValueChangedColor = Color.Orange;
        public Color ValueInitialColor = Color.LightGreen;
        public Color ValueNotExecutedColor = Color.DarkGray;
        public Color ErrorColor = Color.Red;
        #endregion

        #region Constructor
        public ctlFlowAnalysis()
        {
            InitializeComponent();

            //Init the legend
            InitLegendItem(panInitial, ValueInitialColor, "Initial value");
            InitLegendItem(panValueNotSet, ValueNotSet, "Value not set");
            InitLegendItem(panValueSet, ValueSetColor, "Value set");
            InitLegendItem(panValueChanged, ValueChangedColor, "Value changed");
            InitLegendItem(panNotExecuted, ValueNotExecutedColor, "Not executed");
            InitLegendItem(panError, ErrorColor, "Error");
        }

        private void InitLegendItem(Panel panel, Color color, string toolTipText)
        {
            panel.BackColor = color;
            toolTip.SetToolTip(panel, toolTipText);
        }
        #endregion
    }
}
