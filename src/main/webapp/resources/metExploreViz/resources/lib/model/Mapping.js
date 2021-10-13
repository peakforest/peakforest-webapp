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
var Mapping=function(c,b,a,d){this.name=c;this.conditions=b;this.targetLabel=a;this.data=[];this.id=d};Mapping.prototype={getId:function(){return this.id},setId:function(a){this.id=a},getName:function(){return this.name},setName:function(a){this.name=a},getConditions:function(){return this.conditions},getTargetLabel:function(){return this.targetLabel},getConditionByName:function(a){var b=null;this.comparedPanels.forEach(function(c){if(c.name==a){b=c}});return b},addMap:function(a){this.data.push(a)},getData:function(){return this.data}};