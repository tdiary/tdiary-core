NAME=tdiary
VERSION=`ruby -rtdiary -e 'puts TDIARY_VERSION'`
PKG=$(NAME)-$(VERSION).tar.gz
REMOVE=Makefile CVS theme/CVS erb/CVS misc/CVS misc/plugin/CVS skel/CVS plugin/CVS tdiary.conf .htaccess

snapshot:
	cvs co $(NAME)
	cd $(NAME); rm -rf $(REMOVE); cd ..
	tar zcvf $(NAME).tar.gz $(NAME)
	rm -r $(NAME)
	scp $(NAME).tar.gz tdiary:/home/httpd/tdiary/download/

pkg:
	cvs co $(NAME)
	mv $(NAME) $(NAME)-$(VERSION)
	cd $(NAME)-$(VERSION); rm -rf $(REMOVE); cd ..
	tar zcvf $(PKG) $(NAME)-$(VERSION)
	rm -r $(NAME)-$(VERSION)
	scp $(PKG).tar.gz tdiary:/home/httpd/tdiary/download/
