% Plik generujący wyniki na wykresie i w postaci tabeli, Postprocessing
clc; clear all; close all;

% Zamknięcie otwartych okien typu figure
all_fig = findall(0, 'type', 'figure');
close(all_fig)

load('Dane_2');
% dane = 1;

% Nazwa arkusza Excela z ktorego skrypt pobiera dane wynikowe etapu 2
Etap2_wyniki = "Etap2_wyniki"; 

% Odczytywanie wyników etapu drugiego z Excela
stationCap = readvars(filename,'Range',"A2:A"+num2str(liczba_stacji+1),'Sheet',Etap2_wyniki);
locationHappiness = readvars(filename,'Range',"B2:B"+num2str(p+1),'Sheet',Etap2_wyniki);
demandPart = readvars(filename,'Range',"C2:C"+num2str(1+liczba_stacji*p),'Sheet',Etap2_wyniki);

FunkcjaCelu_Etap2 = 0;
for i=1:p
    FunkcjaCelu_Etap2 = FunkcjaCelu_Etap2 + locationHappiness(i);
end

% Rysowanie na wykresie
f1 = figure('Name', 'Lokalizacje i dobrane stacje', 'NumberTitle','off');
hold on; grid on;
f1.Position = [0 125 1200 800];
title('Lokalizacje i dobrane stacje hulajnóg, '+sprintf("M = %i",all_hulajnogi),'FontSize',16);
txt={sprintf("Funkcja celu Etapu 1 = %.1f", minHapp),...
    sprintf("Funkcja celu Etapu 2 = %.1f", FunkcjaCelu_Etap2)};
subtitle(txt);

prescaler_lokalizacji = 70; % do umieszczenia napisów na wykresie
for i=1:p
    
    % Rysowanie punktów zapotrzebowania
    skaler_punktow = 15*p*zapotrzebowanie(i)/sum(zapotrzebowanie,'all');
    if skaler_punktow == 0, skaler_punktow = 0.01; end
    plot(L_wsp(i,1),L_wsp(i,2),'or', 'MarkerSize', skaler_punktow); hold on; grid on; %wielkosci punktów zalezne od zapotrzebowania (i)
    
    % Rysowanie nazw punktów
    if dane ~= 3
        text(L_wsp(i,1),L_wsp(i,2)+2*abs((max(L_wsp(:,2))-(min(L_wsp(:,2)))))/prescaler_lokalizacji,Nazwy_lokalizacji(i),'FontSize',14,'FontWeight','bold');
    else
        text(L_wsp(i,1)+0.0001,L_wsp(i,2)+0.001, Nazwy_lokalizacji(i));
    end
end

%zakresy i nazwy osi
if dane ~= 3
    axis([min(L_wsp(:,1))-1 max(L_wsp(:,1))+1 min(L_wsp(:,2))-1 max(L_wsp(:,2))+1]);
    xlabel('X','FontSize',15);
    ylabel('Y','FontSize',15);
else
    xlim([20.978 21.017]); 
    axis equal;
    xlabel('Długość geograficzna [^o]','FontSize',15);
    ylabel('Szerokość geograficzna [^o]','FontSize',15);
end

Dlugosci = zeros(p,p);
% Rysownie dróg
for i=1:p
    for j = 1:p
        if drogi(i,j) > 0
            plot([L_wsp(i,1),L_wsp(j,1)],[L_wsp(i,2), L_wsp(j,2)],'r'); hold on;
        end
    end
end

prescaler_stacji = 100;
m = 1;
% Umieszczanie stacji hulajnóg na wykresie
for i=1:liczba_drog
    if isStation(i) > 0
        if alfa(i)<1e-5, alfa(i)=0; end
        if abs(x(i))<1e-5, x(i)=0; end
        if abs(y(i))<1e-5, y(i)=0; end
        skaler_drog = 30*liczba_stacji*stationCap(m)/sum(stationCap,'all');
        plot(x(i),y(i),'.b', 'MarkerSize',skaler_drog); hold on
        text(x(i)-2*abs((max(L_wsp(:,1))-(min(L_wsp(:,1)))))/prescaler_stacji, y(i)-1*abs((max(L_wsp(:,1))-(min(L_wsp(:,1)))))/prescaler_stacji, sprintf("%i",m),'Color','b','FontSize',12)
        m = m+1;
    end
end

f2 = uifigure('Name', 'Parametry stacji', 'NumberTitle','off');
f2.Position = [1202 640 717 339];

% Tabela z informacjami o stacjach
m = 1;
for i=1:liczba_drog
    if isStation(i) > 0
        if dane ~= 3        
            X(m) = sprintf("%.2f",x(i));
            Y(m) = sprintf("%.2f",y(i));
        else
            X(m) = sprintf("%.4f",x(i));
            Y(m) = sprintf("%.4f",y(i));
        end
        numer(m) = sprintf("%i",m);
        Alfa(m) = sprintf("%.2f",alfa(i));
        Pojemnosc(m) = sprintf("%i",stationCap(m));
        Nazwy_stacji(m) = Routes_plot(i);
        m = m+1;
    end
end

T_stations = table(Nazwy_stacji',X',Y',Alfa',Pojemnosc','VariableNames',{'Stacja','X', 'Y', 'Alpha',...
    'Pojemność'},'RowNames',numer');
uit1 = uitable(f2,'Data',T_stations{:,:},'ColumnName',T_stations.Properties.VariableNames,...
    'RowName',T_stations.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);
s = uistyle;
s.HorizontalAlignment = 'left';
addStyle(uit1,s); 

% Tabela z informacjami o wykorzystaniu przez lokalizacje poszczegolnych
% stacji
f3 = uifigure('Name', 'Wykorzystanie stacji przez poszczególne lokalizacje', 'NumberTitle','off');
f3.Position = [1202 125 717 483];
m = 1;
for i=1:p
    for j=1:liczba_stacji
        if zapotrzebowanie(i) ~= 0
            Lok(i,j) = [num2str(demandPart(m))+" ("+sprintf("%.0f",demandPart(m)/zapotrzebowanie(i)*100)+"%)"];
        else
            Lok(i,j) = " "; 
        end
        m = m+1;
    end
end

T_lok_stat = table(Lok,'RowNames',Nazwy_lokalizacji);
uit2 = uitable(f3,'Data',T_lok_stat{:,:},'ColumnName',numer,...
    'RowName',T_lok_stat.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);
addStyle(uit2,s); 

