(deftemplate container
   (slot tip (type SYMBOL))
   (slot capacitate_actuala (type INTEGER))
   (slot capacitate_maxima (type INTEGER))
)

;(deseu <id> < tip>)
(defrule R1-incarca-din-fisier
     ;(inactiv)
    (declare (salience 100))
	(ora ?x)
	=>
	(if (and (>= ?x 7) (< ?x 22))
	then
	(open deseuri.txt fisierD)
	(open rezultate.txt fout "w")
    (assert (fisier deschis))
    (bind ?linie (readline fisierD))
    (while (neq ?linie EOF) do
        (bind ?desId (gensym*))
        (assert (deseu ?desId (explode$ ?linie)))
        (bind ?linie (readline fisierD))
    )
    (assert (faza oprire))
	(close fisierD))
	(if (and (< ?x 7)(>= ?x 22))
	then
	(assert (Masina-scoasa-din-functiune)))
	
)



;(deseu <id> < tip>)
;(sortat <id> < tip> <reciclabilitate>)
(defrule R2-determina-reciclabilitate
 
    (declare (salience 90))
	 ;(inactiv)
    ?d <- (deseu ?id ?tip)
    =>
    (if (or (eq ?tip plastic) (eq ?tip metal) (eq ?tip white-glass)
            (eq ?tip green-glass) (eq ?tip brown-glass) (eq ?tip paper)
            (eq ?tip cardboard))
        then
        (printout fout "Deseu reciclabil" crlf)
        (assert (sortat ?id ?tip reciclabil))
		(assert (container (tip ?tip) (capacitate_actuala 0) (capacitate_maxima 100)))
		(retract ?d)
        else
        (if (or (eq ?tip biological) (eq ?tip battery))
            then
            (printout fout "Deseu nereciclabil" crlf)
            (assert (sortat ?id ?tip nereciclabil))
			(retract ?d)
            else
            (printout fout "Nu se poate determina reciclabilitatea, tipul deșeului necunoscut" crlf)
			(retract ?d)
        )
    )
)


;(container (tip ?tip) (capacitate_actuala ?capacitate_actuala) (capacitate_maxima ?capacitate_maxima))
(defrule R3-adauga-deseu-reciclabil-in-container
 
    (declare (salience 80))
	  ; (inactiv)
    ?deseu <- (sortat ?id ?tip reciclabil)
    ?container <- (container (tip ?tip) (capacitate_actuala ?capacitate_actuala) (capacitate_maxima ?capacitate_maxima))
    (test (< ?capacitate_actuala ?capacitate_maxima))
    =>
    (printout t"Deseu de " ?tip " adaugat in containerul de " ?tip ". Capacitate actuala: " (+ ?capacitate_actuala 1) crlf)
    (modify ?container (capacitate_actuala (+ ?capacitate_actuala 1)))
    (retract ?deseu)
    (if (= (+ ?capacitate_actuala 1) ?capacitate_maxima) 
        then
        (printout fout "Atentie! Containerul de " ?tip " este acum plin." crlf))
)

		
(defrule R4-acordare-recompensa

   (declare (salience 60))
     ; (inactiv)
   ?container <- (container (tip ?tip) (capacitate_actuala ?capacitate_actuala) (capacitate_maxima ?capacitate_maxima))
   =>

   (if (or (eq ?tip plastic) (eq ?tip metal) (eq ?tip white-glass)
           (eq ?tip green-glass) (eq ?tip brown-glass))
       then
       (bind ?recompensa (* ?capacitate_actuala 1))
       (printout fout "Recompensa de " ?recompensa " lei acordata pentru " ?tip "." crlf)
        
   else
       (if (or (eq ?tip cardboard) (eq ?tip paper))
           then
           (bind ?recompensa (* ?capacitate_actuala 0.5))
           (printout fout "Recompensa de " ?recompensa " lei acordata pentru " ?tip "." crlf)
           
		   
		   )))

(defrule Rinchidere
 (declare (salience 0))
 =>
   (close fout)
   )

(deffacts bf
 (faza verificare-ora)
 )
 

(defrule R5-verificare-oră
    (declare (salience 110))
    ?a <- (faza verificare-ora)
    =>
	 (bind ?time (gm-time))
	 (printout t ?time crlf)
     (bind ?h1 (nth$ 4 ?time))
	 (bind ?hours (+ ?h1 3))
     (printout t ?hours crlf)
        (retract ?a)
        (assert (ora ?hours)))
		

