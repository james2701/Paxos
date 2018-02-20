
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
        {:propose, s, c} ->
            proposals = 
                if s not in proposals do proposals ++ [s, c] else proposals 
                end
            if s not in proposals do 
                if active do
                    spawn Commander, :start, [config, self(), acceptors, replicas, {bnum, s, c}]
                end
            end
            next config, acceptors, replicas, bnum, active, proposals
        {:adpopted, bnum, pvals} ->
            y = pmax {}, pvals
            send self(), y
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
            next config, acceptors, replicas, bnum, active, proposals
    end
    
end

def pmax mylist, pvals do
    {b, s, c} = first(pvals)
    unless List.keymember?(mylist, s, 1) do
        mylist = mylist ++ {b, s, c}
    else
         {b1, s1, c1} = List.keyfind(mylist, s, 1)
         if b > b1 do
             List.keyreplace(mylist, s, 1, {b, s, c})
         end
    end
    pvals = List.delete_at(pvals, 0)
    if length(pvals) == 0 do
        {blist, slist, clist} = DAC.unzip3(mylist)
        List.zip([slist, clist])
    else
        pmax mylist, pvals
    end
end




end # Server

