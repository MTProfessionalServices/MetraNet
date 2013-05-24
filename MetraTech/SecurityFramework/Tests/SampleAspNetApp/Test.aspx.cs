using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Globalization;
using System.Text;

namespace SampleAspNetApp
{
    public partial class Test : System.Web.UI.Page
    {
		private enum ParserStatus
		{
			None,
			Parsing,
			Parsed,
			ParsedPrev,
			Failed
		}

		private const string tmp = "\\\\x(?<word>[0-9a-fA-F]{2})|(\\\\u(?<word>[0-9a-fA-F]{4}))|\\\\(?<newLine>n)|\\\\(?<escape>[^n])";
		private Regex testRegex = new Regex(tmp, RegexOptions.Multiline | RegexOptions.Compiled);

		private StringBuilder _parsingToken;
		private StringBuilder _parsingNumber = new StringBuilder(4);
		private char _currentToken;

		private string regexResult;
		private string parseResult;

        protected void Page_Load(object sender, EventArgs e)
        {
					MetraTech.SecurityFramework.Core.Common.Logging.LoggingHelper.LogDebug("SampleAspNetApp:Test", "Page_Load");
            this.Response.Cookies.Add(new HttpCookie("test", "cookie"));
        }

        protected string GetText()
        {
            return File.ReadAllText(Server.MapPath("Text.txt"));
        }

		protected void btnTest_Click(object sender, EventArgs e)
		{
			string value = txtTest.Text;
			int circles = 10000;

			double parserMillisec = TestParser(value, circles);

			double regexMillisec = TestRegex(value, circles);

			lblTest.Text = regexResult;
			lblTest2.Text = Parse(value);
			double ratio = regexMillisec / parserMillisec;
			lblRatio.Text = Math.Round(ratio, 2).ToString();

			custEquals.IsValid = regexResult == parseResult;

			List<double> ratios = ViewState["Ratios"] as List<double> ?? new List<double>();
			ratios.Add(ratio);

			ViewState["Ratios"] = ratios;

			lblRatioAvg.Text = Math.Round(ratios.Count == 1 ? ratio : ratios.Skip(1).Average(), 2).ToString();
		}

		private double TestParser(string value, int circles)
		{
			DateTime startTime = DateTime.Now;

			for (int i = 0; i < circles; i++)
			{
				parseResult = Parse(value);
			}

			double result = (DateTime.Now - startTime).TotalMilliseconds;
			lblParseTime.Text = Math.Round((result / (circles / 1000)), 2).ToString();

			return result;
		}

		private double TestRegex(string value, int circles)
		{
			DateTime startTime = DateTime.Now;

			for (int i = 0; i < circles; i++)
			{
				regexResult = RegexParse(value);
			}

			double result = (DateTime.Now - startTime).TotalMilliseconds;
			lblRegexTime.Text = Math.Round((result / (circles / 1000)), 2).ToString();

			return result;
		}

		private string RegexParse(string value)
		{
			return testRegex.Replace(value, Evaluate);
		}

		private string Evaluate(Match value)
		{
			string result = null;
			Group g;
			
			g = value.Groups["word"];
			if (g.Success)
			{
				result = ParseChar(g.Value).ToString();
			}
			else
			{
				g = value.Groups["newLine"];
				if (g.Success)
				{
					result = Environment.NewLine;
				}
				else
				{
					g = value.Groups["escape"];
					result = g.Value;
				}
			}

			return result;
		}

		private static char ParseChar(string value)
		{
			return Convert.ToChar(int.Parse(value, NumberStyles.AllowHexSpecifier, CultureInfo.InvariantCulture));
		}

		private string Parse(string value)
		{
			StringBuilder result = new StringBuilder(value.Length);
			ParserStatus lastStatus = ParserStatus.None;

			for (int i = 0; i < value.Length; i++)
			{
				StringBuilder failedToken;
				switch ((lastStatus = ParseToken(value[i], out failedToken)))
				{
					case ParserStatus.None:
						result.Append(value[i]);
						break;
					case ParserStatus.Parsed:
						result.Append(_currentToken);
						break;
					case ParserStatus.ParsedPrev:
						result.Append(_currentToken);
						if (ParseToken(value[i], out failedToken) == ParserStatus.None)
						{
							result.Append(value[i]);
						}
						break;
					case ParserStatus.Failed:
						result.Append(failedToken);
						if (ParseToken(value[i], out failedToken) == ParserStatus.None)
						{
							result.Append(value[i]);
						}
						break;
					default: //ParserStatus.Parsing
						// Nothing to do here.
						break;
				}
			}

			if (lastStatus == ParserStatus.Parsing)
			{
				if (_parsingNumber.Length == 0)
				{
					result.Append(_parsingToken);
				}
				else
				{
					result.Append(ParseChar(_parsingNumber.ToString()));
				}
			}

			_parsingToken = null;
			_parsingNumber.Clear();

			return result.ToString();
		}

		private ParserStatus ParseToken(char token, out StringBuilder failedToken)
		{
			ParserStatus result;

			if (_parsingToken == null)
			{
				if (token == '\\')
				{
					result = ParserStatus.Parsing;
					_parsingToken = new StringBuilder(6);
					_parsingToken.Append(token);
				}
				else
				{
					result = ParserStatus.None;
				}
			}
			else
			{
				_parsingToken.Append(token);

				if (_parsingToken.Length == 2)
				{
						if (token == 'x' || token == 'u')
						{
							result = ParserStatus.Parsing;
						}
						else if (token == 'n')
						{
							_currentToken = Environment.NewLine[0];
							result = ParserStatus.Parsed;
						}
						else
						{
							_currentToken = token;
							result = ParserStatus.Parsed;
						}
				}
				else if (_parsingToken[1] == 'x' && "0123456789abcdefABCDEF".IndexOf(token) >= 0)
				{
					_parsingNumber.Append(token);
					result = _parsingToken.Length == 4 ? ParserStatus.Parsed : ParserStatus.Parsing;
				}
				else if (_parsingToken[1] == 'u' && "0123456789abcdefABCDEF".IndexOf(token) >= 0)
				{
					_parsingNumber.Append(token);
					result = _parsingToken.Length == 6 ? ParserStatus.Parsed : ParserStatus.Parsing;
				}
				else
				{
					result = ParserStatus.Failed;
				}
			}

			if (result == ParserStatus.Parsed && _parsingNumber.Length > 0)
			{
				_currentToken = ParseChar(_parsingNumber.ToString());
			}

			if (result == ParserStatus.Failed)
			{
				_parsingToken.Remove(_parsingToken.Length - 1, 1);
				_parsingToken.Remove(0, 1);
				failedToken = _parsingToken;
			}
			else
			{
				failedToken = null;
			}

			if (result != ParserStatus.Parsing)
			{
				_parsingToken = null;
				_parsingNumber.Clear();
			}

			return result;
		}
    }
}