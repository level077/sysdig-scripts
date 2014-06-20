description = "Trace network I/O"
short_description = "Trace network I/O"
category = "Performance"

args = 
{
	{
		name = "port",
		description = "port",
		argtype = "string",
	},
	{
		name = "min_msec",
        	description = "minimum millisecond threshold for showing network I/O",
        	argtype = "int"
	}
}

require "common"
terminal = require "ansiterminal"
terminal.enable_color(true)

function on_set_arg(name,val)
	if name == "port" then
		port = val
	elseif name == "min_msec" then
		min_msec = tonumber(val)
	end
	return true
end

function on_init()
	frawtime = chisel.request_field("evt.rawtime")
	fprocname = chisel.request_field("proc.name")
	ftype = chisel.request_field("evt.type")
	fdir = chisel.request_field("evt.dir")
	fname = chisel.request_field("fd.name")
	fbuff = chisel.request_field("evt.arg.data")
	fdate = chisel.request_field("evt.datetime")
	fisread = chisel.request_field("evt.is_io_read")

	sysdig.set_snaplen(500)

	chisel.set_filter("fd.type=ipv4 and evt.dir=< and evt.is_io=true and fd.port="..port)
	--chisel.set_event_formatter("%evt.arg.data")
	return true
end

temp = {}

function on_event()
	frt = evt.field(frawtime)
	fpn = evt.field(fprocname)
	ft = evt.field(ftype)
	fd = evt.field(fdir)
	fn = evt.field(fname)
	fb = evt.field(fbuff)
	isread = evt.field(fisread)
	fdt = evt.field(fdate)
	if not isread then
		temp[fn] = {rawtime=frt,procname=fpn,["type"]=ft,dir=fd,["fb"]=fb}
	else
		if temp[fn] then
			lat = (frt - temp[fn]["rawtime"])/1000000
			if lat > min_msec then
				print(string.format("%s %-23s %-12d %-10s %-10s %-23s %-23s %-23s",terminal.red,fdt,lat,fpn,ft,fd,fn,temp[fn]["fb"]))
			else
				print(string.format("%s %-23s %-12d %-10s %-10s %-23s %-23s %-23s",terminal.blue,fdt,lat,fpn,ft,fd,fn,temp[fn]["fb"]))
			end
			temp[fn] = nil
		end
	end
	return true
end
