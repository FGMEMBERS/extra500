#    This file is part of extra500
#
#    extra500 is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 2 of the License, or
#    (at your option) any later version.
#
#    extra500 is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with extra500.  If not, see <http://www.gnu.org/licenses/>.
#
#      Authors: Eric van den Berg
#      Date: 04.04.2016
#
#      Last change: Eric van den Berg     
#      Date: 29.06.2016            
#

# The performance Table Data loaded by performance.nas

var performanceTable = {
	cruise : [
			[1,0,199,242,145,155],
			[2,2000,202,238,147,150],
			[3,4000,206,234,149,145],
			[4,6000,210,232,151,141],	
			[5,8000,213,230,153,136],
			[6,10000,217,229,156,132],
			[7,12000,221,227,158,129],
			[8,14000,218,211,161,125],
			[9,16000,216,200,163,123],
			[10,18000,214,190,166,120],
			[11,20000,203,166,158,108],
			[12,22000,199,152,161,107],
			[13,24000,193,140,154,105],
			[14,25000,186,128,165,105]
		],
	climb : [
			[1,0,0,0,0],
			[2,1000,42,3,1],
			[3,2000,90,6,3],
			[4,3000,132,9,4],
			[5,4000,180,12,6],	
			[6,5000,222,15,7],
			[7,6000,270,18,9],
			[8,7000,312,20,10],
			[9,8000,360,23,12],
			[10,9000,402,26,13],
			[11,10000,444,29,15],
			[12,11000,492,32,16],
			[13,12000,534,35,18],
			[14,13000,582,38,20],
			[15,14000,630,41,21],
			[16,15000,684,44,23],
			[17,16000,744,47,26],
			[18,17000,810,50,28],
			[19,18000,876,54,31],
			[20,19000,960,58,34],
			[21,20000,1050,63,38],
			[22,21000,1152,67,42],
			[23,22000,1272,73,48],
			[24,23000,1422,79,54],
			[25,24000,1620,87,63],
			[26,25000,1976,98,75]
		],
	descent : [
			[1,0,0,0,0],
			[2,1000,30,1,2],
			[3,2000,60,2,4],
			[4,3000,90,3,6],
			[5,4000,120,4,8],	
			[6,5000,150,5,10],
			[7,6000,180,6,12],
			[8,7000,210,8,14],
			[9,8000,240,9,16],
			[10,9000,270,10,18],
			[11,10000,300,11,20],
			[12,11000,330,12,22],
			[13,12000,360,13,24],
			[14,13000,390,14,26],
			[15,14000,420,16,28],
			[16,15000,450,17,30],
			[17,16000,480,18,32],
			[18,17000,510,19,34],
			[19,18000,540,20,36],
			[20,19000,570,22,37],
			[21,20000,600,23,39],
			[22,21000,630,24,41],
			[23,22000,660,25,43],
			[24,23000,690,27,44],
			[25,24000,720,28,46],
			[26,25000,750,29,48]
		],
	taxi : [],
	ReconAlt : [
				[1,0,0],
				[2,45,5000],
				[3,80,16000],
				[4,180,25000]
		]
};

#print("performanceTable loaded.")
