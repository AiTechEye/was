# World Action Script (was)  
Version: 1  
Licenses: code: LGPL-2.1, media: CC BY-SA-4.0

in game programing, not in lua


# more necessary changes are on the go, so dont use this is in projects yet, only testing
progress:

[x] make procceses local  
[x] digiline support  
[x] use own wire  
[x] mesecons support  
[x] pipeworks support  
[ ] make sure everything works  
[40%] add/change tables, eg a.b =   or a.b.c.d="string" etc...  
[50%] make event system works  


---



<details><summary>DATA TYPES</summary>
	
|Type|examples|examples|examples|examples|
|---------------|-----------|-|-|-|
|bool		|true	|false
|number		|0	|123.456	|-5
|string		|"asd 134"  
|var		|string	|number	|function	|var	|bool  
|function	|pos(1 2 a)  
|symbol		|! |(nil) |? |(username)  
</details>

<details><summary>VARIABLES</summary>
a variable can only be set to 1 thing at time

|example        |-|-|-|-|-|-|
|---------------|-|-|-|-|-|-|
|varname	|a variable|
|var_aa =	|set variable value|
|another_var =	|"string"| 123.54| false |var |function()| symbol|
|vara = varb	|set to another var|
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
