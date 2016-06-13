medit = VarName1;

data_split = ones(5,300);
n = 1;

while n<=5
    data_split(n,:)=medit(((n-1)*300)+1:n*300,:);  
    
    n = n+1;
end
