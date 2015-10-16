--глобальные переменные
local ee, te, oe, maxf = false, false, false, 0.12
local ce, sbuff		   = 0, ""
local summ, buff 	   = 0, ""
ref_frq 		   = {}
test_frq 			   = {}
graped 				   = {}
result				   = {}
df 				 	   = { 0.001 }
out_name			   = ""
--анализ переданных аргументов
for k,v in pairs(arg) do
	local lua_errors = ""
	if v == "/e" or v == "-e" then
		ef, lua_errors = io.open(arg[k+1])
		if not ef then
			print("ERROR: file name: ", arg[k+1], " is not valid file name or file not found.\n")
			print("LUA_ERROR: ",lua_errors, "\n")
			print("Trying to use std file: reference.txt\n")
			ef = io.open("reference.txt")
			if ef then 
				print("Std reference file found.\n")
				ee = true
			else
				print("ERROR: std file not found. Exiting.\n")
				os.exit()
			end
		end
		ee = true
	elseif v == "/t" or v == "-t" then
		tf, lua_errors = io.open(arg[k+1])
		if not tf then
			print("ERROR: file name: ", arg[k+1], " is not valid file name or file not found.\n")
			print("LUA_ERROR: ",lua_errors, "\n")
			print("Trying to use std file: test.txt\n")
			tf = io.open("test.txt")
			if tf then 
				print("Std test file found.\n")
				te = true
			else
				print("ERROR: std file not found. Exiting.\n")
				os.exit()
			end
		end
		te = true
	elseif v == "/o" or v == "-o" then
		of, lua_errors = io.open(arg[k+1], "w")
		out_name = arg[k+1]
		if not of then
			print("ERROR: file name: ", arg[k+1], " is not valid file name or file not found.\n")
			print("LUA_ERROR: ",lua_errors, "\n")
			print("Trying to use std file: output.txt\n")
			of = io.open("output.txt", "w")
			out_name = "output.txt"
			print("Std output created.\n")
			oe = true
		end
		oe = true
	elseif v == "/f" or v == "-f" then 
		sbuff = arg[k+1]
		sbuff = string.gsub(sbuff, "%,", ".")
		buff, maxf = pcall(tonumber, sbuff)
		if not buff then
			print("ERROR: invalid max frequency: ", arg[k+1], " std frequency 0.12 will be used\n")
			print("LUA_ERROR: ", maxf)
			maxf = 0.12
		end
	end
end
if not oe then
	of = io.open("output.txt", "w")
	out_name = "output.txt"
	print("Std output created.\n")
end
if not te then
	tf = io.open("test.txt")
	if tf then 
		print("Std file found.\n")
	else
		print("ERROR: std file not found. Exiting.\n")
		os.exit()
	end
end
if not ee then
	ef = io.open("reference.txt")
	if ef then 
		print("Std file found.\n")
	else
		print("ERROR: std file not found. Exiting.\n")
		os.exit()
	end
end
--задание диапазона частот
ce = 1
while ce*0.005 <= maxf do
	table.insert(df, 0.005*ce)
	ce = ce + 1
end
--чтение частот опорного приёмника
reference = ef:read()
while reference do
	ce = 0
	ce = string.find(reference, "\t")
	if ce then
		sbuff = string.sub(reference, 1, ce)
		sbuff = string.gsub(sbuff, "%,", ".")
		table.insert(ref_frq, tonumber(sbuff))
	end
	reference = ef:read()
end
--чтение частот тестируемого приёмника
test = tf:read()
while test do
	ce = 0
	ce = string.find(test, "\t")
	if ce then
		sbuff = string.sub(test, 1, ce)
		sbuff = string.gsub(sbuff, "%,", ".")
		table.insert(test_frq, tonumber(sbuff))
		table.insert(graped, false)
	end
	test = tf:read()
end
--подсчёт
for k,v in pairs(df) do
	table.insert(result, 0)
	if not pcall(os.execute, "cls") then
		os.execute("clear")
	end
	print("Ready: ", 100*k/#df)
	for i=1,#ref_frq do
		for j=1,#test_frq do
			if not graped[j] then
				if math.abs(ref_frq[i] - test_frq[j]) < v then
					graped[j] = true
					result[#result] = result[#result] + 1
				end	
			end
		end
	end
end
--вывод результата
for i = 1, #df do
	summ = summ + result[i]/#test_frq
	buff = tostring(summ)
	buff = string.gsub(buff, "%.", ",")
	local write_res, sbuff = of:write(df[i]*1000, "\t", result[i], "\t", buff, "\n")
	local write_c = 0
	while not write_res do
		write_res, sbuff = of:write(df[i]*1000, "\t", result[i], "\t", buff, "\n")
		write_c = write_c + 1
		if write_c > 10 then
			print("ERROR: error occured while writing results to file\n")
			print("Result for df: ", df[i], " will not be in output file\n")
			print("LUA_ERROR: ", sbuff)
			break
		end
	end
end
print("All done, results in: ", out_name, " file.\n")
of:flush()
--закрытие файлов
io.close(ef)
io.close(tf)
io.close(of)
--выход
os.exit()
