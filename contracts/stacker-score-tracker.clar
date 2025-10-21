;; ----------------------------------------------------------------------
;; Contract: stacker-score-tracker.clar
;; Description: Track stacking cycles per user and assign scores.
;; Enhanced with admin tools and tracking utilities.
;; ----------------------------------------------------------------------

;; --- Error Constants ---
(define-constant ERR-NOT-ADMIN (err u100))
(define-constant ERR-CYCLE-ALREADY-LOGGED (err u101))
(define-constant ERR-NOT-STACKED (err u102))
(define-constant ERR-CYCLE-NOT_FOUND (err u103))

;; --- Owner of the contract ---
(define-data-var contract-owner principal tx-sender)

;; --- Tracks if a user has stacked in a cycle ---
;; Key: { cycle, user } => bool
(define-map stacked-cycles { cycle: uint, user: principal } bool)

;; --- Tracks the number of cycles a user has stacked ---
;; Key: user => score (uint)
(define-map stacker-scores principal uint)

;; ----------------------------------------------------------------------
;; PUBLIC FUNCTION: Verify that a user stacked in a cycle.
;; ----------------------------------------------------------------------
(define-public (verify-stacker (user principal) (cycle uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-ADMIN)
    (asserts! (is-none (map-get? stacked-cycles { cycle: cycle, user: user })) ERR-CYCLE-ALREADY-LOGGED)

    (map-set stacked-cycles { cycle: cycle, user: user } true)

    (let ((current-score (default-to u0 (map-get? stacker-scores user))))
      (map-set stacker-scores user (+ current-score u1))
    )

    (print { action: "verify-stacker", user: user, cycle: cycle })
    (ok true)
  )
)

;; ----------------------------------------------------------------------
;; PUBLIC FUNCTION: Transfer contract ownership.
;; ----------------------------------------------------------------------
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-ADMIN)
    (var-set contract-owner new-admin)
    (print { action: "set-admin", new-admin: new-admin })
    (ok true)
  )
)

;; ----------------------------------------------------------------------
;; PUBLIC FUNCTION: Reset a user's stacking score.
;; ----------------------------------------------------------------------
(define-public (reset-user-score (user principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-ADMIN)
    (map-set stacker-scores user u0)
    (print { action: "reset-score", user: user })
    (ok true)
  )
)

;; ----------------------------------------------------------------------
;; PUBLIC FUNCTION: Remove a cycle entry (admin-only).
;; Decreases score if found.
;; ----------------------------------------------------------------------
(define-public (remove-cycle-log (user principal) (cycle uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-ADMIN)

    (asserts! (is-eq (default-to false (map-get? stacked-cycles { cycle: cycle, user: user })) true) ERR-CYCLE-NOT_FOUND)

    ;; Remove entry
    (map-delete stacked-cycles { cycle: cycle, user: user })

    ;; Decrease score by 1 (but not below zero)
    (let ((current-score (default-to u0 (map-get? stacker-scores user))))
      (map-set stacker-scores user (if (> current-score u0) (- current-score u1) u0))
    )

    (print { action: "remove-cycle", user: user, cycle: cycle })
    (ok true)
  )
)

;; ----------------------------------------------------------------------
;; READ-ONLY: Get score for a given user.
;; ----------------------------------------------------------------------
(define-read-only (get-stacker-score (user principal))
  (ok (default-to u0 (map-get? stacker-scores user)))
)

;; ----------------------------------------------------------------------
;; READ-ONLY: Check if user stacked in a specific cycle.
;; ----------------------------------------------------------------------
(define-read-only (did-stack (user principal) (cycle uint))
  (ok (default-to false (map-get? stacked-cycles { cycle: cycle, user: user })))
)

;; ----------------------------------------------------------------------
;; READ-ONLY: Get contract owner (admin).
;; ----------------------------------------------------------------------
(define-read-only (get-owner)
  (ok (var-get contract-owner))
)

;; ----------------------------------------------------------------------
;; READ-ONLY: Get total number of cycles a user has stacked.
;; ----------------------------------------------------------------------
(define-read-only (get-user-cycle-count (user principal))
  (ok (default-to u0 (map-get? stacker-scores user)))
)

;; ----------------------------------------------------------------------
;; READ-ONLY: Get highest stacking score (basic version).
;; Useful for off-chain leaderboard tracking.
;; ----------------------------------------------------------------------
(define-read-only (get-top-stacker-score (users (list 100 principal)))
  (ok 
    (fold find-max-score users u0)
  )
)

(define-private (find-max-score (user principal) (max-score uint))
  (let ((score (default-to u0 (map-get? stacker-scores user))))
    (if (> score max-score)
      score
      max-score
    )
  )
)


;; ----------------------------------------------------------------------
;; READ-ONLY: Total stacked cycles across all users (basic placeholder).
;; Needs to be implemented using event indexer off-chain or log index.
;; ----------------------------------------------------------------------
(define-read-only (get-total-stacked-cycles)
  ;; Placeholder: tracking total cycles on-chain would require more storage.
  (ok u0)
)
