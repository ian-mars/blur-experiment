function saveData(file)

fPath = strcat('data/', file.subjectID, '_responses.mat');
save(fPath, 'file');

end