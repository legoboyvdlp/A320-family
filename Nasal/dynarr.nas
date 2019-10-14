# Class for dynamic arrays
#
# Copyright (c) 2018 dynamic arrays authors:
#  Michael Danilov <mike.d.ft402 -eh- gmail.com>
#  Merspieler http://gitlab.com/merspieler
# Distribute under the terms of GPLv2.

## Useage
# to create a new object: var <name> = dynarr.new();
# to add elements: <name>.add(<element>);
# you can access the full stored array as: <name>.arr
# to get only the used area of the array: var <spliced_array> = <name>.get_spliced()

var dynarr =
{
	new: func(size = 8)
	{
		var this = {parents:[dynarr]};
		this.maxsize = size;
		this.size = 0;
		this.arr = setsize([], size);

		return this;
	},

	# add a new element to the array
	add: func(obj)
	{
		# case there's no space left
		if (me.size + 1 >= me.maxsize)
		{
			# double array size
			me.maxsize *= 2;
			me.arr = setsize(me.arr, me.maxsize);
		}

		# add object and increase used counter
		me.arr[me.size] = obj;
		me.size += 1;
	},

	# delete an element from the array
	del: func(id)
	{
		me.size -= 1;
		for(ii = id; ii < me.size - 1; ii += 1){
			me.arr[ii] = me.arr[ii + 1];
		}
	},

	# returns only the filled part of the array or nil if array is empty
	get_sliced: func()
	{
		if (me.size == 0)
		{
			return nil;
		}

		return me.arr[0:me.size - 1];
	}
};
