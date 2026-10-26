#lang racket/base

(require rackunit
         rackunit/docs-complete
         racket/port
         syntax/location)

(module undocumented racket/base
  (provide first second)
  (define first 1)
  (define second 2))

(define mod (quote-module-path undocumented))

(define (check-skip skip expected)
  (test-case (format "#:skip ~s" skip)
    (define output
      (with-output-to-string
        (lambda ()
          (parameterize ([current-error-port (current-output-port)])
            (check-docs mod #:skip skip)))))
    (check-regexp-match expected output)))

(check-skip 'first #rx"has undocumented exports:\n  \\(second\\)")
(check-skip (list #rx"^first$") #rx"has undocumented exports:\n  \\(second\\)")
(check-skip (list #rx"^second$") #rx"has undocumented exports:\n  \\(first\\)")
(check-skip 'missing #rx"has no documented exports")
(check-skip #f #rx"has no documented exports")
(check-skip '() #rx"has no documented exports")
(check-skip #rx"^first$" #rx"has undocumented exports:\n  \\(second\\)")
(check-skip (lambda (name) (eq? name 'first)) #rx"has undocumented exports:\n  \\(second\\)")
(check-skip '(first) #rx"has undocumented exports:\n  \\(second\\)")
(check-skip (list 'first #rx"^second$") #rx"^$")
