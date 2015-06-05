% Oggetti dominio cargo
 
cargo(c1).
cargo(c2).

airport(sfo).
airport(jfk).

plane(p1).
plane(p2).

#const lastlevel = 2.
level(0..lastlevel).
status(0..lastlevel+1).

% stato iniziale
in(c1, sfo, 0).
in(c2, jfk, 0).
in(p1, sfo, 0).
in(p2, jfk, 0).

% stato finale
goal :- in(c1, jfk, lastlevel+1), in(c2, sfo, lastlevel+1).
:- not goal.

% AZIONI (possono essere eseguite in parallelo) ed almeno una di esse deve essere eseguita

1 {
	load(C,P,A,S) : cargo(C), plane(P), airport(A); 
	unload(C,P,A,S) : cargo(C), plane(P), airport(A); 
	fly(P,F_A, T_A,S) : airport(T_A), plane(P), airport(F_A)
} :- level(S).

% EFFETTI

in(C, P, S+1) :- load(C, P, A, S), status(S), plane(P), in(C, A, S), in(P, A, S).
in(C, A, S+1) :- unload(C, P, A, S), status(S), plane(P), in(C, P, S), in(P, A, S).
in(P, T_A, S+1) :- fly(P, F_A, T_A, S), status(S), plane(P), in(P, F_A, S), airport(F_A), airport(T_A).


% PRECONDIZIONI
:- fly(P, F_A, T_A, S), F_A = T_A.


% REGOLE DI PERSISTENZA
in(C, P, S+1) :- in(C, P, S), status(S), not -in(C, P, S+1).
in(C, A, S+1) :- in(C, A, S), status(S), not -in(C, A, S+1).
in(P, A, S+1) :- in(P, A, S), status(S), not -in(P, A, S+1).

% REGOLE CAUSALI
-in(C, P1, S) :- in(C, P, S), status(S), plane(P1), cargo(C), P != P1.
-in(C, A1, S) :- in(C, A, S), status(S), airport(A1), cargo(C), A1 != A.
-in(P, A1, S) :- in(P, A, S), status(S), airport(A1), plane(P), A != A1.

#show load/4.
#show unload/4.
#show fly/4.
#show in/3.
#show -in/3.