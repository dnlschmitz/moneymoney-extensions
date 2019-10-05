Exporter{version          = 1.3,
         format           = "Categories monthly",
         fileExtension    = "csv",
         reverseOrder     = false,
         description      = "Export categories summed up monthly"}

function writeLine(line)
   assert(io.write(line, "\n"))
end

-- called once at the beginning of the export
function WriteHeader (account, startDate, endDate, transactionCount)
    -- initialize global array to store category sums
    categorySums = {}
    _start = os.date('%b %d %Y', startDate)
    _end   = os.date('%b %d %Y', endDate)


    startmonth = tonumber(os.date('%m', startDate))
    startyear = tonumber(os.date('%Y',startDate))

    lastmonth = tonumber(os.date('%m', endDate))
    lastyear = tonumber(os.date('%Y', endDate))

    months ={}

    currentmonth = startmonth
    currentyear = startyear

    months[1] = (tostring(currentyear) .. " " .. string.format("%02d", currentmonth))

    for i = 0, ((12-startmonth)+(lastyear-startyear-1)*12+lastmonth-1) do
            currentmonth = (i+startmonth)%12+1
	    currentyear = startyear + math.floor((i+startmonth)/12)
            months[2+i] =  (tostring(currentyear) .. " " .. string.format("%02d", currentmonth))
    end


    
    writeLine("Category sums from " .. _start .. " to " .. _end .. " (" .. transactionCount .. " transactions).")
    writeLine(os.date("File exported at %c."))
    assert(io.write("Category; "))

    for i, v in ipairs(months) do
	    assert(io.write(v, "; "))
    end
    assert(io.write("\n"))
end


-- called for every booking day
function WriteTransactions (account, transactions)
    -- This method is called for every booking day.
    -- I use it to sum up all the bookings into a global categorySums variable.
    for _,transaction in ipairs(transactions) do

	_month = os.date('%Y %m', transaction.bookingDate)
        categoryName = transaction.category
	
        if categoryName == "" then
          categoryName = "(ohne)"
        end

	if not (categorySums[categoryName]) then
		categorySums[categoryName]={}
	end


        if (categorySums[categoryName][_month]) then
            categorySums[categoryName][_month] =
                categorySums[categoryName][_month] + transaction.amount
        else
            categorySums[categoryName][_month] = transaction.amount
        end
    end
end

function WriteTail (account)

    output = {}
    for i, v in pairs(categorySums) do
	    if not output[i] then 
		    output[i] = {} 
		    CountMonth =0
		    for i,v in ipairs(months) do 
			    CountMonth=CountMonth+1 
		    end
		    for j=1, CountMonth do
			    output[i][months[j]]=0
		    end
	    end
	
    end
   


    for i, v in pairs(categorySums) do

	    for k, v2 in pairs(v) do
		    output[i][k] = categorySums[i][k]
	    end
    end


    for i, v in pairs(output) do

	    -- extract the category name only
	    -- changes "Group A\Group B\Category name" to "Category name"
	    categoryName = string.match(i, "[^\\]+$")
	    assert(io.write(categoryName))

	    for j=1, CountMonth do
   		
		-- change "-39.99 to 39,99
		sum = string.gsub(tostring(v[months[j]] * -1), "%.", ",")
       		
		-- writeLine(categoryName .. ";" .. months[j] .. ";" .. sum)
		assert(io.write("; ", sum))

	    end
	    assert(io.write("\n"))
    
    end
    
end

