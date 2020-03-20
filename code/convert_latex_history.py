#!/usr/bin/env python

"""
Originally developed for paper-ptdins.
Turns a tex document into a history format.
Use by makefiles with tex documents.
"""

import os,sys,re

subs = [
(r"(\.|\?|\.\")[ \t]+([^\n])",r"\1\n\2",),
('[\n]{2,}','\n\n',),]

fn,fn_out = sys.argv[1],sys.argv[2]
if len(sys.argv)>3: 
	raise Exception('too many arguments: %s'%str(sys.argv))
if not os.path.isfile(fn):
	raise Exception('cannot find source: %s'%fn)
with open(fn) as fp: 
	text = fp.read()
for pattern,replace in subs:
	text = re.sub(pattern,replace,text)
with open(fn_out,'w') as fp: 
	fp.write(text)
