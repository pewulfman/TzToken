(**
   This file implements the TZIP-7 protocol (a.k.a FA1.2)
   copyright Wulfman Corporation 2022
*)

module Allowance = struct
   type spender        = address
   type allowed_amount = nat
	type t = (spender, allowed_amount) map
end

module Ledger = struct
   type owner      = address
   type spender    = address
   type amount_    = nat
   type t = (owner, amount_ * Allowance.t) big_map
end

module TokenMetadata = struct
   type data = {token_id:nat;token_info:(string,bytes)map}
   type t = data
end

module Storage = struct
   type t = {
      ledger : Ledger.t;
      token_metadata : TokenMetadata.t;
      totalSupply : nat;
   }
end


type storage = Storage.t


(** transfer entrypoint *)
type transfer = address * (address * nat)
(** approve *)
type approve = (address * nat)
(** getBalance entrypoint *)
type getAllowance = (address * address) * nat contract
(** getBalance entrypoint *)
type getBalance = address * nat contract
(** getTotalSupply entrypoint *)
type getTotalSupply = unit * nat contract
