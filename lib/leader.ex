
# distributed algorithms, n.dulay 2 feb 18
# coursework 2, paxos made moderately complex

defmodule Leader do

def start config, acceptors, replicas do
    bnum = {0, self()}
    active = false
    proposals = []
    spawn Scout, :start, [config, self(), acceptors, bnum]
    next config, acceptors, replicas, bnum, active, proposals
end # start

def next config, acceptors, replicas, bnum, active, proposals do
    receive do
        #{:propose, s, c} ->
            #proposals = 
                #if [ s, _ ] not in proposals do proposals ++ [s, c] else proposals 
                #end
            #if [ s, _ ] not in proposals do 
                #if active do
                    #spawn Commander, :start, [config, self(), acceptors, replicas, {bnum, s, c}]
                #end
            #end
        #{:adpopted, bnum, pvals} ->
            #proposals = proposalsh
        {:preempted, r, lamda} ->
            active = 
                if {r, lamda} > bnum do
                    false
                else
                    active
                end
            bnum = 
                if {r, lamda} > bnum do
                    {r+1, self()}
                else
                    bnum
                end
            if {r, lamda} > bnum do
                spawn Scout, :start, [config, self(), acceptors, bnum]
            end
    end
end

end # Server

