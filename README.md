# World Action Script (was)  
Version: 1  
Licenses: code: LGPL-2.1, media: CC BY-SA-4.0

in game programing, not in lua

---


<details><summary>DATA TYPES</summary>
	
|Type|examples|examples|examples|examples|examples|examples|
|---------------|-----------|-|-|-|-|-|
|bool		|true	|false
|number		|0	|123.456	|-5
|string		|"asd 134"  
|var		|string	|number	|function	|var	|bool|table|  
|function	|pos(1 2 a)  
|symbol		|! |(nil) |? (username)|  
</details>

<details><summary>VARIABLES</summary>
a variable can only be set to 1 thing at time

|example        |-|-|-|-|-|-|
|---------------|-|-|-|-|-|-|
|varname	|a variable|
|var_aa =	|set variable value|
|another_var =	|"string"| 123.54| false |var |function()| symbol|
|vara = varb	|set to another var|
|vara.b =	|set as table|
|vara.1 = 	|variable index 1 set, eg in lua: vara[1] (limeted to root variable)
|event.msg.item	|item from event message|
|a += 5		|add 5
|a -= 4		|sub 4
|a *= 98	|multiply
|a /= 2		|divide
|a !=		|a = nil (used becaouse you can't set a=nll )

note the character "-" can mess if it is written together another symbol

**add a node, could be**
```lua
node.add(pos( -1 2 34) "default:dirt")
```
**and...**
```lua
c = 34
a = pos(1 2 c)
dirt="default:dirt"
node.add(a dirt)
```
you can use "return" to break the currently run
</details>



<details><summary>Saving/load</summary>
Everthing in the "save" variable/table will be automacly saved and loaded, eg:
	
```lua
save.a="asd"
save.unit_users.singleplayer.lpos=get.pos()

if(save.a=="asd")
..code..
end
```
</details>





<details><summary>Events</summary>
Any reasons to the script on the unit is running will be able in the "event" variable, eg: event.type

|event	      |type         |channel|from_channel|msg|
|-------------|-------------|-------|------------|---|
|run by gui   |"gui_run"    |✖      |✖          |✖
|timer        |"timer"      |✖      |✖          |✖
|wire         |"wire"       |✔      |✔          |✔
|digilines    |"digiline"   |✔      |✖          |✔
|msesecons on |"mesecon on" |✖      |✖          |✖
|meseconns off|"mesecon off"|✖      |✖          |✖
|pipeworks    |"pipeworks"  |✖      |✖          |✔ (item,count)
</details>





<details><summary>IF</summary>

```lua
if(a==b)  
	..code..  
endif  
```
```lua
if(1=="asd" or a~=b and 87.3>=c nor a<=3 not "aasd"==!)  
	..code..  
elseif(b==!)  
	..code..  
elseif(b~=a not c<b)  
	..code..  
else  
	..code..  
endif  
```
</details>





<details><summary>FOR LOOP</summary>

```lua
start_n = 3
end_n = 100
for(start_n end_n)
 ..code...
 next
 ```
 max loops is 1000, dont use negative values
use "break" to breat the loop
</details>





<details><summary>REGISTRY FUNCTIONS</summary>

```lua
was.register_function("name"{  
	info="",			--function description  
	privs={},			--required privileges, eg (kick=true,server=true)  
	action=function(arg1,arg2...)	--function  
		return result  
	end  
})  
```
```lua
was.register_function("name"{  
	packed=true,		--inputs all args as table
	action=function(args)  
		return result  
	end  
})  
```
</details>





<details><summary>REGISTRY SYMBOLS</summary>

a symbol are called while calling a function or setting a var  
```lua
was.register_symbol("#",function(),"info"  
		return result  
	end  
})  
```
</details>





<details><summary>USERDATA</summary>

The user's information are stored in the global variable "was.userdata"  
but is only able while the function / variables are active.  

|variable / function|description |
|-------------------|------------|
|was.iuserdata(index)		|return indexed active data|
|was.ilastuserdata()		|return last index|
|was.userdata.data		|the active line|
|was.userdata.index		|index of active line|
|was.userdata.function_name	|name of active function|
|was.userdata.name		|user's name|
|was.userdata.var		|all active variabbles|
|was.userdata.error		|crach and send text message|
</details>
