using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MetraTech.SecurityFramework;
using System.Drawing;
using System.Diagnostics;

namespace SampleAspNetApp
{
	public partial class Processor : System.Web.UI.Page
	{
		protected void Page_Load(object sender, EventArgs e)
		{
			//ConfigurationLoader cl = SecurityKernel.Loader;
			ISubsystem proc = SecurityKernel.Processor;// cl.GetSubsystem<MetraTech.SecurityFramework.Processor>();
			lblError.Text = "";
			lblResult.Text = "Result:";

			if (Page.IsPostBack == false)
			{
				ddlProc.Items.Add("");
				foreach (string idEngine in proc.Api.EngineIds)
				{
					ddlProc.Items.Add(idEngine);
				}

				ddlProc.Text = "";
			}
		}

		protected void btnProcClick(object sender, EventArgs e)
		{
			lblWorkedRules.Text = "Worked rules: ";
			string inputText = txtProc.Text;
			ApiInput input = new ApiInput(inputText);
			ApiOutput output = null;

			string id = ddlProc.Text;
			if (string.IsNullOrEmpty(id))
			{
				lblError.Text = "Choose another engine!";
				return;
			}

			IEngine engine = SecurityKernel.Processor.Api.GetEngine(id);

			if (engine == null)
			{
				lblError.Text = "Engine not found";
				return;
			}


			ProcessorEngine pEngine = ((ProcessorEngine)engine);
			Stopwatch watch = new Stopwatch();
			watch.Start();
			
			try
			{
				output = pEngine.Execute(input);
			}
			catch (ProcessorException exc)
			{
				if (exc.Errors != null)
				{
					List<string> list = new List<string>();
					list.Add(exc.Message);
					list.AddRange(GetExceptions(exc.Errors));
					Engines.DataSource = list;
					lblResult.ForeColor = Color.Red;
				}

				lblResult.Text += "	" + exc.Message;
			}
			finally
			{
				watch.Stop();
				lblTicks.Text = (((double)watch.ElapsedTicks) * 1000.0 / (double)Stopwatch.Frequency).ToString();
			}

			IEnumerable<string> _rules = pEngine.ChainRules.Distinct<string>();
			KeyValuePair<string, int>[] sourceArray = new KeyValuePair<string, int>[_rules.Count<string>()];
			int i = 0;

			foreach (string str in _rules)
			{
				sourceArray[i] = new KeyValuePair<string, int>(str, pEngine.ChainRules.Where<string>(p => p.Equals(str)).Count<string>());
				i++;
			}

			Rules.DataSource = sourceArray;
			int a = pEngine.ChainRules.Distinct<string>().Count<string>();
			ChainRules.DataSource = pEngine.ChainRules;

			if (output != null)
			{
				lblProc.Text = HttpUtility.HtmlEncode(output.ToString());

			}

			DataBind();
		}

		protected void ddlProc_IChange(object sender, EventArgs e)
		{
			listIncRules.Items.Clear();
			string id = ddlProc.Text;
			bool istrue = false;
			foreach (IEngine engine in SecurityKernel.Processor.Api.Engines)
			{
				if (engine.Id == id)
				{
					istrue = true;
					ProcessorEngine pEngine = ((ProcessorEngine)engine);
					lblStartRule.Text = "Start rule: " + pEngine.IdFirstRule;
					foreach (string idRule in pEngine.Rules.Keys)
					{
						listIncRules.Items.Add(idRule);
					}
					break;
				}
			}
			if (istrue)
			{
				pnlInclude.Visible = true;
			}
			else
			{
				pnlInclude.Visible = false;
			}
		}

		private List<string> GetExceptions(IEnumerable<Exception> exceptions)
		{
			List<string> retList = new List<string>();
			if (exceptions != null)
			{
				foreach (Exception exc in exceptions)
				{
					if (exc is ProcessorException)
					{
						retList.Add(exc.Message);
						retList.AddRange(GetExceptions(((ProcessorException)exc).Errors));
					}
					else
					{
						retList.Add(exc.Message);
					}
				}
			}

			return retList;
		}
	}
}