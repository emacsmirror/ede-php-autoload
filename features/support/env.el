(require 'package)
(require 'f)
(require 'cl-lib)
(require 'ert)
(require 'eieio)

(defvar ede-php-autoload-support-path
  (f-dirname load-file-name))

(defvar ede-php-autoload-features-path
  (f-parent ede-php-autoload-support-path))

(defvar ede-php-autoload-root-path
  (f-parent ede-php-autoload-features-path))

(defvar ede-php-autoload-test-projects-root-path
  (f-join ede-php-autoload-root-path "test/projects"))

(defun ede-php-autoload-test-get-project-file-path (file project)
  "Return the absolute path for FILE relative to PROJECT."
  (f-join ede-php-autoload-test-projects-root-path project file))

(defun ede-php-autoload-test-get-current-project-name ()
  "Return the test project currently visited."
  (car
   (f-split
    (f-relative
     (or (buffer-file-name) default-directory)
     ede-php-autoload-test-projects-root-path))))

(defun ede-php-autoload-test-set-composer (composer-file-name)
  "Set the composer file of the project with-composer.

COMPOSER-FILE-NAME is either default or new."
  (let* ((project-root (f-join ede-php-autoload-test-projects-root-path "with-composer"))
         (destination (f-join project-root "composer.json")))

    (when (f-exists? destination)
      (f-delete destination))

    (f-copy (f-join project-root (format "%s-composer.json" composer-file-name))
            destination)))

(add-to-list 'load-path ede-php-autoload-root-path)

(package-generate-autoloads "ede-php-autoload" ede-php-autoload-root-path)
(load (f-join ede-php-autoload-root-path "ede-php-autoload-autoloads.el"))

(Setup
 (global-ede-mode 1))

(Before
 (setq ede-projects nil)

 (ede-php-autoload-test-set-composer "default")

 ;; Define projects
 ;; The composer projet is auto-detected
 (ede-php-autoload-project "Without composer"
                           :file (f-join ede-php-autoload-test-projects-root-path
                                         "without-composer/project")
                           :class-autoloads '(:psr-0 (("Psr0Ns" . "src/Psr0Ns")
                                                      ("Psr0Split\\Ns1" . "src/Psr0Split/Ns1")
                                                      ("Psr0Split\\Ns2" . "src/Psr0Split/Ns2")
                                                      ("" . "src/Fallback/Psr0"))
                                                     :psr-4 (("Psr4Ns" . "src/Psr4Ns")
                                                             ("MultiDirNs" . ("src/MultiDirNs1" "src/MultiDirNs2"))
                                                             ("Psr4Split\\Ns1" . "src/Psr4Split/Ns1")
                                                             ("Psr4Split\\Ns2" . "src/Psr4Split/Ns2")
                                                             ("NonExisting" . "src/NonExisting")
                                                             ("" . "src/Fallback/Psr4"))
                                                     :class-map ((ClassMapNs\\MyClass . "src/ClassMapNs/MyClass.php")))
                           :include-path '(".")
                           :system-include-path '("/usr/share/php")))
