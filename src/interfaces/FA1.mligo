(**
   This file implements the TZIP-5 protocol (a.k.a FA1)
   copyright Wulfman Corporation 2022
*)

module Ledger = struct
   type owner  = address
   type amount_ = nat
   type t = (owner, amount_) big_map
end

module Storage = struct
   type t = {
      ledger : Ledger.t;
      totalSupply : nat;
   }
end


type storage = Storage.t


(** transfer entrypoint *)
type transfer = address * (address * nat)
(** getBalance entrypoint *)
type getBalance = address * nat contract
(** getTotalSupply entrypoint *)
type getTotalSupply = unit * nat contract
