
int : PIPESTAGES= 0;
int: TMAX;
int: V;
set of int: VERTICES= 1..V;

int: NMAX= 32;

array[VERTICES] of set of VERTICES: successors;
array[VERTICES] of set of VERTICES: predecessors;
int :E;
array[1..E, 1..2] of 1..V: edges;

% variables
array [VERTICES] of var 1..TMAX: T;
array [VERTICES] of var 1..3: L;
array [VERTICES] of var 0..8: top_pow_L;
var int: sum_pow_L= sum(top_pow_L);
array [VERTICES] of var bool: top;
array [VERTICES] of var bool: bottom;

array [1..TMAX] of var 0..NMAX: sum_top;
%array [1..TMAX] of var set of VERTICES: t_to_v;

array [1..3] of int: power_func= [2, 4, 8];

% pipeline hazard constraint
constraint forall(v in 1..V) (
      forall (s in successors[v]) (
         (T[s] = T[v]) \/ (T[s] > T[v] + PIPESTAGES)
      )
    );

% level constraint
constraint forall(e in 1..E) (
    if (T[edges[e, 1]] = T[edges[e, 2]]) then 
      L[edges[e, 2]] >= L[edges[e, 1]] + 1
    endif
  );

constraint forall(v in 1..V) (
    bottom[v] -> L[v] = 1
  );
% top constraint
constraint forall(v in 1..V) (
    top[v] = forall(s in successors[v]) (T[s] > T[v])
  );

constraint forall(v in 1..V) (
    bottom[v] = forall(p in predecessors[v]) (T[p] < T[v])
  );

constraint forall(v in 1..V) (
    if (top[v]) then
      top_pow_L[v] = power_func[L[v]]
    else
      top_pow_L[v] = 0
    endif
  );

% sum constraint
%constraint forall(t in 1..TMAX) (
%    sum_top[t] = sum([ L[v] | v in VERTICES where T[v] = t])
%    sum_top[t] = sum([power_func[L[v]] | v in VERTICES where (T[v] = t) /\
%    top[v]])
%    sum_top[t] = sum(v in t_to_v[t] where top[v]) (power_func[L[v]])
%  );

% channeling constraint
%include "int_set_channel.mzn";
%constraint int_set_channel(T, t_to_v);

% global constraints
%include "partition_set.mzn";
%constraint partition_set(t_to_v, VERTICES);

% set sizes cannot increse beyond a given value
%constraint forall (t in 1..TMAX) (
%    card(t_to_v[t]) <= NMAX
%  );

%include "cumulative.mzn";
%constraint cumulative(T, [1 | v in 1..V], [1 | v in 1..V], NMAX);

%include "at_most_int.mzn";
%constraint forall(t in 1..TMAX) (at_most_int(NMAX, T, t));

solve minimize sum_pow_L;
%solve minimize max(T);
%solve  :: int_search(L, anti_first_fail, indomain_min, complete) minimize sum_pow_L;

output ["sum_pow_L = \(sum_pow_L/NMAX) \n",
  "top_pow_L = \(top_pow_L)\n",
  "T = \(T)\n"];


