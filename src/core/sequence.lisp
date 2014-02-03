(in-package :cl-user)
(defpackage cl21.core.sequence
  (:use :cl)
  (:shadow :push
           :pushnew
           :pop)
  (:import-from :split-sequence
                :split-sequence
                :split-sequence-if)
  (:import-from :alexandria
                :length=)
  (:export :split-sequence
           :split-sequence-if

           :sequence
           :fill
           :copy-seq
           :make-sequence
           :subseq
           :reduce
           :count
           :count-if
           :length ;; TODO: Write as a generic function
           :reverse
           :nreverse
           :sort
           :stable-sort

           :find
           :find-if
           :position
           :position-if

           :search
           :mismatch
           :replace
           :concatenate
           :elt
           :merge

           :map
           :map-into

           :remove
           :remove-if
           :remove-if-not
           :filter
           :remove-duplicates

           :delete
           :delete-if
           :delete-if-not
           :delete-duplicates

           :substitute
           :substitute-if
           :nsubstitute
           :nsubstitute-if

           :push
           :pushnew
           :pop

           ;; Alexandria
           :length=

           :take
           :drop
           :take-while
           :drop-while
           :partition-by
           :subdivide
           :concat))
(in-package :cl21.core.sequence)

(setf (symbol-function 'filter) (symbol-function 'remove-if-not))

(defmacro push (value place)
  `(typecase ,place
     (vector (vector-push-extend ,value ,place))
     (T (cl:push ,value ,place))))

(defmacro pushnew (value place &rest keys)
  `(typecase ,place
     (vector (or (find ,value ,place ,@keys)
                 (vector-push-extend ,value ,place)))
     (T (cl:pushnew ,value ,place ,@keys))))

(defmacro pop (place)
  `(typecase ,place
     (vector (cl:vector-pop ,place))
     (T (cl:pop ,place))))

(defun take (n sequence)
  "Take the first `n` elements from `sequence`."
  (subseq sequence 0 n))

(defun drop (n sequence)
  "Drop the first `n` elements from `sequence`."
  (subseq sequence n))

(defun take-while (pred sequence)
  (let ((pos (position-if (complement pred) sequence)))
    (subseq sequence 0 (or pos 0))))

(defun drop-while (pred sequence)
  (let ((pos (position-if (complement pred) sequence)))
    (if pos
        (subseq sequence pos)
        (subseq sequence 0 0))))

(defun partition-by (pred sequence)
  "Given a predicate PRED, partition SEQUENCE into two sublists, the first
of which has elements that satisfy PRED, the second which do not."
  (let ((yes nil)
        (no nil))
    (map nil
         #'(lambda (x)
             (if (funcall pred x)
                 (push x yes)
                 (push x no)))
         sequence)
    (values yes no)))

(defun subdivide (sequence chunk-size)
  "Split `sequence` into subsequences of size `chunk-size`."
  (check-type sequence sequence)
  (check-type chunk-size (integer 1))

  (etypecase sequence
    ; Since lists have O(N) access time, we iterate through manually,
    ; collecting each chunk as we pass through it. Using SUBSEQ would
    ; be O(N^2).
    (list (loop :while sequence
                :collect
                (loop :repeat chunk-size
                      :while sequence
                      :collect (pop sequence))))

    ; For other sequences like strings or arrays, we can simply chunk
    ; by repeated SUBSEQs.
    (sequence (loop :with len := (length sequence)
                    :for i :below len :by chunk-size
                    :collect (subseq sequence i (min len (+ chunk-size i)))))))

(defun concat (sequence &rest more-sequences)
  (let ((type (type-of sequence)))
    (apply #'concatenate
           (if (listp type)
               (car type)
               type)
           sequence
           more-sequences)))
