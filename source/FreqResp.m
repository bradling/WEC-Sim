function [h,w] = FreqResp(b,a,w)
s = 1i*w;
h = polyval(b,s)./polyval(a,s);