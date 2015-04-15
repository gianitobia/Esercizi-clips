(defmodule ORDER_MANAGEMENT (import PLANNER ?ALL) (export ?ALL))

;regola che converte tutti gli ordini di checkFinish in una sequenza di MacroAction
(defrule rec_finish_lookfor (declare (salience 12))
	?f <- (createMacro)
	?o <- (pulisci-table (table-id ?tb))
	=>
	(assert (lookfor TB) (lookfor RB))
	(focus MIN_DISTANCE)
)

(defrule rec_message_finish (declare (salience 14))
	?f <- (createMacro)
	?o <- (pulisci-table (table-id ?tb))
	?b1 <- (best-TB ?rtr ?ctr)				;da modificare quando ci saranno piu di trash basket
	?b2 <- (best-RB ?rr ?cr) 					;da modificare quando ci saranno piu di un recyclable basket
	(Table (table-id ?tb) (pos-r ?rt) (pos-c ?ct))
	=>
	(retract ?f ?o ?b1 ?b2)
	(assert 
		(MacroAction (macrostep 1) (oper Move) (param1 ?rt) (param2 ?ct))
		(MacroAction (macrostep 2) (oper CheckFinish) (param1 ?rt) (param2 ?ct))
		(macrostep 1)
	)
)

;regola che converte tutti gli ordini di Order con numero di porzione di cibi pari a 0 in una sequenza di MacroAction
(defrule rec_order_lookfor1 (declare (salience 12))
	?f <- (createMacro)
	?o <- (coda-ordini (sender ?tb) (tipo ?type) (drink ?nd) (food ?nf))
	(test (= ?nf 0))
	=>
	(assert (lookfor DD))
	(focus MIN_DISTANCE)
)

(defrule rec_order_createMacro1 (declare (salience 12))
	?f <- (createMacro)
	?o <- (coda-ordini (sender ?tb) (tipo ?type) (drink ?nd) (food ?nf))
	(test (= ?nf 0))
	?b <- (best_DD ?rd ?cd) 		;da modificare quando ci saranno piu di un drink dispenser
	(Table (table-id ?tb) (pos-r ?rt) (pos-c ?ct))
	=>
	(retract ?f ?o ?b)
	(assert 
		(MacroAction (macrostep 1) (oper Move) (param1 ?rd) (param2 ?cd))
		(MacroAction (macrostep 2) (oper LoadDrink) (param1 ?rd) (param2 ?cd) (param3 ?nd))
		(MacroAction (macrostep 3) (oper Move) (param1 ?rt) (param2 ?ct))
		(MacroAction (macrostep 4) (oper DeliveryDrink) (param1 ?rt) (param2 ?ct) (param3 ?nd))
		(macrostep 1)
	)
)

;regola che converte tutti gli ordini di Order con numero di porzione di bevande pari a 0 in una sequenza di MacroAction
(defrule rec_order_lookfor2 (declare (salience 12))
	?f <- (createMacro)
	?o <- (coda-ordini (sender ?tb) (tipo ?type) (drink ?nd) (food ?nf))
	(test (= ?nd 0))
	=>
	(assert (lookfor FD))
	(focus MIN_DISTANCE)
)

(defrule rec_message_createMacro2 (declare (salience 12))
	?f <- (createMacro)
	?o <- (coda-ordini (sender ?tb) (tipo ?type) (drink ?nd) (food ?nf))
	(test (= ?nd 0))
	?b <- (best_FD ?rf ?cf) 		;da modificare quando ci saranno piu di food dispenser
	(Table (table-id ?tb) (pos-r ?rt) (pos-c ?ct))
	=>
	(retract ?f ?o ?b)
	(assert 
		(MacroAction (macrostep 1) (oper Move) (param1 ?rf) (param2 ?cf))
		(MacroAction (macrostep 2) (oper LoadFood) (param1 ?rf) (param2 ?cf) (param3 ?nf))				
		(MacroAction (macrostep 3) (oper Move) (param1 ?rt) (param2 ?ct))
		(MacroAction (macrostep 4) (oper DeliveryFood) (param1 ?rt) (param2 ?ct) (param3 ?nf))
		(macrostep 1)
	)
)

;regola che converte tutti gli ordini di Order con numero di porzione di cibi e bevande diverso da 0 in una sequenza di MacroAction
(defrule rec_order_lookfor3 (declare (salience 10))
	?f <- (createMacro)
	?o <- (coda-ordini (sender ?tb) (tipo ?type) (drink ?nd) (food ?nf))
	=>
	(assert (lookfor FD) (lookfor DD))
	(focus MIN_DISTANCE)
)

(defrule rec_message_createMacro3 (declare (salience 10))
	?f <- (createMacro)
	?o <- (coda-ordini (sender ?tb) (drink ?nd) (food ?nf))
	?b1 <- (best_FD ?rf ?cf)	
	?b2 <- (best_DD ?rd ?cd) 	
	(Table (table-id ?tb) (pos-r ?rt) (pos-c ?ct))
	=>
	(retract ?f ?o ?b1 ?b2)
	(assert 
		(MacroAction (macrostep 1) (oper Move) (param1 ?rd) (param2 ?cd))
		(MacroAction (macrostep 2) (oper LoadDrink) (param1 ?rd) (param2 ?cd) (param3 ?nd))
		(MacroAction (macrostep 3) (oper Move) (param1 ?rf) (param2 ?cf))
		(MacroAction (macrostep 4) (oper LoadFood) (param1 ?rf) (param2 ?cf) (param3 ?nf))
		(MacroAction (macrostep 5) (oper Move) (param1 ?rt) (param2 ?ct))
		(MacroAction (macrostep 6) (oper DeliveryDrink) (param1 ?rt) (param2 ?ct) (param3 ?nd))
		(MacroAction (macrostep 7) (oper DeliveryFood) (param1 ?rt) (param2 ?ct) (param3 ?nf))
		(macrostep 1)
	)
)


;Da aggiungere le regole per generare piu` macroaction in modo da poter prendere e consegnare piu` bevande e drink