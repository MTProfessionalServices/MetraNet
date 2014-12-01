
function fnVisualizeLineChart(objLineChartConfig) {

    this.data = objLineChartConfig.data;
	var that = this;

    this.margin = { top: objLineChartConfig.margin.top, right: objLineChartConfig.margin.right, bottom: objLineChartConfig.margin.bottom, left: objLineChartConfig.margin.left };
    this.width = objLineChartConfig.width - this.margin.left - this.margin.right;
    this.height = objLineChartConfig.height - this.margin.top - this.margin.bottom;

    this.Y_AXIS_LABEL = objLineChartConfig.yAxisLabel;
    this.X_AXIS_LABEL = objLineChartConfig.xAxisLabel;

    this.X_AXIS_COLUMN = objLineChartConfig.xAxisColumn;
    this.Y_AXIS_COLUMN = objLineChartConfig.yAxisColumn;

    this.ignoreColumns = objLineChartConfig.ignoreColumns;

    this.color = d3.scale.category10();

    this.x = d3.scale.linear().range([0, this.width]);

    //var x = d3.time.scale().range([0, width]);
    this.y = d3.scale.linear().range([this.height, 0]);

    this.color.domain(d3.keys(this.data[0]).filter(function (key) {
        var include = true;

        if (that.ignoreColumns != null) {
            for (var i = 0; i < that.ignoreColumns.length; i++) {
                include = include && (key !== that.ignoreColumns[i]);
            }
        }

        return (include && key !== that.X_AXIS_COLUMN);

    }));

	this.getSeries = getSeries;
	function getSeries ()
	{
		return that.color.domain().map(function (name) {
			var colorData = {
				name: name,
				values: that.data.map(function (d) {
					var dataObj = { x_axis: d[that.X_AXIS_COLUMN], y_axis: +d[name] };
					return dataObj;
				}
				   )
			};

			return colorData;
		});
	}
	
    this.series = getSeries ();

    //  x.domain([d3.extent(data, function (d) { return d[X_AXIS_COLUMN]; }),0]);

    this.x.domain([
           d3.max(this.series, function (c) { return d3.max(c.values, function (v) { return v.x_axis; }); }),
            d3.min(this.series, function (c) { return d3.min(c.values, function (v) { return v.x_axis; }); })
         ]);

    this.y.domain([
            d3.min(this.series, function (c) { return d3.min(c.values, function (v) { return v.y_axis; }); }),
            d3.max(this.series, function (c) { return d3.max(c.values, function (v) { return v.y_axis; }); })
        ]);


    this.xAxis = d3.svg.axis()
            .scale(this.x)
            .orient("bottom")
           // .tickFormat("")
           // .ticks(0);

    this.yAxis = d3.svg.axis()
            .scale(this.y)
            .orient("left")
           // .tickFormat("")
           // .ticks(0);

    this.svg = d3.select(objLineChartConfig.elementId)
            .attr("width", this.width + this.margin.left + this.margin.right)
            .attr("height", this.height + this.margin.top + this.margin.bottom)
            .append("g")
            .attr("transform", "translate(" + this.margin.left + "," + this.margin.top + ")");

    this.svg.append("text")
            .attr("x", (this.width / 2))
            .attr("y", 0 - (this.margin.top / 2))
            .attr("text-anchor", "middle")
            .style("font-weight", "bold")
            .text(objLineChartConfig.chartTitle);

    this.svg.append("g")
              .attr("class", "x axis")
              .attr("transform", "translate(0," + this.height + ")")
              .call(this.xAxis)
     .append("text")
    .attr("x", this.width)
    .attr("y", this.margin.bottom)
    .attr("dx", ".75em")
    .style("text-anchor", "end");
    //.text(this.X_AXIS_LABEL);*/

    this.svg.append("g")
              .attr("class", "y axis")
               .call(this.yAxis)
              .append("text")
              .attr("transform", "rotate(-90)")
              .attr("y", -this.margin.left)
              .attr("dy", ".75em")
              .style("text-anchor", "end");
    // .text(this.Y_AXIS_LABEL);

    this.line = d3.svg.line()
                .interpolate("linear")
                .x(function (d) { return that.x(d.x_axis); })
                .y(function (d) { return that.y(d.y_axis); });

	this.updateData = updateData;
	function updateData()
	{
		that.series = getSeries ();
		
		that.x.domain([
			   d3.max(that.series, function (c) { return d3.max(c.values, function (v) { return v.x_axis; }); }),
				d3.min(that.series, function (c) { return d3.min(c.values, function (v) { return v.x_axis; }); })
			 ]);

		that.y.domain([
				d3.min(that.series, function (c) { return d3.min(c.values, function (v) { return v.y_axis; }); }),
				d3.max(that.series, function (c) { return d3.max(c.values, function (v) { return v.y_axis; }); })
			]);

		that.xAxis.scale(that.x);
		that.yAxis.scale(that.y);

//        that.line.x(function (d) { return that.x(d.x_axis); })
//			.y(function (d) { return that.y(d.y_axis); });

		var currLine = that.svg.selectAll(".currLine")
				  .data([]);
		currLine.exit().remove();
		currLine = that.svg.selectAll(".currLine")
				  .data(that.series);
		
		var currEnter = currLine.enter().append("g")
				  .attr("class", "currLine");

		currEnter.append("path")
				  .attr("class", "line")
				  .attr("d", function (d) { return that.line(d.values); })
				  .style("stroke", function (d) { return that.color(d.name); });

		currEnter.append("text")
			  .datum(function (d) { return { name: d.name, value: d.values[d.values.length - 1] }; })
			  .attr("transform", function (d) { return "translate(" + that.x(d.value.x_axis) + "," + that.y(d.value.y_axis) + ")"; })
			  .attr("x", 3)
			  .attr("dy", ".35em");
		//.text(function (d) { return d.name; });
	}
	
	that.updateData ();
}



function fnVisualizeLineChart2(objLineChartConfig) {
    d3.select(objLineChartConfig.elementId).selectAll("svg > *").remove();
    var data = objLineChartConfig.data;
    var colordata = objLineChartConfig.colordata;

    var margin = { top: objLineChartConfig.margin.top, right: objLineChartConfig.margin.right, bottom: objLineChartConfig.margin.bottom, left: objLineChartConfig.margin.left };
    var width = objLineChartConfig.width - margin.left - margin.right;
    var height = objLineChartConfig.height - margin.top - margin.bottom;

    var Y_AXIS_LABEL = objLineChartConfig.yAxis["Label"];
    var X_AXIS_LABEL = objLineChartConfig.xAxis["Label"];

    var X_AXIS_COLUMN = objLineChartConfig.xAxis["Column"];
    var Y_AXIS_COLUMN = objLineChartConfig.yAxis["Column"];

    var ignoreColumns = objLineChartConfig.yAxis["IgnoreColumns"];

    var color = d3.scale.category10();

    var x;
    
    if(objLineChartConfig.xAxis["Scale"] == "time")
        x = d3.time.scale().range([0, width]);
    else   
        x= d3.scale.linear().range([0, width]);

    var y = d3.scale.linear().range([height, 0]);



    color.domain(d3.keys(data[0]).filter(function (key) {
        var include = true;

        if (ignoreColumns != null) {
            for (var i = 0; i < ignoreColumns.length; i++) {
                include = include && (key !== ignoreColumns[i]);

            }
        }

        return (include && key !== X_AXIS_COLUMN);

    }));

    var series = color.domain().map(function (name) {
        var colorData = {
            name: name,
            values: data.map(function (d) {
                var dataObj = { x_axis: d[X_AXIS_COLUMN], y_axis: +d[name] , name : d.adapter};
                return dataObj;
            }
               )
        };

        return colorData;
    });



    //  x.domain([d3.extent(data, function (d) { return d[X_AXIS_COLUMN]; }),0]);

    if (objLineChartConfig.xAxis["Reverse"] == "true") {
        x.domain([
           d3.max(series, function (c) { return d3.max(c.values, function (v) { return v.x_axis; }); }),
            d3.min(series, function (c) { return d3.min(c.values, function (v) { return v.x_axis; }); })
         ]);
    }
    else {
        x.domain([
           d3.min(series, function (c) { return d3.max(c.values, function (v) { return v.x_axis; }); }),
            d3.max(series, function (c) { return d3.min(c.values, function (v) { return v.x_axis; }); })
         ]);
    }

    y.domain([
            d3.min(series, function (c) { return d3.min(c.values, function (v) { return v.y_axis; }); }),
            d3.max(series, function (c) { return d3.max(c.values, function (v) { return v.y_axis; }); })
        ]);


    var xAxis = d3.svg.axis()
            .scale(x)
            .orient("bottom")
            .tickSize(0,0)
            .tickFormat("")
			;

    var yAxis = d3.svg.axis()
            .scale(y)
            .orient("left")
            .tickSize(0,0)
            .tickFormat("")
			;

    var svg = d3.select(objLineChartConfig.elementId)
            .attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom)
            .append("g")
            .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    svg.append("text")
            .attr("x", (width / 2))
            .attr("y", 0 - (margin.top / 2))
            .attr("text-anchor", "middle")
            .style("font-weight", "bold")
            .style("color", "#1F4978")
            .text(objLineChartConfig.chartTitle);

    svg.append("g")
              .attr("class", "x axis")
              .attr("transform", "translate(0," + height + ")")
              .call(xAxis)
     .append("text")
    .attr("x", width)
    .attr("y", margin.bottom)
    .attr("dx", ".75em")
    .style("text-anchor", "end");
    //.text(X_AXIS_LABEL);

    svg.append("g")
              .attr("class", "y axis")
               .call(yAxis)
              .append("text")
              .attr("transform", "rotate(-90)")
              .attr("y", -margin.left)
              .attr("dy", ".75em")
              .style("text-anchor", "end");
    // .text(Y_AXIS_LABEL);

    var line = d3.svg.line()
                .interpolate("linear")
                .x(function (d) { return x(d.x_axis); })
                .y(function (d) { return y(d.y_axis); });


    var currLine = svg.selectAll(".currLine")
              .data(series)
            .enter().append("g")
              .attr("class", "currLine");

    currLine.append("path")
              .attr("class", "line")
              .attr("d", function (d) { return line(d.values); })
              .style("stroke", function (d) {
                  if (colordata && colordata[d.name] != null)
                      return colordata[d.name];
                  else
                      return color(d.name);
              });

    currLine.append("text")
          .datum(function (d) { return { name: d.name, value: d.values[d.values.length - 1] }; })
          .attr("transform", function (d) { return "translate(" + x(d.value.x_axis) + "," + y(d.value.y_axis) + ")"; })
          .attr("x", 3)
          .attr("dy", ".35em");

          
          var mygforeachline = currLine.append("g")          
          .attr("class","dc-tooltip-0");
          
          var inners = mygforeachline.selectAll("circle")
          .data(function (d) { return d.values;})
          .enter()
          .append("circle").attr("cx",function (d) { return x(d.x_axis);})
          .attr("cy",function (d) { return y(d.y_axis);})
          .attr("class", "dot")
          .attr("r", "3")
          .attr("fill","#00B0F0")
          .style("fill-opacity", "0.3")
          .style("stroke-opacity", "0.6")
          .append("title").text(function (d) { return  d.name + " : " + d.y_axis +" Seconds";});
    return this;
}


//CreateLegend('legend', svglegend);

function CreateLegend(data,svglegend) {
    
    rectangle = svglegend.selectAll("rect").data(data).enter().append("rect");
    var RectangleAttrb = rectangle.attr("x", function (d) { return d.x_axis; })
                       .attr("y", function (d) { return d.y_axis; })
                       .attr("width", 30)
                       .attr("height", 10)
                       .style("fill", function (d) { return d.color; });




    var textparam = svglegend.selectAll("text").data(data).enter().append("text");

    var text = textparam.attr("x", function (d) { return d.x_axis + 30 + 10; })
                       .attr("y", function (d) { return d.y_axis + 10 ; })
                       .attr("width", 30)
                       .attr("height", 10)
                       .text(function (d) { return d.text; });
}


function fnVisualizePieChart(objPieChartConfig) {


    var data = objPieChartConfig.data;
    var colordata = objPieChartConfig.colordata;


    var margin = { top: objPieChartConfig.margin.top, right: objPieChartConfig.margin.right, bottom: objPieChartConfig.margin.bottom, left: objPieChartConfig.margin.left };
    var width = objPieChartConfig.width - margin.left - margin.right;
    var height = objPieChartConfig.height - margin.top - margin.bottom;

    var SEGMENT = objPieChartConfig.segment;
    var DATA = objPieChartConfig.datafield;


    radius = Math.min(width, height) / 3;

    var color = d3.scale.ordinal()
           .range(["blue", "red", "yellow"]);

    data.forEach(function (d) {
        d[DATA] = +d[DATA];
    });

    var arc = d3.svg.arc()
            .outerRadius(radius - 10)
            .innerRadius(0);

    var pie = d3.layout.pie()
            .sort(null)
            .value(function (d) { return d[DATA]; });

    var svg = d3.select(objPieChartConfig.elementId)
            .attr("width", width)
            .attr("height", height)
            .append("g")
            .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");


    svg.append("text")
            .attr("x", 0)
            .attr("y", -(height + margin.top) / 3)
            .attr("text-anchor", "middle")
            .style("font-weight", "bold")
            .text(objPieChartConfig.chartTitle);



    var g = svg.selectAll(".arc")
              .data(pie(data))
              .enter().append("g")
              .attr("class", "arc");

    var count = 0;

    g.append("path")
              .attr("d", arc)
              .attr("id", function (d) { return "arc-" + (count++); })
              .style("fill", function (d) {
                 if(colordata && colordata[d.data[SEGMENT]])
                    return(colordata[d.data[SEGMENT]]);
                  else
                    return color(d.data[SEGMENT]);
              });

    g.append("text").attr("transform", function (d) {
        return "translate(" + arc.centroid(d) + ")";
    }).attr("dy", ".35em").style("text-anchor", "middle")
    //          .text(function(d) {
    //              return d.data[DATA];
    //          })
          ;


    /*count = 0;

    var legend = svg.selectAll(".legend")
              .data(data).enter()
              .append("g")
              .attr("class", "legend")
              .attr("legend-id", function (d) {
                  return count++;
              })
              .attr("transform", function (d, i) {
                  return "translate(-50," + (-70 + i * 20) + ")";
              })


    legend.append("rect")
              .attr("x", -40)
              .attr("width", 18)
              .attr("height", 18)
              .style("fill", function (d) {
                  return colordata[d[SEGMENT]];
              });

    legend.append("text")
              .attr("x", -50)
              .attr("y", 9)
              .attr("dy", ".35em")
              .style("text-anchor", "end").text(function (d) {
                  return d[SEGMENT];
              });
              
              */
}


function fnVisualizeBarChart(objBarChartConfig) {

    var data = objBarChartConfig.data;
    var colordata = objBarChartConfig.colordata;


    var margin = { top: objBarChartConfig.margin.top,
        right: objBarChartConfig.margin.right,
        bottom: objBarChartConfig.margin.bottom,
        left: objBarChartConfig.margin.left
    };

    var width = objBarChartConfig.width - margin.left - margin.right;
    var height = objBarChartConfig.height - margin.top - margin.bottom;

    var Y_AXIS_LABEL = objBarChartConfig.yAxis["Label"];
    var X_AXIS_LABEL = objBarChartConfig.xAxis["Label"];

    var X_AXIS_COLUMN = objBarChartConfig.xAxis["Column"];
    var Y_AXIS_COLUMN = objBarChartConfig.yAxis["Column"];



    var x = d3.scale.ordinal()
     .rangeRoundBands([0, width], .1);
    // .range([0,width]);

    var y = d3.scale.linear()
    .range([height, 0]);

    var xAxis = d3.svg.axis()
    .scale(x)
    .orient("bottom")
    .ticks(0)
    .tickFormat("");

    var yAxis = d3.svg.axis()
    .scale(y)
    .orient("left")
    .ticks(0);

    var svg = d3.select(objBarChartConfig.elementId)
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");


    x.domain(data.map(function (d) { return d[X_AXIS_COLUMN]; }));
    y.domain([0, d3.max(data, function (d) { return d[Y_AXIS_COLUMN]; })]);

    svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis);

    svg.append("g")
      .attr("class", "y axis")
      .call(yAxis)
    .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end")
      .text("");

    svg.selectAll(".bar")
      .data(data)
    .enter().append("rect")
      .attr("class", "bar")
      .attr("x", function (d) { return x(d[X_AXIS_COLUMN]); })
      .attr("width", x.rangeBand())
      .attr("y", function (d) { return y(d[Y_AXIS_COLUMN]); })
      .attr("height", function (d) { return height - y(d[Y_AXIS_COLUMN]); })
      .style("fill", function (d) {
          return colordata[d[X_AXIS_COLUMN]];
      }
             );

}
