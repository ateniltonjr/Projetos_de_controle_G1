%   Projeto 1 - Grupo 1 - Controle e Servomecanismos - 5024.2
% Projeto de um compensador

clear all
close all
clc

% Função de transferência do ramo direto com polo na origem
g = zpk([], [0 -10 -70], 1);

% Especificações
pup = 5; % Máximo percentual de ultrapassagem
Ts = 0.6; % Máximo tempo de assentamento

% Cálculo do coeficiente de amortecimento
zeta = (-log(pup/100))/(sqrt(pi^2+log(pup/100)^2));

% Cálculo de zeta*wn
wn = 4/(Ts*zeta);

% Ponto que deverá pertencer ao LGR
So = -zeta*wn - wn*sqrt(1-zeta^2)*i;

% Arbitrando um zero
z = -6.667;

% Condição de fase
phi1 = 180 - atand(imag(So)/abs(real(So))); 
theta = 90;
phi2 = atand(imag(So)/abs(real(So) + 10));
phi3 = atand(imag(So)/abs(real(So) + 70));
phi4 = 180 + theta - phi1 - phi2 - phi3;

% Localização do polo
p = imag(So)/tand(phi4) - z;

% Adicionando um polo na origem e ajustando para manter estabilidade
gc = zpk([-6.667], [-9.8466], 1); %Inicialmente com ganho unitário, Kc = 0

% Cálculo da condição de módulo para determinar Kc
p1 = 0;
p2 = -10;
p3 = -70;
z1 = -6.667;

% Cálculo das distâncias dos polos e zeros ao ponto So
d_p1 = abs(So - p1); % 9.6603
d_p2 = abs(So - p2); %7.7452
d_p3 = abs(So - p3); % 63.718
d_z1 = abs(So - z1); %6.9913

% Aplicação da condição de módulo
Kc = (d_p1 * d_p2 * d_p3) / d_z1; 
%Kc = 681.9218

% Ajuste do ganho Kc
% FT de malha aberta com compensação
G_mac = (Kc*9.8) * gc * g; %Acressimo de um ganho de 9.8 escolhido empiricamente para atender o requisito de erro

% Plotando o LGR
figure (1)
hold on
rlocus(Kc*g, 'r')
rlocus(G_mac, 'g')
sgrid(zeta, 0)
legend('sem compensador', 'com compensador')
hold off

% Sistema compensado em malha fechada
G_comp = feedback(G_mac, 1);

% Simulação para entrada rampa
t = 0:0.01:10;
rampa = t;

figure (2)
hold on
ylabel('Amplitude')
xlabel('Tempo')
lsim(G_comp, rampa, t);
legend('Resposta do sistema compensado a uma rampa', 'rampa')
hold off

% Resposta ao degrau sem compensador
gf = feedback(g, 1);
figure (3)
ylabel('Amplitude')
xlabel('Tempo')
step(gf)
legend('Resposta ao degrau sem compensador')

% Resposta ao degrau do sistema compensado
figure (4)
ylabel('Amplitude')
xlabel('Tempo')
step(G_comp, 'r')
legend(sprintf('Resposta ao degrau do sistema compensado\nUPP%% = 4.9%%\nTs = 546 ms\nErro = 0.1547'))

% Cálculo do erro em regime estacionário para entrada rampa
Kv = dcgain(G_mac * tf([1 0], [1]));
E_rampa = 1 / Kv;

disp(['O erro em regime estacionário para rampa é ', num2str(E_rampa)]);

if isfinite(E_rampa) && E_rampa < 0.15
    disp('Atende à especificação.');
else
    disp('NÃO atende à especificação de 0.15A.');
end