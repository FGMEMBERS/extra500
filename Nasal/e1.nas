#    This file is part of Extra500
#
#    The Changer is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 2 of the License, or
#    (at your option) any later version.
#
#    The Changer is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Extra500.  If not, see <http://www.gnu.org/licenses/>.
#
#      Author: Eric van den Berg
#      Date:   05.02.2013
#
#     Last modified by: Eric van den Berg
#     Date:             14.04.2013

#Common bit swap function (taken from Mig-15bis)
var bitswap = func (bit_name)
	{         
		var set_pos=getprop(bit_name);
		if (!((set_pos==1) or (set_pos==0)))
		{
			return (0); 
		}
		else
		{
			var swap_pos=1-abs(set_pos);
			setprop(bit_name, swap_pos);
			return (1); 
		}
	}

#general bit add function 
var bitadd = func (bit_name1,bit_name2,bit_name3)
	{         
		var set_pos1 = getprop(bit_name1);
            var set_pos2 = getprop(bit_name2);
		if (!((set_pos1==1) or (set_pos1==0) or (set_pos2==1) or (set_pos2==0)))
		{
			return (0); 
		}
		else
		{
			var sum = set_pos1 + set_pos2;
			setprop(bit_name3, sum);
			return (1); 
		}
	}
