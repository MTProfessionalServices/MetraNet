(function() {

// Chart design based on the recommendations of Stephen Few. Implementation
// based on the work of Clint Ivy, Jamie Love, and Jason Davies.
// http://projects.instantcognition.com/protovis/bulletchart/
d3.bullet = function() {
  var orient = "left", // TODO top & bottom
      reverse = false,
      duration = 850,
	  delay = 200,
      ranges = bulletRanges,
      markers = bulletMarkers,
      measures = bulletMeasures,
	  rangeTitles = bulletRangeTitles,
	  markerTitles = bulletMarkerTitles,
	  measureTitles = bulletMeasureTitles,
	  rangeTicks = bulletRangeTicks,
	  markerClass = bulletMarkerClass,
	  rangeClass = bulletRangeClass,
	  measureRanges = bulletMeasureRanges,
      width = 380,
      height = 30,
      tickFormat = null;

  // For each small multiple…
  function bullet(g) {
    g.each(function(d, i) {
      var rangez = ranges.call(this, d, i).slice()/*.sort(d3.descending)*/,
          markerz = markers.call(this, d, i).slice()/*.sort(d3.descending)*/,
          measurez = measures.call(this, d, i).slice()/*.sort(d3.descending)*/,
          rangeTitlez = rangeTitles.call(this, d, i).slice(),
          markerTitlez = markerTitles.call(this, d, i).slice(),
          measureTitlez = measureTitles.call(this, d, i).slice(),
		  rangeTickz = rangeTicks.call(this, d, i).slice(),
		  markerClazz = markerClass.call(this, d, i).slice(),
		  rangeClazz = rangeClass.call(this, d, i).slice(),
		  measureRangez = measureRanges.call(this, d, i).slice(),
	      x0Measures = new Array(),
	      x1Measures = new Array(),
	      x0Ranges = new Array(),
	      x1Ranges = new Array(),
          g = d3.select(this);

       x0Measures[0] = 0;
       x1Measures[0] = 0;
       x0Ranges[0] = 0;
       x1Ranges[0] = 0;
      // Compute the new x-scale.
      var x1 = d3.scale.linear()
          .domain([0, Math.max(rangez[rangez.length-1], markerz[markerz.length-1], measurez[measurez.length-1])])
          .range(reverse ? [width, 0] : [0, width]);

      // Retrieve the old x-scale, if this is an update.
      var x0 = this.__chart__ || d3.scale.linear()
          .domain([0, Infinity])
          .range(x1.range());

      // Stash the new scale.
      this.__chart__ = x1;

      // Derive width-scales from the x-scales.
      var w0 = bulletWidth(x0),
          w1 = bulletWidth(x1);

	  var rangeColors = d3.scale.linear().domain([0,rangez.length - 1]).range(["#eee", "#888"]);
	  var measureColors = d3.scale.linear().domain([0,measurez.length - 1]).range(["#164284", "#b0c4ee"]);

      // Update the range rects.
      var range = g.selectAll("rect.range")
          .data(rangez);
	  
	  range.exit().remove();
      range.enter().append("rect")
          .attr("class", function(d, i) { return "range s" + i; })
          .attr("width", function(d, i) { x0Ranges[i+1] = w0(d); return w0(d) - x0Ranges[i];})
          .attr("height", height)
          .attr("x", function(d,i) {return reverse ? x0(d) : x0Ranges[i];})
		  .attr("fill", function(d,i) { if (i ==0){return "#fff";} return rangeColors(i-1);})
        .transition()
		  .delay(function (d,i){ if(rangez.length==0){return 0;}return duration * (i/rangez.length); }) 
          .duration(duration)
          .attr("width", function(d, i) { x1Ranges[i+1] = w1(d); return w1(d) - x1Ranges[i];})
          .attr("x", function(d,i) {return reverse ? x1(d) : x1Ranges[i];})
		  .attr("fill", function(d,i) { if (i ==0){return "#fff";} return rangeColors(i-1);});
		  
      range.transition()
		  .delay(function (d,i){ if(rangez.length==0){return 0;}return duration * (i/rangez.length); }) 
          .duration(duration)
          .attr("width", function(d, i) { x0Ranges[i+1] = w0(d); x1Ranges[i+1] = w1(d); return w1(d) - x1Ranges[i];})
          .attr("x", function(d,i) {return reverse ? x1(d) : x1Ranges[i];})
          .attr("height", height)
		  .attr("fill", function(d,i) { if (i ==0){return "#fff";} return rangeColors(i-1);});

	  range.append("title").text(function(d, i) { return rangeTitlez[i];});

      // Update the measure rects.
      var measure = g.selectAll("rect.measure")
          .data(measurez);

	  measure.exit().remove();
      measure.enter().append("rect")
          .attr("class", function(d, i) { return "measure s" + i; })
          .attr("width", function(d, i) { x0Measures[i+1] = w0(d); return w0(d) - x0Measures[i];})
          .attr("height", height / 3)
          .attr("x", function(d,i) {return reverse ? x0(d) : x0Measures[i];})
          .attr("y", height / 3)
		  .attr("fill", function(d,i) {return measureColors(i);})
        .transition()
		  .delay(function (d,i){ if (measurez.length == 0){return 0;} return 2* (duration * (i/measurez.length));}) 
          .duration(2*duration)
          .attr("width", function(d, i) { x1Measures[i+1] = w1(d); return w1(d) - x1Measures[i];})
          .attr("x", function(d,i) {return reverse ? x1(d) : x1Measures[i];})
		  .attr("fill", function(d,i) {return measureColors(i);});
		  
      measure.transition()
		  .delay(function (d,i){ if (measurez.length == 0){return 0;} return 2* (duration * (i/measurez.length));}) 
          .duration(2*duration)
          .attr("width", function(d, i) { x0Measures[i+1] = w0(d); x1Measures[i+1] = w1(d); return w1(d) - x1Measures[i];})
          .attr("height", height / 3)
          .attr("x", function(d,i) {return reverse ? x1(d) : x1Measures[i];})
          .attr("y", height / 3)
		  .attr("fill", function(d,i) {return measureColors(i);});

	  measure.on('mouseover', function(d, i) { if (i < measureRangez.length) {g.select("#tickbubble" + measureRangez[i]).transition().duration(250).attr("y", -20).attr("height", 20); }})
		  .on('mouseout', function(d, i) { if (i < measureRangez.length) {g.select("#tickbubble" + measureRangez[i]).transition().duration(250).attr("y", 0).attr("height", 0); }});
	  measure.append("title").text(function(d, i) { return measureTitlez[i];});


      // Update the marker lines.
      var marker = g.selectAll("line.marker")
          .data(markerz);

      marker.enter().append("line")
          .attr("class", function(d,i) {if (markerClazz.length <= i || markerClazz[i].length <= 0){return "marker";} return "marker " + markerClazz[i];})
          .attr("x1", x0)
          .attr("x2", x0)
          .attr("y1", height / 6)
          .attr("y2", height * 5 / 6)
        .transition()
		  .delay(function (d,i){ if(markerz.length==0){return 0;}return duration * (i/markerz.length)/2; }) 
          .duration(duration/2)
          .attr("x1", x1)
          .attr("x2", x1);

	  marker.transition()
		  .delay(function (d,i){ if(markerz.length==0){return 0;}return duration * (i/markerz.length)/2; }) 
          .duration(duration/2)
          .attr("x1", x1)
          .attr("x2", x1)
          .attr("y1", height / 6)
          .attr("y2", height * 5 / 6);

	  marker.append("title").text(function(d, i) { return markerTitlez[i];});

      // Compute the tick format.
      var format = tickFormat || x1.tickFormat(8);

      // Update the tick groups.
      var tick = g.selectAll("g.tick")
          .data(x1.ticks(4), function(d) {
            return format(d);
          });

      // Initialize the ticks with the old scale, x0.

      // Transition the exiting ticks to the new scale, x1.
      tick.exit().transition()
          .duration(250)
          .attr("transform", bulletTranslate(x1))
          .style("opacity", 1e-6)
          .remove();

      var tickEnter = tick.enter().append("g")
          .attr("class", "tick")
          .attr("transform", bulletTranslate(x0))
          .style("opacity", 1e-6);

      tickEnter.append("line")
          .attr("y1", height)
          .attr("y2", height * 7 / 6);

      tickEnter.append("text")
          .attr("text-anchor", "middle")
          .attr("dy", "1em")
          .attr("y", height * 7 / 6)
          .text(format);
		  
//	  tickEnter.append("title").text(d.tickTitle);

      // Transition the entering ticks to the new scale, x1.
      tickEnter.transition()
          .duration(250)
          .attr("transform", bulletTranslate(x1))
          .style("opacity", 1);

      // Transition the updating ticks to the new scale, x1.
      var tickUpdate = tick.transition()
          .duration(250)
          .attr("transform", bulletTranslate(x1))
          .style("opacity", 1);

      tickUpdate.select("line")
          .attr("y1", height)
          .attr("y2", height * 7 / 6);

      tickUpdate.select("text")
          .attr("y", height * 7 / 6);

	  if (rangez.length > 1 && x1Ranges[rangez.length] >= width)
	  {
	    //console.log("Removing last range...");
	    rangez.length = rangez.length - 1;
	  }
      // Update the tick groups.
      var rate = g.selectAll("g.rate")
          .data(rangez, function(d, i) {
            return rangeTickz[i];
          });

      // Initialize the ticks with the old scale, x0.

      // Transition the exiting ticks to the new scale, x1.
      rate.exit().transition()
          .duration(250)
          .attr("transform", bulletTranslate(x1))
          .style("opacity", 1e-6)
          .remove();

      var rateEnter = rate.enter().append("g")
          .attr("class", "rate")
          .attr("transform", bulletTranslate(x0))
          .style("opacity", 1e-6);

      rateEnter.append("line")
          .attr("y1", -height * 1/6)
          .attr("y2", 0);

	  rateEnter.append("rect").attr("fill", "green").attr("opacity", 0.4).attr("id", function(d,i){return "tickbubble" + i;})
          .attr("dy", "-.25em")
          .attr("y", 0)
		  .attr("rx", 5)
		  .attr("ry", 5)
		  .attr("height", 0)
          .attr("width", function(d, i) { if ((i+2) < x0Ranges.length){return x0Ranges[i+2] - x0Ranges[i+1];} if((i+1)<x0Ranges.length && x0Measures.length>=2){ return (x0Measures[x0Measures.length-1]-x0Measures[x0Measures.length-2]); } if((i+1)<x0Ranges.length && x0Measures.length>=1){ return (x0Measures[x0Measures.length-1]); }return x0Ranges[i+1];})
          .attr("width", function(d, i) { return x0Ranges[i+1] - x0Ranges[i];})
		  .style("stroke", "black").style("stroke-width", 2);

	  rateEnter.append("text")
          .attr("text-anchor", "middle")
          .attr("dy", "-.25em")
		  .attr("x", function(d, i) { if ((i+2)<x0Ranges.length){return (x0Ranges[i+2] - x0Ranges[i+1]) / 2;} if((i+1)<x0Ranges.length && x0Measures.length>=2){ return (x0Measures[x0Measures.length-1] - x0Measures[x0Measures.length-2])/2; } if((i+1)<x0Ranges.length && x0Measures.length>=1){ return (x0Measures[x0Measures.length-1])/2; } return x1Ranges[i+1]/2; })
          .attr("y", -height * 1 / 6)
          .text(function(d, i) {
            return rangeTickz[i];
          })
		  .attr("class", function(d, i){if (rangeClazz.length <= 0) { return "tick"; } return "tick " + rangeClazz[i];})
		  ;
	
      // Transition the entering ticks to the new scale, x1.
      rateEnter.transition()
          .duration(250)
          .attr("transform", bulletTranslate(x1))
          .style("opacity", 1);

      // Transition the updating ticks to the new scale, x1.
      var rateUpdate = rate.transition()
          .duration(250)
          .attr("transform", bulletTranslate(x1))
          .style("opacity", 1);

      rateUpdate.select("line")
          .attr("y1", -height * 1/6)
          .attr("y2", 0);

      rateUpdate.select("rect")
          .attr("width", function(d, i) { if ((i+2) < x1Ranges.length){return x1Ranges[i+2] - x1Ranges[i+1];} if((i+1)<x1Ranges.length && x1Measures.length>=2){ return (x1Measures[x1Measures.length-1]-x1Measures[x1Measures.length-2]); } if((i+1)<x1Ranges.length && x1Measures.length>=1){ return (x1Measures[x1Measures.length-1]); }return x1Ranges[i+1];})
		  .attr("y", 0)
          ;

	  rateUpdate.select("text")
		  .attr("x", function(d, i) { if ((i+2) < x1Ranges.length){ return (x1Ranges[i+2] - x1Ranges[i+1]) / 2;} if((i+1)<x1Ranges.length && x1Measures.length>=2){ return (x1Measures[x1Measures.length-1]-x1Measures[x1Measures.length-2])/2; } if((i+1)<x1Ranges.length && x1Measures.length>=1){ return (x1Measures[x1Measures.length-1])/2; } return x1Ranges[i+1]/2; })
          .attr("y", -height * 1/ 6);

	  if (g.selectAll("text.subtitle").empty())
	  {
	    var axisLabel = g.append("text").attr("class", "subtitle").text(d.tickTitle).attr("y", (height * 2)-3).attr("x", width / 2).attr("text-anchor", "middle");
	  }
    });
    d3.timer.flush();
  }

  // left, right, top, bottom
  bullet.orient = function(x) {
    if (!arguments.length) return orient;
    orient = x;
    reverse = orient == "right" || orient == "bottom";
    return bullet;
  };

  // ranges (bad, satisfactory, good)
  bullet.ranges = function(x) {
    if (!arguments.length) return ranges;
    ranges = x;
    return bullet;
  };

  // markers (previous, goal)
  bullet.markers = function(x) {
    if (!arguments.length) return markers;
    markers = x;
    return bullet;
  };

  // markers (previous, goal)
  bullet.markerClass = function(x) {
    if (!arguments.length) return markerClass;
    markerClass = x;
    return bullet;
  };

  // measures (actual, forecast)
  bullet.measures = function(x) {
    if (!arguments.length) return measures;
    measures = x;
    return bullet;
  };

  bullet.measureRanges = function(x) {
    if (!arguments.length) return measureRanges;
    measureRanges = x;
    return bullet;
  };

  bullet.width = function(x) {
    if (!arguments.length) return width;
    width = x;
    return bullet;
  };

  bullet.height = function(x) {
    if (!arguments.length) return height;
    height = x;
    return bullet;
  };

  bullet.tickFormat = function(x) {
    if (!arguments.length) return tickFormat;
    tickFormat = x;
    return bullet;
  };

  bullet.rangeClass = function(x) {
    if (!arguments.length) return rangeClass;
    rangeClass = x;
    return bullet;
  };

  bullet.duration = function(x) {
    if (!arguments.length) return duration;
    duration = x;
    return bullet;
  };

  bullet.rangeTitles = function(x) {
    if (!arguments.length) return rangeTitles;
    rangeTitles = x;
    return bullet;
  };

  bullet.markerTitles = function(x) {
    if (!arguments.length) return markerTitles;
    markerTitles = x;
    return bullet;
  };

  bullet.measureTitles = function(x) {
    if (!arguments.length) return measureTitles;
    measureTitles = x;
    return bullet;
  };

  bullet.rangeTicks = function(x) {
    if (!arguments.length) return rangeTicks;
    rangeTicks = x;
    return bullet;
  };

  return bullet;
};

function bulletRangeTitles(d) {
  return d.rangeTitles;
}

function bulletRangeClass(d) {
  return d.rangeClass;
}

function bulletRangeTicks(d) {
  return d.rangeTicks;
}

function bulletMarkerTitles(d) {
  return d.markerTitles;
}

function bulletMarkerClass(d) {
  return d.markerClass;
}

function bulletMeasureTitles(d) {
  return d.measureTitles;
}

function bulletRanges(d) {
  return d.ranges;
}

function bulletMarkers(d) {
  return d.markers;
}

function bulletMeasures(d) {
  return d.measures;
}

function bulletMeasureRanges(d) {
  return d.measureRanges;
}

function bulletTranslate(x) {
  return function(d) {
    return "translate(" + x(d) + ",0)";
  };
}

function bulletWidth(x) {
  var x0 = x(0);
  return function(d) {
    return Math.abs(x(d) - x0);
  };
}

})();
