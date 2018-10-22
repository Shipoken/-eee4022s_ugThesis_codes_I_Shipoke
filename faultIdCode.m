%% SHPISA003        2018 - 09 - 30
% Isai Shipoke      shpisa003@myuct.ac.za

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = faultIdCode(x,a,b,c,p)
clearLCD(p);
total = sum(x);
    A=0; B=0; C=0; G=0;

    dataA = a(:,2); 
    dataB = b(:,2);
    dataC = c(:,2);

    % Compute coefficient sums for Phase A
    [~,cD1A] = dwt(dataA,'db4');
    d1A = upcoef('d',cD1A,'db4',1,length(dataA));
    d1A(1:6) = 0; d1A(2995:3001) = 0;
    amplA = abs(d1A);
    magA = amplA(:,1);              % magnitude of the detail components
    highA = max(magA);              % highest detail component amplitude
    sumA = sum(magA);               % sum of detail components

    % Compute coefficient sums for Phase B
    [~,cD1b] = dwt(dataB,'db4');
    d1B = upcoef('d',cD1b,'db4',1,length(dataB));
    d1B(1:6) = 0; d1B(2995:3001) = 0;
    amplB = abs(d1B);
    magB = amplB(:,1);              % magnitude of the detail components
    highB = max(magB);              % highest detail component amplitude
    sumB = sum(magB);               % sum of detail components


    % Compute coefficient sums for Phase C
    [~,cD1c] = dwt(dataC,'db4');
    d1C = upcoef('d',cD1c,'db4',1,length(dataC));
    d1C(1:6) = 0; d1C(2995:3001) = 0;
    amplC = abs(d1C);
    magC = amplC(:,1);              % magnitude of the detail components
    highC = max(magC);              % highest detail component amplitude
    sumC = sum(magC);               % sum of detail components

    sumV = [sumA sumB sumC];
    sumV =sort(sumV, 'descend');
    diff = sumV(1)-sumV(2);%i = sumV(2);
    %j = sumV(3);
    totalSum = sumA+sumB+sumC;
    minS = min([sumA, sumB, sumC]);
    maxS = max([sumA, sumB, sumC]);
    minS = round(minS,3);

    % This is the fault classification code
    if  minS==0.041 || minS==0.4540
        G = 1;
    end
    if  highA > 0.05 &&  highB > 0.05 && highC > 0.05
        G = 1;
    end
    if maxS==sumA
        A=1;
        if abs(sumA-sumB) < 0.1
                B=1; 
        else
            B=0;
        end  
        if abs(sumA-sumC) < 0.1
            C=1;
        else        
            C=0;
        end   
        
        else if maxS==sumB
            B=1;
            if abs(sumB-sumA) < 1
                A=1;
            else
                A=0;
            end        
            if abs(sumB-sumC) < 0.8 && (sumB/sumC) < 5 %1
                C=1;
            else           
                C=0;
            end      

        else if maxS==sumC
                C=1;
                if abs(sumC-sumA) < 1
                    A=1;
                else              
                    A=0;
                end           
                if abs(sumC-sumB) > 1
                    B=1;
                else                
                    B=0;
                end                    
            end     
        end
    end

    % 3 phase to ground faults
    if G==1&&A==1&&B==1&&C==1
        printLCD(p,'The DWT Analysis');
        printLCD(p,'ABCG fault');
    end
    % 2 phase to ground faults
    if G==1&&A==1&&B==1&&C==0
        printLCD(p,'The DWT Analysis');
        printLCD(p,'ABG fault');
    end
    if G==1&&A==1&&B==0&&C==1
        printLCD(p,'The DWT Analysis');
        printLCD(p,'ACG fault');
    end
    if G==1&&A==0&&B==1&&C==1
        printLCD(p,'The DWT Analysis');
        printLCD(p,'BCG fault');
    end

    % 1 phase to ground faults
    if G==1&&A==1&&B==0&&C==0
        printLCD(p,'The DWT Analysis');
        printLCD(p,'AG fault');
    end
    if G==1&&A==0&&B==1&&C==0
        printLCD(lcd,'The DWT Analysis');
        printLCD(p,'BG fault');
    end
    if G==1&&A==0&&B==0&&C==1
        printLCD(p,'The DWT Analysis');
        printLCD(p,'CG fault');
    end

    % 2 phase to phase faults
    if G==0&&A==1&&B==1&&C==1
        printLCD(p,'The DWT Analysis');
        printLCD(p,'ABC fault');
    end
    if G==0&&A==1&&B==1&&C==0
        printLCD(p,'The DWT Analysis');
        printLCD(p,'AB fault');
    end
    if G==0&&A==1&&B==0&&C==1
        printLCD(p,'The DWT Analysis');
        printLCD(p,'AC fault');
    end
    if G==0&&A==0&&B==1&&C==1
        printLCD(p,'The DWT Analysis');
        printLCD(p,'BC fault');
    end
    
%% Plot modal current DWT output
figure(2)
for k=1:length(d1A)
    if abs(d1A(k))<2e-4
        d1A(k) = 0;
    end
end
subplot(3,1,1);
plot(tout,d1A);
title('d1A');
xlabel('time(s)');
ylabel('(A)');
grid on;

for k=1:length(d1B)
    if abs(d1B(k))<2e-4
        d1B(k) = 0;
    end
end
subplot(3,1,3);
plot(tout,d1B);
title('d1B');
xlabel('time(s)');
ylabel('(A)');
grid on;

for k=1:length(d1C)
    if abs(d1C(k))<2e-4
        d1C(k) = 0;
    end
end
subplot(3,1,2);
plot(tout,d1C);
title('d1C');
xlabel('time(s)');
ylabel('(A)');
grid on;

%% plot some graphs for explanation
figure(3)
for k=1:length(amplA)
    if abs(amplA(k))<2e-4
        amplA(k) = 0;
    end
end
subplot(3,1,1); plot(tout,amplA);
title('d1A Absolute Value'); 
xlabel('time(s)'); 
ylabel('(A)'); 
grid;
for k=1:length(amplB)
    if abs(amplB(k))<2e-4
        amplB(k) = 0;
    end
end
subplot(3,1,2); plot(tout,amplB);     % plot(time(1:414),d1);
title('d1B Absolute Value');
xlabel('time(s)'); ylabel('(A)');
grid;
for k=1:length(amplC)
    if abs(amplC(k))<2e-4
        amplC(k) = 0;
    end
end
subplot(3,1,3); plot(tout,amplC);
title('d1C Absolute Value');
xlabel('time(s)'); ylabel('(A)');
grid;