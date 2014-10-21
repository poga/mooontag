all:
	lsc -cw index.ls | jade -w index.jade | stylus -w index.styl
