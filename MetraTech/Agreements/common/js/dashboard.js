/* 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Scripts for rendering of fusion charts on the Metanga Dashboard. Created by Erik Egbertson
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
$(document).ready(function() {

  /* Churn History Spark Line  */
  var myChart21 = new FusionCharts("../common/charts/swf/SparkLine.swf","ID2-1", "100%", "60", "0", "0");
  myChart21.setDataURL("../common/charts/data/churn_history_dash.xml");
  myChart21.render("container_2-1");

  /* Days Outstanding Bullet Chart  */
	var myChart31 = new FusionCharts("../common/charts/swf/HBullet.swf","ID3-1", "100%", "60", "0", "0");
	myChart31.setDataURL("../common/charts/data/billing_daysoutstanding_dash.xml");
	myChart31.render("container_3-1");

  /* Enrollment History Spark Chart  */
	var myChart41 = new FusionCharts("../common/charts/swf/SparkLine.swf","ID4-1", "100%", "60", "0", "0");
	myChart41.setDataURL("../common/charts/data/enrollments_history_dash.xml");
	myChart41.render("container_4-1");

  /* Account Spark Bar Charts  */
  var myChart61 = new FusionCharts("../common/charts/swf/SparkColumn.swf", "ID6-1", "100%", "45", "0", "0");
  myChart61.setDataURL("../common/charts/data/account_history_dash.xml");
  myChart61.render("container_6-1");

  var myChart62 = new FusionCharts("../common/charts/swf/SparkColumn.swf", "ID6-2", "100%", "45", "0", "0");
  myChart62.setDataURL("../common/charts/data/account_history_dash.xml");
  myChart62.render("container_6-2");

  var myChart63 = new FusionCharts("../common/charts/swf/SparkColumn.swf", "ID6-3", "100%", "45", "0", "0");
  myChart63.setDataURL("../common/charts/data/account_history_dash.xml");
  myChart63.render("container_6-3");

  var myChart64 = new FusionCharts("../common/charts/swf/SparkColumn.swf", "ID6-4", "100%", "45", "0", "0");
  myChart64.setDataURL("../common/charts/data/account_history_dash.xml");
  myChart64.render("container_6-4");
  
  var myChart65 = new FusionCharts("../common/charts/swf/SparkColumn.swf", "ID6-5", "100%", "45", "0", "0");
  myChart65.setDataURL("../common/charts/data/account_history_dash.xml");
  myChart65.render("container_6-5");

  /* Product Spark Bar Charts  */
  var myChart71 = new FusionCharts("../common/charts/swf/SparkColumn.swf","ID7-1", "100%", "45", "0", "0");
  myChart71.setDataURL("../common/charts/data/product_history_dash.xml");
  myChart71.render("container_7-1");

  var myChart72 = new FusionCharts("../common/charts/swf/SparkColumn.swf","ID7-2", "100%", "45", "0", "0");
  myChart72.setDataURL("../common/charts/data/product_history_dash.xml");
  myChart72.render("container_7-2");

  var myChart73 = new FusionCharts("../common/charts/swf/SparkColumn.swf","ID7-3", "100%", "45", "0", "0");
  myChart73.setDataURL("../common/charts/data/product_history_dash.xml");
  myChart73.render("container_7-3");

  var myChart74 = new FusionCharts("../common/charts/swf/SparkColumn.swf","ID7-4", "100%", "45", "0", "0");
  myChart74.setDataURL("../common/charts/data/product_history_dash.xml");
  myChart74.render("container_7-4"); 

  var myChart75 = new FusionCharts("../common/charts/swf/SparkColumn.swf","ID7-5", "100%", "45", "0", "0");
  myChart75.setDataURL("../common/charts/data/product_history_dash.xml");
  myChart75.render("container_7-5");

  /* Subscription Expiration Stacked Column Chart  */	
	var myChart81 = new FusionCharts("../common/charts/swf/StackedColumn2D.swf","ID8-1", "100%", "260", "0", "0");
	myChart81.setDataURL("../common/charts/data/subscription_expirations_dash.xml");
	myChart81.render("container_8-1");
						   
}); // =End