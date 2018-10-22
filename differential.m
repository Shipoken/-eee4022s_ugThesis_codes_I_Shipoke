%% SHPISA003        2018 - 09 - 25
% Isai Shipoke      shpisa003@myuct.ac.za
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% I am using LaTEX text editor
set(0,'defaulttextinterpreter','Latex');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear a;
% make sure to use the right COM port
a = arduino('com14','Nano3','libraries','ExampleLCD/LCDAddon','ForceBuild',true);                                  
a.writeDigitalPin('D9',1);              % Tihs is for setting the green LED ON
a.writeDigitalPin('D10',0);             % Tihs is for setting the green LED OFF
TH1 = 0.012;                            % set the threshold

% Partition the modal current signal into time and data series
time = Vm(:,1); 
data = Vm(1:length(time),2);
lev = 1;                                % decomposition level
len =  length(data);                

tic;                                    % timing the DWT fault detection method
[cA1,cD1] = dwt(data,'db4',lev);        % decomposition to level one
d1 = upcoef('d',cD1,'db4',lev,len);     % detail coefficients extraction
d1(1:7) = 0; d1(2995:3001) = 0;

amplitude = abs(d1);
mag = amplitude(:,1);                   % magnitude of the detail components

highest = max(mag);
index = find(amplitude==highest);
fault_time = time(index);

if highest > TH1
    a.writeDigitalPin('D8',1);          % This is for breaker tripping signal
    toc;                                % This is to view the elapse time
    a.writeDigitalPin('D9',0);          % Tihs is for setting the green LED OFF
    a.writeDigitalPin('D10',1);         % Tihs is for setting the red LED ON

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    faultIdCode(mag,Ia,Ib,Ic,lcd);      % go to the fault identification code
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
else
    printLCD(lcd,'The DWT Analysis');
    printLCD(lcd,'Found No Fault');
    
    
    
    %% plot some graphs for explanation
    figure(1)
    for k=1:length(data)
        if abs(data(k))<2e-4
            data(k) = 0;
        end
    end
    subplot(3,1,1); plot(time,data);
    title('Modal Current'); 
    xlabel('time(s)'); 
    ylabel('(A)'); 
    grid;

    for k=1:length(d1)
        if abs(d1(k))<2e-4
            d1(k) = 0;
        end
    end
    subplot(3,1,2); plot(time,d1);      % plot(time(1:414),d1);
    title('Detail Coefficients at Level 1');
    xlabel('time(s)'); ylabel('(A)');
    grid;

    for k=1:length(amplitude)
        if abs(amplitude(k))<2e-4
            amplitude(k) = 0;
        end
    end
    subplot(3,1,3); plot(time,amplitude);
    title('d1 Absolute Value');
    xlabel('time(s)'); ylabel('(A)');
    grid;
end