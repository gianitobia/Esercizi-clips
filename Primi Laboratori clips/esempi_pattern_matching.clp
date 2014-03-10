#ESEMPIO 1
         

(deffacts data-facts  
        (data 1.0 blue "red")  
        (data 1 blue)  
        (data 1 blue red)  
        (data 1 blue RED)  
        (data 1 blue red 6.9)
        (pippo)
        (data 2 red)
)
        
(defrule find-data1
  (data ? blue red $?)
  =>  (assert (r1))
)
  
  
(defrule find-data2
  (data ?x blue red $?)
  => (assert (result ?x))
)

(defrule find-data-3
  (data ?x ?y ?z)
  =>
  (assert (primo ?x) (secondo ?y) (terzo ?z))
)
  
 
(defrule find-data-4
  (data ?x $?y ?z)
  =>
  (printout t "?x = " ?x crlf
              "?y = " ?y crlf
              "?z = " ?z crlf
              "------" crlf)
)

#ESEMPIO 2

#Si noti che l'esempio illustra bene solo le problematiche di 
#pattern matching in fatti non ordinati , mentre lascia a desiderare per la semantica
#(non controlla casi di omonimia, per cui e' possibile che nipote sia piu' vecchio del nonno)
 
(deftemplate person  (slot name)  (slot age)  (slot father))
 
(deffacts people  (person (name Joe) (age 20) ( father Bill)) 
                  (person (name Bob) (age 20)  (father Tom))  
                  (person (name Joe) (age 34) (father Luis))
                  (person (name Sue) (age 34) (father Luis))
                  (person (name Sue) (age 20)  (father George))
                  (person (name Bill) (age 54) (father Joseph))
                  (person (name Joseph) (age 81)(father Bob))
)
                  
                  

(defrule getperson1
         (person (name Joe) (age ?x))
         =>  (assert (eta Joe ?x))
)
 
(defrule getperson2
          (person (age ?x&20|21|22) (name ?y))
          => (assert (eta ?y ?x))
)
 
 (defrule grandparent
 	(person (name ?x) (father ?y))
 	(person (name ?y) (father ?z))
 	=> (assert (gp ?z ?x))
)

#ESEMPIO 3
#Confronti fra variabili
(deffacts datinum
   (data 3)
   (data 6)
   (data 14)
   (data 1)
)
   
(defrule example-4
   (data ?y)	
   (data ?x&:(> ?x ?y))
   => (assert (larger ?x ?y))
)