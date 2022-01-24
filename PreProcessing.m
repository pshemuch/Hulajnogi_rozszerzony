clear all; clc;

% INSTRUKCJA
% 1. Jako pierwszy wykonać skrypt o nazwie “PreProcessing.m” - skrypt
%     na podstawie danych z Excela wygeneruje plik tekstowy “Etap1alt.dat”.
% 2. Następnie przejść do CPLEX’a i uruchomić konfigurację uruchomienia 
%     o nazwie “Konfiguracja3” - wyniki etapu pierwszego zostaną 
%     wyeksportowane do Excela do arkusza “Etap1_wyniki”.
% 3. Ponownie przejść do Matlab i uruchomić skrypt “MiddleProcessing.m” 
%     - skrypt na podstawie wyników z etapu pierwszego wygeneruje plik 
%     tekstowy “Etap2.dat”.
% 4. Wrócić do CPLEX’a i aktywować konfigurację uruchomienia o nazwie 
%     “Konfiguracja2” - wyniki etapu drugiego również zostaną 
%     wyeksportowane do Excela tym razem do arkusza “Etap2_wyniki”.
% 5. Na koniec w Matlabie uruchomić skrypt “PostProcessing.m”, który na 
%     podstawie zebranych danych narysuje wykres, na którym umieszczone 
%     będą lokalizacje, drogi oraz stacje. Ponadto wygenerowane zostaną 
%     tabele z parametrami poszczególnych stacji oraz tabela informująca 
%     o wykorzystaniu stacji przez poszczególne lokalizacje.

%% Preprocessing
clc

dane = 3; %     należy ustawić 3 jeśli wprowadzamy współrzędne geograficzne
%               w innym przypadku dane = 1;

%   Zapisywanie command window jako plik Etap1alt.dat
dfile ='C:\Users\Hp\AppData\Roaming\IBM\ILOG\CPLEX_Studio201\workspace\Hulajnogi\Etap1alt.dat';

% Usuwanie istniejącego pliku Etap1alt.dat
if exist(dfile, 'file') ; delete(dfile); end
diary(dfile)
diary on

disp('SheetConnection ResultSheet("Excel-Cplex.xlsm");'); 
disp('isStation to SheetWrite(ResultSheet,"Etap1_wyniki!A2:A100");'); 
disp('alfa to SheetWrite(ResultSheet,"Etap1_wyniki!B2:B100");');
disp('x to SheetWrite(ResultSheet,"Etap1_wyniki!C2:C100");');
disp('y to SheetWrite(ResultSheet,"Etap1_wyniki!D2:D100");');
disp('minHapp to SheetWrite(ResultSheet,"Etap1_wyniki!E2:E2");');



% Pobieranie danych z arkusza Excela
filename = 'C:\Users\Hp\AppData\Roaming\IBM\ILOG\CPLEX_Studio201\workspace\Hulajnogi\Excel-Cplex.xlsm';
matlab_read = "Matlab_read"; % Arkusz excela z ktorego skrypt odczytuje dane
p = readvars(filename,'Range',"A3:A3",'Sheet',matlab_read); % liczba lokalizacji
Nazwy_lokalizacji = readvars(filename,'Range',"C3:C"+num2str(p+2),'TextType','string','Sheet',matlab_read); % nazwy
L_wsp(:,1) = readvars(filename,'Range',"D3:D"+num2str(p+2),'Sheet',matlab_read); % współrzędne x
L_wsp(:,2) = readvars(filename,'Range',"E3:E"+num2str(p+2),'Sheet',matlab_read); % współrzędne y
happiness = readvars(filename,'Range',"F3:F"+num2str(p+2),'Sheet',matlab_read); % happiness
max_dist = readvars(filename,'Range',"G3:G"+num2str(p+2),'Sheet',matlab_read); % max_dist
zapotrzebowanie = readvars(filename,'Range',"H3:H"+num2str(p+2),'Sheet',matlab_read); % max_dist
all_hulajnogi = readvars(filename,'Range',"I3:I3",'Sheet',matlab_read); % all hulajnogi
BigConst = readvars(filename,'Range',"M3:M3",'Sheet',matlab_read); % BigConst

for i = 1:p        
    drogi(1:p, i) = readvars(filename,'Range',[3 16+i p+2 16+i],'Sheet',matlab_read); % drogi pomiedzy lokalizacjami
end  

% Obliczanie liczby dróg
suma = 0;
for i=1:p
    for j=1:p
        suma = suma+drogi(i,j);
    end
end
liczba_drog = suma/2;

max_Size = readvars(filename,'Range',"J3:J"+num2str(liczba_drog+2),'Sheet',matlab_read);
max_hulajnogi = readvars(filename,'Range',"L3:L"+num2str(liczba_drog+2),'Sheet',matlab_read); % max_hulajnogi
            
L=containers.Map();
for i=1:p    
    L(string(i))=[L_wsp(i,1),L_wsp(i,2)];
end

% Funkcja liczaca odleglosci miedzy punktami
f = @(x,y) sqrt((y(1)-x(1))^2+(y(2)-x(2))^2);

% Macierz przechowująca odległości między punktami
O = zeros(p,p);

% Obliczanie odległości
for i=1:p
    for j=1:p
        if dane == 3
            O(i,j)=f(L(string(i)),L(string(j)))*111111; % Przeliczenie odległość w stopniach na metry
        else
            O(i,j)=f(L(string(i)),L(string(j)));
        end
    end
end

disp("BigConst = "+num2str(BigConst)+";");
disp(" ");
disp("AllHulajnogi = "+num2str(all_hulajnogi)+";");
disp(" ");
disp("ALLlocations = {");

% Wypisanie krotek typu Location
for i=1:p
    Locations(i)=["<"+Nazwy_lokalizacji(i)+","+num2str(L_wsp(i,1))+","+num2str(L_wsp(i,2))+","+num2str(happiness(i))+...
                ","+num2str(max_dist(i))+","+num2str(zapotrzebowanie(i))+">"];
    disp(Locations(i));
end
Locations = Locations';
disp("};");

Dlugosci = O.*drogi;

k = 1;
m = 1;
Routes(1:p,1:p) = "0" ;
disp(" ");
disp("routes = {");

% Wypisanie krotek typu Route
for i=1:p 
    for j=1:p
        if drogi(i,j)>0 && Routes(j,i) == "0"
            Routes(i,j)=["<"+Nazwy_lokalizacji(i)+"__to__"+Nazwy_lokalizacji(j)+", <"+Nazwy_lokalizacji(i)+","+num2str(L_wsp(i,1))+","+num2str(L_wsp(i,2))+","+num2str(happiness(i))+...
                ","+num2str(max_dist(i))+","+num2str(zapotrzebowanie(i))+">, <"+Nazwy_lokalizacji(j)+","+num2str(L_wsp(j,1))+...
                ","+num2str(L_wsp(j,2))+","+num2str(happiness(j))+","+num2str(max_dist(j))+","+...
                num2str(zapotrzebowanie(j))+">, "+num2str(max_hulajnogi(m))+">"];
            disp(Routes(i,j));
            Routes_plot(m) = Nazwy_lokalizacji(i)+"__to__"+Nazwy_lokalizacji(j);
            Routes_col(m) = Routes(i,j);
            m = m+1;
        end
    end
end

Routes_plot = Routes_plot';
Routes_col = Routes_col';

disp("};");
disp(" ");
disp("distances = {");

% Wypisywanie krotek typu ShortestDistance
m = 1;
for i=1:p
    for j=1:p
        Distances(i,j)=["<<"+Nazwy_lokalizacji(i)+","+num2str(L_wsp(i,1))+","+num2str(L_wsp(i,2))+","+num2str(happiness(i))+...
            ","+num2str(max_dist(i))+","+num2str(zapotrzebowanie(i))+">, <"+Nazwy_lokalizacji(j)+","+num2str(L_wsp(j,1))+...
            ","+num2str(L_wsp(j,2))+","+num2str(happiness(j))+","+num2str(max_dist(j))+","+...
            num2str(zapotrzebowanie(j))+">, "+num2str(O(i,j))+">"];
        disp(Distances(i,j));
        Distances_col(m) = Distances(i,j);
        m = m+1;
    end
end
Distances_col = Distances_col';
disp("};");
disp(" ");

% zapis nazw dróg do Excela
writematrix(Routes_plot, filename, 'Sheet', matlab_read, 'Range', 'K3')

diary off;

save('Dane')