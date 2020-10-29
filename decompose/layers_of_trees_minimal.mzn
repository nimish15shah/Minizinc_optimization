
int : PIPESTAGES= 0;
int: TMAX;
int: V;
set of int: VERTICES= 1..V;

int: D= 3;
int: NMAX= 32;

array[VERTICES] of set of VERTICES: successors;
array[VERTICES] of int: SLACK_DICT;
array[VERTICES] of set of VERTICES: predecessors;
int :E;
array[1..E, 1..2] of 1..V: edges;

% variables
array [VERTICES] of var 1..TMAX: T;
array [VERTICES] of var 1..D: L;

array [VERTICES] of var bool: top;
array [VERTICES] of var bool: bottom;


%array [VERTICES] of var 0..D: L_of_top = [top[v] * L[v] | v in VERTICES];
%var int: L_count = 4*count(L_of_top, 3) + 2*count(L_of_top,2)  +
%count(L_of_top,1);
%var int: L_count = sum([count(L, l)/(pow(2, 3-l)) | l in 1..D]);
%var int: L_count = sum([top[v] * (pow(2,L[v]) - 1)| v in VERTICES]);

var int: tot_cost= sum(top);
%var int: tot_cost= L_count;

% pipeline hazard constraint
constraint forall(v in 1..V) (
      forall (s in successors[v]) (
         (T[s] >= T[v]) /\ (T[s] <= T[v] + SLACK_DICT[v])
      )
    );

% level constraint
constraint forall(e in 1..E) (
    L[edges[e, 2]] >= (T[edges[e, 1]] = T[edges[e, 2]])*L[edges[e, 1]] + 1
  );

constraint forall(v in 1..V) (
    bottom[v] == (L[v] = 1)
  );
% top constraint
constraint forall(v in 1..V) (
    top[v] = 1 - (forall(s in successors[v]) (T[s] = T[v]))
  );

constraint forall(v in 1..V) (
    bottom[v] = forall(p in predecessors[v]) (T[p] < T[v])
  );


% fix the final node
constraint T[V] == TMAX;

solve minimize tot_cost;

output [
%"approx_blocks = \(L_count/NMAX) \n",
%    "\(count(L,3)), \(count(L,2)), \(count(L,1)) \n"
  "T[root] = \(T[V])\n",
  ];


