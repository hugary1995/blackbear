function [d,v] = KLexpansion(Lc1,Lc2,X,Y,Np,tol)
%%

disp('------------------------------------------------')

%% Correlation function

C = @(tau, Lc) exp(-pi*tau^2/4/Lc^2);

%% Correlation matrix

disp('setting up correlation matrix...')
R = zeros(Np);

for i = 1:Np
    fprintf('%d/%d\n',i,Np);
    for j = i+1:Np
        tau1 = abs(X(i)-X(j));
        tau2 = abs(Y(i)-Y(j));
        R(i,j) = C(tau1,Lc1)*C(tau2,Lc2);
    end
end

R = R+R'+eye(Np);

%% Find KL basis

disp('solving for eignevalues and associated KL basis...')

[V,D] = eig(R);
[d,ind] = sort(diag(D),'descend');
v = V(:,ind);

nu = 0;
err = 1;
R_trace = trace(R);
while err > tol
    nu = nu + 1;
    err = 1 - sum(d(1:nu))/R_trace;
end

d = d(1:nu);
v = v(:,1:nu);

fprintf('need %d eigenpairs to reach a tolerance of %.2f%%\n',nu,tol*100);

%% end

disp('------------------------------------------------')

end