# World Action Script (was)  
Version: 1  
Licenses: code: LGPL-2.1, media: CC BY-SA-4.0

in game programing, not in lua

---

#### =====DATA TYPES===== 
bool		true	false  
number		0	123.456	-5
string		"asd 134"  
var		string	number	function	var	bool  
function	pos(1 2 a)  
symbol		! (nil) ? (username)  

#### =====VARIABLE=====  
a variable can only be set to 1 thing at time  

varname		a variable  
varname =	set variable value  
example_var =	"string" 123.54 false var function() symbol  
global varname		stored in user memory  

a += 5		add 5 if   
a -= 7.8	sub 7.8
a *= 98		multiply
a /= 2		divide
a !=		a = nil (used becaouse you can't set a=nnll )
note the character "-" can mess if it is written together another symbol

**add a node, could be**
node.add(pos( -1 2 34) "default:dirt")

**and...**
c = 34
a = pos(1 2 c)
dirt="default:dirt"
node.add(a dirt)

#### ========IF=======

if(a==b)  
	..code..  
endif  

if(1=="asd" or a~=b and 87.3>=c nor a<=3 not "aasd"==!)  
	..code..  
elseif(b==!)  
	..code..  
elseif(b~=a not c<b)  
	..code..  
else  
	..code..  
endif  

#### ========REGISTRY=FUNCTIONS=======

was.register_function("name"{  
	info="",			--function description  
	privs={},			--required privileges, eg (kick=true,server=true)  
	action=function(arg1,arg2...)	--function  
		return result  
	end  
})  
was.register_function("name"{  
	packed=true,		--inputs all args as table + usedata  
	action=function(args)  
		return result  
	end  
})  

#### ========REGISTRY=SYMBOLS=======  
a symbol are called while calling a function or setting a var  

was.register_symbol("#",function(),"info"  
		return result  
	end  
})  

#### ========USERDATA=======

The user's information are stored in the global variable "was.userdata"  
but is only able while the function / variables are active.  

was.iuserdata(index)	--return indexed active data  
was.ilastuserdata()		--return last index  

was.userdata.data		--the active line  
was.userdata.index		--index of active line  
was.userdata.function_name	--name of active function  
was.userdata.name		--user's name  
was.userdata.var		--all active variabbles  
