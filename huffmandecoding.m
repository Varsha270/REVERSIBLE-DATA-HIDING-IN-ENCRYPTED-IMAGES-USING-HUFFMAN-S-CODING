function [ehcode] = huffmandecoding(Jcode8_Data,hcode)
symbols = unique(Jcode8_Data);
symbols=symbols(1,1:399);
hcode=symbols;
% length(symbols)
prob = (1:length(symbols))/length(symbols);
prob=prob/1000;
Adata=1-sum(prob);
PProb=[prob Adata];
% sum(PProb)
% length(PProb)
symbols1 = [symbols 0];
dict = huffmandict(symbols1,PProb);
ehcode = huffmandeco(symbols1,dict);
disp('Hamming Decoding')
disp(ehcode)
% if(length(symbols)==length(Jcode8_Data))
% else
%     hcode=Jcode8_Data;
% end
end

