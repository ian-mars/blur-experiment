function out = DefaultInput(prompt, default)

prompt = strcat(prompt, sprintf(' (Default is "%s")', default), '\n');
tmp = input(prompt, 's');
if isempty(tmp)
    out = default;
else
    out = tmp;
end

end