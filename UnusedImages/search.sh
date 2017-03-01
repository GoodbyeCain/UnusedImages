#!/bin/sh
#  search.sh
#  UnusedImages
#
#  Created by baidu on 2017/2/27.
#  Copyright © 2017年 say. All rights reserved.

path=$1

const_string=`/usr/bin/grep -r --include='*.h' --include='*.m' -E '@\"[-a-zA-Z0-9_]*?\"' $path -o -h`
const_string=${const_string//'"'/''}
const_string=${const_string//'@'/''}

#Background
name_ref=`/usr/bin/grep -r --include='*.xib' --include='*.storyboard' -E 'mage=\".+?\"' $path -o -h`
name_ref=${name_ref//'"'/''}
name_ref=${name_ref//'mage='/''}

echo $const_string $name_ref
#echo $name_ref
