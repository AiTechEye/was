# World Action Script (was)  
Version: 1  
Licenses: code: LGPL-2.1, media: CC BY-SA-4.0

in game programing, not in lua

---

### =====DATA TYPES===== 
|Type|examples|examples|examples|examples|
|---------------|-----------|-|-|-|
|bool		|true	|false
|number		|0	|123.456	|-5
|string		|"asd 134"  
|var		|string	|number	|function	|var	|bool  
|function	|pos(1 2 a)  
|symbol		|! |(nil) |? |(username)  

### =====VARIABLES=====  
a variable can only be set to 1 thing at time

|example        |-|-|-|-|-|-|
|---------------|-|-|-|-|-|-|
|varname	|a variable|
|var_aa =	|set variable value|
|another_var =	|"string"| 123.54| false |var |function()| symbol|
|global varname	|stored in user memory|
|vara = varb	|set to another var|
|a += 5		|add 5
|a -= 7.8	|sub 7.8
|a *= 98	|multiply
|a /= 2		|divide
|a !=		|a = nil (used becaouse you can't set a=nnll )
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
### ========IF=======
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
### ========FOR=LOOP=======
```lua
start = 3
end = 100
for(start end)
 ..code...
 next
 ```

### ========REGISTRY=FUNCTIONS=======
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
	packed=true,		--inputs all args as table + usedata  
	action=function(args)  
		return result  
	end  
})  
```
### ========REGISTRY=SYMBOLS=======  
a symbol are called while calling a function or setting a var  
```lua
was.register_symbol("#",function(),"info"  
		return result  
	end  
})  
```
### ========USERDATA=======

The user's information are stored in the global variable "was.userdata"  
but is only able while the function / variables are active.  

was.iuserdata(index)	--return indexed active data  
was.ilastuserdata()		--return last index  

was.userdata.data		--the active line  
was.userdata.index		--index of active line  
was.userdata.function_name	--name of active function  
was.userdata.name		--user's name  
was.userdata.var		--all active variabbles  
