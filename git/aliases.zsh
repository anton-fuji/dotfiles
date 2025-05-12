[alias]
	ad = add
	cm = commit -m
	s = status
	ss = status -s	
	rb = rebase
	st = stash
	sh = show
	ps = push
	pl = pull

	br = branch
	brd = branch -d

	co = checkout
	cob = checkout -b

	l = log
	l1 = log -1
	l2 = log -2
	l3 = log -3
	lo = log --oneline

# alias lists
	alias = !git config --get-regexp '^alias\\.' | sed 's/alias\\.\\([^ ]*\\) \\(.*\\)/\\1\\\t => \\2/' | sort

# graph
	gr = log --graph --date=short --decorate=short --pretty=format:'%Cgreen%h %Creset%cd %Cblue%cn %Cred%d %Creset%s'
