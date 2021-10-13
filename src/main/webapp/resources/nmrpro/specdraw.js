(function(f){if(typeof exports==="object"&&typeof module!=="undefined"){module.exports=f()}else if(typeof define==="function"&&define.amd){define([],f)}else{var g;if(typeof window!=="undefined"){g=window}else if(typeof global!=="undefined"){g=global}else if(typeof self!=="undefined"){g=self}else{g=this}g.specdraw = f()}})(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
(function(exports) {

  var bootstrap = (typeof exports.bootstrap === "object") ?
    exports.bootstrap :
    (exports.bootstrap = {});

  bootstrap.tooltip = function() {

    var tooltip = function(selection) {
        selection.each(setup);
      },
      animation = d3.functor(false),
      html = d3.functor(false),
      title = function() {
        var title = this.getAttribute("data-original-title");
        if (title) {
          return title;
        } else {
          title = this.getAttribute("title");
          this.removeAttribute("title");
          this.setAttribute("data-original-title", title);
        }
        return title;
      },
      over = "mouseenter.tooltip",
      out = "mouseleave.tooltip",
      placements = "top left bottom right".split(" "),
      placement = d3.functor("top");

    tooltip.title = function(_) {
      if (arguments.length) {
        title = d3.functor(_);
        return tooltip;
      } else {
        return title;
      }
    };

    tooltip.html = function(_) {
      if (arguments.length) {
        html = d3.functor(_);
        return tooltip;
      } else {
        return html;
      }
    };

    tooltip.placement = function(_) {
      if (arguments.length) {
        placement = d3.functor(_);
        return tooltip;
      } else {
        return placement;
      }
    };

    tooltip.show = function(selection) {
      selection.each(show);
    };

    tooltip.hide = function(selection) {
      selection.each(hide);
    };

    tooltip.toggle = function(selection) {
      selection.each(toggle);
    };

    tooltip.destroy = function(selection) {
      selection
        .on(over, null)
        .on(out, null)
        .attr("title", function() {
          return this.getAttribute("data-original-title") || this.getAttribute("title");
        })
        .attr("data-original-title", null)
        .select(".tooltip")
        .remove();
    };

    function setup() {
      var root = d3.select(this),
          animate = animation.apply(this, arguments),
          tip = root.append("div")
            .attr("class", "tooltip");

      if (animate) {
        tip.classed("fade", true);
      }

      // TODO "inside" checks?

      tip.append("div")
        .attr("class", "tooltip-arrow");
      tip.append("div")
        .attr("class", "tooltip-inner");

      var place = placement.apply(this, arguments);
      tip.classed(place, true);

      root.on(over, show);
      root.on(out, hide);
    }

    function show() {
      var root = d3.select(this),
          content = title.apply(this, arguments),
          tip = root.select(".tooltip")
            .classed("in", true),
          markup = html.apply(this, arguments),
          innercontent = tip.select(".tooltip-inner")[markup ? "html" : "text"](content),
          place = placement.apply(this, arguments),
          pos = root.style("position"),
          outer = getPosition(root.node()),
          inner = getPosition(tip.node()),
          style;

      if (pos === "absolute" || pos === "relative") {
          outer.x = outer.y = 0;
      }

      var style;
      switch (place) {
        case "top":
          style = {x: outer.x + (outer.w - inner.w) / 2, y: outer.y - inner.h};
          break;
        case "right":
          style = {x: outer.x + outer.w, y: outer.y + (outer.h - inner.h) / 2};
          break;
        case "left":
          style = {x: outer.x - inner.w, y: outer.y + (outer.h - inner.h) / 2};
          break;
        case "bottom":
          style = {x: Math.max(0, outer.x + (outer.w - inner.w) / 2), y: outer.y + outer.h};
          break;
      }

      tip.style(style ?
        {left: ~~style.x + "px", top: ~~style.y + "px"} :
        {left: null, top: null});

      this.tooltipVisible = true;
    }

    function hide() {
      d3.select(this).select(".tooltip")
        .classed("in", false);

      this.tooltipVisible = false;
    }

    function toggle() {
      if (this.tooltipVisible) {
        hide.apply(this, arguments);
      } else {
        show.apply(this, arguments);
      }
    }

    return tooltip;
  };

  function getPosition(node) {
    var mode = d3.select(node).style('position');
    if (mode === 'absolute' || mode === 'static') {
      return {
        x: node.offsetLeft,
        y: node.offsetTop,
        w: node.offsetWidth,
        h: node.offsetHeight
      };
    } else {
      return {
        x: 0,
        y: 0,
        w: node.offsetWidth,
        h: node.offsetHeight
      };
    }
  }

})(this);


},{}],2:[function(require,module,exports){
// d3.tip
// Copyright (c) 2013 Justin Palmer
//
// Tooltips for d3.js SVG visualizations

(function (root, factory) {
  if (typeof define === 'function' && define.amd) {
    // AMD. Register as an anonymous module with d3 as a dependency.
    define(['d3'], factory)
  } else if (typeof module === 'object' && module.exports) {
    // CommonJS
    module.exports = function(d3) {
      d3.tip = factory(d3)
      return d3.tip
    }
  } else {
    // Browser global.
    root.d3.tip = factory(root.d3)
  }
}(this, function (d3) {

  // Public - contructs a new tooltip
  //
  // Returns a tip
  return function() {
    var direction = d3_tip_direction,
        offset    = d3_tip_offset,
        html      = d3_tip_html,
        text      = ' ',
        textnode  = null,
        bootstrap = false,
        node      = initNode(),
        svg       = null,
        point     = null,
        target    = null

    function tip(vis) {
      svg = getSVGNode(vis)
      point = svg.createSVGPoint()
      document.body.appendChild(node)
    }

    // Public - show the tooltip on the screen
    //
    // Returns a tip
    tip.show = function() {
      var args = Array.prototype.slice.call(arguments)
      if(args[args.length - 1] instanceof SVGElement) target = args.pop()

      var content = html.apply(this, args),
          poffset = offset.apply(this, args),
          dir     = direction.apply(this, args),
          nodel   = getNodeEl(),
          i       = directions.length,
          coords,
          scrollTop  = document.documentElement.scrollTop || document.body.scrollTop,
          scrollLeft = document.documentElement.scrollLeft || document.body.scrollLeft
      
      if(!bootstrap)
        nodel.html(content)
          .style({ opacity: 1, 'pointer-events': 'all' })
      else{
        textnode.text(text)
        nodel.style({ opacity: 1, 'pointer-events': 'none' })
      }
      
      while(i--) nodel.classed(directions[i], false)
      coords = direction_callbacks.get(dir).apply(this)
      nodel.classed(dir, true).style({
        top: (coords.top +  poffset[0]) + scrollTop + 'px',
        left: (coords.left + poffset[1]) + scrollLeft + 'px'
      })

      return tip
    }

    // Public - hide the tooltip
    //
    // Returns a tip
    tip.hide = function() {
      var nodel = getNodeEl()
      nodel.style({ opacity: 0, 'pointer-events': 'none' })
      return tip
    }

    // Public: Proxy attr calls to the d3 tip container.  Sets or gets attribute value.
    //
    // n - name of the attribute
    // v - value of the attribute
    //
    // Returns tip or attribute value
    tip.attr = function(n, v) {
      if (arguments.length < 2 && typeof n === 'string') {
        return getNodeEl().attr(n)
      } else {
        var args =  Array.prototype.slice.call(arguments)
        d3.selection.prototype.attr.apply(getNodeEl(), args)
      }

      return tip
    }

    // Public: Proxy style calls to the d3 tip container.  Sets or gets a style value.
    //
    // n - name of the property
    // v - value of the property
    //
    // Returns tip or style property value
    tip.style = function(n, v) {
      if (arguments.length < 2 && typeof n === 'string') {
        return getNodeEl().style(n)
      } else {
        var args =  Array.prototype.slice.call(arguments)
        d3.selection.prototype.style.apply(getNodeEl(), args)
      }

      return tip
    }

    // Public: Set or get the direction of the tooltip
    //
    // v - One of n(north), s(south), e(east), or w(west), nw(northwest),
    //     sw(southwest), ne(northeast) or se(southeast)
    //
    // Returns tip or direction
    tip.direction = function(v) {
      if (!arguments.length) return direction
      direction = v == null ? v : d3.functor(v)

      return tip
    }

    // Public: Sets or gets the offset of the tip
    //
    // v - Array of [x, y] offset
    //
    // Returns offset or
    tip.offset = function(v) {
      if (!arguments.length) return offset
      offset = v == null ? v : d3.functor(v)

      return tip
    }

    // Public: sets or gets the html value of the tooltip
    //
    // v - String value of the tip
    //
    // Returns html value or tip
    tip.html = function(v) {
      if (!arguments.length) return html
      html = v == null ? v : d3.functor(v)

      return tip
    }

    // Public: sets or gets the text value of the tooltip
    //
    // v - String value of the tip
    //
    // Returns text value or tip
    tip.text = function(v) {
      if (!arguments.length) return text
      text = v == null ? ' ' : v
      
      return tip
    }

    tip.bootstrap = function(v) {
      if (!arguments.length) return bootstrap
      bootstrap = v;
      if(v == true){
        var nodel = getNodeEl()
        nodel.html('<div class="tooltip-arrow"></div><div class="tooltip-inner">'
          + text +'</div>')
        textnode = nodel.select('.tooltip-inner')
      }
      
      return tip
    }
    // Public: destroys the tooltip and removes it from the DOM
    //
    // Returns a tip
    tip.destroy = function() {
      if(node) {
        getNodeEl().remove();
        node = null;
      }
      return tip;
    }

    function d3_tip_direction() { return 'n' }
    function d3_tip_offset() { return [0, 0] }
    function d3_tip_html() { return ' ' }

    var direction_callbacks = d3.map({
      n:  direction_n,
      s:  direction_s,
      e:  direction_e,
      w:  direction_w,
      nw: direction_nw,
      ne: direction_ne,
      sw: direction_sw,
      se: direction_se
    }),

    directions = direction_callbacks.keys()

    function direction_n() {
      var bbox = getScreenBBox()
      return {
        top:  bbox.n.y - node.offsetHeight,
        left: bbox.n.x - node.offsetWidth / 2
      }
    }

    function direction_s() {
      var bbox = getScreenBBox()
      return {
        top:  bbox.s.y,
        left: bbox.s.x - node.offsetWidth / 2
      }
    }

    function direction_e() {
      var bbox = getScreenBBox()
      return {
        top:  bbox.e.y - node.offsetHeight / 2,
        left: bbox.e.x
      }
    }

    function direction_w() {
      var bbox = getScreenBBox()
      return {
        top:  bbox.w.y - node.offsetHeight / 2,
        left: bbox.w.x - node.offsetWidth
      }
    }

    function direction_nw() {
      var bbox = getScreenBBox()
      return {
        top:  bbox.nw.y - node.offsetHeight,
        left: bbox.nw.x - node.offsetWidth
      }
    }

    function direction_ne() {
      var bbox = getScreenBBox()
      return {
        top:  bbox.ne.y - node.offsetHeight,
        left: bbox.ne.x
      }
    }

    function direction_sw() {
      var bbox = getScreenBBox()
      return {
        top:  bbox.sw.y,
        left: bbox.sw.x - node.offsetWidth
      }
    }

    function direction_se() {
      var bbox = getScreenBBox()
      return {
        top:  bbox.se.y,
        left: bbox.e.x
      }
    }

    function initNode() {
      var node = d3.select(document.createElement('div'))
      node.style({
        position: 'absolute',
        top: 0,
        opacity: 0,
        'pointer-events': 'none',
        'box-sizing': 'border-box'
      })

      return node.node()
    }

    function getSVGNode(el) {
      el = el.node()
      if(el.tagName.toLowerCase() === 'svg')
        return el

      return el.ownerSVGElement
    }

    function getNodeEl() {
      if(node === null) {
        node = initNode();
        // re-add node to DOM
        document.body.appendChild(node);
      };
      return d3.select(node);
    }

    // Private - gets the screen coordinates of a shape
    //
    // Given a shape on the screen, will return an SVGPoint for the directions
    // n(north), s(south), e(east), w(west), ne(northeast), se(southeast), nw(northwest),
    // sw(southwest).
    //
    //    +-+-+
    //    |   |
    //    +   +
    //    |   |
    //    +-+-+
    //
    // Returns an Object {n, s, e, w, nw, sw, ne, se}
    function getScreenBBox() {
      var targetel   = target || d3.event.target;

      while ('undefined' === typeof targetel.getScreenCTM && 'undefined' === targetel.parentNode) {
          targetel = targetel.parentNode;
      }

      var bbox       = {},
          matrix     = targetel.getScreenCTM(),
          tbbox      = targetel.getBBox(),
          width      = tbbox.width,
          height     = tbbox.height,
          x          = tbbox.x,
          y          = tbbox.y

      point.x = x
      point.y = y
      bbox.nw = point.matrixTransform(matrix)
      point.x += width
      bbox.ne = point.matrixTransform(matrix)
      point.y += height
      bbox.se = point.matrixTransform(matrix)
      point.x -= width
      bbox.sw = point.matrixTransform(matrix)
      point.y -= height / 2
      bbox.w  = point.matrixTransform(matrix)
      point.x += width
      bbox.e = point.matrixTransform(matrix)
      point.x -= width / 2
      point.y -= height / 2
      bbox.n = point.matrixTransform(matrix)
      point.y += height
      bbox.s = point.matrixTransform(matrix)

      return bbox
    }

    return tip
  };

}));

},{}],3:[function(require,module,exports){
/*!
  * Bowser - a browser detector
  * https://github.com/ded/bowser
  * MIT License | (c) Dustin Diaz 2015
  */

!function (name, definition) {
  if (typeof module != 'undefined' && module.exports) module.exports = definition()
  else if (typeof define == 'function' && define.amd) define(definition)
  else this[name] = definition()
}('bowser', function () {
  /**
    * See useragents.js for examples of navigator.userAgent
    */

  var t = true

  function detect(ua) {

    function getFirstMatch(regex) {
      var match = ua.match(regex);
      return (match && match.length > 1 && match[1]) || '';
    }

    function getSecondMatch(regex) {
      var match = ua.match(regex);
      return (match && match.length > 1 && match[2]) || '';
    }

    var iosdevice = getFirstMatch(/(ipod|iphone|ipad)/i).toLowerCase()
      , likeAndroid = /like android/i.test(ua)
      , android = !likeAndroid && /android/i.test(ua)
      , chromeBook = /CrOS/.test(ua)
      , edgeVersion = getFirstMatch(/edge\/(\d+(\.\d+)?)/i)
      , versionIdentifier = getFirstMatch(/version\/(\d+(\.\d+)?)/i)
      , tablet = /tablet/i.test(ua)
      , mobile = !tablet && /[^-]mobi/i.test(ua)
      , result

    if (/opera|opr/i.test(ua)) {
      result = {
        name: 'Opera'
      , opera: t
      , version: versionIdentifier || getFirstMatch(/(?:opera|opr)[\s\/](\d+(\.\d+)?)/i)
      }
    }
    else if (/yabrowser/i.test(ua)) {
      result = {
        name: 'Yandex Browser'
      , yandexbrowser: t
      , version: versionIdentifier || getFirstMatch(/(?:yabrowser)[\s\/](\d+(\.\d+)?)/i)
      }
    }
    else if (/windows phone/i.test(ua)) {
      result = {
        name: 'Windows Phone'
      , windowsphone: t
      }
      if (edgeVersion) {
        result.msedge = t
        result.version = edgeVersion
      }
      else {
        result.msie = t
        result.version = getFirstMatch(/iemobile\/(\d+(\.\d+)?)/i)
      }
    }
    else if (/msie|trident/i.test(ua)) {
      result = {
        name: 'Internet Explorer'
      , msie: t
      , version: getFirstMatch(/(?:msie |rv:)(\d+(\.\d+)?)/i)
      }
    } else if (chromeBook) {
      result = {
        name: 'Chrome'
      , chromeBook: t
      , chrome: t
      , version: getFirstMatch(/(?:chrome|crios|crmo)\/(\d+(\.\d+)?)/i)
      }
    } else if (/chrome.+? edge/i.test(ua)) {
      result = {
        name: 'Microsoft Edge'
      , msedge: t
      , version: edgeVersion
      }
    }
    else if (/chrome|crios|crmo/i.test(ua)) {
      result = {
        name: 'Chrome'
      , chrome: t
      , version: getFirstMatch(/(?:chrome|crios|crmo)\/(\d+(\.\d+)?)/i)
      }
    }
    else if (iosdevice) {
      result = {
        name : iosdevice == 'iphone' ? 'iPhone' : iosdevice == 'ipad' ? 'iPad' : 'iPod'
      }
      // WTF: version is not part of user agent in web apps
      if (versionIdentifier) {
        result.version = versionIdentifier
      }
    }
    else if (/sailfish/i.test(ua)) {
      result = {
        name: 'Sailfish'
      , sailfish: t
      , version: getFirstMatch(/sailfish\s?browser\/(\d+(\.\d+)?)/i)
      }
    }
    else if (/seamonkey\//i.test(ua)) {
      result = {
        name: 'SeaMonkey'
      , seamonkey: t
      , version: getFirstMatch(/seamonkey\/(\d+(\.\d+)?)/i)
      }
    }
    else if (/firefox|iceweasel/i.test(ua)) {
      result = {
        name: 'Firefox'
      , firefox: t
      , version: getFirstMatch(/(?:firefox|iceweasel)[ \/](\d+(\.\d+)?)/i)
      }
      if (/\((mobile|tablet);[^\)]*rv:[\d\.]+\)/i.test(ua)) {
        result.firefoxos = t
      }
    }
    else if (/silk/i.test(ua)) {
      result =  {
        name: 'Amazon Silk'
      , silk: t
      , version : getFirstMatch(/silk\/(\d+(\.\d+)?)/i)
      }
    }
    else if (android) {
      result = {
        name: 'Android'
      , version: versionIdentifier
      }
    }
    else if (/phantom/i.test(ua)) {
      result = {
        name: 'PhantomJS'
      , phantom: t
      , version: getFirstMatch(/phantomjs\/(\d+(\.\d+)?)/i)
      }
    }
    else if (/blackberry|\bbb\d+/i.test(ua) || /rim\stablet/i.test(ua)) {
      result = {
        name: 'BlackBerry'
      , blackberry: t
      , version: versionIdentifier || getFirstMatch(/blackberry[\d]+\/(\d+(\.\d+)?)/i)
      }
    }
    else if (/(web|hpw)os/i.test(ua)) {
      result = {
        name: 'WebOS'
      , webos: t
      , version: versionIdentifier || getFirstMatch(/w(?:eb)?osbrowser\/(\d+(\.\d+)?)/i)
      };
      /touchpad\//i.test(ua) && (result.touchpad = t)
    }
    else if (/bada/i.test(ua)) {
      result = {
        name: 'Bada'
      , bada: t
      , version: getFirstMatch(/dolfin\/(\d+(\.\d+)?)/i)
      };
    }
    else if (/tizen/i.test(ua)) {
      result = {
        name: 'Tizen'
      , tizen: t
      , version: getFirstMatch(/(?:tizen\s?)?browser\/(\d+(\.\d+)?)/i) || versionIdentifier
      };
    }
    else if (/safari/i.test(ua)) {
      result = {
        name: 'Safari'
      , safari: t
      , version: versionIdentifier
      }
    }
    else {
      result = {
        name: getFirstMatch(/^(.*)\/(.*) /),
        version: getSecondMatch(/^(.*)\/(.*) /)
     };
   }

    // set webkit or gecko flag for browsers based on these engines
    if (!result.msedge && /(apple)?webkit/i.test(ua)) {
      result.name = result.name || "Webkit"
      result.webkit = t
      if (!result.version && versionIdentifier) {
        result.version = versionIdentifier
      }
    } else if (!result.opera && /gecko\//i.test(ua)) {
      result.name = result.name || "Gecko"
      result.gecko = t
      result.version = result.version || getFirstMatch(/gecko\/(\d+(\.\d+)?)/i)
    }

    // set OS flags for platforms that have multiple browsers
    if (!result.msedge && (android || result.silk)) {
      result.android = t
    } else if (iosdevice) {
      result[iosdevice] = t
      result.ios = t
    }

    // OS version extraction
    var osVersion = '';
    if (result.windowsphone) {
      osVersion = getFirstMatch(/windows phone (?:os)?\s?(\d+(\.\d+)*)/i);
    } else if (iosdevice) {
      osVersion = getFirstMatch(/os (\d+([_\s]\d+)*) like mac os x/i);
      osVersion = osVersion.replace(/[_\s]/g, '.');
    } else if (android) {
      osVersion = getFirstMatch(/android[ \/-](\d+(\.\d+)*)/i);
    } else if (result.webos) {
      osVersion = getFirstMatch(/(?:web|hpw)os\/(\d+(\.\d+)*)/i);
    } else if (result.blackberry) {
      osVersion = getFirstMatch(/rim\stablet\sos\s(\d+(\.\d+)*)/i);
    } else if (result.bada) {
      osVersion = getFirstMatch(/bada\/(\d+(\.\d+)*)/i);
    } else if (result.tizen) {
      osVersion = getFirstMatch(/tizen[\/\s](\d+(\.\d+)*)/i);
    }
    if (osVersion) {
      result.osversion = osVersion;
    }

    // device type extraction
    var osMajorVersion = osVersion.split('.')[0];
    if (tablet || iosdevice == 'ipad' || (android && (osMajorVersion == 3 || (osMajorVersion == 4 && !mobile))) || result.silk) {
      result.tablet = t
    } else if (mobile || iosdevice == 'iphone' || iosdevice == 'ipod' || android || result.blackberry || result.webos || result.bada) {
      result.mobile = t
    }

    // Graded Browser Support
    // http://developer.yahoo.com/yui/articles/gbs
    if (result.msedge ||
        (result.msie && result.version >= 10) ||
        (result.yandexbrowser && result.version >= 15) ||
        (result.chrome && result.version >= 20) ||
        (result.firefox && result.version >= 20.0) ||
        (result.safari && result.version >= 6) ||
        (result.opera && result.version >= 10.0) ||
        (result.ios && result.osversion && result.osversion.split(".")[0] >= 6) ||
        (result.blackberry && result.version >= 10.1)
        ) {
      result.a = t;
    }
    else if ((result.msie && result.version < 10) ||
        (result.chrome && result.version < 20) ||
        (result.firefox && result.version < 20.0) ||
        (result.safari && result.version < 6) ||
        (result.opera && result.version < 10.0) ||
        (result.ios && result.osversion && result.osversion.split(".")[0] < 6)
        ) {
      result.c = t
    } else result.x = t

    return result
  }

  var bowser = detect(typeof navigator !== 'undefined' ? navigator.userAgent : '')

  bowser.test = function (browserList) {
    for (var i = 0; i < browserList.length; ++i) {
      var browserItem = browserList[i];
      if (typeof browserItem=== 'string') {
        if (browserItem in bowser) {
          return true;
        }
      }
    }
    return false;
  }

  /*
   * Set our detect method to the main bowser object so we can
   * reuse it to test other user agents.
   * This is needed to implement future tests.
   */
  bowser._detect = detect;

  return bowser
});

},{}],4:[function(require,module,exports){
(function(root, factory) {
	if (typeof module === 'object' && module.exports) {
		module.exports = function(d3) {
			d3.contextMenu = factory(d3);
			return d3.contextMenu;
		};
	} else {
		root.d3.contextMenu = factory(root.d3);
	}
}(	this, 
	function(d3) {
		return function (menu, openCallback) {

			// create the div element that will hold the context menu
			d3.selectAll('.d3-context-menu').data([1])
				.enter()
				.append('div')
				.attr('class', 'd3-context-menu');

			// close menu
			d3.select('body').on('click.d3-context-menu', function() {
				d3.select('.d3-context-menu').style('display', 'none');
			});

			// this gets executed when a contextmenu event occurs
			return function(data, index) {
				var elm = this;

				d3.selectAll('.d3-context-menu').html('');
				var list = d3.selectAll('.d3-context-menu').append('ul');
				list.selectAll('li').data(menu).enter()
					.append('li')
					.html(function(d) {
						return (typeof d.title === 'string') ? d.title : d.title(data);
					})
					.on('click', function(d, i) {
						d.action(elm, data, index);
						d3.select('.d3-context-menu').style('display', 'none');
					});

				// the openCallback allows an action to fire before the menu is displayed
				// an example usage would be closing a tooltip
				if (openCallback) {
					if (openCallback(data, index) === false) {
						return;
					}
				}

				// display context menu
				d3.select('.d3-context-menu')
					.style('left', (d3.event.pageX - 2) + 'px')
					.style('top', (d3.event.pageY - 2) + 'px')
					.style('display', 'block');

				d3.event.preventDefault();
				d3.event.stopPropagation();
			};
		};
	}
));

},{}],5:[function(require,module,exports){
'use strict';

function getConverter() {

    // the following RegExp can only be used for XYdata, some peakTables have values with a "E-5" ...
    var xyDataSplitRegExp = /[,\t \+-]*(?=[^\d,\t \.])|[ \t]+(?=[\d+\.-])/;
    var removeCommentRegExp = /\$\$.*/;
    var peakTableSplitRegExp = /[,\t ]+/;
    var DEBUG = false;

    var GC_MS_FIELDS = ['TIC', '.RIC', 'SCANNUMBER'];

    function convertToFloatArray(stringArray) {
        var l = stringArray.length;
        var floatArray = new Array(l);
        for (var i = 0; i < l; i++) {
            floatArray[i] = parseFloat(stringArray[i]);
        }
        return floatArray;
    }

    /*
     options.keepSpectra: keep the original spectra for a 2D
     options.xy: true // create x / y array instead of a 1D array
     options.keepRecordsRegExp: which fields do we keep
     */

    function convert(jcamp, options) {
        options = options || {};

        var keepRecordsRegExp=/^[A-Z]+$/;
        if (options.keepRecordsRegExp) keepRecordsRegExp=options.keepRecordsRegExp;

        var start = new Date();

        var ntuples = {},
            ldr,
            dataLabel,
            dataValue,
            ldrs,
            i, ii, position, endLine, infos;

        var result = {};
        result.profiling = [];
        result.logs = [];
        var spectra = [];
        result.spectra = spectra;
        result.info = {};
        var spectrum = {};

        if (!(typeof jcamp === 'string')) return result;
        // console.time('start');

        if (result.profiling) result.profiling.push({action: 'Before split to LDRS', time: new Date() - start});

        ldrs = jcamp.split(/[\r\n]+##/);

        if (result.profiling) result.profiling.push({action: 'Split to LDRS', time: new Date() - start});

        if (ldrs[0]) ldrs[0] = ldrs[0].replace(/^[\r\n ]*##/, '');

        for (i = 0, ii = ldrs.length; i < ii; i++) {
            ldr = ldrs[i];
            // This is a new LDR
            position = ldr.indexOf('=');
            if (position > 0) {
                dataLabel = ldr.substring(0, position);
                dataValue = ldr.substring(position + 1).trim();
            } else {
                dataLabel = ldr;
                dataValue = '';
            }
            dataLabel = dataLabel.replace(/[_ -]/g, '').toUpperCase();

            if (dataLabel === 'DATATABLE') {
                endLine = dataValue.indexOf('\n');
                if (endLine === -1) endLine = dataValue.indexOf('\r');
                if (endLine > 0) {
                    var xIndex = -1;
                    var yIndex = -1;
                    // ##DATA TABLE= (X++(I..I)), XYDATA
                    // We need to find the variables

                    infos = dataValue.substring(0, endLine).split(/[ ,;\t]+/);
                    if (infos[0].indexOf('++') > 0) {
                        var firstVariable = infos[0].replace(/.*\(([a-zA-Z0-9]+)\+\+.*/, '$1');
                        var secondVariable = infos[0].replace(/.*\.\.([a-zA-Z0-9]+).*/, '$1');
                        xIndex = ntuples.symbol.indexOf(firstVariable);
                        yIndex = ntuples.symbol.indexOf(secondVariable);
                    }

                    if (xIndex === -1) xIndex = 0;
                    if (yIndex === -1) yIndex = 0;

                    if (ntuples.first) {
                        if (ntuples.first.length > xIndex) spectrum.firstX = ntuples.first[xIndex];
                        if (ntuples.first.length > yIndex) spectrum.firstY = ntuples.first[yIndex];
                    }
                    if (ntuples.last) {
                        if (ntuples.last.length > xIndex) spectrum.lastX = ntuples.last[xIndex];
                        if (ntuples.last.length > yIndex) spectrum.lastY = ntuples.last[yIndex];
                    }
                    if (ntuples.vardim && ntuples.vardim.length > xIndex) {
                        spectrum.nbPoints = ntuples.vardim[xIndex];
                    }
                    if (ntuples.factor) {
                        if (ntuples.factor.length > xIndex) spectrum.xFactor = ntuples.factor[xIndex];
                        if (ntuples.factor.length > yIndex) spectrum.yFactor = ntuples.factor[yIndex];
                    }
                    if (ntuples.units) {
                        if (ntuples.units.length > xIndex) spectrum.xUnit = ntuples.units[xIndex];
                        if (ntuples.units.length > yIndex) spectrum.yUnit = ntuples.units[yIndex];
                    }
                    spectrum.datatable = infos[0];
                    if (infos[1] && infos[1].indexOf('PEAKS') > -1) {
                        dataLabel = 'PEAKTABLE';
                    } else if (infos[1] && (infos[1].indexOf('XYDATA') || infos[0].indexOf('++') > 0)) {
                        dataLabel = 'XYDATA';
                        spectrum.deltaX = (spectrum.lastX - spectrum.firstX) / (spectrum.nbPoints - 1);
                    }
                }
            }


            if (dataLabel === 'TITLE') {
                spectrum.title = dataValue;
            } else if (dataLabel === 'DATATYPE') {
                spectrum.dataType = dataValue;
                if (dataValue.indexOf('nD') > -1) {
                    result.twoD = true;
                }
            } else if (dataLabel === 'XUNITS') {
                spectrum.xUnit = dataValue;
            } else if (dataLabel === 'YUNITS') {
                spectrum.yUnit = dataValue;
            } else if (dataLabel === 'FIRSTX') {
                spectrum.firstX = parseFloat(dataValue);
            } else if (dataLabel === 'LASTX') {
                spectrum.lastX = parseFloat(dataValue);
            } else if (dataLabel === 'FIRSTY') {
                spectrum.firstY = parseFloat(dataValue);
            } else if (dataLabel === 'NPOINTS') {
                spectrum.nbPoints = parseFloat(dataValue);
            } else if (dataLabel === 'XFACTOR') {
                spectrum.xFactor = parseFloat(dataValue);
            } else if (dataLabel === 'YFACTOR') {
                spectrum.yFactor = parseFloat(dataValue);
            } else if (dataLabel === 'DELTAX') {
                spectrum.deltaX = parseFloat(dataValue);
            } else if (dataLabel === '.OBSERVEFREQUENCY' || dataLabel === '$SFO1') {
                if (!spectrum.observeFrequency) spectrum.observeFrequency = parseFloat(dataValue);
            } else if (dataLabel === '.OBSERVENUCLEUS') {
                if (!spectrum.xType) result.xType = dataValue.replace(/[^a-zA-Z0-9]/g, '');
            } else if (dataLabel === '$SFO2') {
                if (!result.indirectFrequency) result.indirectFrequency = parseFloat(dataValue);

            } else if (dataLabel === '$OFFSET') {   // OFFSET for Bruker spectra
                result.shiftOffsetNum = 0;
                if (!result.shiftOffsetVal)  result.shiftOffsetVal = parseFloat(dataValue);
            } else if (dataLabel === '$REFERENCEPOINT') {   // OFFSET for Varian spectra


                // if we activate this part it does not work for ACD specmanager
                //         } else if (dataLabel=='.SHIFTREFERENCE') {   // OFFSET FOR Bruker Spectra
                //                 var parts = dataValue.split(/ *, */);
                //                 result.shiftOffsetNum = parseInt(parts[2].trim());
                //                 result.shiftOffsetVal = parseFloat(parts[3].trim());
            } else if (dataLabel === 'VARNAME') {
                ntuples.varname = dataValue.split(/[, \t]{2,}/);
            } else if (dataLabel === 'SYMBOL') {
                ntuples.symbol = dataValue.split(/[, \t]{2,}/);
            } else if (dataLabel === 'VARTYPE') {
                ntuples.vartype = dataValue.split(/[, \t]{2,}/);
            } else if (dataLabel === 'VARFORM') {
                ntuples.varform = dataValue.split(/[, \t]{2,}/);
            } else if (dataLabel === 'VARDIM') {
                ntuples.vardim = convertToFloatArray(dataValue.split(/[, \t]{2,}/));
            } else if (dataLabel === 'UNITS') {
                ntuples.units = dataValue.split(/[, \t]{2,}/);
            } else if (dataLabel === 'FACTOR') {
                ntuples.factor = convertToFloatArray(dataValue.split(/[, \t]{2,}/));
            } else if (dataLabel === 'FIRST') {
                ntuples.first = convertToFloatArray(dataValue.split(/[, \t]{2,}/));
            } else if (dataLabel === 'LAST') {
                ntuples.last = convertToFloatArray(dataValue.split(/[, \t]{2,}/));
            } else if (dataLabel === 'MIN') {
                ntuples.min = convertToFloatArray(dataValue.split(/[, \t]{2,}/));
            } else if (dataLabel === 'MAX') {
                ntuples.max = convertToFloatArray(dataValue.split(/[, \t]{2,}/));
            } else if (dataLabel === '.NUCLEUS') {
                if (result.twoD) {
                    result.yType = dataValue.split(/[, \t]{2,}/)[0];
                }
            } else if (dataLabel === 'PAGE') {
                spectrum.page = dataValue.trim();
                spectrum.pageValue = parseFloat(dataValue.replace(/^.*=/, ''));
                spectrum.pageSymbol = spectrum.page.replace(/=.*/, '');
                var pageSymbolIndex = ntuples.symbol.indexOf(spectrum.pageSymbol);
                var unit = '';
                if (ntuples.units && ntuples.units[pageSymbolIndex]) {
                    unit = ntuples.units[pageSymbolIndex];
                }
                if (result.indirectFrequency && unit !== 'PPM') {
                    spectrum.pageValue /= result.indirectFrequency;
                }
            } else if (dataLabel === 'RETENTIONTIME') {
                spectrum.pageValue = parseFloat(dataValue);
            } else if (dataLabel === 'XYDATA') {
                prepareSpectrum(result, spectrum);
                // well apparently we should still consider it is a PEAK TABLE if there are no '++' after
                if (dataValue.match(/.*\+\+.*/)) {
                    parseXYData(spectrum, dataValue, result);
                } else {
                    parsePeakTable(spectrum, dataValue, result);
                }
                spectra.push(spectrum);
                spectrum = {};
            } else if (dataLabel === 'PEAKTABLE') {
                prepareSpectrum(result, spectrum);
                parsePeakTable(spectrum, dataValue, result);
                spectra.push(spectrum);
                spectrum = {};
            } else if (isMSField(dataLabel)) {
                spectrum[convertMSFieldToLabel(dataLabel)] = dataValue;
            } else if (dataLabel.match(keepRecordsRegExp)) {
                result.info[dataLabel] = dataValue.trim();
            }
        }

        // Currently disabled
        //    if (options && options.lowRes) addLowRes(spectra,options);

        if (result.profiling) result.profiling.push({action: 'Finished parsing', time: new Date() - start});

        if (Object.keys(ntuples).length>0) {
            var newNtuples=[];
            var keys=Object.keys(ntuples);
            for (var i=0; i<keys.length; i++) {
                var key=keys[i];
                var values=ntuples[key];
                for (var j=0; j<values.length; j++) {
                    if (! newNtuples[j]) newNtuples[j]={};
                    newNtuples[j][key]=values[j];
                }
            }
            result.ntuples=newNtuples;
        }

        if (result.twoD) {
            add2D(result);
            if (result.profiling) result.profiling.push({
                action: 'Finished countour plot calculation',
                time: new Date() - start
            });
            if (!options.keepSpectra) {
                delete result.spectra;
            }
        }


        // maybe it is a GC (HPLC) / MS. In this case we add a new format
        if (spectra.length > 1 && (! spectra[0].dataType || spectra[0].dataType.toLowerCase().match(/.*mass./))) {
            addGCMS(result);
            if (result.profiling) result.profiling.push({
                action: 'Finished GCMS calculation',
                time: new Date() - start
            });
        }


        if (options.xy) { // the spectraData should not be a oneD array but an object with x and y
            if (spectra.length > 0) {
                for (var i=0; i<spectra.length; i++) {
                    var spectrum=spectra[i];
                    if (spectrum.data.length>0) {
                        for (var j=0; j<spectrum.data.length; j++) {
                            var data=spectrum.data[j];
                            var newData={x:Array(data.length/2), y:Array(data.length/2)};
                            for (var k=0; k<data.length; k=k+2) {
                                newData.x[k/2]=data[k];
                                newData.y[k/2]=data[k+1];
                            }
                            spectrum.data[j]=newData;
                        }

                    }

                }
            }
        }

        if (result.profiling) {
            result.profiling.push({action: 'Total time', time: new Date() - start});
        }

        //   console.log(result);
        //    console.log(JSON.stringify(spectra));
        return result;

    }


    function convertMSFieldToLabel(value) {
        return value.toLowerCase().replace(/[^a-z0-9]/g, '');
    }

    function isMSField(dataLabel) {
        for (var i = 0; i < GC_MS_FIELDS.length; i++) {
            if (dataLabel === GC_MS_FIELDS[i]) return true;
        }
        return false;
    }

    function addGCMS(result) {
        var spectra = result.spectra;
        var existingGCMSFields = [];
        var i;
        for (i = 0; i < GC_MS_FIELDS.length; i++) {
            var label = convertMSFieldToLabel(GC_MS_FIELDS[i]);
            if (spectra[0][label]) {
                existingGCMSFields.push(label);
            }
        }
        if (existingGCMSFields.length===0) return;
        var gcms = {};
        gcms.gc = {};
        gcms.ms = [];
        for (i = 0; i < existingGCMSFields.length; i++) {
            gcms.gc[existingGCMSFields[i]] = [];
        }
        for (i = 0; i < spectra.length; i++) {
            var spectrum = spectra[i];
            for (var j = 0; j < existingGCMSFields.length; j++) {
                gcms.gc[existingGCMSFields[j]].push(spectrum.pageValue);
                gcms.gc[existingGCMSFields[j]].push(parseFloat(spectrum[existingGCMSFields[j]]));
            }
          if (spectrum.data) gcms.ms[i] = spectrum.data[0];

        }
        result.gcms = gcms;
    }

    function prepareSpectrum(result, spectrum) {
        if (!spectrum.xFactor) spectrum.xFactor = 1;
        if (!spectrum.yFactor) spectrum.yFactor = 1;
        if (spectrum.observeFrequency) {
            if (spectrum.xUnit && spectrum.xUnit.toUpperCase() === 'HZ') {
                spectrum.xUnit = 'PPM';
                spectrum.xFactor = spectrum.xFactor / spectrum.observeFrequency;
                spectrum.firstX = spectrum.firstX / spectrum.observeFrequency;
                spectrum.lastX = spectrum.lastX / spectrum.observeFrequency;
                spectrum.deltaX = spectrum.deltaX / spectrum.observeFrequency;
            }
        }
        if (result.shiftOffsetVal) {
            var shift = spectrum.firstX - result.shiftOffsetVal;
            spectrum.firstX = spectrum.firstX - shift;
            spectrum.lastX = spectrum.lastX - shift;
        }
    }

    function parsePeakTable(spectrum, value, result) {
        spectrum.isPeaktable=true;
        var i, ii, j, jj, values;
        var currentData = [];
        spectrum.data = [currentData];

        // counts for around 20% of the time
        var lines = value.split(/,? *,?[;\r\n]+ */);

        var k = 0;
        for (i = 1, ii = lines.length; i < ii; i++) {
            values = lines[i].trim().replace(removeCommentRegExp, '').split(peakTableSplitRegExp);
            if (values.length % 2 === 0) {
                for (j = 0, jj = values.length; j < jj; j = j + 2) {
                    // takes around 40% of the time to add and parse the 2 values nearly exclusively because of parseFloat
                    currentData[k++] = (parseFloat(values[j]) * spectrum.xFactor);
                    currentData[k++] = (parseFloat(values[j + 1]) * spectrum.yFactor);
                }
            } else {
                result.logs.push('Format error: ' + values);
            }
        }
    }

    function parseXYData(spectrum, value, result) {
        // we check if deltaX is defined otherwise we calculate it
        if (!spectrum.deltaX) {
            spectrum.deltaX = (spectrum.lastX - spectrum.firstX) / (spectrum.nbPoints - 1);
        }

        spectrum.isXYdata=true;

        var currentData = [];
        spectrum.data = [currentData];

        var currentX = spectrum.firstX;
        var currentY = spectrum.firstY;
        var lines = value.split(/[\r\n]+/);
        var lastDif, values, ascii, expectedY;
        values = [];
        for (var i = 1, ii = lines.length; i < ii; i++) {
            //var previousValues=JSON.parse(JSON.stringify(values));
            values = lines[i].trim().replace(removeCommentRegExp, '').split(xyDataSplitRegExp);
            if (values.length > 0) {
                if (DEBUG) {
                    if (!spectrum.firstPoint) {
                        spectrum.firstPoint = parseFloat(values[0]);
                    }
                    var expectedCurrentX = parseFloat(values[0] - spectrum.firstPoint) * spectrum.xFactor + spectrum.firstX;
                    if ((lastDif || lastDif === 0)) {
                        expectedCurrentX += spectrum.deltaX;
                    }
                    result.logs.push('Checking X value: currentX: ' + currentX + ' - expectedCurrentX: ' + expectedCurrentX);
                }
                for (var j = 1, jj = values.length; j < jj; j++) {
                    if (j === 1 && (lastDif || lastDif === 0)) {
                        lastDif = null; // at the beginning of each line there should be the full value X / Y so the diff is always undefined
                        // we could check if we have the expected Y value
                        ascii = values[j].charCodeAt(0);

                        if (false) { // this code is just to check the jcamp DIFDUP and the next line repeat of Y value
                            // + - . 0 1 2 3 4 5 6 7 8 9
                            if ((ascii === 43) || (ascii === 45) || (ascii === 46) || ((ascii > 47) && (ascii < 58))) {
                                expectedY = parseFloat(values[j]);
                            } else
                            // positive SQZ digits @ A B C D E F G H I (ascii 64-73)
                            if ((ascii > 63) && (ascii < 74)) {
                                // we could use parseInt but parseFloat is faster at least in Chrome
                                expectedY = parseFloat(String.fromCharCode(ascii - 16) + values[j].substring(1));
                            } else
                            // negative SQZ digits a b c d e f g h i (ascii 97-105)
                            if ((ascii > 96) && (ascii < 106)) {
                                // we could use parseInt but parseFloat is faster at least in Chrome
                                expectedY = -parseFloat(String.fromCharCode(ascii - 48) + values[j].substring(1));
                            }
                            if (expectedY !== currentY) {
                                result.logs.push('Y value check error: Found: ' + expectedY + ' - Current: ' + currentY);
                                result.logs.push('Previous values: ' + previousValues.length);
                                result.logs.push(previousValues);
                            }
                        }
                    } else {
                        if (values[j].length > 0) {
                            ascii = values[j].charCodeAt(0);
                            // + - . 0 1 2 3 4 5 6 7 8 9
                            if ((ascii === 43) || (ascii === 45) || (ascii === 46) || ((ascii > 47) && (ascii < 58))) {
                                lastDif = null;
                                currentY = parseFloat(values[j]);
                                currentData.push(currentX, currentY * spectrum.yFactor);;
                                currentX += spectrum.deltaX;
                            } else
                            // positive SQZ digits @ A B C D E F G H I (ascii 64-73)
                            if ((ascii > 63) && (ascii < 74)) {
                                lastDif = null;
                                currentY = parseFloat(String.fromCharCode(ascii - 16) + values[j].substring(1));
                                currentData.push(currentX, currentY * spectrum.yFactor);;
                                currentX += spectrum.deltaX;
                            } else
                            // negative SQZ digits a b c d e f g h i (ascii 97-105)
                            if ((ascii > 96) && (ascii < 106)) {
                                lastDif = null;
                                currentY = -parseFloat(String.fromCharCode(ascii - 48) + values[j].substring(1));
                                currentData.push(currentX, currentY * spectrum.yFactor);;
                                currentX += spectrum.deltaX;
                            } else



                            // DUP digits S T U V W X Y Z s (ascii 83-90, 115)
                            if (((ascii > 82) && (ascii < 91)) || (ascii === 115)) {
                                var dup = parseFloat(String.fromCharCode(ascii - 34) + values[j].substring(1)) - 1;
                                if (ascii === 115) {
                                    dup = parseFloat('9' + values[j].substring(1)) - 1;
                                }
                                for (var l = 0; l < dup; l++) {
                                    if (lastDif) {
                                        currentY = currentY + lastDif;
                                    }
                                    currentData.push(currentX, currentY * spectrum.yFactor);;
                                    currentX += spectrum.deltaX;
                                }
                            } else
                            // positive DIF digits % J K L M N O P Q R (ascii 37, 74-82)
                            if (ascii === 37) {
                                lastDif = parseFloat('0' + values[j].substring(1));
                                currentY += lastDif;
                                currentData.push(currentX, currentY * spectrum.yFactor);;
                                currentX += spectrum.deltaX;
                            } else if ((ascii > 73) && (ascii < 83)) {
                                lastDif = parseFloat(String.fromCharCode(ascii - 25) + values[j].substring(1));
                                currentY += lastDif;
                                currentData.push(currentX, currentY * spectrum.yFactor);;
                                currentX += spectrum.deltaX;
                            } else
                            // negative DIF digits j k l m n o p q r (ascii 106-114)
                            if ((ascii > 105) && (ascii < 115)) {
                                lastDif = -parseFloat(String.fromCharCode(ascii - 57) + values[j].substring(1));
                                currentY += lastDif;
                                currentData.push(currentX, currentY * spectrum.yFactor);;
                                currentX += spectrum.deltaX;
                            }
                        }
                    }
                }
            }
        }

    }

    function convertTo3DZ(spectra) {
        var noise = 0;
        var minZ = spectra[0].data[0][0];
        var maxZ = minZ;
        var ySize = spectra.length;
        var xSize = spectra[0].data[0].length / 2;
        var z = new Array(ySize);
        for (var i = 0; i < ySize; i++) {
            z[i] = new Array(xSize);
            for (var j = 0; j < xSize; j++) {
                z[i][j] = spectra[i].data[0][j * 2 + 1];
                if (z[i][j] < minZ) minZ = spectra[i].data[0][j * 2 + 1];
                if (z[i][j] > maxZ) maxZ = spectra[i].data[0][j * 2 + 1];
                if (i !== 0 && j !== 0) {
                    noise += Math.abs(z[i][j] - z[i][j - 1]) + Math.abs(z[i][j] - z[i - 1][j]);
                }
            }
        }
        return {
            z: z,
            minX: spectra[0].data[0][0],
            maxX: spectra[0].data[0][spectra[0].data[0].length - 2],
            minY: spectra[0].pageValue,
            maxY: spectra[ySize - 1].pageValue,
            minZ: minZ,
            maxZ: maxZ,
            noise: noise / ((ySize - 1) * (xSize - 1) * 2)
        };

    }

    function add2D(result) {
        var zData = convertTo3DZ(result.spectra);
        result.contourLines = generateContourLines(zData);
        delete zData.z;
        result.minMax = zData;
    }


    function generateContourLines(zData, options) {
        //console.time('generateContourLines');
        var noise = zData.noise;
        var z = zData.z;
        var contourLevels = [];
        var nbLevels = 7;
        var povarHeight = new Float32Array(4);
        var isOver = [];
        var nbSubSpectra = z.length;
        var nbPovars = z[0].length;
        var pAx, pAy, pBx, pBy;

        var x0 = zData.minX;
        var xN = zData.maxX;
        var dx = (xN - x0) / (nbPovars - 1);
        var y0 = zData.minY;
        var yN = zData.maxY;
        var dy = (yN - y0) / (nbSubSpectra - 1);
        var minZ = zData.minZ;
        var maxZ = zData.maxZ;

        //System.out.prvarln('y0 '+y0+' yN '+yN);
        // -------------------------
        // Povars attribution
        //
        // 0----1
        // |  / |
        // | /  |
        // 2----3
        //
        // ---------------------d------

        var lineZValue;
        for (var level = 0; level < nbLevels * 2; level++) { // multiply by 2 for positif and negatif
            var contourLevel = {};
            contourLevels.push(contourLevel);
            var side = level % 2;
            if (side === 0) {
                lineZValue = (maxZ - 5 * noise) * Math.exp(level / 2 - nbLevels) + 5 * noise;
            } else {
                lineZValue = -(maxZ - 5 * noise) * Math.exp(level / 2 - nbLevels) - 5 * noise;
            }
            var lines = [];
            contourLevel.zValue = lineZValue;
            contourLevel.lines = lines;

            if (lineZValue <= minZ || lineZValue >= maxZ) continue;

            for (var iSubSpectra = 0; iSubSpectra < nbSubSpectra - 1; iSubSpectra++) {
                for (var povar = 0; povar < nbPovars - 1; povar++) {
                    povarHeight[0] = z[iSubSpectra][povar];
                    povarHeight[1] = z[iSubSpectra][povar + 1];
                    povarHeight[2] = z[(iSubSpectra + 1)][povar];
                    povarHeight[3] = z[(iSubSpectra + 1)][(povar + 1)];

                    for (var i = 0; i < 4; i++) {
                        isOver[i] = (povarHeight[i] > lineZValue);
                    }

                    // Example povar0 is over the plane and povar1 and
                    // povar2 are below, we find the varersections and add
                    // the segment
                    if (isOver[0] !== isOver[1] && isOver[0] !== isOver[2]) {
                        pAx = povar + (lineZValue - povarHeight[0]) / (povarHeight[1] - povarHeight[0]);
                        pAy = iSubSpectra;
                        pBx = povar;
                        pBy = iSubSpectra + (lineZValue - povarHeight[0]) / (povarHeight[2] - povarHeight[0]);
                        lines.push(pAx * dx + x0, pAy * dy + y0, pBx * dx + x0, pBy * dy + y0);
                    }
                    if (isOver[3] !== isOver[1] && isOver[3] !== isOver[2]) {
                        pAx = povar + 1;
                        pAy = iSubSpectra + 1 - (lineZValue - povarHeight[3]) / (povarHeight[1] - povarHeight[3]);
                        pBx = povar + 1 - (lineZValue - povarHeight[3]) / (povarHeight[2] - povarHeight[3]);
                        pBy = iSubSpectra + 1;
                        lines.push(pAx * dx + x0, pAy * dy + y0, pBx * dx + x0, pBy * dy + y0);
                    }
                    // test around the diagonal
                    if (isOver[1] !== isOver[2]) {
                        pAx = povar + 1 - (lineZValue - povarHeight[1]) / (povarHeight[2] - povarHeight[1]);
                        pAy = iSubSpectra + (lineZValue - povarHeight[1]) / (povarHeight[2] - povarHeight[1]);
                        if (isOver[1] !== isOver[0]) {
                            pBx = povar + 1 - (lineZValue - povarHeight[1]) / (povarHeight[0] - povarHeight[1]);
                            pBy = iSubSpectra;
                            lines.push(pAx * dx + x0, pAy * dy + y0, pBx * dx + x0, pBy * dy + y0);
                        }
                        if (isOver[2] !== isOver[0]) {
                            pBx = povar;
                            pBy = iSubSpectra + 1 - (lineZValue - povarHeight[2]) / (povarHeight[0] - povarHeight[2]);
                            lines.push(pAx * dx + x0, pAy * dy + y0, pBx * dx + x0, pBy * dy + y0);
                        }
                        if (isOver[1] !== isOver[3]) {
                            pBx = povar + 1;
                            pBy = iSubSpectra + (lineZValue - povarHeight[1]) / (povarHeight[3] - povarHeight[1]);
                            lines.push(pAx * dx + x0, pAy * dy + y0, pBx * dx + x0, pBy * dy + y0);
                        }
                        if (isOver[2] !== isOver[3]) {
                            pBx = povar + (lineZValue - povarHeight[2]) / (povarHeight[3] - povarHeight[2]);
                            pBy = iSubSpectra + 1;
                            lines.push(pAx * dx + x0, pAy * dy + y0, pBx * dx + x0, pBy * dy + y0);
                        }
                    }
                }
            }
        }
        // console.timeEnd('generateContourLines');
        return {
            minX: zData.minX,
            maxX: zData.maxX,
            minY: zData.minY,
            maxY: zData.maxY,
            segments: contourLevels
        };
        //return contourLevels;
    }


    function addLowRes(spectra, options) {
        var spectrum;
        var averageX, averageY;
        var targetNbPoints = options.lowRes;
        var highResData;
        for (var i = 0; i < spectra.length; i++) {
            spectrum = spectra[i];
            // we need to find the current higher resolution
            if (spectrum.data.length > 0) {
                highResData = spectrum.data[0];
                for (var j = 1; j < spectrum.data.length; j++) {
                    if (spectrum.data[j].length > highResData.length) {
                        highResData = spectrum.data[j];
                    }
                }

                if (targetNbPoints > (highResData.length / 2)) return;
                var i, ii;
                var lowResData = [];
                var modulo = Math.ceil(highResData.length / (targetNbPoints * 2));
                for (i = 0, ii = highResData.length; i < ii; i = i + 2) {
                    if (i % modulo === 0) {
                        lowResData.push(highResData[i], highResData[i + 1])
                    }
                }
                spectrum.data.push(lowResData);
            }
        }
    }

    return convert;

}

var convert = getConverter();

function JcampConverter(input, options, useWorker) {
    if (typeof options === 'boolean') {
        useWorker = options;
        options = {};
    }
    if (useWorker) {
        return postToWorker(input, options);
    } else {
        return convert(input, options);
    }
}

var stamps = {},
    worker;

function postToWorker(input, options) {
    if (!worker) {
        createWorker();
    }
    return new Promise(function (resolve) {
        var stamp = Date.now() + '' + Math.random();
        stamps[stamp] = resolve;
        worker.postMessage({stamp: stamp, input: input, options: options});
    });
}

function createWorker() {
    var workerURL = URL.createObjectURL(new Blob([
        'var getConverter =' + getConverter.toString() + ';var convert = getConverter(); onmessage = function (event) { postMessage({stamp: event.data.stamp, output: convert(event.data.input, event.data.options)}); };'
    ], {type: 'application/javascript'}));
    worker = new Worker(workerURL);
    URL.revokeObjectURL(workerURL);
    worker.addEventListener('message', function (event) {
        var stamp = event.data.stamp;
        if (stamps[stamp]) {
            stamps[stamp](event.data.output);
        }
    });
}

module.exports = {
    convert: JcampConverter
};
},{}],6:[function(require,module,exports){
var nanoModal;!function a(b,c,d){function e(g,h){if(!c[g]){if(!b[g]){var i="function"==typeof require&&require;if(!h&&i)return i(g,!0);if(f)return f(g,!0);throw new Error("Cannot find module '"+g+"'")}var j=c[g]={exports:{}};b[g][0].call(j.exports,function(a){var c=b[g][1][a];return e(c?c:a)},j,j.exports,a,b,c,d)}return c[g].exports}for(var f="function"==typeof require&&require,g=0;g<d.length;g++)e(d[g]);return e}({1:[function(a,b,c){function d(a,b){var c=document,d=a.nodeType||a===window?a:c.createElement(a),f=[];b&&(d.className=b);var g=e(),h=e(),i=function(a,b){d.addEventListener?d.addEventListener(a,b,!1):d.attachEvent("on"+a,b),f.push({event:a,handler:b})},j=function(a,b){d.removeEventListener?d.removeEventListener(a,b):d.detachEvent("on"+a,b);for(var c,e=f.length;e-->0;)if(c=f[e],c.event===a&&c.handler===b){f.splice(e,1);break}},k=function(a){var b=!1,c=function(c){b||(b=!0,setTimeout(function(){b=!1},100),a(c))};i("touchstart",c),i("mousedown",c)},l=function(a){d&&(d.style.display="block",g.fire(a))},m=function(a){d&&(d.style.display="none",h.fire(a))},n=function(){return d.style&&"block"===d.style.display},o=function(a){d&&(d.innerHTML=a)},p=function(a){d&&(o(""),d.appendChild(c.createTextNode(a)))},q=function(){if(d.parentNode){for(var a,b=f.length;b-->0;)a=f[b],j(a.event,a.handler);d.parentNode.removeChild(d),g.removeAllListeners(),h.removeAllListeners()}},r=function(a){var b=a.el||a;d.appendChild(b)};return{el:d,addListener:i,addClickListener:k,onShowEvent:g,onHideEvent:h,show:l,hide:m,isShowing:n,html:o,text:p,remove:q,add:r}}var e=a("./ModalEvent");b.exports=d},{"./ModalEvent":3}],2:[function(a,b,c){function d(a,b,c,f,g){if(void 0!==a){b=b||{};var h,i=e("div","nanoModal nanoModalOverride "+(b.classes||"")),j=e("div","nanoModalContent"),k=e("div","nanoModalButtons");i.add(j),i.add(k),i.el.style.display="none";var l,m=[];b.buttons=b.buttons||[{text:"Close",handler:"hide",primary:!0}];var n=function(){for(var a=m.length;a-->0;){var b=m[a];b.remove()}m=[]},o=function(){i.el.style.marginLeft=-i.el.clientWidth/2+"px"},p=function(){for(var a=document.querySelectorAll(".nanoModal"),b=a.length;b-->0;)if("none"!==a[b].style.display)return!0;return!1},q=function(){i.isShowing()||(d.resizeOverlay(),c.show(c),i.show(l),o())},r=function(){i.isShowing()&&(i.hide(l),p()||c.hide(c),b.autoRemove&&l.remove())},s=function(a){var b={};for(var c in a)a.hasOwnProperty(c)&&(b[c]=a[c]);return b};return l={modal:i,overlay:c,show:function(){return f?f(q,l):q(),l},hide:function(){return g?g(r,l):r(),l},onShow:function(a){return i.onShowEvent.addListener(function(){a(l)}),l},onHide:function(a){return i.onHideEvent.addListener(function(){a(l)}),l},remove:function(){c.onRequestHide.removeListener(h),h=null,n(),i.remove()},setButtons:function(a){var b,c,d,f=a.length,g=function(a,b){var c=s(l);a.addClickListener(function(a){c.event=a||window.event,b.handler(c)})};if(n(),0===f)k.hide();else for(k.show();f-->0;)b=a[f],d="nanoModalBtn",b.primary&&(d+=" nanoModalBtnPrimary"),d+=b.classes?" "+b.classes:"",c=e("button",d),"hide"===b.handler?c.addClickListener(l.hide):b.handler&&g(c,b),c.text(b.text),k.add(c),m.push(c);return o(),l},setContent:function(b){return b.nodeType?(j.html(""),j.add(b)):j.html(b),o(),a=b,l},getContent:function(){return a}},h=c.onRequestHide.addListener(function(){b.overlayClose!==!1&&i.isShowing()&&l.hide()}),l.setContent(a).setButtons(b.buttons),document.body.appendChild(i.el),l}}var e=a("./El"),f=document,g=function(a){var b=f.documentElement,c="scroll"+a,d="offset"+a;return Math.max(f.body[c],b[c],f.body[d],b[d],b["client"+a])};d.resizeOverlay=function(){var a=f.getElementById("nanoModalOverlay");a.style.width=g("Width")+"px",a.style.height=g("Height")+"px"},b.exports=d},{"./El":1}],3:[function(a,b,c){function d(){var a={},b=0,c=function(c){return a[b]=c,b++},d=function(b){b&&delete a[b]},e=function(){a={}},f=function(){for(var c=0,d=b;d>c;++c)a[c]&&a[c].apply(null,arguments)};return{addListener:c,removeListener:d,removeAllListeners:e,fire:f}}b.exports=d},{}],4:[function(a,b,c){var d=a("./ModalEvent"),e=function(){
function b(){if(!g.querySelector("#nanoModalOverlay")){var a=e("style"),b=a.el,h=g.querySelectorAll("head")[0].childNodes[0];h.parentNode.insertBefore(b,h);var i=".nanoModal{position:absolute;top:100px;left:50%;display:none;z-index:9999;min-width:300px;padding:15px 20px 10px;-webkit-border-radius:10px;-moz-border-radius:10px;border-radius:10px;background:#fff;background:-moz-linear-gradient(top,#fff 0,#ddd 100%);background:-webkit-gradient(linear,left top,left bottom,color-stop(0%,#fff),color-stop(100%,#ddd));background:-webkit-linear-gradient(top,#fff 0,#ddd 100%);background:-o-linear-gradient(top,#fff 0,#ddd 100%);background:-ms-linear-gradient(top,#fff 0,#ddd 100%);background:linear-gradient(to bottom,#fff 0,#ddd 100%);filter:progid:DXImageTransform.Microsoft.gradient(startColorstr='#ffffff', endColorstr='#dddddd', GradientType=0)}.nanoModalOverlay{position:absolute;top:0;left:0;width:100%;height:100%;z-index:9998;background:#000;display:none;-ms-filter:\"alpha(Opacity=50)\";-moz-opacity:.5;-khtml-opacity:.5;opacity:.5}.nanoModalButtons{border-top:1px solid #ddd;margin-top:15px;text-align:right}.nanoModalBtn{color:#333;background-color:#fff;display:inline-block;padding:6px 12px;margin:8px 4px 0;font-size:14px;text-align:center;white-space:nowrap;vertical-align:middle;cursor:pointer;-webkit-user-select:none;-moz-user-select:none;-ms-user-select:none;user-select:none;border:1px solid transparent;-webkit-border-radius:4px;-moz-border-radius:4px;border-radius:4px}.nanoModalBtn:active,.nanoModalBtn:focus,.nanoModalBtn:hover{color:#333;background-color:#e6e6e6;border-color:#adadad}.nanoModalBtn.nanoModalBtnPrimary{color:#fff;background-color:#428bca;border-color:#357ebd}.nanoModalBtn.nanoModalBtnPrimary:active,.nanoModalBtn.nanoModalBtnPrimary:focus,.nanoModalBtn.nanoModalBtnPrimary:hover{color:#fff;background-color:#3071a9;border-color:#285e8e}";b.styleSheet?b.styleSheet.cssText=i:a.text(i),c=e("div","nanoModalOverlay nanoModalOverride"),c.el.id="nanoModalOverlay",g.body.appendChild(c.el),c.onRequestHide=d();var j=function(){c.onRequestHide.fire()};c.addClickListener(j),e(g).addListener("keydown",function(a){var b=a.which||a.keyCode;27===b&&j()});var k,l=e(window);l.addListener("resize",function(){k&&clearTimeout(k),k=setTimeout(f.resizeOverlay,100)}),l.addListener("orientationchange",function(){for(var a=0;3>a;++a)setTimeout(f.resizeOverlay,1e3*a+200)})}}var c,e=a("./El"),f=a("./Modal"),g=document;document.body&&b();var h=function(a,d){return b(),f(a,d,c,h.customShow,h.customHide)};return h.resizeOverlay=f.resizeOverlay,h}();nanoModal=e},{"./El":1,"./Modal":2,"./ModalEvent":3}]},{},[1,2,3,4]),"undefined"!=typeof window&&("function"==typeof window.define&&window.define.amd&&window.define(function(){return nanoModal}),window.nanoModal=nanoModal),"undefined"!=typeof module&&(module.exports=nanoModal);
},{}],7:[function(require,module,exports){
(function() {
  var out$ = typeof exports != 'undefined' && exports || this;

  var doctype = '<?xml version="1.0" standalone="no"?><!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">';

  function isExternal(url) {
    return url && url.lastIndexOf('http',0) == 0 && url.lastIndexOf(window.location.host) == -1;
  }

  function inlineImages(el, callback) {
    var images = el.querySelectorAll('image');
    var left = images.length;
    if (left == 0) {
      callback();
    }
    for (var i = 0; i < images.length; i++) {
      (function(image) {
        var href = image.getAttribute('xlink:href');
        if (href) {
          if (isExternal(href.value)) {
            console.warn("Cannot render embedded images linking to external hosts: "+href.value);
            return;
          }
        }
        var canvas = document.createElement('canvas');
        var ctx = canvas.getContext('2d');
        var img = new Image();
        href = href || image.getAttribute('href');
        img.src = href;
        img.onload = function() {
          canvas.width = img.width;
          canvas.height = img.height;
          ctx.drawImage(img, 0, 0);
          image.setAttribute('xlink:href', canvas.toDataURL('image/png'));
          left--;
          if (left == 0) {
            callback();
          }
        }
        img.onerror = function() {
          console.log("Could not load "+href);
          left--;
          if (left == 0) {
            callback();
          }
        }
      })(images[i]);
    }
  }

  function styles(el, selectorRemap) {
    var css = "";
    var sheets = document.styleSheets;
    for (var i = 0; i < sheets.length; i++) {
      if (isExternal(sheets[i].href)) {
        console.warn("Cannot include styles from other hosts: "+sheets[i].href);
        continue;
      }
      var rules = sheets[i].cssRules;
      if (rules != null) {
        for (var j = 0; j < rules.length; j++) {
          var rule = rules[j];
          if (typeof(rule.style) != "undefined") {
            var match = null;
            try {
              match = el.querySelector(rule.selectorText);
            } catch(err) {
              console.warn('Invalid CSS selector "' + rule.selectorText + '"', err);
            }
            if (match) {
              var selector = selectorRemap ? selectorRemap(rule.selectorText) : rule.selectorText;
              css += selector + " { " + rule.style.cssText + " }\n";
            } else if(rule.cssText.match(/^@font-face/)) {
              css += rule.cssText + '\n';
            }
          }
        }
      }
    }
    return css;
  }

  out$.svgAsDataUri = function(el, options, cb) {
    options = options || {};
    options.scale = options.scale || 1;
    var xmlns = "http://www.w3.org/2000/xmlns/";

    inlineImages(el, function() {
      var outer = document.createElement("div");
      var clone = el.cloneNode(true);
      var width, height;
      if(el.tagName == 'svg') {
        width = parseInt(clone.getAttribute('width') || clone.style.width || out$.getComputedStyle(el).getPropertyValue('width'));
        height = parseInt(clone.getAttribute('height') || clone.style.height || out$.getComputedStyle(el).getPropertyValue('height'));
      } else {
        var box = el.getBBox();
        width = box.x + box.width;
        height = box.y + box.height;
        clone.setAttribute('transform', clone.getAttribute('transform').replace(/translate\(.*?\)/, ''));

        var svg = document.createElementNS('http://www.w3.org/2000/svg','svg')
        svg.appendChild(clone)
        clone = svg;
      }

      clone.setAttribute("version", "1.1");
      clone.setAttributeNS(xmlns, "xmlns", "http://www.w3.org/2000/svg");
      clone.setAttributeNS(xmlns, "xmlns:xlink", "http://www.w3.org/1999/xlink");
      clone.setAttribute("width", width * options.scale);
      clone.setAttribute("height", height * options.scale);
      clone.setAttribute("viewBox", "0 0 " + width + " " + height);
      outer.appendChild(clone);

      var css = styles(el, options.selectorRemap);
      var s = document.createElement('style');
      s.setAttribute('type', 'text/css');
      s.innerHTML = "<![CDATA[\n" + css + "\n]]>";
      var defs = document.createElement('defs');
      defs.appendChild(s);
      clone.insertBefore(defs, clone.firstChild);

      var svg = doctype + outer.innerHTML;
      var uri = 'data:image/svg+xml;base64,' + window.btoa(unescape(encodeURIComponent(svg)));
      if (cb) {
        cb(uri);
      }
    });
  }

  out$.saveSvgAsPng = function(el, name, options) {
    options = options || {};
    out$.svgAsDataUri(el, options, function(uri) {
      var image = new Image();
      image.src = uri;
      image.onload = function() {
        var canvas = document.createElement('canvas');
        canvas.width = image.width;
        canvas.height = image.height;
        var context = canvas.getContext('2d');
        context.drawImage(image, 0, 0);

        var a = document.createElement('a');
        a.download = name;
        a.href = canvas.toDataURL('image/png');
        document.body.appendChild(a);
        a.addEventListener("click", function(e) {
          a.parentNode.removeChild(a);
        });
        a.click();
      }
    });
  }
})();

},{}],8:[function(require,module,exports){
/*
 Copyright (c) 2012, Vladimir Agafonkin
 Simplify.js is a high-performance polyline simplification library
 mourner.github.com/simplify-js
*/

module.exports = simplify;

// to suit your point format, run search/replace for '.x' and '.y'
// to switch to 3D, uncomment the lines in the next 2 functions
// (configurability would draw significant performance overhead)


function getSquareDistance(p1, p2) { // square distance between 2 points

  var dx = p1.x - p2.x,
//      dz = p1.z - p2.z,
      dy = p1.y - p2.y;

  return dx * dx +
//         dz * dz +
         dy * dy;
}

function getSquareSegmentDistance(p, p1, p2) { // square distance from a point to a segment

  var x = p1.x,
      y = p1.y,
//      z = p1.z,

      dx = p2.x - x,
      dy = p2.y - y,
//      dz = p2.z - z,

      t;

  if (dx !== 0 || dy !== 0) {

    t = ((p.x - x) * dx +
//         (p.z - z) * dz +
         (p.y - y) * dy) /
            (dx * dx +
//             dz * dz +
             dy * dy);

    if (t > 1) {
      x = p2.x;
      y = p2.y;
//      z = p2.z;

    } else if (t > 0) {
      x += dx * t;
      y += dy * t;
//      z += dz * t;
    }
  }

  dx = p.x - x;
  dy = p.y - y;
//  dz = p.z - z;

  return dx * dx +
//         dz * dz +
         dy * dy;
}

// the rest of the code doesn't care for the point format


function simplifyRadialDistance(points, sqTolerance) { // distance-based simplification

  var i,
      len = points.length,
      point,
      prevPoint = points[0],
      newPoints = [prevPoint];

  for (i = 1; i < len; i++) {
    point = points[i];

    if (getSquareDistance(point, prevPoint) > sqTolerance) {
      newPoints.push(point);
      prevPoint = point;
    }
  }

  if (prevPoint !== point) {
    newPoints.push(point);
  }

  return newPoints;
}


// simplification using optimized Douglas-Peucker algorithm with recursion elimination

function simplifyDouglasPeucker(points, sqTolerance) {

  var len = points.length,

      MarkerArray = (typeof Uint8Array !== undefined + '')
                  ? Uint8Array
                  : Array,

      markers = new MarkerArray(len),

      first = 0,
      last  = len - 1,

      i,
      maxSqDist,
      sqDist,
      index,

      firstStack = [],
      lastStack  = [],

      newPoints  = [];

  markers[first] = markers[last] = 1;

  while (last) {

    maxSqDist = 0;

    for (i = first + 1; i < last; i++) {
      sqDist = getSquareSegmentDistance(points[i], points[first], points[last]);

      if (sqDist > maxSqDist) {
        index = i;
        maxSqDist = sqDist;
      }
    }

    if (maxSqDist > sqTolerance) {
      markers[index] = 1;

      firstStack.push(first);
      lastStack.push(index);

      firstStack.push(index);
      lastStack.push(last);
    }

    first = firstStack.pop();
    last = lastStack.pop();
  }

  for (i = 0; i < len; i++) {
    if (markers[i]) {
      newPoints.push(points[i]);
    }
  }

  return newPoints;
}


function simplify(points, tolerance, highestQuality) {

  var sqTolerance = (tolerance !== undefined)
                  ? tolerance * tolerance
                  : 1;

  if (!highestQuality) {
    points = simplifyRadialDistance(points, sqTolerance);
  }
  points = simplifyDouglasPeucker(points, sqTolerance);

  return points;
};

},{}],9:[function(require,module,exports){
function bin(data, binsize) {
  var out = [];
  var bin_index = 0, 
      bin_xval = 0,
      bin_yval = 0;
  for (var i = 0; i < data.length; i++) {
    bin_xval += data[i].x;
    bin_yval += data[i].y;
    bin_index++;
    if(bin_index === binsize){
      out.push( {x:bin_xval/bin_index, y:bin_yval/bin_index} );
      bin_index = bin_xval = bin_yval = 0;
    }
  }
  if(bin_index > 0){
    out.push( {x:bin_xval/bin_index, y:bin_yval/bin_index} );
  }
  return out;
}

module.exports = function (spec_line, binsize) {
  var x_extent = Math.abs( spec_line.range().x[0] - spec_line.range().x[1] );
  var nbins = x_extent / binsize;
  var bin_points = Math.floor( spec_line.datum().length / nbins );
  
  var binned_data = bin(spec_line.datum(), bin_points);
  console.log(binned_data);
	//TODO: upadting data with new size breaks peak picking and integration.
  spec_line.datum(binned_data);
};
},{}],10:[function(require,module,exports){
module.exports = function (){
  function getDataPoint (x_point, pixel_to_i, local_max) {
    var i;
    if(local_max){
      var s_window = [ pixel_to_i( x_point-10 ), pixel_to_i( x_point+10 ) ];

      i = s_window[0] + data.slice(s_window[0],s_window[1]+1).whichMax();
    }else{
      i = pixel_to_i( x_point );          
    }
    return data[i];
  }
  function registerDispatcher() {
    var suff = ".line."+dispatch_idx;
    dispatcher.on("regionchange"+suff, null);
    dispatcher.on("mouseenter"+suff, null);
    dispatcher.on("mouseleave"+suff, null);
    dispatcher.on("mousemove"+suff, null);  
    
    if( enabled ){
      dispatcher.on("regionchange"+suff, svg_elem.on("_regionchange"));
      dispatcher.on("mouseenter"+suff, function(){_main.show(true);});
      dispatcher.on("mouseleave"+suff, function(){_main.show(false);});
      if ( shown ){
        dispatcher.on("mousemove"+suff, svg_elem.on("_mousemove"));  
      }
    }
    dispatcher.on("specDataChange"+suff, function (s) {
      if(s === _main.parent()){_main.datum(s.datum());}
    });
    dispatcher.on("crosshairEnable"+suff, _main.enable);
  }
  
  var x, y, data, dispatcher;
  var svg_elem, dispatch_idx;
  var enabled, shown;
  
  var tip = d3.tip()
    .attr('class', 'crosshair tooltip')
    .direction('ne')
    .offset([0, 0])
    .bootstrap(true);
    
  var core = require('../elem');
  var source = core.SVGElem().class('crosshair');
  core.inherit(_main, source);
  
  function _main(spec_line) {
    x = _main.xScale();
    y = _main.yScale();
    dispatcher = _main.dispatcher();
    dispatch_idx = ++dispatcher.idx;
    enabled = shown = true;
        
    svg_elem = source(spec_line)
      .datum(null).call(tip); // I am clearing the data bound to the selection, not the Elem.
    
    svg_elem.append("circle")
      .attr("class", "clr"+ spec_line.lineIdx())
      .attr("r", 4.5)
      .on("click",function(){
        spec_line.selected( !spec_line.selected() );
      })
      .on("mouseenter",function(){
        spec_line.parent().highlightSpec(spec_line);
      })
      .on("mouseleave",function(){
        spec_line.parent().highlightSpec();
      });

    svg_elem
      .on("_regionchange", function(e){
        if(e.xdomain){          
          svg_elem.datum(null);
          svg_elem.attr("transform", "translate(" + (-10000) + "," + (-10000) + ")");
          tip.hide();
        }else{
          var datum = svg_elem.datum();
          if(datum){
            svg_elem.attr("transform", "translate(" + x(datum.x) + "," + y(datum.y) + ")");
            tip.show(svg_elem.node());
          }
        }
      })
      .on("_mousemove", function(e){
        var p = getDataPoint(e.xcoor, spec_line.pixelToi, e.shiftKey);
      
        if(typeof p === 'undefined'){
          svg_elem.datum(null);
          return;
        }
        
        svg_elem.datum(p)
          .attr("transform", "translate(" + x(p.x) + "," + y(p.y) + ")");
        tip.text(d3.round(p.x,3)).show(svg_elem.node());
      })
      .on('remove', function () {
        _main.enabled(false);
        dispatcher.on("crosshairEnable.line."+dispatch_idx, null);
        data = null;
        tip.destroy();
      });
    
    registerDispatcher();
    return svg_elem;                  
  }
  
  _main.show = function (_) {
    if (!arguments.length) {return shown;}
    shown = _;
    
    if (!svg_elem){return _main;}
    svg_elem.style("display", _? null : "none");
    
    if(_) { tip.show(svg_elem); }
    else{tip.hide();}
    
    registerDispatcher();
    return _main;
  };
  _main.enable = function (_) {
    if (!arguments.length) {return enabled;}
    enabled = _;
    
    return _main.show(_);
  };
  _main.datum = function(_){
    if (!arguments.length) {return data;}
    data = _;
    return _main;
  };
  return _main;
};

},{"../elem":22}],11:[function(require,module,exports){
function integrate(data){
  var _cumsum = data.map(function(d) { return d.y; }).cumsum();
  
  var ret = data.map(function(d,i){
    return {x:d.x, y:_cumsum[i]};
  });  
  return ret;
}

module.exports = function (){
  var core = require('../elem');
  var source = core.SVGElem().class('integration');
  core.inherit(IntegElem, source);
  
  var x, y, dispatcher, data;
  var svg_elem, path_elem, text_elem, path;
  var segment, integ_val, integ_factor, reduction_factor;
  
  
  function IntegElem(spec_line){
    function redrawPath() {      
      path_elem
        .datum(data)
        .attr("d", path);
      changeTextPos();
    }
    function changeTextPos() {
      var mid_p = path_elem.node()
        .getPointAtLength(0.5 * path_elem.node().getTotalLength());
  
      text_g.attr("transform", "translate("+ mid_p.x +","+ mid_p.y +")");
      changeText();
    }
    function changeText() {
      text_elem.datum(integ_val)
        .text((integ_val/integ_factor).toFixed(2));
      
      var bbox = text_elem.node().getBBox();
      //console.log(bbox, text_elem.text());
      text_elem.attr("dx", -bbox.width/2);
      
      redrawRect();
    }
    function redrawRect() {
      var bbox = text_elem.node().getBBox();
      //TODO: bbox is zero at rendering
      //console.log(bbox, text_elem.text());
      text_rect.attr("width", bbox.width +4)
        .attr("height", bbox.height +4)        
        .attr("x", bbox.x -2)
        .attr("y", bbox.y -2);
    }
    
    x = IntegElem.xScale();
    y = IntegElem.yScale();
    dispatcher = IntegElem.dispatcher();
    
    svg_elem = source(spec_line);
    IntegElem.updateData();
    if(!integ_factor){ integ_factor = integ_val; }
    if(!reduction_factor){ reduction_factor = 1; }
    
    
    path = d3.svg.line()
      .x(function(d) { return x(d.x); })
      .y(function(d) { return y(d.y/reduction_factor) - y.range()[0]*0.3; });
    
    
    path_elem = svg_elem.append("path")
      .attr("class", "line");
      
    var text_g = svg_elem.append("g")
      .attr("class", "integration-text");
      
    var text_rect = text_g.append("rect");
    
    text_elem = text_g.append("text");
    
    var modals = IntegElem.parentApp().modals();
    
    text_g.on("mouseenter", function () {
      svg_elem.classed("highlight", true);
    })
    .on("mouseleave", function () {
      svg_elem.classed("highlight", false);
    })
    .on("click", d3.contextMenu(
      [{
         title: 'Set integral',
         action: modals.input("Set Integral to: ",
          text_elem.text(),
           function (input) {
            integ_factor = text_elem.datum()/input;
            dispatcher.integ_refactor(integ_factor);
           }
         ),
       }]
    ));
  
    redrawPath();
    svg_elem.on("_redraw", function (e) {
      if(e.x){
        redrawPath();
      }
    })
    .on("_refactor", function (e) {
      IntegElem.integFactor(e);
      changeText();
    })
    .on('_reduction_factor', function (e) {
      IntegElem.reductionFactor(e);
      redrawPath();
    });
    
    // Register event listeners
    
    var dispatch_idx = ++dispatcher.idx;
    dispatcher.on("redraw.integ."+dispatch_idx, svg_elem.on("_redraw"));
    dispatcher.on("integ_refactor."+dispatch_idx, svg_elem.on("_refactor"));
    dispatcher.on("specDataChange.integ."+dispatch_idx, function (s) {
      if(s === IntegElem.parent()){
        if(integ_factor === integ_val){ // if the integral is equal to 1.00, keep it.
          IntegElem.updateData();
          integ_factor = integ_val;
          dispatcher.integ_refactor(integ_factor);
        }else{
          IntegElem.updateData();
        }        
      }
    });
  }
  
    
  IntegElem.segment = function (_) {
    if (!arguments.length) {return segment;}
    segment = _;
    
    return IntegElem.updateData();
  };
  IntegElem.updateData = function () {
    if (! (segment && svg_elem) ) { // not initialized or no segments.
      integ_val = undefined;
      return IntegElem;
    }
    
    var spec_line = IntegElem.parent();
    data = integrate (Array.prototype.slice.apply( spec_line.datum(), segment ) );
    integ_val = data[ data.length-1 ].y;
    
    return IntegElem;
  };
  IntegElem.integFactor = function (_) {
    if (!arguments.length) {return integ_factor;}
    integ_factor = _;
    
    return IntegElem;
  };
  IntegElem.integValue = function (_) {
    if (!arguments.length) {return integ_val;}
    integ_val = _;
    
    return IntegElem;
  };
  IntegElem.reductionFactor = function (_) {
    if (!arguments.length) {return reduction_factor;}
    reduction_factor = _;
    
    if (IntegElem.sel()){
      IntegElem.sel().on('_redraw')({x:true});
    }
    return IntegElem;
  };
  return IntegElem;
};

},{"../elem":22}],12:[function(require,module,exports){
function calcReductionFactor(spec_container) {
  var seg_len = [];
  var specs = spec_container.spectra();
  for (var i = 0; i < specs.length; i++) {
    seg_len = seg_len.concat(
      specs[i].segments(true).map(
      function (s) {
        return s.integValue();
      })
    );
  }
  
  var red = d3.max( seg_len ) / (spec_container.yScale().domain()[1]*0.5);
  
  spec_container.spectra().forEach(function (s) {
    s.segments(true).forEach(function (seg) {
      seg.reductionFactor(red);
    });
  });
  
  return d3.max( seg_len ) / 0.5;
}
function get_integ_factor(spec_container) {
  var specs = spec_container.spectra();
  var integ_factor;
  for (var i = 0; i < specs.length; i++) {
    var segs = specs[i].segments();
    for (var j = 0; j < segs.length; j++) {
      integ_factor = segs[j].integFactor();
      if(integ_factor){ return integ_factor;}
    }
  }
}

module.exports = function () {
  var core = require('../elem');
  var path_elem = require('./path-simplify')();
  var source = core.SVGElem().class('spec-line');
  core.inherit(SpecLine, source);
  
  
  var data, s_id, spec_label, _crosshair;  //initiailized by parent at generation
  var x, y, dispatcher;                //initiailized by parent at rendering
  var line_idx, range={}, svg_elem;    //initialized by self at rendering
  var i_to_pixel;                     //a scale to convert data point to pixel position
  var ppm_to_i;                       //a scale to convert ppm to data point (reverse of data[i].x)
  
  var selected = true;
  var data_slice, scale_factor = 1;
  var peaks = [], segments = core.ElemArray();
  
  
  function SpecLine(spec_container) {
    x = SpecLine.xScale();
    y = SpecLine.yScale();
    dispatcher = SpecLine.dispatcher();
    i_to_pixel = x.copy();
    
    
    line_idx = spec_container.spectra().indexOf(SpecLine);
    svg_elem = source(spec_container)
      .classed('selected', selected)
      .classed('clr'+line_idx, true);
    
    
        
    path_elem.datum(data)
      .xScale(x)
      .yScale(y)
      .simplify(1)
      .class("line")
      (svg_elem);
    
    if(typeof _crosshair === 'undefined'){
      SpecLine.crosshair(true);
    }
    if(_crosshair){
      _crosshair.xScale(x)
        .yScale(y)
        .dispatcher(dispatcher)
        (SpecLine);
    }
      
    for (var i = 0; i < segments.length; i++) {
      render_segment(segments[i]);
    }
    
    svg_elem
      .on("_redraw", function(e){
        if(e.x){
          path_elem.redraw().sel()
            .attr("transform", 'scale(1,1)translate(0,0)');
          
          //integration
          calcReductionFactor(spec_container);
        }else{ //change is in the Y axis only.
          var orignial_yscale = y.copy().domain(spec_container.range().y);
          
          var translate_coor = [0,
             -Math.min(orignial_yscale(y.domain()[1]), orignial_yscale(y.domain()[0]) )];

          var  scale_coor = [ 1,
            Math.abs((spec_container.range().y[0]-spec_container.range().y[1])/(y.domain()[0]-y.domain()[1]))];
        
          path_elem.sel()
            .attr("transform","scale("+scale_coor+")"+"translate("+ translate_coor +")");
        }
      })
      .on("_regionchange", function(e){
        if(e.xdomain){
          var new_slice = e.xdomain.map(SpecLine.ppmToi);
					// The reason I always update the i_to_pixel scale is that:
					// If the xdomain is larger than the spectrum range, the data slice will equal
					// the data length (i.e all the data is included), even in the xdomain changes.
					i_to_pixel.domain( new_slice )
						.range(new_slice.map(function (i) { return x( data[i].x ); }));
					
          if (data_slice && new_slice[0] === data_slice[0] && new_slice[1] === data_slice[1]){
            return;
          }else{
            data_slice = new_slice;
            
            render_data();
            range.y = path_elem.range().y;
            range.y[0] *= scale_factor;
            range.y[1] *= scale_factor;
          }
        }
      })
      .on("_integrate", function(e){
        var s = e.xdomain.map(SpecLine.ppmToi).sort(d3.ascending);
        SpecLine.addSegment(s);
      })
      .on("_segment", function () {
      });
    
    // Register event listeners
    var dispatch_idx = ++dispatcher.idx;
    dispatcher.on("regionchange.line."+dispatch_idx, svg_elem.on("_regionchange"));
    dispatcher.on("redraw.line."+dispatch_idx, svg_elem.on("_redraw"));
    dispatcher.on("integrate.line."+dispatch_idx, svg_elem.on("_integrate"));
    
    svg_elem.on('remove', function () {
      dispatcher.on("regionchange.line."+dispatch_idx, null);
      dispatcher.on("redraw.line."+dispatch_idx, null);
      dispatcher.on("integrate.line."+dispatch_idx, null);
      data = null;
      if(_crosshair){
        _crosshair.remove();        
      }
    });
    
    //SpecLine.addSegment([1000,1050]);
    return svg_elem;                  
  }
  function render_segment(s) {
    if (!svg_elem){ return; }
    
    s.xScale(x).yScale(y)
      .dispatcher(dispatcher)
      (SpecLine);
  }
  function redraw(x, y) {
    if (!svg_elem){ return; }
    svg_elem.on("_redraw")({x:x, y:y});
  }
  function render_data() {
    //TODO: Update peaks, integrate, segments to match new data.
    if (!svg_elem){ return; }

    //TODO: resample factors both x and y dimensions.
    // Both dimension need to have the same unit, i.e. pixels.                    
    path_elem.datum( Array.prototype.slice.apply(data, data_slice) );    
    svg_elem.on("_redraw")({x:true});
  }
  
  SpecLine.addSegment = function (_) {
    var integ_elem = require('./integration-elem')()
      .segment(_)
      .integFactor(get_integ_factor(SpecLine.parent()));
    
    segments.push(integ_elem);
    
    render_segment(integ_elem);
    calcReductionFactor( SpecLine.parent() );
  };
  SpecLine.delSegment = function (between) {
    segments = segments.filter(function (e) {
      //retain all peaks NOT within the region.
      return !(e >= between[0] && e <= between[1]);
    });
  };
  SpecLine.segments = function (visible) {
    var idx = segments;
    if(visible){ //get only peaks in the visible range (within dataSlice)
      idx = idx.filter(function (s) {
        var e = s.segment();
        return e[0] > data_slice[0] && 
          e[0] < data_slice[1] &&
          e[1] > data_slice[0] && 
          e[1] < data_slice[1];
      });
    }
    return idx;
  };
  SpecLine.addPeaks = function (idx) {
    peaks = peaks.concat(idx);
  };
  SpecLine.delPeaks = function (between) {
    between = between.map(SpecLine.ppmToi).sort(d3.ascending);
    peaks = peaks.filter(function (e) {
      //retain all peaks NOT within the region.
      return !(e >= between[0] && e <= between[1]);
    });
  };
  SpecLine.peaks = function (visible) {
    var idx = peaks;
    if(visible){ //get only peaks in the visible range (within dataSlice)
      idx = idx.filter(function (e) {
        return e > data_slice[0] && e < data_slice[1];
      });
    }
    return data.subset(idx);
  };
  SpecLine.iToPixel = function (_) {
    return i_to_pixel(_);
  };
  SpecLine.pixelToi = function (_) {
    return Math.round( i_to_pixel.invert(_) );
  };
  SpecLine.ppmToi = function (_) {
    console.log('ppm', _);
    var i = Math.round( ppm_to_i(_) );
    i = i > data.length-1 ? data.length-1 : i;
    i = i < 0 ? 0 : i;
    
    if (data[i-1] && Math.abs(_ - data[i].x) > Math.abs(_ - data[i-1].x) ){
      i--;
    }else if(data[i+1] && Math.abs(_ - data[i].x) > Math.abs(_ - data[i+1].x) ){
      i++;
    }
    return i;
  };
  SpecLine.range = function () {
    return range;
  };
  SpecLine.datum = function(_){
    if (!arguments.length) {return data;}
    if(!_[0].x){ //if data is array, not xy format
      if ( data  && data.length === _.length){ // if we are replacing existing data
        // Use the x-coordinates of the old data.
        data = _.map(function(d,i){ return {x:data[i].x, y:d}; });
      }else{
        // Otherwise, create a linespace over the x-axis 
        // over the range of the parent container.
        var xscale = d3.scale.linear()
          .range(SpecLine.parent().range().x)
          .domain([0, _.length]);
      
        data = _.map(function(d,i){ return {x:xscale(i), y:d}; });        
      }
    }else{ // Data is in XY format.
      data = _;
    }
    
    range.x = [data[0].x, data[data.length-1].x];
    range.y = d3.extent(data.map(function(d) { return d.y; }));
    ppm_to_i = d3.scale.linear()
      .range([0, data.length])
      .domain([ data[0].x, data[data.length-1].x ]);
    
    //TODO: Update peaks, integrate, segments to match new data.
    if(dispatcher)
      {dispatcher.specDataChange(SpecLine);}

    render_data();
    return SpecLine;
  };
  SpecLine.label = function(_){
    if (!arguments.length) {return spec_label;}
    spec_label = _;
    return SpecLine;
  };
  SpecLine.crosshair = function(_){
    if (!arguments.length) {return _crosshair;}
    
    if(_){
      _crosshair = require('./crosshair')().datum(data);
    } else {
      _crosshair = false;
    }      
    
    return SpecLine;
  };
  SpecLine.s_id = function(_){
    if (!arguments.length) {return s_id;}
    s_id = _;
    return SpecLine;
  };  
  SpecLine.selected = function(_){
    if (!arguments.length) {return selected;}
    selected = _;
    if(svg_elem){
      svg_elem.classed('selected', _);
    }
    return SpecLine;
  };
  SpecLine.lineIdx = function () {
    return line_idx;
  };
  SpecLine.scaleFactor = function (_) {
    if (!arguments.length) {return scale_factor;}
    scale_factor = _;
    redraw();
    return SpecLine;
  };
  
  return SpecLine;
};

},{"../elem":22,"./crosshair":10,"./integration-elem":11,"./path-simplify":14}],13:[function(require,module,exports){
module.exports = function (){
  var x, y, dispatcher;
  var svg_elem, _brush;
  var core = require('../elem');
  var source = core.SVGElem().class('main-brush');
  core.inherit(MainBrush, source);
  
  function makeBrushEvent() {
    if (_brush.empty()){
      if(x && y) {_brush.extent([[0,0],[0,0]]);}
      else{ _brush.extent([0,0]); }
      
      svg_elem.call(_brush);
      return null;
    }
    var e = {};
    if(x && y){
      e.xdomain = [_brush.extent()[1][0], _brush.extent()[0][0]];
      e.ydomain = [_brush.extent()[1][1], _brush.extent()[0][1]];        
    }else{
      e.xdomain = x? _brush.extent().reverse():null;
      e.ydomain = y? _brush.extent():null;
    }    
    
    _brush.clear();        
    svg_elem.call(_brush);
    return e;
  }
  function changeRegion () {      
    var e = makeBrushEvent();
    if(e)
      {MainBrush.parent().changeRegion(e);}
  }    
  function peakdel () {
    var e = makeBrushEvent();
    if(e)
      {dispatcher.peakdel(e);}
  }
  function integrate () {
    var e = makeBrushEvent();
    if(e)
      {dispatcher.integrate(e);}
  }
  function peakpick() {
    _brush.clear();
    svg_elem.call(_brush);
  }
  
  function MainBrush(spec_container) {    
    x = MainBrush.xScale();
    y = MainBrush.yScale();
    dispatcher = MainBrush.dispatcher();
    
    
    _brush = d3.svg.brush()
      .x(x)
      .y(y)
      .on("brushend", changeRegion);
    
    svg_elem = source(spec_container)
      .call(_brush);

    svg_elem.selectAll("rect")
      .attr("height", spec_container.height());
    
    svg_elem.select(".background")
      .style('cursor', null)
      .style('pointer-events', 'all');
    
    svg_elem.on('peakpickEnable', function (_) {
      svg_elem.classed("peakpick-brush", _);
      MainBrush.parent().sel().classed("peakpick-brush", _);
      
      _brush.on("brushend", _? peakpick : changeRegion);
    })
    .on('peakdelEnable', function (_) {
      svg_elem.classed("peakdel-brush", _);
      MainBrush.parent().sel().classed("peakdel-brush", _);
      
      _brush.on("brushend", _? peakdel : changeRegion);
    })
    .on('integrateEnable', function (_) {
      svg_elem.classed("integrate-brush", _);
      MainBrush.parent().sel().classed("integrate-brush", _);
      
      _brush.on("brushend", _? integrate : changeRegion);
    });
  
    // Register event listeners
    var dispatch_idx = ++dispatcher.idx;    
    dispatcher.on("peakpickEnable.brush."+dispatch_idx, svg_elem.on('peakpickEnable'));
    dispatcher.on("peakdelEnable.brush."+dispatch_idx, svg_elem.on('peakdelEnable'));
    dispatcher.on("integrateEnable.brush."+dispatch_idx, svg_elem.on('integrateEnable'));
    
    return svg_elem;                  
  }

  return MainBrush;
};

},{"../elem":22}],14:[function(require,module,exports){
var simplify = require('../utils/simplify-line');
module.exports = function () {
  var core = require('../elem');
  var source = core.ResponsiveElem('path');
  core.inherit(PathElem, source);
  
  
  var data;  //initiailized by parent at generation
  var x, y;                //initiailized by parent at rendering
  var range={}, svg_elem;    //initialized by self at rendering
  var data_resample, simplify_val, path_fun;
  
  function PathElem(spec_line) {
    x = PathElem.xScale();
    y = PathElem.yScale();
  
    path_fun = d3.svg.line()
      .interpolate('linear')
      .x(function(d) { return x(d.x); })
      .y(function(d) { return y(d.y); });
    
    svg_elem = source(spec_line);
    return svg_elem;      
  }
  function update_range() {
    range.x = [data_resample[0].x, data_resample[data_resample.length - 1].x];
    range.y = d3.extent(data_resample.map(function (d) { return d.y; }));
  }
  PathElem.redraw = function () {
    if ( !svg_elem ){return PathElem;}
    if (data.length < 2) { svg_elem.attr("d", null); }
    else { svg_elem.attr("d", path_fun); }
    return PathElem;
  };
  PathElem.update = function () {
    if ( !svg_elem ){return PathElem;}
    console.log('data length',data.length);
    if (data.length < 2) {
      svg_elem.datum(null);
      return PathElem;
    }
    
    if(simplify_val){
      data_resample = simplify(data, x, simplify_val);
      console.log('simplify', data_resample.length);
    }else{
      data_resample = data;
    }
    
    svg_elem.datum(data_resample);
    update_range();
    return PathElem;
  };
  PathElem.range = function () {
    return range;
  };
  PathElem.datum = function (_) {
    if (!arguments.length) {return data;}
    data = _;
    
    return PathElem.update();
  };
  PathElem.simplify = function (_) {
    if (!arguments.length) {return simplify_val;}
    simplify_val = _;
    return PathElem;
  };
  
  
  return PathElem;
};

},{"../elem":22,"../utils/simplify-line":50}],15:[function(require,module,exports){
var contextMenu = require('d3-context-menu')(d3);

function peakLine(line_x, line_y, label_x){
  var bottom = Math.max(line_y - 10, 60);
  return d3.svg.line()
    .defined(function(d) { return !isNaN(d[1]); })
    ([
    [label_x, 40], 
    [line_x, 60],
    [line_x, 80],
    [NaN, NaN],
    [line_x, bottom - 10],
    [line_x, bottom]
    ]);
}

function adjust_peak_positions(_peaks, text_width, container_width) {
  var tw = text_width;
  var current_pos = container_width - tw;
  //console.log('start', container_width, tw, _peaks);
  for (var i = 0; i < _peaks.length; i++) {
    //console.log(_peaks[i].d.x, _peaks[i].pos, current_pos );
    if(_peaks[i].pos > current_pos){
      _peaks[i].pos = current_pos;
    }
    current_pos = _peaks[i].pos - tw;
  }
  
  if(current_pos < tw){ // if the rightmost peak is out of canvas.
    current_pos = tw;
    for (i = _peaks.length - 1; i >= 0; i--) {
      if( _peaks[i].pos < current_pos ){
        _peaks[i].pos = current_pos;
        current_pos = _peaks[i].pos + tw;
      }else{
        break;
      }
    }
  }
  return _peaks;    
}

function getPeaks(spec_container) {
  var spectra = spec_container.spectra();
  var x = spec_container.xScale();
  var all_peaks = [];
  for (var i = 0; i < spectra.length; i++) {
    var p = spectra[i].peaks(true).map(function (d) {
      return {line:spectra[i].lineIdx(), pos:x(d.x), d:d};
    });
    all_peaks = all_peaks.concat(p);
  }
  all_peaks = all_peaks.sort(function (a, b) {
    return d3.descending(a.pos, b.pos);
  });
  return all_peaks;
}

module.exports = function(){
  var menu = [
    {
      title: 'Delete peak',
      action: function(elm, d) {
        _main.parent().spectra().filter(function (s) {
            return s.lineIdx() === d.line;
          })[0]
          .delPeaks([d.d.x, d.d.x]);
        dispatcher.peakpick();
      }
    }
  ];
  function update_text() {
    var peak_text = svg_elem.selectAll("text")
      .data(_peaks);

    peak_text.enter()
      .append("text")
      .attr("dy", "0.35em")
      .attr("focusable", true)
      .on("focus", function(){});

    peak_text.exit().remove();
  }

  function update_lines() {
    var peak_line = svg_elem.selectAll("path")
      .data(_peaks);

    peak_line.enter()
      .append("path")
      .style("fill", "none");  
  
    peak_line.exit().remove();
  }

  function redraw_text() {
    svg_elem.selectAll("text").text(function(d){return d3.round(d.d.x ,3);})
      .attr("transform", function (d) {
        return "translate(" + d.pos + ",0)rotate(90)";
      })
      .attr('class', function (d) {
        return 'peak-text clr' + d.line;  
      })
      .on("keydown", function(d) {
        if(d3.event.keyCode===68){
          dispatcher.peakdel({xdomain:[d.d.x, d.d.x]});
        }
      })
      .on('click', contextMenu(menu));
  }

  function redraw_lines() {      
    svg_elem.selectAll("path")
      .attr("d", function(d){return peakLine( x(d.d.x), y(d.d.y), d.pos );})
      .attr('class', function (d) {
        return 'peak-line clr' + d.line;  
      });
  }
  
  function get_text_width() {
    var dummy_elem = svg_elem.append("text").text('any');
    
    // Using heigth because text will be rotated.
    var text_width = dummy_elem.node().getBBox().height;
    dummy_elem.remove();
    return text_width;    
  }
  
  var svg_elem, x, y, dispatcher;
  var _peaks = [];
  
  var core = require('../elem');
  var source = core.SVGElem().class('peaks');
  core.inherit(_main, source);
  
  function _main(spec_container) {

    x = _main.xScale();
    y = _main.yScale();
    dispatcher = _main.dispatcher();
    
    var width = spec_container.width();
    svg_elem = source(spec_container);
    
    
    svg_elem
      .on("_click", function(e){
        var spectra = spec_container.spectra();
        
        spectra.forEach(function (s) {
          if(s.crosshair()){ // If there is a crosshair, get its current data. 
            s.crosshair().sel().on("_mousemove")(e);
            var p = s.crosshair().sel().datum();
            if(p){
              console.log(p, s.ppmToi(p.x));
              s.addPeaks( s.ppmToi(p.x) );
            }
          }else{
            s.addPeaks( s.pixelToi(e.xcoor) );
          }
        });
        dispatcher.peakpick();
      })
      .on("_regionchange", function (e) {
        if(e.xdomain){
          _peaks = getPeaks(spec_container);
          _peaks = adjust_peak_positions(_peaks, get_text_width(), width);
        }
      })
      .on("_redraw", function(e){
        if(e.x){
          update_text();
          update_lines();
          
          if (_peaks.length === 0){return;}
          redraw_text();
        }
        redraw_lines();
      })
      .on("_peakpick", function () {
        svg_elem.on("_regionchange")({xdomain:true});
        svg_elem.on("_redraw")({x:true, y:true});
      })
      .on("_peakdel", function (e) {
        if(e.xdomain){
          spec_container.spectra().forEach(function (s) {
            s.delPeaks(e.xdomain);
          });
        }
        if(e.ydomain){
          //TODO: delete peaks based on y-coordinates
        }
        dispatcher.peakpick();
      });
    
    // Register event listeners
    var dispatch_idx = ++dispatcher.idx;
    dispatcher.on("regionchange.peaks."+dispatch_idx, svg_elem.on("_regionchange"));
    dispatcher.on("redraw.peaks."+dispatch_idx, svg_elem.on("_redraw"));    
    dispatcher.on("peakpickEnable.peaks."+dispatch_idx, function (_) {
        dispatcher.on("click.peaks."+dispatch_idx, 
          _? svg_elem.on("_click"): null);
    });
    
    dispatcher.on("peakpick.peaks."+dispatch_idx, svg_elem.on("_peakpick"));
    dispatcher.on("peakdel.peaks."+dispatch_idx, svg_elem.on("_peakdel"));
    
    return svg_elem;            
  }
  
  _main.peaks = function () {
    return getPeaks(_main.parent());
  };
    
  return _main;
};

},{"../elem":22,"d3-context-menu":4}],16:[function(require,module,exports){
module.exports = function(){
  var svg_elem, x, y, dispatcher,brushscale;
  
  var core = require('../elem');
  var source = core.SVGElem().class('scale-brush');
  core.inherit(_main, source);
  
  function _main(slide) {
    x = _main.xScale();
    y = _main.yScale();
    dispatcher = _main.dispatcher();
    
    var mainscale = x? x : y;
    brushscale = x? x.copy() : y.copy();
    
    var axis = d3.svg.axis()
      .scale(brushscale)
      .orient(x? "bottom": "top")
      .tickFormat(d3.format("s"));
    
    var _brush = d3.svg.brush()
      .x(brushscale)
      .on("brushstart",function(){d3.event.sourceEvent.stopPropagation();})
      .on("brushend", function () {//test x or y domain?
        var extent = _brush.empty()? brushscale.domain() : _brush.extent().reverse();
        extent = extent.sort(brushscale.domain()[0] > brushscale.domain()[1]?
          d3.descending : d3.ascending );
        
        slide.changeRegion( x ? {xdomain:extent}  : {ydomain:extent} );
      });
    
    svg_elem = source(slide)
      .classed( x ?  "x" : "y", true)
      .attr("transform", x? "translate(0," + -20 + ")"
        : "translate(-20," + 0 + ")rotate("+90+")"
      );

    svg_elem.append("g")
      .call(axis)
      .attr("class", "brush-axis");
    
        
    svg_elem.append("g")
      .attr("class", "brush")
      .call(_brush)
      .selectAll("rect")
        .attr("y", -5)
        .attr("height", 10);
    
            
    svg_elem.select(".background")
      .style('pointer-events', 'all');
  
    
    svg_elem
      .on("_rangechange", function(e){
        if(e.x || (e.y && y)){
          brushscale.domain( x? e.x : e.y);          
          
          svg_elem.select(".brush-axis").call(axis);
          svg_elem.select(".brush").call(_brush);          
        }
      })
      .on("_regionchange", function(e){
        if(e.xdomain || (e.ydomain && y)){
          var domain = process_domains(mainscale.domain(), brushscale.domain());
          _brush.extent(domain);
        }
      })
      .on("_redraw", function(e){
        if(e.x || (e.y && y))
          {svg_elem.select(".brush").call(_brush);}
      });
    
    // Register event listeners
    var dispatch_idx = ++dispatcher.idx;
    dispatcher.on("rangechange.scalebrush."+dispatch_idx, svg_elem.on("_rangechange"));
    dispatcher.on("regionchange.scalebrush."+dispatch_idx, svg_elem.on("_regionchange"));
    dispatcher.on("redraw.scalebrush."+dispatch_idx, svg_elem.on("_redraw"));    

    return svg_elem;                  
  }
  
  function process_domains(main, brush) {
    var domain = [0,0];
    if(main[0]>main[1]){
      domain[0] = Math.min(main[0], brush[0]);
      domain[1] = Math.max(main[1], brush[1]);
    }else{
      domain[0] = Math.max(main[0], brush[0]);
      domain[1] = Math.min(main[1], brush[1]);
    }
    
    if(domain.join() === brush.join())
      {domain = [0,0];}
    
    return domain;
  }
  return _main;
};

},{"../elem":22}],17:[function(require,module,exports){
module.exports = function () {
  var core = require('../elem');
  var source = core.SVGElem().class('main-focus');
  core.inherit(SpecContainer, source);
  
  
  var focus, x, y, dispatcher, data, range = {};
  var x_label;
  var specs = core.ElemArray();
  var peak_picker = require('./peak-picker')();
  var main_brush = require('./main-brush')();
  
  var timestamp = 0;
  var zoomer = d3.behavior.zoom()
    .on("zoom", function () {
      if(d3.event.sourceEvent.timeStamp - timestamp < 50){
            return;
      }
      timestamp = d3.event.sourceEvent.timeStamp;
      /* * When a y brush is applied, the scaled region should go both up and down.*/
      var new_range = range.y[1]/zoomer.scale() - range.y[0];
      var addition = (new_range - (y.domain()[1] - y.domain()[0]))/2;
    
      var new_region = [];
      if(y.domain()[0] === range.y[0]) { new_region[0] = range.y[0]; }
      else{new_region[0] = Math.max(y.domain()[0]-addition, range.y[0]);}
      new_region[1] = new_region[0] + new_range;
      
      focus.on("_regionchange")(
        {zoom:true,  ydomain:new_region}
      );
    });

  
  function SpecContainer(slide) {
    x = SpecContainer.xScale();
    y = SpecContainer.yScale();
    dispatcher = SpecContainer.dispatcher();
    
    focus = source(slide)
      .attr("pointer-events", "all")
      .attr('clip-path', "url(#" + slide.clipId() + ")")
      .attr("width", SpecContainer.width())
      .attr("height", SpecContainer.height())
      .call(zoomer)
      .on("dblclick.zoom", null)
      .on("mousedown.zoom", null);
    
    
    // overlay rectangle for mouse events to be dispatched.
    focus.append("rect")
      .attr("width", SpecContainer.width())
      .attr("height", SpecContainer.height())
      .style("fill", "none");
    
    /*********** Handling Events **************/
    focus
      .on("_redraw", function(e){
        dispatcher.redraw(e);
      })
      .on("_regionchange", function(e){
        // If the change is in X
        if(e.xdomain){
          x.domain(e.xdomain);  
        }        
        dispatcher.regionchange({xdomain:e.xdomain});
              
        if(e.ydomain){
          y.domain(e.ydomain);
          if(!e.zoom){//If y domain is changed by brush, adjust zoom scale
            zoomer.scale((range.y[0]-range.y[1])/(y.domain()[0]-y.domain()[1]));            
          } 
        }else{
          //modify range.y  and reset the zoom scale
          var s = SpecContainer.spectra(true);
          if (s.length === 0){// if no spectra are selected.
            s = specs;        // use all spectra.
          }
          var y0 = d3.min(s.map(function(s){return s.range().y[0];})),
            y1 = d3.max(s.map(function(s){return s.range().y[1];}));
          var y_limits = (y1-y0);
          y0 = y0 - (0.05 * y_limits);
          y1 = y1 + (0.05 * y_limits);
          
          
          range.y = [y0,y1];
          y.domain(range.y);
          dispatcher.rangechange({y:range.y});
          zoomer.scale(1);
        }
      
        dispatcher.regionchange({ydomain:y.domain()});
        focus.on("_redraw")({x:e.xdomain, y:true});
      })
      .on("_rangechange", function(e){
        if(e.x) { range.x = e.x; }  
        if(e.y) { range.y = e.y; }
      
        dispatcher.rangechange(e);
        
        if(!e.norender){
          focus.on("_regionchange")({xdomain:range.x, ydomain:range.y});
        } 
      });
      
    if (SpecContainer.parentApp().config() > 1){
      focus.on("mouseenter", dispatcher.mouseenter)
        .on("mouseleave", dispatcher.mouseleave)
        .on("mousemove", function(){
          var new_e = d3.event;
          new_e.xcoor = d3.mouse(this)[0];
          new_e.ycoor = d3.mouse(this)[1];
      
          dispatcher.mousemove(new_e);
        })
        .on("mousedown", function () {  // Why?! because no brush when cursor on path?
          var new_click_event = new Event('mousedown');
          new_click_event.pageX = d3.event.pageX;
          new_click_event.clientX = d3.event.clientX;
          new_click_event.pageY = d3.event.pageY;
          new_click_event.clientY = d3.event.clientY;
          focus.select(".main-brush").node()
            .dispatchEvent(new_click_event);
        })
        .on("click", function(){
          var new_e = d3.event;
          new_e.xcoor = d3.mouse(this)[0];
          new_e.ycoor = d3.mouse(this)[1];
    
          dispatcher.click(new_e);
        })
        .on("dblclick", dispatcher.regionfull);
    }
    
    dispatcher.on("regionfull",function () {
      focus.on("_regionchange")({xdomain:range.x});    
    });
      
    
    //brushes
    if (SpecContainer.parentApp().config() > 1){
      main_brush.xScale(x)
        .dispatcher(dispatcher)
        (SpecContainer);      
    }
  

    //spectral lines
    for (var i = 0; i < specs.length; i++) {
      render_spec(specs[i]);
    }
    
    //peak picker  
    if (SpecContainer.parentApp().config() > 2){
      peak_picker.xScale(x)
        .yScale(y)
        .dispatcher(dispatcher)
        (SpecContainer);
    }    
  }
  function update_range() {
    var sel = SpecContainer.spectra(true);
    if (sel.length === 0){// if no spectra are selected.
      sel = specs;        // use all spectra.
    }
    
    var x0 = d3.max(sel.map(function(s){return s.range().x[0];})),
      x1 = d3.min(sel.map(function(s){return s.range().x[1];})),
      y0 = d3.min(sel.map(function(s){return s.range().y[0];})),
      y1 = d3.max(sel.map(function(s){return s.range().y[1];}));
    
    // Add 5% margin to top and bottom (easier visualization).
    var y_limits = (y1-y0);
    y0 = y0 - (0.05 * y_limits);
    y1 = y1 + (0.05 * y_limits);

    var xdomain = x.domain();
    focus.on("_rangechange")({x:[x0,x1], y:[y0,y1], norender: specs.length > 1});

    if(specs.length > 1){
      focus.on("_regionchange")({xdomain:xdomain});  
    }
  }
  
  function render_spec(s) {
    if(!focus){return;}
    
    s.xScale(x).yScale(y)
      .dispatcher(dispatcher)
      (SpecContainer);
        
    update_range();
  }
  
  SpecContainer.changeRegion = function (_) {
    if( focus ){
      focus.on('_regionchange')(_);
    }
  };
  SpecContainer.addSpec = function(spec_data, crosshair){
    if (!arguments.length) {
      throw new Error("appendSlide: No data provided.");
    } 
    if(spec_data['nd'] !== 1 ||
      (x_label && spec_data['x_label'] !== x_label)
    ){ // TODO: parentApp undefined until rendering.
      SpecContainer.parentApp().appendSlide(spec_data);
      return;
    }
    
    if(typeof crosshair === 'undefined'){
      crosshair = true;
    }
    console.log('x_labels', x_label, spec_data['x_label']);
    // TODO: s_id is only present in 'connected' mode.
    var s_id = null;
    var spec_label = 'spec'+specs.length;

    if(typeof spec_data["s_id"] !== 'undefined') {s_id = spec_data["s_id"];}
    if(typeof spec_data['label'] !== 'undefined') {spec_label = spec_data["label"];}
    
    // Find the spectrum with the same s_id.
    // If it is present, overwrite it.
    // Otherwise, create a new spectrum.
    var s = specs.filter(function (e) {
      return e.s_id() === s_id;
    }  );
    
    if ( s.length === 0 ){
       s = require('./line')()
        .datum(spec_data["data"])
        .crosshair(crosshair)
        .s_id(s_id)
        .label(spec_label);
      
      specs.push(s);
      render_spec(s);
    }else{
      s = s[0];
      s.datum(spec_data["data"]);//TODO: setData!!
      update_range();
    }
    console.log('specs.length', specs.length);
    if (specs.length === 1) { 
      x_label = spec_data['x_label']; 
      console.log('set x_label to ', x_label, spec_data['x_label']);
    }
    if(SpecContainer.parentApp()){
      SpecContainer.parentApp().dispatcher().slideContentChange();
    }
    return s;
  };
  SpecContainer.addPeaks = function (idx) { //TODO:move peaks to line
    if(!focus){return;}
    focus.select(".peaks").node().addpeaks(data.subset(idx));      
    focus.select(".peaks").on("_regionchange")({xdomain:true});
    focus.select(".peaks").on("_redraw")({x:true});      
  };
  SpecContainer.nd = function(){
    return 1;
  };
  SpecContainer.spectra = function (selected) {
    if (!selected){return specs;}
    
    return  specs.filter( function (s) { return s.selected(); } );
  };
  SpecContainer.highlightSpec = function (_) {
    var s_idx = specs.indexOf(_);
    if(s_idx < 0){ //no spectrum to highlight
      specs.sel().classed('dimmed', false)
        .classed('highlighted', false);
    }else{
      specs.sel().classed('dimmed', true);
      _.sel().classed('highlighted', true);
    }    
  };
  SpecContainer.peakPicker = function () {
    return peak_picker;
  };
  SpecContainer.mainBrush = function () {
    return main_brush;
  };
  SpecContainer.range = function(){
    return range;
  };
  SpecContainer.datum = function(_){
    if (!arguments.length) {return data;}
    data = _;
    
    //TODO: Clear all spectra first.
    SpecContainer.addSpec(_);
    return SpecContainer;
  };
  
  
  return SpecContainer;
};
},{"../elem":22,"./line":12,"./main-brush":13,"./peak-picker":15}],18:[function(require,module,exports){
module.exports = function () {
  var svg_elem, x, y, dispatcher;
  var core = require('../elem');
  var source = core.ResponsiveElem('path').class('threshold line x');
  core.inherit(_main, source);
    
  function _main(spec_container, callback) {
    x = _main.xScale() || spec_container.xScale();
    y = _main.yScale() || spec_container.yScale();
    dispatcher = _main.dispatcher() || spec_container.dispatcher();
    
    svg_elem = source(spec_container)
      .on("_mousemove", function(e) {
        svg_elem.attr("d", d3.svg.line()([[x.range()[0], e.ycoor], [x.range()[1], e.ycoor]]));
      })
      .on("_click", function (e) {
        callback(y.invert(e.ycoor));
        svg_elem.remove();
        dispatcher.on("mousemove.thresh."+dispatch_idx, null);  
        dispatcher.on("click.thresh."+dispatch_idx, null);
      });
    
    var dispatch_idx = ++dispatcher.idx;
    dispatcher.on("mousemove.thresh."+dispatch_idx, svg_elem.on("_mousemove"));  
    dispatcher.on("click.thresh."+dispatch_idx, svg_elem.on("_click"));
  }

  return _main;  
};
},{"../elem":22}],19:[function(require,module,exports){
module.exports = function(){
  function registerDispatcher() {
    var suff = ".line."+dispatch_idx;
    dispatcher.on("regionchange"+suff, null);
    dispatcher.on("mouseenter"+suff, null);
    dispatcher.on("mouseleave"+suff, null);
    dispatcher.on("mousemove"+suff, null);  
    
    if( enabled ){
      dispatcher.on("regionchange"+suff, svg_elem.on("_regionchange"));
      dispatcher.on("mouseenter"+suff, function(){_main.show(true);});
      dispatcher.on("mouseleave"+suff, function(){_main.show(false);});
      if ( shown ){
        dispatcher.on("mousemove"+suff, svg_elem.on("_mousemove"));  
      }
    }
    dispatcher.on("crosshairEnable"+suff, _main.enable);
  }
  
  var core = require('../elem');
  var source = core.SVGElem().class('crosshair');
  core.inherit(_main, source);
  
  var svg_elem, x, y, dispatcher, dispatch_idx;
  var enabled, shown;
  var tip = d3.tip()
    .attr('class', 'crosshair tooltip')
    .direction('ne')
    .offset([0, 0])
    .bootstrap(true);
  
  
  function _main(spec_img) {
    x = _main.xScale();
    y = _main.yScale();
    dispatcher = _main.dispatcher();
    dispatch_idx = ++dispatcher.idx;
    enabled = shown = true;
    
    svg_elem = source(spec_img)
      .classed("clr" + spec_img.lineIdx(), true)
      .datum(null).call(tip);

    var crosslines = svg_elem.append("g")
      .attr("class", "crosshair line");
    
    
    var xline = crosslines.append("path")
      .attr("class", "crosshair line x");
    
    var yline = crosslines.append("path")
      .attr("class", "crosshair line y");
    
    var cross_circle = svg_elem.append("circle")
      .attr("r", 4.5);

    //TODO: select / highlight spectrum from dataset.

    svg_elem
      .on("_regionchange", function(){
          //TODO: update coordinates
      })
      .on("_mousemove", function(e){
        var data_point = [x.invert(e.xcoor), y.invert(e.ycoor)];
        
        svg_elem.datum(data_point);
        cross_circle.attr("transform", "translate(" + e.xcoor + "," + e.ycoor + ")");
        tip.text(
          d3.round(data_point[0],2) + ', ' + d3.round(data_point[1],2)
        ).show(cross_circle.node());
        
        xline.attr('d', d3.svg.line()
          ( [[x.range()[0], e.ycoor], [x.range()[1], e.ycoor]] )
        );
        yline.attr('d', d3.svg.line()
          ( [[e.xcoor, y.range()[0]], [e.xcoor, y.range()[1]]] )
        );
      })
      .on('remove', function () {
        _main.enabled(false);
        dispatcher.on("crosshairEnable.line."+dispatch_idx, null);
        tip.destroy();
      });
        
    registerDispatcher();
    return svg_elem;                  
  }
  
  _main.show = function (_) {
    if (!arguments.length) {return shown;}
    shown = _;
    
    if (!svg_elem){return _main;}
    svg_elem.style("display", _? null : "none");
    
    if(_) { tip.show(svg_elem); }
    else{tip.hide();}
    
    registerDispatcher();
    return _main;
  };
  _main.enable = function (_) {
    if (!arguments.length) {return enabled;}
    enabled = _;
    
    return _main.show(_);
  };
  return _main;
};

},{"../elem":22}],20:[function(require,module,exports){
module.exports = function () {
  var core = require('../elem');
  var source = core.SVGElem().class('main-focus');
  core.inherit(SpecContainer, source);

  var x, y, dispatcher, data;
  var focus, range = {};
  var specs = core.ElemArray();
  var main_brush = require('../d1/main-brush')();
  
  var zoomer = d3.behavior.zoom()
    .on("zoom", function (){
      var slide = SpecContainer.parent();
      
      slide.select("#rfunc").attr("slope", zoomer.scale());
      slide.select("#bfunc").attr("slope", zoomer.scale());
    }).scaleExtent([0.1,100]);  
  
  function SpecContainer(slide) {
    x = SpecContainer.xScale();
    y = SpecContainer.yScale();
    dispatcher = SpecContainer.dispatcher();
    
    focus = source(slide)
      .attr("pointer-events", "all")
      .attr('clip-path', "url(#" + slide.clipId() + ")")
      .attr("width", SpecContainer.width())
      .attr("height", SpecContainer.height())
      .call(zoomer) // TODO: if app.config > 1
      .on("dblclick.zoom", null)
      .on("mousedown.zoom", null);
        
    
    /*********** Handling Events **************/
    focus
      .on("_redraw", function(e){      
        dispatcher.redraw(e);
      })
      .on("_regionchange", function(e){
        // If the change is in X
        if(e.xdomain){
          x.domain(e.xdomain);  
        }        
        //dispatcher.regionchange({xdomain:e.xdomain});
              
        if(e.ydomain){
          y.domain(e.ydomain);          
        }
        
        dispatcher.regionchange({xdomain:e.xdomain, ydomain:y.domain()});
        focus.on("_redraw")({x:e.xdomain, y:true});
      })
      .on("_rangechange", function(e){
        if(e.x)
          {range.x = e.x;}
        if(e.y)
          {range.y = e.y;}
      
        dispatcher.rangechange(e);
        
        if(!e.norender){
          focus.on("_regionchange")({xdomain:range.x, ydomain:range.y});
        } 
      });
      
    if (SpecContainer.parentApp().config() > 1){
      focus.on("mouseenter", dispatcher.mouseenter)
        .on("mouseleave", dispatcher.mouseleave)
        .on("mousemove", function(){
          var new_e = d3.event;
          new_e.xcoor = d3.mouse(this)[0];
          new_e.ycoor = d3.mouse(this)[1];
      
          dispatcher.mousemove(new_e);
        })
        .on("mousedown", function () {  // Why?! because no brush when cursor on path?
          var new_click_event = new Event('mousedown');
          new_click_event.pageX = d3.event.pageX;
          new_click_event.clientX = d3.event.clientX;
          new_click_event.pageY = d3.event.pageY;
          new_click_event.clientY = d3.event.clientY;
          focus.select(".main-brush").node()
            .dispatchEvent(new_click_event);
        })
        .on("click", function(){
          var new_e = d3.event;
          new_e.xcoor = d3.mouse(this)[0];
          new_e.ycoor = d3.mouse(this)[1];
    
          dispatcher.click(new_e);
        })
        .on("dblclick", dispatcher.regionfull);

      dispatcher.on("regionfull",function () {
      focus.on("_regionchange")({xdomain:range.x, ydomain:range.y});    
    });
    }
    //spectral lines
    for (var i = 0; i < specs.length; i++) {
      render_spec(specs[i]);
    }
    //brushes
    if (SpecContainer.parentApp().config() > 1){
      main_brush
        .xScale(x)
        .yScale(y)
        .dispatcher(dispatcher)
        (SpecContainer);
    }
    
  }
  function render_spec(s) {
    if(!focus){return;}

    s.xScale(x).yScale(y)
      .dispatcher(dispatcher)
      (SpecContainer);
        
    update_range();
  }
  function update_range() {
    var x0 = d3.max(specs.map(function(s){return s.range().x[0];})),
      x1 = d3.min(specs.map(function(s){return s.range().x[1];})),
      y0 = d3.min(specs.map(function(s){return s.range().y[0];})),
      y1 = d3.max(specs.map(function(s){return s.range().y[1];}));
    

    var xdomain = x.domain(), ydomain = y.domain();
    focus.on("_rangechange")({x:[x0,x1], y:[y0,y1], norender: specs.length > 1});

    if(specs.length > 1){
      focus.on("_regionchange")({xdomain:xdomain, ydomain:ydomain});
    }
  }
  
  SpecContainer.addSpec = function(spec_data, crosshair){
    if (!arguments.length) {
      throw new Error("appendSlide: No data provided.");
    } 
    
    if(typeof crosshair === 'undefined'){
      crosshair = true;
    }
    var s = specs.filter(function (e) {
      return e.s_id() === spec_data["s_id"];
    }  );
    
    if ( s.length === 0 ){
      if(specs.length !== 0){ //TODO: Until we support 2D datasets.
        SpecContainer.parentApp().appendSlide(spec_data);
        return;
      }
      
      s = require('./spec2d')()
        .datum(spec_data["data"])
        .s_id(spec_data["s_id"])
        .label(spec_data["label"])
        .crosshair(crosshair)
        .range({x:spec_data["x_domain"], y:spec_data["y_domain"]});
        
      specs.push(s);
			render_spec(s);
    }else{
      s = s[0];
      s.datum(spec_data["data"])
        .range({x:spec_data["x_domain"], y:spec_data["y_domain"]});
    }
    
    return s;
  };
  SpecContainer.highlightSpec = function(){};
  SpecContainer.changeRegion = function (_) {
    if( focus ){
      focus.on('_regionchange')(_);
    }
  };
  SpecContainer.nd = function(){
    return 2;
  };
  SpecContainer.spectra = function () {
    return specs;
  };
  SpecContainer.range = function(){
    return range;
  };
  SpecContainer.datum = function(_){
    if (!arguments.length) {return data;}
    data = _;
    
    SpecContainer.addSpec(_);
    return SpecContainer;
  };
  return SpecContainer;  
};
},{"../d1/main-brush":13,"../elem":22,"./spec2d":21}],21:[function(require,module,exports){
module.exports = function () {
  var core = require('../elem');
  var source = core.SVGElem().class('spec-img');
  core.inherit(_main, source);
  
  var data, s_id, spec_label, _crosshair;  //initiailized by parent at generation
  var x, y, dispatcher;                //initiailized by parent at rendering
  var svg_elem, img_elem, line_idx, range={};    //initiailized by self at rendering
  
  
  function _main(spec_container) {
    x = _main.xScale();
    y = _main.yScale();
    dispatcher = _main.dispatcher();
    
    svg_elem = source(spec_container);
    line_idx = spec_container.spectra().indexOf(_main);
    
    //svg_elem.attr("clip-path","url(#" + svg_elem.selectP('.spec-slide').node().clip_id + ")");

    img_elem = svg_elem.append("g")
      .attr("filter", "url(#" + spec_container.parent().filterId()+ ")")
      .append("svg:image")
        .attr('width', spec_container.width())
        .attr('height', spec_container.height())
        .attr('xlink:href', "data:image/png;base64," + data)
        .attr("preserveAspectRatio", "none");  
        
    
    /*** TODO: 2D dataset vis *****
    ******************************/
    
    if(_crosshair){
      _crosshair 
        .xScale(x).yScale(y)
        .dispatcher(dispatcher)
        (_main);
    }
      
    
    // TODO: 2D integration
    
    svg_elem
      .on("_redraw", redraw)
      .on("_regionchange", function(){
      })
      .on("_integrate", function(){
      })
      .on("_segment", function () {
      })
      .on('_remove', function () {
        dispatcher.on("regionchange.line."+dispatch_idx, null);
        dispatcher.on("redraw.line."+dispatch_idx, null);
        data = null;
        if(_crosshair){_crosshair.remove();}
      });
    
    // Register event listeners
    var dispatch_idx = ++dispatcher.idx;
    dispatcher.on("regionchange.line."+dispatch_idx, svg_elem.on("_regionchange"));
    dispatcher.on("redraw.line."+dispatch_idx, svg_elem.on("_redraw"));
        
    return svg_elem;                  
  }
  function redraw() {
    if (!img_elem) {return;}
    
    var orignial_xscale = x.copy().domain(range.x),
      orignial_yscale = y.copy().domain(range.y);

    //zooming on 2d picture by first translating, then scaling.
    var translate_coor = [-Math.min(orignial_xscale(x.domain()[1]), orignial_xscale(x.domain()[0])),
               -Math.min(orignial_yscale(y.domain()[1]), orignial_yscale(y.domain()[0]) )];

    var  scale_coor = [ Math.abs((range.x[0]-range.x[1])/(x.domain()[0]-x.domain()[1])),
               Math.abs((range.y[0]-range.y[1])/(y.domain()[0]-y.domain()[1]))];

    img_elem.attr("transform","scale("+scale_coor+")"+"translate("+ translate_coor +")");
  }
  function render_data() {
    if (!img_elem) {return;}
    
    img_elem.attr('xlink:href', "data:image/ png;base64," + data);
    redraw();
  }
  
  _main.datum = function(_){
    if (!arguments.length) {return data;}
    data = _;
    
    render_data();
    return _main;
  };
  _main.range = function(_){
    if (!arguments.length) {return range;}
    range = _;
    return _main;
  };
  _main.crosshair = function(_){
    if (!arguments.length) {return _crosshair;}

    if(_){
      _crosshair = require('./crosshair-2d')();
    } else {
      _crosshair = false;
    }    return _main;
  };
  _main.s_id = function(_){
    if (!arguments.length) {return s_id;}
    s_id = _;
    return _main;
  };
  _main.label = function(_){
    if (!arguments.length) {return spec_label;}
    spec_label = _;
    return _main;
  };
  _main.lineIdx = function () {
    return line_idx;
  };
  
  return _main;
};

},{"../elem":22,"./crosshair-2d":19}],22:[function(require,module,exports){

function inherit(target, source){
  for (var f in source){
    if (typeof source[f] === 'function'){
      //console.log(f);
      d3.rebind(target, source, f);
    }
  }
}

function ElemArray(arr){
  if(!arr){
    arr = [];
  }
  arr.nodes = function(){
    return this.map(function(e){return e.node();});
  };
  arr.sel = function(){
    return d3.selectAll(this.nodes());
  };
  return arr;
}

function Elem(tag){
  var selection, parentElem, width, height, cls;
  function _main (container){
    selection = container.append(tag || 'div');
    parentElem = container;
    if(cls){
      selection.classed(cls, true);
    }
    return selection;
  }
  
  _main.sel = function(){
    return selection;
  };
  _main.node = function(){
    return selection ? selection.node() : undefined;
  };
  _main.parent = function(){
    return parentElem ;
  };
  _main.width = function(_){
    if (!arguments.length) {return width;}
    width = _;
    return _main;
  };
  _main.height = function(_){
    if (!arguments.length) {return height;}
    height = _;
    return _main;
  };
  _main.class = function(_){
    if (!arguments.length) {return cls;}
    cls = _;
    return _main;
  };
  _main.append = function(_){ 
    if(!selection){
      throw new Error('Elem is not in DOM');
    }
    return selection.append(_);
  };
  _main.select = function(_){
    if(!selection){
      throw new Error('Elem is not in DOM');
    }
    return selection.select(_);
  };
  _main.selectAll = function(_){
    if(!selection){
      throw new Error('Elem is not in DOM');
    }
    return selection.selectAll(_);
  };
  _main.remove = function () {
    if( selection ){
      if ( selection.on('remove') ){
        selection.on('remove')();
      }
      selection.remove();
    }
  };
  _main.parentApp = function () {
    var _parent = parentElem;
    while(_parent){    
      if(typeof _parent.currentSlide === 'function'){
        return _parent;
      }
      _parent = _parent.parent ? _parent.parent() : null;
    }
    return null;
  };
  return _main;
}

function ResponsiveElem(tag){
  var source = Elem(tag);
  var x, y, data, dispatcher;
  function _main (container){
    var selection = source(container);
    return selection;
  }
  _main.xScale = function(_){
    if (!arguments.length) {return x;}
    x = _;
    return _main;
  };
  _main.yScale = function(_){
    if (!arguments.length) {return y;}
    y = _;
    return _main;
  };
  _main.datum = function(_){
    if (!arguments.length) {return data;}
    data = _;
    return _main;
  };
  _main.dispatcher = function(_) {
    if (!arguments.length) {return dispatcher;}
    dispatcher = _;
    return _main;
  };  
  inherit(_main, source);
  return _main;
}

function SVGElem(){
  var source = ResponsiveElem('g');
  function _main (container){
    var selection = source(container);
    return selection;
  }
  inherit(_main, source);
  return _main;
}

module.exports.inherit = inherit;
module.exports.ElemArray = ElemArray;
module.exports.Elem = Elem;
module.exports.ResponsiveElem = ResponsiveElem;
module.exports.SVGElem = SVGElem;

},{}],23:[function(require,module,exports){
var events = {
  crosshair:true,
  peakpick:false,
  peakdel:false,
  integrate:false,
  zoom:["x", "y", false]
};

var shortcuts = [];
events.crosshairToggle = function (app) {
  events.crosshair = !events.crosshair;
  app.slideDispatcher().crosshairEnable(events.crosshair);
};

events.peakpickToggle = function (app) {
  if(events.zoom[0] !== false)  events.zoom.rotateTo(false);  
  if(events.peakdel !== false)  events.peakdelToggle(app);
  if(events.integrate !== false)  events.integrateToggle(app);
  
  events.peakpick = !events.peakpick;
  app.slideDispatcher().peakpickEnable(events.peakpick);
}

events.peakdelToggle = function (app) {
  if(events.zoom[0] !== false)  events.zoom.rotateTo(false);  
  if(events.peakpick !== false)  events.peakpickToggle(app);
  if(events.integrate !== false)  events.integrateToggle(app);  
  
  events.peakdel = !events.peakdel;
  app.slideDispatcher().peakdelEnable(events.peakdel);  
}

events.integrateToggle = function (app) {
  if(events.zoom[0] !== false)  events.zoom.rotateTo(false);  
  if(events.peakpick !== false)  events.peakpickToggle(app);
  if(events.peakdel !== false) events.peakdelToggle(app);

  events.integrate = !events.integrate;
  app.slideDispatcher().integrateEnable(events.integrate);  
}

events.zoomToggle = function (app) {
  if(events.peakpick !== false)  events.peakpickToggle(app);
  if(events.peakdel !== false)  events.peakdelToggle(app);
  if(events.integrate !== false)  events.integrateToggle(app);  
  
  events.zoom.rotate();
  //dispatcher.integrateEnable(events.integrate);  
}

function add_kbd_shortcut(shortcut, fun, message) {
  shortcut = shortcut.toUpperCase()
  var all_keys = shortcut.split(' ');
  var key = all_keys[all_keys.length - 1];
  var shift = shortcut.indexOf('SHIFT') > -1;
  var ctrl = shortcut.indexOf('CONTROL') > -1 || shortcut.indexOf('CTRL') > -1;
  var alt = shortcut.indexOf('ALT') > -1;
  shortcuts.push({key:[key, shift, ctrl, alt], fun:fun, message: message});
}

function shortcut_to_text(s) {
  ret = '';
  if(s[1]) ret +='⇧';
  if(s[2]) ret +='Ctrl';
  if(s[3]) ret +='⌥';
  
  if(s[0]) ret += s[0];
  console.log(s, ret);
  return ret
}
events.display_shortcuts = function(app) {
  var nano = app.modals().proto('Keyboard Shortcuts', '', 'hide');
  el = d3.select(nano.modal.el).select(".nanoModalContent")//.style('display', 'table');
  el.append('table').selectAll('tr')
    .data(shortcuts).enter()
    .append('tr')
    .each(function (d,i) {
      var _this = d3.select(this)
      _this.append('td').append('kbd').text(shortcut_to_text(d.key));
      _this.append('td').text(d.message)
    });
  
  nano.show();
};

events.registerKeyboard = function(app){
  add_kbd_shortcut('?', events.display_shortcuts, 'Display help and keyboard shortcuts');
  add_kbd_shortcut('c', events.crosshairToggle, 'Toggle crosshair');
  add_kbd_shortcut('z', events.zoomToggle, 'Toggle zoom');
  add_kbd_shortcut('f', function(app){app.slideDispatcher().regionfull(app)}, 'View full spectrum');
  add_kbd_shortcut('shift', null, 'Move cursor to nearest peak maximum');
  
  if(app.config() > 2){
    add_kbd_shortcut('p', events.peakpickToggle, 'Peak picking');
    add_kbd_shortcut('d', events.peakdelToggle, 'Peak deletion');
    add_kbd_shortcut('i', events.integrateToggle, 'Peak integration');
  }
  
  // Add keyboard listener
  d3.select("body").on("keypress", function() {
    //app.slideDispatcher().log("keyCode: " + d3.event.keyCode);
    var pressed = String.fromCharCode(d3.event.keyCode).toUpperCase()
    for (var i = 0; i < shortcuts.length; i++) {
      var k = shortcuts[i].key;
      if(k[0] != pressed || 
        (k[1] && !d3.event.shiftKey) ||
        (k[2] && !d3.event.ctrlKey) ||
        (k[3] && !d3.event.altKey)){
          continue;
        }else{
          shortcuts[i].fun(app);
          break;
        }
    }
    //fall back if nothing matched the shortcut
    app.slideDispatcher().keyboard(d3.event);
  });    
};
module.exports = events;
},{}],24:[function(require,module,exports){
require('./utils/array');
module.exports = {};
module.exports.App = require('./main_app');
module.exports.hooks = {};
module.exports.hooks.readers = require('./pro/plugin-hooks');
module.exports.hooks.input = require('./input_elem');
module.exports.get_spectrum = require('./pro/process_data').get_spectrum;
module.exports.version = "0.6.0";
//console.log("specdraw:"+ spec.version);


//TODO: respond to resize.
//TODO: check browser and fallback if not supported.
},{"./input_elem":25,"./main_app":27,"./pro/plugin-hooks":39,"./pro/process_data":41,"./utils/array":44}],25:[function(require,module,exports){
var inp = {};
var fireEvent = require('./utils/event');

inp.num = function (label, val, _min, _max, step, unit) {
  var elem = d3.select(document.createElement("label"));
  elem.classed('param num', true)
    .text(label)
    .append("input")
      .attr({
        type: 'number',
        value: typeof val === "undefined" ? 0: val,
        min: typeof _min === 'undefined'? -Infinity: _min,
        max: typeof _max === 'undefined'? Infinity: _max,
        step: typeof step === 'undefined'? 1: step
      })
      .text(typeof unit === 'undefined'? '': unit);
  
  elem.node().getValue = function(){ 
    return elem.select('input').node().value;
  };
  return function () { return elem.node();  };
};

inp.text = function (label, placeholder) {
  var elem = d3.select(document.createElement("label"));
  elem.classed('param text', true)
    .text(label)
    .append("input")
      .attr({
        type: 'text',
        placeholder: placeholder || ''
      });
  
  return function () { return elem.node(); };
};

inp.checkbox = function (label, val) {
  var elem = d3.select(document.createElement('label'));
  elem.classed('param checkbox', true)
    .append("input")
      .attr('type', 'checkbox')
      .on('change', function () {
        fireEvent(this, 'input');
      })
      .node().checked = val ? true: false;
  
  elem.append('div')
      .classed('checker', true);
  elem.append('div')
    .classed('checkbox-label', true)
    .text(typeof label === 'string' ? label : '');
  
  elem.node().getValue = function(){ 
    return elem.select('input').node().checked;
  };
  return function () { return elem.node();  };
};
inp.checkbox_toggle = function (label, val, div_data) {
  var elem = d3.select(document.createElement('div'))
    .classed('param checkbox-toggle', true);
  
  elem.append(inp.checkbox(label, val))
    .select('input').on('change', function () {
      elem.select('.div_enable')
        .classed('disabled', !this.checked);
      fireEvent(this, 'input');
    });
  
  elem.append(inp.div(div_data))
    .classed('div_enable', true)
    .classed('disabled', !elem.select('input').node().checked);
    
  elem.node().getValue = elem.select('.param.checkbox').node().getValue;
  
  return function () { return elem.node();  };
};
inp.select = function (label, options, val) {
  var elem = d3.select(document.createElement('label'))
    .classed('param select', true)
    .text(label);
  var select_elem = elem.append("select");
  
  select_elem.selectAll('option')
    .data(options).enter()
    .append('option')
      .text(function(d){return d;});
  
  select_elem.node().value = val;
  
  elem.node().getValue = function(){ 
    return select_elem.node().value;
  };
  return function () { return elem.node();  };
};

inp.select_multi = function (label, options) {
  var elem = d3.select(document.createElement('div'))
    .classed('param select-multi', true);
  
  elem.append('label')
    .text(label)
    .append("input")
      .attr('type', 'checkbox')
      .style('display', 'none')
      .on('change', function () {
        elem.select('ul')
          .classed('shown', this.checked);
      })
      .node().checked = false;
  
  elem.append('ul')
    .classed('block-list', true)
    .selectAll('li')
    .data(options).enter()
    .append('li')
      .each(function(d){
        d3.select(this).append(inp.checkbox(d, true));
      });
  
  elem.node().getValue = function(){ 
    return elem.selectAll('.param.checkbox')
      .filter(function () {
        return this.children[0].checked;
      })[0]
      .map(function (e) {
        return typeof(e.value) !== 'undefined' ? e.value
          : d3.select(e).select('.checkbox-label').text();
      });
  };
  return function () { return elem.node();  };
};

inp.select_toggle = function (label, options, app) {
  console.log(label, options);
  var elem = d3.select(document.createElement('div'))
    .classed('param select-toggle', true);
  
  elem.append(inp.select(label, Object.keys(options))) 
    .selectAll('option')
      .attr('value', function(d){return d;})
      .text(function(d){return options[d][0];});
  
  var fieldset = elem.append("div")
    .classed("method_params", true);
  var select_elem = elem.select('select').node();
  
  elem.select('select').on('input', function () {
      d3.event.stopPropagation();
    })
    .on('change', function () {
      fieldset.select('fieldset').remove();

      if( Object.keys( options[select_elem.value][1]).length > 0 ){
        fieldset.append("fieldset")
          .append(inp.div( options[select_elem.value][1], app ));
          //.appened('legend', 'Parameters');
      }
      console.log(app);
      fireEvent(this.parentNode, 'input');
    });
  
  if( Object.keys(options[ select_elem.value ][1]).length > 0 ){
    fieldset.append("fieldset")  
      .append(inp.div( options[ select_elem.value ][1], app ));
  }
  
  elem.node().getValue = function(){ 
    return select_elem.value;
  };
  return function(){return elem.node();};
};
inp.button = function (label) {
  var elem = d3.select(document.createElement('input'))
    .classed('param btn', true)
    .attr('type', 'button')
    .attr('value', label)
    .on("click", function(){ fireEvent(this, 'input'); });
  
  elem.node().getValue = function(){ 
    return d3.event && d3.event.target === elem.node();
  };  
  return function(){return elem.node();};
};
inp.threshold = function (label, axis, app) {
  //console.log('app: ',app);
  var elem = d3.select(document.createElement('div'))
  .classed('param threshold', true);
  
  var input = elem.append("input").attr("type", "hidden");

  var val = elem.append("input")
    .attr("type", "text")
    .attr('readonly', 'readonly');
  
  elem.insert(inp.button(label), ':last-child')
    .on("click", function(){ 
      var modal = d3.selectAll(".nanoModalOverride:not([style*='display: none'])")
        .style('display', 'none');
      
      //TODO: app-specific.
      var th_fun = require('./d1/threshold')();
      
      th_fun(app.currentSlide().specContainer(), function (t) {
        val.attr('value', t.toExponential(2));
        input.attr('value', t);
        modal.style('display', 'block');
      });
        
    });
  
  elem.node().getValue = function () {
    return input.node().value;
  };
  return function() { return elem.node(); };
};
/* parses the GUI data into a div HTML element.
   @param div_data object containing parameter names as keys
   and GUI information (Array) as values.
   The GUI array consists of the following:
   * label: text label of the input
   * type: the input type:
      0:number 1:checkbox 2:text 3:select_toggle 4:checkbox_toggle
      5:button 6:threshold
*/
inp.div = function (div_data, app) {
  var div = d3.select(document.createElement('div'));
  for (var key in div_data){
    var p = div_data[key];
    if(typeof p === 'function') {continue;} //Exclude Array prototype functions.
    div.append(parseInputElem.apply(null, p.concat(app)))
      .node().id = key;
  }
  
  return function() {return div.node();};
};

var parseInputElem = function (label, type, details, app) {
  var f = [
    inp.num, inp.checkbox, inp.text, inp.select_toggle,
    inp.checkbox_toggle, inp.button, inp.threshold
  ][type];
  
  var args = [label].concat(details);
  args = [3,4,6].indexOf(type) !== -1 ? args.concat(app) : args;
  return f.apply(null, args);
};

inp.spectrumSelector = function (app) {
  var specs = app.currentSlide() ? app.currentSlide().spectra(): null;
  
  
  if ( (!specs) || specs.length === 0){
    return function () {
      return d3.select(document.createElement('div')).text('No Spectra to show').node();
    };
  } 
  
  var spec_container = app.currentSlide().specContainer();    
  var elem =   d3.select(
    inp.select_multi('Select Spectrum', specs)()
    ).classed('spec-selector', true);
  
  elem.selectAll('li')
      .each(function(s){
        d3.select(this).select('.checkbox')          
          .style('color', getComputedStyle(s.select('path').node()).stroke)
          .style('opacity', getComputedStyle(s.select('path').node()).strokeOpacity)
          .select('.checkbox-label').text( s.label() );
          
        d3.select(this).on('mouseenter', function () {
          spec_container.highlightSpec(s);
        })//mouseover
        .on('mouseleave', function () {
          spec_container.highlightSpec();
        });//mouseout
      });//end each
  
  elem.node().getValue = function () {
    return elem.selectAll('li')
      .filter(function () {
        return d3.select(this).select('input').node().checked === true;
      })
      .data().map(function(e){
          return e.s_id();
      });
  };
  elem.node().id = 'sid';
  
  return function(){return elem.node();};
};
inp.preview = function(auto){
  var div_data = {
    "prev_auto":["Instant Preview", 1, typeof auto !== 'undefined'],
    "prev_btn":["Preview", 5, null],
  };
  return inp.div(div_data);
};
inp.popover = function (title) {
  var div = d3.select(document.createElement('div'))
    .classed('popover right', true);
  
  div.append('div').classed('arrow', true);
  var inner = div.append('div').classed('popover-inner', true);
  inner.append('h3').classed('popover-title', true).text(title);
  inner.append('div').classed('popover-content', true);
  
  return function() {return div.node();};
};

module.exports = inp;
},{"./d1/threshold":18,"./utils/event":46}],26:[function(require,module,exports){
module.exports = function (app) {
  app.append('div').classed('logo', true)
    .text('SpecdrawJS')
    .on('click', function () {
      app.modals().proto('SpecdrawJS', 
      'A javascript library for interactive processing and visualization of NMR spectra.'+
      '<br> Author: Ahmed Mohamed'+
      '<br> For bug reports, go to <a href="https://github.com/ahmohamed/specdraw.js/issues" target="_blank"> Github Repository </a>',
      function (modal) {
        modal.hide();
      }).show();
    });
};
},{}],27:[function(require,module,exports){
module.exports = function(){
  var core = require('./elem');
  var source = core.Elem().class('spec-app');
  core.inherit(App, source);
  
  var selection, app_width, app_height;
  var app_dispatcher = d3.dispatch('slideChange', 'slideContentChange', 'menuUpdate');
  var modals, config = 3;
  var slides = core.ElemArray(), current_slide;
  var base_url = '/nmr/';
  
  function check_size(divnode) {
    app_width = App.width();
    app_height = App.height();
    if (typeof app_width === 'undefined' ||
      typeof app_height === 'undefined' ||
      isNaN(app_width) || isNaN(app_height)
    ){
      var size = require('./utils/get-size')(divnode);
      app_width = size[0];
      app_height = size[1];
      if (typeof app_width === 'undefined' ||
        typeof app_height === 'undefined'){
          return false;
        }
    }
    if (app_width < 300 || app_height < 300){return false;}
    return true;
  }
  
  function App(div) {
    if(!check_size(div.node())){
      require('./utils/docready')(function () {  render(div); });
      return;
    }    
    render(div);
  }
  
  function render(div){
    if ( !check_size(div.node()) ){
      if(div.node().tagName.toLowerCase() === 'specdraw-js'){
        // When web components are used, the element's dimensions are not
        // set even when the DOM is ready. However, the container div is set.
        if (!check_size(div.node().parentNode)){
          //TODO: better response when canvas is small
          throw new Error("SpecApp: Canvas size too small. Width and height must be at least 400px");
        }
      }else{
        throw new Error("SpecApp: Canvas size too small. Width and height must be at least 400px");  
      }
    }
    
    selection = source(div)
      .style({
        width:app_width,
        height:app_height        
      });
    modals = require('./modals')(App);
    
    if(config > 1){
      require('./menu/menu')(App);
      app_width -= 50; //deduct 50px for column menu.
      /**** Keyboard events and logger ****/
      require('./events').registerKeyboard(App);
    }
    
    app_dispatcher.on('slideChange.app', function (s) {
      if (current_slide !== s) { App.currentSlide(s);  }
    });
    
    for (var i = 0; i < slides.length; i++) {
      render_slide(slides[i]);
    }
    if(slides.length === 0){
      App.appendSlide();
    }
    
    require('./logo')(App);
  }
  function render_slide(s) {
    if(! selection){ return; }
    s.width(app_width).height(app_height)
      (App);

    App.currentSlide(s);
  }
  
  App.slides = function () {
    return slides;
  };
  App.currentSlide = function (s) {
    if (!arguments.length) { return current_slide || slides[slides.length -1]; }
    if (current_slide) { // When the first slide is added, no current_slide.
      current_slide.show(false);
    }
    s.show(true);
    current_slide = s;
    app_dispatcher.slideChange(s);
  };
  App.dispatcher = function () {
    return app_dispatcher;
  };
  App.slideDispatcher = function () {
    return current_slide.slideDispatcher();
  };
  App.modals = function () {
    return modals;
  };
  App.pluginRequest = require('./pro/plugins')(App);
  App.appendSlide = function(data){
    console.log('append_slide start');
		var s = require('./slide')().datum(data);
		console.log('slide added');
    slides.push(s);
    render_slide(s);
    return App;
  };
  App.config = function (_) {
    if (!arguments.length) {return config;}
    config = _;
    
    return App;
  };
  App.connect = function (url){
    if (!arguments.length) {return base_url;}
    base_url = url;
    config = 4;
    
    return App;
  };
  App.options = {
    grid:{x:false, y:false}
  };
  App.data = function (url, s_per_slide) {
    if(typeof s_per_slide === 'undefined'){
      s_per_slide = 5;
    }
    var callback = function (data) {
      if(!App.currentSlide() || App.currentSlide().spectra().length  > s_per_slide - 1){
        App.appendSlide(data);
      }else{
        App.currentSlide().addSpec(data, config > 1);
      }
    };
    
    require('./pro/process_data').get_spectrum(url,  callback);
    return App;
  };
  return App;
};

//TODO: remove Elements

},{"./elem":22,"./events":23,"./logo":26,"./menu/menu":30,"./modals":35,"./pro/plugins":40,"./pro/process_data":41,"./slide":43,"./utils/docready":45,"./utils/get-size":48}],28:[function(require,module,exports){
function find_menu_item (menu, item) {
  for (var i = menu.length - 1; i >= 0; i--) {
    if(menu[i].label === item){
      if(!menu[i].children) {menu[i].children = [];}
      return menu[i];
    }
  }
  menu.push({label:item, children:[]});
  return menu[menu.length-1];
}


module.exports = function (menu, menu_path) {
  var path = find_menu_item(menu, menu_path[0]);

  for (var j = 1; j < menu_path.length; j++) {
    path = find_menu_item(path.children, menu_path[j]);
  }
  return path;
};

},{}],29:[function(require,module,exports){
var inp = require('../input_elem');
var fireEvent = require('../utils/event');

function add_li(sel) {
  sel.enter()
    .append("li")
    .text(function(d){return d.label;})
    .classed('menu-item', true)
    .classed('not1d', function(d){ return d.nd && d.nd.indexOf(1) < 0; })
    .classed('not2d', function(d){ return d.nd && d.nd.indexOf(2) < 0; });
  
  return sel;    
}

function recursive_add(sel){
  var new_sel = sel.filter(function(d){return d.children;})
    .classed('openable', true)
    //.attr('tabindex', 1)
    .append("div").append("ul")
    .selectAll("li")
      .data(function(d){return d.children;})
      .call(add_li);
  
  if(new_sel.filter(function(d){return d.children;}).size() > 0){
    recursive_add(new_sel);
  }
}

function main_menu (app) {
  var menu_data;
  function _main(div) {
    div.select('.menu-container').remove();
    
    var nav = div.append(inp.popover('Menu'))
      .classed('menu-container', true)
      .select('.popover-content')
        .append('div')
        .classed('main-menu', true)
          .append("ul")
          .classed('nav',true);
    
    nav.selectAll("li")
      .data(menu_data)
      .call(add_li)
      .call(recursive_add);
      
    nav.selectAll('li')
      .on("click", function(d){
        if(d.fun){
          fireEvent(div.node(), 'click'); //close the menu.
          d.fun(app);
        }else{
          this.focus();
        }
      });

  }
  _main.data = function (_) {
    if (!arguments.length) {return menu_data;}
    menu_data = _;
    return _main;
  };
  return _main;
}

module.exports = main_menu;
},{"../input_elem":25,"../utils/event":46}],30:[function(require,module,exports){
var fullscreen = require('../utils/fullscreen');
var bootstrap = require('../../lib/bootstrap-tooltip').bootstrap;
var events = require('../events');

module.exports = function (app){  
  function toggle(callback){
    if(d3.event.target !== this) {return;}
  
    var button = d3.select(this).toggleClass('opened');
    var opened = button.classed('opened');
    button.select('.tooltip')
      .style('display', opened ? 'none': null);
    
    if (opened && typeof callback === 'function'){
      button.call(callback);
    }
    return opened;
  }
  // Import needed modules for sub-menus
  var main_menu = require('./main_menu')(app),
    spectra = require('./spectra')(app),
    slides = require('./slides')(app),
    get_menu_data = require('./menu_data');
  
  var column_menu_buttons = [
    ['open-menu', 'Menu'],
    ['open-spec-legend', 'Spectra'],
    ['open-slides', 'Slides'],
    ['kbd', 'Keyboard Shortcuts'],
  ];
  
  // Full client-side only buttons
  if(app.config() > 2){
    column_menu_buttons = column_menu_buttons.concat(
      [//['open-settings', 'Settings'],
        //['open-download', 'Download Spectra'], //TODO: download spectra: csv, peak table, Jcamp?
      ['open-fullscreen', 'Fullscreen App'],
      ['connection-status', 'Connection Status']]
    );
  }
  
  var elem = app.append('div')
    .classed('column-menu', true);
    
  elem.selectAll('div')
    .data(column_menu_buttons).enter()
    .append('div')
    .attr('class', function(d){return d[0];})
    .attr('title', function(d){return d[1];})
    .call(bootstrap.tooltip().placement('right'))
    .on('click', toggle);
  
  elem.select('.open-spec-legend').on('click', function(){
    toggle.apply(this, [spectra]);
  });
  elem.select('.open-slides').on('click', function(){
    toggle.apply(this, [slides]);
  });
  elem.select('.kbd').on('click', function(){
    events.display_shortcuts(app);
  });
  
  var app_dispatcher = app.dispatcher();
  app_dispatcher.on('slideChange.menu', function () {
    elem.select('.open-spec-legend').call( spectra );
    elem.select('.open-slides').call( slides );
    app_dispatcher.menuUpdate();
  });
  
  app_dispatcher.on('slideContentChange.menu', function () {
    elem.select('.open-spec-legend').call( spectra );
  });
  
  app_dispatcher.on('menuUpdate.menu', function () {
    elem.select('.open-menu').call( main_menu.data(get_menu_data(app)) );
  });
  
  //initialize main-menu
  elem.select('.open-menu').call( main_menu.data(get_menu_data(app)) );
  
  if(app.config() < 3){ return elem; }
  
  /*******   Full client-side only  ***********/
  // Full screen manipulation
  elem.select('.open-fullscreen')
    .on('click', function () {
      fullscreen.toggle(app.node());
      toggle.apply(this);
    });
  
  d3.select(window).on('resize.fullscreenbutton', function () {
    elem.select('.open-fullscreen').classed('opened', fullscreen.isFull() );
  });
  /******************************************/
  return elem;                  
};

},{"../../lib/bootstrap-tooltip":1,"../events":23,"../utils/fullscreen":47,"./main_menu":29,"./menu_data":31,"./slides":33,"./spectra":34}],31:[function(require,module,exports){
var events = require('../events');
var append_menu = require('./append-menu');
var server_menu = require('./serverside-menu');

function saveSVG(slide, filename) {
  slide.selectAll('text').attr('font-size', '10px');
  require('save-svg-as-png').svgAsDataUri (slide.node().parentNode, {}, function(uri) {
    var a = document.createElement("a");
    a.download = filename;
    a.href = uri;
    a.setAttribute("data-downloadurl", uri);
    a.click();    
  });  
}

function savePNG(slide, filename) {
  slide.selectAll('text').attr('font-size', '10px');
  require('save-svg-as-png').saveSvgAsPng(slide.node().parentNode, filename);
}

function add_item(i, menu_data){
  var path = append_menu(menu_data, i['menu_path']);
  path.children = null;
  path.fun = i['fun'];
  path.nd = i['nd'];
}
var config2 = [{ menu_path:['View', 'Change region', 'Set X region'],
    fun: function (app){app.modals().xRegion();},
    nd: [1,2]
  },
  { menu_path:['View', 'Change region', 'Set Y region'],
    fun: function (app){app.modals().yRegion();},
    nd: [1,2]
  },
  { menu_path:['View', 'Change region', 'Full spectrum'],
    fun: function (app){app.slideDispatcher().regionfull();},
    nd: [1,2]
  },
  { menu_path:['View', 'Show/hide crosshair'],
    fun: events.crosshairToggle,
    nd: [1,2]
  }];

var config3 = [{ menu_path:['Analysis', 'Peak Picking', 'Manual peak picking'],
    fun: events.peakpickToggle,  nd: [1]
  },
  { menu_path:['Analysis', 'Peak Picking', 'Delete peaks'],
    fun: events.peakdelToggle,  nd: [1]
  },
  { menu_path:['Analysis', 'Peak integration'],
    fun: events.integrateToggle,  nd: [1]
  },
/*TODO  { menu_path:['View', 'Scale selected spectra'],
    fun: function (app){app.modals().scaleLine();},
    nd: [1]
  },*/
  { menu_path:['Save Slide', 'As PNG image'],
    fun: function (app){savePNG(app.currentSlide(), 'specdraw_slide.png');},
    nd: [1,2]
  },
  { menu_path:['Save Slide', 'As SVG image'],
    fun: function (app){saveSVG(app.currentSlide(), 'specdraw_slide.svg');},
    nd: [1,2]
  },
  { menu_path:['Bin Spectra'],
    fun: function (app){
      app.modals().input("Bin size", 0.04, 
      function (input) {
        var bin = require('../d1/binning');
        var specs = app.currentSlide().spectra(true);
        for (var i = 0; i < specs.length; i++) {
          bin(specs[i], +input);
        }
      })();
    },
    nd: [1]
  } ];  

module.exports = function (app) {
  
  var entries = config2;
  if(app.config() > 2){
    entries = entries.concat(config3);
  }
  if(app.config() > 3){
    entries = server_menu(app).concat(entries);
  }
  
  if (app.currentSlide() && app.currentSlide().nd()) {
    var current_nd = app.currentSlide().nd();
    entries = entries.filter(function (e) {
      return !(e.nd && e.nd.indexOf(current_nd) < 0);
    });    
  }
  
  var menu_data = [];
  for (var i = 0; i < entries.length; i++) {
    add_item(entries[i], menu_data);
  }
  return menu_data;
};


},{"../d1/binning":9,"../events":23,"./append-menu":28,"./serverside-menu":32,"save-svg-as-png":7}],32:[function(require,module,exports){
var bootstrap = require('../../lib/bootstrap-tooltip').bootstrap;
var ajax = require('../pro/ajax');

function read_menu(app, response) {
  function plugin_functor (c) {
    if(c["args"]){
      return function(app) {
        app.modals().methods(c["fun"], c["args"], c["title"])();
      };
    }else{
      return function (app) { app.pluginRequest (c["fun"]); };
    }
  }
  
  //var c = response;
  for (var i = 0; i < response.length; i++) {
    server_menu.push( {
      menu_path: response[i]['menu_path'],
      nd: response[i]['nd'],
      fun: plugin_functor(response[i])
    });
    
    //response[i]['fun'] = plugin_functor(response[i]);
  }
	//server_menu = response;
  app.dispatcher().menuUpdate();
}




var server_menu;
module.exports = function(app) {
	if (server_menu) {
		return server_menu;
	}
  server_menu = []; //flag that we are getting the menu.
  
  app.select('.connection-status')
    .attr('class', 'connection-status connecting')
    .attr('title', 'Connection status: connecting')
		.on('click', null)
    .call(bootstrap.tooltip().placement('right'));
  
  ajax.getJSON(app.connect() + 'menu', success, fail);
  
  function success(response) {
    app.select('.connection-status')
      .attr('class', 'connection-status connected')
      .attr('title', 'Connection status: connected')
      .call(bootstrap.tooltip().placement('right'));
    read_menu(app, response);
  }
  function fail() {
    server_menu = undefined;
    app.select('.connection-status')
      .attr('class', 'connection-status disconnected')
      .attr('title', 'Disconnected. Click to reconnect.')
			.on('click', function () { module.exports(app);})
      .call(bootstrap.tooltip().placement('right'));
  }
	
	// it returns an empty array until the ajax call returns, and calls dispatcher().menuUpdate()
	return [];
};


},{"../../lib/bootstrap-tooltip":1,"../pro/ajax":36}],33:[function(require,module,exports){
var inp = require('../input_elem');

module.exports = function (app) {
  function _main(div) {    
    div.select('.menu-container').remove();
    
    var nav = div.append(inp.popover('Slides'))
      .classed('menu-container', true)
      .select('.popover-content');
    
    nav.append('ul')
      .classed('block-list slide-list', true)
      .selectAll('li')
      .data(app.slides).enter()
      .append('li')
        .text(function(d,i){return 'Slide ' + (i+1);})
        .on('click', function (d) {
          app.dispatcher().slideChange(d);
        });
    
    if(app.config() > 2){
      nav.select('ul')
        .append('li')
          .text('+ New Slide')
          .on('click', function () {
            app.appendSlide();
          });
    }
      
    return div;
  }
  return _main;
};


},{"../input_elem":25}],34:[function(require,module,exports){
var inp = require('../input_elem');

function spectra (app) {
  function _main(div) {
    div.select('.menu-container').remove();
    
    var nav = div.append(inp.popover('Spectra'))
      .classed('menu-container', true)
      .select('.popover-content');
    
    //TODO: SpectrumSelector takes an App
    var spec_selector = inp.spectrumSelector(app);    
    
    if( (!app.currentSlide()) || app.currentSlide().spectra().length === 0){
      nav.append(spec_selector);
    }else{
      var spec_list = d3.select( spec_selector() ).select('ul');
      
      if(app.config() > 2){
        spec_list.append('li')
          .text('+ Add spectrum')
          .on('click', require('../pro/open-file')(app) );
      }
      
      nav.append( function () {return spec_list.node();} )
        .classed('block-list spec-list no-checkbox', true);
    }  
    
    return div;
  }
  return _main;
}

module.exports = spectra;
},{"../input_elem":25,"../pro/open-file":38}],35:[function(require,module,exports){
require('nanoModal')
var nanoModal = window.nanoModal;
nanoModal.customHide = function(defaultHide, modalAPI) {
  modalAPI.modal.el.style.display = 'block';
  defaultHide();
};

function app_modals(app){
  var modals = {};
  
  modals.proto = function (title, content, ok_fun, cancel_fun) {  
    var nano = nanoModal(
      '',
      {
      overlayClose: false,
      autoRemove:true,
      buttons: [
        {
          text: "OK",
          handler: ok_fun,
          primary: true
        }, 
        {
          text: "Cancel",
          handler: cancel_fun || "hide",
          classes:"cancelBtn"
        }
      ]}
    );
  
    if(!app){
      app = d3.select('.spec-app');
    }
    //TODO: define spec-app;
    app.append(function () {return nano.overlay.el;});
    app.append(function () {return nano.modal.el;});
  
    var el = d3.select(nano.modal.el);
    el.select(".nanoModalContent").html(content || '');
    el.insert("div", ":first-child")
      .classed('title', true)
      .text( title? title : "Dialogue" );
  
    el.on("keydown", function() {
      if (d3.event.keyCode===13) { // Enter
        d3.select(nano.modal.el).select(".nanoModalBtnPrimary").node().click();
      }
      if (d3.event.keyCode===27) { // Escape
        d3.select(nano.modal.el).select(".cancelBtn").node().click();
      }
    });
  
    nano.onShow(function () {
      el.style({
        'display': 'flex',
        'flex-direction': 'column',
        'margin-left': -el.node().clientWidth /2,
        'max-width': 0.8 * el.node().parentNode.clientWidth,
        'max-height': 0.8 * el.node().parentNode.clientHeight
      });
      var drag = d3.behavior.drag()
        .on("drag", function () {
          el.style("top", d3.event.sourceEvent.pageY+"px")
            .style("left", d3.event.sourceEvent.pageX+"px");
        });
      d3.select(nano.modal.el).select(".title").call(drag);
      d3.select(nano.modal.el).select(".cancelBtn").node().focus();
    
      //{display: flex,flex-direction: column}
    });
    return nano;
  };

  modals.error = function (title, message) {
    var nano = modals.proto('Error: ' + title, message);
    d3.select(nano.modal.el)
      .classed('errorModal', true)
      .select('.cancelBtn').text('Dismiss');
    nano.show();
  };

  modals.range = function (text, _range, callback, _curr_val){
    var range;
    if(_range[0]>_range[1]){
      range = [_range[1], _range[0]];
    }else{
      range = _range;
    }
    range = [d3.round(range[0],3), d3.round(range[1],3)];
  
    if(typeof _curr_val === 'undefined'){
      _curr_val = range;
    }else{
      if(_curr_val[0]>_curr_val[1])
        {_curr_val = [_curr_val[1], _curr_val[0]];}
    
      _curr_val = [d3.round(_curr_val[0],3), d3.round(_curr_val[1],3)];
    }
  
    var content = text +
      '<input type="number" id="range0" step="0.001" value='+_curr_val[0]+ ' min='+ range[0] + ' max='+ range[1] +'>' +
      ' - ' +
      '<input type="number" id="range1" step="0.001" value='+_curr_val[1]+ ' min='+ range[0] + ' max='+ range[1] +'>';
    
    var nano = modals.proto("Range", content,
      function(modal) {
        modal.hide();
        var input_range = d3.select(modal.modal.el)
          .selectAll("input")[0].map(function(e){ return +e.value; });
      
        if (input_range[0] < range[0] || input_range[0] > range[1] ||
          input_range[1] < range[0] || input_range[1] > range[1] ||
          input_range[0] > input_range[1]) {
          nanoModal("Invalid input."+input_range).show();
        }else{
          if(_range[0]>_range[1]){
            callback(input_range.reverse());
          }else{
            callback(input_range);
          }
        }
      });
  
    return nano.show;  
  };

  modals.input = function (text, value, callback){  
    var content = text +
      '<input type="number" id="input0" step="0.001" value='+value+'>';
    
    var nano = modals.proto("Numeric", content,
      function(modal) {
        modal.hide();
        var input = d3.select(modal.modal.el)
          .select("input").node().value;
        callback(input);
      });
  
    return nano.show;  
  };

  modals.xRegion = function () {
    modals.range(
      "Set x region to:<br>",
      app.currentSlide().range().x,
      function (new_range) { app.currentSlide().changeRegion({xdomain:new_range}); },
      app.currentSlide().specContainer().xScale().domain()
    )();
  };

  modals.yRegion = function () {
    modals.range(
      "Set y region to:\n",
      app.currentSlide().range().y,
      function (new_range) { app.currentSlide().changeRegion({ydomain:new_range}); },
      app.currentSlide().specContainer().yScale().domain()
    )();
  };

  modals.slider = function (text, value, callback){  
    var content = text +
      '<input id="slider" type="range" min="-5" max="5" value="0" step="0.001"/>';
    
    var nano = modals.proto("Slider", content,
      function(modal) {
        modal.hide();
      },
      function () {
        callback(0);
      });
  
    d3.select(nano.modal.el).select("#slider")
      .on("input", function(){
        callback(+this.value);
      });
  
    return nano.show;  
  };

  modals.scaleLine = function () {
    modals.slider(
      "Scale spectrum by a factor:",
      0,function (value) {
        app.currentSlide().spectra(true)
          .forEach(function (s) {
            s.setScaleFactor(Math.pow(2,value));
          });
      }  
    )();
  };

  modals.methods = function (fun ,args, title, specSelector, has_preview) {
    var el;
    var preview = true;
    
  
    var ok_fun = function (modal) {
      preview = false;
      require('./utils/event')(el.node(), 'input');
      modal.hide();
    };
  
    var nano = modals.proto(title, '',  ok_fun);
    el = d3.select(nano.modal.el).select(".nanoModalContent");
  
  
    var timer = null;
    el.on('input', function () {
      var form_data = {};
      el.selectAll('.param')
        .filter(function () {
          return this.id !== '';
        })
        .each(function () {
          form_data[this.id] = this.getValue();
        });
    
      if(timer) { clearTimeout(timer); }
        
    
      if(preview === false || 
        d3.event.target === el ||
        form_data['prev_btn'] === true){
        app.pluginRequest(fun, form_data, form_data['s_id'], preview);
      }else  if(form_data['prev_auto'] === true){
        timer = setTimeout(function () {
          app.pluginRequest(fun, form_data, form_data['s_id'], true);
        }, 300);
      }
    });
  
    var inp = require('./input_elem');
    el.append(inp.spectrumSelector(app));
    el.append(inp.div(args, app));
    //el.append(inp.preview(true));
    return nano.show;
  };
  
  return modals;
}
//spec.modals = modals;
module.exports = app_modals;
},{"./input_elem":25,"./utils/event":46,"nanoModal":6}],36:[function(require,module,exports){
//TODO:var modals = spec.modals;
var modals = require('../modals')();

var request = function (url, callback, err) {
  var http_request = new XMLHttpRequest();
  http_request.open("GET", url, true);
  http_request.onreadystatechange = function () {
    var done = 4;
    var ok = 200;
    if (http_request.readyState === done && http_request.status === ok){
      if(typeof(callback) === 'function')
        {callback(http_request.responseText);}
    }else  if (http_request.readyState === done){
      err(http_request.responseText);
    }
  };
  http_request.send();  
};

var getJSON = function(url, callback, err_fun, show_progress){
  var prog = ajaxProgress();
  if (typeof err_fun !== 'function'){
    err_fun = modals.error;
  }
  request(url, function (response) {
    prog.stop();
    var json;
    try {
      json = JSON.parse(response);
    } catch (e) {
      json = response.toString();
    }
    if(typeof json['error'] === 'undefined'){
      callback(json);
    }else{
      err_fun(json['error']['name'], json['error']['message']);
    }

  },
  function (error) {
    prog.stop();
    err_fun('Network Error', error);
  });

  if(show_progress)
    {prog();}
};

var ajaxProgress = function () {
  var interval, stopped=false;
  function check () {
    request('/nmr/test', function (response) {
      if(!stopped){
        // TODO: Progress should be bound to app
        d3.select(".progress").text(response);
        setTimeout(check, 100);
      }else{
        request('/nmr/test?complete=1');
      }
    });
  }

  var run = function() {
    check();
  };

  run.stop = function() {
    clearInterval(interval);
    stopped = true;
    // TODO: Progress should be bound to app
    d3.select(".progress").text("Completed");
      /*.transition()
      .duration(2500)
      .style("opacity", 1e-6)*/
  };
  return run;
};

module.exports.request = request;
module.exports.getJSON = getJSON;

},{"../modals":35}],37:[function(require,module,exports){
var converter = require('jcampconverter');


function jcamp_to_xy(spectrum) {
  var data = spectrum.data[0];
  var ret = [];
  for (var i = 0; i < data.length; i+=2) {
    ret.push({x:data[i], y:data[i+1]});
  }
  return ret;
}
function jcamp1d(result) {
  var spec_data = {};
  spec_data.data = jcamp_to_xy(result.spectra[0]);
  return spec_data;
}

function jcamp2d(result) {
  var spec_data = {};
  var spectra = result.spectra;
  
  var z_domain = d3.max( [Math.abs(result.minMax.minZ), Math.abs(result.minMax.maxZ)] );
  z_domain = [-z_domain, z_domain];
  
  var width = spectra.length, 
    height = spectra[0].nbPoints;
  
  var scale = d3.scale.linear().domain(z_domain).rangeRound([0,255]).clamp(true);
  
  var canvas = d3.select(document.createElement("canvas"))
      .attr("width", width)
      .attr("height", height)
      .style("width", width + "px")
      .style("height", height + "px")
      .node();
      
  var c = canvas.getContext("2d");
  var imageData = c.createImageData(width, height);
  
  
  var pos = 0, val;
  for (var y = height*2 -1; y > 0; y-=2) {
    for (var x = 0; x < width; x++) {
      val = scale( spectra[x].data[0][y] );
      imageData.data[pos++] = val;
      imageData.data[pos++] = val;
      imageData.data[pos++] = val;
      imageData.data[pos++] = 255; // opaque alpha
    }
  }

  c.putImageData(imageData, 0, 0, 0, 0, width, height);
  spec_data.data = canvas.toDataURL("image/png").replace('data:image/png;base64,','');
  spec_data.x_domain = [result.minMax.minX, result.minMax.maxX];
  spec_data.y_domain = [result.minMax.minY, result.minMax.maxY];
  spec_data.z_domain = z_domain;
  spec_data.nd = 2;
  spec_data.data_type = 'spectrum';
  spec_data.format = 'png';
  
  
  return spec_data;
}

module.exports = function(json, callback) {
  var result = converter.convert(json, {keepSpectra:true});
  
  var spec_data;
  if (result.twoD){
    spec_data = jcamp2d(result);
  }else{
    spec_data = jcamp1d(result);
  }
  
  spec_data.label = result.spectra[0].title;
  spec_data.x_label = result.xType;
  spec_data.y_label = result.yType;
  spec_data.nd = result.twoD? 2 : 1;
  
  callback(spec_data);
};

},{"jcampconverter":5}],38:[function(require,module,exports){
function modal_input(app, node, callback) {
  var modals =   app.modals();
  var nano = modals.proto(undefined, '',
    function(modal) {
      modal.hide();
      var input = d3.select(modal.modal.el)
        .select("input").node().value;
      callback(input);
    });
  
  var el = d3.select(nano.modal.el).select(".nanoModalContent");
  el.append(node);
  return nano.show;
}

module.exports = function (app, callback) {
  return function () {
    callback = callback || app.currentSlide().addSpec;
    modal_input ( app,
      require('../input_elem').text('File URL', 'http://'),
      function (input) {
        require('./process_data').get_spectrum(input,  callback);
      }
    )();
  };
  
};
},{"../input_elem":25,"./process_data":41}],39:[function(require,module,exports){
function handle_peaks (app, json) {
  var spec = app.currentSlide().spectra().filter(function (s) {
    return s.s_id() === json['s_id'];
  });
  
  if (spec.length === 0){
    app.modals.error('Incompatible server response', 
    'Can\'t find spectrum with s_id:' + json['s_id']);
  }
  spec[0].addPeaks(json['peaks']);
  app.slideDispatcher().peakpick();
}

function handle_segs (app, json) {
  var spec = app.currentSlide().spectra().filter(function (s) {
    return s.s_id() === json['s_id'];
  });
  
  if (spec.length === 0){
    app.modals.error('Incompatible server response', 
    'Can\'t find spectrum with s_id:' + json['s_id']);
  }
  
  for (var i = 0; i < json['segs'].length; i++) {
    spec[0].addSegmentl( json['segs'][i] );
  }
}

//TODO:handle_spec_like
function handle_spec_feature (app, json, preview){
  if (json['peaks'] !== undefined){
    handle_peaks(app, json, preview);
  }
  if (json['segs'] !== undefined){
    handle_segs(app, json, preview);
  }
}

function handle_spectrum (app, json, preview){
  require('./process_data')
    .process_spectrum(json, app.currentSlide().addSpec);
}

module.exports.spectrum = handle_spectrum;
module.exports.spec_feature = handle_spec_feature;
},{"./process_data":41}],40:[function(require,module,exports){
module.exports = function (app) {
  function request (fun, params, s_id, preview) {
    params = params || {};
  
    var sel, all_sids;
    if(!params['sid']){
      if(s_id){
        params['sid'] = s_id;
      }else{
        sel = app.currentSlide().spectra(true);
        all_sids = sel.map(function (s) { return s.s_id(); });
        params['sid'] = all_sids.filter(function (e) { return e; });
      }
    }
    if(params['sid'].length === 0){
      var message = 'Please select one or more spectra!';
      if(all_sids.length > 0){ // if some s_ids were null;
        sel = app.currentSlide().spectra();
        var null_labels = sel.filter(function (s) { return !s.s_id(); })
          .map(function (s) { return s.label(); })
          .join(', ');
        
        message += '<br>NOTE: ['+ null_labels +'] spectra are stored locally' +
          ' and not connected to the server.';
      }
      app.modals().error('No Spectra selected', message);
      return;
    }
    
    var prefix = fun+'_';
    var params_str = 'sid=' + 
      JSON.stringify(params['sid']) + '&preview=' + (+preview) +'&'+ prefix + '=null';
  
    for(var key in params){
      if(key === 'sid') {continue;}
      if(params_str.length>0) {params_str +='&';}
    
      params_str += prefix + key+'='+params[key];
    }
  
    var url = app.connect() + 'plugins?'+params_str;
    //var ajax = pro.ajax();
    var ajax = require('./ajax');
    ajax.getJSON(url, function (response) {
        respond(response, preview);
    });
  }
  
   function respond (json, preview) {
    if (json.constructor === Array) {
      for (var i = json.length - 1; i >= 0; i--) {
        respond(json[i]);
      }
      return;
    }
    var hooks = require('./plugin-hooks');
    
    var type = json['data_type'];
    if (type === undefined){ //if no data_type, it is assumed as spectrum
      type = 'spectrum';
    }
    if(typeof hooks[type] === 'function'){
      hooks[type](app, json, preview);
    }else{
      app.modals.error('Unsupported data-type', 
        'Couldn\'t find suitable function to read "'+type+'" data');
    }
    
  }
  return request;
};

},{"./ajax":36,"./plugin-hooks":39}],41:[function(require,module,exports){
var get_png_data = function(y, callback){
  var img = document.createElement("img");
  
  img.onload = function(){
    var canvas = document.createElement("canvas");
    canvas.width = img.width;
    canvas.height = img.height;

    // Copy the image contents to the canvas
    var ctx = canvas.getContext("2d");

    ctx.drawImage(img, 0, 0);    
    var buffer = ctx.getImageData(0,0,img.width,img.height).data;
  
    var img_data = Array.prototype.filter.call(buffer, function(element, index){
        return(index%4 === 0);
    });
    
    callback(img_data);
  };
  
  img.src = "data:image/png;base64," + y;  
};

var process_png = function(pre_data, render_fun){
  if (pre_data['nd'] === 1){
    get_png_data(pre_data['y'], function(img_data){
      // Scaling X and Y
      var xscale = d3.scale.linear().range(pre_data['x_domain']).domain([0, img_data.length]);
      var yscale = d3.scale.linear().range(pre_data['y_domain']).domain([0, 255]);
    
      // Mapping data and rendering
      var data = img_data.map(function(d,i){ return {x:xscale(i), y:yscale(d)}; });
      render_fun(data);  
    });
  }
  
  if (pre_data['nd'] === 2){
    // Mapping data and rendering
    render_fun(pre_data);
  }
};

var process_xy = function(pre_data, render_fun){
  var data = pre_data.x.map(function(d,i){ return {x:d, y:pre_data.y[i]}; });  
  render_fun(data);
};

var process_b64 = function(pre_data, render_fun){
  var img_data = atob(pre_data['y']);
  console.log(img_data);
  // Scaling X and Y
  var xscale = d3.scale.linear().range(pre_data['x_domain']).domain([0, img_data.length]);
  var yscale = d3.scale.linear().range(pre_data['y_domain']).domain([0, 255]);

  // Mapping data and rendering
  var data = img_data.map(function(d,i){ return {x:xscale(i), y:yscale(d)}; });
  render_fun(data);  
};


var processPNG = function (json, callback) {
  if (!json['nd'] || json['nd'] === 1){
    var img = document.createElement("img");
  
    img.onload = function(){
      var canvas = document.createElement("canvas");
      canvas.width = img.width;
      canvas.height = img.height;

      // Copy the image contents to the canvas
      var ctx = canvas.getContext("2d");

      ctx.drawImage(img, 0, 0);    
      var buffer = ctx.getImageData(0,0,img.width,img.height).data;
  
      var img_data = [];
      var _16bit = (json['format'] === "png16");
      var len = _16bit? buffer.length/2: buffer.length;
      
      var yscale = d3.scale.linear().range(json['y_domain']).domain([0, 255]);
      if(_16bit) {yscale.domain([0,Math.pow(2,16)-1]);}
      
      for (var i = 0; i < len; i+=4) {
        if(!_16bit){
          img_data.push(yscale(buffer[i]));
        }else{
          img_data.push( yscale( (buffer[ i + len ] << 8) + buffer[i]) );
        }
      }
      
      if(json['x_domain']){
        var xscale = d3.scale.linear().range(json['x_domain']).domain([0, img_data.length]);
        img_data = img_data.map(function(d,i){ return {x:xscale(i), y:d}; });
      }
      
      //console.log("img_data",img_data);
      var ret;
      if(typeof json["s_id"] !== 'undefined'){
        ret = {data:img_data, s_id:json['s_id']};
      }else{ ret = {data:img_data}; }
      
      callback(ret);
    };
    var png_data = json['data']? json['data']: json['y'];
    img.src = "data:image/png;base64," + png_data;
  }else if (json['nd'] === 2){
    // Mapping data and rendering
    callback(json);
  }else{
    console.log("Unsupported data dimension: "+ json['nd']);
  }
};

var processPNGworker = function (json, callback) {
  if (!json['nd'] || json['nd'] === 1){
    var img = document.createElement("img");
  
    img.onload = function(){
      var canvas = document.createElement("canvas");
      canvas.width = img.width;
      canvas.height = img.height;
  
      var e = {};
      e._16bit = (json['format'] === "png16");
      
      // Copy the image contents to the canvas
      var ctx = canvas.getContext("2d");
      ctx.drawImage(img, 0, 0);    
      e.buffer = ctx.getImageData(0,0,img.width,img.height).data;
      
      e.y_range = json['y_domain'];
      e.y_domain = [0, 255];
      if(e._16bit) {e.y_domain = [0,Math.pow(2,16)-1];}
      
      var worker_callback = function(e) {
        console.log('worker done');
        var img_data = [].slice.call(e.data);
        
        if(json['x_domain']){
          var xscale = d3.scale.linear().range(json['x_domain']).domain([0, img_data.length]);
          img_data = img_data.map(function(d,i){ return {x:xscale(i), y:d}; });
        }
      
        json['data'] = img_data;
        callback(json);
      };
      
      var worker_message = [e, [e.buffer.buffer]];
      
      require('./worker').addJob({message:worker_message, callback:worker_callback});
    };
    var png_data = json['data']? json['data']: json['y'];
    img.src = "data:image/png;base64," + png_data;
  }else if (json['nd'] === 2){
    // Mapping data and rendering
    callback(json);
  }else{
    console.log("Unsupported data dimension: "+ json['nd']);
  }
};


/* * get the sepctrum from the web service in one these formats:
  * Plain JSON X-Y ['xy']
  * JSON X(range), Y (base64) ['base64'] --> if scaled down to 8 or 16 bits: require "y_domain"
  * JSON X(range), Y(png) ['png']--> require "y_domain"

  ** JSON object will contain the following parameters:
  * format: xy, base64, png
  * nd: number of dimensions (1 or 2)
  * x or x_domain: the chemical shift (x) value for each point, or chemical shift range (x_doamin)
  * y: singal intensities along the sepctrum.
  * y_domain: if 'y' was reduced to 8 or 16 bit, y_domain scales it back to original values.
*/
function process_spectrum (json, render_fun){
  if(typeof json !== 'object'){ //it wasn't a json file.
    console.log(json, typeof json);
    return require('./jcamp')(json, render_fun);
  }
  if (json.constructor === Array) {
    for (var i = json.length - 1; i >= 0; i--) {
      process_spectrum(json[i], render_fun);
    }
    return;
  }
  switch (json['format']){
    case 'xy':
      process_xy(json, render_fun);
      break;
    case 'base64'://add base64 processing
      process_b64(json, render_fun);
      break;
    case 'png':
    case 'png16':
      if (require('./worker').maxWorkers() > 0){
        processPNGworker(json, render_fun);
      }else{
        processPNG(json, render_fun);
      }      
      break;
  }  
}

function get_spectrum (url, render_fun) {
  var ajax = require('./ajax');
  ajax.getJSON(url, function (response) {
    process_spectrum(response, render_fun);
  });
}

module.exports.get_spectrum = get_spectrum;
module.exports.process_spectrum = process_spectrum;
},{"./ajax":36,"./jcamp":37,"./worker":42}],42:[function(require,module,exports){
var workers_pool = [];
var MAX_WORKERS = (navigator.hardwareConcurrency || 2) -1;

function make_png_worker () {
  var png_worker = function () {
    function scale(range, domain){
      var domain_limits = domain[1] - domain[0];
      var range_limits = range[1] - range[0];
    
      return function(_){
        return ((_ - domain[0]) / domain_limits) * range_limits + range[0];
      };
    }
  
    self.onmessage = function(e, buf){
      e = e.data;
      var buffer = e.buffer;
      var len = e._16bit? buffer.length/2: buffer.length;
    
      var yscale = scale(e.y_range, e.y_domain);
      var img_data = new Float64Array(len/4);
    
      for (var i = 0; i < len; i+=4) {
        if(! e._16bit){
          img_data[i/4] = yscale(buffer[i]);
        }else{
          img_data[i/4] = yscale( (buffer[ i + len ] << 8) + buffer[i] );
        }
      }
      self.postMessage(img_data, [img_data.buffer]);
    };  
  };
  var blob = new Blob(['('+ png_worker.toString() +')()'],
    { type: 'application/javascript' });
  var blobURL = window.URL.createObjectURL(blob);
  var worker = new Worker(blobURL);  
  return worker;
}

var q = [];

function next (worker) {
  var job = q.shift();
  if (!job) // if the queue is finished.
    return;
  
  worker.hasJob = true;
  worker.onmessage = function (e) {
    var callback = job['callback'];
    worker.hasJob = false;
    next(worker);
    callback(e);
  };
  worker.postMessage(job['message'][0], job['message'][1]);
};

function addJob (_) {
  q.push(_);
  var free_worker = getFreeWorker();
  if ( typeof free_worker !== 'undefined'){ //if there is a currently free worker, start this job.
    next(free_worker);
  }
};

function getFreeWorker() {
  for (var i = 0; i < workers_pool.length; i++) {
    if (! workers_pool[i].hasJob){
      return workers_pool[i];
    }
  }
  if (workers_pool.length < MAX_WORKERS){
    var new_worker = make_png_worker();
    workers_pool.push(new_worker);
    return new_worker;
  }
  return undefined;
}

function maxWorkers(_) {
  if (!arguments.length) return MAX_WORKERS;
  MAX_WORKERS = _;
}

module.exports.addJob = addJob;
module.exports.maxWorkers = maxWorkers;
},{}],43:[function(require,module,exports){
module.exports = function(){
  var core = require('./elem');
  var source = core.Elem('g');
  core.inherit(Slide, source);
  
  var data, slide_selection, svg_selection, svg_width, svg_height;
  var clip_id = require('./utils/guid')();
  var filter_id = require('./utils/guid')();
  var parent_app, spec_container;
  
  // Event dispatcher to group all listeners in one place.
  var dispatcher = d3.dispatch(
    "rangechange", "regionchange", "regionfull", "redraw",    //redrawing events
    'specDataChange',
    "mouseenter", "mouseleave", "mousemove", "click",   //mouse events
    "keyboard",                                //Keyboard
    "peakpickEnable", "peakdelEnable", "peakpick", "peakdel",    //Peak picking events
    "integrateEnable", "integrate", "integ_refactor",            //Integration events
    "crosshairEnable",
    "blindregion",
    "log"
  );
  function create_empty_slide(app) {
    svg_selection = app.append('div')
      .text('This slide does not contain any spectra. Click to add one.')
      .style({
        width: (svg_width+'px'),
        'line-height': (svg_height+'px')
      })
      .classed('spec-slide empty', true)
      .on('click', require('./pro/open-file')(app) );
  }
  
  function Slide(app){
    parent_app = app;
    svg_width = Slide.width();
    svg_height = Slide.height();
    
    if(!data){
      create_empty_slide(app);
      return ;
    }
		//TODO: check nd (if missing, or not in [1,2])
    var two_d = (data["nd"] && data["nd"] === 2);
    
    var brush_margin = app.config() > 1 ? 20 : 0;
    var margin = {
        top: 10 + brush_margin,
        right: 40,
        bottom: 40,
        left:10 + brush_margin
    };

    var width = svg_width - margin.left - margin.right,
        height = svg_height - margin.top - margin.bottom;
    
    var x = d3.scale.linear().range([0, width]),
    y = d3.scale.linear().range([height, 0]);
  
    var xAxis = d3.svg.axis().scale(x).orient("bottom"),
        yAxis = d3.svg.axis().scale(y).orient("right")
          .tickFormat(two_d? null : d3.format("s"));
    
    var xGrid = d3.svg.axis().scale(x)
        .orient("bottom").innerTickSize(height)
        .tickFormat(''),
      yGrid = d3.svg.axis().scale(y)
        .orient("right").innerTickSize(width)
        .tickFormat('');
		
    dispatcher.idx = 0;
    
    svg_selection = app.append('svg')
      .classed('spec-slide', true)
      .attr({
        width:svg_width,
        height:svg_height
      });
      
    slide_selection = source(svg_selection)
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")")
      .attr({
        width:svg_width,
        height:svg_height
      });
        
    var defs = slide_selection.append("defs");
    defs.append("clipPath")
    .attr("id", clip_id)
      .append("rect")
        .attr("width", width)
        .attr("height", height);

    /** PNG images are grey scale. All positive and negative values are represented as unsigned 8-bit int.
        where 127 represent the zero. We want to recolor them as follows:
         * positive values colored with a red-orange hue.
        * negative values colored with a blue-cyan hue.
        * Zeros colored as white.
      * To do so, first copy Red component to Green and Blue.
      * Red component will take zeros upto 255/2 (127) i.e negative values. values >127 colored using red/green gradient.
      * constrast this for the blue component.
    */
  
    if(two_d){
      var slope = 1;
      if (require('bowser').safari) {
        slope *= 2;
      }
      var svg_filter = defs.append("filter").attr("id", filter_id);
      svg_filter.append("feColorMatrix")
        .attr("type","matrix")
        .attr("values","1 0 0 0 0  0 0 0 0 0 1 0 0 0 0 0 0 0 1 0");
  
      var fe_component_transfer = svg_filter.append("feComponentTransfer")
        .attr("color-interpolation-filters","sRGB");
  
      fe_component_transfer.append("feFuncR")
        .attr("type","linear")
        .attr("slope",-slope)
        .attr("intercept","0.5");
        
      fe_component_transfer.append("feFuncB")
        .attr("type","linear")
        .attr("slope",slope)
        .attr("intercept","-0.5");
  
      fe_component_transfer = svg_filter.append("feComponentTransfer")
        .attr("color-interpolation-filters","sRGB");

      fe_component_transfer.append("feFuncR")
        .attr("id","rfunc")
        .attr("type","linear")
        .attr("slope","1");
          
      fe_component_transfer.append("feFuncB")
        .attr("id","bfunc")
        .attr("type","linear")
        .attr("slope","1");
                      
      svg_filter.append("feColorMatrix")
        .attr("type","matrix")
        .attr("values","-10 0 0 0 1 -10 0 -10 0 1 0 0 -10 0 1 0 0 0 1 0");
  
    }
    /**********************************/        
    
    //axes  and their labels
    slide_selection.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")");
      

    slide_selection.append("g")
      .attr("class", "y axis")
      .attr("transform", "translate(" + width + ",0)");
    
    slide_selection.append("g").classed('x grid', true);
    slide_selection.append("g").classed('y grid', true);
    
    slide_selection.append("text")
      .attr("class", "x axis-label")
      .attr("text-anchor", "middle")
      .attr("x", width/2)
      .attr("y", height)
      .attr("dy", "2.8em")
      .text("Chemical shift (ppm)");
    
    slide_selection.append("text")
      .attr("class", "y axis-label")
      .attr("text-anchor", "end")
      .attr("y", width)
      .attr("dy", "-.75em")
      .attr("transform", "rotate(-90)")
      .text("Intensity");
    
    dispatcher.on("redraw.slide", function (e) {
      if(e.x){
        slide_selection.select(".x.axis").call(xAxis);
        if(app.options.grid.x){
          slide_selection.select(".x.grid").call(xGrid);
        }
      }
      if(e.y){
        slide_selection.select(".y.axis").call(yAxis);
        if(app.options.grid.y){
          slide_selection.select(".y.grid").call(yGrid);
        }
      }
    });
    
    spec_container = two_d ? require('./d2/spec-container-2d')() : require('./d1/spec-container-1d')();
    //Spec-Container
    spec_container
      .datum(data)
      .xScale(x)
      .yScale(y)
      .width(width)
      .height(height)
      .dispatcher(dispatcher)
      (Slide);
    
    //Scale brushes
    if( app.config() > 1){
      require('./d1/scale-brush')()
        .xScale(x)
        .dispatcher(dispatcher)
        (Slide);
        
      require('./d1/scale-brush')()
        .yScale(y)
        .dispatcher(dispatcher)
        (Slide);
    }
    
    d3.rebind(Slide, spec_container, 'spectra', 'addSpec', 'changeRegion', 'range');
  }
  Slide.show = function (_) {
    if(svg_selection){
      svg_selection.classed('active', _);  
    }    
  };
  Slide.nd = function(){
    if (!data){ //TODO: empty slide?
      return 0;
    }
    return (data["nd"] && data["nd"] === 2) ? 2 : 1;
  };
  Slide.clipId = function(){
    return clip_id;
  };
  Slide.filterId = function(){
    return filter_id;
  };
  Slide.slideDispatcher = function(){
    return dispatcher;
  };
  Slide.specContainer = function(){
    return spec_container;
  };
  Slide.datum = function(_){
    if (!arguments.length) {return data;}
    data = _;
    return Slide;
  };
  Slide.parent = function () {
    return parent_app;
  };
  Slide.spectra = function () {
    // This is called only when spec_container is not present, i.e. empty slide.
    return [];
  };
  Slide.addSpec = function (_) { 
    // This is called only when spec_container is not present, i.e. empty slide.
    // #TODO: Actually, this is also called if the slide is not rendered.
    // In that case, svg_selection & parent_app are undefined.
    // To solve this, add specContainer on initialization.
    
    svg_selection.remove(); // remove the empty slide.
    Slide.datum(_)(parent_app);  // call the slide again with the data.
    if (parent_app.currentSlide() === Slide) { 
			Slide.show(true);
			parent_app.dispatcher().menuUpdate();
		}
  };
  return Slide;
};

},{"./d1/scale-brush":16,"./d1/spec-container-1d":17,"./d2/spec-container-2d":20,"./elem":22,"./pro/open-file":38,"./utils/guid":49,"bowser":3}],44:[function(require,module,exports){
Array.prototype.subset =function(arr){
  var ret = [];
  for (var i = arr.length - 1; i >= 0; i--){
    ret.push(this[arr[i]]);
  } 
  return ret;
};
Array.prototype.rotate =function(reverse){
  if(reverse)
    {this.push(this.shift());}
  else
    {this.unshift(this.pop());}
  return this;
};
Array.prototype.rotateTo =function(val){
  while(this[0] !== val){
    this.rotate();
  }
  return this;
};
Array.prototype.whichMax = function () {
  if (!this.length || this.length === 0)
    {return null;}
    
  if (this.length === 1)
    {return 0;}
  
  var max = this[0].y;
  var maxIndex = 0;
  
  for (var i = 1; i < this.length; i++) {
    if (this[i].y > max) {
      maxIndex = i;
      max = this[i].y;
    }
  }
  return maxIndex;
};
Array.prototype.cumsum = function () {
  for (var _cumsum = [this[0]], i = 0, l = this.length-1; i<l; i++) 
    {_cumsum[i+1] = _cumsum[i] + this[i+1];}
  
  return _cumsum;
};
d3.selection.prototype.selectP =function(selector){
  var parent = this.node().parentNode;
  while(parent){       
    if(parent.matches(selector))
      {return d3.select(parent);}
    
    parent = parent.parentNode;
  }
  return null;
};
d3.selection.prototype.toggleClass = function(class_name){
  return this.classed(class_name, !this.classed(class_name));
};
d3.selection.prototype.size = function() {
  var n = 0;
  this.each(function() { ++n; });
  return n;
};
require('../../lib/d3-tip.edited.js')(d3);
},{"../../lib/d3-tip.edited.js":2}],45:[function(require,module,exports){
"use strict";
// The public function name defaults to window.docReady
// but you can modify the last line of this function to pass in a different object or method name
// if you want to put them in a different namespace and those will be used instead of 
// window.docReady(...)
var funcName = funcName || "docReady";
var readyList = [];
var readyFired = false;
var readyEventHandlersInstalled = false;
    
// call this when the document is ready
// this function protects itself against being called more than once
function ready() {
  if (!readyFired) {
    // this must be set to true before we start calling callbacks
    readyFired = true;
    for (var i = 0; i < readyList.length; i++) {
      // if a callback here happens to add new ready handlers,
      // the docReady() function will see that it already fired
      // and will schedule the callback to run right after
      // this event loop finishes so all handlers will still execute
      // in order and no new ones will be added to the readyList
      // while we are processing the list
      readyList[i].fn.call(window, readyList[i].ctx);
    }
    // allow any closures held by these functions to free
    readyList = [];
  }
}
    
function readyStateChange() {
  if ( document.readyState === "complete" ) {
    ready();
  }
}
    
// This is the one public interface
// docReady(fn, context);
// the context argument is optional - if present, it will be passed
// as an argument to the callback
module.exports = function(callback, context) {
  // if ready has already fired, then just schedule the callback
  // to fire asynchronously, but right away
  if (readyFired) {
    setTimeout(function() {callback(context);}, 1);
    return;
  } else {
    // add the function and context to the list
    readyList.push({fn: callback, ctx: context});
  }
  // if document already ready to go, schedule the ready function to run
  // IE only safe when readyState is "complete", others safe when readyState is "interactive"
  if (document.readyState === "complete" || (!document.attachEvent && document.readyState === "interactive")) {
    setTimeout(ready, 1);
  } else if (!readyEventHandlersInstalled) {
    // otherwise if we don't have event handlers installed, install them
    if (document.addEventListener) {
      // first choice is DOMContentLoaded event
      document.addEventListener("DOMContentLoaded", ready, false);
      // backup is window load event
      window.addEventListener("load", ready, false);
    } else {
      // must be IE
      document.attachEvent("onreadystatechange", readyStateChange);
      window.attachEvent("onload", ready);
    }
    readyEventHandlersInstalled = true;
  }
};
},{}],46:[function(require,module,exports){
module.exports = function(element,event){
  var evt;
  if (document.createEventObject){
    // dispatch for IE
    evt = document.createEventObject();
    return element.fireEvent('on'+event,evt);
  }else{
    // dispatch for firefox + others
    evt = document.createEvent("HTMLEvents");
    evt.initEvent(event, true, true ); // event type,bubbling,cancelable
    return !element.dispatchEvent(evt);
  }
};

},{}],47:[function(require,module,exports){
function launchFullScreen(element) {
  if (element.requestFullscreen)
    { element.requestFullscreen(); }
  else if (element.mozRequestFullScreen)
    { element.mozRequestFullScreen(); }
  else if (element.webkitRequestFullscreen)
    { element.webkitRequestFullscreen(); }
  else if (element.msRequestFullscreen)
    { element.msRequestFullscreen(); }
}
function isFullScreen(){
 return document.fullscreenElement ||
  document.mozFullScreenElement ||
  document.webkitFullscreenElement ||
  document.msFullscreenElement;
}
function toggleFullScreen(element) {
  if (!isFullScreen() ) {  // current working methods
    launchFullScreen(element);
  } else {
    if (document.exitFullscreen) {
      document.exitFullscreen();
    } else if (document.msExitFullscreen) {
      document.msExitFullscreen();
    } else if (document.mozCancelFullScreen) {
      document.mozCancelFullScreen();
    } else if (document.webkitExitFullscreen) {
      document.webkitExitFullscreen();
    }
  }
}

module.exports.launch = launchFullScreen;
module.exports.toggle = toggleFullScreen;
module.exports.isFull = isFullScreen;

},{}],48:[function(require,module,exports){
module.exports = function (node) {
  var clientwidth = node.clientWidth,
  clientheight = node.clientHeight;
  
  var br_width, br_height;
  if(typeof node.getBoundingClientRect === 'function'){
    br_width = node.getBoundingClientRect().width;
    br_height = node.getBoundingClientRect().height;
  }
  var cs_width, cs_height;
  if(typeof getComputedStyle === 'function'){
    cs_width = getComputedStyle(node).width;
    cs_height = getComputedStyle(node).height;
  }
  
  var width = d3.max([clientwidth, br_width, cs_width]),
    height = d3.max([clientheight, br_height, cs_height]);
  
  return [width, height];
};
},{}],49:[function(require,module,exports){
module.exports = function (){
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(
    /[xy]/g, function(c) {
      var r = Math.random()*16|0,v=c==='x'?r:r&0x3|0x8;
      return v.toString(16);
    }
  );
};

},{}],50:[function(require,module,exports){
module.exports = function (data, xscale, tolerance) {
  var ppm_range = Math.abs(xscale.domain()[0] - xscale.domain()[1]);
  var pixels = Math.abs(xscale.range()[0] - xscale.range()[1]);
  var ppm_per_pixel = ppm_range / pixels;
  tolerance *= ppm_per_pixel;
  
  var dataResample = require('simplify')(data, tolerance);
  return dataResample;
};

},{"simplify":8}]},{},[24])(24)
});