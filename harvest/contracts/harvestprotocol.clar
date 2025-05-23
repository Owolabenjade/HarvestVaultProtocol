;; HarvestVault - Advanced Yield Farming Protocol
;; Stake tokens, earn rewards, compound yields with time-weighted bonuses

;; Constants
(define-constant contract-owner tx-sender)
(define-constant reward-token-symbol "HARVEST")
(define-constant base-reward-rate u100) ;; 1% per 144 blocks (~1 day)
(define-constant blocks-per-day u144)
(define-constant max-multiplier u300) ;; 3x max bonus
(define-constant min-stake-amount u1000000) ;; 1 token with 6 decimals

;; Error constants
(define-constant err-owner-only (err u100))
(define-constant err-insufficient-balance (err u101))
(define-constant err-pool-not-found (err u102))
(define-constant err-already-staked (err u103))
(define-constant err-not-staked (err u104))
(define-constant err-insufficient-stake (err u105))
(define-constant err-pool-paused (err u106))
(define-constant err-invalid-amount (err u107))

;; Data variables
(define-data-var total-pools uint u0)
(define-data-var protocol-paused bool false)
(define-data-var emergency-withdraw-enabled bool false)

;; Define reward token
(define-fungible-token harvest-token)

;; Simplified token handling - users transfer tokens before calling stake
(define-private (record-stake-deposit (pool-id uint) (amount uint))
    (let
        (
            (pool (unwrap! (map-get? staking-pools pool-id) err-pool-not-found))
        )
        ;; Update pool totals
        (map-set staking-pools pool-id (merge pool {
            total-staked: (+ (get total-staked pool) amount)
        }))
        (ok true)
    )
)

;; Data maps
(define-map staking-pools
    uint
    {
        name: (string-ascii 32),
        stake-token: principal,
        total-staked: uint,
        reward-per-block: uint,
        min-stake-period: uint,
        active: bool,
        created-at: uint
    }
)

(define-map user-stakes
    {pool-id: uint, user: principal}
    {
        amount: uint,
        staked-at: uint,
        last-claim: uint,
        total-claimed: uint
    }
)

(define-map pool-stats
    uint
    {
        total-participants: uint,
        total-rewards-distributed: uint,
        apy: uint
    }
)

;; Pool management functions
(define-public (create-pool 
    (name (string-ascii 32))
    (stake-token principal)
    (reward-per-block uint)
    (min-stake-period uint))
    (let
        (
            (pool-id (+ (var-get total-pools) u1))
        )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (asserts! (> reward-per-block u0) err-invalid-amount)
        (map-set staking-pools pool-id {
            name: name,
            stake-token: stake-token,
            total-staked: u0,
            reward-per-block: reward-per-block,
            min-stake-period: min-stake-period,
            active: true,
            created-at: block-height
        })
        (map-set pool-stats pool-id {
            total-participants: u0,
            total-rewards-distributed: u0,
            apy: u0
        })
        (var-set total-pools pool-id)
        (ok pool-id)
    )
)

(define-public (stake-tokens (pool-id uint) (amount uint))
    (let
        (
            (pool (unwrap! (map-get? staking-pools pool-id) err-pool-not-found))
            (existing-stake (map-get? user-stakes {pool-id: pool-id, user: tx-sender}))
        )
        (asserts! (not (var-get protocol-paused)) err-pool-paused)
        (asserts! (get active pool) err-pool-paused)
        (asserts! (>= amount min-stake-amount) err-insufficient-stake)
        (asserts! (is-none existing-stake) err-already-staked)
        
        ;; Record stake (user must transfer tokens separately)
        (map-set user-stakes {pool-id: pool-id, user: tx-sender} {
            amount: amount,
            staked-at: block-height,
            last-claim: block-height,
            total-claimed: u0
        })
        
        ;; Update pool totals
        (try! (record-stake-deposit pool-id amount))
        (ok true)
    )
)

(define-public (claim-rewards (pool-id uint))
    (let
        (
            (pool (unwrap! (map-get? staking-pools pool-id) err-pool-not-found))
            (stake (unwrap! (map-get? user-stakes {pool-id: pool-id, user: tx-sender}) err-not-staked))
            (blocks-staked (- block-height (get last-claim stake)))
            (base-reward (/ (* (get amount stake) (get reward-per-block pool) blocks-staked) u10000))
            (time-bonus (calculate-time-bonus (get staked-at stake)))
            (final-reward (/ (* base-reward time-bonus) u100))
        )
        (asserts! (not (var-get protocol-paused)) err-pool-paused)
        (asserts! (> blocks-staked u0) err-invalid-amount)
        
        ;; Mint reward tokens
        (try! (ft-mint? harvest-token final-reward tx-sender))
        
        ;; Update stake record
        (map-set user-stakes {pool-id: pool-id, user: tx-sender} (merge stake {
            last-claim: block-height,
            total-claimed: (+ (get total-claimed stake) final-reward)
        }))
        
        (ok final-reward)
    )
)

(define-public (unstake-tokens (pool-id uint))
    (let
        (
            (pool (unwrap! (map-get? staking-pools pool-id) err-pool-not-found))
            (stake (unwrap! (map-get? user-stakes {pool-id: pool-id, user: tx-sender}) err-not-staked))
            (stake-duration (- block-height (get staked-at stake)))
            (amount (get amount stake))
        )
        (asserts! (or 
            (var-get emergency-withdraw-enabled)
            (>= stake-duration (get min-stake-period pool))) err-insufficient-stake)
        
        ;; Claim pending rewards first
        (try! (claim-rewards pool-id))
        
        ;; Remove stake record
        (map-delete user-stakes {pool-id: pool-id, user: tx-sender})
        
        ;; Update pool totals
        (map-set staking-pools pool-id (merge pool {
            total-staked: (- (get total-staked pool) amount)
        }))
        
        (ok amount)
    )
)

(define-public (compound-rewards (pool-id uint))
    (let
        (
            (rewards (try! (claim-rewards pool-id)))
            (current-stake (unwrap! (map-get? user-stakes {pool-id: pool-id, user: tx-sender}) err-not-staked))
        )
        ;; Auto-compound by increasing stake amount
        (map-set user-stakes {pool-id: pool-id, user: tx-sender} (merge current-stake {
            amount: (+ (get amount current-stake) rewards)
        }))
        (ok rewards)
    )
)

;; Helper functions
(define-private (calculate-time-bonus (staked-at uint))
    (let
        (
            (days-staked (/ (- block-height staked-at) blocks-per-day))
        )
        (if (<= days-staked u7) u100        ;; 1x for first week
        (if (<= days-staked u30) u150       ;; 1.5x for first month  
        (if (<= days-staked u90) u200       ;; 2x for first quarter
        max-multiplier)))                   ;; 3x for longer
    )
)

;; Read-only functions
(define-read-only (get-pool-info (pool-id uint))
    (map-get? staking-pools pool-id)
)

(define-read-only (get-user-stake (pool-id uint) (user principal))
    (map-get? user-stakes {pool-id: pool-id, user: user})
)

(define-read-only (calculate-pending-rewards (pool-id uint) (user principal))
    (match (map-get? user-stakes {pool-id: pool-id, user: user})
        stake (let
            (
                (pool (unwrap! (map-get? staking-pools pool-id) (err u0)))
                (blocks-staked (- block-height (get last-claim stake)))
                (base-reward (/ (* (get amount stake) (get reward-per-block pool) blocks-staked) u10000))
                (time-bonus (calculate-time-bonus (get staked-at stake)))
            )
            (ok (/ (* base-reward time-bonus) u100)))
        (ok u0))
)

(define-read-only (get-pool-stats (pool-id uint))
    (map-get? pool-stats pool-id)
)

;; Admin functions
(define-public (toggle-pool (pool-id uint))
    (let
        (
            (pool (unwrap! (map-get? staking-pools pool-id) err-pool-not-found))
        )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set staking-pools pool-id (merge pool {
            active: (not (get active pool))
        }))
        (ok true)
    )
)

(define-public (emergency-pause)
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (var-set protocol-paused true)
        (var-set emergency-withdraw-enabled true)
        (ok true)
    )
)