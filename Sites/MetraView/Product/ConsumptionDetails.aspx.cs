using System;
using System.Text.RegularExpressions;
using MetraTech.UI.Common;

namespace MetraView.Product
{
  public partial class ConsumptionDetails : MTPage
  {
    protected void Page_Load(object sender, EventArgs e)
    {

    }
    
    
    
    protected string FixJsonDate(string input)
    {
      MatchEvaluator me = MTListServicePage.MatchDate;
      string json = Regex.Replace(input, "\\\\/\\Date[(](-?\\d+)[)]\\\\/", me, RegexOptions.None);
      return json;
    }

    protected string GetJsonData()
    {
      var json = @"{
    ""IncludedQuantity"": 0.45,
    ""Days"": [
        {
            ""Date"": ""\/Date(1281844800000)\/"",
            ""DayOfWeek"": ""Sunday"",
            ""Quantity"": 0.000435
        },
        {
            ""Date"": ""\/Date(1281931200000)\/"",
            ""DayOfWeek"": ""Monday"",
            ""Quantity"": 0.002345
        },
        {
            ""Date"": ""\/Date(1282017600000)\/"",
            ""DayOfWeek"": ""Tuesday"",
            ""Quantity"": 0.040435
        },
        {
            ""Date"": ""\/Date(1282104000000)\/"",
            ""DayOfWeek"": ""Wednesday"",
            ""Quantity"": 0.003234
        },
        {
            ""Date"": ""\/Date(1282190400000)\/"",
            ""DayOfWeek"": ""Thursday"",
            ""Quantity"": 0.000234
        },
        {
            ""Date"": ""\/Date(1282276800000)\/"",
            ""DayOfWeek"": ""Friday"",
            ""Quantity"": 0.000435
        },
        {
            ""Date"": ""\/Date(1282363200000)\/"",
            ""DayOfWeek"": ""Saturday"",
            ""Quantity"": 0.008234
        },
        {
            ""Date"": ""\/Date(1282449600000)\/"",
            ""DayOfWeek"": ""Sunday"",
            ""Quantity"": 0.003941
        },
        {
            ""Date"": ""\/Date(1282536000000)\/"",
            ""DayOfWeek"": ""Monday"",
            ""Quantity"": 0.157347
        },
        {
            ""Date"": ""\/Date(1282622400000)\/"",
            ""DayOfWeek"": ""Tuesday"",
            ""Quantity"": 0.007373
        },
        {
            ""Date"": ""\/Date(1282708800000)\/"",
            ""DayOfWeek"": ""Wednesday"",
            ""Quantity"": 0.000426
        },
        {
            ""Date"": ""\/Date(1282795200000)\/"",
            ""DayOfWeek"": ""Thursday"",
            ""Quantity"": 0.001235
        },
        {
            ""Date"": ""\/Date(1282881600000)\/"",
            ""DayOfWeek"": ""Friday"",
            ""Quantity"": 0.293123
        },
        {
            ""Date"": ""\/Date(1282968000000)\/"",
            ""DayOfWeek"": ""Saturday"",
            ""Quantity"": 0.000234
        },
        {
            ""Date"": ""\/Date(1283054400000)\/"",
            ""DayOfWeek"": ""Sunday"",
            ""Quantity"": 0.012947
        },
        {
            ""Date"": ""\/Date(1283140800000)\/"",
            ""DayOfWeek"": ""Monday"",
            ""Quantity"": 0.045712
        },
        {
            ""Date"": ""\/Date(1283227200000)\/"",
            ""DayOfWeek"": ""Tuesday"",
            ""Quantity"": 0.002347
        },
        {
            ""Date"": ""\/Date(1280635200000)\/"",
            ""DayOfWeek"": ""Sunday"",
            ""Quantity"": 0.093737
        },
        {
            ""Date"": ""\/Date(1280721600000)\/"",
            ""DayOfWeek"": ""Monday"",
            ""Quantity"": 0.012341
        },
        {
            ""Date"": ""\/Date(1280808000000)\/"",
            ""DayOfWeek"": ""Tuesday"",
            ""Quantity"": 0.000029
        },
        {
            ""Date"": ""\/Date(1280894400000)\/"",
            ""DayOfWeek"": ""Wednesday"",
            ""Quantity"": 0.080003
        },
        {
            ""Date"": ""\/Date(1280980800000)\/"",
            ""DayOfWeek"": ""Thursday"",
            ""Quantity"": 0.120234
        },
        {
            ""Date"": ""\/Date(1281067200000)\/"",
            ""DayOfWeek"": ""Friday"",
            ""Quantity"": 0.072529
        },
        {
            ""Date"": ""\/Date(1281153600000)\/"",
            ""DayOfWeek"": ""Saturday"",
            ""Quantity"": 0.100048
        },
        {
            ""Date"": ""\/Date(1281240000000)\/"",
            ""DayOfWeek"": ""Sunday"",
            ""Quantity"": 0.000237
        }
    ]
};";
      json = FixJsonDate(json);
      return json;
    }
  }
}