;// _______________________________________________________________________________________________________________________
;// ENV                                                                                                                   
;// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
(defmodule ENV (import MAIN ?ALL))

;// DEFTEMPLATE
;Definizione della cella
(deftemplate cell  
	(slot pos-r) 
	(slot pos-c) 
    (slot contains (allowed-values Wall Person  Empty Parking Table Seat TrashBasket
                                        RecyclableBasket DrinkDispenser FoodDispenser))
)

;Definizione stato agente
(deftemplate agentstatus 
	(slot step)
    (slot time) 
	(slot pos-r) 
	(slot pos-c) 
	(slot direction) 
	(slot l-drink)			;numero di cibi caricati;			Drink + Food <= 4
    (slot l-food)			;numero di bevande caricate;
    (slot l_d_waste)		;true appena carica dei rifiuti da buttare nei riciclabili
    (slot l_f_waste)		;true appena carica dei rifiuti da buttate nel cestino
)

;Defizinizione dello stato di ciascuno tavolo
(deftemplate tablestatus	
	(slot step)
    (slot time)
	(slot table-id)
	(slot clean (allowed-values yes no))		;Value = no => tavolo deve essere pulito
	(slot l-drink)
    (slot l-food)
)

;Definzione del'ordine fatto da un tavolo
(deftemplate orderstatus	;// tiente traccia delle ordinazioni
	(slot step)
    (slot time)				;// tempo corrente
	(slot arrivaltime)		;// momento in cui é arrivata l'ordinazione
	(slot requested-by)		;// tavolo richiedente
	(slot drink-order)
    (slot food-order)
    (slot drink-deliv)
    (slot food-deliv)
    (slot answer (allowed-values pending
								 accepted
								 delayed
								 rejected))		;NON deve mai assumure valore Rejected
)

;Percezione per la pulizia dello stato
(deftemplate cleanstatus
	(slot step)
    (slot time)
	(slot arrivaltime)	
	(slot requested-by)		;// tavolo coinvolto nella richiesta
    (slot source)           ;// agent se agent ha fatto checkfinish positiva, altrimenti il tavolo	
)

;Definizione status di ciascuna persona
(deftemplate personstatus 	;// informazioni sulla posizione delle persone
	(slot step)
    (slot time)
	(slot ident)			;//identificativo della persona
	(slot pos-r)
	(slot pos-c)
	(slot activity)   		;// activity seated se cliente seduto, stand se in piedi, oppure path  		
    (slot move)			
)

;// modella i movimenti delle persone. l'environment deve tenere conto dell'interazione di tanti agenti. Il mondo cambia sia per le azioni del robot, si per le azioni degli operatori. Il modulo environment deve gestire le interazioni.
(deftemplate personmove
	(slot step)
	(slot ident)
	(slot path-id)
)

;Definizione degli eventi che devono essere interpretati dall'agent;
(deftemplate event   		;// gli eventi sono le richieste dei tavoli: ordini e finish
	(slot step)
	(slot type (allowed-values request finish))
	(slot source)
	(slot food)
    (slot drink)
)

;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////// 					REGOLE DI CREAZIONE					/////////////////////////////////////
;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;// DEFRULE
;//imposta il valore iniziale di ciascuna cella 
(defrule creation1	(declare (salience 25))
	(create-map)
    (prior-cell (pos-r ?r) (pos-c ?c) (contains ?x)) 
	=>
    (assert (cell (pos-r ?r) (pos-c ?c) (contains ?x)))
)

(defrule creation2	(declare (salience 24))
	?f1<-	(create-history) 
	=>
   	(load-facts "history.txt")
    (retract ?f1)
)

(defrule creation3	(declare (salience 23))
	(create-initial-setting)
    (Table (table-id ?tb) (pos-r ?r) (pos-c ?c))
	=> 
    (assert (tablestatus (step 0) (time 0) (table-id ?tb) (clean yes) (l-drink 0) (l-food 0)))
)

(defrule creation411
         (declare (salience 22))
         (create-initial-setting)
         (Table (table-id ?tb) (pos-r ?r) (pos-c ?c))
         (cell (pos-r ?rr&:(= ?rr (- ?r 1))) (pos-c ?c) (contains Empty))
=> 
         (assert (serviceTable ?tb (- ?r 1) ?c))
)
(defrule creation412
         (declare (salience 22))
         (create-initial-setting)
         (Table (table-id ?tb) (pos-r ?r) (pos-c ?c))
         (cell (pos-r ?rr&:(= ?rr (+ ?r 1))) (pos-c ?c) (contains Empty))
=> 
         (assert (serviceTable ?tb (+ ?r 1) ?c))
)
(defrule creation413
         (declare (salience 22))
         (create-initial-setting)
         (Table (table-id ?tb) (pos-r ?r) (pos-c ?c))
         (cell (pos-c ?cc&:(= ?cc (- ?c 1))) (pos-r ?r) (contains Empty))
=> 
         (assert (serviceTable ?tb ?r (- ?c 1)))
)
(defrule creation414
         (declare (salience 22))
         (create-initial-setting)
         (Table (table-id ?tb) (pos-r ?r) (pos-c ?c))
         (cell (pos-c ?cc&:(= ?cc (+ ?c 1))) (pos-r ?r) (contains Empty))
=> 
         (assert (serviceTable ?tb ?r (+ ?c 1)))
)
(defrule creation421
         (declare (salience 22))
         (create-initial-setting)
         (TrashBasket (TB-id ?tb) (pos-r ?r) (pos-c ?c))
         (cell (pos-r ?rr&:(= ?rr (- ?r 1))) (pos-c ?c) (contains Empty|Parking))
=> 
         (assert (serviceTB ?tb (- ?r 1) ?c))
)
(defrule creation422
         (declare (salience 22))
         (create-initial-setting)
         (TrashBasket (TB-id ?tb) (pos-r ?r) (pos-c ?c))
         (cell (pos-r ?rr&:(= ?rr (+ ?r 1))) (pos-c ?c) (contains Empty|Parking))
=> 
         (assert (serviceTB ?tb (+ ?r 1) ?c))
)
(defrule creation423
         (declare (salience 22))
         (create-initial-setting)
         (TrashBasket (TB-id ?tb) (pos-r ?r) (pos-c ?c))
         (cell (pos-c ?cc&:(= ?cc (- ?c 1))) (pos-r ?r) (contains Empty|Parking))
=> 
         (assert (serviceTB ?tb ?r (- ?c 1)))
)
(defrule creation424
         (declare (salience 22))
         (create-initial-setting)
         (TrashBasket (TB-id ?tb) (pos-r ?r) (pos-c ?c))
         (cell (pos-c ?cc&:(= ?cc (+ ?c 1))) (pos-r ?r) (contains Empty|Parking))
=> 
         (assert (serviceTB ?tb ?r (+ ?c 1)))
)
(defrule creation431
         (declare (salience 22))
         (create-initial-setting)
         (RecyclableBasket (RB-id ?rb) (pos-r ?r) (pos-c ?c))
         (cell (pos-r ?rr&:(= ?rr (- ?r 1))) (pos-c ?c) (contains Empty|Parking))
=> 
         (assert (serviceRB ?rb (- ?r 1) ?c))
)
(defrule creation432
         (declare (salience 22))
         (create-initial-setting)
         (RecyclableBasket (RB-id ?rb) (pos-r ?r) (pos-c ?c))
         (cell (pos-r ?rr&:(= ?rr (+ ?r 1))) (pos-c ?c) (contains Empty|Parking))
=> 
         (assert (serviceRB ?rb (+ ?r 1) ?c))
)
(defrule creation433
         (declare (salience 22))
         (create-initial-setting)
         (RecyclableBasket (RB-id ?rb) (pos-r ?r) (pos-c ?c))
         (cell (pos-c ?cc&:(= ?cc (- ?c 1))) (pos-r ?r) (contains Empty|Parking))
=> 
         (assert (serviceRB ?rb ?r (- ?c 1)))
)
(defrule creation434
         (declare (salience 22))
         (create-initial-setting)
         (RecyclableBasket (RB-id ?tb) (pos-r ?r) (pos-c ?c))
         (cell (pos-c ?cc&:(= ?cc (+ ?c 1))) (pos-r ?r) (contains Empty|Parking))
=> 
         (assert (serviceRB ?tb ?r (+ ?c 1)))
)
(defrule creation441
         (declare (salience 22))
         (create-initial-setting)
         (FoodDispenser (FD-id ?fd) (pos-r ?r) (pos-c ?c))
         (cell (pos-r ?rr&:(= ?rr (- ?r 1))) (pos-c ?c) (contains Empty))
=> 
         (assert (serviceFD ?fd (- ?r 1) ?c))
)
(defrule creation442
         (declare (salience 22))
         (create-initial-setting)
         (FoodDispenser (FD-id ?fd) (pos-r ?r) (pos-c ?c))
         (cell (pos-r ?rr&:(= ?rr (+ ?r 1))) (pos-c ?c) (contains Empty))
=> 
         (assert (serviceFD ?fd (+ ?r 1) ?c))
)
(defrule creation443
         (declare (salience 22))
         (create-initial-setting)
         (FoodDispenser (FD-id ?fd) (pos-r ?r) (pos-c ?c))
         (cell (pos-c ?cc&:(= ?cc (- ?c 1))) (pos-r ?r) (contains Empty))
=> 
         (assert (serviceFD ?fd ?r (- ?c 1)))
)
(defrule creation444
         (declare (salience 22))
         (create-initial-setting)
         (FoodDispenser (FD-id ?fd) (pos-r ?r) (pos-c ?c))
         (cell (pos-c ?cc&:(= ?cc (+ ?c 1))) (pos-r ?r) (contains Empty))
=> 
         (assert (serviceFD ?fd ?r (+ ?c 1)))
)
(defrule creation451
         (declare (salience 22))
         (create-initial-setting)
         (DrinkDispenser (DD-id ?dd) (pos-r ?r) (pos-c ?c))
         (cell (pos-r ?rr&:(= ?rr (- ?r 1))) (pos-c ?c) (contains Empty))
=> 
         (assert (serviceDD ?dd (- ?r 1) ?c))
)
(defrule creation452
         (declare (salience 22))
         (create-initial-setting)
         (DrinkDispenser (DD-id ?dd) (pos-r ?r) (pos-c ?c))
         (cell (pos-r ?rr&:(= ?rr (+ ?r 1))) (pos-c ?c) (contains Empty))
=> 
         (assert (serviceDD ?dd (+ ?r 1) ?c))
)
(defrule creation453
         (declare (salience 22))
         (create-initial-setting)
         (DrinkDispenser (DD-id ?tb) (pos-r ?r) (pos-c ?c))
         (cell (pos-c ?cc&:(= ?cc (- ?c 1))) (pos-r ?r) (contains Empty))
=> 
         (assert (serviceDD ?tb ?r (- ?c 1)))
)
(defrule creation454
         (declare (salience 22))
         (create-initial-setting)
         (DrinkDispenser (DD-id ?dd) (pos-r ?r) (pos-c ?c))
         (cell (pos-c ?cc&:(= ?cc (+ ?c 1))) (pos-r ?r) (contains Empty))
=> 
         (assert (serviceDD ?dd ?r (+ ?c 1)))
)
(defrule creation5
         (declare (salience 21))
?f1 <-   (create-initial-setting)
?f2 <-   (create-map)
         (initial_agentposition (pos-r ?r) (pos-c ?c) (direction ?d))
=> 
         (assert (agentstatus (step 0) (time 0) (pos-r ?r) (pos-c ?c) (direction ?d)
                              (l-drink 0) (l-food 0) (l_d_waste no) (l_f_waste no))
                 (status (step 0) (time 0) (result no))
                 (penalty 0))
         (retract ?f1 ?f2)
)

;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////// 					REGOLE GESTIONE EVENTI					/////////////////////////////////////
;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

;regola per la generazione di un nuovo ordine da parte di un tavolo pulito
;Questa regola scatta se:
;	- C'e' una richiesta di ordine da un tavolo
;	- Non ne sia stata gia' fatta un altra dallo stesso
(defrule neworder1	(declare (salience 200))
	(status (step ?i) (time ?t))
	?f1 <- (event (step ?i) (type request) (source ?tb) (food ?nf) (drink ?nd))
	(tablestatus (step ?i) (table-id ?tb) (clean yes))
    (not (orderstatus (step ?i) (requested-by ?tb))) 
	=> 
	(assert 
		(orderstatus (step ?i) 
					 (time ?t) 
					 (arrivaltime ?t) 
					 (requested-by ?tb) 
                     (drink-order ?nd) (food-order ?nf)
                     (drink-deliv 0) (food-deliv 0)
                     (answer pending)
		)
		
		(msg-to-agent (request-time ?t) 
					  (step ?i) 
					  (sender ?tb) 
					  (type order)
                      (drink-order ?nd) 
					  (food-order ?nf)
		)
	)
	(retract ?f1)		
	(printout t crlf " ENVIRONMENT:" crlf)
	(printout t " - " ?tb " orders " ?nf " food e " ?nd " drinks" crlf)
    (assert (printGUI (time ?t) (step ?i) (source "ENV") (verbosity 0) (text  "%p1 orders %p2 food e %p3 drinks.") (param1 ?tb) (param2 ?nf) (param3 ?nd)))  
)

;Regola per la generazione di un nuovo ordine da parte di un tavolo sporco
;Questa regola scatta se:
;	- C'e' una richiesta di ordine da un tavolo
;	- C'e' una richesta di pulito il tavolo
(defrule neworder2	(declare (salience 200))
	(status (step ?i) (time ?t))
	?f1 <- (event (step ?i) (type request) (source ?tb) (food ?nf) (drink ?nd))
	(tablestatus (step ?i) (table-id ?tb) (clean no))
    (cleanstatus (step ?i) (arrivaltime ?tt&:(< ?tt ?t)) (requested-by ?tb))
	=> 
	(assert  
		(orderstatus (step ?i) 
					 (time ?t) 
					 (arrivaltime ?t) 
					 (requested-by ?tb) 
                     (drink-order ?nd) (food-order ?nf)
                     (drink-deliv 0) (food-deliv 0)
                     (answer pending)
		)
	 	
		(msg-to-agent (request-time ?t) 
					  (step ?i) 
					  (sender ?tb)
					  (type order)
                      (drink-order ?nd) (food-order ?nf)
		)
	)
	(retract ?f1)		
	(printout t crlf " ENVIRONMENT:" crlf)
	(printout t " - " ?tb " orders " ?nf " food e " ?nd " drinks" crlf)
    (assert (printGUI (time ?t) (step ?i) (source "ENV") (verbosity 0) (text  "%p1 orders %p2 food e %p3 drinks.") (param1 ?tb) (param2 ?nf) (param3 ?nd)))      
)

;Regola per la gestione della terminazione di un ordine per un tavolo
;Questa regola scatta se:
;	- Il tavolo e` sporco
;	- Non ci sono ordini o richieste di pulizia presenti
(defrule newfinish	(declare (salience 200))
	(status (step ?i) (time ?t))
	?f1 <- (event (step ?i) (type finish) (source ?tb))
	(tablestatus (step ?i) (table-id ?tb) (clean no))
    (not (cleanstatus (step ?i) (arrivaltime ?tt&:(< ?tt ?t)) (requested-by ?tb))) ;non c'è già stato un finish
    (not (orderstatus (step ?i) (time ?t) (requested-by ?tb)))   ;l'ordine è stato completato
    => 
	(assert 	
		(cleanstatus (step ?i) 
					 (time ?t) 
					 (arrivaltime ?t) 
					 (requested-by ?tb) 
					 (source ?tb)
		)
        
		(msg-to-agent (request-time ?t) 
					  (step ?i) 
					  (sender ?tb) 
					  (type finish)
		)
	)
	(retract ?f1)
	(printout t crlf " ENVIRONMENT:" crlf)
	(printout t " - " ?tb " declares finish " crlf)
    (assert (printGUI (time ?t) (step ?i) (source "ENV") (verbosity 0) (text  "%p1 declares finish.") (param1 ?tb)))      
)

;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////// 					EVOLUZIONE TEMPORALE					/////////////////////////////////////
;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

;// per ogni istante di tempo che intercorre fra l'informazione di finish di un tavolo  e 
;//  pulitura (clean) del tavolo,  l'agente prende 3 penalità
(defrule CleanEvolution1 	(declare (salience 10))
	(status (time ?t) (step ?i))
	?f1	<-	(cleanstatus (step = (- ?i 1)) (time ?tt) (arrivaltime ?at) (requested-by ?tb) (source ?tb))
	(not (cleanstatus (step ?i)  (arrivaltime ?at) (requested-by ?tb))) 
	?f2 <-	(penalty ?p)
	=> 
	(modify ?f1 (time ?t) (step ?i))
	(assert (penalty (+ ?p (* (- ?t ?tt) 3))))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 2) 
		(text  "Penalty increased to %p1.") 
		(param1 (+ ?p (* (- ?t ?tt) 3)))
	))      
	(retract ?f2)	
)

(defrule CleanEvolution2       
	(declare (salience 10))
	(status (time ?t) (step ?i))
	?f1	<-	(cleanstatus (step = (- ?i 1)) (time ?tt) (arrivaltime ?at) (requested-by ?tb) (source agent))
	(not (cleanstatus (step ?i)  (arrivaltime ?at) (requested-by agent))) 
	=> 
	(modify ?f1 (time ?t) (step ?i))
)

;// per ogni istante di tempo che intercorre fra la request e la inform, l'agente prende 50 penalità
(defrule RequestEvolution1	(declare (salience 10))
	(status (time ?t) (step ?i))
	?f1 <- (orderstatus (step = (- ?i 1)) (time ?tt) (arrivaltime ?at) (requested-by ?tb) (answer pending))
	(not (orderstatus (step ?i) (arrivaltime ?at) (requested-by ?tb) (answer ~pending)))
	?f2 <- (penalty ?p)
	=> 
	(modify ?f1 (time ?t) (step ?i))
	(assert (penalty (+ ?p (* (- ?t ?tt) 50))))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1.") 
		(param1 (+ ?p (* (- ?t ?tt) 50)))
	))
	(retract ?f2)
)

;// penalità perchè l'ordine è stato accepted e non è ancora stato completato
;Gli ordini devono essere accettati anche se ne sto portando a termine altri
;pertanto prendo penalita' per ciascun ordine che accetto ma che non riesco a servire
(defrule RequestEvolution2	(declare (salience 10))
	(status (time ?t) (step ?i))
	?f1 <- (orderstatus (step = (- ?i 1)) (time ?tt) (arrivaltime ?at) 
						(requested-by ?tb) (answer accepted) (drink-order ?nd)
						(food-order ?nf) (drink-deliv ?dd) (food-deliv ?df))
    (not (orderstatus (step ?i) (arrivaltime ?at) (requested-by ?tb)))
	?f2 <- (penalty ?p)	
	=> 
    (modify ?f1 (time ?t) (step ?i))
	(assert (penalty (+ ?p (* (- ?t ?tt) (max 1 (* (+ (- ?nd ?dd) (- ?nf ?df)) 2))))))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 2) 
		(text  "Penalty increased to %p1.") 
		(param1 (+ ?p (* (- ?t ?tt) (max 1 (* (+ (- ?nd ?dd) (- ?nf ?df)) 2)))))
	))
	(retract ?f2)
)

;// penalità perchè l'ordine è stato delayed e non è ancora stato completato
;Rispondo con deleyed solo se il tavolo deve essere pulino prima che possa portare il nuovo ordine richiesto
(defrule RequestEvolution3 (declare (salience 10))
    (status (time ?t) (step ?i))
	?f1 <- (orderstatus (step = (- ?i 1)) (time ?tt) (arrivaltime ?at) 
						(requested-by ?tb) (answer delayed) (drink-order ?nd) 
						(food-order ?nf) (drink-deliv ?dd) (food-deliv ?df))
    (not (orderstatus (step ?i) (arrivaltime ?at) (requested-by ?tb)))
	?f2 <- (penalty ?p)
	=> 
    (modify ?f1 (time ?t) (step ?i))
	(assert (penalty (+ ?p (* (- ?t ?tt) (max 1 (+ (- ?nd ?dd) (- ?nf ?df)))))))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 2) 
		(text  "Penalty increased to %p1.") 
		(param1 (+ ?p (* (- ?t ?tt) (max 1 (+ (- ?nd ?dd) (- ?nf ?df))))))
	))
	(retract ?f2)
)

;//SE NON CI SONO RICHIESTA AGGIUNTIVE FACCIO SCORRERE IL TEMPO NORMALMENTE
(defrule RequestEvolution4	(declare (salience 10))
	(status (time ?t) (step ?i))
	?f1 <- (tablestatus (step = (- ?i 1)) (time ?tt) (table-id ?tb))
    (not (tablestatus (step ?i)  (table-id ?tb)))
	=>
	(modify ?f1 (time ?t) (step ?i))
)


;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////// 					GENERA MOVIMENTI PERSONE					/////////////////////////////////////
;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

;// Persona ferma non arriva comando di muoversi
(defrule MovePerson1	(declare (salience 9))    
	(status (step ?i) (time ?t)) 
	?f1	<-	(personstatus (step =(- ?i 1)) (ident ?id) (activity seated|stand))
	(not (personmove (step ?i) (ident ?id)))
	=> 
	(modify ?f1 (time ?t) (step ?i))
)
         
;//Persona ferma ma arriva comando di muoversi         
(defrule MovePerson2
   (declare (salience 10))    
        (status (step ?i) (time ?t))  
 ?f1 <- (personstatus (step =(- ?i 1)) (ident ?id) (activity seated|stand))
 ?f2 <- (personmove (step  ?i) (ident ?id) (path-id ?m))
        => (modify  ?f1 (time ?t) (step ?i) (activity ?m) (move 0))
           (retract ?f2)
)    
       
;// La cella in cui deve  andare la persona è libera. Persona si muove. 
;// La cella di partenza è un seat in cui si trovava l'operatore
(defrule MovePerson3
   (declare (salience 10))    
        (status (step ?i) (time ?t))   
 ?f1 <- (personstatus (step =(- ?i 1)) (ident ?id) (pos-r ?x) (pos-c ?y) 
                      (activity ?m&~seated&~stand) (move ?s))
        (cell (pos-r ?x) (pos-c ?y) (contains Seat))
 ?f3 <- (move-path ?m =(+ ?s 1) ?id ?r ?c)
        (not (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)))
 ?f2 <- (cell (pos-r ?r) (pos-c ?c) (contains Empty))
        => (modify  ?f1  (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) (move (+ ?s 1)))
           (modify ?f2 (contains Person))
           (retract ?f3)		
)

;// La cella in cui deve  andare la persona è libera. Persona si muove. 
;// La cella di partenza è occupata da cliente (Person) , per cui dopo lo spostamento 
;// del cliente la cella di partenza diventa libera e quella di arrivo contiene person
(defrule MovePerson4
   (declare (salience 10))    
        (status (step ?i) (time ?t)) 
 ?f1 <- (personstatus (step =(- ?i 1)) (ident ?id) (pos-r ?x) (pos-c ?y) 
                      (activity ?m&~seated|~stand) (move ?s))
 ?f4 <- (cell (pos-r ?x) (pos-c ?y) (contains Person))
 ?f3 <- (move-path ?m =(+ ?s 1) ?id ?r ?c)
        (not (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)))
 ?f2 <- (cell (pos-r ?r) (pos-c ?c) (contains Empty))
        => (modify  ?f1  (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) (move (+ ?s 1)))
           (modify ?f2 (contains Person))
           (modify ?f4 (contains Empty))
           (retract ?f3)
)
		   
;// La cella in cui deve andare il cliente è un seat e il seat non è occupata da altra persona.
;// La cella di partenza diventa libera, e l'attivita del cliente diventa seated
(defrule MovePerson5
   (declare (salience 10))    
        (status (step ?i) (time ?t)) 
 ?f1 <- (personstatus (step =(- ?i 1)) (ident ?id) (pos-r ?x) (pos-c ?y) 
                       (activity ?m&~seated&~stand) (move ?s))
 ?f3 <- (move-path ?m =(+ ?s 1) ?id ?r ?c)
        (not (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)))
 ?f2 <- (cell (pos-r ?r) (pos-c ?c) (contains Seat))
        (not (personstatus (step =(- ?i 1)) (pos-r ?r) (pos-c ?c) 
                       (activity seated)))
 ?f4 <- (cell (pos-r ?x) (pos-c ?y) (contains Person))
        => (modify  ?f1  (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) (activity seated) (move NA))
           (modify ?f4 (contains Empty))
           (retract ?f3)
)

;// La cella in cui deve  andare la persona è occupata dal robot. Persona non si muove           
(defrule MovePerson_wait1
	(declare (salience 10))    
	(status (step ?i) (time ?t))
?f1<-	(personstatus (step =(- ?i 1)) (time ?tt) (ident ?id) (activity ?m&~seated&~stand) (move ?s))
	(move-path ?m =(+ ?s 1) ?id ?r ?c)
	(agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c))
?f2<-	(penalty ?p)
=> 
	(modify  ?f1 (time ?t) (step ?i))
	(assert (penalty (+ ?p (* (- ?t ?tt) 20))))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 2) 
		(text  "Penalty increased to %p1.") 
		(param1 (+ ?p (* (- ?t ?tt) 20)))
	))
	(retract ?f2)
;	(printout t " - penalità aumentate" ?id " attende che il robot si sposti)" crlf)
)
;// La cella in cui deve  andare la persona non è libera (ma non è occupata da robot). Persona non si muove           
(defrule MovePerson_wait2
	(declare (salience 10))    
	(status (step ?i) (time ?t))
?f1<-	(personstatus (step =(- ?i 1)) (time ?tt) (ident ?id) (activity ?m&~seated&~stand) (move ?s))
	(move-path ?m =(+ ?s 1) ?id ?r ?c)
        (cell (pos-r ?r) (pos-c ?c) (contains ~Empty&~Seat))
	(not (agentstatus (step ?i) (time ?t) (pos-r ?r) (pos-c ?c)))
=>
	(modify  ?f1 (time ?t) (step ?i))
)

;// La cella in cui deve andare il cliente è un seat ma il seat è occupata da altra persona.
;// il cliente resta fermo
(defrule MovePerson_wait3
   (declare (salience 10))    
        (status (step ?i) (time ?t)) 
 ?f1 <- (personstatus (step =(- ?i 1)) (ident ?id) (pos-r ?x) (pos-c ?y) 
                       (activity ?m&~seated&~stand) (move ?s))
 ?f3 <- (move-path ?m =(+ ?s 1) ?id ?r ?c)
        (not (agentstatus (time ?i) (pos-r ?r) (pos-c ?c)))
 ?f2 <- (cell (pos-r ?r) (pos-c ?c) (contains Seat))
        (personstatus (step =(- ?i 1)) (pos-r ?r) (pos-c ?c) 
                       (activity seated))
        => (modify  ?f1  (step ?i) (time ?t))
)
;//La serie di mosse è stata esaurita, la persona rimane ferma dove si trova
(defrule MovePerson_end
   (declare (salience 9))    
        (status (step ?i) (time ?t)) 
?f1<-	(personstatus (step =(- ?i 1)) (time ?tt) (ident ?id) (activity ?m&~seated&~stand) (move ?s))
	(not (move-path ?m =(+ ?s 1) ?id ?r ?c))
        => (modify  ?f1  (time ?t) (step ?i) (activity stand) (move NA)) 
)


;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;///////////////////////// 		REGOLE PER GESTIONE INFORM (in caso di request) DALL'AGENTE		/////////////////////////////////
;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

;// l'agente ha inviato inform che l'ordine è accettato (e va bene)
(defrule msg-order-accepted-OK	(declare (salience 20))
	?f1 <- (status (step ?i) (time ?t))
	(exec (step ?i) (action Inform) (param1 ?tb) (param2 ?request) (param3 accepted))
	?f2 <- (orderstatus (step ?i) (time ?t) (requested-by ?tb) (arrivaltime ?request) (answer pending))		
	?f3 <- (agentstatus (step ?i) (time ?t))
	(tablestatus (step ?i) (time ?t) (table-id ?tb) (clean yes))	
	=> 
	(modify ?f1 (time (+ ?t 1)) (step (+ ?i 1)))
	(modify ?f2 (time (+ ?t 1)) (step (+ ?i 1)) (answer accepted))
	(modify ?f3 (time (+ ?t 1)) (step (+ ?i 1)))
)

;// l'agente ha inviato inform che l'ordine è accettato (e ma non sono vere le condizioni)
; ACCETTA UN ORDINE SU UN TAVOLO CHE DEVE ESSERE PULITO
(defrule msg-order-accepted-KO1	(declare (salience 20))
	?f1 <- (status (step ?i) (time ?t))
	(exec (step ?i) (action Inform) (param1 ?tb) (param2 ?request) (param3 accepted))
	?f2 <- (orderstatus (step ?i) (time ?t) (requested-by ?tb) (arrivaltime ?request) (answer pending))		
	?f3 <- (agentstatus (step ?i) (time ?t))
	(tablestatus (step ?i) (time ?t) (table-id ?tb) (clean no))	
	?f4 <- (penalty ?p)	
	=> 
	(modify ?f1 (time (+ ?t 1)) (step (+ ?i 1)))
	(modify ?f2 (time (+ ?t 1)) (step (+ ?i 1)) (answer accepted))
	(modify ?f3 (time (+ ?t 1)) (step (+ ?i 1)))
    (assert (penalty (+ ?p 500000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by accepted a dirty table.") 
		(param1 (+ ?p 500000))
	))
	(retract ?f4)
)

;// l'agente ha inviato inform che l'ordine è delayed (e va bene)
(defrule msg-order-delayed-OK	(declare (salience 20))
	?f1	<-	(status (step ?i) (time ?t))
	(exec (step ?i) (action Inform) (param1 ?tb) (param2 ?request) (param3 delayed))
	?f2	<-	(orderstatus (step ?i) (time ?t) (requested-by ?tb) (arrivaltime ?request) (answer pending))		
	?f3	<-	(agentstatus (step ?i) (time ?t))
	(tablestatus (step ?i) (time ?t) (table-id ?tb) (clean no))
	(cleanstatus (step ?i) (time ?t) (arrivaltime ?tt&:(< ?tt ?request)) (requested-by ?tb))	
	=> 
	(modify ?f1 (time (+ ?t 1)) (step (+ ?i 1)))
	(modify ?f2 (time (+ ?t 1)) (step (+ ?i 1)) (answer delayed))
	(modify ?f3 (time (+ ?t 1)) (step (+ ?i 1)))
)

;// l'agente ha inviato inform che l'ordine è delayed (e non va bene dovrebbe essere accepted)
(defrule msg-order-delayed-KO1	(declare (salience 20))
	?f1	<-	(status (step ?i) (time ?t))
	(exec (step ?i) (action Inform) (param1 ?tb) (param2 ?request) (param3 delayed))
	?f2	<-	(orderstatus (step ?i) (time ?t) (requested-by ?tb) (arrivaltime ?request) (answer pending))		
	?f3	<-	(agentstatus (step ?i) (time ?t))
	(tablestatus (step ?i) (time ?t) (table-id ?tb) (clean yes))
	?f4	<-	(penalty ?p)	
	=>	 
	(modify ?f1 (time (+ ?t 1)) (step (+ ?i 1)))
	(modify ?f2 (time (+ ?t 1)) (step (+ ?i 1)) (answer delayed))
	(modify ?f3 (time (+ ?t 1)) (step (+ ?i 1)))
    (assert (penalty (+ ?p 500000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by delayed but clean table.") 
		(param1 (+ ?p 500000))
	))
	(retract ?f4)
)

;// l'agente ha inviato inform che l'ordine è rejected (e non va bene dovrebbe essere accepted)
(defrule msg-order-rejected-KO1	(declare (salience 20))
	?f1	<-	(status (step ?i) (time ?t))
	(exec (step ?i) (action Inform) (param1 ?tb) (param2 ?request) (param3 rejected))
	?f2	<-	(orderstatus (step ?i) (time ?t) (requested-by ?tb) (arrivaltime ?request) (answer pending))		
	?f3	<-	(agentstatus (step ?i) (time ?t))
	(tablestatus (step ?i) (time ?t) (table-id ?tb) (clean yes))
	?f4	<-  (penalty ?p)	
	=> 
	(modify ?f1 (time (+ ?t 1)) (step (+ ?i 1)))
	(modify ?f2 (time (+ ?t 1)) (step (+ ?i 1)) (answer rejected))
	(modify ?f3 (time (+ ?t 1)) (step (+ ?i 1)))
	(assert (penalty (+ ?p 5000000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by a rejected.") 
		(param1 (+ ?p 5000000))
	))
	(retract ?f4)
)

;// l'agente ha inviato inform che l'ordine è rejected (e non va bene dovrebbe essere delayed)
(defrule msg-order-rejected-KO2	(declare (salience 20))
	?f1	<-	(status (step ?i) (time ?t))
	(exec (step ?i) (action Inform) (param1 ?tb) (param2 ?request) (param3 rejected))
	?f2	<-	(orderstatus (step ?i) (time ?t) (requested-by ?tb) (arrivaltime ?request) (answer pending))		
	?f3	<-	(agentstatus (step ?i) (time ?t))
    (tablestatus (step ?i) (time ?t) (table-id ?tb) (clean no))
    (cleanstatus (step ?i) (time ?t) (arrivaltime ?tt&:(< ?tt ?request)) (requested-by ?tb))
	?f4	<-	(penalty ?p)	
	=> 
	(modify ?f1 (time (+ ?t 1)) (step (+ ?i 1)))
	(modify ?f2 (time (+ ?t 1)) (step (+ ?i 1)) (answer accepted))
	(modify ?f3 (time (+ ?t 1)) (step (+ ?i 1)))
    (assert (penalty (+ ?p 5000000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by rejected.") 
		(param1 (+ ?p 5000000))
	))
	(retract ?f4)
)

;// l'agente invia un'inform  per un servizio che non è più pending
(defrule msg-mng-KO1	(declare (salience 20))
	?f1	<-	(status (step ?i) (time ?t))
	(exec (step ?i) (action Inform) (param1 ?tb) (param2 ?request))
	(orderstatus (step ?i) (time ?t) (requested-by ?tb) (arrivaltime ?request) (answer ~pending))		
	?f3	<-	(agentstatus (step ?i) (time ?t))
	?f4	<-	(penalty ?p)
	=> 
	(modify ?f1 (time (+ ?t 1)) (step (+ ?i 1)))
	(modify ?f3 (time (+ ?t 1)) (step (+ ?i 1)))
	(assert (penalty (+ ?p 10000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by a service not more in pending.") 
		(param1 (+ ?p 10000))
	))
	(retract ?f4)
)

;// arriva un'inform per una richiesta non fatta dal tavolo
(defrule msg-mng-KO2	(declare (salience 20))
	?f1	<-	(status (step ?i) (time ?t))
	(exec (step ?i) (action Inform) (param1 ?tb) (param2 ?request))
    (not (orderstatus (step ?i) (time ?t) (requested-by ?tb) (arrivaltime ?request))) 
	?f3	<-	(agentstatus (step ?i) (time ?t))
	?f4	<-	(penalty ?p)
	=> 
	(modify ?f1 (time (+ ?t 1)) (step (+ ?i 1)))
	(modify ?f3 (time (+ ?t 1)) (step (+ ?i 1)))
	(assert (penalty (+ ?p 500000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by inform not made by that table.") 
		(param1 (+ ?p 500000))
	))
	(retract ?f4)
)

;// Regole per il CheckFinish
;// Operazione OK- risposta yes
(defrule CheckFinish_OK_YES	(declare (salience 20))    
	?f2	<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action CheckFinish) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
	?f1	<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
    (serviceTable ?tb ?rr ?cc)
	(tablestatus (step ?i) (table-id ?tb) (clean no))
    (msg-to-agent  (request-time ?rt)  (step ?ii) (sender ?tb) (type order))
    (not (orderstatus (step ?i) (time ?t) (requested-by ?tb)))
    (not (cleanstatus (step ?i) (arrivaltime ?at&:(> ?at ?rt)) (requested-by ?tb) (source ?tb)))
    (test (> (- ?t ?rt)  100))
	=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 40)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 40)))
	(assert (perc-finish (step (+ ?i 1)) (time (+ ?t 40)) (finish yes))
    (cleanstatus (step (+ ?i 1)) (time (+ ?t 40)) (arrivaltime (+ ?t 40)) (requested-by ?tb) (source agent)))
)

;// Operazione OK- Risposta no
(defrule CheckFinish_OK_NO	(declare (salience 20))    
	?f2	<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action CheckFinish) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
	?f1	<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
    (serviceTable ?tb ?rr ?cc)
	?f3	<-	(tablestatus (step ?i) (table-id ?tb) (clean no))
    (msg-to-agent  (request-time ?rt)  (step ?ii) (sender ?tb) (type order))
    (not (orderstatus (step ?i) (time ?t) (requested-by ?tb)))
    (not (cleanstatus (step ?i) (arrivaltime ?iii&:(> ?iii ?ii)) (requested-by ?tb) (source ?tb)))
    (test (or (= (- ?t ?rt)  100) (< (- ?t ?rt)  100)))
	=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 40)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 40)))
	(assert (perc-finish (step (+ ?i 1)) (time (+ ?t 40)) (finish no)))
)

; operazione non serve, il tavolo ha già richiesto cleantable 
(defrule CheckFinish_useless-1	(declare (salience 20))    
	?f2	<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action CheckFinish) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
	?f1	<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
    (serviceTable ?tb ?rr ?cc)
	?f3	<-	(tablestatus (step ?i) (table-id ?tb) (clean no))
    (msg-to-agent  (request-time ?rt)  (step ?ii&:(< ?ii ?i)) (sender ?tb) (type order))
    (cleanstatus (step ?i) (arrivaltime ?iii&:(> ?iii ?ii)) (requested-by ?tb))
	?f4	<-	(penalty ?p)
	=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 40)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 40)))
	(assert (perc-finish (step (+ ?i 1)) (time (+ ?t 40)) (finish yes))
    (penalty (+ ?p 10000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by checkfinish on a table with cleantable request.") 
		(param1 (+ ?p 10000))
	))
    (retract ?f4)
)

;// operazione non serve, il tavolo è gia pulito
(defrule CheckFinish_useless-2	(declare (salience 20))    
	?f2	<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action CheckFinish) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
	?f1	<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
    (serviceTable ?tb ?rr ?cc)
	?f3	<-	(tablestatus (step ?i) (table-id ?tb) (clean yes))
	?f4	<-  (penalty ?p)
	=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 40)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 40)))
	(assert (perc-finish (step (+ ?i 1)) (time (+ ?t 40)) (finish yes))
	(penalty (+ ?p 10000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by cleantable on a clean table.") 
		(param1 (+ ?p 10000))
	))
	(retract ?f4)
)

;// Operazione sbagliata perchè chiede finish prima che l'ordine sia stato completato
(defrule CheckFinish_Useless-3	(declare (salience 20))    
	?f2	<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action CheckFinish) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
	?f1	<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
    (serviceTable ?tb ?rr ?cc)
	?f3	<-	(tablestatus (step ?i) (table-id ?tb) (clean no))
	(msg-to-agent  (request-time ?rt)  (step ?ii) (sender ?tb) (type order))
	(orderstatus (step ?i) (time ?t) (requested-by ?tb))
	?f4	<-  (penalty ?p)
=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 40)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 40)))
	(assert (perc-finish (step (+ ?i 1)) (time (+ ?t 40)) (finish no))
	(penalty (+ ?p 100000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by cleantable too early.") 
		(param1 (+ ?p 100000))
	))
	(retract ?f4)
)

;// operazione di checkFinish fatta su tavolo che non ha fatto richiesta
(defrule CheckFinish_useless-4	(declare (salience 20))    
	?f2	<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action CheckFinish) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
	?f1	<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
    (serviceTable ?tb ?rr ?cc)
	?f3	<-	(tablestatus (step ?i) (table-id ?tb) (clean no))
    (not (msg-to-agent  (request-time ?rt)  (step ?ii&:(< ?ii ?i)) (sender ?tb) (type order)))
	?f4	<-  (penalty ?p)
	=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 40)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 40)))
	(assert (perc-finish (step (+ ?i 1)) (time (+ ?t 40)) (finish no))
	(penalty (+ ?p 100000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by useless cleantable.") 
		(param1 (+ ?p 100000))
	))
	(retract ?f4)
)

;// L'azione di CheckFinish  fallisce perchè l'agente non è accanto ad un tavolo 
(defrule CheckFinish_KO_1	(declare (salience 20))
	?f2	<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action CheckFinish) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
	?f1	<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
	(not (serviceTable ?tb ?rr ?cc))
	?f5	<-  (penalty ?p)
	=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 30)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 30))) 
	(assert (penalty (+ ?p	500000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, checkFinish wrong because robot not near a table.") 
		(param1 (+ ?p 500000))
	))
	(retract ?f5)
)

;// L'azione di CheckFinish fallisce perchè la posizione indicata non 
;//contiene un tavolo 
(defrule CheckFinish_KO_2	(declare (salience 20))
	?f2	<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action CheckFinish) (param1 ?x) (param2 ?y))
	(not (Table (table-id ?tb) (pos-r ?x) (pos-c ?y)))
	?f1	<-	(agentstatus (step ?i) (time ?t))
	?f5	<-  (penalty ?p)
	=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 30)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 30))) 
	(assert (penalty (+ ?p	500000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by a cleantable on a cell where isn't a table.") 
		(param1 (+ ?p 500000))
	))
	(retract ?f5)
)

;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;///////////////////////// 						REGOLE PER il Clean Table						/////////////////////////////////
;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

;// Operazione OK
(defrule CleanTable_OK_1	(declare (salience 20))    
	?f2	<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action CleanTable) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
	?f1	<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) (l-food  0) (l-drink 0) (l_d_waste ?dw) (l_f_waste ?fw))
    (serviceTable ?tb ?rr ?cc)
	?f3	<-	(tablestatus (step ?i) (table-id ?tb) (l-drink ?tld&:(> ?tld 0)) (l-food ?tlf&:(> ?tlf 0)))
	?f4	<-	(cleanstatus (step ?i) (requested-by ?tb))
	=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t (+ 10 (* 2 ?tld) (* 3 ?tlf)))))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t (+ 10 ( * 2 ?tld) (* 3 ?tlf)))) (l_d_waste yes) (l_f_waste yes))
	(modify ?f3 (step (+ ?i 1)) (time (+ ?t (+ 10 ( * 2 ?tld) (* 3 ?tlf)))) (l-drink 0) (l-food 0) (clean yes))
	(retract ?f4)
)

(defrule CleanTable_OK_2	(declare (salience 20))    
	?f2	<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action CleanTable) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
	?f1	<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) (l-food  0) (l-drink 0) (l_d_waste ?dw) (l_f_waste ?fw))
    (serviceTable ?tb ?rr ?cc)
	?f3	<-	(tablestatus (step ?i) (table-id ?tb) (l-drink ?tld&:(> ?tld 0)) (l-food 0))
	?f4	<-	(cleanstatus (step ?i) (requested-by ?tb))
	=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t (+ 10 ( * 2 ?tld)))))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t (+ 10 ( * 2 ?tld)))) (l_d_waste yes) (l_f_waste ?fw))
	(modify ?f3 (step (+ ?i 1)) (time (+ ?t (+ 10 ( * 2 ?tld)))) (l-drink 0) (l-food 0) (clean yes))
	(retract ?f4)
)

;// Operazione OK
(defrule CleanTable_OK_3
	(declare (salience 20))    
?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action CleanTable) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food  0) (l-drink 0) (l_d_waste ?dw) (l_f_waste ?fw))
        (serviceTable ?tb ?rr ?cc)
?f3<-	(tablestatus (step ?i) (table-id ?tb) (l-drink 0) (l-food ?tlf&:(> ?tlf 0)))
?f4<-	(cleanstatus (step ?i) (requested-by ?tb))
=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t (+ 10  (* 3 ?tlf)))))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t (+ 10  (* 3 ?tlf)))) 
                    (l_d_waste ?dw) (l_f_waste yes))
	(modify ?f3 (step (+ ?i 1)) (time (+ ?t (+ 10  (* 3 ?tlf)))) 
                    (l-drink 0) (l-food 0) (clean yes))
	(retract ?f4)
)
;// CleanTable  ha fisicamente successo ma fatta quando non 
;// c'è  richiesta di cleanTable o dopo CheckFinish positiva
(defrule CleanTable_K0_1
	(declare (salience 20))    
?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action CleanTable) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food  0) (l-drink 0) (l_d_waste ?dw) (l_f_waste ?fw))
        (serviceTable ?tb ?rr ?cc)
?f3<-	(tablestatus (step ?i) (table-id ?tb) (l-drink ?tld) (l-food ?tlf)(clean no))
 	(not (cleanstatus (step ?i) (requested-by ?tb)))
?f5<-   (penalty ?p)
=> 
	(modify ?f2 (step (+ ?i 1)) 
                    (time (+ ?t (+ 10 
                                   (* 2 ?tld) 
                                   (* 3 ?tlf))))
        )
	(modify ?f1 (step (+ ?i 1)) 
                    (time (+ ?t (+ 10 (* 2 ?tld) (* 3 ?tlf)))) 
                    (l_d_waste yes) (l_f_waste yes))
	(modify ?f3 (step (+ ?i 1)) (time (+ ?t (+ 10 ( * 2 ?tld) (* 3 ?tlf))))
                    (l-drink 0) (l-food 0) (clean yes))
	(assert (penalty (+ ?p 500000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by a cleantable it's not requested.") 
		(param1 (+ ?p 500000))
	))
	(retract ?f5)
)
;// azione inutile di cleantable perchè il tavolo è già pulito
(defrule CleanTable_K0_2
	(declare (salience 20))    
?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action CleanTable) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food  0) (l-drink 0) (l_d_waste ?dw) (l_f_waste ?fw))
        (serviceTable ?tb ?rr ?cc)
?f3<-	(tablestatus (step ?i) (table-id ?tb) (clean yes))
?f5<-   (penalty ?p)
=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 30)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 30)) 
                    (l_d_waste ?dw) (l_f_waste ?fw))
	(modify ?f3 (step (+ ?i 1)) (time (+ ?t 30)))
	(assert (penalty (+ ?p 10000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by a cleantable on a clean table.") 
		(param1 (+ ?p 10000))
	))
	(retract ?f5)
)

;// il robot tenta di fare CleanTable  ma fallisce perchè sta già trasportando cibo 
;// e o bevande
(defrule CleanTable_KO_3
	(declare (salience 20))
?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action CleanTable) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-drink ?ld) (l-food ?lf))
        (test (> (+ ?ld ?lf) 0))
        (serviceTable ?tb ?rr ?cc)
?f5<-   (penalty ?p)
=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 30)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 30)))
	(assert (penalty (+ ?p	500000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by cleantable when the robot has food or drink.") 
		(param1 (+ ?p 500000))
	))
   	(retract ?f5)
)    
;// L'azione di CleanTable fallisce perchè l'agente non è accanto ad un tavolo 
(defrule CleanTable_KO_4
	(declare (salience 20))
?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action CleanTable) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
        (not (serviceTable ?tb ?rr ?cc))
?f5<-   (penalty ?p)
=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 30)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 30))) 
	(assert (penalty (+ ?p	500000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by robot not near a table.") 
		(param1 (+ ?p 500000))
	))
    (retract ?f5)
) 
;// L'azione di CleanTable fallisce perchè la posizione indicata non 
;//contiene un tavolo 
(defrule CleanTable_KO_5
	(declare (salience 20))
?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action CleanTable) (param1 ?x) (param2 ?y))
	(not (Table (table-id ?tb) (pos-r ?x) (pos-c ?y)))
?f1<-	(agentstatus (step ?i) (time ?t))
?f5<-   (penalty ?p)
=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 30)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 30))) 
	(assert (penalty (+ ?p	500000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by cell not contains a table.") 
		(param1 (+ ?p 500000))
	))
    (retract ?f5)
)

;// __________________________________________________________________________________________
;// REGOLE PER il EmptyFood
;// Operazione OK
(defrule EmptyFood_OK
	(declare (salience 20))    
?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action EmptyFood) (param1 ?x) (param2 ?y))
	(TrashBasket (TB-id ?trb) (pos-r ?x) (pos-c ?y))
?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l_f_waste yes))
        (serviceTB ?trb ?rr ?cc)
=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 6)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 6)) (l_f_waste no))
)
;// Operazione inutile perchè agente non ha avanzi di cibo a bordo
(defrule EmptyFood_KO1
	(declare (salience 20))       
?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action EmptyFood) (param1 ?x) (param2 ?y))
	(TrashBasket (TB-id ?trb) (pos-r ?x) (pos-c ?y))
?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l_f_waste no))
        (serviceTB ?trb ?rr ?cc)
?f5<-   (penalty ?p)
=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 6)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 6)) (l_f_waste no))
    (assert (penalty (+ ?p	10000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by emptyfood when robot doesnt have food waste.") 
		(param1 (+ ?p 10000))
	))
	(retract ?f5)
)    
;// Operazione fallisce perchè l'agente non è adiacente a un TrashBasket
(defrule EmptyFood_KO2
	(declare (salience 20))
?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action EmptyFood) (param1 ?x) (param2 ?y))
	(TrashBasket (TB-id ?trb) (pos-r ?x) (pos-c ?y))
?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
        (not (serviceTB ?trb ?rr ?cc))
?f5<-   (penalty ?p)    
=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 6)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 6)))
    (assert (penalty (+ ?p	500000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by robot not near a TB.") 
		(param1 (+ ?p 500000))
	))
	(retract ?f5)
)
;// Operazione fallisce perchè la cella indicata non è un TrashBasket
(defrule EmptyFood_KO3
	(declare (salience 20))
	?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action EmptyFood) (param1 ?x) (param2 ?y))
	(not (TrashBasket (TB-id ?trb) (pos-r ?x) (pos-c ?y)))
	?f1<-	(agentstatus (step ?i) (time ?t))
	?f5<-   (penalty ?p)    
	=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 6)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 6)))
    (assert (penalty (+ ?p	500000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by cell not contains a TB.") 
		(param1 (+ ?p 500000))
	))
	(retract ?f5)
)
;// __________________________________________________________________________________________
;// REGOLE PER il Release (svuota contenitori bevande in RecyclableBasket)
;// Operazione OK
(defrule Release_OK
	(declare (salience 20))    
?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action Release) (param1 ?x) (param2 ?y))
	(RecyclableBasket (RB-id ?rb) (pos-r ?x) (pos-c ?y))
?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l_d_waste yes))
        (serviceRB ?rb ?rr ?cc)
=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 8)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 8)) (l_d_waste no))
)
;// Operazione inutile perchè agente non ha contenitori di bevande a bordo
(defrule Release_KO1
	(declare (salience 20))       
	?f2 <- (status (time ?t) (step ?i)) 
	(exec (step ?i) (action Release) (param1 ?x) (param2 ?y))
	(RecyclableBasket (RB-id ?rb) (pos-r ?x) (pos-c ?y))
	?f1 <- (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l_d_waste no))
        (serviceRB ?rb ?rr ?cc)
	?f5<- (penalty ?p)
	=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 8)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 8)) (l_d_waste no))
    (assert (penalty (+ ?p	10000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by release when robot doesnt have drink waste.") 
		(param1 (+ ?p 10000))
	))
	(retract ?f5)
)    
;// Operazione fallisce perchè l'agente non è adiacente a un RecyclableBasket
(defrule Release_KO2
	(declare (salience 20))
	?f2 <- (status (time ?t) (step ?i)) 
	(exec (step ?i) (action Release) (param1 ?x) (param2 ?y))
	(RecyclableBasket (RB-id ?rb) (pos-r ?x) (pos-c ?y))
	?f1 <- (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
    (not (serviceRB ?rb ?rr ?cc))
	?f5 <- (penalty ?p)    
=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 8)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 8)))
    (assert (penalty (+ ?p	500000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by when robot isn't near a RB'.") 
		(param1 (+ ?p 500000))
	))
    (retract ?f5)
)
;// Operazione fallisce perchè la cella indicata non è un RecyclableBasket
(defrule Release_KO3
	(declare (salience 20))
?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action Release) (param1 ?x) (param2 ?y))
	(not (RecyclableBasket (RB-id ?rb) (pos-r ?x) (pos-c ?y)))
?f1<-	(agentstatus (step ?i) (time ?t))
?f5<-   (penalty ?p)    
=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 8)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 8)))
    (assert (penalty (+ ?p	500000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by cell not contains a RB.") 
		(param1 (+ ?p 500000))
	))
	(retract ?f5)
)
;/// REGOLE PER WAIT
(defrule WAIT
	(declare (salience 20))
?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action Wait))
?f1<-	(agentstatus (step ?i) (time ?t))   
=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 10)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 10)))
)
;// __________________________________________________________________________________________
;// REGOLE PER il prelievo di Food da food Dispenser
;// Operazione OK
(defrule load-food_OK
	(declare (salience 20))    
?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action LoadFood) (param1 ?x) (param2 ?y))
	(FoodDispenser (FD-id ?fd) (pos-r ?x) (pos-c ?y))
?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
        (serviceFD ?fd ?rr ?cc)
        (test (< (+ ?lf ?ld) 4))
=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 5)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 5)) (l-food (+ ?lf 1)))
)
;// Operazione fallisce perchè l'agente è già a pieno carico
(defrule load-food_KO1
	(declare (salience 20))    
?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action LoadFood) (param1 ?x) (param2 ?y))
	(FoodDispenser (FD-id ?fd) (pos-r ?x) (pos-c ?y))
?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
        (serviceFD ?fd ?rr ?cc)
        (test (= (+ ?lf ?ld) 4))
?f5<-   (penalty ?p)
=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 5)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 5)))
    (assert (penalty (+ ?p	100000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by robot is full.") 
		(param1 (+ ?p 100000))
	))
	(retract ?f5)
)    
;// Operazione fallisce perchè l'agente è già carico di immondizia
(defrule load-food_KO2
	(declare (salience 20))    
?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action LoadFood) (param1 ?x) (param2 ?y))
	(FoodDispenser (FD-id ?fd) (pos-r ?x) (pos-c ?y))
?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food ?lf) (l-drink ?ld) (l_d_waste ?dw) (l_f_waste ?fw))
        (serviceFD ?fd ?rr ?cc)
        (test (or (eq ?dw yes) (eq ?fw yes)))
?f5<-   (penalty ?p)
=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 5)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 5)))
    (assert (penalty (+ ?p	500000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by robot is full of waste.") 
		(param1 (+ ?p 500000))
	))
    (retract ?f5)
)
;// Operazione fallisce perchè l'agente non è adiacente a un FoodDispenser
(defrule load-food_KO3
	(declare (salience 20))    
?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action LoadFood) (param1 ?x) (param2 ?y))
	(FoodDispenser (FD-id ?fd) (pos-r ?x) (pos-c ?y))
?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
        (not (serviceFD ?fd ?rr ?cc))
?f5<-   (penalty ?p)
=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 5)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 5)))
    (assert (penalty (+ ?p	500000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by robot isn't near a FD.") 
		(param1 (+ ?p 500000))
	))
    (retract ?f5)
)
;// Operazione fallisce perchè la cella indicata non è un FoodDispenser
(defrule load-food_KO4
	(declare (salience 20))    
?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action LoadFood) (param1 ?x) (param2 ?y))
	(not (FoodDispenser (FD-id ?fd) (pos-r ?x) (pos-c ?y)))
?f1<-	(agentstatus (step ?i) (time ?t))
?f5<-   (penalty ?p)
=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 5)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 5)))
    (assert (penalty (+ ?p	500000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by cell not contains a FD.") 
		(param1 (+ ?p 500000))
	))
    (retract ?f5)
)
;// __________________________________________________________________________________________
;// REGOLE PER il prelievo di drink da drink Dispenser
;// Operazione OK
(defrule load-drink_OK
	(declare (salience 20))    
	?f2 <- (status (time ?t) (step ?i)) 
	(exec (step ?i) (action LoadDrink) (param1 ?x) (param2 ?y))
	(DrinkDispenser (DD-id ?dd) (pos-r ?x) (pos-c ?y))
	?f1 <- (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
    					(l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
    (serviceDD ?dd ?rr ?cc)
    (test (< (+ ?lf ?ld) 4))
	=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 6)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 6)) (l-drink (+ ?ld 1)))
)
;// Operazione fallisce perchè l'agente è già a pieno carico
(defrule load-drink_KO1
	(declare (salience 20))    
	?f2 <- (status (time ?t) (step ?i)) 
	(exec (step ?i) (action LoadDrink) (param1 ?x) (param2 ?y))
	(DrinkDispenser (DD-id ?dd) (pos-r ?x) (pos-c ?y))
	?f1 <- (agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
    (serviceDD ?dd ?rr ?cc)
    (test (= (+ ?lf ?ld) 4))
	?f5<-   (penalty ?p)
=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 6)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 6)))
    (assert (penalty (+ ?p	100000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by robot is full.") 
		(param1 (+ ?p 100000))
	))
	(retract ?f5)
)    
;// Operazione fallisce perchè l'agente è già carico di immondizia
(defrule load-drink_KO2
	(declare (salience 20))    
?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action LoadDrink) (param1 ?x) (param2 ?y))
	(DrinkDispenser (DD-id ?dd) (pos-r ?x) (pos-c ?y))
?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food ?lf) (l-drink ?ld) (l_d_waste ?dw) (l_f_waste ?fw))
        (serviceDD ?dd ?rr ?cc)
        (test (or (eq ?dw yes) (eq ?fw yes)))
?f5<-   (penalty ?p)
=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 6)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 6)))
    (assert (penalty (+ ?p	500000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by robot is full of waste.") 
		(param1 (+ ?p 500000))
	))
    (retract ?f5)
)
;// Operazione fallisce perchè l'agente non è adiacente a un drinkDispenser
(defrule load-drink_KO3
	(declare (salience 20))    
?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action LoadDrink) (param1 ?x) (param2 ?y))
	(DrinkDispenser (DD-id ?dd) (pos-r ?x) (pos-c ?y))
?f1<-	(agentstatus (step ?i) (time ?t)(pos-r ?rr) (pos-c ?cc))
        (not (serviceDD ?dd ?rr ?cc))
?f5<-   (penalty ?p)
=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 6)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 6)))
    (assert (penalty (+ ?p	500000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by robot isn't near a DD.") 
		(param1 (+ ?p 500000))
	))
    (retract ?f5)
)
;// Operazione fallisce perchè la cella indicata non è un drinkDispenser
(defrule load-drink_KO4
	(declare (salience 20))    
?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action LoadDrink) (param1 ?x) (param2 ?y))
	(not (DrinkDispenser (DD-id ?dd) (pos-r ?x) (pos-c ?y)))
?f1<-	(agentstatus (step ?i) (time ?t))
?f5<-   (penalty ?p)
=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 6)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 6)))
    (assert (penalty (+ ?p	500000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by cell not contains a DD.") 
		(param1 (+ ?p 500000))
	))
    (retract ?f5)
)
;// __________________________________________________________________________________________
;// REGOLE PER LA CONSEGNA Di Food ad un tavolo
;// ¯¯consegna Food su un tavolo che ha ordine ancora aperto
;// le penalità di riferiscono alla durata dell'azione (4 unità di tempo) 
;// per i punti (2) per i cibi e bevande non ancora consegnati 
(defrule delivery-food_OK
	(declare (salience 20))    
?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action DeliveryFood) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food ?alf&:(> ?alf 0)))
        (serviceTable ?tb ?rr ?cc)
?f3<-	(tablestatus (step ?i) (table-id ?tb) (l-drink ?tld) (l-food ?tlf))
?f4<-	(orderstatus (step ?i) (requested-by ?tb) (food-order ?nfo) (food-deliv ?dfo&:(< ?dfo ?nfo))
                     (drink-order ?ndo) (drink-deliv ?ddo))
?f5<-   (penalty ?p)
=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 4)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 4)) (l-food (- ?alf 1)))
	(modify ?f3 (step (+ ?i 1)) (time (+ ?t 4)) (l-food (+ ?tlf 1)) (clean no))
	(modify ?f4 (step (+ ?i 1)) (time (+ ?t 4)) (food-deliv ( + ?dfo 1)))
	(assert (penalty (+ ?p	(max  1 (* 8 (+ (- ?ndo ?ddo) (- ?nfo  (+ ?dfo 1))))))))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1.") 
		(param1 (+ ?p (+ ?p	(max  1 (* 8 (+ (- ?ndo ?ddo) (- ?nfo  (+ ?dfo 1))))))))
	))
    (retract ?f5)
)
;// assegna una penalità nel caso in cui si tenti di consegnare un cibo ad un tavolo
;// quando l'ordinazione è già stata completata (ordestatus eleinato) o non è mai stato fatto
(defrule delivery-food_WRONG_2
	(declare (salience 20))
?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action DeliveryFood) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food ?alf&:(> ?alf 0)))
        (serviceTable ?tb ?rr ?cc)
?f3<-	(tablestatus (step ?i) (table-id ?tb) (l-drink ?tld) (l-food ?tlf))
	(not (orderstatus (step ?i) (requested-by ?tb))) 
?f5<-   (penalty ?p)
=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 4)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 4)) (l-food (- ?alf 1)))
	(modify ?f3 (step (+ ?i 1)) (time (+ ?t 4)) (l-food (+ ?tlf 1)))
	(assert (penalty (+ ?p	500000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by a delivery food on a table with order completed or no order.") 
		(param1 (+ ?p 500000))
	))
    (retract ?f5)
) 
;// il robot tenta di fare una delivery-food  ma non sta trasportando cibo
(defrule delivery-food_WRONG_3
	(declare (salience 20))
?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action DeliveryFood) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-food ?alf&:(= ?alf 0)))
        (serviceTable ?tb ?rr ?cc)
?f5<-   (penalty ?p)
=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 4)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 4)))
	(assert (penalty (+ ?p	100000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by a delivery food but no food on the robot.") 
		(param1 (+ ?p 100000))
	))
    (retract ?f5)
)    
;// __________________________________________________________________________________________
;// REGOLE PER LA CONSEGNA Di DRINK ad un tavolo
;// ¯¯consegna drink a un tavolo che ha ordine ancora aperto
;// le penalità di riferiscono alla durata dell'azione (4 unità di tempo) 
;// per i punti (2) per i cibi e bevande non ancora consegnati 
(defrule delivery-drink_OK
	(declare (salience 20))    
?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action DeliveryDrink) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-drink ?ald&:(> ?ald 0)))
        (serviceTable ?tb ?rr ?cc)
?f3<-	(tablestatus (step ?i) (table-id ?tb) (l-drink ?tld) (l-food ?tlf))
?f4<-	(orderstatus (step ?i) (requested-by ?tb) (food-order ?nfo) (food-deliv ?dfo)
                     (drink-order ?ndo) (drink-deliv ?ddo&:(< ?ddo ?ndo)))
?f5<-   (penalty ?p)
	=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 4)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 4)) (l-drink (- ?ald 1)))
	(modify ?f3 (step (+ ?i 1)) (time (+ ?t 4)) (l-drink (+ ?tld 1)) (clean no))
	(modify ?f4 (step (+ ?i 1)) (time (+ ?t 4))  (drink-deliv ( + ?ddo 1)))
	(assert (penalty (+ ?p	(max 1 (* 8 (+ (- ?nfo ?dfo) (- ?ndo  (+ ?ddo 1))))))))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1.") 
		(param1 (+ ?p	(max 1 (* 8 (+ (- ?nfo ?dfo) (- ?ndo  (+ ?ddo 1)))))))
	))
    (retract ?f5)
)

;// assegna una penalità nel caso in cui si tenti di consegnare un cibo ad un tavolo
;// quando l'ordinazione è già stata completata o non è stato fatto ordine
(defrule delivery-drink_WRONG_2
	(declare (salience 20))
?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action DeliveryDrink) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-drink ?ald&:(> ?ald 0)))
        (serviceTable ?tb ?rr ?cc)
?f3<-	(tablestatus (step ?i) (table-id ?tb) (l-drink ?tld) (l-food ?tlf))
	(not (orderstatus (step ?i) (requested-by ?tb))) 
?f5<-   (penalty ?p)
=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 4)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 4)) (l-drink (- ?ald 1)))
	(modify ?f3 (step (+ ?i 1)) (time (+ ?t 4)) (l-drink (+ ?tld 1)))
	(assert (penalty (+ ?p	500000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by a delivery food on a table with order completed or no order.") 
		(param1 (+ ?p 500000))
	))
    (retract ?f5)
) 
;// il robot tenta di fare una delivery-food  ma non sta trasportando cibo
(defrule delivery-drink_WRONG_3
	(declare (salience 20))
?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action DeliveryDrink) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc) 
                     (l-drink ?ald&:(= ?ald 0)))
        (serviceTable ?tb ?rr ?cc)
?f5<-   (penalty ?p)
=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 4)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 4)))
	(assert (penalty (+ ?p	100000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by a delivery food but no food on the robot.") 
		(param1 (+ ?p 100000))
	))
    (retract ?f5)
)    
;// L'azione di delivery-food o delivery-drink fallisce perchè l'agente non è accanto ad un tavolo 
(defrule delivery_WRONG_4
	(declare (salience 20))
?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action DeliveryFood|DeliveryDrink) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
?f1<-	(agentstatus (step ?i) (time ?t) (pos-r ?rr) (pos-c ?cc))
        (not (serviceTable ?tb ?rr ?cc))
?f5<-   (penalty ?p)
=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 4)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 4))) 
	(assert (penalty (+ ?p	500000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by a delivery food or drink but robot isn't near a table.") 
		(param1 (+ ?p 500000))
	))
    (retract ?f5)
) 
;// L'azione di delivery-food o o delivery-drink fallisce perchè la posizione indicata non 
;//contiene un tavolo 
(defrule delivery_WRONG_5
	(declare (salience 20))
?f2<-	(status (time ?t) (step ?i)) 
	(exec (step ?i) (action DeliveryFood|DeliveryDrink) (param1 ?x) (param2 ?y))
	(not (Table (table-id ?tb) (pos-r ?x) (pos-c ?y)))
?f1<-	(agentstatus (step ?i) (time ?t))
?f5<-   (penalty ?p)
=> 
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 4)))
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 4))) 
	(assert (penalty (+ ?p	500000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1, caused by a delivery food or drink but cell isn't table.") 
		(param1 (+ ?p 500000))
	))
    (retract ?f5)
) 

(defrule order-completed	(declare (salience 18))
	(status (time ?t) (step ?i)) 
	(exec (step ?ii&:(= ?ii (- ?i 1))) (action DeliveryFood|DeliveryDrink) (param1 ?x) (param2 ?y))
	(Table (table-id ?tb) (pos-r ?x) (pos-c ?y))
	?f1 <- (orderstatus (step ?i) (requested-by ?tb) (food-order ?nfo) (food-deliv ?dfo&:(= ?dfo ?nfo)) 
		   (drink-order ?ndo) (drink-deliv ?ddo&:(= ?ddo  ?ndo)))
	=>
	(retract ?f1)
)

(defrule perc-load-generation1	(declare (salience 19))
	(status (time ?t) (step ?i)) 
	(exec (step ?ii&:(= ?ii (- ?i 1))) (action DeliveryFood|DeliveryDrink|LoadDrink|LoadFood))
    (agentstatus (step ?i)  (l-drink  0) (l-food 0))	
	=>      
	(assert (perc-load (time ?t) (step ?i) (load no)))
)

(defrule perc-load-generation2	(declare (salience 19))
	(status (time ?t) (step ?i)) 
	(exec (step ?ii&:(= ?ii (- ?i 1))) (action DeliveryFood|DeliveryDrink|LoadDrink|LoadFood))
    (agentstatus (step ?i)  (l-drink  ?ld) (l-food ?lf))
    (test (> (+ ?ld ?lf) 0))	
	=>
	(assert (perc-load (time ?t) (step ?i) (load yes)))
)


;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
;///////////////////////// 							REGOLE PER MOVIMENTO						/////////////////////////////////
;////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

(defrule forward-north-ok 
	(declare (salience 20))    
?f2<-	(status (step ?i) (time ?t)) 
	(exec (step ?i) (action  Forward))
?f1<-	(agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction north))
	(cell (pos-r =(+ ?r 1)) (pos-c ?c) (contains Empty|Parking))
=> 
	(modify ?f1 (pos-r (+ ?r 1)) (step (+ ?i 1)) (time (+ ?t 2)))
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 2)))		
;	(printout t " ENVIRONMENT:" crlf)
;	(printout t " - azione eseguita: Forward" crlf)	
;	(printout t " - in direzione: north" crlf)
;	(printout t " - nuova posizione dell'agente: (" (+ ?r 1) "," ?c ")" crlf)	
) 
(defrule forward-north-bump 
	(declare (salience 20))    
?f2<-	(status (step ?i) (time ?t)) 
	(exec (step ?i) (action  Forward))
?f1<-   (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction north))
	(cell (pos-r =(+ ?r 1)) (pos-c ?c) (contains ~Empty&~Parking))
?f3<-   (penalty ?p)
=> 
	(modify ?f1  (step (+ ?i 1)) (time (+ ?t 2)))
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 2)))
	(assert (perc-bump (step (+ ?i 1)) (time (+ ?t 2)) (pos-r ?r) (pos-c ?c) (direction north) (bump yes)))
	(retract ?f3)
	(assert (penalty (+ ?p 10000000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1 caused by a bump.") 
		(param1 (+ ?p 10000000))
	))
;	(printout t " ENVIRONMENT:" crlf)
;	(printout t " - penalità +10000000 (Forward-north-bump): " (+ ?p 10000000) crlf)
)
(defrule forward-south-ok 
	(declare (salience 20))    
?f2<-	(status (step ?i) (time ?t))  
	(exec (step ?i) (action  Forward))
?f1<-	(agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction south))
	(cell (pos-r =(- ?r 1)) (pos-c ?c) (contains Empty|Parking))
=> 
	(modify ?f1 (pos-r (- ?r 1)) (step (+ ?i 1)) (time (+ ?t 2)))
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 2)))	
;	(printout t " ENVIRONMENT:" crlf)
;	(printout t " - azione eseguita: Forward" crlf)	
;	(printout t " - in direzione: south" crlf)
;	(printout t " - nuova posizione dell'agente: (" (- ?r 1) "," ?c ")" crlf)
)
(defrule forward-south-bump 
	(declare (salience 20))    
?f2<-	(status (step ?i) (time ?t)) 
	(exec (step ?i) (action  Forward))
?f1<-   (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction south))
	(cell (pos-r =(- ?r 1)) (pos-c ?c) (contains ~Empty&~Parking))
?f3<-   (penalty ?p)
=> 
	(modify ?f1 (step (+ ?i 1)) (time (+ ?t 2)))
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 2)))
	(assert (perc-bump (step (+ ?i 1)) (time (+ ?t 2)) (pos-r ?r) (pos-c ?c) (direction south) (bump yes)))
	(retract ?f3)
	(assert (penalty (+ ?p 10000000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1 caused by a bump.") 
		(param1 (+ ?p 10000000))
	))
;	(printout t " ENVIRONMENT:" crlf)
;	(printout t " - penalità +10000000 (forward-south-bump): " (+ ?p 10000000) crlf)
) 
(defrule forward-west-ok 
	(declare (salience 20))    
?f2<-	(status (step ?i) (time ?t)) 
	(exec (step ?i) (action  Forward))
?f1<-	(agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction west))
	(cell (pos-r ?r) (pos-c =(- ?c 1)) (contains Empty|Parking))
=> 
	(modify ?f1 (pos-c (- ?c 1)) (step (+ ?i 1)) (time (+ ?t 2)))
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 2)))	
;	(printout t " ENVIRONMENT:" crlf)
;	(printout t " - azione eseguita: Forward" crlf)	
;	(printout t " - in direzione: west" crlf)
;	(printout t " - nuova posizione dell'agente: (" ?r "," (- ?c 1) ")" crlf)	
)
(defrule forward-west-bump 
	(declare (salience 20))    
?f2<-	(status (step ?i) (time ?t)) 
	(exec (step ?i) (action  Forward))
?f1<-   (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction west))
	(cell (pos-r ?r) (pos-c =(- ?c 1)) (contains ~Empty&~Parking))
?f3<-   (penalty ?p)
=> 
	(modify  ?f1  (step (+ ?i 1)) (time (+ ?t 2)))
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 2)))
	(assert (perc-bump (step (+ ?i 1)) (time (+ ?t 2)) (pos-r ?r) (pos-c ?c) (direction west) (bump yes)))
	(retract ?f3)
	(assert (penalty (+ ?p 10000000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1 caused by a bump.") 
		(param1 (+ ?p 10000000))
	))
;	(printout t " ENVIRONMENT:" crlf)
;	(printout t " - penalità +10000000 (forward-west-bump): " (+ ?p 10000000) crlf)
)
(defrule forward-east-ok 
	(declare (salience 20))    
?f2<-	(status (step ?i) (time ?t)) 
	(exec (step ?i) (action  Forward))
?f1<-	(agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction east))
	(cell (pos-r ?r) (pos-c =(+ ?c 1)) (contains Empty|Parking))
=> 
	(modify  ?f1 (pos-c (+ ?c 1)) (step (+ ?i 1)) (time (+ ?t 2)))
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 2)))	
;	(printout t " ENVIRONMENT:" crlf)
;	(printout t " - azione eseguita: Forward" crlf)	
;	(printout t " - in direzione: east" crlf)
;	(printout t " - nuova posizione dell'agente: (" ?r "," (+ ?c 1) ")" crlf)
) 
(defrule forward-east-bump 
	(declare (salience 20))    
?f2<-	(status (step ?i) (time ?t)) 
	(exec (step ?i) (action  Forward))
?f1<-   (agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction east))
	(cell (pos-r ?r) (pos-c =(+ ?c 1)) (contains ~Empty&~Parking))
?f3<-   (penalty ?p)
=> 
	(modify  ?f1  (step (+ ?i 1)) (time (+ ?t 2)))
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 2)))
	(assert (perc-bump (step (+ ?i 1)) (time (+ ?t 2)) (pos-r ?r) (pos-c ?c) (direction east) (bump yes)))
	(retract ?f3)
	(assert (penalty (+ ?p 10000000)))
	(assert (printGUI 
		(time ?t) (step ?i) (source "ENV") (verbosity 1) 
		(text  "Penalty increased to %p1 caused by a bump.") 
		(param1 (+ ?p 10000000))
	))
;	(printout t " ENVIRONMENT:" crlf)
;	(printout t " - penalità +10000000 (forward-east-bump): " (+ ?p 10000000) crlf)
)
(defrule turnleft1
	(declare (salience 20))      
?f2<-	(status (step ?i) (time ?t)) 
	(exec (step ?i) (action  Turnleft))
?f1<-	(agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction west))
	(cell (pos-r ?r) (pos-c ?c))
=>	
	(modify  ?f1 (direction south) (step (+ ?i 1)) (time (+ ?t 1)) )
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)) )		
;	(printout t " ENVIRONMENT:" crlf)
;	(printout t " - azione eseguita: turnleft" crlf)	
;	(printout t " - nuova direzione dell'agente: south" crlf)
)
(defrule turnleft2
	(declare (salience 20))      
?f2<-	(status (step ?i) (time ?t)) 
	(exec (step ?i) (action  Turnleft))
?f1<-	(agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction south))
	(cell (pos-r ?r) (pos-c ?c))
=> 
	(modify  ?f1 (direction east) (step (+ ?i 1)) (time (+ ?t 1)))
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)))		
;	(printout t " ENVIRONMENT:" crlf)
;     	(printout t " - azione eseguita: turnleft" crlf)	
;     	(printout t " - nuova direzione dell'agente: east" crlf)
)
(defrule turnleft3
	(declare (salience 20))      
?f2<-	(status (step ?i) (time ?t)) 
	(exec (step ?i) (action  Turnleft))
?f1<-	(agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction east))
	(cell (pos-r ?r) (pos-c ?c))
=> 
	(modify  ?f1 (direction north) (step (+ ?i 1)) (time (+ ?t 1)))
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)))		
;	(printout t " ENVIRONMENT:" crlf)
;	(printout t " - azione eseguita: turnleft" crlf)	
;	(printout t " - nuova direzione dell'agente: north" crlf)
)
(defrule turnleft4
	(declare (salience 20))      
?f2<-	(status (step ?i) (time ?t)) 
	(exec (step ?i) (action  Turnleft))
?f1<-	(agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction north))
	(cell (pos-r ?r) (pos-c ?c))
=> 
	(modify  ?f1 (direction west) (step (+ ?i 1)) (time (+ ?t 1)))
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)))		
;	(printout t " ENVIRONMENT:" crlf)
;	(printout t " - azione eseguita: turnleft" crlf)	
;	(printout t " - nuova direzione dell'agente: west" crlf)
)
(defrule turnright1
	(declare (salience 20))      
?f2<-	(status (step ?i) (time ?t)) 
	(exec (step ?i) (action  Turnright))
?f1<-	(agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction west))
	(cell (pos-r ?r) (pos-c ?c))
=> 
	(modify  ?f1 (direction north) (step (+ ?i 1))  (time (+ ?t 1)))
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)))		
;	(printout t " ENVIRONMENT:" crlf)
;	(printout t " - azione eseguita: turnright" crlf)	
;	(printout t " - nuova direzione dell'agente: north" crlf)
)
(defrule turnright2
	(declare (salience 20))      
?f2<-	(status (step ?i) (time ?t)) 
	(exec (step ?i) (action  Turnright))
?f1<-	(agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction south))
	(cell (pos-r ?r) (pos-c ?c))
=> 
	(modify  ?f1 (direction west) (step (+ ?i 1)) (time (+ ?t 1)))
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)))		
;	(printout t " ENVIRONMENT:" crlf)
;	(printout t " - azione eseguita: turnright" crlf)	
;	(printout t " - nuova direzione dell'agente: west" crlf)
)
(defrule turnright3
	(declare (salience 20))      
?f2<-	(status (step ?i) (time ?t)) 
	(exec (step ?i) (action  Turnright))
?f1<-	(agentstatus (step ?i) (pos-r ?r) (pos-c ?c) (direction east))
	(cell (pos-r ?r) (pos-c ?c))
=> 
	(modify ?f1 (direction south) (step (+ ?i 1)) (time (+ ?t 1)))
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)))		
;	(printout t " ENVIRONMENT:" crlf)
;	(printout t " - azione eseguita: turnright" crlf)	
;	(printout t " - nuova direzione dell'agente: south" crlf)
)
(defrule turnright4
	(declare (salience 20))      
?f2<-	(status (step ?i) (time ?t)) 
	(exec (step ?i) (action  Turnright))
?f1<-	(agentstatus (step ?i) (pos-r ?r) (pos-c ?c)(direction north))
	(cell (pos-r ?r) (pos-c ?c))
=> 
	(modify ?f1 (direction east) (step (+ ?i 1)) (time (+ ?t 1)))
	(modify ?f2 (step (+ ?i 1)) (time (+ ?t 1)))		
;	(printout t " ENVIRONMENT:" crlf)
;	(printout t " - azione eseguita: turnright" crlf)	
;	(printout t " - nuova direzione dell'agente: east" crlf)
)
;// __________________________________________________________________________________________
;// REGOLE PER PERCEZIONI VISIVE (N,S,E,O)          
;// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ 
(defrule percept-north	(declare (salience 5))
	?f1	<-	(agentstatus (step ?i) (time ?t&:(> ?t 0)) (pos-r ?r) (pos-c ?c) (direction north)) 
	(cell (pos-r =(+ ?r 1))	(pos-c =(- ?c 1)) (contains ?x1))
	(cell (pos-r =(+ ?r 1)) (pos-c ?c)  	(contains ?x2))
	(cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)) (contains ?x3))
	(cell (pos-r ?r) 		(pos-c =(- ?c 1)) (contains ?x4))
	(cell (pos-r ?r) 		(pos-c ?c)  	(contains ?x5))
	(cell (pos-r ?r) 		(pos-c =(+ ?c 1)) (contains ?x6))
	(cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)) (contains ?x7))
	(cell (pos-r =(- ?r 1)) (pos-c ?c)  	(contains ?x8))
	(cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)) (contains ?x9))
=> 
	(assert 	
		(perc-vision (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) (direction north) 
			(perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
			(perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
			(perc7 ?x7) (perc8 ?x8) (perc9 ?x9)
		)
	)
	(focus MAIN)
)

(defrule percept-south	(declare (salience 5))
	?f1	<-	(agentstatus (step ?i) (time ?t&:(> ?t 0)) (pos-r ?r) (pos-c ?c) (direction south)) 
	(cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)) (contains ?x1))
	(cell (pos-r =(- ?r 1)) (pos-c ?c)  	(contains ?x2))
	(cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)) (contains ?x3))
	(cell (pos-r ?r)  	(pos-c =(+ ?c 1)) (contains ?x4))
	(cell (pos-r ?r)  	(pos-c ?c)  	(contains ?x5))
	(cell (pos-r ?r)  	(pos-c =(- ?c 1)) (contains ?x6))
	(cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)) (contains ?x7))
	(cell (pos-r =(+ ?r 1)) (pos-c ?c)  	(contains ?x8))
	(cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)) (contains ?x9))
=> 
	(assert 	
		(perc-vision (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) (direction south) 
			(perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
			(perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
			(perc7 ?x7) (perc8 ?x8) (perc9 ?x9)
		)
	)
	(focus MAIN)
)

(defrule percept-east	(declare (salience 5))
	?f1	<- (agentstatus (step ?i) (time ?t&:(> ?t 0)) (pos-r ?r) (pos-c ?c) (direction east)) 
	(cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)) (contains ?x1))
	(cell (pos-r ?r)  	(pos-c =(+ ?c 1)) (contains ?x2))
	(cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)) (contains ?x3))
	(cell (pos-r =(+ ?r 1)) (pos-c ?c)  	(contains ?x4))
	(cell (pos-r ?r)  	(pos-c ?c)  	(contains ?x5))	
	(cell (pos-r =(- ?r 1)) (pos-c ?c)  	(contains ?x6))
	(cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1))	(contains ?x7))
	(cell (pos-r ?r)		(pos-c =(- ?c 1)) (contains ?x8))
	(cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)) (contains ?x9))
=> 	
	(assert 	
		(perc-vision (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) (direction east) 
			(perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
			(perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
			(perc7 ?x7) (perc8 ?x8) (perc9 ?x9)
		)
	)
	(focus MAIN)
)

(defrule percept-west	(declare (salience 5))
	?f1	<-	(agentstatus (step ?i) (time ?t&:(> ?t 0)) (pos-r ?r) (pos-c ?c) (direction west)) 
	(cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)) (contains ?x1))
	(cell (pos-r ?r)  	(pos-c =(- ?c 1)) (contains ?x2))
	(cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)) (contains ?x3))
	(cell (pos-r =(- ?r 1)) (pos-c ?c)  	(contains ?x4))
	(cell (pos-r ?r)  	(pos-c ?c)  	(contains ?x5))
	(cell (pos-r =(+ ?r 1)) (pos-c ?c)  	(contains ?x6))
	(cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)) (contains ?x7))	
	(cell (pos-r ?r)  	(pos-c =(+ ?c 1)) (contains ?x8))	
	(cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)) (contains ?x9))
	=> 
	(assert 	
		(perc-vision (step ?i) (time ?t) (pos-r ?r) (pos-c ?c) (direction west) 
			(perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
			(perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
			(perc7 ?x7) (perc8 ?x8) (perc9 ?x9)
		)
	)
	(focus MAIN)
)