# MemoryUse
Iron Scripter Challenge Jan 20, 2021
This is my response to https://ironscripter.us/a-memory-reporting-challenge/

I started with MemUse.ps1 with a goal of meeting the requirements in "one" piped command.  I modified the requirements somewhat as the challenge has the output by process name. The problem with processname is that 2 different executables could create processes with the same name.  I see this in threat hunting when malicious files are executed as a process with a legitimate name like "explorer" but when you look at the executable path it is coming from a different location than the legitimate "explorer.exe".

My next step is to work the bonus requirements in functions.  I'll make one with a "Get" verb which will not do any formatting/sorting etc. as I believe "Get" cmdlets should return raw data.  The other function will be a "Show" function that will do the same processing as the "Get" maybe just call it, but format/sort etc.
