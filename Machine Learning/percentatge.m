function [percentatget1,percentatget2,percentatgeflair] = percentatge(orden,typM)

total = numel(orden);

t1= contains(orden(1,:), 'T1')==1;
t2= contains(orden(1,:), 'T2')==1;
flair=contains(orden(1,:), 'FLAIR')==1;

sumt1= sum(t1==1);
percentatget1= (sumt1/total)*100;

sumt2= sum(t2==1);
percentatget2= (sumt2/total)*100;

sumflair= sum(flair==1);
percentatgeflair= (sumflair/total)*100;
   
end

