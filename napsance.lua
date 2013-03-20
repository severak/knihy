if not arg[1] then
	print "Jedinny parametr je nazev souboru na prezvejkani!"
	return 0
end


local zpracuj=arg[1]
local BACKSLASH = string.byte("\\")
local push = table.insert
local out = {}
local footnotes = {}
local vtextu = false
local whitelines = 0

function foot(match)
	local text = string.match(match, "\\footnote{(.*)}")
	push(footnotes, text)
	return '['..(#footnotes)..']'
end

function skupina(match)
	local text = string.match(match, "{(.+)}")
	if string.match(text, "\\it.*") then
		return '[i]'..text..'[/i]'
	end
	return text
end

function poznamky()
	local max=0
	for num,text in ipairs(footnotes) do
		push(out, string.format("[%d] : %s", num, text))
		max=num
	end 
	if max>0 then
		for i=1,max do
			table.remove(footnotes)
		end
	end
end

for line in io.lines(zpracuj) do
	if vtextu then
		if string.byte(line)==BACKSLASH then
			if string.match(line, "\\emptylines.*") then
				local kolik=string.match(line, "\\emptylines[%d]")
				kolik=tonumber(kolik) or 1
				for i=1,kolik do
					push(out, "")
				end
			elseif string.match(line, "\\chapter{.*}") then
				local chapname = string.match(line, "\\chapter{(.*)}")
				poznamky()
				push(out, '')
				push(out, '[u]'.. chapname ..'[/u]')
			end
		elseif string.match(line, "^%s*$") then
			whitelines = whitelines + 1
		else
			line = string.gsub(line, "\\footnote%b{}", foot)
			line = string.gsub(line, "%b{}", skupina)
			line = string.gsub(line, "(\\[^%s]+)", "")
			line = string.gsub(line, "%s+", " ")
			if whitelines>0 then
				line = '[tab]'..line
			end
			push(out, line)
			whitelines = 0
		end
	elseif string.match(line, "^\\starttext") then
		vtextu = true
	end
end

for i,line in ipairs(out) do
	print(line)
end

