include "alldifferent.mzn";
%include "alldifferent_except_0.mzn";
include "nvalue_fn.mzn";
include "decreasing_int.mzn";

int: T;
int: D;
int: N_per_tree= pow(2, D) - 1;
int: N= T * N_per_tree;

set of int: NODES = 1..N;
int: V;
set of int: VERTICES= 1..V;

%set of VERTICES: Done;
array [0..V] of var bool: Done;

array[NODES] of set of NODES: first_n;
array[NODES] of set of NODES: second_n;
array[NODES] of set of NODES: successor_n;

array[VERTICES] of VERTICES: first;
array[VERTICES] of VERTICES: second;
array[VERTICES] of set of VERTICES: successors;

array[0..V] of 0..V: dfs_lvl;
var 0..V: dfs_max;
var 0..V: dfs_min;

array [NODES] of var 0..(V-1): active_v;
%array [NODES] of var 0..(7*V-1): cumm_v;

%array [NODES] of var bool: node_active;
array [0..V] of var bool: x;
% convexity constraint
array[VERTICES] of var bool: a;
array[VERTICES] of var bool: d;

var 1..N: total_active_vertices; 

ann: search_ann1;
ann: search_ann2;
ann: search_ann3;
search_ann1 = int_search(active_v, input_order, indomain_max);
search_ann2 = int_search([total_active_vertices] ++ x, input_order, indomain_min);
search_ann3 = int_search(a ++ d, input_order, indomain_min);

%solve :: seq_search ([search_ann1, search_ann2, search_ann3]) maximize total_active_vertices;
solve maximize total_active_vertices;
%solve maximize V*total_active_vertices - (dfs_max - dfs_min);
%solve maximize total_active_vertices - ((1/V)*(dfs_max - dfs_min));
%solve maximize nvalue(active_v);

constraint forall(n in NODES) (
              forall (f in first_n[n]) (
                if (active_v[n] != 0) then
                  if ((Done[first[active_v[n]]] == false) ) then
                    active_v[f] = first[active_v[n]]
                  else 
                    active_v[f] = 0  
                  endif
                endif
              )
          );

constraint forall(n in NODES) (
              forall (f in second_n[n]) (
                if (active_v[n] != 0) then
                  if (Done[second[active_v[n]]] == false) then
                    active_v[f] = second[active_v[n]]
                  else 
                    active_v[f] = 0  
                  endif
                endif
              )
          );

%constraint forall(t in 0..(T-1)) (
%              forall (d in 0..(D-2)) (
%                forall (p in 0..(pow(2,d) - 1)) (
%                  active_v[t*N_per_tree + pow(2,d + 1) - 1 + 2*p + 1 + 1] = second[active_v[t*N_per_tree + pow(2,d) - 1 + p + 1]] \/
%%                  active_v[t*N_per_tree + pow(2,d + 1) - 1 + 2*p + 1 + 1] = 0
%                  active_v[t*N_per_tree + pow(2,d + 1) - 1 + 2*p + 1 + 1] = active_v[t*N_per_tree + pow(2,d) - 1 + p + 1]
%                )
%              )
%           );

constraint total_active_vertices = sum(i in 1..V)(x[i]);
%constraint forall(v in active_set)
%              (has_element(v, active_v));              

%constraint active_v[1] = first[active_v[3]] \/ 
%           active_v[1] = active_v[3];
%     
%constraint active_v[2] = second[active_v[3]] \/ 
%           active_v[2] = active_v[3];
%     
%constraint active_v[4] = first[active_v[6]] \/ 
%           active_v[4] = active_v[6];
%     
%constraint active_v[5] = second[active_v[6]] \/ 
%           active_v[5] = active_v[6];
%     
%constraint active_v[3] = first[active_v[7]] \/ 
%           active_v[3] = active_v[7];
%     
%constraint active_v[6] = second[active_v[7]] \/ 
%           active_v[6] = active_v[7];

%constraint forall(i in NODES) (
%           x[active_v[i]] = true
%         );
constraint forall(v in VERTICES) (
           x[v] = (has_element(v, active_v)) 
         );
     
% Top nodes should be all different
constraint decreasing_int([active_v[t*N_per_tree + 1] | t in 0..(T-1)]);

%constraint forall(n in NODES) (
%            cumm_v[n] = active_v[n] + sum(f in first_n[n]) (active_v[f]) + sum(s in second_n[n]) (active_v[s])
%          );

constraint forall(n in NODES) (
        forall(f in first_n[n]) (
          forall(s in second_n[n]) (
          (active_v[f] != 0)
            -> active_v[f] > active_v[s]
          )
        )
      );

% Second row elements are all different
constraint alldifferent([active_v[t*N_per_tree + 1] | t in 0..(T-1)]  
            ++ [active_v[t*N_per_tree + 2] | t in 0..(T-1)]
            ++ [active_v[t*N_per_tree + 3] | t in 0..(T-1)]
            );
constraint alldifferent([active_v[1], active_v[2], active_v[3], active_v[8], active_v[9], active_v[10], active_v[15],active_v[16], active_v[17], active_v[22], active_v[23], active_v[24]]
            );


%constraint alldifferent([active_v[t*N_per_tree + 4] | t in 0..(T-1)]  ++ [active_v[t*N_per_tree + 5] | t in 0..(T-1)]);
%constraint alldifferent([active_v[t*N_per_tree + 6] | t in 0..(T-1)]  ++ [active_v[t*N_per_tree + 7] | t in 0..(T-1)]);

%constraint alldifferent(active_v);

constraint forall(t in 0..T-1) ( active_v[t*N_per_tree + 4] != 0 -> active_v[t*N_per_tree + 4] > active_v[t*N_per_tree + 5]);
constraint forall(t in 0..T-1) ( active_v[t*N_per_tree + 6] != 0 -> active_v[t*N_per_tree + 6] > active_v[t*N_per_tree + 7]);
constraint forall(t in 0..T-1) ( active_v[t*N_per_tree + 4] = 0 -> active_v[t*N_per_tree + 5] != 0 );
constraint forall(t in 0..T-1) ( active_v[t*N_per_tree + 6] = 0 -> active_v[t*N_per_tree + 7] != 0 );

% second nd third level are not zero
constraint forall(t in 0..T-1) ( active_v[t*N_per_tree + 2] != 0 );
constraint forall(t in 0..T-1) ( active_v[t*N_per_tree + 3] != 0 );

constraint x[V] = false;
%constraint (V in active_set) = false;

% Symmetry breaking
% Top nodes have increasing values
%constraint value_precede_chain(VERTICES, [active_v[t*N_per_tree + 1] | t in 0..(T-1)]);
%constraint seq_precede_chain(array1d([active_v[1]]));

% convexity constraints
%constraint forall(v in VERTICES) (
%              a[v] >= x[v]
%            );
%constraint forall(v in VERTICES) (
%              a[v] >= a[first[v]]
%            );
%constraint forall(v in VERTICES) (
%              a[v] >= a[second[v]]
%            );
constraint forall(v in VERTICES) (
%              a[v] <= x[v] + a[first[v]] + a[second[v]]
              a[v] = (x[v] \/ a[first[v]] \/ a[second[v]])
            );
%constraint forall(v in VERTICES) (
%            if x[v] = true then a[v] = true
%            else a[v] = a[first[v]] \/ a[second[v]]
%            endif
%            );

%constraint forall(v in VERTICES) (
%              d[v] >= x[v]
%            );

%constraint forall(v in VERTICES) (
%%              trace("first: \(v) , \(first[v])\n", d[first[v]] >= d[v])
%              d[first[v]] >= d[v]
%            );

%constraint forall(v in VERTICES) (
%%              trace("second: \(v) , \(second[v])\n", d[second[v]] >= d[v])
%              d[second[v]] >= d[v]
%            );

constraint forall(v in VERTICES) (
%              1 - x[v] + a[v] + d[v] <= 2
               (a[v] /\ d[v]) = x[v]
            );

constraint forall(v in VERTICES) (
%              trace("\(v), \(successors[v]) \n",d[v] <= x[v] + sum(s in successors[v]) (d[s]))
%              d[v] <= x[v] + sum(s in successors[v]) (d[s])
              d[v] = (x[v] \/ exists([d[s] | s in successors[v]]))
%              trace("\(v), \(successors[v]) \n",d[v] = x[v] \/ exist(successors[v]))
            );

% if predecessors node is 0, it is marked as input
constraint forall(n in NODES) (
          forall(f in first_n[n]) (
            ((active_v[n] != 0) /\ (active_v[f] = 0))-> (x[first[active_v[n]]] = false)
          )
        );

constraint forall(n in NODES) (
          forall(f in second_n[n]) (
            ((active_v[n] != 0) /\ (active_v[f] = 0))-> (x[second[active_v[n]]] = false)
          )
        );
% inputs of lowest level nodes cannot be mapped
constraint forall(t in 0..(T-1)) (
              forall (d in (D-1)..(D-1)) (
                forall (p in 0..(pow(2,d) - 1)) (
                    (active_v[t*N_per_tree + pow(2,d) - 1 + p + 1] != 0) -> (x[first[active_v[t*N_per_tree + pow(2,d) - 1 + p + 1]]] = false)
                  )
                )
              );
          
constraint forall(t in 0..(T-1)) (
              forall (d in (D-1)..(D-1)) (
                forall (p in 0..(pow(2,d) - 1)) (
                    (active_v[t*N_per_tree + pow(2,d) - 1 + p + 1] != 0) -> (x[second[active_v[t*N_per_tree + pow(2,d) - 1 + p + 1]]] = false)
                  )
                )
              );

%constraint forall(t in 0..(T-1)) (
%              forall (d in (D-1)..(D-1)) (
%                forall (p in 0..(pow(2,d) - 1)) (
%                  trace("\(t*N_per_tree + pow(2,d) - 1 + p + 1)\n" , true)
%                  )
%                )
%              );
%constraint false;

% Done
constraint forall(v in 0..V-1) (Done[v] = false);
constraint Done[V] = true;
%constraint forall(v in Done) (
%            trace("\(v)\n", x[v]= false)
%%            x[v] = false
%          );
          
% dfs
constraint forall(n in NODES) (
            dfs_max >= dfs_lvl[active_v[n]]
          );

constraint forall(n in NODES) (
            dfs_min <= dfs_lvl[active_v[n]]
          );


constraint dfs_max = max([dfs_lvl[active_v[n]] | n in NODES]);
constraint dfs_min = min([dfs_lvl[active_v[n]] | n in NODES where active_v[n] != 0]);

output [ "active_v = \(active_v)\n",
      "total_active_vertices = \(total_active_vertices) \n"
    ];
