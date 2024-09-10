% This is the second half of Exercise 3
% as part of the Pocket AI and IoT workshop, 
% debuted at the Grace Hopper Celebration 2019, 
% and presented at the Society of Women Engineers WE19

% Clear all previously collected data and plots
clear m; clearvars -except teamID; close all; clc;

% Add the helper files to your path so that
% you can use them in this file. 
addpath(fullfile(pwd,'helperFiles'));

% Check whether you have licenses for all 
% required products
checkProductLicenses();

%% Enter a team ID
teamID = input('Enter your team ID (1 to 5) and press Return','s');
if isempty(teamID)
    teamID = num2str(randi(5));
    disp(['Your team ID is ' teamID])
end

% Collect data and predict activity
Ex1_CountSteps

% Send the number of steps to ThingSpeak
stepChallengeChannelID = 858241;
stepChallengeWriteAPIKey = '7Y2A9505MA6AT7OP';

dataWritten = false;
while ~dataWritten
    try
        thingSpeakWrite(stepChallengeChannelID,...
                        {teamID, numSteps},...
                        'WriteKey',stepChallengeWriteAPIKey);
        dataWritten = true;
    catch
        pauseFor(randi(10))
    end
end

% Read the total number of steps taken by everyone
% in the last 60 minutes
numMins = 60;
ThisData = thingSpeakRead(stepChallengeChannelID,...
    'Numminutes',numMins,...
    'OutputFormat','table');

% Plot the results of the step challenge
% aggregated for everyone in the room
if ~isempty(ThisData)
    [G, id] = findgroups(ThisData.UserData);
    totalSteps = splitapply(@sum, ThisData.Steps, G);
    
    bar(totalSteps);
    set(gca,'xticklabel',id);
    xtickangle(45)    
    title(sprintf('Twenty Second Step Count Challenge Winners\npast %d minutes', numMins));
    ylabel('# of Steps')

else
    figure
    text(0.5, 0.5, ...
         ['No data collected in the past ' num2str(numMins) ' minutes'],...
         'HorizontalAlignment', 'center')
end
