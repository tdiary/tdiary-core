;;; http.el -- utils for HTTP

;; Copyright (C) 2002 Junichiro Kita

;; Author: Junichiro Kita <kita@kitaj.no-ip.com>

;; $Id: http.el,v 1.2 2002-05-19 14:11:00 kitaj Exp $
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or (at
;; your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;;; Code:

(require 'pces)

(defvar http-timeout 10
  "Timeout for HTTP.")

;; derived from url.el
(defconst http-url-unreserved-chars
  '(
    ?a ?b ?c ?d ?e ?f ?g ?h ?i ?j ?k ?l ?m ?n ?o ?p ?q ?r ?s ?t ?u ?v ?w ?x ?y ?z
    ?A ?B ?C ?D ?E ?F ?G ?H ?I ?J ?K ?L ?M ?N ?O ?P ?Q ?R ?S ?T ?U ?V ?W ?X ?Y ?Z
    ?0 ?1 ?2 ?3 ?4 ?5 ?6 ?7 ?8 ?9
    ?$ ?- ?_ ?. ?! ?~ ?* ?' ?\( ?\) ?,)
  "A list of characters that are _NOT_ reserve in the URL spec.
This is taken from draft-fielding-url-syntax-02.txt - check your local
internet drafts directory for a copy.")

;; derived from url.el
(defun http-url-hexify-string (str coding)
  "Escape characters in a string.
At first, encode STR using CODING, then url-hexify."
  (mapconcat
   (function
    (lambda (char)
      (if (not (memq char http-url-unreserved-chars))
          (if (< char 16)
              (upcase (format "%%0%x" char))
            (upcase (format "%%%x" char)))
        (char-to-string char))))
   (encode-coding-string str coding) ""))

(defun http-fetch (url method &optional user pass data)
  "Fetch via HTTP.

URL is a url to be POSTed.
METHOD is 'get or 'post.
USER and PASS must be a valid username and password, if required.  
DATA is an alist, each element is in the form of (FIELD . DATA).

If no error, return a buffer which contains output from the web server.
If error, return a cons cell (ERRCODE . DESCRIPTION)."
  (let (connection server port path buf str len)
    (string-match "^http://\\([^/:]+\\)\\(:\\([0-9]+\\)\\)?\\(/.*$\\)" url)
    (setq server (match-string 1 url)
	  port (string-to-int (or (match-string 3 url) "80"))
	  path (match-string 4 url))
    (setq str (mapconcat
	       '(lambda (x)
		  (concat (car x) "=" (cdr x)))
	       data "&"))
    (setq len (length str))
    (save-excursion
      (setq buf (get-buffer-create (concat "*result from " server "*")))
      (set-buffer buf)
      (erase-buffer)
      (setq connection
	    (as-binary-process
	     (open-network-stream (concat "*request to " server "*")
				  buf
				  server
				  port)))
      (process-send-string
       connection
       (concat (if (eq method 'post)
		   (concat "POST " path)
		 (concat "GET " path (if (> len 0)
					 (concat "?" str))))
	       " HTTP/1.0\r\n"
	       (concat "Host: " server "\r\n")
	       "Connection: close\r\n"
	       "Content-type: application/x-www-form-urlencoded\r\n"
	       (if (and user pass)
		   (concat "Authorization: Basic "
			   (base64-encode-string
			    (concat user ":" pass))
			   "\r\n"))
	       (if (eq method 'post)
		   (concat "Content-length: " (int-to-string len) "\r\n"
			   "\r\n"
			   str))
	       "\r\n"))
      (goto-char (point-min))
      (while (not (search-forward "</body>" nil t))
	(unless (accept-process-output connection http-timeout)
	  (error "HTTP fetch: Connection timeout!"))
	(goto-char (point-min)))
      (goto-char (point-min))
      (save-excursion
	(if (re-search-forward "HTTP/1.1 \\([0-9][0-9][0-9]\\) \\(.*\\)" nil t)
	    (let ((code (match-string 1))
		  (desc (match-string 2)))
	      (cond ((equal code "200")
		     buf)
		    (t
		     (cons code desc)))))))))

(provide 'http)
;;; http.el ends here
