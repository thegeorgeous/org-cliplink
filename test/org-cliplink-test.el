(require 'el-mock)

(add-to-list 'load-path ".")
(load "org-cliplink.el")

(ert-deftest org-cliplink-parse-response-test ()
  (let ((test-data '(("test-data/responses/inconsistent-eol-response" .
                      ((("Last-Modified" . "Sun, 08 Mar 2015 14:06:08 GMT")
                        ("Content-Length" . "199")
                        ("Content-type" . "text/html")
                        ("Date" . "Sun, 08 Mar 2015 14:17:14 GMT")
                        ("Server" . "SimpleHTTP/0.6 Python/2.7.9")) .
                        "Here goes body\n"))
                     ("test-data/responses/correct-response-without-title" .
                      ((("Last-Modified" . "Sun, 08 Mar 2015 14:06:08 GMT")
                        ("Content-Length" . "199")
                        ("Content-type" . "text/html")
                        ("Date" . "Sun, 08 Mar 2015 14:17:14 GMT")
                        ("Server" . "SimpleHTTP/0.6 Python/2.7.9")) .
                        "Here goes body\n")))))
    (dolist (test-case test-data)
      (message (car test-case))
      (let ((data-file (car test-case))
            (expected-outcome (cdr test-case)))
        (with-temp-buffer
          (insert-file data-file)
          (should (equal (org-cliplink-parse-response) expected-outcome)))))))

(ert-deftest org-cliplink-jira-extract-summary-from-current-buffer-positive-test ()
  (with-mock
   (stub org-cliplink-parse-response =>
         '(nil . "{\"fields\":{\"summary\":\"Hello, World\"}}"))
   (should (equal (org-cliplink-jira-extract-summary-from-current-buffer)
                  "Hello, World"))))

(ert-deftest org-cliplink-jira-extract-summary-from-current-buffer-negative-test ()
  (with-mock
   (stub org-cliplink-parse-response =>
         '(nil . "{}"))
   (should (not (org-cliplink-jira-extract-summary-from-current-buffer)))))

(ert-deftest org-cliplink-read-secrets-positive-test ()
  (let ((org-cliplink-secrets-path "./test-data/secrets/org-cliplink-secrets.el"))
    (should (equal (org-cliplink-read-secrets)
                   '(:hello (1 2 3))))))

(ert-deftest org-cliplink-read-secrets-negative-test ()
  (let ((org-cliplink-secrets-path "/path/to/non/existing/secrets"))
    (should (not (org-cliplink-read-secrets)))))

(ert-run-tests-batch-and-exit)
