function [AB,BB,CB,DB] = bilintrans(A,B,C,D,Ts)
%%
a = Ts/2; b = 1; c = -a; d = 1;
%% State-Space Representation
[ra,ca] = size(A);
iidd = inv(a*eye(ra)-c*A);  %(T/2*I + T/2*A)^{-1}           = 2/T(I + A)^{-1}
AB = (b*A-d*eye(ra))*iidd;  %(A-I)2/T(I + A)^{-1}           = 2/T(A-I)(I + A)^{-1}
BB = (a*b-c*d)*iidd*B;      %(T/2+T/2)*2/T(I + A)^{-1}B     = 2(I + A)^{-1}B
CB = C*iidd;                %C 2/T(I + A)^{-1}              = 2/T(I + A)^{-1}
DB = D + c*C*iidd*B;        % D - T/2C (2/T(I + A)^{-1})B   = D - C(I + A)^{-1})B