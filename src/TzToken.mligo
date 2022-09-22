(* Tezos FA abstraction layer
	copyright WULFMAN corporation 2022
*)

(*
	On tezos, tokens can be instanciate with different contract specification.
	This library aim to facilitate communication with crypto-monnaie with different specification.
*)

#import "interfaces/FA1.2.mligo" "FA1"
#import "interfaces/FA2.mligo" "FA2"


type t =
	XTZ of unit (* For handling native Tezos token *)
|	FA1 of address (* For FA1.2 contract *)
|	FA2 of (address * nat) (* For FA2 contract *)

let transfer (contract: t) (sender: address) (receiver: address) (amount:nat) =
	match contract with
		XTZ ->
		(match (Tezos.get_contract_opt receiver : unit contract option) with
			Some contract ->
				if Tezos.get_sender () = sender then
					Some (Tezos.transaction () (amount * 1mutez) contract)
				else None
		| 	None -> None
		)
	|	FA1 (address) ->
		(match (Tezos.get_entrypoint_opt "%transfer" address : FA1.transfer contract option) with
			Some contract ->
				Some (Tezos.transaction (sender,(receiver,amount)) 0tez contract)
		| 	None -> None
		)
	|	FA2 (address,id) ->
		(match (Tezos.get_entrypoint_opt "%transfer" address : FA2.transfer contract option) with
			Some contract ->
				Some (Tezos.transaction [{from_=sender;tx=[{to_=receiver;token_id=id;amount=amount}]}] 0tez contract)
		| 	None -> None
		)
