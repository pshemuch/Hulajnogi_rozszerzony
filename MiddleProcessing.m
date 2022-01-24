%% Middle processing
clc; clear all; close all;

load('Dane');

%   Zapisywanie command window jako plik Etap2.dat
d1file ='C:\Users\Hp\AppData\Roaming\IBM\ILOG\CPLEX_Studio201\workspace\Hulajnogi\Etap2.dat';

% Usuwanie istniejącego pliku Etap2.dat
if exist(d1file, 'file') ; delete(d1file); end
diary(d1file)
diary on

disp('SheetConnection ResultSheet("Excel-Cplex.xlsm");')
disp('stationCap to SheetWrite(ResultSheet,"Etap2_wyniki!A2:A100");')
disp('locationHappiness to SheetWrite(ResultSheet,"Etap2_wyniki!B2:B100");')
disp('demandPart to SheetWrite(ResultSheet,"Etap2_wyniki!C2:C200");')
disp(' ');

% Nazwa arkusza Excela z ktorego skrypt pobiera dane wynikowe etapu 1
Etap1_wyniki = "Etap1_wyniki"; 

% Odczytywanie wyników etapu pierszego z Excela
isStation = readvars(filename,'Range',"A2:A"+num2str(liczba_drog+1),'Sheet',Etap1_wyniki);
alfa = readvars(filename,'Range',"B2:B"+num2str(liczba_drog+1),'Sheet',Etap1_wyniki);
x = readvars(filename,'Range',"C2:C"+num2str(liczba_drog+1),'Sheet',Etap1_wyniki);
y = readvars(filename,'Range',"D2:D"+num2str(liczba_drog+1),'Sheet',Etap1_wyniki);
minHapp = readvars(filename,'Range',"E2:E2",'Sheet',Etap1_wyniki);

disp("AllHulajnogi = "+num2str(all_hulajnogi)+";");
disp(" ");

% Wypisanie krotek typu Location
disp("locations = {");
for i=1:p
    Locations(i)=["<"+Nazwy_lokalizacji(i)+","+num2str(L_wsp(i,1))+","+num2str(L_wsp(i,2))+","+num2str(happiness(i))+...
                ","+num2str(max_dist(i))+","+num2str(zapotrzebowanie(i))+">"];
    disp(Locations(i));
end
Locations = Locations';
disp("};");
disp(" ");

% Wypisanie krotek typu Station
disp("stations = {");
m = 1;
for i=1:liczba_drog
    if isStation(i) > 0
        if alfa(i)<1e-5, alfa(i)=0; end
        Stations(m) = "<" + Routes_plot(i) + "," + num2str(x(i)) + "," + num2str(y(i)) + "," + num2str(max_Size(i)) + ">";
        disp(Stations(m))
        liczba_stacji = m;
        m = m+1;
    end
end


disp("};");
disp(" ");

% Odległości pomiędzy lokalizacjami i stacjami
D = zeros(p,liczba_stacji);

disp("distances = {");
k = 1;
% Wypisanie krotek typu ShortestDistance
for i=1:p
m = 1;
    for j=1:liczba_drog
        if isStation(j) > 0
            D(i,m)=f([L_wsp(i,1) L_wsp(i,2)], [x(j) y(j)]);
            
            D_L_to_S(i,m)=["<<"+Nazwy_lokalizacji(i)+","+num2str(L_wsp(i,1))+","+num2str(L_wsp(i,2))+","+num2str(happiness(i))+...
                            ","+num2str(max_dist(i))+","+num2str(zapotrzebowanie(i))+">, <"+Routes_plot(j)+","+num2str(x(j))+...
                            ","+num2str(y(j))+","+num2str(max_Size(j))+">, "+num2str(D(i,m))+">"];
            disp(D_L_to_S(i,m));
            D_L_to_S_col(k) = D_L_to_S(i,m);
            m = m+1;
            k = k+1;
        end
    end
end

D_L_to_S_col = D_L_to_S_col';


disp("};");

diary off

save('Dane_2');
close all;