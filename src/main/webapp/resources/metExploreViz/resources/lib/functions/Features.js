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
metExploreD3.Features={features:{highlightSubnetwork:{description:"highlightSubnetwork",enabledTo:["lcottret","npoupin"]},layouts:{description:"layouts",enabledTo:["fjourdan"]},algorithm:{description:"layouts",enabledTo:["cfrainay"]}},isEnabled:function(b,a){if(this.features[b]!=undefined){return this.isEnabledForUser(b,a)||this.isEnabledForAll(b)}return false},isEnabledForUser:function(b,a){if(this.features[b]!=undefined){return this.features[b].enabledTo.indexOf(a)!=-1}return false},isEnabledForAll:function(a){if(this.features[a]!=undefined){return this.features[a].enabledTo.indexOf("all")!=-1}return false}};