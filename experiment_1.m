close all;
clear all;
sca;

% ask for subject id, defaulting to 'nobody'
subjectID = DefaultInput('Subject ID: ', 'nobody');
fPath = strcat('data/', subjectID, '_responses.mat');

% if data has already been gathered, load it
if exist(fPath, 'file') == 2
    load(fPath);
else  % if this is a new subject, create the file object we'll want to save
    file.subjectID = subjectID;
    file.responseDict = containers.Map();
    file.stimulusList = ['a', 'b', 'c', 'd'];  % TODO grab big list of files to load instead
end

saveData(file);

PsychDefaultSetup(2);
%skip sync test to work with my computer
% Screen('Preference', 'SkipSyncTests', 1); 

screenNumber = max(Screen('Screens'));

%set white, grey, and black
white = WhiteIndex(screenNumber);
grey = white / 2;
black = BlackIndex(screenNumber);

%open screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey,...
    [], 32, 2,[], [],  kPsychNeed32BPCFloat);

%get screen size
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

%flip to clear
Screen('Flip', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Set the text size
Screen('TextSize', window, 40);

% Query the maximum priority level
topPriorityLevel = MaxPriority(window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% % Set up alpha-blending for smooth (anti-aliased) lines
% Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');



%-------------------------------------
%create stimuli and response vectors
%-------------------------------------

%get image directory
im_names = dir('~/Desktop/blur_stimuli/*.png');
%create stimulus vector of randomized numbers
im_nums = 1:length(im_names);
im_nums = Shuffle(im_nums);



% %number of trials
% numRepeats = 10;
% 
% %create stimulus vector
% stimuli = ['a', 'b', 'c', 'd'];
% stimVect = Shuffle(repmat(stimuli, 1, numRepeats));
% 
% %response vector
% respVect = zeros(1, 4);
% 
% %vector to count # of times stimulus is presented
% countVect = zeros(1, 4);





%Timing information

% Presentation Time in seconds and frames
presTimeSecs = 0.2;
presTimeFrames = round(presTimeSecs / ifi);

% Interstimulus interval time in seconds and frames
isiTimeSecs = 1;
isiTimeFrames = round(isiTimeSecs / ifi);

% Numer of frames to wait before re-drawing
waitframes = 1;





% %keyboard info
% 
% a = KbName('a');
% b = KbName('b');
% c = KbName('c');
% d = KbName('d');
% escape = KbName('ESCAPE');





%Experimental Loop

for trial = 1:length(im_nums)
    
    %stim = stimVect(trial);
    theImage = imread(strcat('~/Desktop/blur_stimuli/', im_names(im_nums(trial)).name));
    
    
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    if trial == 1
        DrawFormattedText(window, 'Press Any Key To Begin', 'center', 'center', black);
        Screen('Flip', window);
        KbStrokeWait;
    end
    
    Screen('DrawDots', window, [xCenter; yCenter], 10, black, [], 2);
    vbl = Screen('Flip', window);
    
    for frame = 1:isiTimeFrames - 1

        % Draw the fixation point
        Screen('DrawDots', window, [xCenter; yCenter], 10, black, [], 2);

        % Flip to the screen
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
    end
    
    for frame = 1:presTimeFrames

%         % Set the right blend function for drawing the gabors
%         Screen('BlendFunction', window, 'GL_ONE', 'GL_ZERO');
%         
%         Screen('TextSize', window, 80);
%         DrawFormattedText(window, stim, 'center', 'center', white);
        Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
        %make image texture
        imTex = Screen('MakeTexture', window, theImage);
        %draw texture
        Screen('DrawTexture', window, imTex, [], [], 0);
        
        
%         Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
%         
%         Screen('DrawDots', window, [xCenter; yCenter], 10, black, [], 2);
% 
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        
    end
     
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    Screen('DrawDots', window, [xCenter; yCenter], 10, black, [], 2);

    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

    respToBeMade = true;
    while respToBeMade
       [keyIsDown,secs, keyCode] = KbCheck;
       if keyCode(escape)
           saveData(file);
           ShowCursor;
           sca;
           return
%        elseif keyCode(a)
%            if stim == 'a'
%                response = 1;
%                respToBeMade = false;
%            else
%                response = 0;
%                respToBeMade = false;
%            end
%        elseif keyCode(b)
%            if stim == 'b'
%                response = 1;
%                respToBeMade = false;
%            else
%                response = 0;
%                respToBeMade = false;
%            end
%        elseif keyCode(c)
%            if stim == 'c'
%                response = 1;
%                respToBeMade = false;
%            else
%                response = 0;
%                respToBeMade = false;
%            end
%        elseif keyCode(d)
%            if stim == 'd'
%                response = 1;
%                respToBeMade = false;
%            else
%                response = 0;
%                respToBeMade = false;
%            end
%        end
    end
    
    if stim == 'a'
        respVect(1) = respVect(1) + response;
        countVect(1) = countVect(1) + 1;
    elseif stim == 'b'
        respVect(2) = respVect(2) + response;
        countVect(2) = countVect(2) + 1;cd
    elseif stim == 'c'
        respVect(3) = respVect(3) + response;
        countVect(3) = countVect(3) + 1;
    else
        respVect(4) = respVect(4) + response;
        countVect(4) = countVect(4) + 1;
    end
end

saveData(file);
sca;


