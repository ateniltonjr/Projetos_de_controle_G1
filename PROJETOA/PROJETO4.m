clear all
close all
clc

k = 1;
g = zpk( [], [ -1 -2], 2*k);

% Espicificações:
pup = 5; % Overshoot
Ts = 0.6;
Kv = 0.9;

% CÁLCULOS ...
zeta = (-log(pup/100))/(sqrt(pi^2+log(pup/100)^2));  % Obtendo o coef. de amortecimento zeta
% zeta = 0.69

% Cálculo de zeta*wn
Wn = 4/(Ts*zeta);
% Wn = 9.66 rad/s

% Polo que deve pertencer ao LGR:
So = -zeta*Wn + Wn*sqrt(1 - zeta^2)*i ;
% So = -6.667 + 6.99i
  
% Como o ponto So não pertence ao LGR, deve-se colocar o polo do PI na
% origem e determinar a posição do zero, que vale Kp/Ki

% Condição de fase para determinação do zero
% sum(theta) - sum(phi) = 180°
phi1 = 180 - atand( imag(So) / (real(So) - 2)); % phi1 = 218.89°
phi2 = 180 - atand( imag(So) / (real(So) - 1)); % phi2 = 222.36°
phi3 = 180 - atand( imag(So) / real(So)); % phi1 = 226.36°
theta = phi1 + phi2 + phi3 + 180 -2*360; % Cálculo de theta
% theta = 127.616°

z = real(So) - imag(So)/tand(theta); % Cálculo do polo do PI
% z = -1.28

%Condição de módulo para calcular o KP
dz1 = abs( So - z); % 8.826
dp1 = abs( So - 2); % 11.135
dp2 = abs( So - 1); % 10.37
dp3 = abs( So); % 9.66

Kp = ( dp1 * dp2 * dp3 ) / dz1; 
% Kp = 126.46
Ki = z*Kp; % Isolando Ki, onde z = Ki/Kp
% Ki = 126.46
G_pi = zpk( [Ki/Kp], [0], Kp/190);
gg = g*G_pi;

% Plotando o LGR para determinar KP e KI
figure (1)
hold on
rlocus(g, 'r')
rlocus(gg*( 126/Kp), 'b')
title('Lugar das raízes sem o ganho KP')
legend('LGR sem o controlador', 'LGR com o controlador')
hold off
 
Gf = feedback(gg, 1);
figure (2)
step(Gf)

% Cálculo do erro em regime estacionário para entrada rampa
Kv = dcgain(g*G_pi * tf([1 0], [1]));

disp(['O erro em regime estacionário para rampa é ', num2str(Kv)]);

if isfinite(Kv) && Kv > 0.9
    disp('Atende à especificação.');
else
    disp('NÃO atende à especificação de Kv > 0.9');
end