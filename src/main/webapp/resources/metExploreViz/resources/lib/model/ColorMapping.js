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
var ColorMapping=function(a,b){this.name=a;this.value=b};ColorMapping.prototype={getName:function(){return this.name},setName:function(a){this.name=a},getValue:function(){return this.value},setValue:function(a){this.value=a}};