/*
 This file is part of MetExploreViz 

 Copyright © 2016 INRA 
 Contact: http://metexplore.toulouse.inra.fr/metexploreViz/doc/contact 
 GNU General Public License Usage 
 This file may be used under the terms of the GNU General Public License version 3.0 as 
 published by the Free Software Foundation and appearing in the file LICENSE included in the 
 packaging of this file. 
 Please review the following information to ensure the GNU General Public License version 3.0 
 requirements will be met: http://www.gnu.org/copyleft/gpl.html. 
 If you are unsure which license is appropriate for your use, please contact us 
 at http://metexplore.toulouse.inra.fr/metexploreViz/doc/contact
 Version: 1.2.0.2 
 Build Date: Mon Nov 21 14:42:33 CET 2016 
 */
var MetExploreViz={initFrame:function(b){var d=document.createElement("iframe");d.id="iFrameMetExploreViz",d.height="100%",d.width="100%",d.border=0,d.setAttribute("style","border: none;top: 0; right: 0;bottom: 0; left: 0; width: 100%;height: 100%;");var c=document.getElementsByTagName("script");var f;for(var e=0;e<c.length;e++){if(c[e].src.search("metExploreViz/metexploreviz.js")!=-1){f=c[e].src}}var h=document.location.href;var g=0;while(f[g]==h[g]&&g!=h.length&&g!=f.length){g++}var f=f.substr(g,f.length-1);f=f.split("/metexploreviz.js");res=h.substr(g,h.length-1);res=res.split("/");var j="";for(var e=0;e<res.length-1;e++){j+="../"}var a=j+f[0]+"/index.html";document.getElementById(b).insertBefore(d,document.getElementById(b).firstChild);d.src=a},launchMetexploreFunction:function(b){if(typeof metExploreViz!=="undefined"){b();return}var a=this;setTimeout(function(){a.launchMetexploreFunction(b)},100)},onloadMetExploreViz:function(a){this.launchMetexploreFunction(a)}};