close all;
clear all;
sca;
develop_mode = false;
if develop_mode
    stereoMode = 0;
    skipTests = 1;
    shouldMirrorReverse = false;
else
    stereoMode = 4;
    skipTests=0;
    shouldMirrorReverse = true;
end

try
%get image directory
im_names = dir('~/Desktop/blur_stimuli/*.png');
im_nums = 1:length(im_names);
% ask for subject id, defaulting to 'nobody'
subjectID = defaultInput('Subject ID: ', 'nobody');
fPath = strcat('data/', subjectID, '_responses.mat');

% if data has already been gathered, load it
if exist(fPath, 'file') == 2
    load(fPath);
else  % if this is a new subject, create the file object we'll want to save
    file.subjectID = subjectID;
    file.responseDict = containers.Map();
    file.stimulusList = Shuffle(im_nums);
    file.respNum = 1;
    saveData(file);
end

PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', skipTests);
HideCursor();

screenNumber = max(Screen('Screens'));

%set white, grey, and black
white = WhiteIndex(screenNumber);
grey = white / 2;
black = BlackIndex(screenNumber);

%open screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black,...
    [], 32, 2,stereoMode, [],  kPsychNeed32BPCFloat);

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
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');



%Timing information

% Presentation Time in seconds and frames
presTimeSecs = 2.5;
presTimeFrames = round(presTimeSecs / ifi);

% Interstimulus interval time in seconds and frames
isiTimeSecs = 1;
isiTimeFrames = round(isiTimeSecs / ifi);

% Numer of frames to wait before re-drawing
waitframes = 1;


respIm = imread('responses_image.png');
if shouldMirrorReverse
    respIm(:,:,1) = fliplr(respIm(:,:,1));
    respIm(:,:,2) = fliplr(respIm(:,:,2));
    respIm(:,:,3) = fliplr(respIm(:,:,3));
end

respTex = Screen('MakeTexture', window, respIm);

 %keyboard info
 
 a = KbName('a');
 w = KbName('w');
 s = KbName('s');
 d = KbName('d');
 up = KbName('UpArrow');
 down = KbName('DownArrow');
 left = KbName('LeftArrow');
 right = KbName('RightArrow');
 escape = KbName('ESCAPE');
 space = KbName('SPACE');



%Experimental Loop
currentRespNum = file.respNum;
for trial = 1:length(im_nums)+50

    if file.respNum > length(file.stimulusList)
        saveData(file);
        break
    end

    im_num = file.stimulusList(file.respNum);
    im_name = im_names(im_num).name;
    theImage = imread(strcat('~/Desktop/blur_stimuli/', im_name));
    if shouldMirrorReverse
        theImage = fliplr(theImage);
    end
    
    if trial == 1
        DrawFormattedText(window, 'Press Any Key To Begin', 'center', 'center', white, [], shouldMirrorReverse);
        Screen('Flip', window);
        KbStrokeWait;
    end
    
    if mod(trial, 200) == 0
        DrawFormattedText(window, 'You have seen 200 images. Feel free to take a break.'...
            , 'center', 'center', white, [], shouldMirrorReverse);
        DrawFormattedText(window, 'Press any key to resume', 'center', screenYpixels * .6 , white, [], shouldMirrorReverse);
        Screen('Flip', window);
        KbStrokeWait;
    end
    
    Screen('DrawDots', window, [xCenter; yCenter], 10, black, [], 2);
    vbl = Screen('Flip', window);
    shouldRedoPrevious = false;
    for frame = 1:isiTimeFrames - 1

        % Draw the fixation point
        Screen('DrawDots', window, [xCenter; yCenter], 10, white, [], 2);

        % Flip to the screen
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        [keyIsDown,secs, keyCode] = KbCheck;
        if keyCode(space)
            shouldRedoPrevious = true;
            continue
        end
    end
    
    if shouldRedoPrevious
        file.respNum = currentRespNum - 1;
        shouldRedoPrevious = false;
        continue
    end
    
    %make image texture
    imTex = Screen('MakeTexture', window, theImage);
    for frame = 1:presTimeFrames
        
        %draw texture
        Screen('DrawTexture', window, imTex, [], [], 0);
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        
    end
    Screen('Close', imTex);

    Screen('DrawTexture', window, respTex);

    Screen('TextSize', window, 40);
    
    DrawFormattedText(window, 'Valid Responses:', 'center', screenYpixels * .1, white, [], shouldMirrorReverse);
    
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

    respToBeMade = true;
    while respToBeMade
       [keyIsDown,secs, keyCode] = KbCheck;
       if keyCode(escape)
           saveData(file);
           ShowCursor;
           sca;
           return
       elseif keyCode(a)
           file.responseDict(im_name) = 'a';
           file.respNum = file.respNum + 1;
           respToBeMade = false;
       elseif keyCode(w)
           file.responseDict(im_name) = 'w';
           file.respNum = file.respNum + 1;
           respToBeMade = false;
       elseif keyCode(s)
           file.responseDict(im_name) = 's';
           file.respNum = file.respNum + 1;
           respToBeMade = false;
       elseif keyCode(d)
           file.responseDict(im_name) = 'd';
           file.respNum = file.respNum + 1;
           respToBeMade = false;
       elseif keyCode(up)
           file.responseDict(im_name) = 'up';
           file.respNum = file.respNum + 1;
           respToBeMade = false;
       elseif keyCode(down)
           file.responseDict(im_name) = 'down';
           file.respNum = file.respNum + 1;
           respToBeMade = false;
       elseif keyCode(right)
           file.responseDict(im_name) = 'right';
           file.respNum = file.respNum + 1;
           respToBeMade = false;
       elseif keyCode(left)
           file.responseDict(im_name) = 'left';
           file.respNum = file.respNum + 1;
           respToBeMade = false;
       end
    end
    
    currentRespNum = file.respNum;
    

end

saveData(file);
ShowCursor();
sca;
catch
    sca;
    psychrethrow(psychlasterror);
    error = psychlasterror; error.stack
    ShowCursor;
end


