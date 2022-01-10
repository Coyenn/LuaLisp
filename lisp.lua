function split(str, sep)
    local result = {}
    local regex = ("([^%s]+)"):format(sep)

    for each in str:gmatch(regex) do
        table.insert(result, each)
    end

    return result
end

function parse(program)
    return read_from_tokens(tokenize(program))
end

function tokenize(program)
    local replacedParenthesesOpen = string.gsub(program, '[(]', ' ( ')
    local replacedParenthesesClose = string.gsub(replacedParenthesesOpen, '[)]', ' ) ')

    return split(replacedParenthesesClose, ' ')
end

function read_from_tokens(tokens)
    if not(type(tokens) == "table") or #tokens == 0 then
        error("Unexpected EOF while reading")
    end

    local token = table.remove(tokens, 1)

    if token == '(' then
        local body = {}

        while not(tokens[1] == ')') do
            table.insert(body, read_from_tokens(tokens))
        end

        table.remove(tokens, 1)

        return body
    elseif token == ')' then
        error('Unexpected )')
    else
        return token
    end

    return tokens
end

local VMfunctions = {
    ["print"] = {
        ["raw"] = function(args)
            print(args[1])
        end
    },
    ["add"] = {
        ["raw"] = function(args)
            print(args[1] + args[2])
        end
    }
}

function run(program)
    local tokens = parse(program)

    function runScope(scope)
        for _, value in ipairs(scope) do
            if type(value) == "table" then
                runScope(value)
            else
                for VMfunctionsIndex, _ in pairs(VMfunctions) do
                    if VMfunctionsIndex == value then
                        local args = {}

                        for i, v in ipairs(scope) do
                            if not(v == value) then
                                table.insert(args, v)
                            end
                        end

                        VMfunctions[tostring(value)]["raw"](args)
                    end
                end
            end
        end
    end

    runScope(tokens)
end

local program1 = '(add 1 1)'
local program2 = '(print Hello_World)'

run(program1)
run(program2)
