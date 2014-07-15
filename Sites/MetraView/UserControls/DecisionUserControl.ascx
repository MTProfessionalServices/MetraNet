<%@ Control Language="C#" AutoEventWireup="true" CodeFile="DecisionUserControl.ascx.cs"
  Inherits="UserControls_DecisionUserControl" %>
<style>
  button
  {
    position: static;
    right: 10px;
    top: 10px;
  }
  .bullet
  {
    font: 10px sans-serif;
  }
  .bullet .marker
  {
    stroke: #000;
    stroke-width: 3px;
  }
  .bullet .marker.good
  {
    stroke: Green;
    stroke-width: 3px;
    stroke-dasharray: 2,1;
  }
  .bullet .marker.bad
  {
    stroke: Red;
    stroke-width: 3px;
    stroke-dasharray: 2,1;
  }
  .bullet .marker.past
  {
    stroke: Blue;
    stroke-width: 3px;
    stroke-dasharray: 2,1;
  }
  .bullet .tick line
  {
    stroke: #666;
    stroke-width: .5px;
  }
  .bullet .tick.major line
  {
    stroke: #666;
    stroke-width: .5px;
  }
  .bullet .tick.selected
  {
    font-weight:bolder;
  }
  .bullet .tick.expired
  {
    text-decoration:line-through;
  }
  .bullet .tick.future
  {
    font-style:italic;
  }
  .bullet .domain
  {
    fill: none;
  }
  .bullet .title
  {
    fill: #000;
    display: block;
    font-size: 14px;
    font-weight: bold;
    position: absolute;
    text-anchor: off;
  }
  .bullet .range.s0
  {
    display: block;
    position: absolute;
  }
  .bullet .subtitle
  {
    fill: #999;
    text-anchor: off;
  }
  .bullet .dates
  {
    fill: #000;
    text-anchor: off;
  }
  .bullet .tbutton
  {
    fill:white;
    stroke-width:1;
    stroke:black;
    stroke-opacity:0.05;
  }
  .bullet .notice
  {
    fill:#000;
    font-size: 7px;
    text-anchor: off;
  }
  .bullet .tick
  {
    fill:#000;
  }
.contextmenu {
-moz-border-radius:10px;
-webkit-border-radius:10px;
-khtml-border-radius:10px;
border-radius:10px;
}
.contextmenu li
{
  list-style-type:none;
  padding-left: 20px;
  padding-right: 5px;
}
.contextmenu li:hover
{
  font-weight:bolder;
}
.datepicker {
-moz-border-radius:10px;
-webkit-border-radius:10px;
-khtml-border-radius:10px;
border-radius:10px;
overflow-y:auto;
overflow-x:visible;
max-height: 100px;
}
.datepicker li
{
  list-style-type:none;
  padding-left: 20px;
  padding-right: 5px;
white-space:nowrap;
}
.datepicker li:hover
{
  font-weight:bolder;
}
</style>
<script src="/Res/JavaScript/d3.v3.min.js"></script>
<script src="/Res/JavaScript/Bullet.js"></script>
<script>

  function populateDatePicker(id) {
    clearDatePickers(); 
    var dp = document.getElementById(id);
    var old = dp.innerHTML;
    dp.innerHTML = "";
    var div = d3.select("#" + id);
    div.on("click", null);
    div.style("overflow-y","auto");
    div.style("overflow-x","visible");
    var ul = div.append("ul").style("margin-left", "0px").style("margin-right", "10px").style("padding-left", "0px");
    ul.append("li").style("background", "url(/Res/images/icons/ui_radio_button.png) left center no-repeat").attr("datepickerid", id).attr("interval", div.attr("interval")).attr("title", "Interval " + div.attr("interval")).attr("selected", "true").on("click", function () { var ul = d3.select(this); /*console.log("" + ul.text() + " " + ul.attr("datepickerid"));*/ document.getElementById(ul.attr("datepickerid")).innerHTML = ul.text(); d3.select("#" + ul.attr("datepickerid")).style("overflow", "hidden").attr("title", "Interval " + ul.attr("interval")).attr("interval", ul.attr("interval")).on("click", function () { populateDatePicker(ul.attr("datepickerid")); }); d3.event.preventDefault(); d3.event.stopPropagation(); }).text(old);
//    ul.append("li").style("background", "url(/Res/images/icons/ui_radio_button_uncheck.png) left center no-repeat").attr("datepickerid", id).attr("interval", 90133432).attr("title", "Interval 90133432").on("click", function () { var ul = d3.select(this); console.log("" + ul.text() + " " + ul.attr("datepickerid")); document.getElementById(ul.attr("datepickerid")).innerHTML = ul.text(); d3.select("#" + ul.attr("datepickerid")).on("click", function () { populateDatePicker(ul.attr("datepickerid")); }); d3.event.preventDefault(); d3.event.stopPropagation(); }).text("February 28, 2012 - February 27, 2013");
    d3.event.preventDefault();
  }

  function selectDatePicker() {
  }

  function clearDatePickers() {
    d3.selectAll(".datepicker").each(function (d, i) {
      var div = d3.select(this);
      var ul = div.select("ul");
      if (!ul.empty()) {
        var sel = ul.select("li[selected='true']");
        if (!sel.empty()) {
          var txt = sel.text();
          div.text(txt).attr("title", "Interval 97773432").style("right", "0px").style("text-anchor", "end");
          div.style("overflow", "hidden");
        }
        div.on("click", function () { populateDatePicker(div.attr("id")); });
      }
    });

  }

  var margin = { top: 25, right: 50, bottom: 20, left: 25 },
    width = 510 - margin.left - margin.right,
    height = 70 - margin.top - margin.bottom;

  var chart = d3.bullet()
    .width(width)
    .height(height);

  d3.json("<%=Request.ApplicationPath%>/AjaxServices/DecisionService.aspx?_=" + new Date().getTime(), function (error, data) {
    var svg = d3.select("#NowCast-body").selectAll("svg")
      .data(data)
    .enter().append("svg")
      .attr("class", "bullet")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom + 35);
    svg.append("rect").attr("width", width + margin.right - 10).attr("height", height + margin.top + margin.bottom + 30).attr("fill", "white").attr("fill-opacity", 0);
    svg
      .on("contextmenu", function (d, i) {
        d3.selectAll(".bullet .contextmenu").attr("display", "none");
        var cm = d3.select("#contextmenu" + 0)
                                                .style("display", "block")
                                                .style("left", d3.event.pageX + "px")
                                                .style("top", d3.event.pageY + "px")
                                                ;
        d3.event.preventDefault();
        return false;
      });
    svg = svg.append("g")
      .attr("transform", "translate(" + margin.left + "," + (margin.top + 20) + ")")
      .call(chart);

    var title = svg.append("g")

      .attr("transform", "translate(-6," + 1.35 * -height + ")");

    title.append("text")
      .attr("class", "title")
      .attr("dx", "-1em")
      .text(function (d) { return d.title; });

    title.append("text")
      .attr("class", "subtitle")
      .attr("dx", "-1em")
      .attr("dy", "1.2em")
      .text(function (d) { return d.subtitle; });

    //title.append("text")
    //  .attr("class", "notice")
    //  .attr("x", width + margin.left)
    //  .attr("y", 3.4 * height)
    //  .attr("text-anchor", "end")
    //  .text(TEXT_NOWCAST_RIGHT_CLICK_FOR_OPTIONS);

    var svgd = svg.data();
    if ((typeof svgd === 'undefined') || svgd === undefined || svgd == null || svgd.length == 0) {
      d3.select("#NowCast-body").append("text").text(NO_DECISIONS_TEXT);
      return;
    }

    var cnt = 0;
    if (title != null && title.length > 0) {
      cnt = title[0].length;
    }
    title.each(function (d, i) {
      var bdy = document.getElementById("NowCast-body");
      var rect = bdy.getBoundingClientRect();
      var span = d3.select("#NowCast-body").append("span").style("position", "relative");
      span.style("top", -((cnt * 100) + 11) + "px");
      if (Object.hasOwnProperty.call(window, "ActiveXObject") && !window.ActiveXObject) {
        span.style("right", "+40px");
      } 
      else if (navigator.userAgent.toLowerCase().indexOf('firefox') > -1) {
        span.style("right", "+40px");
      }
      else {
        span.style("right", "-480px");
      }
      var button = span.append("div");
      button.attr("class", "datepicker").style("white-space", "nowrap").style("display", "inline-block").attr("id", "datepicker" + i).style("width", "auto").style("position", "absolute").style("background-color", "#fff").style("border", "dotted").style("border-width", "1px").style("border-color", "#aaa").style("padding", "0px").style("padding-left", "2px").style("padding-right", "2px").style("margin", "0px");
      if (i == 0) {
        //        button.style("top", -((cnt * 100) + 41) + "px"); //.style("right", "-300px");
        button.style("top", ((i * 108) - 25) + "px"); //.style("right", "-300px");
      }
      else {
        button.style("top", ((i * 108) - 25) + "px"); //.style("right", "-300px");
      }
      button.attr("interval", d.intervalId);
      button.text(d.datesLabel).attr("title", "Interval " + d.intervalId).style("right", "0px").style("text-anchor", "end");
      span.on("contextmenu", function (d, i) {
        d3.selectAll(".bullet .contextmenu").attr("display", "none");
        var cm = d3.select("#contextmenu" + 0)
                                                .style("display", "block")
                                                .style("left", d3.event.pageX + "px")
                                                .style("top", d3.event.pageY + "px")
                                                ;
        d3.event.preventDefault();
        return false;
      });
    });

    d3.selectAll(".datepicker").on("click", function (d, i) {
      populateDatePicker("datepicker" + i);
    });

    var divs = d3.select("#NowCast-body").append("div").attr("id", function (d, i) { return "contextmenu" + i; }).attr("class", "contextmenu").style("display", "none").style("top", "150px").style("left", "400px").style("position", "absolute").style("background-color", "#fff").style("border", "solid").style("border-width", "3px").style("padding", "2px");
    var ul = divs.append("ul").attr("class", "contextmenulist").style("margin-left", "0px").style("padding-left", "0px");
    //    ul.append("li").attr("class", "contextmenuitem").style("background", "url(/Res/images/icons/checkbox_yes.png) left center no-repeat").text("Include Previous Results");
    //    ul.append("li").attr("class", "contextmenuitem").style("background", "url(/Res/images/icons/checkbox_no.png) left center no-repeat").text("Include Projected Results");
    //    ul.append("li").attr("class", "contextmenuitem").style("background", "url(/Res/images/icons/arrow_redo.png) left center no-repeat").text("Redraw").on('click', function () { console.log("redraw"); svg.call(chart); });
    //ul.append("li").attr("class", "contextmenuitem").style("background", "url(/Res/images/icons/arrow_refresh_small.png) left center no-repeat").text(TEXT_NOWCAST_REFRESH).on('click', function () {
    //  d3.json("<%=Request.ApplicationPath%>/AjaxServices/DecisionService.aspx?_=" + new Date().getTime(), function (error, data) {
    //    var svg = d3.select("#NowCast-body").selectAll("svg")
    //  .data(data); svg.call(chart);
    //  });
    //});

    d3.select("body").on('click', function (d, i) { d3.selectAll(".contextmenu").style("display", "none"); d3.selectAll(".bullet .tbutton").attr("height", 13); });
    d3.select("body").on('contextmenu', function (d, i) { clearDatePickers(); });
    //    d3.selectAll("button").on("click", function () {
    //      svg.datum(randomize).call(chart.duration(1000)); // TODO automatic transition
    //    });
  });
  </script>
