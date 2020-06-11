
int: Tree;
int: D;
int: N_per_tree= pow(2, D) - 1;
int: N= Tree * N_per_tree;
int : PIPESTAGES= 0;

set of int: NODES = 1..N;
int: V;
set of int: VERTICES= 1..V;

array[VERTICES] of set of VERTICES: successors;
array[VERTICES] of set of VERTICES: predecessors;
int :E;
array[1..E, 1..2] of 1..V: edges;

array[NODES] of set of NODES: first_n;
array[NODES] of set of NODES: second_n;
array[NODES] of 0..N: successor_n;

int: TMAX;

% variables
array [1..V] of var 1..TMAX: T;
array [1..V] of var NODES: v_to_alu_map;
array [NODES, 1..TMAX] of var 0..V: alu_to_v_map;


% pipeline hazard constraint
constraint forall(v in 1..V) (
      forall (s in successors[v]) (
         (T[s] = T[v]) \/ (T[s] > T[v] + PIPESTAGES)
      )
    );

% node constraint within same cycle
constraint forall(e in 1..E) (
    if (T[edges[e, 1]] = T[edges[e, 2]]) then 
      v_to_alu_map[edges[e, 2]] = successor_n[v_to_alu_map[edges[e, 1]]]
    endif
  );

% if an alu is non zero and predecessor alu is also non zero, then
% child-parent relation should be satisfied
constraint  forall(t in 1..TMAX) ( 
        forall(n in NODES) (
            forall (f in first_n[n]) (
              if (alu_to_v_map[n, t] != 0) then
                (alu_to_v_map[f,t] !=0 ) -> (alu_to_v_map[f, t] in predecessors[alu_to_v_map[n, t]])
              endif
            )
          )
       );
constraint  forall(t in 1..TMAX) ( 
        forall(n in NODES) (
            forall (f in second_n[n]) (
              if (alu_to_v_map[n, t] != 0) then
                (alu_to_v_map[f,t] !=0 ) -> (alu_to_v_map[f, t] in predecessors[alu_to_v_map[n, t]])
              endif
            )
          )
       );

% if an alu is 0, but successor_n is not zero, predecessors have to be 0
constraint  forall(t in 1..TMAX) ( 
        forall(n in NODES) (
            if (successor_n[n] != 0) then
              forall (f in first_n[n]) (
                forall (s in second_n[n]) (
                  if ((alu_to_v_map[n, t] = 0) /\ (alu_to_v_map[successor_n[n],
                  t] != 0)) then
                    (alu_to_v_map[f, t] = 0) /\ (alu_to_v_map[s, t] = 0)
                  endif
                )
              )
            endif
          )
       );


% channel constraints between two views
constraint forall(v in 1..V) (alu_to_v_map[v_to_alu_map[v], T[v]] = v);
constraint forall(t in 1..TMAX) (
    forall(n in NODES) (
      if (alu_to_v_map[n, t] != 0) then
        (T[alu_to_v_map[n,t]] = t) /\ (v_to_alu_map[alu_to_v_map[n, t]] = n)
      endif
    )
  );

% break symmetry
constraint forall(t_cycle in 1..TMAX) (
    forall(n in NODES) (
      forall(f in first_n[n]) (
        forall(s in second_n[n]) (
          alu_to_v_map[f, t_cycle] >= alu_to_v_map[s, t_cycle]
        )
      )
    )
  );

% break symmetry within tree tops
include "decreasing_int.mzn";
constraint forall(t_cycle in 1..TMAX) (
    decreasing_int([alu_to_v_map[tr*N_per_tree + 1, t_cycle] | tr in 0..(Tree-1)])
  );

include "alldifferent_except_0.mzn";
constraint forall(t_cycle in 1..TMAX) (
      alldifferent_except_0([alu_to_v_map[n, t_cycle] | n in NODES])
    );

include "cumulative.mzn";
constraint cumulative(T, [1 | v in 1..V], [1 | v in 1..V], N);

include "fzn_at_most_int.mzn";
constraint forall(t in 1..TMAX) (fzn_at_most_int(N, T, t));



solve ::restart_geometric(1.5, 1000) minimize max(T);

%output ["alu_to_v_map = \(alu_to_v_map) \n", 
%  "T= \(max(T))\n" ];
