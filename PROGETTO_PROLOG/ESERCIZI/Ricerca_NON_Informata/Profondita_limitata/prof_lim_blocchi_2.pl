% Definizione azioni applicabili ed eseguibili
% Specifica delle azioni mediante precondizioni ed effetti alla STRIPS
% Gli stati sono rappresentati con insiemi ordinati

apply(pickup(X),S):-
	block(X),
	ord_memberchk(ontable(X),S),
	ord_memberchk(clear(X),S),
	ord_memberchk(handempty,S).
	
apply(putdown(X),S):-
	block(X),
	ord_memberchk(holding(X),S).
	
apply(stack(X,Y),S):-
	block(X), block(Y), X\=Y,
	ord_memberchk(holding(X),S),
	ord_memberchk(clear(Y),S).

apply(unstack(X,Y),S):-
	block(X), block(Y), X\=Y,
	ord_memberchk(on(X,Y),S),
	ord_memberchk(clear(X),S),
	ord_memberchk(handempty,S).
	
	
transform(pickup(X),S1,S2):-
	block(X),
	list_to_ord_set([ontable(X),clear(X),handempty],States_to_Remove),
	ord_subtract(S1,States_to_Remove,S),
	list_to_ord_set([holding(X)],States_to_Add),
	ord_union(S,States_to_Add,S2).
	
transform(putdown(X),S1,S2):-
	block(X),
	list_to_ord_set([holding(X)],States_to_Remove),
	ord_subtract(S1,States_to_Remove,S),
	list_to_ord_set([ontable(X),clear(X),handempty],States_to_Add),
	ord_union(S,States_to_Add,S2).

transform(stack(X,Y),S1,S2):-
	block(X), block(Y), X\=Y,
	list_to_ord_set([holding(X),clear(Y)],States_to_Remove),
	ord_subtract(S1,States_to_Remove,S),
	list_to_ord_set([on(X,Y),clear(X),handempty],States_to_Add),
	ord_union(S,States_to_Add,S2).

transform(unstack(X,Y),S1,S2):-
	block(X), block(Y), X\=Y,
	list_to_ord_set([on(X,Y),clear(X),handempty],States_to_Remove),
	ord_subtract(S1,States_to_Remove,S),
	list_to_ord_set([holding(X),clear(Y)],States_to_Add),
	ord_union(S,States_to_Add,S2).


% Definizione dominio - Stato initial - Stato finale

:- use_module(library(lists)).
:- use_module(library(ordsets)).

% esempio Prof. Torasso
block(a).
block(b).
block(c).
block(d).
block(e).
block(f).
block(g).
block(h).


initial(S):-
	list_to_ord_set([clear(a), clear(c), clear(d), clear(e), clear(f), clear(g), clear(h), on(a,b), ontable(b), ontable(c), ontable(d), ontable(e), ontable(f), ontable(g), ontable(h), handempty],S).

goal(G):- list_to_ord_set([on(a,b),on(b,c),on(c,d),on(d,e),
	ontable(e)],G).

final(S):- goal(G), ord_subset(G,S).

% PASSO BASE della ricorsione
deep_search_lim(S,_,[]) :- final(S), !.		% utilizzo una variabile anonima perche` il limite
											% lo controllo nel passo ricorsivo

%PASSO Ricorsivo
deep_search_lim(S, Limit, [Action|Tail]) :-
	New_Limit is Limit - 1,
	New_Limit > 0, 
	apply(Action, S),
	transform(Action, S, S_Updated),
	deep_search_lim(S_Updated, New_Limit, Tail).

find_solution :-
	initial(S),
	Limit is 13,			%imposto il limite della profondita'	
	statistics(walltime,[Start,_]),
	deep_search_lim(S, Limit, List),
	statistics(walltime,[End,_]),
	Time is End - Start,
	write(List),
	write(Time).