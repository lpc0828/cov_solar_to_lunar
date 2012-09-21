--#!/usr/bin/env lua
module("cov_solar_to_lunar",package.seeall)

--local bit = require("bit")

--[[
-- lua接口
-- svn: http://svn.corp.qunar.com/svn/flight.qunar.com/lowprice_openresty/branches/zh_20120806/cov_solar_to_lunar
-- author: pengcheng.liu@qunar.com
-- createDate: 2012-08-06
-- function name: cov_solar_to_lunar(solarDate)
-- param: solarDate as "solarYear-solarMonth-solarDay"
-- return lunarDate as "lunarYear-lunarMonth-lunarDay"
--]]



-- 农历每一年每一天信息
--[[说明：
-- 1. 前4bit,前提这一年为闰年才有意义，1为大月，0为小月
-- 2. 中间12bit, 每bit代表一个月，1为大月，0为小月
-- 3. 最后4bit，代表这一年的闰月月份，0不润，与前四位配合使用
--]]
tableDetail = {
--          0x0D954, 0x0D4A0, 0x0DA50, 0x07552, 0x056A0, 0x0ABB7, 0x025D0, 0x092D0, 0x0CAB5,            -- 2001-2009    
--          0x0A950, 0x0B4A0, 0x0BAA4, 0x0AD50, 0x055D9, 0x04BA0, 0x0A5B0, 0x15176, 0x052B0, 0x0A930,   -- 2010-2019  
--          0x07954, 0x06AA0, 0x0AD50, 0x05B52, 0x04B60, 0x0A6E6, 0x0A4E0, 0x0D260, 0x0EA65, 0x0D530,   -- 2020-2029    
--          0x05AA0, 0x076A3, 0x096D0, 0x04BD7, 0x04AD0, 0x0A4D0, 0x1D0B6, 0x0D250, 0x0D520, 0x0DD45,   -- 2030-2039    
--          0x0B5A0, 0x056D0, 0x055B2, 0x049B0, 0x0A577, 0x0A4B0, 0x0AA50, 0x1B255, 0x06D20, 0x0ADA0,   -- 2040-2049
--          0x055b0
{0, {1,1,0,1,1,0,0,1,0,1,0,1}, 4},    --2001
{0, {1,1,0,1,0,1,0,0,1,0,1,0}, 0},    --2002
{0, {1,1,0,1,1,0,1,0,0,1,0,1}, 0},    --2003
{0, {0,1,1,1,0,1,0,1,0,1,0,1}, 2},    --2004
{0, {0,1,0,1,0,1,1,0,1,0,1,0}, 0},    --2005
{0, {1,0,1,0,1,0,1,1,1,0,1,1}, 7},    --2006
{0, {0,0,1,0,0,1,0,1,1,1,0,1}, 0},    --2007
{0, {1,0,0,1,0,0,1,0,1,1,0,1}, 0},    --2008
{0, {1,1,0,0,1,0,1,0,1,0,1,1}, 5},    --2009
{0, {1,0,1,0,1,0,0,1,0,1,0,1}, 0},    --2010
{0, {1,0,1,1,0,1,0,0,1,0,1,0}, 0},    --2011
{0, {1,0,1,1,1,0,1,0,1,0,1,0}, 4},    --2012
{0, {1,0,1,0,1,1,0,1,0,1,0,1}, 0},    --2013
{0, {0,1,0,1,0,1,0,1,1,1,0,1}, 9},    --2014
{0, {0,1,0,0,1,0,1,1,1,0,1,0}, 0},    --2015
{0, {1,0,1,0,0,1,0,1,1,0,1,1}, 0},    --2016
{1, {0,1,0,1,0,0,0,1,0,1,1,1}, 6},    --2017
{0, {0,1,0,1,0,0,1,0,1,0,1,1}, 0},    --2018
{0, {1,0,1,0,1,0,0,1,0,0,1,1}, 0},    --2019
{0, {0,1,1,1,1,0,0,1,0,1,0,1}, 4},    --2020
{0, {0,1,1,0,1,0,1,0,1,0,1,0}, 0},    --2021
{0, {1,0,1,0,1,1,0,1,0,1,0,1}, 0},    --2022
{0, {0,1,0,1,1,0,1,1,0,1,0,1}, 2},    --2023
{0, {0,1,0,0,1,0,1,1,0,1,1,0}, 0},    --2024
{0, {1,0,1,0,0,1,1,0,1,1,1,0}, 6},    --2025
{0, {1,0,1,0,0,1,0,0,1,1,1,0}, 0},    --2026
{0, {1,1,0,1,0,0,1,0,0,1,1,0}, 0},    --2027
{0, {1,1,1,0,1,0,1,0,0,1,1,0}, 5},    --2028
{0, {1,1,0,1,0,1,0,1,0,0,1,1}, 0},    --2029
{0, {0,1,0,1,1,0,1,0,1,0,1,0}, 0},    --2030
{0, {0,1,1,1,0,1,1,0,1,0,1,0}, 3},    --2031
{0, {1,0,0,1,0,1,1,0,1,1,0,1}, 0},    --2032
{0, {0,1,0,0,1,0,1,1,1,1,0,1}, 7},    --2033
{0, {0,1,0,0,1,0,1,0,1,1,0,1}, 0},    --2034
{0, {1,0,1,0,0,1,0,0,1,1,0,1}, 0},    --2035
{1, {1,1,0,1,0,0,0,0,1,0,1,1}, 6},    --2036
{0, {1,1,0,1,0,0,1,0,0,1,0,1}, 0},    --2037
{0, {1,1,0,1,0,1,0,1,0,0,1,0}, 0},    --2038
{0, {1,1,0,1,1,1,0,1,0,1,0,0}, 5},    --2039
{0, {1,0,1,1,0,1,0,1,1,0,1,0}, 0},    --2040
{0, {0,1,0,1,0,1,1,0,1,1,0,1}, 0},    --2041
{0, {0,1,0,1,0,1,0,1,1,0,1,1}, 2},    --2042
{0, {0,1,0,0,1,0,0,1,1,0,1,1}, 0},    --2043
{0, {1,0,1,0,0,1,0,1,0,1,1,1}, 7},    --2044
{0, {1,0,1,0,0,1,0,0,1,0,1,1}, 0},    --2045
{0, {1,0,1,0,1,0,1,0,0,1,0,1}, 0},    --2046
{1, {1,0,1,1,0,0,1,0,0,1,0,1}, 5},    --2047
{0, {0,1,1,0,1,1,0,1,0,0,1,0}, 0},    --2048
{0, {1,0,1,0,1,1,0,1,1,0,1,0}, 0},    --2049
        }

-- 含有闰月的年
tableLeap = {
            2001, 2004, 2006, 2009,
            2012, 2014, 2017,
            2020, 2023, 2025, 2028,
            2031, 2033, 2036, 2039,
            2042,2044, 2047, 
            2050
           }


-- 分隔字符串
function split(str, sep)
    local sep, fields = sep or "\t", {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

-- 得到每个月的天数
function get_solar_month_days(solarYear, curMonth)
    local i = curMonth
    if (i==1 or i==3 or i==5 or i==7 or i==8 or i==10 or i==12) then
        return 31; 
    elseif (i==4 or i==6 or i== 9 or i==11) then
        return 30;
    elseif(i==2) then
        if ((solarYear%4==0 and solarYear%100~=0) or (solarYear%400==0)) then
            return 29;
        else
            return 28;
        end
    end
    return 0;
end


-- 计算阳历从 2001年 到 当日期 的总天数
function get_total_days_from20010124(solarYear, solarMon, solarDay)
    local nDays= 0
    local nYear = 0
    
    nYear = solarYear-2001
    nDays = nYear*365 + math.floor(nYear/4)
    
    --print("sadada"..nDays) 
    for curMonth=1, solarMon-1, 1 do
        --print(curMonth.."==="..nDays.."\n")
        nDays = nDays+get_solar_month_days(solarYear,curMonth) 
        --print("==="..nDays.."\n")
    end
    nDays = nDays-24
    nDays = nDays+solarDay
    --print("nDays="..nDays)
    return nDays
end 


function get_leapYear_days(curYear_detail)
    local nDays = 0
    --print("======"..nDays.."=====") 
    if (curYear_detail[3] ~= 0) then
        if (curYear_detail[1] == 1) then
            nDays = nDays+30
        else
            nDays = nDays+29
        end
    end
    --print("======"..nDays.."=====")
    for i,v in pairs(curYear_detail[2]) do
        --print(i)
        if (v == 1) then
            nDays = nDays+30
        else
            nDays = nDays+29
        end
    end
    --print("======"..nDays.."=====")
    return nDays
end 


function get_Not_leapYear_days(curYear_detail)
    local nDays = 0
    for i,v in pairs(curYear_detail[2]) do
        if (v == 1) then
            nDays = nDays+30
        else
            nDays = nDays+29
        end
    end
    --print("get_Not_leapYear_days("..curYear_detail..")="..nDays)
    return nDays
end 


function get_days(yearValue, isLeap)
    local nDays
    for i,v in pairs(tableDetail) do
        if (i+2000 == yearValue) then 
            if (isLeap) then
               nDays = get_leapYear_days(v)
            else
               nDays = get_Not_leapYear_days(v)   
            end 
            break;
        end
    end
    --print(nDays)
    return nDays
end


function get_Not_leapLunar_month_And_day(table,nLastDays)
    for i,v in pairs(table) do
        if (1 == v) then
            if (nLastDays<=30) then
                return i, nLastDays
            else
                nLastDays = nLastDays-30
            end
        else
            if (nLastDays <= 29) then
                return i, nLastDays
            else
                nLastDays = nLastDays-29
            end
        end
    end
end


function get_leapLunar_month_And_day(table, nLastDays)
    for i,v in pairs(table[2]) do
        if (1 == v) then
            if (nLastDays<=30) then
                return i, nLastDays
            else
                nLastDays = nLastDays-30
            end
        else
            if (nLastDays <= 29) then
                return i, nLastDays
            else
                nLastDays = nLastDays-29
            end
        end
 
        if (i == table[3]) then
            -- 减去闰月时间
            if (1 == table[1]) then
                if (nLastDays<=30) then
                    return i, nLastDays
                else
                    nLastDays = nLastDays-30
                end
            else
                if (nLastDays<=29) then
                    return i, nLastDays
                else
                    nLastDays = nLastDays-29
                end
            end
        end
    end
end


function get_lunar_month_And_day(year, nLastDays)
 
    local isLeap = false;
    for i,v in pairs(tableLeap) do
        if (year == v) then
            isLeap = true
            break
        end
    end
    --print(isLeap)
    table = tableDetail[year-2000]
    if (isLeap) then
        return get_leapLunar_month_And_day(table, nLastDays)
    else
        return get_Not_leapLunar_month_And_day(table[2], nLastDays)
    end
end



-- 获取农历那一年的天数
function get_lunarYear_days(curYear)    
    --print(curYear.."\n")
    for i,v in pairs(tableLeap) do
        --print(i.." == ".. v.."\n")
        if (v == curYear) then
           return get_days(curYear, true)
        end
    end
    --print("return get_days(yearValue, false)")
    return get_days(curYear, false)
end

-- 阳历转成农历
function cov_solar_to_lunar(date)
    --获取阳历日期
    local arg = split(date, "-")
    local solarYear, solarMon, solarDay = arg[1], arg[2], arg[3];
    --print(solarYear, solarMon, solarDay)
    
    local totalDays = get_total_days_from20010124(solarYear, solarMon, solarDay)
       
    -- 计算农历过了几年
    local year
    local temp = 0;
    for i=2001, solarYear, 1 do
        temp = get_lunarYear_days(i)
        --print("totalDays="..totalDays.."   ".."temp="..temp.."\n")
        if (totalDays < temp) then
            year = i
            break
        end
        totalDays = totalDays-temp
        --print("====="..totalDays)
    end
    --print("1=1=1=1="..year.."=="..totalDays)
    local month,day = get_lunar_month_And_day(year, totalDays+1)

    --print(year.."--"..month.."--"..day.."\n")
    if (month<10) then
        month = "0"..month
    end
    if (day<10) then
        day = "0"..day
    end
    return year.."-"..month.."-"..day
end



--cov_solar_to_lunar("2012-09-30")

