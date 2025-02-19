clear all
close all
clc
%Compensador em atraso de fase
%Dados iniciais
s = tf('s');
K = 820; %Valor do ganho inicial
G = zpk([],[0 -10 -20],K); %FT da planta
zeta = 0.6; % Fator de amortecimento dado pela questão
% Kv = 41 /s (Valor de Kv desejado para um erro 10 vezes menor que o atual)
% Entrada em rampa 360º/s
% Ev= 87.8°
figure(1) %Abre figura 1 
rlocus(G) % Plota o LGR do RD
sgrid(zeta,0) %Plota as retas do fator de amortecimento no LGR
K = rlocfind(G); %Busca o novo valor de K no encontro do LGR e reta do zeta
Kv = dcgain(s*K*G);%Equação de limite para a constante de velocidade
Kv
erro_velocidade = 1/(Kv); %Erro de velocidade
erro_velocidade
% Questão solicita que o erro atual seja reduzida a 1/10 e o valor Kv 10
% vezes maior dado a equação acima;
erro_requerido = (erro_velocidade)/(10); %Erro solicitado pela questão
erro_requerido
Gf = feedback(G*K,1); %FTMF com valor do ganho encontrado no LRG
t = 0:0.1:100; %Vetor tempo

% Projetando o compensador para um erro/10 e um K*10
% Utilizando a equação da constante de erro
% estático temos que (Zc/Pc) = (Kn/Ka)
% com isso encontra-se um valor de Zc = 10*Pc
p = -0.01;
z = 10*p; 
Gc = zpk([z],[p],1); % FT do compensador em atraso de fase
Kvc = dcgain(Gc*G*K*s);% Novo valor de K adimitido por meio
Kvc
%da malha aberta com compensador
erro_compensado = 1/(Kvc); %Erro do compensador com novo valor de ganho
erro_compensado
figure(1) %Abre a figura 
hold on %Segura os dados do gráfico
rlocus(Gc*G*K) %LGR com compensador
sgrid(zeta,0)
legend('Sistema sem compensação','Sistema compensado')
Kc = rlocfind(Gc*G*K); %Novo valor do ganho interceptado
Kc
%entre o a reta zeta e o LRG
Gc = zpk([z],[p],Kc); %FT do compensador com o novo valoro de 
% de ganho Kc
Gfc = feedback(Gc*G,1); %FTMF com compensador
Y_Gfc = lsim(Gfc,t,t); % Rampa aplicada a FTMF com compensador
Y_Gk = lsim(Gf,t,t); % Rampa aplicada a FTMF
figure(2) %Abre a figura 2
hold on %Segura os dados

plot(t,t) %Plota a rampa
plot(t,Y_Gk) %Saida do sistema original com ganho K
plot(t,Y_Gfc) %Saída do sistema com compensador de atraso de fase 
grid
legend('Rampa de referência','Saída da planta com ganho K','Saída do sistema compensado')

