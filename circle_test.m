close all;
clear all;
sca;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

LEFT_BUFFER = 0;
RIGHT_BUFFER = 1;

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;
inc = white - grey;

stereoMode = 4;
%open screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black,...
    [], 32, 2,stereoMode, [],  kPsychNeed32BPCFloat);

Screen('SelectStereoDrawBuffer', window, RIGHT_BUFFER);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

im = imread('~/Desktop/blur_stimuli/concave_horizontal_0_center_0_0.png');

imTex = Screen('MakeTexture', window, im);

Screen('DrawTexture', window, imTex, [], [], 0);

Screen('Flip', window);

KbStrokeWait;

sca;
 
