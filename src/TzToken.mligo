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
		let amount = amount * 1mutez in
		(* Handling The native token is a special case which requires special logic *)
		let () = if (sender <> Tezos.get_self_address ()) then (
			(* Case 1:  The sender is not the contract
				check the quantity is correct and do a transaction *)
			if (Tezos.get_amount () < amount) then
				failwith "Not enough token transfered to contract"
		) else (
			(* Case 2: The sender is the contract.
				Check that there is enough balance.
				 -> This is done by the protocol *)
			()
		) in
		(match (Tezos.get_contract_opt receiver : unit contract option) with
				Some contract ->
					if Tezos.get_sender () = sender then
						Some (Tezos.transaction () amount contract)
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

let transfer_exn (contract: t) (sender: address) (receiver: address) (amount:nat) =
	Option.unopt_with_error
		(transfer contract sender receiver amount)
		"Contract not found"

