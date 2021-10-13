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
var MappingData=function(c,b,a,d){this.node=c;this.mappingName=b;this.conditionName=a;this.mapValue=d};MappingData.prototype={getNode:function(){return this.node},setNode:function(a){this.node=a},getMappingName:function(){return this.mappingName},getConditionName:function(){return this.conditionName},getMapValue:function(){return this.mapValue},setMapValue:function(a){this.mapValue=a}};