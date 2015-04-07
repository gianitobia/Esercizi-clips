;// AGENT
(defmodule AGENT (import MAIN ?ALL) (export ?ALL))

(deftemplate init-agent (slot done (allowed-values yes no))) ; Ci dice se l'inizializzazione dell'agente è conclusa

(deftemplate K-cell  
	(slot pos-r) 
	(slot pos-c) 
    (slot contains (allowed-values Wall 
								   Person  
								   Empty 
								   Parking 
								   Table 
								   Seat 
								   TrashBasket
                                   RecyclableBasket 
								   DrinkDispenser 
								   FoodDispenser))
)

(deftemplate K-agent
	(slot step)
    (slot time) 
	(slot pos-r) 
	(slot pos-c) 
	(slot direction) 
	(slot l-drink)
    (slot l-food)
    (slot l_d_waste)
    (slot l_f_waste)
)

(deftemplate last-perc (slot step))

;Definizone del template per le azioni pieanificate
(deftemplate planned-action
	(slot step)
	(slot action (allowed-values Forward Turnright Turnleft Wait 
                        LoadDrink LoadFood DeliveryFood DeliveryDrink 
                        CleanTable EmptyFood Release CheckFinish Inform)
	)		;azioni da far effettuare al robot
	(slot pos_r)		;riga da dove viene effettuata l'azione 
	(slot pos_c) 		;colonna da dove si effettua l'azione
	(slot param3)		;possibile terzo parametro da usare per le quantitá
)

;definizione del template per i goal a cui bisogna arrivare
;possiamo definire dei goal a vari livelli di astrazione
;piu' il valore e' alto piu' l'azione e' specifica
(deftemplate planned-goal
	;(slot level)
	;(slot ordine)		;0 -> N; successione di passi ad uno stesso livello di astrazione
	;(slot action)		;tipo di azione richiesta dal goal
	(slot pos_r)		;riga della posizione finale del robot
	(slot pos_c) 		;colonna della posione finale del robot
)

;beginagent1 inizializza l'ambiente e quindi la mappa conosciuta dall'agent
(defrule beginagent1 (declare (salience 11))
    (status (step 0))
    (not (exec (step 0)))
	(not (init-agent (done yes)))
    (prior-cell (pos-r ?r) (pos-c ?c) (contains ?x)) 
	=>
    (assert (K-cell (pos-r ?r) (pos-c ?c) (contains ?x)))
)

;beginagent2 inizializza la posizione dell'agente iniziale
(defrule beginagent2 (declare (salience 11))
    (status (step 0))
    (not (exec (step 0)))
	(not (init-agent (done yes)))
    (initial_agentposition (pos-r ?r) (pos-c ?c) (direction ?d))
	=> 
    (assert (K-agent (step 0) (time 0) (pos-r ?r) (pos-c ?c) (direction ?d)
                              (l-drink 0) (l-food 0) (l_d_waste no) (l_f_waste no))
	)
	; la percezione precedente alla prima "non esiste" (è a step -1)
	(assert (last-perc (step -1)))
	(assert (init-agent (done yes)))						  
)

;inserire qui richiamo alla pianificazione

;regola per inizare la pianificazione
(defrule ask-plan (declare (salience 4))
	?f <- (status (step ?i) (time ?t))
	(K-agent (pos-r ?r) (pos-c ?c))
	(not (planned-action (step ?st))); Non ci sono azioni da mandare in esecuzione
	=>
    (modify ?f (result no))
    (assert (something-to-plan))
    (assert (printGUI (time ?t) (step ?i) (source "AGENT") (verbosity 2) (text  "Starting to plan: (%p1, %p2) --> (%p3, %p4)") (param1 ?r) (param2 ?c) (param3 3) (param4 9)))      
    (focus PLANNER)
)

; Esegue una pianificazione ed esecuzione del goal
;(defrule start-planning (declare (salience 3))
;    (status (step ?i) (time ?t))
;    (K-agent (pos-r ?r) (pos-c ?c))
;    (planned-goal (pos_r ?goal-r) (pos_c ?goal-c))
; 	=> 
;	(printout t crlf " == AGENT ==" crlf) (printout t "Starting to plan (" ?r ", "?c ") --> (" ?goal-r ", "?goal-c ")" crlf crlf)
;    (assert (printGUI (time ?t) (step ?i) (source "AGENT") (verbosity 2) (text  "Starting to plan: (%p1, %p2) --> (%p3, %p4)") (param1 ?r) (param2 ?c) (param3 ?goal-r) (param4 ?goal-c)))      
;    (assert (something-to-plan)) ; Avvisa che A star ha qualcosa da fare
;    (focus PLANNER)
;)

; Decodifica una azione data dal piano (planned-action) in forma di exec per l'ENV
; Decodifica una azione data dal piano (planned-action) in forma di exec per l'ENV
(defrule decode-plan-execute (declare (salience 2))
	?f <- (status (step ?i))
 	?f2 <- (planned-action (step ?i) (action ?oper) (pos_r ?r) (pos_c ?c)) ; r e c non vengono utilizzati, ma possono essere utili da tenere nel fatto
	=>
    (modify ?f (result no)) ; CHIEDERE AL PROF
    (retract ?f2)
    (assert (exec (step ?i) (action ?oper))) ; andrà in esecuzione effettivamente 
)

; Esegue una singola exec del piano
(defrule exec-act (declare (salience 2))
    (status (step ?i) (time ?t))
    (exec (step ?i) (action ?oper))
 	=>      
	(printout t crlf  "== AGENT ==" crlf) (printout t "Start the execution of the action: " ?oper)
    (assert (printGUI (time ?t) (step ?i) (source "AGENT") (verbosity 1) (text  "Start the execution of the action: %p1") (param1 ?oper)))      
    (focus MAIN)
)

(defrule end-plan-execute (declare (salience 1))
    (not (planned-action (step ?st)))
    (status (step ?i) (time ?t))    
    ?f <- (status (result no)) ; QUESTA SERVE PER ESEGUIRE UN SOLO GOAL.
    => 
	(printout t crlf " @@ AGENT @@ " crlf) (printout t "The execution of the plan is completed.")
    (assert (printGUI (time ?t) (step ?i) (source "AGENT") (verbosity 2) (text  "The execution of the plan is completed.")))          
    (modify ?f (result done)) ; ORA CHE VOGLIAMO UN SOLO GOAL.
)

;regola per chiedere quale azioni eseguire - vecchia 
;(defrule ask_act
; 	?f <-   (status (step ?i))
;    =>  
;	(printout t crlf crlf)
;    (printout t "action to be executed at step:" ?i)
;    (printout t crlf crlf)
;    (modify ?f (result no))
;)
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;// 											REGOLE GESTIONE MESSAGGI CON ENV			          					  //
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

;Si e' deciso di informare l'agente 
(defrule inform-ENV-accepted (declare (salience 10))
	?f <- (msg-to-agent (request-time ?t) (step ?i) (sender ?tb) (type order) (drink-order ?nd) (food-order ?nf))
	(not (pulisci-table ?tb))
	(not (planned-action (step ?i)))
	=>
	(assert (exec (step ?i) (action Inform) (param1 ?tb) (param2 ?t) (param3 accepted)))
	(assert (printGUI (time ?t) (step ?i) (source "AGENT") (verbosity 1) (text  "Start the execution of the action: %p1") (param1 Inform-accepted)))
	;Accodare l'ordine
	;Tornare al MAIN
	(retract ?f)
	(focus MAIN)
)

(defrule inform-ENV-delayed (declare (salience 10))
	?f <- (msg-to-agent (request-time ?t) (step ?i) (sender ?tb) (type order) (drink-order ?nd) (food-order ?nf))
	(pulisci-table ?tb)
	(not (planned-action (step ?i)))
	=>
	(assert (exec (step ?i) (action Inform) (param1 ?tb) (param2 ?t) (param3 delayed)))
	(assert (printGUI (time ?t) (step ?i) (source "AGENT") (verbosity 1) (text  "Start the execution of the action: %p1") (param1 Inform-delayed)))
	;Accodare l'ordine
	;Tornare al MAIN
	(retract ?f)
	(focus MAIN)
)

;Regola che blocca il robot mentre sta eseguendo il piano ed invia una inform di ordine accepted 
(defrule inform-ENV-accepted-busy (declare (salience 10))
	?f <- (msg-to-agent (request-time ?t) (step ?i) (sender ?tb) (type order) (drink-order ?nd) (food-order ?nf))
	(not (pulisci-table ?tb))
	=>
	(assert 
		(inform-temp ?i Inform ?tb ?t accepted)
		(posticipate 1)
	)
	(retract ?f)
	(focus POSTICIPATE)
	;aggiornare il cont delle exec
	;asserire la nuova exect di inform
	;accodare l'ordine
	
)

;Regola che blocca il robot mentre sta eseguendo il piano ed invia una inform di ordine accepted 
(defrule inform-ENV-deleyed-busy (declare (salience 10))
	?f <- (msg-to-agent (request-time ?t) (step ?i) (sender ?tb) (type order) (drink-order ?nd) (food-order ?nf))
	(pulisci-table ?tb)
	=>
	(assert 
		(inform-temp ?i Inform ?tb ?t deleyed)
		(posticipate yes)
	)
	(retract ?f)
	(focus POSTICIPATE)
	;aggiornare il cont delle exec
	;asserire la nuova exect di inform
	;accodare l'ordine	
)

(defrule inform-ENV-exec-inform-busy (declare (salience 11))
	?f1 <- (inform-temp ?i Inform ?tb ?t ?type)
	?f2 <- (posticipate-exec)
	=>
	(assert (exec (step ?i) (action Inform) (param1 ?tb) (param2 ?t) (param3 ?type)))
	(retract ?f1 ?f2)
    (assert (printGUI (time ?t) (step ?i) (source "AGENT") (verbosity 1) (text  "Start the execution of the action: %p1") (param1 Inform)))      
    (focus MAIN)
)

;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;// 								REGOLE PER INTERPRETARE LE PERCEZIONI VISIVE (N, S, E, O)          					  //
;///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

; Le percezioni modificano le K-cell (agente orientato west)
(defrule k-percept-west (declare (salience 20))
	(status (step ?s))
	?ka <- (K-agent) ; recupera il K-agent
	?fs <- (last-perc (step ?old-s))
	(test (> ?s ?old-s))
	(perc-vision (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction west) 
	(perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
	(perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
	(perc7 ?x7) (perc8 ?x8) (perc9 ?x9))
	?f1 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)))
	?f2 <- (K-cell (pos-r ?r)   (pos-c =(- ?c 1)))
	?f3 <- (K-cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)))
	?f4 <- (K-cell (pos-r =(- ?r 1)) (pos-c ?c))
	?f5 <- (K-cell (pos-r ?r)   (pos-c ?c) )
	?f6 <- (K-cell (pos-r =(+ ?r 1)) (pos-c ?c) )
	?f7 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1))) 
	?f8 <- (K-cell (pos-r ?r)   (pos-c =(+ ?c 1)))  
	?f9 <- (K-cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)))
	=> 
	(modify ?ka (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction west)) ; Modifica il K-agent
	(modify ?f1 (contains ?x1))
	(modify ?f2 (contains ?x2))
	(modify ?f3 (contains ?x3))
	(modify ?f4 (contains ?x4))
	(modify ?f5 (contains ?x5))
	(modify ?f6 (contains ?x6))
	(modify ?f7 (contains ?x7))
	(modify ?f8 (contains ?x8))
	(modify ?f9 (contains ?x9))
	(modify ?fs (step ?s))
)

; Le percezioni modificano le K-cell (agente orientato east)
(defrule k-percept-east	(declare (salience 20))
	(status (step ?s))
	?ka <- (K-agent)
	?fs <- (last-perc (step ?old-s))
	(test (> ?s ?old-s))
	(perc-vision (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction east) 
	(perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
	(perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
	(perc7 ?x7) (perc8 ?x8) (perc9 ?x9))
	?f1 <- (K-cell (pos-r ?r)   (pos-c =(+ ?c 1)))
	?f2 <- (K-cell (pos-r ?r)   (pos-c =(+ ?c 1)))
	?f3 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)))
	?f4 <- (K-cell (pos-r =(+ ?r 1)) (pos-c ?c))
	?f5 <- (K-cell (pos-r ?r)   (pos-c ?c))
	?f6 <- (K-cell (pos-r =(- ?r 1)) (pos-c ?c))
	?f7 <- (K-cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1))) 
	?f8 <- (K-cell (pos-r ?r)   (pos-c =(- ?c 1)))  
	?f9 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)))
	=> 
	(modify ?ka (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction east)) ; Modifica il K-agent       
	(modify ?f1 (contains ?x1))
	(modify ?f2 (contains ?x2))
	(modify ?f3 (contains ?x3))
	(modify ?f4 (contains ?x4))
	(modify ?f5 (contains ?x5))
	(modify ?f6 (contains ?x6))
	(modify ?f7 (contains ?x7))
	(modify ?f8 (contains ?x8))
	(modify ?f9 (contains ?x9))
	(modify ?fs (step ?s))
)
 
; Le percezioni modificano le K-cell (agente orientato south)
(defrule k-percept-south	(declare (salience 20))
	(status (step ?s))
	?ka <- (K-agent)
	?fs <- (last-perc (step ?old-s))
	(test (> ?s ?old-s))
	(perc-vision (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction south) 
	(perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
	(perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
	(perc7 ?x7) (perc8 ?x8) (perc9 ?x9))
	?f1 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)))
	?f2 <- (K-cell (pos-r =(- ?r 1)) (pos-c ?c))
	?f3 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)))
	?f4 <- (K-cell (pos-r ?r)   (pos-c =(+ ?c 1)))
	?f5 <- (K-cell (pos-r ?r)   (pos-c ?c))
	?f6 <- (K-cell (pos-r ?r)   (pos-c =(- ?c 1)))
	?f7 <- (K-cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)))
	?f8 <- (K-cell (pos-r =(+ ?r 1)) (pos-c ?c))
	?f9 <- (K-cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)))
	=> 
	(modify ?ka (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction south)) ; Modifica il K-agent        
	(modify ?f1 (contains ?x1))
	(modify ?f2 (contains ?x2))
	(modify ?f3 (contains ?x3))
	(modify ?f4 (contains ?x4))
	(modify ?f5 (contains ?x5))
	(modify ?f6 (contains ?x6))
	(modify ?f7 (contains ?x7))
	(modify ?f8 (contains ?x8))
	(modify ?f9 (contains ?x9))
	(modify ?fs (step ?s))
)

; Le percezioni modificano le K-cell (agente orientato north)
(defrule k-percept-north	(declare (salience 20))
	(status (step ?s))
	?ka <- (K-agent)
	?fs <- (last-perc (step ?old-s))
	(test (> ?s ?old-s))
	(perc-vision (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction north) 
	(perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
	(perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
	(perc7 ?x7) (perc8 ?x8) (perc9 ?x9))
	?f1 <- (K-cell (pos-r =(+ ?r 1))    (pos-c =(- ?c 1)))
	?f2 <- (K-cell (pos-r =(+ ?r 1)) (pos-c ?c))
	?f3 <- (K-cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)))
	?f4 <- (K-cell (pos-r ?r)       (pos-c =(- ?c 1)))
	?f5 <- (K-cell (pos-r ?r)       (pos-c ?c))
	?f6 <- (K-cell (pos-r ?r)       (pos-c =(+ ?c 1)))
	?f7 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)))
	?f8 <- (K-cell (pos-r =(- ?r 1)) (pos-c ?c))
	?f9 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)))
	=> 
	(modify ?ka (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction north)) ; Modifica il K-agent
	(modify ?f1 (contains ?x1))
	(modify ?f2 (contains ?x2))
	(modify ?f3 (contains ?x3))
	(modify ?f4 (contains ?x4))
	(modify ?f5 (contains ?x5))
	(modify ?f6 (contains ?x6))
	(modify ?f7 (contains ?x7))
	(modify ?f8 (contains ?x8))
	(modify ?f9 (contains ?x9))
	(modify ?fs (step ?s))
)
 
(defmodule POSTICIPATE (import AGENT ?ALL) (export ?ALL))

(defrule posticipate-exec-start (declare (salience 20))
	?f <- (posticipate ?passi)
	(status (step ?st))
	=>
	(assert 
		(step ?passi)
		(start ?st)
		(back 1)
	)
	(retract ?f)
)

(defrule posticipate-exec-begin (declare (salience 10))
	(planned-action (step ?i))
	?f <- (start ?i)
	(back 1)
	=>
	(assert (start =(+ ?i 1)))
	(retract ?f)
)

(defrule posticipate-exec (declare (salience 9))
	(start ?i)
	(step ?passi)
	?f1 <- (back ?b)
	?f2 <- (planned-action (step =(- ?i ?b)))
	=>
	(assert (back =(+ ?b 1)))
	(retract ?f1)
	(modify ?f2 (step =(+ (- ?i ?b) ?passi)))
)


(defrule posticipate-exec-end (declare (salience 8))
	?f1 <- (start ?st)
	?f2 <- (step ?p)
	?f3 <- (back ?b)
	=>
	(retract ?f1 ?f2 ?f3)
	(assert (posticipate-exec))
	(pop-focus)
)